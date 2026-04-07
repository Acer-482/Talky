import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';

/// 聊天框架组件
class ChatMessageList<T extends Object> extends StatefulWidget {
  /// 气泡构建器
  final Widget Function(BuildContext context, Animation<double> animation, Object item, int index)
  bubbleBuilder;

  /// 项列表
  final List<T> items;

  /// 比较是否相同
  final bool Function(Object a, Object b) areItemsTheSame;

  /// 滚动
  final Function(ScrollController controller)? onScroll;

  const ChatMessageList({
    required this.bubbleBuilder,
    required this.items,
    required this.areItemsTheSame,
    this.onScroll,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ChatMessageListState<T>();
}

class _ChatMessageListState<T extends Object> extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController(); // 滚动控制器
  late final VoidCallback _scrollListener; // 滚动监听器

  /// 构建消息列表
  Widget _buildMessageList() {
    return widget.items.isEmpty
        ? const Center(child: Text('无消息')) // 无消息
        : ImplicitlyAnimatedList<T>(
            physics: const BouncingScrollPhysics(), // 滚动效果
            controller: _scrollController, // 滚动控制器
            reverse: true, // 反向
            itemBuilder: (context, animation, item, i) {
              return SizeFadeTransition(
                animation: animation,
                child: widget.bubbleBuilder(context, animation, item, i),
              );
            },
            items: List<T>.from(widget.items.reversed), // 消息列表（反转）
            areItemsTheSame: widget.areItemsTheSame, // 比较消息是否为同一条
          ); // 聊天气泡动画列表
  }

  @override
  void initState() {
    super.initState();
    if (widget.onScroll != null) {
      _scrollListener = () =>
          widget.onScroll!.call(_scrollController); // 包装滚动回调
      _scrollController.addListener(_scrollListener); // 添加监听器
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildMessageList();
  }

  @override
  void dispose() {
    if (widget.onScroll != null) {
      _scrollController.removeListener(_scrollListener); // 移除监听器
    }
    _scrollController.dispose();
    super.dispose();
  }
}
