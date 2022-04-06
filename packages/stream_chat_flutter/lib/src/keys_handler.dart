import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///Intent for new lines
class NewLineIntent extends Intent {}

///Intent for new lines with numpad
class NewLineWithNumPadIntent extends Intent {}

///Intent for enter
class EnterIntent extends Intent {}

///Intent for enter with numpad
class NumPadEnterIntent extends Intent {}

///Intent for any enter
class NumPadEnterAndEnterIntent extends Intent {}

///Wrapper that takes care of handling enter or shift + enter keypress
class KeysHandler extends StatelessWidget {
  ///Constructor
  KeysHandler({
    Key? key,
    required this.child,
    required this.onNewLineAction,
    required this.onEnterAction,
  }) : super(key: key);

  ///Child to wrap
  final Widget child;

  ///Function invoked on new line pressed
  final Function(Intent) onNewLineAction;

  ///Function invoked on enter key pressed
  final Function(Intent) onEnterAction;

  final Map<LogicalKeySet, Intent> _shortcuts = {
    LogicalKeySet(
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.enter,
    ): NewLineIntent(),
    LogicalKeySet(
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.numpadEnter,
    ): NewLineWithNumPadIntent(),
    LogicalKeySet(LogicalKeyboardKey.enter): EnterIntent(),
    LogicalKeySet(LogicalKeyboardKey.numpadEnter): NumPadEnterIntent(),
    LogicalKeySet(LogicalKeyboardKey.numpadEnter, LogicalKeyboardKey.enter):
        NumPadEnterAndEnterIntent(),
  };

  @override
  Widget build(BuildContext context) {
    //ignore: omit_local_variable_types
    final Map<Type, Action<Intent>> _actions = {
      NewLineWithNumPadIntent: CallbackAction(onInvoke: onNewLineAction),
      NewLineIntent: CallbackAction(onInvoke: onNewLineAction),
      EnterIntent: CallbackAction(onInvoke: onEnterAction),
      NumPadEnterIntent: CallbackAction(onInvoke: onEnterAction),
      NumPadEnterAndEnterIntent: CallbackAction(onInvoke: onEnterAction),
    };

    return FocusableActionDetector(
      actions: _actions,
      shortcuts: _shortcuts,
      child: child,
    );
  }
}
