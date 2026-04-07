import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/packets/status_response.dart';

part 'logout_response.mapper.dart';

/// 登出响应
@MappableClass()
class LogoutResponse extends StatusResponse with LogoutResponseMappable {
  LogoutResponse({required super.status, super.message, super.stamp});
}
