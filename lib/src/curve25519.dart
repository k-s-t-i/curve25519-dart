import 'dart:typed_data';

import 'package:collection/collection.dart';

import 'constants.dart';
import 'ed25519.dart';
import 'util.dart';


class Curve25519 {

  /// Empty Constructor
  Curve25519();

  /// Generate new x25519 KeyPair
  KeyPair newKeyPair() {

    var privateKeyBytes = Rand().randomBytes(32);

    privateKeyBytes[0]  &= 248;
    privateKeyBytes[31] &= 127;
    privateKeyBytes[31] |= 64;

    var privateKey = PrivateKey(privateKeyBytes);

    var ed = ExtendedGroupElement.scalarMultBase(privateKey.bytes);
    var edYPlusOne = ed.Y + ed.Z;
    var oneMinusEdY = ed.Z - ed.Y;
    var invOneMinusEdY = oneMinusEdY.invert();
    var montX = edYPlusOne * invOneMinusEdY;

    var publicKey = PublicKey(montX.toBytes());

    return KeyPair(publicKey, privateKey);
  }

  /// Calculate shared agreement between A: keyPair and B: other
  Uint8List calculateAgreement(KeyPair keyPair, PublicKey publicKey) {

    return Uint8List.fromList(Scalar(keyPair.privateKey.bytes).scarlarMult(publicKey.bytes));

  }

  /// Sign byte message message using keyPair
  Signature sign(KeyPair keyPair, Uint8List message, SignatureType type) {
    var messageBytes = Int8List.fromList(message);
    if (messageBytes.isEmpty) {
      throw Exception('Message Invalid!');
    }
    if (type == SignatureType.STANDARD) {
      var signature = _signStandard(keyPair, messageBytes);
      if (signature == null) {
        throw Exception('Message length exceeds maximum length');
      }
      return signature;
    }

    if (type == SignatureType.VRF) {
      var signature = _signVRF(keyPair, messageBytes);
      if (signature == null) {
        throw Exception('Message length exceeds maximum length');
      }
      return signature;
    }

    throw Exception('Signature Could not be generated at this time');
  }

  /// Verify Signature
  /// Boolean return for STANDARD SignatureType
  /// False for failure if VRF SignatureType
  /// VRF output byte array if true for VRF SignatureType
  dynamic verify(Uint8List message, Signature signature) {
    var messageBytes = Int8List.fromList(message);
    if (messageBytes.isEmpty) {
      return false;
    }
    if (signature.type == SignatureType.STANDARD) {
      return _verifyStandard(signature.publicKey, messageBytes, signature);
    } else if (signature.type == SignatureType.VRF) {
      return _verifyVRF(signature.publicKey, messageBytes, signature);
    }

    return false;
  }

  Signature? _signStandard(KeyPair keyPair, List<int> message) {
    var pubKeyPoint = ExtendedGroupElement();
    var edPubKey = List<int>.generate(
      32,
      (_) => 0,
      growable: false,
    );
    var sigBuffer = List<int>.generate(
      message.length + 128,
      (_) => 0,
      growable: false,
    );
    var signBit = 0;

    if (message.length > Constants.MSGMAXLEN) {
      return null;
    }

    pubKeyPoint = ExtendedGroupElement.scalarMultBase(keyPair.privateKey.bytes);
    edPubKey = pubKeyPoint.toBytes();

    signBit = edPubKey[31] & 0x80;

    List.copyRange(sigBuffer, 64, message);
    List.copyRange(sigBuffer, 32, keyPair.privateKey.bytes);

    sigBuffer[0] = 0xFE.toSigned(8);
    for (var i = 1; i < 32; i++){
      sigBuffer[i] = 0xFF.toSigned(8);
    }

    List.copyRange(sigBuffer, message.length + 64, Rand().randomBytes(64));

    var nonce = Sha512().digest(sigBuffer);
    List.copyRange(sigBuffer, 32, edPubKey);

    nonce = Scalar(nonce).reduction();
    var R = ExtendedGroupElement.scalarMultBase(nonce);

    List.copyRange(sigBuffer, 0, R.toBytes());

    var hram = Sha512().digest(sigBuffer.sublist(0, message.length + 64));
    hram = Scalar(hram).reduction();

    var S = Scalar(hram).mulAdd(Scalar(keyPair.privateKey.bytes), Scalar(nonce));

    List.copyRange(sigBuffer, 32, S, 0, 32);

    sigBuffer[63] &= 0x7F;
    sigBuffer[63] |= signBit;

    return Signature(
        bytes: sigBuffer.sublist(0, 64),
        publicKey: keyPair.publicKey,
        type: SignatureType.STANDARD
    );
  }

