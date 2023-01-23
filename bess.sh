# install docker
# sudo apt-get install docker.io
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER


yes | sudo apt-get install docker-compose


git clone https://github.com/omec-project/upf.git
sudo apt install make
cd upf/
#make docker-build

sudo sysctl -w vm.nr_hugepages=102400
tee -a /etc/sysctl.conf << EOF
vm.nr_hugepages = 102400
EOF

tee -a /etc/default/grub << EOF
GRUB_CMDLINE_LINUX="intel_iommu=on iommu=pt default_hugepagesz=1G hugepagesz=1G hugepages=2 transparent_hugepage=never"
EOF
sudo update-grub

cd
sed -i 's/"mode": "dpdk"/"mode": "sim"/' /home/ubuntu/upf/conf/upf.json

sed -i 's/mode="dpdk"/#mode="dpdk"/' /home/ubuntu/upf/scripts/docker_setup.sh 
sed -i 's/#mode="sim"/mode="sim"/'  /home/ubuntu/upf/scripts/docker_setup.sh 

cd /home/ubuntu/upf/
./scripts/docker_setup.sh
wait
docker exec bess-pfcpiface pfcpiface -config conf/upf.json -simulate create
docker exec bess ./bessctl run up4
docker exec bess ./bessctl show pipeline > pipeline.txt


