#!/bin/bash
# funcoeszz
# vim: noet noai tw=78
#
# INFORMAÇÕES: http://aurelio.net/zz
# NASCIMENTO : 22 fevereiro 2000
# AUTORES    : Aurélio Marinho Jargas <verde (a) aurelio net>
#              Thobias Salazar Trevisan <thobias (a) thobias org>
# DESCRIÇÃO  : Funções de uso geral para bash[12], que buscam informações em
#              arquivos locais e dicionários/tradutores/fontes na internet
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
#    !!    ** criada a página na Internet da funções
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
# 20031124 <> arrumado problema de várias funções em arquivos com espaços
#          <> echozz: arrumado problema de expansão do asterisco
#          <> cep: URL e filtro atualizados (agora só por endereço)
#          <> dicportugues: URL e filtro atualizados (valeu geraldo)
#          <> pronuncia: URL atualizada (valeu moyses)
#          <> linuxnews: N) filtro atualizado
#          <> dicjargon: URL atualizada
#          <> ramones: mostra mensagem quando atualiza dados
# 20040128 ++ hora, -- somahora (valeu victorelli)
#          ++ ZZCOR,ZZPATH,ZZTMPDIR: cfg via variáveis de ambiente (valeu rbp)
#          <> arrumanome: adicionadas opções -d e -r
#          <> arrumanome: arrumado bug DIR/ARQ de mesmo nome (valeu helio)
#          <> ss: arrumado bug com --rapido e --fundo (valeu ulysses)
#          <> ss: a frase não precisa mais das aspas
#          <> irpf: arrumada mensagem de erro (valeu rbp)
# 20040219 ++ tempo
#          <> beep: com parâmetros, agora serve de alarme
#          <> howto: saída melhorada, mais limpa
#          <> dicabl: URL atualizada (valeu leonardo)
#          <> ajuda: agora paginando com o $PAGER, se existir (valeu rbp)
#          <> echozz: arrumado bug de imprimir duplicado (valeu rbp)
#          <> configurações: arrumado bug do $ZZPATH (valeu nexsbr)
#          <> zzzz: --bashrc detecta comando 'source' ou '.'
#          <> zzzz: --bashrc adicionado "export ZZPATH"
# 20040329 ++ moeda, ++ horacerta
#          <> pronuncia: filtro atualizado (valeu roberto)
#          <> dicbabelfish: agora aceita vários idiomas (valeu rbp)
#          <> howto: agora pode passar parâmetro após --atualiza (valeu rbp)
#          <> trocapalavra: agora aceita '(' como primeiro parâmetro
#          <> dolar: filtro atualizado para tirar o 'SP'
#          <> linuxnews: O) filtro atualizado
# 20040518 ++ bovespa (valeu denis)
#          ++ loteria (valeu polidoro)
#          <> tv: URL atualizada (valeu matheus)
#          <> dicbabelfish: filtro atualizado (valeu rbp)
#          <> linuxnews: N) filtro atualizado
#
##############################################################################
#
#                                Configuração
#                                ------------
#
#
### Configuração via variáveis de ambiente
#
# Algumas variáveis de ambiente podem ser usadas para alterar o comportamento
# padrão das funções. Basta defini-las em seu .bashrc ou na própria linha de
# comando antes de chamar as funções. São elas:
#
#      $ZZCOR    - Liga/Desliga as mensagens coloridas (1 e 0)
#      $ZZPATH   - Caminho completo para o arquivo das funções
#      $ZZTMPDIR - Diretório para armazenar arquivos temporários
#
#
### Configuração fixa neste arquivo (hardcoded)
#
# A configuração também pode ser feita diretamente neste arquivo, se você
# puder fazer alterações nele.
#
ZZCOR_DFT=1                     # colorir mensagens? 1 liga, 0 desliga
ZZPATH_DFT=/usr/bin/funcoeszz   # rota absoluta deste arquivo
ZZTMPDIR_DFT=${TMPDIR:-/tmp}    # diretório temporário
#
#
##############################################################################
#
#                               Inicialização
#                               -------------
#
#
# Variáveis e funções auxiliares usadas pelas funções ZZ.
# Não altere nada aqui.
#
#
ZZWWWDUMP='lynx -dump      -nolist -crawl -width=300 -accept_all_cookies'
ZZWWWLIST='lynx -dump                     -width=300 -accept_all_cookies'
ZZWWWPOST='lynx -post-data -nolist -crawl -width=300 -accept_all_cookies'
ZZWWWHTML='lynx -source'
ZZERDATA='[0-9][0-9]\/[0-9][0-9]\/[0-9]\{4\}'; # dd/mm/aaa ou mm/dd/aaaa
ZZERHORA='[012][0-9]:[0-9][0-9]'
ZZSEDURL='s| |+|g;s|&|%26|g'
getczz(){ stty raw; eval $1="`dd bs=1 count=1 2>&-`"; stty cooked; }
echozz(){
  if [ "$ZZCOR" != '1' ]; then echo -e "$*" ; else
  echo -e "\033[36;1m$*"; echo -ne "\033[m" ; fi
}
seqzz(){
 local o=+ a=1 z=${1:-1}; [ "$2" ] && { a=$1; z=$2; } ; [ $a -gt $z ] && o=-
 while [ $a -ne $z ]; do echo $a ; eval "a=\$((a$o 1))"; done; echo $a
}
#
#
### Truques para descobrir a localização deste arquivo no sistema
#
# Se a chamada foi pelo executável, o arquivo é o $0.
# Senão, tenta usar a variável de ambiente ZZPATH, definida pelo usuário.
# Caso não exista, usa o local padrão ZZPATH_DFT.
# Finalmente, força que ZZPATH seja uma rota absoluta.
#
[ "${0##*/}" = 'bash' -o "${0#-}" != "$0" ] || ZZPATH="$0"
[ "$ZZPATH" ] || ZZPATH=$ZZPATH_DFT
[ "$ZZPATH" ] || echozz 'AVISO: $ZZPATH vazia. zzajuda e zzzz não funcionarão'
[ "${ZZPATH#/}" = "$ZZPATH" ] && ZZPATH="$PWD/${ZZPATH#./}"
#
### Últimos ajustes
#
ZZCOR="${ZZCOR:-$ZZCOR_DFT}"
ZZTMP="${ZZTMPDIR:-$ZZTMPDIR_DFT}/zz"
unset ZZCOR_DFT ZZPATH_DFT ZZTMPDIR_DFT
#
#
##############################################################################


# ----------------------------------------------------------------------------
# Mostra uma tela de ajuda com explicação e sintaxe de todas as funções
# Obs.: tátátá, é xunxo. Sou preguiçoso sim, e daí &:)
# Uso: zzajuda
# ----------------------------------------------------------------------------
zzajuda(){ zzzz -z $1 zzajuda && return
local pinte=: ; [ $ZZCOR = '1' -a "$PAGER" != 'less' ] &&
 pinte='s \<zz[a-z2]\+\> [36;1m&[m '
sed '1s/.*/*** ajuda das funções ZZ (tecla Q sai)/p;2g;2p;/^# --*$/,/^# --*$/{
s/^# //p;};d' $ZZPATH | uniq | sed "$pinte" | ${PAGER:-less -r}
}


