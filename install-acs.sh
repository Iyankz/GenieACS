#!/bin/bash

################################################################################
# SKRIP INSTALASI OTOMATIS GENIEACS 1.2.13
# ----------------------------------------------------------------------------
# Penulis         : Iyankz & Gemini (AI Partner)
# Lisensi         : MIT License
# Platform        : Ubuntu 22.04 LTS (Jammy Jellyfish)
# Deskripsi       : Memudahkan deployment TR-069 ACS secara cepat dan aman.
################################################################################

# Definisi Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' 
BOLD='\033[1m'

# Fungsi Spinner (Animasi Loading)
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "${CYAN} [%c]  ${NC}" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Fungsi menjalankan perintah
run_command() {
    local cmd="$1"
    local msg="$2"
    printf "${YELLOW}%-50s${NC}" "$msg..."
    eval "$cmd" > /dev/null 2>&1 &
    spinner $!
    wait $!
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Selesai${NC}"
    else
        echo -e "${RED}Gagal${NC}"
        exit 1
    fi
}

# Banner Utama
clear
echo -e "${BLUE}${BOLD}"
echo "-------------------------------------------------------------"
echo "    GENIEACS INSTALLER - SISTEM TR-069"
echo "    Penyusun: Iyankz & Gemini"
echo "    Status  : Kolaborasi AI & Human"
echo "============================================================="
echo -e "${NC}"

# Cek Akses Root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Skrip ini harus dijalankan sebagai root (sudo)${NC}"
    exit 1
fi

# Cek Versi OS
if [ "$(lsb_release -cs)" != "jammy" ]; then
    echo -e "${RED}Error: Skrip ini hanya mendukung Ubuntu 22.04 (Jammy)${NC}"
    exit 1
fi

total_steps=22
current_step=0

# --- PROSES INSTALASI ---

run_command "apt-get update -y" "Update repositori sistem ($(( ++current_step ))/$total_steps)"

run_command "curl -fsSL https://deb.nodesource.com/setup_16.x | bash -" "Menyiapkan repo NodeSource v16 ($(( ++current_step ))/$total_steps)"
run_command "apt-get install -y nodejs" "Install Node.js & NPM ($(( ++current_step ))/$total_steps)"

run_command "wget -q http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb" "Install libssl1.1 (Dependensi) ($(( ++current_step ))/$total_steps)"

run_command "curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -" "Menambahkan GPG Key MongoDB ($(( ++current_step ))/$total_steps)"
run_command "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse' | tee /etc/apt/sources.list.d/mongodb-org-4.4.list" "Menambahkan Repo MongoDB 4.4 ($(( ++current_step ))/$total_steps)"
run_command "apt-get update -y && apt-get install -y mongodb-org" "Install MongoDB Server ($(( ++current_step ))/$total_steps)"
run_command "systemctl enable --now mongod" "Menjalankan database MongoDB ($(( ++current_step ))/$total_steps)"

run_command "npm install -g genieacs@1.2.13" "Install GenieACS via NPM ($(( ++current_step ))/$total_steps)"
run_command "useradd --system --no-create-home --user-group genieacs" "Membuat user sistem 'genieacs' ($(( ++current_step ))/$total_steps)"
run_command "mkdir -p /opt/genieacs/ext && chown -R genieacs:genieacs /opt/genieacs" "Menyiapkan direktori /opt/genieacs ($(( ++current_step ))/$total_steps)"

# Membuat file konfigurasi environment
cat << EOF > /opt/genieacs/genieacs.env
GENIEACS_CWMP_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-cwmp-access.log
GENIEACS_NBI_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-nbi-access.log
GENIEACS_FS_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-fs-access.log
GENIEACS_UI_ACCESS_LOG_FILE=/var/log/genieacs/genieacs-ui-access.log
GENIEACS_DEBUG_FILE=/var/log/genieacs/genieacs-debug.yaml
GENIEACS_EXT_DIR=/opt/genieacs/ext
NODE_OPTIONS=--enable-source-maps
EOF
run_command "node -e \"console.log('GENIEACS_UI_JWT_SECRET=' + require('crypto').randomBytes(128).toString('hex'))\" >> /opt/genieacs/genieacs.env" "Mengamankan UI dengan JWT Secret ($(( ++current_step ))/$total_steps)"
chmod 600 /opt/genieacs/genieacs.env
chown genieacs:genieacs /opt/genieacs/genieacs.env

# Menyiapkan logging
mkdir -p /var/log/genieacs
chown genieacs:genieacs /var/log/genieacs

# Konfigurasi dan Aktivasi Service
for service in cwmp nbi fs ui; do
    cat << EOF > /etc/systemd/system/genieacs-$service.service
[Unit]
Description=GenieACS $service
After=network.target

[Service]
User=genieacs
EnvironmentFile=/opt/genieacs/genieacs.env
ExecStart=/usr/local/bin/genieacs-$service
Restart=always

[Install]
WantedBy=default.target
EOF
    run_command "systemctl enable --now genieacs-$service" "Aktivasi layanan genieacs-$service ($(( ++current_step ))/$total_steps)"
done

# --- HASIL AKHIR ---
echo -e "\n${MAGENTA}${BOLD}Status Layanan Akhir:${NC}"
for s in mongod genieacs-cwmp genieacs-nbi genieacs-fs genieacs-ui; do
    status=$(systemctl is-active $s)
    if [ "$status" = "active" ]; then
        echo -e "${GREEN}✔ $s Berhasil dijalankan${NC}"
    else
        echo -e "${RED}✘ $s Gagal dijalankan${NC}"
    fi
done

echo -e "\n${BLUE}=============================================================${NC}"
echo -e "${GREEN}${BOLD}INSTALASI BERHASIL DISELESAIKAN!${NC}"
echo -e "Dashboard GenieACS dapat diakses di:"
echo -e "URL: ${CYAN}${BOLD}http://$(hostname -I | awk '{print $1}'):3000${NC}"
echo -e "${BLUE}=============================================================${NC}"
echo -e "Skrip hasil kolaborasi Iyankz & Gemini AI Partner."
