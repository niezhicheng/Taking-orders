import 'dart:async';

import 'package:bruno/bruno.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/utils/apiurl.dart';
import 'package:untitled2/utils/dio.dart';

import '../chat/view.dart';
import '../utils/ws.dart';
import 'logic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailPagePage extends StatefulWidget {
  DetailPagePage({Key? key}) : super(key: key);

  @override
  State<DetailPagePage> createState() => _DetailPagePageState();
}

class _DetailPagePageState extends State<DetailPagePage> {
  final logic = Get.put(DetailPageLogic());
  final webSocketService = Get.find<WebSocketService>();
  final state = Get.find<DetailPageLogic>().state;
  ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int detailid = 0;
  var data = {};
  int commentid = 0;

  List commentlist = [];
  var hintText = "请输入评论的内容";
  void addMention(String username) {
    setState(() {
      hintText = "回复@" + username;
    });
  }

  @override
  void initState() {
    var arguments = Get.arguments;
    if (arguments != null) {
      var id = arguments["id"];
      print("ID: $id");
      detailid = id;
      findArtile(id);
      ListComment(id);
      _scrollController.addListener(_scrollToEnd);
    }
    // TODO: implement initState
    super.initState();
  }

  void findArtile(id) async {
    var parmes = {
      'ID': id,
    };
    final res = await HttpUtil().get('/PA/findPostArticle', data: parmes);
    if (res.data['code'] == 0) {
      setState(() {
        data = res.data['data']['rePA'];
      });
    }
  }

  void ListComment(id) async {
    var parmes = {
      'page': 1,
      'pageSize': 10,
      'post_article_id': id,
    };
    final res = await HttpUtil().get('/Cmt/getUserCommentList', data: parmes);
    if (res.data['code'] == 0) {
      if (res.data['total'] != 0) {
        setState(
          () {
            commentlist = res.data['data']['list'];
          },
        );
      }
    }
  }

  void commentArtile() async {
    var data = {
      'post_article_id': detailid,
      'content': _controller.text,
      'parentId': commentid
    };
    final res = await HttpUtil().post('/Cmt/createUserComment', data: data);
    if (res.data['code'] == 0) {
      BrnToast.show("评论成功", context);
      ListComment(detailid);
      setState(() {
        hintText = "请输入评论的内容";
        _controller.text = "";
        commentid = 0;
      });
      _scrollToEnd();
    } else {
      BrnToast.show("评论失败", context);
    }
  }

