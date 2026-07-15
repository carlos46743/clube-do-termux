#!/bin/bash

# =============================================
# CLUBE DO TERMUX - PAINEL MULTIFUNÇÕES v2.0
# =============================================


# Cores para melhor visualização
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'


# Diretório base
BASE_DIR="$HOME/termux-projects"
CONFIG_DIR="$HOME/.termux-painel"
LOG_FILE="$CONFIG_DIR/painel.log"


# Criar diretórios necessários
mkdir -p "$BASE_DIR" "$CONFIG_DIR"


# Função para log
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}


# Função para verificar se já está instalado
check_installed() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓ Instalado${NC}"
        return 0
    else
        echo -e "${RED}✗ Não instalado${NC}"
        return 1
    fi
}


# Função para mostrar cabeçalho
show_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}${BOLD}${WHITE}      CLUBE DO TERMUX - PAINEL MULTIFUNÇÕES     ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}${YELLOW}            Versão 2.0 - Melhorado!              ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📊 Sistema:$(uname -o) | Kernel:$(uname -r)${NC}"
    echo -e "${BLUE}📦 Pacotes instalados:$(pkg list-installed 2>/dev/null | wc -l)${NC}"
    echo ""
}


# Função para menu principal
show_menu() {
    show_header
    echo -e "${GREEN}━━━━━━━━━━━ 📦 INSTALAÇÕES ━━━━━━━━━━━${NC}"
    echo -e " ${YELLOW}[1]${NC} Atualizar Termux"
    echo -e " ${YELLOW}[2]${NC} Instalar ferramentas básicas"
    echo -e " ${YELLOW}[3]${NC} Instalar Git $(check_installed git)"
    echo -e " ${YELLOW}[4]${NC} Instalar Python $(check_installed python)"
    echo -e " ${YELLOW}[5]${NC} Instalar Node.js $(check_installed node)"
    echo -e " ${YELLOW}[6]${NC} Instalar Docker (proot) $(check_installed docker)"
    echo -e " ${YELLOW}[7]${NC} Instalar Ubuntu"
    echo -e " ${YELLOW}[8]${NC} Instalar Debian"
    
    echo -e "\n${GREEN}━━━━━━━━━━━ 🖥️ INTERFACE ━━━━━━━━━━━${NC}"
    echo -e " ${YELLOW}[9]${NC}  Instalar XFCE + Termux:X11"
    echo -e " ${YELLOW}[10]${NC} Instalar OpenClaude"
    echo -e " ${YELLOW}[11]${NC} Instalar Gemini CLI"
    echo -e " ${YELLOW}[12]${NC} Instalar Hermes Agent"
    
    echo -e "\n${GREEN}━━━━━━━━━━ 🔐 GIT/SSH ━━━━━━━━━━━${NC}"
    echo -e " ${YELLOW}[13]${NC} GitHub Login (gh) $(check_installed gh)"
    echo -e " ${YELLOW}[14]${NC} Gerar chave SSH"
    echo -e " ${YELLOW}[15]${NC} Clonar repositório Git"
    
    echo -e "\n${GREEN}━━━━━━━━━━ 🛠️ UTILITÁRIOS ━━━━━━━━━━━${NC}"
    echo -e " ${YELLOW}[16]${NC} Backup do Termux"
    echo -e " ${YELLOW}[17]${NC} Informações do sistema"
    echo -e " ${YELLOW}[18]${NC} Teste de velocidade da internet"
    echo -e " ${YELLOW}[19]${NC} Scanner de portas da rede local"
    echo -e " ${YELLOW}[20]${NC} Gerenciador de projetos"
    echo -e " ${YELLOW}[21]${NC} Personalizar Termux"
    echo -e " ${YELLOW}[22]${NC} Atualizar todos os projetos"
    echo -e " ${YELLOW}[23]${NC} 📊 Status do sistema"
    echo -e " ${YELLOW}[24]${NC} 🧹 Limpar cache"
    
    echo -e "\n${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e " ${RED}[0]${NC} Sair"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -ne "${CYAN}➜ Escolha uma opção: ${NC}"
}


