import 'package:easyringtone/app.dart';
import 'package:easyringtone/core/tone_platform.dart';
import 'package:easyringtone/features/tones/application/tone_providers.dart';
import 'package:easyringtone/features/tones/domain/tone.dart';
import 'package:easyringtone/l10n/gen/app_localizations.dart';
import 'package:easyringtone/ui/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What a tone list does when the user presses its action button.
/// True when it worked, so the list page can close.
typedef ToneAction = Future<bool> Function(BuildContext context, WidgetRef ref, Tone tone);

/// Makes [tone] the phone's tone for [kind], asking once for "Modify system settings".
Future<bool> useToneFlow(BuildContext context, WidgetRef ref, ToneKind kind, Tone tone) async {
  final l10n = context.l10n;
  await ref.read(playbackProvider.notifier).stop();
  if (!context.mounted) return false;
  final actions = ref.read(toneActionsProvider);
  var outcome = await runWithWait(context, () => actions.use(kind, tone));
  if (outcome == ChangeOutcome.needsPermission) {
    if (!context.mounted || !await askWriteSettings(context, ref)) return false;
    if (!context.mounted) return false;
    outcome = await runWithWait(context, () => actions.use(kind, tone));
  }
  if (!context.mounted || outcome == null) return false;
  if (outcome != ChangeOutcome.ok) {
    await showProblem(context, l10n.somethingWrong);
    return false;
  }
  await showDone(context, doneMessage(l10n, kind, tone.title));
  return true;
}

String doneMessage(AppLocalizations l10n, ToneKind kind, String title) => switch (kind) {
  ToneKind.call => l10n.doneCall(title),
  ToneKind.message => l10n.doneMessage(title),
  ToneKind.alarm => l10n.doneAlarm(title),
};

/// Explains Android's "Modify system settings" switch, opens it and waits for the user to come back.
/// True when the switch is on afterwards.
Future<bool> askWriteSettings(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final platform = ref.read(tonePlatformProvider);
  final go = await askYesNo(
    context,
    title: l10n.permissionTitle,
    message: l10n.permissionBody,
    yes: l10n.openSettings,
    no: l10n.notNow,
    icon: Icons.settings,
  );
  if (!go || !await platform.openSettings(SettingsPage.writeSettings)) return false;
  await waitForResume();
  final granted = await platform.canWriteSettings();
  if (!granted && context.mounted) showNote(context, l10n.permissionStillOff);
  return granted;
}

/// Asks the user to allow Do Not Disturb access, which Android needs before some sound changes.
Future<void> askDndAccess(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final go = await askYesNo(
    context,
    title: l10n.dndTitle,
    message: l10n.dndBody,
    yes: l10n.openSettings,
    no: l10n.notNow,
    icon: Icons.do_not_disturb_on,
  );
  if (go) await ref.read(tonePlatformProvider).openSettings(SettingsPage.dndAccess);
}
