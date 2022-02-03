kubectl create secret docker-registry regsecret \
    --docker-server=https://registry.pivotal.io/ \
    --docker-username='TANZU_NETWORK_USERNAME' \
    --docker-password='TANZU_NETWORK_PASSWORD' \
    --namespace=dev

kubectl apply -f postgres.yaml

kubectl apply -f postgres-service-binding-rbac.yaml
