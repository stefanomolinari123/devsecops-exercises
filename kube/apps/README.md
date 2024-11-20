# redis-leader deployment and service
kubectl apply -n dso-apps -f redis-leader-deployment.yaml
kubectl apply -n dso-apps -f redis-leader-service.yaml

# redis-follower deployment and service
kubectl apply -n dso-apps -f redis-follower-deployment.yaml
kubectl apply -n dso-apps -f redis-follower-service.yaml

# frontend deployment and service
kubectl apply -n dso-apps -f frontend-deployment.yaml
kubectl apply -n dso-apps -f frontend-service.yaml
kubectl scale deployment frontend -n dso-apps --replicas=5
