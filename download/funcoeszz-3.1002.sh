#!/bin/bash
# funcoeszz
# vim: noet noai tw=78
#
# INFORMAÇÕES: http://aurelio.net/zz
# NASCIMENTO : 22 fevereiro 2000
# AUTORES    : Aurélio Marinho Jargas <verde (a) aurelio net>
#              Thobias Salazar Trevisan <thobias (a) lcp coppe ufrj br>
# DESCRIÇÃO  : Funções de uso geral para bash[12], que buscam informações em
#              arquivos locais e dicionários/tradutores/fontes na internet
# VEJA TAMBÉM: Pacotes de funções do Thobias, similar às funções ZZ:
#              http://www.cos.ufrj.br/~thobias/scr/index.html
#
# REGISTRO DE MUDANÇAS:
# 20000222 ** 1ª versão
# 20000424 ++ cores, beep, limpalixo, rpmverdono
# 20000504 ++ calcula, jpgi, gifi, trocapalavra, ajuda, echozz, forzz
# 20000515 ++ dominiopais, trocaextensao, kill, <> $* > "$@"
#          -- jpgi, gifi: o identify já faz
# 20000517 <> trocapalavra -> basename no $T
# 20000601 -- dicbabel: agora com session &:(
# 20000612 ++ celulartim, trocaarquivo
# 20000823 <> dicjarg: + palavras com espaços, -- celulartim
# 20000914 ++ dicabl, dicdict, dicbabel, <> nome oficial: .bashzz
#          -- dicdic: página fora do ar
# 20000915 ++ mini-manual no cabeçalho, bugzilla, getczz, ZZPOST
#    !!    ** 1º anúncio externo
# 20000920 ++ freshmeat, ZZWWWHTML, <> ZZDUMP -> ZZWWWDUMP (idem ZZPOST)
#          <> ZZWWW*: -crawl -width -aacookies, <> bugzilla: saída +limpa
#          <> kill: mostra núm do processo
# 20001108 <> dic: babi->babylon, jarg->jargon, babel->babelfish
#          ++ dicmichaelis, ++ cep
# 20001230 <> cep: TipoPesquisa=, <> cabeçalho == /bin/bash, ++ cinclude
#          <> dolar: mostra data e trata acima de R$ 2 (triste realidade)
# 20010214 ++ detran
# 20010314 <> dominiopais: URL nova, pesquisa local, procura código ou nome
#          <> freshmeat: atualizada
# 20010320 <> bugzilla: ++UNCONFIRMED, product: Conectiva Linux
# 20010322 <> bugzilla: status entre ()
# 20010713 <> babelfish: re-re-arrumado, jargon: quebra 72 colunas
# 20010717 <> trocaextensao: /usr/bin/rename, /tmp/zz<arquivo>.$$
#          ++ arrumanome, ++ diffpalavra
# 20010724 ++ ramones, <> dicdict: atualizado
# 20010801 <> calcula: entrada/saída com vírgulas
# 20010808 ++ dicasl, -- ramal (palha)
# 20010809 ++ irpf (valeu stulzer), <> detran -> detranpr
#          <> dicjargon: agora local e www (tá BLOAT Kra!!!)
# 20010820 <> dicdict: saída em 72 colunas, <> detranpr: mais dados
#          <> cep: URL nova
# 20010823 ++ ZZTMP (andreas chato &:) )
#    !!    ** funcoeszz agora é um pacote do Conectiva Linux
# 20010828 ++ maiores, <> dicmichaelis: simplificado
# 20011001 ++ chavepgp (valeu missiaggia)
# 20011002 <> limpalixo: aceita $1 também, ++ /usr/bin/funcoeszz (valeu gwm)
#          <> dolar: URL nova, formato novo (valeu bruder)
# 20011015 <> arrumanome: s/^-/_/, mv -v --
# 20011018 <> "$@" na chamada do executável (++aspas)
# 20011108 <> dolar: formato melhorado
# 20011113 ++ cores
# 20011211 <> freshmeat: mudança no formato (©), ++ detransp (valeu elton)
#          ++ $ZZER{DATA,HORA}
# 20011217 ++ noticiaslinux, whoisbr (valeu marçal)
# 20020107 ++ zzzz, $ZZPATH, --version
# 20020218 ++ função temporária casadosartistas &:)
#    !!    ** página da funções em http://verde666.org/zz
# 20020219 ++ tv
# 20020222 <> cep: número do CEP, ++ sigla (valeu thobias)
# 20020226 <> s/registrobr/whoisbr/ na ajuda (valeu graebin)
# 20020228 ++ rpmfind (valeu thobias), s/==/=/ pro bash1 (valeu kallás)
# 20020306 <> dolar: pequena mudança na saída
# 20020313 <> zz: ++listagem das funções, ++--atualiza, ++--bashrc
#          <> chamando pelo executável, pode omitir o zz do nome
#          ++ TODAS as funções agora possuem --help (ou -h)
# 20020315 ++ nextel, <> noticiaslinux: ++tchelinux, zz: (bashrc)
# 20020419 ++ pronuncia (valeu thobias)
# 20020605 <> trocaextensao: -- /usr/bin/rename (valeu leslie)
#          <> casadosartistas: atualizada para casa3 (valeu ataliba)
#          <> zzzz: pr tirado fora (bug na versão nova)
# 20020611 <> casadosartistas: ++ index.php3 na URL (valeu thobias)
#          <> nextel: URL atualizada (valeu samsoniuk)
#          <> noticiaslinux: Z) URL/filtro atualizados (valeu thobias)
# 20020622 <> dicasl: URL/filtro atualizados (valeu thobias)
#          ++ uniq, <> limpalixo: s/stdin/${1:--}/, reconhece vim
#          <> ramones: agora grava arquivo para consulta local (+rápido!)
# 20020827 <> tv: checa 2 horas adiante se na atual falhar (valeu copag)
#          ++ howto (valeu thobias), <> tv: URL atualizada (valeu copag)
#          <> arrumanome: nome mais limpo
# 20021030 <> noticiaslinux: Z) URL atualizada (valeu thobias)
#          <> noticiaslinux: B) filtro atualizado
#          <> dicbabelfish: filtro atualizado
#          -- casadosartistas: fim do programa
# 20021107 <> pronuncia: filtro arrumado (valeu thobias)
#          <> pronuncia: reconhece na hora arquivos já baixado (+rápido!)
#          ++ senha (valeu thobias), ++ linuxnews (valeu thobias)
# 20021206 <> maiores: adicionada opção -r
#          <> uniq: malabarismos de cat/sort/uniq trocados por um SED
#          <> dicbabelfish: filtro atualizado, <> dolar: filtro atualizado
#          ++ ascii, ++ seqzz
# 20030124 <> ascii: adicionado --help
#          <> dicjargon: URL atualizada (valeu jic)
#          <> noticiaslinux: I) URL atualizada (valeu thobias)
#          ++ letrademusica (valeu thobias)
# 20030207 ++ data, <> noticiaslinux B) filtro atualizado (valeu thobias)
#          <> linuxnews: D) filtro atualizado (valeu thobias)
#          <> pronuncia: filtro arrumado (valeu thobias)
# 20030211 <> data: arrumado bug "value too great for base" (valeu sergio)
#          -- michaelis: a UOL fechou o acesso livre :(
#          <> zzzz: retirado código de pacote RPM no --atualiza
#          <> linuxnews: F) filtro atualizado
#          <> noticiaslinux: B) filtro atualizado
# 20030226 ++ dicportugues: direto de Portugal (valeu marciorosa)
# 20030317 <> zzzz: adicionado --tcshrc (valeu spengler)
#          <> echozz: não estava imprimindo texto sem cores
#          <> linuxnews: O) arrumado, filtro atualizado (valeu thobias)
# 20030331 <> dicportugues: URL nova, filtro novo (valeu thobias)
# 20030403 ++ google, dolar: agora inclui a hora da última atualização
#    !!    ** início do concurso para o logotipo
#    !!    ** página da funções mudou-se para http://aurelio.net/zz
#    !!    ** o Thobias foi empossado como co-autor (06maio)
# 20030507 <> trocapalavra: só regrava arquivos modificados
#          <> irpf: recebe o ano como parâmetro (2001 ou 2002)
#          <> noticiaslinux: Z) URL e filtros atualizados (valeu brain)
#          <> trocaextensao: adicionada checagem se é a mesma extensão
#          <> uniq: arrumada, não estava funcionado direito
#          <> dicbabelfish, tv: filtro atualizado
#          <> arrumado bug que mostrava "esta função não existe!"
# 20030612 ++ ss, ++ maiusculas, ++ minusculas
#          <> irpf: restituições de 2003 incluídas
#          <> arrumanome: mais caracteres estranhos cadastrados
#          <> noticiaslinux: apagado lixo: "tee pbr.html" (valeu bernardo)
#          <> trocapalavra: só regrava arquivos modificados (agora sim)
#          <> trocapalavra: trata arquivos com espaço no nome (valeu rbp)
#          <> cep: URL mudou (valeu fernando braga)
#          <> echozz: mensagens coloridas em azul
# 20030713 ++ noticiassec
#          <> howto: URL nova, procura mini-HOWTOs também
#          <> dicjargon: URL nova, cache local, mais esperto
#          <> linuxnews: atualizada URL para Linux Weekly News
#          <> arrumanome: não apaga arquivo já existente (valeu paulo henrique)
#          <> noticiaslinux: adicionado site Notícias Linux (valeu bernardo)
#          <> dicbabelfish, dolar: arrumado filtro
#          -- bugzilla, rpmdono, rpmdisco: retiradas do pacote
# 20031002 ++ converte, contapalavra
#          <> howto: de volta para a URL antiga
#          <> noticiassec: --help arrumado
#          <> noticiaslinux: Z) filtro atualizado
#          <> tv: sbt arrumado (valeu vinicius)
#          <> zzzz: bashrc: checagem +esperta, quebra a linha (valeu luciano)




