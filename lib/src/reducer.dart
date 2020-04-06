import 'package:redux/redux.dart';

import 'models.dart';

class MarduxReducer<St> {
  Reducer<St> createReducer() {
    return combineReducers<St>([
      TypedReducer<St, ReduceAction>(_handleReduceAction),
    ]);
  }

  St _handleReduceAction(St state, ReduceAction action) {
    return action.reduxAction.reduce(action.status);
  }
}
