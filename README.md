# 🚀 Kubernetes Cluster Setup using KOPS, Terraform & AWS CLI

This repository provides a step-by-step guide to provision a production-ready Kubernetes cluster using **KOPS**, **Terraform**, and **AWS CLI**. It automates the infrastructure setup, Route 53 DNS configuration, and Kubernetes cluster creation on AWS EC2 instances.

---

## 🧰 Prerequisites

Before you begin, ensure the following tools are installed on your machine:

- ✅ AWS CLI
- ✅ Terraform
- ✅ A Domain
- ✅ An AWS account
- ✅ Update your Hostname and Domain in **variables.tf** file **line 28**

---
## 🔐 Step 1: Create SSH Key Pairs and Configure AWS CLI Credentials
Generate a separate SSH key pair:
controller-key: for accessing the Kops Instance
``` bash
ssh-keygen -t rsa -f controller-key
```
then,
```bash
aws configure
```
You’ll be prompted for:

AWS Access Key ID

AWS Secret Access Key

Default region name (e.g. us-east-1)

Output format (e.g. json)

---

## ⚙️ Step 2: Provision Infrastructure with Terraform
Initialize and preview your Terraform setup:

```bash
terraform init
terraform plan
```
Export environment credentials if needed:
```bash
export AWS_ACCESS_KEY_ID=<your-access-key>
export AWS_SECRET_ACCESS_KEY=<your-secret-key>
```
Then apply the infrastructure changes:

``` bash
terraform apply
```

### 📌 Output
After a successful deployment:

✅ Route 53 DNS Zone ID is created and available

✅ Kops Instance Public IP is provisioned

✅ S3 Bucket Name for Kops state is created

✅ Two template commands to deploy the Kubernetes cluster from the Kops instance

---

## 🌐 Step 3: Configure Route 53 DNS
<li> After Route 53 is provisioned via Terraform:

<li> Go to AWS Route 53 → Hosted Zones.

<li> Copy the NS (Name Server) records.
<br> 

![NameServer Record](https://github.com/GitanshKapoor/Kubernetes-Cluster-Deployment-Using-KOPS-and-Terraform/blob/main/Documents//DNS.png)

<li>Go to your domain registrar (e.g., GoDaddy, Namecheap).
<li>Update the domain's nameservers to the AWS Route 53 NS records.
<br>
  
![NameServer Record](https://github.com/GitanshKapoor/Kubernetes-Cluster-Deployment-Using-KOPS-and-Terraform/blob/main/Documents//NameServer%20Record.png)

---

## 🖥️ Step 4: Connect to KOPS EC2 Controller Instance
SSH into the KOPS VM created by Terraform:

``` bash
chmod 600 controller-key && ssh -i "controller-key" ubuntu@<kops-ec2-ip>
```
If credentials are not already set, run:
``` bash
aws configure
```
You’ll be prompted for:

AWS Access Key ID

AWS Secret Access Key

Default region name (e.g. us-east-1)

Output format (e.g. json)

---

## ☸️ Step 5: Create Kubernetes Cluster with KOPS
Run the following command to create the cluster:

``` bash
kops create cluster \
  --name=<your-domain> \
  --state=s3://<your-kops-state-store> \
  --zones=us-east-1a,us-east-1b \
  --node-count=2 \
  --node-size=t3.small \
  --control-plane-size=t3.medium \
  --dns-zone=<your-domain> \
  --node-volume-size=12 \
  --control-plane-volume-size=12 \
  --ssh-public-key=/home/ubuntu/.ssh/id_rsa.pub
```
Replace:
- **your-domain.com** with your FQDN (e.g. example.yourdomain.com)
- **your-kops-state-store** with your S3 bucket name created automatically check

---

## 🔄 Step 6: Apply the KOPS Cluster Configuration
To build the cluster:

``` bash
kops update cluster \
  --name=<your-domain> \
  --state=s3://<your-kops-state-store> \
  --yes \
  --admin
```

Replace:
- **your-domain.com** with your FQDN (e.g. example.yourdomain.com)
- **your-kops-state-store** with your S3 bucket name created automatically check


---

## ✅ Step 7: Validate the Cluster
Wait for 6–7 minutes for the cluster to fully start, then verify that your Kubernetes cluster is up and running.
#### Option-1
``` bash
kops validate cluster --state=s3://<your-kops-state-store>
```
#### Option-2
On the Kops instance, run the following command to verify that the Kubernetes cluster is up and running:
``` bash
kubectl get nodes
```
![Cluster State](https://github.com/GitanshKapoor/Kubernetes-Cluster-Deployment-Using-KOPS-and-Terraform/blob/main/Documents/Cluster%20State.png)
<br>
#### Option-3
Navigate to the AWS Console → EC2 Resource Dashboard to verify that the Kubernetes cluster is up and running <br><br>
![Cluster Status](https://github.com/GitanshKapoor/Kubernetes-Cluster-Deployment-Using-KOPS-and-Terraform/blob/main/Documents/Cluster%20Status.png)

---

### 📁 Project Structure
```sh
.
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── route53.tf
│   └── security_group.tf
├── Documents
└── README.md
```
---
### 🧹 Cleanup
To destroy all the resources created by Terraform:

``` bash
terraform destroy
```
---

### ⚠️ Warning
- Ensure your domain is properly configured with Route 53
- S3 bucket used by KOPS must be in the same region as your cluster
- The SSH public key path must match the one on your local machine
- Always use a domain that you own and control
