#!/bin/bash

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
    
    ___  ________  ________  ________  ________    _______     
   |\  \|\   __  \|\   __  \|\_____  \|\   __  \  /  ___  \    
   \ \  \ \  \|\  \ \  \|\  \|____|\ /\ \  \|\  \/__/|_/  /|   
 __ \ \  \ \   ____\ \   _  _\    \|\  \ \  \\\  \__|//  / /   
|\  \\_\  \ \  \___|\ \  \\  \|  __\_\  \ \  \\\  \  /  /_/__  
\ \________\ \__\    \ \__\\ _\ |\_______\ \_______\|\________\
 \|________|\|__|     \|__|\|__|\|_______|\|_______| \|_______|
                                                               
                                                               
                                                               
                                                          


   🚀 WEB SERVER INSTALLER | TERMUX EDITION |By : Japra 302 🚀
EOF
echo -e "\e[0m"

sleep 1
type_text "🔥 Selamat datang di Skrip Ajaib Web Server Termux! 🔥" 0.03
sleep 1
type_text "⚡ Menginstal Apache, PHP, MariaDB, phpMyAdmin, dan Ngrok..." 0.03
sleep 1
echo ""

# Mulai Instalasi
echo "🔹 Memperbarui daftar paket..."
loading_bar
termux-change-repo || handle_error "Gagal mengganti repo!"
pkg update && pkg upgrade -y || handle_error "Gagal memperbarui paket!"

echo "🔹 Menginstal Apache, PHP, MariaDB, dan alat tambahan..."
loading_bar
pkg install apache2 php php-fpm mariadb wget unzip curl -y || handle_error "Gagal menginstal paket."

echo "🔹 Mengunduh dan menyiapkan phpMyAdmin..."
loading_bar
wget -q --show-progress https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip || handle_error "Gagal mengunduh phpMyAdmin."
unzip phpMyAdmin-5.2.1-all-languages.zip || handle_error "Gagal mengekstrak phpMyAdmin."
mv phpMyAdmin-5.2.1-all-languages $PREFIX/share/phpmyadmin || handle_error "Gagal memindahkan phpMyAdmin."
chmod -R 755 $PREFIX/share/phpmyadmin

echo "🔹 Mengedit konfigurasi Apache..."
loading_bar
CONFIG_PATH="$PREFIX/etc/apache2/httpd.conf"
sed -i '/LoadModule php/d' $CONFIG_PATH
sed -i '/AddHandler application\/x-httpd-php/d' $CONFIG_PATH
sed -i '/DirectoryIndex index.php/d' $CONFIG_PATH
sed -i '/Alias \/phpmyadmin/d' $CONFIG_PATH
sed -i '/<Directory "\/data\/data\/com.termux\/files\/usr\/share\/phpmyadmin">/,/<\/Directory>/d' $CONFIG_PATH

# Tambahkan konfigurasi baru
echo "\n# Konfigurasi PHP-FPM" >> $CONFIG_PATH
echo "LoadModule php_module modules/libphp.so" >> $CONFIG_PATH
echo "AddHandler application/x-httpd-php .php" >> $CONFIG_PATH
echo "DirectoryIndex index.php index.html" >> $CONFIG_PATH
echo "Alias /phpmyadmin \"$PREFIX/share/phpmyadmin\"" >> $CONFIG_PATH
echo "<Directory \"$PREFIX/share/phpmyadmin\">" >> $CONFIG_PATH
echo "    AllowOverride All" >> $CONFIG_PATH
echo "    Require all granted" >> $CONFIG_PATH
echo "</Directory>" >> $CONFIG_PATH

echo "🔹 Memulai Apache dan PHP-FPM..."
loading_bar

apachectl start || handle_error "Gagal memulai Apache!"

echo "🔹 Menyiapkan database MariaDB..."
loading_bar
mysql_install_db || handle_error "Gagal menginisialisasi database."
mysqld_safe & sleep 5
mysql -u root -e "CREATE DATABASE phpmyadmin;" || handle_error "Gagal membuat database."
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';" || handle_error "Gagal mengatur password root."
mysql -u root -e "FLUSH PRIVILEGES;"

echo "🔹 Restarting services..."
loading_bar
apachectl restart || handle_error "Gagal memulai Apache!"

# NGROK SETUP
echo "🔹 Menginstal dan Menyiapkan Ngrok..."
loading_bar

# Periksa apakah ngrok sudah terpasang
if ! command -v ngrok &> /dev/null; then
    echo "🔹 Mengunduh Ngrok..."
    wget -q --show-progress https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip || handle_error "Gagal mengunduh Ngrok."
    unzip ngrok-stable-linux-arm.zip -d $PREFIX/bin || handle_error "Gagal mengekstrak Ngrok."
    chmod +x $PREFIX/bin/ngrok
fi

# Tambahkan token Ngrok (ganti dengan token kamu)
NGROK_TOKEN="YOUR_NGROK_TOKEN"
ngrok config add-authtoken 2srIEjiuP5TOF2d3LAWX7tbeWLf_4hzLoXTjLeXEh1ynyTrH8

echo "🔹 Menjalankan Ngrok untuk Web Server..."
loading_bar

ngrok http 8080 &  
sleep 2  

# Ambil URL Publik dari Ngrok
NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o '"public_url":"[^"]*' | cut -d'"' -f4)

clear
# Fungsi untuk menampilkan teks dengan efek mengetik
type_text() {
    text="$1"
    delay="$2"
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

# Menampilkan teks 
type_text "🌍Sesungguhnya bukan aku yang hebat dan Bukan aku yang berilmu,🌍" 0.05
type_text "tiada kepemilikan dalam diri ini." 0.05
type_text "Apa yang tampak sebagai pemahaman hanyalah cahaya-Nya" 0.05
type_text "yang memancar melalui wujud yang sementara." 0.05
type_text "Aku tidak mengetahui, aku tidak memiliki, aku tidak ada—hanya Dia" 0.05
type_text "yang nyata dalam segala yang disangka ada." 0.05

# Tunggu beberapa detik sebelum menghapus
sleep 3
clear

# Warna hijau untuk teks
echo -e "\e[32m"

# Menampilkan ASCII art/logo
cat << "EOF"
    
     _ ___ ___ ____ __ ___ 
  _ | | _ \ _ \__ //  \_  )
 | || |  _/   /|_ \ () / / 
  \__/|_| |_|_\___/\__/___|
                           
EOF

echo -e "\e[0m"

# Menampilkan informasi instalasi
type_text "🚀 Instalasi selesai! Web server siap digunakan!" 0.02
type_text "🌐 Akses Web Server: http://127.0.0.1:8080" 0.02
type_text "🌐 phpMyAdmin: http://127.0.0.1:8080/phpmyadmin" 0.02
type_text "🌍 Ngrok URL: $NGROK_URL" 0.02
echo ""
