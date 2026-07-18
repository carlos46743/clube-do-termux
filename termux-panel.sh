#!/usr/bin/env bash
#
# CLUBE DO TERMUX - PAINEL MULTIFUNÇÕES v2.1
#   Agora compatível com Termux (Android) e Linux (Debian/Ubuntu/Fedora/Arch)
#   Rede + Segurança + Mais pacotes
#
# Uso:
#   bash termux-panel.sh          # modo interativo
#   bash termux-panel.sh --help   # ajuda
#

set -euo pipefail

# ──────────────────────────────────────────────
# CORES
# ──────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# ──────────────────────────────────────────────
# SEGURANÇA: LIMPEZA NA SAÍDA
# ──────────────────────────────────────────────
TEMP_FILES=()
cleanup() {
    for f in "${TEMP_FILES[@]}"; do rm -f "$f" 2>/dev/null || true; done
}
trap cleanup EXIT
trap 'echo -e "\n${RED}⚠ Encerrando...${NC}"; cleanup; exit 1' INT TERM

# ──────────────────────────────────────────────
# DETECÇÃO DE PLATAFORMA
# ──────────────────────────────────────────────
IS_TERMUX=false
[[ -n "${PREFIX:-}" && -d /data/data/com.termux ]] && IS_TERMUX=true

detect_distro() {
    if $IS_TERMUX; then echo "termux"
    elif command -v apt &>/dev/null; then echo "debian"
    elif command -v dnf &>/dev/null; then echo "fedora"
    elif command -v pacman &>/dev/null; then echo "arch"
    elif command -v zypper &>/dev/null; then echo "suse"
    else echo "unknown"
    fi
}

DISTRO=$(detect_distro)

# ──────────────────────────────────────────────
# GERENCIADOR DE PACOTES ABSTRATO
# ──────────────────────────────────────────────
PKG_INSTALL=""; PKG_UPDATE=""; PKG_UPGRADE=""
PKG_CLEAN=""; PKG_LIST=""; PKG_SEARCH=""
PKG_GROUP_INSTALL=""

case "$DISTRO" in
    termux)
        PKG_INSTALL="pkg install -y"
        PKG_UPDATE="pkg update"
        PKG_UPGRADE="pkg upgrade -y"
        PKG_CLEAN="pkg clean"
        PKG_LIST="pkg list-installed 2>/dev/null"
        PKG_SEARCH="pkg search"
        TERMUX_RELOAD="termux-reload-settings 2>/dev/null || true"
        SUDO=""
        ;;
    debian)
        PKG_INSTALL="sudo apt install -y"
        PKG_UPDATE="sudo apt update"
        PKG_UPGRADE="sudo apt upgrade -y"
        PKG_CLEAN="sudo apt autoclean && sudo apt autoremove -y"
        PKG_LIST="dpkg -l 2>/dev/null"
        PKG_SEARCH="apt search"
        PKG_GROUP_INSTALL="sudo apt install -y"
        TERMUX_RELOAD="true"
        SUDO="sudo"
        ;;
    fedora)
        PKG_INSTALL="sudo dnf install -y"
        PKG_UPDATE="sudo dnf check-update || true"
        PKG_UPGRADE="sudo dnf upgrade -y"
        PKG_CLEAN="sudo dnf clean all"
        PKG_LIST="dnf list installed 2>/dev/null"
        PKG_SEARCH="dnf search"
        PKG_GROUP_INSTALL="sudo dnf groupinstall -y"
        TERMUX_RELOAD="true"
        SUDO="sudo"
        ;;
    arch)
        PKG_INSTALL="sudo pacman -S --noconfirm"
        PKG_UPDATE="sudo pacman -Sy"
        PKG_UPGRADE="sudo pacman -Su --noconfirm"
        PKG_CLEAN="sudo pacman -Sc --noconfirm 2>/dev/null || true"
        PKG_LIST="pacman -Q 2>/dev/null"
        PKG_SEARCH="pacman -Ss"
        PKG_GROUP_INSTALL="sudo pacman -S --noconfirm"
        TERMUX_RELOAD="true"
        SUDO="sudo"
        ;;
    suse)
        PKG_INSTALL="sudo zypper install -y"
        PKG_UPDATE="sudo zypper refresh"
        PKG_UPGRADE="sudo zypper update -y"
        PKG_CLEAN="sudo zypper clean"
        PKG_LIST="zypper se --installed-only 2>/dev/null"
        PKG_SEARCH="zypper se"
        PKG_GROUP_INSTALL="sudo zypper install -y"
        TERMUX_RELOAD="true"
        SUDO="sudo"
        ;;
    *)
        echo -e "${RED}Distribuição não suportada: $DISTRO${NC}"
        echo -e "${YELLOW}Tente executar no Termux ou numa distro Debian/Fedora/Arch.${NC}"
        exit 1
        ;;
esac

pkg_install()  { $PKG_INSTALL "$@"; }
pkg_update()   { $PKG_UPDATE; }
pkg_upgrade()  { $PKG_UPGRADE; }
pkg_clean()    { eval "$PKG_CLEAN"; }
pkg_list()     { eval "$PKG_LIST"; }
pkg_count()    { pkg_list 2>/dev/null | wc -l; }

# ──────────────────────────────────────────────
# DIRETÓRIOS E LOG
# ──────────────────────────────────────────────
BASE_DIR="$HOME/termux-projects"
CONFIG_DIR="$HOME/.termux-painel"
LOG_FILE="$CONFIG_DIR/painel.log"
REPORT_DIR="$CONFIG_DIR/reports"
mkdir -p "$BASE_DIR" "$CONFIG_DIR" "$REPORT_DIR"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }

# ──────────────────────────────────────────────
# HELP
# ──────────────────────────────────────────────
show_help() {
    cat <<EOF
Clube do Termux - Painel Multifunções v2.1

Uso:
  bash termux-panel.sh          Modo interativo (menu)
  bash termux-panel.sh --help   Mostra esta ajuda

Plataformas suportadas:
  • Termux (Android)
  • Linux: Debian, Ubuntu, Fedora, Arch, openSUSE

Funcionalidades:
  Instalações:   git, python, nodejs, docker, ubuntu, debian, XFCE, ollama
  IA/CLI:        OpenClaude, Gemini CLI, Hermes Agent
  Rede:          ping, DNS, traceroute, portas, speedtest, whois
  Segurança:     auditoria, firewall (UFW), SSH hardening, scan de vulnerabilidades
  Pacotes:       dev tools, segurança, servidores, mídia, redes
  Git/SSH:       GitHub CLI, chave SSH, clonar repositórios
  Utilitários:   backup, info, projetos, personalização

Licença: MIT
EOF
    exit 0
}

