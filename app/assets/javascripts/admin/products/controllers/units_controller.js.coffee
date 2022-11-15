angular.module("admin.products")
  .controller "unitsCtrl", ($scope, VariantUnitManager, OptionValueNamer, UnitPrices, PriceParser, $http) ->
    $scope.product = { master: {} }
    $scope.product.master.product = $scope.product
    $scope.placeholder_text = ""

    $scope.$watchCollection '[product.variant_unit_with_scale, product.master.unit_value_with_description, product.price, product.variant_unit_name]', ->
      $scope.processVariantUnitWithScale()
      $scope.processUnitValueWithDescription()
      $scope.processUnitPrice()
      $scope.placeholder_text = new OptionValueNamer($scope.product.master).name() if $scope.product.variant_unit_scale

    $scope.variant_unit_options = VariantUnitManager.variantUnitOptions()

    $scope.rate = localStorage.getItem("rate") || 1
    $scope.symbol = localStorage.getItem("symbol") || "$"
    $scope.b_cur =  'usd'
    $scope.t_cur = ''

    $scope.items = [{
      index: 0,  
      id: 1,
      label: 'usd',
      currency_id: 3
    },{
      index: 1,
      id: 2,
      label: 'ngn',
      currency_id: 1
    },{
      index: 2,
      id: 3,
      label: 'eur',
      currency_id: 4
    },{
      index: 3,
      id: 4,
      label: 'gbp',
      currency_id: 5
    },{
      index: 4,
      id: 5,
      label: 'ghs',
      currency_id: 6
    },{
      index: 5,
      id: 6,
      label: 'kes',
      currency_id: 8
    }];

    $scope.selected = $scope.items[localStorage.getItem("currency")];

    $scope.currency = () ->
      # this api is to get current enviroment

      $http.get("/api/v1/custom/env_info").then (response) ->
        $scope.env_hostname = response.data.env_hostname

        # this api is to get current currency rate
        $http.get("#{$scope.env_hostname}/api/v1/currency_conversion?b_cur=usd&&t_cur=#{$scope.selected.label}&currency_id=&user_id=").then (response) ->
          localStorage.setItem("rate",response.data.rate);
          localStorage.setItem("label",$scope.selected.label);
          localStorage.setItem("symbol",response.data.symbol);
          $scope.rate = response.data.rate
          $scope.symbol = response.data.symbol
          $scope.label = $scope.selected.label

        .catch (response)=>
          Messages.flash({error: response.data.error})

      .catch (response)=>
        Messages.flash({error: response.data.error}) 


    $scope.processVariantUnitWithScale = ->
      if $scope.product.variant_unit_with_scale
        match = $scope.product.variant_unit_with_scale.match(/^([^_]+)_([\d\.]+)$/)
        if match
          $scope.product.variant_unit = match[1]
          $scope.product.variant_unit_scale = parseFloat(match[2])
        else
          $scope.product.variant_unit = $scope.product.variant_unit_with_scale
          $scope.product.variant_unit_scale = null
      else if $scope.product.variant_unit && $scope.product.variant_unit_scale
        $scope.product.variant_unit_with_scale = VariantUnitManager.getUnitWithScale($scope.product.variant_unit, parseFloat($scope.product.variant_unit_scale))
      else
        $scope.product.variant_unit = $scope.product.variant_unit_scale = null

    $scope.processUnitValueWithDescription = ->
      if $scope.product.master.hasOwnProperty("unit_value_with_description")
        match = $scope.product.master.unit_value_with_description.match(/^([\d\.,]+(?= *|$)|)( *)(.*)$/)
        if match
          $scope.product.master.unit_value  = PriceParser.parse(match[1])
          $scope.product.master.unit_value  = null if isNaN($scope.product.master.unit_value)
          $scope.product.master.unit_value *= $scope.product.variant_unit_scale if $scope.product.master.unit_value && $scope.product.variant_unit_scale
          $scope.product.master.unit_description = match[3]
      else
        value = $scope.product.master.unit_value
        value /= $scope.product.variant_unit_scale if $scope.product.master.unit_value && $scope.product.variant_unit_scale
        $scope.product.master.unit_value_with_description = value + " " + $scope.product.master.unit_description

    $scope.processUnitPrice = ->
      price = $scope.product.price
      scale = $scope.product.variant_unit_scale
      unit_type = $scope.product.variant_unit
      unit_value = $scope.product.master.unit_value
      variant_unit_name = $scope.product.variant_unit_name
      symbol = $scope.symbol
      rate = $scope.rate
      $scope.unit_price = UnitPrices.displayableUnitPrice(price, scale, unit_type, unit_value, variant_unit_name, symbol, rate)

    $scope.hasVariants = (product) ->
      Object.keys(product.variants).length > 0

    $scope.hasUnit = (product) ->
      product.variant_unit_with_scale?
