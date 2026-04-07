import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/packets/request_packet.dart';

part 'join_chat_group_request.mapper.dart';

/// 加入树洞请求
@MappableClass()
class JoinChatGroupRequest extends RequestPacket
    with JoinChatGroupRequestMappable {
  JoinChatGroupRequest({this.id, super.stamp});

  final String? id;
}
