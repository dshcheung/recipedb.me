app.factory('UserServices', ["$http", function($http){
  var user = {};

  user.status = false;
  user.username = "";

  return user;
}])