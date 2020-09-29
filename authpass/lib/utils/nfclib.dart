import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

Future<void> displayNFCDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Please Tap NFC card to continue'),
      content: Text('content'),
      actions: [
        FlatButton(
          child: Text('CANCEL'),
          onPressed: () {
            NfcManager.instance.stopSession();
            Navigator.pop(context, true);
          },
        )
      ],
    ),
  );
}

Future<void> init({
  @required BuildContext context,
  @required String masterPasswordHash,
}) async {
  await NfcManager.instance.startSession(onDiscovered: (tag) async {
    final card = IsoDep.from(tag);
    if (card == null) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }
    try {
      await card.transceive(
          data:
              Uint8List.fromList("00A4040C0Aa00000006203010c0701".toListHex()));
      final passwordlenhex =
          masterPasswordHash.length.toRadixString(16).padLeft(2, '0');
      final result = await card.transceive(
          data: Uint8List.fromList("B0010000$passwordlenhex".toListHex()
            ..addAll(masterPasswordHash.codeUnits)));
      print(result.toStringHex());
      // if (result.toStringHex() == '6982') {
      //   NfcManager.instance.stopSession();
      //   Navigator.of(context, rootNavigator: true).pop();
      //   return true;
      // }
      NfcManager.instance.stopSession();
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      return;
    }
  });
  await displayNFCDialog(context);
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
      temp += u8.toRadixString(16);
    }
    return temp;
  }
}
