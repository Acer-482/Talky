// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:talky_shared/account/account.dart';
// import 'package:talky_shared/account/account_db.dart';
// import 'package:talky_shared/chat/base_chat_message.dart';
// import 'package:talky_shared/chat/base_chat_message_db.dart';
// import 'package:talky_shared/chat/chat_group/chat_group.dart';
// import 'package:talky_shared/chat/chat_group/chat_group_db.dart';

// /// 数据库管理器
// class DatabaseManager {
//   static final String accountsTableName = 'accounts';
//   static final String chatGroupsTableName = 'chat_groups';
//   static final String accountGroupsTableName = 'account_groups';
//   static final String groupMembersTableName = 'group_members';
//   static final String messagesTableName = 'messages';

//   /// 数据库本地存储路径
//   final String path;

//   /// 数据库
//   late final Database _database;

//   DatabaseManager({required this.path});

//   /// 初始化
//   static Future<void> init() async {
//     sqfliteFfiInit(); // 初始化 FFI
//   }

//   /// 打开数据库
//   Future<void> open() async {
//     final factory = databaseFactoryFfi; // 数据库工厂
//     // 打开数据库（如果文件不存在会自动创建）
//     _database = await factory.openDatabase(
//       path,
//       options: OpenDatabaseOptions(
//         version: 1,
//         onCreate: (db, version) async {
//           await _createTables();
//         },
//       ),
//     );
//   }

//   // 创建表
//   Future<void> _createTables() async {
//     final db = _database;
//     // 账户列表 //
//     await db.execute('''
//       CREATE TABLE $accountsTableName (
//         id TEXT PRIMARY KEY,
//         username TEXT UNIQUE NOT NULL,
//         password TEXT NOT NULL,
//         description TEXT,
//         phoneNumber TEXT,
//         email TEXT,
//         nickname TEXT,
//         clientId TEXT,
//         lastLoggedDateTime INTEGER,
//         createdDateTime INTEGER NOT NULL
//       )
//     ''');
//     // 账户表 //
//     await db.execute('''
//       CREATE TABLE $chatGroupsTableName (
//         id TEXT PRIMARY KEY,
//         name TEXT NOT NULL,
//         description TEXT,
//         owner TEXT NOT NULL,
//         timestamp INTEGER NOT NULL
//       )
//     ''');
//     // 账户&树洞 关联表 //
//     await db.execute('''
//       CREATE TABLE $accountGroupsTableName (
//         account_id TEXT NOT NULL,
//         group_id TEXT NOT NULL,
//         PRIMARY KEY (account_id, group_id)
//       )
//     ''');
//     // 树洞成员表 //
//     await db.execute('''
//       CREATE TABLE $groupMembersTableName (
//         group_id TEXT NOT NULL,
//         user_id TEXT NOT NULL,
//         PRIMARY KEY (group_id, user_id)
//       )
//     ''');
//     // 消息表
//     await db.execute('''
//       CREATE TABLE $messagesTableName (
//         id TEXT PRIMARY KEY,
//         sender TEXT NOT NULL,
//         target TEXT NOT NULL,
//         type TEXT NOT NULL,
//         content TEXT NOT NULL,
//         timestamp INTEGER NOT NULL
//       )
//     ''');
//   }

//   // ---------- 账户操作 ---------- //

//   /// 添加账户
//   Future<void> insertAccount(Account account) async {
//     final db = _database;
//     await db.insert(accountsTableName, account.toDbMap()); // 插入

//     // 批量插入关联树洞
//     final batch = db.batch();
//     for (final groupId in account.joinedChatGroup) {
//       batch.insert(accountGroupsTableName, {
//         'account_id': account.id,
//         'group_id': groupId,
//       });
//     }
//     await batch.commit();
//   }

//   /// 删除账户
//   Future<void> removeAccount(String id) async {
//     final db = _database;
//     await db.delete(
//       accountGroupsTableName,
//       where: 'account_id = ?',
//       whereArgs: [id],
//     );
//     await db.delete(accountsTableName, where: 'id = ?', whereArgs: [id]);
//   }

//   /// 修改账户
//   Future<void> modifyAccount(Account newAccount) async {
//     final db = _database;
//     // 开启事务 确保一致性 //
//     await db.transaction((txn) async {
//       // 更新主表 //
//       await txn.update(
//         accountsTableName,
//         newAccount.toDbMap(),
//         where: 'id = ?',
//         whereArgs: [newAccount.id],
//       );
//       // 更新关联表 //
//       await txn.delete(
//         accountGroupsTableName,
//         where: 'account_id = ?',
//         whereArgs: [newAccount.id],
//       ); // 删除
//       for (final groupId in newAccount.joinedChatGroup) {
//         await txn.insert(accountGroupsTableName, {
//           'account_id': newAccount.id,
//           'group_id': groupId,
//         });
//       } // 添加
//     });
//   }

//   /// 获取账户
//   ///
//   /// 不存在时返回`null`
//   Future<Account?> getAccount(String id) async {
//     final db = _database;
//     // 获取账户部分数据 //
//     final result = await db.query(
//       accountsTableName,
//       where: 'id = ?',
//       whereArgs: [id],
//       limit: 1,
//     );
//     if (result.isEmpty) return null;
//     final accountMap = result.first;
//     // 获取该账户加入的树洞 //
//     final groupResult = await db.query(
//       accountGroupsTableName,
//       where: 'account_id = ?',
//       whereArgs: [id],
//     );
//     final joinedGroups = groupResult
//         .map((e) => e['group_id'] as String)
//         .toList();
//     return AccountDb.fromDbMap(accountMap, joinedGroups: joinedGroups);
//   }

