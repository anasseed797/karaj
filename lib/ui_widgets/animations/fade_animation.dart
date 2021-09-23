import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  const FadeAnimation({Key key, this.delay, this.child}) : super(key: key);

/*

    final tween = MultiTrackTween([
      Track("opacity").add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
      Track("translateY").add(Duration(milliseconds: 500), Tween(begin: -30.0, end: 0.0), curve: Curves.easeOut)
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(
            offset: Offset(0, animation["translateY"]),
            child: child
        ),
      ),
    );
 */
  @override
  Widget build(BuildContext context) {
    final tween = MultiTween()
      ..add("opacity",Tween(begin: 0.0, end: 1.0), Duration(milliseconds: 500),)
      ..add("translateY", Tween(begin: 30.0, end: 0.0), Duration(milliseconds: 500));

    return PlayAnimation<MultiTweenValues>(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, child, value) => Opacity(
        opacity: value.get("opacity"),
        child: Transform.translate(
            offset: Offset(0, value.get("translateY")), child: child),
      ),
    );

  }
}