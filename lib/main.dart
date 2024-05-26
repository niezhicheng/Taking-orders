import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:untitled2/reset_passwd/view.dart';
import 'package:untitled2/utils/shared_preferences.dart';
import 'package:untitled2/utils/sqlite.dart';
import 'package:untitled2/utils/ws.dart';
import 'home/view.dart';
import 'login/view.dart';
import 'package:untitled2/reset_passwd/view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  Get.put<WebSocketService>(WebSocketService(), permanent: true);
  runApp(const MyApp());
}

class AuthController extends GetxController {
  RxBool isTokenAvailable = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await checkToken();
  }

  Future<void> checkToken() async {
    try {
      final accessToken = await SharedPreferencesUtils.getData("token");
      print(accessToken);
      if (accessToken != null) {
        // 在此处编写访问令牌可用的代码
        // isTokenAvailable 设置为 true
        isTokenAvailable.value = true;
        print(isTokenAvailable.value);
      } else {
        // 在此处编写访问令牌不可用的代码
        // isTokenAvailable 设置为 false
        isTokenAvailable.value = false;
      }
    } catch (error) {
      // 在此处编写处理错误的代码
      print("Error occurred while getting data: $error");
    }
    // 检查是否存在令牌的逻辑（例如，从存储中获取令牌并进行验证）
    // 设置isTokenAvailable的值为true或false
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    return FutureBuilder(
      future: authController.checkToken(), // 调用 checkToken 方法
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 如果令牌检查仍在进行中，显示加载指示器或其他内容
          return CircularProgressIndicator();
        } else {
          // 令牌检查完成后，根据令牌的可用性设置初始路由
          return ScreenUtilInit(
            designSize: const Size(750, 1334),
            builder: (context, child) {
              return GetMaterialApp(
                debugShowCheckedModeBanner: false,
                initialRoute:
                    authController.isTokenAvailable.value ? '/home' : '/login',
                getPages: [
                  GetPage(name: '/home', page: () => HomePage()),
                  GetPage(name: '/login', page: () => LoginPage()),
                  GetPage(name: '/resetPasswd', page: () => ResetPasswdPage()),
                ],
              );
            },
          );
        }
      },
    );
  }
}
