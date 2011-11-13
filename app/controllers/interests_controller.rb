class InterestsController < ApplicationController
  
  def index
     Interest.updateOne(params[:id],params[:value]);
     render :nothing => true
   end
   
end
