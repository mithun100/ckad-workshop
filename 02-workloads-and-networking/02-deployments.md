# Deployments

A bare Pod has a fatal flaw: delete it, or lose its node, and it's gone. `checkout-api` needs
to survive that. This is where we evolve it from a single Pod into a self-healing, updatable
Deployment.

## The bridge: ReplicaSet (instructor demo)

Before Deployments, meet the controller they're built on. A **ReplicaSet** keeps a fixed
number of pod copies running — delete one and it respawns.

```yaml
# manifests/replicaset.yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: checkout-api-rs
  labels:
    app: checkout
    tier: backend
spec:
  replicas: 3
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
```

```bash
k apply -f manifests/replicaset.yaml
k get rs checkout-api-rs
k get pods -l app=checkout
```

**Prove self-healing:** delete a pod and watch it come back.

```bash
k delete pod -l app=checkout --field-selector=status.phase=Running | head -1
k get pods -l app=checkout
```

**The catch:** a ReplicaSet can keep pods alive, but it has **no rolling update or rollback**.
Change the image and existing pods are *not* updated. That single limitation is why you almost
never create a ReplicaSet directly — you use a Deployment, which manages ReplicaSets for you and
adds the rollout machinery.

```bash
k delete rs checkout-api-rs
```

> **Exam Tip:** You'll rarely be asked to *create* a ReplicaSet, but you must recognize that a
> Deployment owns one. `kubectl get rs` after any Deployment change shows the ReplicaSets it
> spins up — that's how rollouts and rollbacks actually work under the hood.

## Create the Deployment (instructor demo)

The imperative way first, then the manifest.

```bash
k create deployment checkout-api-deploy --image=nginx:1.25 --replicas=3
k get deploy checkout-api-deploy
k get rs
k get pods -l app=checkout
```

Generate and inspect the YAML the exam way:

```bash
k create deployment checkout-api-deploy --image=nginx:1.25 --replicas=3 $do > deploy.yaml
cat deploy.yaml
```

The committed manifest reuses the Module 1 labels explicitly:

```yaml
# manifests/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkout-api-deploy
  labels:
    app: checkout
    tier: backend
spec:
  replicas: 3
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
        image: nginx:1.25
```

```bash
k apply -f manifests/deployment.yaml
```

> **Exam Tip:** `spec.selector.matchLabels` MUST match `spec.template.metadata.labels`. If they
> disagree, the API server rejects the Deployment. This is the single most common Deployment YAML
> error — check it first when a manifest won't apply.

## Scaling

```bash
k scale deployment checkout-api-deploy --replicas=5
k get pods -l app=checkout
k scale deployment checkout-api-deploy --replicas=3
```

## Rolling update (instructor demo)

Update the image and watch the Deployment replace pods gradually — no downtime.

```bash
k set image deployment/checkout-api-deploy checkout-api=nginx:1.26
k rollout status deployment/checkout-api-deploy
k get rs
```

**What to observe:** `rollout status` reports progress; `get rs` now shows a **second**
ReplicaSet — the new one scaling up as the old scales down.

Inspect and undo:

```bash
k rollout history deployment/checkout-api-deploy
k rollout undo deployment/checkout-api-deploy
k rollout undo deployment/checkout-api-deploy --to-revision=1
```

## Break it / troubleshoot (instructor-led, ~4 minutes)

Roll out a bad image tag and watch the update get stuck.

```bash
k set image deployment/checkout-api-deploy checkout-api=nginx:does-not-exist
k rollout status deployment/checkout-api-deploy
k get pods -l app=checkout
```

**What you'll see:** `rollout status` hangs (`Waiting for deployment ... rollout to finish`),
and a new pod is stuck in `ImagePullBackOff`.

**Ask the room:** "Are we down? How many pods are still serving?"

**Expected answer:** No — RollingUpdate keeps the old pods running until the new ones are healthy.
The bad new pod never goes `Ready`, so the old ReplicaSet stays up. This is the whole point of a
rolling update.

**Root cause:** the new image tag doesn't exist. **Fix:** roll back.

```bash
k rollout undo deployment/checkout-api-deploy
k rollout status deployment/checkout-api-deploy
```

> **Exam Tip:** A stuck rollout does NOT take your app down — the old ReplicaSet keeps serving.
> `kubectl rollout undo` is the fastest recovery; you rarely need to hand-edit anything.

## RollingUpdate vs Recreate (annotated)

The default strategy is `RollingUpdate`. You control its pace with `maxSurge` (how many *extra*
pods above desired count during the update) and `maxUnavailable` (how many can be *down* at once).

```yaml
spec:
  strategy:
    type: RollingUpdate          # default — replaces pods gradually, no downtime
    rollingUpdate:
      maxSurge: 1                 # at most 1 pod ABOVE the desired 3 during the update
      maxUnavailable: 0          # never drop below the desired count (zero-downtime)
```

The alternative kills everything first, then creates the new version — brief downtime, but no two
versions running at once:

```yaml
spec:
  strategy:
    type: Recreate               # terminate ALL old pods, THEN start new ones (has downtime)
```

> **Exam Tip:** `Recreate` matters when two versions of your app must never run simultaneously
> (e.g. an incompatible schema migration). Otherwise `RollingUpdate` with `maxUnavailable: 0` is
> the zero-downtime default.

## Independent challenge (5 minutes)

**Scenario:** Working from a Deployment `checkout-api-deploy` running `nginx:1.25`:

**Requirements:**
- Scale it to 4 replicas
- Roll it out to `nginx:1.27` and confirm the rollout completed
- Check the rollout history, then roll back to the previous revision
- Verify all pods are `Running` on the rolled-back image

<details>
<summary>Solution</summary>

```bash
k scale deployment checkout-api-deploy --replicas=4
k set image deployment/checkout-api-deploy checkout-api=nginx:1.27
k rollout status deployment/checkout-api-deploy
k rollout history deployment/checkout-api-deploy
k rollout undo deployment/checkout-api-deploy
k get pods -l app=checkout -o jsonpath='{.items[*].spec.containers[*].image}'
```
</details>

> **Docs to search** (only `kubernetes.io/docs` and `kubernetes.io/blog` are open to you in the exam — no bookmarks, so learn to navigate them fast): [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) · [kubectl reference](https://kubernetes.io/docs/reference/kubectl/) — the Deployments page has ready-to-copy rolling-update and rollback examples.

## Practice Labs / Homework

- Lab - Kubernetes - CKAD - Rolling Updates and Rollbacks
- Lab - Deployment strategies (optional/bonus — Blue-Green/Canary, beyond core scope)
