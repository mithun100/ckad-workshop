#!/usr/bin/env bash
# Reset the local lab cluster to a clean state before a demo.
#
# Usage: ./reset-lab.sh [-y] [--files]
#   -y       skip the confirmation prompt
#   --files  also delete local scratch YAML/properties files created during practice
#
# Removes: Helm releases, every non-system namespace, all workload/config/network/storage
# objects in `default`, and all PersistentVolumes.
# Keeps: system namespaces, ingress-nginx (slow to reinstall), the `kubernetes` Service,
# the default ServiceAccount and the kube-root-ca.crt ConfigMap.

set -uo pipefail
cd "$(dirname "$0")"

ASSUME_YES=false
CLEAN_FILES=false
for arg in "$@"; do
  case "$arg" in
    -y) ASSUME_YES=true ;;
    --files) CLEAN_FILES=true ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

# Namespaces that are never deleted and never have Helm releases removed.
PROTECTED_NS="default kube-system kube-public kube-node-lease local-path-storage ingress-nginx"

# Untracked/ignored practice files that are safe to wipe.
SCRATCH_FILES="
01-pods-and-configuration/app.properties
01-pods-and-configuration/checkout-pod.yaml
01-pods-and-configuration/pod.yaml
01-pods-and-configuration/test.yaml
02-workloads-and-networking/job.yaml
02-workloads-and-networking/job_3.yaml
02-workloads-and-networking/manifests/job_2.yaml
02-workloads-and-networking/network-policy-default-deny-ingress.yaml
checkout-pod.yaml
"

is_protected() {
  case " $PROTECTED_NS " in *" $1 "*) return 0 ;; *) return 1 ;; esac
}

command -v kubectl >/dev/null || { echo "kubectl not found" >&2; exit 1; }
CTX=$(kubectl config current-context 2>/dev/null) || { echo "No kubectl context set" >&2; exit 1; }

echo "Cluster context: $CTX"
if ! $ASSUME_YES; then
  read -r -p "Delete all lab resources in this cluster? [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

echo "==> Uninstalling Helm releases"
if command -v helm >/dev/null; then
  helm list -A -o json 2>/dev/null \
    | tr '{' '\n' \
    | sed -n 's/.*"name":"\([^"]*\)".*"namespace":"\([^"]*\)".*/\1 \2/p' \
    | while read -r rel ns; do
        is_protected "$ns" && [ "$ns" != "default" ] && continue
        helm uninstall "$rel" -n "$ns" --wait --timeout 120s
      done
fi

echo "==> Deleting custom namespaces"
for ns in $(kubectl get ns -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'); do
  is_protected "$ns" || kubectl delete ns "$ns" --wait=false
done

echo "==> Cleaning the default namespace"
KINDS="deployments.apps replicasets.apps statefulsets.apps daemonsets.apps cronjobs.batch jobs.batch \
horizontalpodautoscalers.autoscaling pods services ingresses.networking.k8s.io \
networkpolicies.networking.k8s.io configmaps secrets persistentvolumeclaims \
serviceaccounts rolebindings.rbac.authorization.k8s.io roles.rbac.authorization.k8s.io \
resourcequotas limitranges"
for kind in $KINDS; do
  kubectl get "$kind" -n default -o name 2>/dev/null \
    | grep -vE '^(service/kubernetes|configmap/kube-root-ca\.crt|serviceaccount/default)$' \
    | xargs -r kubectl delete -n default --wait=false --ignore-not-found >/dev/null 2>&1
done

echo "==> Deleting PersistentVolumes"
kubectl delete pv --all --wait=false >/dev/null 2>&1

echo "==> Resetting context namespace to default"
kubectl config set-context --current --namespace=default >/dev/null

echo "==> Waiting for pods to terminate (up to 60s)"
for _ in $(seq 1 30); do
  left=$(kubectl get pods -A --no-headers 2>/dev/null \
    | awk '$1 !~ /^(kube-system|kube-public|kube-node-lease|local-path-storage|ingress-nginx)$/' | wc -l)
  [ "$left" -eq 0 ] && break
  sleep 2
done

if $CLEAN_FILES; then
  echo "==> Removing scratch files"
  for f in $SCRATCH_FILES; do
    [ -e "$f" ] && rm -v -- "$f"
  done
fi

echo
echo "Remaining in default:"
kubectl get all,cm,secret,pvc,ingress,networkpolicy -n default 2>&1
echo
echo "Lab reset complete. Note: aliases (k, kn) and 'export do' are per-shell; re-run 00-setup if you opened a new terminal."
