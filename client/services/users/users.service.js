angular.module('probedock.users').factory('users', function(api, auth, eventUtils, $rootScope) {

  var service = eventUtils.service({

    getUser: function(id) {
      return api.getResource(id, '/users').then(function(res) {
        return res.data;
      });
    },

    updateUser: function(user) {
      return api.patchResource(user, '/users').then(function(updatedUser) {

        if (auth.currentUser && updatedUser.id == auth.currentUser.id) {
          auth.updateCurrentUser(updatedUser);
        }

        service.emit('update', updatedUser);

        return updatedUser;
      });
    },

    deleteUser: function(user) {
      return api.deleteResource(user, '/users');
    }
  });

  return service;
});
