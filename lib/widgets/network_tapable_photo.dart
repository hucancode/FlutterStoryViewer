import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkTapablePhoto extends StatelessWidget {
  NetworkTapablePhoto({ Key key, this.imageUrl, this.color, this.onTap }) : super(key: key);

  final String imageUrl;
  final Color color;
  final VoidCallback onTap;

  Widget build(BuildContext context) {
    return Material(
      // Slightly opaque color appears where the image has transparency.
      color: Theme.of(context).primaryColor.withOpacity(0.25),
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints size) {
            return CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }
}