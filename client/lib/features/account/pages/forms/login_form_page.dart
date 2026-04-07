import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/account/models/account_model.dart';
import 'package:talky_client/features/account/pages/forms/account_form_page.dart';
import 'package:talky_client/core/pages/forms/base_form_page.dart';
import 'package:talky_client/core/utils/text_field_utils.dart';
import 'package:talky_client/core/widgets/option_group.dart';
import 'package:talky_shared/utils/validator_utils.dart';
import 'package:talky_shared/packets/accounts/log_in_request.dart';

/// 登录表单页面
///
/// 当用户登录成功时返回true
class LoginFormPage extends BaseFormPage<LoginFormPage> {
  const LoginFormPage({super.key});

  @override
  BaseFormPageState<LoginFormPage> createState() => _LoginFormPageState();
}

class _LoginFormPageState extends BaseFormPageState<LoginFormPage> {
  final _accountController = TextEditingController(); // 账户输入控制器
  final _passwordController = TextEditingController(); // 密码输入控制器

  // 跳转到注册页面
  void _navigateToSigninPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountFormPage()),
    ); // 跳转到注册页面
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountModel>(
      builder: (context, model, child) {
        // 成功登录 //
        if (model.isLogged) {
          WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) => Navigator.pop(context, model.account!),
          ); // 返回
        }
        return super.build(context);
      },
    );
  }

  @override
  List<Widget> buildChildren(BuildContext context) {
    return [
      OptionGroup(
        children: [
          TextFieldUtils.buildStdTextForm(
            _accountController,
            '账户名',
            validator: ValidatorUtils.username,
          ),
          TextFieldUtils.buildStdTextForm(
            _passwordController,
            '密码',
            obscureText: true,
            validator: ValidatorUtils.password,
          ),
          Align(
            alignment: .centerRight,
            child: TextButton(
              onPressed: _navigateToSigninPage,
              child: Text('没有账户？创建一个！'),
            ), // 注册按钮
          ), // 对齐
        ],
      ),
    ];
  }

  @override
  void onSubmit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountModel>().sendLoginRequest(
        LogInRequest(
          username: _accountController.text,
          password: _passwordController.text,
        ),
      ); // 发送登录请求
    });
  }

  @override
  String get title => '登录';
}
