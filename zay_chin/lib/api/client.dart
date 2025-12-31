import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import './config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  String? _accessToken;
  PersistCookieJar? _cookieJar;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    final dir = await getApplicationSupportDirectory();
    _cookieJar = PersistCookieJar(storage: FileStorage('${dir.path}/cookies'));
    _dio.interceptors.add(CookieManager(_cookieJar!));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final newToken = await _refreshToken();
              if (newToken != null) {
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newToken';
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              }
            } catch (e) {
              _accessToken = null;
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _refreshToken() async {
    try {
      final response = await _dio.get('${ApiConfig.authPrefix}/refresh');
      final token = response.data['data']['auth']['access_token'] as String;
      _accessToken = token;
      await _secureStorage.write(key: 'access_token', value: token);
      return token;
    } catch (e) {
      return null;
    }
  }

  void setAccessToken(String token) {
    _accessToken = token;
    _secureStorage.write(key: 'access_token', value: token);
  }

  void clearToken() {
    _accessToken = null;
    _secureStorage.delete(key: 'access_token');
    _cookieJar?.deleteAll();
  }

  bool hasToken() => _accessToken != null;

  String? get accessToken => _accessToken;

  Dio get dio => _dio;

  Future<void> bootstrapAuth() async {
    await init();
    final refreshed = await _refreshToken();
    if (refreshed != null) return;
    final stored = await _secureStorage.read(key: 'access_token');
    if (stored != null && stored.isNotEmpty) {
      _accessToken = stored;
    }
  }
}
