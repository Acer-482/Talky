import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/account/models/account_model.dart';
import 'package:talky_client/core/pages/forms/base_form_page.dart';
import 'package:talky_client/core/utils/text_field_utils.dart';
import 'package:talky_client/features/hobby_tag/widgets/hobby_tag_selector.dart';
import 'package:talky_shared/hobby_tag/hobby_tag.dart';
import 'package:talky_shared/utils/validator_utils.dart';
import 'package:talky_client/core/widgets/option_group.dart';
import 'package:talky_shared/account/account.dart';
import 'package:talky_shared/packets/accounts/modify_account_request.dart';
import 'package:talky_shared/packets/accounts/signup_request.dart';

/// 账户表单页面
///
/// 提供创建/修改/注销账户的功能
class AccountFormPage extends BaseFormPage<AccountFormPage> {
  /// 账户
  ///
  /// 为`null`时 创建账户
  final Account? account;
  const AccountFormPage({this.account, super.key});

  @override
  BaseFormPageState<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends BaseFormPageState<AccountFormPage> {
  final GlobalKey<FormState> _confirmFormKey = GlobalKey(); // 确认表单
  late final TextEditingController _accountController; // 账户 输入控制器
  late final TextEditingController _passwordController; // 密码 输入控制器
  late final TextEditingController _confirmPasswordController =
      TextEditingController(); // 确认密码 输入控制器

  late final TextEditingController _ageController; // 年龄 输入控制器
  late final TextEditingController _signatureController; // 个人签名 输入控制器

  late final TextEditingController _phoneController; // 手机号码 输入控制器
  late final TextEditingController _emailController; // 电子邮箱 输入控制器

  late List<HobbyTag> _hobbyTags; // 兴趣爱好标签列表

  // 弹出确认窗口
  Future<bool> _showConfirmDialog() async {
    final ret = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认更改密码'),
        content: Column(
          spacing: 8,
          mainAxisSize: .min,
          children: [
            Text('请再次键入更改后的密码'),
            Form(key: _confirmFormKey, child: _buildConfirmField()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 验证表单
              if (_confirmFormKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('确认'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    return ret ?? false;
  }

  // 构建确认密码输入框
  TextFormField _buildConfirmField() {
    _confirmPasswordController.clear(); // 清空确认密码输入框
    return TextFieldUtils.buildStdTextForm(
      _confirmPasswordController,
      widget.account == null ? '确认密码' : '确认更改后的密码',
      icon: const Icon(Icons.lock),
      obscureText: true,
      validator: (value) =>
          value != _passwordController.text ? '两次密码不一致' : null,
    );
  }

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    // 初始化输入控制器 //
    _accountController = TextEditingController(text: account?.username);
    _passwordController = TextEditingController(text: account?.password);
    _ageController = TextEditingController(
      text: account?.age == null ? null : '${account!.age}',
    );
    _hobbyTags = account?.hobbyTags ??[ ];
    _signatureController = TextEditingController(text: account?.signature);
    _phoneController = TextEditingController(text: account?.phoneNumber);
    _emailController = TextEditingController(text: account?.email);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountModel>(
      builder: (context, model, child) {
        // 创建账户模式 & 登录成功 //
        if (widget.account == null && context.read<AccountModel>().isLogged) {
          WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) => Navigator.pop(context),
          ); // 关闭页面
        }
        return super.build(context);
      },
    );
  }

  @override
  List<Widget> buildChildren(BuildContext context) {
    return [
      OptionGroup(
        title: '基本信息',
        children: [
          TextFieldUtils.buildStdTextForm(
            _accountController,
            '账户名',
            icon: const Icon(Icons.tag),
            validator: ValidatorUtils.username,
          ),
          TextFieldUtils.buildStdTextForm(
            _passwordController,
            '密码',
            icon: const Icon(Icons.password),
            obscureText: true,
            validator: ValidatorUtils.password,
          ),
          if (widget.account == null) _buildConfirmField(), // 注册时直接显示确认对话框
        ],
      ),
      OptionGroup(
        title: '个人信息',
        children: [
          TextFieldUtils.buildStdTextForm(
            _ageController,
            '年龄',
            icon: const Icon(Icons.numbers_rounded),
            validator: ValidatorUtils.age,
          ),
          ListTile(
            title: const Text('兴趣爱好'),
            subtitle: _hobbyTags.isNotEmpty
                ? Text('当前爱好：${_hobbyTags.map((e) => e.hobby).join(',')}')
                : null,
            trailing: IconButton(
              onPressed: () async {
                final ret = await showHobbyTagSelector(context, _hobbyTags);
                if (ret != null) {
                  _hobbyTags = ret;
                }
                setState(() {});
              },
              icon: const Icon(Icons.add),
              tooltip: '选择预设',
            ), // 选择爱好标签预设
          ),
          TextFieldUtils.buildStdTextForm(
            _signatureController,
            '个性签名',
            icon: const Icon(Icons.abc),
            minLines: 1,
            maxLines: 3,
          ),
        ],
      ),
      OptionGroup(
        title: '关联信息',
        children: [
          TextFieldUtils.buildStdTextForm(
            _phoneController,
            '手机号',
            icon: const Icon(Icons.numbers_rounded),
            validator: ValidatorUtils.phoneNumber,
          ),
          TextFieldUtils.buildStdTextForm(
            _emailController,
            '邮箱',
            icon: const Icon(Icons.email),
            validator: ValidatorUtils.eMail,
          ),
        ],
      ),
    ];
  }

  @override
  void onSubmit() async {
    // 创建账户/修改账户 //
    if (widget.account == null) {
      // 创建账户 //
      context.read<AccountModel>().sendSignUpRequest(
        SignupRequest(
          username: _accountController.text,
          password: _passwordController.text,
          age: int.tryParse(_ageController.text),
          hobbies: _hobbyTags,
          signature: _signatureController.text,
          phoneNumber: _phoneController.text,
          email: _emailController.text,
        ),
      ); // 发送注册请求
    } else {
      final account = widget.account!;
      // 修改账户 //
      // 当密码有变更时显示确认对话框
      if (_passwordController.text != account.password
          ? await _showConfirmDialog()
          : true) {
        final context = this.context; // 获取上下文
        if (context.mounted) {
          context.read<AccountModel>().sendModifyAccountRequest(
            ModifyAccountRequest(
              username: _accountController.text != account.username
                  ? _accountController.text
                  : null,
              password: _passwordController.text != account.password
                  ? _passwordController.text
                  : null,
              age: _ageController.text != '${account.age}'
                  ? int.tryParse(_ageController.text)
                  : null,
              hobbies: _hobbyTags,
              signature: _signatureController.text != account.signature
                  ? _signatureController.text
                  : null,
              phoneNumber: _phoneController.text != account.phoneNumber
                  ? _phoneController.text
                  : null,
              email: _emailController.text != account.email
                  ? _emailController.text
                  : null,
            ),
          ); // 发送注册请求
          Navigator.pop(context); // 返回上一页面
        }
      }
    }
  }

  @override
  String get title => widget.account == null ? '创建账户' : '修改账户';
}
