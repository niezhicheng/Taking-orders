import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../success/view.dart';
import '../utils/dio.dart';
import 'logic.dart';

class PostPage extends StatefulWidget {
  PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final logic = Get.put(PostLogic());

  final state = Get.find<PostLogic>().state;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  List imagePaths = [];

  Future<void> _selectImages() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // 执行文件上传
      File file = File(pickedFile.path);
      // Response response = await httpUtil.uploadFile(file);
      final res = await HttpUtil().uploadFile(file);
      if (res.data['code'] == 0) {
        setState(() {
          imagePaths.add({
            'path': pickedFile.path,
            'value': res.data['data']['file']['ID']
          });
        });
      }
    }
  }

  void postArtile() async {
    var data = {
      'title': _titleController.text,
      'context': _contentController.text,
      'figure': imagePaths,
    };
    final res = await HttpUtil().post('/PA/createUserPostArticle', data: data);
    print(res);
    if (res.data['code'] == 0) {
      BrnToast.show("发布成功", context);
      Get.to(() => SuccessPage());
    } else {
      BrnToast.show("发布失败", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "发布帖子",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: "请输入标题", // 输入内容的提示文本
                          filled: true,
                          fillColor: Colors.grey[200], // 输入框背景色
                          border: OutlineInputBorder(
                            // 移除下划线
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 10.0,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入标题';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: "请输入内容", // 输入内容的提示文本
                          filled: true,
                          fillColor: Colors.grey[200], // 输入框背景色
                          border: OutlineInputBorder(
                            // 移除下划线
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 10.0,
                          ),
                        ),
                        maxLines: null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入内容';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: imagePaths.length + 1,
                        itemBuilder: (context, index) {
                          if (index == imagePaths.length) {
                            // 最后一个位置显示加号图标
                            return GestureDetector(
                              onTap: _selectImages,
                              child: Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.add,
                                  size: 40.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          } else {
                            // 显示已选择的图片
                            return Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Image.file(
                                    File(imagePaths[index]['path']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4.0,
                                  right: 4.0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        imagePaths.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.h),
          color: Color.fromRGBO(73, 129, 245, 1),
          height: 70.h,
          child: InkWell(
            onTap: () {
              if (_formKey.currentState!.validate()) {
                // 在这里执行帖子发布的逻辑，例如调用 API 发送数据
                postArtile();
                // 清空输入框和选择的图片
                // _titleController.clear();
                // _contentController.clear();
                // setState(() {
                //   imagePaths = [];
                // });
              }
            },
            child: Center(
              child: Text(
                "发布",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
