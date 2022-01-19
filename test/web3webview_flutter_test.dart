import 'package:flutter_test/flutter_test.dart';

import 'package:web3webview_flutter/web3webview_flutter.dart';

Future<Web3RpcResponse> _callback(Web3RpcRequest p1) async {
  return Web3RpcResponse(error: "error");
}

void main() {
  test('ok', () {
    Web3WebView(1.toRadixString(16), "https://cloudflare-eth.com", _callback);
  });
}
