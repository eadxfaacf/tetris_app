import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetris Clone',
      theme: ThemeData.dark(),
      home: const TetrisGame(),
    );
  }
}

class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  static const int rows = 20;
  static const int columns = 10;

  List<List<Color?>> board = List.generate(
      rows, (_) => List.filled(columns, null, growable: false),
      growable: false);

  Timer? gameTimer;
  Duration tickRate = const Duration(milliseconds: 500);

  Tetromino? currentPiece;

  @override
  void initState() {
    super.initState();
    spawnPiece();
    startGameLoop();
  }

  void startGameLoop() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(tickRate, (_) => moveDown());
  }

  void spawnPiece() {
    currentPiece = Tetromino.random();
    currentPiece!.x = 3;
    currentPiece!.y = 0;
  }

  void moveDown() {
    if (!currentPiece!.collides(board, dy: 1)) {
      setState(() => currentPiece!.y++);
    } else {
      lockPiece();
      clearLines();
      spawnPiece();
    }
  }

  void lockPiece() {
    for (var cell in currentPiece!.shape) {
      int x = currentPiece!.x + cell[0];
      int y = currentPiece!.y + cell[1];
      if (y >= 0 && y < rows && x >= 0 && x < columns) {
        board[y][x] = currentPiece!.color;
      }
    }
  }

  void clearLines() {
    setState(() {
      board.removeWhere((row) => row.every((cell) => cell != null));
      int cleared = rows - board.length;
      for (int i = 0; i < cleared; i++) {
        board.insert(0, List.filled(columns, null));
      }
    });
  }

  void moveLeft() {
    if (!currentPiece!.collides(board, dx: -1)) {
      setState(() => currentPiece!.x--);
    }
  }

  void moveRight() {
    if (!currentPiece!.collides(board, dx: 1)) {
      setState(() => currentPiece!.x++);
    }
  }

  void rotate() {
    setState(() {
      currentPiece!.rotate();
      if (currentPiece!.collides(board)) {
        currentPiece!.rotateBack();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tetris")),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows * columns,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
              ),
              itemBuilder: (context, index) {
                int x = index % columns;
                int y = index ~/ columns;

                Color? color = board[y][x];

                for (var cell in currentPiece!.shape) {
                  int px = currentPiece!.x + cell[0];
                  int py = currentPiece!.y + cell[1];
                  if (px == x && py == y) {
                    color = currentPiece!.color;
                  }
                }

                return Container(
                  margin: const EdgeInsets.all(1),
                  color: color ?? Colors.grey[900],
                );
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: moveLeft, child: const Icon(Icons.arrow_left)),
              ElevatedButton(onPressed: rotate, child: const Icon(Icons.rotate_right)),
              ElevatedButton(onPressed: moveRight, child: const Icon(Icons.arrow_right)),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class Tetromino {
  late List<List<int>> shape;
  late Color color;
  int x = 0;
  int y = 0;

  Tetromino(this.shape, this.color);

  static final List<Tetromino> pieces = [
    Tetromino([[0,0],[1,0],[2,0],[3,0]], Colors.cyan),
    Tetromino([[0,0],[0,1],[1,1],[2,1]], Colors.blue),
    Tetromino([[2,0],[0,1],[1,1],[2,1]], Colors.orange),
    Tetromino([[1,0],[2,0],[0,1],[1,1]], Colors.green),
    Tetromino([[0,0],[1,0],[1,1],[2,1]], Colors.red),
    Tetromino([[0,0],[1,0],[2,0],[1,1]], Colors.purple),
    Tetromino([[0,0],[1,0],[0,1],[1,1]], Colors.yellow),
  ];

  static Tetromino random() {
    final rand = Random();
    final template = pieces[rand.nextInt(pieces.length)];
    return Tetromino(
      List.from(template.shape.map((c) => List.from(c))),
      template.color,
    );
  }

  bool collides(List<List<Color?>> board, {int dx = 0, int dy = 0}) {
    for (var cell in shape) {
      int nx = x + cell[0] + dx;
      int ny = y + cell[1] + dy;

      if (nx < 0 || nx >= _TetrisGameState.columns) return true;
      if (ny >= _TetrisGameState.rows) return true;
      if (ny >= 0 && board[ny][nx] != null) return true;
    }
    return false;
  }

  void rotate() {
    for (var cell in shape) {
      int temp = cell[0];
      cell[0] = -cell[1];
      cell[1] = temp;
    }
  }

  void rotateBack() {
    for (var cell in shape) {
      int temp = cell[0];
      cell[0] = cell[1];
      cell[1] = -temp;
    }
  }
}
