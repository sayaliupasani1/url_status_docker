#-----main.tf-----------

resource "docker_network" "urlnet" {
	name = "urlnet"
}

resource "docker_image" "urlapp" {
	name = "sayaliupasani/urlapp:1.0"
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
}

resource "docker_container" "nginx" {
	name = "nginx_proxy"
	image = "${docker_image.nginx_proxy.name}"
	hostname = "nginx_server"
	ports {
	  internal = "80"
	  external = "8085"
	}
	volumes {

	  host_path = "${path.cwd}/../nginx/data/"
	  container_path = "/etc/nginx/conf.d"
	}

	networks_advanced {
	  name = "urlnet"
	}
}