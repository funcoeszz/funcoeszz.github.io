#!/bin/bash
# funcoeszz
# vim: noet noai tw=78
#
# INFORMA��ES: http://funcoeszz.net
# NASCIMENTO : 22 fevereiro 2000
# AUTORES    : Aur�lio Marinho Jargas <verde (a) aurelio net>
#              Thobias Salazar Trevisan <thobias (a) thobias org>
# DESCRI��O  : Fun��es de uso geral para bash[12], que buscam informa��es em
#              arquivos locais e dicion�rios/tradutores/fontes na internet
# LICEN�A    : GPL
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
# 20001230 <> cep: TipoPesquisa=, <> cabe�alho == /bin/bash, ++ cinclude
#          <> dolar: mostra data e trata acima de R$ 2 (triste realidade)
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
#    !!    ** criada a p�gina na Internet da fun��es
# 20020219 ++ tv
# 20020222 <> cep: n�mero do CEP, ++ sigla (valeu thobias)
# 20020226 <> s/registrobr/whoisbr/ na ajuda (valeu graebin)
# 20020228 ++ rpmfind (valeu thobias), s/==/=/ pro bash1 (valeu kall�s)
# 20020306 <> dolar: pequena mudan�a na sa�da
# 20020313 <> zz: ++listagem das fun��es, ++--atualiza, ++--bashrc
#          <> chamando pelo execut�vel, pode omitir o zz do nome
#          ++ TODAS as fun��es agora possuem --help (ou -h)
# 20020315 ++ nextel, <> noticiaslinux: ++tchelinux, zz: (bashrc)
# 20020419 ++ pronuncia (valeu thobias)
# 20020605 <> trocaextensao: -- /usr/bin/rename (valeu leslie)
#          <> casadosartistas: atualizada para casa3 (valeu ataliba)
#          <> zzzz: pr tirado fora (bug na vers�o nova)
# 20020611 <> casadosartistas: ++ index.php3 na URL (valeu thobias)
#          <> nextel: URL atualizada (valeu samsoniuk)
#          <> noticiaslinux: Z) URL/filtro atualizados (valeu thobias)
# 20020622 <> dicasl: URL/filtro atualizados (valeu thobias)
#          ++ uniq, <> limpalixo: s/stdin/${1:--}/, reconhece vim
#          <> ramones: agora grava arquivo para consulta local (+r�pido!)
# 20020827 <> tv: checa 2 horas adiante se na atual falhar (valeu copag)
#          ++ howto (valeu thobias), <> tv: URL atualizada (valeu copag)
#          <> arrumanome: nome mais limpo
# 20021030 <> noticiaslinux: Z) URL atualizada (valeu thobias)
#          <> noticiaslinux: B) filtro atualizado
#          <> dicbabelfish: filtro atualizado
#          -- casadosartistas: fim do programa
# 20021107 <> pronuncia: filtro arrumado (valeu thobias)
#          <> pronuncia: reconhece na hora arquivos j� baixado (+r�pido!)
#          ++ senha (valeu thobias), ++ linuxnews (valeu thobias)
# 20021206 <> maiores: adicionada op��o -r
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
#          <> zzzz: retirado c�digo de pacote RPM no --atualiza
#          <> linuxnews: F) filtro atualizado
#          <> noticiaslinux: B) filtro atualizado
# 20030226 ++ dicportugues: direto de Portugal (valeu marciorosa)
# 20030317 <> zzzz: adicionado --tcshrc (valeu spengler)
#          <> echozz: n�o estava imprimindo texto sem cores
#          <> linuxnews: O) arrumado, filtro atualizado (valeu thobias)
# 20030331 <> dicportugues: URL nova, filtro novo (valeu thobias)
# 20030403 ++ google, dolar: agora inclui a hora da �ltima atualiza��o
#    !!    ** o Thobias foi empossado como co-autor (06maio)
# 20030507 <> trocapalavra: s� regrava arquivos modificados
#          <> irpf: recebe o ano como par�metro (2001 ou 2002)
#          <> noticiaslinux: Z) URL e filtros atualizados (valeu brain)
#          <> trocaextensao: adicionada checagem se � a mesma extens�o
#          <> uniq: arrumada, n�o estava funcionado direito
#          <> dicbabelfish, tv: filtro atualizado
#          <> arrumado bug que mostrava "esta fun��o n�o existe!"
# 20030612 ++ ss, ++ maiusculas, ++ minusculas
#          <> irpf: restitui��es de 2003 inclu�das
#          <> arrumanome: mais caracteres estranhos cadastrados
#          <> noticiaslinux: apagado lixo: "tee pbr.html" (valeu bernardo)
#          <> trocapalavra: s� regrava arquivos modificados (agora sim)
#          <> trocapalavra: trata arquivos com espa�o no nome (valeu rbp)
#          <> cep: URL mudou (valeu fernando braga)
#          <> echozz: mensagens coloridas em azul
# 20030713 ++ noticiassec
#          <> howto: URL nova, procura mini-HOWTOs tamb�m
#          <> dicjargon: URL nova, cache local, mais esperto
#          <> linuxnews: atualizada URL para Linux Weekly News
#          <> arrumanome: n�o apaga arquivo j� existente (valeu paulo henrique)
#          <> noticiaslinux: adicionado site Not�cias Linux (valeu bernardo)
#          <> dicbabelfish, dolar: arrumado filtro
#          -- bugzilla, rpmdono, rpmdisco: retiradas do pacote
# 20031002 ++ converte, contapalavra
#          <> howto: de volta para a URL antiga
#          <> noticiassec: --help arrumado
#          <> noticiaslinux: Z) filtro atualizado
#          <> tv: sbt arrumado (valeu vinicius)
#          <> zzzz: bashrc: checagem +esperta, quebra a linha (valeu luciano)
# 20031124 <> arrumado problema de v�rias fun��es em arquivos com espa�os
#          <> echozz: arrumado problema de expans�o do asterisco
#          <> cep: URL e filtro atualizados (agora s� por endere�o)
#          <> dicportugues: URL e filtro atualizados (valeu geraldo)
#          <> pronuncia: URL atualizada (valeu moyses)
#          <> linuxnews: N) filtro atualizado
#          <> dicjargon: URL atualizada
#          <> ramones: mostra mensagem quando atualiza dados
# 20040128 ++ hora, -- somahora (valeu victorelli)
#          ++ ZZCOR,ZZPATH,ZZTMPDIR: cfg via vari�veis de ambiente (valeu rbp)
#          <> arrumanome: adicionadas op��es -d e -r
#          <> arrumanome: arrumado bug DIR/ARQ de mesmo nome (valeu helio)
#          <> ss: arrumado bug com --rapido e --fundo (valeu ulysses)
#          <> ss: a frase n�o precisa mais das aspas
#          <> irpf: arrumada mensagem de erro (valeu rbp)
# 20040219 ++ tempo
#          <> beep: com par�metros, agora serve de alarme
#          <> howto: sa�da melhorada, mais limpa
#          <> dicabl: URL atualizada (valeu leonardo)
#          <> ajuda: agora paginando com o $PAGER, se existir (valeu rbp)
#          <> echozz: arrumado bug de imprimir duplicado (valeu rbp)
#          <> configura��es: arrumado bug do $ZZPATH (valeu nexsbr)
#          <> zzzz: --bashrc detecta comando 'source' ou '.'
#          <> zzzz: --bashrc adicionado "export ZZPATH"
# 20040329 ++ moeda, ++ horacerta
#          <> pronuncia: filtro atualizado (valeu roberto)
#          <> dicbabelfish: agora aceita v�rios idiomas (valeu rbp)
#          <> howto: agora pode passar par�metro ap�s --atualiza (valeu rbp)
#          <> trocapalavra: agora aceita '(' como primeiro par�metro
#          <> dolar: filtro atualizado para tirar o 'SP'
#          <> linuxnews: O) filtro atualizado
# 20040518 ++ bovespa (valeu denis)
#          ++ loteria (valeu polidoro)
#          <> tv: URL atualizada (valeu matheus)
#          <> dicbabelfish: filtro atualizado (valeu rbp)
#          <> linuxnews: N) filtro atualizado
# 20041029 ++ wikipedia
#          <> linuxnews: N) filtro atualizado, D) virou T)
#          <> noticiaslinux: --R)dL, ++Y)ahoo (valeu brusso, nakabashi)
#          <> noticiaslinux: .BR agora � P), LinuxinBrazil agora � B)r Linux
#          <> loteria: lotomania: todas as dezenas (valeu bianchi, hoffmann)
#          <> dicas-l: extens�o mudou de .shtml para .php
#          <> arrumado erro ao carreg�-las no bashrc (valeu hildebrando)
# 20041111 ++ nomefoto
#          <> arrumado de vez o erro no carregamento (valeu carvalhaes)
#          <> se o script for chamado sem argumentos, n�o mostra nada
#          <> noticiaslinux: B) URL e filtro atualizados
#          <> noticiassec: C) URL atualizada
#          <> loteria: adicionada lotof�cil (valeu casali)
#          <> tv: URL e filtro atualizados (valeu broonu)
#          <> diffpalavra: op��es cat/diff/rm, funciona BSD (valeu carvalhaes)
#          <> horacerta: URL e filtro atualizados
# 20041223 ++ natal, security, cpf, cnpj, linha
#          -- dicdict: removida, est� quebrada e tem pouco uso
#          <> dicabl: URL e filtro atualizados (valeu sartini)
#          <> ramones: n�o estava achando certas palavras (valeu rodarvus)
#          <> data: checagem da data passada pelo usu�rio (valeu rbp)
#          <> horacerta: filtro atualizado
# 20050318 <> dicbabylon: URL e filtros atualizados (valeu rivanor)
#          <> chavepgp: URL e filtro atualizados (valeu frederico)
#          <> bovespa: agora com mercado fracion�rio tamb�m (valeu casali)
#          <> dictodos: tirado dicdict (valeu rbp)
#          <> data: retirada possibilidade de loop infinito (valeu rbp)
#          <> ss: arrumado bug com o Ctrl+C (valeu sartini e tiago)
#          <> horacerta: filtro atualizado (valeu polidoro)
#          <> noticiaslinux: --O)linux --T)chelinux ++U)nderLinux ++V)ivaoLinux
#          <> security: fedora: filtro atualizado
#          <> moeda: URL atualizada
#          <> ramones: URL atualizada
#          <> dicbabelfish: colocadas todas as l�nguas no --help
# 20050519 ++ novo esquema de fun��es extras: $ZZEXTRA $ZZEXTRA_DFT ~/.zzextra
#          <> zzzz, ajuda: levando em conta fun��es extras tamb�m
#          <> SED antigo compliant: zzzz, ajuda, security, maiores (tks djony)
#          <> SED antigo compliant: detransp, diffpalavra, dicjargon, cinclude
#          <> SED antigo compliant: google, kill, nomefoto, converte, chavepgp
#          <> ajuda: retirado caractere de controle (agora rola copiar&colar)
#          <> loteria: agora mostra quando ficou acumulado (valeu casali)
#          <> converte: adicionadas temperaturas em Kelvin (valeu aires)
#          <> noticiaslinux: P) removido, I): atualizado (valeu nakabashi)
#          <> dicbabylon: checagem do idioma informado
#          <> security: slackware: URL atualizada (valeu duke)
#          <> horacerta: filtro atualizado
#          <> zzzz: zzhora -h mostrava ajuda da zzhoracerta
# 20050630 ++ locale (valeu kojima)
#          <> freshmeat: filtro simplificado
#          <> chavepgp: filtro consertado (valeu frederico)
#          <> loteria: filtro atualizado para apagar lixos (valeu casali)
#          <> dicportugues: melhorada a formata��o da sa�da
#          <> dicbabylon: melhorada a formata��o da sa�da
#          <> noticiassec: F) filtro atualizado
#          <> noticiaslinux: U) filtro atualizado, B) URL atualizada
#          <> sigla: filtro atualizado (valeu douglas)
# 20050930 ++ calculaip, ipinternet 
#          <> security: s/mandrake/mandriva/
#          <> whoisbr: agora mostra informa��es sobre o DNS do dom�nio
#          <> dolar: filtro atualizado
#          <> linuxnews: S) filtro atualizado
#          <> dicabl: URL atualizada (valeu sartini)
#    !!    ** dom�nio funcoeszz.net e camiseta 5 anos
# 20061114 ++ zzfoneletra (valeu rodolfo)
#          <> dicabl: URL e filtro atualizados (valeu sartini)
#          <> dicasl: URL e filtro atualizados
#          <> dicportugues: filtro atualizado (BSD)
#          <> dolar: filtro atualizado (BSD)
#          <> dominiopais: URL e filtro atualizados
#          <> google: filtro atualizado
#          <> howto: filtro atualizado
#          <> ipinternet: filtro atualizado
#          <> linuxnews: S) filtro atualizado, O) filtro atualizado
#          <> locale: URL e filtros atualizados
#          <> loteria: URL e filtro atualizados (valeu casali)
#          <> nomefoto: n�o sobrescreve arquivo j� existente (valeu nogaroto)
#          <> noticiaslinux: I) URL atualizada (valeu aires)
#          <> noticiaslinux: U) URL e filtro atualizados
#          <> noticiaslinux: V) filtro atualizado, N) filtro atualizado
#          <> pronuncia: agora usa o comando 'say' no mac
#          <> security: URL e filtro atualizados para Conectiva e Mandriva
#          <> sigla: filtro atualizado
#
##############################################################################
#
#                                Configura��o
#                                ------------
#
#
### Configura��o via vari�veis de ambiente
#
# Algumas vari�veis de ambiente podem ser usadas para alterar o comportamento
# padr�o das fun��es. Basta defini-las em seu .bashrc ou na pr�pria linha de
# comando antes de chamar as fun��es. S�o elas:
#
#      $ZZCOR    - Liga/Desliga as mensagens coloridas (1 e 0)
#      $ZZPATH   - Caminho completo para o arquivo das fun��es
#      $ZZEXTRA  - Caminho completo para o arquivo com fun��es adicionais
#      $ZZTMPDIR - Diret�rio para armazenar arquivos tempor�rios
#
#
### Configura��o fixa neste arquivo (hardcoded)
#
# A configura��o tamb�m pode ser feita diretamente neste arquivo, se voc�
# puder fazer altera��es nele.
#
ZZCOR_DFT=1                     # colorir mensagens? 1 liga, 0 desliga
ZZPATH_DFT=/usr/bin/funcoeszz   # rota absoluta deste arquivo
ZZEXTRA_DFT=~/.zzextra          # rota absoluta deste arquivo
ZZTMPDIR_DFT=${TMPDIR:-/tmp}    # diret�rio tempor�rio
#
#
##############################################################################
#
#                               Inicializa��o
#                               -------------
#
#
# Vari�veis e fun��es auxiliares usadas pelas fun��es ZZ.
# N�o altere nada aqui.
#
#
ZZWWWDUMP='lynx -dump      -nolist -crawl -width=300 -accept_all_cookies'
ZZWWWLIST='lynx -dump                     -width=300 -accept_all_cookies'
ZZWWWPOST='lynx -post-data -nolist -crawl -width=300 -accept_all_cookies'
ZZWWWHTML='lynx -source'
ZZERDATA='[0-9][0-9]\/[0-9][0-9]\/[0-9]\{4\}'; # dd/mm/aaa ou mm/dd/aaaa
ZZERHORA='[012][0-9]:[0-9][0-9]'
ZZSEDURL='s| |+|g;s|&|%26|g;s|@|%40|g'
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
### Truques para descobrir a localiza��o deste arquivo no sistema
#
# Se a chamada foi pelo execut�vel, o arquivo � o $0.
# Sen�o, tenta usar a vari�vel de ambiente ZZPATH, definida pelo usu�rio.
# Caso n�o exista, usa o local padr�o ZZPATH_DFT.
# Finalmente, for�a que ZZPATH seja uma rota absoluta.
#
[ "${0##*/}" = 'bash' -o "${0#-}" != "$0" ] || ZZPATH="$0"
[ "$ZZPATH" ] || ZZPATH=$ZZPATH_DFT
[ "$ZZPATH" ] || echozz 'AVISO: $ZZPATH vazia. zzajuda e zzzz n�o funcionar�o'
[ "${ZZPATH#/}" = "$ZZPATH" ] && ZZPATH="$PWD/${ZZPATH#./}"
[ "$ZZEXTRA" ] || ZZEXTRA=$ZZEXTRA_DFT
[ -f "$ZZEXTRA" ] || ZZEXTRA=
#
### �ltimos ajustes
#
ZZCOR="${ZZCOR:-$ZZCOR_DFT}"
ZZTMP="${ZZTMPDIR:-$ZZTMPDIR_DFT}/zz"
unset ZZCOR_DFT ZZPATH_DFT ZZEXTRA_DFT ZZTMPDIR_DFT
#
#
##############################################################################


