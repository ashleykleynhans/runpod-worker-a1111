## Building the Docker image

### Docker Image Variants

Two Docker image variants are available, each targeting a different CUDA version:

| Variant | CUDA | PyTorch | xformers |
|---------|------|---------|----------|
| `cuda124` | 12.4.1 | 2.6.0 | 0.0.29.post3 |
| `cuda128` | 12.8.1 | 2.10.0 | 0.0.34 |

### Building with Docker Bake

The recommended way to build is using `docker buildx bake`, which builds both variants in one command.

1. Sign up for a Docker hub account if you don't already have one.
2. Build and push using Docker Bake:
```bash
# Clone the repo
git clone https://github.com/ashleykleynhans/runpod-worker-a1111.git
cd runpod-worker-a1111

# Log in to Docker Hub
docker login

# Build and push both variants
docker buildx bake --push
```

To build only a specific variant:

```bash
# Build only the CUDA 12.4 variant
docker buildx bake cuda124 --push

# Build only the CUDA 12.8 variant
docker buildx bake cuda128 --push
```

### Building Manually

You can also build a single image directly with `docker build`:

```bash
# Clone the repo
git clone https://github.com/ashleykleynhans/runpod-worker-a1111.git
cd runpod-worker-a1111

# Build and push
docker build -t dockerhub-username/runpod-worker-a1111:1.0.0 .
docker login
docker push dockerhub-username/runpod-worker-a1111:1.0.0
```

If you're building on an M1 or M2 Mac, there will be an architecture
mismatch because they are `arm64`, but RunPod runs on `amd64`
architecture, so you will have to add the `--platform` as follows:

```bash
docker buildx build --push -t dockerhub-username/runpod-worker-a1111:1.0.0 . --platform linux/amd64
```
