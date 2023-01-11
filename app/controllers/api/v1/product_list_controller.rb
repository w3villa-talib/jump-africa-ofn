class Api::V1::ProductListController < ApplicationController
  def product_info
    info = []

    if params[:parent_id]
      enterprise_info = Spree::User.find_by(parent_id: params[:parent_id]).enterprises.select(:id, :name, :permalink, :address_id)
    else
      enterprise_info = Enterprise.includes(:supplied_products).distributors_with_active_order_cycles
    end

    if enterprise_info
      enterprise_info.each do |enterprise|
        country = enterprise&.address&.country&.name
        if params[:parent_id].present?
          logo_url = enterprise.logo.attached? ?  enterprise.logo_url(:thumb) : ""
          data = enterprise.attributes.merge(country: country, logo_url: logo_url, total_products: enterprise.supplied_products.count)
          info.push(data)
        else
          enterprise.supplied_products.each do |supplied_products|

            if supplied_products.images.present?
              if supplied_products.images.first.attachment.attached?
                image = supplied_products.images.first.url(:small)
              end
            end

            unit_to_display = supplied_products&.variants&.first.unit_to_display
            price = supplied_products&.variants&.first&.price.to_f
            data = supplied_products.attributes.merge(image_url: image, price: price, unit: unit_to_display, enterprise_info: enterprise.attributes.merge(country: country))
            info.push(data)
          end
        end
      end
      render json: {msg: "Success", product_info: info, success: true}, status: 200
    else 
      render json: {msg: "Product not found", product_info: info, success: true}, status: 404
    end
  end
end
