class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :admin_only, except: [:index, :show, :teams]
    before_action :authorize_manager, only: [:team_assignment, :assign_team]
    before_action :admin_only, only: [:update_role]

    def index
        @users = User.all
    end

    def teams
        @user = User.find(params[:id])
        @teams = @user.teams
    end

    def new
      @user = User.new
    end

    def teams
      @user = User.find(params[:id])
      @teams = @user.teams
    end

    def team_assignment
      @user = User.find(params[:id])
      @teams = Team.all
    end

    def assign_team
        @user = User.find(params[:id])
        @user.teams << Team.find(params[:user][:team_id]) if params[:user][:team_id].present?
        redirect_to @user, notice: 'User was successfully assigned to the team.'
    end

    def update
      if @user.update(user_params)
          flash[:notice] = "Your account information was successfully updated"
          redirect_to @user
      else
          render 'edit'
      end
  end

  def create
      @user =User.new(user_params)
      if @user.save
          session[:user_id] = @user.id
          flash[:notice] = "Welcome to Team Manager #{@user.name},You have successfully signed up"
          redirect_to root_path
      else
          render 'new'
      end   
  end

  def destroy
    @user = User.find(params[:id])

    if current_user.admin? || current_user == @user
      @user.destroy
      session[:user_id] = nil if current_user == @user
      flash[:notice] = "Account successfully deleted"
      redirect_to root_path
    else
      redirect_to root_path, alert: "Access denied. You are not authorized to delete this account."
    end
  end
  
  def update_role
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_path, notice: "User role updated successfully."
    else
      redirect_to users_path, alert: "Failed to update user role."
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation, :role)
  end
  
   
    def admin_only
        redirect_to root_path, alert: 'Access denied.' unless current_user.admin?
    end

    def authorize_manager
      return if current_user.admin? || (current_user.manager? && current_user == User.find(params[:id]))
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
end
  