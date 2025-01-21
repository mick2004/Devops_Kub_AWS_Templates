AFter TF apply

aws eks update-kubeconfig --region us-east-1 --name ascode-cluster

kubectl get nodes

kubectl get pods

kubectl run testpod --image=nginx

kubectl get pods --watch
