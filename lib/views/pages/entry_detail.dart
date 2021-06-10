import 'dart:async';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pop_experiment/models/entry.dart';
import 'package:pop_experiment/services/entry_service.dart';
import 'package:pop_experiment/views/widgets/hero_banner.dart';
import 'package:provider/provider.dart';

class EntryDetail extends StatefulWidget {
  final Entry model;
  EntryDetail({Key? key, required this.model})
      : super(key: key);
  @override
  EntryDetailState createState() => EntryDetailState();
}

class EntryDetailState extends State<EntryDetail>  {
  static const FETCH_CONTENT_AGAIN = true;
  static const NO_CONTENT = "Seems no content 😀";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.model.title??"Untitled"),
      ),
      body: Container(
        color: Theme.of(context).canvasColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRect(
              child: SizedBox(
                width: double.infinity,//kMaxRadius * 2.0,
                height: 120,//kMaxRadius * 2.0,
                child: buildHeroWidget(context),
              ),
            ),
            Expanded(
              child: buildMDViewer(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeroWidget(BuildContext context) {
    return BannerHero(id: widget.model.id, imageUrl: widget.model.thumbnail??"");
  }

  Future<String> readMD(BuildContext context) async {
    if(!FETCH_CONTENT_AGAIN)
    {
      return widget.model.content??NO_CONTENT;
    }
    if(widget.model.content != null)
    {
      return widget.model.content!;
    }
    final provider = Provider.of<EntryService>(context, listen: false);
    widget.model.content = await provider.fetchContent(widget.model.id);
    return widget.model.content!;
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
