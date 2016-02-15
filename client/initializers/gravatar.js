angular.module('probedock').config(function(gravatarServiceProvider) {
  gravatarServiceProvider.defaults = {
     // Use auto-generated identicons (based on the e-mail) for users not registered on gravatar
    default: 'identicon'
  };
});
