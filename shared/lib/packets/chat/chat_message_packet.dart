import 'package:dart_mappable/dart_mappable.dart';
import 'package:talky_shared/chat/base_chat_message.dart';
import 'package:talky_shared/packets/base_packet.dart';

part 'chat_message_packet.mapper.dart';

/// 聊天信息包
///
/// 代表了一条消息
///
/// 由客户端发出时，为发送消息；由服务器发出时，为群发消息
@MappableClass()
class ChatMessagePacket extends BasePacket with ChatMessagePacketMappable {
  ChatMessagePacket({required this.chatMessage, super.stamp});

  /// 聊天信息
  final BaseChatMessage chatMessage;
}
