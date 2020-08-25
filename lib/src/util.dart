import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:curve25519_vrf/curve25519_vrf.dart';
import 'package:pointycastle/pointycastle.dart' hide Signature, PublicKey, PrivateKey;

import 'constants.dart';

enum SignatureType {
  STANDARD,
  VRF
}

class PublicKey {

  final List<int> _bytes;

  PublicKey(this._bytes)
      : assert(_bytes != null),
        assert (_bytes.length == Constants.PUBLICKEYLENGTH);

  bool operator == (other) =>
      other is PublicKey &&
          const ListEquality<int>().equals(_bytes, other._bytes);

  List<int> get bytes => _bytes;
}

class PrivateKey {

  final List<int> _bytes;

  PrivateKey(this._bytes)
      : assert(_bytes != null),
        assert (_bytes.length == Constants.PRIVATEKEYLENGTH);

  bool operator == (other) =>
      other is PublicKey &&
          const ListEquality<int>().equals(_bytes, other.bytes);

  List<int> get bytes => _bytes;
}

class KeyPair {

  final PublicKey _publicKey;
  final PrivateKey _privateKey;

  KeyPair(this._publicKey, this._privateKey)
      : assert(_publicKey != null),
        assert(_privateKey != null);

  bool operator == (other) =>
      other is KeyPair &&
          _publicKey == other.publicKey &&
          _privateKey == other.privateKey;

  PublicKey get publicKey => _publicKey;

  PrivateKey get privateKey => _privateKey;
}

class Signature {

  final List<int> _bytes;
  final PublicKey _publicKey;
  final SignatureType _type;

  const Signature([List<int> bytes, PublicKey publicKey, SignatureType type])
      : assert(bytes != null),
        assert(publicKey != null),
        assert(type != null),
        _bytes = bytes,
        _publicKey = publicKey,
        _type = type;

  List<int> get bytes => _bytes;

  PublicKey get publicKey => _publicKey;

  SignatureType get type => _type;

  bool operator == (other) =>
      other is Signature &&
          const ListEquality<int>().equals(bytes, other.bytes) &&
          _publicKey == other.publicKey;

  dynamic isValid(Uint8List message) {
    return Curve25519().verify(message, this);
  }
}

/// Sha512 Digests from PointyCastle
class Sha512 {

  static Digest _d;

  Sha512(){
    _d = Digest('SHA-512');
  }


  List<int> digest(List<int> bytes){
    var toHash = Uint8List.fromList(bytes);
    var b = _d.process(toHash);
    var hash = List<int>(b.length);
    for (var i = 0; i < b.length; i++) {
      var add = b[i];
      if (add > 127) {
        add = add - 256;
      }
      hash[i] = add;
    }
    return hash;
  }

}

class Rand {

  final maxBytes = 256;
  final maxInt = 2^32-1;
  Rand();

  /// random byte array of length
  List<int> randomBytes(int length) {

    var random = Random.secure();

    var randBytes = Int8List(length);

    for (var i = 0; i < length; i++){

      var next = random.nextInt(maxBytes);
      if (next > 127) {
        next = next - 256;
      }
      randBytes[i] = next;
    }

    return randBytes;
  }

  /// random int array of length
  Int32List randomInt(int length) {
    var random = Random.secure();
    return Int32List.fromList(List<int>.generate(length, (i) => random.nextInt(maxInt)));
  }
}