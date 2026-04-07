import 'package:dart_mappable/dart_mappable.dart';

part 'base_chat_message.mapper.dart';

/// 基本聊天信息
///
/// 代表一条聊天消息
@MappableClass()
abstract class BaseChatMessage with BaseChatMessageMappable {
  /// 消息id
  final String id;

  /// 发送者id
  final String sender;

  /// 目标id
  final String target;

  /// 创建时间
  final DateTime timestamp;

  BaseChatMessage({
    required this.id,
    required this.sender,
    required this.target,
    DateTime? createDateTime,
  }) : timestamp = createDateTime ?? DateTime.now();
}
