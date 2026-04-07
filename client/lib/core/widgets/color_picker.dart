import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// 颜色选择器
class ColorPickerDialog extends StatefulWidget {
  final Color color; // 初始颜色

  const ColorPickerDialog({required this.color, super.key});

  @override
  State<StatefulWidget> createState() => _ColorPickerDialogState();
}

/// 颜色选择器
class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color color; // 选择的颜色
  @override
  void initState() {
    super.initState();
    color = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('选取颜色'),
      content: Padding(
        padding: .all(10),
        child: InteractiveViewer(
          child: ColorPicker(
            pickerColor: color,
            onColorChanged: (value) => color = value,
            hexInputBar: true,
          ), // 颜色选择器
        ), // 交互式查看器 防止溢出容器
      ), // 内边距
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, color), // 返回颜色
          child: const Text('确定'),
        ),
      ],
    );
  }
}
