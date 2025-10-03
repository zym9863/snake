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
  
  // 食物旋转动画控制器
  late AnimationController _foodRotationController;
  late Animation<double> _foodRotationAnimation;
  
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
    
    // 初始化食物脉冲动画
    _foodAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _foodAnimation = GameAnimations.createFoodPulseAnimation(_foodAnimationController);
    _foodAnimationController.repeat(reverse: true);
    
    // 初始化食物旋转动画
    _foodRotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _foodRotationAnimation = GameAnimations.createFoodRotationAnimation(_foodRotationController);
    _foodRotationController.repeat();
    
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
    _foodRotationController.dispose();
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                GameTheme.backgroundColor,
                GameTheme.backgroundAccent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: GameTheme.snakeHeadColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            title: Row(
              children: [
                Icon(
                  Icons.videogame_asset,
                  color: GameTheme.snakeHeadColor,
                  size: 28,
                  shadows: [
                    Shadow(
                      color: GameTheme.snakeHeadColor.withOpacity(0.8),
                      blurRadius: 10,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                const Text(
                  '霓虹贪吃蛇', 
                  style: TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color(0xFF00F5FF),
                        blurRadius: 15,
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        color: Color(0xFF00F5FF),
                        blurRadius: 25,
                        offset: Offset(0, 0),
                      ),
                    ],
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // 显示分数
              Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: GameTheme.backgroundAccent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: GameTheme.scoreColor.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: GameTheme.scoreGlowColor.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _scoreAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scoreAnimation.value,
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: GameTheme.scoreColor,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_game.score}',
                              style: GameTheme.scoreTextStyle.copyWith(fontSize: 22),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
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
                      GameTheme.gameOverColor.withOpacity(0.3),
                      GameTheme.gameOverColor.withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: GameTheme.gameOverColor.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      '💀 游戏结束 💀',
                      textAlign: TextAlign.center,
                      style: GameTheme.gameOverTextStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '最终分数: ${_game.score}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GameTheme.scoreColor,
                        shadows: [
                          Shadow(
                            color: GameTheme.scoreGlowColor.withOpacity(0.8),
                            blurRadius: 10,
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
                    border: Border.all(color: GameTheme.snakeHeadColor.withOpacity(0.5), width: 3.0),
                    color: GameTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: GameTheme.snakeHeadColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: GameTheme.foodGlowColor.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double cellSize = constraints.maxWidth / _game.gridSize;
                      return Stack(
                        children: [
                          // 背景图片
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/generated_1741655967983.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // 绘制网格线（可选）
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _game.gridSize,
                              ),
                              itemCount: _game.gridSize * _game.gridSize,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: GameTheme.gridLineColor.withOpacity(0.2)),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // 绘制蛇
                          ...List.generate(_game.snake.length, (index) {
                            final part = _game.snake[index];
                            final isHead = index == 0;
                            final bodyColor = isHead 
                              ? GameTheme.snakeHeadColor 
                              : GameTheme.getSnakeBodyColor(index, _game.snake.length, _game.score);
                            
                            return Positioned(
                              left: part.x * cellSize,
                              top: part.y * cellSize,
                              width: cellSize,
                              height: cellSize,
                              child: Container(
                                margin: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      bodyColor,
                                      bodyColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(isHead ? 6 : 4),
                                  border: Border.all(
                                    color: bodyColor.withOpacity(0.5),
                                    width: isHead ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: bodyColor.withOpacity(isHead ? 0.8 : 0.6),
                                      blurRadius: isHead ? 12 : 8,
                                      spreadRadius: isHead ? 2 : 1,
                                    ),
                                  ],
                                ),
                                // 蛇头添加眼睛效果
                                child: isHead ? Stack(
                                  children: [
                                    Positioned(
                                      left: cellSize * 0.25,
                                      top: cellSize * 0.3,
                                      child: Container(
                                        width: cellSize * 0.15,
                                        height: cellSize * 0.15,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.5),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: cellSize * 0.25,
                                      top: cellSize * 0.3,
                                      child: Container(
                                        width: cellSize * 0.15,
                                        height: cellSize * 0.15,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.5),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ) : null,
                              ),
                            );
                          }),
                          
                          // 绘制食物 - 带脉冲和旋转动画
                          AnimatedBuilder(
                            animation: Listenable.merge([_foodAnimation, _foodRotationAnimation]),
                            builder: (context, child) {
                              return Positioned(
                                left: _game.food.x * cellSize + (cellSize * (1 - _foodAnimation.value) / 2),
                                top: _game.food.y * cellSize + (cellSize * (1 - _foodAnimation.value) / 2),
                                width: cellSize * _foodAnimation.value,
                                height: cellSize * _foodAnimation.value,
                                child: Transform.rotate(
                                  angle: _foodRotationAnimation.value,
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        colors: [
                                          GameTheme.foodColor,
                                          GameTheme.foodGlowColor,
                                          GameTheme.foodColor.withOpacity(0.8),
                                        ],
                                        stops: const [0.3, 0.6, 1.0],
                                      ),
                                      borderRadius: BorderRadius.circular(cellSize / 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: GameTheme.foodGlowColor.withOpacity(0.8),
                                          blurRadius: 15,
                                          spreadRadius: 3,
                                        ),
                                        BoxShadow(
                                          color: GameTheme.foodColor.withOpacity(0.5),
                                          blurRadius: 25,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: cellSize * 0.4,
                                        height: cellSize * 0.4,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
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
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    GameTheme.backgroundColor,
                    GameTheme.backgroundAccent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // 方向控制
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GameTheme.backgroundAccent.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: GameTheme.gridLineColor,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDirectionButton(Icons.arrow_upward, () {
                              _game.changeDirection(Direction.up);
                            }),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDirectionButton(Icons.arrow_downward, () {
                              _game.changeDirection(Direction.down);
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 游戏控制按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        icon: _game.gameState == GameState.playing 
                          ? Icons.pause_circle_filled 
                          : (_game.gameState == GameState.gameOver 
                            ? Icons.replay_circle_filled 
                            : Icons.play_circle_filled),
                        label: _game.gameState == GameState.playing ? '暂停' : 
                               _game.gameState == GameState.gameOver ? '重新开始' : '开始',
                        onPressed: () {
                          if (_game.gameState == GameState.playing) {
                            _game.pauseGame();
                          } else {
                            _game.startGame();
                          }
                        },
                        style: GameTheme.getActionButtonStyle(_game.gameState),
                      ),
                      const SizedBox(width: 20),
                      _buildActionButton(
                        icon: Icons.refresh,
                        label: '重置',
                        onPressed: () {
                          _game.resetGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameTheme.resetButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          elevation: 12,
                          shadowColor: GameTheme.resetButtonColor.withOpacity(0.8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide(color: GameTheme.resetButtonColor.withOpacity(0.8), width: 2),
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
  
  // 构建游戏控制按钮（开始/暂停/重置）
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ButtonStyle style,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      style: style,
    );
  }
}
