import 'package:json_annotation/json_annotation.dart';

part 'rpc.g.dart';

@JsonSerializable()
class RPCError implements Exception {
  final int code;
  final String message;
  final dynamic data;

  const RPCError(this.code, this.message, this.data);

  @override
  String toString() {
    return 'RPCError: got code $code with msg "$message".';
  }

  factory RPCError.fromJson(Map<String, dynamic> json) =>
      _$RPCErrorFromJson(json);

  Map<String, dynamic> toJson() => _$RPCErrorToJson(this);
}

// ignore: constant_identifier_names
const RpcErrorChainDisconnected = RPCError(4901, "Chain Disconnected", null);
// ignore: constant_identifier_names
const RpcErrorDisconnected = RPCError(4900, "Disconnected", null);
// ignore: constant_identifier_names
const RpcErrorUnauthorized = RPCError(4100, "Unauthorized", null);
// ignore: constant_identifier_names
const RpcErrorUnsupportedMethod = RPCError(4200, "Unsupported Method", null);
// ignore: constant_identifier_names
const RpcErrorUserRejected = RPCError(4001, "User Rejected Request", null);

// https://eips.ethereum.org/EIPS/eip-3085
@JsonSerializable()
class Web3RpcWalletAddEthereumChain {
  String chainId;
  List<String>? blockExplorerUrls;
  String? chainName;
  List<String>? iconUrls;
  Web3RpcWalletAddEthereumChainNativeInfo nativeCurrency;
  List<String>? rpcUrls;

  Web3RpcWalletAddEthereumChain(this.chainId, this.rpcUrls, this.chainName,
      this.nativeCurrency, this.blockExplorerUrls);

  factory Web3RpcWalletAddEthereumChain.fromJson(Map<String, dynamic> json) =>
      _$Web3RpcWalletAddEthereumChainFromJson(json);

  Map<String, dynamic> toJson() => _$Web3RpcWalletAddEthereumChainToJson(this);
}

// https://ethereum-magicians.org/t/eip-3326-wallet-switchethereumchain
@JsonSerializable()
class Web3RpcWalletSwitchEthereumChain {
  String chainId;

  Web3RpcWalletSwitchEthereumChain(this.chainId);

  factory Web3RpcWalletSwitchEthereumChain.fromJson(
          Map<String, dynamic> json) =>
      _$Web3RpcWalletSwitchEthereumChainFromJson(json);

  Map<String, dynamic> toJson() =>
      _$Web3RpcWalletSwitchEthereumChainToJson(this);
}

// https://eips.ethereum.org/EIPS/eip-747
@JsonSerializable()
class Web3RpcWalletWatchAsset {
  String type; // eg: "ERC20"
  Web3RpcWalletWatchAssetOptions options;

  Web3RpcWalletWatchAsset(this.type, this.options);

  factory Web3RpcWalletWatchAsset.fromJson(Map<String, dynamic> json) =>
      _$Web3RpcWalletWatchAssetFromJson(json);

  Map<String, dynamic> toJson() => _$Web3RpcWalletWatchAssetToJson(this);
}

@JsonSerializable()
class Web3RpcWalletAddEthereumChainNativeInfo {
  String name;
  int decimals;
  String symbol;

  Web3RpcWalletAddEthereumChainNativeInfo(
      this.name, this.decimals, this.symbol);

  factory Web3RpcWalletAddEthereumChainNativeInfo.fromJson(
          Map<String, dynamic> json) =>
      _$Web3RpcWalletAddEthereumChainNativeInfoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$Web3RpcWalletAddEthereumChainNativeInfoToJson(this);
}

@JsonSerializable()
class Web3RpcWalletWatchAssetOptions {
  String address;
  String? symbol;
  int? decimals;
  String? image;

  Web3RpcWalletWatchAssetOptions(
      this.address, this.symbol, this.decimals, this.image);

  factory Web3RpcWalletWatchAssetOptions.fromJson(Map<String, dynamic> json) =>
      _$Web3RpcWalletWatchAssetOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$Web3RpcWalletWatchAssetOptionsToJson(this);
}
