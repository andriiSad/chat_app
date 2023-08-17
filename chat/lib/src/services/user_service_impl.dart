import 'package:rethink_db_ns/rethink_db_ns.dart';

import '../models/user.dart';
import 'user_service_contract.dart';

class UserService implements IUserService {
  UserService(this._r, this._connection);

  final RethinkDb _r;
  final Connection _connection;
  @override
  Future<User> connect(User user) async {
    final data = user.toJson();

    if (user.id != null) {
      data['id'] = user.id!;
    }

    final result = await _r.table('users').insert(
      data,
      {'conflict': 'update', 'return_changes': true},
    ).run(_connection);

    final List<dynamic> changes = result['changes'] as List<dynamic>;

    final Map<String, dynamic> newUserData =
        changes.first['new_val'] as Map<String, dynamic>;

    return User.fromJson(newUserData);
  }

  @override
  Future<void> disconnect(User user) async {
    await _r.table('users').update({
      'id': user.id,
      'active': false,
      'last_seen': DateTime.now()
    }).run(_connection);
  }

  @override
  Future<List<User>> online() async {
    final Cursor users = await _r
        .table('users')
        .filter({'active': true}).run(_connection) as Cursor;
    final userList = await users.toList();
    return userList
        .map((user) => User.fromJson(user as Map<String, dynamic>))
        .toList();
  }
}
