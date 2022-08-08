class Api::V1::SessionController < ApplicationController
    def logout
        user = Spree::User.find_by_email(params[:email])
        if user
          user.update(logout_from_jumpAfrica: true)
          render json: {msg: "success"}, status: 200
        else 
          render json: {error_message: "record not found", auth: false}, status: 404
        end   
       
    end
end
