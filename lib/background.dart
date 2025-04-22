import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flamy_flower/flamy_game.dart';

class Background extends ParallaxComponent<FlamyGame> with HasGameRef<FlamyGame> {
  @override
  Future<void> onLoad() async {
    try {
      print('Loading background image...');
      
      final layers = [
        ParallaxImageData('stormy_sky.jpg'),
        ParallaxImageData('stormy_sky.jpg'),
        ParallaxImageData('stormy_sky.jpg'),
      ];

      parallax = await game.loadParallax(
        layers,
        baseVelocity: Vector2(0, 0),
        repeat: ImageRepeat.repeatY,
        fill: LayerFill.width,
        alignment: Alignment.bottomCenter,
      );

      position = Vector2(0, game.size.y);
      
      priority = -1;
      
      print('Background loaded successfully');
    } catch (e) {
      print('Error loading background: $e');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    position.y = game.camera.viewfinder.position.y - game.size.y/2;
  }
}