# Função para instalar ferramentas básicas
install_basic() {
    echo -e "${YELLOW}📦 Instalando ferramentas básicas...${NC}"
    pkg update -y && pkg upgrade -y
    pkg install -y \
        curl \
        wget \
        vim \
        nano \
        htop \
        neofetch \
        termux-api \
        openssh \
        nmap \
        net-tools \
        dnsutils \
        unzip \
        zip \
        tar \
        tree \
        jq \
        bc \
        figlet \
        toilet
    log "Ferramentas básicas instaladas"
    echo -e "${GREEN}✅ Ferramentas básicas instaladas!${NC}"
    sleep 2
}


# Função para instalar Ubuntu
install_ubuntu() {
    echo -e "${YELLOW}🐧 Instalando Ubuntu no Termux...${NC}"
    pkg install -y proot-distro
    proot-distro install ubuntu
    echo -e "${GREEN}✅ Ubuntu instalado! Para iniciar: proot-distro login ubuntu${NC}"
    log "Ubuntu instalado"
    sleep 2
}


# Função para instalar Debian
install_debian() {
    echo -e "${YELLOW}🐧 Instalando Debian no Termux...${NC}"
    pkg install -y proot-distro
    proot-distro install debian
    echo -e "${GREEN}✅ Debian instalado! Para iniciar: proot-distro login debian${NC}"
    log "Debian instalado"
    sleep 2
}


# Função para instalar Docker (proot)
install_docker() {
    echo -e "${YELLOW}🐳 Instalando Docker via proot...${NC}"
    pkg install -y proot-distro
    proot-distro install ubuntu
    echo -e "${GREEN}✅ Docker instalado via proot!${NC}"
    echo -e "${YELLOW}Para usar o Docker:${NC}"
    echo "1. proot-distro login ubuntu"
    echo "2. apt update && apt install -y docker.io"
    echo "3. docker --version"
    log "Docker (proot) instalado"
    sleep 3
}


# Função para instalar XFCE
install_xfce() {
    echo -e "${YELLOW}🖥️ Instalando XFCE + Termux:X11...${NC}"
    pkg install -y x11-repo
    pkg install -y tigervnc xfce4 xfce4-terminal
    pkg install -y termux-x11-nightly
    echo -e "${GREEN}✅ XFCE instalado!${NC}"
    echo -e "${YELLOW}Para iniciar:${NC}"
    echo "1. termux-x11 :0 &"
    echo "2. export DISPLAY=:0"
    echo "3. startxfce4 &"
    log "XFCE instalado"
    sleep 3
}


# Função para instalar OpenClaude
install_openclaude() {
    echo -e "${YELLOW}🤖 Instalando OpenClaude...${NC}"
    npm install -g openclaude
    echo -e "${GREEN}✅ OpenClaude instalado! Use: openclaude${NC}"
    log "OpenClaude instalado"
    sleep 2
}


# Função para instalar Gemini CLI
install_gemini() {
    echo -e "${YELLOW}🤖 Instalando Gemini CLI...${NC}"
    npm install -g @google/gemini-cli
    echo -e "${GREEN}✅ Gemini CLI instalado! Use: gemini${NC}"
    log "Gemini CLI instalado"
    sleep 2
}


# Função para instalar Hermes Agent
install_hermes() {
    echo -e "${YELLOW}🤖 Instalando Hermes Agent...${NC}"
    pip install hermes-agent
    echo -e "${GREEN}✅ Hermes Agent instalado!${NC}"
    log "Hermes Agent instalado"
    sleep 2
}


# Função para GitHub Login
github_login() {
    echo -e "${YELLOW}🔐 Configurando GitHub CLI...${NC}"
    pkg install -y gh
    gh auth login
    log "GitHub login configurado"
    sleep 2
}


