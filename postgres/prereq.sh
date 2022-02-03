export HELM_EXPERIMENTAL_OCI=1
helm registry login registry.pivotal.io \
       --username="TANZU_NETWORK_USERNAME" \
       --password="TANZU_NETWORK_PASSWORD"
helm pull oci://registry.pivotal.io/tanzu-sql-postgres/postgres-operator-chart --version v1.5.0 --untar --untardir .
