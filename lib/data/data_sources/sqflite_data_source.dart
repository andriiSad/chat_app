import 'package:sqflite/sqflite.dart';

import '../../models/chat.dart';
import '../../models/local_message.dart';
import 'data_source_contract.dart';

class SqfliteDataSource implements IDataSource {
  const SqfliteDataSource(this._db);
  final Database _db;

  @override
  Future<void> addChat(Chat chat) async {
    await _db.insert('chats', chat.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> addMessage(LocalMessage message) async {
    await _db.insert('messages', message.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteChat(String chatId) async {
    final batch = _db.batch();
    batch.delete('messages', where: 'chatId = ?', whereArgs: [chatId]);
    batch.delete('chats', where: 'id = ?', whereArgs: [chatId]);
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Chat>> findAllChats() async {
    return _db.transaction((txn) async {
      //selecting all chats with their latest messages
      final chatsWithLatestMessage = await txn.rawQuery('''
  SELECT messages.*
  FROM (
    SELECT chat_id, MAX(created_at) AS created_at
    FROM messages
    GROUP BY chat_id
  ) AS latest_messages
  INNER JOIN messages
  ON messages.chat_id = latest_messages.chat_id
  AND messages.created_at = latest_messages.created_at
''');

      final chatsWithUnreadMessages = await txn.rawQuery('''
  SELECT chat_id, count(*) AS unread
  FROM messages
  WHERE receipt = ?
  GROUP BY chat_id
''', ['delivered']);
      return chatsWithLatestMessage.map<Chat>((row) {
        final int unread = int.parse(chatsWithUnreadMessages
            .firstWhere((element) => row['chat_id'] == element['chat_id'],
                orElse: () => {'unread': 0})['unread']
            .toString());
        final chat = Chat.fromJson(row);
        chat.unread = unread;
        chat.mostRecent = LocalMessage.fromJson(row);
        return chat;
      }).toList();
    });
  }

  @override
  Future<Chat> findChat(String chatId) async {
    return _db.transaction((txn) async {
      //selecting all chats with their latest messages
      final listOfChatMaps = await txn.query(
        'chats',
        where: 'id = ?',
        whereArgs: [chatId],
      );

      final unread = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT* FROM MESSAGES WHERE chat_id = ? AND receipt = ?',
          [chatId, 'delivered']))!;

      final mostRecentMessage = await txn.query(
        'messages',
        where: 'chatId = ?',
        whereArgs: [chatId],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      final chat = Chat.fromJson(listOfChatMaps.first);
      chat.unread = unread;
      chat.mostRecent = LocalMessage.fromJson(mostRecentMessage.first);
      return chat;
    });
  }

  @override
  Future<List<LocalMessage>> findMessages(String chatId) async {
    final listOfMaps = await _db.query(
      'messages',
      where: 'chatId = ?',
      whereArgs: [chatId],
    );
    return listOfMaps
        .map<LocalMessage>((row) => LocalMessage.fromJson(row))
        .toList();
  }

  @override
  Future<void> updateMessage(LocalMessage message) async {
    await _db.update(
      'messages',
      message.toJson(),
      where: 'id = ?',
      whereArgs: [message.message.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
