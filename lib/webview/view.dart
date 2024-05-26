import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'logic.dart';

class WebviewPage extends StatefulWidget {
  final String url;
  final String title;

  WebviewPage({required this.url, required this.title});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  final logic = Get.put(WebviewLogic());
  final state = Get.find<WebviewLogic>().state;
  double height = 0;
  late Uri _url;

  @override
  void initState() {
    super.initState();
    _url = Uri.parse(widget.url);
    _launchUrl();
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 返回上一个页面
          },
        ),
      ),
    );
  }
}
