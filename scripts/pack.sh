echo "import 'dart:convert';

String injectJs = utf8.fuse(base64).decode(\"`cat assets/inject.js | base64`\");
String injectJsBundle = Uri.encodeComponent(utf8.fuse(base64).decode(\"`cat assets/index.js | base64`\"));
" > lib/src/assets.dart