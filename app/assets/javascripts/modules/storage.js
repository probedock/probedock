angular.module('probe-dock.storage', ['angular-storage'])

  .service('appStore', function(store) {
    return store.getNamespacedStore('probe-dock');
  })

;
