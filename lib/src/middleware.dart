import 'package:redux/redux.dart';

import 'models.dart';

typedef ErrorFn = Function(dynamic error);

Middleware<St> createMarduxMiddleware<St>({
  Function onRequest,
  Function onError,
}) {
  return (Store<St> store, dynamic act, NextDispatcher next) async {
    next(act);

    final action = isReduxAction(act);
    if (action == null) {
      return;
    }

    action.setStore(store);
    action.before();

    try {
      final request = action.request();
      if (request is Future) {
        store.dispatch(ReduceAction(action, RequestStatus(isLoading: true)));

        final res = await request;

        store.dispatch(ReduceAction(
          action,
          RequestStatus(
            data: res,
          ),
        ));

        action.after();
        return;
      }
    } catch (e) {
      store.dispatch(ReduceAction(action, RequestStatus(error: e)));

      if (onError is ErrorFn) {
        store.dispatch(onError(e));
      }
      return;
    }

    store.dispatch(ReduceAction(action, null));
    action.after();
  };
}

ReduxAction isReduxAction(dynamic action) {
  if (action is ReduxAction) return action;
  return null;
}
