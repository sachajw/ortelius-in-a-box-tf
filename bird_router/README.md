# BIRD for PureLB

PureLB is a load-balancer orchestrator for Kubernetes clusters.
It uses standard Linux networking and routing protocols, and works with the operating system to announce service addresses.

This is a simple packaging of the open source routing software [BIRD](https://bird.network.cz) Version 2.0 (currently 2.0.9).

The included sample configuration bird-cm.yml imports the routing table entries created when PureLB adds allocated load-balancer addresses to kube-lb0.

## Documentation

The PureLB documentation describes use alongside PureLB.

https://purelb.gitlab.io/docs

## Quick Start

* Edit the Bird configmap to enable & configure routing
* Create the router namespace<br/>
`kubectl create namespace router`
* Apply the edited configmap<br/>
`kubectl apply -f bird-cm.yml`
* Deploy the Bird Router<br/>
`kubectl apply -f bird.yml`

## Development

The Makefile builds the container image and pushes it to a registry. Run "make" with no parameters to get help on the available variables and goals.
