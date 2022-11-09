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
end
