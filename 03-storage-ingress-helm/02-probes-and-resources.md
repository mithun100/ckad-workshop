# Probes & Resources

Every `checkout-api` pod so far has had one problem nobody mentioned: Kubernetes considered it
"healthy" the instant its process started, and never checked again. No pod in this workshop has
declared how much CPU/memory it needs, either. Both are quietly some of the most exam-relevant
gaps to leave open — this lesson closes them.

## The three probe types (instructor demo)

| Probe | Answers | Failure action |
|---|---|---|
| `startupProbe` | Has the app finished starting up? | Kills the container if it never succeeds |
| `readinessProbe` | Is it ready for traffic *right now*? | Removes it from Service `Endpoints` — container keeps running |
| `livenessProbe` | Is it still working, or stuck? | Kubernetes restarts the container |

The distinction that trips people up: a failing **readiness** probe never restarts anything — it
just stops traffic from being routed there. A failing **liveness** probe restarts the container.

```yaml
# manifests/deployment-with-probes.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkout-api-healthy
  labels:
    app: checkout
    tier: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: checkout
      tier: backend
  template:
    metadata:
      labels:
        app: checkout
        tier: backend
    spec:
      containers:
      - name: checkout-api
        image: nginx
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "64Mi"
          limits:
            cpu: "250m"
            memory: "128Mi"
        startupProbe:
          httpGet:
            path: /
            port: 80
          failureThreshold: 10
          periodSeconds: 2
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 2
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
```

```bash
k apply -f manifests/deployment-with-probes.yaml
k get pods -l app=checkout,tier=backend
k describe pod -l app=checkout,tier=backend | grep -A2 "Liveness\|Readiness\|Startup"
```

**What to observe:** `READY` shows `1/1` only once the readiness probe has succeeded at least
once — not the moment the container starts.

> **Exam Tip:** `startupProbe` exists specifically for slow-starting apps: while it's running,
> liveness and readiness probes are paused, so a legitimately slow boot doesn't get killed by an
> impatient liveness probe. Omit it and liveness probes run from container start.

## Resource requests vs. limits (instructor demo)

Two different jobs, same syntax:
- **`requests`** — what the scheduler guarantees when picking a node. A pod won't be scheduled
  onto a node that can't satisfy its requests.
- **`limits`** — the hard ceiling. Exceed the **memory** limit and the container is killed
  (`OOMKilled`). Exceed the **CPU** limit and it's throttled, not killed.

```bash
k describe pod -l app=checkout,tier=backend | grep -A4 "Limits\|Requests"
```

> **Exam Tip:** Memory limit breaches kill the container. CPU limit breaches only throttle it.
> This asymmetry is a frequent exam trick — "why did my pod die" vs. "why is my pod slow" have
> different answers depending on which resource was the problem.

## Break it / troubleshoot (instructor-led, ~4 minutes)

### Part A: a readiness probe pointed at the wrong port

```bash
k apply -f manifests/broken-readiness-pod.yaml
k get pod checkout-api-broken-probe
```

**What you'll see:** `STATUS` is `Running`, but `READY` never reaches `1/1`.

**Ask the room:** "The container is Running — so why would a Service selecting this pod get
empty Endpoints?"

**Expected answer:** `Running` only means the process started. `READY` depends on the readiness
probe succeeding — and a Service only routes to pods that are both selected **and** Ready.

```bash
k describe pod checkout-api-broken-probe | grep -A3 Readiness
```

**Root cause:** the probe checks port `8080`; nginx listens on `80`. **Fix:** correct the port
and re-apply — `READY` flips to `1/1` within one probe interval.

```bash
k delete pod checkout-api-broken-probe
```

### Part B: a container that exceeds its memory limit

```bash
k apply -f manifests/oom-pod.yaml
k get pod checkout-api-oom -w
```

**What you'll see:** `RESTARTS` climbing, and `kubectl describe` showing `OOMKilled` as the last
termination reason.

```bash
k describe pod checkout-api-oom | grep -A3 "Last State"
```

**Root cause:** the container asks to allocate 250Mi but its `limits.memory` is `100Mi`.
**Fix:** raise the limit to accommodate real usage, or fix the application if the usage itself is
the bug — in the exam, raising the limit to a stated value is usually the actual ask.

```bash
k delete pod checkout-api-oom
```

> **Exam Tip:** `OOMKilled` only ever means the **memory limit**, not the request, was exceeded.
> `kubectl describe pod` → `Last State` → `Reason: OOMKilled` is the signature to recognize
> instantly — don't waste exam minutes checking logs first.

## Independent challenge (5 minutes)

**Scenario:** Create a Pod named `checkout-worker-healthy` using image `nginx` that:

**Requirements:**
- Requests `100m` CPU / `64Mi` memory, limits `200m` CPU / `128Mi` memory
- Has a readiness probe on port `80`, path `/`
- Has a liveness probe on port `80`, path `/`, with `initialDelaySeconds: 5`

<details>
<summary>Solution</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: checkout-worker-healthy
spec:
  containers:
  - name: checkout-api
    image: nginx
    resources:
      requests:
        cpu: "100m"
        memory: "64Mi"
      limits:
        cpu: "200m"
        memory: "128Mi"
    readinessProbe:
      httpGet:
        path: /
        port: 80
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
```
</details>

> **Docs to search** (only `kubernetes.io/docs` and `kubernetes.io/blog` are open to you in the exam — no bookmarks, so learn to navigate them fast): [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) · [Resource Management for Pods](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).

## Practice Labs / Homework

- Lab - Kubernetes - CKAD - Readiness and Liveness Probes
- Lab - Kubernetes - CKAD - Resource Requirements and Limits
