import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:plantito_iot/modules/widgetview.dart';

/// Widget View Architecture for StatefulWidget
///
/// Implementations:
/// ```
/// class _MyWidgetView extends StflView<MyWidget, _MyWidgetController> {
///   const _MyWidgetView (_MyWidgetController.state) : super(state, key: ObjectKey(state));
///
///   Widget build(BuildContext build){
///     //_MyWidgetView can now easily access everything on widget and state,
///     // properly typed, no parameter passing boilerplate :)
///   }
/// }
/// ```
/// If you want to access the providers, consider using [ConStflView]
/// instead
abstract class StflView<T1, T2> extends StatelessWidget {
  final T2 state;
  T1 get widget => (state as State).widget as T1;
  const StflView(this.state, {required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context);
}

/// A Consumer Stateful Widget View
abstract class ConStflView<T1, T2> extends StatelessWidget {
  final T2 state;
  final WidgetRef ref;
  T1 get widget => (state as State).widget as T1;
  const ConStflView(this.state, this.ref, {required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context);
}

/// Widget View Architecture for StatelessWidget
///
/// Implementations:
/// ```
/// class _MyWidgetView extends StlsView<MyWidget> {
///   const _MyWidgetView (this.state, {Key key}) : super(key: key);
///
///   Widget build(BuildContext build){
///      //Can easily handlers and params values on .widget
///    }
/// }
/// ```
/// If you want to access the providers, consider using [ConStlsView]
/// instead
abstract class StlsView<T1> extends StatelessWidget {
  final T1 state;
  const StlsView(this.state, {required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context);
}

/// A Consumer Stateless Widget View
abstract class ConStlsView<T1> extends StatelessWidget {
  final T1 state;
  final WidgetRef ref;
  const ConStlsView(this.state, this.ref, {required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context);
}

// /// A Consumer Stateless Widget View
// abstract class ConStlsView<T1> extends ConsumerWidget {
//   final T1 widget;
//   const ConStlsView(this.widget, {required Key key}) : super(key: key);
//   @override
//   Widget build(BuildContext context, WidgetRef ref);
// }
