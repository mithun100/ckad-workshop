# Jobs and CronJobs

Not everything is a long-running server. `checkout-api` also needs batch work — clearing out
stale, abandoned orders. That's a **Job** (run once to completion) or a **CronJob** (run on a
schedule). Unlike a Deployment, these are *meant* to exit.

## Jobs (instructor demo)

A Job runs a pod until it completes successfully, then stops. Here, a simulated cleanup task.

```yaml
# manifests/job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: checkout-order-cleanup
spec:
  completions: 3
  parallelism: 1
  backoffLimit: 4
  activeDeadlineSeconds: 100
  template:
    spec:
      containers:
      - name: cleanup
        image: busybox
        command: ["sh", "-c", "echo cleaning up stale checkout orders; sleep 5; echo done"]
      restartPolicy: Never
```

```bash
k apply -f manifests/job.yaml
k get job checkout-order-cleanup
k get pods -l job-name=checkout-order-cleanup
k logs -l job-name=checkout-order-cleanup
```

**What to observe:** `COMPLETIONS` climbs to `3/3` as three pods each run to success, one at a time.

**The four fields that get tested:**

| Field | Meaning |
|---|---|
| `completions` | How many successful pod runs the Job needs before it's Complete |
| `parallelism` | How many pods may run at the same time |
| `backoffLimit` | How many retries on failure before the Job is marked Failed |
| `activeDeadlineSeconds` | Hard wall-clock cap for the whole Job, regardless of retries |

> **Exam Tip:** `restartPolicy` on a Job pod must be `Never` or `OnFailure` — the default `Always`
> is invalid for a Job and the manifest is rejected. This trips people up constantly.

## Generate a Job the exam way

```bash
k create job checkout-cleanup-quick --image=busybox $do -- sh -c "echo done" > job.yaml
cat job.yaml
```

## CronJobs (semi-guided)

A CronJob wraps a Job in a schedule — each firing creates a Job, which creates a pod. Build this
one using the pattern as reference: run the cleanup every 5 minutes.

<details>
<summary>Solution</summary>

```yaml
# manifests/cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: checkout-order-cleanup-cron
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup
            image: busybox
            command: ["sh", "-c", "echo cleaning up stale checkout orders; sleep 5; echo done"]
          restartPolicy: Never
```

```bash
k apply -f manifests/cronjob.yaml
k get cronjob checkout-order-cleanup-cron
k get jobs --watch     # a new Job appears each time the schedule fires
```
</details>

**The schedule field** is standard cron: `minute hour day-of-month month day-of-week`.
`*/5 * * * *` = every 5 minutes. Trigger one immediately without waiting:

```bash
k create job --from=cronjob/checkout-order-cleanup-cron cleanup-manual
```

> **Exam Tip:** `kubectl create job --from=cronjob/<name> <newname>` is the fast way to test a
> CronJob's work without waiting for the schedule. Worth memorizing.

## Break it / troubleshoot (instructor-led, ~4 minutes)

Apply a Job whose command always fails, and watch `backoffLimit` do its job.

```bash
k create job checkout-cleanup-fail --image=busybox -- sh -c "echo failing; exit 1"
k get job checkout-cleanup-fail
k get pods -l job-name=checkout-cleanup-fail
```

**What you'll see:** repeated pod failures, `RESTARTS`/new pods climbing, and eventually the Job
marked `Failed` once retries are exhausted.

**Ask the room:** "It keeps retrying — where's the retry count set, and where do we see why it failed?"

**Expected answer:** retries are capped by `backoffLimit` (default 6); the cause is in the pod
logs and `kubectl describe job`.

```bash
k describe job checkout-cleanup-fail
k logs -l job-name=checkout-cleanup-fail
```

**Root cause:** the container command exits non-zero every time. **Fix:** correct the command
(exit 0), or set a sane `backoffLimit` so a broken Job fails fast instead of retrying forever.

```bash
k delete job checkout-cleanup-fail
```

> **Exam Tip:** A Job that "won't finish" is usually a failing command hitting `backoffLimit`, or
> `completions` set higher than you intended. `kubectl describe job` shows both the pod statuses
> and the failure reason in one place.

## Independent challenge (5 minutes)

**Scenario:** Create a Job named `checkout-report` that runs `busybox` printing
`generating checkout report`, requires **2** successful completions, allows **2** pods to run in
parallel, and gives up after **3** failed retries.

<details>
<summary>Solution</summary>

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: checkout-report
spec:
  completions: 2
  parallelism: 2
  backoffLimit: 3
  template:
    spec:
      containers:
      - name: report
        image: busybox
        command: ["sh", "-c", "echo generating checkout report"]
      restartPolicy: Never
```

```bash
k apply -f report-job.yaml
k get job checkout-report
```
</details>

> **Docs to search** (only `kubernetes.io/docs` and `kubernetes.io/blog` are open to you in the exam — no bookmarks, so learn to navigate them fast): [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/) · [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) — both pages have copy-pasteable spec blocks.

## Practice Labs / Homework

- Lab - Kubernetes - CKAD - Jobs and CronJobs
