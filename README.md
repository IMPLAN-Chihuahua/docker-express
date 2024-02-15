# Docker configuration for Express applications
This repo has the necessary files to containerized an Express application

## Usage
In your project directory e.g., resource-api

Clone this repository within the project directory, then move the configuration files to the root of your project, and build the image
```
$ cd resource-api
$ git clone git@github.com:IMPLAN-Chihuahua/docker-express.git
$ mv docker-express/Dockerfile docker-express/.dockerignore .
$ rm -rf docker-express
$ docker build -t express-api .
```
Whe running a container instance, map the host port (e.g., 80) to the container port 8080
```
$ docker run --detach --port 80:8080 express-api
```

## Notes
To display a healthy status for a Docker container when running ```$ docker ps``` the Express application must have an endpoint to '/' (without any prefix).
