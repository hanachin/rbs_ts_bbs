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
  def create(title)
    @board = Board.new
    @board.title = title

    if @board.save
      render json: { id: @board.id, message: 'Board was successfully created.' }
    else
      render json: @board.errors.full_messages.to_json
    end
  end

  # PUT /boards/1
  def update(id, title)
    @board = Board.find(id)
    @board.title = title

    if @board.save
      render json: { id: @board.id, message: 'Board was successfully updated.' }
    else
      render json: @board.errors.full_messages.to_json
    end
  end

  # DELETE /boards/1
  def destroy(id)
    @board = Board.find(id)
    @board.destroy

    render json: { message: 'Board was successfully destroyed.' }
  end
end