  void _scrollToEnd() {
    // 检查滚动位置是否已经到达最底部
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // 执行滚动到最下面的逻辑
      Timer(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.removeListener(_scrollToEnd);
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(73, 129, 245, 1),
        title: Text("帖子详细"),
        actions: [
          TextButton(
            onPressed: () => {
              BrnDialogManager.showMoreButtonDialog(
                context,
                actions: [
                  '屏蔽该动态',
                  '拉黑作者',
                  '举报',
                ],
                title: "在这您可进行相应的操作",
                indexedActionClickCallback: (index) {
                  Navigator.of(context).pop();
                  BrnToast.show("操作成功", context);
                },
              )
            },
            child: const Text(
              "操作",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (data.length == 0) ...[
            CircularProgressIndicator(),
          ] else ...[
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: 10.h,
                        left: 10.w,
                        right: 10.w,
                        bottom: 10.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(80.0), // 设置圆角半径为图片的一半
                                child: CachedNetworkImage(
                                  imageUrl: data['userModel']['headerImg'],
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 70.w,
                                    height: 60.h,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                              SizedBox(
                                width: 20.w,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        data['userModel']['nickName'],
                                        style: TextStyle(
                                          fontSize: 30.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        formatDateTime(data['CreatedAt']),
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          color: Colors.black45,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                          OutlinedButton(
                            onPressed: () {},
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
                            child: const Text('动态'),
                          ),
                        ],
                      ),
                    ),
                    Flex(
                      direction: Axis.vertical,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: 10.w,
                            right: 10.w,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "${data['title']}",
                              style: TextStyle(
                                fontSize: 32.sp,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.vertical,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: 10.w,
                            right: 10.w,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "${data['context']}",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10.w,
                        horizontal: 10.w,
                      ),
                      child: buildImageGrid(),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.w,
                            horizontal: 10.w,
                          ),
                          child: Text(
                            "评论 ${data['comments']}",
                            style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: List.generate(
                        commentlist.length,
                        (index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 10.w,
                              horizontal: 10.w,
                            ),
                            child: buildCommet(index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8.0),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: hintText, // 输入内容的提示文本
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                hintText = "请输入评论的内容";
                                _controller.text = "";
                                commentid = 0;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.blueAccent,
                        ),
                      ),
                      child: const Text('发送'),
                      onPressed: () {
                        commentArtile();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget buildImageGrid() {
    return SingleChildScrollView(
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(), // 禁用内部 GridView 的滚动
        shrinkWrap: true, // 让 GridView 高度适应内容
        crossAxisCount: 3, // 每行显示的图片数量
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1, // 控制图片宽高比例
        children: List.generate(data['figure'].length, (index) {
          return InkWell(
            onTap: () {
              Get.to(
                () => ExtendImags(
                  data['figure'][index]['url'],
                ),
              );
            },
            child: CachedNetworkImage(
              imageUrl: data['figure'][index]['url'],
              imageBuilder: (context, imageProvider) => Container(
                width: double.infinity, // 设置宽度为撑满父容器
                height: double.infinity, // 设置高度为撑满父容器
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          );
        }),
      ),
    );
  }

  Widget buildCommet(index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            customListTile(index),
          ],
        )
      ],
    );
  }

  Widget customListTile(index) {
    return InkWell(
      onTap: () {
        commentid = commentlist[index]['comment']['ID'];
        addMention(commentlist[index]['comment']['userModel']['nickName']);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: Image.network(
                '${commentlist[index]['comment']['userModel']['headerImg']}',
                width: 50.w,
                height: 40.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${commentlist[index]['comment']['userModel']['nickName']}",
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "${commentlist[index]['comment']['content']}",
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Text(
                              formatDateTime(
                                  commentlist[index]['comment']['CreatedAt']),
                              style: TextStyle(
                                fontSize: 22.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (commentlist[index]['comment']['userModel']
                                      ['ID'] ==
                                  webSocketService.userid.value ||
                              data['userModel']['ID'] ==
                                  webSocketService.userid.value) ...[
                            TextButton(
                              onPressed: () {
                                BrnDialogManager.showConfirmDialog(
                                  context,
                                  title: "删除",
                                  cancel: '取消',
                                  confirm: '确定',
                                  message: "您确定删除此评论么。",
                                  onConfirm: () {
                                    Navigator.of(context).pop();
                                    BrnToast.show("确定", context);
                                  },
                                  onCancel: () {
                                    Navigator.of(context).pop();
                                    BrnToast.show("取消", context);
                                  },
                                );
                              },
                              child: Text(
                                "删除",
                              ),
                            ),
                          ],
                          TextButton(
                            onPressed: () {
                              BrnDialogManager.showConfirmDialog(
                                context,
                                title: "举报",
                                cancel: '取消',
                                confirm: '确定',
                                message: "您确定举报此评论么。",
                                onConfirm: () {
                                  BrnToast.show("确定", context);
                                },
                                onCancel: () {
                                  Navigator.of(context).pop();
                                  BrnToast.show("取消", context);
                                },
                              );
                            },
                            child: Text(
                              "举报",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  buildSubComment(index),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget iconNumberButton() {
    int likesCount = 10; // 替换为实际的数字

    return InkWell(
      onTap: () {
        // 处理按钮点击事件
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.thumb_up,
            size: 22.sp,
          ),
          SizedBox(width: 1.w),
          Text(
            '$likesCount',
            style: TextStyle(
              fontSize: 22.sp,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget iconCommentButton() {
    return InkWell(
      onTap: () {
        // 处理按钮点击事件
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.comment,
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
        ],
      ),
    );
  }

  Widget buildSubComment(int i) {
    print("这是${commentlist[i]}");
    return Column(
      children: List.generate(
        commentlist[i]['children'].length,
        (index) {
          return Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Image.network(
                      commentlist[i]['children'][index]['comment']['userModel']
                          ['headerImg'],
                      width: 48.w,
                      height: 38.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commentlist[i]['children'][index]['comment']
                              ['userModel']['nickName'],
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          commentlist[i]['children'][index]['comment']
                              ['content'],
                          style: TextStyle(
                            fontSize: 22.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Text(
                                    "09-09 广东",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Row(
                            //   children: [
                            //     iconCommentButton(),
                            //     iconNumberButton(),
                            //   ],
                            // )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
          return Text(commentlist[i]['children'][index]['comment']['content']);
        },
      ),
    );
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    DateFormat formatter = DateFormat('yyyy年MM月dd日');
    return formatter.format(dateTime);
  }
}
