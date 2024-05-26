import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:get/get.dart';
import 'package:untitled2/chat/model.dart';
import 'package:untitled2/mesagelist/model.dart';
import 'package:untitled2/utils/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:untitled2/utils/sqlite.dart';

// http://chengxuyuanbuluo.cn:8888/
class WebSocketService extends GetxService {
  late IOWebSocketChannel _channel;
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  IOWebSocketChannel get channel => _channel;

  Stream<String> get messageStream => _messageController.stream;
  final token = RxString('');
  final _isConnected = RxBool(false);
  final userid = RxInt(0);
  Timer? reconnectTimer; // Timer对象用于重新连接
  RxBool get isConnected => _isConnected;

  Future<void> connect(String tokens) async {
    final ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // 没有网络连接，不进行重新连接
      print('没有网络连接');
      return;
    }
    var url = "";
    if (tokens == "") {
      url = 'ws://chengxuyuanbuluo.cn:8888/base/wsconnect?token=$token';
    } else {
      url = 'ws://chengxuyuanbuluo.cn:8888/base/wsconnect?token=$tokens';
    }
    _channel = IOWebSocketChannel.connect(url);
    try {
      _isConnected.value = true;
    } catch (e) {
      // 处理异常
    }
    int? value = await getInt("userid");
    final maxseq = await DatabaseHelper.instance.getMaxSeqByUserId(value!);
    sendMessage(
      MessageM(
        sender: value,
        userid: value,
        receiver: 0,
        messageType: 7,
        seq: maxseq,
      ),
    );

