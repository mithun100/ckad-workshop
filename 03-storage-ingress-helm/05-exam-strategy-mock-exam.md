# Exam Strategy & Mock Exam

This is the last lesson before you're on your own with KodeKloud, killer.sh, and the real exam.
Everything below is tactics, not new Kubernetes content — the kind of thing that's obvious in
hindsight and expensive to learn during the actual 2 hours.

## The tactics that actually move your score

- **Set up your environment first, every time.** `alias k=kubectl`, `export do=...`, vimrc — the
  30 seconds this costs you at minute 0 saves minutes 5 through 115.
- **Read the whole question before typing anything.** Multi-part questions bury requirements in
  the middle sentence. Missing one subclause after getting the rest right is the most common way
  to lose partial credit on an otherwise-correct answer.
- **Generate, don't hand-write, whenever you can.** `kubectl create/run ... $do > file.yaml`, then
  edit only what the question actually requires changing.
- **Verify after every apply.** `kubectl get`, `kubectl describe` — don't assume success because
  `kubectl apply` printed `created`. A pod stuck in `Pending` still says `created`.
- **Flag and skip past the ~4 minute mark.** Use `kubectl config` contexts/namespaces to jump
  between questions if the exam UI supports it; note the question number and move on. Partial
  credit on 18 questions beats a perfect score on 12.
- **Know your copy-paste shortcuts to the exam terminal.** However the proctoring software hands
  you a remote terminal, practice that exact copy/paste flow beforehand — fumbling it mid-exam
  costs real minutes.
- **`kubectl explain <resource>.<field>` beats searching docs** for a field name or type you've
  forgotten — it's instant and works offline from the terminal itself.

> **Exam Tip:** The single highest-leverage habit in this list is **verify after every apply**.
> Almost every mock-exam point lost in practice runs traces back to assuming a resource worked
> because the command didn't error.

## Mock Exam

Fifteen tasks, spanning all four modules. Treat it like the real thing: **20 minutes**, no
looking at the lesson files, `kubernetes.io/docs` and `helm.sh/docs` only if you get stuck.
Solutions are hidden — check only after you've attempted every task.

1. Create a Pod named `mock-pod-1` using image `nginx`, labeled `app=mock,tier=web`.
2. Create a ConfigMap named `mock-config` with key `ENV=staging`, and a Pod that consumes it as
   an environment variable.
3. Create a Secret named `mock-secret` with key `password=hunter2`, mounted as a volume at
   `/etc/secret` in a Pod.
4. Create a Deployment named `mock-deploy` with 3 replicas of image `nginx:1.25`.
5. Trigger a rolling update of `mock-deploy` to `nginx:1.26`, then roll it back.
6. Create a Job named `mock-job` that runs `busybox` printing `done`, with 2 completions.
7. Create a CronJob named `mock-cron` that runs every 5 minutes, same container as above.
8. Expose `mock-deploy` with a ClusterIP Service named `mock-svc` on port `80`.
9. Create a NetworkPolicy that allows only pods labeled `role=frontend` to reach `mock-deploy`
   on port 80.
10. Create a PVC named `mock-pvc` requesting `256Mi`, using the cluster's default StorageClass.
11. Add a readiness probe and a liveness probe (both HTTP GET on `/`, port 80) to `mock-deploy`.
12. Set resource requests (`100m`/`64Mi`) and limits (`200m`/`128Mi`) on `mock-deploy`.
13. Create an Ingress named `mock-ingress` routing host `mock.local` to `mock-svc` on port 80.
14. Install the `bitnami/nginx` Helm chart as a release named `mock-release` with 2 replicas.
15. A pod named `mock-broken` is stuck in `CrashLoopBackOff` — find the cause and fix it (you'll
    need to create a deliberately broken pod first: use image `busybox` with no `command`, which
    exits immediately — then fix it by adding a long-running command).

<details>
<summary>Solutions</summary>

```bash
# 1
k run mock-pod-1 --image=nginx --labels="app=mock,tier=web"

# 2
k create configmap mock-config --from-literal=ENV=staging
k run mock-pod-2 --image=nginx --env="ENV=staging" --dry-run=client -o yaml > p2.yaml
# then edit p2.yaml to use valueFrom.configMapKeyRef instead of a literal value, or:
cat <<'EOF' | k apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: mock-pod-2
spec:
  containers:
  - name: mock
    image: nginx
    envFrom:
    - configMapRef:
        name: mock-config
EOF

# 3
k create secret generic mock-secret --from-literal=password=hunter2
cat <<'EOF' | k apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: mock-pod-3
spec:
  containers:
  - name: mock
    image: nginx
    volumeMounts:
    - name: secret-vol
      mountPath: /etc/secret
  volumes:
  - name: secret-vol
    secret:
      secretName: mock-secret
EOF

# 4
k create deployment mock-deploy --image=nginx:1.25 --replicas=3

# 5
k set image deployment/mock-deploy nginx=nginx:1.26
k rollout status deployment/mock-deploy
k rollout undo deployment/mock-deploy

# 6
k create job mock-job --image=busybox -- sh -c "echo done"
# edit the generated job to set completions: 2, or:
k patch job mock-job -p '{"spec":{"completions":2}}'

# 7
k create cronjob mock-cron --image=busybox --schedule="*/5 * * * *" -- sh -c "echo done"

# 8
k expose deployment mock-deploy --name=mock-svc --port=80 --target-port=80

# 9
cat <<'EOF' | k apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: mock-netpol
spec:
  podSelector:
    matchLabels:
      app: nginx
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
EOF

# 10
cat <<'EOF' | k apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mock-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 256Mi
EOF

# 11 + 12
k patch deployment mock-deploy -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx","readinessProbe":{"httpGet":{"path":"/","port":80}},"livenessProbe":{"httpGet":{"path":"/","port":80}},"resources":{"requests":{"cpu":"100m","memory":"64Mi"},"limits":{"cpu":"200m","memory":"128Mi"}}}]}}}}'

# 13
cat <<'EOF' | k apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mock-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: mock.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mock-svc
            port:
              number: 80
EOF

# 14
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install mock-release bitnami/nginx --set replicaCount=2

# 15
k run mock-broken --image=busybox
k get pod mock-broken   # CrashLoopBackOff - busybox with no command exits immediately
k delete pod mock-broken
k run mock-broken --image=busybox -- sh -c "sleep 3600"
```
</details>

## After the mock: what's next

- Score yourself honestly — anything under ~80% on a *second* attempt means more KodeKloud labs
  before killer.sh, not straight to killer.sh.
- Use **both** killer.sh attempts included with your registration. The first is diagnostic; the
  second should feel close to a dry run of the real thing.
- Re-read [docs/exam.md](../docs/exam.md)'s **Out of scope** section one more time — RBAC,
  Security Contexts, and Kustomize carry real weight and nothing in this workshop teaches them.

> **Exam Tip:** If you only remember one thing from this whole workshop: the exam rewards
> *recovering* from a broken resource under time pressure, not creating one perfectly on the
> first try. That's been the point of every break/fix exercise since Module 1.

## Practice Labs / Homework

- killer.sh — both included attempts
- Full KodeKloud CKAD mock exams
