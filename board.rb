require_relative 'piece/king'
require_relative 'piece/pawn'
require_relative 'piece/other_pieces'

PIECE_MAP = {
  # icons
  "\u2654" => [King, :white, "\u2654"],
  "\u2655" => [Queen, :white, "\u2655"],
  "\u2656" => [Rook, :white, "\u2656"],
  "\u2657" => [Bishop, :white, "\u2657"],
  "\u2658" => [Knight, :white, "\u2658"],
  "\u2659" => [Pawn, :white, "\u2659"],
  "\u265A" => [King, :black, "\u265A"],
  "\u265B" => [Queen, :black, "\u265B"],
  "\u265C" => [Rook, :black, "\u265C"],
  "\u265D" => [Bishop, :black, "\u265D"],
  "\u265E" => [Knight, :black, "\u265E"],
  "\u265F" => [Pawn, :black, "\u265F"],
  # ascii
  "K" => [King, :white, "\u2654"],
  "Q" => [Queen, :white, "\u2655"],
  "R" => [Rook, :white, "\u2656"],
  "B" => [Bishop, :white, "\u2657"],
  "N" => [Knight, :white, "\u2658"],
  "P" => [Pawn, :white, "\u2659"],
  "k" => [King, :black, "\u265A"],
  "q" => [Queen, :black, "\u265B"],
  "r" => [Rook, :black, "\u265C"],
  "b" => [Bishop, :black, "\u265D"],
  "n" => [Knight, :black, "\u265E"],
  "p" => [Pawn, :black, "\u265F"],
}

class Board
  attr_reader :grid, :can_empassant

  def initialize
    @grid = Array.new(8) { Array.new(8) {NullPiece.instance} }
    @can_empassant = false
  end

  def set_board(board_string)
    grid = board_string.gsub(' ', '').strip().split("\n").map{|row| row.strip().split('')}
    raise 'Invalid board' unless grid.size() == 8 and grid.all?{|row| row.size() == 8}

    for row,x in grid.each_with_index
      for item,y in row.each_with_index
        pos = [x,y]
        (piece, color, symbol) = PIECE_MAP[item]
        self[pos] = piece.new(
          color=color,
          pos=pos,
          board=self,
          symbol=" #{symbol} ") unless !piece
      end
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

  def set_empassant(start_pos,end_pos)
    two_moves = (end_pos[0] - start_pos[0]).abs != 1
    @can_empassant = (self[start_pos].class == Pawn && two_moves)
  end

  def wrap_rook(start_pos,end_pos)
    piece = self[start_pos]
    if piece.class == King && (end_pos[1] - start_pos[1]) == 2
      x, y = start_pos
      move_piece([x,y+3],[x,y+1])
    elsif piece.class == King && (end_pos[1] - start_pos[1]) == -2
      x, y = start_pos
      move_piece([x,y-4],[x,y-1])
    end
  end

  def castling?(start_pos,end_pos)
    piece = self[start_pos]
    piece.class == King && (end_pos[1] - start_pos[1]).abs != 1
  end

  def promoting?(start_pos,end_pos)
    piece = self[start_pos]
    piece.class == Pawn && (end_pos[0] == 0 || end_pos[7])
  end

  def empassanting?(start_pos,end_pos)
    taking = start_pos[1] != end_pos[1]
    self[start_pos].class == Pawn && taking &&
     self[end_pos].class == NullPiece && (end_pos[0] == start_pos[0] + self[start_pos].forward_dir)
  end

  def clean_up_empassanted_piece(start_pos,end_pos)
    x, y = end_pos
    piece = self[start_pos]
    if piece.color == :white
      self[[x+1,y]] = NullPiece.instance
    else
      self[[x-1,y]] = NullPiece.instance
    end
  end

  def choose_piece(start_pos)
    pawn = self[start_pos]
    white_uni = {
      'q': " \u2655 ",
      'r': " \u2656 ",
      'n': " \u2658 ",
      'b': " \u2657 ",
    }
    black_uni = {
      'q': " \u265B ",
      'r': " \u265C ",
      'n': " \u265E ",
      'b': " \u265D ",
    }
    puts 'Please choose which piece you want.'
    puts 'Press Q for Queen, R for Rook, N for Knight, B for Bishop.'
    choice = gets.chomp!.downcase
    pawn.color == :white ? code = white_uni[choice.to_sym] : code = black_uni[choice.to_sym]
    if choice === 'q'
      self[start_pos] = Queen.new(pawn.color,start_pos,self,code)
    elsif choice === 'r'
      self[start_pos] = Rook.new(pawn.color,start_pos,self,code)
    elsif choice === 'n'
      self[start_pos] = Knight.new(pawn.color,start_pos,self,code)
    elsif choice === 'b'
      self[start_pos] = Bishop.new(pawn.color,start_pos,self,code)
    end
  end

  def is_valid_move?(start_pos, end_pos)
    piece = self[start_pos]
    if !self.is_on_board?(start_pos) || piece.class == NullPiece
      puts "You cannot move a nil piece!"
      sleep(0.7)
      return false
    end
    unless piece.moves.include?(end_pos)
      puts "You cannot move there!"
      sleep(0.7)
      return false
    end
    if !castling?(start_pos,end_pos) && piece.move_into_check?(end_pos)
      puts "You cannot move into check!"
      sleep(0.7)
      return false
    end
    true
  end

  def find_kings
    kings_hash = {white: 0, black: 0}
    @grid.each_with_index do |row,idx1|
      row.each_with_index do |piece,idx2|
        pos = [idx1,idx2]
        kings_hash[piece.color] = pos if piece.class == King
      end
    end
    kings_hash
  end

  def in_check?(color)
    kings_hash = self.find_kings
    @grid.any? do |row|
      row.any? do |piece|
        next if piece.class == NullPiece || piece.color == color
        piece.moves.include?(kings_hash[color])
      end
    end
  end

  def under_attack_by?(color,pos)
    @grid.any? do |row|
      row.any? do |piece|
        next if piece.class == NullPiece || piece.class == King || piece.color != color
        piece.moves.include?(pos)
      end
    end
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
    self.in_check?(color) && !valid_moves?(color)
  end

end
