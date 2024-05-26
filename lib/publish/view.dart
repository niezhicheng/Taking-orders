import 'package:bottom_picker/bottom_picker.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' hide Response;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../success/view.dart';
import 'logic.dart';
import '../utils/dio.dart';

class ProjectMode {
  final int id;
  final String value;

  ProjectMode(this.id, this.value);
}

class PublishPage extends StatefulWidget {
  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final logic = Get.put(PublishLogic());

  final state = Get.find<PublishLogic>().state;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _pproCategoryController = TextEditingController();
  final TextEditingController _projectModeController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController(); //预算
  final TextEditingController _devCycleController =
      TextEditingController(); //开发周期
  final TextEditingController _devlanguageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  double _textFieldHeight = 50.0.h; // 初始高度
  List images = [];
  int? _selectedProCategory;
  int? _selectedProjectMode;
  int? _selectedDevLanguage;
  int? _selectedProjectStatus;
  int? _selectedFundingStatus;
  int? _selectedReceiver;

  double? _budget = 0.0;
  double? _escrowAmount;
  double? _projectQuotation;
  List imagePaths = [];
  List Category = [];
  List Devlang = [];
  bool _isLoading = false;
  final RxBool isTrue = true.obs;
  @override
  void initState() {
    _getListCategory();
    _getListDevlang();
    super.initState();
  }

  Future<void> _getListCategory() async {
    final response = await HttpUtil().get(
      '/ProCategory/getProjectCategoryListAll',
    );
    setState(() {
      Category = response.data['data']['list'];
    });
  }

  Future<void> _getListDevlang() async {
    final response = await HttpUtil().get(
      '/Dla/getDevlangListAll',
    );
    setState(() {
      Devlang = response.data['data']['list'];
    });
  }

