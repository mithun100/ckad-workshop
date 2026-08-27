# Delivery Schedule

The workshop content is organized by **topic module**, not by session number. This file is
the only place that maps modules to actual live sessions — if you run this as 3 sessions,
5 sessions, or a single all-day workshop, edit this file only. Nothing inside the module
folders needs to change.

## Current plan: Cloud Native Dallas, 3 sessions × 90 minutes

| Session | Date | Module(s) covered |
|---|---|---|
| Session 1 | TBD | `01-pods-and-configuration` |
| Session 2 | TBD | `02-workloads-and-networking` |
| Session 3 | TBD | `03-storage-ingress-helm` |

## Modules (in dependency order)

1. **`01-pods-and-configuration`** — Pods, ConfigMaps, Secrets. Establishes the running
   `checkout-api` scenario and its labels. Everything downstream depends on this module's
   label scheme (`app=checkout,tier=<role>`).
2. **`02-workloads-and-networking`** — Multi-container pods, Deployments, Jobs/CronJobs,
   Services, NetworkPolicies. Requires module 1.
3. **`03-storage-ingress-helm`** — Ingress, Volumes/PVCs, Helm, exam strategy, mock exam.
   Requires modules 1 and 2.

## If you need to re-pace this later

- **Fewer, longer sessions:** combine modules 2 and 3 into one session — nothing in either
  module's content changes, just update the table above.
- **More, shorter sessions:** split a module in two (e.g., Deployments as its own session,
  Jobs/Services/Networking as another) — same principle, edit the table, don't rename folders.
- **Different audience/cadence (e.g., the internal work version):** duplicate this file as
  `SCHEDULE-work.md` with its own session mapping, keep the module folders untouched and
  shared between both audiences.
