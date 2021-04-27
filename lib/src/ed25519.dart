import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'constants.dart';

/// FieldElement represents an element of the field GF(2^255 - 19)
class FieldElement extends UnmodifiableInt32ListView {
  /// '0'
  factory FieldElement.zero() {
    return FieldElement().._data[0] = 0;
  }

  /// '1'
  factory FieldElement.one() {
    return FieldElement().._data[0] = 1;
  }

  /// New FieldElement from 32 byte array
  factory FieldElement.fromBytes(List<int> bytes) {
    var h0 = bytes[0] & 0xFF;
    h0 |= (bytes[1] << 8) & 0xFF00;
    h0 |= (bytes[2] << 16) & 0xFF0000;
    h0 |= (bytes[3] << 24) & 0xFF000000;

    var h1 = bytes[4 + 0] & 0xFF;
    h1 |= (bytes[4 + 1] << 8) & 0xFF00;
    h1 |= (bytes[4 + 2] << 16) & 0xFF0000;
    h1 <<= 6;

    var h2 = bytes[7 + 0] & 0xFF;
    h2 |= (bytes[7 + 1] << 8) & 0xFF00;
    h2 |= (bytes[7 + 2] << 16) & 0xFF0000;
    h2 <<= 5;

    var h3 = bytes[10 + 0] & 0xFF;
    h3 |= (bytes[10 + 1] << 8) & 0xFF00;
    h3 |= (bytes[10 + 2] << 16) & 0xFF0000;
    h3 <<= 3;

    var h4 = bytes[13 + 0] & 0xFF;
    h4 |= (bytes[13 + 1] << 8) & 0xFF00;
    h4 |= (bytes[13 + 2] << 16) & 0xFF0000;
    h4 <<= 2;

    var h5 = bytes[16 + 0] & 0xFF;
    h5 |= (bytes[16 + 1] << 8) & 0xFF00;
    h5 |= (bytes[16 + 2] << 16) & 0xFF0000;
    h5 |= (bytes[16 + 3] << 24) & 0xFF000000;

    var h6 = bytes[20 + 0] & 0xFF;
    h6 |= (bytes[20 + 1] << 8) & 0xFF00;
    h6 |= (bytes[20 + 2] << 16) & 0xFF0000;
    h6 <<= 7;

    var h7 = bytes[23 + 0] & 0xFF;
    h7 |= (bytes[23 + 1] << 8) & 0xFF00;
    h7 |= (bytes[23 + 2] << 16) & 0xFF0000;
    h7 <<= 5;

    var h8 = bytes[26 + 0] & 0xFF;
    h8 |= (bytes[26 + 1] << 8) & 0xFF00;
    h8 |= (bytes[26 + 2] << 16) & 0xFF0000;
    h8 <<= 4;

    var h9 = bytes[29 + 0] & 0xFF;
    h9 |= (bytes[29 + 1] << 8) & 0xFF00;
    h9 |= (bytes[29 + 2] << 16) & 0xFF0000;
    h9 = h9 & 8388607;
    h9 <<= 2;

    var carry9 = (h9 + (1 << 24)) >> 25;
    h0 += carry9 * 19;
    h9 -= carry9 << 25;
    var carry1 = (h1 + (1 << 24)) >> 25;
    h2 += carry1;
    h1 -= carry1 << 25;
    var carry3 = (h3 + (1 << 24)) >> 25;
    h4 += carry3;
    h3 -= carry3 << 25;
    var carry5 = (h5 + (1 << 24)) >> 25;
    h6 += carry5;
    h5 -= carry5 << 25;
    var carry7 = (h7 + (1 << 24)) >> 25;
    h8 += carry7;
    h7 -= carry7 << 25;

    var carry0 = (h0 + (1 << 25)) >> 26;
    h1 += carry0;
    h0 -= carry0 << 26;
    var carry2 = (h2 + (1 << 25)) >> 26;
    h3 += carry2;
    h2 -= carry2 << 26;
    var carry4 = (h4 + (1 << 25)) >> 26;
    h5 += carry4;
    h4 -= carry4 << 26;
    var carry6 = (h6 + (1 << 25)) >> 26;
    h7 += carry6;
    h6 -= carry6 << 26;
    var carry8 = (h8 + (1 << 25)) >> 26;
    h9 += carry8;
    h8 -= carry8 << 26;

    var h = Int32List(10);
    h[0] = h0;
    h[1] = h1;
    h[2] = h2;
    h[3] = h3;
    h[4] = h4;
    h[5] = h5;
    h[6] = h6;
    h[7] = h7;
    h[8] = h8;
    h[9] = h9;

    return FieldElement(h);
  }

  Int32List _data;

  FieldElement([Int32List? data])
      : _data = data ?? Int32List(10),
        assert(data == null || data.length == 10),
        super(data ?? Int32List(10));

  /// Get index in FieldElement
  @override
  int operator [](int index) {
    assert(index < _data.length);
    return _data.elementAt(index);
  }

  /// Set index in FieldElement
  @override
  void operator []=(int index, int element) {
    assert(index < _data.length);
    var data = List<int>.from(_data);
    data.insert(index, element);
    _data = Int32List.fromList(data);
  }

  /// Insert iterable into FieldElement at index
  @override
  void insertAll(int index, Iterable<int> iterable) {
    assert(index + iterable.length <= _data.length);
    var data = List<int>.from(_data);
    data.insertAll(index, iterable);
    _data = Int32List.fromList(data);
  }

  /// Add FieldElements together
  @override
  FieldElement operator +(other) {
    assert(other is FieldElement);
    var data = Int64List(10);
    for (var i = 0; i < 10; i++) {
      data[i] = _data[i] + other[i];
    }
    return FieldElement(Int32List.fromList(data));
  }

  ///FieldElement subtractor
  FieldElement operator -(other) {
    assert(other is FieldElement);
    var data = Int64List(10);
    for (var i = 0; i < 10; i++) {
      data[i] = _data[i] - other[i] as int;
    }
    return FieldElement(Int32List.fromList(data));
  }

  ///FieldElement multiplication
  FieldElement operator *(other) {
    assert(other is FieldElement);

    var f0 = _data[0];
    var f1 = _data[1];
    var f2 = _data[2];
    var f3 = _data[3];
    var f4 = _data[4];
    var f5 = _data[5];
    var f6 = _data[6];
    var f7 = _data[7];
    var f8 = _data[8];
    var f9 = _data[9];
    var g0 = other[0];
    var g1 = other[1];
    var g2 = other[2];
    var g3 = other[3];
    var g4 = other[4];
    var g5 = other[5];
    var g6 = other[6];
    var g7 = other[7];
    var g8 = other[8];
    var g9 = other[9];
    var g1_19 = 19 * g1; /* 1.959375*2^29 */
    var g2_19 = 19 * g2; /* 1.959375*2^30; still ok */
    var g3_19 = 19 * g3;
    var g4_19 = 19 * g4;
    var g5_19 = 19 * g5;
    var g6_19 = 19 * g6;
    var g7_19 = 19 * g7;
    var g8_19 = 19 * g8;
    var g9_19 = 19 * g9;
    var f1_2 = 2 * f1;
    var f3_2 = 2 * f3;
    var f5_2 = 2 * f5;
    var f7_2 = 2 * f7;
    var f9_2 = 2 * f9;
    var f0g0 = f0 * g0;
    var f0g1 = f0 * g1;
    var f0g2 = f0 * g2;
    var f0g3 = f0 * g3;
    var f0g4 = f0 * g4;
    var f0g5 = f0 * g5;
    var f0g6 = f0 * g6;
    var f0g7 = f0 * g7;
    var f0g8 = f0 * g8;
    var f0g9 = f0 * g9;
    var f1g0 = f1 * g0;
    var f1g1_2 = f1_2 * g1;
    var f1g2 = f1 * g2;
    var f1g3_2 = f1_2 * g3;
    var f1g4 = f1 * g4;
    var f1g5_2 = f1_2 * g5;
    var f1g6 = f1 * g6;
    var f1g7_2 = f1_2 * g7;
    var f1g8 = f1 * g8;
    var f1g9_38 = f1_2 * g9_19;
    var f2g0 = f2 * g0;
    var f2g1 = f2 * g1;
    var f2g2 = f2 * g2;
    var f2g3 = f2 * g3;
    var f2g4 = f2 * g4;
    var f2g5 = f2 * g5;
    var f2g6 = f2 * g6;
    var f2g7 = f2 * g7;
    var f2g8_19 = f2 * g8_19;
    var f2g9_19 = f2 * g9_19;
    var f3g0 = f3 * g0;
    var f3g1_2 = f3_2 * g1;
    var f3g2 = f3 * g2;
    var f3g3_2 = f3_2 * g3;
    var f3g4 = f3 * g4;
    var f3g5_2 = f3_2 * g5;
    var f3g6 = f3 * g6;
    var f3g7_38 = f3_2 * g7_19;
    var f3g8_19 = f3 * g8_19;
    var f3g9_38 = f3_2 * g9_19;
    var f4g0 = f4 * g0;
    var f4g1 = f4 * g1;
    var f4g2 = f4 * g2;
    var f4g3 = f4 * g3;
    var f4g4 = f4 * g4;
    var f4g5 = f4 * g5;
    var f4g6_19 = f4 * g6_19;
    var f4g7_19 = f4 * g7_19;
    var f4g8_19 = f4 * g8_19;
    var f4g9_19 = f4 * g9_19;
    var f5g0 = f5 * g0;
    var f5g1_2 = f5_2 * g1;
    var f5g2 = f5 * g2;
    var f5g3_2 = f5_2 * g3;
    var f5g4 = f5 * g4;
    var f5g5_38 = f5_2 * g5_19;
    var f5g6_19 = f5 * g6_19;
    var f5g7_38 = f5_2 * g7_19;
    var f5g8_19 = f5 * g8_19;
    var f5g9_38 = f5_2 * g9_19;
    var f6g0 = f6 * g0;
    var f6g1 = f6 * g1;
    var f6g2 = f6 * g2;
    var f6g3 = f6 * g3;
    var f6g4_19 = f6 * g4_19;
    var f6g5_19 = f6 * g5_19;
    var f6g6_19 = f6 * g6_19;
    var f6g7_19 = f6 * g7_19;
    var f6g8_19 = f6 * g8_19;
    var f6g9_19 = f6 * g9_19;
    var f7g0 = f7 * g0;
    var f7g1_2 = f7_2 * g1;
    var f7g2 = f7 * g2;
    var f7g3_38 = f7_2 * g3_19;
    var f7g4_19 = f7 * g4_19;
    var f7g5_38 = f7_2 * g5_19;
    var f7g6_19 = f7 * g6_19;
    var f7g7_38 = f7_2 * g7_19;
    var f7g8_19 = f7 * g8_19;
    var f7g9_38 = f7_2 * g9_19;
    var f8g0 = f8 * g0;
    var f8g1 = f8 * g1;
    var f8g2_19 = f8 * g2_19;
    var f8g3_19 = f8 * g3_19;
    var f8g4_19 = f8 * g4_19;
    var f8g5_19 = f8 * g5_19;
    var f8g6_19 = f8 * g6_19;
    var f8g7_19 = f8 * g7_19;
    var f8g8_19 = f8 * g8_19;
    var f8g9_19 = f8 * g9_19;
    var f9g0 = f9 * g0;
    var f9g1_38 = f9_2 * g1_19;
    var f9g2_19 = f9 * g2_19;
    var f9g3_38 = f9_2 * g3_19;
    var f9g4_19 = f9 * g4_19;
    var f9g5_38 = f9_2 * g5_19;
    var f9g6_19 = f9 * g6_19;
    var f9g7_38 = f9_2 * g7_19;
    var f9g8_19 = f9 * g8_19;
    var f9g9_38 = f9_2 * g9_19;

    var h0 = f0g0 +
        f1g9_38 +
        f2g8_19 +
        f3g7_38 +
        f4g6_19 +
        f5g5_38 +
        f6g4_19 +
        f7g3_38 +
        f8g2_19 +
        f9g1_38;
    var h1 = f0g1 +
        f1g0 +
        f2g9_19 +
        f3g8_19 +
        f4g7_19 +
        f5g6_19 +
        f6g5_19 +
        f7g4_19 +
        f8g3_19 +
        f9g2_19;
    var h2 = f0g2 +
        f1g1_2 +
        f2g0 +
        f3g9_38 +
        f4g8_19 +
        f5g7_38 +
        f6g6_19 +
        f7g5_38 +
        f8g4_19 +
        f9g3_38;
    var h3 = f0g3 +
        f1g2 +
        f2g1 +
        f3g0 +
        f4g9_19 +
        f5g8_19 +
        f6g7_19 +
        f7g6_19 +
        f8g5_19 +
        f9g4_19;
    var h4 = f0g4 +
        f1g3_2 +
        f2g2 +
        f3g1_2 +
        f4g0 +
        f5g9_38 +
        f6g8_19 +
        f7g7_38 +
        f8g6_19 +
        f9g5_38;
    var h5 = f0g5 +
        f1g4 +
        f2g3 +
        f3g2 +
        f4g1 +
        f5g0 +
        f6g9_19 +
        f7g8_19 +
        f8g7_19 +
        f9g6_19;
    var h6 = f0g6 +
        f1g5_2 +
        f2g4 +
        f3g3_2 +
        f4g2 +
        f5g1_2 +
        f6g0 +
        f7g9_38 +
        f8g8_19 +
        f9g7_38;
    var h7 = f0g7 +
        f1g6 +
        f2g5 +
        f3g4 +
        f4g3 +
        f5g2 +
        f6g1 +
        f7g0 +
        f8g9_19 +
        f9g8_19;
    var h8 = f0g8 +
        f1g7_2 +
        f2g6 +
        f3g5_2 +
        f4g4 +
        f5g3_2 +
        f6g2 +
        f7g1_2 +
        f8g0 +
        f9g9_38;
    var h9 =
        f0g9 + f1g8 + f2g7 + f3g6 + f4g5 + f5g4 + f6g3 + f7g2 + f8g1 + f9g0;

    var carry0 = ((h0 + (1 << 25)) as int) >> 26;
    h1 += carry0;
    h0 -= carry0 << 26;
    var carry4 = ((h4 + (1 << 25)) as int) >> 26;
    h5 += carry4;
    h4 -= carry4 << 26;

    var carry1 = ((h1 + (1 << 24)) as int) >> 25;
    h2 += carry1;
    h1 -= carry1 << 25;
    var carry5 = ((h5 + (1 << 24)) as int) >> 25;
    h6 += carry5;
    h5 -= carry5 << 25;

    var carry2 = ((h2 + (1 << 25)) as int) >> 26;
    h3 += carry2;
    h2 -= carry2 << 26;
    var carry6 = ((h6 + (1 << 25)) as int) >> 26;
    h7 += carry6;
    h6 -= carry6 << 26;

    var carry3 = ((h3 + (1 << 24)) as int) >> 25;
    h4 += carry3;
    h3 -= carry3 << 25;
    var carry7 = ((h7 + (1 << 24)) as int) >> 25;
    h8 += carry7;
    h7 -= carry7 << 25;

    carry4 = ((h4 + (1 << 25)) as int) >> 26;
    h5 += carry4;
    h4 -= carry4 << 26;
    var carry8 = ((h8 + (1 << 25)) as int) >> 26;
    h9 += carry8;
    h8 -= carry8 << 26;

    var carry9 = ((h9 + (1 << 24)) as int) >> 25;
    h0 += carry9 * 19;
    h9 -= carry9 << 25;

    carry0 = ((h0 + (1 << 25)) as int) >> 26;
    h1 += carry0;
    h0 -= carry0 << 26;

    var h = FieldElement();
    h[0] = h0 as int;
    h[1] = h1 as int;
    h[2] = h2 as int;
    h[3] = h3 as int;
    h[4] = h4 as int;
    h[5] = h5 as int;
    h[6] = h6 as int;
    h[7] = h7 as int;
    h[8] = h8 as int;
    h[9] = h9 as int;

    return h;
  }

