user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    'upstream=$upstream_addr $request_time';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    keepalive_timeout 60;

    # Upstream setup for Blue-Green apps
    upstream main_backend {
        server blue_app:${PORT} max_fails=1 fail_timeout=4s;
        server green_app:${PORT} backup;
    }

    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://main_backend;

            # Fast failover logic
            proxy_connect_timeout 1s;
            proxy_send_timeout 2s;
            proxy_read_timeout 2s;
            proxy_next_upstream error timeout http_500 http_502 http_503 http_504;
            proxy_next_upstream_tries 2;

            # Preserve headers and source info
            proxy_pass_request_headers on;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_buffering off;
        }

        # App health endpoint
        location /healthz {
            proxy_pass http://main_backend/healthz;
        }

        # App version endpoint
        location /version {
            proxy_pass http://main_backend/version;
        }
    }
}
