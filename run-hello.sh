#docker system prune -a -f

# Pre cleanup
docker-compose down
docker stop $(docker ps -a -f "name=koha_" -q)
docker rm $(docker ps -a -f "name=koha_" -q)
docker volume prune -f

# Pull the latest image
docker-compose -f docker-compose-hello.yml pull

# Run tests
#docker-compose -f docker-compose-hello.yml -p koha up --abort-on-container-exit --no-color --force-recreate
docker-compose -f docker-compose-hello.yml -p koha up --no-color --force-recreate

# Post cleanup
docker-compose down
docker stop $(docker ps -a -f "name=koha_" -q)
#docker rm $(docker ps -a -f "name=koha_" -q)
#docker volume prune -f

