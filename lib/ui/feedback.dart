import 'dart:async';

import 'package:easyringtone/app.dart';
import 'package:easyringtone/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A big green tick and one OK button: the user always sees that a change worked.
Future<void> showDone(BuildContext context, String message) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    icon: const Icon(Icons.check_circle, color: AppColors.call, size: 72),
    content: Text(message, textAlign: TextAlign.center),
    actions: [_OkButton(label: context.l10n.ok)],
  ),
);

/// Something did not work: say so in plain words.
Future<void> showProblem(BuildContext context, String message) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    icon: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 64),
    content: Text(message, textAlign: TextAlign.center),
    actions: [_OkButton(label: context.l10n.ok)],
  ),
);

/// Asks a yes/no question with two big buttons. True when the user chose [yes].
Future<bool> askYesNo(
  BuildContext context, {
  required String title,
  required String message,
  required String yes,
  required String no,
  IconData icon = Icons.info_outline,
}) async {
  final answer = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message),
      actionsOverflowDirection: VerticalDirection.up,
      actionsOverflowButtonSpacing: AppSpacing.sm,
      actions: [
        OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(no)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(yes)),
      ],
    ),
  );
  return answer ?? false;
}

void showNote(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 6)));
}

/// Runs [work] behind a "Please wait" box so nothing gets pressed twice.
/// Shows a problem message and returns null when Android reports an error.
Future<T?> runWithWait<T>(BuildContext context, Future<T> Function() work) async {
  final l10n = context.l10n;
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: Text(l10n.pleaseWait)),
            ],
          ),
        ),
      ),
    ),
  );
  T? value;
  var failed = false;
  try {
    value = await work();
  } on PlatformException catch (e) {
    debugPrint('Native error: ${e.code} ${e.message}');
    failed = true;
  }
  navigator.pop();
  if (failed && context.mounted) await showProblem(context, l10n.somethingWrong);
  return value;
}

/// Completes when the user comes back to the app (for example from Android's Settings).
Future<void> waitForResume() {
  final done = Completer<void>();
  late final AppLifecycleListener listener;
  listener = AppLifecycleListener(
    onResume: () {
      listener.dispose();
      done.complete();
    },
  );
  return done.future;
}

class _OkButton extends StatelessWidget {
  const _OkButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(onPressed: () => Navigator.pop(context), child: Text(label)),
  );
}
