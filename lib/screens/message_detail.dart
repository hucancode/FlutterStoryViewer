// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pop_template/widgets/radial_expansion.dart';

class MessageDetail extends StatelessWidget {
  final Completer<WebViewController> controller = Completer<WebViewController>();

  static const double kMinRadius = 32.0;
  static const double kMaxRadius = 128.0;
  static RectTween customTween(Rect? begin, Rect? end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }

  final int id;
  final String? title;
  final String? banner;
  final String? content;

  MessageDetail({Key? key, required this.id, this.title, this.banner, this.content})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title??"Untitled"),
        ),
        body: buildMessageViewer(),
        // Container(
        //   color: Theme.of(context).canvasColor,
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     mainAxisSize: MainAxisSize.max,
        //     children: [
        //       SizedBox(
        //         width: kMaxRadius * 2.0,
        //         height: kMaxRadius * 2.0,
        //         child: buildHeroWidget(context),
        //       ),
        //       Padding(
        //         padding: EdgeInsets.all(20.0),
        //         child: Text(
        //           content??"No content.",
        //           style: TextStyle(fontWeight: FontWeight.bold),
        //           textScaleFactor: 1.0,
        //         ),
        //       ),
        //       const SizedBox(width: double.infinity, height: 16.0),
        //     ],
        //   ),
        // ),
        );
  }

  Hero buildHeroWidget(BuildContext context) {
    return Hero(
      createRectTween: customTween,
      tag: id,
      child: RadialExpansion(
        maxRadius: kMaxRadius,
        child: buildMessageBanner(),
      ),
    );
  }
  

  Widget buildMessageViewer()
  {
    final String contentBase64 = base64Encode(const Utf8Encoder().convert(content??""));
    String url = 'data:text/html;base64,$contentBase64';
    
    return WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            controller.complete(webViewController);
          },
          onProgress: (int progress) {
            print("WebView is loading (progress : $progress%)");
          },
          navigationDelegate: onWebNavigation,
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          gestureNavigationEnabled: true,
        );
  }

  FutureOr<NavigationDecision> onWebNavigation(NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            print('blocking navigation to $request}');
            return NavigationDecision.prevent;
          }
          print('allowing navigation to $request');
          return NavigationDecision.navigate;
        }

  Widget buildMessageBanner() {
    //return Image.asset(banner, fit: BoxFit.cover);
    // return CachedNetworkImage(
    //         imageUrl: banner,
    //         placeholder: (context, url) => CircularProgressIndicator(),
    //         errorWidget: (context, url, error) => Icon(Icons.error),
    //         fit: BoxFit.cover,
    //       );
    return Image.network(banner??"", fit: BoxFit.cover);
  }
}
