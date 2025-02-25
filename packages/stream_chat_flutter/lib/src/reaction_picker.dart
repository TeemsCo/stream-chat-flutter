import 'package:ezanimation/ezanimation.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/src/extension.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/reaction_picker.png)
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/reaction_picker_paint.png)
///
/// It shows a reaction picker
///
/// Usually you don't use this widget as it's one of the default widgets used
/// by [MessageWidget.onMessageActions].
class ReactionPicker extends StatefulWidget {
  /// Constructor for creating a [ReactionPicker] widget
  const ReactionPicker({
    Key? key,
    required this.message,
    this.closePortal,
    this.shouldPop = true,
    this.showShadow = false,
  }) : super(key: key);

  /// Message to attach the reaction to
  final Message message;

  /// Void function that closes the widget. It should be provided only
  /// when this widget is used in a portal
  final VoidCallback? closePortal;

  /// If the widget should display its shadow
  final bool showShadow;

  /// Indicates if it should pop after picking a reaction
  final bool shouldPop;

  @override
  _ReactionPickerState createState() => _ReactionPickerState();
}

class _ReactionPickerState extends State<ReactionPicker>
    with TickerProviderStateMixin {
  List<EzAnimation> animations = [];

  @override
  Widget build(BuildContext context) {
    final chatThemeData = StreamChatTheme.of(context);
    final reactionIcons = chatThemeData.reactionIcons;

    if (animations.isEmpty && reactionIcons.isNotEmpty) {
      reactionIcons.forEach((element) {
        animations.add(
          EzAnimation.tween(
            Tween(begin: 0.0, end: 1.0),
            const Duration(milliseconds: 500),
            curve: Curves.easeInOutBack,
          ),
        );
      });

      triggerAnimations();
    }

    final child = Material(
      borderRadius: BorderRadius.circular(16),
      color: chatThemeData.colorTheme.barsBg,
      clipBehavior: Clip.hardEdge,
      elevation: widget.showShadow ? 8 : 0,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.7),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: reactionIcons
              .map<Widget>((reactionIcon) {
                final ownReactionIndex =
                    widget.message.ownReactions?.indexWhere(
                          (reaction) => reaction.type == reactionIcon.type,
                        ) ??
                        -1;
                final index = reactionIcons.indexOf(reactionIcon);

                final child = reactionIcon.builder(
                  context,
                  ownReactionIndex != -1,
                  24,
                );

                return ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(
                    height: 24,
                    width: 24,
                  ),
                  child: RawMaterialButton(
                    elevation: 0,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints.tightFor(
                      height: 24,
                      width: 24,
                    ),
                    onPressed: () {
                      if (widget.closePortal != null) {
                        widget.closePortal!();
                      }
                      if (ownReactionIndex != -1) {
                        removeReaction(
                          context,
                          widget.message.ownReactions![ownReactionIndex],
                        );
                      } else {
                        sendReaction(
                          context,
                          reactionIcon.type,
                        );
                      }
                    },
                    child: AnimatedBuilder(
                      animation: animations[index],
                      builder: (context, child) => Transform.scale(
                        scale: animations[index].value,
                        child: child,
                      ),
                      child: child,
                    ),
                  ),
                );
              })
              .insertBetween(const SizedBox(
                width: 14,
              ))
              .toList(),
        ),
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeInOutBack,
      duration: const Duration(milliseconds: 500),
      builder: (context, val, widget) => Transform.scale(
        scale: val,
        child: widget,
      ),
      child: child,
    );
  }

  void triggerAnimations() async {
    for (final a in animations) {
      a.start();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void pop() async {
    for (final a in animations) {
      a.stop();
    }
    if (widget.shouldPop) {
      Navigator.of(context).pop();
    }
  }

  /// Add a reaction to the message
  void sendReaction(BuildContext context, String reactionType) {
    StreamChannel.of(context).channel.sendReaction(
          widget.message,
          reactionType,
          enforceUnique: true,
        );
    pop();
  }

  /// Remove a reaction from the message
  void removeReaction(BuildContext context, Reaction reaction) {
    StreamChannel.of(context).channel.deleteReaction(widget.message, reaction);
    pop();
  }

  @override
  void dispose() {
    for (final a in animations) {
      a.dispose();
    }
    super.dispose();
  }
}