  ///FieldElement fe * 121666
  FieldElement mul121666() {
    var f = Int64List.fromList(_data);
    var h0 = f[0] * 121666;
    var h1 = f[1] * 121666;
    var h2 = f[2] * 121666;
    var h3 = f[3] * 121666;
    var h4 = f[4] * 121666;
    var h5 = f[5] * 121666;
    var h6 = f[6] * 121666;
    var h7 = f[7] * 121666;
    var h8 = f[8] * 121666;
    var h9 = f[9] * 121666;

    var carry9 = (h9 + (1 << 24)) >> 25;
    h0 += carry9 * 19;
    h9 -= carry9 << 25;
    var carry1 = (h1 + (1 << 24)) >> 25;
    h2 += carry1;
    h1 -= carry1 << 25;
    var carry3 = (h3 + (1 << 24)) >> 25;
    h4 += carry3;
    h3 -= carry3 << 25;
    var carry5 = (h5 + (1 << 24)) >> 25;
    h6 += carry5;
    h5 -= carry5 << 25;
    var carry7 = (h7 + (1 << 24)) >> 25;
    h8 += carry7;
    h7 -= carry7 << 25;

    var carry0 = (h0 + (1 << 25)) >> 26;
    h1 += carry0;
    h0 -= carry0 << 26;
    var carry2 = (h2 + (1 << 25)) >> 26;
    h3 += carry2;
    h2 -= carry2 << 26;
    var carry4 = (h4 + (1 << 25)) >> 26;
    h5 += carry4;
    h4 -= carry4 << 26;
    var carry6 = (h6 + (1 << 25)) >> 26;
    h7 += carry6;
    h6 -= carry6 << 26;
    var carry8 = (h8 + (1 << 25)) >> 26;
    h9 += carry8;
    h8 -= carry8 << 26;

    var out = FieldElement();
    out[0] = h0;
    out[1] = h1;
    out[2] = h2;
    out[3] = h3;
    out[4] = h4;
    out[5] = h5;
    out[6] = h6;
    out[7] = h7;
    out[8] = h8;
    out[9] = h9;
    return out;
  }

  ///Check if this == other
  @override
  bool operator ==(other) {
    assert(other is FieldElement);
    var zero = this - other;
    return zero.isZero;
  }

  /// Replace (f,g) with (g,g) if b == 1;
  /// replace (f,g) with (f,g) if b == 0.
  void cmov(FieldElement a, int b) {
    // var c = FieldElement();
    var x = List<int>.generate(10, (_) {
      return 0;
    }, growable: false);
    b = -b;

    for (var i = 0; i < 10; i++) {
      x[i] = b & (_data[i] ^ a[i]);
      _data[i] = _data[i] ^ x[i];
    }
  }

  /// swap a, b if b == 1
  void cswap(FieldElement a, int b) {
    var x = List<int>.generate(10, (_) {
      return 0;
    }, growable: false);
    var f = List<int>.from(_data);
    var g = List<int>.from(a);
    b = -b;

    for (var i = 0; i < 10; i++) {
      x[i] = f[i] ^ g[i];
      x[i] &= b;
      f[i] = f[i] ^ x[i];
      g[i] = g[i] ^ x[i];
    }

    insertAll(0, Int32List.fromList(f));
    a.insertAll(0, Int32List.fromList(g));
  }

  /// invert FieldElement
  FieldElement invert() {
    var t0 = FieldElement(),
        t1 = FieldElement(),
        t2 = FieldElement(),
        t3 = FieldElement();
    var i = 0;

    t0 = square();
    t1 = t0.square();
    t1 = t1.square();
    t1 = this * t1;
    t0 = t0 * t1;
    t2 = t0.square();
    t1 = t1 * t2;
    t2 = t1.square();
    for (i = 1; i < 5; ++i) {
      t2 = t2.square();
    }
    t1 = t2 * t1;
    t2 = t1.square();
    for (i = 1; i < 10; ++i) {
      t2 = t2.square();
    }
    t2 = t2 * t1;
    t3 = t2.square();
    for (i = 1; i < 20; ++i) {
      t3 = t3.square();
    }
    t2 = t3 * t2;
    t2 = t2.square();
    for (i = 1; i < 10; ++i) {
      t2 = t2.square();
    }
    t1 = t1 * t2;
    t2 = t1.square();
    for (i = 1; i < 50; ++i) {
      t2 = t2.square();
    }
    t2 = t2 * t1;
    t3 = t2.square();
    for (i = 1; i < 100; ++i) {
      t3 = t3.square();
    }
    t2 = t3 * t2;
    t2 = t2.square();
    for (i = 1; i < 50; ++i) {
      t2 = t2.square();
    }
    t1 = t1 * t2;
    t1 = t1.square();
    for (i = 1; i < 5; ++i) {
      t1 = t1.square();
    }
    var out = FieldElement();
    out = t1 * t0;

    return out;
  }

  /// Check if FieldElement is reduced in byte representation
  bool isReduced(List<int> s) {
    var f = FieldElement.fromBytes(s);
    var strict = f.toBytes();

    return ListEquality<int>().equals(strict, s);
  }

  /// Edwards point to Montgomery X
  FieldElement montRHS() {
    var A = FieldElement.zero();
    var one = FieldElement.one();
    A[0] = 486662;
    var u2 = square();
    var Au = A * this;
    var inner = u2 + Au;
    inner = inner + one;
    return this * inner;
  }

  /// Tells whether the value is zero.
  bool get isZero => _data.every((element) => element == 0);

  /// return -FieldElement
  FieldElement neg() {
    var out = FieldElement();

    for (var i = 0; i < 10; i++) {
      out[i] = -_data[i];
    }
    return out;
  }

  /// fieldelement ^ 22523
  FieldElement pow22523() {
    var out = FieldElement(this);

    var t0 = out.square();
    for (var i = 1; i < 1; ++i) {
      t0 = t0.square();
    }

    var t1 = t0.square();
    for (var i = 1; i < 2; ++i) {
      t1 = t1.square();
    }

    t1 = this * t1;

    t0 = t0 * t1;

    t0 = t0.square();
    for (var i = 1; i < 1; ++i) {
      t0 = t0.square();
    }

    t0 = t1 * t0;

    t1 = t0.square();
    for (var i = 1; i < 5; ++i) {
      t1 = t1.square();
    }

    t0 = t1 * t0;

    t1 = t0.square();
    for (var i = 1; i < 10; ++i) {
      t1 = t1.square();
    }

    t1 = t1 * t0;

    var t2 = t1.square();
    for (var i = 1; i < 20; ++i) {
      t2 = t2.square();
    }

    t1 = t2 * t1;

    t1 = t1.square();
    for (var i = 1; i < 10; ++i) {
      t1 = t1.square();
    }

    t0 = t1 * t0;

    t1 = t0.square();
    for (var i = 1; i < 50; ++i) {
      t1 = t1.square();
    }

    t1 = t1 * t0;

    t2 = t1.square();
    for (var i = 1; i < 100; ++i) {
      t2 = t2.square();
    }

    t1 = t2 * t1;

    t1 = t1.square();
    for (var i = 1; i < 50; ++i) {
      t1 = t1.square();
    }

    t0 = t1 * t0;

    t0 = t0.square();
    for (var i = 1; i < 2; ++i) {
      t0 = t0.square();
    }

    out = t0 * out;

    return out;
  }

