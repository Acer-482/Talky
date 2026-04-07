import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/packets/base_packet.dart';

part 'status_response.mapper.dart';

/// 响应数据包
///
/// 继承该类以实现相对应的 状态响应
///
/// 通常由服务器发出
@MappableClass()
abstract class StatusResponse extends BasePacket with StatusResponseMappable {
  StatusResponse({required this.status, this.message, super.stamp});

  /// 状态码
  final int status;

  /// 额外信息
  final String? message;
}
