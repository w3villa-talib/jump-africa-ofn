angular.module('Darkswarm').controller "CartCtrl", ($scope, Cart, CurrentHub, $http) ->
  $scope.Cart = Cart

  $scope.CurrentHub = CurrentHub
  $scope.max_characters = 20
  $scope.rate = localStorage.getItem("rate") || 1
  $scope.total = Cart.total() 
  $scope.symbol = localStorage.getItem("symbol") || "$"
  $scope.b_cur =  'usd'
  $scope.t_cur = ''

  $scope.items = [{
    index: 0,  
    id: 1,
    label: 'usd',
  },{
    index: 1,
    id: 2,
    label: 'ngn',
  },{
    index: 2,
    id: 3,
    label: 'eur',
  },{
    index: 3,
    id: 4,
    label: 'gbp',
  },{
    index: 4,
    id: 5,
    label: 'ghs',
  },{
    index: 5,
    id: 6,
    label: 'kes',
  }];

  $scope.selected = $scope.items[localStorage.getItem("currency")];

  $scope.currency = () ->
    $scope.total = Cart.total()
    $http.get("http://147.182.140.137:81/api/v1/currency_conversion?b_cur=usd&&t_cur=#{$scope.selected.label}").then (response) ->
      console.log(response.data)
      console.log($scope.selected)
      localStorage.setItem("currency",$scope.selected.index);
      localStorage.setItem("rate",response.data.rate);
      localStorage.setItem("symbol",response.data.symbol);
      console.log(localStorage.getItem("currency"))
      $scope.rate = response.data.rate
      $scope.symbol = response.data.symbol
      $scope.total = Math.round($scope.total * response.data.rate)

    .catch (response)=>
      Messages.flash({error: response.data.error})  