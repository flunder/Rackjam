class BrandsController < ApplicationController

  respond_to :html, :js, :mobile
  
  def index
    @brands = Brand.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @brands }
    end
  end

  def show
    # Brand-data
    @brand = Brand.find_by_permalink(params[:id])
    
    # Item-data
    @brandName = params[:id]
    @getItems = Item.tagged_with(@brandName) if @brandName and @brandName != 'all'  
    @items = @getItems.order("updated_at DESC").paginate :page => params[:page]
    
    respond_with @items
  end

  def new
    @brand = Brand.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @brand }
    end
  end

  def edit
    @brand = Brand.find_by_permalink(params[:id])
  end

  def create
    @brand = Brand.new(params[:brand])

    respond_to do |format|
      if @brand.save
        format.html { redirect_to(@brand, :notice => 'Brand was successfully created.') }
        format.xml  { render :xml => @brand, :status => :created, :location => @brand }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @brand.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @brand = Brand.find_by_permalink(params[:id])

    respond_to do |format|
      if @brand.update_attributes(params[:brand])
        format.html { redirect_to(@brand, :notice => 'Brand was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @brand.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @brand = Brand.find_by_permalink(params[:id])
    @brand.destroy

    respond_to do |format|
      format.html { redirect_to(brands_url) }
      format.xml  { head :ok }
    end
  end
end
