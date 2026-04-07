import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 聊天气泡
class ChatBubble extends StatefulWidget {
  /// 发送者名称
  final String? name;

  /// 消息内容文本
  ///
  /// 当[buildMessageContent]未实现时会调用，否则无效
  final String? message;

  /// 头像
  final Widget? avatar;

  /// 是否为己方发送
  final bool isMe;

  /// 可选时间戳
  final DateTime? timestamp;

  /// 点击头像回调
  final VoidCallback? onAvatarTap;

  /// 点击消息回调
  final VoidCallback? onMessageTap;

  /// 构建消息内容组件
  ///
  /// 未设置时默认为标准文本
  final Widget Function(BuildContext context)? buildMessageContent;

  const ChatBubble({
    this.name,
    this.message,
    this.avatar,
    required this.isMe,
    this.timestamp,
    this.onAvatarTap,
    this.onMessageTap,
    this.buildMessageContent,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  /// 返回状态图标
  ///
  /// 仅自己消息时显示
  Widget? buildStatusIcon(BuildContext context) {
    return null;

    // if (!widget.isMe) return null;
    // return const Padding(
    //   padding: EdgeInsets.all(4),
    //   child: Icon(Icons.done, size: 16, color: Colors.blue),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        spacing: 8,
        mainAxisAlignment: widget.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 对方消息左侧头像
          if (!widget.isMe) widget.avatar ?? const SizedBox.shrink(),
          // 消息主体
          Flexible(
            child: Column(
              crossAxisAlignment: widget.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // 发送者名称
                if (!widget.isMe && widget.name != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SelectableText(
                      widget.name!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ), // 文本
                  ), // 内边距
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.isMe)
                      buildStatusIcon(context) ?? const SizedBox.shrink(),
                    Flexible(
                      child: GestureDetector(
                        onTap: widget.onMessageTap,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ), // 限制
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ), // 内边距
                          decoration: BoxDecoration(
                            color: widget.isMe
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16).copyWith(
                              topLeft: widget.isMe
                                  ? null
                                  : const Radius.circular(4),
                              topRight: widget.isMe
                                  ? const Radius.circular(4)
                                  : null,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ), // 装饰器
                          child:
                              widget.buildMessageContent?.call(context) ??
                              SelectableText(
                                widget.message ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: widget.isMe
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                        ), // 容器
                      ), // 手势检测器
                    ), // 限制容器
                  ],
                ), // 气泡行 - 包含状态图标和气泡内容
                // 时间戳
                if (widget.timestamp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: SelectableText(
                      DateFormat(
                        'HH:mm:ss',
                      ).format(widget.timestamp!.toLocal()),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: widget.isMe
                            ? theme.colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.7,
                              )
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                        fontSize: 10,
                      ),
                    ), // 文本
                  ), // 内边距
              ],
            ),
          ),

          if (widget.isMe) widget.avatar ?? SizedBox(), // 己方消息右侧头像
        ],
      ),
    );
  }
}
