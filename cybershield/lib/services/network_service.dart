import 'package:cybershield/core/constants/api_constants.dart';
import 'package:cybershield/services/token_storage.dart';
import 'package:dio/dio.dart';

class NetworkService {
  NetworkService._();
  static final NetworkService instance = NetworkService._();
  factory NetworkService() => instance;

  late final Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'cf-access-client-id': ApiConstants.cfAccessClientId,
          'cf-access-client-secret': ApiConstants.cfAccessClientSecret,
        },
      ),
    );

    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
  }

  Dio get dio {
    try {
      _dio;
    } catch (_) {
      init();
    }
    return _dio;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> multipartPost(
    String path, {
    required FormData formData,
  }) async {
    return await dio.post(path, data: formData);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage().getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await TokenStorage().clearAll();
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 403) {
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          error: 'تم حظر الطلب بواسطة جدار الحماية (Cloudflare WAF)',
        ),
      );
    } else {
      handler.next(err);
    }
  }
}
