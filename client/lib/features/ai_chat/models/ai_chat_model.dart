import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talky_client/features/ai_chat/enums/ai_model_type.dart';
import 'package:talky_client/features/ai_chat/models/ai_chat_message.dart';
import 'package:talky_client/features/settings/models/ai_chat_config_model.dart';
import 'package:talky_client/core/services/api_service.dart';

/// AI聊天模型
///
/// 在接收流时会发生大量更新 谨慎在过高的组件调用
class AiChatModel extends ChangeNotifier {
  final AiChatConfigModel aiChatConfigModel;
  final ApiService apiService; // Api模型

  List<AiChatMessage> get messages => aiChatConfigModel.messageList; // 获取消息列表
  AiModelType model; // AI模型

  AiChatModel({
    required this.aiChatConfigModel,
    required this.apiService,
    this.model = .deepseekV3,
  });

  /// 清空聊天记录
  Future<void> cleanChatMessageList() async {
    await aiChatConfigModel.updateMessageList([]); // 更新消息列表
    sendSystemMessage(
      '你是一位温暖、耐心的心理支持伙伴，请用同理心倾听，给予鼓励和建议。同时注意用户的情绪，用户的表达可能不准确，需要仔细解析潜在信号（如求助）',
    ); // 添加系统提示
    notifyListeners(); // 通知监听
  }

  /// 发送用户消息
  Future<bool> sendMessage(String? content) async {
    // 添加消息 //
    final message = AiChatMessage(role: .user, content: content); // 构建消息
    messages.add(message); // 添加消息到列表
    // 发送请求 //
    return apiService.sendMessage(
      messages,
      content,
      model: model,
      onMessageReady: (message) {
        messages.add(message);
        notifyListeners();
      },
      onChunk: (partial) {
        notifyListeners();
      },
      onDone: (message) => aiChatConfigModel.updateMessageList(messages),
    );
  }

  /// 发送系统消息
  ///
  /// 仅添加到列表 不会发送网络请求 直到用户信息发出
  void sendSystemMessage(String? content) {
    final message = AiChatMessage(role: .system, content: content); // 构建消息
    messages.add(message); // 添加消息到列表
  }

  /// 正在传输
  bool get isStreaming => apiService.isStreaming;
}
