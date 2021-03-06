#coding: utf-8 
class PlayersController < ApplicationController

  def index
    @players=User.all
    @user=User.new
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cities }
    end 
  end

  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        @city=City.new(:name=>"首城",:capital=>true )
        @user.cities<<@city

        format.html { redirect_to "/register", notice: '玩家创建成功！' }
      else
        format.html { redirect_to "/register",notice:'玩家创建失败!' }
      end
    end

  end

  def destroy
    @user=User.find(params[:id])
    @user.destroy()
    redirect_to "/register",notice:'删除成功。'
  end
  
  def cities_ajax
    @user=User.find params[:id]
    @cities=@user.cities.map {|city| [city.name,city.id]}
  end

end
