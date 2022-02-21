library web3webview_flutter;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:web3webview_flutter/assets.dart';

part 'web3webview_flutter.g.dart';

@JsonSerializable()
class Web3RpcRequest {
  final String chainId;
  final String method;
  final int? id;
  final String? jsonrpc;
  final Object? params;

  Web3RpcRequest(this.chainId, this.method,
      {this.id, this.jsonrpc, this.params});

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
  late String chainId;
  late String rpcUrl;
  InAppWebViewController? inAppWebViewController;

  Web3WebViewController(
    this.chainId,
    this.rpcUrl, {
    this.inAppWebViewController,
  });

  Future<dynamic> emitEvent(String topic, List<dynamic> args) {
    return inAppWebViewController!.evaluateJavascript(
        source:
            'window.ethereum._BitizenEventEmit("$topic", "${jsonEncode(args)}");');
  }

  Future<dynamic> emitChainChanged(String newChainId) {
    return inAppWebViewController!.evaluateJavascript(
        source:
            'window.ethereum._BitizenEventEmit("chainChanged", ["$newChainId"]);');
  }

  Future<dynamic> emitNetworkChanged(int networkId) {
    return inAppWebViewController!.evaluateJavascript(
        source:
            'window.ethereum._BitizenEventEmit("networkChanged", [$networkId]);');
  }

  Future<dynamic> emitAccountsChanged(List<String> newAccounts) {
    return inAppWebViewController!.evaluateJavascript(
        source:
            'window.ethereum._BitizenEventEmit("accountsChanged", ${jsonEncode(newAccounts)});');
  }

  Future<dynamic> updateRpcUrl(String _chainId, String _rpcUrl) {
    chainId = _chainId;
    rpcUrl = _rpcUrl;
    return inAppWebViewController!.evaluateJavascript(
        source: 'window.ethereum._BitizenUpdateRpcUrl("$chainId", "$rpcUrl");');
  }
}

class Web3WebView extends StatefulWidget {
  final String initialChainId;
  final String initialRpcUrl;
  final bool? debugEnabled;
  final bool? keepAlive;
  final Future<Web3RpcResponse> Function(Web3RpcRequest) onRpcRequest;

  final URLRequest? initialUrlRequest;
  final void Function(Web3WebViewController)? onWeb3WebViewCreated;

  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;
  final int? windowId;

