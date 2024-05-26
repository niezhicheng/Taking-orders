import 'package:bruno/bruno.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:untitled2/chat/view.dart';

import '../utils/apiurl.dart';
import '../utils/dio.dart';
import '../utils/ws.dart';
import 'logic.dart';

class DetailPage extends StatefulWidget {
  DetailPage({Key? key}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final logic = Get.put(DetailLogic());

  final state = Get.find<DetailLogic>().state;
  final webSocketService = Get.find<WebSocketService>();

  Map<String, dynamic> data = {};
  Map<String, dynamic> userModel = {};
  var category = "";
  var lanauage = "";
  List datas = [];
  var id = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = Get.arguments["id"];
    print(id);
    Initdata(id);
  }

  void Initdata(int id) async {
    var query = {
      "ID": id,
    };
    final res = await HttpUtil().get(
      '/PubPro/findUserPublishProject',
      data: query,
    );
    var responseData = res.data; // 获取响应数据
    if (responseData['code'] == 0) {
      setState(() {
        data = responseData['data']['rePubPro'];
        category = data['category']['categoryName'];
        lanauage = data["lanauage"]["languageName"];
        datas = data["attachmentImage"];
        userModel = data["userModel"];
      });
    }
  }

  Future<void> seizeOrdersProjectPush() async {
    var data = {
      'ID': id,
    };
    final response = await HttpUtil().post(
      '/PubPro/seizeOrdersPublishProject',
      data: data,
    );
    BrnToast.show(
      response.data['msg'],
      context,
      duration: BrnDuration.long,
    );
    Initdata(id);
  }

  Widget displayOption(int option) {
    Widget optionWidget;

    switch (option) {
      case 1:
        optionWidget = Text(
          '抢单',
          style: TextStyle(fontWeight: FontWeight.w500),
        );
        break;
      case 2:
        optionWidget = Text(
          '竞标',
          style: TextStyle(fontWeight: FontWeight.w500),
        );
        break;
      case 3:
        optionWidget = Text(
          '驻场开发',
          style: TextStyle(fontWeight: FontWeight.w500),
        );
        break;
      case 4:
        optionWidget = Text(
          '远程开发',
          style: TextStyle(fontWeight: FontWeight.w500),
        );
        break;
      default:
        optionWidget = Text(
          '未知选项',
          style: TextStyle(fontWeight: FontWeight.w500),
        );
    }

    return optionWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("项目详情"),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Color.fromRGBO(73, 129, 245, 1),
        elevation: 0.0,
        actions: [
          TextButton(
            onPressed: () => {
              BrnMiddleInputDialog(
                title: '是否要举报该项目',
                message: "如果涉嫌恐怖,谩骂或者其他的违法行为都可进行举报 ",
                hintText: '请输入举报的内容',
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
              "举报",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 40.h),
              height: 800,
              width: double.infinity,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 30.w, right: 30.w),
                    child: Text(
                      data["projectName"] ?? "",
                      style: TextStyle(
                        fontSize: 60.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30.w, right: 30.w),
                    child: Row(
                      children: [
                        Text(
                          category ?? "",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          lanauage ?? "",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${data["devCycle"] ?? ""}天",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        displayOption(data["projectMode"] ?? 0)
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                    ),
                    child: Row(
                      children: [],
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text(
                      "项目描述",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data["description"] ?? ""),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text(
                      "附件图片",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: GridView.count(
                      crossAxisCount: 3, // 每行显示的图片数量
                      shrinkWrap: true, // 让网格布局适应内容的大小
                      physics: NeverScrollableScrollPhysics(), // 禁用滚动
                      children: List.generate(
                        datas.length,
                        (itemIndex) {
                          if (itemIndex < datas.length) {
                            return Padding(
                                padding: EdgeInsets.only(right: 5.0, top: 5.0),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(
                                      () => ExtendImags(
                                        datas[itemIndex]['url'],
                                      ),
                                    );
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: datas[itemIndex]['url'],
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      width: double.infinity, // 设置宽度为撑满父容器
                                      height: double.infinity, // 设置高度为撑满父容器
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ));
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: userModel["headerImg"] ??
                                "https://qmplusimg.henrongyi.top/gva_header.jpg",
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                        title: Text(
                          userModel["nickName"] ?? "",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: userModel['customerType'] == 2
                            ? Row(
                                children: [
                                  BrnStateTag(
                                    tagText: '淘宝商家',
                                    tagState: TagState.failed,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  BrnStateTag(
                                    tagText: '普通用户',
                                    tagState: TagState.failed,
                                  ),
                                ],
                              ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70.h,
        margin: EdgeInsets.all(25.0),
        child: (data['receiver'] == webSocketService.userid.value)
            ? BrnBigMainButton(
                title: "沟通",
                bgColor: Color(0xFFFA3F3F),
                isEnable: true,
                onTap: () {
                  if (data["userid"] == webSocketService.userid.value) {
                    Get.snackbar(
                      '提示',
                      '不能和自己沟通',
                      snackPosition: SnackPosition.BOTTOM,
                      margin: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      backgroundColor: Colors.grey[800],
                      colorText: Colors.white,
                    );
                    return;
                  }
                  Get.to(
                    () => ChatPage(),
                    arguments: {
                      'receiver': data["userid"],
                      'sender': webSocketService.userid.value
                    },
                  );
                },
              )
            : ((data['projectStatus'] == 1)
                ? BrnBigMainButton(
                    title: "抢单",
                    isEnable: true,
                    onTap: () {
                      if (data["userid"] == webSocketService.userid.value) {
                        Get.snackbar(
                          '提示',
                          '不能抢自己单',
                          snackPosition: SnackPosition.BOTTOM,
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 30,
                          ),
                          backgroundColor: Colors.grey[800],
                          colorText: Colors.white,
                        );
                        return;
                      }
                      seizeOrdersProjectPush();
                    },
                  )
                : BrnBigMainButton(
                    title: getTitleFromStatusCode(data['projectStatus'] ?? 1),
                    isEnable: false,
                    onTap: () {},
                  )),
      ),
    );
  }

  String getTitleFromStatusCode(int statusCode) {
    String title;
    switch (statusCode) {
      case 1:
        title = '抢单';
        break;
      case 2:
        title = '沟通中';
        break;
      case 3:
        title = '已录用';
        break;
      case 4:
        title = '交付中';
        break;
      case 5:
        title = '已结束';
        break;
      case 6:
        title = '项目关闭';
        break;
      default:
        title = '未知状态';
        break;
    }
    return title;
  }
}
