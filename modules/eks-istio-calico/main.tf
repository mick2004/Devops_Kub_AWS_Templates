module "vpc"{
    source = "terraform-aws-modules/vpc/aws"
    name = "eks-vpc"
    cidr = "10.0.0.0/16"

    azs = ["us-west-2a","us-west-2b"]
    private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
    public_subnets = ["10.0.101.0/24","10.0.102.0/24"]
    tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    cluster_name = var.cluster_name
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    

    eks_managed_node_groups = {
        eks_nodes = {

            desired_capacity = var.desired_capacity
            max_capacity = 1
            min_capacity = 1

            instance_type = var.node_instance_type
            iam_role_arn     = aws_iam_role.node_group_role.arn 

        }
    }
}

resource "aws_iam_role" "node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "node_group_policy" {
  name   = "eks-node-group-policy"
  role   = aws_iam_role.node_group_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:DescribeCluster"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_group_policy_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  role       = aws_iam_role.node_group_role.name
  policy_arn = each.value
}

