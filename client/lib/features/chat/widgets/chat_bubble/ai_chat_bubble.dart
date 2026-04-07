import 'package:flutter/material.dart';
import 'package:flutter_smooth_markdown/flutter_smooth_markdown.dart';
import 'package:talky_client/features/ai_chat/models/ai_chat_message.dart';
import 'package:talky_client/features/chat/widgets/chat_bubble/chat_bubble.dart';

/// AI消息气泡
class AiChatBubble extends StatefulWidget {
  /// ai消息
  final AiChatMessage aiMessage;

  /// 是否流式接收中
  final bool isStreaming;

  const AiChatBubble({
    required this.aiMessage,
    required this.isStreaming,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AiChatBubbleState();
}

class _AiChatBubbleState extends State<AiChatBubble> {
  bool _showReason = false; // 思考内容是否展开
  /// 构建消息主体内容
  Widget _buildMessageContent(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 如果有思考内容，显示可折叠区域
        if (widget.aiMessage.hasReasoning) _buildReasoningTile(context),
        // AI 回复内容（Markdown）
        SmoothMarkdown(
          data: widget.aiMessage.content,
          styleSheet: MarkdownStyleSheet.fromTheme(theme),
          selectable: true,
          onTapLink: (url) {},
        ),
        // 流式加载指示器
        if (widget.isStreaming)
          const Padding(
            padding: EdgeInsets.only(left: 4, top: 4),
            child: SizedBox(
              width: 8,
              height: 8,
              child: CircularProgressIndicator(strokeWidth: 1),
            ),
          ),
      ],
    );
  }

  // 推理部分
  Widget _buildReasoningTile(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: const Icon(Icons.psychology),
            title: const Text('思考过程'),
            trailing: Icon(_showReason ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _showReason = !_showReason),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(8),
              child: SmoothMarkdown(
                data: widget.aiMessage.reasoningContent,
                styleSheet: MarkdownStyleSheet.fromTheme(theme),
                selectable: true,
              ),
            ),
            crossFadeState: _showReason
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      name: 'AI',
      avatar: const CircleAvatar(child: Icon(Icons.smart_toy, size: 20)),
      isMe: false,
      buildMessageContent: _buildMessageContent,
    );
  }
}
