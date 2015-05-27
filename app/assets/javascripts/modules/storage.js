angular.module('probedock.storage', ['angular-storage'])

  .service('appStore', function(store) {
    return store.getNamespacedStore('probedock');
  })

;
