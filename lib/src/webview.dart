library web3webview_flutter;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:json_annotation/json_annotation.dart';

import 'assets.dart';

part 'webview.g.dart';

@JsonSerializable()
class Web3RpcRequest {
  final String method;
  final int? id;
  final String? jsonrpc;
  final Object? params;

  Web3RpcRequest(this.method, {this.id, this.jsonrpc, this.params});

  factory Web3RpcRequest.fromJson(Map<String, dynamic> json) =>
      _$Web3RpcRequestFromJson(json);

  Map<String, dynamic> toJson() => _$Web3RpcRequestToJson(this);
}

@JsonSerializable()
class Web3RpcResponse {
  final int? id;
  final String? jsonrpc;
  final Object? result;
  final Object? error;

  Web3RpcResponse({this.id, this.jsonrpc, this.result, this.error}) {
    assert(result == null || error == null);
  }

  factory Web3RpcResponse.fromJson(Map<String, dynamic> json) =>
      _$Web3RpcResponseFromJson(json);

  Map<String, dynamic> toJson() => _$Web3RpcResponseToJson(this);
}

class Web3WebViewController {
  InAppWebViewController? inAppWebViewController;
  Web3WebView widget;

  Web3WebViewController(
    this.widget, {
    InAppWebViewController? inAppWebViewController,
  }) {
    inAppWebViewController = inAppWebViewController;
  }

  Future<Uint8List?> takeScreenshot(
      {ScreenshotConfiguration? screenshotConfiguration}) async {
    return inAppWebViewController?.takeScreenshot(
        screenshotConfiguration: screenshotConfiguration);
  }

  Future<Uri?> getUrl() async {
    return inAppWebViewController?.getUrl();
  }

  Future<void> goBack() async {
    return inAppWebViewController?.goBack();
  }

  Future<void> goForward() async {
    return inAppWebViewController?.goForward();
  }

  Future<void> loadUrl(URLRequest req) async {
    return inAppWebViewController?.loadUrl(urlRequest: req);
  }

  Future<bool?> canGoBack() async {
    return inAppWebViewController?.canGoBack();
  }

  Future<dynamic> emitEvent(String topic, List<dynamic> args) async {
    return inAppWebViewController?.evaluateJavascript(
        source:
            'window.ethereum._BitizenEventEmit("$topic", "${jsonEncode(args)}");');
  }

  Future<dynamic> emitChainChanged(String newChainId) async {
    assert(newChainId.startsWith("0x"));
    return inAppWebViewController?.evaluateJavascript(
        source:
            'window.ethereum._BitizenEventEmit("chainChanged", ["$newChainId"]);');
  }

  Future<dynamic> emitNetworkChanged(int networkId) async {
    return inAppWebViewController?.evaluateJavascript(
        source:
            'window.ethereum._BitizenEventEmit("networkChanged", [$networkId]);');
  }

  Future<dynamic> emitConnect(String chainId) async {
    assert(chainId.startsWith("0x"));
    return inAppWebViewController?.evaluateJavascript(
        source:
            'window.ethereum._BitizenEventEmit("connect", [{"chainId": "$chainId"}]);');
  }

  Future<dynamic> emitAccountsChanged(List<String> newAccounts) async {
    return inAppWebViewController?.evaluateJavascript(
        source:
            'window.ethereum._BitizenEventEmit("accountsChanged", [${jsonEncode(newAccounts)}]);');
  }

  UnmodifiableListView<UserScript> getAllUserScript(Uri? url) {
    return UnmodifiableListView([
      UserScript(
        source: injectJs.replaceFirst("#BITIZEN_INJECT#", injectJsBundle),
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        forMainFrameOnly: true,
      ),
      ...?widget.initialUserScripts,
    ]);
  }

  Future<void> reload() async {
    return Platform.isAndroid
        ? inAppWebViewController?.reload()
        : inAppWebViewController?.loadUrl(
            urlRequest: URLRequest(
                url: await inAppWebViewController?.getUrl() ??
                    widget.initialUrlRequest!.url!));
  }
}

class Web3WebView extends StatefulWidget {
  final bool? debugEnabled;
  final bool
      androidEnableUserScript; // injectScript: enable: async disable: sync
  // final Future<WebResourceResponse?> Function(
  //         InAppWebViewController controller, WebResourceRequest request)?
  //     androidShouldInterceptRequest;
  final Future<Web3RpcResponse> Function(Web3RpcRequest) onRpcRequest;

  final URLRequest? initialUrlRequest;
  final void Function(Web3WebViewController)? onWeb3WebViewCreated;

  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;
  final int? windowId;

