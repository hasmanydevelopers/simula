class ErrorsController < ApplicationController
  skip_before_filter :authenticate_user!
  def routing
   render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
end