[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && show_help

# ──────────────────────────────────────────────
# FUNÇÕES AUXILIARES
# ──────────────────────────────────────────────
check_installed() {
    if command -v "$1" &>/dev/null; then
        echo -e "${GREEN}✓ Instalado${NC}"
        return 0
    else
        echo -e "${RED}✗ Não instalado${NC}"
        return 1
    fi
}

check_port() {
    local host="$1" port="$2"
    timeout 3 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null && {
        echo -e "${GREEN}  ✓ $host:$port — ABERTA${NC}"
        return 0
    } || {
        echo -e "${RED}  ✗ $host:$port — FECHADA/FILTRADA${NC}"
        return 1
    }
}

pause() { echo ""; read -rp "Pressione ENTER para continuar..." _; }

sanitize_input() {
    local input="$1"
    input="${input//[^a-zA-Z0-9_.:\/\/\-]/}"
    echo "$input"
}

require_root() {
    if ! $IS_TERMUX && [[ "$(id -u)" -ne 0 ]]; then
        echo -e "${YELLOW}⚠ Essa operação requer privilégios sudo.${NC}"
    fi
}

safe_curl() {
    local url="$1" out="$2"
    curl -fsSL --connect-timeout 15 --max-time 60 "$url" -o "$out" 2>/dev/null
}

mktemp_safe() {
    local f
    f="$(mktemp /tmp/clube-XXXXXX 2>/dev/null)" || f="/tmp/clube-$$"
    TEMP_FILES+=("$f")
    echo "$f"
}

# ──────────────────────────────────────────────
# CABEÇALHO
# ──────────────────────────────────────────────
show_header() {
    clear
    local plat="$DISTRO"
    $IS_TERMUX && plat="Termux"
    echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}${BOLD}      CLUBE DO TERMUX - PAINEL MULTIFUNÇÕES   ${NC}${GREEN}║${NC}"
    echo -e "${GREEN}║${NC}          v2.1 · ${plat} · Rede + Segurança      ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📊 Sistema: $(uname -o) | Kernel: $(uname -r)${NC}"
    $IS_TERMUX && echo -e "${BLUE}📦 Pacotes: $(pkg_count)${NC}"
    echo ""
}

# ──────────────────────────────────────────────
# MENU
# ──────────────────────────────────────────────
show_menu() {
    show_header
    echo -e "${GREEN}━━━━━━━━━━━ 📦 INSTALAÇÕES ─────────────────${NC}"
    echo -e " ${YELLOW}[1]${NC} Atualizar sistema"
    echo -e " ${YELLOW}[2]${NC} Ferramentas básicas"
    echo -e " ${YELLOW}[3]${NC} Git              $(check_installed git)"
    echo -e " ${YELLOW}[4]${NC} Python           $(check_installed python3)"
    echo -e " ${YELLOW}[5]${NC} Node.js          $(check_installed node)"
    echo -e " ${YELLOW}[6]${NC} Docker           $(check_installed docker)"
    echo -e " ${YELLOW}[7]${NC} Ubuntu (proot/apt)"
    echo -e " ${YELLOW}[8]${NC} Debian (proot/apt)"
    echo -e " ${YELLOW}[9]${NC}  XFCE + VNC"

    echo -e "\n${GREEN}━━━━━━━━━━━ 🤖 IA ─────────────────────────${NC}"
    echo -e " ${YELLOW}[10]${NC} OpenClaude"
    echo -e " ${YELLOW}[11]${NC} Gemini CLI"
    echo -e " ${YELLOW}[12]${NC} Hermes Agent"
    echo -e " ${YELLOW}[13]${NC} 🦙 Ollama"

    echo -e "\n${GREEN}━━━━━━━━━━━ 📦 MAIS PACOTES ───────────────${NC}"
    echo -e " ${YELLOW}[14]${NC} Ferramentas de rede"
    echo -e " ${YELLOW}[15]${NC} Ferramentas de segurança"
    echo -e " ${YELLOW}[16]${NC} Servidores (nginx, apache, mysql)"
    echo -e " ${YELLOW}[17]${NC} Build tools (gcc, make, cmake)"
    echo -e " ${YELLOW}[18]${NC} Mídia (ffmpeg, imagemagick)"

    echo -e "\n${GREEN}━━━━━━━━━━━ 🔐 GIT/SSH ─────────────────${NC}"
    echo -e " ${YELLOW}[19]${NC} GitHub Login (gh) $(check_installed gh)"
    echo -e " ${YELLOW}[20]${NC} Gerar chave SSH"
    echo -e " ${YELLOW}[21]${NC} Clonar repositório"

    echo -e "\n${GREEN}━━━━━━━━━━━ 🌐 REDE ──────────────────────${NC}"
    echo -e " ${YELLOW}[22]${NC} Diagnóstico de rede"
    echo -e " ${YELLOW}[23]${NC} Testar portas TCP"
    echo -e " ${YELLOW}[24]${NC} Speedtest"
    echo -e " ${YELLOW}[25]${NC} DNS lookup + whois"
    echo -e " ${YELLOW}[26]${NC} Escanear rede local"

    echo -e "\n${GREEN}━━━━━━━━━━━ 🛡️  SEGURANÇA ────────────────${NC}"
    echo -e " ${YELLOW}[27]${NC} 🔍 Auditoria de segurança"
    echo -e " ${YELLOW}[28]${NC} 🧱 Configurar firewall (UFW)"
    echo -e " ${YELLOW}[29]${NC} 🔒 Hardening SSH"
    echo -e " ${YELLOW}[30]${NC} 🕵️  Verificar vulnerabilidades"

    echo -e "\n${GREEN}━━━━━━━━━━━ 🛠️  UTILITÁRIOS ───────────────${NC}"
    echo -e " ${YELLOW}[31]${NC} Backup do sistema"
    echo -e " ${YELLOW}[32]${NC} Informações do sistema"
    echo -e " ${YELLOW}[33]${NC} Gerenciador de projetos"
    echo -e " ${YELLOW}[34]${NC} Personalizar terminal"
    echo -e " ${YELLOW}[35]${NC} Atualizar projetos Git"
    echo -e " ${YELLOW}[36]${NC} 📊 Status do sistema"
    echo -e " ${YELLOW}[37]${NC} 🧹 Limpar cache"

    echo -e "\n${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " ${RED}[0]${NC} Sair"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -ne "${CYAN}➜ Escolha uma opção: ${NC}"
}

# ──────────────────────────────────────────────
# INSTALAÇÕES
# ──────────────────────────────────────────────

install_basic() {
    echo -e "${YELLOW}📦 Instalando ferramentas básicas...${NC}"
    pkg_update
    pkg_upgrade
    local pkgs=(curl wget vim nano htop neofetch openssh nmap unzip zip tar tree jq bc figlet)
    $IS_TERMUX && pkgs+=(termux-api net-tools dnsutils toilet)
    pkg_install "${pkgs[@]}"
    log "Ferramentas básicas instaladas"
    echo -e "${GREEN}✅ Concluído!${NC}"
    sleep 2
}

