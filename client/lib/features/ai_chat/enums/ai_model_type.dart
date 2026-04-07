/// ai模型类型
enum AiModelType { deepseekV3 }

/// Ai模型Api请求路径
extension AiModelsApiPath on AiModelType {
  
  String get path => switch (this) {
    .deepseekV3 => 'deepseek-ai/DeepSeek-V3.2',
  };
}