# ----------------------------------------------------------------------------
# Mostra uma tela de ajuda com explica��o e sintaxe de todas as fun��es
# Obs.: t�t�t�, � xunxo. Sou pregui�oso sim, e da� &:)
# Uso: zzajuda
# ----------------------------------------------------------------------------
zzajuda(){ zzzz -z $1 zzajuda && return
local pinte esc=$(echo -ne '\033[') ; [ $ZZCOR = '1' -a "$PAGER" != 'less' ] &&
  pinte="s zz[a-z0-9]\{2,\} ${esc}36;1m&${esc}m "
cat $ZZPATH $ZZEXTRA | sed '1{s/.*/** Ajuda das fun��es ZZ (tecla Q sai)/;G;p;}
  /^# --*$/,/^# --*$/{s/-\{20,\}/-------/;s/^# //p;};d' | uniq |
  sed "s/^-\{7\}/&&&&&&&&&&&/;$pinte" | ${PAGER:-less -r}
}


# ----------------------------------------------------------------------------
# Mostra informa��es (como vers�o e localidade) sobre as fun��es
# Com a op��o --atualiza, baixa a vers�o mais nova das fun��es
# Com a op��o --bashrc, "instala" as fun��es no ~/.bashrc
# Com a op��o --tcshrc, "instala" as fun��es no ~/.tcshrc
# Uso: zzzz [--atualiza|--bashrc|--tcshrc]
# ----------------------------------------------------------------------------
zzzz(){
[ "$1" = '-z' -a -z "${2#(}" ] && return 1  # zztrocapalavra '(' 'foo'
if [ "$1" = '-z' -o "$1" = '-h' -o "$1" = '--help' ]; then # -h)zzzz -z)resto
  [ "$1" = '-z' -a "$2" != '--help' -a "$2" != '-h' ] && return 1 #alarmefalso
  local pat="Uso: [^ ]*${3:-zzzz} \{0,1\}"; zzajuda | grep -C9 "^$pat\b" |
  sed -e ':a' -e '$bz' -e 'N;ba' -e ':z' \
      -e "s/.*\n---*\(\n\)\(.*$pat\)/\1\2/;s/\(\n\)---.*/\1/"; return 0
fi
local rc vl vr URL='http://funcoeszz.net' cfg="source $ZZPATH" cfgf=~/.bashrc
local cor='n�o'; [ "$ZZCOR" = '1' ] && cor='sim'; [ -f "$ZZPATH" ] || return
vl=$(sed -n '/^$/q;s/^# 200\(.\)\(..\).*/\1.\2/p' $ZZPATH | sed '$!d;s/\.0/./')
if [ "$1" = '--atualiza' ]; then # obt�m vers�o nova, se !=, download
  echo "Procurando a vers�o nova, aguarde."
  vr=$($ZZWWWDUMP $URL | sed -n 's/.*vers�o atual \([0-9.]\{1,\}\).*/\1/p')
  echo "vers�o local : $vl"; echo "vers�o remota: $vr"; echo
  [ "$vr" ] || return ; if [ "$vl" = "$vr" ]; then
    echo 'Voc� j� est� com a �ltima vers�o.'
  else
    local urlexe="$URL/funcoeszz" exe="funcoeszz-$vr"
    echo -n 'Baixando a vers�o nova... '; $ZZWWWHTML $urlexe > $exe
    echo 'PRONTO!'; echo "Arquivo '$exe' baixado, instale-o manualmente."
  fi
elif [ "$1" = '--bashrc' ]; then # instala fun��es no ~/.bashrc
  if ! grep -q "^ *\(source\|\.\) .*funcoeszz" $cfgf;
  then (echo; echo "$cfg"; echo "export ZZPATH=$ZZPATH") >> $cfgf
        echo 'feito!'
  else  echo "as fun��es j� est�o no $cfgf!"; fi
elif [ "$1" = '--tcshrc' ]; then # cria aliases para as fun��es no /.tcshrc
  cfgf=~/.zzcshrc cfg="source $cfgf"; echo > $cfgf
  if ! grep -q "^ *$cfg" ~/.tcshrc; then echo "$cfg" >> ~/.tcshrc ; fi
  for func in $(ZZCOR=0 zzzz | sed '1,/^(( fu/d;s/,//g'); do
    echo "alias zz$func 'funcoeszz zz$func'" >> $cfgf;
  done; echo 'feito!'
else # mostra informa��es sobre as fun��es
  rc='n�o instalado' ; grep -qs "^ *$cfg" $cfgf && rc="$cfgf"
  echozz "( local)\c"; echo " $ZZPATH"; echozz "(vers�o)\c"; echo " $vl"
  echozz "( cores)\c"; echo " $cor"; echozz "(   tmp)\c"; echo " $ZZTMP"
  echozz "(bashrc)\c"; echo " $rc";
  echozz "(extras)\c"; echo " ${ZZEXTRA:-nenhum}"
  local arq extra; for arq in "$ZZPATH" "$ZZEXTRA"; do
    [ "$arq" -a -f "$arq" ] && {
      echo; echozz "(( fun��es dispon�veis ${extra:+EXTRA }))"
      sed -n '/^zz\([a-z0-9]\{1,\}\)(.*/s//\1/p' $arq | sort |
      sed -e ':a' -e '$b' -e 'N; s/\n/, /; /.\{50\}/{p;d;};ba'; extra=1; }
  done
fi
}



# ----------------------------------------------------------------------------
# #### D I V E R S O S
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Aguarda N minutos e dispara uma sirene usando o 'speaker'
# �til para lembrar de eventos pr�ximos no mesmo dia
# Se n�o receber nenhum argumento, serve para restaurar o 'beep' da m�quina
# para o seu tom e dura��o originais
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
# Retira linhas em branco e coment�rios
# Para ver rapidamente quais op��es est�o ativas num arquivo de configura��o
# Al�m do tradicional #, reconhece coment�rios de arquivos .vim
# Obs.: aceita dados vindos da ENTRADA PADR�O (STDIN)
# Uso: zzlimpalixo [arquivo]
# Ex.: zzlimpalixo ~/.vimrc
#      cat /etc/inittab | zzlimpalixo
# ----------------------------------------------------------------------------
zzlimpalixo(){ zzzz -z $1 zzlimpalixo && return
local z='#'; case "$1" in *.vim|*.vimrc*)z='"';; esac
cat "${1:--}" | tr '\t' ' ' | sed "\,^ *\($z\|$\),d" | uniq
}


