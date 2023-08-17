import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/message/message_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

void main() {
  final RethinkDb r = RethinkDb();
  late Connection connection;
  late MessageService sut;

  setUp(() async {
    connection = await r.connect(host: '127.0.0.1');
    await createDb(r, connection);
    sut = MessageService(r, connection);
  });

  tearDown(() async {
    sut.dispose();
    await cleanDb(r, connection);
    connection.close();
  });

  final firstUser = User.fromJson({
    'id': '1111',
    'username': 'firstUsername',
    'photoUrl': 'url',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  final secondUser = User.fromJson({
    'id': '2222',
    'username': 'secondUsername',
    'photoUrl': 'url',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  test('sent message successfully', () async {
    final message = Message(
      from: firstUser.id!,
      to: '3333',
      timestamp: DateTime.now(),
      content: 'this is a message',
    );
    final res = await sut.send(message);
    expect(res, true);
  });

  test('successfully subscribe and receive messages', () async {
    sut.messages(secondUser).listen(expectAsync1((message) {
          expect(message.to, secondUser.id);
          expect(message.id, isNotEmpty);
        }, count: 2));

    final message = Message(
      from: firstUser.id!,
      to: secondUser.id!,
      timestamp: DateTime.now(),
      content: 'this is message',
    );

    final secondMessage = Message(
      from: firstUser.id!,
      to: secondUser.id!,
      timestamp: DateTime.now(),
      content: 'this is another message',
    );

    await sut.send(message);
    await sut.send(secondMessage);
  });
  test('successfully subscribe and receive new messages', () async {
    final message = Message(
      from: firstUser.id!,
      to: secondUser.id!,
      timestamp: DateTime.now(),
      content: 'this is message',
    );

    final secondMessage = Message(
      from: firstUser.id!,
      to: secondUser.id!,
      timestamp: DateTime.now(),
      content: 'this is another message',
    );

    await sut.send(message);
    await sut.send(secondMessage).whenComplete(
        () => sut.messages(secondUser).listen(expectAsync1((message) {
              expect(message.to, secondUser.id);
            }, count: 2)));
  });

  test('receiving messages', () async {
    // Simulate sending a message from secondUser to firstUser
    final sentMessage = Message(
      from: secondUser.id!,
      to: firstUser.id!,
      timestamp: DateTime.now(),
      content: 'hello from secondUser',
    );
    await sut.send(sentMessage);

    // Subscribe to messages for firstUser
    final messagesStream = sut.messages(firstUser);

    // Wait for the stream to emit a message
    final receivedMessage = await messagesStream.first;

    // Verify that the received message matches the sent message
    expect(receivedMessage.from, sentMessage.from);
    expect(receivedMessage.to, sentMessage.to);
    expect(receivedMessage.content, sentMessage.content);
  });
}
