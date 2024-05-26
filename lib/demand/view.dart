import 'package:bruno/bruno.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../utils/dio.dart';
import 'logic.dart';

class DemandPage extends StatefulWidget {
  DemandPage({Key? key}) : super(key: key);

  @override
  State<DemandPage> createState() => _DemandPageState();
}

class _DemandPageState extends State<DemandPage> {
  final logic = Get.put(DemandLogic());

  final state = Get.find<DemandLogic>().state;

  int page = 1;

  int pageSize = 10;

  List<dynamic> list = [];
  late int _index;

  @override
  void initState() {
    _getPubProRecUserList();

    // TODO: implement initState
    super.initState();
  }

  Future<void> _getPubProRecUserList() async {
    var data = {'page': 1, 'pageSize': pageSize};
    final response = await HttpUtil().get(
      '/PubPro/ProjectRecUserList',
      data: data,
    );
    setState(() {
      list = response.data['data']['list'];
    });
  }

  Future<void> _addPubProRecUserList() async {
    var data = {'page': page, 'pageSize': pageSize};
    final response = await HttpUtil().get(
      '/PubPro/ProjectRecUserList',
      data: data,
    );
    setState(() {
      list.addAll(response.data['data']['list']);
    });
  }

  Future<void> _CancelDemandProject(int id) async {
    var data = {'ID': id};
    final response = await HttpUtil().post(
      '/PubPro/CancelDemandProject',
      data: data,
    );
    if (response.data['code'] == 0) {
      BrnToast.show(response.data['msg'], context);
    } else {
      BrnToast.show(response.data['msg'], context);
    }
    _getPubProRecUserList();
  }

  Future<void> _RecruitingAgainProject(int id) async {
    var data = {'ID': id};
    final response = await HttpUtil().post(
      '/PubPro/RecruitingAgainProject',
      data: data,
    );
    if (response.data['code'] == 0) {
      BrnToast.show(response.data['msg'], context);
    } else {
      BrnToast.show(response.data['msg'], context);
    }
    _getPubProRecUserList();
  }

  Future<void> _ProjectCompletionProject(int id) async {
    var data = {'ID': id};
    final response = await HttpUtil().post(
      '/PubPro/ProjectCompletionProject',
      data: data,
    );
    if (response.data['code'] == 0) {
      BrnToast.show(response.data['msg'], context);
    } else {
      BrnToast.show(response.data['msg'], context);
    }
    _getPubProRecUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "发布管理",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
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
                        return Container(
                          color: Colors.white,
                          child: buildItem(context, index),
                        );
                      },
                      childCount: list.length,
                    ),
                  ),
                  const FooterLocator.sliver(),
                ],
              ),
              onRefresh: () async {
                await Future.delayed(
                  const Duration(seconds: 2),
                  () {
                    if (mounted) {
                      page = 1;
                      _getPubProRecUserList();
                    }
                  },
                );
              },
              onLoad: () async {
                await Future.delayed(
                  const Duration(seconds: 2),
                  () {
                    if (mounted) {
                      page = page + 1;
                      _addPubProRecUserList();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  list[index]['projectName'],
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  list[index]['description'],
                  style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          BrnStateTag(
            tagText: getStatusText(list[index]['projectStatus']),
            tagState: TagState.failed,
          ),
          BrnVerticalIconButton(
            name: '操作',
            iconWidget: Icon(Icons.more),
            onTap: () {
              BrnDialogManager.showMoreButtonDialog(
                context,
                actions: [
                  '取消需求',
                  '重新招募技术',
                  '项目完成',
                ],
                title: "对此需求进行操作",
                indexedActionClickCallback: (indexx) {
                  print(indexx);
                  switch (indexx) {
                    case 0:
                      _CancelDemandProject(list[index]['ID']);
                      break;
                    case 1:
                      _RecruitingAgainProject(list[index]['ID']);
                      break;

                    case 2:
                      _ProjectCompletionProject(list[index]['ID']);
                      break;
                  }
                },
              );
            },
          ),
        ],
      ),
    );
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
