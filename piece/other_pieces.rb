require_relative 'modules'
require_relative 'piece'

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
