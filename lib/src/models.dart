import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';

typedef Dispatch<St> = void Function(ReduxAction<St> action);
typedef RequestFn = Future Function(RequestAction req);

abstract class ReduxAction<St> {
  Store<St> _store;

  void setStore(Store store) => _store = (store as Store<St>);

  Store<St> get store => _store;

  St get state => _store.state;

  Dispatch<St> get dispatch => _store.dispatch;

  void before() {}

  void after() {}

  St reduce(RequestStatus status);

  FutureOr<dynamic> request() {
    return null;
  }
}

class RequestStatus {
  final bool isLoading;
  final dynamic data;
  final dynamic error;

  bool get hasError => error != null;

  RequestStatus({this.isLoading = false, this.data, this.error});
}

/// Basic reduce actoin
/// Calls reduce
class ReduceAction {
  final ReduxAction reduxAction;
  final RequestStatus status;

  ReduceAction(this.reduxAction, this.status);
}

/// Async model for the client request
class RequestAction {
  final String url;
  final String method;
  final dynamic body;
  final Map<String, dynamic> query;
  final Map<String, dynamic> headers;

  /// Overrided the clients base url
  final String baseUrl;

  RequestAction({
    @required this.url,
    @required this.method,
    this.body,
    this.query,
    this.headers,
    this.baseUrl,
  });
}

class RequestStatusAction {
  final ReduxAction reduxAction;
  final dynamic res;
  final dynamic error;
  final bool isLoading;

  RequestStatusAction({
    @required this.reduxAction,
    this.res,
    this.error,
    this.isLoading = false,
  });
}

/// Base Viewmodel
abstract class BaseModel<T> {
  final Store store;

  BaseModel(this.store);

  BaseModel fromStore();

  T get state => store.state;

  Dispatch get dispatch => store.dispatch;
}
