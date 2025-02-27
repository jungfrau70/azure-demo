sudo docker build .
sudo docker images

sudo docker build -t my-wordpress:1.0 .
sudo docker images

sudo docker run -d -p 8080:80 my-wordpress:1.0

sudo docker ps

sudo docker stop <container_id>

sudo docker logs <container_id>

<!-- sudo docker rm <container_id>

sudo docker rmi <image_id> -->








