app.factory('Message', ["$http", function($http){

  var msg = {};

  msg.sendNoty = function (notyType, notyMessage) {
    noty({
      layout: 'center',
      text: notyMessage,
      type: notyType,
      timeout: 5000,
      closeWith: ['click']
    })
  }

  return msg;

}]);