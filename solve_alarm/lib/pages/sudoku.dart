import 'package:flutter/material.dart';
import 'dart:math';

class SudokuPage extends StatefulWidget {
  final Function onSudokuSolved;

  const SudokuPage({Key? key, required this.onSudokuSolved}) : super(key: key);

  @override
  _SudokuPageState createState() => _SudokuPageState();
}



class _SudokuPageState extends State<SudokuPage> {
  late List<List<int>> _board;
  late List<List<bool>> _isEditable;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    _printBoard(); // Debug print
  }

  void _initializeBoard() {
    _board = List.generate(4, (_) => List.filled(4, 0));
    _isEditable = List.generate(4, (_) => List.filled(4, true));

    _generateSolvedBoard();
    _createPuzzle();
  }

  void _generateSolvedBoard() {
    List<int> numbers = [1, 2, 3, 4];
    numbers.shuffle();

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        _board[i][j] = numbers[(i * 2 + j) % 4];
      }
      if (i % 2 == 1) {
        numbers.shuffle();
      }
    }
  }

  void _createPuzzle() {
    Random random = Random();
    int numbersToKeep = 3; // Keep 3 numbers on the board

    while (numbersToKeep > 0) {
      int row = random.nextInt(4);
      int col = random.nextInt(4);

      if (_isEditable[row][col]) {
        _isEditable[row][col] = false;
        numbersToKeep--;
      }
    }

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (_isEditable[i][j]) {
          _board[i][j] = 0; // Clear editable cells
        }
      }
    }

    _printBoard(); // Debug print
  }

  bool _isBoardValid() {
    // Check rows
    for (int i = 0; i < 4; i++) {
      if (!_isRowValid(i)) return false;
    }

    // Check columns
    for (int j = 0; j < 4; j++) {
      if (!_isColumnValid(j)) return false;
    }

    // Check 2x2 squares
    for (int i = 0; i < 4; i += 2) {
      for (int j = 0; j < 4; j += 2) {
        if (!_isSquareValid(i, j)) return false;
      }
    }

    return true;
  }

  bool _isRowValid(int row) {
    Set<int> numbers = {};
    for (int j = 0; j < 4; j++) {
      if (_board[row][j] == 0) return false;
      if (!numbers.add(_board[row][j])) return false;
    }
    return true;
  }

  bool _isColumnValid(int col) {
    Set<int> numbers = {};
    for (int i = 0; i < 4; i++) {
      if (_board[i][col] == 0) return false;
      if (!numbers.add(_board[i][col])) return false;
    }
    return true;
  }

  bool _isSquareValid(int startRow, int startCol) {
    Set<int> numbers = {};
    for (int i = startRow; i < startRow + 2; i++) {
      for (int j = startCol; j < startCol + 2; j++) {
        if (_board[i][j] == 0) return false;
        if (!numbers.add(_board[i][j])) return false;
      }
    }
    return true;
  }

   void _updateCell(int row, int col, int value) {
    setState(() {
      _board[row][col] = value;
    });

    if (_isBoardValid()) {
      widget.onSudokuSolved();
      Navigator.of(context).pop(true); // Return true when solved
    }
  }

  void _printBoard() {
    print("Current Sudoku Board:");
    for (int i = 0; i < 4; i++) {
      print(_board[i].map((e) => e == 0 ? '_' : e.toString()).join(' '));
    }
    print("\nEditable cells:");
    for (int i = 0; i < 4; i++) {
      print(_isEditable[i].map((e) => e ? 'O' : 'X').join(' '));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Löse das Sudoku'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 4; i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int j = 0; j < 4; j++)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: _isEditable[i][j] ? Colors.white : Colors.grey[300],
                        ),
                        child: _isEditable[i][j]
                            ? TextField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    int? number = int.tryParse(value);
                                    if (number != null && number >= 1 && number <= 4) {
                                      _updateCell(i, j, number);
                                    }
                                  } else {
                                    _updateCell(i, j, 0);
                                  }
                                },
                              )
                            : Center(
                                child: Text(
                                  _board[i][j] != 0 ? _board[i][j].toString() : '',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}