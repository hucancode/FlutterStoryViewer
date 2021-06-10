import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:pop_experiment/models/entry.dart';
import 'package:pop_experiment/services/entry_service.dart';
import 'package:pop_experiment/services/local_entry_service.dart';
import 'package:pop_experiment/models/profile.dart';
import 'package:pop_experiment/services/filter_service.dart';
import 'package:pop_experiment/services/geofence_history.dart';
import 'package:pop_experiment/views/widgets/radial_expansion.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class EntryListView extends StatefulWidget {

  List<Entry> entries;
  
  EntryListView({Key? key, required this.entries}) : super(key: key);
  EntryListViewState createState()
  {
    return EntryListViewState();
  }
}

class EntryListViewState extends State<EntryListView> {
  final GlobalKey<AnimatedListState> listRef = GlobalKey();

  @override
  void initState()
  {
    super.initState();
    final provider = Provider.of<LocalEntryService>(context, listen: false);
    provider.eventController.stream.listen((event) {
      print('EntryListViewState got event ${event.type}');
      switch (event.type) {
        case EntryEventType.insert:
          listRef.currentState?.insertItem(event.index, duration: Duration(milliseconds: 300));
          break;
        case EntryEventType.delete:
          listRef.currentState?.removeItem(
            event.index,
            (context, animation) {
              return FadeTransition(
                opacity:
                    CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0)),
                child: SizeTransition(
                  sizeFactor:
                      CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
                  axisAlignment: 0.0,
                  child: buildItem(provider.entries[event.index], context),
                ),
              );
            },
            duration: Duration(milliseconds: 600),
          );
          break;
        default:
      }
    });
  }

  Widget buildItem(Entry message, BuildContext context) {
    final provider = Provider.of<LocalEntryService>(context, listen: false);
    print('buildItem for message ${message.id}');
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: buildItemContent(message, context),
        actions: [
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => provider.delete(message.id),
          ),
          IconSlideAction(
            caption: 'Favorite',
            color: Colors.amber,
            icon: Icons.favorite,
            onTap: () => provider.addToFavorite(message.id),
          ),
        ],
        secondaryActions: [
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => provider.delete(message.id),
          ),
          IconSlideAction(
            caption: 'Favorite',
            color: Colors.amber,
            icon: Icons.favorite,
            onTap: () => provider.addToFavorite(message.id),
          ),
        ],
      );
  }

  Widget buildItemContent(Entry message, BuildContext context) {
    print('buildItemContent for message ${message.id}');
    final formatter = DateFormat('yyyy-MM-dd');
    final provider = Provider.of<LocalEntryService>(context, listen: false);
    return ListTile(
        key: ValueKey<Entry>(message),
        selected: message.isSelected,
        title: Text(message.title??"Untitled"),
        subtitle: Text(message.modifiedDate != null?formatter.format(message.modifiedDate!):""),
        selectedTileColor: Colors.amber,
        leading: CircleAvatar(
          child: buildHeroWidget(context, message.id, message.thumbnail??"no_icon"),
        ),
        trailing: Visibility(
          child: Icon(Icons.favorite),
          visible: message.isFavorite,
        ),
        onTap: () {
          if(provider.totalSelected > 0)
          {
            provider.toggleSelect(message.id);
          }
          else
          {
            Navigator.pushNamed(context, '/detail', arguments: message);
          }
        },
        onLongPress: () {
          provider.toggleSelect(message.id);
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    print('build message_list ${widget.entries.length}');
    return Expanded(
      child: AnimatedList(
        key: listRef,
        initialItemCount: widget.entries.length,
        itemBuilder: (context, index, animation) {
          if(index >= widget.entries.length)
          {
            return SizedBox(height: 1);
          }
          return FadeTransition(
            opacity: animation,
            child: buildItem(widget.entries[index], context),
          );
        }
      ),
    );
  }

  static const double kMinRadius = 32.0;
  static const double kMaxRadius = 120.0;
  static const opacityCurve =
      const Interval(0.0, 0.75, curve: Curves.fastOutSlowIn);

  static RectTween customTween(Rect? begin, Rect? end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }
  static Tween<Offset> introTween(Offset? begin, Offset? end) {
    return MaterialPointArcTween(begin: begin, end: end);
  }


  Widget buildHeroWidget(BuildContext context, int id, String iconPath) {
    return Container(
      width: kMinRadius * 2.0,
      height: kMinRadius * 2.0,
      child: Hero(
        createRectTween: customTween,
        tag: id,
        child: RadialExpansion(
          maxRadius: kMinRadius,
          child: buildIcon(iconPath),
        ),
      ),
    );
  }

  Widget buildIcon(String iconPath) {
    return CachedNetworkImage(
      imageUrl: iconPath,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fit: BoxFit.cover,
    );
    //return Image.network(iconPath, fit: BoxFit.cover);
    //return Image.asset(iconPath, fit: BoxFit.cover);
  }
}
