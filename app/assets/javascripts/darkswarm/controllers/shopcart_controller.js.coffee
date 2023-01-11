angular.module('Darkswarm').controller "ShopcartCtrl", ($scope, Cart, CurrentHub, $http) ->
  $scope.Cart = Cart

  $scope.CurrentHub = CurrentHub
  $scope.max_characters = 20
  $scope.rate = localStorage.getItem("rate") || 1
  $scope.total = Cart.total()
  $scope.symbol = localStorage.getItem("symbol") || "$"
  $scope.balance = localStorage.getItem("balance") || localStorage.getItem("balance_first")
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
    $scope.total = Cart.total()

    # this api is to get current enviroment
    $http.get("/api/v1/custom/env_info").then (response) ->
      $scope.env_hostname = response.data.env_hostname
      $scope.user_id = response.data.user_id

      # this api is to get current currency rate
      $http.get("#{$scope.env_hostname}/api/v1/currency_conversion?b_cur=usd&&t_cur=#{$scope.selected.label}&currency_id=#{$scope.selected.currency_id}&user_id=#{$scope.user_id}").then (response) ->
        localStorage.setItem("currency",$scope.selected.index);
        localStorage.setItem("currency_id",$scope.selected.currency_id);
        localStorage.setItem("rate",response.data.rate);
        localStorage.setItem("symbol",response.data.symbol);
        localStorage.setItem("balance", response.data.balance);
        $scope.rate = response.data.rate
        $scope.symbol = response.data.symbol
        $scope.balance = response.data.balance
        $scope.total = Math.round($scope.total * response.data.rate);
        $scope.cart_total = localStorage.getItem("cart_total_amount")
        location.reload(true);
        # this code is for disabled checkout warning and button
        if ($scope.balance < ($scope.cart_total * $scope.rate))
          $('#checkout_form .button').prop('disabled', true);
          $('#checkout_form .text_red').addClass("d_block");
          $('#checkout_form .text_red').removeClass("d_none");
        else
          $('#checkout_form .button').prop('disabled', false);
          $('#checkout_form .text_red').removeClass("d_block");
          $('#checkout_form .text_red').addClass("d_none");

      .catch (response)=>
        Messages.flash({error: response.data.error}) 

    .catch (response)=>
      Messages.flash({error: response.data.error}) 