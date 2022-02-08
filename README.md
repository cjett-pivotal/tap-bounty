# TAB Bounty Challenge
##Goals: 
- Deploy Tanzu Application Platform to GKE.
- Configure ingress and routing.
- Install Postgres Operator on TAP.
- Deploy a Postgres Instance. 
- Deploy Spring Petclinic application with Postgres database.

## TAP Installation on GKE
###Prerequisites:
>Note: 
- GKE Cluster with the following configuration:
  - cluster-version "1.21.6-gke.1500" or above
  - machine-type "e2-standard-4"
  - disk-type "pd-standard" 
  - disk-size "100"
  - num-nodes "3"

  For example, use the command below to create a GKE cluster.  
  ```bash
  gcloud beta container --project "PROJECT_ID" clusters create "tap-gke-cluster" --zone "us-central1-c" --no-enable-basic-auth --cluster-version "1.21.6-gke.1500" --release-channel "regular" --machine-type "e2-standard-4" --image-type "COS_CONTAINERD" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --max-pods-per-node "110" --num-nodes "3" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias --network "projects/fluted-lambda-274409/global/networks/default" --subnetwork "projects/fluted-lambda-274409/regions/us-central1/subnetworks/default" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --node-locations "us-central1-c"
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

###Installing Tanzu Application Platform:


## Use the jupyter notebook <a href="https://github.com/sreeramsunkara/tap-bounty/blob/main/jupyter/tap-install.ipynb">jupyter/tap-install.ipyn</a> to install TAP following the instructions.
# Postgres Operator Installation
## Use the jupyter notebook <a href="https://github.com/sreeramsunkara/tap-bounty/blob/main/jupyter/tap-install.ipynb">jupyter/tap-install.ipyn</a> to install Postgres Operator on TAP following the instructions.
# Deploy Spring Petclinic App and bind to Postgres database
## Use the jupyter notebook <a href="https://github.com/sreeramsunkara/tap-bounty/blob/main/jupyter/tap-install.ipynb">jupyter/tap-install.ipyn</a> to install Postgres Operator on TAP following the instructions.
