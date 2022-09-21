# frozen_string_literal: true

require 'spree/core/controller_helpers/order'
require 'open_food_network/tag_rule_applicator'

class BaseController < ApplicationController
  layout 'darkswarm'

  include Spree::Core::ControllerHelpers::Order

  include I18nHelper
  include OrderCyclesHelper
  require 'faraday'

  before_action :set_locale
  # before_action :redirect_to_jump_africa
  before_action :logout_from_jumpAfricaApp
  before_action :set_account_summary

  private

  def redirect_to_jump_africa
    if !spree_current_user
      redirect_to "#{ENV["JUMP_AFRICA_APP_URL"]}/signin"
    end
  end  

  def logout_from_jumpAfricaApp
    if spree_current_user.present?
      if spree_current_user.logout_from_jumpAfrica?
        @shopfront_redirect = session[:shopfront_redirect] 
        sign_out(spree_current_user)
        session.clear
        # redirect_to_jump_africa
      end
    end  
  end  

  def set_order_cycles
    unless @distributor.ready_for_checkout?
      @order_cycles = OrderCycle.where('false')
      return
    end

    @order_cycles = Shop::OrderCyclesList.new(@distributor, current_customer).call

    set_order_cycle
  end

  def set_account_summary
    if spree_current_user
     response = Faraday.get "#{ENV["JUMP_AFRICA_APP_URL"]}/api/v1/account",{userId: session[:jumpAfrica_user_id]},{token: session[:jwt_token]}
     response = JSON.parse(response.body)
     @account_summary = response['account_summary']
     @user_account = response["user"]
     @current_market = response['current_market']
    end 
  end  

  # Default to the only order cycle if there's only one
  #
  # Here we need to use @order_cycles.size not @order_cycles.count
  #   because OrderCyclesList returns a modified ActiveRecord::Relation
  #     and these modifications are not seen if it is reloaded with count
  def set_order_cycle
    return if @order_cycles.size != 1

    current_order(true).set_order_cycle! @order_cycles.first
  end
end
