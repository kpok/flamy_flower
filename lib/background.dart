import 'package:flame/components.dart';
import 'package:flame/game.dart';

class Background extends SpriteComponent with HasGameRef<FlameGame> {
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('stormy_sky.jpg');
    size = gameRef.size;
    position = Vector2.zero();
  }
}
