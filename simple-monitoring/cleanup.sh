#!/bin/bash

# ==============================================================================
# Script Name    : cleanup.sh
# Description    : Menghapus Netdata secara total dari Ubuntu 24.04
# Author         : Seizenz
# ==============================================================================

set -euo pipefail

# Validasi root
if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] Jalankan dengan sudo!"
   exit 1
fi

echo "[INFO] Memulai proses pembersihan..."

# --- 1. MENGGUNAKAN UNINSTALLER BAWAAN ---
# Netdata biasanya menyediakan skrip uninstall di lokasi ini.
UNINSTALLER="/usr/libexec/netdata/netdata-uninstaller.sh"

if [ -f "$UNINSTALLER" ]; then
    echo "[INFO] Menjalankan uninstaller resmi Netdata..."
    # --yes untuk menjalankan secara otomatis tanpa konfirmasi manual
    sh "$UNINSTALLER" --yes --force
else
    echo "[WARN] Uninstaller resmi tidak ditemukan, mencoba metode manual (apt)..."
    systemctl stop netdata || true
    apt-get purge -y netdata
    apt-get autoremove -y
fi

# --- 2. PEMBERSIHAN SISA KONFIGURASI ---
# Terkadang uninstaller menyisakan folder log atau cache.
echo "[INFO] Menghapus sisa folder konfigurasi dan log..."
rm -rf /etc/netdata
rm -rf /var/lib/netdata
rm -rf /var/log/netdata
rm -rf /tmp/netdata-kickstart.sh

# --- 3. VERIFIKASI AKHIR ---
if ! ss -tuln | grep -q ':19999'; then
    echo "[SUCCESS] Sistem bersih. Port 19999 sudah tertutup."
else
    echo "[ERROR] Port 19999 masih aktif. Periksa proses yang tersisa."
    exit 1
fi