  /// FieldElement square
  FieldElement square() {
    var f0 = _data[0];
    var f1 = _data[1];
    var f2 = _data[2];
    var f3 = _data[3];
    var f4 = _data[4];
    var f5 = _data[5];
    var f6 = _data[6];
    var f7 = _data[7];
    var f8 = _data[8];
    var f9 = _data[9];
    var f0_2 = 2 * f0;
    var f1_2 = 2 * f1;
    var f2_2 = 2 * f2;
    var f3_2 = 2 * f3;
    var f4_2 = 2 * f4;
    var f5_2 = 2 * f5;
    var f6_2 = 2 * f6;
    var f7_2 = 2 * f7;
    var f5_38 = 38 * f5; /* 1.959375*2^30 */
    var f6_19 = 19 * f6; /* 1.959375*2^30 */
    var f7_38 = 38 * f7; /* 1.959375*2^30 */
    var f8_19 = 19 * f8; /* 1.959375*2^30 */
    var f9_38 = 38 * f9; /* 1.959375*2^30 */
    var f0f0 = f0 * f0;
    var f0f1_2 = f0_2 * f1;
    var f0f2_2 = f0_2 * f2;
    var f0f3_2 = f0_2 * f3;
    var f0f4_2 = f0_2 * f4;
    var f0f5_2 = f0_2 * f5;
    var f0f6_2 = f0_2 * f6;
    var f0f7_2 = f0_2 * f7;
    var f0f8_2 = f0_2 * f8;
    var f0f9_2 = f0_2 * f9;
    var f1f1_2 = f1_2 * f1;
    var f1f2_2 = f1_2 * f2;
    var f1f3_4 = f1_2 * f3_2;
    var f1f4_2 = f1_2 * f4;
    var f1f5_4 = f1_2 * f5_2;
    var f1f6_2 = f1_2 * f6;
    var f1f7_4 = f1_2 * f7_2;
    var f1f8_2 = f1_2 * f8;
    var f1f9_76 = f1_2 * f9_38;
    var f2f2 = f2 * f2;
    var f2f3_2 = f2_2 * f3;
    var f2f4_2 = f2_2 * f4;
    var f2f5_2 = f2_2 * f5;
    var f2f6_2 = f2_2 * f6;
    var f2f7_2 = f2_2 * f7;
    var f2f8_38 = f2_2 * f8_19;
    var f2f9_38 = f2 * f9_38;
    var f3f3_2 = f3_2 * f3;
    var f3f4_2 = f3_2 * f4;
    var f3f5_4 = f3_2 * f5_2;
    var f3f6_2 = f3_2 * f6;
    var f3f7_76 = f3_2 * f7_38;
    var f3f8_38 = f3_2 * f8_19;
    var f3f9_76 = f3_2 * f9_38;
    var f4f4 = f4 * f4;
    var f4f5_2 = f4_2 * f5;
    var f4f6_38 = f4_2 * f6_19;
    var f4f7_38 = f4 * f7_38;
    var f4f8_38 = f4_2 * f8_19;
    var f4f9_38 = f4 * f9_38;
    var f5f5_38 = f5 * f5_38;
    var f5f6_38 = f5_2 * f6_19;
    var f5f7_76 = f5_2 * f7_38;
    var f5f8_38 = f5_2 * f8_19;
    var f5f9_76 = f5_2 * f9_38;
    var f6f6_19 = f6 * f6_19;
    var f6f7_38 = f6 * f7_38;
    var f6f8_38 = f6_2 * f8_19;
    var f6f9_38 = f6 * f9_38;
    var f7f7_38 = f7 * f7_38;
    var f7f8_38 = f7_2 * f8_19;
    var f7f9_76 = f7_2 * f9_38;
    var f8f8_19 = f8 * f8_19;
    var f8f9_38 = f8 * f9_38;
    var f9f9_38 = f9 * f9_38;
    var h0 = f0f0 + f1f9_76 + f2f8_38 + f3f7_76 + f4f6_38 + f5f5_38;
    var h1 = f0f1_2 + f2f9_38 + f3f8_38 + f4f7_38 + f5f6_38;
    var h2 = f0f2_2 + f1f1_2 + f3f9_76 + f4f8_38 + f5f7_76 + f6f6_19;
    var h3 = f0f3_2 + f1f2_2 + f4f9_38 + f5f8_38 + f6f7_38;
    var h4 = f0f4_2 + f1f3_4 + f2f2 + f5f9_76 + f6f8_38 + f7f7_38;
    var h5 = f0f5_2 + f1f4_2 + f2f3_2 + f6f9_38 + f7f8_38;
    var h6 = f0f6_2 + f1f5_4 + f2f4_2 + f3f3_2 + f7f9_76 + f8f8_19;
    var h7 = f0f7_2 + f1f6_2 + f2f5_2 + f3f4_2 + f8f9_38;
    var h8 = f0f8_2 + f1f7_4 + f2f6_2 + f3f5_4 + f4f4 + f9f9_38;
    var h9 = f0f9_2 + f1f8_2 + f2f7_2 + f3f6_2 + f4f5_2;
    int carry0;
    int carry1;
    int carry2;
    int carry3;
    int carry4;
    int carry5;
    int carry6;
    int carry7;
    int carry8;
    int carry9;

    carry0 = (h0 + (1 << 25)) >> 26;
    h1 += carry0;
    h0 -= carry0 << 26;
    carry4 = (h4 + (1 << 25)) >> 26;
    h5 += carry4;
    h4 -= carry4 << 26;

    carry1 = (h1 + (1 << 24)) >> 25;
    h2 += carry1;
    h1 -= carry1 << 25;
    carry5 = (h5 + (1 << 24)) >> 25;
    h6 += carry5;
    h5 -= carry5 << 25;

    carry2 = (h2 + (1 << 25)) >> 26;
    h3 += carry2;
    h2 -= carry2 << 26;
    carry6 = (h6 + (1 << 25)) >> 26;
    h7 += carry6;
    h6 -= carry6 << 26;

    carry3 = (h3 + (1 << 24)) >> 25;
    h4 += carry3;
    h3 -= carry3 << 25;
    carry7 = (h7 + (1 << 24)) >> 25;
    h8 += carry7;
    h7 -= carry7 << 25;

    carry4 = (h4 + (1 << 25)) >> 26;
    h5 += carry4;
    h4 -= carry4 << 26;
    carry8 = (h8 + (1 << 25)) >> 26;
    h9 += carry8;
    h8 -= carry8 << 26;

    carry9 = (h9 + (1 << 24)) >> 25;
    h0 += carry9 * 19;
    h9 -= carry9 << 25;

    carry0 = (h0 + (1 << 25)) >> 26;
    h1 += carry0;
    h0 -= carry0 << 26;

    var h = FieldElement();
    h[0] = h0;
    h[1] = h1;
    h[2] = h2;
    h[3] = h3;
    h[4] = h4;
    h[5] = h5;
    h[6] = h6;
    h[7] = h7;
    h[8] = h8;
    h[9] = h9;

    return h;
  }

  /// FieldElement^2 * 2
  FieldElement square2() {
    var f0 = _data[0];
    var f1 = _data[1];
    var f2 = _data[2];
    var f3 = _data[3];
    var f4 = _data[4];
    var f5 = _data[5];
    var f6 = _data[6];
    var f7 = _data[7];
    var f8 = _data[8];
    var f9 = _data[9];
    var f0_2 = 2 * f0;
    var f1_2 = 2 * f1;
    var f2_2 = 2 * f2;
    var f3_2 = 2 * f3;
    var f4_2 = 2 * f4;
    var f5_2 = 2 * f5;
    var f6_2 = 2 * f6;
    var f7_2 = 2 * f7;
    var f5_38 = 38 * f5; /* 1.959375*2^30 */
    var f6_19 = 19 * f6; /* 1.959375*2^30 */
    var f7_38 = 38 * f7; /* 1.959375*2^30 */
    var f8_19 = 19 * f8; /* 1.959375*2^30 */
    var f9_38 = 38 * f9; /* 1.959375*2^30 */
    var f0f0 = f0 * f0;
    var f0f1_2 = f0_2 * f1;
    var f0f2_2 = f0_2 * f2;
    var f0f3_2 = f0_2 * f3;
    var f0f4_2 = f0_2 * f4;
    var f0f5_2 = f0_2 * f5;
    var f0f6_2 = f0_2 * f6;
    var f0f7_2 = f0_2 * f7;
    var f0f8_2 = f0_2 * f8;
    var f0f9_2 = f0_2 * f9;
    var f1f1_2 = f1_2 * f1;
    var f1f2_2 = f1_2 * f2;
    var f1f3_4 = f1_2 * f3_2;
    var f1f4_2 = f1_2 * f4;
    var f1f5_4 = f1_2 * f5_2;
    var f1f6_2 = f1_2 * f6;
    var f1f7_4 = f1_2 * f7_2;
    var f1f8_2 = f1_2 * f8;
    var f1f9_76 = f1_2 * f9_38;
    var f2f2 = f2 * f2;
    var f2f3_2 = f2_2 * f3;
    var f2f4_2 = f2_2 * f4;
    var f2f5_2 = f2_2 * f5;
    var f2f6_2 = f2_2 * f6;
    var f2f7_2 = f2_2 * f7;
    var f2f8_38 = f2_2 * f8_19;
    var f2f9_38 = f2 * f9_38;
    var f3f3_2 = f3_2 * f3;
    var f3f4_2 = f3_2 * f4;
    var f3f5_4 = f3_2 * f5_2;
    var f3f6_2 = f3_2 * f6;
    var f3f7_76 = f3_2 * f7_38;
    var f3f8_38 = f3_2 * f8_19;
    var f3f9_76 = f3_2 * f9_38;
    var f4f4 = f4 * f4;
    var f4f5_2 = f4_2 * f5;
    var f4f6_38 = f4_2 * f6_19;
    var f4f7_38 = f4 * f7_38;
    var f4f8_38 = f4_2 * f8_19;
    var f4f9_38 = f4 * f9_38;
    var f5f5_38 = f5 * f5_38;
    var f5f6_38 = f5_2 * f6_19;
    var f5f7_76 = f5_2 * f7_38;
    var f5f8_38 = f5_2 * f8_19;
    var f5f9_76 = f5_2 * f9_38;
    var f6f6_19 = f6 * f6_19;
    var f6f7_38 = f6 * f7_38;
    var f6f8_38 = f6_2 * f8_19;
    var f6f9_38 = f6 * f9_38;
    var f7f7_38 = f7 * f7_38;
    var f7f8_38 = f7_2 * f8_19;
    var f7f9_76 = f7_2 * f9_38;
    var f8f8_19 = f8 * f8_19;
    var f8f9_38 = f8 * f9_38;
    var f9f9_38 = f9 * f9_38;
    var h0 = f0f0 + f1f9_76 + f2f8_38 + f3f7_76 + f4f6_38 + f5f5_38;
    var h1 = f0f1_2 + f2f9_38 + f3f8_38 + f4f7_38 + f5f6_38;
    var h2 = f0f2_2 + f1f1_2 + f3f9_76 + f4f8_38 + f5f7_76 + f6f6_19;
    var h3 = f0f3_2 + f1f2_2 + f4f9_38 + f5f8_38 + f6f7_38;
    var h4 = f0f4_2 + f1f3_4 + f2f2 + f5f9_76 + f6f8_38 + f7f7_38;
    var h5 = f0f5_2 + f1f4_2 + f2f3_2 + f6f9_38 + f7f8_38;
    var h6 = f0f6_2 + f1f5_4 + f2f4_2 + f3f3_2 + f7f9_76 + f8f8_19;
    var h7 = f0f7_2 + f1f6_2 + f2f5_2 + f3f4_2 + f8f9_38;
    var h8 = f0f8_2 + f1f7_4 + f2f6_2 + f3f5_4 + f4f4 + f9f9_38;
    var h9 = f0f9_2 + f1f8_2 + f2f7_2 + f3f6_2 + f4f5_2;

    h0 += h0;
    h1 += h1;
    h2 += h2;
    h3 += h3;
    h4 += h4;
    h5 += h5;
    h6 += h6;
    h7 += h7;
    h8 += h8;
    h9 += h9;

    var carry0 = (h0 + (1 << 25)) >> 26;
    h1 += carry0;
    h0 -= carry0 << 26;
    var carry4 = (h4 + (1 << 25)) >> 26;
    h5 += carry4;
    h4 -= carry4 << 26;

    var carry1 = (h1 + (1 << 24)) >> 25;
    h2 += carry1;
    h1 -= carry1 << 25;
    var carry5 = (h5 + (1 << 24)) >> 25;
    h6 += carry5;
    h5 -= carry5 << 25;

    var carry2 = (h2 + (1 << 25)) >> 26;
    h3 += carry2;
    h2 -= carry2 << 26;
    var carry6 = (h6 + (1 << 25)) >> 26;
    h7 += carry6;
    h6 -= carry6 << 26;

    var carry3 = (h3 + (1 << 24)) >> 25;
    h4 += carry3;
    h3 -= carry3 << 25;
    var carry7 = (h7 + (1 << 24)) >> 25;
    h8 += carry7;
    h7 -= carry7 << 25;

    carry4 = (h4 + (1 << 25)) >> 26;
    h5 += carry4;
    h4 -= carry4 << 26;
    var carry8 = (h8 + (1 << 25)) >> 26;
    h9 += carry8;
    h8 -= carry8 << 26;

    var carry9 = (h9 + (1 << 24)) >> 25;
    h0 += carry9 * 19;
    h9 -= carry9 << 25;

    carry0 = (h0 + (1 << 25)) >> 26;
    h1 += carry0;
    h0 -= carry0 << 26;

    var h = FieldElement();
    h[0] = h0;
    h[1] = h1;
    h[2] = h2;
    h[3] = h3;
    h[4] = h4;
    h[5] = h5;
    h[6] = h6;
    h[7] = h7;
    h[8] = h8;
    h[9] = h9;

    return h;
  }

  /// Square root
  /// return null if error
  FieldElement? sqrt() {
    var out = FieldElement();
    var i = FieldElement.fromBytes(Constants.iBytes);

    var exp = pow22523();
    var legendre = exp.square();
    legendre = legendre.square();
    legendre = legendre * this;
    legendre = legendre * this;

    if (!(legendre == FieldElement.zero()) &&
        !(legendre == FieldElement.one())) {
      return null;
    }

    var b = this * exp;
    var b2 = b.square();
    var bi = b * i;

    var isEqual = 0;
    if (b2 == this) {
      isEqual = 1;
    }
    b.cmov(bi, 1 ^ isEqual);

    for (var j = 0; j < 10; j++) {
      out[j] = b[j];
    }

    b2 = square();

    if (this == b2) {
      return null;
    }

    return out;
  }

