import 'package:flutter/material.dart';

class TabIconData {
  TabIconData({
    this.name = 'name',
    this.imagePath = Icons.error,
    this.index = 0,
    this.isSelected = false,
    this.animationController,
  });

  IconData imagePath;
  bool isSelected;
  int index;
  String name;

  /// icon 动画
  AnimationController? animationController;

  static List<TabIconData> tabIconsList = <TabIconData>[
    TabIconData(
      name: '首页',
      imagePath: Icons.home,
      index: 0,
      isSelected: true,
      animationController: null,
    ),
    TabIconData(
      name: '社区',
      imagePath: Icons.local_fire_department,
      index: 1,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      name: '消息',
      imagePath: Icons.add_alert_sharp,
      index: 2,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      name: '我的',
      imagePath: Icons.person,
      index: 3,
      isSelected: false,
      animationController: null,
    ),
  ];
}
