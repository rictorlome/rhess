require_relative 'piece'


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
    if (left_attack[1].between?(0,SIZE) && self.board[left_attack].color != nil && self.board[left_attack].color != self.color)
      side_attacks << left_attack
    end
    if (right_attack[1].between?(0,SIZE) && self.board[right_attack].color != nil && self.board[right_attack].color != self.color)
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
