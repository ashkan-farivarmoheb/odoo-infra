#!/bin/bash
set -o xtrace
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    apiServerEndpoint: ${endpoint}
    certificateAuthority: ${cluster_auth_base64}
    cidr: ${service_ipv4_cidr}
    name: ${cluster_name}
  kubelet:
    config:
      maxPods: 58
      clusterDNS:
      - ${dns_cluster_ip}
    flags:
    - "--node-labels=eks.amazonaws.com/nodegroup-image=${ami_id},eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=${cluster_name}-node-group"

--//--