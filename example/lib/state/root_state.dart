import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

@immutable
class RootState {
  final ThemeState themeState;
  final String language;
  final String router;

  RootState({
    required this.themeState,
    this.language = 'en',
    this.router = '/readme',
  });

  static RootState initial() => RootState(
        themeState: ThemeState.initial(),
      );

  RootState copy({ThemeState? themeState, String? language, String? router}) {
    return RootState(
      themeState: themeState ?? this.themeState,
      language: language ?? this.language,
      router: router ?? this.router,
    );
  }
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

bool get isDark => rootStore.state.themeState.brightness == Brightness.dark;

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
    return state.copy(
        themeState: new ThemeState(
      isDark ? Brightness.light : Brightness.dark,
    ));
  }
}

class ChangeLanguage extends BaseUIEvent {
  @override
  RootState reducer(RootState state) {
    final language = state.language;
    return state.copy(language: language == 'en' ? 'zh' : 'en');
  }

  static String storeConverter(Store<RootState> store) => store.state.language;
}

class ChangeRouter extends BaseUIEvent {
  final String router;

  ChangeRouter(this.router);

  static String storeConverter(Store<RootState> store) => store.state.router;

  @override
  RootState reducer(RootState state) => state.copy(router: router);
}
