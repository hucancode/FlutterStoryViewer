import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:pop_experiment/models/entry.dart';
import 'package:pop_experiment/models/entry_list.dart';
import 'package:pop_experiment/models/profile.dart';
import 'package:pop_experiment/services/filter_service.dart';
import 'package:pop_experiment/services/geofence_history.dart';
import 'package:pop_experiment/services/profile_manager.dart';
import 'package:pop_experiment/views/widgets/radial_expansion.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class EntryListView extends StatefulWidget {
  
  EntryListView({Key? key}) : super(key: key);
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
    final provider = Provider.of<EntryList>(context, listen: false);
    provider.eventController.stream.listen((event) {
      print('EntryListViewState got event ${event.type}');
      switch (event.type) {
        case EntryListEventType.insert:
          listRef.currentState?.insertItem(event.index, duration: Duration(milliseconds: 300));
          break;
        case EntryListEventType.delete:
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
    final provider = Provider.of<EntryList>(context, listen: false);
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
    final provider = Provider.of<EntryList>(context, listen: false);
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
    final entries = Provider.of<EntryList>(context).entries;
    final profile = Provider.of<Profile>(context, listen: false);
    final geofenceHistory = Provider.of<GeofenceHistory>(context);
    final filteredEntries = entries.where((e) {
      if(e.filterID is int)
      {
        final filter = FilterService().readById(e.filterID!);
        final error = ProfileManager().applyFilter(filter, profile);
        if(error != 0)
        {
          print('entry filtered out, filter result = $error');
          return false;
        }
      }
      if(e.geofences.isNotEmpty)
      {
        // if(!e.geofences.any((fence) => geofenceHistory.history.contains(fence)))
        // {
        //   return false;
        // }
      }
      if(e.beacons.isNotEmpty)
      {
        // do beacon test
      }
      return true;
    }).toList();
    print('build message_list ${entries.length}');
    return Expanded(
        child: AnimatedList(
            key: listRef,
            initialItemCount: entries.length,
            itemBuilder: (context, index, animation) {
              return FadeTransition(
                opacity: animation,
                child: buildItem(entries[index], context),
              );
            }));
  }

  static const double kMinRadius = 32.0;
  static const double kMaxRadius = 128.0;
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
          maxRadius: kMaxRadius,
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
