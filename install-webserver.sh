#!/bin/bash

# Redirect output to log file for debugging
exec > >(tee -a install.log) 2>&1

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
    for cmd in wget unzip sed pgrep; do
        if ! command -v $cmd &> /dev/null; then
            echo "⚠️ '$cmd' tidak ditemukan. Menginstal..."
            pkg install $cmd -y || handle_error "Gagal menginstal $cmd."
        fi
    done
}

# Fungsi untuk memeriksa status layanan
check_service_status() {
    service_name="$1"
    pgrep $service_name > /dev/null || handle_error "$service_name tidak berjalan."
}

# Backup file konfigurasi sebelum diedit
backup_config() {
    config_file="$1"
    if [ -f "$config_file" ]; then
        cp "$config_file" "${config_file}.bak" || handle_error "Gagal membuat backup konfigurasi."
        echo "✅ Backup konfigurasi berhasil: ${config_file}.bak"
    else
        echo "⚠️ File konfigurasi tidak ditemukan: $config_file"
    fi
}

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

# Mulai Instalasi
echo "🔹 Memperbarui daftar paket..."
loading_bar
termux-change-repo || handle_error "Gagal mengganti repo!"
pkg update && pkg upgrade -y || handle_error "Gagal memperbarui paket!"

echo "🔹 Menginstal Apache, PHP, MariaDB, dan alat tambahan..."
loading_bar
pkg install apache2 php php-fpm mariadb wget unzip -y || handle_error "Gagal menginstal paket."

echo "🔹 Mengunduh dan menyiapkan phpMyAdmin..."
read -p "Masukkan versi phpMyAdmin (default: 5.2.1): " PHPMYADMIN_VERSION
PHPMYADMIN_VERSION="${PHPMYADMIN_VERSION:-5.2.1}"
PHPMYADMIN_URL="https://files.phpmyadmin.net/phpMyAdmin/$PHPMYADMIN_VERSION/phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip"
wget -q --show-progress "$PHPMYADMIN_URL" -O phpmyadmin.zip || handle_error "Gagal mengunduh phpMyAdmin."
unzip phpmyadmin.zip || handle_error "Gagal mengekstrak phpMyAdmin."
mv phpMyAdmin-$PHPMYADMIN_VERSION-all-languages $PREFIX/share/phpmyadmin || handle_error "Gagal memindahkan phpMyAdmin."
mkdir -p $PREFIX/share/phpmyadmin/tmp || handle_error "Gagal membuat direktori tmp."
chmod 755 $PREFIX/share/phpmyadmin/tmp || handle_error "Gagal mengatur izin direktori tmp."

echo "🔹 Mengedit konfigurasi Apache..."
CONFIG_PATH="$PREFIX/etc/apache2/httpd.conf"
backup_config "$CONFIG_PATH"

# Hapus konfigurasi lama jika ada
sed -i '/LoadModule php/d' $CONFIG_PATH
sed -i '/AddType application\/x-httpd-php/d' $CONFIG_PATH
sed -i '/DirectoryIndex index.php/d' $CONFIG_PATH
sed -i '/Alias \/phpmyadmin/d' $CONFIG_PATH
sed -i '/<Directory "\/data\/data\/com.termux\/files\/usr\/share\/phpmyadmin">/,/<\/Directory>/d' $CONFIG_PATH
sed -i '/ServerName localhost/d' $CONFIG_PATH
sed -i '/<FilesMatch "\.php$">/,/<\/FilesMatch>/d' $CONFIG_PATH

# Tambahkan konfigurasi baru
cat <<EOT >> $CONFIG_PATH
# Konfigurasi PHP-FPM
<FilesMatch "\.php$">
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
# Konfigurasi phpMyAdmin
Alias /phpmyadmin "$PREFIX/share/phpmyadmin"
<Directory "$PREFIX/share/phpmyadmin">
    AllowOverride All
    Require all granted
</Directory>
# Pastikan ServerName diatur
ServerName localhost
EOT

echo "🔹 Memulai Apache dan PHP-FPM..."
loading_bar
pkill -f httpd || echo "Apache tidak berjalan, melanjutkan..."
pkill -f php-fpm || echo "PHP-FPM tidak berjalan, melanjutkan..."
php-fpm & || handle_error "Gagal memulai PHP-FPM!"
apachectl start || handle_error "Gagal memulai Apache!"

echo "🔹 Menyiapkan database MariaDB..."
loading_bar
mysql_install_db || handle_error "Gagal menginisialisasi database."
mysqld_safe & sleep 5

# Minta pengguna untuk memasukkan password root MariaDB
read -sp "🔒 Masukkan password root MariaDB (default: root): " MYSQL_ROOT_PASSWORD
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root}"
echo ""
mysql -u root -e "CREATE DATABASE phpmyadmin;" || handle_error "Gagal membuat database."
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" || handle_error "Gagal mengatur password root."
mysql -u root -e "FLUSH PRIVILEGES;"

echo "🔹 Mengunduh dan menginstal Ngrok..."
NGROK_URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-arm64.zip"
wget -q --show-progress "$NGROK_URL" -O ngrok.zip || handle_error "Gagal mengunduh Ngrok."
unzip ngrok.zip || handle_error "Gagal mengekstrak Ngrok."
chmod +x ngrok || handle_error "Gagal mengatur izin Ngrok."
mv ngrok $PREFIX/bin/ || handle_error "Gagal memindahkan Ngrok."

echo "🔹 Masukkan token Ngrok (atau tekan Enter untuk melewati):"
read NGROK_TOKEN
if [ ! -z "$NGROK_TOKEN" ]; then
    ngrok authtoken $NGROK_TOKEN || handle_error "Gagal mengatur token Ngrok."
    ngrok http 8080 & || handle_error "Gagal memulai Ngrok."
    echo "🔹 Ngrok aktif! Cek URL publik di Termux."
else
    echo "🔹 Ngrok dilewati."
fi

echo "🔹 Restarting services..."
loading_bar
pkill -f httpd || echo "Apache tidak berjalan, melanjutkan..."
pkill -f php-fpm || echo "PHP-FPM tidak berjalan, melanjutkan..."
php-fpm & || handle_error "Gagal memulai PHP-FPM!"
apachectl start || handle_error "Gagal memulai Apache!"

# Verifikasi status layanan
check_service_status "httpd"
check_service_status "php-fpm"

# Tampilkan pesan sukses dengan gaya keren
clear
echo -e "\e[32m"
cat << "EOF"
     █████╗ ██╗  ██╗███╗   ███╗ █████╗ ██████╗ 
    ██╔══██╗██║  ██║████╗ ████║██╔══██╗██╔══██╗
    ███████║███████║██╔████╔██║███████║██║  ██║
    ██╔══██║██╔══██║██║╚██╔╝██║██╔══██║██║  ██║
    ██║  ██║██║  ██║██║ ╚═╝ ██║██║  ██║██████╔╝
    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝  
EOF
echo -e "\e[0m"
type_text "🚀 Instalasi selesai! Web server siap digunakan!" 0.02
type_text "🌐 Akses Web Server: http://127.0.0.1:8080" 0.02
type_text "🌐 phpMyAdmin: http://127.0.0.1:8080/phpmyadmin" 0.02
type_text "🌍 Ngrok (jika aktif): Jalankan 'ngrok http 8080' untuk melihat URL publik." 0.02
echo ""
