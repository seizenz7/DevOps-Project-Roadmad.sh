#!/bin/bash

# ==============================================================================
# Script Name    : test_dashboard.sh
# Description    : Simulasi beban kerja (Load Test) untuk memicu grafik & alert
# Author         : Seizenz
# ==============================================================================

set -euo pipefail

echo "[INFO] Menyiapkan alat simulasi beban (stress)..."
sudo apt update && sudo apt install -y stress

echo "--------------------------------------------------------"
echo "Pilih jenis pengujian yang ingin dijalankan:"
echo "1. Stress CPU (Memicu Alert > 80%)"
echo "2. Stress Memory (RAM)"
echo "3. Stress Disk I/O"
echo "4. Berhenti/Stop semua stress"
echo "--------------------------------------------------------"
read -p "Masukkan pilihan (1-4): " CHOICE

case $CHOICE in
    1)
        echo "[RUN] Membebani CPU selama 60 detik..."
        # Menjalankan 4 pekerja CPU (ubah sesuai jumlah core yang ingin dibebani) selama 60 detik
        stress --cpu 4 --timeout 60s &
        echo "[TIP] Buka dashboard http://localhost:19999 sekarang untuk melihat grafik CPU melonjak!"
        ;;
    2)
        # Membebani RAM sebesar 1GB selama 60 detik (ubah sesuai kebutuhan)
        echo "[RUN] Membebani RAM sebesar 1GB..."
        stress --vm 1 --vm-bytes 1G --timeout 60s &
        ;;
    3)
        # Membebani Disk I/O dengan 4 pekerja selama 60 detik (ubah sesuai kebutuhan)
        echo "[RUN] Membebani Disk I/O..."
        stress --io 4 --timeout 60s &
        ;;
    4)
        echo "[STOP] Menghentikan semua proses stress..."
        sudo pkill stress || echo "Tidak ada proses stress yang berjalan."
        ;;
    *)
        echo "Pilihan tidak valid."
        ;;
esac

echo "[INFO] Skrip selesai. Monitor hasilnya di dashboard Netdata."