# AWS EKS Cluster Deployment with Terraform and Vault

This project demonstrates how to deploy a highly available EKS (Elastic Kubernetes Service) cluster on AWS using Terraform. The deployment process integrates with HashiCorp Vault to securely manage AWS credentials. This guide provides a step-by-step setup of the VPC, EKS cluster, IAM roles, and how to retrieve Kubernetes configuration securely.

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
2. [HashiCorp Vault](https://www.vaultproject.io/docs/install) installed and configured with policies and roles.
3. [AWS CLI](https://aws.amazon.com/cli/) installed and configured with necessary permissions.
4. [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for managing your EKS cluster.

## Project Structure

```plaintext
project/
├── main.tf                   # Main Terraform configuration (Vault, EKS module)
├── variable.tf               # Variables for Vault and AWS configuration
├── outputs.tf                # Output values like EKS cluster endpoint, security group ID
├── aws/
│   └── eks/
│       ├── iam.tf            # IAM roles and policies for EKS
│       ├── provider.tf       # AWS provider configuration
│       ├── security.tf       # Security group definitions
│       ├── variable.tf       # Variables for AWS configuration
│       ├── vpc.tf            # VPC and subnet definitions
│       └── main.tf           # EKS cluster configuration
├── configs/
│   └── kubeconfig_<cluster_name>  # Generated kubeconfig for EKS
└── README.md                 # README file (that you currently reading)
```

## How to Deploy the EKS Cluster

### 1. Configure Vault

Ensure Vault is configured with the required policies and AppRoles to manage AWS credentials. You can follow the Vault setup as outlined in this project.

### 2. Set Environment Variables

You need to set the Vault role ID and secret ID as environment variables:

```bash
export TF_VAR_vault_role_id=<your-vault-role-id>
export TF_VAR_vault_secret_id=<your-vault-secret-id>
```

### 3. Deploy with Terraform

Run the following commands to initialize and apply the Terraform configurations:

```bash
terraform init
terraform apply
```

This will provision the VPC, subnets, IAM roles, security groups, and EKS cluster.

### 4. Retrieve kubeconfig

After the deployment is complete, you can retrieve the `kubeconfig` file to access your Kubernetes cluster: 

```bash
aws eks update-kubeconfig --region <aws-region> --name <eks-cluster-name>
```

This command will generate a `kubeconfig` file to manage the EKS cluster using `kubectl`. (or ./configs/kubeconfig location)

### 5. Outputs

Once the Terraform deployment is complete, the following outputs will be available:
- **EKS Cluster Endpoint**: The control plane endpoint for accessing the cluster.
- **Security Group ID**: The security group associated with the EKS control plane.
- **Cluster Name**: The name of the EKS cluster.
- **Kubeconfig File**: Kubeconfig file will be located at ./configs folder

## Adding IAM Users as Cluster Admins

To give an IAM user administrative access to the EKS cluster, you need to perform the following steps:

### 1. Create IAM Identity Mapping

Run the following command to map the IAM user to a Kubernetes user:

```bash
eksctl create iamidentitymapping \
    --cluster eks-cluster \
    --region us-west-2 \
    --arn <ARN-of-IAM-User> \
    --username iam-admin-k8s
```

This maps the IAM user to the Kubernetes username `iam-admin-k8s`.

### 2. Define Cluster Role and Role Binding

Create the following `ClusterRole` to allow managing pods:

#### `cluster_role.yaml`

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-manage-role
rules:
  - apiGroups:
      - "rbac.authorization.k8s.io/v1"
    resources:
      - "pods"
    verbs:
      - "create"
      - "delete"
      - "describe"
      - "get"
      - "list"
      - "patch"
      - "update"
```

Apply this role using:

```bash
kubectl apply -f cluster_role.yaml
```

### 3. Create Cluster Role Binding

Bind the IAM user to the role created above:

#### `role_binding.yaml`

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: pod-manage-binding
subjects:
- kind: User
  name: iam-admin-k8s  # Username declared in eksctl command
roleRef:
  kind: Role
  name: pod-manage-role # Role name declared in cluster_role.yaml
  apiGroup: rbac.authorization.k8s.io
```

Apply this role binding using:

```bash
kubectl apply -f role_binding.yaml
```

The IAM user will now have pod management capabilities within the EKS cluster.