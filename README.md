# Rhess

## A Ruby implementation of Chess, featuring all the rules, including: flexible pawn-promotion, castling (king and queenside), as well as en passant!

![Demo Image](https://github.com/rictorlome/rhess/blob/master/rhess_screenshot.png)

## Description

This is a Ruby terminal game version of Chess. Right now, it supports castling, en passant, and pawn-promotion. The gameplay works using the keyboard. You select a piece using the space-bar, and select its destination with the spacebar as well. The pieces are rendered using unicode and the ruby colorize gem.

## Features

My intent with this implementation of chess was to code simple, highly semantic class interactions. The most complicated method is easily the move_piece method, which must listen

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

Another big decision came during move validation. Instead of duplicating the board for every possible move, I decided to move the piece, check if the board was in check, and then move the piece back. This came with numerous consequences especially for castling. One of the conditions for castling is that the king does not pass through check. The check method determines whether the pieces' moves include an attack on the king. The runs the castling move on the kings, which lead to an infinite loop. In order to avoid this stack overflow, I limited the check validation to movement of the other color's pieces.

## Instructions

In order to run this application, the user must clone the github repository and run game.rb in the terminal.
The exact command is: 'ruby game.rb'. Then the game should open up, allowing the user to play against a friend or against his or her self.

## Future

The main immediate goal for this app is to get a live version working on the browser in order to enable easier play. My current strategy for this is to combine the chessboard.js library with the opalrb transpiler to JS. The former will enable easy user interaction without duplicating the move validation, the latter will allow me to preserve my existing game logic without a total refactoring into JavaScript.
