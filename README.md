#### Hunting compromised software dependencies inside Kubernetes workloads
This was created for workshop no.1 of PlatformCon: <br/>
https://platformcon.com/sessions/hunting-compromised-software-dependencies-inside-kubernetes-workloads

##### Learning Outcomes
This practical, hands-on session covers Kubernetes incident response. Moving beyond theory, it uses a live workshop to hunt threats in real time.

**The workflow:**
- We'll poison a container image with dummy ```malicious software dependencies``` to see if we are able to detect malware in Kubernetes.
- Use data sources such as ```CVSS```, ```EPSS```, and CISA's ```KEV``` database to understand the likelihood of exploitation or if it's already been exploited.
- Finally, we'll use ```ExploitDB``` to identify examples of weaponised scripts actively targeting environments with the aforementioned vulnerability.

## Part 1: Poisoning a Kubernetes workload

