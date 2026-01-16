#!/usr/bin/env bash
echo "Deleting Automatic1111 Web UI"
rm -rf /workspace/stable-diffusion-webui

echo "Deleting venv"
rm -rf /workspace/venv

echo "Cloning A1111 repo to /workspace"
cd /workspace
git clone --depth=1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

echo "Installing Ubuntu updates"
apt update
apt -y upgrade

echo "Installing bc and aria2 Ubuntu packages"
apt -y install bc aria2

echo "Creating and activating venv"
cd stable-diffusion-webui
python3 -m venv /workspace/venv
source /workspace/venv/bin/activate

echo "Installing Torch"
pip3 install --no-cache-dir torch==2.1.2+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

echo "Installing xformers"
pip3 install --no-cache-dir xformers==0.0.23.post1 --index-url https://download.pytorch.org/whl/cu118

# Use community fork since Stability-AI made their repo private
export STABLE_DIFFUSION_REPO="https://github.com/w-e-w/stablediffusion.git"

echo "Installing A1111 Web UI"
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/install-automatic.py
python3 -m install-automatic --skip-torch-cuda-test

echo "Cloning ControlNet extension repo"
cd /workspace/stable-diffusion-webui
git clone --depth=1 https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet

echo "Cloning the ReActor extension repo"
git clone https://github.com/Gourieff/sd-webui-reactor.git extensions/sd-webui-reactor
git checkout v0.6.1

echo "Cloning the After Detailer extension repo"
git clone --depth=1 https://github.com/Bing-su/adetailer.git extensions/adetailer

echo "Installing dependencies for ControlNet"
cd /workspace/stable-diffusion-webui/extensions/sd-webui-controlnet
pip3 install -r requirements.txt

echo "Installing dependencies for ReActor"
cd /workspace/stable-diffusion-webui/extensions/sd-webui-reactor
pip3 install -r requirements.txt
pip3 install onnxruntime-gpu

echo "Installing dependencies for After Detailer"
cd /workspace/stable-diffusion-webui/extensions/adetailer
python3 -m install

echo "Installing the model for ReActor"
mkdir -p /workspace/stable-diffusion-webui/models/insightface
cd /workspace/stable-diffusion-webui/models/insightface
aria2c -o inswapper_128.onnx https://github.com/facefusion/facefusion-assets/releases/download/models/inswapper_128.onnx

echo "Configuring ReActor to use the GPU instead of CPU"
echo "CUDA" > /workspace/stable-diffusion-webui/extensions/sd-webui-reactor/last_device.txt

echo "Installing RunPod Serverless dependencies"
cd /workspace/stable-diffusion-webui
pip3 install huggingface_hub runpod

echo "Downloading Deliberate v2 model"
cd /workspace/stable-diffusion-webui/models/Stable-diffusion
aria2c -o deliberate_v2.safetensors https://huggingface.co/ashleykleynhans/a1111-models/resolve/main/Stable-diffusion/deliberate_v2.safetensors

echo "Downloading SDXL base model"
aria2c -o sd_xl_base_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors

echo "Downloading SDXL Refiner"
aria2c -o sd_xl_refiner_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors

echo "Downloading turboDiffusionXL v112 model"
aria2c -o turboDiffusionXL_v112.safetensors https://huggingface.co/ashleykleynhans/a1111-models/resolve/main/Stable-diffusion/turboDiffusionXL_v112.safetensors

echo "Downloading SD 1.5 VAE"
cd /workspace/stable-diffusion-webui/models/VAE
aria2c -o vae-ft-mse-840000-ema-pruned.safetensors https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors

echo "Downloading SDXL VAE"
aria2c -o sdxl_vae.safetensors https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors

echo "Downloading SD 1.5 ControlNet models"
mkdir -p /workspace/stable-diffusion-webui/models/ControlNet
cd /workspace/stable-diffusion-webui/models/ControlNet
aria2c -o control_v11p_sd15_openpose.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth
aria2c -o control_v11p_sd15_canny.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_canny.pth
aria2c -o control_v11f1p_sd15_depth.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1p_sd15_depth.pth
aria2c -o control_v11p_sd15_inpaint.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_inpaint.pth
aria2c -o control_v11p_sd15_lineart.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_lineart.pth
aria2c -o control_v1p_sd15_brightness.safetensors https://huggingface.co/ioclab/ioc-controlnet/resolve/main/models/control_v1p_sd15_brightness.safetensors
aria2c -o control_v11f1e_sd15_tile.pth https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1e_sd15_tile.pth

echo "Downloading SDXL ControlNet models"
aria2c -o diffusers_xl_canny_full.safetensors https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_canny_full.safetensors

echo "Downloading InstantID ControlNet models"
aria2c -o ip-adapter_instant_id_sdxl.bin "https://huggingface.co/InstantX/InstantID/resolve/main/ip-adapter.bin?download=true"
aria2c -o control_instant_id_sdxl.safetensors "https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/diffusion_pytorch_model.safetensors?download=true"

echo "Downloading Upscalers"
mkdir -p /workspace/stable-diffusion-webui/models/ESRGAN
cd /workspace/stable-diffusion-webui/models/ESRGAN
aria2c -o 4x-UltraSharp.pth https://huggingface.co/ashleykleynhans/upscalers/resolve/main/4x-UltraSharp.pth
aria2c -o lollypop.pth https://huggingface.co/ashleykleynhans/upscalers/resolve/main/lollypop.pth

echo "Creating log directory"
mkdir -p /workspace/logs

echo "Installing config files"
cd /workspace/stable-diffusion-webui
rm webui-user.sh config.json ui-config.json
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/webui-user.sh
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/config.json
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/ui-config.json

echo "Starting A1111 Web UI"
deactivate
export HF_HOME="/workspace"
cd /workspace/stable-diffusion-webui
./webui.sh -f
