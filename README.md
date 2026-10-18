# Enterprise DevOps AWS EKS Capstone

## Project Overview

This project demonstrates the containerization, deployment, monitoring, scaling, and troubleshooting of three applications using AWS and Kubernetes.

The objective was to build a production-style cloud deployment environment and gain hands-on experience managing containerized workloads on Amazon EKS.

## Applications

The platform consists of three applications:

| Application | Port | Description |
|---|---|---|
| Action Messages | 5001 | Flask-based messaging and notification service |
| TechPathway Warehouse | 5002 | Flask-based warehouse application |
| Weekly Call | 5111 | Application that integrates with other platform services |

Each application has its own Dockerfile, Kubernetes Deployment, and Kubernetes Service.

## Technologies Used

- **Git and GitHub:** Source code management and version control
- **Docker:** Containerization of applications
- **Amazon ECR:** Storage of Docker images
- **Amazon EKS:** Managed Kubernetes cluster
- **Kubernetes:** Container orchestration and application management
- **Amazon RDS MySQL:** Managed relational database
- **Kubernetes ConfigMaps and Secrets:** Application configuration
- **Horizontal Pod Autoscaler:** CPU-based application autoscaling
- **Prometheus:** Metrics collection and monitoring
- **Grafana:** Visualization of infrastructure metrics
- **Amazon CloudWatch:** AWS infrastructure monitoring
- **Helm:** Kubernetes package management
- **AWS CLI and kubectl:** Infrastructure and Kubernetes administration

## Architecture

The application deployment follows this workflow:

```text
Application Source Code
         |
         v
     Docker Build
         |
         v
     Amazon ECR
         |
         v
     Amazon EKS
         |
         v
 Kubernetes Deployments
         |
         v
   Application Pods
         |
         v
 Kubernetes Services
         |
         +---- Action Messages :5001
         |
         +---- Warehouse :5002
         |
         +---- Weekly Call :5111
                    |
                    v
              Amazon RDS MySQL

Monitoring:
EKS Workloads --> Prometheus --> Grafana
EKS / AWS Resources --> Amazon CloudWatch
```

The applications use Kubernetes Services for internal communication. Application configuration is provided through ConfigMaps and Secrets.

## 1. Docker Containerization

Each application was packaged into a Docker image.

Dockerfiles were configured with application dependencies, Gunicorn startup commands, exposed ports, and a non-root application user.

Example build command:

```bash
docker build --platform linux/amd64 -t action-messages:local ./action-messages
```

The images were tested locally before being pushed to Amazon ECR.

## 2. Amazon ECR

Three Amazon ECR repositories were used to store the container images:

- action-messages
- techpathway-warehouse
- weekly-call

Docker images were tagged and pushed to their respective repositories.

Kubernetes Deployments reference these images when creating application Pods.

## 3. Amazon EKS Deployment

An Amazon EKS cluster was provisioned in the AWS `us-east-1` Region.

The cluster used managed worker nodes to run the containerized applications.

A dedicated Kubernetes namespace named `techpathway` was used to organize application resources.

Example deployment commands:

```bash
kubectl apply -f kubernetes/action-messages-deployment.yaml
kubectl apply -f kubernetes/action-messages-service.yaml

kubectl apply -f kubernetes/techpathway-warehouse-deployment.yaml
kubectl apply -f kubernetes/techpathway-warehouse-service.yaml

kubectl apply -f kubernetes/weekly-call-deployment.yaml
kubectl apply -f kubernetes/weekly-call-service.yaml
```

These commands assume the namespace, ConfigMap, Secrets, database connectivity, and container images have already been configured.

## 4. Kubernetes Services

Each application was exposed internally using a Kubernetes ClusterIP Service.

| Service | Port |
|---|---|
| action-messages | 5001 |
| techpathway-warehouse | 5002 |
| weekly-call | 5111 |

Services provide stable internal network endpoints for application communication.

## 5. Database Integration

Amazon RDS MySQL was used as the managed database service.

The database was deployed privately, with access controlled through AWS networking and security groups.

