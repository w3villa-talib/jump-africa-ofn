class Api::V1::CustomController < ApplicationController
  def enterprise_info
    enterprise = Enterprise.find_by(id: "#{params[:enterprise_id]}")
    if enterprise
      user_info = enterprise.users.first
      render json: {msg: "success", user_info: user_info, enterprise: enterprise}, status: 200
    else 
      render json: {error_message: "record not found", auth: false}, status: 404
    end
  end

  def env_info
    env_site_url = "#{ENV["JUMP_AFRICA_APP_URL"]}"
    if env_site_url
      render json: {msg: "success", env_hostname: env_site_url, success: true }, status: 200
    else
      render json: { msg: "success", env_hostname: "https://jump.africa", success: true }, status: 200
    end
  end
end
