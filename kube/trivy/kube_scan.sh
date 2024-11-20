#! /bin/bash
# SCAN cluster for vulnerabilities
# $1 is cluster ip

TRIVY_DB=${TRIVY_DB:-ghcr.io/aquasecurity/trivy-db,public.ecr.aws/aquasecurity/trivy-db}
TRIVY_JAVA_DB=${TRIVY_JAVA_DB:-ghcr.io/aquasecurity/trivy-java-db,public.ecr.aws/aquasecurity/trivy-java-db}
CLUSTER_IP=$1

if [ -z "$CLUSTER_IP" ]; then
    echo 'Missing mandatory cluster ip argument' >&2
    exit 1
fi

namespaces=dso-apps
resources=deployment,pods
report_type=summary # or all

mkdir -p "$HOME"/Library/Caches

# start scanning k8s cluster @ provided ip
docker run --rm \
    -it \
    -v "$HOME"/.kube/config-dso-user:/root/.kube/config:z \
    -v "$HOME"/Library/Caches:/root/.cache/:z \
    -e TRIVY_DB_REPOSITORY="$TRIVY_DB" \
    -e TRIVY_JAVA_DB_REPOSITORY="$TRIVY_DB_JAVA" \
    --add-host k8scp-dso:"$CLUSTER_IP" \
    aquasec/trivy k8s \
    --severity HIGH,CRITICAL \
    --include-namespaces $namespaces \
    --include-kinds $resources \
    --report $report_type
