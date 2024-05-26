import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/dio.dart';
import 'logic.dart';

class ResetPasswdPage extends StatefulWidget {
  ResetPasswdPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswdPage> createState() => _ResetPasswdPageState();
}

class _ResetPasswdPageState extends State<ResetPasswdPage> {
  final logic = Get.put(ResetPasswdLogic());

  final state = Get.find<ResetPasswdLogic>().state;

  TextEditingController _passwordController = TextEditingController();

  TextEditingController _confirmPasswordController = TextEditingController();

  void _setPassword() async {
    var data = {
      'password': _passwordController.text,
      'newPassword': _confirmPasswordController.text
    };
    final res = await HttpUtil().post('/user/changeUserPassword', data: data);
    var responseData = res.data; // 获取响应数据
    if (responseData['code'] == 0) {
      BrnToast.show("设置密码成功", context);
      Get.toNamed('/home');
    } else {
      BrnToast.show("设置密码失败", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置密码'),
        backgroundColor: Color.fromRGBO(73, 129, 245, 1),
        leading: Container(),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '密码',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '确认密码',
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    String password = _passwordController.text;
                    String confirmPassword = _confirmPasswordController.text;
                    if (password == confirmPassword) {
                      _setPassword();
                      // 密码匹配，可以进行密码设置逻辑
                      // 例如将密码保存到数据库或发送到服务器
                    } else {
                      // 密码不匹配，显示错误提示
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('错误'),
                            content: Text('密码不匹配，请重新输入。'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('确定'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('设置密码'),
                ),
                TextButton(
                  onPressed: () {
                    Get.toNamed('/home');
                  },
                  child: Text("以后设置"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