  final InAppWebViewSettings? initialSettings;
  final UnmodifiableListView<UserScript>? initialUserScripts;
  final PullToRefreshController? pullToRefreshController;
  final ContextMenu? contextMenu;
  final void Function(InAppWebViewController controller, Uri? url)?
      onPageCommitVisible;
  final void Function(InAppWebViewController controller, String? title)?
      onTitleChanged;
  final Future<AjaxRequestAction> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxProgress;
  final Future<AjaxRequestAction?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxReadyStateChange;
  final void Function(
          InAppWebViewController controller, ConsoleMessage consoleMessage)?
      onConsoleMessage;
  final Future<bool?> Function(InAppWebViewController controller,
      CreateWindowAction createWindowAction)? onCreateWindow;
  final void Function(InAppWebViewController controller)? onCloseWindow;
  final void Function(InAppWebViewController controller)? onWindowFocus;
  final void Function(InAppWebViewController controller)? onWindowBlur;
  final Future<JsAlertResponse?> Function(
          InAppWebViewController controller, JsAlertRequest jsAlertRequest)?
      onJsAlert;
  final Future<JsConfirmResponse?> Function(
          InAppWebViewController controller, JsConfirmRequest jsConfirmRequest)?
      onJsConfirm;
  final Future<JsPromptResponse?> Function(
          InAppWebViewController controller, JsPromptRequest jsPromptRequest)?
      onJsPrompt;
  final void Function(
          InAppWebViewController, WebResourceRequest, WebResourceError)?
      onReceivedError;
  final void Function(
          InAppWebViewController, WebResourceRequest, WebResourceResponse)?
      onReceivedHttpError;
  final void Function(
          InAppWebViewController controller, LoadedResource resource)?
      onLoadResource;
  final void Function(InAppWebViewController controller, Uri? url)? onLoadStart;
  final void Function(InAppWebViewController controller, Uri? url)? onLoadStop;
  final void Function(InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult)? onLongPressHitTestResult;
  final void Function(InAppWebViewController controller, int progress)?
      onProgressChanged;
  final Future<ClientCertResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedClientCertRequest;
  final Future<HttpAuthResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedHttpAuthRequest;
  final Future<ServerTrustAuthResponse?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedServerTrustAuthRequest;
  final void Function(InAppWebViewController controller, int x, int y)?
      onScrollChanged;
  final void Function(
          InAppWebViewController controller, Uri? url, bool? androidIsReload)?
      onUpdateVisitedHistory;
  final Future<AjaxRequest?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      shouldInterceptAjaxRequest;
  final Future<FetchRequest?> Function(
          InAppWebViewController controller, FetchRequest fetchRequest)?
      shouldInterceptFetchRequest;
  final Future<NavigationActionPolicy?> Function(
          InAppWebViewController controller, NavigationAction navigationAction)?
      shouldOverrideUrlLoading;
  final void Function(InAppWebViewController controller)? onEnterFullscreen;
  final void Function(InAppWebViewController controller)? onExitFullscreen;
  final void Function(InAppWebViewController controller, int x, int y,
      bool clampedX, bool clampedY)? onOverScrolled;
  final void Function(InAppWebViewController)? onWebContentProcessDidTerminate;

  const Web3WebView(this.onRpcRequest,
      {Key? key,
      this.onWeb3WebViewCreated,
      this.initialUrlRequest,
      this.gestureRecognizers,
      this.windowId,
      this.initialSettings,
      this.initialUserScripts,
      this.pullToRefreshController,
      this.contextMenu,
      this.onPageCommitVisible,
      this.onTitleChanged,
      this.onAjaxProgress,
      this.onAjaxReadyStateChange,
      this.onConsoleMessage,
      this.onCreateWindow,
      this.onCloseWindow,
      this.onWindowFocus,
      this.onWindowBlur,
      this.onJsAlert,
      this.onJsConfirm,
      this.onJsPrompt,
      this.onReceivedError,
      this.onReceivedHttpError,
      this.onLoadResource,
      this.onLoadStart,
      this.onLoadStop,
      this.onLongPressHitTestResult,
      this.onProgressChanged,
      this.onReceivedClientCertRequest,
      this.onReceivedHttpAuthRequest,
      this.onReceivedServerTrustAuthRequest,
      this.onScrollChanged,
      this.onUpdateVisitedHistory,
      this.shouldInterceptAjaxRequest,
      this.shouldInterceptFetchRequest,
      this.shouldOverrideUrlLoading,
      this.onEnterFullscreen,
      this.onExitFullscreen,
      this.onOverScrolled,
      this.debugEnabled,
      this.androidEnableUserScript = true,
      this.onWebContentProcessDidTerminate})
      : super(key: key);

  @override
  State<Web3WebView> createState() => _Web3WebViewState();
}

class _Web3WebViewState extends State<Web3WebView> {
  InAppWebViewSettings? initialSettings;
  late Web3WebViewController _web3webViewController;

  @override
  initState() {
    super.initState();
    if (widget.debugEnabled ?? false) {
      log("web3webview_flutter Web3WebView initState url:${widget.initialUrlRequest?.url}");
    }
  }

  @override
  dispose() {
    super.dispose();
    if (widget.debugEnabled ?? false) {
      log("web3webview_flutter Web3WebView dispose url:${widget.initialUrlRequest?.url}");
    }
  }

