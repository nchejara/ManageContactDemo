# Application deployment using Kubernates


### Prerequisites

1. Install docker or podman
2. Install minikube
3. Install KubeCTL


## Deploy Application


```
    kubectl apply -f db-secrets.yaml
    kubectl apply -f env-db-config.yaml

    kubectl apply -f db-deployment.yaml
    // db-deployment will create Volume, Pod and service

    kubectl apply -f frontend-deployment
    // frontend-deployment will create pos and service

```



## Verify Application resources

```
    kubectl get all

```


## Ingress setup

Enable ingress addons in minikube

```
    minikube addons enable ingress
    kubectl get ns
    kubectl get pods -n ingress-nginx

```