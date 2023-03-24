'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "favicon.png": "5dcef449791fa27946b3d35ad8803796",
"manifest.json": "b7af836488c18a2977727c75f941a75f",
"index.html": "cb030397c5e6be528b7ad21715cc19a2",
"/": "cb030397c5e6be528b7ad21715cc19a2",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/NOTICES": "b269f0821b1677ae5f81499f0f80d31f",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.json": "184e11c5edcb75a1c28fd00277ec85b2",
"assets/assets/images/4a.jpg": "039759d856f7cc8cd865bd26a9fc5837",
"assets/assets/images/5b.jpg": "894660ebca4c2e1a280bebba48a23835",
"assets/assets/images/12b.jpg": "fe2eda6a83da03b203631c6494639c10",
"assets/assets/images/9b.jpg": "b53320a109c4fb433862373b4cacf7d9",
"assets/assets/images/8b.jpg": "b6f919e9d5fcfea1be78f419d1054edf",
"assets/assets/images/1a.jpg": "cf49e93bae19431a2fe72e888ff6b7d3",
"assets/assets/images/4b.jpg": "84ab6c86e116a6e5946d87135d095118",
"assets/assets/images/5a.jpg": "fcf11595400f9d39196780db75313519",
"assets/assets/images/2b.jpg": "4e0166932db0f4a00b9426b5ae97f333",
"assets/assets/images/10b.jpg": "84e84933088f74a54a90c025527cfeba",
"assets/assets/images/3b.jpg": "919b974b29169ddc7f1286c71b1ff70c",
"assets/assets/images/1b.jpg": "7ae93da6e7097d98242fd01fbb65cf9c",
"assets/assets/images/11a.jpg": "70ebddf9b551b71f9f864c5fba28673b",
"assets/assets/images/12a.jpg": "163a683774b8d10baad13d9c4c68077c",
"assets/assets/images/7b.jpg": "2d971ca29c04f19a2380f69d8e964377",
"assets/assets/images/7a.jpg": "28506aacce01a7160a8fc6e057929871",
"assets/assets/images/3a.jpg": "1ad5f437ea47a47a5e76b001b841715b",
"assets/assets/images/6a.jpg": "ec2d6ae0b04a8fa998ada00d4e5a33eb",
"assets/assets/images/9a.jpg": "4e4b8aa5194ee0ebfdd2d88ba3d3e2dd",
"assets/assets/images/10a.jpg": "507ad408f06c24c57b6b3a1dada33861",
"assets/assets/images/2a.jpg": "01d6f058c7aa0b1dbd8376d1135d0da3",
"assets/assets/images/6b.jpg": "113c8da46d548f792a2605a31d6d9bb2",
"assets/assets/images/11b.jpg": "3147f3ca723f8c9fab6d66ee9cc4b64d",
"assets/assets/images/8a.jpg": "e505e9cdd78f663565a45790cab251d3",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"version.json": "a4994e2c98d3c7124d65d4ed14f2db8b",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"main.dart.js": "f08d473ef0a85c01f8b35b0007ae9b8c"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
