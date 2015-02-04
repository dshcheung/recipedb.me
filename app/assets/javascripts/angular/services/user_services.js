app.factory('UserServices', ["$http", function($http){
  var user = {};

  user.status = false;
  user.username = "";
  user.userID = null;

  user.activateSearch = false;
  user.main = {};
  user.main.search_parameters = {};
  user.main.search_parameters.categories = [];
  user.main.search_parameters.keywords = [];
  user.main.search_parameters.timeframe = [0, 1440];
  user.main.page = null;

  return user;
}])