require 'singleton'
require 'colorize'
require_relative '../board'
require_relative 'modules'

SIZE = 7

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
