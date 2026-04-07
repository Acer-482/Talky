import 'package:flutter/material.dart';

/// 基础表单页面
abstract class BaseFormPage<T extends BaseFormPage<T>> extends StatefulWidget {
  const BaseFormPage({super.key});

  @override
  BaseFormPageState<T> createState();
}

/// 基础表单页面状态
abstract class BaseFormPageState<T extends BaseFormPage<T>> extends State<T> {
  final GlobalKey<FormState> _formKey = GlobalKey(); // 全局表单

  /// 验证表单
  bool get validate => _formKey.currentState!.validate();

  /// 标题
  String? get title;

  /// 浮动按钮文本
  String? get floatingActionButtonText => '提交';

  /// 构建约束
  ///
  /// 默认最大宽度`580`，需要自定义时请重写
  BoxConstraints get buildConstraints => const BoxConstraints(maxWidth: 580);

  /// 构建子组件
  List<Widget> buildChildren(BuildContext context);

  /// 提交
  void onSubmit();

  // 构建主体
  Widget _buildBody() {
    return Align(
      alignment: .center, // 居中
      child: ConstrainedBox(
        constraints: buildConstraints,
        child: Padding(padding: .all(10), child: _buildForm()),
      ), // 容器
    ); // 对齐
  }

  // 构建表单
  Form _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(children: buildChildren(context)), // 列表
    ); // 表单
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null ? AppBar(title: Text(title!)) : null,
      body: _buildBody(),
      floatingActionButton: floatingActionButtonText != null
          ? FloatingActionButton.extended(
              onPressed: () => {if (validate) onSubmit()},
              label: Text(floatingActionButtonText!),
            )
          : null,
    );
  }
}
