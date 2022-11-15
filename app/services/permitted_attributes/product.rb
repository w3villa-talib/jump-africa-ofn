# frozen_string_literal: true

module PermittedAttributes
  class Product
    def self.attributes
      [
        :id, :name, :description, :supplier_id, :price, :permalink,
        :variant_unit, :variant_unit_scale, :unit_value, :unit_description, :variant_unit_name,
        :display_as, :sku, :available_on, :group_buy, :group_buy_unit_size,
        :taxon_ids, :primary_taxon_id, :tax_category_id, :shipping_category_id,
        :meta_keywords, :meta_description, :notes, :inherits_properties, :selected_currency,
        { product_properties_attributes: [:id, :property_name, :value],
          variants_attributes: [PermittedAttributes::Variant.attributes],
          images_attributes: [:attachment] }
      ]
    end
  end
end
