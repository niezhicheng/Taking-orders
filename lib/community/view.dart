import 'package:bruno/bruno.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/utils/apiurl.dart';

import '../detail_page/view.dart';
import '../utils/dio.dart';
import 'logic.dart';

class CommunityPage extends StatefulWidget {
  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final logic = Get.put(CommunityLogic());

  final state = Get.find<CommunityLogic>().state;
  RxList list = <dynamic>[].obs;
  int page = 1;
  int pageSize = 10;
  int total = 0;

  late int index = 0; //一级分类下标

  void listArtile() async {
    var data = {
      'page': 1,
      'pageSize': 10,
    };
    final res = await HttpUtil().get('/PA/getPostUserArticleList', data: data);
    if (res.data['code'] == 0) {
      list.value = res.data['data']['list'];
    }
  }

  void addArtile() async {
    var data = {
      'page': page,
      'pageSize': pageSize,
    };
    final res = await HttpUtil().get('/PA/getPostUserArticleList', data: data);
    if (res.data['code'] == 0) {
      list.value.addAll(res.data['data']['list']);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listArtile();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
                      "开源导航",
                      style: TextStyle(fontSize: 35.sp), // 设置字体大小为16
                    ),
                  ),
                  Tab(
                    child: Text(
                      "讨论社区",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 150.h),
                        color: Colors.white12,
                        child: ListView.builder(
                          itemCount: state.sourceCategory.length,
                          itemBuilder: (BuildContext context, int position) {
                            return getRow(position);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(bottom: 150.h),
                        child: ListView.builder(
                          itemCount: state.opSource.value.length,
                          itemBuilder: (BuildContext context, int index) {
                            List<String> tags =
                                state.opSource.value[index]['label'].split(',');
                            return Column(
                              children: [
                                ListTile(
                                    title: Text(
                                        state.opSource.value[index]['title']),
                                    subtitle: Text(
                                      state.opSource.value[index]['describe'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                    // trailing: Text("trailing"),
                                    leading: CachedNetworkImage(
                                      imageUrl: state.opSource.value[index]
                                          ['icon'],
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 120.w, // 设置宽度为撑满父容器
                                        height: 70.h, // 设置高度为撑满父容器
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )

                                    // leading: ClipOval(
                                    //   child: Image.network(
                                    //     state.opSource.value[index]['icon'],
                                    //     fit: BoxFit.cover,
                                    //   ),
                                    // ),
                                    ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   children: [
                                //     SizedBox(
                                //       width: 20.w,
                                //     ),
                                //     Text("项目标签:"),
                                //     SizedBox(
                                //       width: 20.w,
                                //     ),
                                //     Row(
                                //       children:
                                //           tags.asMap().entries.map((entry) {
                                //         int index = entry.key;
                                //         String tag = entry.value;
                                //         return Row(
                                //           children: [
                                //             BrnStateTag(
                                //               tagText: tag,
                                //               tagState: TagState.succeed,
                                //             ),
                                //             SizedBox(
                                //                 width: index < tags.length - 1
                                //                     ? 10.w
                                //                     : 0), // 最后一个标签后面不添加间距
                                //           ],
                                //         );
                                //       }).toList(),
                                //     ),
                                //   ],
                                // ),
                                Container(
                                  constraints:
                                      BoxConstraints(maxWidth: 550.w), // 设置最大宽度
                                  child: Row(
                                    children: [
                                      SizedBox(width: 20.w),
                                      Text("项目标签:"),
                                      SizedBox(width: 20.w),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: tags
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              int index = entry.key;
                                              String tag = entry.value;
                                              return Row(
                                                children: [
                                                  BrnStateTag(
                                                    tagText: tag,
                                                    tagState: TagState.succeed,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        index < tags.length - 1
                                                            ? 10.w
                                                            : 0,
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(bottom: 30.h)),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
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
                                  String formattedDate =
                                      formatDateTime(list[index]['CreatedAt']);
                                  return InkWell(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                            top: 10.h,
                                            left: 10.w,
                                            right: 10.w,
                                            bottom: 10.h,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      80.0,
                                                    ), // 设置圆角半径为图片的一半
                                                    child: CachedNetworkImage(
                                                      imageUrl: list[index]
                                                              ['userModel']
                                                          ['headerImg'],
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        width: 70.w,
                                                        height: 60.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      progressIndicatorBuilder: (context,
                                                              url,
                                                              downloadProgress) =>
                                                          CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 20.w,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "${list[index]['userModel']['nickName']}",
                                                            style: TextStyle(
                                                              fontSize: 30.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            formattedDate,
                                                            style: TextStyle(
                                                              fontSize: 20.sp,
                                                              color: Colors
                                                                  .black45,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
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
                                                  backgroundColor:
                                                      const Color.fromRGBO(
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
                                                  "${list[index]['title']}",
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: 10.w,
                                            right: 10.w,
                                            top: 10.h,
                                          ),
                                          child: buildImageGrid(index),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10.h,
                                            horizontal: 10.w,
                                          ),
                                          child: buildPostFooter(index),
                                        )
                                      ],
                                    ),
                                    onTap: () {
                                      Get.to(() => DetailPagePage(),
                                          arguments: {
                                            "id": list[index]['ID'],
                                          });
                                    },
                                  );
                                },
                                childCount: list.length,
                              ),
                            ),
                            const FooterLocator.sliver(),
                          ],
                        ),
                        onRefresh: () async {
                          await Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) {
                              listArtile();
                            }
                          });
                        },
                        onLoad: () async {
                          await Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) {
                              page = page + 1;
                              addArtile();
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

  Widget buildImageGrid(index) {
    int length = list[index]['figure'].length;

    if (length <= 0) {
      // 当长度小于等于 0 时，返回一个空容器或者其他你希望显示的小部件
      return Container();
    }
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 3,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
        children: List.generate(
          length,
          (i) {
            return CachedNetworkImage(
              imageUrl: list[index]['figure'][i]['url'],
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
            );
          },
        ),
      ),
    );
  }

  Widget buildPostFooter(index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Row(
        //   children: [
        //     Icon(Icons.share),
        //     SizedBox(
        //       width: 20.w,
        //     ),
        //     Text('${list[index]['forward']}'), // 显示点赞数
        //   ],
        // ),
        // Row(
        //   children: [
        //     Icon(Icons.thumb_up),
        //     SizedBox(
        //       width: 20.w,
        //     ),
        //     Text('${list[index]['like']}'), // 显示点赞数
        //   ],
        // ),
        Row(
          children: [
            SvgPicture.asset(
              "assets/浏览.svg",
              width: 40.w,
              height: 40.h,
            ),
            SizedBox(
              width: 20.w,
            ),
            Text('${list[index]['browse']}'), // 显示点赞数
          ],
        ),
        Row(
          children: [
            SvgPicture.asset(
              "assets/评论.svg",
              width: 30.w,
              height: 30.h,
            ),
            SizedBox(
              width: 20.w,
            ),
            Text('${list[index]['comments']}'), // 显示点赞数
          ],
        )
      ],
    );
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    DateFormat formatter = DateFormat('yyyy年MM月dd日');
    return formatter.format(dateTime);
  }

  Widget getRow(int i) {
    Color textColor = Theme.of(context).primaryColor; //字体颜色
    return GestureDetector(
      child: Container(
        // height: 80.h,
        alignment: Alignment.center,
        // padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        //Container下的color属性会与decoration下的border属性冲突，所以要用decoration下的color属性
        decoration: BoxDecoration(
          color: index == i ? Colors.white : Colors.white12,
          border: Border(
            left: BorderSide(
              width: 5,
              color: index == i ? Colors.blueAccent : Colors.white,
            ),
          ),
        ),
        child: Text(
          state.sourceCategory[i]['categoryName'],
          style: TextStyle(
            color: index == i ? Color.fromRGBO(73, 129, 245, 1) : Colors.black,
            fontWeight: index == i ? FontWeight.w600 : FontWeight.w400,
            fontSize: 16,
          ),
        ),
      ),
      onTap: () {
        setState(() {
          index = i; //记录选中的下标
          textColor = Color.fromRGBO(73, 129, 245, 1);
          print("这是打印出来的id${index}");
          logic.initOpSource(state.sourceCategory[index]['ID']);
        });
      },
    );
  }
}