//   // ---------- 树洞操作 ---------- //

//   /// 添加树洞
//   Future<void> insertChatGroup(ChatGroup group) async {
//     final db = _database;
//     await db.insert(chatGroupsTableName, group.toDbMap());

//     // 批量插入成员
//     final batch = db.batch();
//     for (final memberId in group.members) {
//       batch.insert(groupMembersTableName, {
//         'group_id': group.id,
//         'user_id': memberId,
//       });
//     }
//     await batch.commit();
//   }

//   /// 删除树洞
//   Future<void> removeChatGroup(String id) async {
//     final db = _database;
//     // 先删除关联表
//     await db.delete(
//       groupMembersTableName,
//       where: 'group_id = ?',
//       whereArgs: [id],
//     );
//     await db.delete(chatGroupsTableName, where: 'id = ?', whereArgs: [id]);
//   }

//   /// 修改树洞
//   Future<void> modifyChatGroup(ChatGroup newGroup) async {
//     final db = _database;
//     await db.transaction((txn) async {
//       // 更新主表
//       await txn.update(
//         chatGroupsTableName,
//         newGroup.toDbMap(),
//         where: 'id = ?',
//         whereArgs: [newGroup.id],
//       );
//       // 更新成员表：先删后加
//       await txn.delete(
//         groupMembersTableName,
//         where: 'group_id = ?',
//         whereArgs: [newGroup.id],
//       );
//       for (final memberId in newGroup.members) {
//         await txn.insert(groupMembersTableName, {
//           'group_id': newGroup.id,
//           'user_id': memberId,
//         });
//       }
//     });
//   }

//   /// 获取树洞
//   ///
//   /// 不存在时返回`null`
//   Future<ChatGroup?> getChatGroup(String id) async {
//     final db = _database;
//     final result = await db.query(
//       chatGroupsTableName,
//       where: 'id = ?',
//       whereArgs: [id],
//       limit: 1,
//     );
//     if (result.isEmpty) return null;
//     final groupMap = result.first;

//     // 查询该树洞的成员
//     final memberResult = await db.query(
//       groupMembersTableName,
//       where: 'group_id = ?',
//       whereArgs: [id],
//     );
//     final members = memberResult.map((e) => e['user_id'] as String).toList();

//     return ChatGroupDb.fromDbMap(groupMap, members: members);
//   }

//   /// 获取账户加入的所有树洞
//   Future<List<ChatGroup>> getAccountChatGroups(String accountId) async {
//     final db = _database;
//     // 先通过 account_groups 获取树洞ID列表
//     final groupIdsResult = await db.query(
//       accountGroupsTableName,
//       where: 'account_id = ?',
//       whereArgs: [accountId],
//     );
//     final groupIds = groupIdsResult
//         .map((e) => e['group_id'] as String)
//         .toList();

//     final groups = <ChatGroup>[];
//     for (final groupId in groupIds) {
//       final group = await getChatGroup(groupId);
//       if (group != null) groups.add(group);
//     }
//     return groups;
//   }

//   // ---------- 消息操作 ---------- //

//   /// 插入一条消息
//   Future<void> insertMessage(BaseChatMessage message) async {
//     final db = _database;
//     await db.insert(messagesTableName, message.toDbMap());
//   }

//   /// 获取指定会话的消息列表
//   ///
//   /// 按时间正序（从旧到新）
//   ///
//   /// 参数：
//   /// - [targetId] - 会话ID（树洞ID或对方用户ID）
//   /// - [limit] - 限制返回条数，默认全部
//   /// - [beforeId] - 可选，获取比某条消息更早的消息（用于分页加载）
//   Future<List<BaseChatMessage>> getMessages(
//     String targetId, {
//     int? limit,
//     String? beforeId,
//   }) async {
//     final db = _database;
//     // 构建查询
//     var query = db.query(
//       messagesTableName,
//       where: 'target = ?',
//       whereArgs: [targetId],
//       orderBy: 'timestamp ASC', // 按时间升序（旧到新）
//       limit: limit,
//     );
//     // 如果有 beforeId，需要找到该消息的时间戳，然后查询更早的消息
//     // 这里简化实现，如需分页可按需扩展
//     final maps = await query;
//     return maps.map((m) => MessageDb.fromDbMap(m)).toList();
//   }

//   // ---------- 其他操作 ---------- //

//   /// 批量插入多条消息
//   Future<void> insertMessages(List<BaseChatMessage> messages) async {
//     final db = _database;
//     final batch = db.batch();
//     for (final msg in messages) {
//       batch.insert(messagesTableName, msg.toDbMap());
//     }
//     await batch.commit();
//   }

//   /// 删除某会话的所有消息
//   Future<void> clearMessages(String targetId) async {
//     final db = _database;
//     await db.delete(
//       messagesTableName,
//       where: 'target = ?',
//       whereArgs: [targetId],
//     );
//   }
// }
