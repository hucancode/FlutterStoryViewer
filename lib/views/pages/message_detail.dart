// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pop_template/views/widgets/radial_expansion.dart';

class MessageDetail extends StatelessWidget {
  static const FETCH_CONTENT_AGAIN = false;
  static const NO_CONTENT = "Seems no content 😀";
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
      body: Container(
        color: Theme.of(context).canvasColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: double.infinity,//kMaxRadius * 2.0,
              height: 120,//kMaxRadius * 2.0,
              child: buildHeroWidget(context),
            ),
            Expanded(
              child: buildMDViewer(context),
            ),
          ],
        ),
      ),
    );
  }

  Hero buildHeroWidget(BuildContext context) {
    return Hero(
      createRectTween: customTween,
      tag: id,
      child: ClipRect(
        child: Transform.scale(
          scale: 2.1,
          child: RadialExpansion(
            maxRadius: kMaxRadius,
            child: buildMessageBanner(),
          ),
        ),
      ),
    );
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

  Future<String> readMD(BuildContext context) async {
    if(!FETCH_CONTENT_AGAIN)
    {
      return content??NO_CONTENT;
    }
    const serverEndpoint = 'pop-ex.atpop.info:3100';
    final selectAPI = '/entry/read/$id';
    try {
      var uri = Uri.https(serverEndpoint, selectAPI);
      var response = await http.get(uri).timeout(Duration(seconds: 10), onTimeout: (){
        print('request timed out {$uri.toString()}');
        return null;
      });
      if (response.statusCode == 200)
      {
        var responseJson = json.decode(response.body);
        return responseJson["content"];
      }
      print('response.statusCode = ${response.statusCode}: ${response.body}');
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    return "";
  }

  Widget buildMDViewer(BuildContext context) {
    return FutureBuilder(
      future: readMD(context),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator()
          );
        }
        return Padding(
          padding: EdgeInsets.all(5.0),
          child: Markdown(
            selectable: true,
            data: snapshot.data??NO_CONTENT,
          ),
        );
      },
    );
  }
}
