Hetzner Cloud terraform example 
-----------------------------

Will create one cx11 Ubuntu host with defined ssh key and install Docker on the host

How to setup?
--------------

* cp .env.dist .env
* edit .env variables and save
* run: 
  * docker-compose run --rm terraform plan
  * docker-compose run --rm terraform apply
  * docker-compose run --rm terraform destroy
