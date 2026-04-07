import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/packets/request_packet.dart';

part 'get_message_list_request.mapper.dart';

/// 获取消息请求
@MappableClass()
class GetMessageListRequest extends RequestPacket
    with GetMessageListRequestMappable {
  GetMessageListRequest({
    required this.id,
    this.startId,
    required this.count,
    super.stamp,
  });

  /// 树洞id
  final String id;

  /// 基准的消息id
  final String? startId;

  /// 获取数量
  final int count;
}
