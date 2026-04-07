import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/account/models/account_model.dart';
import 'package:talky_client/features/account/widgets/account_profile_widget.dart';
import 'package:talky_shared/account/account_profile.dart';

/// 账户资料组件
class AccountProfilePage extends StatelessWidget {
  /// 账户资料
  final AccountProfile profile;
  const AccountProfilePage({required this.profile, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: .all(0),
      title: Text('${profile.username}的账户资料'),
      content: AccountProfileWidget(
        avatar: context.read<AccountModel>().getAvatar(
          profile.username,
        ), // 获取头像
        accountProfile: profile,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
