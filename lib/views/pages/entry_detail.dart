import 'dart:async';
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pop_experiment/models/entry.dart';
import 'package:pop_experiment/services/entry_service.dart';
import 'package:pop_experiment/services/server_config.dart';
import 'package:pop_experiment/views/widgets/radial_expansion.dart';
import 'package:provider/provider.dart';

class EntryDetail extends StatelessWidget {
  static const FETCH_CONTENT_AGAIN = false;
  static const NO_CONTENT = "Seems no content 😀";

  static const double kMinRadius = 32.0;
  static const double kMaxRadius = 128.0;
  static RectTween customTween(Rect? begin, Rect? end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }

  final Entry model;

  EntryDetail({Key? key, required this.model})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(model.title??"Untitled"),
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
      tag: model.id,
      child: ClipRect(
        child: Transform.scale(
          scale: 2.1,
          child: RadialExpansion(
            maxRadius: kMaxRadius,
            child: buildBanner(),
          ),
        ),
      ),
    );
  }

  Widget buildBanner() {
    return CachedNetworkImage(
            imageUrl: model.thumbnail??"",
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
          );
    //return Image.network(banner??"", fit: BoxFit.cover);
    //return Image.asset(banner??"", fit: BoxFit.cover);
  }

  Future<String> readMD(BuildContext context) async {
    if(!FETCH_CONTENT_AGAIN)
    {
      return model.content??NO_CONTENT;
    }
    final provider = Provider.of<EntryService>(context);
    return await provider.fetchContent(model.id);
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
