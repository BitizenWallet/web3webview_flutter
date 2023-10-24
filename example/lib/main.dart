import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3webview_flutter/web3webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InAppWebViewController.setWebContentsDebuggingEnabled(true);
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
  final demoAccounts = [
    "0x0000000000000000000000000000000000000000",
    "0x0000000000000000000000000000000000000001"
  ];

  Web3WebViewController? _web3WebViewController;

  Future<Web3RpcResponse> _callback(Web3RpcRequest req) async {
    log("bingo _callback ${req.toJson()}");
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
    // _testUpdateRpcUrl(controller);
  }

  // ignore: unused_element
  void _testUpdateRpcUrl(InAppWebViewController controller) async {
    await Future.delayed(const Duration(seconds: 60));
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
          androidEnableUserScript: false,
          initialSettings: InAppWebViewSettings(
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
            useHybridComposition: true,
            supportMultipleWindows: true,
            allowsInlineMediaPlayback: true,
          ),
          initialUrlRequest:
              URLRequest(url: WebUri.uri(Uri.parse("https://uniswap.org"))),
          // URLRequest(url: WebUri.uri(Uri.parse("https://web3-react-mu.vercel.app"))),
          // URLRequest(url: WebUri.uri(Uri.parse("https://web3modal.com"))),
          // URLRequest(url: WebUri.uri(Uri.parse("https://app.sushi.com/en/swap"))),
          // URLRequest(url: Uri.parse("https://baidu.com")),
          // URLRequest(
          //     url: Uri.parse("https://ddg.gg/?q=ethereum+account+balance")),
          // URLRequest(url: WebUri.uri(
          //             Uri.parse("https://pancakeswap.finance/swap"))),
          // URLRequest(url: WebUri.uri(Uri.parse("https://playtimedao.io"))),
          // URLRequest(url: WebUri.uri(Uri.parse("https://opensea.io"))),
          // URLRequest(url: Uri.parse("https://www.sandbox.game")),
          // URLRequest(url: Uri.parse("https://httpbin.org/anything")),
          // URLRequest(url: WebUri.uri(Uri.parse("http://192.168.55.163:8090"))),
          // URLRequest(url: WebUri.uri(
          //             Uri.parse("https://bitizenwallet.github.io/test-dapp/"))),
          onWeb3WebViewCreated: _onWeb3WebViewCreated,
          onLoadStop: _onPageFinished,
          shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
          onReceivedError: _onReceivedError,
          debugEnabled: true,
          onCreateWindow: (controller, createWindowAction) {
            return Future.value(false);
          },
        ),
      ),
    );
  }

  void _onWeb3WebViewCreated(Web3WebViewController controller) {
    _web3WebViewController = controller;
  }

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
    var uri = navigationAction.request.url!;

    log("bingo _shouldOverrideUrlLoading ${uri.toString()}");

    if (!["http", "https", "file", "chrome", "data", "javascript", "about"]
        .contains(uri.scheme)) {
      if (await canLaunch(uri.toString())) {
        await launch(
          uri.toString(),
        );
      }
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  void _onReceivedError(InAppWebViewController controller,
      WebResourceRequest? req, WebResourceError? err) {
    log("bingo _onReceivedError $req $err");
  }
}
