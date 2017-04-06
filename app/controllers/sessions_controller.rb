class SessionsController < ApplicationController
  def new
  end
  def create
    # use instance variable (@user) so that it is available in
    # user login integration test using assigns(:user). This is necessary to 
    # verify remember_token is stored properly in cookies
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        log_in @user
        if (params[:session][:remember_me] == '1')
          remember @user
        else
          forget @user
        end
        flash[:success] = "Welcome back to the sample app!"
        redirect_back_or @user
      else
        message = "Account not activated. "
        message += "Check your email for activation link."
        flash.now[:danger] = message
        render 'new'
      end
    else
      flash.now[:danger] = 'Invalid email/password combination provided'
      render 'new'
    end
  end
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
  
end
