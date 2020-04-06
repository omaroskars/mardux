import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;
import 'package:mardux/mardux.dart';

///////////////////////////////////////////////////////////////////////////////
/// Setup a basic Redux state for the app
/// The AppState contains:
///   counter     : Counter for how many times the button is pressed
///   description : Description text from a server
///   isLoading   : Indicator for loading state
///   errorMsg    : An error message if an error occurs

class AppState {
  final int counter;
  final String description;
  final bool isLoading;
  final String errorMsg;

  AppState({
    this.counter,
    this.description,
    this.isLoading,
    this.errorMsg,
  });

  AppState copy({
    int counter,
    String description,
    bool isLoading,
    dynamic errorMsg,
  }) =>
      AppState(
        counter: counter ?? this.counter,
        description: description ?? this.description,
        isLoading: isLoading ?? false,
        errorMsg: errorMsg ?? null,
      );

  static AppState initialState() =>
      AppState(counter: 0, description: "", isLoading: false, errorMsg: null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          counter == other.counter &&
          description == other.description &&
          errorMsg == other.errorMsg &&
          isLoading == other.isLoading;

  @override
  int get hashCode => counter.hashCode ^ description.hashCode;
}

///////////////////////////////////////////////////////////////////////////////

/// Setup the store

void main() {
  // Create an instance of mardux reducer
  final marduxReducer = Mardux.createReducer<AppState>();

  // Create an instance of mardux middleware
  final marduxMiddleware = Mardux.createMiddleware<AppState>();

  // Initialize the store with mardux reducer and middleware
  final store = new Store<AppState>(
    marduxReducer,
    initialState: AppState.initialState(),
    middleware: [
      marduxMiddleware,
    ],
  );

  runApp(MyApp(
    store: store,
    title: "Mardux demo",
  ));
}

///////////////////////////////////////////////////////////////////////////////

class MyApp extends StatelessWidget {
  final Store<AppState> store;
  final String title;

  const MyApp({Key key, this.store, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CounterWidget(),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

/// Helper class known as a ViewModel.
/// The view model has direct access to the store's state for convenience.
/// You can therefore use the state directly or access it through the store.state

class _VM extends BaseModel<AppState> {
  final int count;
  final String desc;
  final bool isLoading;
  final String errorMsg;

  _VM(
    Store store, {
    this.count,
    this.desc,
    this.isLoading,
    this.errorMsg,
  }) : super(store);

  @override
  BaseModel fromStore() {
    return _VM(store,
        count: state.counter,
        desc: state.description,
        isLoading: state.isLoading,
        errorMsg: state.errorMsg);
  }
}

class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _VM>(
      converter: (store) => _VM(store).fromStore(), // initialize the VM
      builder: (context, vm) => Scaffold(
        appBar: AppBar(title: Text("Mardux async demo")),
        body: buildBody(context, vm),
        floatingActionButton: FloatingActionButton(
          onPressed: () => vm.dispatch(IncrementCountAction()),
          tooltip: "Increment",
          child: new Icon(Icons.add),
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context, _VM vm) {
    if (vm.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.blue,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      );
    }

    if (vm.errorMsg != null) {
      return Center(child: Text(vm.errorMsg));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          vm.count.toString(),
          style: Theme.of(context).textTheme.display1,
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            vm.desc,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

/// This action makes an asynchronous request to the numbers api.
/// Updates the state when its loading,
/// When it gets a response it increments the counter and updates
/// the description with the response
class IncrementCountAction extends ReduxAction<AppState> {
  @override
  request() {
    final url = "http://numbersapi.com/${state.counter + 1}";
    final res = http.read(url);

    return res;
  }

  //
  @override
  AppState reduce(RequestStatus status) {
    // Handle loading state
    if (status.isLoading) {
      return state.copy(isLoading: status.isLoading);
    }

    // Update the error message if an error occurs
    if (status.hasError) {
      return state.copy(
        errorMsg: "Error occured",
      );
    }

    // Parse response from the server
    final description = status.data;

    // Update the state with incremented counter
    // and a description from the server
    return state.copy(
      counter: state.counter + 1,
      description: description,
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
