app.factory('UserServices', ["$http", function($http){
  var user = {};

  user.status = false;
  user.username = "";
  user.userID = null;

  user.activateSearch = false;
  user.main = {};
  user.resetMain = function(){
    user.main.search_parameters = {};
    user.main.search_parameters.categories = [];
    user.main.search_parameters.ingredients = [];
    user.main.search_parameters.keywords = [];
    user.main.search_parameters.timeframe = [0, 1440];
    user.main.recipes = [];
    user.main.totalItems = 1;
    user.main.page = 1;
  };
  user.resetMain();

  return user;
}])
