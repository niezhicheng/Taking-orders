import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../utils/dio.dart';
import 'logic.dart';

class PersonaldataPage extends StatefulWidget {
  @override
  State<PersonaldataPage> createState() => _PersonaldataPageState();
}

class _PersonaldataPageState extends State<PersonaldataPage> {
  final logic = Get.put(PersonaldataLogic());

  final state = Get.find<PersonaldataLogic>().state;
  TextEditingController nickNameController = TextEditingController();
  var userinfo = {};
  var customerType = 0;
  @override
  void initState() {
    _getUserInfo();
    // TODO: implement initState
    super.initState();
  }

  Future<void> _getUserInfo() async {
    final response = await HttpUtil().get(
      '/user/getUserInfo',
    );
    setState(() {
      userinfo = response.data['data']['userInfo'];
      nickNameController.text = userinfo['nickName'];
      customerType = userinfo['customerType'];
    });
  }

  Future<void> _updateUserInfo() async {
    var data = {
      'nickName': nickNameController.text,
      'customerType': customerType,
    };
    final response = await HttpUtil().post(
      '/user/setSelfUserInfo',
      data: data,
    );
    BrnToast.show(
      response.data['msg'],
      context,
      duration: BrnDuration.long,
    );
    _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          "个人资料",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10.h,
          ),
          BrnTextInputFormItem(
            controller: nickNameController,
            title: "昵称",
            hint: "请输入",
          ),
          SizedBox(
            height: 10.h,
          ),
          BrnRadioInputFormItem(
            title: "用户类型",
            options: [
              "普通用户",
              "淘宝商家",
            ],
            value: userinfo['customerType'] == 2 ? "淘宝商家" : "普通用户",
            onChanged: (oldValue, newValue) {
              if (newValue == '淘宝商家') {
                customerType = 2;
              } else {
                customerType = 1;
              }
            },
          ),
          SizedBox(
            height: 20.h,
          ),
          Container(
            padding: EdgeInsets.all(20.0.w),
            child: BrnBigMainButton(
              title: '更新资料',
              onTap: () {
                _updateUserInfo();
              },
            ),
          )
        ],
      ),
    );
  }
}
