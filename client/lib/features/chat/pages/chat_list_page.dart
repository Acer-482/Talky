import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/account/models/account_model.dart';
import 'package:talky_client/features/chat/models/chat_model.dart';
import 'package:talky_client/core/pages/status/disconnect_page.dart';
import 'package:talky_client/core/pages/status/not_logged_page.dart';
import 'package:talky_client/features/chat/pages/chat_page.dart';
import 'package:talky_client/features/chat/pages/chat_group_form_page.dart';
import 'package:talky_client/features/chat/pages/join_chat_group.dart';
import 'package:talky_client/features/account/pages/forms/login_form_page.dart';
import 'package:talky_client/core/utils/button_utils.dart';
import 'package:talky_client/features/settings/models/network_config_model.dart';
import 'package:talky_shared/chat/chat_group/chat_group.dart';

/// 聊天列表页面
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<StatefulWidget> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
  }

  // 跳转到创建树洞页面
  Future<void> _navigateToCreateChatGroup() {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatGroupFormPage()),
    );
  }

  // 跳转到加入树洞页面
  Future<void> _navigateToJoinChatGroup() {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JoinChatGroupPage()),
    );
  }

  /// 构建并验证数据
  Widget _buildWithCheckData(ChatModel chatModel) {
    final networkConfigModel = context.read<NetworkConfigModel>();
    // 未连接 //
    if (!chatModel.isConnected) {
      return const Center(child: DisconnectPage());
    }
    // 未登录 //
    if (!context.read<AccountModel>().isLogged) {
      // 自动登录 //
      if (networkConfigModel.autoLogin) {
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginFormPage()),
          ),
        ); // 跳转到登录页面
      }
      return const Center(child: NotLoggedPage());
    }
    // 树洞列表无效 //
    if (!chatModel.isChatGroupVaild) {
      chatModel.sendGetChatGroupRequest(); // 发送更新请求
      return Center(child: CircularProgressIndicator()); // 返回加载动画
    }
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 600),
      child: chatModel.chatGroupList!.isEmpty
          ? _buildGuidePage(chatModel) // 状态为空 显示引导页面
          : _buildListBody(chatModel), // 均完毕 构建页面主体,
    );
  }

  /// 构建列表主体
  Widget _buildListBody(ChatModel model) {
    return Container(
      key: ValueKey('ListBody'), // 提供key 以支持动画
      margin: .all(12), // 外边距
      child: Scaffold(
        appBar: _buildAppbar(model),
        body: _buildAnimatedList(model),
      ), // 页面骨架
    );
  }

  /// 构建应用栏
  AppBar _buildAppbar(ChatModel model) {
    return AppBar(
      title: Text('聊天列表'),
      actions: [
        IconButton(
          onPressed: () {
            model.sendGetChatGroupRequest(); // 发送请求
          },
          icon: const Icon(Icons.refresh),
          tooltip: '刷新列表',
        ),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          tooltip: '更多',
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'create',
              child: Row(spacing: 4, children: [Icon(Icons.add), Text('创建树洞')]),
            ),
            const PopupMenuItem<String>(
              value: 'join',
              child: Row(
                spacing: 4,
                children: [Icon(Icons.arrow_outward_rounded), Text('加入树洞')],
              ),
            ),
          ],
          onSelected: (String value) {
            // 处理菜单项选择
            switch (value) {
              case 'create':
                _navigateToCreateChatGroup();
                break;
              case 'join':
                _navigateToJoinChatGroup();
                break;
            }
          },
        ),
      ], // 按钮组
    );
  }

  /// 构建动画列表
  Widget _buildAnimatedList(ChatModel model) {
    final List<ChatGroup> chatGroupList = model.chatGroupList!; // 树洞列表
    return ImplicitlyAnimatedList<ChatGroup>(
      items: chatGroupList,
      areItemsTheSame: (oldItem, newItem) =>
          oldItem.id == newItem.id, // 提供比较器，通过判断id检测是否为同一元素
      itemBuilder: (context, animation, item, i) => SizeFadeTransition(
        animation: animation,
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                item.name.substring(0, 1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ), // 树洞图标
          title: Text(item.name),
          subtitle: item.description != null ? Text(item.description!) : null,
          onTap: () {
            // 跳转到创建树洞页面
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => ChatPage(chatGroup: item),
              ), // 需实现
            );
          },
        ),
      ),
    );
  }

  // 构建引导页面
  Widget _buildGuidePage(ChatModel model) {
    return Center(
      key: ValueKey('GuidePage'), // 提供key 以支持动画
      child: Padding(
        padding: const EdgeInsets.all(24), // 内边距
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text(
              '让我们开始，首先要做的是？', // 好浓的微软味
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32), // 32像素的分割
            Row(
              children: [
                Expanded(
                  child: ButtonUtils.buildLargeButton(
                    label: '创建树洞',
                    icon: Icons.add,
                    onPressed: () => _navigateToCreateChatGroup(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ButtonUtils.buildLargeButton(
                    label: '加入树洞',
                    icon: Icons.group_add,
                    onPressed: () => _navigateToJoinChatGroup(),
                  ),
                ),
              ],
            ), // 水平布局
          ],
        ), // 垂直布局
      ), // 内边距
    ); // 中心布局
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatModel>(
      builder: (context, model, child) {
        return _buildWithCheckData(model);
      },
    );
  }
}