# ----------------------------------------------------------------------------
# Mostra informações (como versão e localidade) sobre as funções
# Com a opção --atualiza, baixa a versão mais nova das funções
# Com a opção --bashrc, "instala" as funções no ~/.bashrc
# Com a opção --tcshrc, "instala" as funções no ~/.tcshrc
# Uso: zzzz [--atualiza|--bashrc|--tcshrc]
# ----------------------------------------------------------------------------
zzzz(){
[ "$1" = '-z' -a -z "${2#(}" ] && return 1  # zztrocapalavra '(' 'foo'
if [ "$1" = '-z' -o "$1" = '-h' -o "$1" = '--help' ]; then # -h)zzzz -z)resto
  [ "$1" = '-z' -a "$2" != '--help' -a "$2" != '-h' ] && return 1 #alarmefalso
  local pat="Uso: [^ ]*${3:-zzzz}"; zzajuda | grep -C9 "^$pat" | sed ":a
  ;$ bz;N;ba;:z;s/.*\n---*\(\n\)\(.*$pat\)/\1\2/;s/\(\n\)---.*/\1/"; return 0
fi
local rc vl vr URL='http://aurelio.net/zz' cfg="source $ZZPATH" cfgf=~/.bashrc
local cor='não'; [ "$ZZCOR" = '1' ] && cor='sim'; [ -f "$ZZPATH" ] || return
vl=`sed '/^$/{g;q;};/^# 200./!d;s/^# ...\(.\)\(....\).*/\1.\2/;h;d' $ZZPATH`
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
  if ! grep -q "^ *\(source\|\.\) .*funcoeszz" $cfgf;
  then (echo; echo "$cfg"; echo "export ZZPATH=$ZZPATH") >> $cfgf
        echo 'feito!'
  else  echo "as funções já estão no $cfgf!"; fi
elif [ "$1" = '--tcshrc' ]; then # cria aliases para as funções no /.tcshrc
  cfgf=~/.zzcshrc cfg="source $cfgf"; echo > $cfgf
  if ! grep -q "^ *$cfg" ~/.tcshrc; then echo "$cfg" >> ~/.tcshrc ; fi
  for func in `ZZCOR=0 zzzz | sed '1,/^(( fu/d;s/,//g'`; do
    echo "alias zz$func 'funcoeszz zz$func'" >> $cfgf;
  done; echo 'feito!'
else # mostra informações sobre as funçÕes
  rc='não instalado' ; grep -qs "^ *$cfg" $cfgf && rc="$cfgf"
  echozz "( local)\c"; echo " $ZZPATH"; echozz "(versão)\c"; echo " $vl"
  echozz "( cores)\c"; echo " $cor"; echozz "(   tmp)\c"; echo " $ZZTMP"
  echozz "(bashrc)\c"; echo " $rc"; echo
  echozz "( lista)\c"; echo ' zztabtab@yahoogrupos.com.br'
  echozz "(página)\c"; echo " $URL"
  [ "$ZZPATH" -a -f "$ZZPATH" ] && { echo; echozz '(( funções disponíveis ))'
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
# Aguarda N minutos e dispara uma sirene usando o 'speaker'
# Útil para lembrar de eventos próximos no mesmo dia
# Se não receber nenhum argumento, serve para restaurar o 'beep' da máquina
# para o seu tom e duração originais
# Obs.: a sirene tem 4 toques, sendo 2 tons no modo texto e apenas 1 no xterm
# Uso: zzbeep
#      zzbeep 0
#      zzbeep 1 5 15    # espere 1 minuto, depois mais 5, e depois 15
# ----------------------------------------------------------------------------
zzbeep(){ zzzz -z $1 zzbeep && return
[ "$1" ] || { echo -ne '\033[10;750]\033[11;100]\a'; return; }
for i in $*; do echo -n "Vou bipar em $i minutos... "; sleep $((i*60))
  echo -ne '\033[11;900]' # beep longo
  for freq in 500 400 500 400; do echo -ne "\033[10;$freq]\a"; sleep 1; done
  echo -ne '\033[10;750]\033[11;100]'; echo OK; shift; done
}


# ----------------------------------------------------------------------------
# Retira linhas em branco e comentários
# Para ver rapidamente quais opções estão ativas num arquivo de configuração
# Além do tradicional #, reconhece comentários de arquivos .vim
# Obs.: aceita dados vindos da ENTRADA PADRÃO (STDIN)
# Uso: zzlimpalixo [arquivo]
# Ex.: zzlimpalixo ~/.vimrc
#      cat /etc/inittab | zzlimpalixo
# ----------------------------------------------------------------------------
zzlimpalixo(){ zzzz -z $1 zzlimpalixo && return
local z='#'; case "$1" in *.vim|*.vimrc*)z='"';; esac
cat "${1:--}" | tr '\t' ' ' | sed "\,^ *\($z\|$\),d" | uniq
}


# ----------------------------------------------------------------------------
# Converte as letras do texto para minúsculas/MAIÚSCULAS, inclusive acentuadas
# Uso: zzmaiusculas [arquivo]
#      zzminusculas [arquivo]
# Ex.: zzmaiusculas /etc/passwd
#      echo NÃO ESTOU GRITANDO | zzminusculas
# ----------------------------------------------------------------------------
zzminusculas(){ zzzz -z $1 zzminusculas && return
sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
     y/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ/àáâãäåèéêëìíîïòóôõöùúûüçñ/' "$@"; }
zzmaiusculas(){ zzzz -z $1 zzmaiusculas && return
sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/
     y/àáâãäåèéêëìíîïòóôõöùúûüçñ/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ/' "$@"; }


# ----------------------------------------------------------------------------
# Retira as linhas repetidas (consecutivas ou não)
# Útil quando não se pode alterar a ordem original das linhas,
# Então o tradicional sort|uniq falha.
# Uso: zzuniq [arquivo]
# Ex.: zzuniq /etc/inittab
#      cat /etc/inittab | zzuniq
# ----------------------------------------------------------------------------
zzuniq(){ zzzz -z $1 zzuniq && return
## versão UNIX, rápida, mas precisa de cat, sort, uniq e cut
cat -n "${1:--}" | sort -k2 | uniq -f1 | sort -n | cut -f2-
## versão SED, mais lenta para arquivos grandes, mas só precisa do SED
##sed "G;/^\([^\n]*\)\n\([^\n]*\n\)*\1\n/d;h;s/\n.*//" $1
}


# ----------------------------------------------------------------------------
# Mata os processos que tenham o(s) padrão(ões) especificado(s) no nome do
# comando executado que lhe deu origem
# Obs.: se quiser assassinar mesmo o processo, coloque a opção -9 no kill
# Uso: zzkill padrão [padrão2 ...]
# Ex.: zzkill netscape
#      zzkill netsc soffice startx
# ----------------------------------------------------------------------------
zzkill(){ zzzz -z $1 zzkill && return;
local C P; for C in "$@"; do
for P in `ps x --format pid,comm | sed -n "s/^ *\([0-9]\+\) [^ ]*$C.*/\1/p"`
do kill $P && echo -n "$P "; done; echo; done
}


# ----------------------------------------------------------------------------
# Mostra todas as combinações de cores possíveis no console, juntamente com
# os respectivos códigos ANSI para obtê-las
# Uso: zzcores
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
# Gera uma senha aleatória de N caracteres formada por letras e números
# Obs.: a senha gerada não possui caracteres repetidos
# Uso: zzsenha [n]     (padrão n=6)
# Ex.: zzsenha
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
# Mostra a tabela ASCII com todos os caracteres imprimíveis (32-126,161-255)
# no formato: <decimal> <octal> <ascii>
# Obs.: o número de colunas e a largura da tabela são configuráveis
# Uso: zzascii [colunas] [largura]
# Ex.: zzascii
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
# Temas: mosaico, espaco, olho, aviao, jacare, alien, rosa, peixe, siri
# Obs.: aperte Ctrl+C para sair
# Uso: zzss [--rapido|--fundo] [--tema <tema>] [texto]
# Ex.: zzss
#      zzss fui ao banheiro
#      zzss --rapido /
#      zzss --fundo --tema peixe
# ----------------------------------------------------------------------------
zzss(){ zzzz -z $1 zzss && return
local a i j x y z zn lc c fundo tema temas hl pausa=1 c1='40;3' lin=25 col=80
temas="{mosaico} ;{espaco}.; {olho}00;{aviao}--o-0-o--;{jacare}==*-,,--,,--;
       {alien}/-=-\\ ;{rosa}--/--\\-<@;{peixe}>-)))-D; {siri}(_).-=''=-.(_);"
lc=`stty size 2>&-`; [ "$lc" ] && { lin=${lc% *}; col=${lc#* }; } # scr size
tema=mosaico ; while [ $# -ge 1 ]; do case "$1" in                # cmdline
  --fundo)fundo=1;; --rapido)unset pausa;; --tema)tema=${2:- }; shift;;
  *)unset tema;z="$*"; break;; esac; shift; done
