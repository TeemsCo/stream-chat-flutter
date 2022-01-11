import 'package:flutter/material.dart';

///Builder for chat emojis
Widget buildReactionEmojiIcon(
  BuildContext context, {
  required String emoji,
  required bool highlighted,
}) =>
    Center(
      child: Text(
        emoji,
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
    );
