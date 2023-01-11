
allowd_countries = ['NG', 'GH', 'KE', 'ZA', 'ZW', 'ET', 'GB', 'US'] #these countries given by client
country_list = ISO3166::Country.all #get the list of countries

country_list.select do |country_detail|

  is_selected = allowd_countries.include?(country_detail.alpha2) ? true : false
  country = Spree::Country.where(iso: country_detail&.alpha2).find_or_create_by!(
    iso_name: country_detail&.iso_short_name,iso: country_detail&.alpha2, name: country_detail&.common_name, numcode: country_detail&.number.to_i, states_required: true, status: is_selected)
  
#get states related to country 
  state_list = country_detail.subdivisions.to_a
  state_list.select do |states|
    country.states.where(name: states&.last&.name).find_or_create_by!(abbr: states&.first, name: states&.last&.name)
  end
end
