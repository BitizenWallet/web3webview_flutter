import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web3webview_flutter/web3webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _title = 'Flutter Demo Home Page';
  List<String> _rpc = [
    "0x${56.toRadixString(16)}",
    "https://bsc-dataseed.binance.org"
  ];

  final demoAccounts = [
    "0x0000000000000000000000000000000000000000",
    "0x0000000000000000000000000000000000000001"
  ];

  Web3WebViewController? _web3WebViewController;

  Future<Web3RpcResponse> _callback(Web3RpcRequest req) async {
    switch (req.method) {
      case "wallet_requestPermissions":
      case "wallet_getPermissions":
        return Web3RpcResponse(id: req.id, jsonrpc: req.jsonrpc, result: [
          {
            "parentCapability": "eth_accounts",
            "caveats": [
              {
                "type": "limitResponseLength",
                "value": 1,
                "name": "primaryAccountOnly"
              },
              {
                "type": "filterResponse",
                "value": demoAccounts,
                "name": "exposedAccounts"
              }
            ]
          }
        ]);
      case "eth_requestAccounts":
      case "eth_accounts":
        return Web3RpcResponse(
            id: req.id, jsonrpc: req.jsonrpc, result: demoAccounts);
      default:
        return Web3RpcResponse(
            id: req.id, jsonrpc: req.jsonrpc, error: "error");
    }
  }

  void _onPageFinished(InAppWebViewController controller, Uri? url) async {
    log("_onPageFinished $url");
    final t = await controller.getTitle();
    setState(() {
      _title = t ?? "";
    });
    _testUpdateRpcUrl(controller);
  }

  void _testUpdateRpcUrl(InAppWebViewController controller) async {
    await Future.delayed(const Duration(seconds: 60));
    log("testUpdateRpcUrl");
    _rpc = ["0x${100.toRadixString(16)}", "https://rpc.gnosischain.com"];
    await _web3WebViewController!.updateRpcUrl(_rpc[0], _rpc[1]);
    await _web3WebViewController!
        .emitChainChanged("0x${100.toRadixString(16)}");
    await _web3WebViewController!.emitNetworkChanged(100);
    await _web3WebViewController!
        .emitAccountsChanged(["0x0000000000000000000000000000000000000002"]);
    log("testUpdateRpcUrl done");
    await Future.delayed(const Duration(seconds: 10));
    log("testUpdateRpcUrl test reload page");
    await _web3WebViewController!.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _web3WebViewController?.reload(),
          child: const Text("X")),
      body: Center(
        child: Web3WebView(
          _callback,
          _onRetriveRpc,
          initialUrlRequest:
          // URLRequest(url: Uri.parse("https://web3-react-mu.vercel.app")),
          // URLRequest(url: Uri.parse("https://web3modal.com")),
          // URLRequest(url: Uri.parse("https://app.sushi.com/en/swap")),
          // URLRequest(url: Uri.parse("https://metamask.github.io/test-dapp/")),
          URLRequest(url: Uri.parse("https://pancakeswap.finance/swap")),
          // URLRequest(url: Uri.parse("https://app.uniswap.org")),
          onWeb3WebViewCreated: _onWeb3WebViewCreated,
          onLoadStop: _onPageFinished,
          debugEnabled: true,
        ),
      ),
    );
  }

  void _onWeb3WebViewCreated(Web3WebViewController controller) {
    _web3WebViewController = controller;
  }

  List<String> _onRetriveRpc() {
    return _rpc;
  }
}
