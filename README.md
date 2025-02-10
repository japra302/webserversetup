🚀 Web Server Installer | Termux Edition | By : Japra302

Skrip ini secara otomatis menginstal dan mengonfigurasi web server di Termux, termasuk Apache, PHP, MariaDB, dan phpMyAdmin. Selain itu, skrip juga menyediakan opsi untuk mengatur Ngrok agar server dapat diakses dari internet.

📌 Fitur

✅ Instalasi otomatis Apache, PHP, MariaDB, dan phpMyAdmin
✅ Pemeriksaan dan instalasi dependensi yang diperlukan
✅ Backup otomatis file konfigurasi sebelum diubah
✅ Efek ketikan dan loading bar untuk pengalaman yang lebih interaktif
✅ Pemeriksaan koneksi internet dan status layanan sebelum memulai
✅ Konfigurasi otomatis phpMyAdmin agar siap digunakan
✅ Opsi instalasi dan pengaturan Ngrok untuk akses server dari internet

📦 Paket yang Dipasang

Apache2

PHP & PHP-FPM

MariaDB (MySQL)

phpMyAdmin

Wget, Unzip, PV, Dialog

Ngrok (opsional)


🔧 Cara Instalasi

1. Pastikan Termux telah diperbarui:

pkg update && pkg upgrade -y

Pkg install git 


2. Unduh skrip ini:

wget https://github.com/japra302/webserversetup.git -O webserver.sh


3. Jalankan skrip:

1. (git clone https://github.com/japra302/webserversetup.git)

2. (cd webserversetup)

3. (ls -l)

4. (chmod +x install-webserver.sh)


5. (dos2unix install-webserver.sh)

6. (./install-webserver.sh)




4. Ikuti petunjuk di layar untuk menyelesaikan instalasi.



🌐 Akses Web Server

Web Server: http://127.0.0.1:8080

phpMyAdmin: http://127.0.0.1:8080/phpmyadmin

Ngrok (jika aktif): Jalankan ngrok http 8080 untuk melihat URL publik.


🔥 Fitur Tambahan

Backup otomatis sebelum mengedit file konfigurasi.

Restart layanan otomatis setelah instalasi selesai.

Dukungan untuk versi phpMyAdmin yang dapat dipilih pengguna.


🛠 Troubleshooting

Jika terjadi masalah, periksa file log berikut:

Log instalasi: install.log

Log kesalahan: error.log


Untuk restart layanan secara manual:

pkill -f httpd
pkill -f php-fpm
php-fpm &
apachectl start

📜 Lisensi

Proyek ini menggunakan lisensi MIT. Silakan gunakan dan modifikasi sesuai kebutuhan.