# ----------------------------------------------------------------------------
# Convers�o de letras entre min�sculas e MAI�SCULAS, inclusive acentuadas
# Uso: zzmaiusculas [arquivo]
#      zzminusculas [arquivo]
# Ex.: zzmaiusculas /etc/passwd
#      echo N�O ESTOU GRITANDO | zzminusculas
# ----------------------------------------------------------------------------
zzminusculas(){ zzzz -z $1 zzminusculas && return
sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
     y/�������������������������/�������������������������/' "$@"; }
zzmaiusculas(){ zzzz -z $1 zzmaiusculas && return
sed 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/
     y/�������������������������/�������������������������/' "$@"; }


# ----------------------------------------------------------------------------
# Retira as linhas repetidas (consecutivas ou n�o)
# �til quando n�o se pode alterar a ordem original das linhas,
# Ent�o o tradicional sort|uniq falha.
# Uso: zzuniq [arquivo]
# Ex.: zzuniq /etc/inittab
#      cat /etc/inittab | zzuniq
# ----------------------------------------------------------------------------
zzuniq(){ zzzz -z $1 zzuniq && return
## vers�o UNIX, r�pida, mas precisa de cat, sort, uniq e cut
cat -n "${1:--}" | sort -k2 | uniq -f1 | sort -n | cut -f2-
## vers�o SED, mais lenta para arquivos grandes, mas s� precisa do SED
##sed "G;/^\([^\n]*\)\n\([^\n]*\n\)*\1\n/d;h;s/\n.*//" $1
}


# ----------------------------------------------------------------------------
# Mata os processos que tenham o(s) padr�o(�es) especificado(s)
# no nome do comando executado que lhe deu origem
# Obs.: se quiser assassinar mesmo o processo, coloque a op��o -9 no kill
# Uso: zzkill padr�o [padr�o2 ...]
# Ex.: zzkill netscape
#      zzkill netsc soffice startx
# ----------------------------------------------------------------------------
zzkill(){ zzzz -z $1 zzkill && return;
local C P; for C in "$@"; do
for P in `ps x --format pid,comm | sed -n "s/^ *\([0-9][0-9]*\) [^ ]*$C.*/\1/p"`
do kill $P && echo -n "$P "; done; echo; done
}


# ----------------------------------------------------------------------------
# Mostra todas as combina��es de cores poss�veis no console
# juntamente com os respectivos c�digos ANSI para obt�-las
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
# Gera uma senha aleat�ria de N caracteres formada por letras e n�meros
# Obs.: a senha gerada n�o possui caracteres repetidos
# Uso: zzsenha [n]     (padr�o n=6)
# Ex.: zzsenha
#      zzsenha 8
# ----------------------------------------------------------------------------
zzsenha(){ zzzz -z $1 zzsenha && return
local n alpha="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
n=6 ; [ "$1" ] && n=`echo "$1" | sed 's/[^0-9]//g'`
[ $n -gt 62 ] && { echo "zzsenha: O tamanho m�ximo � 62" ; return ; }
while [ $n -ne 0 ]; do n=$((n-1)) ; pos=$((RANDOM%${#alpha}+1))
echo -n "$alpha" | sed "s/\(.\)\{$pos\}.*/\1/" # igual a cut -c$pos
alpha=`echo $alpha | sed "s/.//$pos"` ; done | tr -d '\012' ; echo
}



# ----------------------------------------------------------------------------
# Mostra a tabela ASCII com todos os caracteres imprim�veis (32-126,161-255)
# no formato: <decimal> <octal> <ascii>
# Obs.: o n�mero de colunas e a largura da tabela s�o configur�veis
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
[ "$fundo" ] && c1='30;4'; zn=${#z} ; clear                         # init
( trap "clear;return" 2; i=0 ; while :; do                        # (loop)
  i=$((i+1)) ; j=$((i+1)) ; RANDOM=$j                               # set vars
  x=$((((RANDOM+c*j)%lin)+1)) ; y=$((((RANDOM*c+j)%(col-zn+1))+1))  # set  X,Y
  c=$(((x+y+j+RANDOM)%7  +1)) ; echo -ne "\033[$x;${y}H"            # goto X,Y
  unset hl; [ ! "$fundo" -a $((y%2)) -eq 1 ] && hl='1;'             # bold?
  [ "$ZZCOR" != 1 ] && a="$z" || a="\033[${hl}$c1${c}m$z\033[m"     # color?
  echo -ne $a ; ${pausa:+sleep 1} ; done                            # show
)
}



# ----------------------------------------------------------------------------
# Convers�o de telefones contendo palavras para apenas n�meros
# Uso: zzfoneletra telefone
# Ex.: zzfoneletra 2345-LINUX              # Retorna 2345-54689
#      echo 5555-HELP | zzfoneletra        # Retorna 5555-4357
# ----------------------------------------------------------------------------
zzfoneletra(){ zzzz -z $1 zzfoneletra && return
local conv='y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/'
if test "$1"; then echo $@ | zzmaiusculas | sed $conv
else zzmaiusculas | sed $conv; fi
}



# ----------------------------------------------------------------------------
# #### A R Q U I V O S
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Convers�o de arquivos texto entre DOS e Linux
# Obs.: o arquivo original � gravado como arquivo.{dos,linux}
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
# Troca a extens�o de um (ou v�rios) arquivo especificado
# Uso: zztrocaextensao antiga nova arquivo(s)
# Ex.: zztrocaextensao .doc .txt *
# ----------------------------------------------------------------------------
zztrocaextensao(){ zzzz -z $1 zztrocaextensao && return
[ "$3" ] || { echo 'uso: zztrocaextensao antiga nova arquivo(s)'; return; }
local A p1="$1" p2="$2"; shift 2; [ "$p1" = "$p2" ] && return
for A in "$@"; do [ "$A" != "${A%$p1}" ] && mv -v "$A" "${A%$p1}$p2"; done
}


# ----------------------------------------------------------------------------
# Troca o conte�do de dois arquivos, mantendo suas permiss�es originais
# Uso: zztrocaarquivos arquivo1 arquivo2
# Ex.: zztrocaarquivos /etc/fstab.bak /etc/fstab
# ----------------------------------------------------------------------------
zztrocaarquivos(){ zzzz -z $1 zztrocaarquivos && return
[ "$2" ] || { echo 'uso: zztrocaarquivos arquivo1 arquivo2'; return; }
local at="$ZZTMP.$$"; cat "$2" > $at; cat "$1" > "$2"; cat "$at" > "$1"
rm $at; echo "feito: $1 <-> $2"
}


# ----------------------------------------------------------------------------
# Troca uma palavra por outra em um (ou v�rios) arquivo especificado
# Obs.: se quiser que seja insens�vel a mai�sculas/min�sculas, apenas
#       coloque o modificador 'i' logo ap�s o modificador 'g' no comando sed
#       desligado por padr�o
# Uso: zztrocapalavra antiga nova arquivo(s)
# Ex.: zztrocapalavra excess�o exce��o *.txt
# ----------------------------------------------------------------------------
zztrocapalavra(){ zzzz -z $1 zztrocapalavra && return
[ "$3" ] || { echo 'uso: zztrocapalavra antiga nova arquivo(s)'; return; }
local A T p1="$1" p2="$2"; shift 2; for A in "$@"; do
  grep -qs "$p1" "$A" || continue ; T=$ZZTMP${A##*/}.$$ ; cp "$A" "$T" &&
  sed "s�$p1�$p2�g" "$T" > "$A" && rm -f "$T" && echo "feito $A"; done
}


# ----------------------------------------------------------------------------
# Renomeia arquivos do diret�rio atual, arrumando nomes estranhos
# Obs.: ele deixa tudo em min�sculas, retira acentua��o e troca espa�os em
#       branco, s�mbolos e pontua��o pelo sublinhado _
# Use o -r para ser recursivo e o -d para renomear diret�rios tamb�m
# Uso: zzarrumanome [-d] [-r] arquivo(s)
# Ex.: zzarrumanome *
#      zzarrumanome -d -r .
#      zzarrumanome "DOCUMENTO MAL�O!.DOC"       # fica documento_malao.doc
#      zzarrumanome "RAMONES - Don't Go.mp3"     # fica ramones-dont_go.mp3
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
  y/��������������������������������/aaaaaaaaaaaaeeeeeeeeiiiiiiiiccnn/
  y/������������������ߢУ����������/oooooooooouuuuuuuubcdloosuyyy123/
  s/[^a-z0-9._-]/_/g;s/__*/_/g;s/_\([.-]\)/\1/g;s/\([.-]\)_/\1/g'`
  [ "$A1" = "$A2" ] && continue ; [ -f "$D/$A2" -o -d "$D/$A2" ] && {
    i=1 ; while [ -f "$D/$A2.$i" -o -d "$D/$A2.$i" ]; do i=$((i+1)); done
    A2="$A2.$i"; }; mv -v -- "$A" "$D/$A2"; done
}


# ----------------------------------------------------------------------------
# Renomeia arquivos do diret�rio atual, arrumando a seq��ncia num�rica
# Obs.: �til para passar em arquivos de fotos baixadas de uma c�mera
# Op��es: -n  apenas mostra o que ser� feito, n�o executa
#         -i  define a contagem inicial
#         -d  n�mero de d�gitos para o n�mero
#         -p  prefixo padr�o para os arquivos
# Uso: zznomefoto [-n] [-i N] [-d N] [-p TXT] arquivo(s)
# Ex.: zznomefoto -n *                        # tire o -n para renomear!
#      zznomefoto -n -p churrasco- *.JPG      # tire o -n para renomear!
#      zznomefoto -n -d 4 -i 500 *.JPG        # tire o -n para renomear!
# ----------------------------------------------------------------------------
zznomefoto(){ zzzz -z $1 zznomefoto && return
[ "$1" ] || { echo "uso: zznomefoto [-n] [-i N] [-d N] [-p TXT] fotos.jpg";
return; }; local arq cont ext nao=0 i=1 dig=3 pref='' nome='';
while [ "${1#-}" != "$1" ]; do case "$1" in
  -p) pref="$2"; shift 2;; -i) i=$2 ; shift 2;;
  -d) dig=$2   ; shift 2;; -n) nao=1; shift  ;;
   *) break;; esac; done
for arq in "$@"; do
 cont=$(printf "%0${dig}d" $i); ext=".${arq##*.}"
 nome=$pref ; [ "$nome" ] || nome=$(echo ${arq%.*} | sed 's/[0-9][0-9]*$//')
 novo="$nome$cont$ext"; echo "$arq -> $novo"; i=$((i+1))
 [ "$nao" != 1 ] && {
  [ -e "$novo" ] && { echo "Arquivo $novo j� existe. Abortando."; return; }
  mv "$arq" "$novo"; }
done
}


# ----------------------------------------------------------------------------
# Mostra a diferen�a entre dois textos, mas no contexto de palavras
# �til para conferir revis�es ortogr�ficas ou mudan�as pequenas em frases
# Obs.: se tiver muitas _linhas_ diferentes o diff normal � aconselhado
# Uso: zzdiffpalavra arquivo1 arquivo2
# Ex.: zzdiffpalavra texto-orig.txt texto-novo.txt
#      zzdiffpalavra txt1 txt2 | vi -            # sa�da com sintaxe colorida
# ----------------------------------------------------------------------------
zzdiffpalavra(){ zzzz -z $1 zzdiffpalavra && return
[ "$2" ] || { echo 'uso: zzdiffpalavra arquivo1 arquivo2'; return; }
local split='s/$//;s/^/���\n/;s/ /\n/g' at1="$ZZTMP${1##*/}.$$"
local at2="$ZZTMP${2##*/}.$$"; sed "$split" $1 >$at1; sed "$split" $2 >$at2
diff -U 100 $at1 $at2 | cat -e - | sed '4,${s/^+/�/;s/^-/�/;};s/$$/�/' |
tr -d '\012' | sed 's/\(��[^�]*\)\{1,\}/\n&\n/g;s/\(��[^�]*\)\{1,\}/&\n/g;
s/\(� [^�]*\)\(\(��[^�]*\)\{1,\}\)/\1\n\2/g;s/�/\n/3;s/�/\n/2;s/�/\n/1;s/�//g;
s/\n�/\n+/g;s/\n�/\n-/g;s/[��]/ /g;s/\n\{0,1\} \{0,1\}���\n\{0,1\}/\n/g'
rm -f $at1 $at2
}


# ----------------------------------------------------------------------------
# Acha as fun��es de uma biblioteca da linguagem C (arquivos .h)
# Obs.: o diret�rio padr�o de procura � o /usr/include
# Uso: zzcinclude
# Ex.: zzcinclude stdio
#      zzcinclude /minha/rota/alternativa/stdio.h
# ----------------------------------------------------------------------------
zzcinclude(){ zzzz -z $1 zzcinclude && return
[ "$1" ] || { echo "uso: zzcinclude nome-biblioteca"; return; }
local i="$1"; [ "${i#/}" = "$i" ] && i="/usr/include/$i.h"
[ -f $i ] || { echo "$i n�o encontrado" ; return; } ; cpp -E $i |
sed '/^ *$/d;/^# /d;/^typedef/d;/^[^a-z]/d;s/ *(.*//;s/.* \*\{0,1\}//' | sort
}


# ----------------------------------------------------------------------------
# Acha os 15 maiores arquivos/diret�rios do diret�rio atual (ou especificados)
# Usando-se a op��o -r � feita uma busca recursiva nos subdiret�rios
# Uso: zzmaiores [-r] [dir1 dir2 ...]
# Ex.: zzmaiores
#      zzmaiores /etc /tmp
#      zzmaiores -r ~
# ----------------------------------------------------------------------------
zzmaiores(){ zzzz -z $1 zzmaiores && return
local d rr=0 ; [ "$1" == '-r' ] && { rr=1 ; shift; }
if   [ "$2" ]; then d=$(echo $* | sed 's/^/{/;s/$/}/;s/  */,/')
elif [ "$1" ]; then d="$1"; else d=.; fi
if [ $rr -eq 1 ]; then
  find $d -type f -printf "%11s  %p\n" | sort -nr | sed \
  -e ':p1' -e 's/^\( *[0-9][0-9]*\)\([0-9]\{3\}\)/\1.\2/; /^ *[0-9]\{4\}/b p1'\
  -e ':p2' -e 's/^/ / ; /^[ .0-9]\{1,13\}[0-9] /b p2' -e '15q'
else
  du -s $(eval echo $d/{*,.[^.]*}) 2>/dev/null | sort -nr | sed 15q
fi
}


