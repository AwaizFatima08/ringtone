package com.homilabs.easyringtone

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var tones: ToneChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        tones = ToneChannel(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    @Deprecated("FlutterActivity still delivers results here")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (tones?.onActivityResult(requestCode, resultCode, data) != true) {
            @Suppress("DEPRECATION")
            super.onActivityResult(requestCode, resultCode, data)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        tones?.onPermissionResult(requestCode, grantResults)
    }

    override fun onDestroy() {
        tones?.dispose()
        tones = null
        super.onDestroy()
    }
}
