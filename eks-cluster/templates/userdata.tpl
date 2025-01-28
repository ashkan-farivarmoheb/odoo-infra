#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${cluster_name} \
  --b64-cluster-ca ${cluster_auth_base64} \
  --apiserver-endpoint ${endpoint} \
  --dns-cluster-ip ${dns_cluster_ip} \
  --kubelet-extra-args "--node-labels=eks.amazonaws.com/nodegroup-image=${ami_id},eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=${cluster_name}-node-group"