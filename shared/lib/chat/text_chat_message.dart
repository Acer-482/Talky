import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/chat/base_chat_message.dart';

part 'text_chat_message.mapper.dart';

/// 文本聊天消息
@MappableClass()
class TextChatMessage extends BaseChatMessage with TextChatMessageMappable {
  /// 文本内容
  final String text;

  TextChatMessage({
    required this.text,
    required super.id,
    required super.sender,
    required super.target,
    super.createDateTime,
  });
}
