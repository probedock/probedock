angular.module('probedock.storage').service('appStore', function(store) {
  return store.getNamespacedStore('probedock');
});
