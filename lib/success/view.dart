import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class SuccessPage extends StatelessWidget {
  final logic = Get.put(SuccessLogic());
  final state = Get.find<SuccessLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("恭喜您"),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: Text("项目发布成功"),
      ),
    );
  }
}
