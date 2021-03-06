import 'package:dart_extensions/dart_extensions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:light_it_up/component/sprite/wire.dart';
import 'package:light_it_up/game/puzzle_game.dart';
import 'package:light_it_up/util/app_constants.dart';

mixin BaseDraggable on HasGameRef<PuzzleGame>, HasHitboxes, PositionComponent, Draggable {
  // When it is lower, dragging will be started sooner, it will be more sensitive.
  static const int _dragStartThreshold = 50;

  @override
  bool debugMode = AppConstants.debugMode;

  Vector2? _dragDeltaPosition;
  bool? _isDragHorizontal;

  MoveEffect? _moveEffect;
  Vector2? _positionAfterEffect;

  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    _dragDeltaPosition = info.eventPosition.game - position;
    _isDragHorizontal = null;
    return true;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    final Vector2 dragDeltaPosition = _dragDeltaPosition ?? Vector2(0, 0);
    Vector2 eventPositionWithDelta = info.eventPosition.game;
    double evenPointX = eventPositionWithDelta.x - dragDeltaPosition.x;
    double evenPointY = eventPositionWithDelta.y - dragDeltaPosition.y;

    if (_isDragHorizontal == null) {
      double moveXCount = (evenPointX - position.x).abs();
      double moveYCount = (evenPointY - position.y).abs();

      if (moveXCount >= _dragStartThreshold || moveYCount >= _dragStartThreshold) {
        _isDragHorizontal = moveXCount > moveYCount;
      }

      return true;
    } else {
      if (_moveEffect == null) {
        if (_isDragHorizontal == true) {
          if (evenPointX > position.x) {
            double newX = position.x + AppConstants.wireSize;
            if (_canMoveToPosition(newX, position.y)) {
              moveTo(newX, position.y);
            }
          } else {
            double newX = position.x - AppConstants.wireSize;
            if (_canMoveToPosition(newX, position.y)) {
              moveTo(newX, position.y);
            }
          }
        } else if (_isDragHorizontal == false) {
          if (evenPointY > position.y) {
            double newY = position.y + AppConstants.wireSize;
            if (_canMoveToPosition(position.x, newY)) {
              moveTo(position.x, newY);
            }
          } else {
            double newY = position.y - AppConstants.wireSize;
            if (_canMoveToPosition(position.x, newY)) {
              moveTo(position.x, newY);
            }
          }
        }
      }

      handleDragCanceled(pointerId);
      return false;
    }
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    _dragDeltaPosition = null;
    _isDragHorizontal = null;
    return false;
  }

  @override
  bool onDragCancel(int pointerId) {
    _dragDeltaPosition = null;
    _isDragHorizontal = null;
    return false;
  }

  void moveTo(double x, double y) {
    _positionAfterEffect = Vector2(x, y);
    _moveEffect = MoveEffect.to(_positionAfterEffect!, LinearEffectController(AppConstants.wireMoveEffectDurationSec));
    add(_moveEffect!);
    gameRef.gameController.removeAllElectricityAnimations();

    Future.delayed(
      Duration(milliseconds: (AppConstants.wireMoveEffectDurationSec * 1000 + 50).toInt()),
      () {
        // Although MoveEffects.to() takes us very close to the point we want, it does not equalize exactly.
        // This causes some mapping problems. So we should finalize it manually.
        position = _positionAfterEffect!;
        _moveEffect = null;
        _positionAfterEffect = null;
        gameRef.gameController.updateGameMap();
      },
    );
  }

  bool _canMoveToPosition(double x, double y) {
    // Only wires can be in the safe area, so we filter only Wire objects from the children
    bool hasChildren = gameRef.children.filter((e) => e is Wire).any((e) => e.containsPoint(Vector2(x, y)));
    bool isInSafeArea = x >= gameRef.gameController.minWireX && x <= gameRef.gameController.maxWireX && y >= gameRef.gameController.minWireY && y <= gameRef.gameController.maxWireY;
    return !hasChildren && isInSafeArea;
  }
}
