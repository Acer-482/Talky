import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:talky_client/features/ai_chat/enums/ai_chat_message_sender.dart';
import 'package:talky_client/features/ai_chat/enums/ai_model_type.dart';
import 'package:talky_client/features/ai_chat/models/ai_chat_message.dart';

/// API服务
///
/// 提供与Api通信的方法
class ApiService {
  Client? _client; // 客户端 用于流式请求

  bool _isStreaming = false; // 正在传输
  bool get isStreaming => _isStreaming;

  /// 发送消息
  ///
  /// 参数：
  /// - [messages] - 消息列表 - 将不会修改列表
  /// - [content] - 消息内容
  /// - [model] -  ai模型类型
  /// - [onMessageReady] - 当 `AI消息已准备好` 时调用该回调 - 建议此时将消息加入列表
  /// - [onChunk] - 当 `接收到新chunk` 时调用该回调
  /// - [onChunkError] - 当 `chunk发生错误` 时调用该回调
  /// - [onDone] - 当 `接收消息完成` 时调用该回调
  /// - [onError] - 当 `发生错误` 时调用该回调
  ///
  /// 当返回`false`时 为请求失败
  Future<bool> sendMessage(
    final List<AiChatMessage> messages,
    String? content, {
    required AiModelType model,
    Function(AiChatMessage message)? onMessageReady,
    Function(AiChatMessage partial)? onChunk,
    Function(Object error)? onChunkError,
    Function(AiChatMessage message)? onDone,
    Function(Object error)? onError,
  }) async {
    if (_isStreaming) return false;
    _isStreaming = true;
    // 发送请求 //
    try {
      // 获取api key //
      final apiKey = dotenv.env['SILICONFLOW_API_KEY'];
      if (apiKey == null) throw Exception('API Key 未设置');
      // 构建请求头 //
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };
      // 构建消息 //
      final history = messages.map((m) {
        return {'role': m.role.name, 'content': m.content};
      }).toList();
      // 构建请求主体 //
      final body = jsonEncode({
        'model': model.path, // 模型路径
        'messages': history, // 消息内容/历史
        'stream': true, // 流式
        'enable_thinking': true, // 深度思考
        'max_tokens': 2048, // 最大token
        'temperature': 0.7,
      });

      // 开始流式请求 //
      final request =
          Request(
              'POST',
              Uri.parse('https://api.siliconflow.cn/v1/chat/completions'),
            )
            ..headers.addAll(headers)
            ..body = body;
      _client = Client(); // 构建客户端
      final streamedResponse = await _client!.send(request);
      // 检查返回状态码 //
      if (streamedResponse.statusCode != 200) {
        // 错误响应 读取完整错误信息 //
        final errorBody = await streamedResponse.stream.bytesToString();
        throw Exception('API 错误: ${streamedResponse.statusCode} - $errorBody');
      }
      // 创建AI消息 //
      final assistantMsg = AiChatMessage(role: .assistant, content: '');
      onMessageReady?.call(assistantMsg); // 消息准备 回调
      // 处理流式响应 //
      final stream = streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter()); // 逐行解码器
      // 逐行解码 SSE格式的返回数据 //
      await for (final line in stream) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6); // 获取数据内容，跳过前六个字符('data: ')
          if (data == '[DONE]') {
            break; // 流结束
          }
          // 解码chunk //
          try {
            final jsonChunk = jsonDecode(data);
            final delta = jsonChunk['choices'][0]['delta'];
            if (delta != null) {
              if (delta['reasoning_content'] != null) {
                assistantMsg.appendReasoning(
                  delta['reasoning_content'] as String,
                );
              } // 处理思考内容
              if (delta['content'] != null) {
                assistantMsg.append(delta['content'] as String);
              } // 处理普通内容
              onChunk?.call(assistantMsg); // chunk 回调
            }
          } catch (e) {
            onChunkError?.call(e);
          }
        }
      }

      // 完成 //
      assistantMsg.finish(); // 标记消息完成
      onDone?.call(assistantMsg); // 流完成
      _isStreaming = false;
      return true;
    } catch (e) {
      // 发生错误 //
      onError?.call(e);
      return false;
    } finally {
      cancel();
    }
  }

  /// 取消请求
  void cancel() {
    _client?.close();
    _client = null;
    _isStreaming = false;
  }
}