# Função para gerar chave SSH
generate_ssh() {
    echo -e "${YELLOW}🔑 Gerando chave SSH...${NC}"
    if [ ! -f "$HOME/.ssh/id_rsa" ]; then
        ssh-keygen -t rsa -b 4096 -C "$USER@termux" -f "$HOME/.ssh/id_rsa" -N ""
        echo -e "${GREEN}✅ Chave SSH gerada!${NC}"
        echo -e "${YELLOW}📋 Sua chave pública:${NC}"
        cat "$HOME/.ssh/id_rsa.pub"
    else
        echo -e "${YELLOW}⚠️ Chave SSH já existe!${NC}"
        cat "$HOME/.ssh/id_rsa.pub"
    fi
    log "Chave SSH gerada"
    echo ""
    read -p "Pressione ENTER para continuar..."
}


# Função para clonar repositório
clone_repo() {
    echo -e "${YELLOW}📥 Clonar repositório Git${NC}"
    read -p "Digite a URL do repositório: " repo_url
    if [ ! -z "$repo_url" ]; then
        read -p "Digite o diretório destino (padrão: atual): " dest_dir
        if [ -z "$dest_dir" ]; then
            git clone "$repo_url"
        else
            git clone "$repo_url" "$dest_dir"
        fi
        log "Repositório clonado: $repo_url"
        echo -e "${GREEN}✅ Repositório clonado!${NC}"
    fi
    sleep 2
}


# Função para backup
backup_termux() {
    echo -e "${YELLOW}💾 Fazendo backup do Termux...${NC}"
    backup_dir="$HOME/termux-backup-$(date +%Y%m%d)"
    mkdir -p "$backup_dir"
    
    # Backup de arquivos importantes
    cp -r "$HOME/.termux" "$backup_dir/"
    cp -r "$HOME/.ssh" "$backup_dir/" 2>/dev/null
    cp -r "$HOME/.bashrc" "$backup_dir/" 2>/dev/null
    cp -r "$HOME/.zshrc" "$backup_dir/" 2>/dev/null
    cp -r "$BASE_DIR" "$backup_dir/" 2>/dev/null
    
    # Lista de pacotes instalados
    pkg list-installed > "$backup_dir/packages-list.txt"
    
    # Compactar
    tar -czf "$backup_dir.tar.gz" -C "$HOME" "$(basename "$backup_dir")"
    rm -rf "$backup_dir"
    
    echo -e "${GREEN}✅ Backup criado: $backup_dir.tar.gz${NC}"
    log "Backup realizado"
    sleep 2
}


# Função para informações do sistema
system_info() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}📊 INFORMAÇÕES DO SISTEMA${NC}         ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}🖥️ Sistema Operacional:${NC} $(uname -o)"
    echo -e "${GREEN}🐧 Kernel:${NC} $(uname -r)"
    echo -e "${GREEN}📱 Arquitetura:${NC} $(uname -m)"
    echo -e "${GREEN}🔄 Uptime:${NC} $(uptime | awk '{print $3,$4}' | sed 's/,//')"
    echo -e "${GREEN}💾 Armazenamento:${NC}"
    df -h /data | awk 'NR==2 {print "   Total: "$2" | Usado: "$3" | Livre: "$4" | Uso: "$5}'
    echo -e "${GREEN}🧠 Memória:${NC}"
    free -h | awk 'NR==2 {print "   Total: "$2" | Usado: "$3" | Livre: "$4}'
    echo -e "${GREEN}📦 Pacotes instalados:${NC} $(pkg list-installed 2>/dev/null | wc -l)"
    echo -e "${GREEN}👤 Usuário:${NC} $(whoami)"
    echo -e "${GREEN}🌐 IP Local:${NC} $(ip -4 addr show | grep inet | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -1)"
    echo ""
    read -p "Pressione ENTER para continuar..."
}


# Função para speed test
speed_test() {
    echo -e "${YELLOW}🌐 Teste de velocidade da internet...${NC}"
    pkg install -y speedtest-cli
    speedtest-cli
    log "Teste de velocidade realizado"
    read -p "Pressione ENTER para continuar..."
}


