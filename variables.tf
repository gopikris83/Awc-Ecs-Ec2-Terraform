variable "app_name" {
  description = "Name of the application"
  default     = "ecsEc2App"
}

variable "app_environment" {
  description = "Application environment"
  default     = "Test"
}

variable "ecs_cpu" {
  description = "Ecs CPU size"
  default     = "1024"
}

variable "ecs_memory" {
  description = "ECS Memory size"
  default     = "3072"
}

variable "health_check_path" {
  default = "/"
}

variable "app_port" {
  default     = 80
  description = "port exposed on the docker image"
}

variable "app_count" {
  default     = "2" #choose 2 bcz i have choosen 2 AZ
  description = "numer of docker containers to run"
}

variable "aws_region" {
  default     = "eu-central-1"
  description = "aws region where our resources going to create choose"
  #replace the region as suits for your requirement
}

variable "az_count" {
  default     = "2"
  description = "number of availability zones in above region"
}
