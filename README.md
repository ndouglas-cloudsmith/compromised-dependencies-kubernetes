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
docker pull python:latest
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

<img width="1416" height="493" alt="Screenshot 2026-06-08 at 12 20 09" src="https://github.com/user-attachments/assets/146c20c5-aba4-4128-9b93-eb2e37e3e863" />


Tagging and pushing the docker image to Cloudsmith:
```
docker tag production-app:v1 docker.cloudsmith.io/acme-corporation/acme-repo-one/production-app:v1
docker push docker.cloudsmith.io/acme-corporation/acme-repo-one/production-app:v1
```

### Slopgate

**[Slopgate](https://github.com/nullracodes/slopgate)** is a CI gate designed to protect against slopsquatting and hallucinated dependencies for ```Python```, ```npm```, and ```Go```.
```
pip3 install git+https://github.com/nullracodes/slopgate --break-system-packages
```

<img width="1505" height="305" alt="Screenshot 2026-06-14 at 23 07 46" src="https://github.com/user-attachments/assets/43739bbf-40f6-46a2-be05-a926927cb3f3" />


Download a Python ```requirements.txt``` file and scan it using ```slopgate```
```
wget https://raw.githubusercontent.com/ndouglas-cloudsmith/compromised-dependencies-kubernetes/refs/heads/main/requirements.txt
slopgate scan requirements.txt
```

<img width="1505" height="561" alt="Screenshot 2026-06-14 at 23 15 05" src="https://github.com/user-attachments/assets/8a7ec7a5-c834-47fc-9549-7aadebccb5ad" />

```
slopgate scan requirements.txt --format sarif --output slopgate.sarif
cat slopgate.sarif
```

<img width="1505" height="904" alt="Screenshot 2026-06-14 at 23 23 25" src="https://github.com/user-attachments/assets/6b31d31e-58f4-4e4d-9a03-16e76b06f355" />


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

#### Deployment a malicious Kubernetes workload

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

This will generate a HTML report and serve it to localhost:8000
```
osv-scanner scan image docker.cloudsmith.io/acme-corporation/acme-repo-one/production-app:v1 --serve
```

<img width="1149" height="257" alt="Screenshot 2026-06-08 at 12 16 30" src="https://github.com/user-attachments/assets/51f925f9-da3c-4a3c-a907-f42b7c4914ce" />

<img width="1715" height="1268" alt="Screenshot 2026-06-08 at 12 18 12" src="https://github.com/user-attachments/assets/cc06bb32-07a6-40aa-89e9-ea613cc5a855" />



## Part 2: Exploit-Check.sh

In the next exercise, we will use **[Exploit-Check](https://github.com/ndouglas-cloudsmith/exploit-check)** to understand the severity of vulnerabilities found in our container images.
```
wget https://raw.githubusercontent.com/ndouglas-cloudsmith/exploit-check/refs/heads/main/exploit-check.sh
chmod +x exploit-check.sh
./exploit-check.sh update
```
To query a specific CVE, run the below command:
```
./exploit-check.sh query MAL-2026-2144 
```

<img width="1509" height="1186" alt="Screenshot 2026-06-08 at 12 24 35" src="https://github.com/user-attachments/assets/8d69a22b-2456-4531-aed0-3c8382300969" />

All malicious package reports are accessible directly in **[Github](https://github.com/ossf/malicious-packages/blob/main/osv/malicious/npm/grr-ui/MAL-2025-6.json)**. <br/>
Query the database to see if a specific package ```name```/```version``` is malicious **[MAL-2025-48401](https://osv.dev/vulnerability/MAL-2025-48401)**:

```
curl -s -d \
  '{"version": "1.10.2",
    "package": {"name": "supplychain-firewall-benchmark-hello", "ecosystem": "npm"}}' \
  "https://api.osv.dev/v1/query" | jq .
```

#### Exploitable vulnerabilities

This will generate a HTML report and serve it to localhost:8000
```
osv-scanner scan image docker.cloudsmith.io/acme-corporation/acme-repo-one/python:latest --serve
```

<img width="1267" height="1174" alt="Screenshot 2026-06-08 at 12 51 00" src="https://github.com/user-attachments/assets/b7311806-a65d-40dc-87f4-3499d6c7ea31" />

<img width="1362" height="1180" alt="Screenshot 2026-06-08 at 12 54 46" src="https://github.com/user-attachments/assets/9d5d9b6b-898c-40e7-b76a-329ec83e107e" />

```
./exploit-check.sh query CVE-2026-8376 
```

<img width="1505" height="436" alt="Screenshot 2026-06-08 at 12 56 40" src="https://github.com/user-attachments/assets/b8dfd079-48b1-46c4-89ff-a4ce0dc19ca1" />

#### Comparing CVSS scores with EPSS percentiles and check for Known Exploits

| CVE ID | CVSS Severity | CVSS Score | EPSS Percentage | KEV | ExploitDB | OSV |
| --- |:---------:|:---------:|:---------:|:---------:|:---------:|:---------:|
| `CVE-2021-45786` | **CRITICAL** | **9.8**  | 0.41%      | ❌ | ❌ | ❌ |
| `CVE-2024-0646`  | HIGH         |   7.0    | 0.02%      | ❌ | ❌ | ✅ |
| `CVE-2024-25062` | HIGH         |   7.5    | 0.11%      | ❌ | ❌ | ✅ |
| `CVE-2021-44228` | **CRITICAL** | **10.0** | **94.47%** | ✅ | ✅ | ✅ |
| `CVE-2024-38285` | ❌           |    ❌    | 0.08%      | ❌ | ❌ | ❌ |
| `CVE-2017-0144`  | HIGH         |   8.8    | **94.42%** | ✅ | ✅ | ❌ |
| `CVE-2024-20024` | MEDIUM       |   6.0    | 0.02%      | ❌ | ❌ | ❌ |
| `CVE-2014-0160`  | HIGH         |   7.5    | **94.45%** | ✅ | ✅ | ✅ |
| `CVE-2024-9482`  | MEDIUM       |   5.1    | 0.03%      | ❌ | ❌ | ❌ |
| `CVE-2017-5638`  | **CRITICAL** | **9.8**  | **94.27%** | ✅ | ✅ | N/A|
| `CVE-2024-28085` | LOW          |   3.3    | 9.83%      | ❌ | ❌ | ✅ |
| `CVE-2024-50302` | MEDIUM       |   5.5    | 0.30%      | ✅ | ❌ | ✅ |
| `CVE-2025-47273` | HIGH         | **8.8**  | 0.16%      | ❌ | ❌ | ✅ |
| `CVE-2024-6345`  | ❌           |    ❌    | 4.36%      | ❌ | ❌ | ✅ |
| `CVE-2016-5195`  | HIGH         |   7.0    | **94.18%** | ✅ | ✅ | ✅ |
| `CVE-2022-48477` | MEDIUM       |   4.1    | **0.00%**  | ❌ | ❌ | ❌ |


In the case of ```CVE-2016-5195```, it has a relatively **low CVSS** score, considering the likelihood of exploitation (**EPSS**) is very high:
```
./exploit-check.sh query CVE-2016-5195 
```

<img width="1507" height="513" alt="Screenshot 2026-06-08 at 14 59 29" src="https://github.com/user-attachments/assets/037a5bf0-113d-48f4-ac8f-d753436bfe30" />

## Part 3: ExploitPwned.sh

In this final exercise, we will use **[ExploitPwned](https://github.com/ndouglas-cloudsmith/ExploitPwned)** to understand how hackers are weaponising exploit scripts against these known vulnerabilities:
```
wget https://raw.githubusercontent.com/ndouglas-cloudsmith/ExploitPwned/refs/heads/main/exploitPwned.sh
chmod +x exploitPwned.sh
./exploitPwned.sh update
```

Use the scanner to look-up the vulnerability - ```CVE-2016-5195```
```
./exploitPwned.sh CVE-2016-5195
```

<img width="1507" height="559" alt="Screenshot 2026-06-08 at 15 04 41" src="https://github.com/user-attachments/assets/bcc22101-555e-475e-853a-d3856d148054" />


```
./exploitPwned.sh CVE-2016-5195 --details
```

<img width="1149" height="1174" alt="Screenshot 2026-06-08 at 15 29 17" src="https://github.com/user-attachments/assets/af715ba3-d5a3-4fab-9afe-abec21e57451" />


**[EDB-ID:40838](https://www.exploit-db.com/exploits/40838)** is correctly mapped to the CVE ID within the Exploit Database for the **Dirty COW** vulnerability. <br/>
Saying that, not all people in the security community publish those exploits ethically to the ExploitDB. <br/>
In some cases, they publish their **[POCs on Github](https://github.com/firefart/dirtycow)**.

<br/>

#### Ingress-NGINX Exploits
To prioritise the safety and security of the ecosystem, Kubernetes SIG Network and the Security Response Committee are announcing the upcoming [retirement of Ingress NGINX](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/). Best-effort maintenance will continue until March 2026. Afterward, there will be no further releases, no bugfixes, and no updates to resolve any security vulnerabilities that may be discovered. **Existing deployments of Ingress NGINX will continue to function and installation artifacts will remain available**.
```
./exploitPwned.sh CVE-2025-24514 --details
./exploitPwned.sh CVE-2025-1974 --details
./exploitPwned.sh CVE-2025-1098 --details
./exploitPwned.sh CVE-2025-1097 --details
```
This is an especially strange case where there's no ```KEV``` entry for ```CVE-2025-1974``` considering how actively it's present & exploited: <br/>
https://kubernetes.io/blog/2025/03/24/ingress-nginx-cve-2025-1974/
<br/>

#### Other Test Scenarios
CISA and its partners, through the Joint Cyber Defense Collaborative, responded to active, widespread exploitation of a critical remote code execution (RCE) vulnerability (CVE-2021-44228) in the [Apache Log4j](https://www.cisa.gov/news-events/news/apache-log4j-vulnerability-guidance) software library, versions 2.0-beta9 to 2.14.1, known as "Log4Shell." Log4j is very broadly used in a variety of consumer and enterprise services, websites, and apps (as well as in operational technology products) to log security and performance information. An unauthenticated remote actor could exploit this vulnerability to take control of an affected system.
```
./exploitPwned.sh CVE-2021-44228 --details
```
[Apache Struts](https://www.trendmicro.com/en_us/research/17/c/cve-2017-5638-apache-struts-vulnerability-remote-code-execution.html) is a free and open-source framework used to build Java web applications. We looked into past several Remote Code Execution (RCE) vulnerabilities reported in Apache Struts, and observed that in most of them, attackers have used Object Graph Navigation Language (OGNL) expressions. The use of OGNL makes it easy to execute arbitrary code remotely because Apache Struts uses it for most of its processes.
```
./exploitPwned.sh CVE-2017-5638 --details
```
[EternalBlue](https://en.wikipedia.org/wiki/EternalBlue) is a computer exploit software developed by the US National Security Agency ([NSA](https://www.wired.com/story/eternalblue-leaked-nsa-spy-tool-hacked-world/)) based on a zero-day vulnerability in Microsoft Windows SMB Remote Code Execution. In 2017, a computer worm in the form of ransomware, nicknamed "WannaCry", used the EternalBlue exploit to attack computers using Windows that had not received the latest system updates removing the vulnerability.
```
./exploitPwned.sh CVE-2017-0144 --details
```
[OpenSSL](https://www.cisa.gov/news-events/alerts/2014/04/08/openssl-heartbleed-vulnerability-cve-2014-0160) contained a flaw in its implementation of the TLS/DTLS heartbeat functionality, known as "Heartbleed". This flaw allows an attacker to retrieve private memory of an application that uses the vulnerable OpenSSL library in chunks of 64k at a time. Note that an attacker can repeatedly leverage the vulnerability to retrieve as many 64k chunks of memory as are necessary to retrieve the intended secrets.
```
./exploitPwned.sh CVE-2014-0160 --details
```

## Part 5: Creating a poisoined docker workload

To trigger malicious package flags in an ```osv-scanner``` lookup during a container scan, you don't actually need to install or run the malicious code. **OSV-Scanner** checks manifest files like ```package.json``` or lockfiles like ```package-lock.json``` to identify vulnerabilities. The cleanest and safest way to achieve this is to bake a dummy ```package.json``` file into a generic image. This flags the vulnerabilities perfectly without exposing your system to the actual malicious dependencies.
```
cat << 'EOF' > package-lock.json
{
  "name": "dummy-malware-test",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": {
      "name": "dummy-malware-test",
      "version": "1.0.0",
      "dependencies": {
        "mastra": "1.13.1",
        "mountly": "0.2.2",
        "xorma-js": "1.0.2"
      }
    },
    "node_modules/mastra": {
      "version": "1.13.1",
      "resolved": "https://registry.npmjs.org/mastra/-/mastra-1.13.1.tgz",
      "integrity": "sha512-dummyhash"
    },
    "node_modules/mountly": {
      "version": "0.2.2",
      "resolved": "https://registry.npmjs.org/mountly/-/mountly-0.2.2.tgz",
      "integrity": "sha512-dummyhash"
    },
    "node_modules/xorma-js": {
      "version": "1.0.2",
      "resolved": "https://registry.npmjs.org/xorma-js/-/xorma-js-1.0.2.tgz",
      "integrity": "sha512-dummyhash"
    }
  }
}
EOF
```

This ```Dockerfile``` uses a generic lightweight Alpine image, creates a directory, and copies the ```package.json``` file into it.
```
cat << 'EOF' > Dockerfile
FROM alpine:3.20

WORKDIR /usr/src/app

# Copy the lockfile into the container filesystem
COPY package-lock.json .

CMD ["/bin/sh"]
EOF
```

Build the image:
```
docker build -t boring-image:latest .
```

Check that it was successfulled built:
```
docker images | grep boring-image
```

Run the scanner against your newly built local Docker image:
```
osv-scanner scan image boring-image:latest
```
Because OSV-Scanner parses the filesystem of the container layers looking for known package manifests, it will locate ```/usr/src/app/package.json```, identify the pinned ecosystem versions, and correctly flag:
- ```MAL-2026-5965```
- ```MAL-2026-5260```
- ```MAL-2026-4734```


## PlatformCon 2026 Workshops

1. **[Hunting compromised software dependencies inside Kubernetes workloads](https://github.com/ndouglas-cloudsmith/compromised-dependencies-kubernetes/tree/main)**
2. [AI agents & platform engineering: Efficiency boost or new source of trouble?](https://github.com/ndouglas-cloudsmith/AI-agents-platform-engineering)
3. [Audit-ready Kubernetes: How to leverage policy-as-code for continuous compliance](https://github.com/ndouglas-cloudsmith/audit-ready-kubernetes/tree/main)
4. [The ghost in the machine: Securing AI agent skills](https://github.com/ndouglas-cloudsmith/ghost-in-the-machine/tree/main)