  /// Represent FieldElement as bytes
  List<int> toBytes() {
    var a = _data;

    var q = (19 * a[9] + (1 << 24)) >> 25;

    for (var i = 0; i < 10; i++) {
      if (i % 2 == 1) {
        q = (a[i] + q) >> 25;
        continue;
      }
      q = (a[i] + q) >> 26;
    }

    a[0] += 19 * q;

    var carry = List<int>.generate(
      10,
      (_) => 0,
      growable: false,
    );

    for (var i = 0; i < 10; i++) {
      if (i % 2 == 1) {
        carry[i] = a[i] >> 25;
        if (i < 9) {
          a[i + 1] += carry[i];
        }
        a[i] -= carry[i] << 25;
        continue;
      }
      carry[i] = a[i] >> 26;
      a[i + 1] += carry[i];
      a[i] -= carry[i] << 26;
    }

    var h = Int8List(32);

    h[0] = a[0] >> 0;
    h[1] = a[0] >> 8;
    h[2] = a[0] >> 16;
    h[3] = (a[0] >> 24) | (a[1] << 2);
    h[4] = a[1] >> 6;
    h[5] = a[1] >> 14;
    h[6] = (a[1] >> 22) | (a[2] << 3);
    h[7] = a[2] >> 5;
    h[8] = a[2] >> 13;
    h[9] = (a[2] >> 21) | (a[3] << 5);
    h[10] = a[3] >> 3;
    h[11] = a[3] >> 11;
    h[12] = (a[3] >> 19) | (a[4] << 6);
    h[13] = a[4] >> 2;
    h[14] = a[4] >> 10;
    h[15] = a[4] >> 18;
    h[16] = a[5] >> 0;
    h[17] = a[5] >> 8;
    h[18] = a[5] >> 16;
    h[19] = (a[5] >> 24) | (a[6] << 1);
    h[20] = a[6] >> 7;
    h[21] = a[6] >> 15;
    h[22] = (a[6] >> 23) | (a[7] << 3);
    h[23] = a[7] >> 5;
    h[24] = a[7] >> 13;
    h[25] = (a[7] >> 21) | (a[8] << 4);
    h[26] = a[8] >> 4;
    h[27] = a[8] >> 12;
    h[28] = (a[8] >> 20) | (a[9] << 6);
    h[29] = a[9] >> 2;
    h[30] = a[9] >> 10;
    h[31] = a[9] >> 18;

    return h;
  }

  /// Montgomery X to Edwards Y
  FieldElement toEdY() {
    var one = FieldElement.one();

    var um1 = this - one;
    var up1 = this + one;
    up1 = up1.invert();

    return um1 * up1;
  }

  /// Field Element isNegative
  bool isNegative() {
    var copy = FieldElement()..insertAll(0, this);
    var s = copy.toBytes();
    return s[0] & 1 == 1;
  }

  /// Check if Legendre Polynomial of Field Element is non square
  int legendreIsNonSquare() {
    var temp = pow22523();
    temp = temp.square();
    temp = temp.square();
    temp = temp * this;
    temp = temp * this;

    var bytes = temp.toBytes();

    return 1 & bytes[31];
  }

  /// Convert montgomery X point to Extended Group Element
  ExtendedGroupElement montXToExtended(int signBit) {
    var A = FieldElement.fromBytes(Constants.aBytes);
    var y = toEdY();

    var v2 = montRHS();
    var v = v2.sqrt()!;
    var x = A * this;
    var iv = v.invert();
    x = x * iv;

    var nx = x.neg();
    var isNegative = 0;
    if (x.isNegative()) {
      isNegative = 1;
    }
    x.cmov(nx, isNegative ^ signBit);

    return ExtendedGroupElement(x, y, FieldElement.one(), x * y);
  }
}

/// Group Element Representations:
/// Members of the -x^2 + y^2 = 1 + d *x^2 * y^2 ec curve
/// d = -121665/121666

/// Gr P2 element
/// (X, Y, Z) satisfy x=X/Z, y=Y/Z
class ProjectiveGroupElement {
  /// `0`.
  factory ProjectiveGroupElement.zero() {
    return ProjectiveGroupElement(
        FieldElement.zero(), FieldElement.one(), FieldElement.one());
  }

  FieldElement X, Y, Z;

  ProjectiveGroupElement([FieldElement? X, FieldElement? Y, FieldElement? Z])
      : X = X ?? FieldElement(),
        Y = Y ?? FieldElement(),
        Z = Z ?? FieldElement();

  /// Multiply ExtendedGroupElement by Scalar and store in Projective Group Element
  ProjectiveGroupElement scalarMult(
      List<int> a, ExtendedGroupElement A, List<int> b) {
    var out = ProjectiveGroupElement.zero();

    var Ai = List<CachedGroupElement>.generate(
      8,
      (_) => CachedGroupElement.zero(),
      growable: false,
    );
    for (var count = 0; count < 8; count++) {
      Ai[count] = CachedGroupElement();
    }
    var t = CompletedGroupElement();
    var u = ExtendedGroupElement();
    var A2 = ExtendedGroupElement();

    var aSlide = slide(a);
    var bSlide = slide(b);

    Ai[0] = CachedGroupElement.fromExtended(A);
    t = A.dblToCompleted();
    A2 = t.toExtended();
    t = A2 + Ai[0];
    u = t.toExtended();
    Ai[1] = u.toCached();
    t = A2 + Ai[1];
    u = t.toExtended();
    Ai[2] = u.toCached();
    t = A2 + Ai[2];
    u = t.toExtended();
    Ai[3] = u.toCached();
    t = A2 + Ai[3];
    u = t.toExtended();
    Ai[4] = u.toCached();
    t = A2 + Ai[4];
    u = t.toExtended();
    Ai[5] = u.toCached();
    t = A2 + Ai[5];
    u = t.toExtended();
    Ai[6] = u.toCached();
    t = A2 + Ai[6];
    u = t.toExtended();
    Ai[7] = u.toCached();

    var i = 0;

    for (i = 255; i >= 0; i--) {
      if (aSlide[i] != 0 || bSlide[i] != 0) break;
    }

    for (; i >= 0; i--) {
      t = out.dblToCompleted();

      if (aSlide[i] > 0) {
        u = t.toExtended();
        t = u + Ai[(aSlide[i] / 2).floor()];
      } else if (aSlide[i] < 0) {
        u = t.toExtended();
        t = u - Ai[((-aSlide[i]) / 2).floor()];
      }

      if (bSlide[i] > 0) {
        u = t.toExtended();
        t = t.mAdd(u, Constants.bi[(bSlide[i] / 2).floor()]);
      } else if (bSlide[i] < 0) {
        u = t.toExtended();
        t = t.mSub(u, Constants.bi[((-bSlide[i]) / 2).floor()]);
      }

      out = t.toProjective();
    }
    return out;
  }

  /// Convert List<int> to 256-bit array
  Int8List slide(List<int> a) {
    var r = Int8List(256);

    for (var i = 0; i < 256; i++) {
      r[i] = (1 & (a[i >> 3] / pow(2, i & 7)).floor());
    }

    for (var i = 0; i < 256; i++) {
      if (r[i] != 0) {
        for (var b = 1; b <= 6 && i + b < 256; b++) {
          if (r[i + b] != 0) {
            if (r[i] + (r[i + b] << b) <= 15) {
              r[i] += r[i + b] << b;
              r[i + b] = 0;
            } else if (r[i] - (r[i + b] << b) >= -15) {
              r[i] -= r[i + b] << b;
              for (var k = i + b; k < 256; k++) {
                if (r[k] == 0) {
                  r[k] = 1;
                  break;
                }
                r[k] = 0;
              }
            } else {
              break;
            }
          }
        }
      }
    }
    return r;
  }

  /// Projective Group Element to Completed
  CompletedGroupElement dblToCompleted() {
    var out = CompletedGroupElement();

    out.X = X.square();
    out.Z.insertAll(0, Y.square());
    out.T.insertAll(0, Z.square2());
    out.Y.insertAll(0, X + Y);

    var t0 = out.Y.square();

    out.Y.insertAll(0, out.Z + out.X);
    out.Z.insertAll(0, out.Z - out.X);
    out.X.insertAll(0, t0 - out.Y);
    out.T.insertAll(0, out.T - out.Z);

    return out;
  }

  /// Projective to Bytes
  List<int> toBytes() {
    var reciprocal = Z.invert();

    var x = X * reciprocal;
    var y = Y * reciprocal;

    var bytes = y.toBytes();

    var isNegative = 0;
    if (x.isNegative()) {
      isNegative = 1;
    }
    bytes[31] ^= isNegative << 7;

    return bytes;
  }
}

/// Gr P3 element
/// (X, Y, Z, T) satisfy x=X/Z, y=Y/Z, XY=ZT
class ExtendedGroupElement {
  /// '0'
  factory ExtendedGroupElement.zero() {
    return ExtendedGroupElement(FieldElement.zero(), FieldElement.one(),
        FieldElement.one(), FieldElement.zero());
  }

  FieldElement X, Y, Z, T;

  ExtendedGroupElement(
      [FieldElement? X, FieldElement? Y, FieldElement? Z, FieldElement? T])
      : X = X ?? FieldElement(),
        Y = Y ?? FieldElement(),
        Z = Z ?? FieldElement(),
        T = T ?? FieldElement();

  /// Instantiate from Bytes and Negate
  static ExtendedGroupElement? fromBytesNeg(List<int> bytes) {
    var out = ExtendedGroupElement();

    out.Y.insertAll(0, FieldElement.fromBytes(bytes));
    out.Z.insertAll(0, FieldElement.one());

    var u = out.Y.square();
    var v = u * Constants.d;
    u = u - out.Z;
    v = v + out.Z;

    var v3 = v.square();
    v3 = v3 * v;
    out.X.insertAll(0, v3.square());
    out.X.insertAll(0, out.X * v);
    out.X.insertAll(0, out.X * u);
    out.X.insertAll(0, out.X.pow22523());
    out.X.insertAll(0, out.X * v3);
    out.X.insertAll(0, out.X * u);

    var vxx = out.X.square();
    vxx = vxx * v;

    var check = vxx - u;

    if (!check.isZero) {
      check = vxx + u;
      if (!check.isZero) {
        return null;
      }
      out.X.insertAll(0, out.X * Constants.sqrtm1);
    }

    var isNegative = 0;
    if (out.X.isNegative()) {
      isNegative = 1;
    }

    if (isNegative == (bytes[31] >> 7) & 0x01) {
      out.X.insertAll(0, out.X.neg());
    }
    out.T.insertAll(0, out.X * out.Y);

    return out;
  }

  /// Multiply Scalar by 25519 Base point and store in Extended Group Element
  factory ExtendedGroupElement.scalarMultBase(List<int> a) {
    var e = Int8List(64);
    var r = CompletedGroupElement();
    var s = ProjectiveGroupElement();
    var t = PreComputedGroupElement();

    for (var i = 0; i < 32; ++i) {
      e[2 * i + 0] = a[i] & 15;
      e[2 * i + 1] = (a[i] >> 4) & 15;
    }
    var carry = 0;
    for (var i = 0; i < 63; ++i) {
      e[i] += carry;
      carry = e[i] + 8;
      carry >>= 4;
      e[i] -= carry << 4;
    }
    e[63] += carry;

    var h = ExtendedGroupElement.zero();
    for (var i = 1; i < 64; i += 2) {
      t = t.select((i / 2).floor(), e[i]);
      r = r.mAdd(h, t);
      h = r.toExtended();
    }

    r = h.dblToCompleted();
    s = r.toProjective();
    r = s.dblToCompleted();
    s = r.toProjective();
    r = s.dblToCompleted();
    s = r.toProjective();
    r = s.dblToCompleted();
    h = r.toExtended();

    for (var i = 0; i < 64; i += 2) {
      t = t.select((i / 2).floor(), e[i]);
      r = r.mAdd(h, t);
      h = r.toExtended();
    }
    return h;
  }

  /// Add Cached GE to Extended GE and return Completed GE
  CompletedGroupElement operator +(CachedGroupElement other) {
    var out = CompletedGroupElement();

    out.X.insertAll(0, Y + X);
    out.Y.insertAll(0, Y - X);
    out.Z.insertAll(0, out.X * other.yPlusX);
    out.Y.insertAll(0, out.Y * other.yMinusX);
    out.T.insertAll(0, T * other.T2d);
    out.X.insertAll(0, Z * other.Z);

    var t0 = out.X + out.X;

    out.X.insertAll(0, out.Z - out.Y);
    out.Y.insertAll(0, out.Z + out.Y);
    out.Z.insertAll(0, t0 + out.T);
    out.T.insertAll(0, t0 - out.T);

    return out;
  }

  /// subtract Cached GE from Extended GE and return Completed GE
  CompletedGroupElement operator -(CachedGroupElement other) {
    var out = CompletedGroupElement();

    out.X.insertAll(0, Y + X);
    out.Y.insertAll(0, Y - X);
    out.Z.insertAll(0, out.X * other.yMinusX);
    out.Y.insertAll(0, out.Y * other.yPlusX);
    out.T.insertAll(0, T * other.T2d);
    out.X.insertAll(0, Z * other.Z);

    var t0 = out.X + out.X;

    out.X.insertAll(0, out.Z - out.Y);
    out.Y.insertAll(0, out.Z + out.Y);
    out.Z.insertAll(0, t0 - out.T);
    out.T.insertAll(0, t0 + out.T);

    return out;
  }

