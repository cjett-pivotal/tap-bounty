#!/bin/bash

set -e -o pipefail

export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
export INSTALL_REGISTRY_USERNAME="TANZU_NETWORK_USERNAME"
export INSTALL_REGISTRY_PASSWORD="TANZU_NETWORK_PASSWORD"

export CERTS_DIR="/Users/sunkarasr/projects/tap"
export SA_PWD_FILE="/Users/sunkarasr/projects/tap/sa.json"

kubectl create ns tap-install --dry-run=client -o yaml | kubectl apply -f -

tanzu secret registry add tap-registry \
  --username ${INSTALL_REGISTRY_USERNAME} --password ${INSTALL_REGISTRY_PASSWORD} \
  --server ${INSTALL_REGISTRY_HOSTNAME} \
  --export-to-all-namespaces --yes --namespace tap-install

tanzu package repository add tanzu-tap-repository \
  --url registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:1.0.0 \
  --namespace tap-install

kubectl create ns tanzu-system-ingress --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret tls tls --cert=${CERTS_DIR}/tanzu4u-fullchain.pem --key=${CERTS_DIR}/tanzu4u-privkey.pem -n tanzu-system-ingress --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns learningcenter --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret tls tls --cert=${CERTS_DIR}/tanzu4u-fullchain.pem --key=${CERTS_DIR}/tanzu4u-privkey.pem -n learningcenter --dry-run=client -o yaml | kubectl apply -f -

kubectl create ns dev --dry-run=client -o yaml | kubectl apply -f -

tanzu secret registry add registry-credentials --namespace dev --server gcr.io --username _json_key --password-file ${SA_PWD_FILE}

kubectl -n dev apply -f dev-sa-rbac.yaml
