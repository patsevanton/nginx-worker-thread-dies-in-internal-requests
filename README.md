# nginx-worker-thread-dies-in-internal-requests
check https://github.com/open-telemetry/opentelemetry-cpp-contrib/issues/105

Build the Docker image.
```bash
docker build -t nginx-worker-thread-dies-in-internal-requests:0.0.1 .
```

Run the Docker image in one terminal.
```
docker run \
--name nginx-lua-crash \
-v $(pwd):/tmp/cores \
-v $(pwd)/nginx.conf:/etc/nginx/nginx.conf \
-v $(pwd)/otel-nginx.toml:/otel-nginx.toml \
-it \
--rm \
nginx-worker-thread-dies-in-internal-requests:0.0.1
```
Exec into the Docker container in another terminal.
```
docker exec -it nginx-lua-crash /bin/sh
```
Use curl to crash the worker thread.
```
curl localhost:80
```
Use gdb and confirm the backtrace with bt.
```
gdb /usr/sbin/nginx /tmp/cores/core
```
Edit the file and comment out the ngx.location.capture call on line 18.
```
vi /etc/nginx/nginx.conf
```
Reload Nginx so that it will load the updated configuration file.
```
nginx -s reload
```
The curl will now be successful.
```
curl localhost:80
```