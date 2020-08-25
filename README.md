# Curve25519 Dart
A native Dart Library for Curve25519 suite, including x25519 key pairs, shared secrets, x25519 signatures and the XVEdDSA VRF signature algorithm.

## Installing

```
import 'curve25519/curve25519.dart';
```

The package requires the following dependencies:
```$xslt
dependencies:
  pointycastle:
  collection:
```

## Usage

Below is the syntax for using the Curve25519 Package.

#### Messages

All messages must be given in the form of Uint8List.
```
var message = "message".codeUnits;
```

#### Key Pairs
All KeyPairs are stored in the KeyPair object.

```$xslt
var keyPair = Curve25519().newKeyPair();

var publicKey = keyPair.publicKey;
var privateKey = keyPair.privateKey;

var publicKeyBytes = publicKey.bytes;
var privateKeyBytes = privateKey.bytes;
```

#### Signing
```$xslt
var signatureStandard = Curve25519().sign(keyPair, message, SignatureType.STANDARD);
var signatureVRF = Curve25519().sign(keyPair, message, SignatureType.VRF);
```

#### Verifying
Standard verification returns Boolean.

VRF verification returns false if failure or VRF output byte array if valid.

```$xslt
var isValid = signature.isValid(message);
```

## License

Licensed under the FreeBSD License: https://opensource.org/licenses/bsd-license.php