  final void Function(InAppWebViewController controller)?
      androidOnGeolocationPermissionsHidePrompt;
  final Future<GeolocationPermissionShowPromptResponse?> Function(
          InAppWebViewController controller, String origin)?
      androidOnGeolocationPermissionsShowPrompt;
  final Future<PermissionRequestResponse?> Function(
      InAppWebViewController controller,
      String origin,
      List<String> resources)? androidOnPermissionRequest;
  final Future<SafeBrowsingResponse?> Function(
      InAppWebViewController controller,
      Uri url,
      SafeBrowsingThreat? threatType)? androidOnSafeBrowsingHit;
  final InAppWebViewInitialData? initialData;
  final String? initialFile;
  final InAppWebViewGroupOptions? initialOptions;
  final UnmodifiableListView<UserScript>? initialUserScripts;
  final PullToRefreshController? pullToRefreshController;
  final ContextMenu? contextMenu;
  final void Function(InAppWebViewController controller, Uri? url)?
      onPageCommitVisible;
  final void Function(InAppWebViewController controller, String? title)?
      onTitleChanged;
  final void Function(InAppWebViewController controller)?
      iosOnDidReceiveServerRedirectForProvisionalNavigation;
  final void Function(InAppWebViewController controller)?
      iosOnWebContentProcessDidTerminate;
  final Future<IOSNavigationResponseAction?> Function(
      InAppWebViewController controller,
      IOSWKNavigationResponse navigationResponse)? iosOnNavigationResponse;
  final Future<IOSShouldAllowDeprecatedTLSAction?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? iosShouldAllowDeprecatedTLS;
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
  final void Function(InAppWebViewController controller, Uint8List icon)?
      androidOnReceivedIcon;
  final void Function(
          InAppWebViewController controller, Uri url, bool precomposed)?
      androidOnReceivedTouchIconUrl;
  final void Function(InAppWebViewController controller, Uri url)?
      onDownloadStart;
  final void Function(InAppWebViewController controller, int activeMatchOrdinal,
      int numberOfMatches, bool isDoneCounting)? onFindResultReceived;
  final Future<JsAlertResponse?> Function(
          InAppWebViewController controller, JsAlertRequest jsAlertRequest)?
      onJsAlert;
  final Future<JsConfirmResponse?> Function(
          InAppWebViewController controller, JsConfirmRequest jsConfirmRequest)?
      onJsConfirm;
  final Future<JsPromptResponse?> Function(
          InAppWebViewController controller, JsPromptRequest jsPromptRequest)?
      onJsPrompt;
  final void Function(InAppWebViewController controller, Uri? url, int code,
      String message)? onLoadError;
  final void Function(InAppWebViewController controller, Uri? url,
      int statusCode, String description)? onLoadHttpError;
  final void Function(
          InAppWebViewController controller, LoadedResource resource)?
      onLoadResource;
  final Future<CustomSchemeResponse?> Function(
      InAppWebViewController controller, Uri url)? onLoadResourceCustomScheme;
  final void Function(InAppWebViewController controller, Uri? url)? onLoadStart;
  final void Function(InAppWebViewController controller, Uri? url)? onLoadStop;
  final void Function(InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult)? onLongPressHitTestResult;
  final void Function(InAppWebViewController controller, Uri? url)? onPrint;
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
  final void Function(
          InAppWebViewController controller, double oldScale, double newScale)?
      onZoomScaleChanged;
  // final Future<WebResourceResponse?> Function(
  //         InAppWebViewController controller, WebResourceRequest request)?
  //     androidShouldInterceptRequest;
  final Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, Uri? url)?
      androidOnRenderProcessUnresponsive;
  final Future<WebViewRenderProcessAction?> Function(
          InAppWebViewController controller, Uri? url)?
      androidOnRenderProcessResponsive;
  final void Function(
          InAppWebViewController controller, RenderProcessGoneDetail detail)?
      androidOnRenderProcessGone;
  final Future<FormResubmissionAction?> Function(
      InAppWebViewController controller, Uri? url)? androidOnFormResubmission;
  final Future<JsBeforeUnloadResponse?> Function(
      InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest)? androidOnJsBeforeUnload;
  final void Function(
          InAppWebViewController controller, LoginRequest loginRequest)?
      androidOnReceivedLoginRequest;

  const Web3WebView(
    this.initialChainId,
    this.initialRpcUrl,
    this.onRpcRequest, {
    Key? key,
    this.keepAlive,
    this.onWeb3WebViewCreated,
    this.initialUrlRequest,
    this.gestureRecognizers,
    this.windowId,
    this.androidOnGeolocationPermissionsHidePrompt,
    this.androidOnGeolocationPermissionsShowPrompt,
    this.androidOnPermissionRequest,
    this.androidOnSafeBrowsingHit,
    this.initialData,
    this.initialFile,
    this.initialOptions,
    this.initialUserScripts,
    this.pullToRefreshController,
    this.contextMenu,
    this.onPageCommitVisible,
    this.onTitleChanged,
    this.iosOnDidReceiveServerRedirectForProvisionalNavigation,
    this.iosOnWebContentProcessDidTerminate,
    this.iosOnNavigationResponse,
    this.iosShouldAllowDeprecatedTLS,
    this.onAjaxProgress,
    this.onAjaxReadyStateChange,
    this.onConsoleMessage,
    this.onCreateWindow,
    this.onCloseWindow,
    this.onWindowFocus,
    this.onWindowBlur,
    this.androidOnReceivedIcon,
    this.androidOnReceivedTouchIconUrl,
    this.onDownloadStart,
    this.onFindResultReceived,
    this.onJsAlert,
    this.onJsConfirm,
    this.onJsPrompt,
    this.onLoadError,
    this.onLoadHttpError,
    this.onLoadResource,
    this.onLoadResourceCustomScheme,
    this.onLoadStart,
    this.onLoadStop,
    this.onLongPressHitTestResult,
    this.onPrint,
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
    this.onZoomScaleChanged,
    this.androidOnRenderProcessUnresponsive,
    this.androidOnRenderProcessResponsive,
    this.androidOnRenderProcessGone,
    this.androidOnFormResubmission,
    this.androidOnJsBeforeUnload,
    this.androidOnReceivedLoginRequest,
    this.debugEnabled,
  }) : super(key: key);

  @override
  State<Web3WebView> createState() => _Web3WebViewState();
}

