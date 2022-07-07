docker build -t kohaaloha/koha-testing:buster-arm64-hello --no-cache --rm -f dists/buster-arm64-hello/Dockerfile .

echo "$REGISTRY_PASSWORD" | docker login -u "$REGISTRY_USER" --password-stdin

docker push kohaaloha/koha-testing:buster-arm64-hello

#docker image rm kohaaloha/koha-testing:buster-arm64-hello
