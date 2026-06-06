## Hunting compromised software dependencies inside Kubernetes workloads
This was created for **Workshop #1** of PlatformCon: <br/>
[Link to the PlatformCon session](https://platformcon.com/sessions/hunting-compromised-software-dependencies-inside-kubernetes-workloads)

<img width="100%" height="581" alt="Screenshot 2026-06-06 at 21 32 18" src="https://github.com/user-attachments/assets/77c181e6-6920-4639-ba70-18f8667e3cb0" />


### Learning Outcomes
- We'll poison a container image with dummy ```malicious software dependencies``` to see if we are able to detect malware in Kubernetes.
- Use data from ```CVSS```, ```EPSS```, and CISA's ```KEV``` DB to understand the likelihood of exploit or if it's already exploited.
- Finally, we'll use ```ExploitDB``` to identify examples of weaponised scripts actively targeting environments with a vulnerability.

## Part 1: Poisoning a Kubernetes workload

