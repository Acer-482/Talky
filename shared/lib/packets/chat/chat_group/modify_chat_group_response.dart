import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/chat/chat_group/chat_group.dart';
import 'package:talky_shared/packets/status_response.dart';

part 'modify_chat_group_response.mapper.dart';

/// 修改树洞回应
@MappableClass()
class ModifyChatGroupResponse extends StatusResponse
    with ModifyChatGroupResponseMappable {
  /// 更改后的树洞
  ChatGroup? chatGroup;
  ModifyChatGroupResponse({
    this.chatGroup,
    required super.status,
    super.message,
    super.stamp,
  });
}
