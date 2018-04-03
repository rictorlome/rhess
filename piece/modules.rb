require_relative 'piece'

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
    (1..SIZE).to_a.each do |i|
      move =[pos[0] + i * dx, pos[1] + i * dy]
      break unless (move[0]).between?(0,SIZE) && (move[1]).between?(0,SIZE)
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
      (move[0].between?(0,SIZE) && move[1].between?(0,SIZE)) &&
       (self.color != self.board[move].color || self.board[move].color == nil)
    end
  end
end
