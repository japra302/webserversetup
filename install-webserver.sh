#!/bin/bash

# Redirect output ke log files untuk debugging
touch install.log error.log || { echo "Gagal membuat file log. Periksa izin direktori."; exit 1; }
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

# Fungsi untuk menampilkan loading bar dinamis
loading_bar() {
    duration=${1:-5}
    for ((i=0; i<duration*20; i++)); do
        printf "\r[%-50s] %d%%" "${bar:0:i/2}" $((i*2))
        sleep 0.05
    done
    echo ""
}

# Fungsi untuk menangani kesalahan
handle_error() {
    echo -e "\n❌ ERROR: $1"
    echo "💡 Solusi: Coba jalankan ulang skrip atau periksa log di install.log dan error.log."
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
type_text "⚡ Skrip ini akan menginstal Apache, PHP, MariaDB, phpMyAdmin, dan Ngrok secara otomatis!" 0.03
sleep 1
type_text "🔍 Memulai proses instalasi..." 0.03
sleep 2
echo ""

# Pemeriksaan dependensi
check_dependencies

# Memperbarui daftar paket
echo "🔹 Memperbarui daftar paket..."
loading_bar 3
pkg update && pkg upgrade -y || handle_error "Gagal memperbarui paket!"

# Instalasi Apache, PHP, MariaDB, dan alat tambahan
echo "🔹 Menginstal Apache, PHP, MariaDB, dan alat tambahan..."
loading_bar 5
pkg install apache2 php php-fpm mariadb wget unzip pv dialog openssl -y || handle_error "Gagal menginstal paket."

# Backup konfigurasi Apache jika belum ada backup
CONFIG_PATH="$PREFIX/etc/apache2/httpd.conf"
if [ ! -f "$CONFIG_PATH.bak" ]; then
    cp "$CONFIG_PATH" "$CONFIG_PATH.bak" || handle_error "Gagal membuat backup konfigurasi."
fi

# Konfigurasi Apache
echo "🔹 Mengedit konfigurasi Apache..."
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
loading_bar 3
pgrep -f httpd | xargs kill -9 2>/dev/null || echo "Apache tidak berjalan, melanjutkan..."
pgrep -f php-fpm | xargs kill -9 2>/dev/null || echo "PHP-FPM tidak berjalan, melanjutkan..."
php-fpm & || handle_error "Gagal memulai PHP-FPM!"
apachectl start || handle_error "Gagal memulai Apache!"

# Menyiapkan MariaDB
echo "🔹 Menyiapkan database MariaDB..."
loading_bar 5
mysql_install_db --user=mysql --datadir=$PREFIX/var/lib/mysql || {
    echo "Gagal menginisialisasi MariaDB. Mencoba solusi alternatif..."
    rm -rf $PREFIX/var/lib/mysql
    mkdir -p $PREFIX/var/lib/mysql
    mysql_install_db --user=mysql --datadir=$PREFIX/var/lib/mysql || handle_error "Gagal menginisialisasi database."
}
mysqld_safe --datadir=$PREFIX/var/lib/mysql & sleep 5

# Verifikasi MariaDB sudah berjalan
timeout=30
while ! mysqladmin ping -u root --silent; do
    sleep 1
    ((timeout--))
    if [ $timeout -le 0 ]; then
        handle_error "MariaDB tidak merespons. Timeout tercapai."
    fi
done

# Mengatur password root MariaDB
MYSQL_ROOT_PASSWORD=$(openssl rand -hex 8)
echo "🔒 Password MariaDB: $MYSQL_ROOT_PASSWORD"
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" || handle_error "Gagal mengatur password root."
mysql -u root -e "FLUSH PRIVILEGES;"

# Instalasi phpMyAdmin
echo "🔹 Mengunduh dan menginstal phpMyAdmin..."
PMA_URL="https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip"
wget -q --show-progress "$PMA_URL" -O phpmyadmin.zip || handle_error "Gagal mengunduh phpMyAdmin."
unzip -o phpmyadmin.zip || handle_error "Gagal mengekstrak phpMyAdmin."
mv phpMyAdmin-* $PREFIX/share/phpmyadmin || handle_error "Gagal memindahkan phpMyAdmin."
ln -s $PREFIX/share/phpmyadmin $PREFIX/share/apache2/htdocs/phpmyadmin || handle_error "Gagal membuat symlink phpMyAdmin."
rm -f phpmyadmin.zip

# Instalasi Ngrok
echo "🔹 Mengunduh dan menginstal Ngrok..."
NGROK_URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-arm64.zip"
wget -q --show-progress "$NGROK_URL" -O ngrok.zip || handle_error "Gagal mengunduh Ngrok."
unzip -o ngrok.zip || handle_error "Gagal mengekstrak Ngrok."
chmod +x ngrok
mv ngrok $PREFIX/bin/ || handle_error "Gagal memindahkan Ngrok."
rm -f ngrok.zip

# Tampilkan pesan sukses
clear
echo -e "\e[32m"
type_text "🚀 Instalasi selesai! Web server siap digunakan!" 0.02
type_text "🌐 Akses Web Server: http://127.0.0.1:8080" 0.02
type_text "🌍 phpMyAdmin: http://127.0.0.1:8080/phpmyadmin" 0.02
type_text "🔑 Password MariaDB: $MYSQL_ROOT_PASSWORD" 0.02
type_text "🌍 Ngrok: Jalankan 'ngrok http 8080' untuk mendapatkan URL publik." 0.02
echo -e "\e[0m"
