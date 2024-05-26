import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:untitled2/login/view.dart';
import 'package:untitled2/setting/view.dart';

import '../demand/view.dart';
import '../personaldata/view.dart';
import '../receivedlist/view.dart';
import '../utils/dio.dart';
import '../utils/shared_preferences.dart';

import 'logic.dart';
import '../utils/ws.dart';

class CenterPage extends StatefulWidget {
  @override
  State<CenterPage> createState() => _CenterPageState();
}

class _CenterPageState extends State<CenterPage> {
  final logic = Get.put(CenterLogic());

  final state = Get.find<CenterLogic>().state;
  final webSocketService = Get.find<WebSocketService>();

  var userinfo = {};
  var nickName = "";
  var customerType = 0;
  var headerImg = "";
  var projectCount = {};

  @override
  void initState() {
    _getUserInfo();
    _getProjectCount();
    // TODO: implement initState
    super.initState();
  }

  Future<void> _getUserInfo() async {
    final response = await HttpUtil().get(
      '/user/getUserInfo',
    );
    setState(() {
      userinfo = response.data['data']['userInfo'];
      nickName = userinfo['nickName'];
      customerType = userinfo['customerType'];
      headerImg = userinfo['headerImg'];
    });
  }

  List<Map<String, dynamic>> gridData = [
    {
      'icon': "assets/最新任务_24.svg",
      'text': '我的需求',
    },
    // {
    //   'icon': "assets/稿件征集_48.svg",
    //   'text': '我的帖子',
    // },
    // {
    //   'icon': "assets/身份认证_48.svg",
    //   'text': '身份认证',
    // },
    // {
    //   'icon': "assets/钱包_48.svg",
    //   'text': '账户余额',
    // },
  ];

  Future<void> _getProjectCount() async {
    final response = await HttpUtil().get(
      '/PubPro/UserPublishProjectCount',
    );
    setState(() {
      projectCount = response.data['data']['usercount'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(73, 129, 245, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                Get.to(() => SettingPage());
              },
              child: SvgPicture.asset(
                "assets/设置.svg",
                width: 30.w,
                height: 30.h,
              ),
            )
          ],
        ),
        leading: Container(),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(73, 129, 245, 1),
                    Color.fromRGBO(115, 172, 248, 1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: customListTile(
                headerImg,
                nickName,
                "普通会员",
              ),
            ),
            SizedBox(
              height: 30.h,
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Center(
                        child: InkWell(
                          child: Column(
                            children: [
                              Text(
                                projectCount["communication"].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text("沟通中"),
                            ],
                          ),
                          onTap: () {
                            Get.to(() => ReceivedlistPage(), arguments: {
                              'index': 0,
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.to(() => ReceivedlistPage(), arguments: {
                            'index': 1,
                          });
                        },
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                projectCount["Employed"].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text("已录用"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.to(() => ReceivedlistPage(), arguments: {
                            'index': 2,
                          });
                        },
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                projectCount["Delivery"].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text("交付中"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.to(() => ReceivedlistPage(), arguments: {
                            'index': 3,
                          });
                        },
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                projectCount["Ended"].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text("交付成功"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.to(() => ReceivedlistPage(), arguments: {
                            'index': 4,
                          });
                        },
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                projectCount["Closed"].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text("项目关闭"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.to(() => ReceivedlistPage(), arguments: {
                            'index': 5,
                          });
                        },
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                projectCount["Closed"].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text("交付失败"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Container(
              height: 300.h,
              color: Colors.white,
              margin: EdgeInsets.all(10.0.w),
              child: Padding(
                padding: EdgeInsets.all(20.0.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "管理中心",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 30.sp),
                        ),
                      ],
                    ),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                        ),
                        itemCount: gridData.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              String selectedText = gridData[index]['text'];
                              print('选中的功能项：$selectedText');
                              Get.to(() => DemandPage());
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  gridData[index]['icon'],
                                  width: 30.w,
                                  height: 30.h,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  gridData[index]['text'],
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customListTile(String avatarUrl, String nickname, String otherInfo) {
    return GestureDetector(
      onTap: () {
        // 当列表项被点击时执行的操作
        // 可以根据需要添加相应的逻辑
      },
      child: Container(
        padding: EdgeInsets.all(12.0),
        child: Row(
          children: [
            if (avatarUrl != "") ...[
              CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(avatarUrl), // 头像图片的网络地址
              ),
            ],
            SizedBox(width: 12.0), // 调整头像和文本之间的间距
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.0), // 调整昵称和其他信息之间的间距
                Text(
                  otherInfo,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}
