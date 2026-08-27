# ConfigMaps and Secrets

`checkout-api` shouldn't have its config baked into the image. Let's externalize it.

## Creating ConfigMaps (instructor demo)

```bash
k create configmap checkout-config --from-literal=ENV=prod --from-literal=LOG_LEVEL=info
k get configmap checkout-config -o yaml
```

From a file:

```bash
cat << EOF > app.properties
ENV=prod
LOG_LEVEL=info
EOF
k create configmap checkout-config-file --from-file=app.properties
```

## Injecting as environment variables (instructor demo)

**Method 1 — `envFrom` (injects ALL keys):**

```yaml
# manifests/pod-with-configmap-env.yaml
apiVersion: v1
kind: Pod
metadata:
  name: checkout-api-env
  labels:
    app: checkout
spec:
  containers:
  - name: checkout-api
    image: nginx
    envFrom:
    - configMapRef:
        name: checkout-config
```

**Method 2 — `valueFrom` (picks ONE specific key):**

```yaml
# manifests/pod-with-configmap-env-single.yaml
apiVersion: v1
kind: Pod
metadata:
  name: checkout-api-env-single
  labels:
    app: checkout
spec:
  containers:
  - name: checkout-api
    image: nginx
    env:
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: checkout-config
          key: LOG_LEVEL
```

```bash
k apply -f manifests/pod-with-configmap-env.yaml
k exec checkout-api-env -- env | grep -E 'ENV|LOG_LEVEL'
```

> **Exam Tip:** The exam question specifies HOW to inject — env var vs. volume. Read carefully; the YAML structure is different for each, and using the wrong one loses you the points for that task even if everything else is right.

> **Blanking on the YAML?** Don't guess the nesting from memory — open [Configure a Pod to Use a ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) (`kubernetes.io/docs`, allowed in the exam). It has copy-pasteable `envFrom`, `valueFrom`, and volume-mount blocks. Or run `k explain pod.spec.containers.envFrom` / `k explain pod.spec.containers.env.valueFrom` for the field structure without leaving the terminal.

## Injecting as a volume mount (semi-guided)

Each key in the ConfigMap becomes a file in the mount path. Build this one yourself using the pattern above as reference — mount `checkout-config` at `/etc/checkout-config` in a pod named `checkout-api-vol`.

<details>
<summary>Solution</summary>

```yaml
# manifests/pod-with-configmap-volume.yaml
apiVersion: v1
kind: Pod
metadata:
  name: checkout-api-vol
  labels:
    app: checkout
spec:
  containers:
  - name: checkout-api
    image: nginx
    volumeMounts:
    - name: config-volume
      mountPath: /etc/checkout-config
  volumes:
  - name: config-volume
    configMap:
      name: checkout-config
```

```bash
k apply -f manifests/pod-with-configmap-volume.yaml
k exec checkout-api-vol -- ls /etc/checkout-config
k exec checkout-api-vol -- cat /etc/checkout-config/LOG_LEVEL
```
</details>

## Creating Secrets (instructor demo)

```bash
k create secret generic checkout-db-secret --from-literal=password=mysecretpass
k get secret checkout-db-secret -o yaml
```

**Note the value is base64-encoded, NOT encrypted:**

```bash
echo "bXlzZWNyZXRwYXNz" | base64 -d
```

## Injecting Secrets (same two methods)

```yaml
# manifests/pod-with-secret.yaml
apiVersion: v1
kind: Pod
metadata:
  name: checkout-api-secret
  labels:
    app: checkout
spec:
  containers:
  - name: checkout-api
    image: nginx
    envFrom:
    - secretRef:
        name: checkout-db-secret
```

```bash
k apply -f manifests/pod-with-secret.yaml
k exec checkout-api-secret -- env | grep password
```

## Break it / troubleshoot (~4 minutes)

Instructor applies a pod referencing a ConfigMap key that doesn't exist:

```yaml
# manifests/broken-configmap-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: checkout-broken-config
spec:
  containers:
  - name: checkout-api
    image: nginx
    env:
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: checkout-config
          key: DOES_NOT_EXIST
```

```bash
k apply -f manifests/broken-configmap-pod.yaml
k get pods checkout-broken-config
```

**What you'll see:** `CreateContainerConfigError`.

**Ask the room:** "Where do you look first?" → `kubectl describe pod checkout-broken-config`, check `Events`.

**Root cause:** the key `DOES_NOT_EXIST` isn't in `checkout-config`. **Fix:** correct the key name to `LOG_LEVEL` and re-apply.

## Practice Labs / Homework

- Lab - Kubernetes - CKAD - ConfigMaps
- Lab - Kubernetes - CKAD - Secrets
- Lab - Kubernetes - CKAD - Commands and Arguments

> **Exam Tip:** `envFrom` injects every key in the ConfigMap/Secret as an env var named after the key. `valueFrom` + `configMapKeyRef`/`secretKeyRef` picks exactly one key and lets you rename it. Know both — the exam tests the distinction directly.

> **Docs to search** (only `kubernetes.io/docs` and `kubernetes.io/blog` are open to you in the exam — no bookmarks, so learn to navigate them fast): [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/) · [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) · [Configure a Pod to Use a ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) — the task pages have copy-pasteable YAML blocks worth knowing how to find.
