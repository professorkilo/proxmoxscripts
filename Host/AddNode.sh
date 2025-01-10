#!/bin/bash
#
# AddNode.sh
#
# A script to join a new Proxmox node to an existing cluster using "pvecm add".
# Run **on the NEW node** that you want to add to the cluster.
#
# Usage:
#   ./AddNode.sh <cluster-IP> [<local-node-IP>]
#
# Example:
#   1) If you only have one NIC/IP (cluster IP is 172.20.120.65, local node IP is 172.20.120.66):
#      ./AddNode.sh 172.20.120.65 172.20.120.66
#      This internally runs:
#        pvecm add 172.20.120.65 --link0 172.20.120.66
#
#   2) If you do not specify <local-node-IP>, it will just do:
#      pvecm add 172.20.120.65
#      (No --link0 parameter)
#
# After running this script, you will be prompted for the 'root@pam' password
# of the existing cluster node (the IP you specify). Then Proxmox will transfer
# the necessary keys/config to this node, completing the cluster join.
#
# Note: This script removes any ringX/ringY references and simply uses
#       the '--link0' parameter if you provide a <local-node-IP>.

###############################################################################
# MAIN
###############################################################################

check_root          # Ensure script is run as root
check_proxmox       # Ensure script is running on a Proxmox node

CLUSTER_IP="$1"
LOCAL_NODE_IP="$2"  # Optional

if [[ -z "$CLUSTER_IP" ]]; then
  echo "Error: Missing cluster IP."
  echo "Usage: $0 <existing-cluster-IP> [<local-node-IP>]"
  exit 1
fi

# Check if node is already part of a cluster
if [[ -f "/etc/pve/.members" ]]; then
  echo "Detected /etc/pve/.members. This node may already be in a cluster."
  echo "Press Ctrl-C to abort, or wait 5 seconds to continue..."
  sleep 5
fi

cmd="pvecm add \"$CLUSTER_IP\""

if [[ -n "$LOCAL_NODE_IP" ]]; then
  cmd+=" --link0 \"$LOCAL_NODE_IP\""
fi

echo "=== Join Proxmox Cluster ==="
echo "Existing cluster IP: \"$CLUSTER_IP\""
if [[ -n "$LOCAL_NODE_IP" ]]; then
  echo "Using --link0 \"$LOCAL_NODE_IP\""
fi

echo
echo "Running command:"
echo "  $cmd"
echo
echo "You will be prompted for the 'root@pam' password of the EXISTING cluster node (\"$CLUSTER_IP\")."
echo

eval "$cmd"

echo
echo "=== Done ==="
echo "Check cluster status with:  pvecm status"
echo "You should see this node listed as part of the cluster."
