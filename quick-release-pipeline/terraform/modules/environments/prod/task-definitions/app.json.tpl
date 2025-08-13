[
  {
    "name": "zero-downtime-app-container",
    "image": "${app_image}:v1",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 0
      }
    ],
    "memory": 256,
    "cpu": 128
  }
]