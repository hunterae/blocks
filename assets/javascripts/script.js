(function() {

  var app = angular.module('MainApp', ['ngAnimate']);

  app.controller('MainCtrl', function($scope) {

    $scope.CheckControlSize = function() {
      if ($scope.inputSize == 'frm-sm') {
        $scope.inputSize = 'sm';
      }
      if ($scope.inputSize == 'frm-lg') {
        $scope.inputSize = 'lg';
      }
    }

  });

}());