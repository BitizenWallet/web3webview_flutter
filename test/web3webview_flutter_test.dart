import 'package:flutter_test/flutter_test.dart';

import 'package:web3webview_flutter/web3webview_flutter.dart';

void main() {
  test('ok', () {
    const Web3WebView(_callback);
  });
}

Future<Web3RpcResponse> _callback(Web3RpcRequest p1) async {
  return Web3RpcResponse(error: "error");
}
