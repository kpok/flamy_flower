import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flamy_flower/platform.dart';

class Player extends SpriteAnimationComponent with HasGameRef {
  bool moveLeft = false;
  bool moveRight = false;
  final Vector2 velocity = Vector2.zero();

  Player({required Vector2 position})
      : super(position: position, size: Vector2(50, 50));

  void jump() {
    if (velocity.y == 0) {
      velocity.y = -400; // mocniejszy skok
    }
  }

  @override
  Future<void> onLoad() async {
    final image = await gameRef.images.load('player5.png');

    final spriteSheet = SpriteSheet(
      image: image,
      srcSize: Vector2(341, 341),
    );

    animation = spriteSheet.createAnimation(
      row: 0,
      stepTime: 0.12,
      to: 3,
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Sterowanie poziome
    if (moveLeft) {
      velocity.x = -150;
    } else if (moveRight) {
      velocity.x = 150;
    } else {
      velocity.x = 0;
    }

    // Grawitacja
    velocity.y += 500 * dt;

    // 🔹 Krokowy ruch PIONOWY
    final nextY = position.y + velocity.y * dt;
    const steps = 10;
    final deltaY = (nextY - position.y) / steps.toDouble();

    for (int i = 0; i < steps; i++) {
      position.y += deltaY;

      for (final platform in gameRef.children.whereType<PlatformComponent>()) {
        final horizontallyAligned = toRect().overlaps(platform.toRect());
        final standingOnPlatform = velocity.y > 0 &&
            (position.y + size.y) <= (platform.y + 10) &&
            horizontallyAligned;

        if (standingOnPlatform) {
          position.y = platform.y - size.y;
          velocity.y = 0;
          break;
        }
      }
    }

    // 🔹 Ruch poziomy – normalny, bez krokowania
    position.x += velocity.x * dt;
  }
}
