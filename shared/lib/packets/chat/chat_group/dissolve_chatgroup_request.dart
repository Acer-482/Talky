import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/packets/request_packet.dart';

part 'dissolve_chatgroup_request.mapper.dart';

/// 解散树洞请求
@MappableClass()
class DissolveChatgroupRequest extends RequestPacket
    with DissolveChatgroupRequestMappable {
  DissolveChatgroupRequest({required this.id, super.stamp});

  // 解散的树洞id
  String id;
}
