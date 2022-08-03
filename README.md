# AWS Cluster of nodes thru Terraform
This project create a cluster of nodes in a VPC with 
1. One node designated as the 'coordinator'. File `/home/ec2-user/isCoordinator` is created on this node
1. All other nodes are designated 'worker'. Each worker has an entry in `/etc/hosts` to the coordinator internal IP
1. All nodes have an external IPv4 address, and are SSH-able. A SSH key is created and public key is installed on all hosts
1. Additionally a local hosts file 'vpc_hosts' is created to allow easy login to nodes
1. AWS Systems Manager policy/setup is performed on the nodes so that SSM run-command can be used on these nodes
1. Port 8080 (TCP) is open on the inter node security group 

## Pre reqs
- Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform) on your platform of choice
- Create an AWS User with below permission policies attached :
    - `arn:aws:iam::aws:policy/AmazonEC2FullAccess`
    - `arn:aws:iam::aws:policy/AmazonVPCFullAccess`
    - `arn:aws:iam::aws:policy/IAMFullAccess`
    - To be able to run SSM commands as this user, also attach an inline policy :
    ```
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:*"
            ],
            "Resource": "*"
        }
    ]
    }
    ```
- Drop to shell and assume the above AWS user

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | The project namespace to use for unique resource naming | `string` | `"VPC-CLUSTER"` | no |
| region | AWS region | `string` | `"us-west-2"` | no |
| coordinator_instance_type | Instance type for coordinator | `string` | `"r5.4xlarge"` | no |
| worker_instance_type | Instance type for workers | `string` | `"r5.2xlarge"` | no |
| worker_count | Number of worker instances needed | `number` | `1` | no |

## Outputs

Once the stack is deployed, you can use the locally created 'vpc_hosts' file to ssh into any host
```
ssh -F vpc_hosts coordinator
ssh -F vpc_hosts worker0
ssh -F vpc_hosts worker1
...
```


## Example usage

Edit the variables.tf to your liking then :
```
> terraform plan -out="deploy.tfplan"
....
Plan: 29 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + coordinator_conn_string = (known after apply)

> terraform apply "deploy.tfplan"
```

To destroy the full setup :
```
> terraform destroy
```

To just destroy the EC2 nodes (both coordinator and workers) :
```
> terraform destroy -target 'module.ec2.aws_instance.coordinator'
```
