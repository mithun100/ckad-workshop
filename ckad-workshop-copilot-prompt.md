# CKAD Workshop Repo — Continuation Prompt for GitHub Copilot / Claude in VS Code

Paste this whole prompt into your Copilot Chat (Claude model) inside VS Code, with the
`ckad-workshop` repo open as your workspace. It gives full context so you don't need to
re-explain anything from a prior conversation.

---

## Who I am / what this is

I'm Mithun Banerjee, running a 3-session, 90-minutes-per-session, hands-on CKAD exam prep
workshop for the Cloud Native Dallas CNCF community, and later re-running the same content
internally at my employer (Cisco AppDynamics). I hold CKA, CKAD, CKS, KCNA, CCA.

The repo `ckad-workshop` already exists on GitHub at `github.com/mithun100/ckad-workshop`
and is checked out in this workspace. **Do not assume you're starting from scratch** —
read the existing files in this repo before generating anything, and match their
established style exactly.

## Current repo state (as of last commit)

```
ckad-workshop/
├── SCHEDULE.md
└── 01-pods-and-configuration/
    ├── README.md
    ├── 00-setup.md
    ├── 01-pods.md
    ├── 02-configmaps-secrets.md
    └── manifests/
        ├── pod-basic.yaml
        ├── pod-labels.yaml
        ├── configmap.yaml
        ├── pod-with-configmap-env.yaml
        ├── pod-with-configmap-env-single.yaml
        ├── pod-with-configmap-volume.yaml
        ├── pod-with-secret.yaml
        ├── broken-pod.yaml
        └── broken-configmap-pod.yaml
```

This module (`01-pods-and-configuration`) is content-complete and validated. **Do not
regenerate or restructure it** except for the one specific fix below.

## Repo-wide conventions — read these before generating or editing anything

### 1. Folder naming is topic-based, not session-based
Folders are named `01-pods-and-configuration`, `02-workloads-and-networking`,
`03-storage-ingress-helm` — NOT `session-1`, `session-2`, `session-3`. This is deliberate:
`SCHEDULE.md` at the repo root is the ONLY place that maps topic modules to actual live
session numbers/dates. This lets the delivery cadence change (more sessions, fewer, reorder)
without renaming any content folder. When writing content inside a module, don't hardcode
"Session 1" or "Session 2" — say "this module" and "the next module" instead, and point to
`/SCHEDULE.md` for the actual mapping.

### 2. One running application across every module: `checkout-api`
Never invent a new example app name or use generic `nginx1/nginx2/nginx3`-style filler.
The scenario already established:
- Module 1 (done): `checkout-api` and `checkout-db` as Pods, labeled
  `app=checkout,tier=<backend|database|worker>`
- Module 2 (not yet built): evolve `checkout-api` into a Deployment; add sidecar/init
  container variants; add a Job/CronJob for a checkout-related batch task; expose
  `checkout-api` via Service using the SAME labels from module 1; NetworkPolicy scoped to
  `app=checkout`
- Module 3 (not yet built): Ingress in front of `checkout-api`; PV/PVC for `checkout-db`;
  Helm lifecycle demo (can use a generic public chart like bitnami/nginx for this one,
  since Helm mechanics don't need to tie to the scenario)

### 3. Cluster-agnostic and portable — no exceptions
Every command and manifest must run unmodified on ANY conformant Kubernetes cluster —
KodeKloud's playground (the live-session platform), kind, minikube, Docker Desktop, or a
cloud cluster. No platform-specific paths, contexts, or pre-existing assumptions.

### 4. Idempotent / non-destructive by default
Any command that writes to a file a person might already have content in (dotfiles like
`~/.vimrc`, shell configs, etc.) MUST use an idempotent, append-safe pattern — never a bare
`>` overwrite on files that might pre-exist with the person's own content. Check-then-append
or grep-guarded append is the required pattern. See the fix needed below for the concrete
example of what NOT to do and how to correct it.

### 5. Live-demo vs. homework split — apply to every topic
Every topic subsection follows this exact structure (see `01-pods.md` and
`02-configmaps-secrets.md` in module 1 for the reference implementation):

1. **Instructor demo** — one representative task, full command + YAML + expected output
2. **Guided/semi-guided repeat** — participant does a close variant themselves, hint in a
   `<details><summary>Hint</summary>...</details>` collapsible block, not shown inline
3. **One break/troubleshoot moment per major topic** (not every subtopic) — deliberately
   broken manifest saved as its own file in `manifests/` (not just inline in the `.md`),
   the failure state, the diagnostic question to ask the room, root cause, fix
4. **Independent challenge** — scenario + requirements only, collapsible solution
5. **Practice Labs** section at the end pointing to real KodeKloud lab names (see list below)

### 6. Style rules
- `#` file title, `##` major sections, `###` only if truly needed
- Commands in ` ```bash ` blocks, manifests in ` ```yaml ` blocks
- Every manifest file gets a one-line comment at the top: purpose + any prerequisite
- `> **Exam Tip:** ...` blockquote callouts, tied to something concrete just demonstrated
- No walls of text — short explanation, then command, then expected output
- Reuse the aliases already defined in module 1's `00-setup.md` (`k=kubectl`, `$do` for
  dry-run, `kn` for namespace switching) in all later command examples — don't redefine
  `kubectl` in full each time
