import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/packets/request_packet.dart';

part 'logout_request.mapper.dart';

/// 登出请求
@MappableClass()
class LogoutRequest extends RequestPacket with LogoutRequestMappable {
  LogoutRequest({super.stamp});
}
