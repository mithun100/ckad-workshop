# Ingress

A Service gets you a stable address *inside* the cluster. **Ingress** is the layer on top that
routes external HTTP(S) traffic — by hostname, by path, or both — to one or more Services, from a
single entry point.

## Ingress needs a controller — the resource alone does nothing

This is the one topic in the whole workshop where the resource you create is inert without extra
infrastructure. An `Ingress` object is just routing *rules*; something has to actually read them
and program a proxy. That something is an **Ingress controller**, and it isn't built into
Kubernetes — you install one.

The most common one, and the one these examples assume, is **ingress-nginx**:

```bash
# Docker Desktop / generic:
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# kind:
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# minikube:
minikube addons enable ingress
```

```bash
k get pods -n ingress-nginx
```

**Expected output:** a `controller` pod reaching `Running`/`1/1` — give it a minute after
install. If you skip this, everything below up to **Break it** still works for creating and
inspecting the resource; only actual HTTP routing needs the controller.

## Create an Ingress (instructor demo)

Routes `checkout.local` to the `checkout-api` Service from Module 2.

> **Prerequisite — check before you demo.** The Ingress needs a `checkout-api` Service *and* pods
> labelled `app=checkout,tier=backend` behind it. Both come from Module 2. Check, and apply only
> what's missing (e.g. after a lab reset):
>
> ```bash
> k get svc checkout-api                          # missing? ->
> k apply -f ../02-workloads-and-networking/manifests/service-clusterip.yaml
>
> k get pods -l app=checkout,tier=backend         # none running? ->
> k apply -f ../02-workloads-and-networking/manifests/deployment.yaml
>
> k get endpoints checkout-api                    # must list pod IPs, not <none>
> ```
>
> Skip this and the controller returns `503 Service Temporarily Unavailable`;
> `k describe ingress` will show `services "checkout-api" not found`.

```yaml
# manifests/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: checkout-api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: checkout.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: checkout-api
            port:
              number: 80
```

```bash
k apply -f manifests/ingress.yaml
k get ingress checkout-api-ingress
k describe ingress checkout-api-ingress
```

**What to observe:** `describe` shows the rule, the backend Service, and (once the controller has
synced) an `ADDRESS`. With a controller running locally, test it:

```bash
curl -H "Host: checkout.local" http://localhost/
```

> **Exam Tip:** `pathType: Prefix` matches `/` and everything under it; `pathType: Exact` matches
> only that literal path. Getting this field wrong is a common silent-failure point — the
> Ingress applies fine, but requests 404 at the controller, not at your backend.

## Path-based routing (semi-guided)

A single host can route different paths to different Services. Build this one using the hostname
rule above as reference: route `checkout.local/health` to a second Service named `checkout-health`
(you don't need that Service to exist for this exercise — just the routing rule).

Write the YAML yourself in `manifests/ingress-paths.yaml` (a new scratch file), then check it
without applying anything first:

```bash
k apply -f manifests/ingress-paths.yaml --dry-run=server   # validates against the cluster, creates nothing
```

> **Name collision:** if you give this Ingress a *new* name, the admission webhook rejects it with
> `host "checkout.local" and path "/" is already defined in ingress default/checkout-api-ingress`.
> Two Ingresses can't claim the same host+path. Either reuse the name `checkout-api-ingress` (the
> apply then updates it) or `k delete ingress checkout-api-ingress` first.

<details>
<summary>Solution</summary>

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: checkout-api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: checkout.local
    http:
      paths:
      - path: /health
        pathType: Prefix
        backend:
          service:
            name: checkout-health
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: checkout-api
            port:
              number: 80
```

```bash
k apply -f manifests/ingress-paths.yaml
k describe ingress checkout-api-ingress     # two paths listed; /health shows "services not found"
curl -H "Host: checkout.local" http://localhost/          # 200 -> checkout-api
curl -H "Host: checkout.local" http://localhost/health    # 503 -> checkout-health doesn't exist
```

**What to observe:** `/` still works, while `/health` returns `503` because its Service doesn't
exist. That proves the routing rule matched, which is all this exercise asks for. Restore the
original afterwards with `k apply -f manifests/ingress.yaml`.

**Order doesn't matter to the controller:** the Ingress spec says the longest matching `Prefix`
wins, so `/health` beats `/` however you order them. Listing the specific path first is still the
readable convention.
</details>

## Break it / troubleshoot (instructor-led, ~4 minutes)

Apply an Ingress pointing at a Service name that doesn't exist.

```bash
k apply -f manifests/broken-ingress.yaml
k describe ingress checkout-api-ingress-broken
```

**What you'll see:** the Ingress is created without error, but `describe` shows a warning event
like `Service "checkout-api-svc" not found`, and any request to it 404s or 503s at the controller.

**Ask the room:** "The Ingress applied cleanly. Why is every request failing?"

**Expected answer:** the backend Service name is wrong — `checkout-api-svc` instead of the real
`checkout-api`.

**Root cause:** a typo'd `backend.service.name`. **Fix:** correct the name and re-apply.

```bash
k delete -f manifests/broken-ingress.yaml
```

> **Exam Tip:** Ingress failures are almost always one of three things: missing/misnamed backend
> Service, wrong `ingressClassName` (no controller is listening for that class), or wrong
> `pathType`. `kubectl describe ingress` surfaces the first two directly in its Events.

## Independent challenge (5 minutes)

**Scenario:** Create an Ingress named `checkout-admin-ingress` that routes host `admin.local`,
path `/`, to a Service named `checkout-admin` on port `8080`.

<details>
<summary>Solution</summary>

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: checkout-admin-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: admin.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: checkout-admin
            port:
              number: 8080
```
</details>

> **Docs to search** (only `kubernetes.io/docs` and `kubernetes.io/blog` are open to you in the exam — no bookmarks, so learn to navigate them fast): [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) · [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/).

## Practice Labs / Homework

- Lab - Kubernetes - CKAD - Ingress
