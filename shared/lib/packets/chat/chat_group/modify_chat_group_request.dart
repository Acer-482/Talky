import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/chat/chat_group/chat_group.dart';
import 'package:talky_shared/packets/request_packet.dart';

part 'modify_chat_group_request.mapper.dart';

/// 修改树洞请求
@MappableClass()
class ModifyChatGroupRequest extends RequestPacket
    with ModifyChatGroupRequestMappable {
  /// 更改后的树洞
  ChatGroup chatGroup;
  ModifyChatGroupRequest({required this.chatGroup, super.stamp});
}
