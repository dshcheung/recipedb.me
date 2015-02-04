app.factory('UserServices', ["$http", function($http){
  var user = {};

  user.status = false;
  user.username = "";
  user.userID = null;

  return user;
}])