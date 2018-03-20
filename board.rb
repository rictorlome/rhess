require_relative 'piece'

class Board
  attr_reader :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) {NullPiece.instance} }
    self.set_board
  end
#color, pos, board, symbol
  def set_board
    self[[0,0]] = Rook.new(:black,[0,0],self," \u265C ")
    self[[0,7]] = Rook.new(:black,[0,7],self," \u265C ")
    self[[0,1]] = Knight.new(:black,[0,1],self," \u265E ")
    self[[0,6]] = Knight.new(:black,[0,6],self," \u265E ")
    self[[0,2]] = Bishop.new(:black,[0,2],self," \u265D ")
    self[[0,5]] = Bishop.new(:black,[0,5],self," \u265D ")
    self[[0,4]] = King.new(:black,[0,4],self," \u265A ")
    self[[0,3]] = Queen.new(:black,[0,3],self," \u265B ")
    8.times do |i|
      self[[1,i]] = Pawn.new(:black,[1,i],self," \u265F ")
    end
    self[[7,0]] = Rook.new(:white,[7,0],self," \u2656 ")
    self[[7,7]] = Rook.new(:white,[7,7],self," \u2656 ")
    self[[7,1]] = Knight.new(:white,[7,1],self," \u2658 ")
    self[[7,6]] = Knight.new(:white,[7,6],self," \u2658 ")
    self[[7,2]] = Bishop.new(:white,[7,2],self," \u2657 ")
    self[[7,5]] = Bishop.new(:white,[7,5],self," \u2657 ")
    self[[7,4]] = King.new(:white,[7,4],self," \u2654 ")
    self[[7,3]] = Queen.new(:white,[7,3],self," \u2655 ")
    8.times do |i|
      self[[6,i]] = Pawn.new(:white,[6,i],self," \u2659 ")
    end
  end

  def [](pos)
    x, y = pos
    @grid[x][y]
  end

  def []=(pos,val)
    x, y = pos
    @grid[x][y] = val
  end

  def is_on_board? (pos)
    self[pos].is_a? (Piece)
  end

  def move_piece(start_pos, end_pos)
    piece = self[start_pos]
    if !self.is_on_board?(start_pos) || piece.class == NullPiece
      puts "You cannot move a nil piece!"
      sleep(0.7)
    end
    self[start_pos], self[end_pos] = NullPiece.instance, piece
    piece.pos = end_pos
  end

  def find_kings
    kings_hash = {white: 0, black: 0}
    @grid.each_with_index do |row,idx1|
      row.each_with_index do |piece,idx2|
        pos = [idx1,idx2]
        kings_hash[:white] = pos if piece.class == King && piece.color ==  :white
        kings_hash[:black] = pos if piece.class == King && piece.color ==  :black
      end
    end
    kings_hash
  end

  def check?
    kings_hash = self.find_kings
    check_hash = {white: false, black: false}
    @grid.each do |row|
      row.each do |piece|
        next if piece.class == NullPiece
        moves = piece.moves
        if piece.color == :white
           check_hash[:black] = true if moves.include?(kings_hash[:black])
        elsif piece.color == :black
          check_hash[:white] = true if moves.include?(kings_hash[:white])
        end
      end
    end
    check_hash
  end

  def valid_moves?(color)
    @grid.any? do |row|
      row.any? do |piece|
        next unless piece.color == color
        piece.valid_moves?
      end
    end
  end

  def checkmate?(color)
    check_hash = self.check?
    check_hash[color] && !valid_moves?(color)
  end

end
