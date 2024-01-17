In this workshop, you will create the following resources:
A network named k8s-vpc-2.
A Subnetwork named k8s-subnet-2.
A private cluster named my-gke-cluster has private nodes and has no client access to the public endpoint.
Managed node pool with 3 sets of nodes.
A Linux bastion host with internal IP only. No Public IP is attached. This machine will be accessible over the internal ipv4 address using IAP.
if you want public ip you can expose it.
A Cloud Nat gateway named nat-config
IAP SSH permission
Firewall rule to allow access to jump host via IAP.
To provide outbound internet access for your private nodes, such as to pull images from an external registry, use Cloud NAT to create and configure a Cloud Router. Cloud NAT lets private clusters establish outbound connections over the internet to send and receive packets.

I added the bastion host’s internal IP in the private cluster’s master authorized network. This enabled secure connectivity only from the bastion host.

Pre-requisite:
A GCP Account with one Project.
Service Account. Make sure the SA must have appropriate permission. you can make it an owner role
gcloud CLI.
Terraform

clone the repository in your local assume you setup terrafom in your local

Step1. Run terraform init, fmt, validate, plan and apply.

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply



if everything goes as planned, the cluster should be up with all the workloads and services in a healthy state. For me, it took near about 20 mins to finish the deployment as you can see that resources have been created by Terraform. The same can be verified In UI.


Cloud NAT

Since this cluster’s public endpoint is disabled, we can not access it outside of GCP such that the internet. So how do we access it?

we have deployed a Bastion server within the same network with no public IP attached to it but you can still SSH to it over the internet with IAP.  This machine is already on the allowed list of the cluster’s authorized network.


This is a fresh machine that comes with glcoud cli already installed. You can use these tools to perform many common platform tasks from the command line or through scripts and other automation. In order to access your cluster from this machine, you will need to first authenticate with your google account and then install kubectl.

kubectl is a command-line tool, that allows you to run commands against Kubernetes clusters.

authenticate first with “gcloud auth login”


Copy this link into a browser and enter the authorization code. Once done, you should be in.

Install kubectl. I already installed it. click here to follow the installation steps. Once installed, Let’s connect cluster. copy command-line access from the UI.


sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin



Cluster will be accessible from the bastion host

Step1. install nginx ingress control
 helm repo add nginx-stable https://helm.nginx.com/stable
 helm repo update
 helm install nginx-ingress nginx-stable/nginx-ingress --set rbac.create=true

