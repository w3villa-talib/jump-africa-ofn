# frozen_string_literal: true

class HomeController < BaseController
  layout 'darkswarm'
  require 'faraday'
  before_action :users_count


  def index
    if ContentConfig.home_show_stats
      @num_distributors = cached_count('distributors', Enterprise.is_distributor.activated.visible)
      @num_producers = cached_count('producers', Enterprise.is_primary_producer.activated.visible)
      @num_orders = cached_count('orders', Spree::Order.complete)
      # @num_users = @all_users_count
      @num_users = @all_users_count
    end
  end

  def users_count
    begin
      request = Faraday.get ("#{ENV["JUMP_AFRICA_APP_URL"]}/api/v1/portal_info")
      if request.status == 200
        response = JSON.parse(request.body)
        @all_users_count = response["data"]
      else
        @all_users_count = 0
      end
    rescue Faraday::ConnectionFailed => e
      puts e.to_s
      @all_users_count = 0
    end
  end  

  def sell; end

  def unauthorized
    render 'shared/unauthorized', status: :unauthorized
  end

  private

  # Cache the value of the query count
  def cached_count(statistic, query)
    CacheService.home_stats(statistic) do
      query.count
    end
  end
end
