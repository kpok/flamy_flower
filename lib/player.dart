import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';
import 'package:flamy_flower/platform.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';

class Player extends SpriteAnimationComponent with HasGameRef {
  bool moveLeft = false;
  bool moveRight = false;
  final Vector2 velocity = Vector2.zero();
  final Paint _debugPaint = Paint()..color = Colors.yellow;  // Dodaj kolor debugowania
  bool _spriteLoaded = false;

  Player({required Vector2 position})
      : super(position: position, size: Vector2(50, 50));

  void jump() {
    if (velocity.y == 0) {
      velocity.y = -400;
    }
  }

  void handleInput(KeyEvent event, bool isKeyDown) {
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      moveRight = isKeyDown;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      moveLeft = isKeyDown;
    } else if (event.logicalKey == LogicalKeyboardKey.space && isKeyDown) {
      jump();
    }
  }

  @override
  Future<void> onLoad() async {
    try {
      print('Trying to load player sprite...');
      final image = await gameRef.images.load('player5.png');
      print('Player image loaded successfully');

      final spriteSheet = SpriteSheet(
        image: image,
        srcSize: Vector2(341, 341),
      );

      animation = spriteSheet.createAnimation(
        row: 0,
        stepTime: 0.12,
        to: 3,
      );
      
      _spriteLoaded = true;
      print('Player animation created successfully');
    } catch (e) {
      print('Error loading player sprite: $e');
      _spriteLoaded = false;
    }
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

    // Krokowy ruch pionowy
    final nextY = position.y + velocity.y * dt;
    const steps = 10;
    final deltaY = (nextY - position.y) / steps.toDouble();
    bool collided = false;

    // Sprawdzamy kolizje tylko gdy gracz spada (velocity.y > 0)
    if (velocity.y > 0) {
      for (int i = 0; i < steps; i++) {
        position.y += deltaY;

        for (final platform in parent?.children.whereType<PlatformComponent>() ?? []) {
          final horizontallyAligned = toRect().overlaps(platform.toRect());
          final standingOnPlatform = 
              (position.y + size.y) >= platform.y && // Stopy gracza są na lub poniżej górnej krawędzi platformy
              (position.y + size.y) <= platform.y + 10 && // Ale nie zagłębiają się zbyt głęboko w platformę
              horizontallyAligned;

          if (standingOnPlatform) {
            position.y = platform.y - size.y;
            velocity.y = 0;
            collided = true;
            break;
          }
        }

        if (collided) break;
      }
    } else {
      // Gdy gracz się wznosi, po prostu aktualizujemy pozycję
      position.y = nextY;
    }

    // Ruch poziomy
    position.x += velocity.x * dt;

    // 🔒 Kolizja ze ścianami
    for (final platform in parent?.children.whereType<PlatformComponent>() ?? []) {
      // Sprawdzamy kolizje tylko ze ścianami (platformy o pełnej wysokości)
      if (platform.size.y > 100) { // Zakładamy, że ściany są wyższe niż normalne platformy
        if (toRect().overlaps(platform.toRect())) {
          if (position.x < platform.x) {
            // Uderzenie z lewej
            position.x = platform.x - size.x;
          } else {
            // Z prawej
            position.x = platform.x + platform.size.x;
          }
          velocity.x = 0;
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_spriteLoaded) {
      super.render(canvas);
    } else {
      // Fallback do żółtego prostokąta jeśli sprite się nie załadował
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        _debugPaint,
      );
    }
  }
}
