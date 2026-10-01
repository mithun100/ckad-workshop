# Single-Node Kubernetes on Your Mac

Everything after this session assumes you have a cluster to point `kubectl` at. Here are three
ways to get one running locally — pick whichever fits what you already installed. All three give
you a real, conformant single-node cluster; none of them are "fake" Kubernetes.

## Option A: Docker Desktop's built-in Kubernetes

If you already have Docker Desktop (previous lesson), this is the fastest path — one checkbox,
no extra tooling.

1. Docker Desktop → **Settings** → **Kubernetes** → check **Enable Kubernetes** → **Apply & Restart**.
2. Wait for the whale icon to settle (first start pulls several images — can take a few minutes).

## Option B: kind (Kubernetes in Docker)

Runs a cluster as containers, using whatever container runtime you already have (Docker or
Podman):

```bash
brew install kind
kind create cluster --name ckad
```

## Option C: minikube

A dedicated local-cluster tool with more built-in add-ons (dashboard, ingress controller, etc.):

```bash
brew install minikube
minikube start
```

## Verify, regardless of which option you picked

```bash
kubectl cluster-info
kubectl get nodes
kubectl get ns
```

**Expected output:** `cluster-info` prints a control plane URL; `get nodes` shows at least one
node in `Ready` status; `get ns` shows at least `default`, `kube-system`, `kube-public`. This is
the exact same check Module 1 opens with — if it passes here, you walk into Session 1 ready.

> **Exam Tip:** The exam gives you a cluster already running — you'll never do this setup there.
> The value here is purely that you stop being blocked by infrastructure on your own time, so
> every later module's time is spent on Kubernetes concepts, not on getting a cluster to exist.

## Close the loop: run the image you built, on the cluster you just built

Every manifest in Modules 1–2 uses only public images (`nginx`, `busybox`) pulled from a
registry — that's deliberate, so they run anywhere unmodified. But you also built your own image
by hand in [01-docker-basics.md](01-docker-basics.md) (`checkout-api:v1`), and it's worth seeing
that run as an actual Pod before moving on, since this is the one time all three pieces (your
Dockerfile, your cluster, and a Pod manifest) come together.

[`manifests/checkout-api-local.yaml`](manifests/checkout-api-local.yaml) is fully self-contained
— its header comment includes the exact Dockerfile and build commands, so you can use this one
file on its own without opening any other lesson:

```bash
kubectl apply -f manifests/checkout-api-local.yaml
kubectl get pod checkout-api-local -w
```

`port-forward` blocks the terminal it runs in, so open a **second terminal** for it:

```bash
kubectl port-forward pod/checkout-api-local 8080:80
```

Then, back in your **first** terminal:

```bash
curl http://localhost:8080
```

**Expected output:** the same custom `<h1>checkout-api</h1>` HTML from the Docker lesson —
proof the exact image you built is now running as a Kubernetes Pod, not a Docker container.

**The one detail that trips people up:** `checkout-api:v1` only exists on your machine — it was
never pushed to a registry. Two things make that work:
- `imagePullPolicy: Never` on the Pod — without it, Kubernetes defaults to trying to *pull* the
  image from a registry, which fails for an image that only exists locally.
- The image must be visible to whichever cluster you're using — Docker Desktop's Kubernetes
  shares its daemon automatically, but kind and minikube run in their own isolated environment
  and need the image loaded in explicitly (`kind load docker-image` / `minikube image load` —
  both commands are in the manifest's header comment).

**A second detail, confirmed live rather than theoretical:** this Pod is deliberately labeled
`app: checkout-local-demo`, not the `app=checkout,tier=backend` used everywhere else in this
workshop. If you've already run Module 2 on this same cluster, its `checkout-api-rs` ReplicaSet
is still watching for exactly that label combination — give this Pod those labels instead and the
leftover ReplicaSet "adopts" it as an unwanted extra replica and deletes it within seconds. A
Service or ReplicaSet never checks who created a pod, only whether its labels match — this is
the same mechanism Module 2's label lessons warn about, just encountered from the other side.

```bash
kubectl delete pod checkout-api-local
```

## Which one should you actually use for this workshop?

Any of them. Every manifest and command in this workshop uses only public images (`nginx`,
`busybox`) and no cluster-specific features — they run unmodified on Docker Desktop, kind,
minikube, or the KodeKloud playground. Pick whichever you got working with the least friction.
