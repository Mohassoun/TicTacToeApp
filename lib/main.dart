import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

void main() {
  runApp(TicTacToeApp());
}

Uint8List backgroundImageBytes =
    Uint8List(0); // Initialize to an empty Uint8List

void loadBackgroundImage() async {
  final ByteData data = await rootBundle.load(
      'assets/back.jpg'); // Replace 'assets/back.jpg' with your image path
  backgroundImageBytes = data.buffer.asUint8List();
}

class TicTacToeApp extends StatefulWidget {
  @override
  State<TicTacToeApp> createState() => _TicTacToeAppState();
}

class _TicTacToeAppState extends State<TicTacToeApp> {
  String playerXName = ' ';
  String playerOName = ' ';

  @override
  void initState() {
    super.initState();
    loadBackgroundImage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: (playerXName.isEmpty || playerOName.isEmpty)
          ? PlayerInputScreen(
              onStartGame: (String xName, String oName) {
                setState(() {
                  playerXName = xName;
                  playerOName = oName;
                });
              },
            )
          : TicTacToeGame(playerXName: playerXName, playerOName: playerOName),
    );
  }
}

class PlayerInputScreen extends StatelessWidget {
  final Function(String, String) onStartGame;

  PlayerInputScreen({required this.onStartGame});

  final TextEditingController playerXController = TextEditingController();
  final TextEditingController playerOController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic-Tac'),
        backgroundColor: Colors.black, // Set the background color to black
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: playerXController,
              decoration: InputDecoration(labelText: 'Player X Name'),
            ),
            TextField(
              controller: playerOController,
              decoration: InputDecoration(labelText: 'Player O Name'),
            ),
            ElevatedButton(
              onPressed: () {
                String playerXName = playerXController.text;
                String playerOName = playerOController.text;
                if (playerXName.isNotEmpty && playerOName.isNotEmpty) {
                  onStartGame(playerXName, playerOName);
                } else {
                  // Show an error message or alert if names are empty.
                }
              },
              child: Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  final String playerXName;
  final String playerOName;

  TicTacToeGame({required this.playerXName, required this.playerOName});

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  int xWins = 0;
  int oWins = 0;

  List<List<String>> board = [];
  String currentPlayer = '';

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    board = List.generate(3, (_) => List.filled(3, ''));
    currentPlayer = 'X';
    setState(() {});
  }

  void onCellTapped(int row, int col) {
    if (board[row][col].isEmpty) {
      setState(() {
        board[row][col] = currentPlayer;
        currentPlayer = (currentPlayer == 'X') ? 'O' : 'X';
      });

      String winner = checkForWinner();
      if (winner.isNotEmpty) {
        showWinnerDialog(winner);
      }
    }
  }

  String checkForWinner() {
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == board[i][1] &&
          board[i][1] == board[i][2] &&
          board[i][0].isNotEmpty) {
        return board[i][0];
      }
      if (board[0][i] == board[1][i] &&
          board[1][i] == board[2][i] &&
          board[0][i].isNotEmpty) {
        return board[0][i];
      }
    }
    if (board[0][0] == board[1][1] &&
        board[1][1] == board[2][2] &&
        board[0][0].isNotEmpty) {
      return board[0][0];
    }
    if (board[0][2] == board[1][1] &&
        board[1][1] == board[2][0] &&
        board[0][2].isNotEmpty) {
      return board[0][2];
    }

    bool isDraw = true;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j].isEmpty) {
          isDraw = false;
          break;
        }
      }
    }
    if (isDraw) {
      return 'Draw';
    }

    return '';
  }

  void showWinnerDialog(String winner) {
    String winnerName = (winner == 'Draw') ? 'It\'s a draw!' : 'Player $winner';

    if (winner != 'Draw') {
      winnerName += (winner == 'X') ? widget.playerXName : widget.playerOName;

      if (winner == 'X') {
        xWins++; // Increment X's win count
      } else {
        oWins++; // Increment O's win count
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                winnerName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('X Wins:', style: TextStyle(fontSize: 16)),
                      Text('$xWins',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('O Wins:', style: TextStyle(fontSize: 16)),
                      Text('$oWins',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.pop(context);
              },
              child: Text('Play Again', style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic-Tac'),
      ),
      body: Stack(
        children: <Widget>[
          // Background image
          backgroundImageBytes != null
              ? Positioned.fill(
                  child: Image.memory(
                    backgroundImageBytes,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(), // Add a fallback container if the image is not loaded

          // Game UI
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Text(
                  'Current Player: $currentPlayer',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final row = index ~/ 3;
                    final col = index % 3;
                    String symbol = board[row][col];
                    Color textColor = (symbol == 'X')
                        ? Colors.red
                        : Colors.blue; // Set color based on symbol

                    return GestureDetector(
                      onTap: () => onCellTapped(row, col),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: Center(
                          child: Text(
                            symbol,
                            style: TextStyle(
                                fontSize: 48, color: textColor), // Apply color
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: ElevatedButton(
                  onPressed: resetGame,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                        8.0), // Add padding to the button text
                    child: Text(
                      'Reset Game',
                      style: TextStyle(
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
