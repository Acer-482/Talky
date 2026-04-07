import 'package:flutter/material.dart';

class ChatTextField extends StatefulWidget {
  /// 提交
  final bool Function(String text)? onSubmit;

  const ChatTextField({this.onSubmit, super.key});

  @override
  State<StatefulWidget> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  final GlobalKey<FormState> _key = GlobalKey(); // 表单
  final TextEditingController _textFieldController =
      TextEditingController(); // 输入框控制器

  /// 发送消息
  void send() {
    // 验证表单 //
    if (_key.currentState!.validate()) {
      if (widget.onSubmit?.call(_textFieldController.text) ?? false) {
        _textFieldController.clear(); // 清空输入框
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      mainAxisAlignment: .center,
      children: [
        Expanded(
          child: Form(
            key: _key,
            child: TextFormField(
              controller: _textFieldController, // 控制器
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: .all(.circular(10))),
              ),
              minLines: 1, // 最小1行
              maxLines: 5, // 最大五行
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    value.replaceAll(' ', '').isEmpty) {
                  return '不可发送空内容';
                }
                return null;
              }, // 验证器
            ), // 输入框
          ), // 表单
        ),
        IconButton.filled(
          onPressed: send,
          icon: Icon(Icons.send),
          tooltip: '发送',
        ), // 发送按钮
      ],
    );
  }
}
