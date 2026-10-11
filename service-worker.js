const cacheName='nossa-financas-v6';
self.addEventListener('install',e=>e.waitUntil(caches.open(cacheName).then(c=>c.addAll(['./','./index.html','./styles.css','./bulk.css','./app.js','./config.js','./manifest.webmanifest']))));
self.addEventListener('fetch',e=>e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request))));
