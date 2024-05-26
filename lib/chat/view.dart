import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bruno/bruno.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_document_picker/flutter_document_picker.dart';
// import 'package:flutter_plugin_record/flutter_plugin_record.dart';
// import 'package:flutter_plugin_record/utils/common_toast.dart';
// import 'package:flutter_plugin_record/widgets/custom_overlay.dart';
// import 'package:flutter_plugin_record/widgets/voice_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:untitled2/utils/apiurl.dart';
import '../detail/view.dart';
import '../utils/dio.dart';
import '../utils/shared_preferences.dart';
import '../utils/sqlite.dart';
import '../utils/ws.dart';
import 'logic.dart';
import 'model.dart';

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final logic = Get.put(ChatLogic());

  final state = Get.find<ChatLogic>().state;

  final webSocketService = Get.find<WebSocketService>();
  bool _shrinkWrap = true;
  bool isExpanded = false;
  bool isRecording = false;
  bool isRecord = false;

  ///默认隐藏状态
  bool voiceState = true;

  // FlutterPluginRecord? recordPlugin;
  String recordingTime = "00:00";
  Timer? recordingTimer;
  int elapsedSeconds = 0; // 重置已经录制的秒数
  List<MessageM> messages = [];
  // late RxList<MessageM> messages;
  // final messages = RxList<MessageM>([]).obs;
  TextEditingController _textEditingController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  int userid = 0;
  int receiver = 0;
  int sender = 0;
  int page = 1;
  int pageSize = 20;
  int latestSeq = 0; // 用于保存最新的消息序列号
  Timer? _timer; // 在State类中定义一个Timer变量
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isInitialDataLoaded = false;
  int cishu = 0;

  @override
  void initState() {
    receiver = Get.arguments["receiver"];
    sender = Get.arguments["sender"];
    userid = webSocketService.userid.value;
    initdata();
    _isInitialDataLoaded = true;
    _getPubProRecList();
    _releasePubProRecList();
    // recordPlugin = new FlutterPluginRecord();

    // _init();

    // ///初始化方法的监听
    // recordPlugin?.responseFromInit.listen((data) {
    //   if (data) {
    //     print("初始化成功");
    //   } else {
    //     print("初始化失败");
    //   }
    // });
    //
    // /// 开始录制或结束录制的监听
    // recordPlugin?.response.listen((data) {
    //   if (data.msg == "onStop") {
    //     ///结束录制时会返回录制文件的地址方便上传服务器
    //     print("onStop  " + data.path!);
    //     if (stopRecord != null)
    //       print(
    //         data.path,
    //       );
    //     print(data.audioTimeLength);
    //   } else if (data.msg == "onStart") {
    //     print("onStart --");
    //     print("开始");
    //   }
    // });

    webSocketService.messageStream.listen((message) async {
      final dynamic decodedMessage = jsonDecode(message);
      if (decodedMessage is List) {
        final List<MessageM> convertedMessages =
            decodedMessage.map((item) => MessageM.fromMap(item)).toList();
        for (int i = 0; i < convertedMessages.length; i++) {
          convertedMessages[i].userid = userid;
          messages.insert(0, convertedMessages[i]);
          _updateUI();
        }
      } else {
        final Map<String, dynamic> messageMap = jsonDecode(message);
        final messageObject = MessageM.fromMap(messageMap);
        // _messageController.add(message);
        switch (messageObject.messageType) {
          case 5:
            final index = messages.indexWhere(
              (item) => item.id == messageObject.id,
            );
            if (index != -1) {
              messages[index].status = 3;
              messages[index] = messages[index];
              _updateUI();
            }
            break;
          case 13:
            messageObject.userid = userid;
            messages.insert(0, messageObject);
            _updateUI();
            break;
          case 6:
            break;
          case 3:
            // 处理其他消息类型的逻辑
            messageObject.userid = userid;
            messages.insert(0, messageObject);
            _updateUI();
            break;
          case 1:
            // 处理其他消息类型的逻辑
            messageObject.userid = userid;
            messages.insert(0, messageObject);
            _updateUI();
            break;
        }
      }
    });
    // webSocketService.messageStream.listen((event) {
    //   final Map<String, dynamic> messageMap = jsonDecode(event);
    //   final messageObject = MessageM.fromMap(messageMap);
    //   switch (messageObject.messageType) {
    //     case 5:
    //       final index = messages.indexWhere(
    //         (item) => item.id == messageObject.id,
    //       );
    //       if (index != -1) {
    //         messages[index].status = 3;
    //         messages[index] = messages[index];
    //         _updateUI();
    //       }
    //       break;
    //     case 6:
    //       break;
    //     case 1:
    //       // 处理其他消息类型的逻辑
    //       messageObject.userid = userid;
    //       messages.insert(0, messageObject);
    //       _updateUI();
    //       break;
    //   }
    // });
    // TODO: implement initState
    super.initState();
  }

  void _updateUI() {
    if (!mounted) return; // 避免在页面已卸载的情况下更新UI
    setState(() {});
  }

  void initdata() async {
    if (page >= 2) {
      final data = await DatabaseHelper.instance.getMessagesByUser(
        userid,
        sender,
        receiver,
        page,
        pageSize,
      );
      if (data.isNotEmpty) {
        latestSeq = data[data.length - 1].id!;
      }
      setState(() {
        messages.addAll(data);
      });
    } else {
      final data = await DatabaseHelper.instance.getMessagesByUserMaxLimit(
        userid,
        sender,
        receiver,
      );
      if (data.isNotEmpty) {
        latestSeq = data[data.length - 1].id!;
      }
      setState(() {
        messages = data;
      });
    }
  }

  // ///初始化语音录制的方法
  // void _init() async {
  //   recordPlugin?.init();
  // }
  //
  // ///开始语音录制的方法
  // void start() async {
  //   print("开始录制");
  //   elapsedSeconds = 0; // 重置已经录制的秒数
  //   recordPlugin?.start();
  //   // 启动定时器，每秒更新一次录制时间
  //   recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     setState(() {
  //       elapsedSeconds++; // 每次定时器触发时增加1秒
  //       recordingTime =
  //           "${(elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(elapsedSeconds % 60).toString().padLeft(2, '0')}";
  //       print(recordingTime);
  //       if (elapsedSeconds > 120) {
  //         recordPlugin?.stop();
  //         // 停止定时器
  //         recordingTimer?.cancel();
  //         setState(() {
  //           print("这是");
  //           recordingTime = "00:00";
  //         });
  //       }
  //       print("时间");
  //     });
  //   });
  // }
  //
  // ///停止语音录制的方法
  // void stop() {
  //   print("停止语音");
  //   recordPlugin?.stop();
  //   // 停止定时器
  //   recordingTimer?.cancel();
  //   setState(() {
  //     print("这是");
  //     recordingTime = "00:00";
  //   });
  //   print(recordingTime);
  // }

  int getCurrentTimestamp() {
    DateTime now = DateTime.now();
    int timestamp2 = now.microsecondsSinceEpoch;
    return timestamp2 * 1000;
  }

  void _sendMessage(String messagestext) async {
    if (messagestext.isEmpty) {
      return;
    }
    if (!webSocketService.isConnected.value) {
      return;
    }
    int seq = getCurrentTimestamp();
    MessageM message = MessageM(
      userid: userid,
      sender: userid,
      receiver: receiver,
      messageType: 1,
      context: _textEditingController.text,
      seq: seq,
      status: 1,
    );
    if (receiver == userid) {
      message.receiver = sender;
    }
    final id = await DatabaseHelper.instance.insertMessage(message);
    message.clientId = id;
    webSocketService.sendMessage(message);
    _textEditingController.clear();
    setState(() {
      messages.insert(0, message);
    });
    _timer = Timer(Duration(seconds: 2), () {
      for (var i = 0; i < messages.length; i++) {
        final message = messages[i];
        if (message.clientId == id) {
          if (message.status != 3) {
            message.status = 2;
            messages[i] = message;
            setState(() {});
          } else {
            setState(() {});
          }
          break;
        }
      }
    });
  }

  /// 图片选取
  Future<void> getImage() async {
    final XFile? xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery, // Choose from gallery
      maxWidth:
          1000.0, // Set the maximum width of the image (indirectly reduces file size)
    );

    if (xfile != null) {
      File file = File(xfile.path);
      final response = await HttpUtil().uploadFile(file);
      // print('上传结果: ${response.data['url']}');
      print(response.data['data']['file']['url']);
      int seq = getCurrentTimestamp();
      int microseconds = seq ~/ 1000; // 将纳秒转换为微秒
      DateTime dt =
          DateTime.fromMicrosecondsSinceEpoch(microseconds, isUtc: true);
      DateTime localDateTime = dt.toLocal();
      MessageM message = MessageM(
        userid: userid,
        sender: userid,
        receiver: receiver,
        messageType: 3,
        // context: _textEditingController.text,
        imageUrl: response.data['data']['file']['url'],
        seq: seq,
        status: 1,
      );
      print(message.seq);
      if (receiver == userid) {
        message.receiver = sender;
      }
      final id = await DatabaseHelper.instance.insertMessage(message);
      message.clientId = id;
      webSocketService.sendMessage(message);
      _textEditingController.clear();
      setState(() {
        messages.insert(0, message);
      });
      _timer = Timer(Duration(seconds: 2), () {
        for (var i = 0; i < messages.length; i++) {
          final message = messages[i];
          if (message.clientId == id) {
            if (message.status != 3) {
              message.status = 2;
              messages[i] = message;
              setState(() {});
            } else {
              setState(() {});
            }
            break;
          }
        }
      });
    } else {
      print('选取图片失败');
    }

    // print('${file?.path}');
  }

  /// 视频选取
  Future<void> getphotograph() async {
    final XFile? file = await ImagePicker().pickVideo(
      source: ImageSource.camera, // 调用相机拍摄
    );
    print('${file?.path}');
  }

  /// 附件选取
  Future<void> getDocument() async {
    // FlutterDocumentPickerParams? params = FlutterDocumentPickerParams(
    //     // 允许选取的文件拓展类型，不加此属性则默认支持所有类型
    //     // allowedFileExtensions: ['pdf', 'xls', 'xlsx', 'jpg', 'png', 'jpeg',''],
    //     );
    //
    // String? path = await FlutterDocumentPicker.openDocument(
    //   params: params,
    // );
    //
    // print('$path');
  }

  startRecord() {
    print("开始录制");
  }

  stopRecord(String path, double audioTimeLength) {
    print("结束束录制");
    print("音频文件位置" + path);
    print("音频录制时长" + audioTimeLength.toString());
  }

  @override
  void dispose() {
    recordingTimer?.cancel(); // 取消定时器
    _timer?.cancel();
    _textFieldFocusNode.dispose();
    page = 0;
    pageSize = 20;
    // _connectivitySubscription.cancel();
    super.dispose();
  }

  int ReceProPage = 1;
  int ReceProPageSize = 10;

  List<dynamic> ReceProlist = [];

  List<dynamic> ReceiverOne = [];

  // 接单列表
  Future<void> _getPubProRecList() async {
    var data = {'page': 1, 'pageSize': 10};
    final response = await HttpUtil().get(
      '/PubPro/RecProjectList',
      data: data,
    );
    setState(() {
      ReceProlist = response.data['data']['list'];
    });
  }

  List<dynamic> releaseProlist = [];

  // 发单列表
  Future<void> _releasePubProRecList() async {
    var data = {'page': 1, 'pageSize': 10};
    final response = await HttpUtil().get(
      '/PubPro/ProjectRecUserList',
      data: data,
    );
    setState(() {
      releaseProlist = response.data['data']['list'];
    });
  }

  /// 发送项目
  Future<void> ProjectSending(String text, String projectid) async {
    int seq = getCurrentTimestamp();
    MessageM message = MessageM(
      userid: userid,
      sender: userid,
      receiver: receiver,
      messageType: 13,
      context: text,
      seq: seq,
      status: 1,
      fileType: projectid,
    );
    if (receiver == userid) {
      message.receiver = sender;
    }
    final id = await DatabaseHelper.instance.insertMessage(message);
    message.clientId = id;
    webSocketService.sendMessage(message);
    _textEditingController.clear();
    setState(() {
      messages.insert(0, message);
    });
    _timer = Timer(Duration(seconds: 2), () {
      for (var i = 0; i < messages.length; i++) {
        final message = messages[i];
        if (message.clientId == id) {
          if (message.status != 3) {
            message.status = 2;
            messages[i] = message;
            setState(() {});
          } else {
            setState(() {});
          }
          break;
        }
      }
    });
  }

  /// 交换微信
  Future<void> SwithWexin(String text, String projectid) async {
    int seq = getCurrentTimestamp();
    MessageM message = MessageM(
      userid: userid,
      sender: userid,
      receiver: receiver,
      messageType: 9,
      context: text,
      seq: seq,
      status: 1,
      fileType: projectid,
    );
    if (receiver == userid) {
      message.receiver = sender;
    }
    final id = await DatabaseHelper.instance.insertMessage(message);
    message.clientId = id;
    webSocketService.sendMessage(message);
    _textEditingController.clear();
    setState(() {
      messages.insert(0, message);
    });
    _timer = Timer(Duration(seconds: 2), () {
      for (var i = 0; i < messages.length; i++) {
        final message = messages[i];
        if (message.clientId == id) {
          if (message.status != 3) {
            message.status = 2;
            messages[i] = message;
            setState(() {});
          } else {
            setState(() {});
          }
          break;
        }
      }
    });
  }

  // 录取技术
  Future<void> _AdmissionTechniques(int id) async {
    var data = {'ID': id, 'receiver': receiver};
    if (receiver == webSocketService.userid.value) {
      data['receiver'] = sender;
    }
    final response = await HttpUtil().get(
      '/PubPro/ProjectAdmissionTechniques',
      data: data,
    );
    BrnToast.show("${response.data['msg']}", context);
  }

  // 拒绝此技术
  Future<void> _DenyProjectReceiving(int id) async {
    var data = {'ID': id, 'receiver': receiver};
    if (receiver == webSocketService.userid.value) {
      data['receiver'] = sender;
    }
    final response = await HttpUtil().get(
      '/PubPro/DenyProjectReceiving',
      data: data,
    );
    BrnToast.show("${response.data['msg']}", context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 返回上一个页面
          },
        ),
        actions: [
          TextButton(
            onPressed: () => {
              BrnMiddleInputDialog(
                title: '是否要投诉对方',
                message: "如果对方对您进行谩骂,违法行为的交流等一切行为 您可投诉对方 ",
                hintText: '请输入投诉的内容',
                cancelText: '取消',
                confirmText: '确定',
                autoFocus: true,
                maxLength: 1000,
                maxLines: 2,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                dismissOnActionsTap: false,
                barrierDismissible: true,
                onConfirm: (value) {
                  BrnToast.show(value, context);
                },
                onCancel: () {
                  BrnToast.show("取消", context);
                  Navigator.pop(context);
                },
              ).show(context)
            },
            child: const Text(
              "投诉",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () => {
              BrnDialogManager.showConfirmDialog(context,
                  title: "拉黑",
                  cancel: '取消',
                  confirm: '确定',
                  message: "您确定拉黑对方么 拉黑后您将收不到任何对方发来的消息。", onConfirm: () {
                BrnToast.show("确定", context);
              }, onCancel: () {
                Navigator.of(context).pop();
                BrnToast.show("取消", context);
              })
            },
            child: const Text(
              "拉黑",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
        title: Obx(() {
          final isConnected = webSocketService.isConnected.value;
          return Text(
            isConnected ? "已连接" : "未连接",
            style: const TextStyle(color: Colors.white),
          );
        }),
        backgroundColor: const Color.fromRGBO(73, 129, 245, 1),
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Align(
              // 此处为关键代码
              alignment: Alignment.topRight,
              child: EasyRefresh(
                footer: const ClassicFooter(
                  dragText: '上拉加载',
                  armedText: '释放加载',
                  readyText: '正在加载...',
                  processingText: '正在加载...',
                  processedText: '加载成功',
                  noMoreText: '没有更多数据',
                  failedText: '加载失败',
                  messageText: '上次更新时间：%T',
                ),
                onLoad: () {
                  return Future.delayed(const Duration(seconds: 2), () {
                    if (!mounted) {
                      return;
                    }
                    page = page += 1;
                    setState(() {
                      initdata();
                    });
                  });
                },
                child: CustomScrollView(
                  reverse: true,
                  shrinkWrap: _shrinkWrap,
                  clipBehavior: Clip.none,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final chat = messages[index];
                          final isMe =
                              chat.receiver != webSocketService.userid.value;
                          int? seq = chat.seq;
                          int? nanoseconds = seq;
                          DateTime dateTime =
                              DateTime.fromMicrosecondsSinceEpoch(
                                  nanoseconds ~/ 1000);
                          String formattedDate = formatDateTimeForOne(dateTime);
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0.w, vertical: 10.0.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: isMe
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe) ...[
                                      Container(
                                        width: 60.0.w,
                                        height: 60.0.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Color.fromRGBO(73, 129, 245, 1),
                                          child: Text(
                                            "收",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.0.w),
                                    ],
                                    Flexible(
                                      child: Align(
                                        alignment: isMe
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Row(
                                          mainAxisAlignment: isMe
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.start,
                                          children: [
                                            if (isMe) ...[
                                              if (chat.status == 2) ...[
                                                Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                              ],
                                              if (chat.status == 1) ...[
                                                const CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors
                                                              .blue), // 加载动画颜色
                                                  strokeWidth: 2.0, // 圆圈线条的宽度
                                                ),
                                              ]
                                            ],
                                            Column(
                                              crossAxisAlignment: isMe
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: 500.w,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isMe
                                                        ? const Color.fromRGBO(
                                                            73, 129, 245, 1)
                                                        : Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                          isMe ? 10.0 : 0.0),
                                                      topRight: Radius.circular(
                                                          isMe ? 0.0 : 10.0),
                                                      bottomLeft:
                                                          Radius.circular(10.0),
                                                      bottomRight:
                                                          Radius.circular(10.0),
                                                    ),
                                                  ),
                                                  padding:
                                                      EdgeInsets.all(12.0.w),
                                                  child: Column(
                                                    children: [
                                                      if (chat.messageType ==
                                                          1) ...[
                                                        SelectableText(
                                                          "${chat.context}",
                                                          style: TextStyle(
                                                            fontSize: 30.0.sp,
                                                            color: isMe
                                                                ? Colors.white
                                                                : Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                      if (chat.messageType ==
                                                          3) ...[
                                                        InkWell(
                                                          onTap: () {
                                                            Get.to(
                                                              () => ExtendImags(
                                                                chat.imageUrl
                                                                    .toString(),
                                                              ),
                                                            );
                                                          },
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl:
                                                                "${chat.imageUrl}",
                                                          ),
                                                        ),
                                                      ],
                                                      if (chat.messageType ==
                                                          13) ...[
                                                        if (!isMe) ...[
                                                          InkWell(
                                                            onTap: () {
                                                              String str = chat
                                                                  .fileType
                                                                  .toString();
                                                              int num =
                                                                  int.parse(
                                                                      str);
                                                              Get.to(
                                                                () =>
                                                                    DetailPage(),
                                                                arguments: {
                                                                  "id": num,
                                                                },
                                                              );
                                                            },
                                                            child: ListTile(
                                                              leading:
                                                                  SvgPicture
                                                                      .asset(
                                                                "assets/项目.svg",
                                                                width: 40.w,
                                                                height: 40.h,
                                                              ),
                                                              title: Text(
                                                                chat.context
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              subtitle: Text(
                                                                "点击进入项目详情",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                        if (isMe) ...[
                                                          InkWell(
                                                            onTap: () {
                                                              String str = chat
                                                                  .fileType
                                                                  .toString();
                                                              int num =
                                                                  int.parse(
                                                                      str);
                                                              Get.to(
                                                                () =>
                                                                    DetailPage(),
                                                                arguments: {
                                                                  "id": num,
                                                                },
                                                              );
                                                            },
                                                            child: ListTile(
                                                              leading:
                                                                  SvgPicture
                                                                      .asset(
                                                                "assets/项目s.svg",
                                                                width: 40.w,
                                                                height: 40.h,
                                                              ),
                                                              title: Text(
                                                                chat.context
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                              subtitle: Text(
                                                                "点击进入项目详情",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ]
                                                      ]
                                                      // chat.messageType == 1
                                                      //     ? Text(
                                                      //         "${chat.context}",
                                                      //         style: TextStyle(
                                                      //           fontSize:
                                                      //               30.0.sp,
                                                      //           color: isMe
                                                      //               ? Colors
                                                      //                   .white
                                                      //               : Colors
                                                      //                   .black,
                                                      //         ),
                                                      //       )
                                                      //     : InkWell(
                                                      //         onTap: () {
                                                      //           Get.to(
                                                      //             () =>
                                                      //                 ExtendImags(
                                                      //               chat.imageUrl
                                                      //                   .toString(),
                                                      //             ),
                                                      //           );
                                                      //         },
                                                      //         child:
                                                      //             CachedNetworkImage(
                                                      //           imageUrl:
                                                      //               "${chat.imageUrl}",
                                                      //         ),
                                                      //       ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4.h,
                                                ),
                                                Text(
                                                  formattedDate,
                                                  style: TextStyle(
                                                    fontSize: 17.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (!isMe) ...[
                                              if (chat.status == 2) ...[
                                                Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                              ],
                                              if (chat.status == 1) ...[
                                                CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors
                                                              .blue), // 加载动画颜色
                                                  strokeWidth: 2.0, // 圆圈线条的宽度
                                                ),
                                              ]
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (isMe) ...[
                                      SizedBox(width: 10.0.w),
                                      Container(
                                        width: 60.0.w,
                                        height: 60.0.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Color.fromRGBO(73, 129, 245, 1),
                                          child: Text(
                                            "发",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: messages.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      height: isExpanded ? (isRecording ? 410.h : 300.h) : 170.h,
      // 根据展开状态调整高度
      padding: EdgeInsets.only(left: 10.0.w, right: 10.0.w),
      margin: EdgeInsets.only(top: 5.0.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 2.0,
            spreadRadius: 1.0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              // InkWell(
              //   child: Container(
              //     margin: EdgeInsets.only(top: 8.h, left: 10.w),
              //     decoration: BoxDecoration(
              //       border: Border.all(
              //         color: Colors.grey[300]!,
              //         width: 1.0,
              //       ),
              //       borderRadius: BorderRadius.circular(8.0),
              //     ),
              //     padding: EdgeInsets.symmetric(
              //       horizontal: 10.0,
              //       vertical: 5.0,
              //     ),
              //     child: Text(
              //       "交换微信",
              //       style: TextStyle(
              //         fontSize: 14.0,
              //       ),
              //     ),
              //   ),
              //   onTap: () {},
              // ),
              InkWell(
                child: Container(
                  margin: EdgeInsets.only(top: 8.h, left: 10.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  child: Text(
                    "发送项目",
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return DefaultTabController(
                        length: 2, // 选项卡数量
                        initialIndex: 0, // 初始选中的选项卡索引
                        child: Container(
                          height: 800.h,
                          child: Column(
                            children: [
                              TabBar(
                                labelColor: Colors.black, // 选中的文本颜色
                                unselectedLabelColor: Colors.grey,
                                tabs: [
                                  Tab(
                                    text: '已发布项目',
                                  ),
                                  Tab(
                                    text: '已接项目',
                                  ),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    ListView.builder(
                                      itemCount: releaseProlist.length,
                                      itemBuilder: (BuildContext, index) {
                                        return ListTile(
                                          leading: SvgPicture.asset(
                                            "assets/项目.svg",
                                            width: 60.w,
                                            height: 60.h,
                                          ),
                                          title: Text(
                                            releaseProlist[index]
                                                ['projectName'],
                                          ),
                                          trailing: BrnStateTag(
                                            tagText: getStatusText(
                                                releaseProlist[index]
                                                    ['projectStatus']),
                                            tagState: TagState.running,
                                          ),
                                          onTap: () {
                                            ProjectSending(
                                              releaseProlist[index]
                                                  ['projectName'],
                                              releaseProlist[index]['ID']
                                                  .toString(),
                                            );
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ),
                                    ListView.builder(
                                      itemCount: ReceProlist.length,
                                      itemBuilder: (BuildContext, index) {
                                        return ListTile(
                                          leading: SvgPicture.asset(
                                            "assets/项目.svg",
                                            width: 60.w,
                                            height: 60.h,
                                          ),
                                          title: Text(
                                            ReceProlist[index]['projectName'],
                                          ),
                                          trailing: BrnStateTag(
                                            tagText: getStatusText(
                                                ReceProlist[index]
                                                    ['projectStatus']),
                                            tagState: TagState.running,
                                          ),
                                          onTap: () {
                                            ProjectSending(
                                              ReceProlist[index]['projectName'],
                                              ReceProlist[index]['ID']
                                                  .toString(),
                                            );
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              InkWell(
                child: Container(
                  margin: EdgeInsets.only(top: 8.h, left: 10.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  child: Text(
                    "录用此技术",
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 800.h,
                        child: ListView.builder(
                          itemCount: releaseProlist.length,
                          itemBuilder: (BuildContext, index) {
                            final isdisable =
                                releaseProlist[index]['projectStatus'];
                            return ListTile(
                              leading: SvgPicture.asset(
                                "assets/项目.svg",
                                width: 60.w,
                                height: 60.h,
                              ),
                              title: Text(
                                releaseProlist[index]['projectName'],
                              ),
                              subtitle: BrnStateTag(
                                tagText: getStatusText(
                                  releaseProlist[index]['projectStatus'],
                                ),
                                tagState: TagState.running,
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  if (isdisable == 2) {
                                    // 如果 status 等于1，则执行点击事件
                                    _AdmissionTechniques(
                                        releaseProlist[index]['ID']);
                                    Navigator.pop(context);
                                  } else {
                                    // 如果 status 不等于1，则禁用按钮不让它被点击
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text('提示'),
                                        content: Text('非被接单状态不允许录用此技术！'),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('确认'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                child: Text('录用此技术'),
                              ),
                              onTap: () {
                                Get.to(
                                  () => DetailPage(),
                                  arguments: {
                                    "id": releaseProlist[index]["ID"],
                                  },
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              InkWell(
                child: Container(
                  margin: EdgeInsets.only(top: 8.h, left: 10.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  child: Text(
                    "拒绝此技术重新招募",
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
                onTap: () async {
                  var data = {'receiver': receiver, 'page': 1, 'pageSize': 10};
                  if (userid == receiver) {
                    data['receiver'] = sender;
                  }
                  final response = await HttpUtil().get(
                    '/PubPro/ProjectDenyList',
                    data: data,
                  );
                  if (response.data['code'] == 0) {
                    ReceiverOne = response.data['data']['list'];
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 800.h,
                          child: ListView.builder(
                            itemCount: ReceiverOne.length,
                            itemBuilder: (BuildContext, index) {
                              return ListTile(
                                leading: SvgPicture.asset(
                                  "assets/项目.svg",
                                  width: 60.w,
                                  height: 60.h,
                                ),
                                title: Text(
                                  ReceiverOne[index]['projectName'],
                                ),
                                subtitle: BrnStateTag(
                                  tagText: getStatusText(
                                    ReceiverOne[index]['projectStatus'],
                                  ),
                                  tagState: TagState.running,
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    _DenyProjectReceiving(
                                      ReceiverOne[index]['ID'],
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: Text('拒绝此技术'),
                                ),
                                onTap: () {
                                  Get.to(
                                    () => DetailPage(),
                                    arguments: {
                                      "id": ReceiverOne[index]["ID"],
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
          Row(
            children: <Widget>[
              // InkWell(
              //   onTap: () {
              //     setState(() {
              //       // 处理语音信息按钮点击
              //       isRecording = true;
              //       isExpanded = !isExpanded;
              //     });
              //   },
              //   child: Container(
              //     padding: EdgeInsets.all(16.0.w),
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       color: Colors.grey.withOpacity(0.2),
              //     ),
              //     child: Icon(Icons.mic, size: 36.0.sp),
              //   ),
              // ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: 5.0.w,
                    right: 5.0.w,
                    top: 15.0.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _textEditingController,
                        decoration: const InputDecoration(
                          hintText: '请输入内容',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 3.0,
                          ),
                        ),
                        focusNode: _textFieldFocusNode,
                        onSubmitted: (String text) {
                          _sendMessage(text);
                          _textFieldFocusNode.requestFocus(); // 请求焦点
                        },
                      ),
                      // Positioned(
                      //   top: 0,
                      //   bottom: 0,
                      //   right: 0,
                      //   child: InkWell(
                      //     onTap: () {
                      //       // 处理表情按钮点击
                      //     },
                      //     child: Container(
                      //       padding: EdgeInsets.all(16.0.w),
                      //       child: Icon(Icons.emoji_emotions, size: 36.0.sp),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(
                    () {
                      isExpanded = !isExpanded; // 切换展开状态
                      isRecording = false;
                    },
                  );
                  // _sendMessage(_textEditingController.text);
                },
                child: Container(
                  padding: EdgeInsets.all(16.0.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  child: Icon(
                    isExpanded ? Icons.close : Icons.add,
                    size: 36.0.sp,
                  ),
                ),
              ),
            ],
          ),
          if (isExpanded) // 根据展开状态添加更多功能
            if (!isRecording) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      // 处理语音信息按钮点击
                      getImage();
                    },
                    child: Container(
                      padding: EdgeInsets.all(24.0.w),
                      margin: EdgeInsets.all(25.0.w),
                      height: 100.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      child: Icon(Icons.image, size: 48.0.sp),
                    ),
                  ),
                  // InkWell(
                  //   onTap: () {
                  //     getphotograph();
                  //     // 处理语音信息按钮点击
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.all(24.0.w),
                  //     margin: EdgeInsets.all(25.0.w),
                  //     height: 100.h,
                  //     decoration: BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       color: Colors.grey.withOpacity(0.2),
                  //     ),
                  //     child: Icon(Icons.camera_alt, size: 48.0.sp),
                  //   ),
                  // ),
                  // InkWell(
                  //   onTap: () {
                  //     // 处理语音信息按钮点击
                  //     getDocument();
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.all(24.0.w),
                  //     margin: EdgeInsets.all(25.0.w),
                  //     height: 100.h,
                  //     decoration: BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       color: Colors.grey.withOpacity(0.2),
                  //     ),
                  //     child: Icon(Icons.file_copy, size: 48.0.sp),
                  //   ),
                  // ),
                ],
              ),
            ] else
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 15.0.h),
                    height: 30.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isRecord) ...[
                          Center(
                            child: Text(recordingTime),
                          ),
                        ]
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Center(
                    child: Text(
                      "按住说话",
                      style: TextStyle(),
                    ),
                  ),
                  SizedBox(
                    height: 25.h,
                  ),
                  GestureDetector(
                    onTapDown: (_) {
                      setState(() {
                        isRecord = true;
                        // start();
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        isRecord = false;
                        // stop();
                      });
                    },
                    onTapCancel: () {
                      setState(() {
                        isRecord = false;
                        // stop();
                      });
                    },
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 10,
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 128.sp,
                              ),
                            ),
                            Container(
                              width: isRecord ? 90.0 : 80.0,
                              height: isRecord ? 90.0 : 80.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: isRecord ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 200),
                              child: Container(
                                width: 80.0,
                                height: 80.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: Icon(
                                Icons.mic,
                                size: 40.0,
                                color: isRecord ? Colors.white54 : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  DateTime convertNanosecondsToDateTime(int nanoseconds) {
    Duration duration = Duration(microseconds: nanoseconds ~/ 1000);
    DateTime dateTime = DateTime.utc(1970).add(duration).toLocal();
    return dateTime;
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

  //显示具体的时间
  String formatDateTimeForOne(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(Duration(days: 1));
    DateTime currentYear = DateTime(now.year);
    String formattedDate;

    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      // 当天的消息，显示几点几分
      formattedDate = DateFormat('HH:mm:ss').format(dateTime);
    } else if (dateTime.day == yesterday.day &&
        dateTime.month == yesterday.month &&
        dateTime.year == yesterday.year) {
      // 昨天的消息，显示昨天几点几分
      formattedDate = '昨天 ' + DateFormat('HH:mm:ss').format(dateTime);
    } else if (dateTime.year == currentYear.year) {
      // 当年的消息，显示几月几号
      formattedDate = DateFormat('MM/dd HH:mm:ss').format(dateTime);
    } else {
      // 非当年的消息，显示完整日期，例如：2023/08/04
      formattedDate = DateFormat('yyyy/MM/dd HH:mm:ss').format(dateTime);
    }

    return formattedDate;
  }

  String getStatusText(int status) {
    String statusText;

    switch (status) {
      case 1:
        statusText = '待接单';
        break;
      case 2:
        statusText = '沟通中';
        break;
      case 3:
        statusText = '已录用';
        break;
      case 4:
        statusText = '交付中';
        break;
      case 5:
        statusText = '已结束';
        break;
      case 6:
        statusText = '项目关闭';
        break;
      default:
        statusText = '';
        break;
    }

    return statusText;
  }
}

class ExtendImags extends StatelessWidget {
  // 传入照片的url地址
  String imageUrl;
  ExtendImags(this.imageUrl, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: InkWell(
        onTap: () {
          // 点击图片返回
          Navigator.pop(context);
        },
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
        ),
      ),
    );
  }
}
