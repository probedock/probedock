angular.module('probedock').config(function(gravatarServiceProvider) {
  gravatarServiceProvider.defaults = {
    default: 'identicon' // Use retro style for auto-generated missing avatars
  };
});
