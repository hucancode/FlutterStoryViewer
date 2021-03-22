// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_html/enough_mail_html.dart';

class MimeMessageDetail extends StatefulWidget {
  final MimeMessage message;
  MimeMessageDetail(this.message);

  @override
  MimeMessageDetailState createState() {
    return MimeMessageDetailState();
  }
}
class MimeMessageDetailState extends State<MimeMessageDetail> with TickerProviderStateMixin
{
  int progress = 0;
  final Completer<WebViewController> controller = Completer<WebViewController>();
  final GlobalKey<State<WebView>> webViewRef = GlobalKey();

  @override
  Widget build(BuildContext context) {
    String title = widget.message.decodeSubject()??"Untitled";
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: buildMessageViewer(),
    );
  }

  void updateProgress(int value)
  {
    setState((){
      print("update loading progress $value%");
      this.progress = value;
    });
  }

  Widget buildMessageViewer()
  {
    // TODO: move this to future builder
    String content = widget.message.transformToHtml(blockExternalImages: false, emptyMessageText: 'Nothing here, move on!');
    final String contentBase64 = base64Encode(const Utf8Encoder().convert(content));
    String url = 'data:text/html;base64,$contentBase64';
    
    return Stack(
      children: [
        WebView(
          key: webViewRef,
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            controller.complete(webViewController);
          },
          onProgress: (int value) {
            updateProgress(value);
          },
          navigationDelegate: onWebNavigation,
          onPageStarted: (String url) {
            //print('Page started loading: $url');
            updateProgress(0);
          },
          onPageFinished: (String url) {
            //print('Page finished loading: $url');
            updateProgress(100);
          },
          gestureNavigationEnabled: true,
        ),
        Visibility(
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              // value: progress/100,
            ),
          ),
          visible: progress < 100
        ),
      ],
    );
  }

  FutureOr<NavigationDecision> onWebNavigation(NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            print('blocking navigation to $request}');
            return NavigationDecision.prevent;
          }
          //print('allowing navigation to $request');
          return NavigationDecision.navigate;
        }
}
