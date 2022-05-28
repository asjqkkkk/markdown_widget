import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

@immutable
class RootState {
  final ThemeState themeState;

  RootState({
    required this.themeState,
  });

  static RootState initial() => RootState(
        themeState: ThemeState.initial(),
      );
}

@immutable
class ThemeState {
  final Brightness brightness;

  ThemeState(this.brightness);

  static ThemeState initial() => ThemeState(Brightness.light);

  static ThemeState storeConverter(Store<RootState> store) =>
      store.state.themeState;
}

final Store<RootState> rootStore = Store(
  rootReducer,
  initialState: RootState.initial(),
);

RootState rootReducer(RootState state, dynamic action) {
  BaseUIEvent event = action;
  RootState newState = event.reducer(state);
  return newState;
}

abstract class BaseUIEvent {
  RootState reducer(RootState state);
}

class ChangeThemeEvent extends BaseUIEvent {
  @override
  RootState reducer(RootState state) {
    final brightness = state.themeState.brightness;
    return new RootState(
      themeState: new ThemeState(
          brightness == Brightness.light ? Brightness.dark : Brightness.light),
    );
  }
}
