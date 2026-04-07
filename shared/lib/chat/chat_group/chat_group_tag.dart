import 'package:dart_mappable/dart_mappable.dart';

part 'chat_group_tag.mapper.dart';

/// 树洞标签
@MappableClass()
class ChatGroupTag with ChatGroupTagMappable {
  final String tag; // 标签内容

  const ChatGroupTag({required this.tag});
}
