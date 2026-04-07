import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/account/models/account_model.dart';
import 'package:talky_client/core/pages/status/disconnect_page.dart';
import 'package:talky_client/core/pages/status/not_logged_page.dart';
import 'package:talky_client/features/account/pages/forms/login_form_page.dart';
import 'package:talky_client/features/account/pages/forms/account_form_page.dart';
import 'package:talky_client/features/account/widgets/account_profile_widget.dart';
import 'package:talky_client/features/settings/models/network_config_model.dart';
import 'package:talky_shared/account/account.dart';
import 'package:talky_shared/account/account_profile.dart';

/// 账户页面
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<StatefulWidget> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  /// 构建并验证数据
  Widget _buildWithCheckData(AccountModel model) {
    // 未连接 //
    if (!model.isConnected) {
      return const Center(child: DisconnectPage());
    }
    // 未登录 //
    if (!model.isLogged) {
      // 自动登录 //
      if (context.read<NetworkConfigModel>().autoLogin) {
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginFormPage()),
          ),
        ); // 跳转到登录页面
      }
      return Center(child: const NotLoggedPage());
    }
    return _buildPageBody(model);
  }

  /// 弹出下方菜单
  Future<void> _showBottomSheet(AccountModel model) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: .all(10),
        child: ListView(
          children: [
            ListTile(
              title: const Text('修改账户'),
              subtitle: const Text('修改账户相关数据，如账户名称、密码等'),
              trailing: const Icon(Icons.edit),
              onTap: () => _modifyAccount(model),
            ),
            ListTile(
              title: const Text('登出账户'),
              subtitle: const Text('登出当前登录到的账户'),
              trailing: const Icon(Icons.logout),
              onTap: () => _logoutAccount(model),
            ),
          ],
        ),
      ),
    ); // 显示底部菜单
  }

  /// 修改账户
  Future<void> _modifyAccount(AccountModel model) async {
    Navigator.pop(context); // 关闭菜单
    if (model.account != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AccountFormPage(account: model.account!),
        ),
      );
    }
  }

  /// 登出账户
  Future<void> _logoutAccount(AccountModel account) async {
    Navigator.pop(context); // 关闭菜单
    account.sendLogoutRequest(); // 发送登出请求
  }

  // 构建页面主体
  Widget _buildPageBody(AccountModel accountModel) {
    final Account account = accountModel.account!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // 背景
      margin: const EdgeInsets.all(16),
      child: AccountProfileWidget(
        avatar: accountModel.buildAvatar(),
        account: account,
        accountProfile: AccountProfile.fromAccount(account),
        onTap: () => _showBottomSheet(accountModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountModel>(
      builder: (context, accountModel, child) =>
          _buildWithCheckData(accountModel),
    );
  }
}
