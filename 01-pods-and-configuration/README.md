# Module: Pods, ConfigMaps & Secrets

**Duration:** 1.5 hours
**Live platform:** KodeKloud playground (everyone uses the same environment — see prerequisites below)
**Where this fits in your delivery schedule:** see `/SCHEDULE.md` at the repo root

## Running scenario

Across this whole module set we build and evolve one small app: **`checkout-api`**.

- This module: deploy it as a Pod, externalize its configuration
- Next module (workloads/networking): make it resilient (Deployment), add a Job, expose it with a Service
- Final module (storage/ingress/helm): give it persistent storage, front it with Ingress, package it with Helm

The labels you assign to `checkout-api` here are the same ones a Service will select on in the next module — so a sloppy label choice now creates a real (and instructive) problem later.

## Prerequisites (confirm BEFORE the session)

- Log into KodeKloud, launch the CKAD course playground once
- Run `kubectl get nodes` — you should see at least one node in `Ready` state
- If this doesn't work, flag it immediately — don't wait until we start

## Agenda

| Time | Block |
|---|---|
| 0:00–0:25 | Opening + exam overview + environment setup |
| 0:25–1:00 | Pods — demo + guided lab + break/fix |
| 1:00–1:35 | ConfigMaps & Secrets — demo + guided lab (env var AND volume mount) |
| 1:35–1:30 | Closing + homework (compress to 5 min if we're running late) |

## CKAD domains covered

- Application Design and Build — 20%
- Application Environment, Configuration and Security — 25%

## Homework before the next module

**KodeKloud labs (do these for repetition — we only demoed a slice live):**
- Lab - Kubernetes - CKAD - ConfigMaps
- Lab - Kubernetes - CKAD - Secrets
- Lab - Kubernetes - CKAD - Commands and Arguments

**Videos to watch before the next module** (Mumshad's CKAD course):
- Deployments
- Services
- Jobs

> **Exam Tip:** Homework isn't optional filler — the live session only gives you one guided rep per topic. The KodeKloud practice tests are where the muscle memory actually forms.

## Practice Labs

- Lab - Kubernetes - CKAD - Pods
- Lab - Kubernetes - CKAD - ConfigMaps
- Lab - Kubernetes - CKAD - Secrets