  /// Add 2 Extended Group Elements
  ExtendedGroupElement add(ExtendedGroupElement other) {
    var cached = toCached();
    var p1p1 = other + cached;
    return p1p1.toExtended();
  }

  /// Choose Extended Group Element depending on int b
  /// if b == 1:
  ///   move u to this
  /// if b == 0:
  ///   do nothing
  void cmovExtended(ExtendedGroupElement u, int b) {
    X.cmov(u.X, b);
    Y.cmov(u.Y, b);
    Z.cmov(u.Z, b);
    T.cmov(u.T, b);
  }

  /// Extended GE to Completed
  CompletedGroupElement dblToCompleted() {
    var b = toProjective();
    return b.dblToCompleted();
  }

  /// Negate GE
  ExtendedGroupElement neg() {
    var out = ExtendedGroupElement();

    out.X = X.neg();
    out.Y.insertAll(0, Y);
    out.Z.insertAll(0, Z);
    out.T = T.neg();

    return out;
  }

  /// Extended GE to bytes
  Int8List toBytes() {
    var recip = FieldElement();
    var x = FieldElement();
    var y = FieldElement();

    recip = Z.invert();
    x = X * recip;
    y = Y * recip;
    var s = y.toBytes();

    var isNeg = 0;
    if (x.isNegative()) {
      isNeg = 1;
    }

    s[31] ^= isNeg << 7;

    return s as Int8List;
  }

  /// Extended GE to Cached GE
  CachedGroupElement toCached() {
    var out = CachedGroupElement();

    out.yPlusX.insertAll(0, Y + X);
    out.yMinusX.insertAll(0, Y - X);
    out.Z.insertAll(0, Z);
    out.T2d = T * Constants.d2;

    return out;
  }

  /// Extended GE to projective GE
  ProjectiveGroupElement toProjective() {
    return ProjectiveGroupElement(X, Y, Z);
  }

  /// Multiply Scalar a with Extended GE A and store in Extended GE
  ExtendedGroupElement scalarMult(List<int?> a, ExtendedGroupElement A) {
    var q = ExtendedGroupElement.zero();
    var p = ExtendedGroupElement();
    var t = ExtendedGroupElement();

    var c = CachedGroupElement();
    var t0 = CompletedGroupElement();

    p.T.insertAll(0, A.T);
    p.X.insertAll(0, A.X);
    p.Y.insertAll(0, A.Y);
    p.Z.insertAll(0, A.Z);

    var bit = 0;

    for (var i = 0; i < 256; i++) {
      bit = ((a[i >> 3]! >> (i & 7)) & 1);

      c = q.toCached();
      t0 = p + c;
      t = t0.toExtended();

      q.cmovExtended(t, bit);
      var p1 = p.dblToCompleted();
      p = p1.toExtended();
    }

    return q;
  }

  /// Check if Extended Group Element is Neutral Point
  /// Neutral Point where X == FieldElement.zero() and Y == Z
  bool isNeutral() {
    var zero = FieldElement.zero();

    return (X == zero && Y == Z);
  }

  /// Scalar Multiplication
  ExtendedGroupElement scalarMultCofactor() {
    var p1p1 = dblToCompleted();
    var p2 = p1p1.toProjective();

    p1p1 = p2.dblToCompleted();
    p2 = p1p1.toProjective();

    p1p1 = p2.dblToCompleted();
    return p1p1.toExtended();
  }
}

/// Gr P1P1 element
/// ((X,Z), (Y,T)) satisfy x=X/Z, y=Y/T
class CompletedGroupElement {
  factory CompletedGroupElement.zero() {
    return CompletedGroupElement(FieldElement.zero(), FieldElement.zero(),
        FieldElement.zero(), FieldElement.zero());
  }

  FieldElement X, Y, Z, T;

  CompletedGroupElement(
      [FieldElement? X, FieldElement? Y, FieldElement? Z, FieldElement? T])
      : X = X ?? FieldElement(),
        Y = Y ?? FieldElement(),
        Z = Z ?? FieldElement(),
        T = T ?? FieldElement();

  /// Mixed Add
  CompletedGroupElement mAdd(
      ExtendedGroupElement a, PreComputedGroupElement b) {
    var out = CompletedGroupElement(X, Y, Z, T);
    var t0 = FieldElement();

    out.X = a.Y + a.X;
    out.Y = a.Y - a.X;
    out.Z = out.X * b.yPlusX;
    out.Y = out.Y * b.yMinusX;
    out.T = b.xy2d * a.T;

    t0 = a.Z + a.Z;

    out.X = out.Z - out.Y;
    out.Y = out.Z + out.Y;
    out.Z = t0 + out.T;
    out.T = t0 - out.T;

    return out;
  }

  /// Completed GE to Extended GE
  ExtendedGroupElement toExtended() {
    var out = ExtendedGroupElement();
    out.X = X * T;
    out.Y = Y * Z;
    out.Z = Z * T;
    out.T = X * Y;
    return out;
  }

  /// Completed GE to Projective GE
  ProjectiveGroupElement toProjective() {
    var out = ProjectiveGroupElement();
    out.X = X * T;
    out.Y = Y * Z;
    out.Z = Z * T;
    return out;
  }

  /// Mixed Subtraction
  CompletedGroupElement mSub(
      ExtendedGroupElement p, PreComputedGroupElement q) {
    var out = CompletedGroupElement();

    out.X.insertAll(0, p.X + p.Y);
    out.Y.insertAll(0, p.Y - p.X);
    out.Z.insertAll(0, out.X * q.yMinusX);
    out.Y.insertAll(0, out.Y * q.yPlusX);
    out.T.insertAll(0, p.T * q.xy2d);

    var t0 = p.Z + p.Z;

    out.X.insertAll(0, out.Z - out.Y);
    out.Y.insertAll(0, out.Z + out.Y);
    out.Z.insertAll(0, t0 - out.T);
    out.T.insertAll(0, t0 + out.T);

    return out;
  }
}

/// Precomputed Group Element
/// (y+x, y-x, 2dxy)
class PreComputedGroupElement {
  factory PreComputedGroupElement.zero() {
    return PreComputedGroupElement(
        FieldElement.one(), FieldElement.one(), FieldElement.zero());
  }

  FieldElement yPlusX, yMinusX, xy2d;

  PreComputedGroupElement(
      [FieldElement? yPlusX, FieldElement? yMinusX, FieldElement? xy2d])
      : yPlusX = yPlusX ?? FieldElement(),
        yMinusX = yMinusX ?? FieldElement(),
        xy2d = xy2d ?? FieldElement();

  /// Scalar Mult Base helper function
  PreComputedGroupElement select(int pos, int b) {
    var out = PreComputedGroupElement.zero();
    var negT = PreComputedGroupElement();
    var negB = negative(b);
    var babs = (b - (((-negB) & b) << 1));

    for (var i = 0; i < 8; i++) {
      out.cmov(Constants.base[pos][i], equals(babs, i + 1));
    }
    for (var i = 0; i < 10; i++) {
      negT.yPlusX[i] = out.yMinusX[i];
      negT.yMinusX[i] = out.yPlusX[i];
      negT.xy2d[i] = -out.xy2d[i];
    }
    out.cmov(negT, negB);
    return out;
  }

  /// Scalar Mult Base helper function
  void cmov(PreComputedGroupElement u, int b) {
    yPlusX.cmov(u.yPlusX, b);
    yMinusX.cmov(u.yMinusX, b);
    xy2d.cmov(u.xy2d, b);
  }

  /// Scalar Mult Base helper function
  int negative(int b) {
    return (b >> 63) & 0x01;
  }

  /// Scalar Mult Base helper function
  int equals(int b, int c) {
    var x = b ^ c;
    x--;
    return (x >> 63) & 0x01;
  }
}

/// Cached Group Element
class CachedGroupElement {
  factory CachedGroupElement.zero() {
    return CachedGroupElement(FieldElement.zero(), FieldElement.zero(),
        FieldElement.zero(), FieldElement.zero());
  }

  FieldElement yPlusX, yMinusX, Z, T2d;

  CachedGroupElement(
      [FieldElement? yPlusX,
      FieldElement? yMinusX,
      FieldElement? Z,
      FieldElement? T2d])
      : yPlusX = yPlusX ?? FieldElement(),
        yMinusX = yMinusX ?? FieldElement(),
        Z = Z ?? FieldElement(),
        T2d = T2d ?? FieldElement();

  /// Instantiate Cached GE from Extended GE
  factory CachedGroupElement.fromExtended(ExtendedGroupElement a) {
    var out = CachedGroupElement();
    out.yPlusX = a.Y + a.X;
    out.yMinusX = a.Y - a.X;
    out.Z.insertAll(0, a.Z);
    out.T2d = a.T * Constants.d2;

    return out;
  }
}

/// Store Scalars with byte array representation
class Scalar extends UnmodifiableInt8ListView {
  Int8List _data;
  final int _length;

  Int8List get data => _data;

  Scalar([List<int>? list, int? length])
      : _data = Int8List.fromList(list ?? Int8List(64)),
        _length = length ?? 64,
        super(Int8List.fromList(list ?? Int8List(64)));

  /// Get index in Scalar
  @override
  int operator [](int index) {
    assert(index < _data.length);
    return _data.elementAt(index);
  }

  /// Set index in Scalar
  @override
  void operator []=(int index, int element) {
    assert(index < _length);
    var data = List<int>.from(_data);
    data.insert(index, element);
    _data = Int8List.fromList(data);
  }

  /// Insert iterable into Scalar at index
  @override
  void insertAll(int index, Iterable<int> iterable) {
    assert(index + iterable.length <= _length);
    var data = List<int>.from(_data);
    data.insertAll(index, iterable);
    _data = Int8List.fromList(data);
  }

  /// Choose move for Scalar
  /// if b == 1:
  ///   store this in a
  /// if b == 0:
  ///   do nothing
  void cmov(Scalar a, int b) {
    var count = 32;
    var x = Int8List(32);
    b = -b;
    for (count = 0; count < 32; count++) {
      x[count] = _data[count] ^ a[count];
      x[count] &= b;
      _data[count] = _data[count] ^ x[count];
    }
  }

  /// reduction helper function
  /// convert bytes to int64
  int load3(List<int> bytesIn, int index) {
    var result = bytesIn[index + 0] & 0xFF;
    result |= (bytesIn[index + 1] << 8) & 0xFF00;
    result |= (bytesIn[index + 2] << 16) & 0xFF0000;
    return result;
  }

  /// reduction helper function
  /// convert bytes to int64
  int load4(List<int> bytesIn, int index) {
    var result = bytesIn[index + 0] & 0xFF;
    result |= (bytesIn[index + 1] << 8) & 0xFF00;
    result |= (bytesIn[index + 2] << 16) & 0xFF0000;
    result |= (bytesIn[index + 3] << 24) & 0xFF000000;
    return result;
  }

