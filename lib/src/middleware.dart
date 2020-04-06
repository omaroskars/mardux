import 'package:redux/redux.dart';

import 'models.dart';

typedef GetHeaders = Function({Map<String, dynamic> customHeaders});
typedef RequestFn = Future Function(RequestAction req);
typedef ErrorFn = Function();

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

    // Initialize the store within the action
    action.setStore(store);
    action.before();

    try {
      // Handle async actions
      final request = action.request();
      if (request is Future) {
        // Dispatch a loading action
        store.dispatch(ReduceAction(action, RequestStatus(isLoading: true)));

        // Wait for the response
        final res = await request;

        // Dispatch success action
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
      // Handle error
      store.dispatch(ReduceAction(action, RequestStatus(error: e)));

      // Call global error handler
      if (onError is ErrorFn) {
        store.dispatch(onError());
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
