# frozen_string_literal: true

module Spree
  class UsersController < ::BaseController
    include Spree::Core::ControllerHelpers
    include I18nHelper
    include CablecarResponses
    require 'faraday'

    layout 'darkswarm'

    skip_before_action :set_current_order, only: :show
    prepend_before_action :load_object, only: [:show, :edit, :update]
    prepend_before_action :authorize_actions, only: :new

    before_action :set_locale

    def show
      @payments_requiring_action = PaymentsRequiringAction.new(spree_current_user).query
      @orders = orders_collection.includes(:line_items)

      customers = spree_current_user.customers
      @shops = Enterprise
        .where(id: @orders.pluck(:distributor_id).uniq | customers.pluck(:enterprise_id))

      @unconfirmed_email = spree_current_user.unconfirmed_email
      redirect_to main_app.root_path if params[:secret_key]
    end

    # Endpoint for queries to check if a user is already registered
    def registered_email
      registered = Spree::User.find_by(email: params[:email]).present?

      if registered
        render status: :ok, operations: cable_car.
          inner_html(
            "#login-feedback",
            partial("layouts/alert", locals: { type: "alert", message: t('devise.failure.already_registered') })
          ).
          dispatch_event(name: "login:modal:open")
      else
        head :not_found
      end
    end

    def create user_params, is_admin, userId, data
      @user = Spree::User.find_by_email(user_params[:email])
      if @user
        sign_in(@user, event: :authentication)
        @user.update(logout_from_jumpAfrica: false, parent_id: userId, parent_is_verifiy: data['user_verfication'], parent_default_image: data['default_image'], parent_member_image: data['member_image_url'])
      else
        @user = Spree::User.new(user_params)
        @user.skip_confirmation!
        if @user.save(validate: false)
          @user.update(spree_role_ids: 1) if is_admin  
          @user.update(parent_is_verifiy: data['user_verfication'], parent_default_image: data['default_image'], parent_member_image: data['member_image_url'])
          @user.confirm
          sign_in(@user, event: :authentication)
        else
          render :new
        end
      end
    end

    def update
      if @user.update(user_params)
        if params[:user][:password].present?
          # this logic needed b/c devise wants to log us out after password changes
          Spree::User.reset_password_by_token(params[:user])
          bypass_sign_in(@user)
        end
        redirect_to spree.account_url, notice: Spree.t(:account_updated)
      else
        render :edit
      end
    end

    private

    def orders_collection
      CompleteOrdersWithBalance.new(@user).query
    end

    def load_object
      @user ||= spree_current_user
      if @user
        request = Faraday.get "#{ENV["JUMP_AFRICA_APP_URL"]}/api/v1/profile",{userId: params[:user_id]},{token: params[:secret_key]}
        if request.status == 200
          response = JSON.parse(request.body)
          @user.update(parent_is_verifiy: response['data']['user_verfication'], parent_default_image: response['data']['default_image'], parent_member_image: response['data']['member_image_url'])
        end
        authorize! params[:action].to_sym, @user
        redirect_to main_app.root_path if params[:secret_key]
      else
        # faraday get request with headers
        response = Faraday.get "#{ENV["JUMP_AFRICA_APP_URL"]}/api/v1/profile",{userId: params[:user_id]},{token: params[:secret_key]}
        if response.status == 200
          response = JSON.parse(response.body)
          # create params for user email
          user_params = {email: response['data']['email']}
          userId = params[:user_id]
          is_admin =  response['isAdmin']
          # create user
          if response['auth'] == true
            session[:jwt_token] = params[:secret_key]
            session[:jumpAfrica_user_id] = response['data']['id']

            create(user_params,is_admin,userId, response['data'])
          else
            #  redirect to localhost:3000/login
            redirect_to "#{ENV["JUMP_AFRICA_APP_URL"]}/signin"
          end
        end
      end
    end

    def authorize_actions
      authorize! params[:action].to_sym, Spree::User.new
    end

    def accurate_title
      Spree.t(:my_account)
    end

    def user_params
      ::PermittedAttributes::User.new(params).call
    end
  end
end