[ "$tema" ] && if echo $temas | grep -qs "{$tema}"                # theme
  then z=`echo $temas|sed "s/.*{$tema}//;s/;.*//"`                  # get str
  else echo "tema desconhecido '$tema'"; return; fi                 # error
[ "$tema" = mosaico ] && { fundo=1 ; unset pausa; z=' ';}           # special
trap "clear;return" SIGINT; [ "$fundo" ] && c1='30;4'; zn=${#z}   # init
clear ; i=0 ; while :; do                                         # loop
  i=$((i+1)) ; j=$((i+1)) ; RANDOM=$j                               # set vars
  x=$((((RANDOM+c*j)%lin)+1)) ; y=$((((RANDOM*c+j)%(col-zn+1))+1))  # set  X,Y
  c=$(((x+y+j+RANDOM)%7  +1)) ; echo -ne "\033[$x;${y}H"            # goto X,Y
  unset hl; [ ! "$fundo" -a $((y%2)) -eq 1 ] && hl='1;'             # bold?
  [ "$ZZCOR" != 1 ] && a="$z" || a="\033[${hl}$c1${c}m$z\033[m"     # color?
  echo -ne $a ; ${pausa:+sleep 1} ; done                            # show
}



# ----------------------------------------------------------------------------
# #### A R Q U I V O S
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Conversão de arquivos texto entre DOS e linux
# Obs.: o arquivo original é gravado como arquivo.{dos,linux}
# Uso: zzdos2linux arquivo(s)
#      zzlinux2dos arquivo(s)
# ----------------------------------------------------------------------------
zzdos2linux(){ zzzz -z $1 zzdos2linux && return
local A; for A in "$@"; do cp "$A" "$A.dos" && chmod -x $A &&
sed 's/$//' "$A.dos"   > "$A" && echo "convertido $A"; done; }
zzlinux2dos(){ zzzz -z $1 zzdos2linux && return
local A; for A in "$@"; do cp "$A" "$A.linux" &&
sed 's/$//' "$A.linux" > "$A" && echo "convertido $A"; done; }


# ----------------------------------------------------------------------------
# Troca a extensão de um (ou vários) arquivo especificado
# Uso: zztrocaextensao antiga nova arquivo(s)
# Ex.: zztrocaextensao .doc .txt *
# ----------------------------------------------------------------------------
zztrocaextensao(){ zzzz -z $1 zztrocaextensao && return
[ "$3" ] || { echo 'uso: zztrocaextensao antiga nova arquivo(s)'; return; }
local A p1="$1" p2="$2"; shift 2; [ "$p1" = "$p2" ] && return
for A in "$@"; do [ "$A" != "${A%$p1}" ] && mv -v "$A" "${A%$p1}$p2"; done
}


# ----------------------------------------------------------------------------
# Troca o conteúdo de dois arquivos, mantendo suas permissões originais
# Uso: zztrocaarquivos arquivo1 arquivo2
# Ex.: zztrocaarquivos /etc/fstab.bak /etc/fstab
# ----------------------------------------------------------------------------
zztrocaarquivos(){ zzzz -z $1 zztrocaarquivos && return
[ "$2" ] || { echo 'uso: zztrocaarquivos arquivo1 arquivo2'; return; }
local at="$ZZTMP.$$"; cat "$2" > $at; cat "$1" > "$2"; cat "$at" > "$1"
rm $at; echo "feito: $1 <-> $2"
}


