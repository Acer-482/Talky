import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/chat/models/chat_model.dart';
import 'package:talky_client/core/pages/forms/base_form_page.dart';
import 'package:talky_client/core/utils/text_field_utils.dart';
import 'package:talky_client/features/hobby_tag/widgets/hobby_tag_selector.dart';
import 'package:talky_shared/hobby_tag/hobby_tag.dart';
import 'package:talky_shared/utils/validator_utils.dart';
import 'package:talky_client/core/widgets/option_group.dart';
import 'package:talky_shared/chat/chat_group/chat_group.dart';
import 'package:talky_shared/packets/chat/chat_group/create_chat_group_request.dart';
import 'package:talky_shared/packets/chat/chat_group/modify_chat_group_request.dart';

/// 树洞表单页面
class ChatGroupFormPage extends BaseFormPage<ChatGroupFormPage> {
  /// 树洞
  ///
  /// 为`null`时 创建树洞
  final ChatGroup? chatGroup;

  const ChatGroupFormPage({this.chatGroup, super.key});

  @override
  BaseFormPageState<ChatGroupFormPage> createState() =>
      _ChatGroupFormPageState();
}

class _ChatGroupFormPageState extends BaseFormPageState<ChatGroupFormPage> {
  late final TextEditingController _nameController; // 名称输入控制器
  late final TextEditingController _descriptionController; // 描述输入控制器
  List<HobbyTag> _hobbyTags = []; // 爱好标签

  @override
  String get title => '${widget.chatGroup == null ? '创建' : '修改'}树洞';

  @override
  void initState() {
    super.initState();
    // 初始化输入控制器 //
    final chatGroup = widget.chatGroup;
    _nameController = TextEditingController(text: chatGroup?.name);
    _descriptionController = TextEditingController(
      text: chatGroup?.description,
    );
  }

  /// 构建表单
  @override
  List<Widget> buildChildren(BuildContext context) {
    return [
      OptionGroup(
        title: '基本信息',
        children: [
          TextFieldUtils.buildStdTextForm(
            _nameController,
            '名称',
            validator: ValidatorUtils.chatGroupName,
          ),
          TextFieldUtils.buildStdTextForm(
            _descriptionController,
            '描述',
            minLines: 1,
            maxLines: 5,
          ),
          ListTile(
            title: const Text('树洞爱好'),
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
        ],
      ),
    ];
  }

  /// 提交
  @override
  void onSubmit() {
    if (widget.chatGroup == null) {
      // 创建 //
      context.read<ChatModel>().sendCreateChatGroupRequest(
        CreateChatGroupRequest(
          name: _nameController.text,
          description: _descriptionController.text,
          hobbyTags: _hobbyTags,
        ),
      ); // 发送创建组请求
      // 返回 //
      Navigator.pop(context);
    } else {
      // 修改 //
      final chatGroup = widget.chatGroup!;
      chatGroup.name = _nameController.text;
      chatGroup.description = _descriptionController.text;
      chatGroup.hobbyTags = _hobbyTags;
      // 发送修改组请求 //
      context.read<ChatModel>().sendModifyChatGroupRequest(
        ModifyChatGroupRequest(chatGroup: chatGroup),
      );
      // 返回 //
      Navigator.pop(context);
    }
  }
}
