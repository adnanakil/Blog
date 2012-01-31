class SessionsController < ApplicationController
  def new
    @page_title = 'Sign in'
  end
  
  def create
    email = params[:session][:email]
    password = params[:session][:password]
    user = User.authenticate(email, password)
    
    if user.nil?
      flash.now[:error] = "Invalid email/password combination."
      @page_title = 'Sign in'
      render :new
    else
      sign_in user
      redirect_back_or root_path
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
end
