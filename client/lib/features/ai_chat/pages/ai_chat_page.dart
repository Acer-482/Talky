import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/ai_chat/models/ai_chat_message.dart';
import 'package:talky_client/features/ai_chat/models/ai_chat_model.dart';
import 'package:talky_client/features/chat/widgets/chat_bubble/ai_chat_bubble.dart';
import 'package:talky_client/features/chat/widgets/chat_bubble/chat_bubble.dart';
import 'package:talky_client/features/chat/widgets/chat_message_list.dart';
import 'package:talky_client/features/chat/widgets/chat_text_field.dart';

/// 心理AI聊天页面
class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<StatefulWidget> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  /// 发送消息
  bool send(String text) {
    context.read<AiChatModel>().sendMessage(text); // 发送消息
    setState(() {}); // 更新UI
    return true;
  }

  /// 构建主体
  Widget _buildBody() {
    return Consumer<AiChatModel>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          actions: [
            TextButton.icon(
              onPressed: () {
                model.cleanChatMessageList();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重置聊天记录'),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: .end,
          children: [
            Expanded(
              child: ChatMessageList(
                bubbleBuilder: (context, animation, item, index) {
                  final message = item as AiChatMessage;
                  // 用户
                  if (message.role == .user) {
                    return ChatBubble(message: message.content, isMe: true);
                  }
                  if (message.role == .assistant) {
                    // ai
                    return AiChatBubble(
                      aiMessage: message,
                      isStreaming: model.isStreaming,
                    );
                  } else {
                    return SizedBox();
                  }
                },
                items: model.messages,
                areItemsTheSame: (a, b) => a == b,
              ),
            ),
            ChatTextField(onSubmit: send),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(padding: .all(10), child: _buildBody());
  }
}
