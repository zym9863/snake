import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/snake_game.dart';
import '../theme/theme.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // 游戏模型
  late SnakeGame _game;
  
  // 焦点节点，用于捕获键盘事件
  final FocusNode _focusNode = FocusNode();
  
  // 食物动画控制器
  late AnimationController _foodAnimationController;
  late Animation<double> _foodAnimation;
  
  // 分数动画控制器
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;
  
  // 上一次的分数，用于检测分数变化
  int _lastScore = 0;

  @override
  @override
  void initState() {
    super.initState();
    // 初始化游戏
    _game = SnakeGame();
    _game.addListener(_onGameChange);
    
    // 初始化食物动画
    _foodAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _foodAnimation = GameAnimations.createFoodPulseAnimation(_foodAnimationController);
    _foodAnimationController.repeat(reverse: true);
    
    // 初始化分数动画
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scoreAnimation = GameAnimations.createScoreChangeAnimation(_scoreAnimationController);
    
    _game.initializeGame(); // 初始化游戏，包括加载音效和开始游戏
  }

  // 游戏状态变化回调
  void _onGameChange() {
    if (mounted) {
      // 检测分数变化，触发动画
      if (_game.score > _lastScore) {
        _scoreAnimationController.forward(from: 0.0);
        _lastScore = _game.score;
      }
      
      setState(() {});
    }
  }

  @override
  void dispose() {
    _game.removeListener(_onGameChange);
    _game.dispose();
    _focusNode.dispose();
    _foodAnimationController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  // 处理键盘输入
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _game.changeDirection(Direction.up);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _game.changeDirection(Direction.down);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _game.changeDirection(Direction.left);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _game.changeDirection(Direction.right);
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        // 空格键控制游戏暂停/开始
        if (_game.gameState == GameState.playing) {
          _game.pauseGame();
        } else {
          _game.startGame();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('贪吃蛇游戏', 
          style: TextStyle(
            fontSize: 26, 
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Color(0xFF00E5FF),
                blurRadius: 15,
                offset: Offset(0, 0),
              ),
              Shadow(
                color: Color(0xFF00E5FF),
                blurRadius: 30,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: GameTheme.backgroundColor,
        elevation: 0,
        actions: [
          // 显示分数
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scoreAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: GameTheme.scoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GameTheme.scoreColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '分数: ${_game.score}',
                        style: GameTheme.scoreTextStyle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      backgroundColor: GameTheme.backgroundColor,
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _handleKeyEvent,
        autofocus: true,
        child: Column(
          children: [
            // 游戏状态显示
            if (_game.gameState == GameState.gameOver)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GameTheme.gameOverColor.withOpacity(0.5),
                      GameTheme.gameOverColor.withOpacity(0.2),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      '游戏结束！',
                      textAlign: TextAlign.center,
                      style: GameTheme.gameOverTextStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '最终得分: ${_game.score}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GameTheme.scoreColor,
                        shadows: [
                          Shadow(
                            color: GameTheme.scoreGlowColor.withOpacity(0.8),
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            // 游戏区域
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: GameTheme.gridLineColor, 
                      width: 3.0,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: GameTheme.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: GameTheme.snakeHeadColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: GameTheme.foodColor.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: LayoutBuilder(
                    builder: (context, constraints) {
                      double cellSize = constraints.maxWidth / _game.gridSize;
                      return Stack(
                        children: [
                          // 背景图片
                          Positioned.fill(
                            child: Image.asset(
                              'assets/generated_1741655967983.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          // 绘制网格线（可选）
                          GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _game.gridSize,
                            ),
                            itemCount: _game.gridSize * _game.gridSize,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: GameTheme.gridLineColor.withOpacity(0.3)),
                                ),
                              );
                            },
                          ),
                          
                          // 绘制蛇
                          ...List.generate(_game.snake.length, (index) {
                            final part = _game.snake[index];
                            return Positioned(
                              left: part.x * cellSize,
                              top: part.y * cellSize,
                              width: cellSize,
                              height: cellSize,
                              child: Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: index == 0 
                                    ? GameTheme.snakeHeadColor 
                                    : GameTheme.getSnakeBodyColor(index, _game.snake.length, _game.score),
                                  borderRadius: BorderRadius.circular(index == 0 ? 6 : 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: index == 0 
                                        ? GameTheme.snakeHeadColor.withOpacity(0.8) 
                                        : GameTheme.getSnakeBodyColor(index, _game.snake.length, _game.score).withOpacity(0.5),
                                      blurRadius: index == 0 ? 12 : 8,
                                      spreadRadius: index == 0 ? 2 : 1,
                                    ),
                                  ],
                                ),
                                child: index == 0 
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: cellSize * 0.15,
                                          height: cellSize * 0.15,
                                          margin: EdgeInsets.only(top: cellSize * 0.25),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.8),
                                                blurRadius: 3,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: cellSize * 0.15,
                                          height: cellSize * 0.15,
                                          margin: EdgeInsets.only(top: cellSize * 0.25),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.8),
                                                blurRadius: 3,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                              ),
                            );
                          }),
                          
                          // 绘制食物 - 带脉冲动画
                          AnimatedBuilder(
                            animation: _foodAnimation,
                            builder: (context, child) {
                              return Positioned(
                                left: _game.food.x * cellSize + (cellSize * (1 - _foodAnimation.value) / 2),
                                top: _game.food.y * cellSize + (cellSize * (1 - _foodAnimation.value) / 2),
                                width: cellSize * _foodAnimation.value,
                                height: cellSize * _foodAnimation.value,
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        GameTheme.foodColor,
                                        GameTheme.foodColor.withOpacity(0.8),
                                      ],
                                      center: Alignment.center,
                                      radius: 0.8,
                                    ),
                                    borderRadius: BorderRadius.circular(cellSize / 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: GameTheme.foodGlowColor.withOpacity(0.8),
                                        blurRadius: 15,
                                        spreadRadius: 3,
                                      ),
                                      BoxShadow(
                                        color: GameTheme.foodGlowColor.withOpacity(0.5),
                                        blurRadius: 25,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: cellSize * 0.3,
                                      height: cellSize * 0.3,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // 控制按钮
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Direction buttons with better spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDirectionButton(Icons.arrow_upward, () {
                        _game.changeDirection(Direction.up);
                      }),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDirectionButton(Icons.arrow_back, () {
                        _game.changeDirection(Direction.left);
                      }),
                      const SizedBox(width: 80),
                      _buildDirectionButton(Icons.arrow_forward, () {
                        _game.changeDirection(Direction.right);
                      }),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDirectionButton(Icons.arrow_downward, () {
                        _game.changeDirection(Direction.down);
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_game.gameState == GameState.playing) {
                            _game.pauseGame();
                          } else {
                            _game.startGame();
                          }
                        },
                        style: GameTheme.getActionButtonStyle(_game.gameState),
                        child: Text(
                          _game.gameState == GameState.playing ? '暂停' : 
                          _game.gameState == GameState.gameOver ? '重新开始' : '开始',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          _game.resetGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameTheme.resetButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          elevation: 10,
                          shadowColor: GameTheme.resetButtonColor.withOpacity(0.6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ).copyWith(
                          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                        ),
                        child: const Text(
                          '重置',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建方向控制按钮
  Widget _buildDirectionButton(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: GameTheme.directionButtonStyle,
        child: Icon(icon, size: 32),
      ),
    );
  }
}