# ----------------------------------------------------------------------------
# Conta o n�mero de vezes que uma palavra aparece num arquivo
# Obs.: -i Ignora a diferen�a de mai�sculas/min�sculas
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
grep $ic $word "$p" $arq | ([ "$ic" ] && zzminusculas || cat -) | sed "s�$p�\\
$mask�g" | grep -c "^$mask"
}


# ----------------------------------------------------------------------------
# Mostra uma linha de um texto, aleat�ria ou informada pelo n�mero
# Obs.: Se passado um argumento, restringe o sorteio �s linhas com o padr�o
# Uso: zzlinha [n�mero | -t texto] [arquivo]
# Ex.: zzlinha /etc/passwd           # mostra uma linha qualquer, aleat�ria
#      zzlinha 9 /etc/passwd         # mostra a linha 9 do arquivo
#      zzlinha -t root /etc/passwd   # mostra uma qqr, das que tiverem "root"
#      cat /etc/passwd | zzlinha     # o arquivo pode vir da entrada padr�o
# ----------------------------------------------------------------------------
zzlinha(){ zzzz -z $1 zzlinha && return
local n patt txt
[ "$1" = '-t' ] && { patt="$2"; shift; shift; }
[ "$1" = "${1%*[^0-9]}" ] && { n=$1; shift; }
if [ "$n" ]; then sed -n ${n}p "${1:--}"; else
txt=$(cat "${1:--}" | grep -i "${patt:-.}")
n=$(echo "$txt" | sed -n $=); n=$(((RANDOM%n)+1)); [ $n -eq 0 ] && n=1
echo "$txt" | sed -n ${n}p; fi
}


# ----------------------------------------------------------------------------
# #### C � L C U L O
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Calculadora: + - / * ^ %    # mais operadores, ver `man bc`
# Obs.: n�meros fracionados podem vir com v�rgulas ou pontos: 1,5 ou 1.5
# Uso: zzcalcula n�mero opera��o n�mero
# Ex.: zzcalcula 2,1 / 3,5
#      zzcalcula '2^2*(4-1)'  # 2 ao quadrado vezes 4 menos 1
# ----------------------------------------------------------------------------
zzcalcula(){ zzzz -z $1 zzcalcula && return
[ "$1" ] && echo "scale=2;$*" | sed y/,/./ | bc | sed y/./,/ ; }


