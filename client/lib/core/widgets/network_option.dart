import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/core/models/toast/toast_item.dart';
import 'package:talky_client/features/settings/models/network_config_model.dart';
import 'package:talky_shared/utils/validator_utils.dart';

/// 更改服务器地址对话框
class ModifyServerAddressDialog extends StatefulWidget {
  const ModifyServerAddressDialog({super.key});

  @override
  State<StatefulWidget> createState() => _ModifyServerAddressDialogState();
}

class _ModifyServerAddressDialogState extends State<ModifyServerAddressDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey(); // 表单
  late final TextEditingController _serverHostController; // 服务器地址 输入控制器
  late final TextEditingController _serverPortController; // 服务器端口 输入控制器

  // 提交
  void _submit() {
    // 验证表单 //
    if (_formKey.currentState!.validate()) {
      // 更新配置 //
      final config = context.read<NetworkConfigModel>();
      config.updateServerHost(_serverHostController.text);
      config.updateServerPort(int.parse(_serverPortController.text));
      // 弹出提示 //
      ToastItem(
        '修改服务器地址成功',
        description: '修改的地址将在下次连接到服务器时生效',
        type: .success,
      ).show(context);
      // 关闭页面 //
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    final config = context.read<NetworkConfigModel>();
    _serverHostController = TextEditingController(text: config.host);
    _serverPortController = TextEditingController(text: '${config.port}');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('更改地址'),
      content: Form(
        key: _formKey,
        child: Row(
          spacing: 4,
          crossAxisAlignment: .center,
          mainAxisSize: .min,
          children: [
            Flexible(
              flex: 3,
              child: TextFormField(
                controller: _serverHostController,
                decoration: InputDecoration(label: Text('地址')),
                validator: ValidatorUtils.serverHost,
              ),
            ),
            Flexible(
              flex: 1,
              child: TextFormField(
                controller: _serverPortController,
                decoration: InputDecoration(label: Text('端口')),
                validator: ValidatorUtils.serverPort,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(onPressed: _submit, child: const Text('确定')),
      ],
    );
  }
}
