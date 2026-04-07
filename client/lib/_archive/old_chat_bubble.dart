// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:talky_client/core/models/account_model.dart';
// import 'package:talky_shared/account/account_profile.dart';

// /// 旧消息气泡组件
// class MessageBubble extends StatelessWidget {
//   /// 消息内容
//   final String message;

//   /// 消息是否为己方发送
//   final bool isMe;

//   /// 对方消息显示发送者名称
//   final AccountProfile? profile;

//   /// 显示时间
//   final DateTime? timestamp;

//   /// 点击头像回调
//   final VoidCallback? onAvatarTap;

//   /// 点击消息回调
//   final VoidCallback? onMessageTap;

//   const MessageBubble({
//     required this.message,
//     required this.isMe,
//     this.profile,
//     this.timestamp,
//     this.onAvatarTap,
//     this.onMessageTap,
//     super.key,
//   });
//   // 跳转到详情页面

//   // 构建消息主体
//   Widget _buildBody(BuildContext context) {
//     final theme = Theme.of(context); // 主题
//     final senderName = profile?.username; // 发送者名称
//     return Column(
//       children: [
//         // 对方消息显示发送者名称
//         if (!isMe && senderName != null)
//           Align(
//             alignment: .topLeft, // 左上对齐
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 4),
//               child: Text(
//                 senderName,
//                 style: theme.textTheme.labelSmall?.copyWith(
//                   color: theme.colorScheme.primary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ), // 发送者名称
//             ), // 内边距
//           ), // 对齐
//         _buildBobbleBody(context),
//         // 时间戳
//         if (timestamp != null)
//           Align(
//             alignment: isMe ? .bottomRight : .bottomLeft,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 4),
//               child: Text(
//                 DateFormat('HH:mm:ss').format(timestamp!.toLocal()),
//                 style: theme.textTheme.labelSmall?.copyWith(
//                   color: isMe
//                       ? theme.colorScheme.onPrimaryContainer.withValues(
//                           alpha: 0.7,
//                         )
//                       : theme.colorScheme.onSurface.withValues(alpha: 0.5),
//                   fontSize: 10,
//                 ),
//               ), // 时间文本框
//             ), // 内边距
//           ), // 对齐
//       ],
//     );
//   }

//   // 构建气泡主体
//   Widget _buildBobbleBody(BuildContext context) {
//     final theme = Theme.of(context);
//     return Row(
//       mainAxisAlignment: isMe ? .end : .start,
//       crossAxisAlignment: .end, // 底部对齐
//       children: [
//         if (isMe) _buildStatusIcon(context), // 构建状态图标
//         Flexible(
//           child: GestureDetector(
//             onTap: onMessageTap,
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.7,
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: isMe
//                     ? theme.colorScheme.primaryContainer
//                     : theme.colorScheme.surfaceContainerHighest,
//                 borderRadius: BorderRadius.circular(16).copyWith(
//                   topLeft: isMe ? null : const Radius.circular(4),
//                   topRight: isMe ? const Radius.circular(4) : null, // 圆角
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.05),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: _buildTextBubble(context),
//             ), // 气泡背景
//           ),
//         ),
//       ],
//     );
//   }

//   // 构建文本气泡
//   Widget _buildTextBubble(BuildContext context) {
//     final theme = Theme.of(context);
//     return Text(
//       message,
//       style: theme.textTheme.bodyMedium?.copyWith(
//         color: isMe
//             ? theme.colorScheme.onPrimaryContainer
//             : theme.colorScheme.onSurface,
//       ),
//     ); // 消息内容
//   }

//   /// 构建状态图标
//   Widget _buildStatusIcon(BuildContext context) {
//     return Padding(
//       padding: .all(4),
//       child: const Icon(Icons.done, size: 16, color: Colors.blue),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final accountMode = context.read<AccountModel>();
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: Row(
//         spacing: 8, // 间距
//         mainAxisAlignment: isMe ? .end : .start, // 自己消息靠左 对方消息靠右
//         crossAxisAlignment: .start, // 顶部对齐
//         children: [
//           if (!isMe)
//             IconButton(
//               onPressed:
//                   profile ==
//                       null // 账户资料是否传递
//                   ? null // 未传递 禁用按钮
//                   : onAvatarTap, // 已传递 调用方法
//               icon: profile != null
//                   ? accountMode.getAvatar(profile!.username)
//                   : const Icon(Icons.question_mark),
//             ), // 对方消息左侧显示头像
//           Flexible(child: _buildBody(context)), // 构建消息主体
//           if (isMe) accountMode.buildAvatar()!, // 显示自己的头像
//         ],
//       ),
//     );
//   }
// }
