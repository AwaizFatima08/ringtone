package com.homilabs.easyringtone

import android.Manifest
import android.app.Activity
import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.MediaScannerConnection
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.provider.MediaStore
import android.provider.OpenableColumns
import android.provider.Settings
import android.webkit.MimeTypeMap
import io.flutter.FlutterInjector
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.InputStream
import java.util.concurrent.Executors

/**
 * Everything the app asks of Android: tones (list, play, save into the phone's tone list, set as default),
 * volumes, sound mode, vibration and the settings pages Android keeps for itself.
 * Dart side: lib/core/platform/tone_platform.dart.
 */
class ToneChannel(private val activity: Activity, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {

    companion object {
        const val NAME = "com.homilabs.easyringtone/tones"
        private const val PICK_AUDIO = 4701
        private const val STORAGE_PERMISSION = 4702
        private const val FOLDER = "Easy Ringtone"
    }

    private val channel = MethodChannel(messenger, NAME).also { it.setMethodCallHandler(this) }
    private val ctx get() = activity.applicationContext
    private val audio get() = ctx.getSystemService(AudioManager::class.java)
    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private var player: MediaPlayer? = null
    private var pendingPick: MethodChannel.Result? = null
    private var pendingStorage: ((Boolean) -> Unit)? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "getDefault" -> result.success(getDefault(kind(call)))
                "listTones" -> background(result) { listTones(kind(call)) }
                "canWriteSettings" -> result.success(Settings.System.canWrite(ctx))
                "setDefault" -> result.success(setDefault(kind(call), call.argument<String>("uri")!!))
                "saveTone" -> saveTone(call, result)
                "pickAudio" -> pickAudio(result)
                "play" -> result.success(play(call.argument<String>("source")!!, kind(call)))
                "stop" -> { stop(); result.success(null) }
                "getVolumes" -> result.success(getVolumes())
                "setVolume" -> result.success(setVolume(call.argument<String>("stream")!!, call.argument<Int>("level")!!))
                "getRingerMode" -> result.success(ringerModeName(audio.ringerMode))
                "setRingerMode" -> result.success(setRingerMode(call.argument<String>("mode")!!))
                "getVibrateWhenRinging" -> result.success(vibrateWhenRinging())
                "setVibrateWhenRinging" -> result.success(setVibrateWhenRinging(call.argument<Boolean>("on")!!))
                "testVibration" -> { testVibration(); result.success(null) }
                "getDoNotDisturb" -> result.success(doNotDisturbOn())
                "turnOffDoNotDisturb" -> result.success(turnOffDoNotDisturb())
                "installedApps" -> background(result) { installedApps(call.argument<List<String>>("packages")!!) }
                "openAppSounds" -> result.success(openAppSounds(call.argument<String>("packageName")!!))
                "openApp" -> result.success(openApp(call.argument<String>("packageName")!!))
                "openSettings" -> result.success(openSettings(call.argument<String>("page")!!))
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("native", e.message, e.javaClass.simpleName)
        }
    }

    // ---- Tones ----

    private fun kind(call: MethodCall) = call.argument<String>("kind") ?: "call"

    private fun ringtoneType(kind: String) = when (kind) {
        "message" -> RingtoneManager.TYPE_NOTIFICATION
        "alarm" -> RingtoneManager.TYPE_ALARM
        else -> RingtoneManager.TYPE_RINGTONE
    }

    private fun getDefault(kind: String): Map<String, String>? {
        val uri = RingtoneManager.getActualDefaultRingtoneUri(ctx, ringtoneType(kind)) ?: return null
        val title = try {
            RingtoneManager.getRingtone(ctx, uri)?.getTitle(ctx)
        } catch (_: Exception) {
            null
        }
        return mapOf("uri" to uri.toString(), "title" to (title ?: ""))
    }

    private fun listTones(kind: String): List<Map<String, String>> {
        val manager = RingtoneManager(activity).apply { setType(ringtoneType(kind)) }
        val tones = mutableListOf<Map<String, String>>()
        val cursor = try {
            manager.cursor
        } catch (_: Exception) {
            return tones
        }
        cursor.use {
            while (it.moveToNext()) {
                val title = it.getString(RingtoneManager.TITLE_COLUMN_INDEX) ?: continue
                val uri = manager.getRingtoneUri(it.position) ?: continue
                tones.add(mapOf("uri" to uri.toString(), "title" to title))
            }
        }
        return tones
    }

    /** "ok", or "needsPermission" when the user has not yet allowed "Modify system settings". */
    private fun setDefault(kind: String, uri: String): String {
        if (!Settings.System.canWrite(ctx)) return "needsPermission"
        RingtoneManager.setActualDefaultRingtoneUri(ctx, ringtoneType(kind), Uri.parse(uri))
        return "ok"
    }

    /**
     * Copies a tone into the phone's own Ringtones / Notifications / Alarms folder (sub-folder "Easy Ringtone"),
     * so Android and other apps (WhatsApp, Messenger…) list it. Source is "asset:<key>", "file:<path>" or a
     * content uri. Returns the new MediaStore uri.
     */
    private fun saveTone(call: MethodCall, result: MethodChannel.Result) {
        val source = call.argument<String>("source")!!
        val title = call.argument<String>("title")!!.replace(Regex("[\\\\/:*?\"<>|]"), " ").trim().ifEmpty { "Tone" }
        val kind = kind(call)
        val run = {
            background(result) { saveToneNow(source, title, kind) }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q ||
            activity.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        ) {
            run()
            return
        }
        pendingStorage = { granted ->
            if (granted) run() else result.error("storageDenied", "Storage permission refused", null)
        }
        activity.requestPermissions(arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE), STORAGE_PERMISSION)
    }

    private fun saveToneNow(source: String, title: String, kind: String): String {
        val ext = extensionOf(source)
        val mime = MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext) ?: "audio/ogg"
        val folder = when (kind) {
            "message" -> Environment.DIRECTORY_NOTIFICATIONS
            "alarm" -> Environment.DIRECTORY_ALARMS
            else -> Environment.DIRECTORY_RINGTONES
        }
        val flag = when (kind) {
            "message" -> MediaStore.Audio.Media.IS_NOTIFICATION
            "alarm" -> MediaStore.Audio.Media.IS_ALARM
            else -> MediaStore.Audio.Media.IS_RINGTONE
        }
        val fileName = "$title.$ext"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Audio.Media.DISPLAY_NAME, fileName)
                put(MediaStore.Audio.Media.TITLE, title)
                put(MediaStore.Audio.Media.MIME_TYPE, mime)
                put(MediaStore.Audio.Media.RELATIVE_PATH, "$folder/$FOLDER")
                put(flag, 1)
                put(MediaStore.Audio.Media.IS_MUSIC, 0)
                put(MediaStore.Audio.Media.IS_PENDING, 1)
            }
            val resolver = ctx.contentResolver
            val collection = MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            val uri = resolver.insert(collection, values) ?: error("Could not create the tone file")
            try {
                openInput(source).use { input ->
                    resolver.openOutputStream(uri)!!.use { input.copyTo(it) }
                }
                resolver.update(uri, ContentValues().apply { put(MediaStore.Audio.Media.IS_PENDING, 0) }, null, null)
            } catch (e: Exception) {
                resolver.delete(uri, null, null)
                throw e
            }
            return uri.toString()
        }
        // Android 8–9: write into the public folder, then let the media scanner index it.
        @Suppress("DEPRECATION")
        val dir = File(Environment.getExternalStoragePublicDirectory(folder), FOLDER).apply { mkdirs() }
        var file = File(dir, fileName)
        var n = 2
        while (file.exists()) file = File(dir, "$title $n.$ext").also { n++ }
        openInput(source).use { input -> file.outputStream().use { input.copyTo(it) } }
        val lock = Object()
        var scanned: Uri? = null
        synchronized(lock) {
            MediaScannerConnection.scanFile(ctx, arrayOf(file.absolutePath), arrayOf(mime)) { _, uri ->
                synchronized(lock) { scanned = uri; lock.notifyAll() }
            }
            lock.wait(10_000)
        }
        val uri = scanned ?: error("The phone did not index the tone")
        ctx.contentResolver.update(
            uri,
            ContentValues().apply { put(flag, 1); put(MediaStore.Audio.Media.IS_MUSIC, 0); put(MediaStore.Audio.Media.TITLE, title) },
            null,
            null,
        )
        return uri.toString()
    }

    private fun extensionOf(source: String): String {
        val fromName = when {
            source.startsWith("asset:") || source.startsWith("file:") -> source.substringAfterLast('.', "")
            else -> displayName(Uri.parse(source))?.substringAfterLast('.', "")
                ?: MimeTypeMap.getSingleton().getExtensionFromMimeType(ctx.contentResolver.getType(Uri.parse(source)))
        }
        return fromName?.lowercase()?.takeIf { it.isNotEmpty() && it.length <= 5 } ?: "ogg"
    }

    private fun openInput(source: String): InputStream = when {
        source.startsWith("asset:") -> ctx.assets.open(assetKey(source))
        source.startsWith("file:") -> File(source.removePrefix("file:")).inputStream()
        else -> ctx.contentResolver.openInputStream(Uri.parse(source)) ?: error("Could not read the sound")
    }

    private fun assetKey(source: String) =
        FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(source.removePrefix("asset:"))

    private fun displayName(uri: Uri): String? = try {
        ctx.contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)?.use {
            if (it.moveToFirst()) it.getString(0) else null
        }
    } catch (_: Exception) {
        null
    }

    private fun pickAudio(result: MethodChannel.Result) {
        pendingPick?.success(null)
        pendingPick = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT)
            .addCategory(Intent.CATEGORY_OPENABLE)
            .setType("audio/*")
        try {
            activity.startActivityForResult(intent, PICK_AUDIO)
        } catch (_: ActivityNotFoundException) {
            pendingPick = null
            result.success(null)
        }
    }

    /** Called from MainActivity. True when the result was ours. */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK_AUDIO) return false
        val result = pendingPick ?: return true
        pendingPick = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return true
        }
        val name = displayName(uri)?.substringBeforeLast('.') ?: "Sound"
        result.success(mapOf("uri" to uri.toString(), "title" to name))
        return true
    }

    fun onPermissionResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode != STORAGE_PERMISSION) return
        val callback = pendingStorage ?: return
        pendingStorage = null
        callback(grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED)
    }

    // ---- Listening ----

    /** Plays on the same volume the real tone will use. Returns the sound mode, so Dart can warn about silent. */
    private fun play(source: String, kind: String): String {
        stop()
        val usage = when (kind) {
            "message" -> AudioAttributes.USAGE_NOTIFICATION
            "alarm" -> AudioAttributes.USAGE_ALARM
            else -> AudioAttributes.USAGE_NOTIFICATION_RINGTONE
        }
        val mp = MediaPlayer()
        mp.setAudioAttributes(
            AudioAttributes.Builder().setUsage(usage).setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION).build(),
        )
        if (source.startsWith("asset:")) {
            ctx.assets.openFd(assetKey(source)).use { mp.setDataSource(it.fileDescriptor, it.startOffset, it.length) }
        } else if (source.startsWith("file:")) {
            mp.setDataSource(source.removePrefix("file:"))
        } else {
            mp.setDataSource(ctx, Uri.parse(source))
        }
        mp.setOnPreparedListener { it.start() }
        mp.setOnCompletionListener { finished(it) }
        mp.setOnErrorListener { p, _, _ -> finished(p); true }
        mp.prepareAsync()
        player = mp
        main.postDelayed({ if (player === mp) stop() }, 20_000)
        return playNote(kind)
    }

    /** Why the user may hear nothing: "silent", "vibrate", "doNotDisturb", or "none". */
    private fun playNote(kind: String): String {
        val filter = notifications.currentInterruptionFilter
        if (kind == "alarm") return if (filter == NotificationManager.INTERRUPTION_FILTER_NONE) "doNotDisturb" else "none"
        return when {
            audio.ringerMode == AudioManager.RINGER_MODE_SILENT -> "silent"
            audio.ringerMode == AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
            filter > NotificationManager.INTERRUPTION_FILTER_ALL -> "doNotDisturb"
            else -> "none"
        }
    }

    private val notifications get() = ctx.getSystemService(NotificationManager::class.java)

    private fun doNotDisturbOn() = notifications.currentInterruptionFilter > NotificationManager.INTERRUPTION_FILTER_ALL

    /** "ok", or "needsDndAccess" until the user allows Do Not Disturb access. */
    private fun turnOffDoNotDisturb(): String {
        if (!doNotDisturbOn()) return "ok"
        if (!notifications.isNotificationPolicyAccessGranted) return "needsDndAccess"
        notifications.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
        return "ok"
    }

    private fun finished(mp: MediaPlayer) {
        if (player !== mp) return
        stop()
    }

    private fun stop() {
        val mp = player ?: return
        player = null
        try {
            mp.stop()
        } catch (_: Exception) {
        }
        mp.release()
        channel.invokeMethod("playbackStopped", null)
    }

    // ---- Volume, sound mode, vibration ----

    private val streams = linkedMapOf(
        "ring" to AudioManager.STREAM_RING,
        "message" to AudioManager.STREAM_NOTIFICATION,
        "alarm" to AudioManager.STREAM_ALARM,
        "media" to AudioManager.STREAM_MUSIC,
        "call" to AudioManager.STREAM_VOICE_CALL,
    )

    private fun getVolumes(): Map<String, Map<String, Int>> = streams.mapValues { (_, stream) ->
        val min = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) audio.getStreamMinVolume(stream) else 0
        mapOf("level" to audio.getStreamVolume(stream), "max" to audio.getStreamMaxVolume(stream), "min" to min)
    }

    /** "ok", or "needsDndAccess" when Do Not Disturb blocks the change. */
    private fun setVolume(name: String, level: Int): String {
        val stream = streams[name] ?: error("Unknown stream $name")
        return try {
            audio.setStreamVolume(stream, level, AudioManager.FLAG_PLAY_SOUND)
            "ok"
        } catch (_: SecurityException) {
            "needsDndAccess"
        }
    }

    private fun ringerModeName(mode: Int) = when (mode) {
        AudioManager.RINGER_MODE_SILENT -> "silent"
        AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
        else -> "normal"
    }

    private fun setRingerMode(mode: String): String {
        val wanted = when (mode) {
            "silent" -> AudioManager.RINGER_MODE_SILENT
            "vibrate" -> AudioManager.RINGER_MODE_VIBRATE
            else -> AudioManager.RINGER_MODE_NORMAL
        }
        return try {
            audio.ringerMode = wanted
            if (audio.ringerMode == wanted) "ok" else "needsDndAccess"
        } catch (_: SecurityException) {
            "needsDndAccess"
        }
    }

    /** True/false, or null when the phone has no such setting. */
    private fun vibrateWhenRinging(): Boolean? = try {
        Settings.System.getInt(ctx.contentResolver, Settings.System.VIBRATE_WHEN_RINGING) == 1
    } catch (_: Settings.SettingNotFoundException) {
        null
    }

    /** "ok", "needsPermission", or "notAllowed" when this phone keeps the switch for its own Settings app. */
    private fun setVibrateWhenRinging(on: Boolean): String {
        if (!Settings.System.canWrite(ctx)) return "needsPermission"
        return try {
            Settings.System.putInt(ctx.contentResolver, Settings.System.VIBRATE_WHEN_RINGING, if (on) 1 else 0)
            if (vibrateWhenRinging() == on) "ok" else "notAllowed"
        } catch (_: Exception) {
            "notAllowed"
        }
    }

    private fun testVibration() {
        val vibrator = ctx.getSystemService(Vibrator::class.java) ?: return
        vibrator.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 700, 300, 700), -1))
    }

    // ---- Other apps and settings pages ----

    private fun installedApps(packages: List<String>): List<Map<String, Any>> {
        val pm = ctx.packageManager
        return packages.mapNotNull { pkg ->
            try {
                val info = pm.getApplicationInfo(pkg, 0)
                if (!info.enabled) return@mapNotNull null
                mapOf("packageName" to pkg, "label" to pm.getApplicationLabel(info).toString(), "icon" to iconPng(pm.getApplicationIcon(info)))
            } catch (_: PackageManager.NameNotFoundException) {
                null
            }
        }
    }

    private fun iconPng(drawable: android.graphics.drawable.Drawable): ByteArray {
        val size = 144
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        drawable.setBounds(0, 0, size, size)
        drawable.draw(Canvas(bitmap))
        return ByteArrayOutputStream().also { bitmap.compress(Bitmap.CompressFormat.PNG, 100, it) }.toByteArray()
    }

    private fun openAppSounds(pkg: String): Boolean =
        startSettings(Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(Settings.EXTRA_APP_PACKAGE, pkg)) ||
            startSettings(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$pkg")))

    private fun openApp(pkg: String): Boolean {
        val intent = ctx.packageManager.getLaunchIntentForPackage(pkg) ?: return false
        return start(intent)
    }

    private fun openSettings(page: String): Boolean = when (page) {
        "writeSettings" -> startSettings(Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS, Uri.parse("package:${ctx.packageName}")))
        "dndAccess" -> startSettings(Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS))
        "doNotDisturb" -> startSettings(Intent("android.settings.ZEN_MODE_SETTINGS")) ||
            startSettings(Intent(Settings.ACTION_SOUND_SETTINGS))
        "accessibility" -> startSettings(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
        else -> startSettings(Intent(Settings.ACTION_SOUND_SETTINGS))
    }

    /**
     * Settings runs in its own task on many phones (Oppo, Samsung). Starting it fresh means Back leaves Settings
     * and returns here, instead of walking through pages someone opened there earlier.
     */
    private fun startSettings(intent: Intent) =
        start(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK))

    private fun start(intent: Intent): Boolean = try {
        activity.startActivity(intent)
        true
    } catch (_: ActivityNotFoundException) {
        false
    } catch (_: SecurityException) {
        false
    }

    // ---- Plumbing ----

    private fun <T> background(result: MethodChannel.Result, work: () -> T) {
        io.execute {
            try {
                val value = work()
                main.post { result.success(value) }
            } catch (e: Exception) {
                main.post { result.error("native", e.message, e.javaClass.simpleName) }
            }
        }
    }

    fun dispose() {
        stop()
        channel.setMethodCallHandler(null)
        io.shutdown()
    }
}
