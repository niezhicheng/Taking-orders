import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../detail/view.dart';
import '../utils/dio.dart';
import 'logic.dart';

class ReceivedlistPage extends StatefulWidget {
  @override
  State<ReceivedlistPage> createState() => _ReceivedlistPageState();
}

class _ReceivedlistPageState extends State<ReceivedlistPage>
    with SingleTickerProviderStateMixin {
  final logic = Get.put(ReceivedlistLogic());

  final state = Get.find<ReceivedlistLogic>().state;
  List<BadgeTab> tabs = [];
  late TabController tabController;
  int tabindex = 0;
  int page = 1;
  int pageSize = 10;
  List<dynamic> list = [];

  @override
  void initState() {
    tabindex = Get.arguments['index'];
    tabs.add(BadgeTab(text: "沟通中"));
    tabs.add(BadgeTab(text: "已录用"));
    tabs.add(BadgeTab(text: "交付中"));
    tabs.add(BadgeTab(text: "交付成功"));
    tabs.add(BadgeTab(text: "项目关闭"));
    tabs.add(BadgeTab(text: "交付失败"));
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.index = tabindex;
    _getPubProRecList();
    // TODO: implement initState
    super.initState();
  }

  Future<void> _getPubProRecList() async {
    var data = {
      'projectStatus': tabindex + 2,
      'page': page,
      'pageSize': pageSize
    };
    final response = await HttpUtil().get(
      '/PubPro/ProjectRecList',
      data: data,
    );
    setState(() {
      list = response.data['data']['list'];
    });
  }

  // 退单
  void _chargeback(BuildContext context, int id) async {
    var data = {
      'ID': id,
    };
    final response = await HttpUtil().post(
      '/PubPro/ProjectChargebackProject',
      data: data,
    );
    // ignore: use_build_context_synchronously
    BrnToast.show(response.data['msg'], context);
    // ignore: use_build_context_synchronously
    Navigator.pop(context); // 关闭对话框
    _getPubProRecList();
  }

  // 交付
  void deliver(BuildContext context, int id) async {
    var data = {
      'ID': id,
    };
    final response = await HttpUtil().post(
      '/PubPro/ProjectDeliverProject',
      data: data,
    );
    // ignore: use_build_context_synchronously
    BrnToast.show(response.data['msg'], context);
    // ignore: use_build_context_synchronously
    Navigator.pop(context); // 关闭对话框
    _getPubProRecList();
  }

  @override
  void dispose() {
    tabController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          "接单列表",
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
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          BrnTabBar(
            controller: tabController,
            tabs: tabs,
            onTap: (state, index) {
              state.refreshBadgeState(index);
              setState(() {
                tabindex = index;
              });
              _getPubProRecList();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length, // 列表项的数量
              itemBuilder: (BuildContext context, int index) {
                // 构建每个列表项
                return InkWell(
                  onTap: () {
                    Get.to(
                      () => DetailPage(),
                      arguments: {
                        "id": list[index]["ID"],
                      },
                    );
                  },
                  child: Container(
                    height: 100.0.h,
                    width: double.infinity,
                    color: Colors.white,
                    margin: EdgeInsets.all(10.0.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20.h,
                            ),
                            Container(
                              width: 500.w,
                              child: Text(
                                list[index]['projectName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32.0.sp,
                                ),
                              ),
                            ),
                            Container(
                              width: 500.w,
                              child: Text(
                                list[index]['description'],
                                style: TextStyle(
                                  fontSize: 24.0.sp,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1, // 设置最大行数
                              ),
                            ),
                          ],
                        ),
                        BottomStatus(index),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget BottomStatus(int index) {
    var text = "";

    if (list[index]['projectStatus'] == 2) {
      text = '退单';
    } else if (list[index]['projectStatus'] == 3) {
      text = '交付';
    } else if (list[index]['projectStatus'] == 4) {
      text = '交付中';
    } else if (list[index]['projectStatus'] == 5) {
      text = '交付成功';
    } else if (list[index]['projectStatus'] == 6) {
      text = '项目关闭';
    } else if (list[index]['projectStatus'] == 7) {
      text = '交付失败';
    } else {
      text = '';
    }
    return OutlinedButton(
      onPressed: () {
        print(list[index]['projectStatus']);

        BrnDialogManager.showConfirmDialog(
          context,
          title: "是否确认退单",
          confirm: "确定",
          cancel: "取消",
          message: "请不要随意退单 请谈不妥的时候在进行退单处理",
          onCancel: () {
            BrnToast.show("取消操作", context);
            Navigator.pop(context); // 关闭对话框
          },
          onConfirm: () {
            if (list[index]['projectStatus'] == 2) {
              _chargeback(context, list[index]['ID']);
            }
            if (list[index]['projectStatus'] == 3) {
              deliver(context, list[index]['ID']);
            }
          },
        );
      },
      style: OutlinedButton.styleFrom(
        /// 关于按钮样式请参见 lib/widget/button/text_button.dart 中的说明
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromRGBO(
          73,
          129,
          245,
          1,
        ),
        side: const BorderSide(
          ///   按钮边框的大小和颜色
          width: 1,
          color: Colors.white,
        ),
        shape: const StadiumBorder(),

        ///   按钮的边框的样式（注：按钮边框的大小和颜色请在 style 的 side 中设置）
      ),
      child: Text(text),
    );
  }
}
