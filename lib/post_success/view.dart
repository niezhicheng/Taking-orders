import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class PostSuccessPage extends StatelessWidget {
  PostSuccessPage({Key? key}) : super(key: key);

  final logic = Get.put(PostSuccessLogic());
  final state = Get.find<PostSuccessLogic>().state;

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
        child: Text("帖子发布成功"),
      ),
    );
  }
}