Application database configuration was provided through Kubernetes Secrets.

Real database credentials are intentionally excluded from this repository.

## 6. Horizontal Pod Autoscaling

The Action Messages application was configured with a Horizontal Pod Autoscaler.

HPA configuration:

- Minimum replicas: 2
- Maximum replicas: 6
- CPU utilization target: 70%

The HPA monitors CPU utilization and adjusts the number of application Pods when scaling conditions are met.

Example verification:

```bash
kubectl get hpa -n techpathway
kubectl top pods -n techpathway
```

## 7. Monitoring

### Prometheus

Prometheus was deployed using Helm to collect Kubernetes infrastructure metrics.

### Grafana

Grafana was configured with Prometheus as a data source to visualize cluster and workload metrics.

### Amazon CloudWatch

CloudWatch Observability components were used to support AWS and Kubernetes monitoring.

Monitoring helps identify resource usage, application health, and infrastructure problems.

## 8. Kubernetes Troubleshooting

Six troubleshooting scenarios were performed using the deployed applications.

| Scenario | Application | Root Cause | Resolution |
|---|---|---|---|
| ImagePullBackOff | Action Messages | Invalid container image tag | Restored valid ECR image tag |
| CrashLoopBackOff | Warehouse | Container startup command exited with code 1 | Restored original container startup command |
| Pending Pod | Weekly Call | CPU request exceeded available node capacity | Restored valid CPU resource requests |
| Incorrect Container Port | Weekly Call | Service targetPort incorrectly set to 9999 | Restored targetPort to 5111 |
| Failed Readiness Probe | Action Messages | Incorrect readiness endpoint returned HTTP 404 | Restored `/health` endpoint |
| Failed Liveness Probe | Warehouse | Incorrect liveness endpoint returned HTTP 404 | Restored `/health` endpoint |

### Troubleshooting Commands

```bash
kubectl get pods -n techpathway
kubectl describe pod <pod-name> -n techpathway
kubectl logs <pod-name> -n techpathway
kubectl logs <pod-name> -n techpathway --previous
kubectl get deployments -n techpathway
kubectl get services -n techpathway
kubectl get hpa -n techpathway
```

These commands were used to identify Pod failures, investigate Kubernetes Events, review container logs, and verify recovery.

## 9. Resource Cleanup

Resource cleanup is performed after project verification and documentation.

The cleanup plan includes:

1. Delete application Deployments and Services.
2. Remove the Horizontal Pod Autoscaler.
3. Delete the application namespace.
4. Uninstall Prometheus and Grafana.
5. Check and remove associated persistent storage and monitoring resources.
6. Delete the Amazon EKS cluster.
7. Delete Amazon ECR repositories.
8. Review remaining AWS resources, including RDS, load balancers, networking, and CloudWatch resources.

All AWS resources should be verified before and after deletion to avoid unexpected charges.

## 10. Project Verification

Useful commands include:

```bash
kubectl get nodes
kubectl get deployments -n techpathway
kubectl get pods -n techpathway
kubectl get services -n techpathway
kubectl get hpa -n techpathway
kubectl get pvc -A
helm list -A
```

These commands help verify infrastructure readiness, application health, scaling configuration, monitoring installations, and storage.

## 11. Key Learning Outcomes

This project provided practical experience in:

- Building secure Docker images
- Publishing images to Amazon ECR
- Deploying applications on Amazon EKS
- Managing Kubernetes Deployments and Services
- Connecting applications to Amazon RDS
- Configuring application autoscaling
- Monitoring Kubernetes workloads
- Diagnosing and resolving common Kubernetes failures
- Managing cloud resources and performing cleanup

## Conclusion

The Enterprise DevOps AWS EKS Capstone demonstrates an end-to-end deployment workflow for three containerized applications.

The project combines containerization, cloud infrastructure, Kubernetes orchestration, monitoring, autoscaling, and hands-on troubleshooting to demonstrate practical DevOps engineering skills.

**Project Repository:** https://github.com/abiyecomgit/Enterprise-DevOps-AWS-EKS-Capstone
