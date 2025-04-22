import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/input.dart';
import 'package:flame/experimental.dart';

class MobileControls extends PositionComponent with HasGameRef {
  final Function(bool) onMoveLeft;
  final Function(bool) onMoveRight;
  final Function() onJump;

  late final ButtonComponent leftButton;
  late final ButtonComponent rightButton;
  late final ButtonComponent jumpButton;

  MobileControls({
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onJump,
  }) : super(priority: 10); // Wysoki priorytet, aby być nad grą

  @override
  Future<void> onLoad() async {
    // Przyciski kierunkowe (lewa strona ekranu)
    leftButton = ButtonComponent(
      button: CircleComponent(
        radius: 40,
        paint: Paint()..color = Colors.blue.withOpacity(0.5),
      ),
      position: Vector2(50, gameRef.size.y - 150),
      onPressed: () => onMoveLeft(true),
      onReleased: () => onMoveLeft(false),
      children: [
        TextComponent(
          text: '←',
          position: Vector2(20, 15),
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
      ],
    );

    rightButton = ButtonComponent(
      button: CircleComponent(
        radius: 40,
        paint: Paint()..color = Colors.blue.withOpacity(0.5),
      ),
      position: Vector2(120, gameRef.size.y - 150),
      onPressed: () => onMoveRight(true),
      onReleased: () => onMoveRight(false),
      children: [
        TextComponent(
          text: '→',
          position: Vector2(20, 15),
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
      ],
    );

    // Przycisk skoku (prawa strona ekranu)
    jumpButton = ButtonComponent(
      button: CircleComponent(
        radius: 40,
        paint: Paint()..color = Colors.red.withOpacity(0.5),
      ),
      position: Vector2(gameRef.size.x - 100, gameRef.size.y - 150),
      onPressed: onJump,
      children: [
        TextComponent(
          text: '↑',
          position: Vector2(30, 25),
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
      ],
    );

    addAll([leftButton, rightButton, jumpButton]);
  }
}
