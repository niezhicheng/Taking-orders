import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bottom3/bottom_bar_3.dart';
import '../bottom3/tabIcon_data.dart';
import '../center/view.dart';
import '../community/view.dart';
import '../index/view.dart';
import '../mesagelist/view.dart';
import '../publish/view.dart';
import '../sourcecode/view.dart';
import 'logic.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final logic = Get.put(HomeLogic());

  final state = Get.find<HomeLogic>().state;
  final List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  int currentIndex = 0;
  List _pageList = [
    IndexPage(),
    CommunityPage(),
    MesagelistPage(),
    CenterPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pageList[currentIndex],
          bottomBar(),
        ],
      ),
    );
  }

  Widget bottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: BottomBar3(
        tabIconsList: tabIconsList,
        changeIndex: (index) => onClickBottomBar(index),
        addClick: () {
          debugPrint('点击了中间的按钮');
        },
      ),
    );
  }

  void onClickBottomBar(int index) {
    if (!mounted) return;

    debugPrint('longer   点击了 >>> $index');
    setState(() => currentIndex = index);
    if (currentIndex == "发布项目") {
      print("逻辑走这边");
      Get.to(() => PublishPage());
    }
  }
}