  _onWeb3WebViewCreated(InAppWebViewController controller) async {
    if (widget.debugEnabled ?? false) {
      log("web3webview_flutter _onWeb3WebViewCreated $controller");
    }
    _web3webViewController.inAppWebViewController = controller;

    controller.addJavaScriptHandler(
        handlerName: "BitizenRpcRequest", callback: _bitizenRpcRequest);

    if (widget.onWeb3WebViewCreated != null) {
      widget.onWeb3WebViewCreated!(_web3webViewController);
    }
  }

  Future<dynamic> _bitizenRpcRequest(List<dynamic> msg) async {
    if (widget.debugEnabled ?? false) {
      log("web3webview_flutter _bitizenRpcRequest ${msg.first}");
    }
    final resp = await widget
        .onRpcRequest(Web3RpcRequest.fromJson(jsonDecode(msg.first)));
    if (widget.debugEnabled ?? false) {
      log("web3webview_flutter _bitizenRpcResponse ${jsonEncode(resp)}");
    }
    return resp;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.debugEnabled ?? false) {
      log("web3webview_flutter Web3WebView build url:${widget.initialUrlRequest?.url}");
    }

    if (Platform.isAndroid) {
      initialSettings = widget.initialSettings ?? InAppWebViewSettings();
      if (!widget.androidEnableUserScript) {
        initialSettings!.useShouldInterceptRequest = false;
        initialSettings!.useShouldInterceptResponse = true;
      }
    } else {
      initialSettings = widget.initialSettings;
    }

    _web3webViewController = Web3WebViewController(widget);

    return InAppWebView(
      onWebViewCreated: _onWeb3WebViewCreated,
      initialUrlRequest: widget.initialUrlRequest,
      windowId: widget.windowId,
      initialSettings: initialSettings,
      initialUserScripts: _web3webViewController
          .getAllUserScript(widget.initialUrlRequest?.url),
      // androidShouldInterceptRequest: widget.androidEnableUserScript
      //     ? widget.androidShouldInterceptRequest
      //     : androidShouldInterceptRequest,
      shouldInterceptResponse: widget.androidEnableUserScript
          ? null
          : androidShouldInterceptResponse,
      pullToRefreshController: widget.pullToRefreshController,
      contextMenu: widget.contextMenu,
      onLoadStart: widget.onLoadStart,
      onLoadStop: widget.onLoadStop,
      onReceivedError: widget.onReceivedError,
      onReceivedHttpError: widget.onReceivedHttpError,
      onConsoleMessage: widget.onConsoleMessage,
      onProgressChanged: widget.onProgressChanged,
      shouldOverrideUrlLoading: widget.shouldOverrideUrlLoading,
      onLoadResource: widget.onLoadResource,
      onScrollChanged: widget.onScrollChanged,
      onCreateWindow: widget.onCreateWindow,
      onCloseWindow: widget.onCloseWindow,
      onJsAlert: widget.onJsAlert,
      onJsConfirm: widget.onJsConfirm,
      onJsPrompt: widget.onJsPrompt,
      onReceivedHttpAuthRequest: widget.onReceivedHttpAuthRequest,
      onReceivedServerTrustAuthRequest: widget.onReceivedServerTrustAuthRequest,
      onReceivedClientCertRequest: widget.onReceivedClientCertRequest,
      shouldInterceptAjaxRequest: widget.shouldInterceptAjaxRequest,
      onAjaxReadyStateChange: widget.onAjaxReadyStateChange,
      onAjaxProgress: widget.onAjaxProgress,
      shouldInterceptFetchRequest: widget.shouldInterceptFetchRequest,
      onUpdateVisitedHistory: widget.onUpdateVisitedHistory,
      onLongPressHitTestResult: widget.onLongPressHitTestResult,
      onEnterFullscreen: widget.onEnterFullscreen,
      onExitFullscreen: widget.onExitFullscreen,
      onPageCommitVisible: widget.onPageCommitVisible,
      onTitleChanged: widget.onTitleChanged,
      onWindowFocus: widget.onWindowFocus,
      onWindowBlur: widget.onWindowBlur,
      onOverScrolled: widget.onOverScrolled,
      gestureRecognizers: widget.gestureRecognizers,
      onWebContentProcessDidTerminate: widget.onWebContentProcessDidTerminate,
    );
  }

  Future<WebResourceResponse?> androidShouldInterceptResponse(
      InAppWebViewController controller, WebResourceResponse resp) async {
    if (resp.contentType == "text/html") {
      final allUserScripts = _web3webViewController.getAllUserScript(null);

      String userScriptInject = "";
      for (var s in allUserScripts) {
        userScriptInject += "<script>${s.source}</script>";
      }

      final body = String.fromCharCodes(resp.data ?? []);
      if (body.contains("<head>")) {
        resp.data = Uint8List.fromList(
            body.replaceFirst("<head>", "<head>" + userScriptInject).codeUnits);
      } else if (body.contains("<body>")) {
        resp.data = Uint8List.fromList(
            body.replaceFirst("<body>", "<body>" + userScriptInject).codeUnits);
      }
    }

    resp.statusCode ??= 200;
    resp.reasonPhrase ??= 'Status OK';

    if (widget.debugEnabled ?? false) {
      log("web3webview_flutter androidShouldInterceptResponse ${resp.contentType}");
    }

    return resp;
  }
}