  /// reduce Scalar to 512 bits
  List<int> reduction() {
    var s0 = 2097151 & load3(_data, 0);
    var s1 = 2097151 & (load4(_data, 2) >> 5);
    var s2 = 2097151 & (load3(_data, 5) >> 2);
    var s3 = 2097151 & (load4(_data, 7) >> 7);
    var s4 = 2097151 & (load4(_data, 10) >> 4);
    var s5 = 2097151 & (load3(_data, 13) >> 1);
    var s6 = 2097151 & (load4(_data, 15) >> 6);
    var s7 = 2097151 & (load3(_data, 18) >> 3);
    var s8 = 2097151 & load3(_data, 21);
    var s9 = 2097151 & (load4(_data, 23) >> 5);
    var s10 = 2097151 & (load3(_data, 26) >> 2);
    var s11 = 2097151 & (load4(_data, 28) >> 7);
    var s12 = 2097151 & (load4(_data, 31) >> 4);
    var s13 = 2097151 & (load3(_data, 34) >> 1);
    var s14 = 2097151 & (load4(_data, 36) >> 6);
    var s15 = 2097151 & (load3(_data, 39) >> 3);
    var s16 = 2097151 & load3(_data, 42);
    var s17 = 2097151 & (load4(_data, 44) >> 5);
    var s18 = 2097151 & (load3(_data, 47) >> 2);
    var s19 = 2097151 & (load4(_data, 49) >> 7);
    var s20 = 2097151 & (load4(_data, 52) >> 4);
    var s21 = 2097151 & (load3(_data, 55) >> 1);
    var s22 = 2097151 & (load4(_data, 57) >> 6);
    var s23 = (load4(_data, 60) >> 3);

    s11 += s23 * 666643;
    s12 += s23 * 470296;
    s13 += s23 * 654183;
    s14 -= s23 * 997805;
    s15 += s23 * 136657;
    s16 -= s23 * 683901;
    s23 = 0;

    s10 += s22 * 666643;
    s11 += s22 * 470296;
    s12 += s22 * 654183;
    s13 -= s22 * 997805;
    s14 += s22 * 136657;
    s15 -= s22 * 683901;
    s22 = 0;

    s9 += s21 * 666643;
    s10 += s21 * 470296;
    s11 += s21 * 654183;
    s12 -= s21 * 997805;
    s13 += s21 * 136657;
    s14 -= s21 * 683901;
    s21 = 0;

    s8 += s20 * 666643;
    s9 += s20 * 470296;
    s10 += s20 * 654183;
    s11 -= s20 * 997805;
    s12 += s20 * 136657;
    s13 -= s20 * 683901;
    s20 = 0;

    s7 += s19 * 666643;
    s8 += s19 * 470296;
    s9 += s19 * 654183;
    s10 -= s19 * 997805;
    s11 += s19 * 136657;
    s12 -= s19 * 683901;
    s19 = 0;

    s6 += s18 * 666643;
    s7 += s18 * 470296;
    s8 += s18 * 654183;
    s9 -= s18 * 997805;
    s10 += s18 * 136657;
    s11 -= s18 * 683901;
    s18 = 0;

    var carry6 = (s6 + (1 << 20)) >> 21;
    s7 += carry6;
    s6 -= carry6 << 21;
    var carry8 = (s8 + (1 << 20)) >> 21;
    s9 += carry8;
    s8 -= carry8 << 21;
    var carry10 = (s10 + (1 << 20)) >> 21;
    s11 += carry10;
    s10 -= carry10 << 21;
    var carry12 = (s12 + (1 << 20)) >> 21;
    s13 += carry12;
    s12 -= carry12 << 21;
    var carry14 = (s14 + (1 << 20)) >> 21;
    s15 += carry14;
    s14 -= carry14 << 21;
    var carry16 = (s16 + (1 << 20)) >> 21;
    s17 += carry16;
    s16 -= carry16 << 21;

    var carry7 = (s7 + (1 << 20)) >> 21;
    s8 += carry7;
    s7 -= carry7 << 21;
    var carry9 = (s9 + (1 << 20)) >> 21;
    s10 += carry9;
    s9 -= carry9 << 21;
    var carry11 = (s11 + (1 << 20)) >> 21;
    s12 += carry11;
    s11 -= carry11 << 21;
    var carry13 = (s13 + (1 << 20)) >> 21;
    s14 += carry13;
    s13 -= carry13 << 21;
    var carry15 = (s15 + (1 << 20)) >> 21;
    s16 += carry15;
    s15 -= carry15 << 21;

    s5 += s17 * 666643;
    s6 += s17 * 470296;
    s7 += s17 * 654183;
    s8 -= s17 * 997805;
    s9 += s17 * 136657;
    s10 -= s17 * 683901;
    s17 = 0;

    s4 += s16 * 666643;
    s5 += s16 * 470296;
    s6 += s16 * 654183;
    s7 -= s16 * 997805;
    s8 += s16 * 136657;
    s9 -= s16 * 683901;
    s16 = 0;

    s3 += s15 * 666643;
    s4 += s15 * 470296;
    s5 += s15 * 654183;
    s6 -= s15 * 997805;
    s7 += s15 * 136657;
    s8 -= s15 * 683901;
    s15 = 0;

    s2 += s14 * 666643;
    s3 += s14 * 470296;
    s4 += s14 * 654183;
    s5 -= s14 * 997805;
    s6 += s14 * 136657;
    s7 -= s14 * 683901;
    s14 = 0;

    s1 += s13 * 666643;
    s2 += s13 * 470296;
    s3 += s13 * 654183;
    s4 -= s13 * 997805;
    s5 += s13 * 136657;
    s6 -= s13 * 683901;
    s13 = 0;

    s0 += s12 * 666643;
    s1 += s12 * 470296;
    s2 += s12 * 654183;
    s3 -= s12 * 997805;
    s4 += s12 * 136657;
    s5 -= s12 * 683901;
    s12 = 0;

    var carry0 = (s0 + (1 << 20)) >> 21;
    s1 += carry0;
    s0 -= carry0 << 21;
    var carry2 = (s2 + (1 << 20)) >> 21;
    s3 += carry2;
    s2 -= carry2 << 21;
    var carry4 = (s4 + (1 << 20)) >> 21;
    s5 += carry4;
    s4 -= carry4 << 21;
    carry6 = (s6 + (1 << 20)) >> 21;
    s7 += carry6;
    s6 -= carry6 << 21;
    carry8 = (s8 + (1 << 20)) >> 21;
    s9 += carry8;
    s8 -= carry8 << 21;
    carry10 = (s10 + (1 << 20)) >> 21;
    s11 += carry10;
    s10 -= carry10 << 21;

    var carry1 = (s1 + (1 << 20)) >> 21;
    s2 += carry1;
    s1 -= carry1 << 21;
    var carry3 = (s3 + (1 << 20)) >> 21;
    s4 += carry3;
    s3 -= carry3 << 21;
    var carry5 = (s5 + (1 << 20)) >> 21;
    s6 += carry5;
    s5 -= carry5 << 21;
    carry7 = (s7 + (1 << 20)) >> 21;
    s8 += carry7;
    s7 -= carry7 << 21;
    carry9 = (s9 + (1 << 20)) >> 21;
    s10 += carry9;
    s9 -= carry9 << 21;
    carry11 = (s11 + (1 << 20)) >> 21;
    s12 += carry11;
    s11 -= carry11 << 21;

    s0 += s12 * 666643;
    s1 += s12 * 470296;
    s2 += s12 * 654183;
    s3 -= s12 * 997805;
    s4 += s12 * 136657;
    s5 -= s12 * 683901;
    s12 = 0;

    carry0 = s0 >> 21;
    s1 += carry0;
    s0 -= carry0 << 21;
    carry1 = s1 >> 21;
    s2 += carry1;
    s1 -= carry1 << 21;
    carry2 = s2 >> 21;
    s3 += carry2;
    s2 -= carry2 << 21;
    carry3 = s3 >> 21;
    s4 += carry3;
    s3 -= carry3 << 21;
    carry4 = s4 >> 21;
    s5 += carry4;
    s4 -= carry4 << 21;
    carry5 = s5 >> 21;
    s6 += carry5;
    s5 -= carry5 << 21;
    carry6 = s6 >> 21;
    s7 += carry6;
    s6 -= carry6 << 21;
    carry7 = s7 >> 21;
    s8 += carry7;
    s7 -= carry7 << 21;
    carry8 = s8 >> 21;
    s9 += carry8;
    s8 -= carry8 << 21;
    carry9 = s9 >> 21;
    s10 += carry9;
    s9 -= carry9 << 21;
    carry10 = s10 >> 21;
    s11 += carry10;
    s10 -= carry10 << 21;
    carry11 = s11 >> 21;
    s12 += carry11;
    s11 -= carry11 << 21;

    s0 += s12 * 666643;
    s1 += s12 * 470296;
    s2 += s12 * 654183;
    s3 -= s12 * 997805;
    s4 += s12 * 136657;
    s5 -= s12 * 683901;
    s12 = 0;

    carry0 = s0 >> 21;
    s1 += carry0;
    s0 -= carry0 << 21;
    carry1 = s1 >> 21;
    s2 += carry1;
    s1 -= carry1 << 21;
    carry2 = s2 >> 21;
    s3 += carry2;
    s2 -= carry2 << 21;
    carry3 = s3 >> 21;
    s4 += carry3;
    s3 -= carry3 << 21;
    carry4 = s4 >> 21;
    s5 += carry4;
    s4 -= carry4 << 21;
    carry5 = s5 >> 21;
    s6 += carry5;
    s5 -= carry5 << 21;
    carry6 = s6 >> 21;
    s7 += carry6;
    s6 -= carry6 << 21;
    carry7 = s7 >> 21;
    s8 += carry7;
    s7 -= carry7 << 21;
    carry8 = s8 >> 21;
    s9 += carry8;
    s8 -= carry8 << 21;
    carry9 = s9 >> 21;
    s10 += carry9;
    s9 -= carry9 << 21;
    carry10 = s10 >> 21;
    s11 += carry10;
    s10 -= carry10 << 21;

    var reduced = Scalar();

    reduced[0] = (s0 >> 0);
    reduced[1] = (s0 >> 8);
    reduced[2] = ((s0 >> 16) | (s1 << 5));
    reduced[3] = (s1 >> 3);
    reduced[4] = (s1 >> 11);
    reduced[5] = ((s1 >> 19) | (s2 << 2));
    reduced[6] = (s2 >> 6);
    reduced[7] = ((s2 >> 14) | (s3 << 7));
    reduced[8] = (s3 >> 1);
    reduced[9] = (s3 >> 9);
    reduced[10] = ((s3 >> 17) | (s4 << 4));
    reduced[11] = (s4 >> 4);
    reduced[12] = (s4 >> 12);
    reduced[13] = ((s4 >> 20) | (s5 << 1));
    reduced[14] = (s5 >> 7);
    reduced[15] = ((s5 >> 15) | (s6 << 6));
    reduced[16] = (s6 >> 2);
    reduced[17] = (s6 >> 10);
    reduced[18] = ((s6 >> 18) | (s7 << 3));
    reduced[19] = (s7 >> 5);
    reduced[20] = (s7 >> 13);
    reduced[21] = (s8 >> 0);
    reduced[22] = (s8 >> 8);
    reduced[23] = ((s8 >> 16) | (s9 << 5));
    reduced[24] = (s9 >> 3);
    reduced[25] = (s9 >> 11);
    reduced[26] = ((s9 >> 19) | (s10 << 2));
    reduced[27] = (s10 >> 6);
    reduced[28] = ((s10 >> 14) | (s11 << 7));
    reduced[29] = (s11 >> 1);
    reduced[30] = (s11 >> 9);
    reduced[31] = (s11 >> 17);

    for (var i = 32; i < 64; i++) {
      reduced[i] = this[i];
    }
    return reduced;
  }