# ----------------------------------------------------------------------------
# Troca uma palavra por outra em um (ou vários) arquivo especificado
# Obs.: se quiser que seja insensível a maiúsculas/minúsculas, apenas
#       coloque o modificador 'i' logo após o modificador 'g' no comando sed
#       desligado por padrão
# Uso: zztrocapalavra antiga nova arquivo(s)
# Ex.: zztrocapalavra excessão exceção *.txt
# ----------------------------------------------------------------------------
zztrocapalavra(){ zzzz -z $1 zztrocapalavra && return
[ "$3" ] || { echo 'uso: zztrocapalavra antiga nova arquivo(s)'; return; }
local A T p1="$1" p2="$2"; shift 2; for A in "$@"; do
  grep -qs "$p1" "$A" || continue ; T=$ZZTMP${A##*/}.$$ ; cp "$A" "$T" &&
  sed "s§$p1§$p2§g" "$T" > "$A" && rm -f "$T" && echo "feito $A"; done
}


# ----------------------------------------------------------------------------
# Renomeia arquivos do diretório atual, arrumando nomes estranhos.
# Obs.: ele deixa tudo em minúsculas, retira acentuação e troca espaços em
#       branco, símbolos e pontuação pelo sublinhado _
# Use o -r para ser recursivo e o -d para renomear diretórios também
# Uso: zzarrumanome [-d] [-r] arquivo(s)
# Ex.: zzarrumanome *
#      zzarrumanome -d -r .
#      zzarrumanome "DOCUMENTO MALÃO!.DOC"       # fica documento_malao.doc
#      zzarrumanome "RAMONES - I Don't Care"     # fica ramones-i_don_t_care
# ----------------------------------------------------------------------------
zzarrumanome(){ zzzz -z $1 zzarrumanome && return
local A A1 A2 D i f_R=0 f_D=0;        [ "$1" = '-d' ] && { f_D=1; shift; }
[ "$1" = '-r' ] && { f_R=1; shift; }; [ "$1" = '-d' ] && { f_D=1; shift; }
[ "$1" ] || { echo 'uso: zzarrumanome [-d] [-r] arquivo(s)'; return; }
for A in "$@"; do [ "$A" != / ] && A=${A%/}
  [ -f "$A" -o -d "$A" ] || continue; [ -d "$A" ] && {
    [ "$f_R" -eq 1 ] && zzarrumanome -r ${f_D:+-d} "$A"/*
    [ "$f_D" -eq 0 ] && continue; }
  A1="${A##*/}"; D='.'; [ "${A%/*}" != "$A" ] && D="${A%/*}";
  A2=`echo $A1 | sed "s/[\"']//g"'
  y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/;s/^-/_/
  y/ÀàÁáÂâÃãÄÅäåÈèÉéÊêËëÌìÍíÎîÏïÇçÑñ/aaaaaaaaaaaaeeeeeeeeiiiiiiiiccnn/
  y/ÒòÓóÔôÕõÖöÙùÚúÛûÜüß¢Ð£Øø§µÝý¥¹²³/oooooooooouuuuuuuubcdloosuyyy123/
  s/[^a-z0-9._-]/_/g;s/__*/_/g;s/_\([.-]\)/\1/g;s/\([.-]\)_/\1/g'`
  [ "$A1" = "$A2" ] && continue ; [ -f "$D/$A2" -o -d "$D/$A2" ] && {
    i=1 ; while [ -f "$D/$A2.$i" -o -d "$D/$A2.$i" ]; do i=$((i+1)); done
    A2="$A2.$i"; }; mv -v -- "$A" "$D/$A2"; done
}


# ----------------------------------------------------------------------------
# Mostra a diferença entre dois textos, mas no contexto de palavras.
# Útil para conferir revisões ortográficas ou mudanças pequenas em frases.
# Obs.: se tiver muitas _linhas_ diferentes o diff normal é aconselhado.
# Uso: zzdiffpalavra arquivo1 arquivo2
# Ex.: zzdiffpalavra texto-orig.txt texto-novo.txt
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
# Acha as funções de uma biblioteca da linguagem C (arquivos .h)
# Obs.: o diretório padrão de procura é o /usr/include
# Uso: zzcinclude
# Ex.: zzcinclude stdio
#      zzcinclude /minha/rota/alternativa/stdio.h
# ----------------------------------------------------------------------------
zzcinclude(){ zzzz -z $1 zzcinclude && return
[ "$1" ] || { echo "uso: zzcinclude nome-biblioteca"; return; }
local i="$1"; [ "${i#/}" = "$i" ] && i="/usr/include/$i.h"
[ -f $i ] || { echo "$i não encontrado" ; return; } ; cpp -E $i |
sed '/^ *$/d;/^\(#\|typedef\) /d;/^[^a-z]/d;s/ *(.*//;s/.* \*\?//' | sort
}


# ----------------------------------------------------------------------------
# Acha os 15 maiores arquivos/diretórios do diretório atual (ou especificados)
# Usando-se a opção -r é feita uma busca recursiva nos subdiretórios
# Uso: zzmaiores [-r] [dir1 dir2 ...]
# Ex.: zzmaiores
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
# Conta o número de vezes que uma palavra aparece num arquivo
# Obs.: -i Ignora a diferença de maiúsculas/minúsculas
#       -p Parcial, conta trechos de palavras
# Uso: zzcontapalavra [-i|-p] palavra arquivo
# Ex.: zzcontapalavra root /etc/passwd
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
# Calculadora: + - / * ^ %    # mais operadores, ver `man bc`
# Obs.: números fracionados podem vir com vírgulas ou pontos: 1,5 ou 1.5
# Uso: zzcalcula número operação número
# Ex.: zzcalcula 2,1 / 3,5
#      zzcalcula '2^2*(4-1)'  # 2 ao quadrado vezes 4 menos 1
# ----------------------------------------------------------------------------
zzcalcula(){ zzzz -z $1 zzcalcula && return
[ "$1" ] && echo "scale=2;$*" | sed y/,/./ | bc | sed y/./,/ ; }


# ----------------------------------------------------------------------------
# Faz cálculos com datas e/ou converte data->num e num->data
# Que dia vai ser daqui 45 dias? Quantos dias há entre duas datas? zzdata!
# Quando chamada com apenas um parâmetro funciona como conversor de data
# para número inteiro (N dias passados desde Epoch) e vice-versa.
# Obs.: Leva em conta os anos bissextos     (Epoch = 01/01/1970, editável)
# Uso: zzdata data|num [+|- data|num]
# Ex.: zzdata 22/12/1999 + 69
#      zzdata hoje - 5
#      zzdata 01/03/2000 - 11/11/1999
#      zzdata hoje - dd/mm/aaaa         <---- use sua data de nascimento
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
# Faz cálculos com horários
# A opção -r torna o cálculo relativo à primeira data, por exemplo:
#   02:00 - 03:30 = -01:30 (sem -r) e 22:30 (com -r)
# Uso: zzhora [-r] hh:mm [+|- hh:mm]
# Ex.: zzhora 8:30 + 17:25        # preciso somar duas horas!
#      zzhora 12:00 - agora       # quando falta para o almoço?
#      zzhora -12:00 + -5:00      # horas negativas!!!
#      zzhora 1000                # quanto é 1000 minutos?
#      zzhora -r 5:30 - 8:00      # que horas ir dormir pra acordar às 5:30?
#      zzhora -r agora + 57:00    # e daqui 57 horas, será quando?
# ----------------------------------------------------------------------------
zzhora(){ zzzz -z $1 zzhora && return
local rel=0; [ "$1" = '-r' ] && rel=1 && shift
[ "$1" ] || { echo "uso: zzhora [-r] hh:mm [+|- hh:mm]"; return; }
local hh1 mm1 hh2 mm2 M1 M2 RES H M HD neg Hp Mp HDp
local D=0 hhmm1="$1" oper="${2:-+}" hhmm2="${3:-00}"
[ "${oper#[+-]}" ] && echo "Operação Inválida: $oper" && return
[ "$hhmm1" = 'agora' -o "$hhmm1" = 'now' ] && hhmm1=`date +%H:%M`
[ "$hhmm2" = 'agora' -o "$hhmm2" = 'now' ] && hhmm2=`date +%H:%M`
[ "${hhmm1#*:}" != "$hhmm1" ] || hhmm1=00:$hhmm1
[ "${hhmm2#*:}" != "$hhmm2" ] || hhmm2=00:$hhmm2
hh1=${hhmm1%:*}; mm1=${hhmm1#*:}; hh2=${hhmm2%:*}; mm2=${hhmm2#*:} # extrai
hh1=${hh1#0}   ; mm1=${mm1#0}   ; hh2=${hh2#0}   ; mm2=${mm2#0}    # s/^0//
M1=$((hh1*60+mm1)); M2=$((hh2*60+mm2)); RES=$(($M1 $oper $M2))     # calcula
[ $RES -lt 0 ] && neg=- RES=${RES#-}                               # del -
H=$((RES/60)); M=$((RES%60)); D=$((H/24)); HD=$((H%24)); Hp=$H Mp=$M HDp=$HD
[ $H -le 9 ] && Hp=0$H; [ $M -le 9 ] && Mp=0$M; [ $HD -le 9 ] && HDp=0$HD
if [ $rel -eq 1 ]; then [ "$neg" ] && {
    Mp=$(((60-M)%60)); D=$((H/24+(Mp>0))); HDp=$(((24-HD-(Mp>0))%24))
    [ $HDp -le 9 ] && HDp=0$HDp; [ $Mp -le 9 ] && Mp=0$Mp ; }      # padding
  [ $D -eq 1 ] && { extra=amanhã; [ "$neg" ] && extra=ontem; }
  [ $D -eq 0 ] && extra=hoje; [ "$extra" ] || extra="$neg${D} dias"
  echo "$HDp:$Mp ($extra)"
else
  echo "$neg$Hp:$Mp (${D}d ${HD}h ${M}m)"
fi
}


# ----------------------------------------------------------------------------
# Faz várias conversões como: caracteres, temperatura e distância
#          cf = (C)elsius      para (F)ahrenheit
#          fc = (F)ahrenheit   para (C)elsius
#          km = (K)Quilômetros para (M)ilhas
#          mk = (M)ilhas       para (K)Quilômetros
#          db = (D)ecimal      para (B)inário
#          bd = (B)inário      para (D)ecimal
#          cd = (C)aractere    para (D)ecimal
#          dc = (D)ecimal      para (C)aractere
# Uso: zzconverte <cf|fc|mk|km|db|bd|cd> número
# Ex.: zzconverte cf 5
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
# Busca a cotação do dia do dólar (comercial, paralelo e turismo)
# Obs.: as cotações são atualizadas de 10 em 10 minutos
# Uso: zzdolar
# ----------------------------------------------------------------------------
zzdolar(){ zzzz -z $1 zzdolar && return
$ZZWWWDUMP 'http://br.invertia.com/mercados/divisas/tiposdolar.asp' |
sed 's/^ *//;/Data:/,/Turismo/!d;/percent/d;s/  */ /g
     s/.*Data: \(.*\)/\1 compra   venda   hora/;s|^[1-9]/|0&|;
     s,^\([0-9][0-9]\)/\([0-9]/\),\1/0\2,
     s/^D.lar \|- Corretora\| SP//g;s/ [-+]\?[0-9.]\+ %$//
     s/al /& /;s/lo /&   /;s/mo /&    /;s/ \([0-9]\) / \1.000 /
     s/\.[0-9]\>/&0/g;s/\.[0-9][0-9]\>/&0/g;/^[^0-9]/s/[0-9] /&  /g'
}


# ----------------------------------------------------------------------------
# http://br.invertia.com
# Busca a cotação de várias moedas (mais de 100!) em relação ao dólar
# Com a opção -t, mostra TODAS as moedas, se ela, apenas as principais
# É possível passar várias palavras de pesquisa para filtrar o resultado
# Obs.: Hora GMT, Dólares por unidade monetária para o Euro e a Libra
# Uso: zzmoeda [-t] [pesquisa]
# Ex.: zzmoeda
#      zzmoeda -t
#      zzmoeda euro libra
#      zzmoeda -t peso
# ----------------------------------------------------------------------------
zzmoeda(){ zzzz -z $1 zzmoeda && return
local URL='http://br.invertia.com/mercados/divisas'
local dolar='DOLCM' extra='defaultr.asp' patt='.'
[ "$1" = '-t' ] && { extra='divisasregion.asp?idtel=TODAS' dolar=@; shift; }
[ "$1" ] && patt=$(echo $* | sed 's/ /\\|/g') ; $ZZWWWDUMP "$URL/$extra" |
sed "/[0-9][0-9]$/!d;/Dólar \(Paral\|Ptax\|Turi\)/d;s/\[.*]//;s/^ */  /
s/\( *-\?[0-9][,.0-9]\+\)\{2\}% */    /;/$dolar/{s// &    /;}" | grep -i $patt
}


# ----------------------------------------------------------------------------
# http://www.itautrade.com.br e http://www.bovespa.com.br
# Busca a cotação de uma ação na Bovespa
# Obs.: as cotações têm delay de 15 min em relação ao preço atual no pregão
#       Com a opção -i, é mostrado o índice bovespa
# Uso: zzbovespa [-i] código-da-ação
# Ex.: zzbovespa petr4
#      zzbovespa -i
#      zzbovespa
# ----------------------------------------------------------------------------
zzbovespa(){ zzzz -z $1 zzbovespa && return
local URL='http://www.bovespa.com.br/'
[ "$1" ] || { $ZZWWWDUMP "$URL/Indices/CarteiraP.asp?Indice=Ibovespa" |
sed '/^ *Cód/,/^$/!d'; return; }
[ "$1" = "-i" ] && { $ZZWWWHTML "$URL/Home/HomeNoticias.asp" | sed -n '
/Ibovespa -->/,/IBrX/{//d;s/<[^>]*>//g;s/[[:space:]]*//g;s/^&.*\;//;/^$/d
p;}' | sed '/^Pon/{N;s/^/           /;s/\n/   /;b;};/^IBO/N;N;s/\n/  /g
/^<.-- /d;:a;s/^\([^0-9]\{1,10\}\)\([0-9]\+\)/\1 \2/;ta'; return; }
local URL='http://www.itautrade.com.br/itautradenet/Finder/Finder.aspx?Papel='
$ZZWWWDUMP "$URL$1" | sed '/Ação/,/Oferta/!d;//d;/\.gif/d;s/^ *//;s/Ver O.*//'
}


# ----------------------------------------------------------------------------
# http://www.receita.fazenda.gov.br
# Consulta os lotes de restituição do imposto de renda
# Obs.: funciona para os anos de 2001, 2002 e 2003
# Uso: zzirpf ano número-cpf
# Ex.: zzirpf 2003 123.456.789-69
# ----------------------------------------------------------------------------
zzirpf(){ zzzz -z $1 zzirpf && return
[ "$2" ] || { echo 'uso: zzirpf ano número-cpf'; return; }
local ano=$1 URL='http://www.receita.fazenda.gov.br/Scripts/srf/irpf'
z=${ano#200} ; [ "$z" != 1 -a "$z" != 2 -a "$z" != 3 ] && {
echo "Ano inválido '$ano'. Deve ser 2001, 2002 ou 2003."; return; }
$ZZWWWDUMP "$URL/$ano/irpf$ano.dll?VerificaDeclaracao&CPF=$2" |
sed '1,8d;s/^ */  /;/^  \[BUTTON\]$/d'
}


# ----------------------------------------------------------------------------
# http://www.terra.com.br/cep
# Busca o CEP de qualquer rua de qualquer cidade do país ou vice-versa
# Uso: zzcep estado cidade nome-da-rua
# Ex.: zzcep PR curitiba rio gran
#      zzcep RJ 'Rio de Janeiro' Vinte de
# ----------------------------------------------------------------------------
zzcep(){ zzzz -z $1 zzcep && return
[ "$3" ] || { echo 'uso: zzcep estado cidade rua'; return; }
local URL='http://www.correios.com.br/servicos/cep/Resultado_Log.cfm'
local r c e="$1"; c=`echo "$2"| sed "$ZZSEDURL"`
shift  ;  shift ; r=`echo "$*"| sed "$ZZSEDURL"`
echo "UF=$e&Localidade=$c&Tipo=&Logradouro=$r" | $ZZWWWPOST "$URL" |
sed -n '/^ *UF:/,/^$/{ /Página Anter/d; s/.*óxima Pág.*/...CONTINUA/; p;}'
}


# ----------------------------------------------------------------------------
# http://www.pr.gov.br/detran
# Consulta débitos do veículo, como licenciamento, IPVA e multas (detran-PR)
# Uso: zzdetranpr número-renavam
# Ex.: zzdetranpr 123456789
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
# Consulta débitos do veículo, como licenciamento, IPVA e multas (detran-SP)
# Uso: zzdetransp número-renavam
# Ex.: zzdetransp 123456789
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
# http://www.caixa.gov.br/loterias
# Consulta os resultados da quina, megasena, duplasena e lotomania
# Uso: zzloteria
# Ex.: zzloteria
# ----------------------------------------------------------------------------

zzloteria(){ zzzz -z $1 zzloteria && return
local tipo URL=http://www1.caixa.gov.br/loterias/resultados/asp
for tipo in quina megasena duplasena lotomania; do echozz $tipo:
 lynx -dump -nolist "$URL/$tipo.asp?perfil=loteria" |
 sed -n '/\([0-9][0-9] - \)\{4\}/p;/Concurso n/p' | sed ':a;$!N;s/\n/@@/;ta ;
 s/n.mero //;s/^\( *Con.*)\)@@\(.*\)/\2@@\1/;s/^\([0-9 -]*\)@@  *[0-9].*@@/\1\
/'; done
}


# ----------------------------------------------------------------------------
# #### P R O G R A M A S                                         (internet)
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# http://freshmeat.net
# Procura por programas na base do freshmeat
# Uso: zzfreshmeat programa
# Ex.: zzfreshmeat tetris
# ----------------------------------------------------------------------------
zzfreshmeat(){ zzzz -z $1 zzfreshmeat && return
[ "$1" ] || { echo 'uso: zzfreshmeat programa'; return; }
$ZZWWWLIST "http://freshmeat.net/search/?q=$1" |
sed -n '/^ *© Copyright/,${s,^.* ,,;\|meat\.net/projects/|s,/$,,gp;}' | uniq
}



# ----------------------------------------------------------------------------
# http://rpmfind.net/linux
# Procura por pacotes RPM em várias distribuições
# Obs.: a arquitetura padrão de procura é a i386
# Uso: zzrpmfind pacote [distro] [arquitetura]
# Ex.: zzrpmfind sed
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
# Busca a descrição de um código de país da internet (.br, .ca etc)
# Obs.: o sed deve suportar o I de ignorecase na pesquisa
# Uso: zzdominiopais [.]código|texto
# Ex.: zzdominiopais .br
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
# Busca a identificação da chave PGP, fornecido o nome ou email da pessoa.
# Obs.: de brinde, instruções de como adicionar a chave a sua lista.
# Uso: zzchavepgp nome|email
# Ex.: zzchavepgp Carlos Oliveira da Silva
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
# Procura por dicas sobre determinado assunto na lista Dicas-L
# Obs.: as opções do grep podem ser usadas (-i já é padrão)
# Uso: zzdicasl [opção-grep] palavra(s)
# Ex.: zzdicasl ssh
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
# Whois da fapesp para domínios brasileiros
# Uso: zzwhoisbr domínio
# Ex.: zzwhoisbr abc.com.br
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
# Procura de documentos HOWTO
# Uso: zzhowto [--atualiza] palavra
# Ex.: zzhowto apache
#      zzhowto --atualiza
# ----------------------------------------------------------------------------
zzhowto(){ zzzz -z $1 zzhowto && return
[ "$1" ] || { echo 'uso: zzhowto [--atualiza] palavra'; return; }
local URL z=$1 arq=$ZZTMP.howto
URL='http://www.ibiblio.org/pub/Linux/docs/HOWTO/other-formats/html_single/'
[ "$z" = '--atualiza' ] && { rm -f $arq ; shift; z=$1 ; }
[ -s "$arq" ] || { echo -n 'AGUARDE. Atualizando listagem...'
  $ZZWWWHTML "$URL" | sed -n '/ALT="\[TXT\]"/{
  s/^.*HREF="\([^"]*\).*/\1/;p;}' > $arq ; echo ' feito!' ; }
[ "$z" ] && { echozz $URL; grep -i "$z" $arq; }
}


# ----------------------------------------------------------------------------
# http://... - vários
# Busca as últimas notícias sobre linux em páginas nacionais.
# Obs.: cada página tem uma letra identificadora que pode ser passada como
#       parâmetro, identificando quais páginas você quer pesquisar:
#
#         R)evista do linux    I)nfoexame
#         O)linux              linux in braZ)il
#         ponto B)r            T)chelinux
#         C)ipsga              N)otícias linux
#
# Uso: zznoticiaslinux [sites]
# Ex.: zznoticiaslinux
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
# Busca as últimas notícias sobre linux em páginas em inglês.
# Obs.: cada página tem uma letra identificadora que pode ser passada como
#       parâmetro, identificando quais páginas você quer pesquisar:
#
#          F)reshMeat         Linux D)aily News
#          S)lashDot          Linux W)eekly News
#          N)ewsForge         O)S News
#
# Uso: zzlinuxnews [sites]
# Ex.: zzlinuxnews
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
  echo ; echozz "* NewsForge - ($URL):"; $ZZWWWDUMP $URL |
  sed -n '/^ *Section:/{n;n;s/^ *//;p;}' | $limite ; }
[ "$s" != "${s#*d}" ] && { URL='http://www.linuxdailynews.com'
  echo ; echozz "* Linux Daily News ($URL):"; $ZZWWWHTML $URL |
  sed '/color="#101073">/!d;s,</b>.*,,;s/^.*<b> *//;s,</\?i>,,g' | $limite ; }
[ "$s" != "${s#*w}" ] && { URL='http://lwn.net/Articles'
  echo ; echozz "* Linux Weekly News - ($URL):"; $ZZWWWHTML $URL |
  sed '/class="Headline"/!d;s/^ *//;s/<[^>]*>//g' | $limite ; }
[ "$s" != "${s#*o}" ] && { URL='http://osnews.com'
  echo ; echozz "* OS News - ($URL):"; $ZZWWWHTML $URL |
  sed '/BGCOLOR="#CCCCCC"/!d;s/<[^>]*>//g' | $limite; }
}



# ----------------------------------------------------------------------------
# http://... - vários
# Busca as últimas notícias em sites especializados em segurança.
# Obs.: cada página tem uma letra identificadora que pode ser passada como
#       parâmetro, identificando quais páginas você quer pesquisar:
#
#       Linux Security B)rasil    Linux T)oday - Security
#       Linux S)ecurity           Security F)ocus
#       C)ERT/CC
#
# Uso: zznoticiassec [sites]
# Ex.: zznoticiassec
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
# Retorna apenas os títulos e links do resultado da pesquisa no Google
# Uso: zzgoogle [-n <número>] palavra(s)
# Ex.: zzgoogle receita de bolo de abacaxi
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
# Busca letras de músicas, procurando pelo nome da música
# Obs.: se encontrar mais de uma, mostra a lista de possibilidades
# Uso: zzletrademusica texto
# Ex.: zzletrademusica punkrock
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
# Consulta a programação do dia dos canais abertos da TV
# Pode-se passar os canais e o horário que se quer consultar
#   Identificadores: B)and, C)nt, E)ducativa, G)lobo, R)ecord, S)bt, cU)ltura
# Uso: zztv canal [horário]
# Ex.: zztv bsu 19       # band, sbt e cultura, depois das 19:00
#      zztv . 00         # todos os canais, depois da meia-noite
#      zztv .            # todos os canais, o dia todo
# ----------------------------------------------------------------------------
zztv(){ zzzz -z $1 zztv && return
[ "$1" ] || { echo 'uso: zztv canal [horário]  (ex. zztv bs 22)'; return; }
local c h URL='http://tudoparana.globo.com/gazetadopovo/cadernog/conteudo.phtml?id=310140'
h=`echo $2|sed 's/^\(..\).*/\1/;s/[^0-9]//g'` ; h="($h|$((h+1))|$((h+2)))"
h=`echo $h|sed 's/24/00/;s/25/01/;s/26/02/;s/\<[0-9]\>/0&/g;s,[(|)],\\\\&,g'`
c=`echo $1|sed 's/b/2,/;s/s/4,/;s/c/6,/;s/r/7,/;s/u/9,/;s/g/12,/;s/e/59,/
s/,$//;s@,@\\\\|@g'`; c=$(echo $c | sed 's/^\.$/..\\?/'); $ZZWWWDUMP $URL |
sed -e 's/^ *//;s/[Cc][Aa][Nn][Aa][Ll]/CANAL/;/^[012C]/!d;/^C[^A]/d;/^C/i \'\
    -e . | sed "/^CANAL \($c\) *$/,/^.$/!d;/^C/,/^$h/{/^C\|^$h/!d;};s/^\.//"
}


# ----------------------------------------------------------------------------
# http://www.acronymfinder.com
# Dicionário de siglas, sobre qualquer assunto (como DVD, IMHO, OTAN, WYSIWYG)
# Obs.: há um limite diário de consultas (10 acho)
# Uso: zzsigla sigla
# Ex.: zzsigla RTFM
# ----------------------------------------------------------------------------
zzsigla(){ zzzz -z $1 zzsigla && return
[ "$1" ] || { echo 'uso: zzsigla sigla'; return; }
local URL=http://www.acronymfinder.com/af-query.asp
$ZZWWWDUMP "$URL?String=exact&Acronym=$1&Find=Find" |
sed -n 's/^ *//;s/ *\[go\.gif] *$//p'
}



# ----------------------------------------------------------------------------
# http://cheetah.eb.com
# Toca um .wav que contém a pronúncia correta de uma palavra em inglês
# Uso: zzpronuncia palavra
# Ex.: zzpronuncia apple
# ----------------------------------------------------------------------------
zzpronuncia(){ zzzz -z $1 zzpronuncia && return
[ "$1" ] || { echo 'uso: zzpronuncia palavra'; return; }
local URL URL2 arq dir tmpwav="$ZZTMP.$1.wav"
URL='http://www.m-w.com/cgi-bin/dictionary' URL2='http://www.m-w.com/sound'
[ -f "$tmpwav" ] || { arq=`$ZZWWWHTML "$URL?va=$1" |
  sed -n "/.*audio.pl?\([a-z0-9]*\.wav\)=$1.*/{s//\1/p;q;}"`
  [ "$arq" ] || { echo "$1: palavra não encontrada"; return; }
  dir=`echo $arq | sed 's/^\(.\).*/\1/'`
  WAVURL="$URL2/$dir/$arq" ; echo "URL: $WAVURL"
  $ZZWWWHTML "$WAVURL" > $tmpwav ; echo "Gravado o arquivo '$tmpwav'" ; }
play $tmpwav
}



# ----------------------------------------------------------------------------
# http://weather.noaa.gov/
# Mostra as condições do tempo em um determinado local
# Se nenhum parâmetro for passado, são listados os países disponíveis.
# Se só o país for especificado, são listados os lugares deste país.
# Você também pode utilizar as siglas apresentadas para diferenciá-los.
# Ex: SBPA = Porto Alegre.
# Uso: zztempo <país> <local>
# Ex.: zztempo 'United Kingdom' 'London City Airport'
#      zztempo brazil 'Curitiba Aeroporto'
#      zztempo brazil SBPA
# ----------------------------------------------------------------------------
zztempo(){ zzzz -z $1 zztempo && return
local arq_c P arq_p=$ZZTMP.tempo_p URL='http://weather.noaa.gov'
[ -s "$arq_p" ] || { $ZZWWWHTML "$URL" | sed -n '/="country"/,/\/select/{
s/.*="\([a-zA-Z]*\)">\(.*\) <.*/\1 \2/p;}' > $arq_p; }
[ "$1" ] || { sed 's/^[^ ]* \+//' $arq_p; return; }
P=$(sed -n "s/^[^ ]* \+//;/^$1$/Ip" $arq_p)
[ "$P" ] || { echozz "País [$1] não existe"; return; }
LOCALE_P=$(sed -n "s/ \+$1//Ip" $arq_p); arq_c=$ZZTMP.tempo.$LOCALE_P
[ -s "$arq_c" ] || { $ZZWWWHTML "$URL/weather/${LOCALE_P}_cc.html" |
sed -n '/="cccc"/,/\/select/{//d;s/.*="\([a-zA-Z]*\)">/\1 /p;}' > $arq_c; }
[ "$2" ] || { cat $arq_c; return; }; L=$(sed -n "/${2}/Ip" $arq_c)
[ "$L" ] || { echozz "Local [$2] não existe"; return; }
[ $(echo "$L" | wc -l) -eq 1 ] && {
  $ZZWWWDUMP "$URL/weather/current/${L%% *}.html" |
  sed -n '/Current Weather/,/24 Hour/{//d;/_\{5,\}/d;p;}' || echo "$L"; }
}



# ----------------------------------------------------------------------------
# http://www.worldtimeserver.com
# Mostra a hora certa de um determinado local
# Se nenhum parâmetro for passado, são listados os locais disponíveis
# O parâmetro pode ser tanto a sigla quando o nome do local
# Obs.: -s realiza a busca exata de uma sigla
# Uso: zzhoracerta [-s] local
#  ex: zzhoracerta rio grande do sul
#  ex: zzhoracerta us-ny
#  ex: zzhoracerta -s nz
# ----------------------------------------------------------------------------
zzhoracerta(){ zzzz -z $1 zzhoracerta && return
local H S arq=$ZZTMP.horacerta URL='http://www.worldtimeserver.com/country.asp'
local frufru='s/\([^ ]\) \([^ ]\)/\1 == \2/';[ "$1" = "-s" ] && { shift; S=.;}
[ -s "$arq" ] || { $ZZWWWHTML "$URL" | sed -n '/(UTC\/GMT)/,/\/font/{
s/\(<li>\)\?.*=\([a-zA-Z0-9-]*\)">\([^<]*\).*/\1 \2 \3/;s/<li>/    /
s/<[^>]*>//;/^ *.$/d;p;}' > $arq; }; [ "$1" ] || { sed "$frufru" $arq;return;}
if [ "$S" ]; then H=$( sed 's/^ *//' $arq | grep -i "^$1 "); else H=$(sed \
's/^ *//' $arq | grep -i "$*"); fi;  [ "$H" ] || { echo "Local inexistente"
return; };[ "$(echo "$H" | sed -n 'N;/\n/p')" ] && { echo "$H" |
sed "$frufru"; return;}; $ZZWWWDUMP "${URL%/*}/time.asp?locationid=${H%% *}" |
sed -n '/^ *UTC/,/^ *\[/{/^ \{8,\}/{s///;:a;s/^.\{1,60\}$/ & /;ta;}
/^ *\[/d;p;}'
}



# ----------------------------------------------------------------------------
# http://www.nextel.com.br
# Envia uma mensagem para um telefone NEXTEL (via rádio)
# Obs.: o número especificado é o número próprio do telefone (não o ID!)
# Uso: zznextel de para mensagem
# Ex.: zznextel aurélio 554178787878 minha mensagem mala
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
# Faz traduções de palavras/frases/textos entre idiomas
# Basta especificar quais os idiomas de origem e destino e a frase
# Obs.: Se os idiomas forem omitidos, a tradução será inglês -> português
#
# Idiomas: en_zh en_fr en_de en_it en_ja en_ko en_pt en_es
#          zh_en fr_en de_en it_en ja_en ko_en pt_en es_en
#          ru_en fr_de de_fr
#
# Uso: zzdicbabelfish [idiomas] texto
# Ex.: zzdicbabelfish my dog is green
#      zzdicbabelfish pt_en falcão é massa
#      zzdicbabelfish en_de my hovercraft if full of eels
# ----------------------------------------------------------------------------
zzdicbabelfish(){ zzzz -z $1 zzdicbabelfish && return
[ "$1" ] || { echo 'uso: zzdicbabelfish [idiomas] palavra(s)'; return; }
local URL='http://babelfish.altavista.com/babelfish/tr'
local TXT extra='ienc=iso-8859-1&doit=done&tt=urltext&intl=1'
local INI='^.*<div style=padding[^>]*>' FIM='^<\/div>' L=en_pt
if [ "${1#[a-z][a-z]_[a-z][a-z]}" = '' ]; then L=$1; shift
elif [ "$1" = 'i' ]; then L=pt_en; shift; fi
TXT=`echo "$*"| sed "$ZZSEDURL"`; $ZZWWWHTML "$URL?$extra&urltext=$TXT&lp=$L"|
sed -n "/$INI/,/$FIM/{/$FIM\|^$/d;/$INI/{s/<[^>]*>//g;s/^...//p;};}"
}


# ----------------------------------------------------------------------------
# http://www.babylon.com
# Tradução de palavras em inglês para um monte de idiomas:
# francês, alemão, japonês, italiano, hebreu, espanhol, holandês e
# português. O padrão é o português, é claro.
# Uso: zzdicbabylon [idioma] palavra
# Ex.: zzdicbabylon hardcore
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
# Definições de palavras em inglês, com pesquisa em *vários* bancos de dados
# Uso: zzdicdict palavra
# Ex.: zzdicdict hardcore
# ----------------------------------------------------------------------------
zzdicdict(){ zzzz -z $1 zzdicdict && return
[ "$1" ] || { echo "zzdicdict palavra" && return; }
local INI='^ *Found [0-9]\+ entr\(y\|ies\)' FIM='^ *Try your search'
$ZZWWWDUMP -width=72 "http://www.dictionary.com/cgi-bin/dict.pl?db=*&term=$*"|
sed -n "/$INI/,/$FIM/{/$INI\|$FIM/d;p;}"
}




# ----------------------------------------------------------------------------
# http://www.academia.org.br/vocabula.htm
# Dicionário da ABL - Academia Brasileira de Letras
# Uso: zzdicabl palavra
# Ex.: zzdicabl cabeça-de-
# ----------------------------------------------------------------------------
zzdicabl(){ zzzz -z $1 zzdicabl && return
[ "$1" ] || { echo 'uso: zzdicabl palavra'; return; }
local URL='http://www.academia.org.br/scripts/volta_abl_org.asp'
echo "palavra=$*" | $ZZWWWPOST $URL | sed '1,5d;/^ *\./,$d;s/^ */  /'
}


# ----------------------------------------------------------------------------
# http://www.portoeditora.pt/dol
# Dicionário de português (de Portugal)
# Uso: zzdicportugues palavra
# Ex.: zzdicportugues bolacha
# ----------------------------------------------------------------------------
zzdicportugues(){ zzzz -z $1 zzdicportugues && return
[ "$1" ] || { echo 'uso: zzdicportugues palavra'; return; }
local URL='http://www.priberam.pt/dlpo/definir_resultados.aspx'
local INI='^\(Não \)\?[Ff]o\(i\|ram\) encontrad' FIM='^Imprimir *$'
$ZZWWWDUMP "$URL?pal=$1" | sed -n "s/^ *//;/^$/d;
  s/\[transparent.gif]//;/$INI/,/$FIM/{/$INI\|$FIM/d;p;}"
}


# ----------------------------------------------------------------------------
# http://catb.org/jargon/
# Dicionário de jargões de informática, em inglês
# Uso: zzdicjargon palavra(s)
# Ex.: zzdicjargon vi
#      zzdicjargon all your base are belong to us
# ----------------------------------------------------------------------------
zzdicjargon(){ zzzz -z $1 zzdicjargon && return
[ "$1" ] || { echo 'uso: zzdicjargon palavra'; return; }
local arq=$ZZTMP.jargonfile URL='http://catb.org/jargon/html'
local achei achei2 num mais TXT=`echo "$*" | sed 's/ /-/g'`
[ -s "$arq" ] || { echo -n 'AGUARDE. Atualizando listagem...'
  $ZZWWWLIST "$URL/go01.html" |
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
# Usa todas as funções de dicionário e tradução de uma vez
# Uso: zzdictodos palavra
# Ex.: zzdictodos Linux
# ----------------------------------------------------------------------------
zzdictodos(){ zzzz -z $1 zzdictodos && return
[ "$1" ] || { echo 'uso: zzdictodos palavra'; return; }
local D ; for D in babelfish babylon jargon abl portugues dict
do echozz "zzdic$D:"; zzdic$D $1; done
}


# ----------------------------------------------------------------------------
# http://aurelio.net/doc/ramones.txt
# Procura frases de letras de músicas do ramones
# Uso: zzramones [palavra]
# Ex.: zzramones punk
#      zzramones
# ----------------------------------------------------------------------------
zzramones(){ zzzz -z $1 zzramones && return
local txt n url='http://aurelio.net/doc/ramones.txt' arq=$ZZTMP.ramones
[ -s "$arq" ] || { echo -n 'AGUARDE. Atualizando listagem...'
  $ZZWWWDUMP "$url" > $arq ; echo ' feito!'; }; txt=`grep -iw "${1:-.}" $arq`
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
    shift ; $func "$@"                    # vai!
  fi

## chamando do executável sem argumentos (também para --help)
elif [ "${0##*/}" != 'bash' -a "${0#-}" = "$0" ]; then
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








