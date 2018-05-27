Hetzner Cloud terraform example 
-----------------------------

* Will create one cx11 Ubuntu host with defined ssh key and install Docker and Rancher 2 Server on the host
* Will create three cx11 Ubuntu hosts with defined ssh key and install Docker and join to Rancher 2 Kubernetes Cluster

How to setup?
--------------

* cp .env.dist .env
* edit .env variables and save
* run: 
  * docker-compose run --rm terraform init
  * docker-compose run --rm terraform plan
  * docker-compose run --rm terraform apply
  * docker-compose run --rm terraform destroy

![Rancher 2 Preview](rancher2.png "Rancher 2 Preview")