import 'package:chat/src/models/typing_event.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/typing/typing_notification_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

void main() {
  final RethinkDb r = RethinkDb();
  late Connection connection;
  late TypingNotificationService typingNotificationService;

  setUp(() async {
    connection = await r.connect();
    await createDb(r, connection);
    typingNotificationService = TypingNotificationService(r, connection);
  });

  tearDown(() async {
    typingNotificationService.dispose();
    await cleanDb(r, connection);
    connection.close();
  });

  final firstUser = User.fromJson({
    'id': '1111',
    'username': 'username',
    'photoUrl': 'url',
    'active': true,
    'lastSeen': DateTime.now(),
  });
  final secondUser = User.fromJson({
    'id': '2222',
    'username': 'username',
    'photoUrl': 'url',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  test('sent typing notification successfully', () async {
    final event = TypingEvent(
      from: secondUser.id!,
      to: firstUser.id!,
      event: Typing.start,
    );
    final res = await typingNotificationService.send(event: event, to: firstUser);
    expect(res, true);
  });

  test('successfully subscribe and receive typing events', () async {
    typingNotificationService.subscribe(secondUser, [firstUser.id!]).listen(expectAsync1((event) {
      expect(event.from, firstUser.id);
    }, count: 2));
    final typing = TypingEvent(
      to: secondUser.id!,
      from: firstUser.id!,
      event: Typing.start,
    );
    final stopTyping = TypingEvent(
      to: secondUser.id!,
      from: firstUser.id!,
      event: Typing.stop,
    );

    await typingNotificationService.send(event: typing, to: secondUser);
    await typingNotificationService.send(event: stopTyping, to: secondUser);
  });
}
