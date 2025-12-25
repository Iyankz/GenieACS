# 🛠️ Panduan Troubleshooting GenieACS

Dokumen ini berisi langkah-langkah untuk mendiagnosa dan memperbaiki masalah umum yang mungkin terjadi setelah menggunakan skrip instalasi otomatis pada Ubuntu 22.04.

---

## 1. Memeriksa Status Layanan
Langkah pertama jika sistem tidak bisa diakses adalah memastikan semua komponen berjalan dengan normal.

**Perintah untuk cek semua layanan:**
```bash
systemctl status genieacs-cwmp genieacs-nbi genieacs-fs genieacs-ui mongod
