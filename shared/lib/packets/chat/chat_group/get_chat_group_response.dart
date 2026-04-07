import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/chat/chat_group/chat_group.dart';
import 'package:talky_shared/packets/status_response.dart';

part 'get_chat_group_response.mapper.dart';

/// 获取树洞响应
@MappableClass()
class GetChatGroupResponse extends StatusResponse
    with GetChatGroupResponseMappable {
  GetChatGroupResponse({
    this.chatGroupList,
    this.allChatGroups,
    required super.status,
    super.message,
    super.stamp,
  });

  // 树洞列表
  final List<ChatGroup>? chatGroupList;

  /// 返回所有树洞
  final bool? allChatGroups;
}
