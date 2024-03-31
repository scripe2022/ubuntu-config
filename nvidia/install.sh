sudo echo "deb http://archive.ubuntu.com/ubuntu/ lunar universe" >> /etc/apt/sources.list

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt-get -y install cuda-toolkit-12-4

sudo apt-get install -y nvidia-driver-550-open
sudo apt-get install -y cuda-drivers-550

echo "export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64" >> ~/.bashrc
echo "export PATH=${PATH}:/usr/local/cuda/bin" >> ~/.bashrc

sudo rm cuda-keyring_1.1-1_all.deb
