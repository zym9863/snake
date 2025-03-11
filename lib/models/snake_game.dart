import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
// 导入音频播放器
import 'package:audioplayers/audioplayers.dart';

// 定义蛇的移动方向
enum Direction { up, down, left, right }

// 定义游戏状态
enum GameState { playing, paused, gameOver }

// 定义蛇的身体部分
class SnakePart {
  final int x;
  final int y;

  SnakePart(this.x, this.y);
}

// 定义食物
class Food {
  int x;
  int y;

  Food(this.x, this.y);
}

// 贪吃蛇游戏模型
class SnakeGame extends ChangeNotifier {
  // 游戏区域大小
  final int gridSize;
  
  // 蛇的身体部分列表
  List<SnakePart> snake = [];
  
  // 当前移动方向
  Direction direction = Direction.right;
  
  // 食物
  late Food food;
  
  // 游戏状态
  GameState gameState = GameState.paused;
  
  // 游戏计时器
  Timer? _timer;
  
  // 游戏速度（毫秒）
  int speed = 300;

  // 分数
  int score = 0;

  // 音频播放器
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 构造函数
  SnakeGame({this.gridSize = 20}) {
    // 初始化蛇的位置（从中间开始）
    int middle = gridSize ~/ 2;
    snake.add(SnakePart(middle, middle)); // 蛇头
    snake.add(SnakePart(middle - 1, middle)); // 蛇身
    snake.add(SnakePart(middle - 2, middle)); // 蛇尾

    // 生成第一个食物
    _generateFood();
  }

  // 预加载音效
  Future<void> _loadSoundEffect() async {
    await _audioPlayer.setSourceAsset('sound-effect-1741655983938.mp3');
  }
  
  // 开始游戏
  // 初始化
  Future<void> initializeGame() async {
    await _loadSoundEffect();
    startGame();
  }

  void startGame() {
    if (gameState == GameState.gameOver) {
      // 如果游戏结束，重置游戏
      resetGame();
    }

    gameState = GameState.playing;
    _timer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      _moveSnake();
    });
    notifyListeners();
  }
  
  // 暂停游戏
  void pauseGame() {
    if (gameState == GameState.playing) {
      gameState = GameState.paused;
      _timer?.cancel();
      notifyListeners();
    }
  }
  
  // 重置游戏
  void resetGame() {
    // 停止计时器
    _timer?.cancel();
    
    // 重置蛇的位置
    snake.clear();
    int middle = gridSize ~/ 2;
    snake.add(SnakePart(middle, middle));
    snake.add(SnakePart(middle - 1, middle));
    snake.add(SnakePart(middle - 2, middle));
    
    // 重置方向
    direction = Direction.right;
    
    // 重置分数
    score = 0;
    
    // 重置游戏状态
    gameState = GameState.paused;
    
    // 生成新食物
    _generateFood();
    
    notifyListeners();
  }
  
  // 改变蛇的移动方向
  void changeDirection(Direction newDirection) {
    // 防止180度转弯（蛇不能直接掉头）
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    
    direction = newDirection;
  }
  
  // 移动蛇
  void _moveSnake() {
    if (gameState != GameState.playing) return;
    
    // 获取蛇头位置
    int headX = snake.first.x;
    int headY = snake.first.y;
    
    // 根据方向计算新的蛇头位置
    switch (direction) {
      case Direction.up:
        headY -= 1;
        break;
      case Direction.down:
        headY += 1;
        break;
      case Direction.left:
        headX -= 1;
        break;
      case Direction.right:
        headX += 1;
        break;
    }
    
    // 检查是否撞墙
    if (headX < 0 || headX >= gridSize || headY < 0 || headY >= gridSize) {
      _gameOver();
      return;
    }
    
    // 检查是否撞到自己
    for (var part in snake) {
      if (part.x == headX && part.y == headY) {
        _gameOver();
        return;
      }
    }
    
    // 添加新的蛇头
    snake.insert(0, SnakePart(headX, headY));
    
    // 检查是否吃到食物
    if (headX == food.x && headY == food.y) {
      // 吃到食物，增加分数
      score += 10;

      // 播放音效
      _playSoundEffect();
      
      // 生成新的食物
      _generateFood();
      
      // 加速（可选）
      if (speed > 100 && score % 50 == 0) {
        speed -= 10;
        _timer?.cancel();
        _timer = Timer.periodic(Duration(milliseconds: speed), (timer) {
          _moveSnake();
        });
      }
    } else {
      // 没吃到食物，移除蛇尾
      snake.removeLast();
    }
    
    notifyListeners();
  }

  // 播放音效
  Future<void> _playSoundEffect() async {
    await _audioPlayer.play(AssetSource('sound-effect-1741655983938.mp3'));
  }
  
  // 生成食物
  void _generateFood() {
    Random random = Random();
    int x, y;
    bool onSnake;
    
    // 确保食物不会生成在蛇身上
    do {
      x = random.nextInt(gridSize);
      y = random.nextInt(gridSize);
      
      onSnake = false;
      for (var part in snake) {
        if (part.x == x && part.y == y) {
          onSnake = true;
          break;
        }
      }
    } while (onSnake);
    
    food = Food(x, y);
  }
  
  // 游戏结束
  void _gameOver() {
    gameState = GameState.gameOver;
    _timer?.cancel();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