  bool _verifyStandard(PublicKey publicKey, List<int> message, Signature signature) {

    assert(signature.type == SignatureType.STANDARD);

    var montX = FieldElement.fromBytes(publicKey.bytes);
    var one = FieldElement.one();
    var montXMinusOne = montX - one;
    var montXPlusOne = montX + one;
    var invMontXPlusOne = montXPlusOne.invert();
    var edY = montXMinusOne * invMontXPlusOne;
    var edPubKey = edY.toBytes();

    edPubKey[31] &= 0x7F;  /* bit should be zero already, but just in case */
    edPubKey[31] |= (signature.bytes[63]! & 0x80);
    var verifyBuffer1 = List<int>.generate(
      message.length + 64,
      (_) => 0,
      growable: false,
    );
    var verifyBuffer2 = List<int>.generate(
      message.length + 64,
      (_) => 0,
      growable: false,
    );

    List.copyRange(verifyBuffer1, 0, signature.bytes.sublist(0, 64));
    verifyBuffer1[63] &= 0x7F;

    List.copyRange(verifyBuffer1, 64, message);

    if ((verifyBuffer1[63] & 224) != 0) return false;

    var A = ExtendedGroupElement.fromBytesNeg(edPubKey);

    if (A == null) {
      return false;
    }

    var edPubKeyCopy = Int8List.fromList(edPubKey);

    var rCopy = verifyBuffer1.sublist(0 , 32);
    var sCopy = verifyBuffer1.sublist(32, 64);

    List.copyRange(verifyBuffer2, 0, verifyBuffer1);
    List.copyRange(verifyBuffer2, 32, edPubKeyCopy);

    var h = Sha512().digest(verifyBuffer2);

    h = Scalar(Int8List.fromList(h)).reduction();

    var R = ProjectiveGroupElement().scalarMult(h, A, sCopy);
    var rCheck = R.toBytes();

    if (!ListEquality().equals(rCheck, rCopy)) {
      return false;
    }

    return true;
  }

  Signature? _signVRF(KeyPair keyPair, List<int> message) {

    if (message.length > Constants.MSGMAXLEN) {
      return null;
    }

    var curve25519KeyPair = _calculateCurveKeyPair(keyPair.privateKey);

    var mBuf = Int8List(message.length + Constants.MSTART);
    List.copyRange(mBuf, Constants.MSTART, message);

    var labelset = Labelset();
    var ret = labelset.add(labelset.length, '1'.codeUnits);
    if (ret != 0) {
      return null;
    }

    var Bv = _calculateBv(labelset, curve25519KeyPair.publicKey.bytes, mBuf, message);

    if (Bv == null) {
      return null;
    }

    var Kv = ExtendedGroupElement().scalarMult(curve25519KeyPair.privateKey.bytes, Bv);
    var bvBytes = Bv.toBytes();
    var kvBytes = Kv.toBytes();

    labelset.set(labelset.length - 1, '2'.codeUnitAt(0));

    var extra = Int8List(3 * Constants.POINTLEN);
    List.copyRange(extra, 0, bvBytes);
    List.copyRange(extra, Constants.POINTLEN, kvBytes);

    var rScalar = Int8List(Constants.SCALARLEN);
    var rBytes = _commit(rScalar, labelset, extra, 2*Constants.POINTLEN,
        curve25519KeyPair.publicKey.bytes, curve25519KeyPair.privateKey.bytes, mBuf);

    if (rBytes == null) {
      return null;
    }

    var Rv = ExtendedGroupElement().scalarMult(rScalar, Bv);
    var rvBytes = Rv.toBytes();

    labelset.set(labelset.length - 1, 3);
    List.copyRange(extra, 2 * Constants.POINTLEN, rvBytes);

    var hScalar = _challenge(labelset, extra, extra.length, rBytes, curve25519KeyPair.publicKey.bytes, mBuf);
    if (hScalar == null) {
      return null;
    }

    var sScalar = _prove(rScalar, curve25519KeyPair.privateKey.bytes, hScalar as List<int>);

    var signatureBytes = List<int>.generate(
      96,
      (_) => 0,
      growable: false,
    );

    List.copyRange(signatureBytes, 0, kvBytes);
    List.copyRange(signatureBytes, Constants.POINTLEN, hScalar);
    List.copyRange(signatureBytes, Constants.POINTLEN + Constants.SCALARLEN, sScalar);

    return Signature(
        bytes: signatureBytes,
        publicKey: keyPair.publicKey,
        type: SignatureType.VRF
    );
  }

