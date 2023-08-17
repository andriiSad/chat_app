import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/encryption/encryption_service_impl.dart';
import 'package:chat/src/services/message/message_service_contract.dart';
import 'package:chat/src/services/message/message_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

void main() {
  final RethinkDb r = RethinkDb();
  late Connection connection;
  late IMessageService messageService;

  setUp(() async {
    connection = await r.connect(host: '127.0.0.1');
    final encryptionService = EncryptionService(Encrypter(AES(Key.fromLength(32))));
    await createDb(r, connection);
    messageService = MessageService(r, connection, encryptionService);
  });

  tearDown(() async {
    messageService.dispose();
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
    final res = await messageService.send(message);
    expect(res, true);
  });

  test('successfully subscribe and receive messages', () async {
    messageService.messages(secondUser).listen(expectAsync1((message) {
          expect(message.to, secondUser.id);
          expect(message.id, isNotEmpty);
        }, count: 2));

    final firstMessage = Message(
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

    await messageService.send(firstMessage);
    await messageService.send(secondMessage);
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
    //first message sent
    await messageService.send(message);
    //after second message sent we subscribe for messages
    await messageService
        .send(secondMessage)
        .whenComplete(() => messageService.messages(secondUser).listen(expectAsync1((message) {
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
    await messageService.send(sentMessage);

    // Subscribe to messages for firstUser
    final messagesStream = messageService.messages(firstUser);

    // Wait for the stream to emit a message
    final receivedMessage = await messagesStream.first;

    // Verify that the received message content is the same as the sent message
    expect(receivedMessage.content, sentMessage.content);
  });
}
