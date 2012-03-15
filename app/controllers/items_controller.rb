class ItemsController < ApplicationController

  before_filter :get_view
  respond_to :html, :js, :mobile

  def index
    
    # Selection by type
    if params[:type] 
      @getItems = Item.type(params[:type])
    else 
      @getItems = Item.hasimage.within(10.days.ago)      
    end
    
    # Search
    if params[:search] 
      @getItems = @getItems.search(params[:search])     
    end   
    
    @getItems = Item.tagged_with(params[:brand]) if params[:brand] and params[:brand] != 'all'   # Selection by Brand 
    @items = @getItems.order("updated_at DESC").paginate :page => params[:page]                  # Paginate

    # Convert paths like ?search= to /search/
    @uri = request.fullpath
    if @uri.include? "?search="
        redirect_to '/search/' << @uri.gsub("+","%20")[@uri.index('?search=')+8..100] # replace +'s with spaces and redirect
    elsif @uri.include? "?brand="  
        redirect_to '/brand/' << @uri.gsub("+","%20")[@uri.index('?brand=')+7..100]   # to a better seo uri
    else
      respond_with @items
    end

  end
  
  def top
    # Show the hottest items
    @getItems = Item.hasimage.within(10.days.ago).joins(:interest).order('interests.item_count DESC')
    @items = @getItems.paginate :page => params[:page]  
    render "items/index"
  end

  def show
    @item = Item.find(params[:id])
    respond_with @item
  end

  def new
    @item = Item.new
    respond_with(@item)  
  end

  def edit
    @item = Item.find(params[:id])
  end

  def create
    @item = Item.new(params[:item])
    if @item.save
      flash[:notice] = "Item was successfully updated."
    end
    respond_with(@item)
  end

  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(params[:item])
      flash[:notice] = "Item was successfully updated."
    end
    respond_with(@item)
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    respond_with(@item)
  end
  
  def get
    # Gets items from a site and loads them into the db
    Item.get();
    render :nothing => true
  end
  
  def getone
    Item.getone(params[:url]);
    render :nothing => true
  end
 
  def categorize
    Item.categorize(params[:id]);
    render :nothing => true
  end 
  
  def getFromScrapedad
    Item.get_from_scrapedad
    render :nothing => true
  end
  
  def feed
    @title = "Rackjam feed" # this will be the name of the feed displayed on the feed reader
    @feed_items = Item.all(:limit => 50, :order => 'id desc')
    
    respond_to do |format|
      format.atom { render :layout => false }
      format.rss { redirect_to feed_path(:format => :atom), :status => :moved_permanently } # we want the RSS feeATOM feed
    end
  end
  
  def debug
    #Item.get();
  end
    
end