    _channel.stream.listen((message) async {
      _messageController.add(message);
      final dynamic decodedMessage = jsonDecode(message);
      if (decodedMessage is List) {
        final List<MessageM> convertedMessages =
            decodedMessage.map((item) => MessageM.fromMap(item)).toList();
        for (int i = 0; i < convertedMessages.length; i++) {
          convertedMessages[i].userid = value;
          await DatabaseHelper.instance.insertMessage(
            convertedMessages[i],
          );
          final msg = await DatabaseHelper.instance.getSession(
            value,
            convertedMessages[i].sender,
            convertedMessages[i].receiver,
          );
          Session sessions = Session(
            userId: value,
            sender: convertedMessages[i].sender,
            contactId: convertedMessages[i].receiver,
            lastMessage: convertedMessages[i].context,
            messageType: convertedMessages[i].messageType,
            lastSender: convertedMessages[i].sender,
            seq: convertedMessages[i].seq,
          );
          if (msg == null) {
            await DatabaseHelper.instance.insertSession(sessions);
          } else {
            await DatabaseHelper.instance.updateSessions(sessions);
          }
        }
      } else {
        final Map<String, dynamic> messageMap = jsonDecode(message);
        final messageObject = MessageM.fromMap(messageMap);
        // _messageController.add(message);
        switch (messageObject.messageType) {
          case 5:
            int? clientid = messageObject.clientId;
            await DatabaseHelper.instance.updateMessageStatus(
              clientid!,
              3,
              messageObject.seq,
            );
            break;
          case 6:
            // 这是心跳检测
            break;
          case 3:
            // print("到了这边数据插入了");
            messageObject.userid = value;
            final id = await DatabaseHelper.instance.insertMessage(
              messageObject,
            );
            if (id > 0) {
              print("插入成功");
            }
            final msg = await DatabaseHelper.instance.getSession(
              value,
              messageObject.sender,
              messageObject.receiver,
            );
            Session sessions = Session(
              userId: value,
              sender: messageObject.sender,
              contactId: messageObject.receiver,
              lastMessage: messageObject.context,
              messageType: messageObject.messageType,
              lastSender: messageObject.sender,
              seq: messageObject.seq,
            );
            if (sessions.messageType == 3) {
              sessions.lastMessage = "图片";
            }
            if (msg == null) {
              await DatabaseHelper.instance.insertSession(sessions);
            } else {
              await DatabaseHelper.instance.updateSessions(sessions);
            }
            // 处理其他消息类型的逻辑
            break;
          case 13:
            messageObject.userid = value;
            final id = await DatabaseHelper.instance.insertMessage(
              messageObject,
            );
            if (id > 0) {
              print("插入成功");
            }
            final msg = await DatabaseHelper.instance.getSession(
              value,
              messageObject.sender,
              messageObject.receiver,
            );
            Session sessions = Session(
              userId: value,
              sender: messageObject.sender,
              contactId: messageObject.receiver,
              lastMessage: messageObject.context,
              messageType: messageObject.messageType,
              lastSender: messageObject.sender,
              seq: messageObject.seq,
            );
            if (msg == null) {
              await DatabaseHelper.instance.insertSession(sessions);
            } else {
              await DatabaseHelper.instance.updateSessions(sessions);
            }
            break;
          case 1:
            // print("到了这边数据插入了");
            messageObject.userid = value;
            final id = await DatabaseHelper.instance.insertMessage(
              messageObject,
            );
            if (id > 0) {
              print("插入成功");
            }
            final msg = await DatabaseHelper.instance.getSession(
              value,
              messageObject.sender,
              messageObject.receiver,
            );
            Session sessions = Session(
              userId: value,
              sender: messageObject.sender,
              contactId: messageObject.receiver,
              lastMessage: messageObject.context,
              messageType: messageObject.messageType,
              lastSender: messageObject.sender,
              seq: messageObject.seq,
            );
            if (msg == null) {
              await DatabaseHelper.instance.insertSession(sessions);
            } else {
              await DatabaseHelper.instance.updateSessions(sessions);
            }
            // 处理其他消息类型的逻辑
            break;
        }
      }
      // 插入到数据库
    }, onError: (error) {
      // _isConnected.value = false;

      print('WebSocket连接发生了错误：$error');
      _reconnect(url);
    }, onDone: () {
      _isConnected.value = false;
      print('WebSocket连接已关闭');
      _reconnect(url);
    });
  }

  Future<void> _reconnect(String url) async {
    if (_isConnected.value) {
      return; // 如果已连接，则不进行重新连接
    }

    const duration = Duration(seconds: 2);
    reconnectTimer?.cancel(); // 取消之前的定时器
    reconnectTimer = Timer(duration, () {
      try {
        if (_isConnected.value) {
          return;
        }
        if (token.isNotEmpty && token != '') {
          _channel.sink.close(); // Close the previous WebSocket connection
          connect("");
        }
        print('WebSocket重新连接成功');
        return;
      } catch (e) {
        _isConnected.value = false;
        print('WebSocket重新连接失败：$e');
      }
    });
  }

  @override
  void onClose() {
    _channel.sink.close();
    _messageController.close();
    _isConnected.value = false;
    reconnectTimer?.cancel(); // 取消定时器
    super.onClose();
  }

  @override
  void onInit() {
    getData('token').then((value) {
      if (value != null && value.isNotEmpty) {
        token.value = value;
        connect("");
      }
    });
    // 监听网络连接状态
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        // 没有网络连接，WebSocket连接断开
        _isConnected.value = false;
        _channel.sink.close();
        print('没有网络连接');
      } else if (!_isConnected.value) {
        // 有网络连接且之前WebSocket连接断开，尝试重新连接
        print('网络已连接，尝试重新连接');
        connect("");
      }
    });
    super.onInit();
  }

  Future<void> sendMessage(MessageM MessageM) async {
    if (_isConnected.value) {
      String jsonMessage = jsonEncode(MessageM.toMap());
      _channel.sink.add(jsonMessage);
      if (MessageM.messageType == 7) {
        return;
      }
      final msg = await DatabaseHelper.instance.getSession(
        MessageM.sender,
        MessageM.sender,
        MessageM.receiver,
      );
      final int currentTimestamp = DateTime.now().microsecondsSinceEpoch * 1000;
      Session sessions = Session(
        userId: MessageM.sender,
        sender: MessageM.sender,
        contactId: MessageM.receiver,
        lastMessage: MessageM.context,
        messageType: MessageM.messageType,
        lastSender: MessageM.sender,
        seq: currentTimestamp,
      );
      if (sessions.messageType == 3) {
        sessions.lastMessage = "图片";
      }
      if (msg == null) {
        DatabaseHelper.instance.insertSession(sessions);
      } else {
        DatabaseHelper.instance.updateSessions(sessions);
      }
    } else {
      print('无法发送消息，WebSocket连接未建立');
    }
  }

  void closeWebSocketConnection() {
    _channel.sink.close();
  }
}