# Função para scanner de portas
port_scanner() {
    echo -e "${YELLOW}🔍 Scanner de portas da rede local${NC}"
    read -p "Digite o IP/Máscara (ex: 192.168.1.0/24): " network
    if [ -z "$network" ]; then
        network="192.168.1.0/24"
    fi
    echo -e "${BLUE}Escaneando...${NC}"
    nmap -sn "$network"
    log "Scanner de portas realizado em $network"
    read -p "Pressione ENTER para continuar..."
}


# Função para gerenciador de projetos
project_manager() {
    while true; do
        clear
        echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${NC} ${BOLD}📂 GERENCIADOR DE PROJETOS${NC}          ${CYAN}║${NC}"
        echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
        echo ""
        echo -e " ${YELLOW}[1]${NC} Listar projetos"
        echo -e " ${YELLOW}[2]${NC} Criar novo projeto"
        echo -e " ${YELLOW}[3]${NC} Abrir projeto no VS Code (code-server)"
        echo -e " ${YELLOW}[4]${NC} Remover projeto"
        echo -e " ${YELLOW}[5]${NC} Voltar ao menu principal"
        echo ""
        read -p "➜ Escolha: " project_option
        
        case $project_option in
            1)
                echo -e "\n${GREEN}📁 Projetos encontrados:${NC}"
                ls -la "$BASE_DIR" 2>/dev/null | grep "^d" | awk '{print "   📂 " $9}'
                ;;
            2)
                read -p "Nome do projeto: " project_name
                mkdir -p "$BASE_DIR/$project_name"
                echo -e "${GREEN}✅ Projeto '$project_name' criado em $BASE_DIR/$project_name${NC}"
                log "Projeto criado: $project_name"
                ;;
            3)
                read -p "Nome do projeto: " project_name
                if [ -d "$BASE_DIR/$project_name" ]; then
                    if command -v code-server &> /dev/null; then
                        code-server "$BASE_DIR/$project_name"
                    else
                        echo -e "${YELLOW}Instalando code-server...${NC}"
                        pkg install -y code-server
                        code-server "$BASE_DIR/$project_name"
                    fi
                else
                    echo -e "${RED}❌ Projeto não encontrado!${NC}"
                fi
                ;;
            4)
                read -p "Nome do projeto para remover: " project_name
                if [ -d "$BASE_DIR/$project_name" ]; then
                    rm -rf "$BASE_DIR/$project_name"
                    echo -e "${GREEN}✅ Projeto removido!${NC}"
                    log "Projeto removido: $project_name"
                else
                    echo -e "${RED}❌ Projeto não encontrado!${NC}"
                fi
                ;;
            5)
                break
                ;;
            *)
                echo -e "${RED}❌ Opção inválida!${NC}"
                ;;
        esac
        echo ""
        read -p "Pressione ENTER para continuar..."
    done
}


# Função para personalizar Termux
customize_termux() {
    echo -e "${YELLOW}🎨 Personalizando Termux...${NC}"
    
    # Criar arquivo de configuração
    cat > "$HOME/.termux/termux.properties" << 'EOF'
# Configuração do Termux
use-black-ui = true
bell-character = ignore
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
EOF
    
    # Adicionar alias úteis
    cat >> "$HOME/.bashrc" << 'EOF'
# Alias personalizados
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias update='pkg update && pkg upgrade'
alias install='pkg install'
alias search='pkg search'
alias projects='cd ~/termux-projects'
EOF
    
    # Recarregar configurações
    termux-reload-settings
    echo -e "${GREEN}✅ Termux personalizado!${NC}"
    echo -e "${YELLOW}Atalhos adicionados: ESC, /, -, HOME, UP, END, PGUP${NC}"
    log "Termux personalizado"
    sleep 2
}


