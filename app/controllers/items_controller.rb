class ItemsController < ApplicationController

  before_filter :get_view
  respond_to :js, :html, :json, :iphone

  def index
    # Selection by type
    if params[:type] 
      @getItems = Item.type(params[:type])
    else 
      @getItems = Item.hasimage.within(10.days.ago)         
    end
    @getItems = Item.tagged_with(params[:brand]) if params[:brand] and params[:brand] != 'all'   # Selection by Brand
    @items = @getItems.paginate :page => params[:page]                                           # Paginate

    respond_with @items
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
 
  def categorize
    Item.categorize(params[:id]);
    render :nothing => true
  end 
  
  def feed
    @title = "Rackjam feed" # this will be the name of the feed displayed on the feed reader
    @feed_items = Item.all(:limit => 30)
    
    respond_to do |format|
      format.atom { render :layout => false }
      format.rss { redirect_to feed_path(:format => :atom), :status => :moved_permanently } # we want the RSS feed to redirect permanently to the ATOM feed
    end
  end
    
  def get_view
    
    if params[:view]
      @view = params[:view]
      cookies[:view] = { :value => @view, :expires => 24.hours.from_now }
    else
      # Get view from cookie    
      if cookies[:view] 
        @view = cookies[:view] 
      else
        cookies[:view] = { :value => "grid", :expires => 24.hours.from_now }
      end
    end    
    
    @view ||= 'grid'
  end  
  
  def debug
    #Item.get();
  end
    
end
