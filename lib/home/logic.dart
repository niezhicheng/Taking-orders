import 'package:get/get.dart';

import '../utils/shared_preferences.dart';
import '../utils/ws.dart';
import 'state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();
  final webSocketService = Get.find<WebSocketService>();
  @override
  void onInit() {
    // TODO: implement onInit
    userid();
    super.onInit();
  }

  void userid() async {
    final res = await getInt("userid");
    webSocketService.userid.value = res!;
  }
}
