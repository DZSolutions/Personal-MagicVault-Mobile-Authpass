import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:cryptography/cryptography.dart';

class NFCResult {
  bool _isOk;
  String _data;

  bool get isOk => _isOk;
  String get data => _data;
}

Future<void> _displayNFCDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Please Tap NFC card to continue'),
      actions: [
        FlatButton(
          child: const Text('CANCEL'),
          onPressed: () {
            NfcManager.instance.stopSession();
            Navigator.pop(context, true);
          },
        )
      ],
    ),
  );
}

Future<NFCResult> initCard({
  @required BuildContext context,
  @required String masterPassword,
}) async {
  final result = NFCResult();
  NfcManager.instance.startSession(onDiscovered: (tag) async {
    result._isOk = false;
    final card = IsoDep.from(tag);
    if (card == null) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    await card.transceive(
        data: Uint8List.fromList('00A4040C0AA00000006203010C0701'.toListHex()));
    final passwordlenhex =
        (masterPassword.length ~/ 2).toRadixString(16).padLeft(2, '0');
    var cardResult = await card.transceive(
        data: Uint8List.fromList('B0010000$passwordlenhex'.toListHex()
          ..addAll(masterPassword.toListHex())));
    if (cardResult.toStringHex() != '9000') {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    cardResult = await card.transceive(
        data: Uint8List.fromList('B0020000$passwordlenhex'.toListHex()
          ..addAll(masterPassword.toListHex())));
    if (cardResult.toStringHex() != '9000') {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    cardResult = await card.transceive(
        data: Uint8List.fromList('B0040100$passwordlenhex'.toListHex()
          ..addAll(masterPassword.toListHex())));
    if (cardResult.sublist(cardResult.length - 2).toStringHex() == '9000') {
      result._isOk = true;
      result._data = cardResult.sublist(0, cardResult.length - 2).toStringHex();
    }
    NfcManager.instance.stopSession();
    Navigator.of(context, rootNavigator: true).pop();
  });
  await _displayNFCDialog(context);
  return result;
}

Future<NFCResult> verify({
  @required BuildContext context,
  @required String masterPassword,
}) async {
  final result = NFCResult();
  NfcManager.instance.startSession(onDiscovered: (tag) async {
    result._isOk = false;
    final card = IsoDep.from(tag);
    if (card == null) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    await card.transceive(
        data: Uint8List.fromList('00A4040C0AA00000006203010C0701'.toListHex()));
    final passwordlenhex =
        (masterPassword.length ~/ 2).toRadixString(16).padLeft(2, '0');
    var cardResult = await card.transceive(
        data: Uint8List.fromList('B0020000$passwordlenhex'.toListHex()
          ..addAll(masterPassword.toListHex())));
    if (cardResult.toStringHex() != '9000') {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    cardResult = await card.transceive(
        data: Uint8List.fromList('B0040100$passwordlenhex'.toListHex()
          ..addAll(masterPassword.toListHex())));
    if (cardResult.sublist(cardResult.length - 2).toStringHex() == '9000') {
      result._isOk = true;
      result._data = cardResult.sublist(0, cardResult.length - 2).toStringHex();
    }
    NfcManager.instance.stopSession();
    Navigator.of(context, rootNavigator: true).pop();
  });
  await _displayNFCDialog(context);
  return result;
}

Future<NFCResult> encryptData({
  @required BuildContext context,
  @required String masterPassword,
  @required String data,
}) async {
  final result = NFCResult();
  NfcManager.instance.startSession(onDiscovered: (tag) async {
    result._isOk = false;
    final card = IsoDep.from(tag);
    if (card == null) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    await card.transceive(
        data: Uint8List.fromList('00A4040C0AA00000006203010C0701'.toListHex()));
    var len = (masterPassword.length ~/ 2).toRadixString(16).padLeft(2, '0');
    var cardResult = await card.transceive(
        data: Uint8List.fromList(
            'B0020000$len'.toListHex()..addAll(masterPassword.toListHex())));
    if (cardResult.toStringHex() != '9000') {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    len = data.length.toRadixString(16).padLeft(2, '0');
    cardResult = await card.transceive(
        data: Uint8List.fromList(
            'B0040200$len'.toListHex()..addAll(data.codeUnits)));
    if (cardResult.sublist(cardResult.length - 2).toStringHex() == '9000') {
      result._isOk = true;
      result._data = cardResult.sublist(0, cardResult.length - 2).toStringHex();
    }
    NfcManager.instance.stopSession();
    Navigator.of(context, rootNavigator: true).pop();
  });
  await _displayNFCDialog(context);
  return result;
}

Future<NFCResult> decryptData({
  @required BuildContext context,
  @required String masterPassword,
  @required String data,
}) async {
  final result = NFCResult();
  NfcManager.instance.startSession(onDiscovered: (tag) async {
    result._isOk = false;
    final card = IsoDep.from(tag);
    if (card == null) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    await card.transceive(
        data: Uint8List.fromList('00A4040C0AA00000006203010C0701'.toListHex()));
    var len = (masterPassword.length ~/ 2).toRadixString(16).padLeft(2, '0');
    var cardResult = await card.transceive(
        data: Uint8List.fromList(
            'B0020000$len'.toListHex()..addAll(masterPassword.toListHex())));
    if (cardResult.toStringHex() != '9000') {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    len = (data.length ~/ 2).toRadixString(16).padLeft(2, '0');
    cardResult = await card.transceive(
        data: Uint8List.fromList(
            'B0050200$len'.toListHex()..addAll(data.toListHex())));
    if (cardResult.sublist(cardResult.length - 2).toStringHex() == '9000') {
      result._isOk = true;
      result._data = utf8.decode(cardResult.sublist(0, cardResult.length - 2));
    }
    NfcManager.instance.stopSession();
    Navigator.of(context, rootNavigator: true).pop();
  });
  await _displayNFCDialog(context);
  return result;
}

// nonce 948d0a7ad498d23484ea947b9855bf6
const List<int> _nonce = [
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00
];

Future<String> _computeHash(String password) async {
  const pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac(sha256),
    iterations: 36000,
    bits: 128,
  );
  final hash =
      await pbkdf2.deriveBits(utf8.encode(password), nonce: Nonce(_nonce));
  final hashString = hash.toStringHex();
  return hashString;
}

Future<String> computeHash(String password) async {
  return await compute(_computeHash, password);
}

List<int> toListHex2(String str) {
  List<int> temp = [];
  for (int i = 0; i < str.length; i += 2) {
    temp.add(int.parse(str.substring(i, i + 2), radix: 16));
  }
  return temp;
}

extension StringParsing on String {
  List<int> toListHex() {
    List<int> temp = [];
    for (int i = 0; i < this.length; i += 2) {
      temp.add(int.parse(this.substring(i, i + 2), radix: 16));
    }
    return temp;
  }
}

extension ListParsing on Uint8List {
  String toStringHex() {
    String temp = '';
    for (final u8 in this) {
      temp += u8.toRadixString(16).padLeft(2, '0');
    }
    return temp;
  }
}
