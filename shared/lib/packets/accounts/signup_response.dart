import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/account/account.dart';
import 'package:talky_shared/packets/status_response.dart';

part 'signup_response.mapper.dart';

/// 注册响应
@MappableClass()
class SignupResponse extends StatusResponse with SignupResponseMappable {
  SignupResponse({
    this.account,
    required super.status,
    super.message,
    super.stamp,
  });

  /// 注册创建的账户
  Account? account;
}
