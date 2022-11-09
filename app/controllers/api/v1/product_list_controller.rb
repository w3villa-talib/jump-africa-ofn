class Api::V1::ProductListController < ApplicationController
  def product_info
    info = []
    enterprise_info = Enterprise.all.joins(:supplied_products).distributors_with_active_order_cycles
    if enterprise_info
      enterprise_info.each do |enterprise|
        enterprise.supplied_products.limit(4).each do |supplied_products|
          if supplied_products.images.present?
            if supplied_products.images.first.attachment.attached?
              image = supplied_products.images.first.url(:small)
            end
          end
          unit_to_display = supplied_products.variants.first.unit_to_display
          price = supplied_products.variants.first.price.to_f
          data = supplied_products.attributes.merge(image_url: image, price: price, unit: unit_to_display, enterprise_info: enterprise)
          info.push(data)
        end
      end
      render json: {msg: "success", product_info: info, success: true}, status: 200
    else 
      render json: {error_message: "Product not found", success: true}, status: 404
    end
  end
end