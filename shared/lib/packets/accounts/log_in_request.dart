import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/packets/request_packet.dart';

part 'log_in_request.mapper.dart';

/// 登录请求
@MappableClass()
class LogInRequest extends RequestPacket with LogInRequestMappable {
  LogInRequest({required this.username, required this.password, super.stamp});

  final String username; // 用户名
  final String password; // 密码
}
