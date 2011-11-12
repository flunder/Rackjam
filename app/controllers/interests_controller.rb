class InterestsController < ApplicationController
  
  def index
     Interest.updateOne(params[:id]);
     render :nothing => true
   end
   
end