install_ubuntu() {
    if $IS_TERMUX; then
        echo -e "${YELLOW}🐧 Instalando Ubuntu via proot-distro...${NC}"
        pkg_install proot-distro
        proot-distro install ubuntu
        echo -e "${GREEN}✅ Para entrar: proot-distro login ubuntu${NC}"
    else
        if grep -qi ubuntu /etc/os-release 2>/dev/null; then
            echo -e "${YELLOW}Você já está no Ubuntu!${NC}"
        else
            echo -e "${YELLOW}Usando debootstrap para instalar Ubuntu...${NC}"
            $SUDO apt install -y debootstrap
            $SUDO debootstrap focal /var/chroot/ubuntu 2>/dev/null || {
                echo -e "${YELLOW}Use: sudo debootstrap focal /var/chroot/ubuntu${NC}"
            }
        fi
    fi
    log "Ubuntu instalado"
    sleep 2
}

install_debian() {
    if $IS_TERMUX; then
        echo -e "${YELLOW}🐧 Instalando Debian via proot-distro...${NC}"
        pkg_install proot-distro
        proot-distro install debian
        echo -e "${GREEN}✅ Para entrar: proot-distro login debian${NC}"
    else
        grep -qi debian /etc/os-release 2>/dev/null && { echo -e "${GREEN}✓ Debian detectado${NC}"; sleep 1; return; }
        echo -e "${YELLOW}Instalando debootstrap...${NC}"
        $SUDO apt install -y debootstrap
        echo -e "${GREEN}✅ Use: sudo debootstrap stable /debian${NC}"
    fi
    log "Debian instalado"
    sleep 2
}

install_docker() {
    if $IS_TERMUX; then
        echo -e "${YELLOW}🐳 Docker no Termux requer proot-distro:${NC}"
        pkg_install proot-distro
        proot-distro install ubuntu
        echo -e "${GREEN}✅ Dentro do Ubuntu: apt install -y docker.io${NC}"
    else
        command -v docker &>/dev/null && { echo -e "${GREEN}✓ Docker já instalado${NC}"; sleep 1; return; }
        local dl
        dl="$(mktemp_safe)"
        if safe_curl https://get.docker.com "$dl"; then
            sudo sh "$dl"
            sudo usermod -aG docker "$USER" 2>/dev/null || true
            echo -e "${GREEN}✅ Docker instalado! Re-login para usar sem sudo.${NC}"
        else
            echo -e "${RED}❌ Falha ao baixar instalador Docker${NC}"
        fi
    fi
    log "Docker configurado"
    sleep 2
}

install_xfce() {
    if $IS_TERMUX; then
        echo -e "${YELLOW}🖥️ Instalando XFCE + Termux:X11...${NC}"
        pkg_install x11-repo
        pkg_install tigervnc xfce4 xfce4-terminal termux-x11-nightly
        echo -e "${GREEN}✅ Iniciar: termux-x11 :0 &; export DISPLAY=:0; startxfce4 &${NC}"
    else
        echo -e "${YELLOW}🖥️ Instalando XFCE...${NC}"
        case "$DISTRO" in
            debian) $SUDO apt install -y xfce4 xfce4-terminal tigervnc-standalone-server ;;
            fedora) $SUDO dnf groupinstall -y "Xfce Desktop" ;;
            arch)   $SUDO pacman -S --noconfirm xfce4 xfce4-terminal tigervnc ;;
            *)      echo -e "${RED}Adapte manualmente para sua distro.${NC}" ;;
        esac
        echo -e "${GREEN}✅ Use: vncserver${NC}"
    fi
    log "XFCE instalado"
    sleep 2
}

install_openclaude() {
    echo -e "${YELLOW}🤖 Instalando OpenClaude...${NC}"
    if $IS_TERMUX; then
        termux-setup-storage 2>/dev/null || true
        sleep 1
        pkg_update
        pkg_install curl nodejs git proot
    else
        command -v node &>/dev/null || { echo -e "${YELLOW}Instale Node.js primeiro (opção 5).${NC}"; sleep 2; return; }
    fi
    mkdir -p ~/scripts
    local base="https://raw.githubusercontent.com/jarvesusaram99/open-claude-code-termux/main"
    safe_curl "$base/termux_setup.sh" ~/termux_setup.sh || {
        echo -e "${RED}❌ Repositório não encontrado.${NC}"; log "OpenClaude falhou"; sleep 2; return
    }
    safe_curl "$base/scripts/mobile_tools.sh" ~/scripts/mobile_tools.sh 2>/dev/null || true
    chmod +x ~/termux_setup.sh ~/scripts/mobile_tools.sh 2>/dev/null || true
    export NODE_OPTIONS=--dns-result-order=ipv4first
    bash ~/termux_setup.sh || echo -e "${YELLOW}Execute: bash ~/termux_setup.sh${NC}"
    echo -e "${GREEN}✅ OpenClaude instalado!${NC}"
    log "OpenClaude instalado"
    sleep 2
}

install_gemini() {
    echo -e "${YELLOW}🤖 Instalando Gemini CLI...${NC}"
    command -v node &>/dev/null || { echo -e "${YELLOW}Instale Node.js primeiro (opção 5).${NC}"; sleep 2; return; }
    npm install -g @google/gemini-cli 2>/dev/null && {
        echo -e "${GREEN}✅ Gemini CLI instalado! Use: gemini${NC}"
        log "Gemini CLI instalado"
    } || echo -e "${RED}❌ Erro. Tente: npm install -g @google/gemini-cli${NC}"
    sleep 2
}

install_hermes() {
    echo -e "${YELLOW}🤖 Instalando Hermes Agent...${NC}"
    local dl
    dl="$(mktemp_safe)"
    if safe_curl https://hermes-agent.nousresearch.com/install.sh "$dl"; then
        bash "$dl" && {
            echo -e "${GREEN}✅ Hermes Agent instalado!${NC}"
            log "Hermes Agent instalado"
        } || { echo -e "${RED}❌ Erro na instalação${NC}"; log "Erro Hermes"; }
    else
        echo -e "${RED}❌ Não foi possível baixar o instalador${NC}"
        log "Falha ao baixar Hermes"
    fi
    sleep 2
}

install_ollama() {
    echo -e "${YELLOW}🦙 Instalando Ollama...${NC}"
    if $IS_TERMUX; then
        echo -e "${YELLOW}No Termux, instale manualmente: https://ollama.com/download${NC}"
    else
        local dl
        dl="$(mktemp_safe)"
        if safe_curl https://ollama.com/install.sh "$dl"; then
            sh "$dl" && { echo -e "${GREEN}✅ Ollama instalado!${NC}"; log "Ollama instalado"; } || echo -e "${RED}❌ Erro${NC}"
        else
            echo -e "${RED}❌ Falha ao baixar instalador${NC}"
        fi
    fi
    sleep 2
}

# ──────────────────────────────────────────────
# MAIS PACOTES
# ──────────────────────────────────────────────

