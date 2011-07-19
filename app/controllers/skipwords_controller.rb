class SkipwordsController < ApplicationController
  # GET /skipwords
  # GET /skipwords.xml
  def index
    @skipwords = Skipword.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @skipwords }
    end
  end

  # GET /skipwords/1
  # GET /skipwords/1.xml
  def show
    @skipword = Skipword.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @skipword }
    end
  end

  # GET /skipwords/new
  # GET /skipwords/new.xml
  def new
    @skipword = Skipword.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @skipword }
    end
  end

  # GET /skipwords/1/edit
  def edit
    @skipword = Skipword.find(params[:id])
  end

  # POST /skipwords
  # POST /skipwords.xml
  def create
    @skipword = Skipword.new(params[:skipword])

    respond_to do |format|
      if @skipword.save
        format.html { redirect_to(@skipword, :notice => 'Skipword was successfully created.') }
        format.xml  { render :xml => @skipword, :status => :created, :location => @skipword }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @skipword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /skipwords/1
  # PUT /skipwords/1.xml
  def update
    @skipword = Skipword.find(params[:id])

    respond_to do |format|
      if @skipword.update_attributes(params[:skipword])
        format.html { redirect_to(@skipword, :notice => 'Skipword was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @skipword.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /skipwords/1
  # DELETE /skipwords/1.xml
  def destroy
    @skipword = Skipword.find(params[:id])
    @skipword.destroy

    respond_to do |format|
      format.html { redirect_to(skipwords_url) }
      format.xml  { head :ok }
    end
  end
end
