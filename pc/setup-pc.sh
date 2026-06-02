#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# PC Homelab Setup Script
# Run: bash setup-pc.sh
# ============================================================

echo "=== 0. Enable non-free repos (for firmware, etc.) ==="
sudo sed -i 's/main non-free-firmware/main contrib non-free non-free-firmware/g' /etc/apt/sources.list
sudo apt update

echo ""
echo "=== 1. Basic packages ==="
sudo apt install -y git btop curl neovim ripgrep fd-find lazygit unzip build-essential pkg-config libglvnd-dev linux-headers-$(uname -r)

echo ""
echo "=== 2. NVIDIA Driver from NVIDIA's CUDA repo ==="
echo "     (Debian's 550 driver doesn't support RTX 5070 Blackwell)"
echo "     NVIDIA's 590 driver from their repo does."
# Add NVIDIA's CUDA repo (has 590 drivers with Blackwell support)
wget -q https://developer.download.nvidia.com/compute/cuda/repos/debian13/x86_64/cuda-keyring_1.1-1_all.deb -O /tmp/cuda-keyring.deb
sudo dpkg -i /tmp/cuda-keyring.deb
sudo apt update
sudo apt install -y cuda-drivers
rm -f /tmp/cuda-keyring.deb

echo ""
echo "=== 3. Docker (official repo) ==="
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

echo ""
echo "=== 4. NVIDIA Container Toolkit ==="
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

echo ""
echo "=== 5. Neovim config ==="
git clone git@github.com:DenisSud/dotfiles-nvim.git ~/.config/nvim 2>/dev/null || (cd ~/.config/nvim && git pull)

echo ""
echo "=== 6. pi-agent config ==="
mkdir -p ~/.pi
git clone git@github.com:DenisSud/dotfiles-pi.git ~/.pi/agent 2>/dev/null || (cd ~/.pi/agent && git pull)

echo ""
echo "=== 7. Jellyfin restore dir ==="
mkdir -p ~/jellyfin-restore

echo ""
echo "============================================"
echo "  Setup complete!"
echo "============================================"
echo ""
echo "  ⚠️  REBOOT REQUIRED"
echo "     Run: sudo systemctl reboot"
echo ""
echo "  After reboot, verify GPU:"
echo "     nvidia-smi"
echo ""
echo "  Verify Docker GPU access:"
echo "     docker run --rm --gpus all nvidia/cuda:12.8-base-ubuntu24.04 nvidia-smi"
echo ""
