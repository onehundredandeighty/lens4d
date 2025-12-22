class LensGet<IN, OUT> {
  final List<OUT> Function(String, IN) _getFn;

  LensGet(this._getFn);

  List<OUT> call(String name, IN target) => _getFn(name, target);

  LensGet<IN, NEXT> map<NEXT>(NEXT Function(OUT) nextFn) => LensGet<IN, NEXT>(
    (name, target) => _getFn(name, target).map(nextFn).toList(),
  );
}

class LensSet<IN, OUT> {
  final IN Function(String, List<OUT>, IN) _setFn;

  LensSet(this._setFn);

  IN call(String name, List<OUT> values, IN target) =>
      _setFn(name, values, target);

  LensSet<IN, NEXT> map<NEXT>(OUT Function(NEXT) nextFn) => LensSet<IN, NEXT>(
    (name, values, target) => _setFn(name, values.map(nextFn).toList(), target),
  );
}
