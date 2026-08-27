# Exam Environment Setup

Do this FIRST — in this workshop and in the real exam. You get 2 hours in the exam; don't waste time on repetitive typing.

> **On macOS? Start bash first.** The exam terminal is bash, but macOS defaults to zsh — and zsh handles some things differently (e.g. it doesn't word-split unquoted variables, so `$do` fails). Run `bash` before anything else so you're practicing in the exact same shell you'll get in the exam. Aliases and exports are per-shell, so set them again after switching.

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
grep -q "set expandtab" ~/.vimrc 2>/dev/null || cat << EOF >> ~/.vimrc
" --- CKAD workshop settings ---
set tabstop=2
set shiftwidth=2
set expandtab
EOF
```

YAML is indentation-sensitive. Without this, a stray tab character breaks your manifest and you'll waste exam minutes hunting for it. This command checks whether the setting already exists before appending, so it's safe to run multiple times and never overwrites an existing `~/.vimrc` — if you already have a personal vim config, your content stays intact.

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

- No dedicated lab for this — it's muscle memory. Type these three blocks every time you open a new cluster, including in every later module.
