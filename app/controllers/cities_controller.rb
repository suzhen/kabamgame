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
        City.update_city_cache
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
        City.update_city_cache
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
    City.update_city_cache
    respond_to do |format|
      format.html { redirect_to cities_url }
    end
  end

  def get_food
    current_user.cities.each{|city| city.get_food_num(){|food|food-city.arm_waste_food()  }   }

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

  def queryarm_ajax
    @city=City.find(params[:id])
    @armcache=@city.get_arm_cache
  end

  def querywar_ajax
   @city=City.find(params[:id])
   @warcache=@city.get_war_list   
  end

  def querydefend_ajax
    @city=City.find(params[:id])
    @defendcache=@city.get_defend_list   
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

 def attack_city
    @city=City.find params[:start_city_id]
    if  !params[:attackcity].present?||!params[:arm_ids].present?
      redirect_to @city,:notice=>"攻击失败，缺少参数！"
    end

    arr_arm_id = params[:arm_ids].split(",")
    arr_arm = Arm.find(arr_arm_id.map{|id| id.to_i })

    if @city.start_war(params[:fighter],params[:attackcity],params[:arm_ids])
      arr_arm.each do |arm|
        arm.armstatus="attack"
        arm.save
      end
      @city.update_arm_cache
      redirect_to @city,:notice=>"开始攻击！"
    else
      redirect_to @city,:notice=>"攻击失败,外面部队不能大于5！"
    end
 end

 def fight_arm
    attack_city_id =  params[:key].split("_")[0]
    defend_city_id = params[:ref].split("_")[0]
    @attack_city=City.find attack_city_id
    @defend_city=City.find defend_city_id
    arm_ids=[]
    defend_arm_ids=@defend_city.arms.where("armstatus='nor'").map {|arm| arm.id.to_s}
    attack_arm_ids=params[:ids].split(",")
    arm_ids=defend_arm_ids+attack_arm_ids
   
    #p "战斗人员"+arm_ids.join(",")

    #开战,得到幸存人员
    survivei_arm_ids=Arm.black_box(arm_ids)
    attack_survivei_arm_ids=survivei_arm_ids&attack_arm_ids
    #p "幸存人员"+survivei_arm_ids.join(",")
    #p "攻方人员"+attack_arm_ids.join(",")
    #p "攻方幸存人员"+attack_survivei_arm_ids.join(",")
    #删除死亡士兵
    dead_arm_ids = arm_ids - survivei_arm_ids 
    #p "死亡士兵"+dead_arm_ids.join(",")
    allarmids = Arm.all.map{|arm| arm.id.to_s}
    dead_arm = Arm.find(allarmids&dead_arm_ids)
    dead_arm.each {|arm| arm.destroy }
    @attack_city.update_arm_cache
    @defend_city.update_arm_cache 
    @attack_city.finished_attack(params[:ref],attack_survivei_arm_ids.join(',')) 
    @defend_city.finished_defend(params[:key])
    respond_to do |format|
      format.js
    end
 end

 def back_city
    @city= City.find  params[:cityid]
    @city.back_city(params[:key])
    respond_to do |format|
      format.js
    end
 end


end
