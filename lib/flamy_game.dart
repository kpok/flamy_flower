import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flamy_flower/player.dart';
import 'package:flamy_flower/platform.dart';
import 'package:flamy_flower/background.dart';

class FlamyGame extends FlameGame with HasKeyboardHandlerComponents {
  late Player player;
  final Random _random = Random();
  final double platformSpacing = 100;
  double highestPlatformY = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(Background());

    player = Player(position: Vector2(100, 500));
    add(player);

    // Dolna platforma na całą szerokość ekranu
    final startingPlatform = PlatformComponent(
      position: Vector2(0, size.y - 20),
      size: Vector2(size.x, 20),
    );
    add(startingPlatform);

    // Inne platformy w pionie do góry
    highestPlatformY = size.y - 40;
    while (highestPlatformY > -size.y) {
      final platform = PlatformComponent(
        position: Vector2(
          _random.nextDouble() * (size.x - 100),
          highestPlatformY,
        ),
        size: Vector2(100, 20),
      );
      add(platform);
      highestPlatformY -= platformSpacing;
    }

    camera.viewport = FixedResolutionViewport(resolution: Vector2(480, 800));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Dodawanie nowych platform, gdy Janusz idzie wyżej
    while (player.y < highestPlatformY - platformSpacing) {
      highestPlatformY -= platformSpacing;

      final newPlatform = PlatformComponent(
        position: Vector2(
          _random.nextDouble() * (size.x - 100),
          highestPlatformY,
        ),
        size: Vector2(100, 20),
      );
      add(newPlatform);
    }

    // Usuwanie platform daleko poza ekranem
    children.whereType<PlatformComponent>().forEach((platform) {
      if (platform.y > player.y + size.y + 400) {
        platform.removeFromParent();
      }
    });

    // 📌 Ręczne śledzenie gracza – Janusz zawsze na środku
    camera.viewfinder.position = Vector2(
      player.x - size.x / 2 + player.size.x / 2,
      player.y - size.y / 2 + player.size.y / 2,
    );

  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent;

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      player.moveRight = isKeyDown;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      player.moveLeft = isKeyDown;
    } else if (event.logicalKey == LogicalKeyboardKey.space && isKeyDown) {
      player.jump();
    }

    return KeyEventResult.handled;
  }
}
