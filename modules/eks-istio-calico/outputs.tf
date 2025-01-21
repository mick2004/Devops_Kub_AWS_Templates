output "cluster_name" {
  value = module.eks.cluster_name  # Correct reference
}

output "cluster_endpoint" {
  value = data.aws_eks_cluster.eks.endpoint  # No change required here
}

output "kubeconfig" {
  value = <<EOT
apiVersion: v1
clusters:
- cluster:
    server: ${data.aws_eks_cluster.eks.endpoint}
    certificate-authority-data: ${data.aws_eks_cluster.eks.certificate_authority[0].data}
  name: ${module.eks.cluster_name}
contexts:
- context:
    cluster: ${module.eks.cluster_name}
    user: ${module.eks.cluster_name}
  name: ${module.eks.cluster_name}
current-context: ${module.eks.cluster_name}
kind: Config
preferences: {}
users:
- name: ${module.eks.cluster_name}
  user:
    token: ${data.aws_eks_cluster_auth.eks.token}
EOT
  sensitive = true
}
