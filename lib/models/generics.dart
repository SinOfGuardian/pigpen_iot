class GenericStack<T extends num> {
  final _list = <T>[];

  /// Methods
  void push(T value) => _list.add(value);
  void clear() => _list.clear();
  T pop() => _list.removeAt(0);

  /// Peeking a value
  T get peekFirst => _list.first;
  T get peekLast => _list.last;
  T peekAt(int index) => _list.elementAt(index);
  T? get peekHighest {
    if (_list.isEmpty) return null;
    return _list.reduce((a, b) => a > b ? a : b);
  }

  T? get peekLowest {
    if (_list.isEmpty) return null;
    return _list.reduce((a, b) => a < b ? a : b);
  }

  /// Properties
  int get length => _list.length;
  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;
  List<T> get getList => _list;
}
