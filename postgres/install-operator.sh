kubectl create ns postgres-operator --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret docker-registry regsecret \
    --docker-server=https://registry.pivotal.io/ \
    --docker-username='TANZU_NETWORK_USERNAME' \
    --docker-password='TANZU_NETWORK_PASSWORD' \
    --namespace=postgres-operator

helm install my-postgres-operator postgres-operator/ \
  --namespace=postgres-operator \
  --wait

kubectl get serviceaccount -n postgres-operator

kubectl get all --selector app=postgres-operator -n postgres-operator

kubectl logs -l app=postgres-operator -n postgres-operator

kubectl api-resources --api-group=sql.tanzu.vmware.com -n postgres-operator
