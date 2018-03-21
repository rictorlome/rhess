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
      (move[0].between?(0,7) && move[1].between?(0,7)) &&
       (self.color != self.board[move].color || self.board[move].color == nil)
    end
  end
end


class Piece

  attr_reader :color, :board, :symbol
  attr_accessor :pos, :has_moved

  def initialize(color, pos, board, symbol)
    @color = color
    @pos = pos
    @board = board
    @symbol = symbol
    @has_moved = false
  end

  def replace_piece(end_pos)
    return if self.class == NullPiece
    self.board[end_pos] = self
  end

  def move_into_check?(end_pos)
    start_pos = self.pos
    piece = self.board[end_pos]

    self.board.move_piece(start_pos,end_pos)
    check = self.board.in_check?(self.color)
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
  def moves
    mvs = []
    x, y = self.pos

    m1 = [(x + forward_dir), y]
    mvs << m1 if self.board[m1].color == nil

    m2 = [(x + forward_dir + forward_dir), y]
    mvs << m2 if !@has_moved && self.board[m1].color == nil && self.board[m2].color == nil

    mvs += self.side_attacks
    mvs += empassant
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

  def on_fifth_rank
    (self.pos[0] == 3 && self.color == :white) ||
      (self.pos[0]== 4 && self.color == :black)
  end

  def flanked_by_a_pawn
    x, y = self.pos
    self.color == :white ? opposite = :black : opposite = :white
    left, right = self.board[[x,y-1]], self.board[[x,y+1]]
    (left.class == Pawn && left.color == opposite) ||
      (right.class == Pawn && right.color == opposite)
  end

  def find_flanking_pawn
    x, y = self.pos
    self.color == :white ? opposite = :black : opposite = :white
    left, right = self.board[[x,y-1]], self.board[[x,y+1]]
    return [x+forward_dir,y-1] if (left.class == Pawn && left.color == opposite)
    return [x+forward_dir,y+1] if (right.class == Pawn && right.color == opposite)
  end

  def empassant
    empassant = []
    return empassant unless self.board.can_empassant
    if on_fifth_rank && flanked_by_a_pawn
      empassant << find_flanking_pawn
    end
    empassant
  end



end

class King < Piece
  def move_diffs
    res = []
    (-1..1).each do |row|
      (-1..1).each do |col|
        res << [row,col] unless row == 0 && col == 0
      end
    end
    res
  end

  def kingside_row_clear
    x, y = self.pos
    self.color == :white ? other = :black : other = :white

    rook_in_place = self.board[[x,y+3]].class == Rook && !self.board[[x,y+3]].has_moved

    rook_in_place && (1..2).to_a.all? do |i|
      self.board[[x,y+i]].class == NullPiece &&
      !self.board.under_attack_by?(other,[x,y+i])
    end
  end

  def queenside_row_clear
    x, y = self.pos
    self.color == :white ? other = :black : other = :white

    rook_in_place = self.board[[x,y-4]].class == Rook && !self.board[[x,y-4]].has_moved

    rook_in_place && (1..3).to_a.all? do |i|
      self.board[[x,y-i]].class == NullPiece &&
      !self.board.under_attack_by?(other,[x,y-i])
    end
  end

  def add_castle_to_moves(moves)
    return moves if self.has_moved
    self.color == :white ? other = :black : other = :white
    return moves if self.board.under_attack_by?(other,self.pos)

    x, y = self.pos

    moves.push([x,y+2]) if self.kingside_row_clear
    moves.push([x,y-2]) if self.queenside_row_clear
    moves
  end


  def moves
    moves = []
    self.move_diffs.each do |diff|
      x, y = (self.pos[0] + diff[0]), (self.pos[1] + diff[1])
      moves << [x,y]
    end

    unblocked = moves.select do |move|
      (move[0].between?(0,7) && move[1].between?(0,7)) &&
       (self.color != self.board[move].color || self.board[move].color == nil)
    end
    add_castle_to_moves(unblocked)
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
