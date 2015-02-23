#!/bin/bash
# funcoeszz --- http://verde666.org/zz
# vim: noet noai tw=78
#
# INFORMA��ES: http://verde666.org/zz 
# NASCIMENTO : 22 fevereiro 2000
# AUTOR      : aur�lio marinho jargas <aurelio@verde666.org>
# DESCRI��O  : fun��es de uso geral para bash[12], que buscam informa��es em
#              arquivos locais e dicion�rios/tradutores/fontes na internet
#
# REGISTRO DE MUDAN�AS:
# 20000222 ** 1� vers�o
# 20000424 ++ cores, beep, limpalixo, rpmverdono
# 20000504 ++ calcula, jpgi, gifi, trocapalavra, ajuda, echozz, forzz
# 20000515 ++ dominiopais, trocaextensao, kill, <> $* > "$@"
#          -- jpgi, gifi: o identify j� faz
# 20000517 <> trocapalavra -> basename no $T
# 20000601 -- dicbabel: agora com session &:(
# 20000612 ++ celulartim, trocaarquivo
# 20000823 <> dicjarg: + palavras com espa�os, -- celulartim
# 20000914 ++ dicabl, dicdict, dicbabel, <> nome oficial: .bashzz
#          -- dicdic: p�gina fora do ar
# 20000915 ++ mini-manual no cabe�alho, bugzilla, getczz, ZZPOST
#    !!    ** 1� an�ncio externo
# 20000920 ++ freshmeat, ZZWWWHTML, <> ZZDUMP -> ZZWWWDUMP (idem ZZPOST)
#          <> ZZWWW*: -crawl -width -aacookies, <> bugzilla: sa�da +limpa
#          <> kill: mostra n�m do processo
# 20001108 <> dic: babi->babylon, jarg->jargon, babel->babelfish
#          ++ dicmichaelis, ++ cep
# 20001230 ++ cep: TipoPesquisa=, <> cabe�alho == /bin/bash, ++ cinclude
#          ++ dolar: mostra data e trata acima de R$ 2 (triste realidade)
# 20010214 ++ detran
# 20010314 <> dominiopais: URL nova, pesquisa local, procura c�digo ou nome
#          <> freshmeat: atualizada
# 20010320 <> bugzilla: ++UNCONFIRMED, product: Conectiva Linux
# 20010322 <> bugzilla: status entre ()
# 20010713 <> babelfish: re-re-arrumado, jargon: quebra 72 colunas
# 20010717 <> trocaextensao: /usr/bin/rename, /tmp/zz<arquivo>.$$
#          ++ arrumanome, ++ diffpalavra
# 20010724 ++ ramones, <> dicdict: atualizado
# 20010801 <> calcula: entrada/sa�da com v�rgulas
# 20010808 ++ dicasl, -- ramal (palha)
# 20010809 ++ irpf (valeu stulzer), <> detran -> detranpr
#          <> dicjargon: agora local e www (t� BLOAT Kra!!!)
# 20010820 <> dicdict: sa�da em 72 colunas, <> detranpr: mais dados
#          <> cep: URL nova
# 20010823 ++ ZZTMP (andreas chato &:) )
#    !!    ** funcoeszz agora � um pacote do Conectiva Linux
# 20010828 ++ maiores, <> dicmichaelis: simplificado
# 20011001 ++ chavepgp (valeu missiaggia)
# 20011002 <> limpalixo: aceita $1 tamb�m, ++ /usr/bin/funcoeszz (valeu gwm)
#          <> dolar: URL nova, formato novo (valeu bruder)
# 20011015 <> arrumanome: s/^-/_/, mv -v --
# 20011018 <> "$@" na chamada do execut�vel (++aspas) 
# 20011108 <> dolar: formato melhorado
# 20011113 ++ cores
# 20011211 <> freshmeat: mudan�a no formato (�), ++ detransp (valeu elton)
#          ++ $ZZER{DATA,HORA}
# 20011217 ++ noticiaslinux, whoisbr (valeu mar�al)
# 20020107 ++ zzzz, $ZZPATH, --version
# 20020218 ++ fun��o tempor�ria casadosartistas &:)
#    !!    ** p�gina da fun��es em http://verde666.org/zz
# 20020219 ++ tv
# 20020222 <> cep: n�mero do CEP, ++ sigla (valeu thobias)
# 20020226 <> s/registrobr/whoisbr/ na ajuda (valeu graebin)
# 20020228 ++ rpmfind (valeu thobias), s/==/=/ pro bash1 (valeu kall�s)

#


ZZC=1         # colorir mensagens? 1 liga, 0 desliga

ZZWWWDUMP='lynx -dump      -nolist -crawl -width=300 -accept_all_cookies'
ZZWWWPOST='lynx -post-data -nolist -crawl -width=300 -accept_all_cookies'
ZZWWWHTML='lynx -source'
ZZTMP="${TMPDIR:-/tmp}/zz"

# se voc� colocar as fun��es em outro lugar, redefina o ZZPATH
ZZPATH="$0"; [ "${0%bash}" != "$0" ] && ZZPATH=/usr/bin/funcoeszz

ZZERDATA='[0-9]\{2\}\/[0-9]\{2\}\/[0-9]\{4\}'; # dd/mm/aaa ou mm/dd/aaaa
ZZERHORA='[012][0-9]:[0-9]\{2\}';