- Every YAML file must be valid (parseable by `yaml.safe_load`) — validate before
  considering a file done

---

## TASK 1 — Fix needed right now in `01-pods-and-configuration/00-setup.md`

The `.vimrc` setup command currently uses a destructive overwrite (`>`), which would wipe
out any pre-existing personal vim config on someone's machine. Find this block in
`00-setup.md`:

```bash
cat << EOF > ~/.vimrc
set tabstop=2
set shiftwidth=2
set expandtab
EOF
```

Replace it with this idempotent, non-destructive version:

```bash
grep -q "set expandtab" ~/.vimrc 2>/dev/null || cat << EOF >> ~/.vimrc
" --- CKAD workshop settings ---
set tabstop=2
set shiftwidth=2
set expandtab
EOF
```

Also update the explanatory prose immediately around that block to reflect the new
behavior: it checks whether the setting already exists before appending, so it's safe to
run multiple times and never destroys existing vimrc content. Keep everything else in the
file unchanged.

Do this fix now, as a standalone edit — don't touch anything else in the repo in this task.

---

## TASK 2 — Generate Module 2: `02-workloads-and-networking` (do this only when I ask for it, not automatically)

When I ask you to proceed with this, generate the following, matching every convention
above and using `01-pods-and-configuration`'s files as your style reference:

```
02-workloads-and-networking/
├── README.md
├── 01-multi-container-pods.md
├── 02-deployments.md
├── 03-jobs-cronjobs.md
├── 04-services-networking.md
└── manifests/
    ├── sidecar-pod.yaml
    ├── init-container-pod.yaml
    ├── deployment.yaml
    ├── job.yaml
    ├── cronjob.yaml
    ├── service-clusterip.yaml
    ├── service-nodeport.yaml
    ├── networkpolicy.yaml
    └── (any broken-* manifests needed for that module's break/fix exercises)
```

**Content specifics:**

- **01-multi-container-pods.md** — recap Module 1 homework (Multi-Container Pods, Init
  Containers KodeKloud labs). Demo sidecar pattern: `checkout-api` main container + a
  log-shipper sidecar sharing an `emptyDir` volume. Demo init-container pattern: an init
  container that waits for `checkout-db` to be reachable before `checkout-api` starts.
  Include the "run X before app starts = init container, run X alongside = sidecar"
  framing.

- **02-deployments.md** — evolve `checkout-api` from a bare Pod into a Deployment
  (`checkout-api-deploy`, 3 replicas, reusing `app=checkout,tier=backend` labels). Cover:
  imperative creation, `$do` YAML generation, scaling, `kubectl set image` rolling update,
  `rollout status`, `rollout history`, `rollout undo` (with `--to-revision`), RollingUpdate
  vs Recreate with `maxSurge`/`maxUnavailable` in an annotated manifest.

- **03-jobs-cronjobs.md** — add a `checkout-order-cleanup` Job (busybox, simulated cleanup
  task) and CronJob version. Explain `completions`, `parallelism`, `backoffLimit`,
  `activeDeadlineSeconds`.

- **04-services-networking.md** — expose `checkout-api-deploy` via ClusterIP and NodePort
  Services using selector `app=checkout,tier=backend` — explicitly call back to why the
  Module 1 label choice matters here. DNS verification with `nslookup`. NetworkPolicy
  scoped to `app=checkout`. Break/fix: a Service with a selector that matches no pod's
  labels — empty `Endpoints`, diagnosed with `kubectl get endpoints` / `kubectl describe svc`.

**KodeKloud homework labs to reference (verbatim names):**
- Lab - Kubernetes CKAD - Multi Container Pods
- Practice Test – Init Containers
- Lab - Kubernetes - CKAD - Rolling Updates and Rollbacks
- Lab - Deployment strategies (flag as optional/bonus — Blue-Green/Canary, beyond core scope)
- Lab - Kubernetes - CKAD - Jobs and CronJobs
- Lab - Kubernetes - CKAD - Network Policies

