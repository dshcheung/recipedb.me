app.factory('Message', ["$http", function($http){

  var msg = {};

  msg.sendNoty = function (notyType, notyMessage) {
    noty({
      text: notyMessage,
      type: notyType
    })
  }

  return msg;

}]);