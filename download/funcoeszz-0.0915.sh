#!/bin/sh
# .bashzz
# também disponível em:
# http://www.conectiva.com.br/~aurelio/programas/bash/funcoesZZ
#
# DESCRIÇÃO:
# funções de uso geral para bash[12], que buscam informações em
# arquivos locais e dicionários/tradutores na internet
#
# INSTALAÇÃO:
# copie este arquivo para seu diretório "home" e inclua-o na sua shell
#   [prompt]$ cp .bashzz ~
#   [prompt]$ echo . ~/.bashzz >> ~/.bashrc
#
# AS FUNÇÕES:
#   [prompt]$ zz<TAB><TAB>
#   zzajuda          zzdicdict        zzkill         zzsomahora
#   zzbeep           zzdicjarg        zzlimpalixo    zztrocaarquivos
#   zzcalcula        zzdictodos       zzlinux2dos    zztrocaextensao
#   zzdicabl         zzdolar          zzramal        zztrocapalavra
#   zzdicbabel       zzdominiopais    zzrpmdisco
#   zzdicbabi        zzdos2linux      zzrpmdono
#
# DEMONSTRAÇÃO:
#   [prompt]$ zzdicabl estorvo
#     estorvo (ô) s.m. cf. estorvo, do v. estorvar
#     estorvor (ô) s.m.
#   [prompt]$ zzdolar
#            compra venda
#   LIVRE    1,8360 1,8380
#   PARALELO 1,8700 1,9400
#   TURISMO  1,7800 1,8600
#   EURO     1,5827 1,5868
#   [prompt]$ zzdominiopais cx
#     CX Christmas Island
#   [prompt]$ zzrpmdisco /mnt/cdrom/conectiva/RPMS/vim-*
#   7Mb
#   [prompt]$ zzsomahora 12:56 03:31
#   16:27
#   [prompt]$ zzcalcula '11*(2^8+sqrt(16))+0.34'
#   2860.34
#
# OBSERVAÇÕES:
# - funções que fazem busca na internet necessitam que o pacote 'lynx'
#   esteja instalado, ou redefina o $ZZDUMP
# - não copie e cole as funções com o mouse, pois alguns caracteres
#   de controle deixarão de funcionar
#
# AGRADECIMENTOS:
# arnaldo c. de melo, wanderlei cavassin, ademar reis jr., eliphas levy,
# fernando roxo, osvaldo santana neto, rodrigo missiaggia, raul dias
#
# REGISTRO DE MUDANÇAS:
# 20000222 <aurelio@...> ** 1ª versão
# 20000424 <aurelio@...> ++ cores, beep, limpalixo, rpmverdono
# 20000504 <aurelio@...> ++ calcula, jpgi, gifi, trocapalavra
#                                     ++ ajuda, echozz, forzz
# 20000515 <aurelio@...> ++ dominiopais, trocaextensao, kill
#                                     -- jpgi, gifi: o identify já faz
#                                     <> $* > "$@"
# 20000517 <aurelio@...> <> trocapalavra -> basename no $T
# 20000601 <aurelio@...> -- dicbabel: agora com session &:(
# 20000612 <aurelio@...> ++ celulartim, trocaarquivo
# 20000823 <aurelio@...> <> dicjarg: + palavras com
#                                        espaços (valeu wanderlei)
#                                     -- celulartim
# 20000914 <aurelio@...> ++ dicabl, dicdict, dicbabel
#                                     <> nome oficial para .bashzz
#                                     -- dicdic: página fora do ar
# 20000915 <aurelio@...> ++ mini-manual no cabeçalho
#                                     ** 1º anúncio externo


ZZC=1         # colorir mensagens? 1 liga, 0 desliga

ZZDUMP='lynx -dump -nolist'
ZZSEDURL='s| |+|g;s|&|%26|g'
echozz(){ [ "$ZZC" = 1 ] && echo -ne '\033[1m' ; echo -e "$*\033[m" ; }



# ----------------------------------------------------------------------------
# mostra uma tela de ajuda com explicação e sintaxe de todas as funções
# obs.: tátátá, é xunxo. sou preguiçoso sim, e daí &:)
#       não se esqueça de mudar o valor da variável $ZZARQ caso dê pau
# uso: zzajuda
# ----------------------------------------------------------------------------