**Time budget (90 min):** 10 min recap → 30 min Deployments → 20 min Jobs/CronJobs →
25 min Services/Networking → 5 min close/homework.

---

## TASK 3 — Generate Module 3: `03-storage-ingress-helm` (do this only when I ask for it)

```
03-storage-ingress-helm/
├── README.md
├── 01-ingress.md
├── 02-volumes-pvc.md
├── 03-helm.md
├── 04-exam-strategy.md
└── manifests/
    ├── ingress.yaml
    ├── pv.yaml
    ├── pvc.yaml
    ├── pod-with-pvc.yaml
    └── (any broken-* manifests needed for that module's break/fix exercises)
```

**Content specifics:**

- **01-ingress.md** — path-based routing for `checkout-api-deploy`'s Service, then
  host-based routing, then TLS config. Note: "you won't install the controller in the
  exam — it's already there, you just write the Ingress resource."

- **02-volumes-pvc.md** — PersistentVolume + PVC for `checkout-db` (hostPath-backed for
  portability), pod mounting the PVC, demonstrate data survives pod deletion/recreation,
  explain access modes. Break/fix: PV/PVC access-mode mismatch — PVC stays `Pending`,
  diagnosed with `kubectl describe pvc`.

- **03-helm.md** — standard lifecycle against a public chart (bitnami/nginx is fine here):
  repo add, search, install, list, upgrade `--set`, rollback, uninstall, `helm template`.
  Exam tip: Helm is ~5-8% of the exam, know lifecycle commands, don't over-study it.

- **04-exam-strategy.md** — time management (2 hrs / 15-20 tasks ≈ 6 min/task, flag after
  4 min), imperative-first workflow recap, `kubectl explain` as docs, allowed bookmarks
  (kubernetes.io/docs and /blog only), verify-after-apply habit, exam-day routine checklist.

**KodeKloud homework labs to reference (verbatim names):**
- Lab - CKAD - Ingress Networking - 1
- Lab - CKAD - Ingress Networking - 2
- Lab - Kubernetes - CKAD - Persistent Volumes
- Lab - Storage Class (flag as optional/bonus — beyond core scope)
- Lab – Install Helm
- Lab – Helm Concepts

**Final exam-prep homework (assign at the end of this module, no Module 4 to build toward):**
- Lightning Lab - 1
- Lightning Lab - 2
- Mock Exam - 1
- Mock Exam - 2

**Explicitly flag as self-study only, not covered live anywhere** (real exam weight, no
room in 3 modules): the Security module (RBAC, Service Accounts, Security Contexts,
Admission Controllers, Taints/Tolerations, Node Affinity) and Kustomize module. Mention
this once at the end of `04-exam-strategy.md`, don't build content for it.

**Time budget (90 min):** 15 min Ingress → 15 min Volumes/PVC → 15 min Helm → 10 min exam
strategy → 25 min timed mini mock exam → 10 min debrief.

---

## TASK 4 — Root-level files (do this only when I ask for it)

- **README.md** (repo root) — title "CKAD Exam Prep Workshop — Cloud Native Dallas",
  overview of the 3-module structure built around `checkout-api`, facilitator bio
  (Mithun Banerjee, Senior Technical Leader at Cisco AppDynamics, CKA/CKAD/CKS/KCNA/CCA,
  github.com/mithun100, linkedin.com/in/mbanerjee), link to `SCHEDULE.md` for session
  mapping, prerequisites (KodeKloud account, live sessions standardize on KodeKloud
  playground), CKAD exam overview and domain weight table, resources section, MIT license note.
- **cheatsheet.md** — single-page exam-day reference, reusing the exact aliases/vimrc/
  namespace shortcut from module 1's `00-setup.md` verbatim (don't redefine differently),
  imperative command reference per resource type, `kubectl debug` commands, YAML skeletons,
  time management tips matching `04-exam-strategy.md`.
- **LICENSE** — MIT License, copyright 2026 Mithun Banerjee.

---

## How to work with me on this

- Do TASK 1 immediately — it's a real bug fix, not a nice-to-have.
- Do NOT start TASK 2, 3, or 4 until I explicitly say to proceed with them — I'm building
  this module by module, close to when I'll actually teach each one, not all at once.
- Before generating anything, validate every YAML file you produce parses correctly.
- If anything in my existing repo conflicts with an instruction above, tell me the
  conflict rather than silently picking one — I'd rather resolve it than have it guessed.
