import 'dart:convert';

import 'package:bruno/bruno.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../detail/view.dart';
import '../utils/dio.dart';
import 'logic.dart';

import 'package:bruno/bruno.dart';

class BrnFilterEntity {
  String? key;
  late String name;
  String? defaultValue;
  late List<ItemEntity> children;

  BrnFilterEntity.fromJson(Map<String, dynamic> map) {
    key = map['key'] ?? '';
    name = map['title'] ?? '';
    defaultValue = map['defaultValue'] ?? '';
    children = []..addAll(
        (map['children'] as List? ?? []).map((o) => ItemEntity.fromJson(o)));
  }
}

Color convertColor(int red, int green, int blue) {
  return Color.fromRGBO(red, green, blue, 1.0);
}

class IndexPage extends StatefulWidget {
  IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage>
    with SingleTickerProviderStateMixin {
  final logic = Get.put(IndexLogic());

  final state = Get.find<IndexLogic>().state;

  late EasyRefreshController _controller;
  late EasyRefreshController _controller1;
  Color flutterColor = convertColor(252, 230, 230);
  List<ItemEntity> children = [];

  List<BrnFilterEntity> erlist = [];
  RxList data = <dynamic>[].obs;
  int page = 1;
  int pageSize = 10;
  int total = 0;
  int count = 0;
  int typesOf = 0;
  int devLanguage = 0;
  int proCategory = 0;
  late List<BrnSelectionEntity> rrr = [];

  void Initdata() async {
    var query = {
      'page': 1,
      'pageSize': 10,
      'typesOf': typesOf,
      'devLanguage': devLanguage,
      'proCategory': proCategory
    };
    final res = await HttpUtil().get(
      '/PubPro/getPublishProjectUserList',
      data: query,
    );
    var responseData = res.data; // 获取响应数据
    if (responseData['code'] == 0) {
      if (responseData['data']['total'] != 0) {
        data.value = responseData['data']['list'];
        total = responseData['data']['total'];
        page = 1;
      } else {
        data.value = [];
        total = 0;
        page = 1;
      }
    }
  }

  void Adddata() async {
    var query = {
      'page': page,
      'pageSize': pageSize,
      'typesOf': typesOf,
      'devLanguage': devLanguage,
      'proCategory': proCategory
    };
    final res = await HttpUtil().get(
      '/PubPro/getPublishProjectUserList',
      data: query,
    );
    var responseData = res.data; // 获取响应数据
    if (responseData['code'] == 0) {
      if (data.length != total) {
        data.addAll(responseData['data']['list']);
      }
    }
  }

  void InitFilter() async {
    final res = await HttpUtil().get(
      '/base/FilterData',
    );
    var responseData = res.data; // 获取响应数据
    Map<String, dynamic>? jsonMap = responseData['data'];
    rrr = BrnSelectionEntityListBean.fromJson(jsonMap)!.list!;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Initdata();
    InitFilter();
    _controller = EasyRefreshController();
    _controller1 = EasyRefreshController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller1.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Initdata();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(73, 129, 245, 1),
          elevation: 0.0,
          // backgroundColor: Colors.white,
          leading: Container(),
          title: Row(
            children: [
              TabBar(
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                tabs: [
                  Tab(
                    child: Text(
                      "抢单",
                      style: TextStyle(fontSize: 35.sp), // 设置字体大小为16
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Obx(
          () {
            return TabBarView(
              children: [
                Column(
                  children: <Widget>[
                    BrnSelectionView(
                      originalSelectionData: rrr,
                      onSelectionChanged: (int menuIndex,
                          Map<String, String> filterParams,
                          Map<String, String> customParams,
                          BrnSetCustomSelectionMenuTitle
                              setCustomTitleFunction) {
                        if (filterParams.containsKey('typesOf')) {
                          typesOf = convertToInt(
                            filterParams['typesOf']!,
                          );
                        } else {
                          typesOf = 0;
                        }
                        if (filterParams.containsKey('devLanguage')) {
                          devLanguage = convertToInt(
                            filterParams['devLanguage']!,
                          );
                        } else {
                          devLanguage = 0;
                        }
                        if (filterParams.containsKey('proCategory')) {
                          proCategory = convertToInt(
                            filterParams['proCategory']!,
                          );
                        } else {
                          proCategory = 0;
                        }
                        Initdata();
                      },
                    ),
                    Expanded(
                      child: EasyRefresh(
                        header: const ClassicHeader(
                          dragText: '下拉刷新',
                          armedText: '释放刷新',
                          readyText: '正在刷新...',
                          processingText: '正在刷新...',
                          processedText: '刷新成功',
                          noMoreText: '没有更多数据',
                          failedText: '刷新失败',
                          messageText: '上次更新时间：%T',
                          safeArea: false,
                        ),
                        footer: const ClassicFooter(
                          position: IndicatorPosition.locator,
                          dragText: '上拉加载',
                          armedText: '释放加载',
                          readyText: '正在加载...',
                          processingText: '正在加载...',
                          processedText: '加载成功',
                          noMoreText: '没有更多数据',
                          failedText: '加载失败',
                          messageText: '上次更新时间：%T',
                        ),
                        child: CustomScrollView(
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  // 格式化日期
                                  String dateTimeString =
                                      data[index]['CreatedAt'];
                                  DateTime dateTime =
                                      DateTime.parse(dateTimeString);
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd').format(dateTime);
                                  return InkWell(
                                    child: Container(
                                      padding: EdgeInsets.all(20.0.w),
                                      color: Colors.white,
                                      margin: EdgeInsets.only(top: 10.0.h),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  data[index]["projectName"],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 40.sp,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Text(
                                                "¥${data[index]["budget"]}",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 60.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Container(
                                            child: Row(
                                              children: [
                                                BrnStateTag(
                                                  tagText:
                                                      "${data[index]['lanauage']['languageName'].toString()}开发语言",
                                                  tagState: TagState.succeed,
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                BrnStateTag(
                                                  tagText:
                                                      "${data[index]['category']['categoryName'].toString()}",
                                                  tagState: TagState.succeed,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20.0.h,
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        formattedDate,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                BrnSmallMainButton(
                                                  title: getTitleFromStatusCode(
                                                    data[index]
                                                        ['projectStatus'],
                                                  ),
                                                  onTap: () {
                                                    Get.to(
                                                      () => DetailPage(),
                                                      arguments: {
                                                        "id": data[index]["ID"],
                                                      },
                                                    );
                                                  },
                                                  // maxWidth: 3.w,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Get.to(
                                        () => DetailPage(),
                                        arguments: {
                                          "id": data[index]["ID"],
                                        },
                                      );
                                    },
                                  );
                                },
                                childCount: data.length,
                              ),
                            ),
                            const FooterLocator.sliver(),
                          ],
                        ),
                        onRefresh: () async {
                          await Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) {
                              Initdata();
                            }
                          });
                        },
                        onLoad: () async {
                          await Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) {
                              page = page + 1;
                              Adddata();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
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

  int convertToInt(String numberString) {
    try {
      return int.parse(numberString);
    } catch (e) {
      // 如果无法成功转换为整数，可以根据实际需求决定如何处理异常情况
      // 这里的示例是返回一个默认值，可以根据需要进行修改
      return 0; // 默认值为0
    }
  }
}

// ClipOval(
//   child: Image.network(
//     data[index]
//             ["userModel"]
//         ["headerImg"],
//     fit: BoxFit.cover,
//     width: 30.w,
//     height: 30.h,
//   ),
// ),
// SizedBox(
//   width: 5.0,
// ),
// Text(
//   data[index]["userModel"]
//       ["nickName"],
//   style: TextStyle(
//     fontSize: 30.0.sp,
//   ),
// ),
// 留着头像
