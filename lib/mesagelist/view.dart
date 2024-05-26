import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/mesagelist/model.dart';
import '../chat/model.dart';
import '../chat/view.dart';
import '../utils/sqlite.dart';
import '../utils/ws.dart';
import 'logic.dart';

class MesagelistPage extends StatefulWidget {
  @override
  State<MesagelistPage> createState() => _MesagelistPageState();
}

class _MesagelistPageState extends State<MesagelistPage> {
  final logic = Get.put(MesagelistLogic());

  final state = Get.find<MesagelistLogic>().state;

  List<Session> _data = [];
  final webSocketService = Get.find<WebSocketService>();
  bool _isInitialDataLoaded = false;
  Timer? _delayedTimer;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  int cishu = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initdata();
    _isInitialDataLoaded = true;
    // webSocketService.messageStream.listen((event) {
    //   final dynamic decodedMessage = jsonDecode(message);
    //   if (decodedMessage is List) {
    //   final Map<String, dynamic> messageMap = jsonDecode(event);
    //   final messageObject = MessageM.fromMap(messageMap);
    //   switch (messageObject.messageType) {
    //     case 5:
    //       break;
    //     case 6:
    //       break;
    //     case 1:
    //       _startDelayedExecution();
    //       break;
    //   }
    // });
    webSocketService.messageStream.listen((message) async {
      final dynamic decodedMessage = jsonDecode(message);
      if (decodedMessage is List) {
        final List<MessageM> convertedMessages =
            decodedMessage.map((item) => MessageM.fromMap(item)).toList();
        for (int i = 0; i < convertedMessages.length; i++) {
          _startDelayedExecution();
        }
      } else {
        final Map<String, dynamic> messageMap = jsonDecode(message);
        final messageObject = MessageM.fromMap(messageMap);
        // _messageController.add(message);
        switch (messageObject.messageType) {
          case 5:
            _startDelayedExecution();
            break;
          case 6:
            // 这是心跳检测
            break;
          case 3:
            _startDelayedExecution();
            break;
          case 1:
            _startDelayedExecution();
            break;
        }
      }
    });
  }

  void initdata() async {
    final sessions = await DatabaseHelper.instance.getAllSessions(
      webSocketService.userid.value,
    );
    setState(() {
      _data = sessions;
    });
  }

  void _startDelayedExecution() {
    Timer(Duration(seconds: 2), () {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          initdata();
        }
        print('Delayed async execution');
      });
    });
  }

  @override
  void dispose() {
    _cancelDelayedExecution();
    // _connectivitySubscription.cancel();
    super.dispose();
  }

  void _cancelDelayedExecution() {
    _delayedTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(73, 129, 245, 1),
        title: Text(
          "消息列表",
          style: TextStyle(color: Colors.white),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Center(
            child: Obx(() {
              final isConnected = webSocketService.isConnected.value;
              return Text(
                isConnected ? "已连接" : "未连接",
                style: const TextStyle(color: Colors.white),
              );
            }),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (BuildContext context, int index) {
          final chatItem = _data[index];
          int? seq = chatItem.seq;
          int? nanoseconds = seq;
          DateTime dateTime =
              DateTime.fromMicrosecondsSinceEpoch(nanoseconds! ~/ 1000);
          String formattedDate = formatDateTimeForWeChat(dateTime);
          print('DateTime: $dateTime');
          // final dateTime = DateTime.parse(chatItem.CreatedAt.toString());
          return Container(
            color: Colors.white,
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头像
                    if (chatItem.contactId !=
                        webSocketService.userid.value) ...[
                      CircleAvatar(
                        backgroundColor: Color.fromRGBO(73, 129, 245, 1),
                        child: Text(
                          chatItem.contactId.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (chatItem.contactId ==
                        webSocketService.userid.value) ...[
                      CircleAvatar(
                        backgroundColor: Color.fromRGBO(73, 129, 245, 1),
                        child: Text(
                          chatItem.sender.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    // 聊天信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 用户名和时间
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10.0,
                                  top: 0.0,
                                ),
                                child: () {
                                  if (chatItem.contactId ==
                                      webSocketService.userid.value) {
                                    return Text(
                                      chatItem.sender.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16.0,
                                      ),
                                    );
                                  } else {
                                    return Text(
                                      chatItem.contactId.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16.0,
                                      ),
                                    );
                                  }
                                }(),
                              ),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          // 消息内容
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, top: 5.0),
                            child: Text(
                              "${chatItem.lastMessage}",
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1, // 最多显示1行
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                if (chatItem.contactId == chatItem.sender) {
                  Get.snackbar(
                    '提示',
                    '系统异常',
                    snackPosition: SnackPosition.BOTTOM, // 设置为底部位置
                    margin: EdgeInsets.symmetric(
                      horizontal: 20.h,
                      vertical: 30.h,
                    ), // 自定义边距
                    backgroundColor: Colors.grey[800], // 自定义背景颜色
                    colorText: Colors.white, // 自定义文本颜色
                  );
                  return;
                }
                Get.to(() => ChatPage(), arguments: {
                  'receiver': chatItem.contactId,
                  'sender': chatItem.sender,
                });
              },
            ),
          );
        },
      ),
    );
  }

  String formatDateTimeForWeChat(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(Duration(days: 1));
    DateTime currentYear = DateTime(now.year);
    DateTime previousYear = DateTime(now.year - 1);

    String formattedDate;

    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      // 当天的消息，显示几点几分
      formattedDate = DateFormat('HH:mm').format(dateTime);
    } else if (dateTime.day == yesterday.day &&
        dateTime.month == yesterday.month &&
        dateTime.year == yesterday.year) {
      // 昨天的消息，显示昨天几点几分
      formattedDate = '昨天 ' + DateFormat('HH:mm').format(dateTime);
    } else if (dateTime.year == currentYear.year) {
      // 当年的消息，显示几月几号
      formattedDate = DateFormat('MM/dd').format(dateTime);
    } else {
      // 非当年的消息，显示完整日期，例如：2023/08/04
      formattedDate = DateFormat('yyyy/MM/dd').format(dateTime);
    }

    return formattedDate;
  }
}