ZZC=1         # colorir mensagens? 1 liga, 0 desliga

ZZWWWDUMP='lynx -dump      -nolist -crawl -width=300 -accept_all_cookies'
ZZWWWLIST='lynx -dump                     -width=300 -accept_all_cookies'
ZZWWWPOST='lynx -post-data -nolist -crawl -width=300 -accept_all_cookies'
ZZWWWHTML='lynx -source'
ZZTMP="${TMPDIR:-/tmp}/zz"

# se você colocar as funções em outro lugar, redefina o ZZPATH
ZZPATH="$0"; [ "${0%bash}" != "$0" ] && ZZPATH=/usr/bin/funcoeszz
[ "${ZZPATH#/}" = "$ZZPATH" ] && ZZPATH="$PWD/${ZZPATH#./}"

ZZERDATA='[0-9][0-9]\/[0-9][0-9]\/[0-9]\{4\}'; # dd/mm/aaa ou mm/dd/aaaa
ZZERHORA='[012][0-9]:[0-9][0-9]';

ZZSEDURL='s| |+|g;s|&|%26|g'
getczz(){ stty raw; eval $1="`dd bs=1 count=1 2>&-`"; stty cooked; }
echozz(){ [ "$ZZC" != 1 ] && echo -e $* ||
        { echo -e "\033[36;1m$*"; echo -ne "\033[m"; } ; }
seqzz(){
 local o=+ a=1 z=${1:-1}; [ "$2" ] && { a=$1; z=$2; } ; [ $a -gt $z ] && o=-
 while [ $a -ne $z ]; do echo $a ; eval "a=\$((a$o 1))"; done; echo $a
}



