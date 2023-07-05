import 'package:flutter_test/flutter_test.dart';

import 'package:web3webview_flutter/web3webview_flutter.dart';

void main() {
  test('ok', () {
    Web3WebView(_callback, () => Future.value("0x1"));
  });
}

Future<Web3RpcResponse> _callback(Web3RpcRequest p1) async {
  return Web3RpcResponse(error: "error");
}