class _Web3WebViewState extends State<Web3WebView>
    with AutomaticKeepAliveClientMixin<Web3WebView> {
  InAppWebViewGroupOptions? initialOptions;
  late Web3WebViewController _web3webViewController;

  @override
  initState() {
    super.initState();
    if (widget.debugEnabled ?? false) {
      log("web3webview_flutter Web3WebView initState keepAlive:${widget.keepAlive} url:${widget.initialUrlRequest?.url}");
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

  UnmodifiableListView<UserScript> getAllUserScript(Uri? url) {
    final debugable = (widget.debugEnabled ?? false) ||
        (url?.toString() ?? "").contains("__debug");
    if (debugable) {
      log("web3webview_flutter getAllUserScript url: $url, debugable: $debugable");
    }

    return UnmodifiableListView([
      UserScript(
          source: injectJs
              .replaceFirst("#BITIZEN_INJECT#", injectJsBundle)
              .replaceFirst("#BITIZEN_DEBUG#", debugable ? "√" : "")
              .replaceFirst(
                  "#BITIZEN_INIT_CHAIN_ID#", _web3webViewController.chainId)
              .replaceFirst(
                  "#BITIZEN_INIT_RPC_URL#", _web3webViewController.rpcUrl),
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START),
      ...?widget.initialUserScripts,
    ]);
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
    super.build(context);

    if (widget.debugEnabled ?? false) {
      log("web3webview_flutter Web3WebView build keepAlive:${widget.keepAlive} url:${widget.initialUrlRequest?.url}");
    }

    if (Platform.isAndroid) {
      initialOptions = widget.initialOptions ?? InAppWebViewGroupOptions();
      initialOptions!.android.useShouldInterceptRequest = true;
    } else {
      initialOptions = widget.initialOptions;
    }
    _web3webViewController =
        Web3WebViewController(widget.initialChainId, widget.initialRpcUrl);

    final allUserScript = getAllUserScript(widget.initialUrlRequest?.url);

    return InAppWebView(
      onWebViewCreated: _onWeb3WebViewCreated,
      initialUrlRequest: widget.initialUrlRequest,
      windowId: widget.windowId,
      initialFile: widget.initialFile,
      initialData: widget.initialData,
      initialOptions: widget.initialOptions,
      initialUserScripts: allUserScript,
      pullToRefreshController: widget.pullToRefreshController,
      contextMenu: widget.contextMenu,
      onLoadStart: widget.onLoadStart,
      onLoadStop: widget.onLoadStop,
      onLoadError: widget.onLoadError,
      onLoadHttpError: widget.onLoadHttpError,
      onConsoleMessage: widget.onConsoleMessage,
      onProgressChanged: widget.onProgressChanged,
      shouldOverrideUrlLoading: widget.shouldOverrideUrlLoading,
      onLoadResource: widget.onLoadResource,
      onScrollChanged: widget.onScrollChanged,
      onDownloadStart: widget.onDownloadStart,
      onLoadResourceCustomScheme: widget.onLoadResourceCustomScheme,
      onCreateWindow: widget.onCreateWindow,
      onCloseWindow: widget.onCloseWindow,
      onJsAlert: widget.onJsAlert,
      onJsConfirm: widget.onJsConfirm,
      onJsPrompt: widget.onJsPrompt,
      onReceivedHttpAuthRequest: widget.onReceivedHttpAuthRequest,
      onReceivedServerTrustAuthRequest: widget.onReceivedServerTrustAuthRequest,
      onReceivedClientCertRequest: widget.onReceivedClientCertRequest,
      onFindResultReceived: widget.onFindResultReceived,
      shouldInterceptAjaxRequest: widget.shouldInterceptAjaxRequest,
      onAjaxReadyStateChange: widget.onAjaxReadyStateChange,
      onAjaxProgress: widget.onAjaxProgress,
      shouldInterceptFetchRequest: widget.shouldInterceptFetchRequest,
      onUpdateVisitedHistory: widget.onUpdateVisitedHistory,
      onPrint: widget.onPrint,
      onLongPressHitTestResult: widget.onLongPressHitTestResult,
      onEnterFullscreen: widget.onEnterFullscreen,
      onExitFullscreen: widget.onExitFullscreen,
      onPageCommitVisible: widget.onPageCommitVisible,
      onTitleChanged: widget.onTitleChanged,
      onWindowFocus: widget.onWindowFocus,
      onWindowBlur: widget.onWindowBlur,
      onOverScrolled: widget.onOverScrolled,
      onZoomScaleChanged: widget.onZoomScaleChanged,
      androidOnSafeBrowsingHit: widget.androidOnSafeBrowsingHit,
      androidOnPermissionRequest: widget.androidOnPermissionRequest,
      androidOnGeolocationPermissionsShowPrompt:
          widget.androidOnGeolocationPermissionsShowPrompt,
      androidOnGeolocationPermissionsHidePrompt:
          widget.androidOnGeolocationPermissionsHidePrompt,
      androidShouldInterceptRequest: androidShouldInterceptRequest,
      androidOnRenderProcessGone: widget.androidOnRenderProcessGone,
      androidOnRenderProcessResponsive: widget.androidOnRenderProcessResponsive,
      androidOnRenderProcessUnresponsive:
          widget.androidOnRenderProcessUnresponsive,
      androidOnFormResubmission: widget.androidOnFormResubmission,
      androidOnReceivedIcon: widget.androidOnReceivedIcon,
      androidOnReceivedTouchIconUrl: widget.androidOnReceivedTouchIconUrl,
      androidOnJsBeforeUnload: widget.androidOnJsBeforeUnload,
      androidOnReceivedLoginRequest: widget.androidOnReceivedLoginRequest,
      iosOnWebContentProcessDidTerminate:
          widget.iosOnWebContentProcessDidTerminate,
      iosOnDidReceiveServerRedirectForProvisionalNavigation:
          widget.iosOnDidReceiveServerRedirectForProvisionalNavigation,
      iosOnNavigationResponse: widget.iosOnNavigationResponse,
      iosShouldAllowDeprecatedTLS: widget.iosShouldAllowDeprecatedTLS,
      gestureRecognizers: widget.gestureRecognizers,
    );
  }

  Future<WebResourceResponse?> androidShouldInterceptRequest(
      InAppWebViewController controller, WebResourceRequest request) async {
    final req = http.Request(request.method ?? "GET", request.url);
    request.headers?.forEach((key, value) {
      req.headers[key] = value;
    });
    final originResp = await req.send();
    final contentTypeHeader = originResp.headers["Content-Type"]?.split(";");
    final contentEncoding = contentTypeHeader?[1].split("=");
    final resp = WebResourceResponse(
      contentType: contentTypeHeader?[0] ?? "",
      contentEncoding: contentEncoding?[1] ?? "utf-8",
      data: await originResp.stream.toBytes(),
      headers: originResp.headers,
      statusCode: originResp.statusCode,
      reasonPhrase: originResp.reasonPhrase,
    );

    if (resp.contentType == "text/html") {
      final allUserScripts = getAllUserScript(req.url);

      String userScriptInject = "";
      for (var s in allUserScripts) {
        userScriptInject += "<script>${s.source}</script>";
      }

      final body = String.fromCharCodes(resp.data ?? []);
      if (body.contains("</head>")) {
        userScriptInject += "</head>";
        resp.data = Uint8List.fromList(
            body.replaceFirst("</head>", userScriptInject).codeUnits);
      } else if (body.contains("<body>")) {
        userScriptInject = "<body>" + userScriptInject;
        resp.data = Uint8List.fromList(
            body.replaceFirst("<body>", userScriptInject).codeUnits);
      }
    }

    if (widget.debugEnabled ?? false) {
      log("web3webview_flutter androidShouldInterceptRequest ${req.url.toString()} ${resp.contentType}");
    }

    return resp;
  }

  @override
  bool get wantKeepAlive => widget.keepAlive ?? false;
}
