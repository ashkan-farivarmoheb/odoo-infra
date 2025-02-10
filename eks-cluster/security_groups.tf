# # Security group for the EKS cluster control plane
# resource "aws_security_group" "eks_cluster_sg" {
#   name        = "eks-cluster-sg"
#   description = "Security group for the EKS cluster control plane"
#   vpc_id      = data.aws_vpc.odoo.id

#   # Allow all egress traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.environment}-${var.project}-eks-cluster-sg"
#   }
# }

# # Security group for EKS worker nodes
# resource "aws_security_group" "eks_worker_sg" {
#   name        = "eks-worker-sg"
#   description = "Security group for EKS worker nodes"
#   vpc_id      = data.aws_vpc.odoo.id

#   # Allow all egress traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.environment}-${var.project}-eks-worker-sg"
#   }
# }

# # # Allow worker nodes to communicate with the cluster API Server
# # resource "aws_security_group_rule" "eks_worker_to_cluster" {
# #   type                     = "ingress"
# #   from_port                = 443
# #   to_port                  = 443
# #   protocol                 = "tcp"
# #   security_group_id        = aws_security_group.eks_cluster_sg.id
# #   source_security_group_id = aws_security_group.eks_worker_sg.id
# #   description             = "Allow worker nodes to communicate with cluster API Server"
# # }

# # # Allow cluster control plane to communicate with worker nodes (kubelet)
# # resource "aws_security_group_rule" "eks_cluster_to_worker_kubelet" {
# #   type                     = "ingress"
# #   from_port                = 10250
# #   to_port                  = 10250
# #   protocol                 = "tcp"
# #   security_group_id        = aws_security_group.eks_worker_sg.id
# #   source_security_group_id = aws_security_group.eks_cluster_sg.id
# #   description             = "Allow cluster control plane to communicate with worker kubelet"
# # }

# # # Allow cluster control plane to communicate with worker nodes (https)
# # resource "aws_security_group_rule" "eks_cluster_to_worker_https" {
# #   type                     = "ingress"
# #   from_port                = 443
# #   to_port                  = 443
# #   protocol                 = "tcp"
# #   security_group_id        = aws_security_group.eks_worker_sg.id
# #   source_security_group_id = aws_security_group.eks_cluster_sg.id
# #   description             = "Allow cluster control plane to communicate with worker nodes (https)"
# # }

# # # Allow worker nodes to communicate with each other
# # resource "aws_security_group_rule" "eks_worker_self_communication" {
# #   type                     = "ingress"
# #   from_port                = 0
# #   to_port                  = 65535
# #   protocol                 = "-1"  # Allow all protocols
# #   security_group_id        = aws_security_group.eks_worker_sg.id
# #   source_security_group_id = aws_security_group.eks_worker_sg.id
# #   description             = "Allow worker nodes to communicate with each other"
# # }
