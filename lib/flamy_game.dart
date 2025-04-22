import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flamy_flower/player.dart';
import 'package:flamy_flower/platform.dart';
import 'package:flamy_flower/background.dart';
import 'package:flamy_flower/joystick.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class FlamyGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks, DragCallbacks {
  late Player player;
  final Random _random = Random();
  final double platformSpacing = 100;
  double highestPlatformY = 0;
  double maxCameraY = double.infinity;

  final double worldWidth = 480.0;
  final double worldHeight = 800.0;
  final double wallThickness = 10.0;
  final double initalPlatformY = 1100.0;

  late final World world;
  Vector2? dragStartPosition;
  static const double swipeThreshold = 50;

  bool isMobile = false;

  @override
  Future<void> onLoad() async {
    // Sprawdź czy jesteśmy na urządzeniu mobilnym i czy to nie jest wersja webowa
    isMobile = !kIsWeb && (Platform.isIOS || Platform.isAndroid);

    // Ustawienie viewportu
    camera.viewport = FixedResolutionViewport(resolution: Vector2(worldWidth, worldHeight));
    await super.onLoad();

    world = World();
    add(world);
    camera.world = world;

    // Dodaj tło
    final background = Background();
    world.add(background);

    // Platforma startowa na samym dole ekranu
    final startingPlatform = PlatformComponent(
      position: Vector2(0, initalPlatformY), // Pozycja na dole ekranu
      size: Vector2(worldWidth, 20),
      color: Colors.green,
    );
    world.add(startingPlatform);

    // 🧱 Ściany po bokach
    final wallHeight = 10000.0;
    final wallTopY = -wallHeight / 2;

    final leftWall = PlatformComponent(
      position: Vector2(0, wallTopY),
      size: Vector2(wallThickness, wallHeight),
      color: Colors.blue,
    );

    final rightWall = PlatformComponent(
      position: Vector2(worldWidth - wallThickness, wallTopY),
      size: Vector2(wallThickness, wallHeight),
      color: Colors.red,
    );

    world.add(leftWall);
    world.add(rightWall);

    // Generuj platformy do góry, zaczynając od pozycji tuż nad platformą startową
    highestPlatformY = initalPlatformY - platformSpacing; // Zaczynamy generowanie platform od tej wysokości

    final initialPlatformCount = 100;
    
    for (int i = 0; i < initialPlatformCount; i++) {
      final platform = PlatformComponent(
        position: Vector2(
          _random.nextDouble() * (worldWidth - 100),
          highestPlatformY,
        ),
        size: Vector2(300, 20),
        color: Colors.green,
      );
      world.add(platform);
      highestPlatformY -= platformSpacing;
    }

    // Dodaj gracza tuż nad platformą startową
    player = Player(
      position: Vector2(worldWidth / 2, initalPlatformY - 50), // 50 pikseli nad platformą startową
    );
    world.add(player);

    // Ustaw początkową pozycję kamery na dole
    maxCameraY = size.y;
    camera.viewfinder.position = Vector2(worldWidth / 2, maxCameraY);

    // Dodaj kontrolki tylko na urządzeniach mobilnych
    if (isMobile) {
      // add(MobileControls(
      //   onMoveLeft: (pressed) => player.moveLeft = pressed,
      //   onMoveRight: (pressed) => player.moveRight = pressed,
      //   onJump: () => player.jump(),
      // ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Generuj nowe platformy
    while (player.y < highestPlatformY + size.y * 2) {
      highestPlatformY -= platformSpacing;
      final platform = PlatformComponent(
        position: Vector2(
          _random.nextDouble() * (worldWidth - 100),
          highestPlatformY,
        ),
        size: Vector2(100, 20),
        color: Colors.green,
      );
      world.add(platform);
    }

    // Usuń platformy poza ekranem
    world.children.whereType<PlatformComponent>().forEach((platform) {
      if (platform.y > player.y + size.y + 400) {
        platform.removeFromParent();
      }
    });

    // Aktualizacja kamery - śledzi gracza tylko gdy idzie w górę
    if (player.y < maxCameraY) {
      maxCameraY = player.y;
      camera.viewfinder.position = Vector2(worldWidth / 2, maxCameraY);
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent;
    player.handleInput(event, isKeyDown);
    return KeyEventResult.handled;
  }

  @override
  void onDragStart(DragStartEvent event) {
    dragStartPosition = event.canvasPosition;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (dragStartPosition != null) {
      final dragDelta = event.canvasStartPosition - dragStartPosition!;
      
      // Poziomy ruch
      if (dragDelta.x.abs() > swipeThreshold) {
        player.moveLeft = dragDelta.x < 0;
        player.moveRight = dragDelta.x > 0;
      }
      
      // Skok przy przesunięciu w górę
      if (dragDelta.y < -swipeThreshold && player.velocity.y == 0) {
        player.jump();
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    dragStartPosition = null;
    player.moveLeft = false;
    player.moveRight = false;
  }
}
