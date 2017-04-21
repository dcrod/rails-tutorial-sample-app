class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  def create
    @micropost = current_user.microposts.build(content: params[:content])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      render 'static_pages/home'
    end
  end
  
  def destroy
  end
  
  private
  
    # Strong params
    def micropost_params
      params.require(:micropost).permit(:content)
    end
end
