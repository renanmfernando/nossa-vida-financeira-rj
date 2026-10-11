const cacheName='nossa-financas-v7';
const assets=['./','./index.html','./styles.css','./bulk.css','./app.js','./config.js','./manifest.webmanifest'];

self.addEventListener('install',event=>event.waitUntil(
  caches.open(cacheName).then(cache=>cache.addAll(assets)).then(()=>self.skipWaiting())
));

self.addEventListener('activate',event=>event.waitUntil(
  caches.keys().then(keys=>Promise.all(keys.filter(key=>key!==cacheName).map(key=>caches.delete(key)))).then(()=>self.clients.claim())
));

// Primeiro tenta a rede: uma publicação nova passa a aparecer sem precisar
// apagar dados do navegador. O cache só é usado quando estiver offline.
self.addEventListener('fetch',event=>{
  if(event.request.method!=='GET')return;
  event.respondWith(
    fetch(event.request).then(response=>{
      if(response.ok&&new URL(event.request.url).origin===self.location.origin){
        const copy=response.clone();
        caches.open(cacheName).then(cache=>cache.put(event.request,copy));
      }
      return response;
    }).catch(()=>caches.match(event.request))
  );
});
