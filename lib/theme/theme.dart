import 'package:flutter/material.dart';
import '../models/snake_game.dart';

/// 游戏主题定义
class GameTheme {
  // 霓虹风格配色方案
  static const Color backgroundColor = Color(0xFF000022); // 星空蓝背景
  static const Color snakeHeadColor = Color(0xFF00E5FF); // 青蓝霓虹蛇头
  static const Color snakeBodyColor = Color(0xFF00E5FF); // 蛇身基础色
  static const Color snakeBodyEndColor = Color(0xFFFF00FF); // 蛇身渐变终止色
  static const Color foodColor = Color(0xFFFF00FF); // 品红霓虹食物
  static const Color foodGlowColor = Color(0xFFFF00FF); // 食物光晕
  static const Color gridLineColor = Color(0xFF3A3A3A); // 网格线颜色
  static const Color scoreColor = Color(0xFF00FFAA); // 分数颜色
  static const Color scoreGlowColor = Color(0xFF00FFAA); // 分数光晕
  
  // 按钮颜色
  static const Color startButtonColor = Color(0xFF00E5FF);
  static const Color pauseButtonColor = Color(0xFFFF00FF);
  static const Color resetButtonColor = Color(0xFF651FFF);
  
  // 游戏结束颜色
  static const Color gameOverColor = Color(0xFFFF1744);
  
  // 动态颜色生成 - 根据分数变化蛇的颜色
  static Color getSnakeBodyColor(int index, int totalLength, int score) {
    // 基础渐变 - 从蛇头到蛇尾的渐变
    double t = index / (totalLength - 1);
    
    // 根据分数调整色相
    int hueShift = (score ~/ 50) * 30; // 每50分调整30度色相
    
    // 创建基础渐变色
    Color baseColor = Color.lerp(
      snakeHeadColor, 
      snakeBodyEndColor, 
      t
    ) ?? snakeBodyColor;
    
    // 应用色相偏移
    if (hueShift > 0) {
      HSLColor hslColor = HSLColor.fromColor(baseColor);
      return hslColor.withHue((hslColor.hue + hueShift) % 360).toColor();
    }
    
    return baseColor;
  }
  
  // 食物脉冲动画颜色
  static Color getFoodPulseColor(Animation<double> animation) {
    return Color.lerp(
      foodColor.withOpacity(0.5),
      foodColor.withOpacity(0.9),
      animation.value
    ) ?? foodColor;
  }
  
  // 加速状态颜色
  static Color getSpeedBoostColor(int speed) {
    // 速度越快，颜色越偏红
    if (speed <= 150) {
      return Color.lerp(snakeHeadColor, gameOverColor, (300 - speed) / 150) ?? snakeHeadColor;
    }
    return snakeHeadColor;
  }
  
  // 按钮样式
  static ButtonStyle directionButtonStyle = ElevatedButton.styleFrom(
    shape: const CircleBorder(),
    padding: const EdgeInsets.all(20),
    backgroundColor: Color(0xFF1A1A2E),
    foregroundColor: Color(0xFF00E5FF),
    elevation: 10,
    shadowColor: Color(0xFF00E5FF).withOpacity(0.6),
  ).copyWith(
    overlayColor: MaterialStateProperty.all(Color(0xFF00E5FF).withOpacity(0.2)),
  );
  
  static ButtonStyle getActionButtonStyle(GameState gameState) {
    Color backgroundColor = startButtonColor; // 默认值，避免未初始化错误
    Color foregroundColor = Colors.white;
    
    switch (gameState) {
      case GameState.playing:
        backgroundColor = pauseButtonColor;
        break;
      case GameState.paused:
        backgroundColor = startButtonColor;
        break;
      case GameState.gameOver:
        backgroundColor = resetButtonColor;
        break;
    }
    
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      elevation: 10,
      shadowColor: backgroundColor.withOpacity(0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ).copyWith(
      overlayColor: MaterialStateProperty.all(foregroundColor.withOpacity(0.2)),
    );
  }
  
  // 文本样式
  static TextStyle scoreTextStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: scoreColor,
    shadows: [
      Shadow(
        color: scoreGlowColor.withOpacity(0.9),
        blurRadius: 12,
        offset: Offset(0, 0),
      ),
      Shadow(
        color: scoreGlowColor.withOpacity(0.5),
        blurRadius: 20,
        offset: Offset(0, 0),
      ),
    ],
    letterSpacing: -1.5, // 数码管风格字体通常字间距较小
  );
  
  static TextStyle gameOverTextStyle = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        color: Color(0xFFFF1744),
        blurRadius: 20,
        offset: Offset(0, 0),
      ),
      Shadow(
        color: Color(0xFFFF1744),
        blurRadius: 40,
        offset: Offset(0, 0),
      ),
    ],
  );
  
  static TextStyle buttonTextStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );
}

// 动画效果定义
class GameAnimations {
  // 食物脉冲动画
  static Animation<double> createFoodPulseAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  // 分数变化动画
  static Animation<double> createScoreChangeAnimation(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ),
    );
  }
}