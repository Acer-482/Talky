import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/hobby_tag/hobby_tag.dart';
import 'package:talky_shared/packets/request_packet.dart';

part 'create_chat_group_request.mapper.dart';

/// 创建树洞请求
@MappableClass()
class CreateChatGroupRequest extends RequestPacket
    with CreateChatGroupRequestMappable {
  CreateChatGroupRequest({
    required this.name,
    this.description,
    this.hobbyTags,
    super.stamp,
  });

  /// 组名
  String name;

  /// 介绍
  String? description;

  /// 群爱好
  List<HobbyTag>? hobbyTags;
}
