import 'package:dart_mappable/dart_mappable.dart';

part 'ai_chat_message_sender.mapper.dart';

/// AI聊天消息角色
@MappableEnum()
enum AiChatMessageSender {
  /// 系统
  system,

  /// AI
  assistant,

  /// 用户
  user,
}

/// AI聊天消息角色名称
extension AiChatMessageRoleName on AiChatMessageSender {
  String get name => switch (this) {
    .system => 'system',
    .user => 'user',
    .assistant => 'assistant',
  };
}