install_network_tools() {
    echo -e "${YELLOW}🌐 Instalando ferramentas de rede...${NC}"
    local pkgs
    if $IS_TERMUX; then
        pkgs=(nmap net-tools dnsutils traceroute mtr whois bind-tools)
    else
        case "$DISTRO" in
            debian) pkgs=(nmap net-tools dnsutils traceroute mtr whois bind9-host netcat-openbsd iperf3) ;;
            fedora) pkgs=(nmap net-tools bind-utils traceroute mtr whois nc iperf3) ;;
            arch)   pkgs=(nmap net-tools bind-tools traceroute mtr whois gnu-netcat iperf3) ;;
            suse)   pkgs=(nmap net-tools bind-utils traceroute mtr whois netcat iperf3) ;;
        esac
    fi
    pkg_install "${pkgs[@]}"
    log "Ferramentas de rede instaladas"
    echo -e "${GREEN}✅ Concluído!${NC}"
    sleep 2
}

install_security_tools() {
    echo -e "${YELLOW}🛡️ Instalando ferramentas de segurança...${NC}"
    local pkgs
    if $IS_TERMUX; then
        pkgs=(hydra sqlmap gobuster dirb nikto wfuzz)
    else
        case "$DISTRO" in
            debian) pkgs=(hydra sqlmap gobuster dirb nikto wfuzz lynis rkhunter chkrootkit aide) ;;
            fedora) pkgs=(hydra sqlmap gobuster dirb nikto wfuzz lynis rkhunter aide) ;;
            arch)   pkgs=(hydra sqlmap gobuster dirb nikto wfuzz lynis rkhunter aide) ;;
            suse)   pkgs=(hydra sqlmap gobuster nikto wfuzz lynis rkhunter) ;;
        esac
    fi
    pkg_install "${pkgs[@]}" 2>/dev/null || {
        echo -e "${YELLOW}⚠ Alguns pacotes podem não estar disponíveis. Instalando os que existem...${NC}"
        for p in "${pkgs[@]}"; do
            pkg_install "$p" 2>/dev/null && echo -e "${GREEN}  ✓ $p${NC}" || echo -e "${YELLOW}  - $p pulado${NC}"
        done
    }
    log "Ferramentas de segurança instaladas"
    echo -e "${GREEN}✅ Concluído!${NC}"
    sleep 2
}

install_servers() {
    echo -e "${YELLOW}📡 Instalando servidores...${NC}"
    if $IS_TERMUX; then
        echo -e "${YELLOW}No Termux, servidores são limitados. Instalando leves...${NC}"
        pkg_install nginx mariadb 2>/dev/null || pkg_install nginx
    else
        case "$DISTRO" in
            debian) pkg_install nginx apache2 mariadb-server postgresql redis ;;
            fedora) pkg_install nginx httpd mariadb-server postgresql redis ;;
            arch)   pkg_install nginx apache mariadb postgresql redis ;;
            suse)   pkg_install nginx apache2 mariadb postgresql redis ;;
        esac
        echo -e "${YELLOW}Para iniciar: sudo systemctl enable --now nginx${NC}"
    fi
    log "Servidores instalados"
    echo -e "${GREEN}✅ Concluído!${NC}"
    sleep 2
}

install_build_tools() {
    echo -e "${YELLOW}🔧 Instalando build tools...${NC}"
    if $IS_TERMUX; then
        pkg_install build-essential gcc make cmake pkg-config
    else
        case "$DISTRO" in
            debian) pkg_install build-essential gcc g++ make cmake pkg-config autoconf automake libtool ;;
            fedora) pkg_install @development-tools gcc gcc-c++ make cmake pkgconfig autoconf automake libtool ;;
            arch)   pkg_install base-devel gcc make cmake pkg-config autoconf automake libtool ;;
            suse)   pkg_install -t pattern devel_basis gcc make cmake pkg-config autoconf automake libtool ;;
        esac
    fi
    log "Build tools instaladas"
    echo -e "${GREEN}✅ Concluído!${NC}"
    sleep 2
}

install_media_tools() {
    echo -e "${YELLOW}🎬 Instalando ferramentas de mídia...${NC}"
    local pkgs=(ffmpeg imagemagick sox)
    pkg_install "${pkgs[@]}" 2>/dev/null || {
        for p in "${pkgs[@]}"; do
            pkg_install "$p" 2>/dev/null && echo -e "${GREEN}  ✓ $p${NC}" || echo -e "${YELLOW}  - $p não disponível${NC}"
        done
    }
    log "Ferramentas de mídia instaladas"
    echo -e "${GREEN}✅ Concluído!${NC}"
    sleep 2
}

# ──────────────────────────────────────────────
# GIT/SSH
# ──────────────────────────────────────────────

github_login() {
    echo -e "${YELLOW}🔐 Configurando GitHub CLI...${NC}"
    pkg_install gh
    gh auth login || echo -e "${RED}❌ Falha no login${NC}"
    log "GitHub login"
    sleep 2
}

generate_ssh() {
    echo -e "${YELLOW}🔑 Gerando chave SSH...${NC}"
    local key="$HOME/.ssh/id_ed25519"
    if [ ! -f "$key" ]; then
        ssh-keygen -t ed25519 -C "${USER:-termux}@clube" -f "$key" -N ""
        echo -e "${GREEN}✅ Chave ed25519 gerada em $key${NC}"
    else
        echo -e "${YELLOW}⚠ Chave ed25519 já existe.${NC}"
        key="$HOME/.ssh/id_rsa"
        [ ! -f "$key" ] && { ssh-keygen -t rsa -b 4096 -f "$key" -N ""; echo -e "${GREEN}✅ Chave RSA gerada${NC}"; }
    fi
    echo -e "${YELLOW}📋 Chave pública:${NC}"
    cat "$HOME/.ssh/"*.pub 2>/dev/null || echo -e "${RED}Nenhuma chave encontrada${NC}"
    log "Chave SSH"
    pause
}

clone_repo() {
    echo -e "${YELLOW}📥 Clonar repositório${NC}"
    read -rp "URL: " repo_url
    [[ -z "$repo_url" ]] && { sleep 1; return; }
    repo_url="$(sanitize_input "$repo_url")"
    read -rp "Diretório (ENTER = nome do repo): " dest_dir
    git clone "$repo_url" ${dest_dir:+"$dest_dir"} && {
        echo -e "${GREEN}✅ Clonado!${NC}"; log "Clonado: $repo_url"
    } || echo -e "${RED}❌ Erro ao clonar${NC}"
    sleep 2
}

# ──────────────────────────────────────────────
# REDE
# ──────────────────────────────────────────────

