# Publish 

```
export VERSION=0.1
docker buildx build \
    --push \
    --platform linux/amd64,linux/arm64 \
    --tag ghcr.io/iridian-co/php81-symfony:$VERSION \
    --tag ghcr.io/iridian-co/php81-symfony:latest \
    -f php81.Dockerfile --no-cache .
```