# ----------------------------------------------------------------------------
# mostra uma tela de ajuda com explicação e sintaxe de todas as funções
# obs.: tátátá, é xunxo. sou preguiçoso sim, e daí &:)
# uso: zzajuda
# ----------------------------------------------------------------------------
zzajuda(){ zzzz -z $1 zzajuda && return
sed '1s/.*/*** ajuda das funções ZZ (tecla Q sai)/p;2g;2p;/^# --*$/,/^# --*$/{
s,\(\<zz[a-z2]\+\>\),[36;1m\1[m,;s/^# //p;};d' $ZZPATH | uniq | less -r
}


# ----------------------------------------------------------------------------
# mostra informações (como versão e localidade) sobre as funções
# com a opção --atualiza, baixa a versão mais nova das funções
# com a opção --bashrc, "instala" as funções no ~/.bashrc
# com a opção --tcshrc, "instala" as funções no ~/.tcshrc
# uso: zzzz [--atualiza|--bashrc|--tcshrc]
# ----------------------------------------------------------------------------
zzzz(){
if [ "$1" = '-z' -o "$1" = '-h' -o "$1" = '--help' ]; then # -h)zzzz -z)resto
  [ "$1" = '-z' -a "$2" != '--help' -a "$2" != '-h' ] && return 1 #alarmefalso
  local pat="uso: [^ ]*${3:-zzzz}"; zzajuda | grep -C9 "^$pat" | sed ":a
  ;$ bz;N;ba;:z;s/.*\n---*\(\n\)\(.*$pat\)/\1\2/;s/\(\n\)---.*/\1/"; return 0
fi
local vl vr URL='http://aurelio.net/zz' cfg="source $ZZPATH" cfgf=~/.bashrc
vl=`sed '/^$/{g;q;};/^# 200./!d;s/^# ...\(.\)\(....\).*/\1.\2/;h;d' $ZZPATH`
local rc cor='não'; [ "$ZZC" = '1' ] && cor='sim' ; [ -f "$ZZPATH" ] &&
if [ "$1" = '--atualiza' ]; then # obtém versão nova, se !=, download
  echo "Procurando a versão nova, aguarde."
  vr=`$ZZWWWDUMP $URL | sed -n 's/.*versão atual \([0-9.]\+\).*/\1/p'`
  echo "versão local : $vl"; echo "versão remota: $vr"; echo
  if [ "$vl" = "$vr" ]; then echo 'Você já está com a última versão.'
  else
    local urlexe="$URL/funcoeszz" exe="funcoeszz-$vr"
    echo -n 'Baixando a versão nova... '; $ZZWWWHTML $urlexe > $exe
    echo 'PRONTO!'; echo "Arquivo '$exe' baixado, instale-o manualmente."
  fi
elif [ "$1" = '--bashrc' ]; then # instala funções no ~/.bashrc
  if ! grep -q "^ *source .*funcoeszz" $cfgf;
  then (echo ; echo "$cfg") >> $cfgf; echo 'feito!'
  else echo "as funções já estão no $cfgf!"; fi
elif [ "$1" = '--tcshrc' ]; then # cria aliases para as funções no /.tcshrc
  cfgf=~/.zzcshrc cfg="source $cfgf"; echo > $cfgf
  if ! grep -q "^ *$cfg" ~/.tcshrc; then echo "$cfg" >> ~/.tcshrc ; fi
  for func in `ZZC=0 zzzz | sed '1,/^(( fu/d;s/,//g'`; do
    echo "alias zz$func 'funcoeszz zz$func'" >> $cfgf;
  done; echo 'feito!'
else # mostra informações sobre as funçÕes
  rc='não instalado' ; grep -qs "^ *$cfg" $cfgf && rc="$cfgf"
  echozz "( local)\c"; echo " $ZZPATH"; echozz "(versão)\c"; echo " $vl"
  echozz "( cores)\c"; echo " $cor"; echozz "(   tmp)\c"; echo " $ZZTMP"
  echozz "(bashrc)\c"; echo " $rc"; echo
  echozz "( lista)\c"; echo ' zztabtab@yahoogrupos.com.br'
  echozz "(página)\c"; echo " $URL"
  [ "$ZZPATH" ] && { echo ; echozz '(( funções disponíveis ))' # lista todas
  # o pr tá buggado ### pr -l 10 -w 72 -5
  sed '/^zz[a-z0-9]\+(/!d;s/^zz//;s/(.*//' $ZZPATH | sort |
  sed ':a;$!N;s/\n/, /;ta;s/\(.\{60\}[^ ]*\) /\1\
/g'
  }
fi
}



# ----------------------------------------------------------------------------
# #### D I V E R S O S
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# restaura o 'beep' da máquina
# se por algum motivo o 'beep' da sua máquina parou de funcionar ou mudou a
# freqüência ou duração, essa função o retorna a seu estado original
# uso: zzbeep
# ----------------------------------------------------------------------------
zzbeep(){ zzzz -z $1 zzbeep && return; echo -ne '\033[10;750]\033[11;100]'; }


# ----------------------------------------------------------------------------
# retira linhas em branco e comentários
# para ver rapidamente quais opções estão ativas num arquivo de configuração
# além do tradicional #, reconhece comentários de arquivos .vim
# obs.: aceita dados vindos da ENTRADA PADRÃO (STDIN)
# uso: zzlimpalixo [arquivo]
# ex.: zzlimpalixo ~/.vimrc
#      cat /etc/inittab | zzlimpalixo
# ----------------------------------------------------------------------------
zzlimpalixo(){ zzzz -z $1 zzlimpalixo && return
local z='#'; case "$1" in *.vim|*.vimrc*)z='"';; esac
cat "${1:--}" | tr '\t' ' ' | sed "\,^ *\($z\|$\),d" | uniq
}


# ----------------------------------------------------------------------------
# converte as letras do texto para minúsculas/MAIÚSCULAS, inclusive acentuadas
# uso: zzmaiusculas [arquivo]
#      zzminusculas [arquivo]
# ex.: zzmaiusculas /etc/passwd
#      echo NÃO ESTOU GRITANDO | zzminusculas
# ----------------------------------------------------------------------------
zzminusculas(){ zzzz -z $1 zzminusculas && return
sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
     y/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ/àáâãäåèéêëìíîïòóôõöùúûüçñ/' "$@"; }
zzmaiusculas(){ zzzz -z $1 zzmaiusculas && return
sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/
     y/àáâãäåèéêëìíîïòóôõöùúûüçñ/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ/' "$@"; }


# ----------------------------------------------------------------------------
# retira as linhas repetidas (consecutivas ou não)
# útil quando não se pode alterar a ordem original das linhas,
# então o tradicional sort|uniq falha.
# uso: zzuniq [arquivo]
# ex.: zzuniq /etc/inittab
#      cat /etc/inittab | zzuniq
# ----------------------------------------------------------------------------
zzuniq(){ zzzz -z $1 zzuniq && return
## versão UNIX, rápida, mas precisa de cat, sort, uniq e cut
cat -n "${1:--}" | sort -k2 | uniq -f1 | sort -n | cut -f2-
## versão SED, mais lenta para arquivos grandes, mas só precisa do SED
##sed "G;/^\([^\n]*\)\n\([^\n]*\n\)*\1\n/d;h;s/\n.*//" $1
}


# ----------------------------------------------------------------------------
# mata os processos que tenham o(s) padrão(ões) especificado(s) no nome do
# comando executado que lhe deu origem
# obs.: se quiser assassinar mesmo o processo, coloque a opção -9 no kill
# uso: zzkill padrão [padrão2 ...]
# ex.: zzkill netscape
#      zzkill netsc soffice startx
# ----------------------------------------------------------------------------
zzkill(){ zzzz -z $1 zzkill && return;
local C P; for C in "$@"; do
for P in `ps x --format pid,comm | sed -n "s/^ *\([0-9]\+\) [^ ]*$C.*/\1/p"`
do kill $P && echo -n "$P "; done; echo; done
}


# ----------------------------------------------------------------------------
# mostra todas as combinações de cores possíveis no console, juntamente com
# os respectivos códigos ANSI para obtê-las
# uso: zzcores
# ----------------------------------------------------------------------------
zzcores(){ zzzz -z $1 zzcores && return
local frente fundo bold c
for frente in 0 1 2 3 4 5 6 7; do for bold in '' ';1'; do
  for fundo in 0 1 2 3 4 5 6 7; do
    c="4$fundo;3$frente"; echo -ne "\033[$c${bold}m $c${bold:-  } \033[m"
  done; echo
done; done
}



# ----------------------------------------------------------------------------
# gera uma senha aleatória de N caracteres formada por letras e números
# obs.: a senha gerada não possui caracteres repetidos
# uso: zzsenha [n]     (padrão n=6)
# ex.: zzsenha
#      zzsenha 8
# ----------------------------------------------------------------------------
zzsenha(){ zzzz -z $1 zzsenha && return
local n alpha="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
n=6 ; [ "$1" ] && n=`echo "$1" | sed 's/[^0-9]//g'`
[ $n -gt 62 ] && { echo "zzsenha: O tamanho máximo é 62" ; return ; }
while [ $n -ne 0 ]; do n=$((n-1)) ; pos=$((RANDOM%${#alpha}+1))
echo -n "$alpha" | sed "s/\(.\)\{$pos\}.*/\1/" # igual a cut -c$pos
alpha=`echo $alpha | sed "s/.//$pos"` ; done | tr -d '\012' ; echo
}



# ----------------------------------------------------------------------------
# mostra a tabela ASCII com todos os caracteres imprimíveis (32-126,161-255)
# no formato: <decimal> <octal> <ascii>
# obs.: o número de colunas e a largura da tabela são configuráveis
# uso: zzascii [colunas] [largura]
# ex.: zzascii
#      zzascii 7
#      zzascii 9 100
# ----------------------------------------------------------------------------
zzascii(){ zzzz -z $1 zzascii && return
local ncols=${1:-6} largura=${2:-78} chars=`seqzz 32 126 ; seqzz 161 255`
local largcol=$((largura/ncols))    nchars=`echo "$chars" | sed -n $=`
local nlinhas=$((nchars/ncols+1))     cols=`seqzz 0 $((ncols-1))`
local ref num octal char linha=0
echo $nchars caracteres, $ncols colunas, $nlinhas linhas, $largura de largura
while [ ${linha} -lt $nlinhas ]; do
  ref=''; linha=$((linha+1))
  for col in $cols; do ref="$ref $((nlinhas*col+linha))p;"; done
  for num in `echo "$chars" | sed -n "$ref"`; do
    octal=$((num/8*10+num%8)) ; octal=$((octal/80*100+octal%80))
    [ $octal -lt 100 ] && octal="0$octal" ; char=`echo -e "\\\\$octal"`
    printf "% ${largcol}s" "$num $octal $char"
  done ; echo
done
}



# ----------------------------------------------------------------------------
# Screen Saver para console, com cores e temas
# temas: mosaico, espaco, olho, aviao, jacare, alien, rosa, peixe, siri
# obs.: aperte Ctrl+C para sair
# uso: zzss [--rapido|--fundo] [--tema <tema>] [texto]
# ex.: zzss
#      zzss "fui no banheiro"
#      zzss --rapido /
#      zzss --fundo --tema peixe
# ----------------------------------------------------------------------------
zzss(){ zzzz -z $1 zzss && return
local a i j x y z zn lc c fundo tema temas hl pausa=1 c1='40;3' lin=25 col=80
temas="{mosaico} ;{espaco}.; {olho}00;{aviao}--o-0-o--;{jacare}==*-,,--,,--;
       {alien}/-=-\\ ;{rosa}--/--\\-<@;{peixe}>-)))-D; {siri}(_).-=''=-.(_);"
lc=`stty size 2>&-`; [ "$lc" ] && { lin=${lc% *}; col=${lc#* }; } # scr size
[ "$1" ] || tema=mosaico ; while [ $# -gt 1 ]; do case "$1" in    # cmdline
  --fundo)fundo=1 ;; --rapido)unset pausa ;; --tema)tema=$2;shift;; # ...
  *)echo "opção inválida '$1'"; return ;; esac; shift; done; z=$1   # ...
[ "$tema" ] && if echo $temas | grep -qs "{$tema}"                # theme
  then z=`echo $temas|sed "s/.*{$tema}//;s/;.*//"`                  # get str
  else echo "tema desconhecido '$2'"; return; fi                    # error
[ "$tema" = mosaico ] && { fundo=1 ; unset pausa; z=' ';}           # special
trap "clear;return" SIGINT; [ "$fundo" ] && c1='30;4'; zn=${#z}   # init
clear ; i=0 ; while :; do                                         # loop
  i=$((i+1)) ; j=$((i+1)) ; RANDOM=$j                               # set vars
  x=$((((RANDOM+c*j)%lin)+1)) ; y=$((((RANDOM*c+j)%(col-zn+1))+1))  # set  X,Y
  c=$(((x+y+j+RANDOM)%7  +1)) ; echo -ne "\033[$x;${y}H"            # goto X,Y
  unset hl; [ ! "$fundo" -a $((y%2)) -eq 1 ] && hl='1;'             # bold?
  [ "$ZZC" != 1 ] && a="$z" || a="\033[${hl}$c1${c}m$z\033[m"       # color?
  echo -ne $a ; ${pausa:+sleep 1} ; done                            # show
}



# ----------------------------------------------------------------------------
# #### A R Q U I V O S
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# conversão de arquivos texto entre DOS e linux
# obs.: o arquivo original é gravado como arquivo.{dos,linux}
# uso: zzdos2linux arquivo(s)
#      zzlinux2dos arquivo(s)
# ----------------------------------------------------------------------------
zzdos2linux(){ zzzz -z $1 zzdos2linux && return
local A; for A in "$@"; do cp "$A" "$A.dos" && chmod -x $A &&
sed 's/$//' "$A.dos"   > "$A" && echo "convertido $A"; done; }
zzlinux2dos(){ zzzz -z $1 zzdos2linux && return
local A; for A in "$@"; do cp "$A" "$A.linux" &&
sed 's/$//' "$A.linux" > "$A" && echo "convertido $A"; done; }


# ----------------------------------------------------------------------------
# troca a extensão de um (ou vários) arquivo especificado
# uso: zztrocaextensao antiga nova arquivo(s)
# ex.: zztrocaextensao .doc .txt *
# ----------------------------------------------------------------------------
zztrocaextensao(){ zzzz -z $1 zztrocaextensao && return
[ "$3" ] || { echo 'uso: zztrocaextensao antiga nova arquivo(s)'; return; }
local A p1="$1" p2="$2"; shift 2; [ "$p1" = "$p2" ] && return
for A in "$@"; do [ "$A" != "${A%$p1}" ] && mv -v "$A" "${A%$p1}$p2"; done
}


# ----------------------------------------------------------------------------
# troca o conteúdo de dois arquivos, mantendo suas permissões originais
# uso: zztrocaarquivos arquivo1 arquivo2
# ex.: zztrocaarquivos /etc/fstab.bak /etc/fstab
# ----------------------------------------------------------------------------
zztrocaarquivos(){ zzzz -z $1 zztrocaarquivos && return
[ "$2" ] || { echo 'uso: zztrocaarquivos arquivo1 arquivo2'; return; }
local at="$ZZTMP.$$"; cat "$2" > $at; cat "$1" > "$2"; cat "$at" > "$1"
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
zztrocapalavra(){ zzzz -z $1 zztrocapalavra && return
[ "$3" ] || { echo 'uso: zztrocapalavra antiga nova arquivo(s)'; return; }
local A T p1="$1" p2="$2"; shift 2; for A in "$@"; do
  grep -qs "$p1" "$A" || continue ; T=$ZZTMP${A##*/}.$$ ; cp "$A" "$T" &&
  sed "s§$p1§$p2§g" "$T" > "$A" && rm -f "$T" && echo "feito $A"; done
}


# ----------------------------------------------------------------------------
# renomeia arquivos do diretório atual, arrumando nomes estranhos.
# obs.: ele deixa tudo em minúsculas, retira acentuação e troca espaços em
#       branco, símbolos e pontuação pelo sublinhado _
# uso: zzarrumanome arquivo(s)
# ex.: zzarrumanome *
#      zzarrumanome "DOCUMENTO MALÃO!.DOC"       # fica documento_malao.doc
#      zzarrumanome "RAMONES - I Don't Care"     # fica ramones-i_don_t_care
# ----------------------------------------------------------------------------
zzarrumanome(){ zzzz -z $1 zzarrumanome && return
[ "$1" ] || { echo 'uso: zzarrumanome arquivo(s)'; return; }
local A A1 A2 D i; for A in "$@"; do [ -f "$A" ] || continue;
  A1="${A##*/}"; D="${A%/*}"; D="${D%$A1}" ; A2=`echo $A1 | sed "s/[\"']//g"'
  y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/;s/^-/_/
  y/ÀàÁáÂâÃãÄÅäåÈèÉéÊêËëÌìÍíÎîÏïÇçÑñ/aaaaaaaaaaaaeeeeeeeeiiiiiiiiccnn/
  y/ÒòÓóÔôÕõÖöÙùÚúÛûÜüß¢Ð£Øø§µÝý¥¹²³/oooooooooouuuuuuuubcdloosuyyy123/
  s/[^a-z0-9._-]/_/g;s/__*/_/g;s/_\([.-]\)/\1/g;s/\([.-]\)_/\1/g'`
  [ "$A1" = "$A2" ] && continue ; [ -f "${D:-.}/$A2" ] && {
    i=1 ; while [ -f "${D:-.}/$A2.$i" ]; do i=$((i+1)); done ; A2="$A2.$i"; }
  mv -v -- "$A" "${D:-.}/$A2"; done
}


# ----------------------------------------------------------------------------
# mostra a diferença entre dois textos, mas no contexto de palavras.
# útil para conferir revisões ortográficas ou mudanças pequenas em frases.
# obs.: se tiver muitas _linhas_ diferentes o diff normal é aconselhado.
# uso: zzdiffpalavra arquivo1 arquivo2
# ex.: zzdiffpalavra texto-orig.txt texto-novo.txt
#      zzdiffpalavra txt1 txt2 | vi -            # saída com sintaxe colorida
# ----------------------------------------------------------------------------
zzdiffpalavra(){ zzzz -z $1 zzdiffpalavra && return
[ "$2" ] || { echo 'uso: zzdiffpalavra arquivo1 arquivo2'; return; }
local split='s/$//;s/^/§§§\n/;s/ /\n/g' at1="$ZZTMP${1##*/}.$$"
local at2="$ZZTMP${2##*/}.$$"; sed "$split" $1 >$at1; sed "$split" $2 >$at2
diff -u100 $at1 $at2 | cat - -E | sed '4,${s/^+/¤/;s/^-/¯/;};s/$$/¶/' |
tr -d '\012' | sed 's/\(¶¯[^¶]*\)\+/\n&\n/g;s/\(¶¤[^¶]*\)\+/&\n/g;
s/\(¶ [^¶]*\)\(\(¶¤[^¶]*\)\+\)/\1\n\2/g;s/¶/\n/3;s/¶/\n/2;s/¶/\n/1;s/¶//g;
s/\n¤/\n+/g;s/\n¯/\n-/g;s/[¤¯]/ /g;s/\n\? \?§§§\n\?/\n/g'; rm $at1 $at2
}


# ----------------------------------------------------------------------------
# acha as funções de uma biblioteca da linguagem C (arquivos .h)
# obs.: o diretório padrão de procura é o /usr/include
# uso: zzcinclude
# ex.: zzcinclude stdio
#      zzcinclude /minha/rota/alternativa/stdio.h
# ----------------------------------------------------------------------------
zzcinclude(){ zzzz -z $1 zzcinclude && return
[ "$1" ] || { echo "uso: zzcinclude nome-biblioteca"; return; }
local i="$1"; [ "${i#/}" = "$i" ] && i="/usr/include/$i.h"
[ -f $i ] || { echo "$i não encontrado" ; return; } ; cpp -E $i |
sed '/^ *$/d;/^\(#\|typedef\) /d;/^[^a-z]/d;s/ *(.*//;s/.* \*\?//' | sort
}


# ----------------------------------------------------------------------------
# acha os 15 maiores arquivos/diretórios do diretório atual (ou especificados)
# usando-se a opção -r é feita uma busca recursiva nos subdiretórios
# uso: zzmaiores [-r] [dir1 dir2 ...]
# ex.: zzmaiores
#      zzmaiores /etc /tmp
#      zzmaiores -r ~
# ----------------------------------------------------------------------------
zzmaiores(){ zzzz -z $1 zzmaiores && return
local d rr=0 ; [ "$1" == '-r' ] && { rr=1 ; shift; }
if   [ "$2" ]; then d=`echo $* | sed 's/^/{/;s/$/}/;s/ \+/,/'`
elif [ "$1" ]; then d="$1"; else d=.; fi
if [ $rr -eq 1 ]; then
  find $d -type f -printf "%11s  %p\n" | sort -nr | sed '
  :p1; s/^\( *[0-9]\+\)\([0-9]\{3\}\)/\1.\2/ ; /^ *[0-9]\{4\}/b p1;
  :p2; s/^/ / ; /^[ .0-9]\{1,13\}[0-9] /b p2 ; 15q'
else
  du -s `eval echo $d/{*,.[^.]*}` 2>/dev/null | sort -nr | sed 15q
fi
}


# ----------------------------------------------------------------------------
# conta o número de vezes que uma palavra aparece num arquivo
# obs.: -i Ignora a diferença de maiúsculas/minúsculas
#       -p Parcial, conta trechos de palavras
# uso: zzcontapalavra [-i|-p] palavra arquivo
# ex.: zzcontapalavra root /etc/passwd
#      zzcontapalavra -i -p a /etc/passwd
# ----------------------------------------------------------------------------
zzcontapalavra(){ zzzz -z $1 zzcontapalavra && return
local ic word='-w' mask='@@_@_@@'
[ "$1" = '-p' ] && { word= ; shift; } ; [ "$1" = '-i' ] && { ic=$1; shift; }
[ "$1" = '-p' ] && { word= ; shift; } ; p=$1 ; arq=$2
[ $# -ne 2 ] && { echo 'uso: zzcontapalavra [-i|-p] palavra arquivo'; return;}
[ "$ic"    ] && p=`echo "$p" | zzminusculas` ; [ "$word" ] && p="\b$p\b"
grep $ic $word "$p" $arq | ([ "$ic" ] && zzminusculas || cat -) | sed "s§$p§\\
$mask§g" | grep -c "^$mask"
}


# ----------------------------------------------------------------------------
# #### C Á L C U L O
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# calculadora: + - / * ^ %    # mais operadores, ver `man bc`
# obs.: números fracionados podem vir com vírgulas ou pontos: 1,5 ou 1.5
# uso: zzcalcula número operação número
# ex.: zzcalcula 2,1 / 3,5
#      zzcalcula '2^2*(4-1)'  # 2 ao quadrado vezes 4 menos 1
# ----------------------------------------------------------------------------
zzcalcula(){ zzzz -z $1 zzcalcula && return
[ "$1" ] && echo "scale=2;$*" | sed y/,/./ | bc | sed y/./,/ ; }



# ----------------------------------------------------------------------------
# soma dois horários
# uso: zzsomahora horário1 horário2
# ex.: zzsomahora 12:37 08:45
# ----------------------------------------------------------------------------
zzsomahora(){ zzzz -z $1 zzsomahora && return
[ "$1" ] || { echo "uso: zzsomahora 12:37 08:45"; return; }
local h1 h2 m1 m2 H M
h1=${1%:*}; m1=${1#*:}; h2=${2%:*}; m2=${2#*:} # $h1:$m1 $h2:$m2
h1=${h1#0}; m1=${m1#0}; h2=${h2#0}; m2=${m2#0} # s/^0//
M=$((m1+m2)); H=$((h1+h2+M/60)); M=$((M%60))   # min, hrs, min_sobra
printf "%02d:%02d\n" $H $M
}


# ----------------------------------------------------------------------------
# faz cálculos com datas e/ou converte data->num e num->data
# Que dia vai ser daqui 45 dias? Quantos dias há entre duas datas? zzdata!
# Quando chamada com apenas um parâmetro funciona como conversor de data
# para número inteiro (N dias passados desde Epoch) e vice-versa.
# obs.: Leva em conta os anos bissextos     (Epoch = 01/01/1970, editável)
# uso: zzdata data|num [+|- data|num]
# ex.: zzdata 22/12/1999 + 69
#      zzdata hoje - 5
#      zzdata 01/03/2000 - 11/11/1999
# ----------------------------------------------------------------------------
zzdata(){ zzzz -z $1 zzdata && return
[ $# -eq 3 -o $# -eq 1 ] || { echo 'zzdata data|num [+|- data|num]'; return; }
local yyyy mm dd n1 n2 days d i n isd1=1 d1=$1 oper=$2 d2=$3 epoch=1970
local NUM n1=$d1 n2=$d2 months='31 28 31 30 31 30 31 31 30 31 30 31'
for d in $d1 $d2; do NUM=0 ; [ "$d" = 'hoje' -o "$d" = 'today' ] &&
 { d=`date +%d/%m/%Y` ; [ "$isd1" ] && d1=$d || d2=$d ; }   # get 'today'
 if [ "$d" != "${d#*/}" ]; then n=1 ; y=$epoch              # --date2num--
  yyyy=${d##*/};dd=${d%%/*};mm=${d#*/};mm=${mm%/*};mm=${mm#0};dd=${dd#0}
  op=+; [ $yyyy -lt $epoch ] && op=-; while :; do days=365  # year2num
  [ $((y%4)) -eq 0 ]&&[ $((y%100)) -ne 0 ]||[ $((y%400)) -eq 0 ] && days=366
    [ $y -eq $yyyy ] && break; NUM=$((NUM $op days)); y=$((y $op 1)); done
  for i in $months; do [ $n -eq $mm ] && break; n=$((n+1))  # month2num
    [ $days -eq 366 -a $i -eq 28 ] && i=29 ; NUM=$((NUM+$i)); done
  NUM=$((NUM+dd-1)); [ "$isd1" ] && n1=$NUM || n2=$NUM      # day2num (-1)
 fi ; isd1= ; done ; NUM=$(($n1 $oper $n2))                 # calculate N
[ "${d1##??/*}" = "${d2##??/*}" ] && { echo $NUM; return; } # show num?
y=$epoch; mm=1 ; dd=$((NUM+1)); while :; do days=365        # num2year
  [ $((y%4)) -eq 0 ]&&[ $((y%100)) -ne 0 ]||[ $((y%400)) -eq 0 ] && days=366
  [ $dd -le $days ] && break; dd=$((dd-days)); y=$((y+1)); done; yyyy=$y
for i in $months; do [ $days -eq 366 -a $i -eq 28 ] && i=29 # num2month
  [ $dd -le $i ] && break; dd=$((dd-i)); mm=$((mm+1)); done # then pad&show
[ $dd -le 9 ] && dd=0$dd ; [ $mm -le 9 ] && mm=0$mm ; echo $dd/$mm/$yyyy
}


# ----------------------------------------------------------------------------
# faz várias conversões como: caracteres, temperatura e distância
#          cf = (C)elsius      para (F)ahrenheit
#          fc = (F)ahrenheit   para (C)elsius
#          km = (K)Quilômetros para (M)ilhas
#          mk = (M)ilhas       para (K)Quilômetros
#          db = (D)ecimal      para (B)inário
#          bd = (B)inário      para (D)ecimal
#          cd = (C)aractere    para (D)ecimal
#          dc = (D)ecimal      para (C)aractere
# uso: zzconverte <cf|fc|mk|km|db|bd|cd> número
# ex.: zzconverte cf 5
#      zzconverte dc 65
#      zzconverte db 32
# ----------------------------------------------------------------------------
zzconverte(){ zzzz -z $1 zzconverte && return
[ "$1" = "cf" ] && echo "$2 C = $(echo "scale=2;($2*9/5)+32" | bc) F"
[ "$1" = "fc" ] && echo "$2 F = $(echo "scale=2;($2-32)*5/9" | bc) C"
[ "$1" = "km" ] && echo "$2 km = $(echo "scale=2;$2*0.6214" | bc) milhas"
[ "$1" = "mk" ] && echo "$2 milhas = $(echo "scale=2;$2*1.609" | bc) km"
[ "$1" = "db" ] && echo "obase=2;$2" | bc -l
[ "$1" = "bd" ] && echo "$((2#$2))"
[ "$1" = "cd" ] && echo -n "$2" | od -d | sed -n '1s/^.* \+//p'
[ "$1" = "dc" ] && awk "BEGIN {printf(\"%c\n\",$2)}"
}


#-----------8<------------daqui pra baixo: FUNÇÕES QUE FAZEM BUSCA NA INTERNET
#-------------------------podem parar de funcionar se as páginas mudarem


# ----------------------------------------------------------------------------
# #### C O N S U L T A S                                         (internet)
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# http://br.invertia.com
# busca a cotação do dia do dólar (comercial, paralelo e turismo)
# obs.: as cotações são atualizadas de 10 em 10 minutos
# uso: zzdolar
# ----------------------------------------------------------------------------
zzdolar(){ zzzz -z $1 zzdolar && return
$ZZWWWDUMP 'http://br.invertia.com/mercados/divisas/tiposdolar.asp' |
sed 's/^ *//;/Data:/,/Turismo/!d;/percent/d;s/  */ /g
     s/.*Data: \(.*\)/\1 compra   venda   hora/;s|^[1-9]/|0&|;
     s,^\([0-9][0-9]\)/\([0-9]/\),\1/0\2,
     s/^D.lar \|- Corretora//g;s/ [-+]\?[0-9.]\+ %$//
     s/al /& /;s/lo /&   /;s/mo /&    /;s/ \([0-9]\) / \1.000 /
     s/\.[0-9]\>/&0/g;s/\.[0-9][0-9]\>/&0/g;/^[^0-9]/s/[0-9] /&  /g'
}


# ----------------------------------------------------------------------------
# http://www.receita.fazenda.gov.br
# consulta os lotes de restituição do imposto de renda
# OBS.: funciona para os anos de 2001, 2002 e 2003
# uso: zzirpf ano número-cpf
# ex.: zzirpf 2003 123.456.789-69
# ----------------------------------------------------------------------------
zzirpf(){ zzzz -z $1 zzirpf && return
[ "$2" ] || { echo 'uso: zzirpf ano número-cpf'; return; }
local ano=$1 URL='http://www.receita.fazenda.gov.br/Scripts/srf/irpf'
z=${ano#200} ; [ "$z" != 1 -a "$z" != 2 -a "$z" != 3 ] && {
echo "Ano inválido '$ano'. Deve ser 2001 ou 2002."; return; }
$ZZWWWDUMP "$URL/$ano/irpf$ano.dll?VerificaDeclaracao&CPF=$2" |
sed '1,8d;s/^ */  /;/^  \[BUTTON\]$/d'
}


# ----------------------------------------------------------------------------
# http://www.terra.com.br/cep
# busca o CEP de qualquer rua de qualquer cidade do país ou vice-versa
# uso: zzcep cidade nome-da-rua  OU  zzcep CEP
# ex.: zzcep curitiba rio gran
#      zzcep 'Rio de Janeiro' Vinte de
#      zzcep 80620-150
# ----------------------------------------------------------------------------
zzcep(){ zzzz -z $1 zzcep && return
[ "$1" ] || { echo 'uso: zzcep cidade nome-da-rua  OU  zzcep CEP'; return; }
local r c q="_textCEP=$1&_b_cep.x=1" ; [ "$2" ] && {
c=`echo "$1"| sed "$ZZSEDURL"`; shift; r=`echo "$*"| sed "$ZZSEDURL"`
q="_textCidade=$c&_textRua=$r&_b_r_c.x=1&_b_r_c=Busca"; }
echo "$q" | $ZZWWWPOST 'http://www.terra.com.br/cep/ceps.cgi' | sed '1,2d;$d;
s/^ *//;/^Mapas (opcional):$/{N;N;d;};/^\[USEMAP:modo\.gif\]$/{N;d;};s/^/  /'
}


# ----------------------------------------------------------------------------
# http://www.pr.gov.br/detran
# consulta débitos do veículo, como licenciamento, IPVA e multas (detran-PR)
# uso: zzdetranpr número-renavam
# ex.: zzdetranpr 123456789
# ----------------------------------------------------------------------------
zzdetranpr(){ zzzz -z $1 zzdetranpr && return
[ "$1" ] || { echo 'uso: zzdetranpr número-renavam'; return; }
local URL='http://celepar7.pr.gov.br/detran/consultas/veiculos/deb_novo.asp';
$ZZWWWDUMP "$URL?renavam=$1" | sed 's/^  *//;/^\(___*\)\?$/d; /^\[/d;
1,/^\(Renavam\|Data\):/{//!d;}; /^Resumo das Multas\|^Voltar$/,$d;
/^AUTUAÇ/,${/^Infração:/!d;s///;}; /^\(Discrimi\|Informa\)/s/.*//;
/^Placa/s/^[^:]*: \([A-Z0-9-]\+\).*:/\1 ano/; /^\(Marca\|Munic\)/s/[^:]*: //;
s|^\(.*\) \([0-9]\+,[0-9]\{2\}\|\*\*\* QUITADO \*\*\*\)|\2 \1|;'
}

# ----------------------------------------------------------------------------
# http://www.detran.sp.gov.br
# consulta débitos do veículo, como licenciamento, IPVA e multas (detran-SP)
# uso: zzdetransp número-renavam
# ex.: zzdetransp 123456789
# ----------------------------------------------------------------------------
zzdetransp(){ zzzz -z $1 zzdetransp && return
[ "$1" ] || { echo 'uso: zzdetransp número-renavam'; return; }
local URL='http://sampa5.prodam.sp.gov.br/multas/c_multas.asp'; echo
echo "text1=$1" | $ZZWWWPOST "$URL" | sed 's/^ *//;/^Resultado/,/^Última/!d;
/^___\+$/s/.*/_____/; /^Resultado/s/.* o Ren/Ren/;
/^Seq /,/^Total/{/^Seq/d;/^Total/!s/^/+++/;};
/Última/{G;s/\n//;s/\n_____\(\n\)$/\1/;s/^[^:]\+/Data   /;p;};H;d' |
sed '/^+++/{H;g;s/^\(\n\)+++[0-9]\+ \(...\)\(....\) \([^ ]\+ \)\{2\}\(.*\) \('$ZZERDATA' '$ZZERHORA'\) \(.*\) \('$ZZERDATA' .*\)/Placa: \2-\3\nData : \6\nLocal: \7\nInfr.: \5\nMulta: \8\n/;}'
}



# ----------------------------------------------------------------------------
# #### P R O G R A M A S                                         (internet)
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# http://freshmeat.net
# procura por programas na base do freshmeat
# uso: zzfreshmeat programa
# ex.: zzfreshmeat tetris
# ----------------------------------------------------------------------------
zzfreshmeat(){ zzzz -z $1 zzfreshmeat && return
[ "$1" ] || { echo 'uso: zzfreshmeat programa'; return; }
$ZZWWWLIST "http://freshmeat.net/search/?q=$1" |
sed -n '/^ *© Copyright/,${s,^.* ,,;\|meat\.net/projects/|s,/$,,gp;}' | uniq
}



# ----------------------------------------------------------------------------
# http://rpmfind.net/linux
# procura por pacotes RPM em várias distribuições
# obs.: a arquitetura padrão de procura é a i386
# uso: zzrpmfind pacote [distro] [arquitetura]
# ex.: zzrpmfind sed
#      zzrpmfind lilo mandr i586
# ----------------------------------------------------------------------------
zzrpmfind(){ zzzz -z $1 zzrpmfind && return
[ "$1" ] || { echo 'uso: zzrpmfind pacote [distro] [arquitetura]'; return; }
local URL='http://rpmfind.net/linux/rpm2html/search.php'
echozz 'ftp://rpmfind.net/linux/'
$ZZWWWLIST "$URL?query=$1&submit=Search+...&system=$2&arch=${3:-i386}" |
sed -n '\,ftp://rpmfind,s,^[^A-Z]*/linux/,  ,p' | sort
}



# ----------------------------------------------------------------------------
# #### D I V E R S O S                                           (internet)
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# http://www.iana.org/cctld/cctld-whois.htm
# busca a descrição de um código de país da internet (.br, .ca etc)
# obs.: o sed deve suportar o I de ignorecase na pesquisa
# uso: zzdominiopais [.]código|texto
# ex.: zzdominiopais .br
#      zzdominiopais br
#      zzdominiopais republic
# ----------------------------------------------------------------------------
zzdominiopais(){ zzzz -z $1 zzdominiopais && return
[ "$1" ] || { echo 'uso: zzdominiopais [.]código|texto'; return; }
local i1 i2 a='/usr/share/zoneinfo/iso3166.tab' p=${1#.}
[ $1 != $p ] && { i1='^'; i2='^\.'; }
[ -f $a ] && { echozz 'local:'; sed "/^#/d;/$i1$p/I!d" $a; }
local URL=http://www.iana.org/cctld/cctld-whois.htm ; echozz 'www  :'
$ZZWWWDUMP "$URL" | sed -n "s/^ *//;1,/^z/d;/^__/,$ d;/$i2$p/Ip"
}


# ----------------------------------------------------------------------------
# http://pgp.dtype.org:11371
# busca a identificação da chave PGP, fornecido o nome ou email da pessoa.
# obs.: de brinde, instruções de como adicionar a chave a sua lista.
# uso: zzchavepgp nome|email
# ex.: zzchavepgp Carlos Oliveira da Silva
#      zzchavepgp carlos@dominio.com.br
# ----------------------------------------------------------------------------
zzchavepgp(){ zzzz -z $1 zzchavepgp && return
[ "$1" ] || { echo 'uso: zzchavepgp nome|email'; return; }
local id TXT=`echo "$*"| sed "$ZZSEDURL"` URL='http://pgp.dtype.org:11371'
$ZZWWWDUMP "$URL/pks/lookup?search=$TXT&op=index" | sed '/^Type /,$!d;$G' |
tee /dev/stderr | sed -n 's,^[^/]*/\([0-9A-F]\+\) .*,\1,p' | while read id; do
[ "$id" ] && echo "adicionar: gpg --recv-key $id && gpg --list-keys $id"; done
}


# ----------------------------------------------------------------------------
# http://www.dicas-l.unicamp.br
# procura por dicas sobre determinado assunto na lista Dicas-L
# obs.: as opções do grep podem ser usadas (-i já é padrão)
# uso: zzdicasl [opção-grep] palavra(s)
# ex.: zzdicasl ssh
#      zzdicasl -w vi
#      zzdicasl -vEw 'windows|unix|emacs'
# ----------------------------------------------------------------------------
zzdicasl(){ zzzz -z $1 zzdicasl && return
[ "$1" ] || { echo 'uso: zzdicasl [opção-grep] palavra(s)'; return; }
local o URL='http://www.dicas-l.unicamp.br'; [ "${1##-*}" ] || { o=$1; shift; }
echozz "$URL/dicas-l/<DATA>.shtml"; $ZZWWWHTML "$URL/dicas-l" |
sed '/^<LI><A HREF=/!d;s///;s/\.shtml>//;s,</A>,,' | grep -i $o "$*"
}


# ----------------------------------------------------------------------------
# http://registro.br
# whois da fapesp para domínios brasileiros
# uso: zzwhoisbr domínio
# ex.: zzwhoisbr abc.com.br
#      zzwhoisbr www.abc.com.br
# ----------------------------------------------------------------------------
zzwhoisbr(){ zzzz -z $1 zzwhoisbr && return
[ "$1" ] || { echo 'uso: zzwhoisbr domínio'; return; }
local dom="${1#www.}" URL='http://registro.br/cgi-bin/nicbr/whois'
$ZZWWWDUMP "$URL?qr=$dom" | sed '1,/^%/d;/^remarks/,$d;/^%/d;
/^alterado\|atualizado\|status\|servidor \|último /d'
}


# ----------------------------------------------------------------------------
# http://www.ibiblio.org
# procura de documentos HOWTO
# uso: zzhowto palavra | --atualiza
# ex.: zzhowto apache
#      zzhowto --atualiza
# ----------------------------------------------------------------------------
zzhowto(){ zzzz -z $1 zzhowto && return
[ "$1" ] || { echo 'uso: zzhowto [--atualiza] palavra'; return; }
local URL z=$1 arq=$ZZTMP.howto
URL='http://www.ibiblio.org/pub/Linux/docs/HOWTO/other-formats/html_single/'
[ "$z" = '--atualiza' ] && { rm -f $arq ; z='' ; }
[ -s "$arq" ] || { echo -n 'AGUARDE. Atualizando listagem...'
  $ZZWWWHTML "$URL" | sed -n '/ALT="\[TXT\]"/{
  s/^.*HREF="\([^"]*\).*/\1/;p;}' > $arq ; echo ' feito!' ; }
[ "$z" ] && grep -i "$z" $arq | sed "s,^,$URL,"
}


# ----------------------------------------------------------------------------
# http://... - vários
# busca as últimas notícias sobre linux em páginas nacionais.
# obs.: cada página tem uma letra identificadora que pode ser passada como
#       parâmetro, identificando quais páginas você quer pesquisar:
#
#         R)evista do linux    I)nfoexame
#         O)linux              linux in braZ)il
#         ponto B)r            T)chelinux
#         C)ipsga              N)otícias linux
#
# uso: zznoticiaslinux [sites]
# ex.: zznoticiaslinux
#      zznoticiaslinux rci
# ----------------------------------------------------------------------------
zznoticiaslinux(){ zzzz -z $1 zznoticiaslinux && return
local URL limite n=5 s='brotcizn'; limite="sed ${n}q"; [ "$1" ] && s="$1"
[ "$s" != "${s#*r}" ] && { URL='http://www.RevistaDoLinux.com.br'
  echo ; echozz "* RdL ($URL):"; $ZZWWWHTML $URL |
  sed '/^<.*class=noticias><b>/!d;s///;s,</b>.*,,' | $limite; }
[ "$s" != "${s#*o}" ] && { URL='http://olinux.uol.com.br/home.html'
  echo ; echozz "* OLinux ($URL):"; $ZZWWWDUMP $URL |
  sed 's/^ *//;/^\[.*ÚLTIMAS/,/^\[.*CHAT /!d;/^\[/d;/^$/d' | $limite; }
[ "$s" != "${s#*b}" ] && { URL='http://pontobr.org'
  echo ; echozz "* .BR ($URL):"; $ZZWWWHTML $URL |
  sed '/class="\(boldtext\|type4bigger\)"/!d;s/<[^>]*>//g;s/^[[:blank:]]*//'|
  $limite; }
[ "$s" != "${s#*c}" ] && { URL='http://www.cipsga.org.br'
  echo ; echozz "* CIPSGA ($URL):"; $ZZWWWHTML $URL |
  sed '/^.*<tr><td bgcolor="88ccff"><b>/!d;s///;s,</b>.*,,' | $limite; }
[ "$s" != "${s#*z}" ] && { URL='http://brlinux.linuxsecurity.com.br/noticias/'
  echo ; echozz "* Linux in Brazil ($URL):"; $ZZWWWDUMP $URL |
  sed -n 's/^ *//;/.org - Publicado por/{x;p;};h' | $limite; }
[ "$s" != "${s#*i}" ] && { URL='http://info.abril.com.br'
  echo ; echozz "* InfoExame ($URL):"; $ZZWWWDUMP $URL |
  sed 's/^ *//;/^últimas/,/^download/s/^\[[^]]*]  //p;d' | $limite; }
[ "$s" != "${s#*t}" ] && { URL='http://www.tchelinux.com.br'
  echo ; echozz "* TcheLinux ($URL):"; $ZZWWWDUMP "$URL/backend.php" |
  sed '/<title>/!d;s/ *<[^>]*>//g;/^Tchelinux$/d' | $limite; }
[ "$s" != "${s#*n}" ] && { URL='http://www.noticiaslinux.com.br'
  echo ; echozz "* Notícias Linux ($URL):"; $ZZWWWDUMP "$URL" |
  sed '/^[0-9][0-9]h[0-9][0-9]min/!d;s///;s/...//' | $limite; }
}


# ----------------------------------------------------------------------------
# http://... - vários
# busca as últimas notícias sobre linux em páginas em inglês.
# obs.: cada página tem uma letra identificadora que pode ser passada como
#       parâmetro, identificando quais páginas você quer pesquisar:
#
#          F)reshMeat         Linux D)aily News
#          S)lashDot          Linux W)eekly News
#          N)ewsForge         O)S News
#
# uso: zzlinuxnews [sites]
# ex.: zzlinuxnews
#      zzlinuxnews fsn
# ----------------------------------------------------------------------------
zzlinuxnews(){ zzzz -z $1 zzlinuxnews && return
local URL limite n=5 s='fsndwo'; limite="sed ${n}q"; [ "$1" ] && s="$1"
[ "$s" != "${s#*f}" ] && { URL='http://freshmeat.net'
  echo ; echozz "* FreshMeat ($URL):"; $ZZWWWHTML $URL |
  sed '/href="\/releases/!d;s/<[^>]*>//g;s/&nbsp;//g;s/^ *- //' | $limite ; }
[ "$s" != "${s#*s}" ] && { URL='http://slashdot.org'
  echo ; echozz "* SlashDot ($URL):"; $ZZWWWHTML $URL |
  sed '/^[[:blank:]]*FACE="arial,helv/!d;s/^[^>]*>//;s/<[^>]*>//g
       s/&quot;/"/g'| $limite ;}
[ "$s" != "${s#*n}" ] && { URL='http://newsforge.net'
  echo ; echozz "* NewsForge - ($URL):"; $ZZWWWHTML $URL |
  sed '/<FONT SIZE="-1">/!d;s/<[^>]*>//g' | $limite ; }
[ "$s" != "${s#*d}" ] && { URL='http://www.linuxdailynews.com'
  echo ; echozz "* Linux Daily News ($URL):"; $ZZWWWHTML $URL |
  sed '/color="#101073">/!d;s,</b>.*,,;s/^.*<b> *//;s,</\?i>,,g' | $limite ; }
[ "$s" != "${s#*w}" ] && { URL='http://lwn.net/Articles'
  echo ; echozz "* Linux Weekly News - ($URL):"; $ZZWWWHTML $URL |
  sed '/class="Headline"/!d;s/^ *//;s/<[^>]*>//g' | $limite ; }
[ "$s" != "${s#*o}" ] && { URL='http://osnews.com'
  echo ; echozz "* OS News - ($URL):"; $ZZWWWDUMP $URL |
  sed -n 's/^ *Read similar articles   *//p' | $limite ; }
}



# ----------------------------------------------------------------------------
# http://... - vários
# busca as últimas notícias em sites especializados em segurança.
# obs.: cada página tem uma letra identificadora que pode ser passada como
#       parâmetro, identificando quais páginas você quer pesquisar:
#
#       Linux Security B)rasil    Linux T)oday - Security
#       Linux S)ecurity           Security F)ocus
#       C)ERT/CC
#
# uso: zznoticiassec [sites]
# ex.: zznoticiassec
#      zznoticiassec bcf
# ----------------------------------------------------------------------------
zznoticiassec(){ zzzz -z $1 zznoticiassec && return
local URL limite n=5 s='bsctf'; limite="sed ${n}q"; [ "$1" ] && s="$1"
[ "$s" != "${s#*b}" ] && { URL='http://www.linuxsecurity.com.br/share.php'
  echo ; echozz "* LinuxSecurity Brasil ($URL):"; $ZZWWWDUMP $URL |
  sed -n '/item/,$s,.*<title>\(.*\)</title>,\1,p' | $limite ; }
[ "$s" != "${s#*s}" ] && {
  URL='http://www.linuxsecurity.com/linuxsecurity_advisories.rdf'
  echo ; echozz "* Linux Security ($URL):"; $ZZWWWDUMP $URL |
  sed -n '/item/,$s,.*<title>\(.*\)</title>,\1,p' | $limite ; }
[ "$s" != "${s#*c}" ] && { URL='http://www.cert.org/channels/certcc.rdf'
  echo ; echozz "* CERT/CC ($URL):"; $ZZWWWDUMP $URL |
  sed -n '/item/,$s,.*<title>\(.*\)</title>,\1,p' | $limite ; }
[ "$s" != "${s#*t}" ] && { URL='http://linuxtoday.com/security/index.html'
  echo ; echozz "* Linux Today - Security ($URL):"; $ZZWWWHTML $URL |
  sed -n '/class="nav"><B>/s/<[^>]*>//gp' | $limite ; }
[ "$s" != "${s#*f}" ] && { URL='http://www.securityfocus.com/bid'
  echo ; echozz "* SecurityFocus Vulns Archive ($URL):"; $ZZWWWDUMP $URL |
  sed -n 's/^ *\([0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\)/\1/p' | $limite ; }
}



# ----------------------------------------------------------------------------
# http://google.com
# retorna apenas os títulos e links do resultado da pesquisa no Google
# uso: zzgoogle [-n <número>] palavra(s)
# ex.: zzgoogle receita de bolo de abacaxi
#      zzgoogle -n 5 ramones papel higiênico cachorro
# ----------------------------------------------------------------------------
zzgoogle(){ zzzz -z $1 zzgoogle && return
[ "$1" ] || { echo 'uso: zzgoogle [-n <número>] palavra(s)'; return; }
local TXT n=10 URL='http://www.google.com.br/search'
[ "$1" = '-n' ] && { n=$2; shift; shift; }
TXT=`echo "$*"| sed "$ZZSEDURL"` ; [ "$TXT" ] || return 0
$ZZWWWHTML "$URL?q=$TXT&num=$n&ie=ISO-8859-1&hl=pt-BR" |
sed '/<p class=g>/!d;s|.*<p class=g>||;s|</a><br>.*||;h
s|^<[^>]*>||;s|</\?b>||g;s|</a>.*||;x;s|^<a href=|  |;s|>.*||;H;g;s|.*||;H;g'
## label                            # url                         # blank
}


# ----------------------------------------------------------------------------
# http://letssingit.com
# busca letras de músicas, procurando pelo nome da música
# obs.: se encontrar mais de uma, mostra a lista de possibilidades
# uso: zzletrademusica texto
# ex.: zzletrademusica punkrock
#      zzletrademusica kkk took my baby
# ----------------------------------------------------------------------------
zzletrademusica(){ zzzz -z $1 zzletrademusica && return
[ "$1" ] || { echo 'uso: zzletrademusica texto'; return; }
local txt=`echo "$*"|sed "$ZZSEDURL"` URL=http://letssingit.com/cgi-exe/am.cgi
$ZZWWWDUMP "$URL?a=search&p=1&s=$txt&l=song" | sed -n '
s/^ *//;/^artist /,/Page :/p;/^Artist *:/,${/IFRAME\|^\[params/d;p;}'
}


# ----------------------------------------------------------------------------
# http://tudoparana.globo.com/gazetadopovo/cadernog/tv.html
# consulta a programação do dia dos canais abertos da TV
# pode-se passar os canais e o horário que se quer consultar
#   Identificadores: B)and, C)nt, E)ducativa, G)lobo, R)ecord, S)bt, cU)ltura
# uso: zztv canal [horário]
# ex.: zztv bsu 19       # band, sbt e cultura, depois das 19:00
#      zztv . 00         # todos os canais, depois da meia-noite
#      zztv .            # todos os canais, o dia todo
# ----------------------------------------------------------------------------
zztv(){ zzzz -z $1 zztv && return
[ "$1" ] || { echo 'uso: zztv canal [horário]  (ex. zztv bs 22)'; return; }
local c h URL=http://tudoparana.globo.com/gazetadopovo/cadernog/sess-21.html
h=`echo $2|sed 's/^\(..\).*/\1/;s/[^0-9]//g'` ; h="($h|$((h+1))|$((h+2)))"
h=`echo $h|sed 's/24/00/;s/25/01/;s/26/02/;s/\<[0-9]\>/0&/g;s,[(|)],\\\\&,g'`
c=`echo $1|sed 's/b/2,/;s/s/4,/;s/c/6,/;s/r/7,/;s/u/9,/;s/g/12,/;s/e/59,/
s/,$//;s@,@\\\\|@g'`; c=$(echo $c | sed 's/^\.$/..\\?/'); $ZZWWWDUMP $URL |
sed -e 's/^ *//;s/[Cc][Aa][Nn][Aa][Ll]/CANAL/;/^[012C]/!d;/^C[^A]/d;/^C/i \'\
    -e . | sed "/^CANAL \($c\) *$/,/^.$/!d;/^C/,/^$h/{/^C\|^$h/!d;};s/^\.//"
}


# ----------------------------------------------------------------------------
# http://www.acronymfinder.com
# dicionário de siglas, sobre qualquer assunto (como DVD, IMHO, OTAN, WYSIWYG)
# obs.: há um limite diário de consultas (10 acho)
# uso: zzsigla sigla
# ex.: zzsigla RTFM
# ----------------------------------------------------------------------------
zzsigla(){ zzzz -z $1 zzsigla && return
[ "$1" ] || { echo 'uso: zzsigla sigla'; return; }
local URL=http://www.acronymfinder.com/af-query.asp
$ZZWWWDUMP "$URL?String=exact&Acronym=$1&Find=Find" |
sed -n 's/^ *//;s/ *\[go\.gif] *$//p'
}



# ----------------------------------------------------------------------------
# http://cheetah.eb.com
# toca um .wav que contém a pronúncia correta de uma palavra em inglês
# uso: zzpronuncia palavra
# ex.: zzpronuncia apple
# ----------------------------------------------------------------------------
zzpronuncia(){ zzzz -z $1 zzpronuncia && return
[ "$1" ] || { echo 'uso: zzpronuncia palavra'; return; }
local URL URL2 arq dir tmpwav="$ZZTMP.$1.wav"
URL='http://www.m-w.com/cgi-bin/dictionary' URL2='http://cheetah.eb.com/sound'
[ -f "$tmpwav" ] || {
  arq=`$ZZWWWHTML "$URL?va=$1" | sed "/wav=$1/!d;s/wav=$1'.*/wav/;s/.*?//"`
  [ "$arq" ] || { echo "$1: palavra não encontrada"; return; }
  dir=`echo $arq | sed 's/^\(.\).*/\1/'`
  WAVURL="$URL2/$dir/$arq" ; echo "URL: $WAVURL"
  $ZZWWWHTML "$WAVURL" > $tmpwav ; echo "Gravado o arquivo '$tmpwav'" ; }
play $tmpwav
}



# ----------------------------------------------------------------------------
# http://www.nextel.com.br
# envia uma mensagem para um telefone NEXTEL (via rádio)
# obs.: o número especificado é o número próprio do telefone (não o ID!)
# uso: zznextel de para mensagem
# ex.: zznextel aurélio 554178787878 minha mensagem mala
# ----------------------------------------------------------------------------
zznextel(){ zzzz -z $1 zznextel && return
[ "$3" ] || { echo 'uso: zznextel de para mensagem'; return; }
local from="$1" to="$2" URL=http://page.nextel.com.br/cgi-bin/sendPage_v3.cgi
shift; shift; local subj=zznextel msg=`echo "$*"| sed "$ZZSEDURL"`
echo "to=$to&from=$from&subject=$subj&message=$msg&count=0&Enviar=Enviar" |
$ZZWWWPOST "$URL" | sed '1,/^ *CENTRAL/d;s/.*Individual/ /;N;q'
}



# ----------------------------------------------------------------------------
# #### T R A D U T O R E S   e   D I C I O N Á R I O S           (internet)
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# http://babelfish.altavista.digital.com
# faz traduções de palavras/frases/textos em português e inglês
# uso: zzdicbabelfish [i] texto
# ex.: zzdicbabelfish my dog is green
#      zzdicbabelfish i falcão detona!
# ----------------------------------------------------------------------------
zzdicbabelfish(){ zzzz -z $1 zzdicbabelfish && return
[ "$1" ] || { echo 'uso: zzdicbabelfish [i] palavra(s)'; return; }
local URL='http://babelfish.altavista.com/babelfish/tr' L=en_pt FIM='^<\/div>'
local INI='^.*<Div style=padding[^>]*>'; [ "$1" = 'i' ] && { shift; L=pt_en; }
local TXT=`echo "$*"| sed "$ZZSEDURL"`
$ZZWWWHTML "$URL?doit=done&tt=urltext&intl=1&urltext=$TXT&lp=$L" |
sed -n "/$INI/,/$FIM/{/$FIM\|^$/d;/$INI/{s/<[^>]*>//g;p;};}"
}


# ----------------------------------------------------------------------------
# http://www.babylon.com
# tradução de palavras em inglês para um monte de idiomas:
# francês, alemão, japonês, italiano, hebreu, espanhol, holandês e
# português. o padrão é o português, é claro.
# uso: zzdicbabylon [idioma] palavra
# ex.: zzdicbabylon hardcore
#      zzdicbabylon jap tree
# ----------------------------------------------------------------------------
zzdicbabylon(){ zzzz -z $1 zzdicbabylon && return
[ "$1" ] || { echo -e "zzdicbabylon [idioma] palavra
  idioma = fre ger jap ita heb spa dut ptg" && return; }
local L=ptg ; [ "$2" ] && L=$1 && shift
$ZZWWWDUMP "http://www.babylon.com/trans/bwt.cgi?$L$1" |
sed '1,4d;s/^ *//;/^\($\|_\+\)/d;s/^/  /'
}


# ----------------------------------------------------------------------------
# http://www.dictionary.com
# definições de palavras em inglês, com pesquisa em *vários* bancos de dados
# uso: zzdicdict palavra
# ex.: zzdicdict hardcore
# ----------------------------------------------------------------------------
zzdicdict(){ zzzz -z $1 zzdicdict && return
[ "$1" ] || { echo "zzdicdict palavra" && return; }
local INI='^ *Found [0-9]\+ entr\(y\|ies\)' FIM='^ *Try your search'
$ZZWWWDUMP -width=72 "http://www.dictionary.com/cgi-bin/dict.pl?db=*&term=$*"|
sed -n "/$INI/,/$FIM/{/$INI\|$FIM/d;p;}"
}




# ----------------------------------------------------------------------------
# http://www.academia.org.br/vocabula.htm
# dicionário da ABL - academia brasileira de letras
# uso: zzdicabl palavra
# ex.: zzdicabl cabeça-de-
# ----------------------------------------------------------------------------
zzdicabl(){ zzzz -z $1 zzdicabl && return
[ "$1" ] || { echo 'uso: zzdicabl palavra'; return; }
local URL='http://www.mtec.com.br/cgi-bin/abl/volta_abl_org.asp'
echo "palavra=$*" | $ZZWWWPOST $URL | sed '1,5d;/^ *\./,$d;s/^ */  /'
}


# ----------------------------------------------------------------------------
# http://www.portoeditora.pt/dol
# dicionário de português (de Portugal)
# uso: zzdicportugues palavra
# ex.: zzdicportugues bolacha
# ----------------------------------------------------------------------------
zzdicportugues(){ zzzz -z $1 zzdicportugues && return
[ "$1" ] || { echo 'uso: zzdicportugues palavra'; return; }
local URL='http://www.priberam.pt/DLPO/default.asp'
local INI='^Fo\(i\|ram\) encontrad' FIM='^Se tiver'
echo "pal=$1" | $ZZWWWPOST -width=80 "$URL" | sed -n "s/^ *//;/^$/d;
  s/\[transparent.gif]//;/$INI/,/$FIM/{/$INI\|$FIM/d;p;}"
}


# ----------------------------------------------------------------------------
# http://catb.org/jargon/
# dicionário de jargões de informática, em inglês
# uso: zzdicjargon palavra(s)
# ex.: zzdicjargon vi
#      zzdicjargon all your base are belong to us
# ----------------------------------------------------------------------------
zzdicjargon(){ zzzz -z $1 zzdicjargon && return
[ "$1" ] || { echo 'uso: zzdicjargon palavra'; return; }
local arq=$ZZTMP.jargonfile URL='http://catb.org/jargon/html'
local achei achei2 num mais TXT=`echo "$*" | sed 's/ /-/g'`
[ -s "$arq" ] || { echo -n 'AGUARDE. Atualizando listagem...'
  $ZZWWWLIST "$URL/lexicon.html" |
  sed '/^ *[0-9]\+\. /!d;s,.*/html/,,;/^[A-Z0]\//!d' > $arq ; }
achei=`grep -i "$TXT" $arq` ; num=`echo "$achei" | sed -n '$='`
[ "$achei" ] || return ; [ $num -gt 1 ] && { mais=$achei
  achei2=`echo "$achei" | grep -w "$TXT" | sed q`
  [ "$achei2" ] && achei="$achei2" && num=1 ; }
if [ $num -eq 1 ]; then $ZZWWWDUMP -width=72 "$URL/$achei" |
  sed '1,/_\{9\}/d;/_\{9\}/,$d' ; [ "$mais" ] && echozz '\nTermos parecidos:'
else echozz 'Achei mais de um! Escolha qual vai querer:' ; fi
[ "$mais" ] && echo "$mais" | sed 's/..//;s/\.html$//'
}


# ----------------------------------------------------------------------------
# usa todas as funções de dicionário e tradução de uma vez
# uso: zzdictodos palavra
# ex.: zzdictodos Linux
# ----------------------------------------------------------------------------
zzdictodos(){ zzzz -z $1 zzdictodos && return
[ "$1" ] || { echo 'uso: zzdictodos palavra'; return; }
local D ; for D in babelfish babylon jargon abl portugues dict
do echozz "zzdic$D:"; zzdic$D $1; done
}


# ----------------------------------------------------------------------------
# http://aurelio.net/doc/ramones.txt
# procura frases de letras de músicas do ramones
# uso: zzramones [palavra]
# ex.: zzramones punk
#      zzramones
# ----------------------------------------------------------------------------
zzramones(){ zzzz -z $1 zzramones && return
local txt n url='http://aurelio.net/doc/ramones.txt' arq=$ZZTMP.ramones
[ -s $arq ] || $ZZWWWDUMP "$url" > $arq ; txt=`grep -iw "${1:-.}" $arq`
n=`echo "$txt" | sed -n $=`; n=$((RANDOM%n)); echo "$txt" | sed -n ${n}p
}



# ----------------------------------------------------------------------------
## lidando com a chamada pelo executável

if [ "$1" ]; then
  if [ "$1" = '--help' -o "$1" = '-h' ]; then $0
  elif [ "$1" = '--version' -o "$1" = '-v' ]; then
    echo -n 'funções ZZ v'; zzzz | sed '/versã/!d;s/.* //'
  else
    func="zz${1#zz}" ; type $func >&- 2>&- || { # a função existe?
    echo "ERRO: a função '$func' não existe! (tente --help)"; exit 1; }
    shift ; $func $@                    # vai!
  fi

## chamando do executável sem argumentos (também para --help)
elif [ "${0%bash}" = "$0" ]; then
  echo "
uso: funcoeszz <função> [<parâmetros>]
     funcoeszz <função> --help


dica: inclua as funções ZZ no seu login shell,
      e depois chame-as diretamente pelo nome:

  prompt$ funcoeszz zzzz --bashrc
  prompt$ source ~/.bashrc
  prompt$ zz<TAB><TAB>

  Obs.: funcoeszz zzzz --tcshrc também funciona

lista das funções:
"
  zzzz | sed '1,/(( fu/d'
  exit 0
fi








