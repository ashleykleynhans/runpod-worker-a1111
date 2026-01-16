# Install Automatic1111 Web UI on your Network Volume

> [!NOTE]
> If you have previously installed A1111 on your Network volume,
> but want to install the After Detailer extension, you can follow the
> instructions [here](./installing-adetailer.md).

1. [Create a RunPod Account](https://runpod.io?ref=2xxro4sy).
2. Create a [RunPod Network Volume](https://www.runpod.io/console/user/storage).
3. Attach the Network Volume to a Secure Cloud [GPU pod](https://www.runpod.io/console/gpu-secure-cloud).
4. Select a light-weight template such as RunPod Pytorch.
5. Deploy the GPU Cloud pod.
6. Once the pod is up, open a Terminal and install the required
   dependencies. This can either be done by using the installation
   script, or manually.

## Automatic Installation Script

You can run this automatic installation script which will
automatically install all of the dependencies that get installed
manually below, and then you don't need to follow most of the
manual instructions, you can jump straight to steps 10 and 11.

```bash
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/scripts/install.sh
chmod +x install.sh
./install.sh
```

## Manual Installation

You only need to complete the steps below if you did not run the
automatic installation script above.

1. Install the Automatic1111 WebUI and ControlNet extension:
```bash
# Clone the repo
cd /workspace
git clone --depth=1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

# Upgrade Python
apt update
apt -y upgrade

# Install bc and aria2 Ubuntu packages
apt -y install bc aria2

# Ensure Python version is 3.10.12
python3 -V

# Create and activate venv
cd stable-diffusion-webui
python3 -m venv /workspace/venv
source /workspace/venv/bin/activate

# Install Torch and xformers
pip3 install --no-cache-dir torch==2.1.2+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip3 install --no-cache-dir xformers==0.0.23.post1 --index-url https://download.pytorch.org/whl/cu118

# Use community fork since Stability-AI made their repo private
export STABLE_DIFFUSION_REPO="https://github.com/w-e-w/stablediffusion.git"

# Install A1111 Web UI
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/install-automatic.py
python3 -m install-automatic --skip-torch-cuda-test

# Clone the ControlNet Extension
cd /workspace/stable-diffusion-webui
git clone --depth=1 https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet

# Clone the ReActor Extension
git clone https://github.com/Gourieff/sd-webui-reactor.git extensions/sd-webui-reactor

# Clone the After Detailer Extension
git clone --depth=1 https://github.com/Bing-su/adetailer.git extensions/adetailer

# Install dependencies for ControlNet
cd /workspace/stable-diffusion-webui/extensions/sd-webui-controlnet
pip3 install -r requirements.txt

# Install dependencies for ReActor
cd /workspace/stable-diffusion-webui/extensions/sd-webui-reactor
git checkout v0.6.1
pip3 install -r requirements.txt
pip3 install onnxruntime-gpu

# Install dependencies for After Detailer
cd /workspace/stable-diffusion-webui/extensions/adetailer
python3 -m install

# Install the model for ReActor
mkdir -p /workspace/stable-diffusion-webui/models/insightface
cd /workspace/stable-diffusion-webui/models/insightface
aria2c -o inswapper_128.onnx https://github.com/facefusion/facefusion-assets/releases/download/models/inswapper_128.onnx

# Configure ReActor to use the GPU instead of CPU
echo "CUDA" > /workspace/stable-diffusion-webui/extensions/sd-webui-reactor/last_device.txt
```
2. Install the Serverless dependencies:
```bash
cd /workspace/stable-diffusion-webui
pip3 install huggingface_hub runpod
```
3. Download some models, for example `SDXL` and `Deliberate v2`:
```bash
cd /workspace/stable-diffusion-webui/models/Stable-diffusion
aria2c -o sd_xl_base_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
aria2c -o sd_xl_refiner_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors
aria2c -o deliberate_v2.safetensors https://huggingface.co/ashleykleynhans/a1111-models/resolve/main/Stable-diffusion/deliberate_v2.safetensors
aria2c -o turboDiffusionXL_v112.safetensors https://huggingface.co/ashleykleynhans/a1111-models/resolve/main/Stable-diffusion/turboDiffusionXL_v112.safetensors
```
4. Download VAEs for SD 1.5 and SDXL:
```bash
cd /workspace/stable-diffusion-webui/models/VAE
aria2c -o vae-ft-mse-840000-ema-pruned.safetensors https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors
aria2c -o sdxl_vae.safetensors https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors
```
5. Download ControlNet models, for example `canny` for SD 1.5 as well as SDXL:
```bash
mkdir -p /workspace/stable-diffusion-webui/models/ControlNet
cd /workspace/stable-diffusion-webui/models/ControlNet
aria2c -o control_v11p_sd15_canny.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth
aria2c -o diffusers_xl_canny_full.safetensors https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_canny_full.safetensors
```
6. Download InstantID ControlNet models:
```bash
aria2c -o ip-adapter_instant_id_sdxl.bin "https://huggingface.co/InstantX/InstantID/resolve/main/ip-adapter.bin?download=true"
aria2c -o control_instant_id_sdxl.safetensors "https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/diffusion_pytorch_model.safetensors?download=true"
```
7. Create logs directory:
```bash
mkdir -p /workspace/logs
```
8. Install config files:
```bash
cd /workspace/stable-diffusion-webui
rm webui-user.sh config.json ui-config.json
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/webui-user.sh
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/config.json
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/ui-config.json
```
9. Run the Web UI:
```bash
deactivate
export HF_HOME="/workspace"
cd /workspace/stable-diffusion-webui
./webui.sh -f
```
10. Wait for the Web UI to start up, and download the models. You should
    see something like this when it is ready:
```
Model loaded in 20.8s (calculate hash: 15.6s, create model: 3.5s, apply weights to model: 0.8s, apply half(): 0.1s, calculate empty prompt: 0.5s).
```
11. Press Ctrl-C to exit, and then you can terminate the pod.