  dynamic _verifyVRF(PublicKey publicKey, List<int> message, Signature signature){

    var edPublicKey = _convertPublicKey(publicKey)!;

    var mBuf = List<int>.generate(
      Constants.MSTART + message.length,
      (_) => 0,
      growable: false,
    )..fillRange(0, Constants.MSTART + message.length, 0);

    List.copyRange(mBuf, Constants.MSTART, message);

    var kvBytes = List<int>.generate(
      Constants.POINTLEN,
      (_) => 0,
      growable: false,
    );
    var hScalar = List<int>.generate(
      Constants.SCALARLEN,
      (_) => 0,
      growable: false,
    );
    var sScalar = List<int>.generate(
      Constants.SCALARLEN,
      (_) => 0,
      growable: false,
    );

    List.copyRange(kvBytes, 0, signature.bytes, 0, Constants.POINTLEN);
    List.copyRange(hScalar, 0, signature.bytes, Constants.POINTLEN, Constants.POINTLEN + Constants.SCALARLEN);
    List.copyRange(sScalar, 0, signature.bytes, Constants.POINTLEN + Constants.SCALARLEN, Constants.POINTLEN + Constants.SCALARLEN + Constants.SCALARLEN);

    if (!_pointIsReduced(edPublicKey) || !_pointIsReduced(kvBytes) || !Scalar(sScalar).isReduced() || !Scalar(hScalar).isReduced()) {
      return false;
    }

    var labelset = Labelset();
    labelset.add(labelset.length, '1'.codeUnits);

    var Bv = _calculateBv(labelset, edPublicKey, mBuf, message);
    if (Bv == null) {
      return false;
    }

    var bvBytes = Bv.toBytes();

    var K = ExtendedGroupElement();
    var rCalcBytes = _solveCommitment(K, null, sScalar, edPublicKey, hScalar);
    if (rCalcBytes == null) {
      return false;
    }
    var Kv = ExtendedGroupElement();
    var rvCalcBytes = _solveCommitment(Kv, Bv, sScalar, kvBytes, hScalar);

    if (rvCalcBytes == null) {
      return false;
    }

    var cK = K.scalarMultCofactor();
    var cKv = Kv.scalarMultCofactor();

    if (cK.isNeutral() || cKv.isNeutral() || Bv.isNeutral()) {
      return false;
    }

    labelset.set(labelset.length - 1, 3);

    var extra = List<int>.generate(
      3 * Constants.POINTLEN,
      (_) => 0,
      growable: false,
    );
    List.copyRange(extra, 0, bvBytes);
    List.copyRange(extra, Constants.POINTLEN, kvBytes);
    List.copyRange(extra, 2*Constants.POINTLEN, rvCalcBytes);

    var hCalcScalar = _challenge(labelset, extra, 3*Constants.POINTLEN, rCalcBytes, edPublicKey, mBuf);
    if (hCalcScalar == null) {
      return false;
    }

    if (!ListEquality<int?>().equals(hScalar, hCalcScalar)) {
      return false;
    }

    labelset.set(labelset.length - 1, 4);

    var out = _calcVRFOut(labelset, cKv);
    if (out == null) {
      return false;
    }
    return Uint8List.fromList(out as List<int>);
  }

  KeyPair _calculateCurveKeyPair(PrivateKey privateKey) {

    var edPubKeyPoint = ExtendedGroupElement.scalarMultBase(privateKey.bytes);
    var kBytes = edPubKeyPoint.toBytes();

    var signBit = (kBytes[31] & 0x80) >> 7;
    var kNeg = Scalar(privateKey.bytes).neg();
    var kScalar = Scalar(List.from(privateKey.bytes));
    kScalar.cmov(Scalar(kNeg), signBit);

    kBytes[31] &= 0x7F;

    return KeyPair(PublicKey(kBytes), PrivateKey(kScalar));
  }


  ExtendedGroupElement? _calculateBv(Labelset labelset, List<int> kBytes, List<int> mBuf, List<int> message) {

    if (!labelset.validate()) {
      return null;
    }
    var prefixLength = 2*Constants.POINTLEN + labelset.length;
    if (prefixLength > Constants.MSTART){
      return null;
    }
    var pointer = Constants.MSTART - prefixLength;
    List.copyRange(mBuf, pointer, Constants.bBytes);
    pointer += Constants.POINTLEN;
    List.copyRange(mBuf, pointer, labelset.data);
    pointer += labelset.length;
    List.copyRange(mBuf, pointer, kBytes);
    pointer += Constants.POINTLEN;

    var BvPoint = _hashToPoint(mBuf.sublist(Constants.MSTART - prefixLength));

    if (BvPoint == null) {
      return null;
    }
    if (BvPoint.isNeutral()){
      return null;
    }
    return BvPoint;
  }

