import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/chat/chat_group/chat_group.dart';
import 'package:talky_shared/packets/status_response.dart';

part 'join_chat_group_response.mapper.dart';

/// 加入树洞回复
@MappableClass()
class JoinChatGroupResponse extends StatusResponse
    with JoinChatGroupResponseMappable {
  JoinChatGroupResponse({
    this.chatGroup,
    required super.status,
    super.message,
    super.stamp,
  });

  final ChatGroup? chatGroup;
}
