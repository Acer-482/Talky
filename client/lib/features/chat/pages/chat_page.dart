import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/account/models/account_model.dart';
import 'package:talky_client/features/chat/models/chat_model.dart';
import 'package:talky_client/features/account/pages/account_profile_page.dart';
import 'package:talky_client/features/chat/pages/chat_group_form_page.dart';
import 'package:talky_client/features/chat/widgets/chat_bubble/chat_message_bubble.dart';
import 'package:talky_client/features/chat/widgets/chat_message_list.dart';
import 'package:talky_client/features/chat/widgets/chat_text_field.dart';
import 'package:talky_shared/account/account.dart';
import 'package:talky_shared/chat/base_chat_message.dart';
import 'package:talky_shared/chat/chat_group/chat_group.dart';
import 'package:talky_shared/chat/text_chat_message.dart';
import 'package:talky_shared/packets/chat/chat_message_packet.dart';
import 'package:talky_shared/packets/chat/get_message_list_request.dart';
import 'package:uuid/uuid.dart';

/// 聊天页面
class ChatPage extends StatefulWidget {
  const ChatPage({required this.chatGroup, super.key});
  final ChatGroup chatGroup;

  @override
  State<StatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // 跳转到编辑树洞页面
  Future<void> _navigateToModifyChatGroupPage() {
    return Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ChatGroupFormPage(chatGroup: widget.chatGroup),
      ),
    );
  }

  // 提交
  bool _submit(String text) {
    context.read<ChatModel>().sendMessage(
      widget.chatGroup.id,
      ChatMessagePacket(
        chatMessage: TextChatMessage(
          text: text,
          id: const Uuid().v7(),
          sender: context.read<AccountModel>().account!.id,
          target: widget.chatGroup.id,
        ),
      ),
    ); // 发送消息
    return true;
  }

  /// 构建消息
  Widget _buildBody(ChatModel chatModel) {
    // 获取账户 //
    final accountModel = context.read<AccountModel>();
    if (!accountModel.isLogged) {
      return const Center(child: Text('未登录'));
    }
    // 检查消息列表是否有效 //
    if (!chatModel.messageList.containsKey(widget.chatGroup.id)) {
      chatModel.sendGetMessageListRequest(
        GetMessageListRequest(id: widget.chatGroup.id, count: 50),
      );
      return const Center(child: CircleAvatar());
    }
    // 构建聊天气泡列表 //
    return Column(
      children: [
        Expanded(
          child: ChatMessageList<BaseChatMessage>(
            bubbleBuilder: (context, animation, item, i) => _buildMessageBubble(
              chatModel,
              context.read<AccountModel>().account!,
              item as BaseChatMessage,
            ),
            items: chatModel.messageList[widget.chatGroup.id]!, // 消息列表
            areItemsTheSame: (a, b) =>
                (a as BaseChatMessage).id == (b as BaseChatMessage).id, // 比较方法
            onScroll: _onScroll, // 滚动
          ),
        ),
        ChatTextField(onSubmit: _submit),
      ],
    );
  }

  /// 构建消息气泡
  Widget _buildMessageBubble(
    ChatModel chatModel,
    Account account,
    BaseChatMessage message,
  ) {
    final id = message.sender; // id
    final profile = chatModel.getAccountProfile(id); // 账户资料
    // 无账户资料则发送请求
    if (profile == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => chatModel.sendGetAccountProfileRequest(id),
      );
    }
    // 文本消息
    if (message is TextChatMessage) {
      return ChatMessageBubble(
        message: message,
        isMe: message.sender == account.id,
        profile: profile,
        onAvatarTap: () {
          WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) => chatModel.sendGetAccountProfileRequest(id),
          );
          showDialog(
            context: context,
            builder: (context) => AccountProfilePage(profile: profile!),
          );
        }, // 点击头像更新账户信息并打开账户卡片
      ); // 构建消息气泡
    }
    return Text('不支持的消息类型');
  }

  // 滚动页面
  void _onScroll(ScrollController controller) {
    if (!controller.hasClients) return; // 防止未附加时访问
    final position = controller.position; // 获取滚动位置
    // 判断是否在顶部
    if (position.pixels > position.maxScrollExtent - 10) {
      final chatModel = context.read<ChatModel>();
      final list = chatModel.messageList[widget.chatGroup.id]!;
      chatModel.sendGetMessageListRequest(
        GetMessageListRequest(
          id: widget.chatGroup.id,
          startId: list[0].id,
          count: 10,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatModel>(
      builder: (context, chatModel, child) => Scaffold(
        appBar: AppBar(
          title: Text(widget.chatGroup.name),
          actions: [
            IconButton(
              onPressed: () {
                chatModel.sendGetMessageListRequest(
                  GetMessageListRequest(id: widget.chatGroup.id, count: 10),
                );
              },
              icon: const Icon(Icons.refresh),
              tooltip: '刷新',
            ), // 刷新按钮
            IconButton(
              onPressed: _navigateToModifyChatGroupPage,
              icon: const Icon(Icons.settings),
              tooltip: '选项',
            ), // 选项按钮
          ],
        ),
        body: _buildBody(chatModel),
      ),
    );
  }
}
