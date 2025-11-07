#!/data/data/com.termux/files/usr/bin/bash
# 🚀 Picolas Ubuntu SSH Installer for Termux
# Instala OpenSSH + Ubuntu (proot-distro) y deja todo listo para acceder desde otro celular o PC.

set -e
clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧩 Instalador SSH + Ubuntu para Termux (by Picolas)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Actualizar paquetes
pkg update -y && pkg upgrade -y
pkg install -y openssh proot-distro git nano wget curl

# Configurar SSH
echo "🔑 Configurando servidor SSH..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "▶️ Iniciando SSH en puerto 8022..."
sshd
passwd
echo "✅ SSH listo. Tu puerto es 8022."

# Mostrar IP
IP=$(ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1 | head -n1)
echo "🌐 Dirección IP local: $IP"
echo "Usa este comando desde otro dispositivo en la misma red:"
echo "👉 ssh -p 8022 $(whoami)@$IP"

# Instalar Ubuntu
echo "🐧 Instalando Ubuntu..."
proot-distro install ubuntu

# Crear scripts helper
mkdir -p ~/.picolas-ssh

cat > ~/.picolas-ssh/start-sshd.sh <<'SH'
#!/data/data/com.termux/files/usr/bin/bash
echo "▶️ Iniciando servidor SSH en Termux..."
sshd
IP=$(ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1 | head -n1)
echo "🌐 Dirección IP local: $IP"
echo "Conéctate usando: ssh -p 8022 $(whoami)@$IP"
SH
chmod +x ~/.picolas-ssh/start-sshd.sh

cat > ~/.picolas-ssh/ubuntu-login.sh <<'SH'
#!/data/data/com.termux/files/usr/bin/bash
echo "🧠 Iniciando Ubuntu..."
proot-distro login ubuntu
SH
chmod +x ~/.picolas-ssh/ubuntu-login.sh

# Agregar alias a bashrc
if ! grep -q "picolas-ssh" ~/.bashrc; then
  echo "" >> ~/.bashrc
  echo "# 🚀 Aliases Picolas SSH" >> ~/.bashrc
  echo "alias ssh-start='~/.picolas-ssh/start-sshd.sh'" >> ~/.bashrc
  echo "alias ubuntu='~/.picolas-ssh/ubuntu-login.sh'" >> ~/.bashrc
fi

echo "✅ Instalación completada."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧠 Comandos disponibles:"
echo "   ssh-start   -> Inicia servidor SSH"
echo "   ubuntu      -> Entra a Ubuntu"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📢 Desde otro celular en la misma red:"
echo "   ssh -p 8022 $(whoami)@$IP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
