# HAProxy Reverse Proxy with Logging of HTTPS Request Contents

The goal of this use case is to use HAProxy for load balancing the API requests to the backend servers.

Additionally, the HTTPS bodies of the API requests coming from the clients to the backends need to be logged.

Note that HAProxy version > 1.6.0 is required. The latest version is installed on the server:
```text
$ haproxy -v
HA-Proxy version 1.8.8-1ubuntu0.10 2020/04/03
Copyright 2000-2018 Willy Tarreau <willy@haproxy.org>
```

## SSL/TLS Configurations and Infrastructure Layouts

Infrastructure layouts involving TLS are described here in the [HAProxy deployment guides for tls](https://www.haproxy.com/documentation/haproxy/deployment-guides/tls-infrastructure/).

In order to log the body requests of the HTTPS traffic, two possible layouts could be implemented as shown below.
This scenario implements the first option (SSL/TLS bridging or re-encryption). 

### SSL/TLS Bridging 

HAProxy deciphers the traffic on the client side and re-encrypts it on the server side.
It can access the content of the request and the response and perform advanced processing over the traffic.

```text
client <-- HTTPS --> HAProxy <-- HTTPS -->  backend-1
                            |
                             <-- HTTPS -->  backend-2
                            |
                             <-- HTTPS -->  backend-3
                            | ...
```

### SSL/TLS Offloading

This is also knows as [HAProxy SSL Termination](https://www.haproxy.com/de/blog/haproxy-ssl-termination/).
HAProxy deciphers the traffic on the client side and gets connected in clear traffic mode to the server.

```text
client <-- HTTPS --> HAProxy <-- HTTP -->  backend-1
                            |
                             <-- HTTP -->  backend-2
                            |
                             <-- HTTP -->  backend-3
                            | ...
```

### HAProxy Stats URI

The [stats uri](http://localhost:8404/stats) shows the relevant stats and an example can be found in the [logs folder](./logs).
The stats uri is enabled in the `frontend stats` section of the HAProxy config file.

## Infrastructure Layout

After executing `terraform apply`, the following resources will be created:

- EC2 instances with key pairs:
    - `client-1` (private ip in subnet eu-central-1c)
    - `backend-1` (private ip in subnet eu-central-1b)
    - `backend-2` (private ip in subnet eu-central-1b)
    - `jumphost` (public ip in subnet eu-central-1a)
    - `haproxy` (public ip in subnet eu-central-1a)
- Route53 DNS records:
    - `client-1.local.app`
    - `backend-1.local.app`
    - `backend-2.local.app`
    - `jumphost.local.app`
    - `haproxy.local.app`
    - `flask.local.app` (CNAME pointing to `haproxy.local.app`)
- NAT-Gateway (used by the backends to access the internet)
- Elastic IP and route table for the NAT-Gateway

### Setup

Copy the certificates (generate new ones if needed using the [bash script](./certificates/create_certs.sh)) to the backends and haproxy server from the jumphost: `scp certificates/* ubuntu@jumphost:/home/ubuntu`.

Run the example Flask application on the backends: `python3 app-backend-1.py`.

Copy the contents of the generated haproxy.cfg file to `/etc/haproxy/haproxy.cfg` and restart the haproxy service `sudo service haproxy restart`.

### Client Testing API Requests 

Make sure the generated Root CA is trusted on the client:
```text
sudo cp EC2CA.pem /usr/local/share/ca-certificates/EC2CA.crt && sudo update-ca-certificates
```

Otherwise, the `--insecure` / `-k` option has to be used with curl (`curl -k ...`).

Example requests:
```text
$ curl -X GET https://flask.local.app/users/2
{
  "data-backend-1": [
    "GET"
  ]
}

$ curl -X GET https://flask.local.app/users/2
{
  "data-backend-2": [
    "GET"
  ]
}

$ curl -X POST https://flask.local.app/users/2 -d "data"
{
  "data-backend-2": [
    "POST"
  ]
}

$ curl -X POST https://flask.local.app/users/2 -d "data"
{
  "data-backend-1": [
    "POST"
  ]
}
```

HAProxy log (`/var/log/haproxy.log`):
```text
Apr 24 16:29:06 ip-172-31-29-125 haproxy[6095]: frontend:ft_myapp/ip-172-31-29-125/172.31.29.125:443 client:172.31.10.211:58428 GMT:24/Apr/2020:16:29:06 +0000 body:- request:GET /users/2 HTTP/1.1
Apr 24 16:29:25 ip-172-31-29-125 haproxy[6095]: frontend:ft_myapp/ip-172-31-29-125/172.31.29.125:443 client:172.31.10.211:58430 GMT:24/Apr/2020:16:29:25 +0000 body:- request:GET /users/2 HTTP/1.1
Apr 24 16:29:49 ip-172-31-29-125 haproxy[6095]: frontend:ft_myapp/ip-172-31-29-125/172.31.29.125:443 client:172.31.10.211:58432 GMT:24/Apr/2020:16:29:49 +0000 body:s2112 request:POST /users/2 HTTP/1.1
Apr 24 16:30:01 ip-172-31-29-125 haproxy[6095]: frontend:ft_myapp/ip-172-31-29-125/172.31.29.125:443 client:172.31.10.211:58434 GMT:24/Apr/2020:16:30:01 +0000 body:data request:POST /users/2 HTTP/1.1
Apr 24 16:30:02 ip-172-31-29-125 haproxy[6095]: frontend:ft_myapp/ip-172-31-29-125/172.31.29.125:443 client:172.31.10.211:58436 GMT:24/Apr/2020:16:30:02 +0000 body:data request:POST /users/2 HTTP/1.1
Apr 24 16:30:41 ip-172-31-29-125 haproxy[6095]: frontend:ft_myapp/ip-172-31-29-125/172.31.29.125:443 client:172.31.10.211:58438 GMT:24/Apr/2020:16:30:41 +0000 body:data request:POST /users/2 HTTP/1.1
Apr 24 16:30:43 ip-172-31-29-125 haproxy[6095]: frontend:ft_myapp/ip-172-31-29-125/172.31.29.125:443 client:172.31.10.211:58440 GMT:24/Apr/2020:16:30:43 +0000 body:data request:POST /users/2 HTTP/1.1
Apr 24 16:30:44 ip-172-31-29-125 haproxy[6095]: frontend:ft_myapp/ip-172-31-29-125/172.31.29.125:443 client:172.31.10.211:58442 GMT:24/Apr/2020:16:30:44 +0000 body:data request:POST /users/2 HTTP/1.1
Apr 24 16:30:50 ip-172-31-29-125 haproxy[6095]: frontend:ft_myapp/ip-172-31-29-125/172.31.29.125:443 client:172.31.10.211:58444 GMT:24/Apr/2020:16:30:50 +0000 body:- request:GET /users/2 HTTP/1.1
Apr 24 16:30:52 ip-172-31-29-125 haproxy[6095]: frontend:ft_myapp/ip-172-31-29-125/172.31.29.125:443 client:172.31.10.211:58446 GMT:24/Apr/2020:16:30:52 +0000 body:- request:GET /users/2 HTTP/1.1
```

We can see from the HAProxy log file the client with IP address `172.31.10.211` communicating via `GET` and `POST` requests.
The HTTPS body contents can be also seen in the log file: `body:data`.

# Terraform Docs

This module was also inspired from [jetbrains-infra/terraform-aws-vpc-with-private-subnets-and-nat](https://github.com/jetbrains-infra/terraform-aws-vpc-with-private-subnets-and-nat).

## State List

```text
$ terraform state list
data.aws_ami.ubuntu-bionic-1804-amd64-server
data.aws_internet_gateway.default
data.aws_subnet.default_eu-central-1a
data.aws_subnet.default_eu-central-1b
data.aws_subnet.default_eu-central-1c
data.aws_vpc.main
data.template_file.haproxy
aws_eip.nat_1
aws_instance.backend-1
aws_instance.backend-2
aws_instance.client-1
aws_instance.haproxy
aws_instance.jumphost
aws_key_pair.ec2-backends
aws_key_pair.ec2-clients
aws_key_pair.ec2-haproxy
aws_key_pair.ec2-jumphost
aws_nat_gateway.nat_1
aws_route53_record.backend-1
aws_route53_record.backend-2
aws_route53_record.client-1
aws_route53_record.flask
aws_route53_record.haproxy
aws_route53_record.jumphost
aws_route53_zone.main
aws_route_table.nat_gw_1
aws_route_table_association.app_1_subnet_to_nat_gw
aws_security_group.backend
aws_security_group.client
aws_security_group.haproxy
aws_security_group.jumphost
```

## Requirements

| Name | Version |
|------|---------|
| terraform | 0.12.10 |
| aws | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.0 |
| null | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| role\_arn | The role to be assumed by Terraform (e.g. arn:aws:iam::123456789012:role/Admin). | `string` | n/a | yes |
| session\_name | The session name of the assumed role. | `string` | `"Terraform"` | no |
| testing\_node\_ip | The IP to be used by the testing node in CIDR notation (e.g. 2.4.22.10/32). | `string` | n/a | yes |
| zone\_name | Route53 zone name (e.g. my-awesome-domain.com). | `string` | `"local.app"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ec2-backend-1-id | EC2 instance id of backend-1. |
| ec2-backend-1-private-ip | Private ip of backend-1. |
| ec2-backend-2-id | EC2 instance id of backend-2. |
| ec2-backend-2-private-ip | Private ip of backend-2. |
| ec2-client-1-id | EC2 instance id of client-1. |
| ec2-client-1-private-ip | Private ip of client-1. |
| ec2-haproxy-id | EC2 instance id of HAProxy. |
| ec2-haproxy-private-ip | Private ip of HAProxy. |
| ec2-haproxy-public-ip | Public ip of HAProxy. |
| ec2-jumphost-id | EC2 instance id of jumphost. |
| ec2-jumphost-private-ip | Private ip of jumphost. |
| ec2-jumphost-public-ip | Public ip of jumphost. |
| nat-gw-1-public-ip | Public ip of NAT-Gateway-1. |
| sg-backend-id | Security group id of backends. |
| sg-client-id | Security group id of clients. |
| sg-haproxy-id | Security group id of HAProxy. |
| sg-jumphost-id | Security group id of jumphost. |
| zone\_id | Route53 hosted zone id. |

## Terraform Apply Outputs

```text
Outputs:

ec2-backend-1-id = i-08b83985b35e7dd21
ec2-backend-1-private-ip = 172.31.32.111
ec2-backend-2-id = i-0e8842b9d8c66da93
ec2-backend-2-private-ip = 172.31.33.156
ec2-client-1-id = i-01be54d031ad9e25f
ec2-client-1-private-ip = 172.31.15.142
ec2-haproxy-id = i-000dac8b085bdcda0
ec2-haproxy-private-ip = 172.31.24.23
ec2-haproxy-public-ip = 3.121.174.182
ec2-jumphost-id = i-0cda8c4ac99867e76
ec2-jumphost-private-ip = 172.31.19.43
ec2-jumphost-public-ip = 18.185.149.50
nat-gw-1-public-ip = 18.185.153.241
sg-backend-id = sg-086952f4eadeaa240
sg-client-id = sg-0aea1093f9180d7cf
sg-haproxy-id = sg-03e2830fe5c834c27
sg-jumphost-id = sg-082869fbec3f9a59d
zone_id = Z078875723ZR63J6U4BTW
```
