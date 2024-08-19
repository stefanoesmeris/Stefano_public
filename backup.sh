#!/bin/bash
#
# Todos os compartilhamentos a serem acessados e copiados precisam estar definidos no arquivo
#  /etc/auto.banco
#
# Para que este script funcione, algumas dependencias de pacotes precisam ser satisfeitas.
# Instale o seguinte conjunto de pacotes:
# apt install autofs rsync smbclient cifs-utils
# ATENCAO NAO DEIXE O ARQUIVO /etc/auto.server COM PERMISOES DE EXECUCAO !!!!
# chmod 644 /etc/auto.banco
#
#
#Data
DATA=$(date +%Y-%b-%d)
#Numero que representa a semana no Ano
SEMANA=$(date +%W)
#Dia da semana
#DIA=$(date +%A)
DIA=""
#BASEDIR='/mnt/banco/'


# Inicializa variáveis para as opções
a_flag=""
b_flag=""
d_flag=0
BASEDIR=""
FILE=""

# Processa as opções
while getopts "f:b:d" opt; do
  case $opt in
    f)
      f_flag="$OPTARG"
      ;;
    b)
      b_flag="$OPTARG"
      ;;
    d)
      # espera pegar o parametro d para --delete do rsync
      d_flag=1
      ;;
    \?)
      echo "Opção inválida: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Opção -$OPTARG requer um argumento." >&2
      exit 1
      ;;
  esac
done

# Verifica se as opções foram fornecidas
if [ -z "$f_flag" ]; then
    echo -e "A opção -f não foi fornecida. \n Especifique o arquivo do autofs a ser usado.\n Ex: backup -f /etc/auto.server "
    exit 1
fi

if [ -z "$b_flag" ]; then
    echo "A opção -b não foi fornecida."
    DIA=$(date +%A)
else
    DIA=$b_flag
fi


# Mostra os valores das opções fornecidas
#echo "Opção -f foi utilizada com o valor: $f_flag e DIA $DIA"
#echo "Opção -b foi utilizada com o valor: $b_flag"
#echo "Opção -d foi utilizada com o valor: $d_flag"

# Função para verificar e modificar o arquivo de log
verifica_arquivo() {
    local arquivo="$1"
    local linhas_maximas=1500
    local linhas_corte=1200

    # Verifica se o arquivo existe
    if [ ! -e "$arquivo" ]; then
        # Se o arquivo não existe, cria o arquivo
        touch "$arquivo"
    fi

    # Verifica se o arquivo tem pelo menos uma linha
    if [ ! -s "$arquivo" ]; then
        # Se o arquivo está vazio, adiciona uma linha com a data/hora e o texto
        echo "Iniciando arquivo em: $(date)" >> "$arquivo"
    fi
    # Verifica se o arquivo tem mais de 1500 linhas
    local num_linhas
    num_linhas=$(wc -l < "$arquivo")

    if [ "$num_linhas" -gt "$linhas_maximas" ]; then
        # Se o arquivo tem mais de 1500 linhas, preserva as 1200 primeiras e descarta o restante
        head -n "$linhas_corte" "$arquivo" > "${arquivo}.tmp"
        mv "${arquivo}.tmp" "$arquivo"
    fi

}


calculo () {
        HOURS=$(( $1 / 3600 ))
        MINUTES=$(( ($1 - $HOURS * 3600) / 60 ))
        SECONDS=$(( $1 % 60 ))
        echo "Total: ${HOURS}H:${MINUTES}M:${SECONDS}s."
}

copiar_dados () {
        ls $BASEDIR/$1 > /dev/null
        sleep 2
        if grep -qs $BASEDIR/$1 /proc/mounts; then
            echo " $1 Foi montado com sucesso, procedendo com a copia."
            INICIO=$(date +%Y-%b-%d' '%H:%M)
            INI_TMP=$(date +%s)
            mkdir -p /var/www/html/backup/$DIA
            mkdir -p /var/www/html/backup/$DIA/$1/
            touch -am  /var/www/html/backup/$DIA/$1/
            if [ $d_flag -eq 1 ]; then
         	rsync -vaxE --delete $BASEDIR/$1/  /var/www/html/backup/$DIA/$1/
            else
        	rsync -vaxE  $BASEDIR/$1/  /var/www/html/backup/$DIA/$1/
            fi
            #
            FINAL=$(date +%Y-%b-%d' '%H:%M)
            FIM=$(date +%s)
            Z=$(( $FIM - $INI_TMP ))
            TOTAL=$( calculo $Z )
            verifica_arquivo /var/www/html/backup/backup_log_ok.txt
            sed -i "1 i $DATA Backup do $1 de $DIA iniciado em $INICIO e concluido em $FINAL $TOTAL" /var/www/html/backup/backup_log_ok.txt
            sleep 2
        else
            verifica_arquivo /var/www/html/backup/backup_log_erros.txt
            sed -i "1 i $DATA Falha no Backup do $1 de $DIA em $(date) " /var/www/html/backup/backup_log_erros.txt

        fi

}


# Função para validar linhas do arquivo de configuração do automount/autofs
function validar_linhas_automount {
    local arquivo=$1
    local -a linhas_validas=()

    # Ler o arquivo linha por linha
    while IFS= read -r linha; do
        # Remover espaços em branco no início e no fim da linha
        linha=$(echo "$linha" | sed 's/^[ \t]*//;s/[ \t]*$//')

        # Ignorar linhas em branco ou que começam com '#'
        if [[ -z "$linha" || "$linha" == \#* ]]; then
            continue
        fi

        # Verificar se a linha segue o formato esperado: key [-options] location
        if [[ "$linha" =~ ^[^[:space:]]+[[:space:]]+(-[^[:space:]]+[[:space:]]+)?[^[:space:]]+ ]]; then
            linhas_validas+=("$linha")
        fi
    done < "$arquivo"

    # Retornar a lista dos compartilhamentos válidos
    for linha in "${linhas_validas[@]}"; do
        echo $linha | awk {'print $1'}
    done
}

function  validar_basedir {
    local arquivo=$1
    local basedir=""
    local arquivo=""
    basedir=$(cat /etc/auto.master | grep $1 | awk {'print $1'})
    if [ -z "$basedir" ]; then
         echo -e "Arquivo $1 nao encontrado na configuracao do autofs em /etc/auto.master\n"
         exit 1
    else
         BASEDIR=$basedir
         FILE=$(cat /etc/auto.master | grep $1 | awk {'print $2'})
    fi
}


validar_basedir $f_flag


# Chamar a função com o arquivo de configuração como argumento
COMPARTILHAMENTOS=$(validar_linhas_automount $FILE) #Busca no arquivo do autofs os compartilhamentos configurados para a realizacao do backup.



for X in $COMPARTILHAMENTOS
    do
    #echo -e "ls $BASEDIR/$X \n"
    copiar_dados $X
    done
