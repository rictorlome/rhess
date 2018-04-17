# Rhess

## A Ruby implementation of Chess, featuring all the rules, including: flexible pawn-promotion, castling (king and queenside), as well as en passant!

![Demo Image](https://github.com/rictorlome/rhess/blob/master/rhess_screenshot.png)

## Description

This is a Ruby terminal game version of Chess. Right now, it supports castling, en passant, and pawn-promotion. The gameplay works using the keyboard. You select a piece using the space-bar, and select its destination with the spacebar as well. The pieces are rendered using unicode and the ruby colorize gem.

## Features

My intent with this implementation of chess was to code simple, highly semantic class interactions. The most complicated method is easily the move_piece method, which must listen for non-standard moves such as castling, en passant and pawn promotion. I tried to keep this method easy to read using straightforward helper methods.

``` ruby
def move_piece(start_pos, end_pos)
  piece = self[start_pos]
  wrap_rook(start_pos,end_pos) if castling?(start_pos,end_pos)
  set_empassant(start_pos,end_pos)
  clean_up_empassanted_piece(start_pos,end_pos) if empassanting?(start_pos,end_pos)
  if promoting?(start_pos,end_pos)
    choose_piece(start_pos)
    piece = self[start_pos]
  end
  self[start_pos], self[end_pos] = NullPiece.instance, piece
  piece.pos = end_pos
end
```

Another big decision came during move validation. Instead of duplicating the board for every possible move, I decided to move the piece, determine if the board was in check, and then move the piece back. This came with numerous consequences especially for castling. One of the conditions for castling is that the king does not pass through check. The check method determines whether the pieces' moves include an attack on the king. This, in turn, runs the castling move on the kings, which lead to an infinite loop. In order to avoid this stack overflow, I limited the check validation to movement of the other color's pieces.

## Instructions

In order to run this application, the user must clone the github repository, navigate into the repo folder, install the colorize gem, and run game.rb in the terminal.
```bash
$ git clone https://github.com/rictorlome/rhess.git
$ cd rhess
$ gem install colorize
$ ruby game.rb
```
 Then the game should open up, allowing the user to play against a friend or against his or her self. I have been informed that the game does not work for all versions of ruby. If your version of ruby does not support ```require_relative```, you will not be able to load game.rb. I do not know what the breakdown is for which versions are compatible, but the game should work for the following version:
 ```bash
 $ ruby --version
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-darwin16]
```

In addition, thanks to contributions by [@davegolland](https://github.com/davegolland), there are now additional options with which you can load the game. Running game.rb with the ```--help``` flag will print out the different options, which include fast-forwarding through the instructions and specifying an initial board state.
```bash
$ ruby game.rb -h
Usage: game [options]
    -b, --board PATH                 Specify the initial board file. (default: data/initial_board.txt)
    -f, --fast                       Dont sleep between instructions.
    -h, --help                       Prints this help
```

## Future

The immediate goals for this application can be divided into two main categories:
### 1. To enable easier play and demonstration.
- To this end, getting a version working in the browser is the logical step. The current plan is to use the chessboard.js library for the presentational components, while retaining the existing gameplay logic on a ruby backend.

### 2. To build out chess functionality.

- To improve the board parsing functionality, possibly with different formats.
- To implement a chess-puzzle solving AI.
- To eventually implement a full gameplay AI.
