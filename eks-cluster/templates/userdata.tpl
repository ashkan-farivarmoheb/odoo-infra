#!/bin/bash
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -ex
/etc/eks/bootstrap.sh ${cluster_name} \
  --b64-cluster-ca ${cluster_auth_base64} \
  --apiserver-endpoint ${endpoint} \
  --dns-cluster-ip ${dns_cluster_ip} \
  --kubelet-extra-args "--node-labels=eks.amazonaws.com/nodegroup-image=${ami_id},eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=${cluster_name}-node-group" \
  --container-runtime containerd

--==MYBOUNDARY==--