network_diagnostic() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}🌐 DIAGNÓSTICO DE REDE${NC}               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${YELLOW}[1/6] 🖥  Interfaces de rede${NC}"
    if $IS_TERMUX; then
        ip -4 addr show 2>/dev/null | grep inet | grep -v 127.0.0.1 | awk '{print "   IP: " $2}' || echo "   Sem conexão?"
    else
        ip -4 addr show 2>/dev/null | grep inet | grep -v 127.0.0.1 | awk '{print "   IP: " $2}' || ifconfig 2>/dev/null | grep inet
    fi
    echo ""

    echo -e "${YELLOW}[2/6] 📡 Gateway padrão${NC}"
    ip route 2>/dev/null | grep default | awk '{print "   Gateway: " $3}' || route -n 2>/dev/null | grep '^0.0.0.0' | awk '{print "   Gateway: " $2}'
    echo ""

    echo -e "${YELLOW}[3/6] 🌍 DNS servers${NC}"
    if $IS_TERMUX; then
        cat /data/data/com.termux/files/usr/etc/resolv.conf 2>/dev/null || cat /etc/resolv.conf 2>/dev/null || echo "   Não disponível"
    else
        grep nameserver /etc/resolv.conf 2>/dev/null | awk '{print "   " $2}' || echo "   Não disponível"
    fi
    echo ""

    echo -e "${YELLOW}[4/6] 📶 Ping — google.com${NC}"
    ping -c 2 -W 3 google.com 2>/dev/null | tail -1 || echo -e "${RED}   Sem resposta${NC}"
    echo ""

    echo -e "${YELLOW}[5/6] 🧭 Traceroute — google.com${NC}"
    traceroute -m 10 -q 1 -w 2 google.com 2>/dev/null | head -6 || echo -e "${YELLOW}   traceroute não disponível${NC}"
    echo ""

    echo -e "${YELLOW}[6/6] 🔄 Resolução DNS — google.com${NC}"
    host google.com 2>/dev/null | head -3 || nslookup google.com 2>/dev/null | head -5 || dig +short google.com 2>/dev/null || echo -e "${YELLOW}   Não disponível${NC}"
    echo ""

    # Testar portas comuns
    echo -e "${YELLOW}🔌 Testando conexão a serviços populares:${NC}"
    check_port google.com 80
    check_port google.com 443
    check_port github.com 443
    echo ""

    local report="$REPORT_DIR/network-$(date +%Y%m%d-%H%M%S).txt"
    {
        echo "=== Diagnóstico de Rede ==="
        echo "Data: $(date)"
        echo "Host: $(uname -n)"
        echo "IP: $(hostname -I 2>/dev/null)"
        echo "---"
        echo "Gateway: $(ip route 2>/dev/null | grep default | awk '{print $3}')"
        echo "DNS: $(grep nameserver /etc/resolv.conf 2>/dev/null)"
        echo "Ping google.com: $(ping -c 1 -W 2 google.com 2>/dev/null | grep -o 'time=.*' || echo 'falhou')"
    } > "$report"
    echo -e "${GREEN}📄 Relatório salvo: $report${NC}"
    log "Diagnóstico de rede concluído"
    pause
}

test_ports() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}🔌 TESTE DE PORTAS TCP${NC}               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    read -rp "Host/IP: " host
    host="$(sanitize_input "$host")"
    [[ -z "$host" ]] && host="localhost"
    read -rp "Portas (ex: 22,80,443 ou 1-1000): " ports
    [[ -z "$ports" ]] && ports="22,80,443"

    # Verificar portas abertas localmente também
    echo -e "\n${YELLOW}🔍 Portas escutando localmente:${NC}"
    if $IS_TERMUX; then
        netstat -tlnp 2>/dev/null | head -10 || ss -tlnp 2>/dev/null | head -10
    else
        ss -tlnp 2>/dev/null | head -10 || netstat -tlnp 2>/dev/null | head -10 || true
    fi

    echo -e "\n${YELLOW}📡 Testando $host em portas: ${ports}${NC}"
    echo ""
    IFS=',' read -ra PORT_LIST <<< "$ports"
    for p in "${PORT_LIST[@]}"; do
        p="$(echo "$p" | xargs)"
        if [[ "$p" == *-* ]]; then
            start="${p%-*}"; end="${p#*-}"
            for ((i=start; i<=end; i++)); do
                check_port "$host" "$i"
            done
        else
            check_port "$host" "$p"
        fi
    done
    log "Teste de portas: $host $ports"
    pause
}

dns_lookup() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}🌍 DNS LOOKUP + WHOIS${NC}                ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    read -rp "Domínio ou IP: " target
    target="$(sanitize_input "$target")"
    [[ -z "$target" ]] && target="google.com"

    echo -e "\n${YELLOW}📋 Registros DNS de $target${NC}"
    command -v dig &>/dev/null && {
        dig +short "$target" A 2>/dev/null | head -5 && echo "---" && \
        dig +short "$target" AAAA 2>/dev/null | head -3
    } || {
        host "$target" 2>/dev/null | head -5 || nslookup "$target" 2>/dev/null | head -8
    }

    echo -e "\n${YELLOW}🔎 Reverse DNS${NC}"
    dig +short -x "$target" 2>/dev/null | head -3 || host "$target" 2>/dev/null | head -3

    echo -e "\n${YELLOW}📄 WHOIS${NC}"
    command -v whois &>/dev/null && { whois "$target" 2>/dev/null | head -15 || echo -e "${YELLOW}   whois não disponível${NC}"; } || echo -e "${YELLOW}   Instale whois (opção 14)${NC}"

    log "DNS lookup: $target"
    pause
}

speed_test() {
    echo -e "${YELLOW}🌐 Teste de velocidade...${NC}"
    if command -v speedtest-cli &>/dev/null || pkg_install speedtest-cli 2>/dev/null; then
        speedtest-cli
    else
        echo -e "${YELLOW}speedtest-cli não disponível. Usando curl alternativo...${NC}"
        local dl
        dl="$(mktemp_safe)"
        echo -e "${YELLOW}Baixando arquivo de teste (100MB)...${NC}"
        local start total time speed
        start=$(date +%s)
        curl -sL --connect-timeout 10 --max-time 30 -o "$dl" "https://speed.hetzner.de/100MB.bin" || {
            curl -sL --connect-timeout 10 --max-time 30 -o "$dl" "https://proof.ovh.net/files/100Mb.dat" 2>/dev/null
        }
        total=$(stat -c%s "$dl" 2>/dev/null || echo 0)
        time=$(($(date +%s) - start))
        [ "$time" -gt 0 ] && speed=$((total / time)) || speed=0
        echo -e "${GREEN}📥 Download: $((speed / 1024 / 1024)) MB/s em ${time}s${NC}"
    fi
    log "Speedtest"
    pause
}

port_scanner() {
    echo -e "${YELLOW}🔍 Escaneando rede local...${NC}"
    read -rp "Rede (ex: 192.168.1.0/24): " network
    network="${network:-192.168.1.0/24}"
    if command -v nmap &>/dev/null; then
        echo -e "${BLUE}Hosts ativos:${NC}"
        nmap -sn "$network" 2>/dev/null || sudo nmap -sn "$network"
    else
        echo -e "${RED}nmap não instalado. Use opção 2 ou 14.${NC}"
    fi
    log "Scan de rede: $network"
    pause
}

# ──────────────────────────────────────────────
# SEGURANÇA
# ──────────────────────────────────────────────

