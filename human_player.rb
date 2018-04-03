require_relative 'board'
require_relative 'cursor'
require_relative 'display'
require_relative 'game'

class HumanPlayer
  attr_reader :name, :game, :board, :display, :color

  def initialize(name, game, color)
    @name = name
    @game = game
    @board = game.board
    @display = game.display
    @color = color
  end

  def handle_cheating
    return if display.cursor.move_buffer.empty?
    pos = display.cursor.move_buffer.first
    if self.board[pos].color != self.color
      puts "You can't move that!"
      sleep(0.5)
      display.cursor.move_buffer.pop
    end
  end

  def make_move
    while game.turn == self.color && !game.game_over?

    game.render
    display.cursor.get_input
    self.handle_cheating

      if display.cursor.move_buffer.length == 2
        start, dest = display.cursor.move_buffer
        if board.is_valid_move?(start,dest)
           board.move_piece(start,dest)
           board[dest].has_moved = true
           display.cursor.move_buffer = []
           self.color == :white ? game.turn = :black : game.turn = :white
        else
          display.cursor.move_buffer = []
        end
      end
    end
  end

end
