import 'package:dart_mappable/dart_mappable.dart';

part 'base_packet.mapper.dart';

/// 基本数据包
///
/// 网络通信的基本数据包
@MappableClass(discriminatorKey: 'type')
abstract class BasePacket with BasePacketMappable {
  /// 数据包创建时间戳
  final DateTime stamp;

  BasePacket({DateTime? stamp}) : stamp = stamp ?? DateTime.now();
}
