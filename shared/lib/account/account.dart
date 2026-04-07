import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/hobby_tag/hobby_tag.dart';

part 'account.mapper.dart';

/// 账户类
@MappableClass()
class Account with AccountMappable {
  /// 账户id
  final String id;

  /// 用户名
  String username;

  /// 密码
  String password;

  /// 加入的树洞id列表
  final List<String> joinedChatGroup = [];

  /// 年龄
  int? age;

  /// 兴趣爱好
  List<HobbyTag>? hobbyTags;

  /// 个性签名
  String? signature;

  /// 手机号
  String? phoneNumber;

  /// 邮箱
  String? email;

  /// 登录的客户端id
  String? clientId;

  /// 最后登录日期
  DateTime? lastLoggedDateTime;

  /// 创建日期
  DateTime createdDateTime;

  Account({
    required this.id,
    required this.username,
    required this.password,
    this.age,
    this.hobbyTags,
    this.signature,
    this.phoneNumber,
    this.email,
    DateTime? createdDateTime,
  }) : createdDateTime = createdDateTime ?? DateTime.now();

  /// 登录
  ///
  /// 当已经登录时返回false
  bool login(String clientId) {
    if (this.clientId != null) return false;
    lastLoggedDateTime = DateTime.now(); // 更新最后登录时间
    this.clientId = clientId; // 设置客户端id
    return true;
  }

  /// 登出
  ///
  /// 当未登录时返回false
  bool logout() {
    if (clientId == null) return false;
    clientId = null; // 清空客户端id
    return true;
  }
}
