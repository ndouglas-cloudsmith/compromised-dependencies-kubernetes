#### Hunting compromised software dependencies inside Kubernetes workloads
This was created for workshop no.1 of PlatformCon: <br/>
https://platformcon.com/sessions/hunting-compromised-software-dependencies-inside-kubernetes-workloads

## Learning Outcomes
This practical, hands-on session covers Kubernetes incident response. Moving beyond theory, it uses a live workshop to hunt threats in real time.

The workflow:
• A container intentionally "poisoned" with dummy dependencies will be launched into a Kubernetes workload.
• The session will pivot to detection by scanning malicious dependencies against the OpenSSF Malicious Packages API (OSV.dev).
• Data sources such as CVSS and EPSS, along with information from CISA's KEV index and Exploit Database, will be used to identify examples of weaponized scripts actively targeting the environment.

## Part 1: Poisoning a Kubernetes workload

