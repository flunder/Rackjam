class BucketsController < ApplicationController

  def index
    @buckets = Bucket.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @buckets }
    end
  end

  def show
    @bucket = Bucket.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bucket }
    end
  end

  def new
    @bucket = Bucket.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bucket }
    end
  end

  def edit
    @bucket = Bucket.find(params[:id])
  end

  def create
    @bucket = Bucket.new(params[:bucket])

    respond_to do |format|
      if @bucket.save
        format.html { redirect_to @bucket, notice: 'Bucket was successfully created.' }
        format.json { render json: @bucket, status: :created, location: @bucket }
      else
        format.html { render action: "new" }
        format.json { render json: @bucket.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @bucket = Bucket.find(params[:id])

    respond_to do |format|
      if @bucket.update_attributes(params[:bucket])
        format.html { redirect_to @bucket, notice: 'Bucket was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @bucket.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @bucket = Bucket.find(params[:id])
    @bucket.destroy

    respond_to do |format|
      format.html { redirect_to buckets_url }
      format.json { head :ok }
    end
  end
end
