import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'flamy_game.dart';

void main() {
  runApp(
    GameWidget(
      game: FlamyGame(),
      backgroundBuilder: (_) => Container(color: Colors.transparent),
    ),
  );
}
