# Module: Storage, Ingress & Helm

**Duration:** 1.5 hours
**Live platform:** KodeKloud playground (everyone uses the same environment — see prerequisites below)
**Where this fits in your delivery schedule:** see `/SCHEDULE.md` at the repo root

## Running scenario

This is the final module in the `checkout-api` story — and the one that catches up on exam-heavy
topics the story hasn't needed yet.

- Previous module: `checkout-api` became a self-healing Deployment, exposed by a Service and
  locked down by a NetworkPolicy, with a Job doing order cleanup.
- This module: give `checkout-db` real **persistent storage** so its data survives a pod
  restart, make `checkout-api` self-reporting with **probes** so Kubernetes knows when it's
  actually healthy (not just running), add **resource requests/limits** so it behaves on a
  shared cluster, front it with an **Ingress**, then package the whole thing with **Helm**.
- After this module: the exam itself — strategy, and a timed mock covering all three modules.

Two of this module's topics — probes and resource requests/limits — don't extend the
`checkout-api` story so much as **fix a gap in it**: every pod in Modules 1–2 has been running
without either, which is unrealistic and under-tested territory for the exam. This module closes
that gap before the mock exam, not after.

## Prerequisites (confirm BEFORE the session)

- Everything from the previous modules — aliases (`k`, `kn`), `export do`, and vimrc.
- `checkout-api-deploy` and the `checkout-api` Service from Module 2 should still exist (re-apply
  `02-workloads-and-networking/manifests/deployment.yaml` and `service-clusterip.yaml` if not).
- Run `kubectl get nodes` — at least one node in `Ready` state.

## Agenda

| Time | Block |
|---|---|
| 0:00–0:10 | Recap of previous module's homework |
| 0:10–0:30 | Volumes & Persistent Storage — emptyDir, PV/PVC, StorageClass, break/fix |
| 0:30–0:50 | Probes & Resources — liveness/readiness/startup, requests/limits, OOMKilled |
| 0:50–1:05 | Ingress — routing rules, break/fix |
| 1:05–1:20 | Helm — package, install, upgrade, rollback |
| 1:20–1:30 | Exam strategy + closing |

## CKAD domains covered

- Application Design and Build — 20% (volumes)
- Application Deployment — 20% (Helm)
- Application Observability and Maintenance — 15% (probes)
- Application Environment, Configuration and Security — 25% (resource requests/limits)
- Services and Networking — 20% (Ingress)

## Contents

1. [Volumes & Persistent Storage](01-volumes-and-storage.md) — emptyDir, PV/PVC, StorageClass
2. [Probes & Resources](02-probes-and-resources.md) — liveness/readiness/startup, requests/limits
3. [Ingress](03-ingress.md) — host and path routing rules
4. [Helm](04-helm.md) — package, install, upgrade, rollback
5. [Exam Strategy & Mock Exam](05-exam-strategy-mock-exam.md) — tactics + a timed practice set

## Homework before the exam

**KodeKloud labs (do these for repetition — we only demoed a slice live):**
- Lab - Kubernetes - CKAD - Persistent Volumes and Persistent Volume Claims
- Lab - Kubernetes - CKAD - Readiness and Liveness Probes
- Lab - Kubernetes - CKAD - Resource Requirements and Limits
- Lab - Kubernetes - CKAD - Ingress
- Lab - Kubernetes - CKAD - Helm

**Before exam day:**
- [killer.sh](https://killer.sh/) — the exam simulator included with your CKAD registration. Use both attempts.
- Re-read [docs/exam.md](../docs/exam.md), especially **Out of scope (self-study)** — those topics carry real weight and nothing in this workshop teaches them.

> **Exam Tip:** This is the last guided rep you get. Everything from here is repetition — the
> KodeKloud practice tests and killer.sh are where the muscle memory that actually survives a
> 2-hour clock gets built.

## Practice Labs

- Lab - Kubernetes - CKAD - Persistent Volumes and Persistent Volume Claims
- Lab - Kubernetes - CKAD - Readiness and Liveness Probes
- Lab - Kubernetes - CKAD - Ingress
- Lab - Kubernetes - CKAD - Helm
