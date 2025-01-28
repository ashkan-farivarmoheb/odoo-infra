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

#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${cluster_name} \
  --b64-cluster-ca ${cluster_auth_base64} \
  --apiserver-endpoint https://D1121A1AFB94089B6B7C6013E0E23A6A.gr7.ap-southeast-2.eks.amazonaws.com \
  --dns-cluster-ip 172.20.0.10