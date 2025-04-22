import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PlatformComponent extends RectangleComponent {
  PlatformComponent({
    required Vector2 position,
    required Vector2 size,
    Color? color,
  }) : super(
    position: position,
    size: size,
    paint: Paint()..color = color ?? const Color(0xFF000000),
  );
}