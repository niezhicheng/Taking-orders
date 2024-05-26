import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:untitled2/login/view.dart';
import 'apiurl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:untitled2/utils/shared_preferences.dart';
import 'dart:io';

class HttpUtil {
  static late HttpUtil _instance;
  late Dio dio;
  late BaseOptions options;

  late CancelToken cancelToken = CancelToken();

  static HttpUtil getInstance() {
    _instance ??= HttpUtil();
    return _instance;
  }

  /*
   * config it and create
   */
  HttpUtil() {
    //BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    options = BaseOptions(
      //请求基地址,可以包含子路径
      baseUrl: APIURL.baseUrl,
      //Http请求头.
      headers: {'version': '1.0.0'},
      //请求的Content-Type，默认值是"application/json; charset=utf-8",Headers.formUrlEncodedContentType会自动编码请求体.
      contentType: Headers.jsonContentType,
      //表示期望以那种格式(方式)接受响应数据。接受四种类型 `json`, `stream`, `plain`, `bytes`. 默认值是 `json`,
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    //Cookie管理
    dio.interceptors.add(CookieManager(CookieJar()));
    //打开日志
    dio.interceptors.add(LogInterceptor(responseBody: true));
    //添加拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        //添加token
        String? accessToken = await getData('token');
        if (accessToken != null || accessToken != "") {
          options.headers['x-token'] = accessToken;
        }
        handler.next(options);
      },
      onResponse: (response, handler) async {
        if (response.data['code'].toString() == '401') {
          print('登录过期被拦截到了');
          //token过期，跳转到登录并清空缓存
          await deleteData('token');
        }
        ;
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  /*
   * get请求
   */
  get(url, {data, options, cancelToken}) async {
    Response? response;
    try {
      response = await dio.get(url,
          queryParameters: data, options: options, cancelToken: cancelToken);
      // print('get success---------${response.data}');
//      response.data; 响应体
//      response.headers; 响应头
//      response.request; 请求体
//      response.statusCode; 状态码
    } on DioError catch (e) {
      // print('get error---------$e');
      formatError(e);
    }
    return response;
  }

  /*
   * post请求
   */
  post(url, {data, options, cancelToken}) async {
    Response? response;
    try {
      response = await dio.post(url,
          data: data, options: options, cancelToken: cancelToken);
      // print('post success---------${response.data}');
    } on DioError catch (e) {
      // print('post error---------$e');
      formatError(e);
    }
    return response;
  }

  /*
 * 发起PUT请求
 */
  put(url, {data, options, cancelToken}) async {
    Response? response;
    try {
      response = await dio.put(url,
          data: data, options: options, cancelToken: cancelToken);
      // print('PUT success---------${response.data}');
      // response.data; 响应体
      // response.headers; 响应头
      // response.request; 请求体
      // response.statusCode; 状态码
    } on DioError catch (e) {
      // print('PUT error---------$e');
      formatError(e);
    }
    return response;
  }

/*
 * 发起DELETE请求
 */
  delete(url, {data, options, cancelToken}) async {
    Response? response;
    try {
      response = await dio.delete(url,
          data: data, options: options, cancelToken: cancelToken);
      // print('DELETE success---------${response.data}');
      // response.data; 响应体
      // response.headers; 响应头
      // response.request; 请求体
      // response.statusCode; 状态码
    } on DioError catch (e) {
      print('DELETE error---------$e');
      formatError(e);
    }
    return response;
  }

  /*
   * 下载文件
   */
  downloadFile(urlPath, savePath) async {
    Response? response;
    try {
      response = await dio.download(urlPath, savePath,
          onReceiveProgress: (int count, int total) {
        //进度
        // print("$count $total");
      });
      print('downloadFile success---------${response.data}');
    } on DioError catch (e) {
      // print('downloadFile error---------$e');
      formatError(e);
    }
    return response!.data;
  }

  /*
   * 文件上传
   */
  uploadFile(File file) async {
    Response? response;
    String url = '/fileUploadAndDownload/upload'; // 替换为实际的上传 URL

    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });
    response = await dio.post(url, data: formData);
    return response;
  }

  /*
   * error统一处理
   */
  formatError(DioError e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      // connectionTimeout: 连接超时，即在建立连接时超过了指定的时间。
      // sendTimeout: 发送超时，即在发送请求数据时超过了指定的时间。
      // receiveTimeout: 接收超时，即在接收响应数据时超过了指定的时间。
      // badCertificate: 错误的证书，当使用ValidateCertificate进行证书验证时，如果证书不正确，就会引发此异常。
      // badResponse: 错误的响应，当使用ValidateStatus进行状态码验证时，如果响应状态码不正确，就会引发此异常。
      // cancel: 取消请求操作，当请求被取消时引发此异常。
      // connectionError: 连接错误，例如xhr.onError或Socket异常等。
      // unknown: 未知错误类型，其他一些错误情况。在这种情况下，你可以使用DioException.error属性来获取具体的错误信息
      // It occurs when url is opened timeout.
      print("连接超时");
    } else if (e.type == DioExceptionType.sendTimeout) {
      // It occurs when url is sent timeout.
      print("发送超时");
    } else if (e.type == DioExceptionType.receiveTimeout) {
      //It occurs when receiving timeout
      print("响应超时");
    } else if (e.type == DioExceptionType.badCertificate) {
      // When the server response, but with a incorrect status, such as 404, 503...
      print("出现异常");
    } else if (e.type == DioExceptionType.cancel) {
      // When the request is cancelled, dio will throw a error with this type.
      print("请求取消");
    } else {
      //DEFAULT Default error type, Some other Error. In this case, you can read the DioError.error if it is not null.
      print("未知错误");
    }
  }

  /*
   * 取消请求
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }
}
