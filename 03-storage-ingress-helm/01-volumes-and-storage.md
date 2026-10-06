# Volumes & Persistent Storage

Every container in this workshop so far has been disposable — kill the pod, lose everything it
wrote. That's fine for `checkout-api` (stateless, config lives in ConfigMaps/Secrets), but
`checkout-db` needs its data to survive a pod restart. That's what a volume is for.

## emptyDir (instructor demo)

The simplest volume: created empty when the pod starts, deleted when the pod is removed. Lives
only as long as the pod does — but it **does** survive a container restart within that pod,
which is the whole point of the log-shipping sidecar from Module 1.

```bash
k run checkout-scratch --image=busybox --dry-run=client -o yaml \
  -- sh -c "echo scratch data; sleep 3600" > scratch-pod.yaml
```

Add the volume by hand:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: checkout-scratch
spec:
  containers:
  - name: checkout-scratch
    image: busybox
    command: ["sh", "-c", "echo scratch data; sleep 3600"]
    volumeMounts:
    - name: scratch
      mountPath: /scratch
  volumes:
  - name: scratch
    emptyDir: {}
```

```bash
k apply -f scratch-pod.yaml
k exec checkout-scratch -- sh -c "echo hello > /scratch/data.txt && cat /scratch/data.txt"
k delete pod checkout-scratch   # gone — emptyDir goes with the pod
```

> **Exam Tip:** `emptyDir` is the answer whenever a question says "share data between containers
> in the same pod" without mentioning persistence — exactly what Module 1's sidecar pattern uses
> under the hood.

## PersistentVolume & PersistentVolumeClaim (instructor demo)

For data that must outlive the pod, you need a **PersistentVolume** (the actual storage) and a
**PersistentVolumeClaim** (a pod's request to use some of it). Pods never reference a PV
directly — they claim one through a PVC.

The easiest, most portable path is **dynamic provisioning**: ask for storage, let the cluster's
default StorageClass create the PV for you.

```yaml
# manifests/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: checkout-db-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 256Mi
```

```bash
k apply -f manifests/pvc.yaml
k get pvc checkout-db-pvc
```

**What to observe:** `STATUS` goes to `Bound` and a `VOLUME` name appears — the cluster created a
PV for you automatically because no `storageClassName` was set, so it used whatever StorageClass
is marked `(default)` in `kubectl get storageclass`.

Mount it on `checkout-db`:

```yaml
# manifests/deployment-with-storage.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkout-db-deploy
  labels:
    app: checkout
    tier: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: checkout
      tier: database
  template:
    metadata:
      labels:
        app: checkout
        tier: database
    spec:
      containers:
      - name: checkout-db
        image: nginx
        volumeMounts:
        - name: db-data
          mountPath: /data
      volumes:
      - name: db-data
        persistentVolumeClaim:
          claimName: checkout-db-pvc
```

```bash
k apply -f manifests/deployment-with-storage.yaml
k exec deploy/checkout-db-deploy -- sh -c "echo order-123 > /data/orders.log"
k delete pod -l app=checkout,tier=database
k exec deploy/checkout-db-deploy -- cat /data/orders.log   # still there — new pod, same volume
```

> **Exam Tip:** `replicas: 1` on purpose — `ReadWriteOnce` means only **one node** can mount the
> volume for writing at a time. Scaling this Deployment past 1 replica on a multi-node cluster
> would leave extra pods stuck `Pending`, waiting for a node that can mount the volume.

## Static PV/PVC binding (semi-guided)

Dynamic provisioning isn't the only pattern tested. Sometimes a PVC must bind to a **specific,
pre-created** PersistentVolume — usually via a `storageClassName` that matches and no dynamic
provisioner behind it. Build this one using the dynamic PVC above as reference.

<details>
<summary>Solution</summary>

```yaml
# manifests/pv-static.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: checkout-static-pv
spec:
  capacity:
    storage: 128Mi
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  hostPath:
    path: /tmp/checkout-static-pv
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: checkout-static-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 128Mi
```

```bash
k apply -f manifests/pv-static.yaml
k get pv checkout-static-pv
k get pvc checkout-static-pvc
```
</details>

**What makes them bind:** matching `storageClassName`, an `accessModes` the PV offers, and a
`requests.storage` the PV's `capacity.storage` can satisfy. Get any of those wrong and the PVC
stays `Pending` forever instead of erroring — which is exactly the break/fix below.

> **Exam Tip:** `hostPath` only works on a single-node cluster (exactly what you're using to
> practice). It's never the right answer for a real multi-node cluster — that limitation is the
> lesson, not an oversight.

## Break it / troubleshoot (instructor-led, ~4 minutes)

Apply a PVC requesting a StorageClass that doesn't exist.

```bash
k apply -f manifests/broken-pvc.yaml
k get pvc checkout-broken-pvc
```

**What you'll see:** `STATUS` stuck at `Pending`, indefinitely. No error, no event screaming at
you by default.

**Ask the room:** "The PVC was created without error. Why is nothing happening?"

**Expected answer:** check events — `kubectl describe` on a `Pending` PVC always has the reason.

```bash
k describe pvc checkout-broken-pvc
```

**Root cause:** `storageClassName: does-not-exist` — no provisioner is watching for that class,
so nothing ever creates a PV to bind to. **Fix:** remove `storageClassName` (use the cluster
default) or point it at one that actually exists.

```bash
k delete pvc checkout-broken-pvc
```

> **Exam Tip:** A `Pending` PVC is always a StorageClass problem — wrong name, no default class,
> or a class with no provisioner backing it. `kubectl describe pvc` and
> `kubectl get storageclass` are the first two commands, every time.

## Independent challenge (5 minutes)

**Scenario:** `checkout-api` needs scratch space for temporary file uploads that should NOT
survive a pod restart (unlike `checkout-db`'s data).

**Requirements:**
- Create a Pod named `checkout-uploads` using image `busybox`
- Mount an `emptyDir` volume at `/uploads`
- Command: sleep for an hour so you can exec into it and verify

<details>
<summary>Solution</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: checkout-uploads
spec:
  containers:
  - name: checkout-uploads
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - name: uploads
      mountPath: /uploads
  volumes:
  - name: uploads
    emptyDir: {}
```

```bash
k apply -f uploads-pod.yaml
k exec checkout-uploads -- ls /uploads
```
</details>

> **Docs to search** (only `kubernetes.io/docs` and `kubernetes.io/blog` are open to you in the exam — no bookmarks, so learn to navigate them fast): [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/) · [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) · [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/).

## Practice Labs / Homework

- Lab - Kubernetes - CKAD - Persistent Volumes and Persistent Volume Claims
