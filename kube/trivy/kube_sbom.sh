#! /bin/bash
# Produce KBOM for kubernetes cluster in .kube/config-dso
# $1 is cluster ip

TRIVY_DB=${TRIVY_DB:-ghcr.io/aquasecurity/trivy-db,public.ecr.aws/aquasecurity/trivy-db}
TRIVY_JAVA_DB=${TRIVY_JAVA_DB:-ghcr.io/aquasecurity/trivy-java-db,public.ecr.aws/aquasecurity/trivy-java-db}
CLUSTER_IP=$1

if [ -z "$CLUSTER_IP" ]; then
        echo 'Missing mandatory cluster ip argument' >&2
        exit 1
fi

#create output directory
mkdir -p sboms

#generate sbom
docker run --rm \
    -v "$HOME"/.kube/config-dso-user:/root/.kube/config \
    -v ./sboms:/sboms \
    --add-host k8scp-dso:"$CLUSTER_IP" \
    aquasec/trivy k8s \
    --format cyclonedx \
    -o /sboms/mykbom.cdx.json

#scan sbom for vulnerabilities
docker run --rm \
    -it \
    -v "$HOME"/.kube/config-dso-admin:/root/.kube/config \
    -v "$HOME"/Library/Caches:/root/.cache/ \
    -v ./sboms:/sboms \
    -e TRIVY_DB_REPOSITORY="$TRIVY_DB" \
    -e TRIVY_JAVA_DB_REPOSITORY="$TRIVY_DB_JAVA" \
    --add-host k8scp-dso:"$CLUSTER_IP" \
    aquasec/trivy sbom \
    -f json \
    /sboms/mykbom.cdx.json \
    -o /sboms/mykbom.cdx.vex.json