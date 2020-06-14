class BoardsController < ApplicationController
  permits :title

  # GET /boards
  def index
    @boards = Board.all
  end

  # GET /boards/1
  def show(id)
    @board = Board.find(id)
  end

  # GET /boards/new
  def new
    @board = Board.new
  end

  # GET /boards/1/edit
  def edit(id)
    @board = Board.find(id)
  end

  # POST /boards
  def create(board)
    @board = Board.new(board)

    if @board.save
      redirect_to @board, notice: 'Board was successfully created.'
    else
      render :new
    end
  end

  # PUT /boards/1
  def update(id, board)
    @board = Board.find(id)

    if @board.update(board)
      redirect_to @board, notice: 'Board was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /boards/1
  def destroy(id)
    @board = Board.find(id)
    @board.destroy

    redirect_to boards_url, notice: 'Board was successfully destroyed.'
  end
end
