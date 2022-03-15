import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

const int intMaxValue = 9223372036854775807;

extension StringConversion on Array<Int8> {
  String toDartString({int maxSize = intMaxValue}) {
    List<int> _tmp = [];

    for (var i = 0; i < maxSize; i++) {
      if (this[i] != 0x0000) {
        _tmp.add(this[i]);
      } else {
        break;
      }
    }

    return utf8.decode(_tmp);
  }
}

extension StrToPInt8 on String {
  Pointer<Int8> toPointerInt8() {
    var _tmp = utf8.encode(this);

    final ptr = malloc.allocate<Int8>(sizeOf<Int8>() * _tmp.length);
    for (var i = 0; i < _tmp.length; i++) {
      ptr.elementAt(i).value = _tmp[i];
    }
    return ptr;
  }
}
