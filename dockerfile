FROM nginx:1.25-alpine

ARG LABEL
LABEL mylabel=${LABEL}

RUN apk add --no-cache rsync

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY <<'EOF' /docker-entrypoint.sh
#!/bin/sh
set -e
if [ "${ROBOTS_NOINDEX}" = "true" ] || [ "${ROBOTS_NOINDEX}" = "1" ]; then
  touch /etc/nginx/noindex.flag
fi
exec nginx -g 'daemon off;'
EOF

RUN chmod +x /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]
