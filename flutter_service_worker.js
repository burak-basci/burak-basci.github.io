'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"apple-icon-114x114.png": "a56a0f738043ecbd8b85194fc5eff2a9",
"apple-icon-120x120.png": "e320b0e59f2f559cc70c12fb2c253f58",
"apple-icon-72x72.png": "91c3b0b3f58f3276c6d776e836e8a2c4",
"apple-icon-180x180.png": "67bddcf915ee8f197b70477ebf53dcea",
"ms-icon-70x70.png": "b534289d21bcfadc1c0cc4bca2a69344",
"apple-icon-60x60.png": "538294b9b14d98bd76f4f2af158b980c",
"apple-icon-57x57.png": "b5ef31eb414e811b4898dd5f78417781",
"assets/assets/fonts/roboto/Roboto-Medium.ttf": "68ea4734cf86bd544650aee05137d7bb",
"assets/assets/fonts/roboto/Roboto-Regular.ttf": "8a36205bd9b83e03af0591a004bc97f4",
"assets/assets/fonts/roboto/Roboto-Bold.ttf": "b8e42971dec8d49207a8c8e2b919a6ac",
"assets/assets/fonts/visuelt/VisueltPro-Thin.ttf": "82d7b5b67c24f00acb08f2dccf1fd03b",
"assets/assets/fonts/visuelt/VisueltPro-Regular.ttf": "0f8cd2494eb8c5e3a33352b2dd38fd61",
"assets/assets/fonts/visuelt/VisueltPro-Bold.ttf": "18acd33c965a455418d4204f0f334ea8",
"assets/assets/fonts/visuelt/VisueltPro-Light.ttf": "2a1df2ff00c2611bf1b7fdeeaeebfa59",
"assets/assets/fonts/visuelt/VisueltPro-ExtraLight.ttf": "90bfa0766e43260710e3c6ac0f78c9e9",
"assets/assets/fonts/visuelt/VisueltPro-Black.ttf": "691b6f9aa3ee625e3cd8da2f8849a126",
"assets/assets/fonts/visuelt/VisueltPro-Medium.ttf": "cf4dbc20776a2b309fe30a9bbfe7de0a",
"assets/assets/images/right-arrow.png": "62a7bab73a0fe40acd3f4555adfcab91",
"assets/assets/images/home_dude.png": "4d20839af1a2f79a75266dbbf0369aca",
"assets/assets/images/down-arrow.png": "4393cd5feeb20fb468c7eb223d1bbd06",
"assets/assets/images/default_page_header.png": "5c6f8eb3a22f703781aad6c2528cf0cd",
"assets/assets/images/default_page_footer.png": "663d5187ada8666bfa87120d1665605f",
"assets/assets/images/ios-down-arrow.png": "fa4679d2972f1d11355142a60ed34ede",
"assets/assets/images/piano.jpg": "b40e37fde428618abbc365fb883c71f9",
"assets/assets/images/caesar2.png": "c2bf68cb3b24b5361c95d04c445511a8",
"assets/fonts/MaterialIcons-Regular.otf": "c0351b5640867386b372e6db3a73cf4f",
"assets/AssetManifest.bin.json": "3863cf16874883d260719383918f33c8",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "7c7b5d4cf660b84e7afd6403ff1e1b8b",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "781b07dae47f4e6c89811824a2263f47",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "f3307f62ddff94d2cd8b103daf8d1b0f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/FontManifest.json": "09643af25d4d8aefeb0b80ad51d38b8c",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"assets/NOTICES": "d4ee0c0b577e289bba40ee709583658c",
"assets/AssetManifest.bin": "be03e0f31f2398587cb7e4923a1703fe",
"assets/AssetManifest.json": "80db8774cbbcfde6dc99739aae8d5b8a",
"apple-icon-76x76.png": "8b6bc7cbc55eec00ef45a89ccbef5090",
"favicon.png": "b1e6e19cafa905308746bf2b29652cb7",
"main.dart.js": "44e6d979476d7b1aec2fe4239d61aaf9",
"favicon-96x96.png": "14069518c7f4d0ead1e9d7d97c2bf210",
"favicon.ico": "d92da94026ef14b2470fc77e2df1767e",
"apple-icon-152x152.png": "cfb852814c77351c9a8e27743c525f5d",
"apple-icon-144x144.png": "d6922517e4760d2e17b75e5114efb2b9",
"apple-icon-precomposed.png": "869b1c354f0c580baedf511d46cd20d5",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/canvaskit.wasm": "73584c1a3367e3eaf757647a8f5c5989",
"canvaskit/skwasm.wasm": "2fc47c0a0c3c7af8542b601634fe9674",
"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"canvaskit/chromium/canvaskit.wasm": "143af6ff368f9cd21c863bfa4274c406",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"apple-icon.png": "869b1c354f0c580baedf511d46cd20d5",
"flutter.js": "7d69e653079438abfbb24b82a655b0a4",
"index.html": "905e59eaa97a1e6ff0528797ef2b4113",
"/": "905e59eaa97a1e6ff0528797ef2b4113",
"ms-icon-144x144.png": "d6922517e4760d2e17b75e5114efb2b9",
"ms-icon-150x150.png": "922c023f6bfc6475abca02b0c9d69d16",
"ms-icon-310x310.png": "3df630d318acff6815630dd093df9e8f",
"manifest.json": "c22239d777022c8da38cfd274970f3fa",
"version.json": "c24b28c83c66f0912b83c52039dee59b",
"favicon-16x16.png": "4b1cb3e295a3c89edaed9615e612ed2a",
"icons/android-icon-96x96.png": "14069518c7f4d0ead1e9d7d97c2bf210",
"icons/android-icon-144x144.png": "d6922517e4760d2e17b75e5114efb2b9",
"icons/android-icon-36x36.png": "0f5f99d87f8feb65b912ac3437a800b7",
"icons/android-icon-192x192.png": "950701d52f9d14cb902fc2f1b0e511ac",
"icons/android-icon-48x48.png": "e69d1303a06560441b0bd5d03a3fce05",
"icons/android-icon-72x72.png": "91c3b0b3f58f3276c6d776e836e8a2c4",
"favicon-32x32.png": "b1e6e19cafa905308746bf2b29652cb7"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
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
        // Claim client to enable caching on first launch
        self.clients.claim();
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
