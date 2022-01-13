import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/src/extension.dart';
import 'package:stream_chat_flutter/src/stream_chat_theme.dart';
import 'package:stream_chat_flutter/src/theme/themes.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Widget to display deleted message
class DeletedMessage extends StatelessWidget {
  /// Constructor to create [DeletedMessage]
  const DeletedMessage({
    Key? key,
    required this.isMyMessage,
    required this.messageTheme,
    this.borderRadiusGeometry,
    this.shape,
    this.borderSide,
    this.reverse = false,
  }) : super(key: key);

  ///The deleted message
  final bool isMyMessage;

  /// The theme of the message
  final MessageThemeData messageTheme;

  /// The border radius of the message text
  final BorderRadiusGeometry? borderRadiusGeometry;

  /// The shape of the message text
  final ShapeBorder? shape;

  /// The borderside of the message text
  final BorderSide? borderSide;

  /// If true the widget will be mirrored
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final chatThemeData = StreamChatTheme.of(context);
    print(isMyMessage);
    return Material(
      color: isMyMessage ? const Color(0xFF1774F2) : const Color(0xFFEEEEEE),
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: borderRadiusGeometry ?? BorderRadius.zero,
            side: borderSide ??
                BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? chatThemeData.colorTheme.barsBg.withAlpha(24)
                      : chatThemeData.colorTheme.textHighEmphasis.withAlpha(24),
                ),
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Text(
          context.translations.messageDeletedLabel,
          style: TextStyle(
            color: isMyMessage ? Colors.white : Colors.black,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
