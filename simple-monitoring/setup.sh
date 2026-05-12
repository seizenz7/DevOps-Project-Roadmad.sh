#!/bin/bash

# ==============================================================================
# Script Name    : setup.sh
# Description    : Automated Netdata Installation for Ubuntu 24.04 (WSL)
# Author         : Seizenz
# ==============================================================================

# 'set -e' menghentikan skrip jika ada error.
# 'set -u' menangkap variabel yang belum didefinisikan.
# 'set -o pipefail' menangkap error di dalam pipeline (misal: curl | sh).
set -euo pipefail

# --- 1. VALIDASI HAK AKSES ---
# Memastikan skrip dijalankan sebagai root untuk menghindari kegagalan permission di tengah jalan.
if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] Skrip ini harus dijalankan dengan sudo!"
   exit 1
fi

echo "[INFO] Memulai instalasi Netdata di Ubuntu 24.04..."

# --- 2. UPDATE & DEPENDENCIES ---
# Melakukan update repositori agar paket yang diinstal adalah versi terbaru yang stabil.
apt update && apt install -y curl

# --- 3. INSTALASI NETDATA (IDEMPOTENT) ---
# Cek apakah netdata sudah terinstal untuk menghindari instalasi ulang yang tidak perlu.
if ! command -v netdata &> /dev/null; then
    echo "[INFO] Mengunduh dan menginstal Netdata..."
    # Menggunakan flag --non-interactive agar tidak menunggu input manual di tengah proses otomasi.
    # --disable-telemetry menghormati privasi data jika tidak diperlukan.
    curl https://get.netdata.cloud/kickstart.sh > /tmp/netdata-kickstart.sh
    sh /tmp/netdata-kickstart.sh --disable-telemetry --non-interactive
else
    echo "[SKIP] Netdata sudah terinstal, melewati fase instalasi."
fi

# --- 4. VERIFIKASI LAYANAN (SYSTEMD) ---
# Di WSL, terkadang service tidak langsung aktif meski instalasi berhasil.
echo "[INFO] Memverifikasi layanan Netdata..."
systemctl daemon-reload
systemctl enable netdata

if ! systemctl is-active --quiet netdata; then
    echo "[INFO] Menyalakan layanan Netdata..."
    systemctl start netdata
fi

# --- 5. HEALTH CHECK (OBSERVABILITY) ---
# Memastikan aplikasi tidak hanya "jalan" tapi juga "melayani" (listening) pada port yang benar.
echo "[INFO] Menjalankan pengecekan port 19999..."
# Menggunakan timeout agar pengecekan tidak menggantung jika service butuh waktu untuk startup.
sleep 2 
if ss -tuln | grep -q ':19999'; then
    echo "[SUCCESS] Netdata Dashboard dapat diakses di: http://localhost:19999"
else
    echo "[ERROR] Port 19999 tidak merespon. Periksa log dengan: journalctl -u netdata"
    exit 1
fi

echo "[FINISH] Setup selesai secara bersih."