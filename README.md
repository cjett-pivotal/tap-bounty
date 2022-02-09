# TAB Bounty Challenge
## Goals: 
- Deploy Tanzu Application Platform to GKE.
- Configure ingress and routing.
- Install Postgres Operator on TAP.
- Deploy a Postgres Instance. 
- Deploy Spring Petclinic application with Postgres database.

## TAP Installation on GKE
### Prerequisites:
- Install the [gcloud CLI](https://cloud.google.com/sdk/docs/install) and [initialize](https://cloud.google.com/sdk/docs/initializing)
>Note: Use the jupyter notebook <a href="https://github.com/sreeramsunkara/tap-bounty/blob/main/jupyter/tap-install-prerequistes.ipynb">jupyter/tap-install-prerequisites.ipynb</a> to install prerequisites for installing TAP.
> If you are unable to run notebook, follow the instructions below.
- GKE Cluster with the following configuration:
  - cluster-version "1.21.6-gke.1500" or above
  - machine-type "e2-standard-4"
  - disk-type "pd-standard" 
  - disk-size "100"
  - num-nodes "3"

  For example, use the command below to create a GKE cluster in the `us-central1-c` region.
  - Replace `PROJECT_ID` with a valid project name.  
  - Valid project names can be found via `gcloud projects list` or at [https://console.cloud.google.com/](https://console.cloud.google.com/)
  - Note there are 3 PROJECT_ID values that need to be replaced
    - `project`
      - This is the main name of your project.
    - `network`
      - The network used for the GKE cluster.  Set to use the `default` network ("projects/PROJECT_ID/global/networks/default").  Valid networks can be found via `gcloud compute networks list`
    - `subnetwork`
      - The subnetwork used for the GKE cluster.  Set to use the `default` subnetwork ("projects/PROJECT_ID/regions/us-central1/subnetworks/default").  Valid networks can be found via `gcloud compute networks subnets list`

  ```bash
  gcloud beta container --project "PROJECT_ID" clusters create "tap-gke-cluster" --zone "us-central1-c" --no-enable-basic-auth --cluster-version "1.21.6-gke.1500" --release-channel "regular" --machine-type "e2-standard-4" --image-type "COS_CONTAINERD" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --max-pods-per-node "110" --num-nodes "3" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias --network "projects/PROJECT_ID/global/networks/default" --subnetwork "projects/PROJECT_ID/regions/us-central1/subnetworks/default" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --node-locations "us-central1-c"
  ```
  >Note: GKE zonal clusters come with 1 instance of control plane that can struggle with TAP installation. In order to overcome the problem, you may have to delete and reinstall TAP in case of Control Plane and Cluster failures.
  > Google recommends using a Regional cluster, however a Zonal cluster will work fine after the initial hick ups.
  
  Once the cluster is created, set the Kubernetes context.
  ```bash
  gcloud container clusters get-credentials tap-gke-cluster --zone us-central1-c --project "PROJECT_ID"
  ```
- Install Cluster Essentials for VMWare Tanzu
  - Sign in to Tanzu Network.
  - Navigate to Cluster Essentials for VMware Tanzu on Tanzu Network.
  - Download tanzu-cluster-essentials-darwin-amd64-1.0.0.tgz (for OS X) or tanzu-cluster-essentials-linux-amd64-1.0.0.tgz (for Linux) and unpack the TAR file into tanzu-cluster-essentials directory:
  
  To download using <a href= "https://github.com/pivotal-cf/pivnet-cli">pivnet CLI</a>, please install it and use your pivnet token.
  ```bash
  cd /tmp
  pivnet login --api-token='PIVNET_TOKEN'
  pivnet download-product-files --product-slug='tanzu-cluster-essentials' --release-version='1.0.0' --product-file-id=1105820
  ```
  - Configure and run install.sh
  ```bash
  mkdir $HOME/tanzu-cluster-essentials
  tar -xvf tanzu-cluster-essentials-darwin-amd64-1.0.0.tgz -C $HOME/tanzu-cluster-essentials
  cd $HOME/tanzu-cluster-essentials
  export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:82dfaf70656b54dcba0d4def85ccae1578ff27054e7533d08320244af7fb0343
  export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
  export INSTALL_REGISTRY_USERNAME=TANZU-NET-USER
  export INSTALL_REGISTRY_PASSWORD=TANZU-NET-PASSWORD
  ./install.sh
  ```
  - Install the kapp CLI onto your $PATH:
  ```bash
  sudo cp $HOME/tanzu-cluster-essentials/kapp /usr/local/bin/kapp
  ```
- Install or update the Tanzu CLI and plug-ins
  - Follow the instructions provided in the VMware Documentation to install <a href="https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-general.html#install-or-update-the-tanzu-cli-and-plugins-2">Tanzu CLI and plug-ins</a>

### Installing Tanzu Application Platform:
>Note: Use the jupyter notebook <a href="https://github.com/sreeramsunkara/tap-bounty/blob/main/jupyter/tap-install.ipynb">jupyter/tap-install.ipynb</a> to install Tanzu Application Platform.
> If you are unable to run notebook, follow the instructions below.
- Edit <a href="https://github.com/sreeramsunkara/tap-bounty/blob/main/install/scripts/setUp.sh">setUp.sh</a> and update values forI INSTALL_REGISTRY_HOSTNAME, INSTALL_REGISTRY_USERNAME, INSTALL_REGISTRY_PASSWORD, CERTS_DIR, SA_PWD_FILE

  - INSTALL_REGISTRY_HOSTNAME - registry.tanzu.vmware.com
  - INSTALL_REGISTRY_USERNAME - your Tanzu registry username
  - INSTALL_REGISTRY_PASSWORD - your Tanzu registry password
  - CERTS_DIR - the directory that holds the ssl certs(public and private keys) in .pem format to use in configuring SSL for ingress.
  - SA_PWD_FILE - your GCP Service Account key in json format in a file.

  ```bash
  cd $HOME/projects/tap-bounty/install/scripts
  chmod 755 setUp.sh
  cd $HOME/projects/tap-bounty
  ```
  - Edit <a href="https://github.com/sreeramsunkara/tap-bounty/blob/main/tap-values.yml">tap-values.yml</a> to update the values for GCR_REPOSITORY, SERVICE_ACCOUNT_JSON, TANZU_NETWORK_USERNAME, TANZU_NETWORK_PASSWORD, GITHUB_TOKEN and the domain values.
  
    - GCR_REPOSITORY - gcr.io/PROJECT_ID/REPO_NAME
    - SERVICE_ACCOUNT_JSON - Service Account json to access GCP
    - TANZU_NETWORK_USERNAME - your Tanzu network username
    - TANZU_NETWORK_PASSWORD - your Tanzu network password
    - GITHUB_TOKEN - GitHub access token
    ```bash
    tanzu package install tap -p tap.tanzu.vmware.com -v 1.0.0 --values-file tap-values.yml -n tap-install
    ```
    >Note: If the status shows reconciliation failed for TAP, it may be due to the GKE control plane issue mentioned before. Check the GKE console to view the workloads and their status. If you see errors or warnings such as rebuilding cluster or information about nodes/cluster unavailable, then it means that we have to delete the TAP installation and reinstall again. Check Re-installation instructions below.

- Check the status of the TAP installation 
  ```bash
  tanzu package installed get tap -n tap-install
  ```
- If the status is success, then check all the packages installed.
  ```bash
  tanzu package installed list -A
  ```
- In case of failure, use the following instructions
  - Check the error message for individual package by executing the following command using the information from the List command above.
    ```bash
    tanzu package installed get "name of the package" -n "namespace in which it is installed"
    ```
  - Typical issues are invalid values in tap-values.yml. Doublecheck the values and reinstall again.
- Re-installation in case of failures
  - Delete TAP installation by running the following command.
  ```bash
  tanzu package installed delete tap -n tap-install
  ```
  - Install TAP again
  ```bash
    tanzu package install tap -p tap.tanzu.vmware.com -v 1.0.0 --values-file tap-values.yml -n tap-install
  ```
>Note: If you see errors in GKE console and if the delete command fails, retry again after the GKE cluster is available.

- Configure Ingress and Routing
   
  - Note the external ip address associated with the load balancer.
  ```bash
  kubectl get svc envoy -n tanzu-system-ingress
  ```
  - If you are using a custom domain with Google Cloud DNS, create the DNS records with the ip address noted from above command.
  ```bash
  gcloud beta dns --project=fluted-lambda-274409 record-sets transaction start --zone="tanzu4u"
  gcloud beta dns --project=fluted-lambda-274409 record-sets transaction add "EXT_IP_ADDRESS" --name="tap-gui.tap.tanzu4u.net." --ttl="300" --type="A" --zone="tanzu4u"
  gcloud beta dns --project=fluted-lambda-274409 record-sets transaction execute --zone="tanzu4u"
  ```
  - Configure contour for ingress
  > Note: Edit <a href="https://github.com/sreeramsunkara/tap-bounty/blob/main/tap-ingress/values-ingress.yaml">values-ingress.yaml</a> located in tap-ingress folder.
  ```bash
  cd tap-ingress
  ./configure-ingress.sh values-ingress.yaml
  ```
  - Verify TAP GUI is installed and can be accessed.
  ```bash
  nslookup tap-gui.tap.tanzu4u.net
  open -a "Google Chrome" https://tap-gui.tap.tanzu4u.net
  ```
- Deploy a sample application
  
  - Create a Tanzu workload for tanzu-java-web-app.
  ```bash
  tanzu apps workload create tanzu-java-web-app \
  --git-repo https://github.com/sreeramsunkara/tanzu-java-web-app \
  --git-branch main \
  --type web \
  --label app.kubernetes.io/part-of=tanzu-java-web-app \
  --namespace dev \
  --yes
  ``` 
  - Check the status of the tanzu-java-web-app.
  ```bash
  tanzu apps workload get tanzu-java-web-app -n dev
  ```
  - If using custom domain, create the DNS record for the apps.
  ```bash
  gcloud beta dns --project=fluted-lambda-274409 record-sets transaction start --zone="tanzu4u"
  gcloud beta dns --project=fluted-lambda-274409 record-sets transaction add EXT_IP_ADDRESS --name="*.apps.tap.tanzu4u.net." --ttl="300" --type="A" --zone="tanzu4u"
  gcloud beta dns --project=fluted-lambda-274409 record-sets transaction execute --zone="tanzu4u"
  ```
  > Note: If there is no custom domain, then you will need to create alias and use the hosts file.
  - Access the app to verify.
  ```bash
  open -a "Google Chrome" https://tanzu-java-web-app-dev.apps.tap.tanzu4u.net/
  ```

## Postgres Installation
### Installing Postgres Operator on TAP
>Note: Use the jupyter notebook <a href="https://github.com/sreeramsunkara/tap-bounty/blob/main/jupyter/tap-postgres.ipynb">jupyter/tap-postgres.ipynb</a> to install Tanzu Application Platform.
> If you are unable to run notebook, follow the instructions below.
- Install Helm using homebrew
  ```bash
  brew install helm
  ```
- Edit prereq.sh and update TANZU_NETWORK_USERNAME and TANZU_NETWORK_PASSWORD for Tanzu Network Registry.
  ```bash
  cd $HOME/projects/tap-bounty/postgres
  chmod 755 prereq.sh
  ./prereq.sh
  ```
- Install Postgres Operator based on values provided in postgres-operator/values.yaml
  ```bash
  cat postgres-operator/values.yaml
  ./install-operator.sh
  helm list -n postgres-operator
  ```
### Create Postgres instance in "dev" namespace for use by applications
- Verify ALLOWVOLUMEEXPANSION and VOLUMEBINDINGMODE for available Storage Classes
> Note: Ensure that the storage class VOLUMEBINDINGMODE field is set to volumeBindingMode=WaitForFirstConsumer, to avoid Postgres pods and Persistent Volumes (PV) scheduling issues.
  ```bash
  kubectl get storageclasses
  ```
- Deploy a Postgres instance
> Note: Edit install-instance.sh and update TANZU_NETWORK_USERNAME and TANZU_NETWORK_PASSWORD for Tanzu Network Registry.
> Review and update postgres.yaml and postgres-service-binding-rbac.yaml for any customizations.
  ```bash
  ./install-instance.sh
  ```
- Verify Postgres instance is created successfully
  ```bash
  kubectl get postgres/postgres-db -n dev
  ```

## Deploy Spring Petclinic with Postgres using Service Binding

> Note: Checkout the project https://github.com/sreeramsunkara/spring-petclinic-tap.
Ensure spring.datasource.initialization-mode=always in application.properties and application-postgres.properties to create the schema and data .
For subsequent runs set spring.datasource.initialization-mode=never.
> 
> Update kubernetes/tap/workload.yaml to update the GIT uri for source code.
- Deploy Spring Petclinic workload
  ```bash
  cd $HOME/projects/tap/spring-petclinic-tap
  tanzu apps workload apply -f kubernetes/tap/workload.yaml -y
  ```
> Note: Review the workload.yaml to see service claims for Postgres instance created.
- Verify Spring Petclinic workload is created and running successfully
  ```bash
  tanzu apps workload get spring-petclinic -n dev
  ```
- Access the Petclinic app
  ```bash
  open -a "Google Chrome" https://spring-petclinic-dev.apps.tap.tanzu4u.net/
  ```
- Connect to Postgres DB and verify data
  ```bash
  kubectl exec -n dev -it postgres-db-0 -- bash -c "psql -U pgappuser -d postgres-db"
  ```
  > Note: The above command logs you in to the Postgres DB. You can execute psql to query the database and can quit using \q.
  ```bash
  select * from vets;
  \q
  ```
>Note: Use the jupyter notebook <a href="https://github.com/sreeramsunkara/tap-bounty/blob/main/jupyter/tap-spring-petclinic-postgres.ipynb">jupyter/tap-spring-petclinic-postgres.ipynb</a> to install Tanzu Application Platform.
> If you are unable to run notebook, follow the instructions below.

### Tanzu Application Platform Documentation is available <a href="https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-install-intro.html">here</a>
### Postgres Installation Documentation is available <a href="https://docs.vmware.com/en/VMware-Tanzu-SQL-with-Postgres-for-Kubernetes/1.5/tanzu-postgres-k8s/GUID-install-operator.html">here</a>
