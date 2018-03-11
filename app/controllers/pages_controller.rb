class PagesController < ApplicationController  
  def index
    @jobs = if params[:search]
      Job.where('"jobId" LIKE UPPER(:search) OR UPPER(company) LIKE UPPER(:search) OR UPPER(position) LIKE UPPER(:search) OR UPPER(location) LIKE UPPER(:search)', :search => "%#{params[:search]}%").order('company ASC').paginate(page: params[:page], per_page: 10).order('created_at DESC')
    else
      Job.all.order('company ASC')
    end
    @newPosts = Post.new
    session[:return_to] = request.fullpath
  end

  def home
    @cas_user = session[:cas_user] # holds questID
    @newPosts = Post.new
    @myRankings = Ranking.all.where("user_id = ?", current_user.id)
    session[:return_to] = request.fullpath
  end

  def explore
    @jobs = Job.paginate(page: params[:page], per_page: 10).order('updated_at DESC')
    @newPosts = Post.new    
    respond_to do |format|
      format.js
      format.html
    end
    session[:return_to] = request.fullpath
  end

  def help
  end

  def profile
  	if (User.find_by_username(params[:id]))
  		@username = params[:id]
  	else
  		redirect_to root_path, :notice => "User not found!"
  	end

  	@posts = Post.all.where("user_id = ?", User.find_by_username(params[:id]))
    @rankings = Ranking.all.where("user_id = ?", User.find_by_username(params[:id]))
    @newPosts = Post.new
    session[:return_to] = request.fullpath
  end

  def autocompleteJobs
    @jobs = Job.where('UPPER(company) LIKE UPPER(:search)', :search => "%#{params[:term]}%").distinct.limit(10)
    render json: @jobs.map(&:company)
  end

  def autocompleteLocation
    @locations = Job.where('UPPER(location) LIKE UPPER(:search)', :search => "%#{params[:term]}%").distinct.limit(5)
    render json: @locations.map(&:location)
  end

  def autocompletePosition
    @positions = Job.select(:position).where('UPPER(position) LIKE UPPER(:search)', :search => "%#{params[:term]}%").distinct.limit(5)
    render json: @positions.map(&:position)
  end
end