security_audit() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}🛡️  AUDITORIA DE SEGURANÇA${NC}             ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""

    local report="$REPORT_DIR/security-audit-$(date +%Y%m%d-%H%M%S).txt"
    local issues=0

    # ── 1. Permissões suspeitas (SUID) ──
    echo -e "${YELLOW}[1/8] 🔍 Arquivos SUID/SGID${NC}"
    local suid_files
    suid_files=$(find /usr/bin /usr/sbin /usr/local/bin -perm -4000 -o -perm -2000 2>/dev/null | head -20) || true
    if [[ -n "$suid_files" ]]; then
        echo "$suid_files" | while read -r f; do echo "   ⚠ $f"; done
    else
        echo -e "${GREEN}   ✓ Nenhum SUID suspeito encontrado${NC}"
    fi
    echo ""

    # ── 2. Arquivos com permissão 777 ──
    echo -e "${YELLOW}[2/8] 📂 Permissões 777 em diretórios comuns${NC}"
    local world_writable
    world_writable=$(find /tmp /var/tmp /dev/shm -type f -perm -0002 2>/dev/null | head -10) || true
    if [[ -n "$world_writable" ]]; then
        echo "$world_writable" | while read -r f; do echo "   ⚠ $f"; done
    else
        echo -e "${GREEN}   ✓ Seguro${NC}"
    fi
    echo ""

    # ── 3. Sessions ativas ──
    echo -e "${YELLOW}[3/8] 👥 Sessões ativas${NC}"
    who -u 2>/dev/null | awk '{print "   " $1 " desde " $3 " " $4}' || echo -e "${GREEN}   ✓ Apenas você${NC}"
    echo ""

    # ── 4. Portas abertas ──
    echo -e "${YELLOW}[4/8] 🔊 Portas escutando${NC}"
    if command -v ss &>/dev/null; then
        ss -tlnp 2>/dev/null | grep LISTEN | head -10 || true
    elif command -v netstat &>/dev/null; then
        netstat -tlnp 2>/dev/null | grep LISTEN | head -10 || true
    fi
    echo ""

    # ── 5. Tentativas de login (failed) ──
    echo -e "${YELLOW}[5/8] 🚫 Tentativas de login falhas (últimas 5)${NC}"
    if $IS_TERMUX; then
        echo -e "${YELLOW}   Não disponível no Termux${NC}"
    else
        journalctl -u sshd 2>/dev/null | grep "Failed password" | tail -5 || \
        grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || \
        echo -e "${GREEN}   ✓ Nenhuma falha encontrada${NC}"
    fi
    echo ""

    # ── 6. SSH config ──
    echo -e "${YELLOW}[6/8] 🔐 Configuração SSH${NC}"
    local sshd_config="/etc/ssh/sshd_config"
    if [ -f "$sshd_config" ]; then
        grep -E "PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|Port " "$sshd_config" 2>/dev/null | head -5 | while read -r line; do
            echo "   $line"
            [[ "$line" == *"PermitRootLogin yes"* ]] && { echo -e "   ${RED}   ⚠ Root login permitido!${NC}"; ((issues++)); }
            [[ "$line" == *"PasswordAuthentication yes"* ]] && { echo -e "   ${YELLOW}   ⚠ Senha permitida (considere chave)${NC}"; }
        done
    else
        echo -e "${YELLOW}   SSH não encontrado ou não configurado${NC}"
    fi
    echo ""

    # ── 7. Updates pendentes ──
    echo -e "${YELLOW}[7/8] 📦 Atualizações pendentes${NC}"
    if command -v apt &>/dev/null; then
        local updates
        updates=$(apt list --upgradable 2>/dev/null | grep -c upgradable || echo 0)
        [ "$updates" -gt 1 ] && { echo -e "${RED}   ⚠ $((updates - 1)) pacotes desatualizados${NC}"; ((issues++)); } || echo -e "${GREEN}   ✓ Sistema atualizado${NC}"
    elif command -v dnf &>/dev/null; then
        local updates
        updates=$(dnf check-update 2>/dev/null | grep -cE '^[a-Z]' || echo 0)
        [ "$updates" -gt 0 ] && { echo -e "${RED}   ⚠ $updates pacotes desatualizados${NC}"; ((issues++)); } || echo -e "${GREEN}   ✓ Sistema atualizado${NC}"
    else
        echo -e "${YELLOW}   Não foi possível verificar${NC}"
    fi
    echo ""

    # ── 8. Firewall ──
    echo -e "${YELLOW}[8/8] 🧱 Status do firewall${NC}"
    if command -v ufw &>/dev/null; then
        sudo ufw status 2>/dev/null | head -3
    elif command -v iptables &>/dev/null; then
        sudo iptables -L -n 2>/dev/null | head -5 || echo -e "${YELLOW}   iptables presente mas sem sudo${NC}"
    else
        echo -e "${YELLOW}   Nenhum firewall detectado${NC}"
    fi
    echo ""

    # ── Resumo ──
    echo -e "${GREEN}═══ RESUMO ═══${NC}"
    if [ "$issues" -eq 0 ]; then
        echo -e "${GREEN}✅ Nenhum problema crítico encontrado.${NC}"
    else
        echo -e "${RED}⚠ $issues problema(s) encontrado(s).${NC}"
    fi

    # Salvar relatório
    {
        echo "=== Auditoria de Segurança ==="
        echo "Data: $(date)"
        echo "Host: $(uname -n)"
        echo "Issues: $issues"
    } > "$report"
    echo -e "${GREEN}📄 Relatório salvo: $report${NC}"
    log "Auditoria de segurança: $issues problemas"
    pause
}

setup_firewall() {
    echo -e "${YELLOW}🧱 Configurando firewall (UFW)...${NC}"
    if $IS_TERMUX; then
        echo -e "${YELLOW}Firewall não disponível no Termux (sem kernel privileges).${NC}"
        sleep 2
        return
    fi
    if ! command -v ufw &>/dev/null; then
        echo -e "${YELLOW}Instalando UFW...${NC}"
        pkg_install ufw
    fi
    echo -e "${YELLOW}Configurando regras básicas...${NC}"
    sudo ufw --force reset 2>/dev/null || true
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 80/tcp comment 'HTTP'
    sudo ufw allow 443/tcp comment 'HTTPS'
    # Portas opcionais
    read -rp "Permitir porta 22 (SSH)? [S/n]: " allow_ssh
    [[ "$allow_ssh" =~ ^[Nn] ]] || sudo ufw allow 22/tcp
    read -rp "Permitir porta 8080? [s/N]: " allow_8080
    [[ "$allow_8080" =~ ^[Ss] ]] && sudo ufw allow 8080/tcp
    sudo ufw --force enable 2>/dev/null || echo -e "${RED}Erro ao ativar UFW${NC}"
    sudo ufw status verbose
    log "Firewall configurado"
    echo -e "${GREEN}✅ Firewall ativo! Regras básicas aplicadas.${NC}"
    pause
}