  ExtendedGroupElement? _hashToPoint(List<int> inBytes) {

    var hash = Sha512().digest(inBytes);
    var signBit = (hash[31] & 0x80) >> 7;
    hash[31] &= 0x7F;
    var h = FieldElement.fromBytes(hash);
    var u = _elligator(h);
    var p3 = u.montXToExtended(signBit);
    return p3.scalarMultCofactor();
  }

  List<int>? _commit(rScalar, Labelset labelset, List<int> extra, int extraLength,
      List<int> edPubKeyBytes, List<int> privKeyScalar, List<int> mBuf) {

    if (!labelset.validate()) {
      return null;
    }
    if (rScalar == null) {
      return null;
    }
    var prefixLength = 0;
    prefixLength += Constants.POINTLEN + labelset.length + Constants.RANDLEN;
    prefixLength += ((Constants.BLOCKLEN - (prefixLength % Constants.BLOCKLEN)) % Constants.BLOCKLEN);
    prefixLength += Constants.SCALARLEN;
    prefixLength += ((Constants.BLOCKLEN - (prefixLength % Constants.BLOCKLEN)) % Constants.BLOCKLEN);
    prefixLength += labelset.length + Constants.POINTLEN + extraLength;
    if (prefixLength > Constants.MSTART){
      return null;
    }

    var start = Constants.MSTART - prefixLength;
    var pointer = 0;
    List.copyRange(mBuf, pointer + start, Constants.bBytes);
    pointer += Constants.POINTLEN;
    List.copyRange(mBuf, pointer + start, labelset.data);
    pointer += labelset.length;
    List.copyRange(mBuf, pointer + start, Rand().randomBytes(Constants.RANDLEN));
    pointer += Constants.RANDLEN;
    mBuf.fillRange(pointer + start, pointer + start + ((Constants.BLOCKLEN - (pointer % Constants.BLOCKLEN)) % Constants.BLOCKLEN), 0);
    pointer += ((Constants.BLOCKLEN - (pointer % Constants.BLOCKLEN)) % Constants.BLOCKLEN);
    List.copyRange(mBuf, pointer + start, privKeyScalar);
    pointer += Constants.SCALARLEN;
    mBuf.fillRange(pointer + start, pointer + start + ((Constants.BLOCKLEN - (pointer % Constants.BLOCKLEN)) % Constants.BLOCKLEN), 0);
    pointer += ((Constants.BLOCKLEN - (pointer % Constants.BLOCKLEN)) % Constants.BLOCKLEN);
    List.copyRange(mBuf, pointer + start, labelset.data);
    pointer += labelset.length;
    List.copyRange(mBuf, pointer + start, edPubKeyBytes);
    pointer += Constants.POINTLEN;
    List.copyRange(mBuf, pointer + start, extra.sublist(0, extraLength));
    pointer += extraLength;
    if (pointer + start != Constants.MSTART){
      return null;
    }

    var hash = Sha512().digest(mBuf.sublist(Constants.MSTART - prefixLength));
    hash = Scalar(hash).reduction();
    var rPoint = ExtendedGroupElement.scalarMultBase(hash);
    var rBytes = rPoint.toBytes();
    List.copyRange(rScalar, 0, hash, 0, Constants.SCALARLEN);
    return rBytes;
  }

  FieldElement _elligator(FieldElement a) {

    var one = FieldElement.one();
    var A = FieldElement.zero();
    A[0] = 486662;

    var twoA2 = a.square2();
    var twoA2Plus1 = twoA2 + one;
    var twoA2Plus1Inv = twoA2Plus1.invert();
    var x = twoA2Plus1Inv * A;
    x = x.neg();
    var e = x.montRHS();
    var nonSquare = e.legendreIsNonSquare();

    var Atemp = FieldElement.zero();
    Atemp.cmov(A, nonSquare);
    var out = x + Atemp;
    var outNeg = out.neg();
    out.cmov(outNeg, nonSquare);

    return out;
  }

