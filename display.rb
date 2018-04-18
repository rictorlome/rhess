require 'colorize'
require_relative "cursor.rb"
require_relative "board.rb"

class Display
  attr_reader :cursor, :board

  def initialize(board)
    @board = board
    @current_pos = [0,0]
    @cursor = Cursor.new(@current_pos, @board)
  end

  def render
    @board.grid.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        (i + j).even? ? back = :light_white : back = :light_black
        if [i,j] == @cursor.cursor_pos
          print piece.symbol.colorize(:light_red).colorize( :background => :red)
        elsif [i,j] == @cursor.move_buffer.first
          print piece.symbol.colorize(:color => piece.color, :background => :yellow)
        else
          print piece.symbol.colorize(:color => piece.color, :background => back)
        end
      end
      print "\n"
    end
  end

  def render_to_string
    s = ''
    @board.grid.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        if piece.instance_of? NullPiece
          s += ' _ '
        else
          s += piece.symbol
        end
      end
      s += "\n"
    end
    return s
  end
end