  /// Scalar Multiplcation then Addition
  List<int> mulAdd(Scalar b, Scalar c) {
    var aCopy = List<int>.from(_data);
    aCopy[0] = 2097151 & load3(aCopy, 0);
    aCopy[1] = 2097151 & (load4(aCopy, 2) >> 5);
    aCopy[2] = 2097151 & (load3(aCopy, 5) >> 2);
    aCopy[3] = 2097151 & (load4(aCopy, 7) >> 7);
    aCopy[4] = 2097151 & (load4(aCopy, 10) >> 4);
    aCopy[5] = 2097151 & (load3(aCopy, 13) >> 1);
    aCopy[6] = 2097151 & (load4(aCopy, 15) >> 6);
    aCopy[7] = 2097151 & (load3(aCopy, 18) >> 3);
    aCopy[8] = 2097151 & load3(aCopy, 21);
    aCopy[9] = 2097151 & (load4(aCopy, 23) >> 5);
    aCopy[10] = 2097151 & (load3(aCopy, 26) >> 2);
    aCopy[11] = (load4(aCopy, 28) >> 7);

    var bCopy = List<int>.from(b.data);
    bCopy[0] = 2097151 & load3(bCopy, 0);
    bCopy[1] = 2097151 & (load4(bCopy, 2) >> 5);
    bCopy[2] = 2097151 & (load3(bCopy, 5) >> 2);
    bCopy[3] = 2097151 & (load4(bCopy, 7) >> 7);
    bCopy[4] = 2097151 & (load4(bCopy, 10) >> 4);
    bCopy[5] = 2097151 & (load3(bCopy, 13) >> 1);
    bCopy[6] = 2097151 & (load4(bCopy, 15) >> 6);
    bCopy[7] = 2097151 & (load3(bCopy, 18) >> 3);
    bCopy[8] = 2097151 & load3(bCopy, 21);
    bCopy[9] = 2097151 & (load4(bCopy, 23) >> 5);
    bCopy[10] = 2097151 & (load3(bCopy, 26) >> 2);
    bCopy[11] = (load4(bCopy, 28) >> 7);

    var cCopy = List<int>.from(c.data);
    cCopy[0] = 2097151 & load3(cCopy, 0);
    cCopy[1] = 2097151 & (load4(cCopy, 2) >> 5);
    cCopy[2] = 2097151 & (load3(cCopy, 5) >> 2);
    cCopy[3] = 2097151 & (load4(cCopy, 7) >> 7);
    cCopy[4] = 2097151 & (load4(cCopy, 10) >> 4);
    cCopy[5] = 2097151 & (load3(cCopy, 13) >> 1);
    cCopy[6] = 2097151 & (load4(cCopy, 15) >> 6);
    cCopy[7] = 2097151 & (load3(cCopy, 18) >> 3);
    cCopy[8] = 2097151 & load3(cCopy, 21);
    cCopy[9] = 2097151 & (load4(cCopy, 23) >> 5);
    cCopy[10] = 2097151 & (load3(cCopy, 26) >> 2);
    cCopy[11] = (load4(cCopy, 28) >> 7);

    var s = List<int>.generate(
      24,
      (_) => 0,
      growable: false,
    );
    var carry = List<int>.generate(
      24,
      (_) => 0,
      growable: false,
    );

    s[0] = cCopy[0] + aCopy[0] * bCopy[0];
    s[1] = cCopy[1] + aCopy[0] * bCopy[1] + aCopy[1] * bCopy[0];
    s[2] = cCopy[2] +
        aCopy[0] * bCopy[2] +
        aCopy[1] * bCopy[1] +
        aCopy[2] * bCopy[0];
    s[3] = cCopy[3] +
        aCopy[0] * bCopy[3] +
        aCopy[1] * bCopy[2] +
        aCopy[2] * bCopy[1] +
        aCopy[3] * bCopy[0];
    s[4] = cCopy[4] +
        aCopy[0] * bCopy[4] +
        aCopy[1] * bCopy[3] +
        aCopy[2] * bCopy[2] +
        aCopy[3] * bCopy[1] +
        aCopy[4] * bCopy[0];
    s[5] = cCopy[5] +
        aCopy[0] * bCopy[5] +
        aCopy[1] * bCopy[4] +
        aCopy[2] * bCopy[3] +
        aCopy[3] * bCopy[2] +
        aCopy[4] * bCopy[1] +
        aCopy[5] * bCopy[0];
    s[6] = cCopy[6] +
        aCopy[0] * bCopy[6] +
        aCopy[1] * bCopy[5] +
        aCopy[2] * bCopy[4] +
        aCopy[3] * bCopy[3] +
        aCopy[4] * bCopy[2] +
        aCopy[5] * bCopy[1] +
        aCopy[6] * bCopy[0];
    s[7] = cCopy[7] +
        aCopy[0] * bCopy[7] +
        aCopy[1] * bCopy[6] +
        aCopy[2] * bCopy[5] +
        aCopy[3] * bCopy[4] +
        aCopy[4] * bCopy[3] +
        aCopy[5] * bCopy[2] +
        aCopy[6] * bCopy[1] +
        aCopy[7] * bCopy[0];
    s[8] = cCopy[8] +
        aCopy[0] * bCopy[8] +
        aCopy[1] * bCopy[7] +
        aCopy[2] * bCopy[6] +
        aCopy[3] * bCopy[5] +
        aCopy[4] * bCopy[4] +
        aCopy[5] * bCopy[3] +
        aCopy[6] * bCopy[2] +
        aCopy[7] * bCopy[1] +
        aCopy[8] * bCopy[0];
    s[9] = cCopy[9] +
        aCopy[0] * bCopy[9] +
        aCopy[1] * bCopy[8] +
        aCopy[2] * bCopy[7] +
        aCopy[3] * bCopy[6] +
        aCopy[4] * bCopy[5] +
        aCopy[5] * bCopy[4] +
        aCopy[6] * bCopy[3] +
        aCopy[7] * bCopy[2] +
        aCopy[8] * bCopy[1] +
        aCopy[9] * bCopy[0];
    s[10] = cCopy[10] +
        aCopy[0] * bCopy[10] +
        aCopy[1] * bCopy[9] +
        aCopy[2] * bCopy[8] +
        aCopy[3] * bCopy[7] +
        aCopy[4] * bCopy[6] +
        aCopy[5] * bCopy[5] +
        aCopy[6] * bCopy[4] +
        aCopy[7] * bCopy[3] +
        aCopy[8] * bCopy[2] +
        aCopy[9] * bCopy[1] +
        aCopy[10] * bCopy[0];
    s[11] = cCopy[11] +
        aCopy[0] * bCopy[11] +
        aCopy[1] * bCopy[10] +
        aCopy[2] * bCopy[9] +
        aCopy[3] * bCopy[8] +
        aCopy[4] * bCopy[7] +
        aCopy[5] * bCopy[6] +
        aCopy[6] * bCopy[5] +
        aCopy[7] * bCopy[4] +
        aCopy[8] * bCopy[3] +
        aCopy[9] * bCopy[2] +
        aCopy[10] * bCopy[1] +
        aCopy[11] * bCopy[0];
    s[12] = aCopy[1] * bCopy[11] +
        aCopy[2] * bCopy[10] +
        aCopy[3] * bCopy[9] +
        aCopy[4] * bCopy[8] +
        aCopy[5] * bCopy[7] +
        aCopy[6] * bCopy[6] +
        aCopy[7] * bCopy[5] +
        aCopy[8] * bCopy[4] +
        aCopy[9] * bCopy[3] +
        aCopy[10] * bCopy[2] +
        aCopy[11] * bCopy[1];
    s[13] = aCopy[2] * bCopy[11] +
        aCopy[3] * bCopy[10] +
        aCopy[4] * bCopy[9] +
        aCopy[5] * bCopy[8] +
        aCopy[6] * bCopy[7] +
        aCopy[7] * bCopy[6] +
        aCopy[8] * bCopy[5] +
        aCopy[9] * bCopy[4] +
        aCopy[10] * bCopy[3] +
        aCopy[11] * bCopy[2];
    s[14] = aCopy[3] * bCopy[11] +
        aCopy[4] * bCopy[10] +
        aCopy[5] * bCopy[9] +
        aCopy[6] * bCopy[8] +
        aCopy[7] * bCopy[7] +
        aCopy[8] * bCopy[6] +
        aCopy[9] * bCopy[5] +
        aCopy[10] * bCopy[4] +
        aCopy[11] * bCopy[3];
    s[15] = aCopy[4] * bCopy[11] +
        aCopy[5] * bCopy[10] +
        aCopy[6] * bCopy[9] +
        aCopy[7] * bCopy[8] +
        aCopy[8] * bCopy[7] +
        aCopy[9] * bCopy[6] +
        aCopy[10] * bCopy[5] +
        aCopy[11] * bCopy[4];
    s[16] = aCopy[5] * bCopy[11] +
        aCopy[6] * bCopy[10] +
        aCopy[7] * bCopy[9] +
        aCopy[8] * bCopy[8] +
        aCopy[9] * bCopy[7] +
        aCopy[10] * bCopy[6] +
        aCopy[11] * bCopy[5];
    s[17] = aCopy[6] * bCopy[11] +
        aCopy[7] * bCopy[10] +
        aCopy[8] * bCopy[9] +
        aCopy[9] * bCopy[8] +
        aCopy[10] * bCopy[7] +
        aCopy[11] * bCopy[6];
    s[18] = aCopy[7] * bCopy[11] +
        aCopy[8] * bCopy[10] +
        aCopy[9] * bCopy[9] +
        aCopy[10] * bCopy[8] +
        aCopy[11] * bCopy[7];
    s[19] = aCopy[8] * bCopy[11] +
        aCopy[9] * bCopy[10] +
        aCopy[10] * bCopy[9] +
        aCopy[11] * bCopy[8];
    s[20] = aCopy[9] * bCopy[11] + aCopy[10] * bCopy[10] + aCopy[11] * bCopy[9];
    s[21] = aCopy[10] * bCopy[11] + aCopy[11] * bCopy[10];
    s[22] = aCopy[11] * bCopy[11];
    s[23] = 0;

    carry[0] = (s[0] + (1 << 20)) >> 21;
    s[1] += carry[0];
    s[0] -= carry[0] << 21;
    carry[2] = (s[2] + (1 << 20)) >> 21;
    s[3] += carry[2];
    s[2] -= carry[2] << 21;
    carry[4] = (s[4] + (1 << 20)) >> 21;
    s[5] += carry[4];
    s[4] -= carry[4] << 21;
    carry[6] = (s[6] + (1 << 20)) >> 21;
    s[7] += carry[6];
    s[6] -= carry[6] << 21;
    carry[8] = (s[8] + (1 << 20)) >> 21;
    s[9] += carry[8];
    s[8] -= carry[8] << 21;
    carry[10] = (s[10] + (1 << 20)) >> 21;
    s[11] += carry[10];
    s[10] -= carry[10] << 21;
    carry[12] = (s[12] + (1 << 20)) >> 21;
    s[13] += carry[12];
    s[12] -= carry[12] << 21;
    carry[14] = (s[14] + (1 << 20)) >> 21;
    s[15] += carry[14];
    s[14] -= carry[14] << 21;
    carry[16] = (s[16] + (1 << 20)) >> 21;
    s[17] += carry[16];
    s[16] -= carry[16] << 21;
    carry[18] = (s[18] + (1 << 20)) >> 21;
    s[19] += carry[18];
    s[18] -= carry[18] << 21;
    carry[20] = (s[20] + (1 << 20)) >> 21;
    s[21] += carry[20];
    s[20] -= carry[20] << 21;
    carry[22] = (s[22] + (1 << 20)) >> 21;
    s[23] += carry[22];
    s[22] -= carry[22] << 21;

    carry[1] = (s[1] + (1 << 20)) >> 21;
    s[2] += carry[1];
    s[1] -= carry[1] << 21;
    carry[3] = (s[3] + (1 << 20)) >> 21;
    s[4] += carry[3];
    s[3] -= carry[3] << 21;
    carry[5] = (s[5] + (1 << 20)) >> 21;
    s[6] += carry[5];
    s[5] -= carry[5] << 21;
    carry[7] = (s[7] + (1 << 20)) >> 21;
    s[8] += carry[7];
    s[7] -= carry[7] << 21;
    carry[9] = (s[9] + (1 << 20)) >> 21;
    s[10] += carry[9];
    s[9] -= carry[9] << 21;
    carry[11] = (s[11] + (1 << 20)) >> 21;
    s[12] += carry[11];
    s[11] -= carry[11] << 21;
    carry[13] = (s[13] + (1 << 20)) >> 21;
    s[14] += carry[13];
    s[13] -= carry[13] << 21;
    carry[15] = (s[15] + (1 << 20)) >> 21;
    s[16] += carry[15];
    s[15] -= carry[15] << 21;
    carry[17] = (s[17] + (1 << 20)) >> 21;
    s[18] += carry[17];
    s[17] -= carry[17] << 21;
    carry[19] = (s[19] + (1 << 20)) >> 21;
    s[20] += carry[19];
    s[19] -= carry[19] << 21;
    carry[21] = (s[21] + (1 << 20)) >> 21;
    s[22] += carry[21];
    s[21] -= carry[21] << 21;

    s[11] += s[23] * 666643;
    s[12] += s[23] * 470296;
    s[13] += s[23] * 654183;
    s[14] -= s[23] * 997805;
    s[15] += s[23] * 136657;
    s[16] -= s[23] * 683901;
    s[23] = 0;

    s[10] += s[22] * 666643;
    s[11] += s[22] * 470296;
    s[12] += s[22] * 654183;
    s[13] -= s[22] * 997805;
    s[14] += s[22] * 136657;
    s[15] -= s[22] * 683901;
    s[22] = 0;

    s[9] += s[21] * 666643;
    s[10] += s[21] * 470296;
    s[11] += s[21] * 654183;
    s[12] -= s[21] * 997805;
    s[13] += s[21] * 136657;
    s[14] -= s[21] * 683901;
    s[21] = 0;

    s[8] += s[20] * 666643;
    s[9] += s[20] * 470296;
    s[10] += s[20] * 654183;
    s[11] -= s[20] * 997805;
    s[12] += s[20] * 136657;
    s[13] -= s[20] * 683901;
    s[20] = 0;

    s[7] += s[19] * 666643;
    s[8] += s[19] * 470296;
    s[9] += s[19] * 654183;
    s[10] -= s[19] * 997805;
    s[11] += s[19] * 136657;
    s[12] -= s[19] * 683901;
    s[19] = 0;

    s[6] += s[18] * 666643;
    s[7] += s[18] * 470296;
    s[8] += s[18] * 654183;
    s[9] -= s[18] * 997805;
    s[10] += s[18] * 136657;
    s[11] -= s[18] * 683901;
    s[18] = 0;

    carry[6] = (s[6] + (1 << 20)) >> 21;
    s[7] += carry[6];
    s[6] -= carry[6] << 21;
    carry[8] = (s[8] + (1 << 20)) >> 21;
    s[9] += carry[8];
    s[8] -= carry[8] << 21;
    carry[10] = (s[10] + (1 << 20)) >> 21;
    s[11] += carry[10];
    s[10] -= carry[10] << 21;
    carry[12] = (s[12] + (1 << 20)) >> 21;
    s[13] += carry[12];
    s[12] -= carry[12] << 21;
    carry[14] = (s[14] + (1 << 20)) >> 21;
    s[15] += carry[14];
    s[14] -= carry[14] << 21;
    carry[16] = (s[16] + (1 << 20)) >> 21;
    s[17] += carry[16];
    s[16] -= carry[16] << 21;

    carry[7] = (s[7] + (1 << 20)) >> 21;
    s[8] += carry[7];
    s[7] -= carry[7] << 21;
    carry[9] = (s[9] + (1 << 20)) >> 21;
    s[10] += carry[9];
    s[9] -= carry[9] << 21;
    carry[11] = (s[11] + (1 << 20)) >> 21;
    s[12] += carry[11];
    s[11] -= carry[11] << 21;
    carry[13] = (s[13] + (1 << 20)) >> 21;
    s[14] += carry[13];
    s[13] -= carry[13] << 21;
    carry[15] = (s[15] + (1 << 20)) >> 21;
    s[16] += carry[15];
    s[15] -= carry[15] << 21;

    s[5] += s[17] * 666643;
    s[6] += s[17] * 470296;
    s[7] += s[17] * 654183;
    s[8] -= s[17] * 997805;
    s[9] += s[17] * 136657;
    s[10] -= s[17] * 683901;
    s[17] = 0;

    s[4] += s[16] * 666643;
    s[5] += s[16] * 470296;
    s[6] += s[16] * 654183;
    s[7] -= s[16] * 997805;
    s[8] += s[16] * 136657;
    s[9] -= s[16] * 683901;
    s[16] = 0;

    s[3] += s[15] * 666643;
    s[4] += s[15] * 470296;
    s[5] += s[15] * 654183;
    s[6] -= s[15] * 997805;
    s[7] += s[15] * 136657;
    s[8] -= s[15] * 683901;
    s[15] = 0;

    s[2] += s[14] * 666643;
    s[3] += s[14] * 470296;
    s[4] += s[14] * 654183;
    s[5] -= s[14] * 997805;
    s[6] += s[14] * 136657;
    s[7] -= s[14] * 683901;
    s[14] = 0;

    s[1] += s[13] * 666643;
    s[2] += s[13] * 470296;
    s[3] += s[13] * 654183;
    s[4] -= s[13] * 997805;
    s[5] += s[13] * 136657;
    s[6] -= s[13] * 683901;
    s[13] = 0;

    s[0] += s[12] * 666643;
    s[1] += s[12] * 470296;
    s[2] += s[12] * 654183;
    s[3] -= s[12] * 997805;
    s[4] += s[12] * 136657;
    s[5] -= s[12] * 683901;
    s[12] = 0;

    carry[0] = (s[0] + (1 << 20)) >> 21;
    s[1] += carry[0];
    s[0] -= carry[0] << 21;
    carry[2] = (s[2] + (1 << 20)) >> 21;
    s[3] += carry[2];
    s[2] -= carry[2] << 21;
    carry[4] = (s[4] + (1 << 20)) >> 21;
    s[5] += carry[4];
    s[4] -= carry[4] << 21;
    carry[6] = (s[6] + (1 << 20)) >> 21;
    s[7] += carry[6];
    s[6] -= carry[6] << 21;
    carry[8] = (s[8] + (1 << 20)) >> 21;
    s[9] += carry[8];
    s[8] -= carry[8] << 21;
    carry[10] = (s[10] + (1 << 20)) >> 21;
    s[11] += carry[10];
    s[10] -= carry[10] << 21;

    carry[1] = (s[1] + (1 << 20)) >> 21;
    s[2] += carry[1];
    s[1] -= carry[1] << 21;
    carry[3] = (s[3] + (1 << 20)) >> 21;
    s[4] += carry[3];
    s[3] -= carry[3] << 21;
    carry[5] = (s[5] + (1 << 20)) >> 21;
    s[6] += carry[5];
    s[5] -= carry[5] << 21;
    carry[7] = (s[7] + (1 << 20)) >> 21;
    s[8] += carry[7];
    s[7] -= carry[7] << 21;
    carry[9] = (s[9] + (1 << 20)) >> 21;
    s[10] += carry[9];
    s[9] -= carry[9] << 21;
    carry[11] = (s[11] + (1 << 20)) >> 21;
    s[12] += carry[11];
    s[11] -= carry[11] << 21;

    s[0] += s[12] * 666643;
    s[1] += s[12] * 470296;
    s[2] += s[12] * 654183;
    s[3] -= s[12] * 997805;
    s[4] += s[12] * 136657;
    s[5] -= s[12] * 683901;
    s[12] = 0;

    carry[0] = s[0] >> 21;
    s[1] += carry[0];
    s[0] -= carry[0] << 21;
    carry[1] = s[1] >> 21;
    s[2] += carry[1];
    s[1] -= carry[1] << 21;
    carry[2] = s[2] >> 21;
    s[3] += carry[2];
    s[2] -= carry[2] << 21;
    carry[3] = s[3] >> 21;
    s[4] += carry[3];
    s[3] -= carry[3] << 21;
    carry[4] = s[4] >> 21;
    s[5] += carry[4];
    s[4] -= carry[4] << 21;
    carry[5] = s[5] >> 21;
    s[6] += carry[5];
    s[5] -= carry[5] << 21;
    carry[6] = s[6] >> 21;
    s[7] += carry[6];
    s[6] -= carry[6] << 21;
    carry[7] = s[7] >> 21;
    s[8] += carry[7];
    s[7] -= carry[7] << 21;
    carry[8] = s[8] >> 21;
    s[9] += carry[8];
    s[8] -= carry[8] << 21;
    carry[9] = s[9] >> 21;
    s[10] += carry[9];
    s[9] -= carry[9] << 21;
    carry[10] = s[10] >> 21;
    s[11] += carry[10];
    s[10] -= carry[10] << 21;
    carry[11] = s[11] >> 21;
    s[12] += carry[11];
    s[11] -= carry[11] << 21;

    s[0] += s[12] * 666643;
    s[1] += s[12] * 470296;
    s[2] += s[12] * 654183;
    s[3] -= s[12] * 997805;
    s[4] += s[12] * 136657;
    s[5] -= s[12] * 683901;
    s[12] = 0;

    carry[0] = s[0] >> 21;
    s[1] += carry[0];
    s[0] -= carry[0] << 21;
    carry[1] = s[1] >> 21;
    s[2] += carry[1];
    s[1] -= carry[1] << 21;
    carry[2] = s[2] >> 21;
    s[3] += carry[2];
    s[2] -= carry[2] << 21;
    carry[3] = s[3] >> 21;
    s[4] += carry[3];
    s[3] -= carry[3] << 21;
    carry[4] = s[4] >> 21;
    s[5] += carry[4];
    s[4] -= carry[4] << 21;
    carry[5] = s[5] >> 21;
    s[6] += carry[5];
    s[5] -= carry[5] << 21;
    carry[6] = s[6] >> 21;
    s[7] += carry[6];
    s[6] -= carry[6] << 21;
    carry[7] = s[7] >> 21;
    s[8] += carry[7];
    s[7] -= carry[7] << 21;
    carry[8] = s[8] >> 21;
    s[9] += carry[8];
    s[8] -= carry[8] << 21;
    carry[9] = s[9] >> 21;
    s[10] += carry[9];
    s[9] -= carry[9] << 21;
    carry[10] = s[10] >> 21;
    s[11] += carry[10];
    s[10] -= carry[10] << 21;

    var out = List<int>.generate(
      32,
      (_) => 0,
      growable: false,
    );

    out[0] = (s[0] >> 0);
    out[1] = (s[0] >> 8);
    out[2] = ((s[0] >> 16) | (s[1] << 5));
    out[3] = (s[1] >> 3);
    out[4] = (s[1] >> 11);
    out[5] = ((s[1] >> 19) | (s[2] << 2));
    out[6] = (s[2] >> 6);
    out[7] = ((s[2] >> 14) | (s[3] << 7));
    out[8] = (s[3] >> 1);
    out[9] = (s[3] >> 9);
    out[10] = ((s[3] >> 17) | (s[4] << 4));
    out[11] = (s[4] >> 4);
    out[12] = (s[4] >> 12);
    out[13] = ((s[4] >> 20) | (s[5] << 1));
    out[14] = (s[5] >> 7);
    out[15] = ((s[5] >> 15) | (s[6] << 6));
    out[16] = (s[6] >> 2);
    out[17] = (s[6] >> 10);
    out[18] = ((s[6] >> 18) | (s[7] << 3));
    out[19] = (s[7] >> 5);
    out[20] = (s[7] >> 13);
    out[21] = (s[8] >> 0);
    out[22] = (s[8] >> 8);
    out[23] = ((s[8] >> 16) | (s[9] << 5));
    out[24] = (s[9] >> 3);
    out[25] = (s[9] >> 11);
    out[26] = ((s[9] >> 19) | (s[10] << 2));
    out[27] = (s[10] >> 6);
    out[28] = ((s[10] >> 14) | (s[11] << 7));
    out[29] = (s[11] >> 1);
    out[30] = (s[11] >> 9);
    out[31] = (s[11] >> 17);

    return Int8List.fromList(out);
  }

