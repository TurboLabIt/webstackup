## pipe vs pass

- **`return (pipe);`**: Varnish sets up a **tunnel** (a raw, unbuffered, bidirectional stream) between the client and the backend. Varnish doesn’t inspect or modify the data as it passes through—effectively it is out of the way and acts as a TCP proxy. No caching is performed, and once in “pipe” mode, Varnish does not apply its usual HTTP handling features.

- **`return (pass);`**: Varnish still processes the request and response at the HTTP layer but **bypasses the cache** (i.e., it won’t store or retrieve the object in/from cache). The data flows through Varnish normally (headers can still be modified, logging can still happen, etc.), but Varnish won’t serve it from cache or put it into cache.

If you have a scenario where you want Varnish to completely stand aside and just forward everything (such as certain streaming or WebSocket-type connections), you’d use `return (pipe)`. If you want to ensure a request is passed to the backend (without caching) but still need the usual Varnish HTTP-layer behaviors (like logging, header manipulation, etc.), use `return (pass)`.
