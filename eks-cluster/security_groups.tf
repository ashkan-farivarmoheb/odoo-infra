# Security group for the EKS cluster control plane
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for the EKS cluster control plane"
  vpc_id      = data.aws_vpc.odoo.id

  # Allow all egress traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for EKS worker nodes
resource "aws_security_group" "eks_worker_sg" {
  name        = "eks-worker-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = data.aws_vpc.odoo.id

  # Allow all egress traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow worker nodes to communicate with the cluster API server
resource "aws_security_group_rule" "eks_worker_to_cluster" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_worker_sg.id
}

# Allow the cluster to communicate with worker nodes
resource "aws_security_group_rule" "eks_cluster_to_worker" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_worker_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
}

# Allow worker nodes to communicate with each other (optional)
resource "aws_security_group_rule" "eks_worker_self_communication" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_worker_sg.id
  cidr_blocks       = ["10.0.0.0/16"] # Use your VPC CIDR
}
