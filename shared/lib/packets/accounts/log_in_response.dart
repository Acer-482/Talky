import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/account/account.dart';
import 'package:talky_shared/packets/status_response.dart';

part 'log_in_response.mapper.dart';

/// 登录响应
@MappableClass()
class LogInResponse extends StatusResponse with LogInResponseMappable {
  /// 登录的账户
  final Account? account;

  LogInResponse({
    this.account,
    required super.status,
    super.message,
    super.stamp,
  });
}
