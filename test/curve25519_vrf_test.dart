import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:test/test.dart';

import 'package:curve25519_vrf/curve25519_vrf.dart';
import 'package:curve25519_vrf/src/constants.dart';
import 'package:curve25519_vrf/src/ed25519.dart';


void main() {

  group('Constants', () {

    test('base', () {
        expect(Constants.base.length == 32, isTrue);
        expect(Constants.base[0].length == 8, isTrue);
    });
  });

  group('FieldElement', () {

    FieldElement a;
    FieldElement b;

    setUp(() {
      a = FieldElement();
      b = FieldElement.one();
    });

    test('insertAll', (){
      var c = FieldElement();
      c.insertAll(0, b + b);
      expect(c.length == 10, isTrue);
      expect(c[0] == 2, isTrue);
    });

    test('add', () {
      expect(a + b == b, isTrue);
    });

    test('subtract', () {
      expect(b - b == a, isTrue);
    });

    test('cmov', () {
      var c = FieldElement.one();
      c.cmov(a, 0);
      expect(b == c, isTrue);
    });

    test('fromBytes', () {
      var bytes = List<int>(32)..fillRange(0, 32, 0);
      var fe = FieldElement.fromBytes(bytes);
      assert(fe.isZero, isTrue);

      bytes = Rand().randomBytes(32);
      fe = FieldElement.fromBytes(bytes);
      assert(!fe.isZero, isTrue);
    });
  });


  group('ExtendedGroupElement', () {

    test('constructor', () {
      var a = ExtendedGroupElement();
      expect(a.X.length == 10, isTrue);
      expect(a.Y.length == 10, isTrue);
      expect(a.Z.length == 10, isTrue);
      expect(a.T.length == 10, isTrue);
    });
    
    test('scalarMultVsScalarMultBase', () {

      var bBytes = Uint8List.fromList([
        0x58, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66,
        0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66,
        0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66,
        0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66,
      ]);

      var miscBytes = Uint8List.fromList([
        0x57, 0x17, 0xfa, 0xce, 0xca, 0xb9, 0xdf, 0x0e,
        0x90, 0x67, 0xaa, 0x46, 0xba, 0x83, 0x2f, 0xeb,
        0x1c, 0x49, 0xd0, 0x21, 0xb1, 0x33, 0xff, 0x11,
        0xc9, 0x7a, 0xb8, 0xcf, 0xe3, 0x29, 0x46, 0x17,
      ]);

      var qScalar = Uint8List.fromList([
        0xed, 0xd3, 0xf5, 0x5c, 0x1a, 0x63, 0x12, 0x58,
        0xd6, 0x9c, 0xf7, 0xa2, 0xde, 0xf9, 0xde, 0x14,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10,
      ]);

      var neutralBytes = Uint8List.fromList([
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
      ]);


      var point1, point2, bPoint, miscnegPoint = ExtendedGroupElement();

      bPoint = ExtendedGroupElement.fromBytesNeg(bBytes);
      expect(bPoint != null, isTrue);
      miscnegPoint = ExtendedGroupElement.fromBytesNeg(miscBytes);
      expect(miscnegPoint != null, isTrue);
      bPoint = bPoint.neg();

      point1 = ExtendedGroupElement.scalarMultBase(qScalar);
      point2 = ExtendedGroupElement().scalarMult(qScalar, bPoint);

      var output1 = point1.toBytes();
      var output2 = point2.toBytes();
      expect(ListEquality().equals(output1, neutralBytes), isTrue);
      expect(ListEquality().equals(output2, output1), isTrue);

    });

  });

  group('Curve25519', () {

    test('verify', (){
      var aliceIdentityPrivate = Int8List.fromList([
        0xc0, 0x97, 0x24, 0x84, 0x12,
        0xe5, 0x8b, 0xf0, 0x5d, 0xf4,
        0x87, 0x96, 0x82, 0x05, 0x13,
        0x27, 0x94, 0x17, 0x8e, 0x36,
        0x76, 0x37, 0xf5, 0x81, 0x8f,
        0x81, 0xe0, 0xe6, 0xce, 0x73,
        0xe8, 0x65]);

      var aliceIdentityPublic  = Int8List.fromList([
        0xab, 0x7e, 0x71, 0x7d,
        0x4a, 0x16, 0x3b, 0x7d, 0x9a,
        0x1d, 0x80, 0x71, 0xdf, 0xe9,
        0xdc, 0xf8, 0xcd, 0xcd, 0x1c,
        0xea, 0x33, 0x39, 0xb6, 0x35,
        0x6b, 0xe8, 0x4d, 0x88, 0x7e,
        0x32, 0x2c, 0x64]);

      var aliceEphemeralPublic = Uint8List.fromList([
        0x05, 0xed, 0xce, 0x9d, 0x9c,
        0x41, 0x5c, 0xa7, 0x8c, 0xb7,
        0x25, 0x2e, 0x72, 0xc2, 0xc4,
        0xa5, 0x54, 0xd3, 0xeb, 0x29,
        0x48, 0x5a, 0x0e, 0x1d, 0x50,
        0x31, 0x18, 0xd1, 0xa8, 0x2d,
        0x99, 0xfb, 0x4a]);

      var aliceSig = Int8List.fromList([
        0x5d, 0xe8, 0x8c, 0xa9, 0xa8,
        0x9b, 0x4a, 0x11, 0x5d, 0xa7,
        0x91, 0x09, 0xc6, 0x7c, 0x9c,
        0x74, 0x64, 0xa3, 0xe4, 0x18,
        0x02, 0x74, 0xf1, 0xcb, 0x8c,
        0x63, 0xc2, 0x98, 0x4e, 0x28,
        0x6d, 0xfb, 0xed, 0xe8, 0x2d,
        0xeb, 0x9d, 0xcd, 0x9f, 0xae,
        0x0b, 0xfb, 0xb8, 0x21, 0x56,
        0x9b, 0x3d, 0x90, 0x01, 0xbd,
        0x81, 0x30, 0xcd, 0x11, 0xd4,
        0x86, 0xce, 0xf0, 0x47, 0xbd,
        0x60, 0xb8, 0x6e, 0x88]);

      var aliceKeyPair = KeyPair(PublicKey(aliceIdentityPublic), PrivateKey(aliceIdentityPrivate));
      var aliceSignature = Signature(aliceSig, aliceKeyPair.publicKey, SignatureType.STANDARD);

      expect(Curve25519().verify(aliceEphemeralPublic, aliceSignature), isTrue);

      for (var i=0;i<aliceSignature.bytes.length;i++) {
        var modifiedSig = List<int>.from(aliceSignature.bytes);
        modifiedSig[i] ^= 0x01;
        var modifiedSignature = Signature(modifiedSig, aliceKeyPair.publicKey, SignatureType.STANDARD);
        expect(!Curve25519().verify(aliceEphemeralPublic, modifiedSignature), isTrue);
      }
    });

    test('signature', () {
      var keyPair = Curve25519().newKeyPair();
      var message1 = Uint8List(32);
      var message2 = Uint8List(32);
      message2[0] = 1;
      var signature = Curve25519().sign(keyPair, message1, SignatureType.STANDARD);
      expect(Curve25519().verify(message1, signature), isTrue);
      expect(!Curve25519().verify(message2, signature), isTrue);
    });
    
    test('agreement', () {
      var alicePublic  = Int8List.fromList([
         0x1b,  0xb7,  0x59,  0x66,
         0xf2,  0xe9,  0x3a,  0x36,  0x91,
         0xdf,  0xff,  0x94,  0x2b,  0xb2,
         0xa4,  0x66,  0xa1,  0xc0,  0x8b,
         0x8d,  0x78,  0xca,  0x3f,  0x4d,
         0x6d,  0xf8,  0xb8,  0xbf,  0xa2,
         0xe4,  0xee,  0x28]);

      var alicePrivate = Int8List.fromList([
         0xc8,  0x06,  0x43,  0x9d,  0xc9,
         0xd2,  0xc4,  0x76,  0xff,  0xed,
         0x8f,  0x25,  0x80,  0xc0,  0x88,
         0x8d,  0x58,  0xab,  0x40,  0x6b,
         0xf7,  0xae,  0x36,  0x98,  0x87,
         0x90,  0x21,  0xb9,  0x6b,  0xb4,
         0xbf,  0x59]);

      var bobPublic    = Int8List.fromList([
         0x65,  0x36,  0x14,  0x99,
         0x3d,  0x2b,  0x15,  0xee,  0x9e,
         0x5f,  0xd3,  0xd8,  0x6c,  0xe7,
         0x19,  0xef,  0x4e,  0xc1,  0xda,
         0xae,  0x18,  0x86,  0xa8,  0x7b,
         0x3f,  0x5f,  0xa9,  0x56,  0x5a,
         0x27,  0xa2,  0x2f]);

      var bobPrivate   = Int8List.fromList([
         0xb0,  0x3b,  0x34,  0xc3,  0x3a,
         0x1c,  0x44,  0xf2,  0x25,  0xb6,
         0x62,  0xd2,  0xbf,  0x48,  0x59,
         0xb8,  0x13,  0x54,  0x11,  0xfa,
         0x7b,  0x03,  0x86,  0xd4,  0x5f,
         0xb7,  0x5d,  0xc5,  0xb9,  0x1b,
         0x44,  0x66]);

      var shared       = Int8List.fromList([
         0x32,  0x5f,  0x23,  0x93,  0x28,
         0x94,  0x1c,  0xed,  0x6e,  0x67,
         0x3b,  0x86,  0xba,  0x41,  0x01,
         0x74,  0x48,  0xe9,  0x9b,  0x64,
         0x9a,  0x9c,  0x38,  0x06,  0xc1,
         0xdd,  0x7c,  0xa4,  0xc4,  0x77,
         0xe6,  0x29]);

      var aliceKeyPair = KeyPair(PublicKey(alicePublic), PrivateKey(alicePrivate));
      var bobKeyPair = KeyPair(PublicKey(bobPublic), PrivateKey(bobPrivate));
      var sharedOne = Curve25519().calculateAgreement(aliceKeyPair, bobKeyPair.publicKey);
      var sharedTwo = Curve25519().calculateAgreement(bobKeyPair, aliceKeyPair.publicKey);

      expect(ListEquality().equals(shared, Int8List.fromList(sharedOne)), isTrue);
      expect(ListEquality().equals(shared, Int8List.fromList(sharedTwo)), isTrue);
    });

    test('VRFSigs', () {
      var keyPair = Curve25519().newKeyPair();

      var message1 = Uint8List(32);
      var message2 = Uint8List(108);

      var signature = Curve25519().sign(keyPair, message1, SignatureType.VRF);

      expect(Curve25519().verify(message1, signature) is List, isTrue);
      expect(!Curve25519().verify(message2, signature), isTrue);
    });

    test('largeSignatures', () {
      var message1 = Uint8List(1024*1024);
      var message2 = Uint8List(1048576);
      var message3 = Uint8List(1048576+1);
      var keyPair = Curve25519().newKeyPair();
      var signature1 = Curve25519().sign(keyPair, message1, SignatureType.STANDARD);
      var signature2 = Curve25519().sign(keyPair, message2, SignatureType.STANDARD);
      expect(() => Curve25519().sign(keyPair, message3, SignatureType.STANDARD), throwsException);

      expect(Curve25519().verify(message1, signature1), isTrue);
      expect(Curve25519().verify(message2, signature2), isTrue);

      var signatureVRF1 = Curve25519().sign(keyPair, message1, SignatureType.VRF);
      var signatureVRF2 = Curve25519().sign(keyPair, message2, SignatureType.VRF);
      expect(() => Curve25519().sign(keyPair, message3, SignatureType.VRF), throwsException);

      expect(Curve25519().verify(message1, signatureVRF1) is List, isTrue);
      expect(Curve25519().verify(message2, signatureVRF2) is List, isTrue);
    });
  });
}
