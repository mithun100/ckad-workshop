# Docker and Containers 101

"It works on my machine" used to be a legitimate excuse. A container is what killed it — it
packages your app with everything it needs to run (code, runtime, libraries, config) so it
behaves identically on your laptop, a teammate's laptop, and in the exam's remote cluster.

The fastest way to actually understand that is to stop running other people's containers for a
minute and build your own, from scratch.

## Install Docker Desktop (if you don't have it)

Download from [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
and install it like any other Mac app. Confirm it's running:

```bash
docker version
docker info
```

**Expected output:** both commands print version/info for a `Client` and a `Server` — if only
the `Client` section appears, Docker Desktop isn't running yet. Open it from Applications and
wait for the whale icon in the menu bar to stop animating.

## Warm-up: run someone else's container

```bash
docker run hello-world
```

**What happened:** Docker pulled the `hello-world` image from Docker Hub (a public registry),
started a container from it, ran its one task, and exited. No install, no dependencies on your
machine — the container brought everything it needed. Every image you'll use for the rest of
this workshop (`nginx`, `busybox`) was built exactly the way you're about to build one yourself.

## Build one from scratch: `checkout-api`

An image doesn't come from nowhere — it's built from a **Dockerfile**, a plain-text recipe of
steps. Let's build the very first version of the app this whole workshop is about.

**Save this file.** Make a folder and create `index.html` inside it:

```bash
mkdir checkout-api-image && cd checkout-api-image
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
  <head><title>checkout-api</title></head>
  <body>
    <h1>checkout-api</h1>
    <p>Version 1 — built from scratch, not pulled from a registry.</p>
  </body>
</html>
EOF
```

**Now write the Dockerfile** — the recipe that turns that file into an image:

```dockerfile
# Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
```

```bash
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF
```

Three lines, three ideas:
- `FROM nginx:alpine` — don't start from zero; start from a small, trusted base image that
  already knows how to serve web pages.
- `COPY index.html ...` — layer your own content on top of that base.
- `EXPOSE 80` — document which port the container listens on (this doesn't publish it yet —
  that happens at `run` time, below).

## Build it

```bash
docker build -t checkout-api:v1 .
```

**What to watch:** each line of the Dockerfile becomes a numbered build step in the output —
`FROM`, then `COPY`, then `EXPOSE`. That's not cosmetic; each step becomes its own cached **layer**.
Change only `index.html` and rebuild, and Docker reuses the cached `FROM` layer instead of
re-downloading it — this is why later builds are fast.

## Run it

```bash
docker run -d --name checkout-api -p 8080:80 checkout-api:v1
```

## Show it

```bash
curl http://localhost:8080
```

**Expected output:** your own `<h1>checkout-api</h1>` HTML — not nginx's default welcome page.
That's the proof this container is running *your* image, not a generic one. You can also open
`http://localhost:8080` in a browser.

Look at what you actually built:

```bash
docker images                        # checkout-api:v1 is now listed locally, alongside nginx
docker history checkout-api:v1       # every layer, in build order, with its size
docker inspect checkout-api          # full JSON: ports, mounts, env, the works
```

Clean up when you're done:

```bash
docker stop checkout-api
docker rm checkout-api
```

## The commands you'll actually use day to day

```bash
docker run -d --name web -p 8080:80 nginx     # run nginx in the background, map port 8080 -> 80
docker ps                                      # see what's running
docker logs web                                # see its output
docker exec -it web sh                         # get a shell inside the running container
docker stop web                                # stop it
docker rm web                                  # remove the stopped container
```

## Why this matters for Kubernetes

A Kubernetes **Pod** is, at its simplest, one or more containers running together on a node.
Everything you just did by hand — pull an image, run it, check its logs, exec into it, stop it —
Kubernetes does the same thing, just declaratively and at scale, across many machines instead of
one. The vocabulary doesn't change; only who's driving does.

> **Exam Tip:** `docker logs` and `docker exec` map directly onto `kubectl logs` and
> `kubectl exec` — the muscle memory you build here transfers directly.
