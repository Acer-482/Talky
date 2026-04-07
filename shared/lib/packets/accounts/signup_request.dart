import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/hobby_tag/hobby_tag.dart';
import 'package:talky_shared/packets/request_packet.dart';

part 'signup_request.mapper.dart';

/// 表单请求
@MappableClass()
class SignupRequest extends RequestPacket with SignupRequestMappable {
  /// 用户名
  String username;

  /// 密码
  String password;

  /// 年龄
  int? age;

  /// 兴趣爱好
  List<HobbyTag>? hobbies;

  /// 描述
  String? signature;

  /// 手机号
  String? phoneNumber;

  /// 邮箱
  String? email;

  SignupRequest({
    required this.username,
    required this.password,
    this.age,
    this.hobbies,
    this.signature,
    this.phoneNumber,
    this.email,
    super.stamp,
  });
}