  Future<void> _postProjectPush() async {
    if (_isLoading) {
      return; // 如果正在加载，则不执行任何操作
    }
    var data = {
      'ProjectName': _projectNameController.text,
      'ProCategory': _selectedProCategory,
      'ProjectMode': _selectedProjectMode,
      'Budget': double.tryParse(_budgetController.text),
      'DevLanguage': _selectedDevLanguage,
      'DevCycle': _devCycleController.text,
      'Description': _descriptionController.text,
      "AttachmentImage": imagePaths,
    };
    final response = await HttpUtil().post(
      '/PubPro/createPublishProjectUser',
      data: data,
    );
    setState(() {
      _isLoading = true; // 显示加载状态指示器
    });
    if (response.data['code'] == 0) {
      _showErrorDialog("());发布项目成功");
      Get.to(() => SuccessPage());
    } else {
      _showErrorDialog("发布项目失败" + response.data['msg']);
    }
    // 执行耗时操作
    setState(() {
      _isLoading = false; // 隐藏加载状态指示器
    });
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
        title: Text(
          "发布项目",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20.h),
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.only(left: 40.0.w, right: 40.w),
                  child: TextFormField(
                    controller: _projectNameController,
                    decoration: InputDecoration(
                      hintText: '项目名称',
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black12), // 设置下划线的颜色
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter project name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.h),
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.only(left: 40.0.w, right: 40.w),
                  child: TextFormField(
                    onTap: () {
                      BottomPick(context);
                    },
                    readOnly: true, // 设置为只读
                    controller: _pproCategoryController,
                    decoration: InputDecoration(
                      hintText: '项目分类',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ), // 设置下划线的颜色
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter project name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.h),
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.only(left: 40.0.w, right: 40.w),
                  child: TextFormField(
                    onTap: () {
                      BottomPickProjectModel(context);
                    },
                    readOnly: true, // 设置为只读
                    controller: _projectModeController,
                    decoration: InputDecoration(
                      hintText: '合作模式',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ), // 设置下划线的颜色
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter project name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              BrnRadioInputFormItem(
                isRequire: true,
                title: "预算价格",
                options: [
                  "无预算",
                  "有预算",
                ],
                value: "有预算",
                enableList: [true, true],
                onTip: () {
                  BrnToast.show("点击触发onTip回调", context);
                },
                // onAddTap: () {
                //   BrnToast.show("点击触发onAddTap回调", context);
                // },
                // onRemoveTap: () {
                //   BrnToast.show("点击触发onRemoveTap回调", context);
                // },
                onChanged: (oldValue, newValue) {
                  if (newValue == "有预算") {
                    isTrue.value = true;
                  } else {
                    isTrue.value = false;
                    _budget = 0.0;
                  }
                },
              ),
              Obx(
                () => isTrue.value
                    ? Container(
                        margin: EdgeInsets.only(top: 20.h),
                        color: Colors.white,
                        child: Container(
                          margin: EdgeInsets.only(left: 40.0.w, right: 40.w),
                          child: TextFormField(
                            controller: _budgetController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ), //
                            decoration: InputDecoration(
                              hintText: '预算',
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black12,
                                ), // 设置下划线的颜色
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black12,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _budget = double.tryParse(value);
                              });
                            },
                          ),
                        ),
                      )
                    : Container(),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.h),
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.only(left: 40.0.w, right: 40.w),
                  child: TextFormField(
                    controller: _devlanguageController,
                    onTap: () {
                      BottomPickLanage(context);
                    },
                    readOnly: true, // 设置为只读
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: '开发语言',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ), // 设置下划线的颜色
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.h),
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.only(left: 40.0.w, right: 40.w),
                  child: TextFormField(
                    maxLines: null, // Allow multiple lines of text
                    keyboardType: TextInputType.number,
                    controller: _devCycleController,
                    decoration: InputDecoration(
                      hintText: '开发周期',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ), // 设置下划线的颜色
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter development cycle';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.h),
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.only(left: 40.0.w, right: 40.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("附件图片"),
                    ],
                  ),
                ),
              ),
              Container(
                // margin: EdgeInsets.only(top: 20.h),
                color: Colors.white,
                child: Container(
                  margin: EdgeInsets.only(left: 40.0.w, right: 40.w),
                  alignment: Alignment.centerLeft, // 从左边对齐
                  child: buildGridView(),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.h),
                color: Colors.white,
                child: Container(
                  height: 200.h,
                  margin: EdgeInsets.only(
                    left: 40.0.w,
                    right: 40.w,
                    bottom: 20.h,
                  ),
                  child: TextFormField(
                    expands: true,
                    controller: _descriptionController,
                    maxLines: null, // 允许多行文本输入
                    keyboardType: TextInputType.multiline,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: '描述',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ), // 设置下划线的颜色
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                      ),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 880.0.h),
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.all(20.0),
        child: Container(
          color: Colors.deepOrange,
          height: 70.h,
          width: MediaQuery.of(context).size.width,
          child: TextButton(
            child: Text(
              "提交",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _postProjectPush();
            },
          ),
        ),
      ),
    );
  }

  Future<void> pickImage() async {
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

  Widget buildGridView() {
    final itemCount = imagePaths.length;
    if (itemCount >= 9) {
      // 如果图像数量大于等于9，则不显示加号图标的容器
      return Wrap(
        spacing: 8.0.w, // 子部件之间的水平间距
        runSpacing: 8.0.h, // 子部件之间的垂直间距
        children: List.generate(
          itemCount,
          (index) => Container(
            width: 200.w, // 每个子部件的宽度
            height: 150.h, // 每个子部件的高度
            color: Colors.grey[200],
            child: Image.file(
              File(imagePaths[index]), // 使用已选中图像的文件路径
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      // 如果图像数量小于9，则显示加号图标的容器
      return Wrap(
        spacing: 8.0.w, // 子部件之间的水平间距
        runSpacing: 8.0.h, // 子部件之间的垂直间距
        children: [
          ...List.generate(itemCount,
              (index) => buildImageWithDeleteButton(imagePaths[index], index)),
          InkWell(
            onTap: () {
              pickImage();
            },
            child: Container(
              width: 200.w, // 每个子部件的宽度
              height: 150.h, // 每个子部件的高度
              color: Colors.grey[200],
              child: Icon(
                Icons.add,
                size: 50,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget buildImageWithDeleteButton(dynamic imagePath, int index) {
    return Stack(
      children: [
        Container(
          width: 200.w, // 每个子部件的宽度
          height: 150.h, // 每个子部件的高度
          color: Colors.grey[200],
          child: Image.file(
            File(imagePath['path']), // 使用已选中图像的文件路径
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4.0, // 删除按钮距离顶部的偏移量
          right: 4.0, // 删除按钮距离右侧的偏移量
          child: InkWell(
            onTap: () {
              setState(() {
                imagePaths.removeAt(index); // 从图像路径列表中移除指定索引的图像路径
              });
              // 处理删除按钮点击事件
              // 可以在这里移除图像路径
            },
            child: Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void BottomPick(BuildContext context) {
    String initialCategory = '';
    if (_pproCategoryController.text != '') {
      initialCategory = _pproCategoryController.text;
    }

    int initialIndex =
        Category.indexWhere((item) => item['categoryName'] == initialCategory);
    if (initialIndex == -1) {
      initialIndex = 0; // 或者选择其他合适的默认索引
    }

    BottomPicker(
      items: Category.map((item) => Text(item['categoryName'])).toList(),
      selectedItemIndex: initialIndex,
      title: '请选择项目类型',
      pickerTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      onChange: (val) {
        setState(() {
          String selectedCategory = Category[val]['categoryName'];
          _selectedProCategory = Category[val]['ID'];
          _pproCategoryController.text = selectedCategory;
        });
      },
      onSubmit: (val) {
        setState(() {
          String selectedCategory = Category[val]['categoryName'];
          _selectedProCategory = Category[val]['ID'];
          _pproCategoryController.text = selectedCategory;
        });
      },
    ).show(context);
  }

  void BottomPickProjectModel(BuildContext context) {
    final List<ProjectMode> modes = [
      ProjectMode(1, '抢单'),
      ProjectMode(2, '竞标'),
      ProjectMode(3, '驻场开发'),
      ProjectMode(4, '远程开发'),
    ];

    int initialIndex = 0;
    if (_projectModeController.text != '') {
      String selectedValue = _projectModeController.text;
      ProjectMode? mode = modes.firstWhere((m) => m.value == selectedValue,
          orElse: () => modes[0]);
      initialIndex = modes.indexOf(mode);
    }

    BottomPicker(
      items: modes.map((mode) => Text(mode.value)).toList(),
      selectedItemIndex: initialIndex,
      title: '请选择合作模式',
      pickerTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      onChange: (val) {
        setState(() {
          ProjectMode selectedMode = modes[val];
          _projectModeController.text = selectedMode.value; // 设置选中的value
          _selectedProjectMode = selectedMode.id;
        });
      },
      onSubmit: (val) {
        setState(() {
          ProjectMode selectedMode = modes[val];
          _projectModeController.text = selectedMode.value; // 设置选中的value
          _selectedProjectMode = selectedMode.id;
        });
      },
    ).show(context);
  }

  void BottomPickLanage(BuildContext context) {
    String initialLanguage = '';
    if (_devlanguageController.text != '') {
      initialLanguage = _devlanguageController.text;
    }

    int initialIndex = Devlang.indexWhere(
        (language) => language['languageName'] == initialLanguage);
    if (initialIndex == -1) {
      initialIndex = 0; // 或者选择其他合适的默认索引
    }

    List<Text> pickerItems =
        Devlang.map((language) => Text(language['languageName'])).toList();

    BottomPicker(
      items: pickerItems,
      selectedItemIndex: initialIndex,
      title: '请选择开发语言',
      pickerTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      onChange: (val) {
        setState(() {
          String selectedLanguage = Devlang[val]['languageName'];
          _selectedDevLanguage = Devlang[val]['ID'];
          _devlanguageController.text = selectedLanguage;
        });
      },
      onSubmit: (val) {
        setState(() {
          String selectedLanguage = Devlang[val]['languageName'];
          _selectedDevLanguage = Devlang[val]['ID'];
          _devlanguageController.text = selectedLanguage;
        });
      },
    ).show(context);
  }

  void _showErrorDialog(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
