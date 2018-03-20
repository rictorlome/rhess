require_relative 'board'
require_relative 'piece'
require_relative 'cursor'
require_relative 'display'
require 'byebug'


class Game
  attr_reader :board, :display

  def initialize
    @board = Board.new
    board.set_board
    @display = Display.new(@board)
  end

  def check_status
    check_hash = board.check?
    print "White in check?:  "
    if check_hash[:white]
      puts check_hash[:white].to_s.colorize(:red)
    else
      puts check_hash[:white].to_s.colorize(:green)
    end
    print "Black in check?:  "
    if check_hash[:black]
      puts check_hash[:black].to_s.colorize(:red)
    else
      puts check_hash[:black].to_s.colorize(:green)
    end
  end

  def checkmate_status
    print "White in checkmate?: "
    puts board.checkmate?(:white)
    print "Black in checkmate?: "
    puts board.checkmate?(:black)
  end

  def play
    system("clear")
    100.times do
      display.render
      self.check_status
      self.checkmate_status
      puts "The move buffer: #{display.cursor.move_buffer}"
      display.cursor.get_input
      if display.cursor.move_buffer.length == 2
        start, dest = display.cursor.move_buffer[0], display.cursor.move_buffer[1]
        piece = board[start]
        if piece.moves.include?(dest)
          board.move_piece(start,dest)
        else
          puts "You can't move there!"
          sleep(0.7)
        end
        display.cursor.move_buffer = []
      end
      system("clear")
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  g = Game.new
  g.play
end
