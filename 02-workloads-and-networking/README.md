# Module: Workloads & Networking

**Duration:** 1.5 hours
**Live platform:** KodeKloud playground (everyone uses the same environment — see prerequisites below)
**Where this fits in your delivery schedule:** see `/SCHEDULE.md` at the repo root

## Running scenario

This module continues the **`checkout-api`** story from the previous module.

- Previous module: `checkout-api` ran as a single Pod with its configuration externalized into ConfigMaps and Secrets, labeled `app=checkout,tier=backend`.
- This module: make it real. Add a sidecar and an init container, evolve the bare Pod into a self-healing **Deployment**, run a batch **Job/CronJob** for order cleanup, and expose it with a **Service** — using the exact labels you chose in the previous module. Then lock down traffic with a **NetworkPolicy**.
- Next module (storage/ingress/helm): give it persistent storage, front it with Ingress, package it with Helm.

The label choice `app=checkout,tier=backend` you made in the previous module is what a Service selects on here. A sloppy label then becomes an empty `Endpoints` list now — we break exactly that on purpose.

## Prerequisites (confirm BEFORE the session)

- Everything from the previous module (`01-pods-and-configuration/00-setup.md`) — aliases (`k`, `kn`), `export do`, and vimrc.
- macOS users: start `bash` first so your shell matches the exam (see the previous module's setup notes).
- Run `kubectl get nodes` — at least one node in `Ready` state.

## Agenda

| Time | Block |
|---|---|
| 0:00–0:10 | Recap of previous module's homework + multi-container pods |
| 0:10–0:40 | Deployments — ReplicaSet bridge, rollouts, rollback |
| 0:40–1:00 | Jobs & CronJobs |
| 1:00–1:25 | Services & Networking — ClusterIP, NodePort, DNS, NetworkPolicy, break/fix |
| 1:25–1:30 | Closing + homework |

## CKAD domains covered

- Application Deployment — 20%
- Services and Networking — 20%
- Application Observability and Maintenance — 15%

## Contents

1. [Multi-container Pods](01-multi-container-pods.md) — sidecar and init container patterns
2. [Deployments](02-deployments.md) — ReplicaSet → Deployment, rolling updates, rollback
3. [Jobs & CronJobs](03-jobs-cronjobs.md) — batch and scheduled tasks
4. [Services & Networking](04-services-networking.md) — ClusterIP, NodePort, DNS, NetworkPolicy

## Homework before the next module

**KodeKloud labs (do these for repetition — we only demoed a slice live):**
- Lab - Kubernetes CKAD - Multi Container Pods
- Practice Test – Init Containers
- Lab - Kubernetes - CKAD - Rolling Updates and Rollbacks
- Lab - Deployment strategies (optional/bonus — Blue-Green/Canary, beyond core scope)
- Lab - Kubernetes - CKAD - Jobs and CronJobs
- Lab - Kubernetes - CKAD - Network Policies

**Videos to watch before the next module** (Mumshad's CKAD course):
- Persistent Volumes and Persistent Volume Claims
- Ingress
- Helm

> **Exam Tip:** Deployments, Services, and their labels/selectors are among the most heavily tested topics on the CKAD. The break/fix in this module — a Service selecting no pods — is one of the most common real failure modes you'll debug on exam day.
