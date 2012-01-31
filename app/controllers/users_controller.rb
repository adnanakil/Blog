class UsersController < ApplicationController
  # before_filter :authenticate, :only => [:index, :edit, :update]
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => :destroy
  before_filter :signed_out_user, :only => [:new, :create]
  
  def index
    @search = User.search(params[:search])
    @users = @search.all.paginate(:per_page => 2, :page => params[:page])
    
    @page_title = 'All users'
  end
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.all.paginate(:per_page => 2, :page => params[:page])
    
    @page_title = 'Profile'
  end
  
  def new
    @user = User.new
    
    @page_title = 'Sign up'
  end
  
  def create
    @user = User.new(params[:user])
    
    if @user.save
      sign_in @user
      flash[:success] = "Wlecome to you're Microblog, #{@user.name}!"
      redirect_to root_path
    else
      @page_title = 'Sign up'
      render :new
    end
  end
  
  def edit
    @page_title = 'Edit user'
  end
  
  def update
    @user = User.find(params[:id])
    
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to edit_user_path(@user)
    else
      @page_title = 'Edit user'
      render :edit
    end
  end
  
  def destroy
    user = User.find(params[:id])
    
    if user.admin?
      flash[:error] = "Admin user can't be deleted."
    else
      user.destroy
      flash[:success] = "User destroyed."
    end
    
    redirect_to users_path
  end
  
  # def following
    # @title = "Following"
    # @user = User.find(params[:id])
    # @users = @user.following.all.paginate(:per_page => 2, :page => params[:page])
    # render 'show_follow'
  # end

  # def followers
    # @title = "Followers"
    # @user = User.find(params[:id])
    # @users = @user.followers.all.paginate(:per_page => 2, :page => params[:page])
    # render 'show_follow'
  # end
  
  def following
    show_follow(:following)
  end

  def followers
    show_follow(:followers)
  end

  def show_follow(action)
    @title = action.to_s.capitalize
    @user = User.find(params[:id])
    @users = @user.send(action).all.paginate(:per_page => 2, :page => params[:page])
    render 'show_follow'
  end
  
  private
    def correct_user
      @user = User.find(params[:id])
      redirect_to root_path unless current_user?(@user)
    end
    
    def admin_user
      redirect_to root_path unless current_user.admin?
    end
    
    def signed_out_user
      redirect_to root_path if signed_in?
    end
end
