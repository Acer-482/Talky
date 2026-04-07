import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/packets/base_packet.dart';

part 'request_packet.mapper.dart';

/// 请求包
@MappableClass()
abstract class RequestPacket extends BasePacket with RequestPacketMappable {
  RequestPacket({super.stamp});
}
