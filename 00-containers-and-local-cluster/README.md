# Module 0: Episode Zero — Containers & Local Cluster Setup

**Duration:** 1.5 hours
**Live platform:** Your own Mac (bring it!) — this is the one session where we deliberately
leave the shared KodeKloud playground, because the whole point is learning to stand up your own
environment.
**Where this fits in your delivery schedule:** see `/SCHEDULE.md` at the repo root

> You spoke, we listened. Presenting **Kubernetes: Episode Zero**, the prequel to our Zero to
> Cluster CKAD Cohort.
>
> Every great franchise has a prequel. Ours has fewer lightsabers and more YAML.

## Why this exists

Every later module in this workshop assumes you already have a cluster you can run `kubectl`
against. This session is the one before that assumption — how containers actually work, how to
run them locally without Docker Desktop if you'd rather not, and how to stand up the single-node
cluster the rest of the workshop depends on. Come here first if any of that isn't true yet.

This is a **prequel**, not a prerequisite re-run: nothing here is graded CKAD content, and nobody
re-teaches this later. If you already have Docker/Podman and a working local cluster, you can
skip straight to [`01-pods-and-configuration`](../01-pods-and-configuration/README.md).

## Prerequisites (confirm BEFORE the session)

- A Mac with at least **8 GB of free RAM** — your laptop fan will have opinions, ignore them.
- Admin rights to install software (Docker Desktop or Podman, plus a local Kubernetes tool).
- Nothing else — that's the point of this session.

## Agenda

| Time | Block |
|---|---|
| 0:00–0:25 | [Docker and containers 101](01-docker-basics.md) — why "it works on my machine" is no longer an excuse |
| 0:25–0:50 | [Podman on your Mac](02-podman-on-mac.md) — runs the same containers as Docker |
| 0:50–1:20 | [Single-node Kubernetes on your Mac](03-single-node-kubernetes.md) — your laptop fan will have opinions |
| 1:20–1:30 | Session 1 recap — a refresher if you were there, and we'll pretend we didn't notice if you weren't |

## Contents

1. [Docker and containers 101](01-docker-basics.md)
2. [Podman on your Mac](02-podman-on-mac.md)
3. [Single-node Kubernetes on your Mac](03-single-node-kubernetes.md)

## What you'll leave with

- A working container runtime on your own Mac — Docker Desktop, Podman, or both.
- A single-node Kubernetes cluster you can run `kubectl get nodes` against.
- Everything [`01-pods-and-configuration`](../01-pods-and-configuration/README.md) assumes you
  already have, confirmed working before Session 1 starts.

## Practice Labs

- No dedicated lab — bring your own laptop, follow along live, and leave with a cluster running.
