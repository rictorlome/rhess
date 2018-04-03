require_relative 'piece'

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
      (move[0].between?(0,SIZE) && move[1].between?(0,SIZE)) &&
       (self.color != self.board[move].color || self.board[move].color == nil)
    end
    add_castle_to_moves(unblocked)
  end

end
