# GenieACS Auto-Installer for Ubuntu 22.04

![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Ubuntu%2022.04-orange)
![Version](https://img.shields.io/badge/GenieACS-1.2.13-blue)

Skrip instalasi otomatis untuk **GenieACS 1.2.13** pada sistem operasi Ubuntu 22.04 LTS (Jammy Jellyfish). Skrip ini dirancang agar sederhana, cepat, dan bisa langsung digunakan tanpa konfigurasi manual yang rumit.

## ✍️ Penyusun & Kolaborasi
Skrip ini dikembangkan melalui kolaborasi antara:
* **Iyankz** (Inisiator & Developer)
* **Gemini** (AI Partner & Technical Assistant)

> **Kejujuran Intelektual:** Skrip ini disusun sebagai bagian dari proses belajar saya (Iyankz) dalam mendalami administrasi sistem Linux. Pengembangan ini dibantu oleh teknologi AI (Gemini) untuk memastikan kode yang dihasilkan stabil, aman, dan mengikuti standar praktik terbaik.

---

## 🚀 Fitur Utama
* **Otomatis**: Menginstal Node.js (v16), MongoDB (v4.4), dan GenieACS dalam satu perintah.
* **Siap Pakai**: Konfigurasi otomatis file environment (`.env`) dan pembuatan JWT Secret unik.
* **Sistematis**: Mengatur GenieACS sebagai layanan sistem (`systemd`) agar otomatis berjalan saat server restart (Auto-boot).
* **Monitoring**: Pengecekan status layanan secara real-time di akhir proses instalasi.

---

## 📋 Prasyarat
* Server dengan OS **Ubuntu 22.04 LTS**.
* Hak akses **Root** atau **Sudo**.
* Koneksi internet aktif.

---

## 🛠️ Cara Penggunaan (One-Liner)

Silakan jalankan perintah berikut di terminal Anda untuk memulai instalasi otomatis:

```bash
sudo curl -sSL [https://raw.githubusercontent.com/USERNAME_ANDA/NAMA_REPO/main/install_acs.sh](https://raw.githubusercontent.com/USERNAME_ANDA/NAMA_REPO/main/install_acs.sh) | sudo bash
