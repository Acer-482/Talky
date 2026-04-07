import 'package:flutter/material.dart';

/// 文本框工具类
class TextFieldUtils {
  /// 构建标准输入框
  ///
  /// 参数：
  /// - [controller] - 控制器
  /// - [text] - 文本
  /// - [icon] - 前缀图标
  /// - [suffixIcon] - 后缀图标
  /// - [minLines] - 最小行数
  /// - [maxLines] - 最小行数
  /// - [obscureText] - 密码模式
  /// - [validator] - 验证器
  static TextFormField buildStdTextForm(
    TextEditingController controller,
    String text, {
    Widget? icon,
    Widget? suffixIcon,
    int? minLines,
    int? maxLines = 1,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: icon, // 前缀图标
        suffix: suffixIcon, // 后缀图标
        labelText: text,
      ),
      minLines: minLines,
      maxLines: maxLines,
      obscureText: obscureText, // 密码输入框
      validator: validator, // 表单验证器
    );
  }
}
