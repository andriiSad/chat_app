import 'package:chat/chat.dart';
import 'package:chat_app/data/data_sources/sqflite_data_source.dart';
import 'package:chat_app/models/chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

class MockSqfliteDatabase extends Mock implements Database {}

class MockBatch extends Mock implements Batch {}

void main() {
  late MockSqfliteDatabase database;
  late SqfliteDataSource sqfliteDataSource;
  late MockBatch batch;

  setUp(() {
    database = MockSqfliteDatabase();
    batch = MockBatch();
    sqfliteDataSource = SqfliteDataSource(database);
  });

  final message = Message.fromJson({
    'from': '1111',
    'to': '2222',
    'content': 'hello',
    'timestamp': DateTime.parse('2023-08-01'),
    'id': '4444'
  });

  test('should perform insert of chat to the database', () async {
    //arrange
    final chat = Chat(id: '1234');
    when(database.insert(
      'chats',
      chat.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    ));

    //act
    await sqfliteDataSource.addChat(chat);

    //assert
    verify(database.insert(
      'chats',
      chat.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).called(1);
  });
}
