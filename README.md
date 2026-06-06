## Hunting compromised software dependencies inside Kubernetes workloads
This was created for **Workshop #1** of PlatformCon: <br/>
[Link to the PlatformCon session](https://platformcon.com/sessions/hunting-compromised-software-dependencies-inside-kubernetes-workloads)

<img width="664" height="581" alt="Screenshot 2026-06-06 at 21 32 18" src="https://github.com/user-attachments/assets/77c181e6-6920-4639-ba70-18f8667e3cb0" />


### Learning Outcomes
This practical, hands-on session covers Kubernetes incident response. Moving beyond theory, it uses a live workshop to hunt threats in real time.

**The workflow:**
- We'll poison a container image with dummy ```malicious software dependencies``` to see if we are able to detect malware in Kubernetes.
- Use data sources such as ```CVSS```, ```EPSS```, and CISA's ```KEV``` database to understand the likelihood of exploitation or if it's already been exploited.
- Finally, we'll use ```ExploitDB``` to identify examples of weaponised scripts actively targeting environments with the aforementioned vulnerability.

## Part 1: Poisoning a Kubernetes workload

