#!/bin/bash

# Redirect output ke log files untuk debugging
exec > >(tee -a install.log) 2> >(tee -a error.log >&2)

# Fungsi untuk menampilkan teks dengan efek ketikan
type_text() {
    text="$1"
    delay="${2:-0.05}"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo ""
}

# Fungsi untuk menampilkan loading bar palsu
loading_bar() {
    bar="=============================="
    bar_length=${#bar}
    echo -n "["
    for ((i=0; i<$bar_length; i++)); do
        echo -n "#"
        sleep 0.05
    done
    echo "] 100%"
}

# Fungsi untuk menangani kesalahan
handle_error() {
    echo -e "\n❌ ERROR: $1"
    exit 1
}

# Fungsi untuk memeriksa dependensi
check_dependencies() {
    echo "🔍 Memeriksa dependensi..."
    for cmd in pkg wget unzip sed pgrep php apachectl mariadb; do
        if ! command -v $cmd &> /dev/null; then
            echo "⚠️ '$cmd' tidak ditemukan. Menginstal..."
            pkg install $cmd -y || handle_error "Gagal menginstal $cmd."
        fi
    done
}

# Pemeriksaan koneksi internet
if ! ping -q -c 1 google.com > /dev/null; then
    handle_error "Tidak ada koneksi internet. Harap periksa koneksi Anda."
fi

# Intro ASCII Art
clear
echo -e "\e[32m"
cat << "EOF"
     █████╗ ██╗  ██╗███╗   ███╗ █████╗ ██████╗ 
    ██╔══██╗██║  ██║████╗ ████║██╔══██╗██╔══██╗
    ███████║███████║██╔████╔██║███████║██║  ██║
    ██╔══██║██╔══██║██║╚██╔╝██║██╔══██║██║  ██║
    ██║  ██║██║  ██║██║ ╚═╝ ██║██║  ██║██████╔╝
    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝  
      🚀 WEB SERVER INSTALLER | TERMUX EDITION 🚀
EOF
echo -e "\e[0m"
sleep 1

# Efek teks ketikan
type_text "🔥 Selamat datang di Skrip Ajaib Web Server Termux! 🔥" 0.03
sleep 1
type_text "⚡ Skrip ini akan menginstal Apache, PHP, MariaDB, dan phpMyAdmin secara otomatis!" 0.03
sleep 1
type_text "🔍 Memulai proses instalasi..." 0.03
sleep 2
echo ""

# Pemeriksaan dependensi
check_dependencies

# Memperbarui daftar paket
echo "🔹 Memperbarui daftar paket..."
loading_bar
termux-change-repo || handle_error "Gagal mengganti repo!"
pkg update && pkg upgrade -y || handle_error "Gagal memperbarui paket!"

echo "🔹 Menginstal Apache, PHP, MariaDB, dan alat tambahan..."
loading_bar
pkg install apache2 php php-fpm mariadb wget unzip pv dialog -y || handle_error "Gagal menginstal paket."

echo "🔹 Mengedit konfigurasi Apache..."
CONFIG_PATH="$PREFIX/etc/apache2/httpd.conf"

# Backup konfigurasi jika belum ada backup
if [ ! -f "$CONFIG_PATH.bak" ]; then
    cp "$CONFIG_PATH" "$CONFIG_PATH.bak" || handle_error "Gagal membuat backup konfigurasi."
fi

# Konfigurasi Apache
sed -i '/LoadModule php/d' $CONFIG_PATH
sed -i '/AddType application\/x-httpd-php/d' $CONFIG_PATH
sed -i '/DirectoryIndex index.php/d' $CONFIG_PATH
sed -i '/Alias \/phpmyadmin/d' $CONFIG_PATH
sed -i '/ServerName localhost/d' $CONFIG_PATH

cat <<EOT >> $CONFIG_PATH
# Konfigurasi PHP-FPM
<FilesMatch "\.php$">
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
ServerName localhost
EOT

# Memulai Apache dan PHP-FPM
echo "🔹 Memulai Apache dan PHP-FPM..."
loading_bar
pkill -f httpd || echo "Apache tidak berjalan, melanjutkan..."
pkill -f php-fpm || echo "PHP-FPM tidak berjalan, melanjutkan..."
php-fpm & || handle_error "Gagal memulai PHP-FPM!"
apachectl start || handle_error "Gagal memulai Apache!"

# Menyiapkan MariaDB
echo "🔹 Menyiapkan database MariaDB..."
loading_bar
mysql_install_db --user=mysql --datadir=$PREFIX/var/lib/mysql || handle_error "Gagal menginisialisasi database."
mysqld_safe --datadir=$PREFIX/var/lib/mysql & sleep 5

# Verifikasi MariaDB sudah berjalan
while ! mysqladmin ping -u root --silent; do
    sleep 1
done

echo "🔹 Masukkan password root MariaDB:"
read -sp "🔒 Password (default: root): " MYSQL_ROOT_PASSWORD
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root}"
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" || handle_error "Gagal mengatur password root."
mysql -u root -e "FLUSH PRIVILEGES;"

# Instalasi Ngrok
echo "🔹 Mengunduh dan menginstal Ngrok..."
NGROK_URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-arm64.zip"
wget -q --show-progress "$NGROK_URL" -O ngrok.zip || handle_error "Gagal mengunduh Ngrok."
unzip -o ngrok.zip || handle_error "Gagal mengekstrak Ngrok."
chmod +x ngrok
mv ngrok $PREFIX/bin/ || handle_error "Gagal memindahkan Ngrok."

# Menjalankan Ngrok (opsional)
echo "🔹 Masukkan token Ngrok (atau tekan Enter untuk melewati):"
read NGROK_TOKEN
if [ ! -z "$NGROK_TOKEN" ]; then
    ngrok authtoken $NGROK_TOKEN || handle_error "Gagal mengatur token Ngrok."
    ngrok http 8080 &
fi

# Tampilkan pesan sukses
clear
echo -e "\e[32m"
type_text "🚀 Instalasi selesai! Web server siap digunakan!" 0.02
type_text "🌐 Akses Web Server: http://127.0.0.1:8080" 0.02
type_text "🌍 Ngrok (jika aktif): Jalankan 'ngrok http 8080' untuk melihat URL publik." 0.02
echo ""
