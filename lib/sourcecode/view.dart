import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class SourcecodePage extends StatelessWidget {
  final logic = Get.put(SourcecodeLogic());
  final state = Get.find<SourcecodeLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("消息列表"),
        backgroundColor: Color.fromRGBO(73, 129, 245, 1),
        leading: Container(),
        elevation: 0.0,
      ),
    );
  }
}
