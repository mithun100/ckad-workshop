# The CKAD exam

[← Back to overview](../README.md)

The Certified Kubernetes Application Developer exam is entirely **performance-based** — you
solve tasks in a live cluster, not multiple-choice questions. Everything in this workshop is
shaped to match that reality: imperative-first command habits, verify-after-apply, and
diagnosing broken resources against the clock.

## The facts

| Fact | Detail |
|---|---|
| Format | Performance-based, hands-on in a real cluster |
| Duration | 2 hours |
| Tasks | 15–20 |
| Passing score | 66% |
| Open book | Yes — `kubernetes.io/docs` and `kubernetes.io/blog` only |
| Retake | One free retake included with registration |

> With ~15–20 tasks in 120 minutes, you have roughly **6 minutes per task**. Flag and skip
> anything you can't crack in ~4 minutes and come back — leaving points on easy tasks
> because you got stuck on a hard one is the most common way strong candidates fail.

## Domain weights

| Domain | Weight |
|---|---|
| Application Design and Build | 20% |
| Application Deployment | 20% |
| Application Observability and Maintenance | 15% |
| Application Environment, Configuration and Security | 25% |
| Services and Networking | 20% |

<details>
<summary>How the workshop modules map to these domains</summary>

- **Module 1 (Pods & Configuration)** — Application Design and Build; Application
  Environment, Configuration and Security.
- **Module 2 (Workloads & Networking)** — Application Deployment; Services and Networking;
  Application Observability and Maintenance.
- **Module 3 (Storage, Ingress & Helm)** — Services and Networking; Application Deployment;
  plus exam strategy and a timed mini-mock.

</details>

## Out of scope (self-study)

Stated plainly rather than quietly omitted — these are real CKAD content but are **not**
covered live in this workshop's three-module scope:

- **Security deep-dive** — RBAC, Service Accounts, Security Contexts, Admission Controllers,
  Taints/Tolerations, Node Affinity.
- **Kustomize.**

They carry real exam weight. Budget self-study time for them alongside this workshop.

## Resources

- **Mumshad Mannambeth's CKAD course** — the primary reference and the source of the
  homework labs. On [KodeKloud](https://learn.kodekloud.com/learn/courses/certified-kubernetes-application-developer-ckad) or [Udemy](https://www.udemy.com/course/certified-kubernetes-application-developer/).
- [kubernetes.io/docs](https://kubernetes.io/docs/) — the only documentation allowed in the exam.
- [kubectl cheat sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/).
- [killer.sh](https://killer.sh/) — the exam simulator included with your CKAD registration.

---

Next: [who's running this →](facilitator.md)
