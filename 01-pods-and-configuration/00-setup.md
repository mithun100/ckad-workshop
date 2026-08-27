# Exam Environment Setup

Do this FIRST — in this workshop and in the real exam. You get 2 hours in the exam; don't waste time on repetitive typing.

## Aliases

```bash
alias k=kubectl
alias kn='kubectl config set-context --current --namespace'
export do='--dry-run=client -o yaml'
```

**Why each one matters:**
- `alias k=kubectl` — you'll type `kubectl` hundreds of times today and in the exam. Saves real seconds, every time.
- `alias kn=...` — switches your default namespace instantly instead of typing `-n <namespace>` on every command.
- `export do=...` — turns YAML generation into `k run pod1 --image=nginx $do > pod.yaml` instead of typing the full dry-run flag every time.

## vimrc setup

```bash
cat << EOF > ~/.vimrc
set tabstop=2
set shiftwidth=2
set expandtab
EOF
```

YAML is indentation-sensitive. Without this, a stray tab character breaks your manifest and you'll waste exam minutes hunting for it.

## Verify your cluster

```bash
kubectl cluster-info
kubectl get nodes
kubectl get ns
```

**Expected output:** `cluster-info` shows a control plane URL; `get nodes` shows at least one node in `Ready` status; `get ns` shows at least `default`, `kube-system`, `kube-public`.

If any of these fail, flag it now — don't wait.

> **Exam Tip:** Do this FIRST in the actual exam. You get 2 hours — don't waste time on repetitive typing.

## Practice Labs

- No dedicated lab for this — it's muscle memory. Type these three blocks every time you open a new cluster, including in Sessions 2 and 3 today.
