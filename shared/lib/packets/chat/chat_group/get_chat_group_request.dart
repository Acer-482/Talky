import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/packets/request_packet.dart';

part 'get_chat_group_request.mapper.dart';

/// 树洞组列表请求
@MappableClass()
class GetChatGroupsRequest extends RequestPacket
    with GetChatGroupsRequestMappable {
  GetChatGroupsRequest({this.allChatGroups = false, super.stamp});

  final bool allChatGroups;
}