zzajuda(){
local ZZARQ=$HOME/.bashzz  # a rota completa e nome deste arquivo
sed -n '1s/.*/*** ajuda das funções ZZ para bash (Q sai)/p;2s/.*/ /p;/^$/,${
s_\(\<zz[a-z_2]*\>\)_[1m\1[m_;s/^# //p;}' $ZZARQ | uniq | less -r
}



# #### U M A   L I N H A   /   D I V E R S O S

# ----------------------------------------------------------------------------
# procura um ramal num arquivo local
# troque o /wb/ramais.txt pelo arquivo desejado
# uso: zzramal nome-do-cara
# ----------------------------------------------------------------------------

zzramal(){ [ "$1" ] && grep -i "$*" /wb/ramais.txt ; }


# ----------------------------------------------------------------------------
# restaura o 'beep' da máquina
# se por algum motivo o 'beep' da sua máquina parou de funcionar ou mudou a
# freqüência ou duração, essa função o retorna a seu estado original
# uso: zzbeep
# ----------------------------------------------------------------------------

zzbeep(){ echo -ne '\033[10;750]\033[11;100]' ; }


# ----------------------------------------------------------------------------
# retira linhas em branco e comentários
# para ver rapidamente quais opções estão ativas num arquivo de configuração
# ex.: cat /etc/inittab | zzlimpalixo
# ----------------------------------------------------------------------------

zzlimpalixo(){ sed '\§^[ 	]*\(#\|$\)§d' | uniq ; }


# ----------------------------------------------------------------------------
# mata os processos que tenham o(s) padrão(ões) especificado(s) no nome do
# comando executado que lhe deu origem
# obs.: se quiser assassinar mesmo o processo, coloque a opção -9 no kill
# uso: zzkill padrão [padrão2 ...]
# ex.: zzkill netscape
#      zzkill netsc soffice startx
# ----------------------------------------------------------------------------
zzkill(){ local C P ; for C in "$@" ; do
for P in `ps x --format pid,comm | sed -n "s/^ *\([0-9]\+\) [^ ]*$C.*/\1/p"`
do kill $P ; done ; done
}



# #### A R Q U I V O S   (use por seu próprio risco)

# ----------------------------------------------------------------------------
# encontra o pacote que tem um arquivo ou bilioteca qualquer (demora)
# uso: zzrpmdono arquivo [dir-rpms]
# ex.: zzrpmdono libgd
#      zzrpmdono lilo.conf /tmp/meus-pacotes/
# ----------------------------------------------------------------------------

zzrpmdono(){
[ "$1" ] || { echo 'uso: zzrpmdono arquivo [dir-rpms]'; return; }
local D=/mnt/cdrom/conectiva/RPMS ; [ "$2" ] && D="$2"
for A in $D/*.rpm ; do rpm -qlp $A | grep "$1" && echozz "@ $A" ; done
}


# ----------------------------------------------------------------------------
# conversão de arquivos texto entre DOS e linux
# obs.: o arquivo original é gravado como arquivo.{dos,linux}
# uso: zzdos2linux arquivo(s)
#      zzlinux2dos arquivo(s)
# ----------------------------------------------------------------------------

zzdos2linux(){ local A ; for A in "$@" ; do cp "$A" "$A.dos" && chmod -x $A &&
sed 's/
$//' "$A.dos"   > "$A" && echo "convertido $A" ; done ; }
zzlinux2dos(){ local A ; for A in "$@" ; do cp "$A" "$A.linux" &&
sed 's/$/
/' "$A.linux" > "$A" && echo "convertido $A" ; done ; }


# ----------------------------------------------------------------------------
# troca a extensão de um (ou vários) arquivo especificado
# uso: zztrocaextensao antiga nova arquivo(s)
# ex.: zztrocaextensao .doc .txt *
# ----------------------------------------------------------------------------

zztrocaextensao(){
[ "$3" ] || { echo 'uso: zztrocaextensao antiga nova arquivo(s)'; return; }
local A p1="$1" p2="$2" ; shift ; shift ; for A in "$@" ; do 
[ "$A" != "${A%$p1}" ] && mv -v "$A" "${A%$p1}$p2" ; done
}


# ----------------------------------------------------------------------------
# troca o conteúdo de dois arquivos, mantendo suas permissões originais
# uso: zztrocaarquivos arquivo1 arquivo2
# ex.: zztrocaarquivos /etc/fstab.bak /etc/fstab
# ----------------------------------------------------------------------------

zztrocaarquivos(){
[ "$2" ] || { echo 'uso: zztrocaarquivos arquivo1 arquivo2'; return; }
local at="$HOME/.zztmp"; cat "$2" > $at; cat "$1" > "$2"; cat "$at" > "$1";
rm $at; echo "feito: $1 <-> $2"
}


# ----------------------------------------------------------------------------
# troca uma palavra por outra em um (ou vários) arquivo especificado
# obs.: se quiser que seja insensível a maiúsculas/minúsculas, apenas
#       coloque o modificador 'i' logo após o modificador 'g' no comando sed
#       desligado por padrão
# uso: zztrocapalavra antiga nova arquivo(s)
# ex.: zztrocapalavra excessão exceção *.txt
# ----------------------------------------------------------------------------

zztrocapalavra(){
[ "$3" ] || { echo 'uso: zztrocapalavra antiga nova arquivo(s)'; return; }
local A T p1="$1" p2="$2" ; shift ; shift ; for A in "$@" ; do T=/tmp/${A##*/}
cp $A $T && sed "s§$p1§$p2§g" $T > $A && rm -f $T ; echo "feito $A" ; done
}



# #### C Á L C U L O

# ----------------------------------------------------------------------------
# calculadora: + - / * ^ %    # mais operadores, ver `man bc`
# uso: zzcalcula número operação número
# ex.: zzcalcula 2 / 3
#      zzcalcula '2^2*(4-1)'  # 2 ao quadrado vezes 4 menos 1
# ----------------------------------------------------------------------------

zzcalcula(){ [ "$1" ] && echo "scale=2;$*" | bc ; }


# ----------------------------------------------------------------------------
# soma o espaço em disco que um (ou mais) pacote ocupará quando instalado
# uso: zzrpmdisco pacote(s)
# ex.: zzrpmdisco /mnt/cdrom/conectiva/RPMS/vim-*
# ----------------------------------------------------------------------------

zzrpmdisco(){
[ "$1" ] || { echo 'uso: zzrpmdisco pacotes'; return; } ; local T B r
T=0; for r in $*; do B=`rpm -qp --queryformat %{SIZE} $r`; T=$((T+B)) ; done
T=$((T/1024)); [ $T -ge 1000 ] && echo "$(($T/1024))Mb" || echo ${T}Kb
}


# ----------------------------------------------------------------------------
# soma dois horários
# uso: zzsomahora horário1 horário2
# ex.: zzsomahora 12:37 08:45
# ----------------------------------------------------------------------------

zzsomahora(){
[ "$1" ] || { echo "uso: zzsomahora 12:37 08:45"; return; }
local h1 h2 m1 m2 H M
h1=${1%:*}; m1=${1#*:}; h2=${2%:*}; m2=${2#*:} # $h1:$m1 $h2:$m2
h1=${h1#0}; m1=${m1#0}; h2=${h2#0}; m2=${m2#0} # s/^0//
M=$((m1+m2)); H=$((h1+h2+M/60)); M=$((M%60))   # min, hrs, min_sobra
printf "%02d:%02d\n" $H $M
}



#-----------8<------------daqui pra baixo: FUNÇÕES QUE FAZEM BUSCA NA INTERNET
#-------------------------podem parar de funcionar se mudarem nas páginas


# #### C O T A Ç Ã O   (internet)

# ----------------------------------------------------------------------------
# http://www.agrural.com.br
# busca a cotação do dia do dólar e do euro
# uso: zzdolar
# ----------------------------------------------------------------------------

zzdolar(){
local URL=http://www.agrural.com.br/indicadores/dolar.htm
echozz "         compra venda" ; $ZZDUMP $URL |
sed -n 's/.*\<\([01],[0-9]\{4\}\)\>.*/\1/p' | sed 'N;s/\n/ /' |
sed '1s/^/LIVRE    /;2s/^/PARALELO /;3s/^/TURISMO  /;4s/^/EURO     /'
}



# #### D O M Í N I O S   (internet)

# ----------------------------------------------------------------------------
# http://www.professional.org/user-cgi/pse/domain.pl
# busca a descrição de um código de país da internet (.br, .ca etc)
# uso: zzdominiopais código
# ex.: zzdominiopais .br
#      zzdominiopais org
# ----------------------------------------------------------------------------

zzdominiopais(){
[ "$1" ] || { echo 'uso: zzdominiopais [.]código'; return; }
local URL=http://www.professional.org/user-cgi/pse/domain.pl
local INI='The domain ' ; $ZZDUMP "$URL?domain=${1#.}" |
sed -n "/$INI/,$ {/$INI\|^ *$/d;s/^ */  /p;}"
}




# #### T R A D U T O R E S   e   D I C I O N Á R I O S   (internet)

# ----------------------------------------------------------------------------
# http://babelfish.altavista.digital.com
# faz traduções de palavras/frases/textos em português e inglês
# uso: zzdicbabel [i] texto
# ex.: zzdicbabel my dog is green
#      zzdicbabel i falcão detona!
# ----------------------------------------------------------------------------

zzdicbabel(){
[ "$1" ] || { echo 'uso: zzdicbabel [i] palavra(s)'; return; }
local URL='http://babelfish.altavista.digital.com/raging/translate.dyn'
local L=en_pt INI='^<textarea .* name=q>$' FIM='^<\/textarea>&nbsp;$'
[ "$1" = 'i' ] && { shift; L=pt_en; INI='^ *<textarea .* name=q>$'; }
local TXT=`echo "$*"| sed "$ZZSEDURL"`
lynx -source "$URL?urltext=$TXT&lp=$L" |
sed -n "/$INI/,/$FIM/{/$INI\|$FIM\|^$/d;s/^ */  /p;}"
}


# ----------------------------------------------------------------------------
# http://www.babylon.com
# tradução de palavras em inglês para um monte de idiomas:
# frncês, alemão, japonês, italiano, hebreu, espanhol, holandês e
# português. o padrão é o português, é claro.
# uso: zzdicbabi [idioma] palavra
# ex.: zzdicbabi hardcore
#      zzdicbabi jap tree
# ----------------------------------------------------------------------------

zzdicbabi(){
[ "$1" ] || { echo -e "zzdicbabi [idioma] palavra
  idioma = fre ger jap ita heb spa dut ptg" && return; }
local L=ptg ; [ "$2" ] && L=$1 && shift
$ZZDUMP "http://www.babylon.com/trans/bwt.cgi?$L$1" |
sed '1,4d;s/^ *//;/^\($\|_\+\)/d;s/^/  /'
}


# ----------------------------------------------------------------------------
# http://www.dictionary.com
# definições de palavras em inglês, com pesquisa em *vários* bancos de dados
# uso: zzdicdict palavra
# ex.: zzdicdict hardcore
# ----------------------------------------------------------------------------

zzdicdict(){
[ "$1" ] || { echo "zzdicdict palavra" && return; }
local URL='http://www.dictionary.com/cgi-bin/dict.pl'
local INI='^ *[0-9]\+ entr\(y\|ies\) found.$' FIM='^ *Try your search' 
$ZZDUMP "$URL?db=*&term=$*" | sed -n "/$INI/,/$FIM/{/$INI\|$FIM/d;p;}"
}


## ----------------------------------------------------------------------------
## http://www.dicionario.com.br
## dicionário/tradutor de termos técnicos de informática em inglês
## uso: zzdicdic palavra(s)
## ex.: zzdicdic video card
## ----------------------------------------------------------------------------
#
#zzdicdic(){
#[ "$1" ] || { echo 'uso: zzdicdic palavra'; return; }
#local URL='http://www.dicionario.com.br' INI='Encontrad'
#local FIM='Copyright' TXT=`echo "$*"| sed "$ZZSEDURL"`;
#$ZZDUMP "$URL/cgi-bin/dic.pl?c=$TXT&p=Pesquisa&m=chave" #|
#sed -n "/$INI/,/$FIM/{/$INI\|$FIM/d;s/^ */  /p;}" | sed '1d;$d'
#}


# ----------------------------------------------------------------------------
# http://www.academia.org.br/vocabula.htm
# dicionário da ABL - academia brasileira de letras
# uso: zzdicabl palavra
# ex.: zzdicabl cabeça-de-
# ----------------------------------------------------------------------------

zzdicabl(){
[ "$1" ] || { echo 'uso: zzdicabl palavra'; return; }
local URL='http://www.mtec.com.br/cgi-bin/abl/volta_abl_org.asp'
echo "palavra=$*" | $ZZDUMP -post-data $URL | sed '1,5d;/^ *\./,$d;s/^ */  /'
}


# ----------------------------------------------------------------------------
# http://www.techfak.uni-bielefeld.de/~joern/jargon
# dicionários de jargões de informática, em inglês
# uso: zzdicjarg palavra
# ex.: zzdicjarg vi
# ----------------------------------------------------------------------------

zzdicjarg(){
[ "$1" ] || { echo 'uso: zzdicjarg palavra'; return; }
local TXT=`echo "$*" | sed 's/ /-/g'`
$ZZDUMP http://www.tuxedo.org/~esr/jargon/html/entry/$TXT.html |
sed '1,3d;/ \{5\}_\+/,$d;s/^ */  /'
}


# ----------------------------------------------------------------------------
# usa todas as funções de dicionário e tradução de uma vez
# uso: zzdictodos palavra
# ex.: zzdictodos Linux
# ----------------------------------------------------------------------------
zzdictodos(){
[ "$1" ] || { echo 'uso: zzdictodos palavra'; return; } ; local D
for D in babel babi jarg abl dict ; do echozz "zzdic$D:" ; zzdic$D $1 ; done
}