  List<int?>? _challenge(Labelset labelset, List<int?> extra, int extraLength, List<int> rBytes, List<int> kBytes, List<int?> mBuf) {

    if (!labelset.validate()) {
      return null;
    }
    var prefixLength = 0;
    if (labelset.isEmpty()) {
      prefixLength = 2 * Constants.POINTLEN;
      if (prefixLength > Constants.MSTART) {
        return null;
      }
      List.copyRange(mBuf, Constants.MSTART - 2 * Constants.POINTLEN, rBytes);
      List.copyRange(mBuf, Constants.MSTART - Constants.POINTLEN, kBytes);
    } else {
      prefixLength = 3 * Constants.POINTLEN + 2 * labelset.length + extraLength;
      if (prefixLength > Constants.MSTART) {
        return null;
      }
      var pointer = Constants.MSTART - prefixLength;
      List.copyRange(mBuf, pointer, Constants.bBytes);
      pointer += Constants.POINTLEN;
      List.copyRange(mBuf, pointer, labelset.data);
      pointer += labelset.length;
      List.copyRange(mBuf, pointer, rBytes);
      pointer += Constants.POINTLEN;
      List.copyRange(mBuf, pointer, labelset.data);
      pointer += labelset.length;
      List.copyRange(mBuf, pointer, kBytes);
      pointer += Constants.POINTLEN;
      List.copyRange(mBuf, pointer, extra.sublist(0, extraLength));
      pointer += extraLength;
      if (pointer != Constants.MSTART){
        return null;
      }
    }

    var hash = Sha512().digest(mBuf.sublist(Constants.MSTART - prefixLength));
    hash = Scalar(hash).reduction();

    var out = List<int>.generate(
      Constants.SCALARLEN,
      (_) => 0,
      growable: false,
    );
    List.copyRange(out, 0, hash, 0, Constants.SCALARLEN);
    return out;
  }

  List<int> _prove(List<int> rScalar, List<int> kScalar, List<int> hScalar) {

    return Scalar(hScalar).mulAdd(Scalar(kScalar), Scalar(rScalar));
  }

  List<int>? _convertPublicKey(PublicKey publicKey) {

    if (!FieldElement().isReduced(publicKey.bytes)) {
      return null;
    }
    var u = FieldElement.fromBytes(publicKey.bytes);
    var y = u.toEdY();
    return y.toBytes();
  }

  bool _pointIsReduced(List<int?> p) {
    var strict = List<int>.generate(
      32,
      (_) => 0,
      growable: false,
    );
    List.copyRange(strict, 0, p);
    strict[31] &= 0x7F;
    return FieldElement().isReduced(strict);
  }

  List<int>? _solveCommitment(ExtendedGroupElement? kPoint, ExtendedGroupElement? bPoint, List<int> sScalar, List<int> kBytes, List<int> hScalar) {

    var kNegPoint = ExtendedGroupElement.fromBytesNeg(kBytes);

    if (kNegPoint == null) {
      return null;
    }

    var rBytes;

    if (bPoint == null) {
      var rCalcPointP2 = ProjectiveGroupElement().scalarMult(hScalar, kNegPoint, sScalar);
      rBytes = rCalcPointP2.toBytes();
    } else {
      var sB = ExtendedGroupElement().scalarMult(sScalar, bPoint);
      var hK = ExtendedGroupElement().scalarMult(hScalar, kNegPoint);

      var rCalcExtended = sB.add(hK);
      rBytes = rCalcExtended.toBytes();

    }

    if (kPoint != null) {
      kPoint.X.insertAll(0, kNegPoint.neg().X);
      kPoint.Y.insertAll(0, kNegPoint.neg().Y);
      kPoint.Z.insertAll(0, kNegPoint.neg().Z);
      kPoint.T.insertAll(0, kNegPoint.neg().T);
    }

    return rBytes;
  }

  List<int?>? _calcVRFOut(Labelset labelset, ExtendedGroupElement cKv) {

    var buf = List<int>.generate(
      Constants.BUFLEN,
      (_) => 0,
      growable: false,
    )..fillRange(0, Constants.BUFLEN, 0);

    if (labelset.length + 2*Constants.POINTLEN > Constants.BUFLEN) {
      return null;
    }
    if (!labelset.validate()) {
      return null;
    }

    var cKvBytes = cKv.toBytes();
    var bufptr = 0;
    List.copyRange(buf, bufptr, Constants.bBytes);
    bufptr += Constants.POINTLEN;
    List.copyRange(buf, bufptr, labelset.data);
    bufptr += labelset.length;
    List.copyRange(buf, bufptr, cKvBytes);
    bufptr += Constants.POINTLEN;
    if (bufptr > Constants.BUFLEN) {
      return null;
    }
    var hash = Sha512().digest(buf);

    var out = List<int>.generate(
      Constants.VRFOUTPUTLEN,
      (_) => 0,
      growable: false,
    );
    List.copyRange(out, 0, hash, 0, Constants.VRFOUTPUTLEN);
    return out;
  }


}