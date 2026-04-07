import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/chat/base_chat_message.dart';
import 'package:talky_shared/packets/status_response.dart';

part 'get_message_list_response.mapper.dart';

/// 获取消息列表响应
@MappableClass()
class GetMessageListResponse extends StatusResponse
    with GetMessageListResponseMappable {
  GetMessageListResponse({
    this.id,
    this.messageList,
    this.isFinish,
    required super.status,
    super.message,
    super.stamp,
  });

  /// 树洞id
  final String? id;

  /// 消息列表
  final List<BaseChatMessage>? messageList;

  /// 全部读取完毕
  final bool? isFinish;
}
