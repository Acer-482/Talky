import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/chat/chat_group/chat_group_tag.dart';
import 'package:talky_shared/hobby_tag/hobby_tag.dart';

part 'chat_group.mapper.dart';

/// 树洞
@MappableClass()
class ChatGroup with ChatGroupMappable {
  /// 所有者id
  String owner;

  /// 会话id
  final String id;

  /// 组名
  String name;

  /// 介绍
  String? description;

  /// 群爱好
  List<HobbyTag>? hobbyTags;

  /// 标签
  final List<ChatGroupTag> tags = [];

  /// 成员列表id
  List<String> members;

  /// 创建时间
  final DateTime timestamp;

  ChatGroup({
    required this.owner,
    required this.id,
    required this.name,
    this.description,
    this.hobbyTags,
    List<ChatGroupTag>? tags,
    this.members = const [],
    DateTime? createTime,
  }) : timestamp = createTime ?? DateTime.now() {
    if (tags != null) {
      this.tags.addAll(tags);
    }
  }
}
