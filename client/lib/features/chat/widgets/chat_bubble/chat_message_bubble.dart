import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/account/models/account_model.dart';
import 'package:talky_client/features/chat/widgets/chat_bubble/chat_bubble.dart';
import 'package:talky_shared/account/account_profile.dart';
import 'package:talky_shared/chat/base_chat_message.dart';
import 'package:talky_shared/chat/text_chat_message.dart';

/// 聊天消息气泡
///
/// 支持传递[BaseChatMessage]，通常作为正常用户之间的气泡
class ChatMessageBubble extends StatelessWidget {
  /// 消息
  final BaseChatMessage message;

  /// 为己方发送
  final bool isMe;

  /// 账户资料
  final AccountProfile? profile;

  /// 点击头像
  final VoidCallback? onAvatarTap;

  const ChatMessageBubble({
    required this.message,
    required this.isMe,
    this.profile,
    this.onAvatarTap,
    super.key,
  });

  /// 构建发送者头像
  Widget _buildSenderAvatar(BuildContext context) {
    if (profile == null) {
      return const Icon(Icons.question_mark);
    }
    return IconButton(
      onPressed: onAvatarTap,
      icon: context.read<AccountModel>().getAvatar(profile!.username),
    );
  }

  /// 构建己方头像
  Widget? _buildSelfAvatar(BuildContext context) {
    return context.read<AccountModel>().buildAvatar(); // 自己的头像
  }

  @override
  Widget build(BuildContext context) {
    if (message is TextChatMessage) {
      final textChatMessage = message as TextChatMessage;
      return ChatBubble(
        name: profile?.username,
        message: textChatMessage.text,
        avatar: isMe ? _buildSelfAvatar(context) : _buildSenderAvatar(context),
        isMe: isMe,
        timestamp: textChatMessage.timestamp,
        onAvatarTap: onAvatarTap,
      );
    }
    return Text('无效消息');
  }
}