# Função para atualizar todos os projetos
update_all_projects() {
    echo -e "${YELLOW}🔄 Atualizando todos os projetos...${NC}"
    for project in "$BASE_DIR"/*; do
        if [ -d "$project/.git" ]; then
            echo -e "${BLUE}📂 Atualizando $(basename "$project")...${NC}"
            cd "$project"
            git pull
            cd - > /dev/null
        fi
    done
    echo -e "${GREEN}✅ Projetos atualizados!${NC}"
    log "Projetos atualizados"
    sleep 2
}


# Função para status do sistema
system_status() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}📊 STATUS DO SISTEMA${NC}                ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    
    # Verificar serviços
    echo -e "${GREEN}🔍 Serviços em execução:${NC}"
    ps aux | grep -E "sshd|nginx|mysql|redis|docker" | grep -v grep || echo -e "${YELLOW}   Nenhum serviço em execução${NC}"
    
    echo -e "\n${GREEN}📦 Pacotes instalados (últimos 10):${NC}"
    pkg list-installed 2>/dev/null | tail -10
    
    echo -e "\n${GREEN}💾 Uso de armazenamento:${NC}"
    df -h /data
    
    echo -e "\n${GREEN}🧠 Uso de memória:${NC}"
    free -h
    
    echo -e "\n${GREEN}📁 Projetos:${NC}"
    ls -la "$BASE_DIR" 2>/dev/null | grep "^d" | wc -l | xargs echo "   Total: "
    
    echo ""
    read -p "Pressione ENTER para continuar..."
}


# Função para limpar cache
clean_cache() {
    echo -e "${YELLOW}🧹 Limpando cache...${NC}"
    pkg clean
    rm -rf "$HOME/.cache"/*
    rm -rf "$HOME/.npm/_cacache" 2>/dev/null
    rm -rf "$HOME/.local/share/Trash"/* 2>/dev/null
    echo -e "${GREEN}✅ Cache limpo!${NC}"
    log "Cache limpo"
    sleep 2
}


# Função para verificar e instalar dependências
check_dependencies() {
    local missing=()
    for cmd in "$@"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️ Dependências faltando: ${missing[*]}${NC}"
        read -p "Deseja instalá-las? (s/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            pkg install -y "${missing[@]}"
        fi
    fi
}


# Menu principal loop
while true; do
    show_menu
    read option
    
    case $option in
        1)
            echo -e "${YELLOW}🔄 Atualizando Termux...${NC}"
            pkg update -y && pkg upgrade -y
            log "Termux atualizado"
            echo -e "${GREEN}✅ Termux atualizado!${NC}"
            sleep 2
            ;;
        2) install_basic ;;
        3)
            echo -e "${YELLOW}📦 Instalando Git...${NC}"
            pkg install -y git
            log "Git instalado"
            echo -e "${GREEN}✅ Git instalado!${NC}"
            sleep 2
            ;;
        4)
            echo -e "${YELLOW}🐍 Instalando Python...${NC}"
            pkg install -y python python-pip
            log "Python instalado"
            echo -e "${GREEN}✅ Python instalado!${NC}"
            sleep 2
            ;;
        5)
            echo -e "${YELLOW}📦 Instalando Node.js...${NC}"
            pkg install -y nodejs
            log "Node.js instalado"
            echo -e "${GREEN}✅ Node.js instalado!${NC}"
            sleep 2
            ;;
        6) install_docker ;;
        7) install_ubuntu ;;
        8) install_debian ;;
        9) install_xfce ;;
        10) install_openclaude ;;
        11) install_gemini ;;
        12) install_hermes ;;
        13) github_login ;;
        14) generate_ssh ;;
        15) clone_repo ;;
        16) backup_termux ;;
        17) system_info ;;
        18) speed_test ;;
        19) port_scanner ;;
        20) project_manager ;;
        21) customize_termux ;;
        22) update_all_projects ;;
        23) system_status ;;
        24) clean_cache ;;
        0)
            echo -e "${GREEN}👋 Saindo... Até logo!${NC}"
            log "Sessão encerrada"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Opção inválida!${NC}"
            sleep 1
            ;;
    esac
done