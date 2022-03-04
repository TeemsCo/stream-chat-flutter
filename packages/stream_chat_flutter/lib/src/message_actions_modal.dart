import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/src/extension.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Constructs a modal with actions for a message
class MessageActionsModal extends StatefulWidget {
  /// Constructor for creating a [MessageActionsModal] widget
  const MessageActionsModal({
    Key? key,
    required this.message,
    required this.messageWidget,
    required this.messageTheme,
    this.showReactions = true,
    this.showDeleteMessage = true,
    this.showEditMessage = true,
    this.onReplyTap,
    this.onThreadReplyTap,
    this.showCopyMessage = true,
    this.showReplyMessage = true,
    this.showResendMessage = true,
    this.showThreadReplyMessage = true,
    this.showFlagButton = true,
    this.showPinButton = true,
    this.editMessageInputBuilder,
    this.reverse = false,
    this.customActions = const [],
    this.onCopyTap,
    this.closePortal,
    this.copyLabel,
    this.deleteLabel,
    this.editLabel,
  }) : super(key: key);

  /// Widget that shows the message
  final Widget messageWidget;

  /// Builder for edit message
  final Widget Function(BuildContext, Message)? editMessageInputBuilder;

  /// Callback for when thread reply is tapped
  final OnMessageTap? onThreadReplyTap;

  /// Callback for when reply is tapped
  final OnMessageTap? onReplyTap;

  /// Message in focus for actions
  final Message message;

  /// [MessageThemeData] for message
  final MessageThemeData messageTheme;

  /// Flag for showing reactions
  final bool showReactions;

  /// Callback when copy is tapped
  final OnMessageTap? onCopyTap;

  /// Callback when delete is tapped
  final bool showDeleteMessage;

  /// Flag for showing copy action
  final bool showCopyMessage;

  /// Flag for showing edit action
  final bool showEditMessage;

  /// Flag for showing resend action
  final bool showResendMessage;

  /// Flag for showing reply action
  final bool showReplyMessage;

  /// Flag for showing thread reply action
  final bool showThreadReplyMessage;

  /// Flag for showing flag action
  final bool showFlagButton;

  /// Flag for showing pin action
  final bool showPinButton;

  /// Flag for reversing message
  final bool reverse;

  /// List of custom actions
  final List<MessageAction> customActions;

  /// Void function that closes the widget. It should be provided only
  /// when this widget is used in a portal
  final void Function()? closePortal;

  /// Custom label for the copy action button
  final String? copyLabel;

  /// Custom label for the edit action button
  final String? editLabel;

  /// Custom label for the delete action button
  final String? deleteLabel;

  @override
  _MessageActionsModalState createState() => _MessageActionsModalState();
}

class _MessageActionsModalState extends State<MessageActionsModal> {
  bool get showActionsState => _showActions;

  bool _showActions = true;

  @override
  Widget build(BuildContext context) => _showMessageOptionsModal();

  void closeActionMenu() {
    if (widget.closePortal != null) {
      widget.closePortal!();
    } else {
      Navigator.pop(context);
    }
  }

