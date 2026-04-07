import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_client/features/ai_chat/enums/ai_chat_message_sender.dart';

part 'ai_chat_message.mapper.dart';

/// ai聊天消息
@MappableClass()
class AiChatMessage with AiChatMessageMappable {
  /// 角色
  final AiChatMessageSender role;

  /// 消息内容缓冲区
  final StringBuffer _contentBuffer = StringBuffer();

  /// 获取内容
  String get content => _contentBuffer.toString();

  /// 是否有深度思考内容
  bool get hasReasoning => _reasoningContentBuffer.isNotEmpty;

  /// 思索内容缓冲区
  final StringBuffer _reasoningContentBuffer = StringBuffer();

  /// 获取思索内容
  String get reasoningContent => _reasoningContentBuffer.toString();

  /// 完成标志
  bool _isFinish = false;

  /// 检查消息是否已经完成
  bool get isFinish => _isFinish;

  AiChatMessage({
    required this.role,
    String? reasoningContent,
    String? content,
  }) {
    // 添加内容到缓冲区 //
    _reasoningContentBuffer.write(reasoningContent ?? '');
    _contentBuffer.write(content ?? '');

    /// 发送者非AI //
    if (role != .assistant) {
      if (content == null) throw Exception('发送者非AI时必须提供消息内容');
      finish(); // 立即完成
    }
  }

  /// 添加内容
  void append(String chunk) {
    if (_isFinish) return;
    _contentBuffer.write(chunk);
  }

  /// 添加思索内容
  void appendReasoning(String chunk) {
    if (_isFinish) return;
    _reasoningContentBuffer.write(chunk);
  }

  // 标记消息为完成
  String finish() {
    _isFinish = true;
    return content;
  }
}
