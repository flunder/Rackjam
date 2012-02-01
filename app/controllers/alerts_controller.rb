class AlertsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :get_view

  def index
    @alerts = current_user.alerts

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @alerts }
    end
  end

  def run
    @result =  Alert.runAlertsForUser(current_user.id); 
    @items = @result[0]
  end
  
  def checkid    
    Alert.checkId(params[:id])
    render :nothing => true
  end

  def checkalert    
    @itemId = params[:itemId]
    @userId = params[:userId]
    @alertId = params[:alertId]        

    Alert.checkAlert(@itemId, @userId, @alertId)
    render :nothing => true
  end

  def show
    @alert = Alert.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @alert }
    end
  end

  def new
    @alert = Alert.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @alert }
    end
  end

  def edit
    @alert = Alert.find(params[:id])
  end

  def create
    
    @alert = Alert.new(
      :user_id => current_user.id,
      :freetext => params[:alert][:freetext],
      :price => params[:alert][:price],
      :site => params[:alert][:site]
    )

    respond_to do |format|
      if @alert.save
        format.html { redirect_to @alert, notice: 'Alert was successfully created.' }
        format.json { render json: @alert, status: :created, location: @alert }
      else
        format.html { render action: "new" }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @alert = Alert.find(params[:id])

    respond_to do |format|
      if @alert.update_attributes(params[:alert])
        format.html { redirect_to @alert, notice: 'Alert was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @alert = Alert.find(params[:id])
    @alert.destroy

    respond_to do |format|
      format.html { redirect_to alerts_url }
      format.json { head :ok }
    end
  end
end
