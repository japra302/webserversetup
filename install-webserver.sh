# Bersihkan layar sebelum memulai
clear

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

# Mulai Instalasi
echo "🔹 Memperbarui daftar paket..."
loading_bar
termux-change-repo || handle_error "Gagal mengganti repo!"
pkg update && pkg upgrade -y || handle_error "Gagal memperbarui paket!"

echo "🔹 Menginstal Apache, PHP, MariaDB, dan alat tambahan..."
loading_bar
pkg install apache2 php php-fpm mariadb wget unzip -y || handle_error "Gagal menginstal paket."

echo "🔹 Mengunduh dan menyiapkan phpMyAdmin..."
loading_bar
wget -q --show-progress https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip || handle_error "Gagal mengunduh phpMyAdmin."
unzip phpMyAdmin-5.2.1-all-languages.zip || handle_error "Gagal mengekstrak phpMyAdmin."
mv phpMyAdmin-5.2.1-all-languages $PREFIX/share/phpmyadmin || handle_error "Gagal memindahkan phpMyAdmin."
mkdir -p $PREFIX/share/phpmyadmin/tmp || handle_error "Gagal membuat direktori tmp."
chmod 777 $PREFIX/share/phpmyadmin/tmp || handle_error "Gagal mengatur izin direktori tmp."

echo "🔹 Mengedit konfigurasi Apache..."
loading_bar
CONFIG_PATH="$PREFIX/etc/apache2/httpd.conf"

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

apachectl start || handle_error "Gagal memulai Apache!"

echo "🔹 Menyiapkan database MariaDB..."
loading_bar
mysql_install_db || handle_error "Gagal menginisialisasi database."
mysqld_safe & sleep 5

echo "🔹 Membuat database phpMyAdmin..."
mysql -u root -e "CREATE DATABASE phpmyadmin;" || handle_error "Gagal membuat database."
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';" || handle_error "Gagal mengatur password root."
mysql -u root -e "FLUSH PRIVILEGES;"

echo "🔹 Mengunduh dan menginstal Ngrok..."
loading_bar
wget -q --show-progress https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-arm64.zip || handle_error "Gagal mengunduh Ngrok."
unzip ngrok-stable-linux-arm64.zip || handle_error "Gagal mengekstrak Ngrok."
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
╝     
EOF
echo -e "\e[0m"

type_text "🚀 Instalasi selesai! Web server siap digunakan!" 0.02
type_text "🌐 Akses Web Server: http://127.0.0.1:8080" 0.02
type_text "🌐 phpMyAdmin: http://127.0.0.1:8080/phpmyadmin" 0.02
type_text "🌍 Ngrok (jika aktif): Jalankan 'ngrok http 8080' untuk melihat URL publik." 0.02
echo ""
