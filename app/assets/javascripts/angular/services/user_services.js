app.factory('UserServices', ["$http", "$q", "$rootScope", function($http, $q, $rootScope){
  var user = {};

  user.status = false;
  user.username = "";
  user.userID = null;

  user.fromPage = "/search";

  user.main = {};
  user.resetMain = function(){
    user.main.activateSearch = false;
    user.main.freshSearch = false;
    user.main.search_parameters = {};
    user.main.search_parameters.categories = [];
    user.main.search_parameters.ingredients = [];
    user.main.search_parameters.keywords = [];
    user.main.search_parameters.timeframe = [0, 1440];
    user.main.search_parameters.page = 1;
    user.main.search_parameters.user = false;
    user.main.totalItems = 1;
    user.main.recipes = [];
  };
  user.resetMain();

  user.sub = {};
  user.resetSub = function(){
    user.sub.activateSearch = false;
    user.sub.freshSearch = false;
    user.sub.search_parameters = {};
    user.sub.search_parameters.categories = [];
    user.sub.search_parameters.ingredients = [];
    user.sub.search_parameters.keywords = [];
    user.sub.search_parameters.timeframe = [0, 1440];
    user.sub.search_parameters.page = 1;
    user.sub.search_parameters.user_id = true;
    user.sub.totalItems = 1;
    user.sub.recipes = [];
  };
  user.resetSub();

  // user.getCurrentUser = function() {
  //   return $q(function(resolve,reject){
  //     $http.get("/user/any").success(function(response,status){
  //        console.log('response from service', response);
  //       resolve(response);
  //     });
  //   });
  // };

  return user;
}])
