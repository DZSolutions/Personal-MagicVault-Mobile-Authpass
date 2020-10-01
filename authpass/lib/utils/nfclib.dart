import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:cryptography/cryptography.dart';
import 'package:provider/provider.dart';

class NFCResult {
  bool _isOk = false;
  String _data;
  Uint8List _dataList;

  bool get isOk => _isOk;
  String get data => _data;
  Uint8List get dataList => _dataList;

  void clear() {
    _isOk = false;
    _data = null;
    _dataList = null;
  }
}

class MasterPassword {
  Uint8List hash;
}

void saveMasterPasswordHash(BuildContext context, Uint8List hash) {
  Provider.of<MasterPassword>(context, listen: false).hash = hash;
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

Future<NFCResult> initCard(BuildContext context) async {
  final result = NFCResult();
  NfcManager.instance.startSession(onDiscovered: (tag) async {
    result.clear();
    final masterPasswordHash =
        Provider.of<MasterPassword>(context, listen: false).hash;
    final card = IsoDep.from(tag);
    if (card == null) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    await card.transceive(
        data: Uint8List.fromList('00A4040C0AA00000006203010C0701'.toListHex()));
    final passwordlenhex =
        masterPasswordHash.length.toRadixString(16).padLeft(2, '0');
    var cardResult = await card.transceive(
        data: Uint8List.fromList(
            'B0010000$passwordlenhex'.toListHex()..addAll(masterPasswordHash)));
    if (cardResult.toStringHex() != '9000') {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    cardResult = await card.transceive(
        data: Uint8List.fromList(
            'B0020000$passwordlenhex'.toListHex()..addAll(masterPasswordHash)));
    if (cardResult.toStringHex() != '9000') {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    cardResult = await card.transceive(
        data: Uint8List.fromList(
            'B0040100$passwordlenhex'.toListHex()..addAll(masterPasswordHash)));
    if (cardResult.sublist(cardResult.length - 2).toStringHex() == '9000') {
      cardResult = cardResult.sublist(0, cardResult.length - 2);
      result._isOk = true;
      result._dataList = cardResult;
      result._data = cardResult.toStringHex();
    }
    NfcManager.instance.stopSession();
    Navigator.of(context, rootNavigator: true).pop();
  });
  await _displayNFCDialog(context);
  return result;
}

Future<NFCResult> verify(BuildContext context) async {
  final result = NFCResult();
  NfcManager.instance.startSession(onDiscovered: (tag) async {
    result.clear();
    final masterPasswordHash =
        Provider.of<MasterPassword>(context, listen: false).hash;
    final card = IsoDep.from(tag);
    if (card == null) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    await card.transceive(
        data: Uint8List.fromList('00A4040C0AA00000006203010C0701'.toListHex()));
    final passwordlenhex =
        masterPasswordHash.length.toRadixString(16).padLeft(2, '0');
    var cardResult = await card.transceive(
        data: Uint8List.fromList(
            'B0020000$passwordlenhex'.toListHex()..addAll(masterPasswordHash)));
    if (cardResult.toStringHex() != '9000') {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    cardResult = await card.transceive(
        data: Uint8List.fromList(
            'B0040100$passwordlenhex'.toListHex()..addAll(masterPasswordHash)));
    if (cardResult.sublist(cardResult.length - 2).toStringHex() == '9000') {
      cardResult = cardResult.sublist(0, cardResult.length - 2);
      result._isOk = true;
      result._dataList = cardResult;
      result._data = cardResult.toStringHex();
    }
    NfcManager.instance.stopSession();
    Navigator.of(context, rootNavigator: true).pop();
  });
  await _displayNFCDialog(context);
  return result;
}

Future<NFCResult> encryptData({
  @required BuildContext context,
  @required String data,
}) async {
  final result = NFCResult();
  NfcManager.instance.startSession(onDiscovered: (tag) async {
    result.clear();
    final masterPasswordHash =
        Provider.of<MasterPassword>(context, listen: false).hash;
    final card = IsoDep.from(tag);
    if (card == null) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    await card.transceive(
        data: Uint8List.fromList('00A4040C0AA00000006203010C0701'.toListHex()));
    var len = masterPasswordHash.length.toRadixString(16).padLeft(2, '0');
    var cardResult = await card.transceive(
        data: Uint8List.fromList(
            'B0020000$len'.toListHex()..addAll(masterPasswordHash)));
    if (cardResult.toStringHex() != '9000') {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    len = data.length.toRadixString(16).padLeft(2, '0');
    cardResult = await card.transceive(
        data: Uint8List.fromList(
            'B0040200$len'.toListHex()..addAll(data.codeUnits)));
    if (cardResult.sublist(cardResult.length - 2).toStringHex() == '9000') {
      cardResult = cardResult.sublist(0, cardResult.length - 2);
      result._isOk = true;
      result._dataList = cardResult;
      result._data = cardResult.toStringHex();
    }
    NfcManager.instance.stopSession();
    Navigator.of(context, rootNavigator: true).pop();
  });
  await _displayNFCDialog(context);
  return result;
}

Future<NFCResult> decryptData({
  @required BuildContext context,
  @required String data,
}) async {
  final result = NFCResult();
  NfcManager.instance.startSession(onDiscovered: (tag) async {
    result.clear();
    final masterPasswordHash =
        Provider.of<MasterPassword>(context, listen: false).hash;
    final card = IsoDep.from(tag);
    if (card == null) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    await card.transceive(
        data: Uint8List.fromList('00A4040C0AA00000006203010C0701'.toListHex()));
    var len = masterPasswordHash.length.toRadixString(16).padLeft(2, '0');
    var cardResult = await card.transceive(
        data: Uint8List.fromList(
            'B0020000$len'.toListHex()..addAll(masterPasswordHash)));
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

Future<Uint8List> _computeHash(String password) async {
  const pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac(sha256),
    iterations: 36000,
    bits: 128,
  );
  final hash =
      await pbkdf2.deriveBits(utf8.encode(password), nonce: Nonce(_nonce));
  // final hashString = hash.toStringHex();
  return hash;
}

Future<Uint8List> computeHash(String password) async {
  return await compute(_computeHash, password);
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
