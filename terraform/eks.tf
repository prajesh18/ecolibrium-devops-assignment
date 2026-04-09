# ---------------- EKS CLUSTER ----------------
resource "aws_eks_cluster" "main" {
  name     = "ecolibrium-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn

  version = "1.29"

  vpc_config {
    subnet_ids = concat(
      aws_subnet.public[*].id,
      aws_subnet.private[*].id
    )
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}


# ---------------- NODE GROUP ----------------
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "ecolibrium-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = aws_subnet.private[*].id
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_policy
  ]
}
