# Working with Pods

We're deploying `checkout-api` — the app we'll keep evolving across every module.

## Create a pod imperatively (instructor demo)

```bash
k run checkout-api --image=nginx
```

```bash
k get pods
k get pod checkout-api -o wide
k describe pod checkout-api
```

**What to observe:** `STATUS` should move from `ContainerCreating` to `Running`. `-o wide` shows which node it landed on and its pod IP.

## Generate YAML the exam way (instructor demo)

Never write a Pod manifest from scratch. Generate it, then edit.

```bash
k run checkout-api-2 --image=nginx $do > pod.yaml
cat pod.yaml
```

Walk through the generated structure: `apiVersion`, `kind`, `metadata` (name, labels), `spec.containers` (name, image, resources).

```bash
k apply -f pod.yaml
```

## kubectl explain — your in-exam documentation (instructor demo)

```bash
k explain pod.spec
k explain pod.spec.containers
k explain pod.spec.containers.resources
```

> **Exam Tip:** `kubectl explain` is faster than searching kubernetes.io for a field name you half-remember. Use it before you reach for a browser tab.

## Labels and selectors (guided — you type this along with the demo)

```bash
k run checkout-api --image=nginx --labels="app=checkout,tier=backend" --dry-run=client -o yaml > checkout-pod.yaml
k apply -f checkout-pod.yaml
k get pods -l app=checkout
k get pods -l 'tier in (backend,frontend)'
k label pod checkout-api env=dev
```

**Why this label choice matters later:** in the next module, a Service will select pods using `app=checkout`. If you mislabel it now, the Service silently matches zero pods later — and that's a real CKAD failure mode, not just a today problem.

## Semi-guided: your turn

Now — **without copying the block above** — create a second pod called `checkout-db` with labels `app=checkout,tier=database`. Generate the YAML first with `--dry-run=client`, inspect it, then apply.

<details>
<summary>Hint (open only if stuck)</summary>

```bash
k run checkout-db --image=nginx --labels="app=checkout,tier=database" $do > checkout-db.yaml
k apply -f checkout-db.yaml
k get pods -l app=checkout
```
</details>

## Editing and deleting

```bash
k edit pod checkout-api
k delete pod checkout-api-2
```

## Break it / troubleshoot (instructor-led, ~4 minutes)

Instructor applies a pod with a deliberately bad image tag:

```yaml
# broken-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: checkout-broken
  labels:
    app: checkout
spec:
  containers:
  - name: checkout-api
    image: nginx:this-tag-does-not-exist
```

```bash
k apply -f broken-pod.yaml
k get pods
```

**What you'll see:** `STATUS` shows `ErrImagePull` then `ImagePullBackOff`.

**Ask the room:** "What's the first command you'd run to investigate?"

**Expected answer:** `kubectl describe pod checkout-broken` — check the `Events` section at the bottom.

```bash
k describe pod checkout-broken
```

**Root cause:** the image tag doesn't exist in the registry. **Fix:** edit the image tag to something valid (`nginx` or `nginx:latest`) and re-apply, or delete and recreate.

```bash
k delete pod checkout-broken
```

> **Exam Tip:** `ImagePullBackOff` and `CrashLoopBackOff` are the two most common broken-pod states in the exam. `describe` → `Events` is always your first move, before logs, before anything else.

## Independent challenge (5 minutes)

**Scenario:** Create a pod named `checkout-worker` using image `busybox`, with labels `app=checkout,tier=worker`, that runs the command `sleep 3600` so it doesn't immediately exit.

**Requirements:**
- Generate the YAML with `--dry-run=client` first
- Labels must be exactly `app=checkout,tier=worker`
- Verify it reaches `Running` status (busybox exits immediately without a command — that's the twist)

<details>
<summary>Solution</summary>

```bash
k run checkout-worker --image=busybox --labels="app=checkout,tier=worker" $do -- sleep 3600 > checkout-worker.yaml
k apply -f checkout-worker.yaml
k get pods checkout-worker
```
</details>

## Practice Labs

- Lab - Kubernetes - CKAD - Pods
- Lab - Kubernetes - CKAD - Labels and Selectors
