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

List all local images:
```
docker images
```

Remove unwanted images:
```
docker rmi python:latest
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