ZZSEDURL='s| |+|g;s|&|%26|g'
echozz(){ [ "$ZZC" = 1 ] && echo -ne '\033[1m'; echo -e "$*\033[m"; }
getczz(){ stty raw; eval $1="`dd bs=1 count=1 2>&-`"; stty cooked; }


# ----------------------------------------------------------------------------
# mostra uma tela de ajuda com explica��o e sintaxe de todas as fun��es
# obs.: t�t�t�, � xunxo. sou pregui�oso sim, e da� &:)
# uso: zzajuda
# ----------------------------------------------------------------------------
zzajuda(){
sed -n '1s/.*/*** ajuda das fun��es ZZ (tecla Q sai)/p;2g;2p;/^# -\+$/,${
s,\(\<zz[a-z2]\+\>\),[1m\1[m,;s/^# //p;}' $ZZPATH | uniq | less -r
}


# ----------------------------------------------------------------------------
# mostra informa��es (como vers�o e localidade) sobre as fun��es
# uso: zzzz
# ----------------------------------------------------------------------------
zzzz(){
echo "local : $ZZPATH"; [ -f "$ZZPATH" ] && { echo -n 'vers�o: ' 
sed '/^$/{g;q;};/^# 200./!d;s/^# ...\(.\)\(....\).*/\1.\2/;h;d' $ZZPATH; }
echo 'lista : zztabtab@yahoogrupos.com.br'
echo 'p�gina: http://verde666.org/zz'
}


# #### D I V E R S O S

# ----------------------------------------------------------------------------
# restaura o 'beep' da m�quina
# se por algum motivo o 'beep' da sua m�quina parou de funcionar ou mudou a
# freq��ncia ou dura��o, essa fun��o o retorna a seu estado original
# uso: zzbeep
# ----------------------------------------------------------------------------
zzbeep(){ echo -ne '\033[10;750]\033[11;100]'; }


# ----------------------------------------------------------------------------
# retira linhas em branco e coment�rios
# para ver rapidamente quais op��es est�o ativas num arquivo de configura��o
# uso: zzlimpalixo [arquivo]
# ex.: zzlimpalixo /etc/inittab
#      cat /etc/inittab | zzlimpalixo
# ----------------------------------------------------------------------------
zzlimpalixo(){
local a="$1"; sed '/^[	 ]*\(#\|$\)/d' "${a:-/dev/stdin}" | uniq
}


# ----------------------------------------------------------------------------
# mata os processos que tenham o(s) padr�o(�es) especificado(s) no nome do
# comando executado que lhe deu origem
# obs.: se quiser assassinar mesmo o processo, coloque a op��o -9 no kill
# uso: zzkill padr�o [padr�o2 ...]
# ex.: zzkill netscape
#      zzkill netsc soffice startx
# ----------------------------------------------------------------------------
zzkill(){ local C P; for C in "$@"; do
for P in `ps x --format pid,comm | sed -n "s/^ *\([0-9]\+\) [^ ]*$C.*/\1/p"`
do kill $P && echo -n "$P "; done; echo; done
}


# ----------------------------------------------------------------------------
# mostra todas as combina��es de cores poss�veis no console, juntamente com
# os respectivos c�digos ANSI para obt�-las
# uso: zzcores
# ----------------------------------------------------------------------------
zzcores(){
local frente fundo bold c
for frente in 0 1 2 3 4 5 6 7; do for bold in '' ';1'; do
  for fundo in 0 1 2 3 4 5 6 7; do
    c="4$fundo;3$frente"; echo -ne "\033[$c${bold}m $c${bold:-  } \033[m"
  done; echo
done; done
}



# #### A R Q U I V O S

# ----------------------------------------------------------------------------
# encontra o pacote que tem um arquivo ou bilioteca qualquer (demora)
# uso: zzrpmdono arquivo [dir-rpms]
# ex.: zzrpmdono libgd
#      zzrpmdono lilo.conf /tmp/meus-pacotes/
# ----------------------------------------------------------------------------
zzrpmdono(){
[ "$1" ] || { echo 'uso: zzrpmdono arquivo [dir-rpms]'; return; }
local D=/mnt/cdrom/conectiva/RPMS ; [ "$2" ] && D="$2"
for A in $D/*.rpm; do rpm -qlp $A | grep "$1" && echozz "@ $A"; done
}


# ----------------------------------------------------------------------------
# convers�o de arquivos texto entre DOS e linux
# obs.: o arquivo original � gravado como arquivo.{dos,linux}
# uso: zzdos2linux arquivo(s)
#      zzlinux2dos arquivo(s)
# ----------------------------------------------------------------------------
zzdos2linux(){ local A; for A in "$@"; do cp "$A" "$A.dos" && chmod -x $A &&
sed 's/$//' "$A.dos"   > "$A" && echo "convertido $A"; done; }
zzlinux2dos(){ local A; for A in "$@"; do cp "$A" "$A.linux" &&
sed 's/$//' "$A.linux" > "$A" && echo "convertido $A"; done; }


# ----------------------------------------------------------------------------
# troca a extens�o de um (ou v�rios) arquivo especificado
# uso: zztrocaextensao antiga nova arquivo(s)
# ex.: zztrocaextensao .doc .txt *
# ----------------------------------------------------------------------------
zztrocaextensao(){
local ren=/usr/bin/rename ; [ -x $ren ] && { echo "use o $ren &:)"; return; }
[ "$3" ] || { echo 'uso: zztrocaextensao antiga nova arquivo(s)'; return; }
local A p1="$1" p2="$2"; shift 2; for A in "$@"; do
[ "$A" != "${A%$p1}" ] && mv -v "$A" "${A%$p1}$p2"; done
}


# ----------------------------------------------------------------------------
# troca o conte�do de dois arquivos, mantendo suas permiss�es originais
# uso: zztrocaarquivos arquivo1 arquivo2
# ex.: zztrocaarquivos /etc/fstab.bak /etc/fstab
# ----------------------------------------------------------------------------
zztrocaarquivos(){
[ "$2" ] || { echo 'uso: zztrocaarquivos arquivo1 arquivo2'; return; }
local at="$ZZTMP.$$"; cat "$2" > $at; cat "$1" > "$2"; cat "$at" > "$1"
rm $at; echo "feito: $1 <-> $2"
}


# ----------------------------------------------------------------------------
# troca uma palavra por outra em um (ou v�rios) arquivo especificado
# obs.: se quiser que seja insens�vel a mai�sculas/min�sculas, apenas
#       coloque o modificador 'i' logo ap�s o modificador 'g' no comando sed
#       desligado por padr�o
# uso: zztrocapalavra antiga nova arquivo(s)
# ex.: zztrocapalavra excess�o exce��o *.txt
# ----------------------------------------------------------------------------
zztrocapalavra(){
[ "$3" ] || { echo 'uso: zztrocapalavra antiga nova arquivo(s)'; return; }
local A T p1="$1" p2="$2"; shift 2; for A in "$@"; do T=$ZZTMP${A##*/}.$$
cp $A $T && sed "s�$p1�$p2�g" $T > $A && rm -f $T; echo "feito $A"; done
}


# ----------------------------------------------------------------------------
# renomeia arquivos do diret�rio atual, arrumando nomes estranhos.
# obs.: ele deixa tudo em min�sculas, retira acentua��o e troca espa�os em
#       branco, s�mbolos e pontua��o pelo sublinhado _
# uso: zzarrumanome arquivo(s)
# ex.: zzarrumanome *
#      zzarrumanome "DOCUMENTO MAL�O!.DOC"       # fica documento_malao_.doc
#      zzarrumanome "RAMONES - I Don't Care"     # fica ramones_-_i_don_t_care
# ----------------------------------------------------------------------------
zzarrumanome(){
[ "$1" ] || { echo 'uso: zzarrumanome arquivo(s)'; return; }
local A A1 A2 D; for A in "$@"; do [ -f "$A" ] || continue;
A1="${A##*/}"; D="${A%/*}/"; A2=`echo $A1 | sed '
y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/;s/^-/_/;
y/��������������������������/aaaaaaaaeeeeiioooooouuccnn/;s/[^a-z0-9._-]/_/g'`
[ "$A1" != "$A2" ] && mv -v -- "$A" "${D%$A/}$A2"; done
}


# ----------------------------------------------------------------------------
# mostra a diferen�a entre dois textos, mas no contexto de palavras.
# �til para conferir revis�es ortogr�ficas ou mudan�as pequenas em frases.
# obs.: se tiver muitas _linhas_ diferentes o diff normal � aconselhado.
# uso: zzdiffpalavra arquivo1 arquivo2
# ex.: zzdiffpalavra texto-orig.txt texto-novo.txt
#      zzdiffpalavra txt1 txt2 | vi -            # sa�da com sintaxe colorida
# ----------------------------------------------------------------------------
zzdiffpalavra(){
[ "$2" ] || { echo 'uso: zzdiffpalavra arquivo1 arquivo2'; return; }
local split='s/$//;s/^/���\n/;s/ /\n/g' at1="$ZZTMP${1##*/}.$$"
local at2="$ZZTMP${2##*/}.$$"; sed "$split" $1 >$at1; sed "$split" $2 >$at2
diff -u100 $at1 $at2 | cat - -E | sed '4,${s/^+/�/;s/^-/�/;};s/$$/�/' |
tr -d '\012' | sed 's/\(��[^�]*\)\+/\n&\n/g;s/\(��[^�]*\)\+/&\n/g;
s/\(� [^�]*\)\(\(��[^�]*\)\+\)/\1\n\2/g;s/�/\n/3;s/�/\n/2;s/�/\n/1;s/�//g;
s/\n�/\n+/g;s/\n�/\n-/g;s/[��]/ /g;s/\n\? \?���\n\?/\n/g'; rm $at1 $at2
}


# ----------------------------------------------------------------------------
# acha as fun��es de uma biblioteca da linguagem C (arquivos .h)
# obs.: o diret�rio padr�o de procura � o /usr/include
# uso: zzcinclude
# ex.: zzcinclude stdio
#      zzcinclude /minha/rota/alternativa/stdio.h
# ----------------------------------------------------------------------------
zzcinclude(){
[ "$1" ] || { echo "uso: zzcinclude nome-biblioteca"; return; }
local i="$1"; [ "${i#/}" = "$i" ] && i="/usr/include/$i.h"
[ -f $i ] || { echo "$i n�o encontrado" ; return; } ; cpp -E $i |
sed '/^ *$/d;/^\(#\|typedef\) /d;/^[^a-z]/d;s/ *(.*//;s/.* \*\?//' | sort
}


# ----------------------------------------------------------------------------
# acha os 15 maiores arquivos/diret�rios do diret�rio atual (ou especificados)
# uso: zzmaiores [dir1 dir2 ...]
# ex.: zzmaiores
#      zzmaiores /etc /tmp
# ----------------------------------------------------------------------------
zzmaiores(){
local d; if [ "$2" ]; then d=`echo $* | sed 's/^/{/;s/$/}/;s/ \+/,/'`
elif [ "$1" ]; then d="$1"; else d=.; fi
du -s `eval echo $d/{*,.[^.]*}` 2>/dev/null | sort -nr | sed 15q
}


# #### C � L C U L O

# ----------------------------------------------------------------------------
# calculadora: + - / * ^ %    # mais operadores, ver `man bc`
# obs.: n�meros fracionados podem vir com v�rgulas ou pontos: 1,5 ou 1.5
# uso: zzcalcula n�mero opera��o n�mero
# ex.: zzcalcula 2,1 / 3,5
#      zzcalcula '2^2*(4-1)'  # 2 ao quadrado vezes 4 menos 1
# ----------------------------------------------------------------------------
zzcalcula(){ [ "$1" ] && echo "scale=2;$*" | sed y/,/./ | bc | sed y/./,/ ; }


# ----------------------------------------------------------------------------
# soma o espa�o em disco que um (ou mais) pacote ocupar� quando instalado
# uso: zzrpmdisco pacote(s)
# ex.: zzrpmdisco /mnt/cdrom/conectiva/RPMS/vim-*
# ----------------------------------------------------------------------------
zzrpmdisco(){
[ "$1" ] || { echo 'uso: zzrpmdisco pacotes'; return; }; local T B r
T=0; for r in $*; do B=`rpm -qp --queryformat %{SIZE} $r`; T=$((T+B)); done
T=$((T/1024)); [ $T -ge 1000 ] && echo "$(($T/1024))Mb" || echo ${T}Kb
}


# ----------------------------------------------------------------------------
# soma dois hor�rios
# uso: zzsomahora hor�rio1 hor�rio2
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



#-----------8<------------daqui pra baixo: FUN��ES QUE FAZEM BUSCA NA INTERNET
#-------------------------podem parar de funcionar se as p�ginas mudarem


# #### C O N S U L T A S                                         (internet)

# ----------------------------------------------------------------------------
# http://br.invertia.com
# busca a cota��o do dia do d�lar (comercial, paralelo e turismo)
# obs.: as cota��es s�o atualizadas de 10 em 10 minutos
# uso: zzdolar
# ----------------------------------------------------------------------------
zzdolar(){
$ZZWWWDUMP 'http://br.invertia.com/mercados/divisas/tiposdolar.asp' |
sed 's/^ *//;/^Dolar \|Data: /!d;s///;s/ \+..:.*//;
     s/^C�m.* \(.*\)/\1 compra venda/;s|^[1-9]/|0&|;
     s/al /&  /;s/lo /&   /;s/mo /&    /;
     s/\(\.[0-9][0-9]\)\( \|$\)/\10 /g'
}


# ----------------------------------------------------------------------------
# http://www.receita.fazenda.gov.br
# consulta os lotes de restitui��o do imposto de renda
# uso: zzirpf n�mero-cpf
# ex.: zzirpf 123.456.789-69
# ----------------------------------------------------------------------------
zzirpf(){
[ "$1" ] || { echo 'uso: zzirpf n�mero-cpf'; return; }
local URL='http://www.receita.fazenda.gov.br/Scripts/srf/irpf/2001'
$ZZWWWDUMP "$URL/irpf2001.dll?VerificaDeclaracao&CPF=$1" |
sed '1,8d;s/^ */  /;/^  \[BUTTON\]$/d'
}


# ----------------------------------------------------------------------------
# http://www.terra.com.br/cep
# busca o CEP de qualquer rua de qualquer cidade do pa�s ou vice-versa
# uso: zzcep cidade nome-da-rua  OU  zzcep CEP
# ex.: zzcep curitiba rio gran
#      zzcep 'Rio de Janeiro' Vinte de
#      zzcep 80620-150
# ----------------------------------------------------------------------------
zzcep(){
[ "$1" ] || { echo 'uso: zzcep cidade nome-da-rua  OU  zzcep CEP'; return; }
local r c q="_textCEP=$1&_b_cep.x=1" ; [ "$2" ] && {
c=`echo "$1"| sed "$ZZSEDURL"`; shift; r=`echo "$*"| sed "$ZZSEDURL"`
q="_textCidade=$c&_textRua=$r&_b_r_c.x=1&_b_r_c.x=0&_b_r_c.y=0"; }
echo "$q" | $ZZWWWPOST 'http://www.terra.com.br/cep/ceps.cgi' | sed '1,2d;$d;
s/^ *//;/^Mapas (opcional):$/{N;N;d;};/^\[USEMAP:modo\.gif\]$/{N;d;};s/^/  /'
}


# ----------------------------------------------------------------------------
# http://www.pr.gov.br/detran
# consulta d�bitos do ve�culo, como licenciamento, IPVA e multas (detran-PR)
# uso: zzdetranpr n�mero-renavam
# ex.: zzdetranpr 123456789
# ----------------------------------------------------------------------------
zzdetranpr(){
[ "$1" ] || { echo 'uso: zzdetranpr n�mero-renavam'; return; }
local URL='http://celepar7.pr.gov.br/detran/consultas/veiculos/deb_novo.asp';
$ZZWWWDUMP "$URL?renavam=$1" | sed 's/^  *//;/^\(___*\)\?$/d; /^\[/d;
1,/^\(Renavam\|Data\):/{//!d;}; /^Resumo das Multas\|^Voltar$/,$d;
/^AUTUA�/,${/^Infra��o:/!d;s///;}; /^\(Discrimi\|Informa\)/s/.*//;
/^Placa/s/^[^:]*: \([A-Z0-9-]\+\).*:/\1 ano/; /^\(Marca\|Munic\)/s/[^:]*: //;
s|^\(.*\) \([0-9]\+,[0-9]\{2\}\|\*\*\* QUITADO \*\*\*\)|\2 \1|;'
}

# ----------------------------------------------------------------------------
# http://www.detran.sp.gov.br
# consulta d�bitos do ve�culo, como licenciamento, IPVA e multas (detran-SP)
# uso: zzdetransp n�mero-renavam
# ex.: zzdetransp 123456789
# ----------------------------------------------------------------------------
zzdetransp(){
[ "$1" ] || { echo 'uso: zzdetransp n�mero-renavam'; return; }
local URL='http://sampa5.prodam.sp.gov.br/multas/c_multas.asp'; echo
echo "text1=$1" | $ZZWWWPOST "$URL" | sed 's/^ *//;/^Resultado/,/^�ltima/!d;
/^___\+$/s/.*/_____/; /^Resultado/s/.* o Ren/Ren/;
/^Seq /,/^Total/{/^Seq/d;/^Total/!s/^/+++/;};
/�ltima/{G;s/\n//;s/\n_____\(\n\)$/\1/;s/^[^:]\+/Data   /;p;};H;d' |
sed '/^+++/{H;g;s/^\(\n\)+++[0-9]\+ \(...\)\(....\) \([^ ]\+ \)\{2\}\(.*\) \('$ZZERDATA' '$ZZERHORA'\) \(.*\) \('$ZZERDATA' .*\)/Placa: \2-\3\nData : \6\nLocal: \7\nInfr.: \5\nMulta: \8\n/;}'
}



# #### P R O G R A M A S                                         (internet)

# ----------------------------------------------------------------------------
# http://freshmeat.net
# procura por programas na base do freshmeat
# uso: zzfreshmeat programa
# ex.: zzfreshmeat tetris
# ----------------------------------------------------------------------------
zzfreshmeat(){
[ "$1" ] || { echo 'uso: zzfreshmeat programa'; return; }
local dump=`echo $ZZWWWDUMP| sed 's/-nolist\|-crawl//g'`
$dump "http://freshmeat.net/search/?q=$1" |
sed -n '/^ *� Copyright/,${s,^.* ,,;\|meat\.net/projects/|s,/$,,gp;}' | uniq
}


# ----------------------------------------------------------------------------
# http://distro.conectiva.com.br/bugzilla
# procura por entradas de um pacote no bugzilla do Conectiva Linux
# uso: zzbugzilla [-v] pacote
# ex.: zzbugzilla kernel
#      zzbugzilla -v kernel
# ----------------------------------------------------------------------------
zzbugzilla(){
[ "$1" ] || { echo 'uso: zzbugzilla [-v] pacote'; return; }
local stat prod b='bug_status' URL='http://distro.conectiva.com.br/bugzilla'
stat="$b=NEW&$b=ASSIGNED&$b=REOPENED&$b=UNCONFIRMED"
prod='product=Conectiva+Linux'
if [ "$1" != '-v' ]; then
  $ZZWWWDUMP "$URL/buglist.cgi?$stat&component=$1&$prod" | sed -n '
    /^ *ID/,/^ *$/{s/^ *//;/^ID/d;s/ \{7\}//;s/ASSI\|NEW\|UNCO\|REOP/(&)/
    s/conectiva\.com\.br/-cnc/;s/^\([^ ]\+ *\).\{12\}/  \1/p;}'
else
  $ZZWWWHTML "$URL/buglist.cgi?$stat&component=$2" | sed -n '
    s/^<INPUT .*=buglist VALUE=\([0-9:]*\)>/buglist=\1/p' |
  $ZZWWWPOST "$URL/long_list.cgi" | sed -n '
    /^ *Bug#:/,/^ *____/{s/^ *//;/^Resolution:/s/@conectiva.com.br//g
    /^\(Component\|Description\):/d;s/ Additional Comments From / /
    /^URL: $/d;/^___/{s/^\(_\{40\}\)_*/\1/;G;};p;}'
fi
}


# ----------------------------------------------------------------------------
# http://rpmfind.net/linux
# procura por pacotes RPM em v�rias distribui��es
# obs.: a arquitetura padr�o de procura � a i386
# uso: zzrpmfind pacote [distro] [arquitetura]
# ex.: zzrpmfind sed
#      zzrpmfind lilo mandr i586 
# ----------------------------------------------------------------------------
zzrpmfind(){
[ "$1" ] || { echo 'uso: zzrpmfind pacote [distro] [arquitetura]'; return; }
local dump=`echo $ZZWWWDUMP| sed 's/-nolist\|-crawl//g'`
local URL='http://rpmfind.net/linux/rpm2html/search.php'
echozz 'ftp://rpmfind.net/linux/'
$dump "$URL?query=$1&submit=Search+...&system=$2&arch=${3:-i386}" |
sed -n '\,ftp://rpmfind,s,^[^A-Z]*/linux/,  ,p' | sort
}



# #### D I V E R S O S                                           (internet)

# ----------------------------------------------------------------------------
# http://www.iana.org/cctld/cctld-whois.htm
# busca a descri��o de um c�digo de pa�s da internet (.br, .ca etc)
# obs.: o sed deve suportar o I de ignorecase na pesquisa
# uso: zzdominiopais [.]c�digo|texto
# ex.: zzdominiopais .br
#      zzdominiopais br
#      zzdominiopais republic
# ----------------------------------------------------------------------------
zzdominiopais(){
[ "$1" ] || { echo 'uso: zzdominiopais [.]c�digo|texto'; return; }
local i1 i2 a='/usr/share/zoneinfo/iso3166.tab' p=${1#.}
[ $1 != $p ] && { i1='^'; i2='^\.'; }
[ -f $a ] && { echozz 'local:'; sed "/^#/d;/$i1$p/I!d" $a; }
local URL=http://www.iana.org/cctld/cctld-whois.htm ; echozz 'www  :'
$ZZWWWDUMP "$URL" | sed -n "s/^ *//;1,/^z/d;/^__/,$ d;/$i2$p/Ip"
}


# ----------------------------------------------------------------------------
# http://pgp.dtype.org:11371
# busca a identifica��o da chave PGP, fornecido o nome ou email da pessoa.
# obs.: de brinde, instru��es de como adicionar a chave a sua lista.
# uso: zzchavepgp nome|email
# ex.: zzchavepgp Carlos Oliveira da Silva
#      zzchavepgp carlos@dominio.com.br
# ----------------------------------------------------------------------------
zzchavepgp(){
[ "$1" ] || { echo 'uso: zzchavepgp nome|email'; return; }
local id TXT=`echo "$*"| sed "$ZZSEDURL"` URL='http://pgp.dtype.org:11371'
$ZZWWWDUMP "$URL/pks/lookup?search=$TXT&op=index" | sed '/^Type /,$!d;$G' |
tee /dev/stderr | sed -n 's,^[^/]*/\([0-9A-F]\+\) .*,\1,p' | while read id; do
[ "$id" ] && echo "adicionar: gpg --recv-key $id && gpg --list-keys $id"; done
}


# ----------------------------------------------------------------------------
# http://www.dicas-l.unicamp.br
# procura por dicas sobre determinado assunto na lista Dicas-L
# obs.: as op��es do grep podem ser usadas (-i j� � padr�o)
# uso: zzdicasl [op��o-grep] palavra(s)
# ex.: zzdicasl ssh
#      zzdicasl -w vi
#      zzdicasl -vEw 'windows|unix|emacs'
# ----------------------------------------------------------------------------
zzdicasl(){
[ "$1" ] || { echo 'uso: zzdicasl [op��o-grep] palavra(s)'; return; }
local o URL='http://www.dicas-l.unicamp.br'; [ "${1##-*}" ] || { o=$1; shift; }
echozz "$URL/dicas-l/<DATA>.shtml"; $ZZWWWHTML "$URL/listagem.html" |
sed '/redarrow\.gif/!d;s/^[^0-9]\+/  /;s/<\/A>$//;s/\.shtml"[^>]*>/ /' |
grep -i $o "$*"
}


# ----------------------------------------------------------------------------
# http://registro.br
# whois da fapesp para dom�nios brasileiros
# uso: zzwhoisbr dom�nio
# ex.: zzwhoisbr abc.com.br
#      zzwhoisbr www.abc.com.br
# ----------------------------------------------------------------------------
zzwhoisbr(){
[ "$1" ] || { echo 'uso: zzwhoisbr dom�nio'; return; }
local dom="${1#www.}" URL='http://registro.br/cgi-bin/nicbr/whois'
$ZZWWWDUMP "$URL?qr=$dom" | sed '1,/^%/d;/^remarks/,$d;/^%/d;
/^alterado\|atualizado\|status\|servidor \|�ltimo /d'
}


# ----------------------------------------------------------------------------
# http://... - v�rios
# busca as �ltimas not�cias sobre linux em p�ginas nacionais.
# obs.: cada p�gina tem uma letra identificadora que pode ser passada como
#       par�metro, identificando quais p�ginas voc� quer pesquisar:
#       R)evista do linux, O)linux, ponto B)r, C)ipsga, I)nfoexame
#       linux in braZ)il
# uso: zznoticiaslinux [sites]
# ex.: zznoticiaslinux
#      zznoticiaslinux rci
# ----------------------------------------------------------------------------
zznoticiaslinux(){
local URL limite n=5 s='brociz'; limite="sed ${n}q"; [ "$1" ] && s="$1" 
[ "$s" != "${s#*r}" ] && { URL='http://www.RevistaDoLinux.com.br'
  echozz "* RdL ($URL):"; $ZZWWWHTML $URL |
  sed '/^<.*class=noticias><b>/!d;s///;s,</b>.*,,' | $limite; }
[ "$s" != "${s#*o}" ] && { URL='http://olinux.uol.com.br/home.html'
  echozz "* OLinux ($URL):"; $ZZWWWDUMP $URL |
  sed 's/^ *//;/^\[.*�LTIMAS/,/^\[.*CHAT /!d;/^\[/d;/^$/d' | $limite; }
[ "$s" != "${s#*b}" ] && { URL='http://pontobr.org'
  echozz "* .BR ($URL):"; $ZZWWWHTML $URL |
  sed '/^<tr>.*#006699.*<U>/!d;s///;s,</U>.*,,' | $limite; }
[ "$s" != "${s#*c}" ] && { URL='http://www.cipsga.org.br'
  echozz "* CIPSGA ($URL):"; $ZZWWWHTML $URL |
  sed '/^.*<tr><td bgcolor="88ccff"><b>/!d;s///;s,</b>.*,,' | $limite; }
[ "$s" != "${s#*z}" ] && { URL='http://linux.matrix.com.br'
  echozz "* Linux in Brazil ($URL):"; $ZZWWWHTML $URL |
  sed '\,^:</b> ,!d;s,,,' | $limite; }
[ "$s" != "${s#*i}" ] && { URL='http://www2.uol.com.br/info/index.shl'
  echozz "* InfoExame ($URL):"; $ZZWWWDUMP $URL |
  sed 's/^ *//;/^�ltimas/,/^download/s/^\[[^]]*]  //p;d' | $limite; }
}


# ----------------------------------------------------------------------------
# http://casa.uol.com.br
# pega as �ltimas not�cias da casa dos artistas II
# uso: zzcasadosartistas
# ----------------------------------------------------------------------------
zzcasadosartistas(){
$ZZWWWDUMP http://casa.uol.com.br/noticias |
sed 's/^ *//;/'$ZZERDATA'/,$!d' | sed 15q
}


# ----------------------------------------------------------------------------
# http://tudoparana.globo.com/gazetadopovo/cadernog/tv.html
# consulta a programa��o do dia dos canais abertos da TV
# pode-se passar os canais e o hor�rio que se quer consultar
#   Identificadores: B)and, C)nt, E)ducativa, G)lobo, R)ecord, S)bt, cU)ltura
# uso: zztv canal [hor�rio]
# ex.: zztv bsu 19       # band, sbt e cultura, depois das 19:00
#      zztv . 00         # todos os canais, depois da meia-noite
#      zztv .            # todos os canais, o dia todo
# ----------------------------------------------------------------------------
zztv(){
[ "$1" ] || { echo 'uso: zztv canal [hor�rio]  (ex. zztv bs 22)'; return; }
local c h="$2" URL=http://tudoparana.globo.com/gazetadopovo/cadernog/tv.html
c=`echo $1 | sed 's/b/2,/;s/s/4,/;s/c/6,/;s/r/7,/;s/u/9,/;s/g/12,/;s/e/59,/
s/,$//;s/,/\\\\|/g'`; $ZZWWWDUMP $URL |
sed -e 's/^ *//;s/canal/CANAL/i;/^[012C]/!d;/^C[^A]/d;/^C/i \' -e . |
sed "/^CANAL \($c\)/,/^.$/!d;/^C/,/^$h/{/^C\|^$h/!d;};s/^\.//"
}


# ----------------------------------------------------------------------------
# http://www.acronymfinder.com
# dicion�rio de siglas, sobre qualquer assunto (como DVD, IMHO, OTAN, WYSIWYG)
# obs.: h� um limite di�rio de consultas (10 acho)
# uso: zzsigla sigla
# ex.: zzsigla RTFM
# ----------------------------------------------------------------------------
zzsigla(){
[ "$1" ] || { echo 'uso: zzsigla sigla'; return; }
local URL=http://www.acronymfinder.com/af-query.asp
$ZZWWWDUMP "$URL?String=exact&Acronym=$1&Find=Find" |
sed -n 's/^ *//;s/ *\[go\.gif] *$//p'
}



# #### T R A D U T O R E S   e   D I C I O N � R I O S           (internet)

# ----------------------------------------------------------------------------
# http://babelfish.altavista.digital.com
# faz tradu��es de palavras/frases/textos em portugu�s e ingl�s
# uso: zzdicbabelfish [i] texto
# ex.: zzdicbabelfish my dog is green
#      zzdicbabelfish i falc�o detona!
# ----------------------------------------------------------------------------
zzdicbabelfish(){
[ "$1" ] || { echo 'uso: zzdicbabelfish [i] palavra(s)'; return; }
local URL='http://babelfish.altavista.com/tr' L=en_pt FIM='^ *<\/textarea>'
local INI='^ *<textarea .* name="q">'; [ "$1" = 'i' ] && { shift; L=pt_en; }
local TXT=`echo "$*"| sed "$ZZSEDURL"`; $ZZWWWHTML "$URL?urltext=$TXT&lp=$L" |
sed -n "/$INI/,/$FIM/{/$FIM\|^$/d;s/$INI/  /p;}"
}


# ----------------------------------------------------------------------------
# http://www.babylon.com
# tradu��o de palavras em ingl�s para um monte de idiomas:
# franc�s, alem�o, japon�s, italiano, hebreu, espanhol, holand�s e
# portugu�s. o padr�o � o portugu�s, � claro.
# uso: zzdicbabylon [idioma] palavra
# ex.: zzdicbabylon hardcore
#      zzdicbabylon jap tree
# ----------------------------------------------------------------------------
zzdicbabylon(){
[ "$1" ] || { echo -e "zzdicbabylon [idioma] palavra
  idioma = fre ger jap ita heb spa dut ptg" && return; }
local L=ptg ; [ "$2" ] && L=$1 && shift
$ZZWWWDUMP "http://www.babylon.com/trans/bwt.cgi?$L$1" |
sed '1,4d;s/^ *//;/^\($\|_\+\)/d;s/^/  /'
}


# ----------------------------------------------------------------------------
# http://www.dictionary.com
# defini��es de palavras em ingl�s, com pesquisa em *v�rios* bancos de dados
# uso: zzdicdict palavra
# ex.: zzdicdict hardcore
# ----------------------------------------------------------------------------
zzdicdict(){
[ "$1" ] || { echo "zzdicdict palavra" && return; }
local INI='^ *Found [0-9]\+ entr\(y\|ies\)' FIM='^ *Try your search'
$ZZWWWDUMP -width=72 "http://www.dictionary.com/cgi-bin/dict.pl?db=*&term=$*"|
sed -n "/$INI/,/$FIM/{/$INI\|$FIM/d;p;}"
}




# ----------------------------------------------------------------------------
# http://www.academia.org.br/vocabula.htm
# dicion�rio da ABL - academia brasileira de letras
# uso: zzdicabl palavra
# ex.: zzdicabl cabe�a-de-
# ----------------------------------------------------------------------------
zzdicabl(){
[ "$1" ] || { echo 'uso: zzdicabl palavra'; return; }
local URL='http://www.mtec.com.br/cgi-bin/abl/volta_abl_org.asp'
echo "palavra=$*" | $ZZWWWPOST $URL | sed '1,5d;/^ *\./,$d;s/^ */  /'
}


# ----------------------------------------------------------------------------
# http://www.uol.com.br/michaelis
# dicion�rio de portugu�s michaelis
# uso: zzdicmichaelis palavra
# ex.: zzdicmichaelis bolacha
# ----------------------------------------------------------------------------
zzdicmichaelis(){
[ "$1" ] || { echo 'uso: zzdicmichaelis palavra'; return; }
#conf p:comeca,exata,trecho m:tudo,substantivo,verbo,adjetivo w:n
local fixo='quantidade=50&campo=verbete' w=80 p=exata m=tudo
local URL='http://cf6.uol.com.br/michaelis/resultados.cfm'
$ZZWWWDUMP -width=72 "$URL?busca=$1&busca2=$1&palavra=$p&morfologia=$m&$fixo" |
sed 's/^  *//;1,/^____/{/^N�o consta/!d;q;};/^Quero participar/,$d'
}


# ----------------------------------------------------------------------------
# http://www.tuxedo.org/jargon
# dicion�rio de jarg�es de inform�tica, em ingl�s (local e www)
# obs.: pesquisa local com aproxima��o. se n�o tiver o jargon instalado,
#       procura na internet. a op��o -r (remoto) for�a a procura na www.
# uso: zzdicjargon [-r] palavra
# ex.: zzdicjargon vi
#      zzdicjargon -r all your base are belong to us
# ----------------------------------------------------------------------------
zzdicjargon(){
[ "$1" ] || { echo 'uso: zzdicjargon [-r] palavra'; return; }
local o='' dir ldir TXT URL='http://www.tuxedo.org/jargon/html/entry'
dir='/usr/share/doc/jargon-*/html/entry'; ldir=`echo $dir`;
[ "$1" = '-r' ] && { o=1 ; shift; }; TXT=`echo "$*" | sed 's/ /-/g'`;
function zzjargondump { $ZZWWWDUMP -width=72 "$1" | sed '1,4d;$d'; }
if [ "$o" ]; then zzjargondump "$URL/$TXT.html"; elif [ "$ldir" = "$dir" ];
then echo `echozz 'jargon local'`' n�o encontrado (veja $dir)';
     echozz 'jargon remoto (www):'; zzjargondump "$URL/$TXT.html"
else echozz 'exato:'; larq="$ldir/$TXT.html";
     if [ -f "$larq" ]; then zzjargondump "$larq";
     else echo '  n�o encontrado'; fi; echozz 'possibilidades:';
     (cd ${ldir%% *} ; echo '  '`\ls -1 | grep -i "$TXT"` | sed 's/\.html//g')
fi ; unset -f zzjargondump
}


# ----------------------------------------------------------------------------
# usa todas as fun��es de dicion�rio e tradu��o de uma vez
# uso: zzdictodos palavra
# ex.: zzdictodos Linux
# ----------------------------------------------------------------------------
zzdictodos(){
[ "$1" ] || { echo 'uso: zzdictodos palavra'; return; }
local D ; for D in babelfish babylon jargon abl michaelis dict
do echozz "zzdic$D:"; zzdic$D $1; done
}


# ----------------------------------------------------------------------------
# http://verde666.org/doc/ramones.txt
# procura frases de letras de m�sicas do ramones
# uso: zzramones [palavra]
# ex.: zzramones punk
#      zzramones
# ----------------------------------------------------------------------------
zzramones(){
local txt n url='http://verde666.org/doc/ramones.txt'
txt=`$ZZWWWDUMP "$url" | grep -iw "${1:-.}"`;
n=`echo "$txt" | sed -n $=`; n=$((RANDOM%n)); echo "$txt" | sed -n ${n}p
}



# ----------------------------------------------------------------------------
## lidando com a chamada pelo execut�vel

if [ "$1" ]; then
  if [ "$1" = '--help' -o "$1" = '-h' ]
  then zzajuda
  elif [ "$1" = '--version' -o "$1" = '-v' ]
  then zzzz | sed '/^local\|^vers/!d'
  else "$@" || echo 'ERRO: esta fun��o n�o existe! (tente --help)'
  fi
## chamando do execut�vel sem argumentos
elif [ "${0%bash}" = "$0" ]; then
  echo "
uso: funcoeszz <fun��o> [<par�metros>]
     funcoeszz --help

dica: inclua as fun��es ZZ no seu login shell,
      e depois chame-as diretamente pelo nome:

  prompt$ cd
  prompt$ echo source /usr/bin/funcoeszz >> .bashrc
  prompt$ source .bashrc
  prompt$ zz<TAB><TAB>
"
  exit 1
fi







