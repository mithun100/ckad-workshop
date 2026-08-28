# CKAD Exam Prep Workshop — Cloud Native Dallas

> A hands-on CKAD workshop where the instructor demos it, you do the labs, and everything is built around **one application that evolves** — from a single Pod into a production-shaped, storage-backed, Ingress-fronted service.

This is the guided, live-troubleshooting layer that sits **on top of** a structured CKAD course
(KodeKloud / Mumshad's course) — not a replacement for it. You watch a concept demoed, repeat it
yourself, then deliberately **break it and fix it**, because diagnosing failures under time
pressure is what the exam actually rewards.

The whole workshop follows **one app — `checkout-api`** — as it evolves from a bare Pod into a
Deployment, then a storage-backed, Ingress-fronted service. The [how it works](docs/how-it-works.md)
guide covers the teaching method, the running scenario, and the diagram of how the modules connect.

---

## Start here

| To understand… | Read |
|---|---|
| **How the workshop works** — teaching method, the `checkout-api` story, prerequisites | [docs/how-it-works.md](docs/how-it-works.md) |
| **The CKAD exam** — format, scoring, domain weights, what's out of scope | [docs/exam.md](docs/exam.md) |
| **Who's running it** | [docs/facilitator.md](docs/facilitator.md) |
| **When each module maps to a live session** | [SCHEDULE.md](SCHEDULE.md) |

## Modules

Content is organized by **topic**, not by session number — [SCHEDULE.md](SCHEDULE.md) is the
single source of truth for how modules map onto live sessions, so the same material re-runs at any
cadence (3 sessions, 5 sessions, or a single all-day workshop) without restructuring.

| Module | Topics | Status |
|---|---|---|
| [`01-pods-and-configuration`](01-pods-and-configuration/README.md) | Pods, ConfigMaps, Secrets | **Available** |
| [`02-workloads-and-networking`](02-workloads-and-networking/README.md) | Multi-container Pods, Deployments, Jobs/CronJobs, Services, NetworkPolicies | **Available** |
| `03-storage-ingress-helm` | Ingress, Volumes/PVCs, Helm, exam strategy, mock exam | Planned |

Modules are published as they are built.

## Prerequisites

You need a Kubernetes cluster you can reach with `kubectl` and a CKAD course for the homework labs
— see [full prerequisites](docs/how-it-works.md#prerequisites). Set these exam-style shortcuts in
your shell first:

```bash
alias k=kubectl
export do='--dry-run=client -o yaml'   # generate manifests fast
alias kn='kubectl config set-context --current --namespace'
```

All manifests use only **public images** (`nginx`, `busybox`) and no cluster-specific features, so
every example runs anywhere — not just on one vendor's playground.

## Connect

Built and facilitated by **Mithun Banerjee**. If you attended a session, want to run this for your
own community, or just want to talk Kubernetes and CKAD — connect with me:

**LinkedIn:** [https://www.linkedin.com/in/mbanerjee/](https://www.linkedin.com/in/mbanerjee/)

Feedback, issues, and PRs are welcome.

## License

Released under the [MIT License](LICENSE).
