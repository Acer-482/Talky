import 'package:talky_shared/chat/base_chat_message.dart';

/// 信息数据库拓展方法
extension MessageDb on BaseChatMessage {
  /// 转为数据库map
  ///
  /// 用于插入信息表
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'sender': sender,
      'target': target,
      'data': toJson(),
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// 从数据库map还原信息
  static BaseChatMessage fromDbMap(Map<String, dynamic> map) {
    final jsonString = map['data'] as String;
    return BaseChatMessageMapper.fromJson(jsonString);
  }
}
