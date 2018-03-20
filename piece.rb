require 'byebug'
require 'singleton'
require 'colorize'
require_relative 'board'

module Slideable

  def horizontal_dirs
    [[-1, 0], [1,0], [0, 1], [0, -1]]
  end

  def diagonal_dirs
    [[-1,-1],[-1,1],[1,1],[1,-1]]
  end

  def moves
    dirs = self.move_dirs
    all_moves = []
    dirs.each do |dir|
      all_moves += grow_unblocked_moves_in_dir(dir[0],dir[1])
    end
    all_moves
  end

  def grow_unblocked_moves_in_dir(dx,dy)
    pos = self.pos
    res = []
    (1..7).to_a.each do |i|
      move =[pos[0] + i * dx, pos[1] + i * dy]
      break unless (move[0]).between?(0,7) && (move[1]).between?(0,7)
      break if self.color == self.board[move].color
      res << move
      break if (self.color != self.board[move].color) && (self.board[move].color != nil)
    end
    res
  end

end

module Steppable
  def moves
    moves = []
    self.move_diffs.each do |diff|
      x, y = (self.pos[0] + diff[0]), (self.pos[1] + diff[1])
      moves << [x,y]
    end

    moves.select do |move|
      # debugger
      (move[0].between?(0,7) && move[1].between?(0,7)) &&
       (self.color != self.board[move].color || self.board[move].color == nil)
    end
  end
end


class Piece

  attr_reader :color, :board, :symbol
  attr_accessor :pos

  def initialize(color, pos, board, symbol)
    @color = color
    @pos = pos
    @board = board
    @symbol = symbol
  end

  def replace_piece(end_pos)
    return if self.class == NullPiece
    self.board[end_pos] = self
  end

  def move_into_check?(end_pos)
    start_pos = self.pos
    piece = self.board[end_pos]

    self.board.move_piece(start_pos,end_pos)
    check = self.board.check?[self.color]
    self.board.move_piece(end_pos,start_pos)

    piece.replace_piece(end_pos)
    check
  end

  def valid_moves?
    self.moves.any? do |move|
      !self.move_into_check?(move)
    end
  end

end

class NullPiece < Piece
  include Singleton

  def initialize
    @color = nil
    @pos = nil
    @symbol = '   '
  end
end


class Pawn < Piece

  def initialize (color, pos, board, symbol)
    super
    if self.color == :white
      @at_start_row = (self.pos[0] == 6)
    else
      @at_start_row = (self.pos[0] == 1)
    end
  end

  def moves
    mvs = []
    x, y = self.pos

    m1 = [(x + forward_dir), y]
    mvs << m1 if self.board[m1].color == nil

    m2 = [(x + forward_dir + forward_dir), y]
    mvs << m2 if @at_start_row && self.board[m1].color == nil && self.board[m2].color == nil

    mvs += self.side_attacks
    mvs
  end

  def forward_dir
    return -1 if self.color == :white
    return 1 if self.color == :black
  end

  def side_attacks
    x,y = self.pos
    side_attacks = []
    left_attack, right_attack = [(x + forward_dir), y+1], [(x + forward_dir), y-1]
    if (left_attack[1].between?(0,7) && self.board[left_attack].color != nil && self.board[left_attack].color != self.color)
      side_attacks << left_attack
    end
    if (right_attack[1].between?(0,7) && self.board[right_attack].color != nil && self.board[right_attack].color != self.color)
      side_attacks << right_attack
    end
    side_attacks
  end

end





class King < Piece
  include Steppable

  def move_diffs
    res = []
    (-1..1).each do |row|
      (-1..1).each do |col|
        res << [row,col] unless row == 0 && col == 0
      end
    end
    res
  end
end

class Knight < Piece
  include Steppable

  def move_diffs
    [[1,2],[1,-2],[-1,2],[-1,-2],[2,1],[2,-1],[-2,1],[-2,-1]]
  end
end


class Rook < Piece
  include Slideable

  def move_dirs
    horizontal_dirs
  end

end

class Bishop < Piece
  include Slideable

  def move_dirs
    diagonal_dirs
  end
end

class Queen < Piece
  include Slideable

  def move_dirs
    horizontal_dirs + diagonal_dirs
  end
end
