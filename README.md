<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🚀 Web Server Installer | Termux Edition | By : Japra302</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 800px;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h1 {
            text-align: center;
            color: #333;
        }
        h2 {
            color: #007BFF;
        }
        pre {
            background: #333;
            color: #fff;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
        }
        ul {
            list-style: none;
            padding: 0;
        }
        ul li::before {
            content: "✅ ";
            color: green;
        }
        .note {
            background: #fffae6;
            padding: 10px;
            border-left: 4px solid #ffc107;
            margin: 10px 0;
        }
    </style>
</head>
<body>

<div class="container">
    <h1>🚀 Web Server Installer | Termux Edition</h1>
    <p><strong>By: Japra302</strong></p>
    <p>Skrip ini secara otomatis menginstal dan mengonfigurasi web server di Termux, termasuk Apache, PHP, MariaDB, dan phpMyAdmin. Selain itu, skrip juga menyediakan opsi untuk mengatur Ngrok agar server dapat diakses dari internet.</p>

    <h2>📌 Fitur</h2>
    <ul>
        <li>Instalasi otomatis Apache, PHP, MariaDB, dan phpMyAdmin</li>
        <li>Pemeriksaan dan instalasi dependensi yang diperlukan</li>
        <li>Backup otomatis file konfigurasi sebelum diubah</li>
        <li>Efek ketikan dan loading bar untuk pengalaman interaktif</li>
        <li>Pemeriksaan koneksi internet dan status layanan sebelum memulai</li>
        <li>Konfigurasi otomatis phpMyAdmin agar siap digunakan</li>
        <li>Opsi instalasi dan pengaturan Ngrok untuk akses server dari internet</li>
    </ul>

    <h2>📦 Paket yang Dipasang</h2>
    <pre>Apache2
PHP & PHP-FPM
MariaDB (MySQL)
phpMyAdmin
Wget, Unzip, PV, Dialog
Ngrok (opsional)</pre>

    <h2>🔧 Cara Instalasi</h2>
    <p>1. Pastikan Termux telah diperbarui:</p>
    <pre>pkg update && pkg upgrade -y
pkg install git</pre>

    <p>2. Unduh skrip ini:</p>
    <pre>wget https://github.com/japra302/webserversetup.git -O webserver.sh</pre>

    <p>3. Jalankan skrip:</p>
    <pre>git clone https://github.com/japra302/webserversetup.git
cd webserversetup
ls -l
chmod +x install-webserver.sh
dos2unix install-webserver.sh
./install-webserver.sh</pre>

    <p>4. Ikuti petunjuk di layar untuk menyelesaikan instalasi.</p>

    <h2>🌐 Akses Web Server</h2>
    <ul>
        <li>Web Server: <a href="http://127.0.0.1:8080">http://127.0.0.1:8080</a></li>
        <li>phpMyAdmin: <a href="http://127.0.0.1:8080/phpmyadmin">http://127.0.0.1:8080/phpmyadmin</a></li>
        <li>Ngrok (jika aktif): Jalankan <code>ngrok http 8080</code> untuk melihat URL publik.</li>
    </ul>

    <h2>🔥 Fitur Tambahan</h2>
    <ul>
        <li>Backup otomatis sebelum mengedit file konfigurasi.</li>
        <li>Restart layanan otomatis setelah instalasi selesai.</li>
        <li>Dukungan untuk versi phpMyAdmin yang dapat dipilih pengguna.</li>
    </ul>

    <h2>🛠 Troubleshooting</h2>
    <p>Jika terjadi masalah, periksa file log berikut:</p>
    <ul>
        <li>Log instalasi: <code>install.log</code></li>
        <li>Log kesalahan: <code>error.log</code></li>
    </ul>
    <p>Untuk restart layanan secara manual:</p>
    <pre>pkill -f httpd
pkill -f php-fpm
php-fpm &
apachectl start</pre>

    <h2>📜 Lisensi</h2>
    <p>Proyek ini menggunakan lisensi MIT. Silakan gunakan dan modifikasi sesuai kebutuhan.</p>
</div>

</body>
</html>
