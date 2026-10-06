# Helm

Every manifest in this workshop so far has been applied one file at a time. Helm is Kubernetes'
package manager — it bundles related manifests into one versioned, parameterized **chart**, so
`checkout-api` becomes one `helm install` instead of five `kubectl apply`s.

## Install Helm (if you don't have it)

```bash
brew install helm
helm version
```

## Scaffold a chart (instructor demo)

```bash
helm create checkout-api-chart
```

**What you got:** a directory with `Chart.yaml` (metadata), `values.yaml` (the defaults you'll
override), and `templates/` (your manifests, as Go templates referencing those values).

```bash
cd checkout-api-chart
tree -L 2
```

Trim the scaffold down to just what `checkout-api` needs — a Deployment and a Service — and point
it at the image and port this workshop has used all along. In `values.yaml`:

```yaml
replicaCount: 3
image:
  repository: nginx
  tag: "1.25"
service:
  port: 80
```

The generated `templates/deployment.yaml` already references `.Values.replicaCount` and
`.Values.image.repository` — that's the templating in action; you're not hand-editing manifests
anymore, you're editing the values that fill them in.

## Install it (instructor demo)

```bash
helm install checkout-api-release . --set replicaCount=3
```

```bash
helm list
k get deploy -l app.kubernetes.io/instance=checkout-api-release
```

**What to observe:** `helm list` shows a release named `checkout-api-release` at `REVISION 1` —
Helm tracks every install/upgrade as a numbered revision, which is what makes rollback possible.

## Upgrade and roll back (instructor demo)

```bash
helm upgrade checkout-api-release . --set replicaCount=5
helm list
k get deploy -l app.kubernetes.io/instance=checkout-api-release
```

**What to observe:** `REVISION` increments to `2`, and the Deployment now has 5 replicas — no
manifest was hand-edited, only the value changed.

```bash
helm history checkout-api-release
helm rollback checkout-api-release 1
helm list
```

**What to observe:** back to `REVISION 3` (rollback is itself a new revision, not a time-travel
back to 1), and the Deployment is back to 3 replicas.

> **Exam Tip:** `helm rollback <release> <revision>` is the Helm-world equivalent of
> `kubectl rollout undo` — same idea, one layer up. `helm history` is your `kubectl rollout
> history`.

## Install an existing public chart (semi-guided)

The exam is more likely to ask you to install someone else's chart than write your own. Add a
repo and install from it:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo bitnami/nginx
```

<details>
<summary>Solution</summary>

```bash
helm install checkout-web bitnami/nginx --set replicaCount=2
helm list
k get pods -l app.kubernetes.io/instance=checkout-web
```
</details>

> **Exam Tip:** `helm show values <repo>/<chart>` prints every overridable value before you
> install — the fastest way to find the right `--set` flag without leaving the terminal.

## Uninstall and clean up

```bash
helm uninstall checkout-api-release
helm uninstall checkout-web
cd ..
```

## Independent challenge (5 minutes)

**Scenario:** Install the `bitnami/nginx` chart as a release named `checkout-frontend`, with 2
replicas, then upgrade it to 4 replicas, then check its revision history.

<details>
<summary>Solution</summary>

```bash
helm install checkout-frontend bitnami/nginx --set replicaCount=2
helm upgrade checkout-frontend bitnami/nginx --set replicaCount=4
helm history checkout-frontend
helm uninstall checkout-frontend
```
</details>

> **Docs to search** (only `kubernetes.io/docs` and `kubernetes.io/blog` are open to you in the exam — no bookmarks, so learn to navigate them fast): [helm.sh/docs](https://helm.sh/docs/) is **also** open-book in the exam alongside kubernetes.io — the only other domain you're allowed to reference.

## Practice Labs / Homework

- Lab - Kubernetes - CKAD - Helm
