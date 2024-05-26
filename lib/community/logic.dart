import 'package:get/get.dart';

import '../utils/dio.dart';
import 'state.dart';

class CommunityLogic extends GetxController {
  final CommunityState state = CommunityState();

  void initCategory(id) async {
    final res = await HttpUtil().get('/OSC/getOpenSourceCategoryListAll');
    if (res.data['code'] == 0) {
      // 更新状态
      state.sourceCategory.value = res.data['data']['list'];
      if (state.sourceCategory.value.length >= 1) {
        initOpSource(state.sourceCategory.value[0]['ID']);
      }
    }
  }

  void initOpSource(categoryName) async {
    print("这是categoryname${categoryName}");
    final res = await HttpUtil().get('/Os/getOpenCategorySourceList',
        data: {"categoryName": categoryName});
    if (res.data['code'] == 0) {
      // 更新状态
      state.opSource.value = res.data['data']['list'];
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initCategory(1);
  }
}
