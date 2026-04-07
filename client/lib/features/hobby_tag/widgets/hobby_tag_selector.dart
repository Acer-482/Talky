import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/hobby_tag/models/hobby_tag_model.dart';
import 'package:talky_shared/hobby_tag/hobby_tag.dart';

/// 显示爱好标签选择器
Future<List<HobbyTag>?> showHobbyTagSelector(
  BuildContext context,
  List<HobbyTag> hobbyTag,
) async {
  return await showModalBottomSheet(
    context: context,
    builder: (context) => HobbyTagSelector(hobbyTag: hobbyTag),
  );
}

/// 爱好标签选择器
class HobbyTagSelector extends StatefulWidget {
  final List<HobbyTag>? hobbyTag;

  const HobbyTagSelector({this.hobbyTag, super.key});

  @override
  State<StatefulWidget> createState() => _HobbyTagSelectorState();
}

class _HobbyTagSelectorState extends State<HobbyTagSelector> {
  late final List<HobbyTag> _selectedTags; // 选中的标签

  @override
  void initState() {
    super.initState();
    _selectedTags = widget.hobbyTag ?? [];
    // 获取爱好标签 //
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => context.read<HobbyTagModel>().getHobbyTags(),
    );
  }

  // 选中标签
  void _selectTag(HobbyTag tag) {
    if (_selectedTags.contains(tag)) {
      // 已经选中标签则删除
      _selectedTags.remove(tag);
    } else {
      // 未选中标签则添加
      _selectedTags.add(tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HobbyTagModel>(
      builder: (context, model, child) {
        if (!model.isReady) {
          return const Center(child: CircularProgressIndicator());
        }
        final hobbyTags = model.hobbyTags;
        return Container(
          padding: .all(4),
          child: ListView(
            children: [
              ListTile(
                title: Text('选择爱好', textScaler: .linear(1.4)),
                subtitle: Text(
                  '当前选择: ${(_selectedTags.map((tag) => tag.hobby).join(', '))}',
                ),
                trailing: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedTags),
                  child: const Text('确定'),
                ),
              ),
              Container(
                padding: .fromLTRB(18, 4, 18, 4),
                child: Wrap(
                  spacing: 4,
                  children: hobbyTags
                      .map(
                        (tag) => ChoiceChip(
                          label: Text(tag.hobby),
                          selected: _selectedTags.contains(tag),
                          onSelected: (_) => setState(() => _selectTag(tag)),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ); // 环绕布局
      },
    );
  }
}