# ----------------------------------------------------------------------------
# Faz c�lculos com datas e/ou converte data->num e num->data
# Que dia vai ser daqui 45 dias? Quantos dias h� entre duas datas? zzdata!
# Quando chamada com apenas um par�metro funciona como conversor de data
# para n�mero inteiro (N dias passados desde Epoch) e vice-versa.
# Obs.: Leva em conta os anos bissextos     (Epoch = 01/01/1970, edit�vel)
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
for d in $d1 $d2; do NUM=0 ; if [ "$d" = 'hoje' -o "$d" = 'today' ]; then
 d=`date +%d/%m/%Y` ; [ "$isd1" ] && d1=$d || d2=$d         # get 'today'
 elif [ "${d##*[^0-9/]}" != "$d" ]; then echo "data inv�lida '$d'"; return; fi
 if [ "$d" != "${d#*/}" ]; then n=1 ; y=$epoch              # --date2num--
  yyyy=${d##*/};dd=${d%%/*};mm=${d#*/};mm=${mm%/*};mm=${mm#0};dd=${dd#0}
  op=+; [ $yyyy -lt $epoch ] && op=-; while :; do days=365  # year2num
  [ $((y%4)) -eq 0 ]&&[ $((y%100)) -ne 0 ]||[ $((y%400)) -eq 0 ] && days=366
    [ $y -ne $yyyy ] || break; NUM=$((NUM $op days)); y=$((y $op 1)); done
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
# Faz c�lculos com hor�rios
# A op��o -r torna o c�lculo relativo � primeira data, por exemplo:
#   02:00 - 03:30 = -01:30 (sem -r) e 22:30 (com -r)
# Uso: zzhora [-r] hh:mm [+|- hh:mm]
# Ex.: zzhora 8:30 + 17:25        # preciso somar duas horas!
#      zzhora 12:00 - agora       # quando falta para o almo�o?
#      zzhora -12:00 + -5:00      # horas negativas!!!
#      zzhora 1000                # quanto � 1000 minutos?
#      zzhora -r 5:30 - 8:00      # que horas ir dormir pra acordar �s 5:30?
#      zzhora -r agora + 57:00    # e daqui 57 horas, ser� quando?
# ----------------------------------------------------------------------------
zzhora(){ zzzz -z $1 zzhora && return
local rel=0; [ "$1" = '-r' ] && rel=1 && shift
[ "$1" ] || { echo "uso: zzhora [-r] hh:mm [+|- hh:mm]"; return; }
local hh1 mm1 hh2 mm2 M1 M2 RES H M HD neg Hp Mp HDp
local D=0 hhmm1="$1" oper="${2:-+}" hhmm2="${3:-00}"
[ "${oper#[+-]}" ] && echo "Opera��o Inv�lida: $oper" && return
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
  [ $D -eq 1 ] && { extra=amanh�; [ "$neg" ] && extra=ontem; }
  [ $D -eq 0 ] && extra=hoje; [ "$extra" ] || extra="$neg${D} dias"
  echo "$HDp:$Mp ($extra)"
else
  echo "$neg$Hp:$Mp (${D}d ${HD}h ${M}m)"
fi
}


# ----------------------------------------------------------------------------
# Faz v�rias convers�es como: caracteres, temperatura e dist�ncia
#          cf = (C)elsius      para (F)ahrenheit
#          fc = (F)ahrenheit   para (C)elsius
#          ck = (C)elsius      para (K)elvin
#          kc = (K)elvin       para (C)elsius
#          fk = (F)ahrenheit   para (K)elvin
#          kf = (K)elvin       para (F)ahrenheit
#          km = (K)Quil�metros para (M)ilhas
#          mk = (M)ilhas       para (K)Quil�metros
#          db = (D)ecimal      para (B)in�rio
#          bd = (B)in�rio      para (D)ecimal
#          cd = (C)aractere    para (D)ecimal
#          dc = (D)ecimal      para (C)aractere
# Uso: zzconverte <cf|fc|ck|kc|fk|kf|mk|km|db|bd|cd> n�mero
# Ex.: zzconverte cf 5
#      zzconverte dc 65
#      zzconverte db 32
# ----------------------------------------------------------------------------
zzconverte(){ zzzz -z $1 zzconverte && return
[ "$1" = "cf" ] && echo "$2 C = $(echo "scale=2;($2*9/5)+32"     | bc) F"
[ "$1" = "fc" ] && echo "$2 F = $(echo "scale=2;($2-32)*5/9"     | bc) C"
[ "$1" = "ck" ] && echo "$2 C = $(echo "scale=2;$2+273.15"       | bc) K"
[ "$1" = "kc" ] && echo "$2 K = $(echo "scale=2;$2-273.15"       | bc) C"
[ "$1" = "kf" ] && echo "$2 K = $(echo "scale=2;($2*1.8)-459.67" | bc) F"
[ "$1" = "fk" ] && echo "$2 F = $(echo "scale=2;($2+459.67)/1.8" | bc) K"
[ "$1" = "km" ] && echo "$2 km = $(echo "scale=2;$2*0.6214"      | bc) milhas"
[ "$1" = "mk" ] && echo "$2 milhas = $(echo "scale=2;$2*1.609"   | bc) km"
[ "$1" = "db" ] && echo "obase=2;$2" | bc -l
[ "$1" = "bd" ] && echo "$((2#$2))"
[ "$1" = "cd" ] && echo -n "$2" | od -d | sed -n '1s/^.*  *//p'
[ "$1" = "dc" ] && awk "BEGIN {printf(\"%c\n\",$2)}"
}


# ----------------------------------------------------------------------------
# Gera um CPF v�lido aleat�rio ou valida um CPF informado
# Obs.: O CPF informado pode estar formatado (pontos e h�fen) ou n�o
# Uso: zzcpf [cpf]
# Ex.: zzcpf 123.456.789-09          # valida o CPF
#      zzcpf 12345678909             # com ou sem formatadores 
#      zzcpf                         # gera um CPF v�lido
# ----------------------------------------------------------------------------
zzcpf(){ zzzz -z $1 zzcpf && return
local i n z d1 d2 cpf base
cpf="$(echo $1 | sed 's/[^0-9]//g')" ; if [ "$cpf" ]
then [ ${#cpf} -ne 11 ] && { echo "CPF inv�lido"; return; }; base=${cpf%??}
else while [ ${#cpf} -lt 9 ]; do cpf="$cpf$((RANDOM%9))"; done; base=$cpf; fi
set - $(echo $base | sed 's/./& /g') # c�lculo do d�gito 1
z=0; for i in 10 9 8 7 6 5 4 3 2 ; do n=$1; z=$((z+(i*n))); shift; done
d1=$((11-(z%11))) ; [ $d1 -ge 10 ] && d1=0
set - $(echo $base | sed 's/./& /g') # c�lculo do d�gito 2
z=0; for i in 11 10 9 8 7 6 5 4 3; do n=$1; z=$((z+(i*n))); shift; done
z=$((z+d1*2)) ; d2=$((11-(z%11))) ; [ $d2 -ge 10 ] && d2=0
if [ ${#cpf} -eq 9 ]                 # ou mostra ou valida
then echo $cpf-$d1$d2 | sed 's/\(...\)\(...\)\(...\)/\1.\2.\3/'
elif [ "${cpf#?????????}" = "$d1$d2" ]; then echo CPF v�lido
else echo "CPF inv�lido (-$d1$d2)"
fi
}


# ----------------------------------------------------------------------------
# Gera um CNPJ v�lido aleat�rio ou valida um CNPJ informado
# Obs.: O CNPJ informado pode estar formatado (pontos e h�fen) ou n�o
# Uso: zzcnpj [cnpj]
# Ex.: zzcnpj 12.345.678/0001-95      # valida o CNPJ
#      zzcnpj 12345678000195          # com ou sem formatadores 
#      zzcnpj                         # gera um CNPJ v�lido
# ----------------------------------------------------------------------------
zzcnpj(){ zzzz -z $1 zzcnpj && return
local i n z d1 d2 cnpj base
cnpj="$(echo $1 | sed 's/[^0-9]//g')" ; if [ "$cnpj" ]
then [ ${#cnpj} -ne 14 ] && { echo "CNPJ inv�lido"; return; }; base=${cnpj%??}
else while [ ${#cnpj} -lt 8 ]; do cnpj="$cnpj$((RANDOM%9))"; done
  cnpj="${cnpj}0001"; base=$cnpj; fi
set - $(echo $base | sed 's/./& /g') # c�lculo do d�gito 1
z=0; for i in 5 4 3 2 9 8 7 6 5 4 3 2 ; do n=$1; z=$((z+(i*n))); shift; done
d1=$((11-(z%11))) ; [ $d1 -ge 10 ] && d1=0
set - $(echo $base | sed 's/./& /g') # c�lculo do d�gito 2
z=0; for i in 6 5 4 3 2 9 8 7 6 5 4 3 2; do n=$1; z=$((z+(i*n))); shift; done
z=$((z+d1*2)); d2=$((11-(z%11))) ; [ $d2 -ge 10 ] && d2=0
if [ ${#cnpj} -eq 12 ]               # ou mostra ou valida
then echo $cnpj-$d1$d2 | sed 's|\(..\)\(...\)\(...\)\(....\)|\1.\2.\3/\4|'
elif [ "${cnpj#????????????}" = "$d1$d2" ]; then echo CNPJ v�lido
else echo "CNPJ inv�lido (-$d1$d2)"
fi
}


# ----------------------------------------------------------------------------
# Calcula o endere�o da rede e o endere�o de broadcast a partir de um 
# ip e uma m�scara de rede
# OBS: se n�o for especificado a m�scara, � assumido a 255.255.255.0
# Uso: zzcalculaip ip netmask
# Ex.: zzcalculaip 127.0.0.1 24
#      zzcalculaip 10.0.0.0/8
#      zzcalculaip 192.168.10.0 255.255.255.240 
#      zzcalculaip 10.10.10.0
# ----------------------------------------------------------------------------
zzcalculaip(){ zzzz -z $1 zzcalculaip && return
[ "$1" ] || { echo "Uso: zzcalculaip ip netmask"; return; }
local addr=${1%/*} mask i ip1 ip2 ip3 ip4 nm1 nm2 nm3 nm4 nm_d net bcast
[ "$(echo $addr|sed "s/\(\([0-9]\{1,2\}\|1[0-9][0-9]\|2[0-4][0-9]\|25[0-5]\)\
\.\)\{3\}\([0-9]\{1,2\}\|1[0-9][0-9]\|2[0-4][0-9]\|25[0-5]\)//")" ] && 
{ echo IP inv�lido; return; }; [ "$1" = "${1#*/}" ] && mask=${2:-24} ||
mask="${1#*/}"; [ "${mask//[0-9.]/}" ] && { echo 'Mascara invalida';return; }
set -- ${mask//./ }; if [ $# != 4 ]; then  
[ "$1" -gt 0 -a "$1" -le 32 -a ! "$2" ] && mask=$(echo 1|sed "/^1\{$1\}$/bb;:a
s/^1\{1,$(($1-1))\}$/&1/;ta;:b;s/^[01]\{1,31\}$/&0/;tb;s/[01]\{8\}/&./g
s/\.$//") || { [ $2 ] || { echo 'Mascara invalida';return; }; } fi
for i in 1 2 3 4;do eval ip$i=$(zzconverte db $(echo $addr | cut -d'.' -f $i)|
sed ':a;s/^[01]\{1,7\}$/0&/;ta'); [ "$2" ] && eval nm$i=$(zzconverte db \
$(echo $mask|cut -d'.' -f $i) | sed ':a;s/^[01]\{1,7\}$/0&/;ta') ||
eval nm$i=$(echo $mask | cut -d'.' -f $i); done
[ "$(echo $nm1$nm2$nm3$nm4 | sed '/^.\{32\}$/s/^1*0*$//')" ] && { 
echo Mascara invalida;return; }; nm_d="${nm1//0}${nm2//0}${nm3//0}${nm4//0}"
echo "End. IP.. : $addr" 
echo "Mascara.. : $((2#$nm1)).$((2#$nm2)).$((2#$nm3)).$((2#$nm4)) = ${#nm_d}"
net=$((((2#$ip1$ip2$ip3$ip4)) & ((2#$nm1$nm2$nm3$nm4))))
i=$(echo $nm1$nm2$nm3$nm4 | sed 's/1/2/g;s/0/1/g' | sed 's/2/0/g')
bcast=$(($net | ((2#$i))))
addr=""; for i in 1 2 3 4; do ip1=$((net & 255)) net=$((net >> 8))
addr="${ip1}.$addr"; done; echo "Rede      : ${addr%.} / ${#nm_d}"
addr=""; for i in 1 2 3 4; do ip1=$((bcast & 255)) bcast=$((bcast >> 8))
addr="${ip1}.$addr"; done; echo "Broadcast : ${addr%.}"
}


#-----------8<------------daqui pra baixo: FUN��ES QUE FAZEM BUSCA NA INTERNET
#-------------------------podem parar de funcionar se as p�ginas mudarem


# ----------------------------------------------------------------------------
# #### C O N S U L T A S                                         (internet)
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# http://br.invertia.com
# Busca a cota��o do dia do d�lar (comercial, paralelo e turismo)
# Obs.: as cota��es s�o atualizadas de 10 em 10 minutos
# Uso: zzdolar
# ----------------------------------------------------------------------------
zzdolar(){ zzzz -z $1 zzdolar && return
$ZZWWWDUMP 'http://br.invertia.com/mercados/divisas/tiposdolar.asp' |
sed 's/^ *//;/Data:/,/Turismo/!d;/percent/d;s/  */ /g
     s/.*Data: \(.*\)/\1 compra   venda   hora/;s|^[1-9]/|0&|;
     s@^\([0-9][0-9]\)/\([0-9]/\)@\1/0\2@
     s/^D.lar //;s/- Corretora//;s/ SP//g;s/ [-+]\{0,1\}[0-9.,]\{1,\}  *%$//
     s/al /& /;s/lo /&   /;s/mo /&    /;s/ \([0-9]\) / \1.000 /
     s/\.[0-9]\>/&0/g;s/\.[0-9][0-9]\>/&0/g;/^[^0-9]/s/[0-9] /&  /g'
}


# ----------------------------------------------------------------------------
# http://br.invertia.com
# Busca a cota��o de v�rias moedas (mais de 100!) em rela��o ao d�lar
# Com a op��o -t, mostra TODAS as moedas, sem ela, apenas as principais
# � poss�vel passar v�rias palavras de pesquisa para filtrar o resultado
# Obs.: Hora GMT, D�lares por unidade monet�ria para o Euro e a Libra
# Uso: zzmoeda [-t] [pesquisa]
# Ex.: zzmoeda
#      zzmoeda -t
#      zzmoeda euro libra
#      zzmoeda -t peso
# ----------------------------------------------------------------------------
zzmoeda(){ zzzz -z $1 zzmoeda && return
local URL='http://br.invertia.com/mercados/divisas'
local dolar='DOLCM' extra='' patt='.'
[ "$1" = '-t' ] && { extra='divisasregion.aspx?idtel=TODAS' dolar=@; shift; }
[ "$1" ] && patt=$(echo $* | sed 's/ /\\|/g')
$ZZWWWDUMP "$URL/$extra" | sed "/[0-9][0-9]$/!d; /D�lar \(Paral\|Ptax\|Turi\)/d
  s/\[.*]//; s/^ */  /; s/\( *-\{0,1\}[0-9][,.0-9]\{1,\}\)\{2\}% */    /
  /$dolar/{s// &    /;}" | grep -i $patt
}


# ----------------------------------------------------------------------------
# http://www.itautrade.com.br e http://www.bovespa.com.br
# Busca a cota��o de uma a��o na Bovespa
# Obs.: as cota��es t�m delay de 15 min em rela��o ao pre�o atual no preg�o
#       Com a op��o -i, � mostrado o �ndice bovespa
# Uso: zzbovespa [-i] c�digo-da-a��o
# Ex.: zzbovespa petr4
#      zzbovespa -i
#      zzbovespa
# ----------------------------------------------------------------------------
zzbovespa(){ zzzz -z $1 zzbovespa && return
local URL='http://www.bovespa.com.br/'
[ "$1" ] || { $ZZWWWDUMP "$URL/Indices/CarteiraP.asp?Indice=Ibovespa" |
sed '/^ *C�d/,/^$/!d'; return; }
[ "$1" = "-i" ] && { $ZZWWWHTML "$URL/Home/HomeNoticias.asp" | sed -n '
/Ibovespa -->/,/IBrX/{//d;s/<[^>]*>//g;s/[[:space:]]*//g;s/^&.*\;//;/^$/d
p;}' | sed '/^Pon/{N;s/^/           /;s/\n/   /;b;};/^IBO/N;N;s/\n/  /g
/^<.-- /d;:a;s/^\([^0-9]\{1,10\}\)\([0-9][0-9]*\)/\1 \2/;ta'; return; }
local URL='http://www.itautrade.com.br/itautradenet/Finder/Finder.aspx?Papel='
$ZZWWWDUMP "$URL$1" | sed '/A��o\|Fracion�rio/,/Oferta/!d; //d; /\.gif/d
s/^ *//; /Milhares/q'
}


# ----------------------------------------------------------------------------
# http://www.wikipedia.org
# Procura no Wikip�dia (enciclop�dia livre)
# Obs.: se nenhum idioma for especificado � utilizado o ingl�s como padr�o
#
# Idiomas: de (alem�o)  , eo (esperanto), es (espanhol), fr (frances),
#          it (italiano), ja (japones)  , la (latin)   , pt (portugues)
#
# Uso: zzwikipedia [-idioma] palavra(s)
# Ex.: zzwikipedia sed
#      zzwikipedia Linus Torvalds
#      zzwikipedia -pt Linus Torvalds
#
# ----------------------------------------------------------------------------
zzwikipedia(){ zzzz -z $1 zzwikipedia && return
local URL idioma; [ "${1#-}" != "$1" ] && { idioma="${1#-}"; shift; }
URL="http://${idioma:-en}.wikipedia.org/wiki/"
[ "$1" ] || { echo 'uso: zzwikipedia [-idioma] palavra(s)'; return; }
$ZZWWWDUMP "$URL$(echo $* | sed 's/  */_/g')" | sed '2d;/^Views$/,$d' |
${PAGER:-less -r}
}


# ----------------------------------------------------------------------------
# http://www.receita.fazenda.gov.br
# Consulta os lotes de restitui��o do imposto de renda
# Obs.: funciona para os anos de 2001, 2002 e 2003
# Uso: zzirpf ano n�mero-cpf
# Ex.: zzirpf 2003 123.456.789-69
# ----------------------------------------------------------------------------
zzirpf(){ zzzz -z $1 zzirpf && return
[ "$2" ] || { echo 'uso: zzirpf ano n�mero-cpf'; return; }
local ano=$1 URL='http://www.receita.fazenda.gov.br/Scripts/srf/irpf'
z=${ano#200} ; [ "$z" != 1 -a "$z" != 2 -a "$z" != 3 ] && {
echo "Ano inv�lido '$ano'. Deve ser 2001, 2002 ou 2003."; return; }
$ZZWWWDUMP "$URL/$ano/irpf$ano.dll?VerificaDeclaracao&CPF=$2" |
sed '1,8d;s/^ */  /;/^  \[BUTTON\]/,$d'
}


# ----------------------------------------------------------------------------
# http://www.terra.com.br/cep
# Busca o CEP de qualquer rua de qualquer cidade do pa�s ou vice-versa
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
sed -n '/^ *UF:/,/^$/{ /P�gina Anter/d; s/.*�xima P�g.*/...CONTINUA/; p;}'
}


# ----------------------------------------------------------------------------
# http://www.pr.gov.br/detran
# Consulta d�bitos do ve�culo, como licenciamento, IPVA e multas (detran-PR)
# Uso: zzdetranpr n�mero-renavam
# Ex.: zzdetranpr 123456789
# ----------------------------------------------------------------------------
zzdetranpr(){ zzzz -z $1 zzdetranpr && return
[ "$1" ] || { echo 'uso: zzdetranpr n�mero-renavam'; return; }
local URL='http://celepar7.pr.gov.br/detran/consultas/veiculos/deb_novo.asp';
$ZZWWWDUMP "$URL?renavam=$1" | sed 's/^  *//;/^\(___*\)\{0,1\}$/d; /^\[/d;
1,/^\(Renavam\|Data\):/{//!d;}; /^Resumo das Multas\|^Voltar$/,$d;
/^AUTUA�/,${/^Infra��o:/!d;s///;}; /^\(Discrimi\|Informa\)/s/.*//;
/^Placa/s/^[^:]*: \([A-Z0-9-]\{1,\}\).*:/\1 ano/;/^\(Marca\|Munic\)/s/[^:]*: //
s|^\(.*\) \([0-9][0-9]*,[0-9]\{2\}\|\*\*\* QUITADO \*\*\*\)|\2 \1|;'
}

# ----------------------------------------------------------------------------
# http://www.detran.sp.gov.br
# Consulta d�bitos do ve�culo, como licenciamento, IPVA e multas (detran-SP)
# Uso: zzdetransp n�mero-renavam
# Ex.: zzdetransp 123456789
# ----------------------------------------------------------------------------
zzdetransp(){ zzzz -z $1 zzdetransp && return
[ "$1" ] || { echo 'uso: zzdetransp n�mero-renavam'; return; }
local URL='http://sampa5.prodam.sp.gov.br/multas/c_multas.asp'; echo
echo "text1=$1" | $ZZWWWPOST "$URL" | sed 's/^ *//;/^Resultado/,/^�ltima/!d;
/^____*$/s/.*/_____/; /^Resultado/s/.* o Ren/Ren/;
/^Seq /,/^Total/{/^Seq/d;/^Total/!s/^/+++/;};
/�ltima/{G;s/\n//;s/\n_____\(\n\)$/\1/;s/^[^:]\{1,\}/Data   /;p;};H;d' |
sed '/^+++/{H;g;s/^\(\n\)+++[0-9][0-9]* \(...\)\(....\) \([^ ]\{1,\} \)\{2\}\(.*\) \('$ZZERDATA' '$ZZERHORA'\) \(.*\) \('$ZZERDATA' .*\)/Placa: \2-\3\nData : \6\nLocal: \7\nInfr.: \5\nMulta: \8\n/;}'
}

# ----------------------------------------------------------------------------
# http://www1.caixa.gov.br/loterias
# Consulta os resultados da quina, megasena, duplasena, lotomania e lotof�cil
# Uso: zzloteria
# Ex.: zzloteria
# ----------------------------------------------------------------------------
zzloteria(){ zzzz -z $1 zzloteria && return
local dump num res acu tipo URL=http://www1.caixa.gov.br/loterias/loterias
for tipo in quina megasena duplasena lotomania lotofacil; do echozz $tipo:
 dump=$($ZZWWWHTML "$URL/$tipo/${tipo}_pesquisa.asp")
 num=$(echo "$dump" | sed -n "s/^\([0-9][0-9]*\)|.*|\($ZZERDATA\)|.*/\1 (\2)/p")
 acu=$(echo "$dump" | sed -n '/ACUMUL/{
       s/.*ACUMUL.* \([0-9/][0-9/: R$.,Mi]*,00\)\..*/Acumulado para \1/
       s/\.\([0-9]\)00\.000,00/.\1 Mi/ ; p ;}')
 if test $tipo = 'lotomania'; then
   res=$(echo "$dump" | sed -n 's/.*[>|]|\(\([0-9][0-9]|\)\{20\}\).*/\1/p'|
         sed 's/|$// ; s/|/@   /10 ; s/|/ - /g' | tr @ '\n')
 elif test $tipo = 'lotofacil'; then
   res=$(echo "$dump" | sed -n 's/.*[>|]|\(\([0-9][0-9]|\)\{15\}\).*/\1/p' |
         sed 's/|$// ; s/|/@   /10 ; s/|/@   /5 ; s/|/ - /g' | tr @ '\n')
 else
   res=$(echo "$dump" | sed -n 's,.*<ul>\(\(<li>[0-9][0-9]*</li>\)*\)</ul>.*,\1,p' |
         sed 's,</li><li>, - ,g;s,</*li>,,g'); fi
 echo -e "   $res\n   Concurso $num"; [ "$acu" ] && echo "   $acu"; echo
done
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
sed -n 's@.*\(http.*freshmeat.net/projects/.*\)/@\1@p'
}



# ----------------------------------------------------------------------------
# http://rpmfind.net/linux
# Procura por pacotes RPM em v�rias distribui��es
# Obs.: a arquitetura padr�o de procura � a i386
# Uso: zzrpmfind pacote [distro] [arquitetura]
# Ex.: zzrpmfind sed
#      zzrpmfind lilo mandr i586
# ----------------------------------------------------------------------------
zzrpmfind(){ zzzz -z $1 zzrpmfind && return
[ "$1" ] || { echo 'uso: zzrpmfind pacote [distro] [arquitetura]'; return; }
local URL='http://rpmfind.net/linux/rpm2html/search.php'
echozz 'ftp://rpmfind.net/linux/'
$ZZWWWLIST "$URL?query=$1&submit=Search+...&system=$2&arch=${3:-i386}" |
sed -n '/ftp:\/\/rpmfind/ s@^[^A-Z]*/linux/@  @p' | sort
}



# ----------------------------------------------------------------------------
# #### D I V E R S O S                                           (internet)
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# http://www.iana.org/cctld/cctld-whois.htm
# Busca a descri��o de um c�digo de pa�s da internet (.br, .ca etc)
# Obs.: o sed deve suportar o I de ignorecase na pesquisa
# Uso: zzdominiopais [.]c�digo|texto
# Ex.: zzdominiopais .br
#      zzdominiopais br
#      zzdominiopais republic
# ----------------------------------------------------------------------------
zzdominiopais(){ zzzz -z $1 zzdominiopais && return
[ "$1" ] || { echo 'uso: zzdominiopais [.]c�digo|texto'; return; }
local i1 i2 a='/usr/share/zoneinfo/iso3166.tab' p=${1#.}
[ $1 != $p ] && { i1='^'; i2='^\.'; }
[ -f $a ] && { echozz 'local:'; grep -i "$i1$p" $a | sed "/^#/d"; }
local URL='http://www.iana.org/root-whois/index.html' ; echozz 'www  :'
$ZZWWWDUMP "$URL" | sed 's/^  *//;/^\./!d' | grep -i "$i2$p"
}


# ----------------------------------------------------------------------------
# http://funcoeszz.net/locales.txt
# Busca o c�digo do idioma (locale). Por exemplo, portugu�s � pt_BR.
# Com a op��o -c, pesquisa somente nos c�digos e n�o em sua descri��o.
# Uso: zzlocale -c c�digo|texto
# Ex.: zzlocale chinese
#      zzlocale -c pt
# ----------------------------------------------------------------------------
zzlocale(){ zzzz -z $1 zzlocale && return
[ "$1" ] || { echo 'uso: zzlocale c�digo|texto'; return; }
local txt="$1" URL='http://funcoeszz.net/locales.txt'
[ "$1" = '-c' ] && { txt="$2[^ ]*$"; }
$ZZWWWDUMP "$URL" | grep -i -- "$txt"
}


# ----------------------------------------------------------------------------
# http://wwwkeys.pgp.net
# Busca a identifica��o da chave PGP, fornecido o nome ou email da pessoa
# Obs.: de brinde, instru��es de como adicionar a chave a sua lista
# Uso: zzchavepgp nome|email
# Ex.: zzchavepgp Carlos Oliveira da Silva
#      zzchavepgp carlos@dominio.com.br
# ----------------------------------------------------------------------------
zzchavepgp(){ zzzz -z $1 zzchavepgp && return
[ "$1" ] || { echo 'uso: zzchavepgp nome|email'; return; }
local id TXT=`echo "$*"| sed "$ZZSEDURL"` URL='http://wwwkeys.pgp.net:11371'
$ZZWWWDUMP "$URL/pks/lookup?docmd=lookup&search=$TXT&op=index" |
sed '/^Type /,$!d;$G' | tee /dev/stderr |
sed -n 's@^[^/]*/\([0-9A-F]\{1,\}\) .*@\1@p' | while read id; do
[ "$id" ] && echo "adicionar: gpg --recv-key $id && gpg --list-keys $id"; done
}


# ----------------------------------------------------------------------------
# http://www.dicas-l.unicamp.br
# Procura por dicas sobre determinado assunto na lista Dicas-L
# Obs.: as op��es do grep podem ser usadas (-i j� � padr�o)
# Uso: zzdicasl [op��o-grep] palavra(s)
# Ex.: zzdicasl ssh
#      zzdicasl -w vi
#      zzdicasl -vEw 'windows|unix|emacs'
# ----------------------------------------------------------------------------
zzdicasl(){ zzzz -z $1 zzdicasl && return
[ "$1" ] || { echo 'uso: zzdicasl [op��o-grep] palavra(s)'; return; }
local o URL='http://www.dicas-l.com.br'; [ "${1##-*}" ] || { o=$1; shift; }
echozz "$URL/dicas-l/"; $ZZWWWHTML "$URL/dicas-l" | grep -i $o "$*" |
sed -n 's@^<LI><A HREF=\([^>]*\)> *\([^ ].*\)</A>@\1: \2@p'
}


# ----------------------------------------------------------------------------
# http://registro.br
# Whois da fapesp para dom�nios brasileiros
# Uso: zzwhoisbr dom�nio
# Ex.: zzwhoisbr abc.com.br
#      zzwhoisbr www.abc.com.br
# ----------------------------------------------------------------------------
zzwhoisbr(){ zzzz -z $1 zzwhoisbr && return
[ "$1" ] || { echo 'uso: zzwhoisbr dom�nio'; return; }
local dom="${1#www.}" URL='http://registro.br/cgi-bin/nicbr/whois'
$ZZWWWDUMP "$URL?qr=$dom" | sed '1,/^%/d;/^remarks/,$d;/^%/d;
/^alterado\|atualizado /d'
}


# ----------------------------------------------------------------------------
# http://www.whatismyip.com
# Mostra o seu n�mero IP (externo) na Internet
# Uso: zzipinternet
# Ex.: zzipinternet
# ----------------------------------------------------------------------------
zzipinternet(){ zzzz -z $1 zzipinternet && return
local URL='http://www.whatismyip.com'
$ZZWWWDUMP $URL | sed -n 's/^ *\([0-9]\{1,3\}\.[0-9.]*\) */IP: \1/p'
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
  $ZZWWWHTML "$URL" | sed -n '/alt="\[TXT\]"/{
  s/^.*href="\([^"]*\).*/\1/;p;}' > $arq ; echo ' feito!' ; }
[ "$z" ] && { echozz $URL; grep -i "$z" $arq; }
}


# ----------------------------------------------------------------------------
# http://... - v�rios
# Busca as �ltimas not�cias sobre linux em p�ginas nacionais
# Obs.: cada p�gina tem uma letra identificadora que pode ser passada como
#       par�metro, identificando quais p�ginas voc� quer pesquisar:
#
#         Y)ahoo Linux         B)r Linux
#         C)ipsga              N)ot�cias linux
#         V)iva o Linux        I)nfoexame
#         U)nder linux
#
# Uso: zznoticiaslinux [sites]
# Ex.: zznoticiaslinux
#      zznoticiaslinux yni
# ----------------------------------------------------------------------------
zznoticiaslinux(){ zzzz -z $1 zznoticiaslinux && return
local URL limite n=5 s='byvucin'; limite="sed ${n}q"; [ "$1" ] && s="$1"
[ "$s" != "${s#*y}" ] && { URL='http://br.news.yahoo.com/tecnologia/linux.html'
  echo ; echozz "* Yahoo Linux ($URL):"; $ZZWWWHTML $URL |
  sed -n '/span class="a5">/s/ \{0,1\}<[^>]*>//gp' | $limite ; }
[ "$s" != "${s#*v}" ] && { URL='http://www.vivaolinux.com.br'
  echo ; echozz "* Viva o Linux ($URL):"; $ZZWWWHTML $URL/index.rdf |
  sed -n '1,/<item>/d;s@.*<title>\(.*\)</title>@\1@p' | $limite ; }
[ "$s" != "${s#*c}" ] && { URL='http://www.cipsga.org.br'
  echo ; echozz "* CIPSGA ($URL):"; $ZZWWWHTML $URL |
  sed '/^.*<tr><td bgcolor="88ccff"><b>/!d;s///;s@</b>.*@@' | $limite; }
[ "$s" != "${s#*b}" ] && { URL='http://br-linux.org/rss/brlinux-iso.xml'
  echo ; echozz "* BR Linux ($URL):"; $ZZWWWDUMP $URL |
  sed -n '1,/<item>/d;s@.*<title>\(.*\)</title>@\1@p' | $limite; }
[ "$s" != "${s#*i}" ] && { URL='http://info.abril.com.br/aberto/infonews/'
  echo ; echozz "* InfoExame ($URL):"; $ZZWWWHTML $URL/index.shl |
  sed -n '/class="teste"/s/<[^>]*>//pg' | $limite; }
[ "$s" != "${s#*u}" ] && { URL='http://under-linux.org/'
  echo ; echozz "* UnderLinux ($URL):"; $ZZWWWHTML "$URL" |
  sed -n '/class="entry-title/{s/<[^>]*>//g;s/^[[:blank:]]*//;p;}'|$limite;}
[ "$s" != "${s#*n}" ] && { URL='http://www.noticiaslinux.com.br'
  echo ; echozz "* Not�cias Linux ($URL):"; $ZZWWWHTML "$URL" |
  sed -n '/<[hH]3>/{s/<[^>]*>//g;s/^[[:blank:]]*//g;p;}' | $limite; }
}


# ----------------------------------------------------------------------------
# http://... - v�rios
# Busca as �ltimas not�cias sobre linux em p�ginas em ingl�s.
# Obs.: cada p�gina tem uma letra identificadora que pode ser passada como
#       par�metro, identificando quais p�ginas voc� quer pesquisar:
#
#          F)reshMeat         Linux T)oday
#          S)lashDot          Linux W)eekly News
#          N)ewsForge         O)S News
#
# Uso: zzlinuxnews [sites]
# Ex.: zzlinuxnews
#      zzlinuxnews fsn
# ----------------------------------------------------------------------------
zzlinuxnews(){ zzzz -z $1 zzlinuxnews && return
local URL limite n=5 s='fsntwo'; limite="sed ${n}q"; [ "$1" ] && s="$1"
[ "$s" != "${s#*f}" ] && { URL='http://freshmeat.net'
  echo ; echozz "* FreshMeat ($URL):"; $ZZWWWHTML $URL |
  sed '/href="\/releases/!d;s/<[^>]*>//g;s/&nbsp;//g;s/^ *- //' | $limite ; }
[ "$s" != "${s#*s}" ] && { URL='http://slashdot.org'
  echo ; echozz "* SlashDot ($URL):"; $ZZWWWHTML $URL |
  sed -n '/<div class="title">/,/<\/div>/{/slashdot/{
          s/<[^>]*>//g;s/^[[:blank:]]*//;p;};}' | $limite;}
[ "$s" != "${s#*n}" ] && { URL='http://www.newsforge.com'
  echo ; echozz "* NewsForge - ($URL):"; $ZZWWWHTML $URL |
  sed -n "/^<h3>/s/<[^>]*>//gp" | $limite ; }
[ "$s" != "${s#*t}" ] && { URL='http://linuxtoday.com/backend/biglt.rss'
  echo ; echozz "* Linux Today ($URL):"; $ZZWWWHTML $URL |
  sed -n '1,/<item>/d;s@.*<title>\(.*\)</title>@\1@p' | $limite ; }
[ "$s" != "${s#*w}" ] && { URL='http://lwn.net/Articles'
  echo ; echozz "* Linux Weekly News - ($URL):"; $ZZWWWHTML $URL |
  sed '/class="Headline"/!d;s/^ *//;s/<[^>]*>//g' | $limite ; }
[ "$s" != "${s#*o}" ] && { URL='http://osnews.com'
  echo ; echozz "* OS News - ($URL):"; $ZZWWWDUMP $URL |
  sed -n '/^ *By /{g;s/^ *//;p;};h' | $limite; }
}



# ----------------------------------------------------------------------------
# http://... - v�rios
# Busca as �ltimas not�cias em sites especializados em seguran�a
# Obs.: cada p�gina tem uma letra identificadora que pode ser passada como
#       par�metro, identificando quais p�ginas voc� quer pesquisar:
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
  sed -n '/item/,$s@.*<title>\(.*\)</title>@\1@p' | $limite ; }
[ "$s" != "${s#*s}" ] && {
  URL='http://www.linuxsecurity.com/linuxsecurity_advisories.rdf'
  echo ; echozz "* Linux Security ($URL):"; $ZZWWWDUMP $URL |
  sed -n '/item/,$s@.*<title>\(.*\)</title>@\1@p' | $limite ; }
[ "$s" != "${s#*c}" ] && { URL='http://www.us-cert.gov/channels/techalerts.rdf'
  echo ; echozz "* CERT/CC ($URL):"; $ZZWWWDUMP $URL |
  sed -n '/item/,$s@.*<title>\(.*\)</title>@\1@p' | $limite ; }
[ "$s" != "${s#*t}" ] && { URL='http://linuxtoday.com/security/index.html'
  echo ; echozz "* Linux Today - Security ($URL):"; $ZZWWWHTML $URL |
  sed -n '/class="nav"><B>/s/<[^>]*>//gp' | $limite ; }
[ "$s" != "${s#*f}" ] && { URL='http://www.securityfocus.com/bid'
  echo ; echozz "* SecurityFocus Vulns Archive ($URL):"; $ZZWWWDUMP $URL |
  sed -n '/^ *\([0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\)/{ G; s/^ *//;s/\n//p; };h'|
  $limite ; }
}


# ----------------------------------------------------------------------------
# http://... - v�rios
# Mostra os �ltimos 5 avisos de seguran�a de v�rias distribui��es e SO
# As suportadas: 
#     conectiva   debian   slackware    gentoo 
#     mandriva    suse     fedora       freebsd 
#
# Uso: zzsecurity [distros]
# Ex.: zzsecutiry
#      zzsecurity conectiva
#      zzsecurity debian gentoo 
# ----------------------------------------------------------------------------
zzsecurity(){ zzzz -z $1 zzsecurity && return
local URL d n=5 CNC9 CNC10
local limite="sed ${n}q"; [ "$1" ] && d="$*" ||
  d='conectiva debian slackware gentoo mandriva suse fedora freebsd' 
[ "$d" != "${d#*conectiva}" ] && { CNC9='000017'; CNC10='000018' 
URL='http://distro.conectiva.com.br/atualizacoes/index.php?id=d&distro='
echo ; echozz "** Atualiza��es Conectiva 9"; echo "$URL$CNC9"
$ZZWWWDUMP "$URL$CNC9" |
sed '/^ *200[0-9]-[0-1][0-9]-[0-3][0-9]/!d;s/^ *//;s/   */ - /' | $limite 
echo ; echozz "** Atualiza��es Conectiva 10"; echo "$URL$CNC10"
$ZZWWWDUMP "$URL$CNC10" |
sed '/^ *200[0-9]-[0-1][0-9]-[0-3][0-9]/!d;s/^ *//;s/   */ - /' | $limite ;}
[ "$d" != "${d#*debian}" ] &&  { URL='http://www.debian.org'
echo; echozz "** Atualiza��es Debian woody"; echo "$URL"
$ZZWWWDUMP "$URL" | 
sed -n '/Security Advisories/,/_______/{/\[[0-9]/s/^ *//p;}' | $limite ;}
[ "$d" != "${d#*slackware}" ] && { echo; echozz "\n** Atualiza��es Slackware"
URL='http://www.slackware.com/security/list.php?l=slackware-security&y=2005'
echo "$URL"; $ZZWWWDUMP "$URL" |
sed '/[0-9]\{4\}-[0-9][0-9]/!d;s/\[sla.*ty\]//;s/^  *//' | $limite ;  }
[ "$d" != "${d#*gentoo}" ] && { echo; echozz "** Atualiza��es Gentoo"
URL='http://www.gentoo.org/security/en/index.xml'; echo "$URL"
$ZZWWWDUMP "$URL" | sed -n '/Recent Advisories/,/^ *$/!d;/[0-9]\{4\}/{s/^ *//; 
s/\([-0-9]* \) *[a-zA-Z]* *\(.*[^ ]\)  *[0-9][0-9]* *$/\1\2/;p;}' | $limite; }
[ "$d" != "${d#*mandriva}" ] && { echo; echozz "** Atualiza��es Mandriva"
URL='http://www.mandriva.com/en/rss/feed/security'; echo "$URL"
$ZZWWWHTML "$URL" | sed -n '/<title>/{s/<[^>]*>//g;s/^ *//;/MDKSA/p;}' | $limite; }
[ "$d" != "${d#*suse}" ] && { echo; echozz "** Atualiza��es Suse"
URL='http://www.novell.com/linux/security/advisories.html'; echo "$URL"
$ZZWWWDUMP "$URL"| sed -n '1,/Advisories/d;s/^ *\([0-9][0-9]\)/\1/p'|$limite; }
[ "$d" != "${d#*fedora}" ] && { echo; echozz "** Atualiza��es Fedora"
URL='http://www.linuxsecurity.com/content/blogcategory/89/102/'; echo "$URL"
$ZZWWWDUMP "$URL"| sed -n 's/^ *\([Ff]edora [Cc]ore.*:.*\) *$/\1/p' |$limite; }
[ "$d" != "${d#*freebsd}" ] && { echo; echozz "** Atualiza��es FreeBSD"
URL='http://www.freebsd.org/security/advisories.rdf'; echo "$URL"
$ZZWWWDUMP "$URL" |
sed -n '/<title>/{s/<[^>]*>//g;s/^ *//;/BSD-SA/p;}' | $limite ; }
}



# ----------------------------------------------------------------------------
# http://google.com
# Retorna apenas os t�tulos e links do resultado da pesquisa no Google
# Uso: zzgoogle [-n <n�mero>] palavra(s)
# Ex.: zzgoogle receita de bolo de abacaxi
#      zzgoogle -n 5 ramones papel higi�nico cachorro
# ----------------------------------------------------------------------------
zzgoogle(){ zzzz -z $1 zzgoogle && return
[ "$1" ] || { echo 'uso: zzgoogle [-n <n�mero>] palavra(s)'; return; }
local TXT n=10 URL='http://www.google.com.br/search'
[ "$1" = '-n' ] && { n=$2; shift; shift; }
TXT=`echo "$*"| sed "$ZZSEDURL"` ; [ "$TXT" ] || return 0
$ZZWWWHTML "$URL?q=$TXT&num=$n&ie=ISO-8859-1&hl=pt-BR" |
sed '/<p class=g>/!d;s/class=l/&\
/g' | sed -n 's/<\/a>.*//;/<\/script>/d;s/.*href="\([^"]*\)">\(.*\)/\2\
\1\
/p' | sed 's/<[^>]*>//g'
}


# ----------------------------------------------------------------------------
# http://letssingit.com
# Busca letras de m�sicas, procurando pelo nome da m�sica
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
# Consulta a programa��o do dia dos canais abertos da TV
# Pode-se passar os canais e o hor�rio que se quer consultar
#   Identificadores: B)and, C)nt, E)ducativa, G)lobo, R)ecord, S)bt, cU)ltura
# Uso: zztv canal [hor�rio]
# Ex.: zztv bsu 19       # band, sbt e cultura, depois das 19:00
#      zztv . 00         # todos os canais, depois da meia-noite
#      zztv .            # todos os canais, o dia todo
# ----------------------------------------------------------------------------
zztv(){ zzzz -z $1 zztv && return
[ "$1" ] || { echo 'uso: zztv canal [hor�rio]  (ex. zztv bs 22)'; return; }
local a c h URL='http://tudoparana.globo.com/gazetadopovo/cadernog'
h=`echo $2|sed 's/^\(..\).*/\1/;s/[^0-9]//g'` ; h="($h|$((h+1))|$((h+2)))"
h=`echo $h|sed 's/24/00/;s/25/01/;s/26/02/;s/\<[0-9]\>/0&/g;s@[(|)]@\\\\&@g'`
c=`echo $1|sed 's/b/2,/;s/s/4,/;s/c/6,/;s/r/7,/;s/u/9,/;s/g/12,/;s/e/59,/
s/,$//;s@,@\\\\|@g'`; c=$(echo $c | sed 's/^\.$/..\\?/'); a=$(
$ZZWWWHTML $URL/capa.phtml | sed -n '/ana11azul.*conteudo.phtml?id=.*[tT][vV]/{
s/.*href=\"[^\"]*\/\([^\"]*\)\".*/\1/p;}'); [ "$a" ] || {
 echo "Programa��o de hoje n�o disponivel"; return; }; $ZZWWWDUMP $URL/$a |
sed -e 's/^ *//;s/[Cc][Aa][Nn][Aa][Ll]/CANAL/;/^[012C]/!d;/^C[^A]/d;/^C/i \'\
    -e . | sed "/^CANAL \($c\) *$/,/^.$/!d;/^C/,/^$h/{/^C\|^$h/!d;};s/^\.//"
}


# ----------------------------------------------------------------------------
# http://www.acronymfinder.com
# Dicion�rio de siglas, sobre qualquer assunto (como DVD, IMHO, WYSIWYG)
# Obs.: h� um limite di�rio de consultas (10 acho)
# Uso: zzsigla sigla
# Ex.: zzsigla RTFM
# ----------------------------------------------------------------------------
zzsigla(){ zzzz -z $1 zzsigla && return
[ "$1" ] || { echo 'uso: zzsigla sigla'; return; }
local URL=http://www.acronymfinder.com/af-query.asp
$ZZWWWDUMP "$URL?String=exact&Acronym=$1&Find=Find" |
sed -n 's/^ *//;s/^.*\* *//;s/more info from .*//;s/ *search Amazon.*//p'
}



# ----------------------------------------------------------------------------
# http://www.m-w.com
# Toca um .wav que cont�m a pron�ncia correta de uma palavra em ingl�s
# Uso: zzpronuncia palavra
# Ex.: zzpronuncia apple
# ----------------------------------------------------------------------------
zzpronuncia(){ zzzz -z $1 zzpronuncia && return
[ "$1" ] || { echo 'uso: zzpronuncia palavra'; return; }
[ -x /usr/bin/say ] && { say $@ ; return; }
local URL URL2 arq dir tmpwav="$ZZTMP.$1.wav"
URL='http://www.m-w.com/cgi-bin/dictionary' URL2='http://www.m-w.com/sound'
[ -f "$tmpwav" ] || { arq=`$ZZWWWHTML "$URL?va=$1" |
  sed -n "/.*audio.pl?\([a-z0-9]*\.wav\)=$1.*/{s//\1/p;q;}"`
  [ "$arq" ] || { echo "$1: palavra n�o encontrada"; return; }
  dir=`echo $arq | sed 's/^\(.\).*/\1/'`
  WAVURL="$URL2/$dir/$arq" ; echo "URL: $WAVURL"
  $ZZWWWHTML "$WAVURL" > $tmpwav ; echo "Gravado o arquivo '$tmpwav'" ; }
play $tmpwav
}



# ----------------------------------------------------------------------------
# http://weather.noaa.gov/
# Mostra as condi��es do tempo em um determinado local
# Se nenhum par�metro for passado, s�o listados os pa�ses dispon�veis.
# Se s� o pa�s for especificado, s�o listados os lugares deste pa�s.
# Voc� tamb�m pode utilizar as siglas apresentadas para diferenci�-los.
# Ex: SBPA = Porto Alegre.
# Uso: zztempo <pa�s> <local>
# Ex.: zztempo 'United Kingdom' 'London City Airport'
#      zztempo brazil 'Curitiba Aeroporto'
#      zztempo brazil SBPA
# ----------------------------------------------------------------------------
zztempo(){ zzzz -z $1 zztempo && return
local arq_c P arq_p=$ZZTMP.tempo_p URL='http://weather.noaa.gov'
[ -s "$arq_p" ] || { $ZZWWWHTML "$URL" | sed -n '/="country"/,/\/select/{
s/.*="\([a-zA-Z]*\)">\(.*\) <.*/\1 \2/p;}' > $arq_p; }
[ "$1" ] || { sed 's/^[^ ]*  *//' $arq_p; return; }
P=$(sed -n "s/^[^ ]*  *//;/^$1$/Ip" $arq_p)
[ "$P" ] || { echozz "Pa�s [$1] n�o existe"; return; }
LOCALE_P=$(sed -n "s/  *$1//Ip" $arq_p); arq_c=$ZZTMP.tempo.$LOCALE_P
[ -s "$arq_c" ] || { $ZZWWWHTML "$URL/weather/${LOCALE_P}_cc.html" |
sed -n '/="cccc"/,/\/select/{//d;s/.*="\([a-zA-Z]*\)">/\1 /p;}' > $arq_c; }
[ "$2" ] || { cat $arq_c; return; }; L=$(sed -n "/${2}/Ip" $arq_c)
[ "$L" ] || { echozz "Local [$2] n�o existe"; return; }
[ $(echo "$L" | wc -l) -eq 1 ] && {
  $ZZWWWDUMP "$URL/weather/current/${L%% *}.html" |
  sed -n '/Current Weather/,/24 Hour/{//d;/_\{5,\}/d;p;}' || echo "$L"; }
}



# ----------------------------------------------------------------------------
# http://www.worldtimeserver.com
# Mostra a hora certa de um determinado local
# Se nenhum par�metro for passado, s�o listados os locais dispon�veis
# O par�metro pode ser tanto a sigla quando o nome do local
# Obs.: -s realiza a busca exata de uma sigla
# Uso: zzhoracerta [-s] local
#  ex: zzhoracerta rio grande do sul
#  ex: zzhoracerta us-ny
#  ex: zzhoracerta -s nz
# ----------------------------------------------------------------------------
zzhoracerta(){ zzzz -z $1 zzhoracerta && return
local H S arq=$ZZTMP.horacerta frufru='s/\([^ ]\) \([^ ]\)/\1 == \2/'
local URL='http://www.worldtimeserver.com/country.html'
[ "$1" = "-s" ] && { shift; S=.; } ; [ -s "$arq" ] || { $ZZWWWHTML "$URL" |
sed -n '/-- begin insert/,/-- end insert/{ //d; /<\/\?\(ul\|li\)>/d
s/^[\t ]*//; s/.*="current_time_in_\([^.]*\).aspx">\(.*\)<.*/\1 \2/
s/<[^>]*>//g; p; }' > $arq; }
[ "$1" ] || { sed "$frufru" $arq; return; }
if [ "$S" ]; then H=$(sed 's/^ *//' $arq | grep -i "^$1 ")
else H=$(sed 's/^ *//' $arq | grep -i "$*"); fi
[ "$H" ] || { echo "Local inexistente" ; return; }
[ "$(echo "$H" | sed -n 'N;/\n/p')" ] && { echo "$H" | sed "$frufru"; return; }
$ZZWWWDUMP "${URL%/*}/current_time_in_${H%% *}.aspx" |
sed -n '/current time/,/GMT/{ /^ \{8,\}/{ s///; :a;s/^.\{1,60\}$/ & /;ta; }
/^ *\[/d; /my favorite\|current time is\|you can\|interests\|marked/d; p; }'
}



# ----------------------------------------------------------------------------
# http://www.nextel.com.br
# Envia uma mensagem para um telefone NEXTEL (via r�dio)
# Obs.: o n�mero especificado � o n�mero pr�prio do telefone (n�o o ID!)
# Uso: zznextel de para mensagem
# Ex.: zznextel aur�lio 554178787878 minha mensagem mala
# ----------------------------------------------------------------------------
zznextel(){ zzzz -z $1 zznextel && return
[ "$3" ] || { echo 'uso: zznextel de para mensagem'; return; }
local from="$1" to="$2" URL=http://page.nextel.com.br/cgi-bin/sendPage_v3.cgi
shift; shift; local subj=zznextel msg=`echo "$*"| sed "$ZZSEDURL"`
echo "to=$to&from=$from&subject=$subj&message=$msg&count=0&Enviar=Enviar" |
$ZZWWWPOST "$URL" | sed '1,/^ *CENTRAL/d;s/.*Individual/ /;N;q'
}



# ----------------------------------------------------------------------------
# #### T R A D U T O R E S   e   D I C I O N � R I O S           (internet)
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# http://babelfish.altavista.digital.com
# Faz tradu��es de palavras/frases/textos entre idiomas
# Basta especificar quais os idiomas de origem e destino e a frase
# Obs.: Se os idiomas forem omitidos, a tradu��o ser� ingl�s -> portugu�s
#
# Idiomas: pt_en pt_fr es_en es_fr it_en it_fr de_en de_fr
#          fr_en fr_de fr_el fr_it fr_pt fr_nl fr_es
#          ja_en ko_en zh_en zt_en el_en el_fr nl_en nl_fr ru_en
#          en_zh en_zt en_nl en_fr en_de en_el en_it en_ja
#          en_ko en_pt en_ru en_es
#
# Uso: zzdicbabelfish [idiomas] texto
# Ex.: zzdicbabelfish my dog is green
#      zzdicbabelfish pt_en falc�o � massa
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
# Tradu��o de UMA PALAVRA em ingl�s para v�rios idiomas
# franc�s, alem�o, japon�s, italiano, hebreu, espanhol, holand�s e
# portugu�s. O padr�o � o portugu�s, � claro.
# Uso: zzdicbabylon [idioma] palavra
# Ex.: zzdicbabylon hardcore
#      zzdicbabylon jap tree
# ----------------------------------------------------------------------------
zzdicbabylon(){ zzzz -z $1 zzdicbabylon && return
local p L='ptg' I=' fre ger jap ita heb spa dut ptg ' tab=$(echo -e \\t)
[ "$1" ] || { echo -e "zzdicbabylon [idioma] palavra\n idiomas:$I" && return;}
[ "${I% $1 *}" != "$I" ] && L=$1 && shift
$ZZWWWHTML "http://online.babylon.com/cgi-bin/trans.cgi?lang=$L&word=$1" |
sed -e '/SEARCH RESULT/,/<\/td>/!d' -e "s/^[$tab ]*//;s/<[^>]*>//g;/^$/d;"
}


# ----------------------------------------------------------------------------
# http://www.academia.org.br/vocabula.htm
# Dicion�rio da ABL - Academia Brasileira de Letras
# Uso: zzdicabl palavra
# Ex.: zzdicabl cabe�a-de-
# ----------------------------------------------------------------------------
zzdicabl(){ zzzz -z $1 zzdicabl && return
[ "$1" ] || { echo 'uso: zzdicabl palavra'; return; }
local URL='http://www.academia.org.br/sistema_busca_palavras_portuguesas'
$ZZWWWLIST "$URL/volta_voca_org.asp?palavra=$1"
}


# ----------------------------------------------------------------------------
# http://www.portoeditora.pt/dol
# Dicion�rio de portugu�s (de Portugal)
# Uso: zzdicportugues palavra
# Ex.: zzdicportugues bolacha
# ----------------------------------------------------------------------------
zzdicportugues(){ zzzz -z $1 zzdicportugues && return
[ "$1" ] || { echo 'uso: zzdicportugues palavra'; return; }
local URL='http://www.priberam.pt/dlpo/definir_resultados.aspx'
local INI='^\(N�o \)\{0,1\}[Ff]oi\{0,1\}\(ram\)\{0,1\} encontrad' FIM='^Imprimir *$'
$ZZWWWDUMP "$URL?pal=$1" | sed -n "s/^ *//;/^$/d;
  s/\[transparent.gif]//;/$INI/,/$FIM/{/$INI/d;/$FIM/d;p;}" |
  sed '/\(.*\.\),$/{ s//[\1]/; H; s/.*//; x; }' # \n + [categoria] 
}


# ----------------------------------------------------------------------------
# http://catb.org/jargon/
# Dicion�rio de jarg�es de inform�tica, em ingl�s
# Uso: zzdicjargon palavra(s)
# Ex.: zzdicjargon vi
#      zzdicjargon all your base are belong to us
# ----------------------------------------------------------------------------
zzdicjargon(){ zzzz -z $1 zzdicjargon && return
[ "$1" ] || { echo 'uso: zzdicjargon palavra'; return; }
local arq=$ZZTMP.jargonfile URL='http://catb.org/jargon/html'
local achei achei2 num mais TXT=`echo "$*" | sed 's/ /-/g'`
[ -s "$arq" ] || { echo 'AGUARDE. Atualizando listagem...'
  $ZZWWWLIST "$URL/go01.html" |
  sed '/^ *[0-9][0-9]*\. /!d;s@.*/html/@@;/^[A-Z0]\//!d' > $arq ; }
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
# Usa todas as fun��es de dicion�rio e tradu��o de uma vez
# Uso: zzdictodos palavra
# Ex.: zzdictodos Linux
# ----------------------------------------------------------------------------
zzdictodos(){ zzzz -z $1 zzdictodos && return
[ "$1" ] || { echo 'uso: zzdictodos palavra'; return; }
local D ; for D in babelfish babylon jargon abl portugues
do echozz "zzdic$D:"; zzdic$D $1; done
}


# ----------------------------------------------------------------------------
# http://aurelio.net/doc/ramones.txt
# Procura frases de letras de m�sicas da banda Ramones
# Uso: zzramones [palavra]
# Ex.: zzramones punk
#      zzramones
# ----------------------------------------------------------------------------
zzramones(){ zzzz -z $1 zzramones && return
local txt n url='http://aurelio.net/doc/misc/ramones.txt' arq=$ZZTMP.ramones
[ -s "$arq" ] || { echo -n 'AGUARDE. Atualizando listagem...'
  $ZZWWWDUMP "$url" > $arq ; echo ' feito!'; }
zzlinha -t "${1:-.}" $arq
}


# ----------------------------------------------------------------------------
# http://www.ibb.org.br/vidanet/
# A mensagem "Feliz Natal" em v�rios idiomas
# Uso: zznatal [palavra]
# Ex.: zznatal                   # busca um idioma aleat�rio
#      zznatal russo             # Feliz Natal em russo
# ----------------------------------------------------------------------------
zznatal(){ zzzz -z $1 zznatal && return
local txt n url='http://www.nisseychallenger.com/feliznatal.html'
local arq=$ZZTMP.natal ; [ -s "$arq" ] || {
  echo -n 'AGUARDE. Atualizando listagem...' ; $ZZWWWDUMP "$url" |
  sed '/^   [A-Z]/!d;s/^ *//;s/   */: /' > $arq; echo ' feito!'; }
echo -n '"Feliz Natal" em '; zzlinha -t "${1:-.}" $arq
}

# ----------------------------------------------------------------------------
## incluindo as fun��es extras
[ "$ZZEXTRA" -a -f "$ZZEXTRA" ] && source "$ZZEXTRA"

# ----------------------------------------------------------------------------
## lidando com a chamada pelo execut�vel

if [ "$1" ]; then
	if [ "$1" = '--help' -o "$1" = '-h' ]; then
		echo "
uso: funcoeszz <fun��o> [<par�metros>]
     funcoeszz <fun��o> --help


dica: inclua as fun��es ZZ no seu login shell,
      e depois chame-as diretamente pelo nome:

  prompt$ funcoeszz zzzz --bashrc
  prompt$ source ~/.bashrc
  prompt$ zz<TAB><TAB>

  Obs.: funcoeszz zzzz --tcshrc tamb�m funciona

lista das fun��es:
"
		zzzz | sed '1,/(( fu/d'
	elif [ "$1" = '--version' -o "$1" = '-v' ]; then
		echo -n 'fun��es ZZ v'; zzzz | sed '/vers�/!d;s/.* //'
	else
		func="zz${1#zz}"
		if type $func >&- 2>&- ; then   # a fun��o existe?
			shift ; $func "$@"            # sim, vai!
		else
			echo "ERRO: fun��o inexistente '$func' (tente --help)"
		fi
	fi
fi