  /// Scalar Multiplcation of this * p
  Int8List scarlarMult(List<int> p) {
    var n = List<int>.from(_data);
    var i = 0;
    var e = List<int>.generate(
      32,
      (_) => 0,
      growable: false,
    );

    for (i = 0; i < 32; ++i) {
      e[i] = n[i];
    }

    var x1 = FieldElement.fromBytes(p);
    var x2 = FieldElement.one();
    var z2 = FieldElement.zero();
    var x3 = FieldElement(x1);
    var z3 = FieldElement.one();

    var swap = 0;
    for (var pos = 254; pos >= 0; --pos) {
      var b = e[(pos / 8).floor()] >> (pos & 7);
      b &= 1;
      swap ^= b;
      x2.cswap(x3, swap);
      z2.cswap(z3, swap);
      swap = b;

      var tmp0 = x3 - z3;
      var tmp1 = x2 - z2;

      x2 = x2 + z2;
      z2 = x3 + z3;
      z3 = tmp0 * x2;
      z2 = z2 * tmp1;
      tmp0 = tmp1.square();
      tmp1 = x2.square();
      x3 = z3 + z2;
      z2 = z3 - z2;
      x2 = tmp1 * tmp0;
      tmp1 = tmp1 - tmp0;
      z2 = z2.square();
      z3 = tmp1.mul121666();
      x3 = x3.square();
      tmp0 = tmp0 + z3;
      z3 = x1 * z2;
      z2 = tmp1 * tmp0;
    }
    x2.cswap(x3, swap);
    z2.cswap(z3, swap);
    z2 = z2.invert();
    x2 = x2 * z2;
    return x2.toBytes() as Int8List;
  }

  /// negate Scalar
  List<int> neg() {
    var zero = Int8List(32);
    return mulAdd(Scalar(Constants.lMinus1), Scalar(zero));
  }

  /// Check if Scalar information lost during reduction to 512 bits
  bool isReduced() {
    var strict = List<int>.generate(
      64,
      (_) => 0,
      growable: false,
    );
    strict.fillRange(0, 64, 0);
    List.copyRange(strict, 0, _data, 0, 32);

    strict = Scalar(strict).reduction();

    if (ListEquality<int>().equals(strict, _data)) {
      return false;
    }
    return true;
  }
}

class Labelset {
  late List<int> _data;
  late int _length;

  /// new Labelset using emoty customization label and protocol name
  Labelset() {
    var protocolName =
        Int8List.fromList('VEdDSA_25519_SHA512_Elligator2'.codeUnits);

    _data = List<int>.generate(
      3 + protocolName.length,
      (_) => 0,
      growable: false,
    );
    _data[0] = 2;
    _data[1] = protocolName.length;
    List.copyRange(_data, 2, protocolName);
    _data[_data.length - 1] = 0;
    _length = 3 + protocolName.length;
  }

  List<int> get data => _data;
  int get length => _length;

  /// add label to labelset
  int add(int pos, List<int> label) {
    if (_length + label.length + 1 > Constants.LABELSETMAXLEN ||
        label.length > Constants.LABELMAXLEN) {
      return -1;
    }
    var newData = List<int>.generate(
      _length + label.length + 1,
      (_) => 0,
      growable: false,
    );

    for (var i = 0; i < newData.length; i++) {
      if (i < pos) {
        newData[i] = _data[i];
      } else if (i > pos + label.length + 1) {
        newData[i] = _data[i - label.length - 1];
      } else if (pos == i) {
        newData[i] = label.length;
      } else {
        newData[i] = label[i - pos - 1];
      }
    }
    _data = List.from(newData);
    _data[0]++;
    _length = _data.length;
    return 0;
  }

  /// check if labelset valid
  bool validate() {
    if (_length < 3 || _length > Constants.LABELSETMAXLEN) {
      return false;
    }
    var numLabels = _data[0];
    var offset = 1;
    for (var count = 0; count < numLabels; count++) {
      var labelLen = _data[offset];
      if (labelLen > Constants.LABELMAXLEN) {
        return false;
      }
      offset += 1 + labelLen;
      if (offset > _length) {
        return false;
      }
    }
    if (offset != _length) {
      return false;
    }
    return true;
  }

  /// change labelset at pos to value
  void set(int pos, int value) {
    assert(pos < _length);
    _data[pos] = value;
  }

  /// Check if labelset empty
  bool isEmpty() {
    if (_length != 3) {
      return false;
    }
    return true;
  }
}
