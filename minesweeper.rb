#!/usr/bin/env ruby

class Square
  attr :x
  attr :y
  attr :marker, true
  attr :transparent, true
  
  def initialize(x,y,marker,transparent=false)
    @x,@y,@marker,@transparent = x,y,marker,transparent
  end

  def draw(canvas)
    unless @transparent 
      canvas[@x][@y] = @marker
    end
  end
end

class Board
  attr :squares
  attr :height
  attr :weight

  def initialize(width, height, defaultMarker)
    @width,@height = width, height
    
    @squares = []
    @width.times do |x|
      column = []
      @height.times do |y|
        column << Square.new(x,y,defaultMarker)
      end
      @squares << column
    end
  end
  
  def draw(canvas)
    @squares.each do |column|
      column.each do |square|
        square.draw(canvas)
      end
    end
  end
  
  def move(x,y)
  end
end

class MineBoard < Board
  MINE_MARKER = "*" 
  EMPTY_MARKER = "."
  EXPLODED_MARKER = "X"
  
  def initialize(width, height, mines)
    super(width, height, EMPTY_MARKER)
    @mines = mines
    @mines.each do |mine|
      x,y = mine
      @squares[x][y] = Square.new(x,y,MINE_MARKER)
    end
    
    @width.times do |x|
      @height.times do |y|
        square = @squares[x][y]
        unless square.marker == MINE_MARKER
          numAdjacentMines = getNumberAdjacentMines(square)
          if numAdjacentMines > 0
            square.marker = String(numAdjacentMines)
          end
        end
      end
    end
  end
  
  def isAdjacent(square, mine)
    x = (square.x - mine[0]).abs
    y = (square.y - mine[1]).abs
    if x < 2 and y < 2
      true
    else
      false
    end
  end
  
  def getNumberAdjacentMines(square)
    adjacentMines = 0
    @mines.each do |mine|
      if isAdjacent(square, mine)
        adjacentMines += 1
      end
    end
    adjacentMines
  end
  
  def move(x,y)
    if @squares[x][y].marker == MINE_MARKER
      @squares[x][y].marker = EXPLODED_MARKER
      raise "Mine exploded!"
    end
  end
  
  def isMine(x,y)
    @squares[x][y].marker == MINE_MARKER
  end
end

class KnownBoard < Board
  UNKNOWN_MARKER = "U"
  KNOWN_MARKER = "K"
  FLAG_MARKER = "F"
  
  def initialize(width, height)
    super(width, height, UNKNOWN_MARKER)
  end
  
  def move(x,y) 
    square = @squares[x][y]
    if square.marker == UNKNOWN_MARKER
      square.marker = KNOWN_MARKER
      square.transparent = true
    end
  end
  
  def isUnknown(x,y)
    @squares[x][y].marker == UNKNOWN_MARKER
  end
end
    
    
class Minesweeper
  
  def initialize(width, height, mines)
    @width = width
    @height = height
    @mines = mines
  end

  def setup()
    @mineBoard = MineBoard.new(@width, @height, @mines)
    @knownBoard = KnownBoard.new(@width, @height)
  end
  
  def draw()
    canvas = []
    column = Array.new(@height)
    @width.times do
      canvas << Array.new(column)
    end
    
    @mineBoard.draw(canvas)
    @knownBoard.draw(canvas)
    
    @height.times do |y|
      @width.times do |x|
        print canvas[x][y]
      end
      puts
    end
  end
  
  def move()
    x,y = gets.split()
    x,y = Integer(x), Integer(y)
    @knownBoard.move(x,y)
    @mineBoard.move(x,y)
  end
  
  def checkWin()
    @width.times do |x|
      @height.times do |y|
        if @knownBoard.isUnknown(x,y) and not @mineBoard.isMine(x,y)
          return false
        end
      end
    end
    return true
  end
  
  def run()
    running = true
    setup()
    while (running)
      draw()
      begin
        move()
      rescue StandardError => err
        puts err
        running = false
      end
      if checkWin()
        running = false
        puts "All mines cleared!"
      end
    end
    draw()
  end
end

class RandomMinesweeper < Minesweeper
  def initialize(width, height, numMines)
    mines = []
    numMines.times do 
      mine = nil 
      while not mine
        mine = [rand(width), rand(height)]
        if mines.include?(mine)
          mine = nil
        else
          mines << mine
        end
      end
    end
    super(width, height, mines)
  end
end

minesweeper = RandomMinesweeper.new(3,3,1)
minesweeper.run()
