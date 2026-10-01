# Podman on Your Mac

Podman runs the same containers as Docker — same images, same `Dockerfile` format, mostly the
same commands — but with a different architecture: no long-running background daemon, and
containers run rootless by default. Good to know it exists, and good to know you're not locked
into one tool.

## Install

```bash
brew install podman
```

Podman on Mac needs a lightweight Linux VM to actually run containers (there's no native Linux
kernel on macOS). Create and start it once:

```bash
podman machine init
podman machine start
```

Confirm it's working:

```bash
podman version
podman info
```

## Run the exact same container as before

```bash
podman run -d --name web -p 8080:80 nginx
podman ps
podman logs web
podman stop web
podman rm web
```

**Notice:** every command is identical to the Docker ones from the previous lesson — only the
binary name changed. If you want the muscle memory to carry over completely, alias it:

```bash
alias docker=podman
```

## The one real difference worth knowing

Docker relies on a single root-privileged background daemon managing every container. Podman
doesn't have a daemon at all — each container is just a regular process, which is why it can run
fully rootless. For this workshop, that difference doesn't change anything you'll type; it's
worth knowing so "no daemon running" isn't a surprise if you ever troubleshoot Podman specifically.

> **Exam Tip:** The exam environment uses Docker/containerd under the hood, not Podman — this
> lesson is about understanding that container tooling is interchangeable, not about switching
> your exam workflow.
