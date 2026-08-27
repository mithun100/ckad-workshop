# Services and Networking

`checkout-api-deploy` now runs 3 pods — but pods are ephemeral and each has its own throwaway IP.
Something stable has to sit in front of them. That's a **Service**, and this is where the label
choice you made back in Module 1 finally pays off (or bites you).

## Why the Module 1 labels matter here

A Service doesn't know about Deployments or pods by name — it finds its backends purely by
**label selector**. The pods behind `checkout-api-deploy` carry `app=checkout,tier=backend`
(chosen in Module 1). Our Service selects on those exact labels. Mislabel the pods and the Service
matches nothing — the failure we deliberately trigger at the end.

## ClusterIP Service (instructor demo)

The default Service type — a stable internal IP and DNS name, reachable from inside the cluster.

```yaml
# manifests/service-clusterip.yaml
apiVersion: v1
kind: Service
metadata:
  name: checkout-api
spec:
  type: ClusterIP
  selector:
    app: checkout
    tier: backend
  ports:
  - port: 80
    targetPort: 80
```

```bash
k apply -f manifests/service-clusterip.yaml
k get svc checkout-api
k get endpoints checkout-api
```

**What to observe:** `get endpoints` lists the IPs of all 3 backend pods. A populated `Endpoints`
list is proof the selector matched. This is the single most useful Service debugging command.

Expose imperatively too (the exam-fast way):

```bash
k expose deployment checkout-api-deploy --name=checkout-api --port=80 --target-port=80
```

## DNS verification (instructor demo)

Every Service gets an in-cluster DNS name: `<service>.<namespace>.svc.cluster.local`. Verify it
resolves from a throwaway pod.

```bash
k run tmp --image=busybox --rm -it --restart=Never -- nslookup checkout-api
```

**What to observe:** `nslookup` returns the Service's ClusterIP. That name is how other pods
(like a future frontend) reach `checkout-api` — never by pod IP.

> **Exam Tip:** Service DNS is `checkout-api` within the same namespace, or
> `checkout-api.<namespace>.svc.cluster.local` across namespaces. If a pod can't reach a Service,
> `nslookup` from a temp pod tells you instantly whether it's a DNS problem or a selector problem.

## NodePort Service (semi-guided)

NodePort opens a fixed port (30000–32767) on every node, forwarding to the Service. Build this one
using the ClusterIP manifest as reference — expose `checkout-api-deploy` on nodePort `30080`.

<details>
<summary>Solution</summary>

```yaml
# manifests/service-nodeport.yaml
apiVersion: v1
kind: Service
metadata:
  name: checkout-api-nodeport
spec:
  type: NodePort
  selector:
    app: checkout
    tier: backend
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

```bash
k apply -f manifests/service-nodeport.yaml
k get svc checkout-api-nodeport
```
</details>

**The three ports, straight:** `targetPort` = the container's port, `port` = the Service's own
port, `nodePort` = the port opened on each node. Traffic flows nodePort → port → targetPort.

## NetworkPolicy (instructor demo)

By default every pod can talk to every other pod. A NetworkPolicy locks that down. This one says:
only `app=checkout,tier=frontend` pods may reach `tier=backend` on port 80.

```yaml
# manifests/networkpolicy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: checkout-api-allow-frontend
spec:
  podSelector:
    matchLabels:
      app: checkout
      tier: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: checkout
          tier: frontend
    ports:
    - protocol: TCP
      port: 80
```

```bash
k apply -f manifests/networkpolicy.yaml
k describe networkpolicy checkout-api-allow-frontend
```

> **Exam Tip:** NetworkPolicies are **additive and default-deny once a pod is selected**: the
> moment a policy selects a pod, everything not explicitly allowed is blocked. Also — enforcement
> needs a CNI that supports it (Calico, Cilium). On Docker Desktop the policy applies but nothing
> is actually blocked, so test enforcement on a cluster that supports it. In the exam, it's enforced.

## Break it / troubleshoot (instructor-led, ~4 minutes)

Apply a Service whose selector matches no pods.

```bash
k apply -f manifests/broken-service.yaml
k get svc checkout-api-broken
k get endpoints checkout-api-broken
```

**What you'll see:** the Service exists and has a ClusterIP, but `ENDPOINTS` is `<none>` — nothing
is behind it, so every request fails.

**Ask the room:** "The Service looks fine in `get svc`. Where's the actual problem?"

**Expected answer:** the `Endpoints` are empty — the selector matches zero pods.

```bash
k describe svc checkout-api-broken
k get pods --show-labels | grep checkout
```

**Root cause:** the selector says `tier=backends` (a typo) but the pods are labelled
`tier=backend`. The selector matches nothing. **Fix:** correct the selector to `tier=backend` and
re-apply — the `Endpoints` populate immediately.

> **Exam Tip:** "Service exists but nothing reaches it" = **check `kubectl get endpoints` first**.
> Empty endpoints almost always means a selector/label mismatch. This is the exact failure mode
> the Module 1 label discipline was protecting you from.

## Independent challenge (5 minutes)

**Scenario:** Expose `checkout-api-deploy` with a new ClusterIP Service named `checkout-internal`
on port `8080` that forwards to the containers' port `80`.

**Requirements:**
- Selector must target `app=checkout,tier=backend`
- Verify `Endpoints` lists the backend pod IPs (not empty)

<details>
<summary>Solution</summary>

```bash
k expose deployment checkout-api-deploy --name=checkout-internal --port=8080 --target-port=80
k get endpoints checkout-internal
```

Or declaratively:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: checkout-internal
spec:
  selector:
    app: checkout
    tier: backend
  ports:
  - port: 8080
    targetPort: 80
```
</details>

> **Docs to search** (only `kubernetes.io/docs` and `kubernetes.io/blog` are open to you in the exam — no bookmarks, so learn to navigate them fast): [Service](https://kubernetes.io/docs/concepts/services-networking/service/) · [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/) · [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/).

## Practice Labs / Homework

- Lab - Kubernetes - CKAD - Network Policies
