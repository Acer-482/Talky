import 'package:talky_client/features/ai_chat/models/ai_chat_message.dart';
import 'package:talky_client/features/settings/models/base_config_model.dart';

/// AI聊天配置模型
class AiChatConfigModel extends BaseConfigModel {
  static const String _keyMessageList = 'message_list'; // 消息列表

  @override
  String get mainKey => 'ai_chat';

  /// 消息列表
  late List<AiChatMessage> messageList;

  AiChatConfigModel({required super.configService});
  @override
  Future<void> init() async {
    messageList = await configService.getList(
      getKey(_keyMessageList),
      [],
      AiChatMessageMapper.fromJson,
    );
  }

  /// 更新AI消息列表
  Future<void> updateMessageList(List<AiChatMessage> messageList) async {
    this.messageList = messageList;
    await configService.setList(
      getKey(_keyMessageList),
      messageList,
      (value) => value.toJson(),
    );
    notifyListeners();
  }
}
