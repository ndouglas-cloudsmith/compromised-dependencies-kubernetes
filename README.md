## Hunting compromised software dependencies inside Kubernetes workloads
This was created for **Workshop #1** of PlatformCon: <br/>
[Link to the PlatformCon session](https://platformcon.com/sessions/hunting-compromised-software-dependencies-inside-kubernetes-workloads)

<img width="50%" height="581" alt="Screenshot 2026-06-06 at 21 32 18" src="https://github.com/user-attachments/assets/77c181e6-6920-4639-ba70-18f8667e3cb0" />


### Learning Outcomes
- We'll poison a container image with dummy ```malicious software dependencies``` to see if we are able to detect malware in Kubernetes.
- Use data from ```CVSS```, ```EPSS```, and CISA's ```KEV``` DB to understand the likelihood of exploit or if it's already exploited.
- Finally, we'll use ```ExploitDB``` to identify examples of weaponised scripts actively targeting environments with a vulnerability.

## Part 1: Poisoning a Kubernetes workload

Simple Docker Image pull and scan:
```
docker pull ollama/ollama:latest
```

```
osv-scanner scan image python:latest
```

For a full vulnerability report on the above image, use the below feature flags:
```
osv-scanner scan image python:latest --all-vulns
```

```
osv-scanner scan image --format vertical python:latest
```

Building our own poisoned Docker container. This ```Dockerfile``` generates harmless metadata strings that match the vulnerable versions you specified.

```
wget https://raw.githubusercontent.com/ndouglas-cloudsmith/compromised-dependencies-kubernetes/refs/heads/main/Dockerfile
docker build -t production-app:v1 .
```

Scan with OSV-Scanner
```
osv-scanner scan image production-app:v1 --all-vulns
```

Tagging and pushing the docker image to Cloudsmith:
```
docker tag production-app:v1 docker.cloudsmith.io/acme-corporation/acme-repo-one/production-app:v1
docker push docker.cloudsmith.io/acme-corporation/acme-repo-one/production-app:v1
```

#### Miscellaneous Commands
```
cloudsmith list packages acme-corporation/acme-repo-one -F pretty_json | jq --arg name "production-app" '.data[] | select(.display_name == $name)'
```

```
cloudsmith list packages acme-corporation/acme-repo-one -q "format:docker"
```

```
cloudsmith quarantine add acme-corporation/acme-repo-one/production-app-jrn9  -k "$CLOUDSMITH_API_KEY"
```
```
cloudsmith quarantine remove acme-corporation/acme-repo-one/production-app-jrn9  -k "$CLOUDSMITH_API_KEY"
```

List all local images:
```
docker images
```

Remove unwanted images:
```
docker rmi python:latest
```

```
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: production-app-deployment
  labels:
    app: production-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: production-app
  template:
    metadata:
      labels:
        app: production-app
    spec:
      containers:
      - name: production-app-container
        image: docker.cloudsmith.io/acme-corporation/acme-repo-one/production-app:v1
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          name: http
        resources:
          limits:
            cpu: "200m"
            memory: "256Mi"
          requests:
            cpu: "100m"
            memory: "128Mi"
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
EOF
```

List all images in Kubernetes pods:
```
kubectl get pods -A -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,IMAGES:.spec.containers[*].image'
```

Scan the public container image:
```
osv-scanner scan image docker.cloudsmith.io/acme-corporation/acme-repo-one/production-app:v1
```

## Part 2: Exploit-Check.sh

In the next exercise, we will use **[Exploit-Check](https://github.com/ndouglas-cloudsmith/exploit-check)** to understand the severity of vulnerabilities found in our container images.
```
wget https://raw.githubusercontent.com/ndouglas-cloudsmith/exploit-check/refs/heads/main/exploit-check.sh
chmod +x exploit-check.sh
```
Update the scanner databases before using it:
```
./exploit-check.sh update
```
To query a specific CVE, run the below command:
```
./exploit-check.sh query CVE-2021-44228
```


## PlatformCon 2026 Workshops

1. **[Hunting compromised software dependencies inside Kubernetes workloads](https://github.com/ndouglas-cloudsmith/compromised-dependencies-kubernetes/tree/main)**
2. [AI agents & platform engineering: Efficiency boost or new source of trouble?](https://github.com/ndouglas-cloudsmith/AI-agents-platform-engineering)
3. [Audit-ready Kubernetes: How to leverage policy-as-code for continuous compliance](https://github.com/ndouglas-cloudsmith/audit-ready-kubernetes/tree/main)
4. [The ghost in the machine: Securing AI agent skills](https://github.com/ndouglas-cloudsmith/ghost-in-the-machine/tree/main)
