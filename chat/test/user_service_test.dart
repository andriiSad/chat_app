import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/user/user_service_contract.dart';
import 'package:chat/src/services/user/user_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helpers.dart';

void main() {
  final RethinkDb r = RethinkDb();
  late Connection connection;
  late IUserService userService;

  setUp(() async {
    connection = await r.connect(host: '127.0.0.1');
    await createDb(r, connection);
    userService = UserService(r, connection);
  });

  tearDown(() async {
    await cleanDb(r, connection);
    connection.close();
  });

  test('creates a new user document in database', () async {
    final user = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastSeen: DateTime.now(),
    );
    final userWithId = await userService.connect(user);
    expect(userWithId.id, isNotEmpty);
  });

  test('get online users', () async {
    final user = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastSeen: DateTime.now(),
    );
    //arrange
    await userService.connect(user);
    //act
    final users = await userService.online();
    //assert
    expect(users.length, 1);
  });

  test('disconnects a user', () async {
    final user = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastSeen: DateTime.now(),
    );

    // arrange
    final connectedUser = await userService.connect(user);

    // act
    await userService.disconnect(connectedUser);

    // try to fetch the disconnected user
    final users = await userService.online();

    // assert
    expect(users.length, 0);
  });
}
