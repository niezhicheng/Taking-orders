import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../login/view.dart';
import '../personaldata/view.dart';
import '../utils/shared_preferences.dart';
import 'logic.dart';
import '../utils/ws.dart';

class SettingPage extends StatelessWidget {
  SettingPage({Key? key}) : super(key: key);

  final logic = Get.put(SettingLogic());
  final state = Get.find<SettingLogic>().state;
  final webSocketService = Get.find<WebSocketService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          "设置",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: ListTile(
              onTap: () {
                Get.to(() => PersonaldataPage());
              },
              title: Text(
                "个人资料",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black26,
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: ListTile(
              onTap: () {
                BrnDialogManager.showConfirmDialog(
                  context,
                  title: "注销账号",
                  cancel: '取消',
                  confirm: '确定',
                  message:
                      "您确定注销账号么 这将会删除您的一切账号记录 包含发布的需求,帖子,还有沟通记录 接单记录等等一切数据。",
                  onConfirm: () {
                    BrnToast.show("确定", context);
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                    BrnToast.show("取消", context);
                  },
                );
              },
              title: Text(
                "注销账号",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              trailing: Icon(
                Icons.logout,
                color: Colors.black26,
              ),
            ),
          ),
          Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Center(
              child: Container(
                height: 70.h,
                width: 600.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(73, 129, 245, 1),
                      Color.fromRGBO(115, 172, 248, 1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                margin: EdgeInsets.only(bottom: 100.0),
                child: InkWell(
                  onTap: () {
                    deleteData("token");
                    deleteData("userid");
                    webSocketService.closeWebSocketConnection();
                    Get.offAll(LoginPage());
                  },
                  child: Center(
                    child: Text(
                      "退出登录",
                      style: TextStyle(
                        fontSize: 32.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
