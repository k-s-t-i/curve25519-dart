import 'dart:typed_data';

import 'package:curve25519_VRF/curve25519.dart';

void main() {
  var message = Uint8List.fromList('This is a very important message!'.codeUnits);
  var keyPair = Curve25519().newKeyPair();
  var signature = Curve25519().sign(keyPair, message, SignatureType.STANDARD);

  if (signature.isValid(message)){
    print('Signature is valid!');
  }

  var signatureVRF = Curve25519().sign(keyPair, message, SignatureType.VRF);

  if (signatureVRF.isValid(message) is List) {
    print('VRF Signature is valid!');
  }

  var bobKeyPair = Curve25519().newKeyPair();
  var aliceKeyPair = Curve25519().newKeyPair();

  var agreement = Curve25519().calculateAgreement(bobKeyPair, aliceKeyPair.publicKey);
  print("This is Bob's and Alice's agreement: " + agreement.toString());
}