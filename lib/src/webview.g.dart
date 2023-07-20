// GENERATED CODE - DO NOT MODIFY BY HAND

part of web3webview_flutter;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Web3RpcRequest _$Web3RpcRequestFromJson(Map<String, dynamic> json) =>
    Web3RpcRequest(
      json['method'] as String,
      id: json['id'] as int?,
      jsonrpc: json['jsonrpc'] as String?,
      params: json['params'],
    );

Map<String, dynamic> _$Web3RpcRequestToJson(Web3RpcRequest instance) =>
    <String, dynamic>{
      'method': instance.method,
      'id': instance.id,
      'jsonrpc': instance.jsonrpc,
      'params': instance.params,
    };

Web3RpcResponse _$Web3RpcResponseFromJson(Map<String, dynamic> json) =>
    Web3RpcResponse(
      id: json['id'] as int?,
      jsonrpc: json['jsonrpc'] as String?,
      result: json['result'],
      error: json['error'],
    );

Map<String, dynamic> _$Web3RpcResponseToJson(Web3RpcResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jsonrpc': instance.jsonrpc,
      'result': instance.result,
      'error': instance.error,
    };
