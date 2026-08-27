# Multi-Container Pods

Last module `checkout-api` was a lone container. Real apps often need a helper running next to them — shipping logs, warming a cache, or waiting for a dependency. That's what multi-container pods are for.

## Recap: the previous module's homework

Before we start, a quick check-in on the homework labs — *Multi Container Pods* and *Init Containers* on KodeKloud. The two patterns below are exactly what those labs drill.

**The framing that decides which one you need:**

- Need to run something **before** the app starts (and it must finish first)? → **init container**
- Need to run something **alongside** the app for the pod's whole life? → **sidecar**

## Sidecar pattern (instructor demo)

A sidecar shares the pod with the main container — same network, and any volumes you mount into both. Here `checkout-api` (nginx) runs next to a `log-shipper` that writes to a shared `emptyDir`.

```yaml
# manifests/sidecar-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: checkout-api-sidecar
  labels:
    app: checkout
    tier: backend
spec:
  containers:
  - name: checkout-api
    image: nginx
    volumeMounts:
    - name: logs
      mountPath: /var/log/checkout
  - name: log-shipper
    image: busybox
    command: ["sh", "-c", "while true; do echo \"$(date) shipped a checkout log line\" >> /var/log/checkout/app.log; sleep 5; done"]
    volumeMounts:
    - name: logs
      mountPath: /var/log/checkout
  volumes:
  - name: logs
    emptyDir: {}
```

```bash
k apply -f manifests/sidecar-pod.yaml
k get pod checkout-api-sidecar
```

**What to observe:** `READY` shows `2/2` — two containers in one pod. Now prove the `emptyDir` is shared: the `log-shipper` writes the file, and the `checkout-api` container can read it.

```bash
k exec checkout-api-sidecar -c checkout-api -- cat /var/log/checkout/app.log
k logs checkout-api-sidecar -c log-shipper
```

> **Exam Tip:** With multiple containers you MUST use `-c <container>` on `exec` and `logs`, or kubectl picks the default and may not be the one you meant. Forgetting `-c` is a classic time-waster.

## Init container pattern (instructor demo)

An init container runs to completion **before** any app container starts. Classic use: block `checkout-api` from starting until `checkout-db` is actually reachable.

```yaml
# manifests/init-container-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: checkout-api-init
  labels:
    app: checkout
    tier: backend
spec:
  initContainers:
  - name: wait-for-db
    image: busybox
    command: ["sh", "-c", "until nslookup checkout-db; do echo waiting for checkout-db; sleep 2; done"]
  containers:
  - name: checkout-api
    image: nginx
```

```bash
k apply -f manifests/init-container-pod.yaml
k get pod checkout-api-init
```

**What you'll see:** `STATUS` sits at `Init:0/1` — the app container hasn't started because the init container is still waiting for `checkout-db` to resolve. That's the break/fix below.

## Break it / troubleshoot (instructor-led, ~4 minutes)

The pod above is stuck. Let's diagnose and fix it.

```bash
k get pod checkout-api-init
k logs checkout-api-init -c wait-for-db
```

**What you'll see:** `Init:0/1`, and the init container logs repeat `waiting for checkout-db`.

**Ask the room:** "The app image is fine — so why won't the pod start?"

**Expected answer:** the init container is blocking on a `checkout-db` Service that doesn't exist yet, so its DNS lookup never succeeds.

**Root cause:** no `checkout-db` Service for DNS to resolve. **Fix:** give it something to resolve. A headless Service (even with no pods behind it) creates the DNS name.

```bash
k create service clusterip checkout-db --tcp=5432:5432
k get pod checkout-api-init -w
```

Once `checkout-db` resolves, the init container exits and `checkout-api` starts — `STATUS` moves to `Running`.

> **Exam Tip:** A pod stuck in `Init:0/1` almost always means an init container's condition isn't met. Check it with `kubectl logs <pod> -c <init-container>` — init container logs are the fast path to the cause.

## Semi-guided: your turn

Add a **second** init container to a pod named `checkout-api-init2` that runs *before* `wait-for-db` and simply prints `preparing checkout-api` then exits. Init containers run **in order**, top to bottom — so it should complete first.

<details>
<summary>Hint (open only if stuck)</summary>

```yaml
  initContainers:
  - name: prepare
    image: busybox
    command: ["sh", "-c", "echo preparing checkout-api"]
  - name: wait-for-db
    image: busybox
    command: ["sh", "-c", "until nslookup checkout-db; do echo waiting for checkout-db; sleep 2; done"]
```
Verify order with `k get pod checkout-api-init2` and `k describe pod checkout-api-init2` (Init containers are listed in run order).
</details>

## Independent challenge (5 minutes)

**Scenario:** Create a pod named `checkout-api-cache` with two containers that run side by side:
- `checkout-api` using image `nginx`
- `cache-warmer` using image `busybox` running `sleep 3600`

**Requirements:**
- Both containers in one pod (a sidecar-style layout)
- Labels `app=checkout,tier=backend`
- Verify `READY` shows `2/2`

<details>
<summary>Solution</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: checkout-api-cache
  labels:
    app: checkout
    tier: backend
spec:
  containers:
  - name: checkout-api
    image: nginx
  - name: cache-warmer
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
```

```bash
k apply -f cache-pod.yaml
k get pod checkout-api-cache
```
</details>

> **Docs to search** (only `kubernetes.io/docs` and `kubernetes.io/blog` are open to you in the exam — no bookmarks, so learn to navigate them fast): [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) · [Communicate Between Containers in a Pod](https://kubernetes.io/docs/tasks/access-application-cluster/communicate-containers-same-pod-shared-volume/) — copy-pasteable multi-container and shared-volume YAML.

## Practice Labs / Homework

- Lab - Kubernetes CKAD - Multi Container Pods
- Practice Test – Init Containers