harden_ssh() {
    echo -e "${YELLOW}🔒 Hardening SSH...${NC}"
    local sshd_config="/etc/ssh/sshd_config"
    if $IS_TERMUX; then
        sshd_config="$PREFIX/etc/ssh/sshd_config"
    fi
    if [ ! -f "$sshd_config" ]; then
        echo -e "${RED}❌ sshd_config não encontrado. Instale openssh primeiro.${NC}"
        sleep 2
        return
    fi
    echo -e "${YELLOW}Fazendo backup...${NC}"
    $SUDO cp "$sshd_config" "${sshd_config}.backup.$(date +%Y%m%d)"
    echo -e "${YELLOW}Aplicando hardening...${NC}"
    $SUDO sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' "$sshd_config"
    $SUDO sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$sshd_config"
    $SUDO sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' "$sshd_config"
    $SUDO sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' "$sshd_config"
    $SUDO sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' "$sshd_config"
    $SUDO sed -i 's/^#*ClientAliveInterval.*/ClientAliveInterval 300/' "$sshd_config"
    $SUDO sed -i 's/^#*ClientAliveCountMax.*/ClientAliveCountMax 2/' "$sshd_config"
    $SUDO sed -i 's/^#*Protocol.*/Protocol 2/' "$sshd_config"
    echo -e "${YELLOW}Reiniciando SSH...${NC}"
    if $IS_TERMUX; then
        sshd -T 2>/dev/null || true
        echo -e "${GREEN}✅ Configuração aplicada! Reinicie: pkill sshd && sshd${NC}"
    else
        sudo systemctl restart sshd 2>/dev/null || sudo service ssh restart 2>/dev/null || echo -e "${YELLOW}Reinicie o SSH manualmente.${NC}"
    fi
    echo -e "${GREEN}✅ Hardening SSH aplicado!${NC}"
    echo -e "${YELLOW}═══ Resumo das alterações ═══${NC}"
    grep -E "PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|X11Forwarding|MaxAuthTries|ClientAliveInterval|ClientAliveCountMax|Protocol" "$sshd_config" | while read -r line; do echo "   $line"; done
    log "Hardening SSH aplicado"
    pause
}

check_vulnerabilities() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}🕵️  VERIFICAÇÃO DE VULNERABILIDADES${NC}    ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Verificando CVEs conhecidos em pacotes instalados...${NC}"

    if command -v lynis &>/dev/null; then
        echo -e "${BLUE}   Executando Lynis (auditoria rápida)...${NC}"
        sudo lynis audit system --quick 2>/dev/null | tail -20 || lynis audit system --quick 2>/dev/null | tail -20 || true
    else
        echo -e "${YELLOW}   Lynis não instalado. Use opção 15 para instalar.${NC}"
    fi
    echo ""

    if command -v rkhunter &>/dev/null; then
        echo -e "${BLUE}   Verificando rootkits (rkhunter)...${NC}"
        sudo rkhunter --check --skip-keypress 2>/dev/null | tail -10 || true
    else
        echo -e "${YELLOW}   rkhunter não instalado.${NC}"
    fi
    echo ""

    # Verificar pacotes com CVEs conhecidos (versões antigas)
    echo -e "${YELLOW}🔎 Pacotes potencialmente vulneráveis:${NC}"
    local packages="openssl libssl libgnutls curl bash sudo"
    for pkg in $packages; do
        local ver
        ver=$(pkg_list 2>/dev/null | grep "$pkg" | head -1 | awk '{print $2}') || true
        [[ -n "$ver" ]] && echo "   $pkg: $ver" || true
    done
    echo -e "${YELLOW}   (versões antigas podem ter CVEs — mantenha o sistema atualizado)${NC}"

    # Checar senhas fracas
    echo ""
    echo -e "${YELLOW}🔐 Checando usuários sem senha:${NC}"
    if ! $IS_TERMUX; then
        awk -F: '($2 == "" || $2 == "!") {print "   ⚠ " $1 ": sem senha"}' /etc/shadow 2>/dev/null | head -5 || echo -e "${GREEN}   ✓ Todos com senha${NC}"
    else
        echo -e "${YELLOW}   Não disponível no Termux${NC}"
    fi

    echo ""
    local report="$REPORT_DIR/vuln-check-$(date +%Y%m%d).txt"
    {
        echo "=== Verificação de Vulnerabilidades ==="
        echo "Data: $(date)"
        echo "Pacotes:"
        for pkg in $packages; do
            pkg_list 2>/dev/null | grep "$pkg" | head -1
        done
    } > "$report"
    echo -e "${GREEN}📄 Relatório salvo: $report${NC}"
    log "Verificação de vulnerabilidades concluída"
    pause
}

# ──────────────────────────────────────────────
# UTILITÁRIOS
# ──────────────────────────────────────────────

backup_system() {
    echo -e "${YELLOW}💾 Fazendo backup...${NC}"
    local backup_dir="$HOME/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    $IS_TERMUX && cp -r "$HOME/.termux" "$backup_dir/" 2>/dev/null || true
    cp -r "$HOME/.ssh" "$backup_dir/" 2>/dev/null || true
    cp -r "$HOME/.bashrc" "$backup_dir/" 2>/dev/null || true
    cp -r "$BASE_DIR" "$backup_dir/projetos" 2>/dev/null || true
    pkg_list > "$backup_dir/packages-list.txt" 2>/dev/null || true
    tar -czf "${backup_dir}.tar.gz" -C "$HOME" "$(basename "$backup_dir")" 2>/dev/null
    rm -rf "$backup_dir"
    echo -e "${GREEN}✅ Backup: ${backup_dir}.tar.gz${NC}"
    log "Backup"
    sleep 2
}

system_info() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}📊 INFORMAÇÕES DO SISTEMA${NC}         ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}🖥️  OS:${NC} $(uname -o)"
    echo -e "${GREEN}🐧 Kernel:${NC} $(uname -r)"
    echo -e "${GREEN}📱 Arch:${NC} $(uname -m)"
    echo -e "${GREEN}🔄 Uptime:${NC} $(uptime -p 2>/dev/null || uptime | awk '{print $3,$4}')"
    echo -e "${GREEN}👤 User:${NC} $(whoami)"
    echo -e "${GREEN}💾 Disco:${NC}"
    df -h / | awk 'NR==2 {print "   Total: "$2" | Usado: "$3" | Livre: "$4" | Uso: "$5}'
    echo -e "${GREEN}🧠 RAM:${NC}"
    free -h | awk 'NR==2 {print "   Total: "$2" | Usado: "$3" | Livre: "$4}'
    echo -e "${GREEN}🌐 IP:${NC} $(hostname -I 2>/dev/null | awk '{print $1}')"
    echo -e "${GREEN}📦 Pacotes:${NC} $(pkg_count)"
    echo ""
    pause
}

