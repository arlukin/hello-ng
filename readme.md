# hello-ng

## Build and Deploy

* If you do not have a local registry started.

```bash
docker run -d -p 9000:5000 --restart=always --name registry registry:latest
```

* Replace the version (v0.1.6, v0-1-6) number in Deployment.yml and Deployment.Local.yml and to this readme file.
* Build and push the image to your local register.

```bash
docker build -t localhost:9000/hello-ng:v1.0.1 . && \
docker push localhost:9000/hello-ng:v1.0.1
```

* Check the you running local context

```bash
kubectl config current-context
kubectl config use-context docker-for-desktop
```

* Apply the local Deployment file

```bash
// kubectl delete -f ./deployment.yml
// kubectl get all
kubectl apply -f ./deployment.yml
```

* Get deployment, replicaset, pods, services from kubernetes to see that it's upp and running

```bash
kubectl get all
```

* Access the loadbalanced page

```bash
// Get external ip  
kubectl get all|grep LoadBalancer| tr -s ' ' |cut -d" " -f4
curl http://35.222.8.62.nip.io/
```

* Make a port-forward to be able to test the service from a browser.

```bash
kubectl port-forward service/hello-ng 8080:80
```

* <http://localhost:8080/k8s/healthy>
* <http://localhost:8080/search?fromId=A=1@O=Luton%20Airport%20Airport%20Bus%20Station@X=-376135@Y=51879391@U=70@L=000156845@B=1@p=1551112319@&toId=A=1@O=Dunstable%20Evelyn%20Road@X=-487403@Y=51890924@U=70@L=000113769@B=1@p=1551112319@&departing=2019-03-01+12:25>

## Make a deployment to AWS kubernetes

* Tag the image with image name from Deployment.yml

```bash
docker tag localhost:9000/hello-ng:v1.0.1 gcr.io/bytapension/hello-ng:v1.0.1
```

* Push the image to AWS

```bash
docker push gcr.io/bytapension/hello-ng:v1.0.1
```

* Switch context to GCP.

```bash
kubectl config current-context
kubectl config use-context gke_bytapension_us-central1-a_bytapension-cluster
```

* Check that there aren't any service running with the same version number.

```bash
kubectl get all --all-namespaces
```

* Apply the Deployment.yml

```bash
kubectl apply -f ./deployment.yml
```

* Se that the service is upp and running.

```bash
kubectl get all
kubectl describe pod/hello-ng-68f7dcbf89-zvffn 
kubectl logs pod/hello-ng-595dd5454-hr5r8 
```

* Make a port-forward to se that it's upp and running, same URLs that you tested locally

```bash
kubectl port-forward service/hello-ng 8080:80
http://localhost:8080/k8s/healthy
http://localhost:8080/search?fromId=A=1@O=Luton%20Airport%20Airport%20Bus%20Station@X=-376135@Y=51879391@U=70@L=000156845@B=1@p=1551112319@&toId=A=1@O=Dunstable%20Evelyn%20Road@X=-487403@Y=51890924@U=70@L=000113769@B=1@p=1551112319@&departing=2019-03-01+12:25
```

* Commit and push the version changes to git

```bash
git add .
git commit -m "Version v0.1.6"
git pull
git push
git checkout development
git pull
git rebase master
git push
```