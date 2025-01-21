variable "cluster_name" {
    default = "eks-istio-calico-cluster"
  
}

variable "region" {
    default = "us-west-2"
}

variable "node_instance_type" {

    default = "t3.medium"
  
}

variable "desired_capacity" {
  
  default = 2
}