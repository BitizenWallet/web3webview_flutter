// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RPCError _$RPCErrorFromJson(Map<String, dynamic> json) => RPCError(
      json['errorCode'] as int,
      json['message'] as String,
      json['data'],
    );

Map<String, dynamic> _$RPCErrorToJson(RPCError instance) => <String, dynamic>{
      'errorCode': instance.errorCode,
      'message': instance.message,
      'data': instance.data,
    };

Web3RpcWalletAddEthereumChain _$Web3RpcWalletAddEthereumChainFromJson(
        Map<String, dynamic> json) =>
    Web3RpcWalletAddEthereumChain(
      json['chainId'] as String,
      (json['rpcUrls'] as List<dynamic>?)?.map((e) => e as String).toList(),
      json['chainName'] as String?,
      Web3RpcWalletAddEthereumChainNativeInfo.fromJson(
          json['nativeCurrency'] as Map<String, dynamic>),
      (json['blockExplorerUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    )..iconUrls =
        (json['iconUrls'] as List<dynamic>?)?.map((e) => e as String).toList();

Map<String, dynamic> _$Web3RpcWalletAddEthereumChainToJson(
        Web3RpcWalletAddEthereumChain instance) =>
    <String, dynamic>{
      'chainId': instance.chainId,
      'blockExplorerUrls': instance.blockExplorerUrls,
      'chainName': instance.chainName,
      'iconUrls': instance.iconUrls,
      'nativeCurrency': instance.nativeCurrency,
      'rpcUrls': instance.rpcUrls,
    };

Web3RpcWalletSwitchEthereumChain _$Web3RpcWalletSwitchEthereumChainFromJson(
        Map<String, dynamic> json) =>
    Web3RpcWalletSwitchEthereumChain(
      json['chainId'] as String,
    );

Map<String, dynamic> _$Web3RpcWalletSwitchEthereumChainToJson(
        Web3RpcWalletSwitchEthereumChain instance) =>
    <String, dynamic>{
      'chainId': instance.chainId,
    };

Web3RpcWalletWatchAsset _$Web3RpcWalletWatchAssetFromJson(
        Map<String, dynamic> json) =>
    Web3RpcWalletWatchAsset(
      json['type'] as String,
      Web3RpcWalletWatchAssetOptions.fromJson(
          json['options'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$Web3RpcWalletWatchAssetToJson(
        Web3RpcWalletWatchAsset instance) =>
    <String, dynamic>{
      'type': instance.type,
      'options': instance.options,
    };

Web3RpcWalletAddEthereumChainNativeInfo
    _$Web3RpcWalletAddEthereumChainNativeInfoFromJson(
            Map<String, dynamic> json) =>
        Web3RpcWalletAddEthereumChainNativeInfo(
          json['name'] as String,
          json['decimals'] as int,
          json['symbol'] as String,
        );

Map<String, dynamic> _$Web3RpcWalletAddEthereumChainNativeInfoToJson(
        Web3RpcWalletAddEthereumChainNativeInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'decimals': instance.decimals,
      'symbol': instance.symbol,
    };

Web3RpcWalletWatchAssetOptions _$Web3RpcWalletWatchAssetOptionsFromJson(
        Map<String, dynamic> json) =>
    Web3RpcWalletWatchAssetOptions(
      json['address'] as String,
      json['symbol'] as String?,
      json['decimals'] as int?,
      json['image'] as String?,
    );

Map<String, dynamic> _$Web3RpcWalletWatchAssetOptionsToJson(
        Web3RpcWalletWatchAssetOptions instance) =>
    <String, dynamic>{
      'address': instance.address,
      'symbol': instance.symbol,
      'decimals': instance.decimals,
      'image': instance.image,
    };
