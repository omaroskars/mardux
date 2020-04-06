import 'package:redux/redux.dart';

import 'models.dart';

class MarduxReducer<St> {
  Reducer<St> createReducer() {
    return combineReducers<St>([
      TypedReducer<St, ReduceAction>(_handleReduceAction),
      // TypedReducer<St, RequestStatusAction>(_handleAsyncAction),
    ]);
  }

  // St _handleAsyncAction(St state, RequestStatusAction action) {
  //   return action.reduxAction
  //       .reduceRequest(action.isLoading, action.res, action.error);
  // }

  St _handleReduceAction(St state, ReduceAction action) {
    return action.reduxAction.reduce(action.status);
  }
}
