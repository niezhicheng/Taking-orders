import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled2/mesagelist/model.dart';

import '../chat/model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'ceshi.db');
    print(path);
    // await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        sender INTEGER,
        receiver INTEGER,
        client_id INTEGER,
        message_type INTEGER,
        context TEXT,
        voice_url TEXT,
        image_url TEXT,
        file_url TEXT,
        seq INTEGER,
        status INTEGER,
        file_type TEXT,
        image_width INTEGER,
        image_height INTEGER,
        voice_duration INTEGER,
        created_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE session (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        sender INTEGER,
        contact_id INTEGER,
        last_message TEXT,
        message_type INTEGER,
        last_sender INTEGER,
        last_sent_at INTEGER,
        unread_count INTEGER,
        is_group_chat INTEGER,
        group_chat_name TEXT,
        delete_not INTEGER,
        seq INTEGER
      )
    ''');
    await db.execute('CREATE INDEX idx_user_id ON messages (user_id)');
    await db.execute(
        'CREATE INDEX idx_sender_receiver ON messages (sender, receiver)');
    await db.execute('CREATE INDEX idx_created_at ON messages (created_at)');
  }

  // 单个插入
  Future<int> insertMessage(MessageM message) async {
    final db = await instance.database;
    return await db.insert('messages', message.toMap());
  }

  //  批量插入
  Future<void> insertMessages(List<MessageM> messages) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var message in messages) {
      batch.insert('messages', message.toMap());
    }
    await batch.commit();
  }

  Future<int> getMaxSeqByUserId(int userId) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT MAX(seq) FROM messages WHERE user_id = ?',
      [userId],
    );
    int maxSeq = result[0].values.first ?? 0;
    return maxSeq;
  }

  // 批量更新操作
  Future<int> updateMessage(MessageM message) async {
    final db = await instance.database;
    return await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  // 单个更新

  Future<int> updateMessageStatus(int id, int status, int seq) async {
    final db = await instance.database;
    return await db.update(
      'messages',
      {'status': status, 'seq': seq},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //删除操作
  Future<int> deleteMessage(int id) async {
    final db = await instance.database;
    return await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MessageM>> getMessagesByUser(
      int userid, int senderId, int receiverId, int page, int pageSize) async {
    final db = await instance.database;
    final offset = (page - 1) * pageSize;
    final result = await db.rawQuery('''
        SELECT * FROM messages
        WHERE (sender = $senderId AND receiver = $receiverId AND user_id = $userid) OR (sender = $receiverId AND receiver = $senderId AND user_id = $userid)
        ORDER BY seq DESC
        LIMIT $pageSize OFFSET $offset
    ''');
    return result.map((map) => MessageM.fromMap(map)).toList();
  }

  Future<List<MessageM>> getMessagesByUserMax(int userid, int senderId,
      int receiverId, int page, int pageSize, int maxID) async {
    final db = await instance.database;
    final offset = (page - 1) * pageSize;
    final result = await db.rawQuery('''
    SELECT * FROM messages
    WHERE (sender = $senderId OR receiver = $receiverId) AND user_id = $userid AND id < ($maxID + $offset)
    ORDER BY seq DESC
    LIMIT $pageSize OFFSET $offset
  ''');
    return result.map((map) => MessageM.fromMap(map)).toList();
  }

  //第一页面
  Future<List<MessageM>> getMessagesByUserMaxLimit(
      int userid, int senderId, int receiverId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
    SELECT * FROM messages
    WHERE (sender = $senderId AND receiver = $receiverId AND user_id = $userid) OR (sender = $receiverId AND receiver = $senderId AND user_id = $userid)
    ORDER BY seq DESC
    LIMIT 20 OFFSET 0
  ''');
    return result.map((map) => MessageM.fromMap(map)).toList();
  }

  // 单个插入
  Future<int> insertSession(Session session) async {
    final db = await instance.database;
    return await db.insert('session', session.toMap());
  }

  Future<Map<String, Object?>?> getSession(
      int userId, int sender, int contactId) async {
    final db = await instance.database;
    final maps = await db.query(
      'session',
      where:
          '(sender = ? AND contact_id = ? AND user_id = ?) OR (sender = ? AND contact_id = ? AND user_id = ?)',
      whereArgs: [sender, contactId, userId, contactId, sender, userId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Session>> getAllSessions(int userid) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'session',
      where: 'user_id = ?',
      whereArgs: [userid],
      orderBy: 'seq DESC', // 根据时间字段降序排序
    );
    return List.generate(maps.length, (index) {
      return Session.fromMapSession(maps[index]);
    });
  }

  // // 批量更新操作
  // Future<int> updateSessions(Session session) async {
  //   print("更新");
  //   final db = await instance.database;
  //   return await db.update(
  //     'session',
  //     session.toMap(),
  //     where: '(sender = ? OR contact_id = ?) AND user_id = ?',
  //     whereArgs: [
  //       session.userId,
  //       session.contactId,
  //       session.userId,
  //     ],
  //   );
  // }

  Future<List<Session>> updateSessions(Session session) async {
    final db = await instance.database;

    // 执行更新操作
    int rowsAffected = await db.update(
      'session',
      session.toMap(),
      where:
          '(sender = ? AND contact_id = ? AND user_id = ?) OR (sender = ? AND contact_id = ? AND user_id = ?)',
      whereArgs: [
        session.sender,
        session.contactId,
        session.userId,
        session.contactId,
        session.sender,
        session.userId,
      ],
    );

    if (rowsAffected > 0) {
      // 执行查询操作以获取更新后的数据
      final List<Map<String, dynamic>> updatedMaps = await db.query(
        'session',
        where:
            '(sender = ? AND contact_id = ? AND user_id = ?) OR (sender = ? AND contact_id = ? AND user_id = ?)',
        whereArgs: [
          session.sender,
          session.contactId,
          session.userId,
          session.contactId,
          session.sender,
          session.userId,
        ],
      );
      if (updatedMaps.isNotEmpty) {
        // 将查询结果转换为 Session 对象并返回
        List<Session> updatedSessions =
            updatedMaps.map((map) => Session.fromMap(map)).toList();
        return updatedSessions;
      }
    }

    return []; // 如果没有更新数据，则返回 0
  }

  Future<List<Map<String, dynamic>>> getLastMessagesWithEachUser() async {
    final db = await instance.database;
    return await db.rawQuery('''
    SELECT *
    FROM messages AS s1
    WHERE seq = (
      SELECT MAX(seq)
      FROM messages AS s2
      WHERE (s2.sender = s1.sender AND s2.receiver = s1.receiver)
         OR (s2.sender = s1.receiver AND s2.receiver = s1.sender)
    )
  ''');
  }
}
