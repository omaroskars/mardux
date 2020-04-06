import 'package:redux/redux.dart';

import 'middleware.dart';
import 'reducer.dart';

class Mardux<St> {
  static Middleware<St> createMiddleware<St>({
    ErrorFn onError,
  }) {
    return createMarduxMiddleware(
      onError: onError,
    );
  }

  static Reducer<St> createReducer<St>() {
    return MarduxReducer<St>().createReducer();
  }
}
