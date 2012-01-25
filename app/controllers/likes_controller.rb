class LikesController < ApplicationController
  
  before_filter :authenticate_user!
  respond_to :js, :html, :json
  
  def index
    @likes = current_user.likes.all
    
    #select * from items where user = 1 
    
    respond_with @likes
  end

  def show
    @like = Like.find(params[:id])
    respond_with @like
  end

  def new
    @like = Like.new
 
    respond_with @like
  end

  def edit
    @like = Like.find(params[:id])
  end

  def create
    @like = Like.new(params[:like])

    if @like.save
      flash[:notice] = "Item was successfully created."
    end
    respond_with(@like)
  end

  def update
    @like = Like.find(params[:id])

    if @like.update_attributes(params[:like])
      flash[:notice] = "Item was successfully updated."
    end
    respond_with(@like)
  end

  def destroy
    @like = Like.find(params[:id])
    @like.destroy

    respond_to do |format|
      format.html { redirect_to(likes_url) }
      format.xml  { head :ok }
    end
  end
end
