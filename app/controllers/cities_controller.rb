#coding: utf-8 
class CitiesController < ApplicationController
  before_filter :authenticate_user!
  # GET /cities
  # GET /cities.json
  def index
    @cities = current_user.cities
 

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /cities/1
  # GET /cities/1.json
  def show
    @city = City.find(params[:id])
     @trainings = @city.get_training_status 

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /cities/new
  # GET /cities/new.json
  def new
    if current_user.cities.count>=10
        redirect_to "/cities", notice: '城池创建失败，最多只能10座城池。' 
       return false
    end

    @city = City.new
   
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /cities/1/edit
  def edit
    @city = City.find(params[:id])
  end

  # POST /cities
  # POST /cities.json
  def create
    @city = City.new(params[:city])
    
    respond_to do |format|
      if @city.save
        current_user.cities<<@city

        format.html { redirect_to @city, notice: '城池创建成功。' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /cities/1
  # PUT /cities/1.json
  def update
    @city = City.find(params[:id])
    current_user.cities.each {|city| city.capital=false;city.save } if params[:city][:capital]
    respond_to do |format|
      if @city.update_attributes(params[:city])
        format.html { redirect_to @city, notice: '城池更新成功。' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /cities/1
  # DELETE /cities/1.json
  def destroy
    @city = City.find(params[:id])
    @city.destroy

    respond_to do |format|
      format.html { redirect_to cities_url }
    end
  end

  def get_food
    current_user.cities.each{|city| city.get_food_num()}

    redirect_to ("/cities")
  end

  def get_population
    current_user.cities.each{|city| city.get_population()}
    redirect_to ("/cities")

  end

  def get_gold
     current_user.cities.each{|city| city.get_gold_num()}
    redirect_to ("/cities")
  end

  def join_training
    @city=City.find(params[:city_id])
    if @city.join_training(params[:armtype],params[:soldiersnum])
      redirect_to @city,:notice=>"成功加入训练队列。"
    else
      redirect_to @city,:notice=>"加入训练队列失败。"
    end
  end
  
  def querytrain_ajax
     @city=City.find(params[:id])
     @trainings = @city.get_training_status 
  end

  def finished_arm
    @city=City.find(params[:city])


    @city.finished_train_arm(   "#{params[:armtype]},#{params[:num]},#{params[:time]}"
)
    respond_to do |format|
      format.js
    end

  end

  def cancel_arm
    @city=City.find(params[:city])
    @city.cancel_train_arm("#{params[:armtype]},#{params[:num]},#{params[:time]}"
)

    respond_to do |format|
      format.js
    end

  end
end
