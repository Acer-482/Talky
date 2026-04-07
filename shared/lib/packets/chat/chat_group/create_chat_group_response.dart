import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/chat/chat_group/chat_group.dart';
import 'package:talky_shared/packets/status_response.dart';

part 'create_chat_group_response.mapper.dart';

/// 创建树洞响应
@MappableClass()
class CreateChatGroupResponse extends StatusResponse
    with CreateChatGroupResponseMappable {
  CreateChatGroupResponse({
    this.chatGroup,
    required super.status,
    super.message,
    super.stamp,
  });

  /// 树洞
  ChatGroup? chatGroup;
}
