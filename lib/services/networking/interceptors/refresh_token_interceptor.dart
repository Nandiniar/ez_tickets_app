import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

//Providers
import '../../../providers/all_providers.dart';

//Endpoints
import '../api_endpoint.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;

  RefreshTokenInterceptor(this._dio);

  // ignore: non_constant_identifier_names
  String get TokenExpiredException => "TokenExpiredException";

  @override
  void onError(
    DioError dioError,
    ErrorInterceptorHandler handler,
  ) async {
    if (dioError.response != null) {
      if (dioError.response!.data != null) {
        final Map<String, dynamic> headers = dioError.response!.data["headers"];

        //Check error type to be token expired error
        String error = headers["error"];
        if (error == TokenExpiredException) {
          //Make new dio and lock old one
          final tokenDio = Dio();
          //contentType already set in tokenDio headers
          tokenDio.options = _dio.options;
          _dio.lock();

          //Get auth details for refresh token request
          final authProv = ProviderContainer().read(authProvider.notifier);
          final Map<String, dynamic> data = {
            "email": authProv.currentUserEmail,
            "password": authProv.currentUserPassword,
            "oldToken": authProv.token
          };

          //Make refresh request and get new token
          final String? newToken = await _refreshTokenRequest(
            dioError: dioError,
            handler: handler,
            tokenDio: tokenDio,
            data: data,
          );

          if(newToken == null) return super.onError(dioError, handler);

          //Update auth and unlock old dio
          authProv.updateToken(newToken);
          _dio.unlock();
          _dio.clear();

          //Make original req with new token
          final response = await _dio.request(
            dioError.requestOptions.path,
            data: dioError.requestOptions.data,
            cancelToken: dioError.requestOptions.cancelToken,
            options: Options(
              headers: {"Authorization": "Bearer $newToken"},
            ),
          );
          return handler.resolve(response);
        }
      }
    }

    //if not token expired error, forward it to try catch in dio_service
    return super.onError(dioError, handler);
  }

  Future<String?> _refreshTokenRequest({
    required DioError dioError,
    required ErrorInterceptorHandler handler,
    required Dio tokenDio,
    required Map<String, dynamic> data,
  }) async {
    debugPrint("--> REFRESHING TOKEN");
    try {
      debugPrint("\tBody: $data");

      final response = await tokenDio.post(
        ApiEndpoint.auth(refreshToken: true),
        data: data,
      );

      debugPrint("\tStatus code:${response.statusCode}");
      debugPrint("\tResponse: ${response.data}");

      //Check new token success
      final success = response.data["headers"]["success"] == 1;

      if (success) {
        debugPrint("<-- END REFRESH");
        return response.data["body"]["token"];
      } else {
        throw Exception;
      }
    } on DioError catch (de) {
      //only caught here for logging
      //forward to try-catch in dio_service for handling
      debugPrint("\t--> ERROR");
      debugPrint("\t\t--> Exception: ${de.error}");
      debugPrint("\t\t--> Message: ${de.message}");
      debugPrint("\t\t--> Response: ${de.response}");
      debugPrint("\t<-- END ERROR");
      debugPrint("<-- END REFRESH");
      _dio.unlock();
      _dio.clear();
      return null;
    } on Exception catch (ex) {
      //only caught here for logging
      //forward to try-catch in dio_service for handling
      debugPrint("\t--> ERROR");
      debugPrint("\t\t--> Exception: $ex");
      debugPrint("\t<-- END ERROR");
      debugPrint("<-- END REFRESH");
      _dio.unlock();
      _dio.clear();
      return null;
    }
  }
}