# 🚀 WEB SERVER INSTALLER | TERMUX EDITION | BY: JAPRA302  

Skrip ini secara otomatis menginstal dan mengonfigurasi web server di Termux, termasuk **Apache, PHP, MariaDB, dan phpMyAdmin**. Selain itu, skrip juga menyediakan opsi untuk mengatur **Ngrok** agar server dapat diakses dari internet.  

---

## 📌 FITUR  
✅ Instalasi otomatis **Apache, PHP, MariaDB, dan phpMyAdmin**  
✅ Pemeriksaan dan instalasi dependensi yang diperlukan  
✅ Backup otomatis file konfigurasi sebelum diubah  
✅ Efek ketikan dan loading bar untuk pengalaman interaktif  
✅ Pemeriksaan koneksi internet dan status layanan sebelum memulai  
✅ Konfigurasi otomatis phpMyAdmin agar siap digunakan  
✅ Opsi instalasi dan pengaturan **Ngrok** untuk akses server dari internet  

---

## 📦 PAKET YANG DIPASANG  
- **Apache2**  
- **PHP & PHP-FPM**  
- **MariaDB (MySQL)**  
- **phpMyAdmin**  
- **Wget, Unzip, PV, Dialog**  
- **Ngrok (opsional)**  

---

## 🔧 CARA INSTALASI  

1️⃣ **Pastikan Termux telah diperbarui:**  
```sh
pkg update && pkg upgrade -y
pkg install git

2️⃣ Unduh skrip ini:

wget https://github.com/japra302/webserversetup.git -O webserver.sh

3️⃣ Jalankan skrip:

git clone https://github.com/japra302/webserversetup.git
cd webserversetup
ls -l
chmod +x install-webserver.sh
dos2unix install-webserver.sh
./install-webserver.sh

4️⃣ Ikuti petunjuk di layar untuk menyelesaikan instalasi.


---

🌐 AKSES WEB SERVER

Web Server: http://127.0.0.1:8080

phpMyAdmin: http://127.0.0.1:8080/phpmyadmin

Ngrok (jika aktif): Jalankan ngrok http 8080 untuk melihat URL publik.



---

🔥 FITUR TAMBAHAN

✅ Backup otomatis sebelum mengedit file konfigurasi.
✅ Restart layanan otomatis setelah instalasi selesai.
✅ Dukungan untuk versi phpMyAdmin yang dapat dipilih pengguna.


---

🛠 TROUBLESHOOTING

Jika terjadi masalah, periksa file log berikut:

Log instalasi: install.log

Log kesalahan: error.log


Untuk restart layanan secara manual, jalankan:

pkill -f httpd
pkill -f php-fpm
php-fpm &
apachectl start


---

📜 LISENSI

Proyek ini menggunakan lisensi MIT. Silakan gunakan dan modifikasi sesuai kebutuhan.


---
