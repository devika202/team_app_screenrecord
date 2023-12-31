class BehaviorLogsController < ApplicationController
  before_action :set_user, only: [:index, :clear_all_logs, :url_visits_table]
  before_action :authenticate_user!

  def index
    @user = User.find(params[:user_id])
    user_behaviors = UserBehavior.where(user_id: @user.id).order(timestamp: :desc)  
    @visited_urls = []

    user_behaviors.each_with_index do |behavior, index|
      url = behavior.page_name
      timestamp = behavior.timestamp.in_time_zone('Asia/Kolkata') 

      if index > 0
        previous_timestamp = user_behaviors[index - 1].timestamp
        time_spent = (previous_timestamp - timestamp).to_i  
        formatted_time_spent = format_time(time_spent)
        @visited_urls << { url: url, timestamp: timestamp, time_spent: formatted_time_spent }
      else
        @visited_urls << { url: url, timestamp: timestamp, time_spent: nil }
      end
    end
    @url_visits_chart_data = user_behaviors.group_by { |b| b.page_name }
    .transform_values(&:count)
  end
  
  def clear_all_logs
    @user.user_behaviors.delete_all
    redirect_to user_behavior_logs_path(@user), notice: "All logs have been cleared."
  end
  def url_visits_table
    @user = User.find(params[:user_id])
    user_behaviors = UserBehavior.where(user_id: @user.id).order(timestamp: :desc)
    grouped_behaviors = user_behaviors.group_by(&:page_name)
    
    @visited_urls = []
  
    grouped_behaviors.each do |page_name, behaviors|
      total_time_spent = 0
    
      behaviors.each_with_index do |behavior, index|
        timestamp = behavior.timestamp
  
        if index > 0
          previous_timestamp = behaviors[index - 1].timestamp
          time_spent = (previous_timestamp - timestamp).to_i
          total_time_spent += time_spent
        end
      end
  
      formatted_total_time_spent = format_time(total_time_spent)
      @visited_urls << { page_name: page_name, total_time_spent: formatted_total_time_spent }
    end
  
    render 'url_visits_table'
  end
  

  private

  def set_user
    @user = User.find(params[:user_id])
  end
  
  def format_time(seconds)
    if seconds < 60
      "#{seconds} seconds"
    elsif seconds < 3600
      "#{seconds / 60} minutes"
    else
      "#{seconds / 3600} hours"
    end
  end
end