  Widget _showMessageOptionsModal() {
    final isDesktop = MediaQuery.of(context).size.width >= 650;
    final mediaQueryData = MediaQuery.of(context);

    var messageTextLength = widget.message.text!.length;
    if (widget.message.quotedMessage != null) {
      var quotedMessageLength =
          (widget.message.quotedMessage!.text?.length ?? 0) + 40;
      if (widget.message.quotedMessage!.attachments.isNotEmpty) {
        quotedMessageLength += 40;
      }
      if (quotedMessageLength > messageTextLength) {
        messageTextLength = quotedMessageLength;
      }
    }

    final streamChatThemeData = StreamChatTheme.of(context);

    final child = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.showReactions &&
              (widget.message.status == MessageSendingStatus.sent))
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: ReactionPicker(
                message: widget.message,
              ),
            ),
          const SizedBox(height: 8),
          if (!isDesktop) IgnorePointer(child: widget.messageWidget),
          const SizedBox(height: 8),
          SizedBox(
            width: isDesktop
                ? mediaQueryData.size.width * 0.2
                : mediaQueryData.size.width,
            child: Material(
              elevation: isDesktop ? 8 : 0,
              shadowColor:
                  isDesktop ? const Color.fromRGBO(0, 0, 0, 0.7) : null,
              color: streamChatThemeData.colorTheme.appBg,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: isDesktop
                    ? const BorderRadius.all(Radius.circular(16))
                    : const BorderRadius.only(
                        topRight: Radius.circular(16),
                        topLeft: Radius.circular(16),
                      ),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: isDesktop ? 6 : 16),
                margin: EdgeInsets.only(left: isDesktop ? 0 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.showReplyMessage &&
                        widget.message.status == MessageSendingStatus.sent)
                      _buildReplyButton(context),
                    if (widget.showThreadReplyMessage &&
                        (widget.message.status == MessageSendingStatus.sent) &&
                        widget.message.parentId == null)
                      _buildThreadReplyButton(context),
                    if (widget.showResendMessage) _buildResendMessage(context),
                    if (widget.showEditMessage) _buildEditMessage(context),
                    if (widget.showDeleteMessage) _buildDeleteButton(context),
                    if (widget.showCopyMessage) _buildCopyButton(context),
                    ...widget.customActions.map(
                      (action) => _buildCustomAction(
                        context,
                        action,
                      ),
                    ),
                    if (widget.showFlagButton) _buildFlagButton(context),
                    if (widget.showPinButton) _buildPinButton(context),
                  ].insertBetween(const SizedBox(height: 10)),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => Navigator.maybePop(context),
      child: _showActions
          ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutBack,
              builder: (context, val, child) => Transform.scale(
                scale: val,
                child: child,
              ),
              child: child,
            )
          : const SizedBox(),
    );
  }

  InkWell _buildCustomAction(
    BuildContext context,
    MessageAction messageAction,
  ) =>
      InkWell(
        onTap: () {
          messageAction.onTap?.call(widget.message);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
          child: Row(
            children: [
              messageAction.leading ?? const Offstage(),
              const SizedBox(width: 16),
              messageAction.title ?? const Offstage(),
            ],
          ),
        ),
      );

  void _showFlagDialog() async {
    final client = StreamChat.of(context).client;

    final streamChatThemeData = StreamChatTheme.of(context);
    final answer = await showConfirmationDialog(
      context,
      title: context.translations.flagMessageLabel,
      icon: StreamSvgIcon.flag(
        color: streamChatThemeData.colorTheme.accentError,
        size: 24,
      ),
      question: context.translations.flagMessageQuestion,
      okText: context.translations.flagLabel,
      cancelText: context.translations.cancelLabel,
    );

    final theme = streamChatThemeData;
    if (answer == true) {
      try {
        await client.flagMessage(widget.message.id);
        await showInfoDialog(
          context,
          icon: StreamSvgIcon.flag(
            color: theme.colorTheme.accentError,
            size: 24,
          ),
          details: context.translations.flagMessageSuccessfulText,
          title: context.translations.flagMessageSuccessfulLabel,
          okText: context.translations.okLabel,
        );
      } catch (err) {
        if (err is StreamChatNetworkError &&
            err.errorCode == ChatErrorCode.inputError) {
          await showInfoDialog(
            context,
            icon: StreamSvgIcon.flag(
              color: theme.colorTheme.accentError,
              size: 24,
            ),
            details: context.translations.flagMessageSuccessfulText,
            title: context.translations.flagMessageSuccessfulLabel,
            okText: context.translations.okLabel,
          );
        } else {
          _showErrorAlert();
        }
      }
    }
  }

  void _togglePin() async {
    final channel = StreamChannel.of(context).channel;

    closeActionMenu();

    try {
      if (!widget.message.pinned) {
        await channel.pinMessage(widget.message);
      } else {
        await channel.unpinMessage(widget.message);
      }
    } catch (e) {
      _showErrorAlert();
    }
  }

  void _showDeleteDialog() async {
    setState(() {
      _showActions = false;
    });
    final answer = await showConfirmationDialog(
      context,
      title: context.translations.deleteMessageLabel,
      icon: StreamSvgIcon.flag(
        color: StreamChatTheme.of(context).colorTheme.accentError,
        size: 24,
      ),
      question: context.translations.deleteMessageQuestion,
      okText: context.translations.deleteLabel,
      cancelText: context.translations.cancelLabel,
    );

    if (answer == true) {
      try {
        Navigator.pop(context);
        await StreamChannel.of(context).channel.deleteMessage(widget.message);
      } catch (err) {
        _showErrorAlert();
      }
    } else {
      setState(() {
        _showActions = true;
      });
    }
  }

  void _showErrorAlert() {
    showInfoDialog(
      context,
      icon: StreamSvgIcon.error(
        color: StreamChatTheme.of(context).colorTheme.accentError,
        size: 24,
      ),
      details: context.translations.operationCouldNotBeCompletedText,
      title: context.translations.somethingWentWrongError,
      okText: context.translations.okLabel,
    );
  }

  Widget _buildReplyButton(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: () {
        closeActionMenu();
        if (widget.onReplyTap != null) {
          widget.onReplyTap!(widget.message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.reply(
              color: streamChatThemeData.primaryIconTheme.color,
            ),
            const SizedBox(width: 16),
            Text(
              context.translations.replyLabel,
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagButton(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: _showFlagDialog,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.iconFlag(
              color: streamChatThemeData.primaryIconTheme.color,
            ),
            const SizedBox(width: 16),
            Text(
              context.translations.flagMessageLabel,
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinButton(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: _togglePin,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.pin(
              color: streamChatThemeData.primaryIconTheme.color,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              context.translations.togglePinUnpinText(
                pinned: widget.message.pinned,
              ),
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final isDeleteFailed =
        widget.message.status == MessageSendingStatus.failed_delete;
    return InkWell(
      onTap: () async {
        try {
          await StreamChannel.of(context).channel.deleteMessage(widget.message);
          closeActionMenu();
        } catch (err) {
          _showErrorAlert();
        }
      },
      // onTap: _showDeleteDialog,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.delete_outlined, color: Color(0xFF666666)),
            const SizedBox(width: 16),
            Text(
              widget.deleteLabel != null
                  ? widget.deleteLabel!
                  : context.translations.toggleDeleteRetryDeleteMessageText(
                      isDeleteFailed: isDeleteFailed,
                    ),
              style: StreamChatTheme.of(context).textTheme.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: () async {
        widget.onCopyTap?.call(widget.message);

        closeActionMenu();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.copy_all_outlined, color: Color(0xFF666666)),
            const SizedBox(width: 16),
            Text(
              widget.copyLabel != null
                  ? widget.copyLabel!
                  : context.translations.copyMessageLabel,
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMessage(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: () async {
        closeActionMenu();

        _showEditBottomSheet(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.edit_outlined, color: Color(0xFF666666)),
            const SizedBox(width: 16),
            Text(
              widget.editLabel != null
                  ? widget.editLabel!
                  : context.translations.editMessageLabel,
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResendMessage(BuildContext context) {
    final isUpdateFailed =
        widget.message.status == MessageSendingStatus.failed_update;
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: () {
        closeActionMenu();

        final channel = StreamChannel.of(context).channel;
        if (isUpdateFailed) {
          channel.updateMessage(widget.message);
        } else {
          channel.sendMessage(widget.message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.circleUp(
              color: streamChatThemeData.colorTheme.accentPrimary,
            ),
            const SizedBox(width: 16),
            Text(
              context.translations.toggleResendOrResendEditedMessage(
                isUpdateFailed: isUpdateFailed,
              ),
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    final streamChatThemeData = StreamChatTheme.of(context);
    showModalBottomSheet(
      context: context,
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: true,
      backgroundColor: MessageInputTheme.of(context).inputBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: StreamChannel(
          channel: channel,
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: StreamSvgIcon.edit(
                        color: streamChatThemeData.colorTheme.disabled,
                      ),
                    ),
                    Text(
                      context.translations.editMessageLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: StreamSvgIcon.closeSmall(),
                      onPressed: Navigator.of(context).pop,
                    ),
                  ],
                ),
              ),
              if (widget.editMessageInputBuilder != null)
                widget.editMessageInputBuilder!(context, widget.message)
              else
                MessageInput(
                  editMessage: widget.message,
                  preMessageSending: (m) {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                    return m;
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThreadReplyButton(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: () {
        closeActionMenu();

        if (widget.onThreadReplyTap != null) {
          widget.onThreadReplyTap!(widget.message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            StreamSvgIcon.thread(
              color: streamChatThemeData.primaryIconTheme.color,
            ),
            const SizedBox(width: 16),
            Text(
              context.translations.threadReplyLabel,
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }
}
