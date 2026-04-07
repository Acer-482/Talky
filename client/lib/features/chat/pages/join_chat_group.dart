import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/account/models/account_model.dart';
import 'package:talky_client/features/chat/models/chat_model.dart';
import 'package:talky_client/core/pages/status/disconnect_page.dart';
import 'package:talky_shared/chat/chat_group/chat_group.dart';
import 'package:talky_shared/packets/chat/chat_group/join_chat_group_request.dart';

/// 加入树洞页面
class JoinChatGroupPage extends StatefulWidget {
  const JoinChatGroupPage({super.key});

  @override
  State<StatefulWidget> createState() => _JoinChatGroupPageState();
}

class _JoinChatGroupPageState extends State<JoinChatGroupPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController; // 标签控制器

  @override
  void initState() {
    super.initState();
    // 初始化标签控制器 //
    _tabController = TabController(length: 2, vsync: this);
    // 更新列表 //
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => _updateList(context.read<ChatModel>()),
    );
  }

  /// 更新列表
  void _updateList(ChatModel model) {
    model.sendGetChatGroupRequest(allChatGroups: true); // 更新
  }

  /// 加入
  void _join(ChatModel model, ChatGroup chatGroup) {
    model.sendJoinChatGroupRequest(JoinChatGroupRequest(id: chatGroup.id));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatModel>(
      builder: (context, model, child) {
        return model.networkService.connectionState == .disconnected
            ? const Center(child: DisconnectPage())
            : Scaffold(
                appBar: AppBar(
                  title: Text('加入树洞'),
                  bottom: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: '智能检索'),
                      Tab(text: '全部群聊'),
                    ],
                  ), // 标签栏
                ),
                body: model.allChatGroupList == null
                    ? CircularProgressIndicator() // 加载
                    : Container(
                        padding: .all(10),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAutoSearch(model),
                            _buildAllChatList(model),
                          ],
                        ), // 标签浏览器
                      ), // 容器
                floatingActionButton: FloatingActionButton(
                  onPressed: () => _updateList(model),
                  tooltip: '刷新',
                  child: const Icon(Icons.refresh),
                ),
              );
      },
    );
  }

  Widget _buildAutoSearch(ChatModel model) {
    final user = context.read<AccountModel>().account; // 获取用户
    final allGroups = model.allChatGroupList ?? []; // 获取群聊列表
    if (user == null) return Center(child: Text('请先登录')); // 提示登录
    final userHobbies = user.hobbyTags ?? []; // 获取用户爱好
    // 检测用户是否有兴趣爱好 //
    if (userHobbies.isEmpty) {
      return const Center(child: Text('请在个人资料中设置兴趣爱好，以便获得精准推荐'));
    }
    // 筛选匹配的群聊 //
    final ranked = <ChatGroup>[];
    for (var group in allGroups) {
      if (group.hobbyTags != null &&
          group.hobbyTags!.where((t) => userHobbies.contains(t)).isNotEmpty) {
        ranked.add(group);
      }
    }
    // 按匹配度降序 //
    ranked.sort((a, b) {
      int aMatch = a.hobbyTags!.where((t) => userHobbies.contains(t)).length;
      int bMatch = b.hobbyTags!.where((t) => userHobbies.contains(t)).length;
      return bMatch.compareTo(aMatch);
    });
    // 检测是否有可推荐的树洞 //
    if (ranked.isEmpty) return const Center(child: Text('无可推荐树洞，创建一个相关的吧！'));
    // 构建 //
    return _buildAllChatList(model);
  }

  // 构建全部群聊
  Widget _buildAllChatList(ChatModel model) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final chatGroup = model.allChatGroupList![index];
        StringBuffer subTitle = StringBuffer();
        if (chatGroup.description != null &&
            chatGroup.description!.isNotEmpty) {
          subTitle.write('介绍：${chatGroup.description!}\n');
        }
        if (chatGroup.hobbyTags != null && chatGroup.hobbyTags!.isNotEmpty) {
          subTitle.write(
            '树洞爱好：${chatGroup.hobbyTags!.map((e) => e.hobby).join('、')}',
          );
        }
        return Card(
          child: ListTile(
            title: Text(chatGroup.name),
            subtitle: subTitle.isNotEmpty ? Text(subTitle.toString()) : null,
            trailing: const Icon(Icons.add),
            enabled: !chatGroup.members.contains(
              context.read<AccountModel>().account!.id,
            ), // 当前账户在树洞内则不允许加入
            onTap: () => _join(model, chatGroup),
          ), // 树洞列表项
        );
      },
      itemCount: model.allChatGroupList!.length,
    );
  }
}
