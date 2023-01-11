angular.module('Darkswarm').controller "BillingCtrl", ($scope, $timeout, $controller, $http) ->
  angular.extend this, $controller('FieldsetMixin', {$scope: $scope})

  $scope.name = "billing"
  $scope.nextPanel = "shipping"

  if !$scope.order.bill_address.address1 
    $http.defaults.headers.common['Access-Control-Allow-Origin'] = '*'
    $http.defaults.headers.common['token'] = localStorage.getItem("jwt_token")
    $http.get('http://192.34.60.159:81/api/v1/profile/user_address_info?userId='+localStorage.getItem("jumpAfrica_user_id")).then (response) ->
      console.log $scope.order.bill_address
      $scope.order.bill_address.address1 = response.data.data.address 
      $scope.order.bill_address.city = response.data.data.city
      $scope.order.bill_address.zipcode = response.data.data.zipcode
      $scope.order.bill_address.phone = response.data.data.phone_number
      return   
   
    

  $scope.summary = ->
    [$scope.order.bill_address.address1,
    $scope.order.bill_address.city,
    $scope.order.bill_address.zipcode]

  $timeout $scope.onTimeout
