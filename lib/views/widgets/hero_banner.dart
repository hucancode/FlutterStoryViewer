import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pop_experiment/views/widgets/radial_expansion.dart';

class BannerHero extends StatefulWidget
{
  final int id;
  final String imageUrl;
  BannerHero({Key? key, required this.id, required this.imageUrl})
      : super(key: key);
  @override
  BannerHeroState createState() => BannerHeroState();
}
class BannerHeroState extends State<BannerHero> with SingleTickerProviderStateMixin
{
  static RectTween customTween(Rect? begin, Rect? end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }
  static const USE_INTRO_ANIMATION = false;
  static const double kMinRadius = 120.0;
  static const double kMaxRadius = 500.0;

  late Animation<double> radialAnimation;
  late AnimationController controller;

  @override            
  void initState() {            
    super.initState();
      controller =
          AnimationController(duration: const Duration(milliseconds: 600), vsync: this);            
      radialAnimation = Tween<double>(begin: kMinRadius, end: kMaxRadius).animate(controller.drive(
        CurveTween(curve: Curves.easeIn),
      ))..addListener(() {            
        setState(() {        
        });
      });
    if(USE_INTRO_ANIMATION)
    {
      controller.forward();
    }
  }
  
  @override
  void dispose() {          
    controller.dispose();            
    super.dispose();            
  }
  
  @override
  Widget build(BuildContext context) {
    final maxRadius = min(radialAnimation.value, MediaQuery.of(context).size.width*1.05);
    return Hero(
      createRectTween: customTween,
      tag: widget.id,
      child: RadialExpansion(
          maxRadius: USE_INTRO_ANIMATION?maxRadius:kMaxRadius,
          child: buildBanner(),
        ),
    );
  }

  Widget buildBanner() {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fit: BoxFit.cover,
    );
    //return Image.network(widget.imageUrl, fit: BoxFit.cover);
    //return Image.asset(widget.imageUrl, fit: BoxFit.cover);
  }
}