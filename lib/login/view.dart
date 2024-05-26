import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/login/password.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../utils/dio.dart';
import '../utils/shared_preferences.dart';
import '../utils/ws.dart';
import '../webview/view.dart';
import 'logic.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:untitled2/utils/apiurl.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final logic = Get.put(LoginLogic());

  final state = Get.find<LoginLogic>().state;
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController CodeEditingController = TextEditingController();
  final webSocketService = Get.find<WebSocketService>();
  bool _showClearButton = false;

  bool _isChecked = false;

  bool _isCountingDown = false;
  int _countdownTime = 60;
  bool _isPhoneNumberValid = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    getDevice();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    CodeEditingController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void getDevice() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;
    print(allInfo);
  }

  void sendSms() {
    if (_isChecked == false) {
      _showErrorDialog("请确认同用户协议");
      return;
    }
    final phoneNumber = _textEditingController.text.replaceAll(' ', '');
    if (phoneNumber.length == 11 && _isPhoneNumber()) {
      _sendDioRequest();
    } else {
      // 显示弹窗
      _showErrorDialog("请输入正确的手机号码");
    }
  }

  void _startCountdown() {
    final phoneNumber = _textEditingController.text.replaceAll(' ', '');
    if (phoneNumber.length == 11 && _isPhoneNumber()) {
      // 发送 Dio 请求
      final code = CodeEditingController.text.replaceAll(' ', '');
      if (code.length == 6) {
      } else {
        _showErrorDialog("请输入正确的验证码");
      }
    } else {
      // 显示弹窗
      _showErrorDialog("请输入正确的手机号码");
    }
  }

  bool _isPhoneNumber() {
    RegExp exp = RegExp(
        r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
    bool matched = exp.hasMatch(_textEditingController.text);
    return matched;
  }

  void _sendDioRequest() async {
    String timeString = getCurrentTimePlusThreeHours();
    print(timeString);
    String doubleEncryptedTime = doubleMd5EncryptTime(timeString);

    var data = {
      'phone': _textEditingController.text,
      'secret': doubleEncryptedTime
    };
    final res = await HttpUtil().post('/base/sendsms', data: data);
    var responseData = res.data; // 获取响应数据
    print(responseData['code']);
    print(responseData['msg']);
    if (responseData['code'] == 0) {
      _showErrorDialog("发送短信成功");
      setState(() {
        _isCountingDown = true;
        _countdownTime = 60;
      });

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_countdownTime > 0) {
            _countdownTime--;
          } else {
            _isCountingDown = false;
            _timer?.cancel();
          }
        });
      });
    } else {
      _showErrorDialog(responseData['msg']);
    }
  }

  String md5Encrypt(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);

    return digest.toString();
  }

  String doubleMd5EncryptTime(String timeString) {
    // 第一次加密
    String encryptedTime = md5Encrypt(timeString);
    return encryptedTime;
  }

  String getCurrentTimePlusThreeHours() {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedTime;
  }

  void login() async {
    var data = {
      'phone': _textEditingController.text,
      'code': CodeEditingController.text
    };
    final res = await HttpUtil().post('/base/phonelogin', data: data);
    var responseData = res.data; // 获取响应数据
    if (responseData['code'] == 0) {
      print("这是密码${responseData['data']['is_password']}");
      SharedPreferencesUtils.addData("token", responseData['data']['token'])
          .then((_) async {
        // 在此处编写处理成功的代码
        // accessToken 已成功添加到 SharedPreferences
        _showErrorDialog("登录成功");
        print(responseData['data']);
        int userid = responseData['data']['user']["ID"];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        try {
          await prefs.setInt('userid', userid);
          // 存储成功时执行的逻辑
          print('userid 存储成功');
          // 可以在这里继续执行其他操作
        } catch (error) {
          // 存储失败时执行的逻辑
          print('userid 存储失败: $error');
        }
        webSocketService.connect(responseData['data']['token']);
        if (responseData['data']['is_password']) {
          Get.toNamed('/home');
        } else {
          Get.toNamed('/resetPasswd');
        }
      }).catchError((error) {
        // 在此处编写处理错误的代码
        print("Error occurred while adding data: $error");
      });
    } else {
      _showErrorDialog("登录失败");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 35.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Get.to(() => PasswordLogin());
                  },
                  child: Text(
                    "密码登录",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 115.h,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "手机号验证码登陆",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "未注册的手机号验证后将自动创建新账户",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            SizedBox(
              height: 65.h,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8.0), // 设置圆角半径
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.0,
                ),
                child: TextField(
                  cursorColor: Colors.red,
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: "请输入手机号码",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8.0,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30.h,
            ),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        controller: CodeEditingController,
                        cursorColor: Colors.red,
                        decoration: InputDecoration(
                          hintText: "6位短信验证码",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 30.0),
                Expanded(
                  flex: 3,
                  child: TextButton(
                    onPressed: _isCountingDown ? null : sendSms,
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(
                        BorderSide(color: Colors.black12),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                        Colors.transparent,
                      ),
                      foregroundColor: MaterialStateProperty.all(
                        Colors.black,
                      ),
                      overlayColor: MaterialStateProperty.all(
                        Colors.transparent,
                      ),
                    ),
                    child: Text(
                      _isCountingDown ? '重新发送$_countdownTime秒' : '获取验证码',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30.h,
            ),
            Container(
              width: double.infinity,
              height: 70.h,
              child: TextButton(
                onPressed: () => {
                  login(),
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.deepOrange),
                  foregroundColor: MaterialStateProperty.all(Colors.green),
                ),
                child: Text(
                  '登陆',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30.h,
            ),
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  visualDensity: VisualDensity.compact, //这两个配合起来变成圆形
                  shape: CircleBorder(), //这两个配合起来变成圆形
                  activeColor: Colors.deepOrangeAccent, //选中后的颜色
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value!;
                    });
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: '我已阅读并同意',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: '用户协议',
                          style: TextStyle(color: Colors.blue),
                          // TODO: 添加服务协议的点击事件处理
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // 打开服务协议网页
                              openWebView(
                                  "http://chengxuyuanbuluo.cn/UserAgreement.html",
                                  "用户协议");
                            },
                        ),
                        TextSpan(text: '和'),
                        TextSpan(
                          text: '隐私注册协议',
                          style: TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // 打开服务协议网页
                              openWebView(
                                  "http://chengxuyuanbuluo.cn/PrivacyAgreement.html",
                                  "隐私注册协议");
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 400.h,
            ),
            // 分割线和其他登录方式文本
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.4),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    '其他登录方式',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.4),
                          ],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void openWebView(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebviewPage(url: url, title: title),
      ),
    );
  }

  void _showErrorDialog(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
