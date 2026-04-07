import 'package:flutter/material.dart';
import 'package:talky_shared/account/account.dart';
import 'package:talky_shared/account/account_profile.dart';

/// 账户资料信息
class AccountProfileWidget extends StatelessWidget {
  /// 头像
  final Widget? avatar;

  /// 账户
  final Account? account;

  /// 账户资料
  final AccountProfile accountProfile;

  /// 点击头像
  final void Function()? onTap;

  const AccountProfileWidget({
    this.avatar,
    this.account,
    required this.accountProfile,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: .min,
        children: [
          ListTile(
            leading: avatar, // 头像
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountProfile.username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (accountProfile.description != null)
                  Text(
                    accountProfile.description!,
                    style: const TextStyle(color: Colors.grey),
                  ),
              ], // 账户名与描述
            ), // 卡片主体
            trailing: onTap == null
                ? null
                : const Icon(Icons.more_horiz, size: 16), // 更多信息 图标
            onTap: onTap,
          ), // 用户卡片
          const Divider(height: 32), // 分割线
          _buildMoreInfo(Icons.numbers_rounded, 'ID: ', accountProfile.id),
          _buildMoreInfo(
            Icons.numbers,
            '年龄: ',
            accountProfile.age != null ? '${accountProfile.age}' : null,
          ),
          _buildMoreInfo(
            Icons.abc,
            '爱好: ',
            accountProfile.hobbies?.map((e) => e.hobby).join(','),
          ),
          _buildMoreInfo(Icons.phone, '电话: ', accountProfile.phoneNumber),
          _buildMoreInfo(Icons.email_outlined, '电子邮件: ', accountProfile.email),
        ],
      ),
    );
  }

  // 构建更多信息
  Widget _buildMoreInfo(IconData iconData, String head, String? data) {
    return data != null && data.isNotEmpty
        ? Row(
            spacing: 8,
            children: [
              Icon(iconData, size: 18, color: Colors.grey),
              Expanded(
                child: Text('$head$data', maxLines: 3, overflow: .ellipsis),
              ),
            ],
          )
        : Container();
  }
}
