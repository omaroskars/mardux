import 'package:redux/redux.dart';

import 'middleware.dart';
import 'reducer.dart';

class Mardux<St> {
  final String baseUrl;

  Mardux({this.baseUrl});

  static Middleware<St> createMiddleware<St>({
    GetHeaders getHeaders,
    Function onError,
    RequestFn onRequest,
  }) {
    return createMarduxMiddleware(
      onRequest: onRequest,
      onError: onError,
    );
  }

  static Reducer<St> createReducer<St>() {
    return MarduxReducer<St>().createReducer();
  }
}

// Future<Response> makeRequest({
//   @required RequestAction action,
//   @required String baseUrl,
//   Map<String, String> headers,
// }) async {
//   final url = "$baseUrl${action.url}";

//   return await MarClient.request(
//     url: url,
//     headers: headers,
//     method: action.method,
//     body: action.body,
//     query: action.query,
//   );
// }
