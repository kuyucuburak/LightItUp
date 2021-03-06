import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:light_it_up/game/puzzle_game.dart';
import 'package:light_it_up/util/alias.dart';
import 'package:light_it_up/util/app_constants.dart';

class BaseSpriteComponent extends SpriteComponent with HasGameRef<PuzzleGame>, HasHitboxes {
  @override
  bool debugMode = AppConstants.debugModeStaticSprites;
  @override
  Color debugColor = Colors.redAccent;

  final SpriteLoader spriteLoader;

  BaseSpriteComponent({
    required Vector2 position,
    required Vector2 size,
    required int priority,
    required this.spriteLoader,
  }) : super(
          position: position,
          size: size,
          priority: priority,
          anchor: AppConstants.anchor,
        ) {
    addHitbox(HitboxRectangle());
  }

  @mustCallSuper
  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await spriteLoader(gameRef);
  }
}