project_manager() {
    while true; do
        clear
        echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC} ${BOLD}📂 GERENCIADOR DE PROJETOS${NC}          ${CYAN}║${NC}"
        echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
        echo ""
        echo -e " ${YELLOW}[1]${NC} Listar"
        echo -e " ${YELLOW}[2]${NC} Criar"
        echo -e " ${YELLOW}[3]${NC} Abrir no VS Code/code-server"
        echo -e " ${YELLOW}[4]${NC} Remover"
        echo -e " ${YELLOW}[5]${NC} Voltar"
        echo ""
        read -rp "➜ Escolha: " opt
        case "$opt" in
            1) ls -1 "$BASE_DIR" 2>/dev/null || echo -e "${YELLOW}Nenhum projeto.${NC}" ;;
            2) read -rp "Nome: " name; mkdir -p "$BASE_DIR/$name"; echo -e "${GREEN}✅ $BASE_DIR/$name${NC}"; log "Projeto: $name" ;;
            3)
                read -rp "Nome: " name
                if [ -d "$BASE_DIR/$name" ]; then
                    if command -v code-server &>/dev/null; then code-server "$BASE_DIR/$name"
                    elif command -v code &>/dev/null; then code "$BASE_DIR/$name"
                    else echo -e "${YELLOW}Use nano/vim: nano $BASE_DIR/$name${NC}"
                    fi
                else echo -e "${RED}Não encontrado.${NC}"
                fi
                ;;
            4)
                read -rp "Nome: " name
                [ -d "$BASE_DIR/$name" ] && { rm -rf "$BASE_DIR/$name"; echo -e "${GREEN}✅ Removido.${NC}"; log "Removido: $name"; } || echo -e "${RED}Não encontrado.${NC}"
                ;;
            5) break ;;
            *) echo -e "${RED}Inválido.${NC}" ;;
        esac
        echo ""; pause
    done
}

customize_terminal() {
    echo -e "${YELLOW}🎨 Personalizando terminal...${NC}"
    if $IS_TERMUX; then
        mkdir -p "$HOME/.termux"
        cat > "$HOME/.termux/termux.properties" <<- 'EOF'
use-black-ui = true
bell-character = ignore
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
EOF
        eval "$TERMUX_RELOAD"
        echo -e "${GREEN}✅ Termux personalizado!${NC}"
    fi

    # Aliases — evita duplicação
    local bashrc="$HOME/.bashrc"
    grep -q "Clube do Termux" "$bashrc" 2>/dev/null || {
        cat >> "$bashrc" <<- 'BASHEOF'

# ── Clube do Termux aliases ──
alias ll='ls -la'
alias la='ls -A'
alias ..='cd ..'
alias cls='clear'
BASHEOF
        if $IS_TERMUX; then
            cat >> "$bashrc" <<- 'BASHEOF'
alias update='pkg update && pkg upgrade'
alias install='pkg install'
alias search='pkg search'
alias projects='cd ~/termux-projects'
BASHEOF
        else
            cat >> "$bashrc" <<- 'BASHEOF'
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias projects='cd ~/termux-projects'
BASHEOF
        fi
        echo -e "${GREEN}✅ Aliases adicionados!${NC}"
    }
    log "Terminal personalizado"
    sleep 2
}

update_all_projects() {
    echo -e "${YELLOW}🔄 Atualizando projetos Git...${NC}"
    local count=0
    for project in "$BASE_DIR"/*; do
        [ -d "$project/.git" ] || continue
        echo -e "${BLUE}📂 $(basename "$project")${NC}"
        (cd "$project" && git pull) || true
        ((count++))
    done
    [ "$count" -eq 0 ] && echo -e "${YELLOW}Nenhum projeto Git encontrado.${NC}" || echo -e "${GREEN}✅ $count projeto(s) atualizado(s)!${NC}"
    log "Projetos atualizados"
    sleep 2
}

system_status() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}📊 STATUS DO SISTEMA${NC}                ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}🔍 Serviços:${NC}"
    ps aux 2>/dev/null | grep -E "sshd|docker|nginx|httpd|apache|mysql|postgres|redis" | grep -v grep | head -10 || echo -e "${YELLOW}   Nenhum serviço relevante${NC}"
    echo ""
    echo -e "${GREEN}💾 Disco:${NC}"
    df -h / | tail -1
    echo ""
    echo -e "${GREEN}🧠 RAM:${NC}"
    free -h
    echo ""
    echo -e "${GREEN}📁 Projetos:${NC} $(ls -d "$BASE_DIR"/*/ 2>/dev/null | wc -l)"
    echo ""
    pause
}

clean_cache() {
    echo -e "${YELLOW}🧹 Limpando cache...${NC}"
    pkg_clean 2>/dev/null || true
    rm -rf "$HOME/.cache"/* 2>/dev/null || true
    rm -rf "$HOME/.npm/_cacache" 2>/dev/null || true
    echo -e "${GREEN}✅ Cache limpo!${NC}"
    log "Cache limpo"
    sleep 2
}

# ──────────────────────────────────────────────
# LOOP PRINCIPAL
# ──────────────────────────────────────────────
while true; do
    show_menu
    read -r option

    case "$option" in
        1) echo -e "${YELLOW}🔄 Atualizando...${NC}"; pkg_update && pkg_upgrade; log "Sistema atualizado"; echo -e "${GREEN}✅ Concluído!${NC}"; sleep 2 ;;
        2) install_basic ;;
        3) echo -e "${YELLOW}📦 Instalando Git...${NC}"; pkg_install git; log "Git instalado"; sleep 2 ;;
        4) echo -e "${YELLOW}🐍 Instalando Python...${NC}"; pkg_install python3 python3-pip 2>/dev/null || pkg_install python; log "Python instalado"; sleep 2 ;;
        5)
            echo -e "${YELLOW}📦 Instalando Node.js...${NC}"
            if $IS_TERMUX; then pkg_install nodejs
            else
                local dl; dl="$(mktemp_safe)"
                if safe_curl https://deb.nodesource.com/setup_20.x "$dl"; then
                    sudo -E bash "$dl" && sudo apt install -y nodejs
                else echo -e "${RED}❌ Falha ao baixar instalador${NC}"
                fi
            fi
            log "Node.js instalado"; sleep 2 ;;
        6) install_docker ;;
        7) install_ubuntu ;;
        8) install_debian ;;
        9) install_xfce ;;
        10) install_openclaude ;;
        11) install_gemini ;;
        12) install_hermes ;;
        13) install_ollama ;;
        14) install_network_tools ;;
        15) install_security_tools ;;
        16) install_servers ;;
        17) install_build_tools ;;
        18) install_media_tools ;;
        19) github_login ;;
        20) generate_ssh ;;
        21) clone_repo ;;
        22) network_diagnostic ;;
        23) test_ports ;;
        24) speed_test ;;
        25) dns_lookup ;;
        26) port_scanner ;;
        27) security_audit ;;
        28) setup_firewall ;;
        29) harden_ssh ;;
        30) check_vulnerabilities ;;
        31) backup_system ;;
        32) system_info ;;
        33) project_manager ;;
        34) customize_terminal ;;
        35) update_all_projects ;;
        36) system_status ;;
        37) clean_cache ;;
        0) echo -e "${GREEN}👋 Até logo!${NC}"; log "Sessão encerrada"; exit 0 ;;
        *) echo -e "${RED}❌ Opção inválida!${NC}"; sleep 1 ;;
    esac
done
