#!/data/data/com.termux/files/usr/bin/bash
# 🚀 Picolas Termux VPS Free Installer
# Crea un mini VPS Ubuntu con Apache y Cloudflared

set -e
clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Instalador de VPS gratuita - by Picolas"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

echo "📦 Actualizando Termux..."
pkg update -y && pkg upgrade -y
pkg install -y proot-distro cloudflared wget curl nano

echo "💿 Instalando Ubuntu (si no existe)..."
if ! proot-distro list | grep -q "^ubuntu"; then
  proot-distro install ubuntu
fi

echo "🧠 Configurando Ubuntu interna..."
proot-distro login ubuntu -- bash -lc '
  set -e
  export DEBIAN_FRONTEND=noninteractive
  apt update -y
  apt install -y apache2
  sed -i "s/^Listen 80/Listen 8080/" /etc/apache2/ports.conf
  sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:8080>/" /etc/apache2/sites-available/000-default.conf
  cat > /var/www/html/index.html <<HTML
<!DOCTYPE html>
<html lang="es">
<head><meta charset="utf-8"><title>Picolas VPS</title></head>
<body style="font-family:system-ui; background:#0a0f1c; color:#e2e8f0; text-align:center; padding:40px">
  <h1>🚀 Picolas VPS casera</h1>
  <p>Servida desde <strong>Ubuntu en Termux</strong> con <strong>Apache</strong> por el puerto 8080.</p>
  <p>URL pública generada con <strong>Cloudflared</strong>.</p>
</body>
</html>
HTML
  service apache2 stop || true
  service apache2 start
'

echo "⚙️ Creando scripts de inicio/parada..."
PREFIX_DIR="$HOME/.picolas-vps"
mkdir -p "$PREFIX_DIR"

cat > "$PREFIX_DIR/start-vps.sh" <<'SH'
#!/data/data/com.termux/files/usr/bin/bash
set -e
echo "▶️ Arrancando Apache dentro de Ubuntu..."
proot-distro login ubuntu -- bash -lc "service apache2 start"
echo "🌐 Abriendo túnel con Cloudflared (HTTP -> http://127.0.0.1:8080)"
echo "📎 Copiá el enlace .trycloudflare.com que aparece abajo 👇"
cloudflared tunnel --url http://127.0.0.1:8080
SH
chmod +x "$PREFIX_DIR/start-vps.sh"

cat > "$PREFIX_DIR/stop-vps.sh" <<'SH'
#!/data/data/com.termux/files/usr/bin/bash
set -e
pkill -f "cloudflared tunnel" >/dev/null 2>&1 || true
proot-distro login ubuntu -- bash -lc "service apache2 stop || true"
echo "✅ VPS detenida correctamente."
SH
chmod +x "$PREFIX_DIR/stop-vps.sh"

SHELL_RC="$HOME/.bashrc"
grep -q "picolas-vps" "$SHELL_RC" 2>/dev/null || cat >> "$SHELL_RC" <<'RC'
# 🧩 Aliases para Picolas VPS
alias vps-start="$HOME/.picolas-vps/start-vps.sh"
alias vps-stop="$HOME/.picolas-vps/stop-vps.sh"
RC

echo
echo "✅ Instalación completada."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👉 Comandos disponibles:"
echo "   vps-start   # inicia la VPS"
echo "   vps-stop    # detiene la VPS"
echo
echo "⚠️ Si no te toma los comandos, ejecutá:"
echo "   source ~/.bashrc"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
EOF
