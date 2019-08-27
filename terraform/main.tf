#-----main.tf-----------

resource "docker_network" "urlnet" {
	name = "urlnet"
}

resource "docker_image" "urlapp" {
	name = "sayaliupasani/urlapp:2.0"
}

resource "docker_image" "nginx_proxy" {
	name = "sayaliupasani/nginx_proxy:1.0"
}

resource "docker_container" "urlapp" {
	name  = "urlapp"
	image = "${docker_image.urlapp.name}"
	hostname = "urlapp"
	volumes {

	  host_path = "${path.cwd}/../app/"
	  container_path ="/url_status_project"
	 }

	networks_advanced {
	  name = "urlnet"
	}

	depends_on = [docker_container.redis]
}

resource "docker_container" "nginx" {
	name = "nginx_proxy"
	image = "${docker_image.nginx_proxy.name}"
	hostname = "nginx_server"
	ports {
	  internal = "80"
	  external = "80"
	}
	volumes {

	  host_path = "${path.cwd}/../nginx/data/"
	  container_path = "/etc/nginx/conf.d"
	}

	networks_advanced {
	  name = "urlnet"
	}

	depends_on = [docker_container.urlapp]
}

resource "docker_container" "redis" {
	name = "url_status_docker_redis_1"
	image = "bitnami/redis:latest"
	hostname = "redis"
	env = ["ALLOW_EMPTY_PASSWORD=yes"]
	ports {
	  internal = "6379"
	  external = "6379"
	}

	networks_advanced {
	  name = "urlnet"
	}

}