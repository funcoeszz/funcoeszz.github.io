#!/usr/bin/env bash
# funcoeszz
#
# INFORMAÇÕES: http://www.funcoeszz.net
# NASCIMENTO : 22 de Fevereiro de 2000
# AUTORES    : Aurelio Marinho Jargas <verde (a) aurelio net>
#              Itamar Santos de Souza <itamarnet (a) yahoo com br>
#              Thobias Salazar Trevisan <thobias (a) thobias org>
# DESCRIÇÃO  : Funções de uso geral para o shell Bash, que buscam
#              informações em arquivos locais e fontes na Internet
# LICENÇA    : GPLv2
# CHANGELOG  : http://www.funcoeszz.net/changelog.html
#
ZZVERSAO=15.5
ZZUTF=1
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
#      $ZZCOR      - Liga/Desliga as mensagens coloridas (1 e 0)
#      $ZZPATH     - Caminho completo para o arquivo principal (funcoeszz)
#      $ZZDIR      - Caminho completo para o diretório com as funções
#      $ZZTMPDIR   - Diretório para armazenar arquivos temporários
#      $ZZOFF      - Lista das funções que você não quer carregar
#
# Nota: Se você é paranóico com segurança, configure a ZZTMPDIR para
#       um diretório dentro do seu HOME.
#
### Configuração fixa neste arquivo (hardcoded)
#
# A configuração também pode ser feita diretamente neste arquivo, se você
# puder fazer alterações nele.
#
ZZCOR_DFT=1                       # colorir mensagens? 1 liga, 0 desliga
ZZPATH_DFT="/usr/bin/funcoeszz"   # rota absoluta deste arquivo
ZZDIR_DFT="$HOME/zz"              # rota absoluta do diretório com as funções
ZZTMPDIR_DFT="${TMPDIR:-/tmp}"    # diretório temporário
#
#
##############################################################################
#
#                               Inicialização
#                               -------------
#
#
# Variáveis auxiliares usadas pelas Funções ZZ.
# Não altere nada aqui.
#
#

ZZWWWDUMP='lynx -dump      -nolist -width=300 -accept_all_cookies -display_charset=UTF-8'
ZZWWWLIST='lynx -dump              -width=300 -accept_all_cookies -display_charset=UTF-8'
ZZWWWPOST='lynx -post-data -nolist -width=300 -accept_all_cookies -display_charset=UTF-8'
ZZWWWHTML='lynx -source'
ZZCODIGOCOR='36;1'            # use zzcores para ver os códigos
ZZSEDURL='s| |+|g;s|&|%26|g;s|@|%40|g'
ZZBASE='zzajuda zztool zzzz'  # Funções essenciais, guardadas neste script

#
### Truques para descobrir a localização deste arquivo no sistema
#
# Se a chamada foi pelo executável, o arquivo é o $0.
# Senão, tenta usar a variável de ambiente ZZPATH, definida pelo usuário.
# Caso não exista, usa o local padrão ZZPATH_DFT.
# Finalmente, força que ZZPATH seja uma rota absoluta.
#
test "${0##*/}" = 'bash' -o "${0#-}" != "$0" || ZZPATH="$0"
test -n "$ZZPATH" || ZZPATH=$ZZPATH_DFT
test "${ZZPATH#/}" = "$ZZPATH" && ZZPATH="$PWD/${ZZPATH#./}"

test -n "$ZZDIR" || ZZDIR=$ZZDIR_DFT

#
### Últimos ajustes
#
ZZCOR="${ZZCOR:-$ZZCOR_DFT}"
ZZTMP="${ZZTMPDIR:-$ZZTMPDIR_DFT}"
ZZTMP="${ZZTMP%/}/zz"  # prefixo comum a todos os arquivos temporários
ZZAJUDA="$ZZTMP.ajuda"
unset ZZCOR_DFT ZZPATH_DFT ZZDIR_DFT ZZTMPDIR_DFT

#
### Forçar variáveis via linha de comando
#
while test $# -gt 0
do
	case "$1" in
		--path) ZZPATH="$2"   ; shift; shift ;;
		--dir ) ZZDIR="${2%/}"; shift; shift ;;
		--cor ) ZZCOR="$2"    ; shift; shift ;;
		*) break;;
	esac
done
#
#
##############################################################################
#
#                                Ferramentas
#                                -----------
#
#

# ----------------------------------------------------------------------------
# zztool
# Miniferramentas para auxiliar as funções.
# Uso: zztool [-e] ferramenta [argumentos]
# Ex.: zztool grep_var foo $var
#      zztool eco Minha mensagem colorida
#      zztool testa_numero $num
#      zztool -e testa_numero $num || return
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-03-01
# ----------------------------------------------------------------------------
zztool ()
{
	local erro ferramenta

	# Devo mostrar a mensagem de erro?
	test "$1" = '-e' && erro=1 && shift

	# Libera o nome da ferramenta do $1
	ferramenta="$1"
	shift

	case "$ferramenta" in
		uso)
			# Extrai a mensagem de uso da função $1, usando seu --help
			if test -n "$erro"
			then
				zzzz -h "$1" -h | grep Uso >&2
			else
				zzzz -h "$1" -h | grep Uso
			fi
		;;
		eco)
			# Mostra mensagem colorida caso $ZZCOR esteja ligada
			if test "$ZZCOR" != '1'
			then
				printf "%b\n" "$*"
			else
				printf "%b\n" "\033[${ZZCODIGOCOR}m$*\033[m"
			fi
		;;
		erro)
			# Mensagem de erro
			printf "%b\n" "$*" >&2
		;;
		acha)
			# Destaca o padrão $1 no texto via STDIN ou $2
			# O padrão pode ser uma regex no formato BRE (grep/sed)
			local esc=$(printf '\033')
			local padrao=$(echo "$1" | sed 's,/,\\/,g') # escapa /
			shift
			zztool multi_stdin "$@" |
				if test "$ZZCOR" != '1'
				then
					cat -
				else
					sed "s/$padrao/$esc[${ZZCODIGOCOR}m&$esc[m/g"
				fi
		;;
		grep_var)
			# $1 está presente em $2?
			test "${2#*$1}" != "$2"
		;;
		index_var)
			# $1 está em qual posição em $2?
			local padrao="$1"
			local texto="$2"
			if zztool grep_var "$padrao" "$texto"
			then
				texto="${texto%%$padrao*}"
				echo $((${#texto} + 1))
			else
				echo 0
			fi
		;;
		arquivo_vago)
			# Verifica se o nome de arquivo informado está vago
			if test -e "$1"
			then
				echo "Arquivo $1 já existe. Abortando." >&2
				return 1
			fi
		;;
		arquivo_legivel)
			# Verifica se o arquivo existe e é legível
			if ! test -r "$1"
			then
				echo "Não consegui ler o arquivo $1" >&2
				return 1
			fi

			# TODO Usar em *todas* as funções que lêem arquivos
		;;
		num_linhas)
			# Informa o número de linhas, sem formatação
			zztool file_stdin "$@" |
				wc -l |
				tr -d ' \t'
		;;
		nl_eof)
			# Garante que a última linha tem um \n no final
			# Necessário porque o GNU sed não adiciona o \n
			# printf abc | bsd-sed ''      #-> abc\n
			# printf abc | gnu-sed ''      #-> abc
			# printf abc | zztool nl_eof   #-> abc\n
			sed '$ { G; s/\n//g; }'
		;;
		testa_ano)
			# Testa se $1 é um ano válido: 1-9999
			# O ano zero nunca existiu, foi de -1 para 1
			# Ano maior que 9999 pesa no processamento
			echo "$1" | grep -v '^00*$' | grep '^[0-9]\{1,4\}$' >/dev/null && return 0

			test -n "$erro" && echo "Ano inválido '$1'" >&2
			return 1
		;;
		testa_ano_bissexto)
			# Testa se $1 é um ano bissexto
			#
			# A year is a leap year if it is evenly divisible by 4
			# ...but not if it's evenly divisible by 100
			# ...unless it's also evenly divisible by 400
			# http://timeanddate.com
			# http://www.delorie.com/gnu/docs/gcal/gcal_34.html
			# http://en.wikipedia.org/wiki/Leap_year
			#
			local y=$1
			test $((y%4)) -eq 0 && test $((y%100)) -ne 0 || test $((y%400)) -eq 0
			test $? -eq 0 && return 0

			test -n "$erro" && echo "Ano bissexto inválido '$1'" >&2
			return 1
		;;
		testa_numero)
			# Testa se $1 é um número positivo
			echo "$1" | grep '^[0-9]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && echo "Número inválido '$1'" >&2
			return 1

			# TODO Usar em *todas* as funções que recebem números
		;;
		testa_numero_sinal)
			# Testa se $1 é um número (pode ter sinal: -2 +2)
			echo "$1" | grep '^[+-]\{0,1\}[0-9]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && echo "Número inválido '$1'" >&2
			return 1
		;;
		testa_numero_fracionario)
			# Testa se $1 é um número fracionário (1.234 ou 1,234)
			# regex: \d+[,.]\d+
			echo "$1" | grep '^[0-9]\{1,\}[,.][0-9]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && echo "Número inválido '$1'" >&2
			return 1
		;;
		testa_dinheiro)
			# Testa se $1 é um valor monetário (1.234,56 ou 1234,56)
			# regex: (  \d{1,3}(\.\d\d\d)+  |  \d+  ),\d\d
			echo "$1" | grep '^\([0-9]\{1,3\}\(\.[0-9][0-9][0-9]\)\{1,\}\|[0-9]\{1,\}\),[0-9][0-9]$' >/dev/null && return 0

			test -n "$erro" && echo "Valor inválido '$1'" >&2
			return 1
		;;
		testa_binario)
			# Testa se $1 é um número binário
			echo "$1" | grep '^[01]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && echo "Número binário inválido '$1'" >&2
			return 1
		;;
		testa_ip)
			# Testa se $1 é um número IP (nnn.nnn.nnn.nnn)
			local nnn="\([0-9]\{1,2\}\|1[0-9][0-9]\|2[0-4][0-9]\|25[0-5]\)" # 0-255
			echo "$1" | grep "^$nnn\.$nnn\.$nnn\.$nnn$" >/dev/null && return 0

			test -n "$erro" && echo "Número IP inválido '$1'" >&2
			return 1
		;;
		testa_data)
			# Testa se $1 é uma data (dd/mm/aaaa)
			local d29='\(0[1-9]\|[12][0-9]\)/\(0[1-9]\|1[012]\)'
			local d30='30/\(0[13-9]\|1[012]\)'
			local d31='31/\(0[13578]\|1[02]\)'
			echo "$1" | grep "^\($d29\|$d30\|$d31\)/[0-9]\{1,4\}$" >/dev/null && return 0

			test -n "$erro" && echo "Data inválida '$1', deve ser dd/mm/aaaa" >&2
			return 1
		;;
		testa_hora)
			# Testa se $1 é uma hora (hh:mm)
			echo "$1" | grep "^\(0\{0,1\}[0-9]\|1[0-9]\|2[0-3]\):[0-5][0-9]$" >/dev/null && return 0

			test -n "$erro" && echo "Hora inválida '$1'" >&2
			return 1
		;;
		multi_stdin)
			# Mostra na tela os argumentos *ou* a STDIN, nesta ordem
			# Útil para funções/comandos aceitarem dados das duas formas:
			#     echo texto | funcao
			# ou
			#     funcao texto

			if test -n "$1"
			then
				echo "$*"  # security: always quote to avoid shell expansion
			else
				cat -
			fi
		;;
		file_stdin)
			# Mostra na tela o conteúdo dos arquivos *ou* da STDIN, nesta ordem
			# Útil para funções/comandos aceitarem dados das duas formas:
			#     cat arquivo1 arquivo2 | funcao
			#     cat arquivo1 arquivo2 | funcao -
			# ou
			#     funcao arquivo1 arquivo2
			#
			# Note que o uso de - para indicar STDIN não é portável, mas esta
			# ferramenta o torna portável, pois o cat o suporta no Unix.

			cat "${@:--}"  # Traduzindo: cat $@ ou cat -
		;;
		list2lines)
			# Limpa lista da STDIN e retorna um item por linha
			# Lista: um dois três | um, dois, três | um;dois;três
			sed 's/[;,]/ /g' |
				tr -s '\t ' '  ' |
				tr ' ' '\n' |
				grep .
		;;
		lines2list)
			# Recebe linhas em STDIN e retorna: linha1 linha2 linha3
			# Ignora linhas em branco e remove espaços desnecessários
			grep . |
				tr '\n' ' ' |
				sed 's/^ // ; s/ $//'
		;;
		endereco_sed)
			# Formata um texto para ser usado como endereço no sed.
			# Números e $ não são alterados, resto fica /entre barras/
			#     foo     -> /foo/
			#     foo/bar -> /foo\/bar/

			local texto="$*"

			if zztool testa_numero "$texto" || test "$texto" = '$'
			then
				echo "$texto"  # 1, 99, $
			else
				echo "$texto" | sed 's:/:\\\/:g ; s:.*:/&/:'
			fi
		;;
		terminal_utf8)
			echo "$LC_ALL $LC_CTYPE $LANG" | grep -i utf >/dev/null
		;;
		texto_em_iso)
			if test $ZZUTF = 1
			then
				iconv -f iso-8859-1 -t utf-8 /dev/stdin
			else
				cat -
			fi
		;;
		texto_em_utf8)
			if test $ZZUTF != 1
			then
				iconv -f utf-8 -t iso-8859-1 /dev/stdin
			else
				cat -
			fi
		;;
		mktemp)
			# Cria um arquivo temporário de nome único, usando $1.
			# Lembre-se de removê-lo no final da função.
			#
			# Exemplo de uso:
			#   local tmp=$(zztool mktemp arrumanome)
			#   foo --bar > "$tmp"
			#   rm -f "$tmp"

			mktemp "${ZZTMP:-/tmp/zz}.${1:-anonimo}.XXXXXX"
		;;
		cache | atualiza)
		# Limpa o cache se solicitado a atualização
		# Atualiza o cache se for fornecido a url
		# e retorna o nome do arquivo de cache
		# Ex.: local cache=$(zztool cache lua <identificador> '$url' dump) # Nome do cache, e atualiza se necessário
		# Ex.: local cache=$(zztool cache php) # Apenas retorna o nome do cache
		# Ex.: zztool cache rm palpite # Apaga o cache diretamente
			local id
			case ${1#zz} in
			on | off | ajuda) break;;
			rm)
				if test "$2" = '*'
				then
					rm -f ${ZZTMP:-XXXX}*
					# Restabelecendo zz.ajuda, zz.on, zz.off
					funcoeszz
				else
					test -n "$3" && id=".$3"
					test -n "$2" && rm -f ${ZZTMP:-XXXX}.${2#zz}${id}*
				fi
			;;
			*)
				# Para mais de um arquivo cache pode-se usar um identificador adicional
				# como PID, um numero incremental ou um sufixo qualquer
				test -n "$2" && id=".$2"

				# Para atualizar é necessário prevenir a existência prévia do arquivo
				test "$ferramenta" = "atualiza" && rm -f ${ZZTMP:-XXXX}.${1#zz}$id

				# Baixo para o cache os dados brutos sem tratamento
				if ! test -s "$ZZTMP.${1#zz}" && test -n "$3"
				then
					case $4 in
					none    ) : ;;
					html    ) $ZZWWWHTML "$3" > "$ZZTMP.${1#zz}$id";;
					list    ) $ZZWWWLIST "$3" > "$ZZTMP.${1#zz}$id";;
					dump | *) $ZZWWWDUMP "$3" > "$ZZTMP.${1#zz}$id";;
					esac
				fi
				test "$ferramenta" = "cache" && echo "$ZZTMP.${1#zz}$id"
			;;
			esac
		;;
		# Ferramentas inexistentes são simplesmente ignoradas
		esac
}


# ----------------------------------------------------------------------------
# zzajuda
# Mostra uma tela de ajuda com explicação e sintaxe de todas as funções.
# Opções: --lista  lista de todas as funções, com sua descrição
#         --uso    resumo de todas as funções, com a sintaxe de uso
# Uso: zzajuda [--lista|--uso]
# Ex.: zzajuda
#      zzajuda --lista
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-04
# ----------------------------------------------------------------------------
zzajuda ()
{
	zzzz -h ajuda "$1" && return

	local zzcor_pager

	if test ! -r "$ZZAJUDA"
	then
		echo "Ops! Não encontrei o texto de ajuda em '$ZZAJUDA'." >&2
		echo "Para recriá-lo basta executar o script 'funcoeszz' sem argumentos." >&2
		return
	fi

	case "$1" in
		--uso)
			# Lista com sintaxe de uso, basta pescar as linhas Uso:
			sed -n 's/^Uso: zz/zz/p' "$ZZAJUDA" |
				sort |
				zztool acha '^zz[^ ]*'
		;;
		--lista)
			# Lista de todas as funções no formato: nome descrição
			grep -A2 ^zz "$ZZAJUDA" |
				grep -v ^http |
				sed '
					/^zz/ {
						# Padding: o nome deve ter 17 caracteres
						# Maior nome: zzfrenteverso2pdf
						:pad
						s/^.\{1,16\}$/& /
						t pad

						# Junta a descricao (proxima linha)
						N
						s/\n/ /
					}' |
				grep ^zz |
				sort |
				zztool acha '^zz[^ ]*'
		;;
		*)
			# Desliga cores para os paginadores antigos
			test "$PAGER" = 'less' -o "$PAGER" = 'more' && zzcor_pager=0

			# Mostra a ajuda de todas as funções, paginando
			cat "$ZZAJUDA" |
				ZZCOR=${zzcor_pager:-$ZZCOR} zztool acha 'zz[a-z0-9]\{2,\}' |
				${PAGER:-less -r}
		;;
	esac
}


# ----------------------------------------------------------------------------
# zzzz
# Mostra informações sobre as funções, como versão e localidade.
# Opções: --atualiza  baixa a versão mais nova das funções
#         --teste     testa se a codificação e os pré-requisitos estão OK
#         --bashrc    instala as funções no ~/.bashrc
#         --tcshrc    instala as funções no ~/.tcshrc
#         --zshrc     instala as funções no ~/.zshrc
# Uso: zzzz [--atualiza|--teste|--bashrc|--tcshrc|--zshrc]
# Ex.: zzzz
#      zzzz --teste
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-01-07
# ----------------------------------------------------------------------------
zzzz ()
{
	local nome_func arg_func padrao func
	local info_instalado info_instalado_zsh info_cor info_utf8 info_base versao_remota
	local arquivo_aliases arquivo_zz
	local n_on n_off
	local bashrc="$HOME/.bashrc"
	local tcshrc="$HOME/.tcshrc"
	local zshrc="$HOME/.zshrc"
	local url_site='http://funcoeszz.net'
	local url_exe="$url_site/funcoeszz"
	local instal_msg='Instalacao das Funcoes ZZ (www.funcoeszz.net)'

	case "$1" in

		# Atenção: Prepare-se para viajar um pouco que é meio complicado :)
		#
		# Todas as funções possuem a opção -h e --help para mostrar um
		# texto rápido de ajuda. Normalmente cada função teria que
		# implementar o código para verificar se recebeu uma destas opções
		# e caso sim, mostrar o texto na tela. Para evitar a repetição de
		# código, estas tarefas estão centralizadas aqui.
		#
		# Chamando a zzzz com a opção -h seguido do nome de uma função e
		# seu primeiro parâmetro recebido, o teste é feito e o texto é
		# mostrado caso necessário.
		#
		# Assim cada função só precisa colocar a seguinte linha no início:
		#
		#     zzzz -h beep "$1" && return
		#
		# Ao ser chamada, a zzzz vai mostrar a ajuda da função zzbeep caso
		# o valor de $1 seja -h ou --help. Se no $1 estiver qualquer outra
		# opção da zzbeep ou argumento, nada acontece.
		#
		# Com o "&& return" no final, a função zzbeep pode sair imediatamente
		# caso a ajuda tenha sido mostrada (retorno zero), ou continuar seu
		# processamento normal caso contrário (retorno um).
		#
		# Se a zzzz -h for chamada sem nenhum outro argumento, é porque o
		# usuário quer ver a ajuda da própria zzzz.
		#
		# Nota: Ao invés de "beep" literal, poderíamos usar $FUNCNAME, mas
		#       o Bash versão 1 não possui essa variável.

		-h | --help)

			nome_func=${2#zz}
			arg_func=$3

			# Nenhum argumento, mostre a ajuda da própria zzzz
			if ! test -n "$nome_func"
			then
				nome_func='zz'
				arg_func='-h'
			fi

			# Se o usuário informou a opção de ajuda, mostre o texto
			if test '-h' = "$arg_func" -o '--help' = "$arg_func"
			then
				# Um xunxo bonito: filtra a saída da zzajuda, mostrando
				# apenas a função informada.
				echo
				ZZCOR=0 zzajuda |
					sed -n "/^zz$nome_func$/,/^----*$/ {
						s/^----*$//
						p
					}" |
					zztool acha zz$nome_func
				return 0
			else

				# Alarme falso, o argumento não é nem -h nem --help
				return 1
			fi
		;;

		# Garantia de compatibilidade do -h com o formato antigo (-z):
		# zzzz -z -h zzbeep
		-z)
			zzzz -h "$3" "$2"
		;;

		# Testes de ambiente para garantir o funcionamento das funções
		--teste)

			### Todos os comandos necessários estão instalados?

			local comando tipo_comando comandos_faltando
			local comandos='awk- bc cat chmod- clear- cp cpp- cut diff- du- find- fmt grep iconv- lynx mktemp mv od- ps- rm sed sleep sort tail- tr uniq'

			for comando in $comandos
			do
				# Este é um comando essencial ou opcional?
				tipo_comando='ESSENCIAL'
				if zztool grep_var - "$comando"
				then
					tipo_comando='opcional'
					comando=${comando%-}
				fi

				printf '%-30s' "Procurando o comando $comando... "

				# Testa se o comando existe
				if type "$comando" >/dev/null 2>&1
				then
					echo 'OK'
				else
					zztool eco "Comando $tipo_comando '$comando' não encontrado"
					comandos_faltando="$comando_faltando $tipo_comando"
				fi
			done

			if test -n "$comandos_faltando"
			then
				echo
				zztool eco "**Atenção**"
				if zztool grep_var ESSENCIAL "$comandos_faltando"
				then
					echo 'Há pelo menos um comando essencial faltando.'
					echo 'Você precisa instalá-lo para usar as Funções ZZ.'
				else
					echo 'A falta de um comando opcional quebra uma única função.'
					echo 'Talvez você não precise instalá-lo.'
				fi
				echo
			fi

			### Tudo certo com a codificação do sistema e das ZZ?

			local cod_sistema='ISO-8859-1'
			local cod_funcoeszz='ISO-8859-1'

			printf 'Verificando a codificação do sistema... '
			zztool terminal_utf8 && cod_sistema='UTF-8'
			echo "$cod_sistema"

			printf 'Verificando a codificação das Funções ZZ... '
			test $ZZUTF = 1 && cod_funcoeszz='UTF-8'
			echo "$cod_funcoeszz"

			# Se um dia precisar de um teste direto no arquivo:
			# sed 1d "$ZZPATH" | file - | grep UTF-8

			if test "$cod_sistema" != "$cod_funcoeszz"
			then
				# Deixar sem acentuação mesmo, pois eles não vão aparecer
				echo
				zztool eco "**Atencao**"
				echo 'Ha uma incompatibilidade de codificacao.'
				echo "Baixe as Funcoes ZZ versao $cod_sistema."
			fi
		;;

		# Baixa a versão nova, caso diferente da local
		--atualiza)

			echo 'Procurando a versão nova, aguarde.'
			versao_remota=$($ZZWWWDUMP "$url_site/v")
			echo "versão local : $ZZVERSAO"
			echo "versão remota: $versao_remota"
			echo

			# Aborta caso não encontrou a versão nova
			test -n "$versao_remota" || return

			# Compara e faz o download
			if test "$ZZVERSAO" != "$versao_remota"
			then
				# Vamos baixar a versão ISO-8859-1?
				test $ZZUTF != '1' && url_exe="${url_exe}-iso"

				echo -n 'Baixando a versão nova... '
				$ZZWWWHTML "$url_exe" > "funcoeszz-$versao_remota"
				echo 'PRONTO!'
				echo "Arquivo 'funcoeszz-$versao_remota' baixado, instale-o manualmente."
				echo "O caminho atual é $ZZPATH"
			else
				echo 'Você já está com a versão mais recente.'
			fi
		;;

		# Instala as funções no arquivo .bashrc
		--bashrc)

			if ! grep "^[^#]*${ZZPATH:-zzpath_vazia}" "$bashrc" >/dev/null 2>&1
			then
				# export ZZDIR="$ZZDIR"  # pasta com as funcoes
				cat - >> "$bashrc" <<-EOS

				# $instal_msg
				export ZZOFF=""  # desligue funcoes indesejadas
				export ZZPATH="$ZZPATH"  # script
				source "\$ZZPATH"
				EOS

				echo 'Feito!'
				echo "As Funções ZZ foram instaladas no $bashrc"
			else
				echo "Nada a fazer. As Funções ZZ já estão no $bashrc"
			fi
		;;

		# Cria aliases para as funções no arquivo .tcshrc
		--tcshrc)
			arquivo_aliases="$HOME/.zzcshrc"

			# Chama o arquivo dos aliases no final do .tcshrc
			if ! grep "^[^#]*$arquivo_aliases" "$tcshrc" >/dev/null 2>&1
			then
				# setenv ZZDIR $ZZDIR
				cat - >> "$tcshrc" <<-EOS

				# $instal_msg
				setenv ZZPATH $ZZPATH
				source $arquivo_aliases
				EOS

				echo 'Feito!'
				echo "As Funções ZZ foram instaladas no $tcshrc"
			else
				echo "Nada a fazer. As Funções ZZ já estão no $tcshrc"
			fi

			# Cria o arquivo de aliases
			echo > $arquivo_aliases
			for func in $(ZZCOR=0 zzzz | grep -v '^(' | sed 's/,//g')
			do
				echo "alias zz$func 'funcoeszz zz$func'" >> "$arquivo_aliases"
			done

			# alias para funcoes base
			for func in $(ZZCOR=0 zzzz | grep 'base)' | sed 's/(.*)//; s/,//g')
			do
				echo "alias $func='funcoeszz $func'" >> "$arquivo_aliases"
			done

			echo
			echo "Aliases atualizados no $arquivo_aliases"
		;;

		# Cria aliases para as funções no arquivo .zshrc
		--zshrc)
			arquivo_aliases="$HOME/.zzzshrc"

			# Chama o arquivo dos aliases no final do .zshrc
			if ! grep "^[^#]*$arquivo_aliases" "$zshrc" >/dev/null 2>&1
			then
				# export ZZDIR=$ZZDIR
				cat - >> "$zshrc" <<-EOS

				# $instal_msg
				export ZZPATH=$ZZPATH
				source $arquivo_aliases
				EOS

				echo 'Feito!'
				echo "As Funções ZZ foram instaladas no $zshrc"
			else
				echo "Nada a fazer. As Funções ZZ já estão no $zshrc"
			fi

			# Cria o arquivo de aliases
			echo > $arquivo_aliases
			for func in $(ZZCOR=0 zzzz | grep -v '^(' | sed 's/,//g')
			do
				echo "alias zz$func='funcoeszz zz$func'" >> "$arquivo_aliases"
			done

			# alias para funcoes base
			for func in $(ZZCOR=0 zzzz | grep 'base)' | sed 's/(.*)//; s/,//g')
			do
				echo "alias $func='funcoeszz $func'" >> "$arquivo_aliases"
			done

			echo
			echo "Aliases atualizados no $arquivo_aliases"
		;;

		# Mostra informações sobre as funções
		*)
			# As funções estão configuradas para usar cores?
			test "$ZZCOR" = '1' && info_cor='sim' || info_cor='não'

			# A codificação do arquivo das funções é UTF-8?
			test "$ZZUTF" = 1 && info_utf8='UTF-8' || info_utf8='ISO-8859-1'

			# As funções estão instaladas no bashrc?
			if grep "^[^#]*${ZZPATH:-zzpath_vazia}" "$bashrc" >/dev/null 2>&1
			then
				info_instalado="$bashrc"
			else
				info_instalado='não instalado'
			fi

			# As funções estão instaladas no zshrc?
			if grep "^[^#]*${ZZPATH:-zzpath_vazia}" "$zshrc" >/dev/null 2>&1
			then
				info_instalado_zsh="$zshrc"
			else
				info_instalado_zsh='não instalado'
			fi

			# Formata funções essenciais
			info_base=$(echo $ZZBASE | sed 's/ /, /g')

			# Informações, uma por linha
			zztool acha '^[^)]*)' "(script) $ZZPATH"
			zztool acha '^[^)]*)' "( pasta) $ZZDIR"
			zztool acha '^[^)]*)' "(versão) $ZZVERSAO ($info_utf8)"
			zztool acha '^[^)]*)' "( cores) $info_cor"
			zztool acha '^[^)]*)' "(   tmp) $ZZTMP"
			zztool acha '^[^)]*)' "(bashrc) $info_instalado"
			zztool acha '^[^)]*)' "( zshrc) $info_instalado_zsh"
			zztool acha '^[^)]*)' "(  base) $info_base"
			zztool acha '^[^)]*)' "(  site) $url_site"

			# Lista de todas as funções

			# Sem $ZZDIR, provavelmente usando --tudo-em-um
			# Tentarei obter a lista de funções carregadas na shell atual
			if test -z "$ZZDIR"
			then
				set |
					sed -n '/^zz[a-z0-9]/ s/ *().*//p' |
					egrep -v "$(echo $ZZBASE | sed 's/ /|/g')" |
					sort > "$ZZTMP.on"
			fi

			if test -r "$ZZTMP.on"
			then
				echo
				n_on=$(zztool num_linhas "$ZZTMP.on")
				zztool eco "(( $n_on funções disponíveis ))"
				cat "$ZZTMP.on" |
					sed 's/^zz//' |
					zztool lines2list |
					sed 's/ /, /g' |
					fmt -w 70
			else
				echo
				echo "Não consegui obter a lista de funções disponíveis."
				echo "Para recriá-la basta executar o script 'funcoeszz' sem argumentos."
			fi

			# Só mostra se encontrar o arquivo...
			if test -r "$ZZTMP.off"
			then
				# ...e se ele tiver ao menos uma zz
				grep zz "$ZZTMP.off" >/dev/null || return

				echo
				n_off=$(zztool num_linhas "$ZZTMP.off")
				zztool eco "(( $n_off funções desativadas ))"
				cat "$ZZTMP.off" |
					sed 's/^zz//' |
					zztool lines2list |
					sed 's/ /, /g' |
					fmt -w 70
			else
				echo
				echo "Não consegui obter a lista de funções desativadas."
				echo "Para recriá-la basta executar o script 'funcoeszz' sem argumentos."
			fi
		;;
	esac
}

# A linha seguinte é usada pela opção --tudo-em-um
#@
# ----------------------------------------------------------------------------
# zzaleatorio
# Gera um número aleatório.
# Sem argumentos, comporta-se igual a $RANDOM.
# Apenas um argumento, número entre 0 e o valor fornecido.
# Com dois argumentos, número entre esses limites informados.
#
# Uso: zzaleatorio [número] [número]
# Ex.: zzaleatorio 10
#      zzaleatorio 5 15
#      zzaleatorio
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-13
# Versão: 5
# Licença: GPL
# Requisitos: zzvira
# ----------------------------------------------------------------------------
zzaleatorio ()
{
	zzzz -h aleatorio "$1" && return

	local inicio=0
	local fim=32767
	local cache=$(zztool cache aleatorio)
	local v_temp

	# Se houver só um número, entre 0 e o número
	test -n "$1" && fim="$1"

	# Se houver dois números, entre o primeiro e o segundo
	test -n "$2" && inicio="$1" fim="$2"

	# Verificações básicas
	zztool testa_numero "$inicio" || return 1
	zztool testa_numero "$fim"    || return 1

	# Se ambos são iguais, retorna o próprio número
	test "$inicio" = "$fim" && { echo "$fim"; return 0; }

	# Se o primeiro é maior, inverte a posição
	if test "$inicio" -gt "$fim"
	then
		v_temp="$inicio"
		inicio="$fim"
		fim="$v_temp"
	fi

	# Usando o dispositivo /dev/urandom
	v_temp=$(od -An -N2 -d /dev/urandom | tr -d -c '[0-9]')

	# Se não estiver disponível, usa o dispositivo /dev/random
	zztool testa_numero $v_temp || v_temp=$(od -An -N2 -d /dev/random | tr -d -c '[0-9]')

	# Se não estiver disponível, usa o tempo em nanosegundos
	zztool testa_numero $v_temp || v_temp=$(date +%N)

	if zztool testa_numero $v_temp
	then
		# Se um dos casos acima atenderem, gera o número aleatório
		echo "$(zzvira $v_temp) $inicio $fim" | awk '{ srand($1); printf "%.0f\n", $2 + rand()*($3 - $2) }'
	else
		# Se existir o cache e o tempo em segundos é o mesmo do atual, aguarda um segundo
		if test -s "$cache"
		then
			test $(cat "$cache") = $(date +%s) && sleep 1
		fi

		# Cria o cache incondicionalmente nesse caso
		echo $(date +%s) > "$cache"

		# Gera o número aleatório
		echo "$inicio $fim" | awk '{ srand(); printf "%.0f\n", $1 + rand()*($2 - $1) }'
	fi
}

# ----------------------------------------------------------------------------
# zzalfabeto
# Central de alfabetos (romano, militar, radiotelefônico, OTAN, RAF, etc).
# Obs.: Sem argumentos mostra a tabela completa, senão traduz uma palavra.
#
# Tipos reconhecidos:
#
#    --militar | --radio | --fone | --otan | --icao | --ansi
#                            Alfabeto radiotelefônico internacional
#    --romano | --latino     A B C D E F...
#    --royal-navy            Marinha Real - Reino Unido, 1914-1918
#    --signalese             Primeira Guerra, 1914-1918
#    --raf24                 Força Aérea Real - Reino Unido, 1924-1942
#    --raf42                 Força Aérea Real - Reino Unido, 1942-1943
#    --raf                   Força Aérea Real - Reino Unido, 1943-1956
#    --us                    Alfabeto militar norte-americano, 1941-1956
#    --portugal              Lugares de Portugal
#    --names                 Nomes de pessoas, em inglês
#    --lapd                  Polícia de Los Angeles (EUA)
#    --morse                 Código Morse
#
# Uso: zzalfabeto [--TIPO] [palavra]
# Ex.: zzalfabeto --militar
#      zzalfabeto --militar cambio
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-07-23
# Versão: 3
# Licença: GPL
# Requisitos: zzmaiusculas
# ----------------------------------------------------------------------------
zzalfabeto ()
{
	zzzz -h alfabeto "$1" && return

	local char letra

	local coluna=1
	local dados="\
A:Alpha:Apples:Ack:Ace:Apple:Able/Affirm:Able:Aveiro:Alan:Adam:.-
B:Bravo:Butter:Beer:Beer:Beer:Baker:Baker:Bragança:Bobby:Boy:-...
C:Charlie:Charlie:Charlie:Charlie:Charlie:Charlie:Charlie:Coimbra:Charlie:Charles:-.-.
D:Delta:Duff:Don:Don:Dog:Dog:Dog:Dafundo:David:David:-..
E:Echo:Edward:Edward:Edward:Edward:Easy:Easy:Évora:Edward:Edward:.
F:Foxtrot:Freddy:Freddie:Freddie:Freddy:Fox:Fox:Faro:Frederick:Frank:..-.
G:Golf:George:Gee:George:George:George:George:Guarda:George:George:--.
H:Hotel:Harry:Harry:Harry:Harry:How:How:Horta:Howard:Henry:....
I:India:Ink:Ink:Ink:In:Item/Interrogatory:Item:Itália:Isaac:Ida:..
J:Juliet:Johnnie:Johnnie:Johnnie:Jug/Johnny:Jig/Johnny:Jig:José:James:John:.---
K:Kilo:King:King:King:King:King:King:Kilograma:Kevin:King:-.-
L:Lima:London:London:London:Love:Love:Love:Lisboa:Larry:Lincoln:.-..
M:Mike:Monkey:Emma:Monkey:Mother:Mike:Mike:Maria:Michael:Mary:--
N:November:Nuts:Nuts:Nuts:Nuts:Nab/Negat:Nan:Nazaré:Nicholas:Nora:-.
O:Oscar:Orange:Oranges:Orange:Orange:Oboe:Oboe:Ovar:Oscar:Ocean:---
P:Papa:Pudding:Pip:Pip:Peter:Peter/Prep:Peter:Porto:Peter:Paul:.--.
Q:Quebec:Queenie:Queen:Queen:Queen:Queen:Queen:Queluz:Quincy:Queen:--.-
R:Romeo:Robert:Robert:Robert:Roger/Robert:Roger:Roger:Rossio:Robert:Robert:.-.
S:Sierra:Sugar:Esses:Sugar:Sugar:Sugar:Sugar:Setúbal:Stephen:Sam:...
T:Tango:Tommy:Toc:Toc:Tommy:Tare:Tare:Tavira:Trevor:Tom:-
U:Uniform:Uncle:Uncle:Uncle:Uncle:Uncle:Uncle:Unidade:Ulysses:Union:..-
V:Victor:Vinegar:Vic:Vic:Vic:Victor:Victor:Viseu:Vincent:Victor:...-
W:Whiskey:Willie:William:William:William:William:William:Washington:William:William:.--
X:X-ray/Xadrez:Xerxes:X-ray:X-ray:X-ray:X-ray:X-ray:Xavier:Xavier:X-ray:-..-
Y:Yankee:Yellow:Yorker:Yorker:Yoke/Yorker:Yoke:Yoke:York:Yaakov:Young:-.--
Z:Zulu:Zebra:Zebra:Zebra:Zebra:Zebra:Zebra:Zulmira:Zebedee:Zebra:--.."

	# Escolhe o alfabeto a ser utilizado
	case "$1" in
		--militar | --radio | --fone | --telefone | --otan | --nato | --icao | --itu | --imo | --faa | --ansi)
			coluna=2 ; shift ;;
		--romano | --latino           ) coluna=1  ; shift ;;
		--royal | --royal-navy        ) coluna=3  ; shift ;;
		--signalese | --western-front ) coluna=4  ; shift ;;
		--raf24                       ) coluna=5  ; shift ;;
		--raf42                       ) coluna=6  ; shift ;;
		--raf43 | --raf               ) coluna=7  ; shift ;;
		--us41 | --us                 ) coluna=8  ; shift ;;
		--pt | --portugal             ) coluna=9  ; shift ;;
		--name | --names              ) coluna=10 ; shift ;;
		--lapd                        ) coluna=11 ; shift ;;
		--morse                       ) coluna=12 ; shift ;;
	esac

	if test "$1"
	then
		# Texto informado, vamos fazer a conversão
		# Deixa uma letra por linha e procura seu código equivalente
		echo "$*" |
			zzmaiusculas |
			sed 's/./&\
/g' |
			while IFS='' read -r char
			do
				letra=$(echo "$char" | sed 's/[^A-Z]//g')
				if test -n "$letra"
				then
					echo "$dados" | grep "^$letra" | cut -d : -f $coluna
				else
					test -n "$char" && echo "$char"
				fi
			done
	else
		# Apenas mostre a tabela
		echo "$dados" | cut -d : -f $coluna
	fi
}

# ----------------------------------------------------------------------------
# zzalinhar
# Alinha um texto a esquerda, direita, centro ou justificado.
#
# As opções -l, --left, -e, --esquerda alinham as colunas a esquerda (padrão).
# As opções -r, --right, -d, --direita alinham as colunas a direita.
# As opções -c, --center, --centro centralizam as colunas.
# A opção -j, --justify, --justificar faz o texto ocupar toda a linha.
#
# As opções -w, --width, --largura seguido de um número,
# determinam o tamanho da largura como base ao alinhamento.
# Obs.: Onde a largura é maior do que a informada não é aplicado alinhamento.
#
# Uso: zzalinhar [-l|-e|-r|-d|-c|-j] [-w <largura>] arquivo
# Ex.: zzalinhar arquivo.txt
#      zzalinhar -c -w 20 arquivo.txt
#      zzalinhar -j arquivo.txt
#      cat arquivo.txt | zzalinhar -r
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-05-23
# Versão: 4
# Licença: GPL
# Requisitos: zzpad zztrim
# ----------------------------------------------------------------------------
zzalinhar ()
{
	zzzz -h alinhar "$1" && return

	local cache=$(zztool mktemp alinhar)
	local alinhamento='r'
	local largura=0
	local larg_efet linha

	while test "${1#-}" != "$1"
	do
		case "$1" in
		-l | --left | -e | --esqueda)  alinhamento='r' ;;
		-r | --right | -d | --direita) alinhamento='l' ;;
		-c | --center | --centro)      alinhamento='c' ;;
		-j | --justify | --justificar) alinhamento='j' ;;
		-w | --width | --largura)
			zztool testa_numero "$2" && largura="$2" || { zztool erro "Largura inválida: $2"; return 1; }
			shift
		;;
		-*) zztool erro "Opção inválida: $1"; return 1 ;;
		*) break;;
		esac
		shift
	done

	zztool file_stdin "$@" > $cache

	larg_efet=$(
		cat "$cache" |
		while read linha
		do
			echo ${#linha}
		done |
		sort -nr |
		head -1
	)

	test $largura -eq 0 -a $larg_efet -gt $largura && largura=$larg_efet

	case $alinhamento in
	'j')
		cat "$cache" |
		zztrim -H |
		sed 's/"/\\"/g' | sed "s/'/\\'/g" |
		awk -v larg=$largura '
			# Função para unir os campos e os separadores de campos(" ")
			function juntar(  str_saida, j) {
				str_saida=""
				for ( j=1; j<=length(campos); j++ ) {
					str_saida = str_saida campos[j] espacos[j]
				}
				sub(/ *$/, "", str_saida)
				return str_saida
			}

			# Função que aumenta a quantidade de espaços intermadiários
			function aumentar_int() {
				espacos[pos_atual] = espacos[pos_atual] " "
				pos_atual--
				pos_atual = (pos_atual == 0 ? qtde : pos_atual)
			}

			# Função para determinar tamanho da string sem erros com codificação
			function tam_linha(entrada,  saida, comando)
			{
				comando = ("echo \"" entrada "\" | wc -m")
				comando | getline saida
				close(comando)
				return saida-1
			}

			{
				# Guardando as linhas em um array
				linha[NR] = $0
			}

			END {
				for (i=1; i<=NR; i++) {
					if (tam_linha(linha[i]) == larg) { print linha[i] }
					else {
						split("", campos)
						split("", espacos)
						qtde = split(linha[i], campos)
						for (x in campos) {
							espacos[x] = " "
						}
						if ( qtde <= 1 ) { print linha[i] }
						else {
							pos_atual = qtde - 1
							saida = juntar()
							while ( tam_linha(saida) < larg ) {
								aumentar_int()
								saida = juntar()
							}
							print saida
						}
					}
				}
			}
		' | sed 's/\\"/"/g'
	;;
	*)
		test "$alinhamento" = "c" && alinhamento="a"

		cat "$cache" |
		zztrim -H |
		zzpad -${alinhamento} $largura
	;;
	esac

	rm -f "$cache"
}

# ----------------------------------------------------------------------------
# zzansi2html
# Converte para HTML o texto colorido do terminal (códigos ANSI).
# Útil para mostrar a saída do terminal em sites e blogs, sem perder as cores.
# Obs.: Exemplos de texto ANSI estão na saída das funções zzcores e zzecho.
# Obs.: Use o comando script para guardar a saída do terminal em um arquivo.
# Uso: zzansi2html [arquivo]
# Ex.: zzecho --letra verde -s -p -N testando | zzansi2html
#      ls --color /etc | zzansi2html > ls.html
#      zzcores | zzansi2html > cores.html
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-09-02
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzansi2html ()
{
	zzzz -h ansi2html "$1" && return

	local esc=$(printf '\033')
	local control_m=$(printf '\r')  # ^M, CR, \r

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |

	# Limpeza inicial do texto
	sed "
		# No Mac, o ESC[K aparece depois de cada código de cor ao usar
		# o grep --color. Exemplo: ^[[1;33m^[[Kamarelo^[[m^[[K
		# Esse código serve pra apagar até o fim da linha, então neste
		# caso, pode ser removido sem problemas.
		s/$esc\[K//g

		# O comando script deixa alguns \r inúteis no arquivo de saída
		s/$control_m*$//
	" |

	# Um único sed toma conta de toda a tarefa de conversão.
	#
	# Esta função cria um SPAN dentro do outro, sem fechar, pois os códigos ANSI
	# são cumulativos: abrir um novo não desliga os anteriores.
	#    echo -e '\e[4mFOO\e[33mBAR'  # BAR é amarelo *e* sublinhado
	#
	# No CSS, o text-decoration é cumulativo para sub-elementos (FF, Safari), veja:
	# <span style=text-decoration:underline>FOO<span style=text-decoration:none>BAR
	# O BAR também vai aparecer sublinhado, o 'none' no SPAN filho não o desliga.
	# Por isso é preciso uma outra tática para desligar sublinhado e blink.
	#
	# Uma alternativa seria fechar todos os SPANs no ^[0m, mas é difícil no sed
	# saber quantos SPANs estão abertos (multilinha). A solução foi usar DIVs,
	# que ao serem fechados desligam todos os SPANs anteriores.
	#    ^[0m  -->  </div><div style="display:inline">
	#
	sed "
		# Engloba o código na tag PRE para preservar espaços
		1 i\\
<pre style=\"background:#000;color:#FFF\"><div style=\"display:inline\">
		$ a\\
</pre>

		# Escapes do HTML
		s/&/&amp;/g
		s/</&lt;/g
		s/>/&gt;/g

		:ini
		/$esc\[[0-9;]*m/ {

			# Guarda a linha original
			h

			# Isola os números (ex: 33;41;1) da *primeira* ocorrência
			s/\($esc\[[0-9;]*\)m.*/\1/
			s/.*$esc\[\([0-9;]*\)$/\1/

			# Se vazio (^[m) vira zero
			s/^$/0/

			# Adiciona separadores no início e fim
			s/.*/;&;/

			# Zero limpa todos os atributos
			#
			# XXX
			# Note que 33;0;4 (amarelo, reset, sublinhado) vira reset,
			# mas deveria ser reset+sublinhado. É um caso difícil de
			# encontrar, então vamos conviver com essa limitação.
			#
			/;;*00*;;*/ {
				s,.*,</div><div style=\"display:inline\">,
				b end
			}

			# Define as cores
			s/;30;/;color:#000;/g; s/;40;/;background:#000;/g
			s/;31;/;color:#F00;/g; s/;41;/;background:#C00;/g
			s/;32;/;color:#0F0;/g; s/;42;/;background:#0C0;/g
			s/;33;/;color:#FF0;/g; s/;43;/;background:#CC0;/g
			s/;34;/;color:#00F;/g; s/;44;/;background:#00C;/g
			s/;35;/;color:#F0F;/g; s/;45;/;background:#C0C;/g
			s/;36;/;color:#0FF;/g; s/;46;/;background:#0CC;/g
			s/;37;/;color:#FFF;/g; s/;47;/;background:#CCC;/g

			# Define a formatação
			s/;1;/;font-weight:bold;/g
			s/;4;/;text-decoration:underline;/g
			s/;5;/;text-decoration:blink;/g

			# Força remoção da formatação, caso não especificado
			/font-weight/! s/$/;font-weight:normal/
			/text-decoration/! s/$/;text-decoration:none/

			# Remove códigos de texto reverso
			s/;7;/;/g

			# Normaliza os separadores
			s/;;;*/;/g
			s/^;//
			s/;$//

			# Engloba as propriedades na tag SPAN
			s,.*,<span style=\"&\">,

			:end

			# Recupera a linha original e anexa o SPAN no final
			# Ex.: ^[33m amarelo ^[m\n<span style=...>
			x
			G

			# Troca o código ANSI pela tag SPAN
			s/$esc\[[0-9;]*m\(.*\)\n\(.*\)/\2\1/

			# E começa tudo de novo, até acabar todos da linha
			b ini
		}
	"
}

# ----------------------------------------------------------------------------
# zzarrumacidade
# Arruma o nome da cidade informada: maiúsculas, abreviações, acentos, etc.
#
# Uso: zzarrumacidade [cidade]
# Ex.: zzarrumacidade SAO PAULO                     # São Paulo
#      zzarrumacidade rj                            # Rio de Janeiro
#      zzarrumacidade Floripa                       # Florianópolis
#      echo Floripa | zzarrumacidade                # Florianópolis
#      cat cidades.txt | zzarrumacidade             # [uma cidade por linha]
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-21
# Versão: 3
# Licença: GPL
# Requisitos: zzcapitalize
# ----------------------------------------------------------------------------
zzarrumacidade ()
{
	zzzz -h arrumacidade "$1" && return

	# 1. Texto via STDIN ou argumentos
	# 2. Deixa todas as iniciais em maiúsculas
	# 3. sed mágico®
	zztool multi_stdin "$@" | zzcapitalize | sed "

		# Volta algumas iniciais para minúsculas
		s/ E / e /g
		s/ De / de /g
		s/ Da / da /g
		s/ Do / do /g
		s/ Das / das /g
		s/ Dos / dos /g

		# Expande abreviações comuns
		s/^Sp$/São Paulo/
		s/^Rj$/Rio de Janeiro/
		s/^Bh$/Belo Horizonte/
		s/^Bsb$/Brasília/
		s/^Rio$/Rio de Janeiro/
		s/^Sampa$/São Paulo/
		s/^Floripa$/Florianópolis/
		# s/^Poa$/Porto Alegre/  # Perigoso, pois existe: Poá - SP

		# Abreviações comuns a Belo Horizonte
		s/^B\. H\.$/Belo Horizonte/
		s/^Bhte$/Belo Horizonte/
		s/^B\. Hte$/Belo Horizonte/
		s/^B\. Hzte$/Belo Horizonte/
		s/^Belo Hte$/Belo Horizonte/
		s/^Belo Hzte$/Belo Horizonte/


		### Restaura acentuação de maneira pontual:

		# Restaura acentuação às capitais
		s/^Belem$/Belém/
		s/^Brasilia$/Brasília/
		s/^Cuiaba$/Cuiabá/
		s/^Florianopolis$/Florianópolis/
		s/^Goiania$/Goiânia/
		s/^Joao Pessoa$/João Pessoa/
		s/^Macapa$/Macapá/
		s/^Maceio$/Maceió/
		s/^S[ãa]o Lu[ií][sz]$/São Luís/
		s/^Vitoria$/Vitória/

		# Muitas cidades emprestam o nome do estado
		#   Santana do Piauí
		#   Teresina de Goiás
		#   Pontal do Paraná
		# então é útil acentuar os nomes de estados.
		#
		s/Amapa$/Amapá/
		s/Ceara$/Ceará/
		s/Goias$/Goiás/
		s/Maranhao$/Maranhão/
		s/Para$/Pará/
		s/Paraiba$/Paraíba/
		s/Parana$/Paraná/
		s/Piaui$/Piauí/
		s/Rondonia$/Rondônia/

		# O nome de alguns estados pode aparecer no início/meio
		#   Paraíba do Sul
		#   Pará de Minas
		#
		s/Amapa /Amapá /
		s/Espirito /Espírito /
		s/Para /Pará /
		s/Paraiba /Paraíba /


		### Restaura acentuação de maneira genérica:

		# Uberlândia, Rolândia
		s/landia /lândia /g
		s/landia$/lândia/

		# Florianópolis, Virginópolis
		s/opolis /ópolis /g
		s/opolis$/ópolis/

		# Palavras terminadas em 'ao' viram 'ão'.
		# Exemplos: São, João, Ribeirão, Capão
		#
		# Não achei nenhum caso de cidade com 'ao' no final:
		#   $ zzcidade 'ao '
		#   $
		#
		# Exceção: duas cidades com aó:
		#   $ zzcidade 'aó '
		#   Alto Caparaó (MG)
		#   Caparaó (MG)
		#   $
		#
		# Exceção da exceção: algum Caparão?
		#   $ zzcidade Caparão
		#   $
		#
		# Então resolvida a exceção Caparaó, é seguro fazer a troca.
		#
		s/Caparao$/Caparaó/
		s/ao /ão /g
		s/ao$/ão/


		### Exceções pontuais:

		# Morro Cabeça no Tempo
		s/ No / no /g

		# Passa-e-Fica
		s/-E-/-e-/g

		# São João del-Rei
		s/ Del-Rei/ del-Rei/g

		# Xangri-lá: Wikipédia
		# Xangri-Lá: http://www.xangrila.rs.gov.br
		# ** Vou ignorar a Wikipédia, não precisa arrumar este

		# Nomes de Papas
		s/^Pedro Ii$/Pedro II/
		s/^Pio Ix$/Pio IX/
		s/^Pio Xii$/Pio XII/

		# Estrela d'Oeste
		# Sítio d'Abadia
		# Dias d'Ávila
		# …
		s/ D'/ d'/g

		# São João do Pau-d'Alho
		# Olhos-d'Água
		# Pau-d'Arco
		# …
		s/-D'/-d'/g
	"
}

# ----------------------------------------------------------------------------
# zzarrumanome
# Renomeia arquivos do diretório atual, arrumando nomes estranhos.
# Obs.: Ele deixa tudo em minúsculas, retira acentuação e troca espaços em
#       branco, símbolos e pontuação pelo sublinhado _.
# Opções: -n  apenas mostra o que será feito, não executa
#         -d  também renomeia diretórios
#         -r  funcionamento recursivo (entra nos diretórios)
# Uso: zzarrumanome [-n] [-d] [-r] arquivo(s)
# Ex.: zzarrumanome *
#      zzarrumanome -n -d -r .                   # tire o -n para renomear!
#      zzarrumanome "DOCUMENTO MALÃO!.DOC"       # fica documento_malao.doc
#      zzarrumanome "RAMONES - Don't Go.mp3"     # fica ramones-dont_go.mp3
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-07-23
# Versão: 1
# Licença: GPL
# Requisitos: zzarrumanome zzminusculas
# ----------------------------------------------------------------------------
zzarrumanome ()
{
	zzzz -h arrumanome "$1" && return

	local arquivo caminho antigo novo recursivo pastas nao i

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-d) pastas=1    ;;
			-r) recursivo=1 ;;
			-n) nao="[-n] " ;;
			* ) break       ;;
		esac
		shift
	done

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso arrumanome; return 1; }

	# Para cada arquivo que o usuário informou...
	for arquivo
	do
		# Tira a barra no final do nome da pasta
		test "$arquivo" != / && arquivo=${arquivo%/}

		# Ignora arquivos e pastas não existentes
		test -f "$arquivo" -o -d "$arquivo" || continue

		# Se for uma pasta...
		if test -d "$arquivo"
		then
			# Arruma arquivos de dentro dela (-r)
			test "${recursivo:-0}" -eq 1 &&
				zzarrumanome -r ${pastas:+-d} ${nao:+-n} "$arquivo"/*

			# Não renomeia nome da pasta (se não tiver -d)
			test "${pastas:-0}" -ne 1 && continue
		fi

		# A pasta vai ser a corrente ou o 'dirname' do arquivo (se tiver)
		caminho='.'
		zztool grep_var / "$arquivo" && caminho="${arquivo%/*}"

		# $antigo é o arquivo sem path (basename)
		antigo="${arquivo##*/}"

		# $novo é o nome arrumado com a magia negra no Sed
		novo=$(
			echo "$antigo" |
			tr -s '\t ' ' ' |  # Squeeze: TABs e espaços viram um espaço
			zzminusculas |
			sed -e "
				# Remove aspas
				s/[\"']//g

				# Remove espaços do início e do fim
				s/^  *//
				s/  *$//

				# Remove acentos
				y/àáâãäåèéêëìíîïòóôõöùúûü/aaaaaaeeeeiiiiooooouuuu/
				y/çñß¢Ð£Øø§µÝý¥¹²³/cnbcdloosuyyy123/

				# Qualquer caractere estranho vira sublinhado
				s/[^a-z0-9._-]/_/g

				# Remove sublinhados consecutivos
				s/__*/_/g

				# Remove sublinhados antes e depois de pontos e hífens
				s/_\([.-]\)/\1/g
				s/\([.-]\)_/\1/g

				# Hífens no início do nome são proibidos
				s/^-/_/

				# Não permite nomes vazios
				s/^$/_/"
		)

		# Se der problema com a codificação, é o y/// do Sed anterior quem estoura
		if test $? -ne 0
		then
			zztool erro "Ops. Problemas com a codificação dos caracteres."
			zztool erro "O arquivo original foi preservado: $arquivo"
			return 1
		fi

		# Nada mudou, então o nome atual já certo
		test "$antigo" = "$novo" && continue

		# Se já existir um arquivo/pasta com este nome, vai
		# colocando um número no final, até o nome ser único.
		if test -e "$caminho/$novo"
		then
			i=1
			while test -e "$caminho/$novo.$i"
			do
				i=$((i+1))
			done
			novo="$novo.$i"
		fi

		# Tudo certo, temos um nome novo e único

		# Mostra o que será feito
		echo "$nao$arquivo -> $caminho/$novo"

		# E faz
		test -n "$nao" || mv -- "$arquivo" "$caminho/$novo"
	done
}

# ----------------------------------------------------------------------------
# zzascii
# Mostra a tabela ASCII com todos os caracteres imprimíveis (32-126,161-255).
# O formato utilizando é: <decimal> <hexa> <octal> <caractere>.
# O número de colunas e a largura da tabela são configuráveis.
# Uso: zzascii [colunas] [largura]
# Ex.: zzascii
#      zzascii 4
#      zzascii 7 100
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-12-06
# Versão: 6
# Licença: GPL
# Requisitos: zzseq zzcolunar
# ----------------------------------------------------------------------------
zzascii ()
{
	zzzz -h ascii "$1" && return

	local largura_coluna decimal hexa octal caractere octal_conversao
	local num_colunas="${1:-5}"
	local largura="${2:-78}"
	local max_colunas=20
	local max_largura=500

	# Verificações básicas
	if (
		! zztool testa_numero "$num_colunas" ||
		! zztool testa_numero "$largura" ||
		test "$num_colunas" -eq 0 ||
		test "$largura" -eq 0)
	then
		zztool -e uso ascii
		return 1
	fi
	if test $num_colunas -gt $max_colunas
	then
		zztool erro "O número máximo de colunas é $max_colunas"
		return 1
	fi
	if test $largura -gt $max_largura
	then
		zztool erro "A largura máxima é de $max_largura"
		return 1
	fi

	# Largura total de cada coluna, usado no printf
	largura_coluna=$((largura / num_colunas))

	echo 'Tabela ASCII - Imprimíveis (decimal, hexa, octal, caractere)'
	echo

	for decimal in $(zzseq 32 126)
	do
		hexa=$( printf '%X'   $decimal)
		octal=$(printf '%03o' $decimal) # NNN
		caractere=$(printf "\\$octal")
		printf "%${largura_coluna}s\n" "$decimal $hexa $octal $caractere"
	done |
		zzcolunar -r -w $largura_coluna $num_colunas |
		sed 's/\(  \)\(32 20 040\)/\2\1/'
		# Sed acima é devido ao alinhamento no zzcolunar que elimina um espaço válido

	echo
	echo 'Tabela ASCII Extendida (ISO-8859-1, Latin-1) - Imprimíveis'
	echo

	# Cada caractere UTF-8 da faixa seguinte é composto por dois bytes,
	# por isso precisamos levar isso em conta no printf final
	largura_coluna=$((largura_coluna + 1))

	for decimal in $(zzseq 161 255)
	do
		hexa=$( printf '%X'   $decimal)
		octal=$(printf '%03o' $decimal) # NNN

		# http://www.lingua-systems.com/unicode-converter/unicode-mappings/encode-iso-8859-1-to-utf-8-unicode.html
		if test $decimal -le 191  # 161-191: ¡-¿
		then
			caractere=$(printf "\302\\$octal")
		else                      # 192-255: À-ÿ
			octal_conversao=$(printf '%03o' $((decimal - 64)))
			caractere=$(printf "\303\\$octal_conversao")
		fi

		# Mostra a célula atual da tabela
		printf "%${largura_coluna}s\n" "$decimal $hexa $octal $caractere"
	done |
		zzcolunar -r -w $((largura_coluna - 1)) $num_colunas
}

# ----------------------------------------------------------------------------
# zzbeep
# Aguarda N minutos e dispara uma sirene usando o 'speaker'.
# Útil para lembrar de eventos próximos no mesmo dia.
# Sem argumentos, restaura o 'beep' para o seu tom e duração originais.
# Obs.: A sirene tem 4 toques, sendo 2 tons no modo texto e apenas 1 no Xterm.
# Uso: zzbeep [números]
# Ex.: zzbeep 0
#      zzbeep 1 5 15    # espere 1 minuto, depois mais 5, e depois 15
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-04-24
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzbeep ()
{
	zzzz -h beep "$1" && return

	local minutos frequencia

	# Sem argumentos, apenas restaura a "configuração de fábrica" do beep
	test -n "$1" || {
		printf '\033[10;750]\033[11;100]\a'
		return 0
	}

	# Para cada quantidade informada pelo usuário...
	for minutos in $*
	do
		# Aguarda o tempo necessário
		printf "Vou bipar em $minutos minutos... "
		sleep $((minutos*60))

		# Ajusta o beep para toque longo (Linux modo texto)
		printf '\033[11;900]'

		# Alterna entre duas freqüências, simulando uma sirene (Linux)
		for frequencia in 500 400 500 400
		do
			printf "\033[10;$frequencia]\a"
			sleep 1
		done

		# Restaura o beep para toque normal
		printf '\033[10;750]\033[11;100]'
		echo OK
	done
}

# ----------------------------------------------------------------------------
# zzbicho
# Jogo do bicho.
# Com um número como argumento indica o bicho e o grupo.
# Se o for um número entre 1 e 25 seguido de "g", lista os números do grupo.
# Sem argumento ou com apenas "g" lista todos os grupos de bichos.
#
# Uso: zzbicho [numero] [g]
# Ex.: zzbicho 123456
#      zzbicho 14 g
#      zzbicho g
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2012-08-27
# Versão: 4
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zzbicho ()
{
	zzzz -h bicho "$1" && return

	# Verificação dos parâmetros: se há $1, ele deve ser 'g' ou um número
	if test $# -gt 0 && test "$1" != 'g' && ! zztool testa_numero "$1"
	then
		zztool -e uso bicho
		return 1
	fi

	echo "$*" |
	awk '{
		grupo[01]="Avestruz"
		grupo[02]="Águia"
		grupo[03]="Burro"
		grupo[04]="Borboleta"
		grupo[05]="Cachorro"
		grupo[06]="Cabra"
		grupo[07]="Carneiro"
		grupo[08]="Camelo"
		grupo[09]="Cobra"
		grupo[10]="Coelho"
		grupo[11]="Cavalo"
		grupo[12]="Elefante"
		grupo[13]="Galo"
		grupo[14]="Gato"
		grupo[15]="Jacaré"
		grupo[16]="Leão"
		grupo[17]="Macaco"
		grupo[18]="Porco"
		grupo[19]="Pavão"
		grupo[20]="Peru"
		grupo[21]="Touro"
		grupo[22]="Tigre"
		grupo[23]="Urso"
		grupo[24]="Veado"
		grupo[25]="Vaca"

		if ($2=="g" && $1 >= 1 && $1 <= 25) {
			numero = $1 * 4
			for (numero = ($1 * 4) - 3;numero <= ($1 *4); numero++) {
				printf "%.2d ", substr(numero,length(numero)-1,2)
			}
			print ""
		}
		else if ($1 == "g" || $1 == "") {
			for (num=1;num<=25;num++) {
				printf "%.2d %s\n",num, grupo[num]
			}
		}
		else {
			numero = substr($1,length($1)-1,2)=="00"?25:int((substr($1,length($1)-1,2) + 3) / 4)
			print grupo[numero], "(" numero ")"
		}
	}' | zztrim -r
}

# ----------------------------------------------------------------------------
# zzbissexto
# Diz se o ano informado é bissexto ou não.
# Obs.: Se o ano não for informado, usa o atual.
# Uso: zzbissexto [ano]
# Ex.: zzbissexto
#      zzbissexto 2000
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-21
# Versão: 1
# Licença: GPL
# Tags: data
# ----------------------------------------------------------------------------
zzbissexto ()
{
	zzzz -h bissexto "$1" && return

	local ano="$1"

	# Se o ano não for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Validação
	zztool -e testa_ano "$ano" || return 1

	if zztool testa_ano_bissexto "$ano"
	then
		echo "$ano é bissexto"
	else
		echo "$ano não é bissexto"
	fi
}

# ----------------------------------------------------------------------------
# zzblist
# Mostra se o IP informado está em alguma blacklist.
# Uso: zzblist IP
# Ex.: zzblist 200.199.198.197
#
# Autor: Vinícius Venâncio Leite <vv.leite (a) gmail com>
# Desde: 2008-10-16
# Versão: 4
# Licença: GPL
# ----------------------------------------------------------------------------
zzblist ()
{
	zzzz -h blist "$1" && return

	local URL="http://addgadgets.com/ip_blacklist/index.php?ipaddr="
	local ip="$1"
	local lista

	test -n "$1" || { zztool -e uso blist; return 1; }

	zztool -e testa_ip "$ip" || return 1

	lista=$(
		$ZZWWWDUMP "${URL}${ip}" |
		grep 'Listed' |
		sed '/ahbl\.org/d;/=/d;/ *Not/d'
	)

	if test $(echo "$lista" | sed '/^ *$/d' | zztool num_linhas) -eq 0
	then
		zztool eco "O IP não está em nenhuma blacklist"
	else
		zztool eco "O IP está na(s) seguinte(s) blacklist"
		echo "$lista" | sed 's/ *Listed//'
	fi
}

# ----------------------------------------------------------------------------
# zzbolsas
# http://br.finance.yahoo.com
# Pesquisa índices de bolsas e cotações de ações.
# Sem parâmetros mostra a lista de bolsas disponíveis (códigos).
# Com 1 parâmetro:
#  -l ou --lista: apenas mostra as bolsas disponíveis e seus nomes.
#  --limpa ou --limpar: exclui todos os arquivos de cache.
#  commodities: produtos de origem primária nas bolsas.
#  taxas_fixas ou moedas: exibe tabela de comparação de câmbio (principais).
#  taxas_cruzadas: exibe a tabela cartesiana do câmbio.
#  nome_moedas ou moedas_nome: lista códigos e nomes das moedas usadas.
#  servicos, economia ou politica: mostra notícias relativas a esse assuntos.
#  noticias: junta as notícias de serviços e economia.
#  volume: lista ações líderes em volume de negócios na Bovespa.
#  alta ou baixa: lista as ações nessa condição na BMFBovespa.
#  "código de bolsa ou ação": mostra sua última cotação.
#
# Com 2 parâmetros:
#  -l e código de bolsa: lista as ações (códigos).
#  --lista e "código de bolsa": lista as ações com nome e última cotação.
#  taxas_fixas ou moedas <principais|europa|asia|latina>: exibe tabela de
#   comparação de câmbio dessas regiões.
#  "código de bolsa" e um texto: pesquisa-o no nome ou código das ações
#    disponíveis na bolsa citada.
#  "código de bolsa ou ação" e data: pesquisa a cotação no dia.
#  noticias e "código de ação": Noticias relativas a essa ação (só Bovespa)
#
# Com 3 parâmetros ou mais:
#  "código de bolsa ou ação" e 2 datas: pesquisa as cotações nos dias com
#    comparações entre datas e variações da ação ou bolsa pesquisada.
#  vs (ou comp) e 2 códigos de bolsas ou ações: faz a comparação entre as duas
#   ações ou bolsas. Se houver um quarto parâmetro como uma data faz essa
#   comparação na data especificada. Mas não compara ações com bolsas.
#
# Uso: zzbolsas [-l|--lista] [bolsa|ação] [data1|pesquisa] [data2]
# Ex.: zzbolsas                  # Lista das bolsas (códigos)
#      zzbolsas -l               # Lista das bolsas (nomes)
#      zzbolsas -l ^BVSP         # Lista as ações do índice Bovespa (código)
#      zzbolsas --lista ^BVSP    # Lista as ações do índice Bovespa (nomes)
#      zzbolsas ^BVSP loja       # Procura ações com "loja" no nome ou código
#      zzbolsas ^BVSP            # Cotação do índice Bovespa
#      zzbolsas PETR4.SA         # Cotação das ações da Petrobrás
#      zzbolsas PETR4.SA 21/12/2010  # Cotação da Petrobrás nesta data
#      zzbolsas commodities      # Tabela de commodities
#      zzbolsas alta             # Lista ações em altas na Bovespa
#      zzbolsas volume           # Lista ações em alta em volume de negócios
#      zzbolsas taxas_fixas
#      zzbolsas taxas_cruzadas
#      zzbolsas noticias sbsp3.sa    # Noticias recentes no mercado da Sabesp
#      zzbolsas vs petr3.sa vale3.sa # Compara ambas cotações
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2009-10-04
# Versão: 23
# Licença: GPL
# Requisitos: zzmaiusculas zzsemacento zzdatafmt
# ----------------------------------------------------------------------------
zzbolsas ()
{
	zzzz -h bolsas "$1" && return

	local url='http://br.finance.yahoo.com'
	local new_york='^NYA ^NYI ^NYY ^NY ^NYL ^NYK'
	local nasdaq='^IXIC ^BANK ^NBI ^IXCO ^IXF ^INDS ^INSR ^OFIN ^IXTC ^TRAN ^NDX'
	local sp='^GSPC ^OEX ^MID ^SPSUPX ^SP600'
	local amex='^XAX ^IIX ^NWX ^XMI'
	local ind_nac='^IBX50 ^IVBX ^IGCX ^IEE INDX.SA'
	local cache=$(zztool mktemp bolsas)
	local bolsa pag pags pag_atual data1 data2 vartemp

	case $# in
		0)
			# Lista apenas os códigos das bolsas disponíveis
			for bolsa in americas europe asia africa
			do
				zztool eco "\n$bolsa :"
				$ZZWWWDUMP "$url/intlindices?e=$bolsa" |
					sed -n '/Última/,/_/p' | sed '/Componentes,/!d' |
					awk '{ printf "%s ", $1}';echo
			done

			zztool eco "\nDow Jones :"
			$ZZWWWDUMP "$url/usindices" |
				sed -n '/Última/,/_/p' | sed '/Componentes,/!d' |
				awk '{ printf "%s ", $1}';echo

			zztool eco "\nNYSE :"
			for bolsa in $new_york; do printf "%s " "$bolsa"; done;echo

			zztool eco "\nNasdaq :"
			for bolsa in $nasdaq; do printf "%s " "$bolsa"; done;echo

			zztool eco "\nStandard & Poors :"
			for bolsa in $sp; do printf "%s " "$bolsa"; done;echo

			zztool eco "\nAmex :"
			for bolsa in $amex; do printf "%s " "$bolsa"; done;echo

			zztool eco "\nOutros Índices Nacionais :"
			for bolsa in $ind_nac; do printf "%s " "$bolsa"; done;echo
		;;
		1)
			# Lista os códigos da bolsas e seus nomes
			case "$1" in
			#Limpa todos os cache acumulado
			--limpa| --limpar) rm -f "${cache:-xxxx}.*" ;;
			-l | --lista)
				for bolsa in americas europe asia africa
				do
					zztool eco "\n$bolsa :"
					$ZZWWWDUMP "$url/intlindices?e=$bolsa" |
						sed -n '/Última/,/_/p' | sed '/Componentes,/!d' |
						sed 's/[0-9]*\.*[0-9]*,[0-9].*//g' |
						awk '{ printf " %-10s ", $1; for(i=2; i<=NF-1; i++) printf "%s ",$i; print $NF}'
				done

				zztool eco "\nDow Jones :"
				$ZZWWWDUMP "$url/usindices" |
					sed -n '/Última/,/_/p' | sed '/Componentes,/!d' |
					sed 's/[0-9]*\.*[0-9]*,[0-9].*//g' |
					awk '{ printf " %-10s ", $1; for(i=2; i<=NF-1; i++) printf "%s ",$i; print $NF}'
					printf " %-10s " "$dj";$ZZWWWDUMP "$url/q?s=$dj" |
					sed -n "/($dj)/{p;q;}" | sed "s/^ *//;s/ *($dj)//"

				zztool eco "\nNYSE :"
				for bolsa in $new_york;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa" |
					sed -n "/($bolsa)/{p;q;}" | sed "s/^ *//;s/ *($bolsa)//"
				done

				zztool eco "\nNasdaq :"
				for bolsa in $nasdaq;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa" |
					sed -n "/($bolsa)/{p;q;}" | sed "s/^ *//;s/ *($bolsa)//"
				done

				zztool eco "\nStandard & Poors :"
				for bolsa in $sp;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa" |
					sed -n "/($bolsa)/{p;q;}" | sed "s/^ *//;s/ *($bolsa)//"
				done

				zztool eco "\nAmex :"
				for bolsa in $amex;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa" |
					sed -n "/($bolsa)/{p;q;}" | sed "s/^ *//;s/ *($bolsa)//"
				done

				zztool eco "\nOutros Índices Nacionais :"
				for bolsa in $ind_nac;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa" |
					sed -n "/($bolsa)/{p;q;}" | sed "s/^ *//;s/ *($bolsa)//;s/ *-$//"
				done
			;;
			commodities)
				zztool eco  "Commodities"
				$ZZWWWDUMP "$url/moedas/mercado.html" |
				sed -n '/^Commodities/,/Mais commodities/p' |
				sed '1d;$d;/^ *$/d;s/CAPTION: //g;s/ *Metais/\
&/'| sed 's/^   //g'
			;;
			taxas_fixas | moedas)
				zzbolsas $1 principais
			;;
			taxas_cruzadas)
				zztool eco "Taxas Cruzadas"
				$ZZWWWDUMP "$url/moedas/principais" |
				sed -n '/CAPTION: Taxas cruzadas/,/Not.cias e coment.rios/p' |
				sed '1d;/^[[:space:]]*$/d;$d;s/ .ltima transação /                  /g; s, N/D,    ,g; s/           //; s/^  *//'
			;;
			moedas_nome | nome_moedas)
				zztool eco "BRL - Real"
				zztool eco "USD - Dolar Americano"
				zztool eco "EUR - Euro"
				zztool eco "GBP - Libra Esterlina"
				zztool eco "CHF - Franco Suico"
				zztool eco "CNH - Yuan Chines"
				zztool eco "HKD - Dolar decHong Kong"
				zztool eco "SGD - Dolar de Singapura"
				zztool eco "MXN - Peso Mexicano"
				zztool eco "ARS - Peso Argentino"
				zztool eco "UYU - Peso Uruguaio"
				zztool eco "CLP - Peso Chileno"
				zztool eco "PEN - Nuevo Sol (Peru)"
			;;
			volume | alta | baixa)
				case "$1" in
					volume) pag='actives';;
					alta)	pag='gainers';;
					baixa)	pag='losers';;
				esac
				zztool eco "Maiores ${1}s"
				$ZZWWWDUMP "$url/${pag}?e=sa" |
				sed -n '/Informações relacionadas/,/^[[:space:]]*$/p' |
				sed '1d;s/Down /-/g;s/ de /-/g;s/Up /+/g;s/Gráfico, .*//g' |
				sed 's/ *Para *cima */ +/g;s/ *Para *baixo */ -/g' |
				awk 'BEGIN {
							printf "%-15s  %-24s  %-24s  %-19s  %-10s\n","Símbolo","Nome","Última Transação","Variação","Volume"
						}
					{
						if (NF > 6) {
							nome = ""
							printf "%-15s ", $1;
							for(i=2; i<=NF-5; i++) {nome = nome sprintf( "%s ", $i)};
							printf " %-24s ", nome;
							for(i=NF-4; i<=NF-3; i++) printf " %-8s ", $i;
							printf "  "
							printf " %-7s ", $(NF-2); printf " %-9s ", $(NF-1);
							printf " %11s", $NF
							print ""
						}
					}'
			;;
			*)
				bolsa=$(echo "$1" | zzmaiusculas)
				# Último índice da bolsa citada ou cotação da ação
				$ZZWWWDUMP "$url/q?s=$bolsa" |
				sed -n "/($bolsa)/,/Cotações atrasadas, salvo indicação/p" |
				sed '{
						/^[[:space:]]*$/d
						/IFRAME:/d;
						/^[[:space:]]*-/d
						/Adicionar ao portfólio/d
						/As pessoas que viram/d
						/Cotações atrasadas, salvo indicação/,$d
						/Próxima data de anúncio/d
						s/[[:space:]]\{1,\}/ /g
						s|p/ *|p/|g
					}' |
				zzsemacento | awk -F":" '{if ( $1 != $2 && length($2)>0 ) {printf "%-20s%s\n", $1 ":", $2} else { print $1 } }'
			;;
			esac
		;;
		2 | 3 | 4)
			# Lista as ações de uma bolsa especificada
			bolsa=$(echo "$2" | zzmaiusculas)
			if test "$1" = "-l" -o "$1" = "--lista" && (zztool grep_var "$bolsa" "$dj $new_york $nasdaq $sp $amex $ind_nac" || zztool grep_var "^" "$bolsa")
			then
				pag_final=$($ZZWWWDUMP "$url/q/cp?s=$bolsa" | sed -n '/Primeira/p;/Primeira/q' | sed "s/^ *//g;s/.* of *\([0-9]\{1,\}\) .*/\1/;s/.* de *\([0-9]\{1,\}\) .*/\1/")
				pags=$(echo "scale=0;($pag_final - 1) / 50" | bc)

				unset vartemp
				pag=0
				while test $pag -le $pags
				do
					if test "$1" = "--lista"
					then
						# Listar as ações com descrição e suas últimas posições
						$ZZWWWDUMP "$url/q/cp?s=$bolsa&c=$pag" |
						sed -n 's/^ *//g;/Símbolo /,/^Tudo /p' |
						sed '/Símbolo /d;/^Tudo /d;/^[ ]*$/d' |
						sed 's/ *Para *cima */ +/g;s/ *Para *baixo */ -/g' |
						awk -v pag_awk=$pag '
						BEGIN { if (pag_awk==0) {printf "%-14s %-54s %-23s %-15s %-10s\n", "Símbolo", "Empresa", "Última Transação", "Variação", "Volume"} }
						{
							nome = ""
							if (NF>=7) {
								if (index($(NF-3),":") != 0) { ajuste=0; limite = 7 } else { ajuste=2; limite = 9 }
								if (NF>=limite) {
									if (ajuste == 0 ) { data_hora = $(NF-3) }
									else if (ajuste == 2 ) { data_hora = $(NF-5) " " $(NF-4) " " $(NF-3) }
									for(i=2;i<=(NF-5-ajuste);i++) {nome = nome " " $i }
									printf "%-13s %-50s %10s %10s %10s %9s %10s\n", $1, nome, $(NF-4-ajuste), data_hora, $(NF-2), $(NF-1), $NF
								}
							}
						}'
					else
						# Lista apenas os códigos das ações
						vartemp=${vartemp}$($ZZWWWDUMP "$url/q/cp?s=$bolsa&c=$pag" |
						sed -n 's/^ *//g;/Símbolo /,/^Tudo /p' |
						sed '/Símbolo /d;/^Tudo /d;/^[ ]*$/d' |
						awk '{printf "%s  ",$1}')

						if test "$pag" = "$pags";then echo $vartemp;fi
					fi
					pag=$(($pag+1))
				done

			# Valores de uma bolsa ou ação em uma data especificada (histórico)
			elif zztool testa_data $(zzdatafmt "$2" 2>/dev/null)
			then
				vartemp=$(zzdatafmt -f "DD MM AAAA DD/MM/AAAA" "$2")
				dd=$(echo $vartemp | cut -f1 -d ' ')
				mm=$(echo $vartemp | cut -f2 -d ' ')
				yyyy=$(echo $vartemp | cut -f3 -d ' ')
				data1=$(echo $vartemp | cut -f4 -d ' ')
				unset vartemp

				mm=$(echo "scale=0;${mm}-1" | bc)
				bolsa=$(echo "$1" | zzmaiusculas)
					# Emprestando as variaves pag, pags e pag_atual efeito estético apenas
					pag=$($ZZWWWDUMP "$url/q/hp?s=$bolsa&a=${mm}&b=${dd}&c=${yyyy}&d=${mm}&e=${dd}&f=${yyyy}&g=d" |
					sed -n "/($bolsa)/p;/Abertura/,/* Preço/p" | sed 's/Data/    /;/* Preço/d' |
					sed 's/^ */ /g;/Proxima data de anuncio/d')

					echo "$pag" | sed -n '2p' | sed 's/ [A-Z]/\
\t&/g;s/Enc ajustado/Ajustado/' | sed '/^ *$/d' | awk 'BEGIN { printf "%-13s\n", "Data" } {printf "%-12s\n", $1}' > "${cache}.pags"

					echo "$pag" | sed -n '3p' | cut -f7- -d" " | sed 's/ [0-9]/\
&/g' | sed '/^ *$/d' | awk 'BEGIN { print "    '$data1'" } {printf "%14s\n", $1}' > "${cache}.pag_atual"
					echo "$pag" | sed -n '1p'| sed 's/^ *//'

					if test -n "$3" && zztool testa_data $(zzdatafmt "$3")
					then
						vartemp=$(zzdatafmt -f "DD MM AAAA DD/MM/AAAA" "$3")
						dd=$(echo $vartemp | cut -f1 -d ' ')
						mm=$(echo $vartemp | cut -f2 -d ' ')
						yyyy=$(echo $vartemp | cut -f3 -d ' ')
						data2=$(echo $vartemp | cut -f4 -d ' ')
						mm=$(echo "scale=0;${mm}-1" | bc)
						unset vartemp

						$ZZWWWDUMP "$url/q/hp?s=$bolsa&a=${mm}&b=${dd}&c=${yyyy}&d=${mm}&e=${dd}&f=${yyyy}&g=d" |
						sed -n "/($bolsa)/p;/Abertura/,/* Preço/p" | sed 's/Data/    /;/* Preço/d' |
						sed 's/^ */ /g' | sed -n '3p' | cut -f7- -d" " | sed 's/ [0-9]/\n&/g' |
						sed '/^ *$/d' | awk 'BEGIN { print "     '$data2'" } {printf " %14s\n", $1}' > "${cache}.pag"

						printf '%b\n' "       Variação\t Var (%)" > "${cache}.vartemp"
						paste "${cache}.pag_atual" "${cache}.pag" | while read data1 data2
						do
							echo "$data1 $data2" | tr -d '.' | tr ',' '.' |
							awk '{ if (index($1,"/")==0) {printf "%15.2f\t", $2-$1; if ($1 != 0) {printf "%7.2f%\n", (($2-$1)/$1)*100}}}' 2>/dev/null
						done >> "${cache}.vartemp"

						paste "${cache}.pags" "${cache}.pag_atual" "${cache}.pag" "${cache}.vartemp"
					else
						paste "${cache}.pags" "${cache}.pag_atual"
					fi
			# Compara duas ações ou bolsas diferentes
			elif (test "$1" = "vs" -o "$1" = "comp")
			then
				if (zztool grep_var "^" "$2" && zztool grep_var "^" "$3")
				then
					vartemp="0"
				elif (! zztool grep_var "^" "$2" && ! zztool grep_var "^" "$3")
				then
					vartemp="0"
				fi
				if test -n "$vartemp"
				then
					# Compara numa data especifica as ações ou bolsas
					if (test -n "$4" && zztool testa_data $(zzdatafmt "$4"))
					then
						zzbolsas "$2" "$4" | sed '/Proxima data de anuncio/d' > "${cache}.pag"
						vartemp=$(zztool num_linhas ${cache}.pag)
						zzbolsas "$3" "$4" |
						sed '/Proxima data de anuncio/d;s/^[[:space:]]*//g;s/[[:space:]]*$//g' |
						sed '2,$s/^[[:upper:][:space:][:space:]][^0-9]*//g' > "${cache}.temp"
						sed -n "1,${vartemp}p" "${cache}.temp" > "${cache}.pags"
					# Ultima cotaçao das açoes ou bolsas comparadas
					else
						zzbolsas "$2" | sed '/Proxima data de anuncio/d' > "${cache}.pag"
						zzbolsas "$3" | sed '/Proxima data de anuncio/d' |
						sed 's/^[[:space:]]*//g;3,$s/.*:[[:space:]]*//g' > "${cache}.pags"
					fi
					# Imprime efetivamente a comparação
					if test $(awk 'END {print NR}' "${cache}.pag") -ge 4 -a $(awk 'END {print NR}' "${cache}.pags") -ge 4
					then
						paste -d"|" "${cache}.pag" "${cache}.pags" |
						awk -F"|" '{printf "%-42s %25s\n", $1, $2}'
					fi
				fi
			# Noticias relacionadas a uma ação especifica
			elif (test "$1" = "noticias" -o "$1" = "notícias" && ! zztool grep_var "^" "$2")
			then
				$ZZWWWDUMP "$url/q/h?s=$bolsa" |
				sed -n '/^[[:blank:]]\{1,\}\*.*Agencia.*)$/p;/^[[:blank:]]\{1,\}\*.*at noodls.*)$/p' |
				sed 's/^[[:blank:]]*//g;s/Agencia/ &/g;s/at noodls/ &/g'
			elif (test "$1" = "taxas_fixas" || test "$1" = "moedas")
			then
				case $2 in
				asia)
					url="$url/moedas/asia-pacifico"
					zztool eco "$(echo $1 | sed 'y/tfm_/TFM /') - Ásia-Pacífico"
				;;
				latina)
					url="$url/moedas/america-latina"
					zztool eco "$(echo $1 | sed 'y/tfm_/TFM /') - América Latina"
				;;
				europa)
					url="$url/moedas/europa"
					zztool eco "$(echo $1 | sed 'y/tfm_/TFM /') - Europa"
				;;
				principais | *)
					url="$url/moedas/principais"
					zztool eco "$(echo $1 | sed 'y/tfm_/TFM /') - Principais"
				;;
				esac

				$ZZWWWDUMP "$url" |
					sed -n '
						# grepa apenas as linhas das moedas e os títulos
						/CAPTION: Taxas fixas/,/CAPTION: Taxas cruzadas/ {
							/^  *[A-Z][A-Z][A-Z]\/[A-Z][A-Z][A-Z]/ p
							/^  *Par cambial/ p
						}' |
					sed '
						# Remove lixos
						s/ *Visualização do gráfico//g
						s/ Inverter pares /                /g

						# A segunda tabela é invertida
						3,$ s/Par cambial             /Par cambial inv./

						# Diminuição do espaçamento para caber em 80 colunas
						s/^  *//
						s/        //

						# Quebra linha antes do título das duas tabelas
						/^Par cambial/ s/^/\
/
						# Apagando linha duplicada com valores em branco
						/[A-Z]\{3\}\/[A-Z]\{3\} *$/d
						'
			else
				bolsa=$(echo "$1" | zzmaiusculas)
				pag_final=$($ZZWWWDUMP "$url/q/cp?s=$bolsa" | sed -n '/Primeira/p;/Primeira/q' | sed 's/^ *//g;s/.* of *\([0-9]\{1,\}\) .*/\1/;s/.* de *\([0-9]\{1,\}\) .*/\1/')
				pags=$(echo "scale=0;($pag_final - 1) / 50" | bc)
				pag=0
				while test $pag -le $pags
				do
					$ZZWWWDUMP "$url/q/cp?s=$bolsa&c=$pag" |
					sed -n 's/^ *//g;/Símbolo /,/Primeira/p' |
					sed '/Símbolo /d;/Primeira/d;/^[ ]*$/d' |
					grep -i "$2"
					pag=$(($pag+1))
				done
			fi
		;;
	esac

	rm -f "${cache:-xxxx}.*"
}

# ----------------------------------------------------------------------------
# zzbraille
# Grafia Braille.
# A estrutura básica do alfabeto braille é composta por 2 colunas e 3 linhas.
# Essa estrutura é chamada de célula Braille
# E a sequência numérica padronizada é como segue:
#  1 4
#  2 5
#  3 6
# Assim fica como um guia, para quem desejar implantar essa acessibilidade.
#
# Com a opção --s1 muda o símbolo ● (relevo, em destaque, cheio)
# Com a opção --s2 muda o símbolo ○ (plano, sem destaque, vazio)
#
# Abaixo de cada célula Braille, aparece o caractere correspondente.
# Incluindo especiais de maiúscula, numérico, espaço, multi-células.
# +++++ : Maiúsculo
# +-    : Capitalize
# __    : Espaço
# ##    : Número
# -( X ): Caractere especial que ocupa mais de uma célula Braille
#
# Atenção: Prefira usar ! em texto dentro de aspas simples (')
#
# Uso: zzbraille <texto> [texto]
# Ex.: zzbraille 'Olá mundo!'
#      echo 'Good Morning, Vietnam!' | zzbraille --s2 ' '
#      zzbraille --s1 O --s2 'X' 'Um texto qualquer'
#      zzbraille --s1 . --s2 ' ' Mensagem
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-05-26
# Versão: 5
# Licença: GPL
# Requisitos: zzminusculas zzmaiusculas zzcapitalize zzseq
# ----------------------------------------------------------------------------
zzbraille ()
{
	zzzz -h braille "$1" && return

	# Lista de caracteres (quase todos)
	local caracter="\
a|1|0|0|0|0|0
b|1|1|0|0|0|0
c|1|0|0|1|0|0
d|1|0|0|1|1|0
e|1|0|0|0|1|0
f|1|1|0|1|0|0
g|1|1|0|1|1|0
h|1|1|0|0|1|0
i|0|1|0|1|0|0
j|0|1|0|1|1|0
k|1|0|1|0|0|0
l|1|1|1|0|0|0
m|1|0|1|1|0|0
n|1|0|1|1|1|0
o|1|0|1|0|1|0
p|1|1|1|1|0|0
q|1|1|1|1|1|0
r|1|1|1|0|1|0
s|0|1|1|1|0|0
t|0|1|1|1|1|0
u|1|0|1|0|0|1
v|1|1|1|0|0|1
w|0|1|0|1|1|1
x|1|0|1|1|0|1
y|1|0|1|1|1|1
z|1|0|1|0|1|1
1|1|0|0|0|0|0
2|1|1|0|0|0|0
3|1|0|0|1|0|0
4|1|0|0|1|1|0
5|1|0|0|0|1|0
6|1|1|0|1|0|0
7|1|1|0|1|1|0
8|1|1|0|0|1|0
9|0|1|0|1|0|0
0|0|1|0|1|1|0
.|0|1|0|0|1|1
,|0|1|0|0|0|0
?|0|1|0|0|0|1
;|0|1|1|0|0|0
!|0|1|1|0|1|0
-|0|0|1|0|0|1
'|0|0|1|0|0|0
*|0|0|1|0|1|0
$|0|0|0|0|1|1
:|0|1|0|0|1|0
=|0|1|1|0|1|1
â|1|0|0|0|0|1
ê|1|1|0|0|0|1
ì|1|0|0|1|0|1
ô|1|0|0|1|1|1
ù|1|0|0|0|1|1
à|1|1|0|1|0|1
ï|1|1|0|1|1|1
ü|1|1|0|0|1|1
õ|0|1|0|1|0|1
ò|0|1|0|1|1|1
ç|1|1|1|1|0|1
é|1|1|1|1|1|1
á|1|1|1|0|1|1
è|0|1|1|1|0|1
ú|0|1|1|1|1|1
í|0|0|1|1|0|0
ã|0|0|1|1|1|0
ó|0|0|1|1|0|1
(|1|1|0|0|0|1
)|0|0|1|1|1|0
[|1|1|1|0|1|1
]|0|1|1|1|1|1
{|1|1|1|0|1|1
}|0|1|1|1|1|1
>|1|0|1|0|1|0
<|0|1|0|1|0|1
°|0|0|1|0|1|1
+|0|1|1|0|1|0
×|0|1|1|0|0|1
÷|0|1|0|0|1|1
&|1|1|1|1|0|1
"

	# Caracteres especias que usam mais de uma célula Braille
	local caracter_esp='―|0|0|1|0|0|1|0|0|1|0|0|1
/|0|0|0|0|0|1|0|1|0|0|0|0
_|0|0|0|1|0|1|0|0|1|0|0|1
€|0|0|0|1|0|0|1|0|0|1|1|0
(|1|1|0|0|0|1|0|0|1|0|0|0
)|0|0|0|0|0|1|0|0|1|1|1|0
«|0|0|0|0|0|1|0|1|1|0|0|1
»|0|0|0|0|0|1|0|1|1|0|0|1
→|0|1|0|0|1|0|1|0|1|0|1|0
←|0|1|0|1|0|1|0|1|0|0|1|0
§|0|1|1|1|0|0|0|1|1|1|0|0
"|0|1|1|0|0|1
'

	local largura=$(echo $(($(tput cols)-2)))
	local c='●'
	local v='○'
	local linha1 linha2 linha3 tamanho i letra letra_original codigo linha0

	# Opção para mudar os símbolos a serem exibidos dentro da célula Braille
	# E garantindo que seja apenas um caractere usando sed. O cut e o awk falham dependendo do ambiente
	while test -n "$1"
	do
		case $1 in
			"--s1") c=$(echo "$2" | sed 's/\(.\).*/\1/'); shift; shift;;
			"--s2") v=$(echo "$2" | sed 's/\(.\).*/\1/'); shift; shift;;
			*) break;;
		esac
	done

	set - $(zztool multi_stdin "$@")
	while test -n "$1"
	do
		# Demarcando início do texto (iniciativa do autor para noção dos limites da célula Braille)
		# E sinalizando espaço entre as palavras
		linha0=${linha0}' __'
		linha1=${linha1}' 00'
		linha2=${linha2}' 00'
		linha3=${linha3}' 00'

		if zztool testa_numero "$1" || zztool testa_numero_fracionario "$1"
		then
			linha0=${linha0}' ##' # Para indicar que começa um número, nas apontamento abaixo da célula
			linha1=${linha1}' 01'
			linha2=${linha2}' 01'
			linha3=${linha3}' 11'
		elif test "$1" = $(zzcapitalize "$1") -a "$1" != $(zzminusculas "$1")
		then
			linha0=${linha0}' +-' # Para indicar que o texto a seguir está com a primeira letra em maiúscula (capitalize)
			linha1=${linha1}' 01'
			linha2=${linha2}' 00'
			linha3=${linha3}' 01'
		elif test "$1" = $(zzmaiusculas "$1") -a "$1" != $(zzminusculas "$1")
		then
			linha0=${linha0}' +++++' # Para indicar que o texto a seguir está todo maiúsculo
			linha1=${linha1}' 01 01'
			linha2=${linha2}' 00 00'
			linha3=${linha3}' 01 01'
		fi

		tamanho=$(echo "${#linha1} + ${#1} * 3" | bc)
		if test $tamanho -le $largura
		then
			for i in $(zzseq ${#1})
			do
				letra=$(echo $1| tr ' ' '#' | zzminusculas | sed "s/^\(.\{1,$i\}\).*/\1/" | sed 's/.*\(.\)$/\1/')
				letra_original=$(echo $1| tr ' ' '#' | sed "s/^\(.\{1,$i\}\).*/\1/" | sed 's/.*\(.\)$/\1/')
				if test -n $letra
				then
					test $letra = '/' && letra='\/'
					codigo=$(echo "$caracter" | sed -n "/^[$letra]/p")
					if test -n $codigo
					then
						letra_original=$(echo $letra_original | tr '#' ' ')
						linha0=${linha0}'('${letra_original}')'
						linha1=${linha1}' '$(echo $codigo | awk -F'|' '{print $2 $5}')
						linha2=${linha2}' '$(echo $codigo | awk -F'|' '{print $3 $6}')
						linha3=${linha3}' '$(echo $codigo | awk -F'|' '{print $4 $7}')
					else
						if test $letra = '\'
						then
							linha0=${linha0}'-( '${letra_original}' )'
							linha1=${linha1}' '$(awk 'BEGIN {print "00 00"}')
							linha2=${linha2}' '$(awk 'BEGIN {print "01 00"}')
							linha3=${linha3}' '$(awk 'BEGIN {print "00 10"}')
						else
							codigo=$(echo "$caracter_esp" | sed -n "/^[$letra]/p")
							test ${#codigo} -ge 25 && linha0=${linha0}'-( '${letra_original}' )'|| linha0=${linha0}'('${letra_original}')'
							linha1=${linha1}' '$(echo $codigo | awk -F'|' '{print $2 $5, $8 $11}')
							linha2=${linha2}' '$(echo $codigo | awk -F'|' '{print $3 $6, $9 $12}')
							linha3=${linha3}' '$(echo $codigo | awk -F'|' '{print $4 $7, $10 $13}')
						fi
					fi
				fi
			done
			shift
		else
			echo "$linha1" | sed "s/1/$c/g;s/0/$v/g"
			echo "$linha2" | sed "s/1/$c/g;s/0/$v/g"
			echo "$linha3" | sed "s/1/$c/g;s/0/$v/g"
			echo "$linha0"
			echo
			unset linha1
			unset linha2
			unset linha3
			unset linha0
		fi
	done
	echo "$linha1" | sed "s/1/$c/g;s/0/$v/g"
	echo "$linha2" | sed "s/1/$c/g;s/0/$v/g"
	echo "$linha3" | sed "s/1/$c/g;s/0/$v/g"
	echo "$linha0"
	echo
}

# ----------------------------------------------------------------------------
# zzbrasileirao
# http://esporte.uol.com.br/
# Mostra a tabela atualizada do Campeonato Brasileiro - Série A, B, C ou D.
# Se for fornecido um numero mostra os jogos da rodada, com resultados.
# Com argumento -l lista os todos os clubes da série A e B.
# Se o argumento -l for seguido do nome do clube, lista todos os jogos já
# ocorridos do clube desde o começo do ano de qualquer campeonato.
#
# Nomenclatura:
#   PG  - Pontos Ganhos
#   J   - Jogos
#   V   - Vitórias
#   E   - Empates
#   D   - Derrotas
#   GP  - Gols Pró
#   GC  - Gols Contra
#   SG  - Saldo de Gols
#   (%) - Aproveitamento (pontos)
#
# Uso: zzbrasileirao [a|b|c] [numero rodada] ou zzbrasileirao -l [nome clube]
# Ex.: zzbrasileirao
#      zzbrasileirao a
#      zzbrasileirao b
#      zzbrasileirao c
#      zzbrasileirao 27
#      zzbrasileirao b 12
#      zzbrasileirao -l
#      zzbrasileirao -l portuguesa
#
# Autor: Alexandre Brodt Fernandes, www.xalexandre.com.br
# Desde: 2011-05-28
# Versão: 22
# Licença: GPL
# Requisitos: zzecho zzpad
# ----------------------------------------------------------------------------
zzbrasileirao ()
{
	zzzz -h brasileirao "$1" && return

	test $(date +%Y%m%d) -lt 20150509 && { zztool erro "Brasileirão 2015 só a partir de 9 de Maio."; return 1; }

	local rodada serie ano time1 time2 horario linha num_linha
	local url="http://esporte.uol.com.br/futebol"

	test $# -gt 2 && { zztool -e uso brasileirao; return 1; }

	serie='a'
	case $1 in
	a | b | c | d) serie="$1"; shift;;
	esac

	if test -n "$1"
	then
		zztool testa_numero "$1" && rodada="$1" || { zztool -e uso brasileirao; return 1; }
	fi

	test "$serie" = "a" && url="${url}/campeonatos/brasileirao/jogos" || url="${url}/campeonatos/serie-${serie}/jogos"

	if test -n "$rodada"
	then
		zztool testa_numero $rodada || { zztool -e uso brasileirao; return 1; }
		$ZZWWWDUMP "$url" |
		sed -n "/Rodada ${rodada}$/,/\(Rodada\|^ *$\)/p" |
		sed '
		/Rodada /d
		s/^ *//
		/[0-9]h[0-9]/{s/pós[ -]jogo//; s/\(h[0-9][0-9]\).*/\1/;}
		s/[A-Z][A-Z][A-Z]//
		s/ *__*//' |
		awk '
			NR % 3 == 1 { time1=$0 }
			NR % 3 == 2 { if ($NF ~ /^[0-9]$/) { reserva=$NF " "; $NF=""; } else reserva=""; time2=reserva $0 }
			NR % 3 == 0 { sub(/  *$/,""); print time1 "|" time2 "|" $0 }
		' |
		sed '/^ *$/d' |
		while read linha
		do
			time1=$(  echo $linha | cut -d"|" -f 1 )
			time2=$(  echo $linha | cut -d"|" -f 2 )
			horario=$(echo $linha | cut -d"|" -f 3 | sed 's/^ *//' )
			echo "$(zzpad -l 22 $time1) X $(zzpad -r 22 $time2) $horario"
		done
	else
		zztool eco $(echo "Série $serie" | tr 'abcd' 'ABCD')
		if test "$serie" = "c" -o "$serie" = "d"
		then
			$ZZWWWDUMP "$url" |
			sed -n "/Grupo \(A\|B\)/,/Rodada 1/{s/^/_/;s/.*Rodada.*//;s/°/./;p;}" |
			while read linha
			do
				if echo "$linha" | grep -E '[12]\.' >/dev/null
				then
					zzecho -f verde -l preto "$linha"
				elif echo "$linha" | grep -E '[34]\.' >/dev/null && test "$serie" = "c"
				then
					zzecho -f verde -l preto "$linha"
				elif echo "$linha" | grep -E '(9\.|10\.)' >/dev/null && test "$serie" = "c"
				then
					zzecho -f vermelho -l preto "$linha"
				else
					echo "$linha"
				fi
			done |
			tr -d _
			zzecho -f verde -l preto " Quartas de Final "
			test "$serie" = "c" && zzecho -f vermelho -l preto " Rebaixamento     "
		else
			num_linha=0
			$ZZWWWDUMP "$url" |
			sed -n "/^ *Classificação *PG/,/20°/{s/^/_/;s/°/./;p}" |
			while read linha
			do
				linha=$(echo "$linha" | awk '{pontos=sprintf("%3d", $NF);sub(/[0-9]+$/,pontos);print}')
				num_linha=$((num_linha + 1))
				case $num_linha in
					[2-5]) zzecho -f verde -l preto "$linha";;
					[6-9] | 1[0-3])
						if test "$serie" = "a"
						then
							zzecho -f ciano -l preto "$linha"
						else
							echo "$linha"
						fi
					;;
					1[89] | 2[01] ) zzecho -f vermelho -l preto "$linha";;
					*) echo "$linha";;
				esac
			done |
			tr -d _

				echo
				if test "$serie" = "a"
				then
					zzecho -f verde -l preto  " Libertadores  "
					zzecho -f ciano -l preto  " Sul-Americana "
				elif test "$serie" = "b"
				then
					zzecho -f verde -l preto  "   Série  A    "
				fi
				zzecho -f vermelho -l preto   " Rebaixamento  "

		fi
	fi
}

# ----------------------------------------------------------------------------
# zzbyte
# Conversão entre grandezas de bytes (mega, giga, tera, etc).
# Uso: zzbyte N [unidade-entrada] [unidade-saida]  # BKMGTPEZY
# Ex.: zzbyte 2048                    # Quanto é 2048 bytes?  -- 2K
#      zzbyte 2048 K                  # Quanto é 2048KB?      -- 2M
#      zzbyte 7 K M                   # Quantos megas em 7KB? -- 0.006M
#      zzbyte 7 G B                   # Quantos bytes em 7GB? -- 7516192768B
#      for u in b k m g t p e z y; do zzbyte 2 t $u; done
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-03-01
# Versão: 1
# Licença: GPL
# Requisitos: zzmaiusculas
# ----------------------------------------------------------------------------
zzbyte ()
{
	zzzz -h byte "$1" && return

	local i i_entrada i_saida diferenca operacao passo falta
	local unidades='BKMGTPEZY' # kilo, mega, giga, etc
	local n="$1"
	local entrada="${2:-B}"
	local saida="${3:-.}"

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso byte; return 1; }

	# Sejamos amigáveis com o usuário permitindo minúsculas também
	entrada=$(echo "$entrada" | zzmaiusculas)
	saida=$(  echo "$saida"   | zzmaiusculas)

	# Verificações básicas
	if ! zztool grep_var "$entrada" "$unidades"
	then
		zztool erro "Unidade inválida '$entrada'"
		return 1
	fi
	if ! zztool grep_var "$saida" ".$unidades"
	then
		zztool erro "Unidade inválida '$saida'"
		return 1
	fi
	zztool -e testa_numero "$n" || return 1

	# Extrai os números (índices) das unidades de entrada e saída
	i_entrada=$(zztool index_var "$entrada" "$unidades")
	i_saida=$(  zztool index_var "$saida"   "$unidades")

	# Sem $3, a unidade de saída será otimizada
	test $i_saida -eq 0 && i_saida=15

	# A diferença entre as unidades guiará os cálculos
	diferenca=$((i_saida - i_entrada))
	if test "$diferenca" -lt 0
	then
		operacao='*'
		passo='-'
	else
		operacao='/'
		passo='+'
	fi

	i="$i_entrada"
	while test "$i" -ne "$i_saida"
	do
		# Saída automática (sem $3)
		# Chegamos em um número menor que 1024, hora de sair
		test "$n" -lt 1024 -a "$i_saida" -eq 15 && break

		# Não ultrapasse a unidade máxima (Yota)
		test "$i" -eq ${#unidades} -a "$passo" = '+' && break

		# 0 < n < 1024 para unidade crescente, por exemplo: 1 B K
		# É hora de dividir com float e colocar zeros à esquerda
		if test "$n" -gt 0 -a "$n" -lt 1024 -a "$passo" = '+'
		then
			# Quantos dígitos ainda faltam?
			falta=$(( (i_saida - i - 1) * 3))

			# Pulamos direto para a unidade final
			i="$i_saida"

			# Cálculo preciso usando o bc (Retorna algo como .090)
			n=$(echo "scale=3; $n / 1024" | bc)
			test "$n" = '0' && break # 1 / 1024 = 0

			# Completa os zeros que faltam
			test "$falta" -gt 0 && n=$(printf "%0.${falta}f%s" 0 "${n#.}")

			# Coloca o zero na frente, caso necessário
			test "${n#.}" != "$n" && n="0$n"

			break
		fi

		# Terminadas as exceções, este é o processo normal
		# Aumenta/diminui a unidade e divide/multiplica por 1024
		i=$(($i $passo 1))
		n=$(($n $operacao 1024))
	done

	# Mostra o resultado
	echo "$n"$(echo "$unidades" | cut -c "$i")
}

# ----------------------------------------------------------------------------
# zzcalcula
# Calculadora.
# Wrapper para o comando bc, que funciona no formato brasileiro: 1.234,56.
# Obs.: Números fracionados podem vir com vírgulas ou pontos: 1,5 ou 1.5.
# Use a opção --soma para somar uma lista de números vindos da STDIN.
#
# Uso: zzcalcula operação|--soma
# Ex.: zzcalcula 2,20 + 3.30          # vírgulas ou pontos, tanto faz
#      zzcalcula '2^2*(4-1)'          # 2 ao quadrado vezes 4 menos 1
#      echo 2 + 2 | zzcalcula         # lendo da entrada padrão (STDIN)
#      zzseq 5 | zzcalcula --soma     # soma números da STDIN
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-04
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzcalcula ()
{
	zzzz -h calcula "$1" && return

	local soma

	# Opção de linha de comando
	if test "$1" = '--soma'
	then
		soma=1
		shift
	fi

	# A opção --soma só lê dados da STDIN, não deve ter argumentos
	if test -n "$soma" -a $# -gt 0
	then
		zztool -e uso calcula
		return 1
	fi

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Limpeza nos dados para chegarem bem no bc
	sed '
		# Espaços só atrapalham (tab+espaço)
		s/[	 ]//g

		# Remove separador de milhares
		s/\.\([0-9][0-9][0-9]\)/\1/g
		' |

	# Temos dados multilinha para serem somados?
	if test -n "$soma"
	then
		sed '
			# Remove linhas em branco
			/^$/d

			# Números sem sinal são positivos
			s/^[0-9]/+&/

			# Se o primeiro da lista tiver sinal + dá erro no bc
			1 s/^+//' |
		# Junta as linhas num única tripa, exemplo: 5+7-3+1-2
		#tr -d '\n'
		paste -s -d ' ' - | sed 's/ //g'
	else
		cat -
	fi |

	# O resultado deve ter somente duas casas decimais
	sed 's/^/scale=2;/' |

	# Entrada de números com vírgulas ou pontos, saída sempre com vírgulas
	sed y/,/./ | bc | sed y/./,/ |

	# Adiciona separador de milhares
	sed '
		s/\([0-9]\)\([0-9][0-9][0-9]\)$/\1.\2/

		:loop
		s/\([0-9]\)\([0-9][0-9][0-9][,.]\)/\1.\2/
		t loop
	'
}

# ----------------------------------------------------------------------------
# zzcalculaip
# Calcula os endereços de rede e broadcast à partir do IP e máscara da rede.
# Obs.: Se não especificada, será usada a máscara padrão (RFC 1918) ou 24.
# Uso: zzcalculaip ip [netmask]
# Ex.: zzcalculaip 127.0.0.1 24
#      zzcalculaip 10.0.0.0/8
#      zzcalculaip 192.168.10.0 255.255.255.240
#      zzcalculaip 10.10.10.0
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2005-09-01
# Versão: 2
# Licença: GPL
# Requisitos: zzconverte
# ----------------------------------------------------------------------------
zzcalculaip ()
{
	zzzz -h calculaip "$1" && return

	local endereco mascara rede broadcast
	local mascara_binario mascara_decimal mascara_ip
	local i ip1 ip2 ip3 ip4 nm1 nm2 nm3 nm4 componente

	# Verificação dos parâmetros
	test $# -eq 0 -o $# -gt 2 && { zztool -e uso calculaip; return 1; }

	# Obtém a máscara da rede (netmask)
	if zztool grep_var / "$1"
	then
		endereco=${1%/*}
		mascara="${1#*/}"
	else
		endereco=$1

		# Use a máscara informada pelo usuário ou a máscara padrão
		if test $# -gt 1
		then
			mascara=$2
		else
			# A máscara padrão é determinada pela RFC 1918 (valeu jonerworm)
			# http://tools.ietf.org/html/rfc1918
			#
			#   10.0.0.0    - 10.255.255.255  (10/8 prefix)
			#   172.16.0.0  - 172.31.255.255  (172.16/12 prefix)
			#   192.168.0.0 - 192.168.255.255 (192.168/16 prefix)
			#
			case "$1" in
				10.*        ) mascara=8  ;;
				172.1[6-9].*) mascara=12 ;;
				172.2?.*    ) mascara=12 ;;
				172.3[01].* ) mascara=12 ;;
				192.168.*   ) mascara=16 ;;
				127.*       ) mascara=8  ;;
				*           ) mascara=24 ;;
			esac
		fi
	fi

	# Verificações básicas
	if ! (
		zztool testa_ip $mascara || (
		zztool testa_numero $mascara && test $mascara -le 32))
	then
		zztool erro "Máscara inválida: $mascara"
		return 1
	fi
	zztool -e testa_ip $endereco || return 1

	# Guarda os componentes da máscara em $1, $2, ...
	# Ou é um ou quatro componentes: 24 ou 255.255.255.0
	set - $(echo $mascara | tr . ' ')

	# Máscara no formato NN
	if test $# -eq 1
	then
		# Converte de decimal para binário
		# Coloca N números 1 grudados '1111111' (N=$1)
		# e completa com zeros à direita até 32, com pontos:
		# $1=12 vira 11111111.11110000.00000000.00000000
		mascara=$(printf "%$1s" 1 | tr ' ' 1)
		mascara=$(
			printf '%-32s' $mascara |
			tr ' ' 0 |
			sed 's/./&./24 ; s/./&./16 ; s/./&./8'
		)
	fi

	# Conversão de decimal para binário nos componentes do IP e netmask
	for i in 1 2 3 4
	do
		componente=$(echo $endereco | cut -d'.' -f $i)
		eval ip$i=$(printf '%08d' $(zzconverte db $componente))

		componente=$(echo $mascara | cut -d'.' -f $i)
		if test -n "$2"
		then
			eval nm$i=$(printf '%08d' $(zzconverte db $componente))
		else
			eval nm$i=$componente
		fi
	done

	# Uma verificação na máscara depois das conversões
	mascara_binario=$nm1$nm2$nm3$nm4
	if ! (
		zztool testa_binario $mascara_binario &&
		test ${#mascara_binario} -eq 32)
	then
		zztool erro 'Máscara inválida'
		return 1
	fi

	mascara_decimal=$(echo $mascara_binario | tr -d 0)
	mascara_decimal=${#mascara_decimal}
	mascara_ip=$((2#$nm1)).$((2#$nm2)).$((2#$nm3)).$((2#$nm4))

	echo "End. IP  : $endereco"
	echo "Mascara  : $mascara_ip = $mascara_decimal"

	rede=$(( ((2#$ip1$ip2$ip3$ip4)) & ((2#$nm1$nm2$nm3$nm4)) ))
	i=$(echo $nm1$nm2$nm3$nm4 | tr 01 10)
	broadcast=$(($rede | ((2#$i)) ))

	# Cálculo do endereço de rede
	endereco=""
	for i in 1 2 3 4
	do
		ip1=$((rede & 255))
		rede=$((rede >> 8))
		endereco="$ip1.$endereco"
	done

	echo "Rede     : ${endereco%.} / $mascara_decimal"

	# Cálculo do endereço de broadcast
	endereco=''
	for i in 1 2 3 4
	do
		ip1=$((broadcast & 255))
		broadcast=$((broadcast >> 8))
		endereco="$ip1.$endereco"
	done
	echo "Broadcast: ${endereco%.}"
}

# ----------------------------------------------------------------------------
# zzcapitalize
# Altera Um Texto Para Deixar Todas As Iniciais De Palavras Em Maiúsculas.
# Use a opção -1 para converter somente a primeira letra de cada linha.
# Use a opção -w para adicionar caracteres de palavra (Padrão: A-Za-z0-9áéí…)
#
# Uso: zzcapitalize [texto]
# Ex.: zzcapitalize root                             # Root
#      zzcapitalize kung fu panda                    # Kung Fu Panda
#      zzcapitalize -1 kung fu panda                 # Kung fu panda
#      zzcapitalize quero-quero                      # Quero-Quero
#      zzcapitalize água ênfase último               # Água Ênfase Último
#      echo eu_uso_camel_case | zzcapitalize         # Eu_Uso_Camel_Case
#      echo "i don't care" | zzcapitalize            # I Don'T Care
#      echo "i don't care" | zzcapitalize -w \'      # I Don't Care
#      cat arquivo.txt | zzcapitalize
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-21
# Versão: 5
# Licença: GPL
# Requisitos: zzminusculas
# ----------------------------------------------------------------------------
zzcapitalize ()
{
	zzzz -h capitalize "$1" && return

	local primeira todas filtros extra x
	local acentuadas='àáâãäåèéêëìíîïòóôõöùúûüçñÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ'
	local palavra='A-Za-z0-9'
	local soh_primeira=0

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-1)
				soh_primeira=1
				shift
			;;
			-w)
				# Escapa a " pra não dar problema no sed adiante
				extra=$(echo "$2" | sed 's/"/\\"/g')
				shift
				shift
			;;
			*) break ;;
		esac
	done

	# Aqui está a lista de caracteres que compõem uma palavra.
	# Estes caracteres *não* disparam a capitalização da letra seguinte.
	# Esta regex é usada na variável $todas, a seguir.
	x="[^$palavra$acentuadas$extra]"

	# Filtro que converte pra maiúsculas somente a primeira letra da linha
	primeira='
		s_^a_A_ ; s_^n_N_ ; s_^à_À_ ; s_^ï_Ï_ ;
		s_^b_B_ ; s_^o_O_ ; s_^á_Á_ ; s_^ò_Ò_ ;
		s_^c_C_ ; s_^p_P_ ; s_^â_Â_ ; s_^ó_Ó_ ;
		s_^d_D_ ; s_^q_Q_ ; s_^ã_Ã_ ; s_^ô_Ô_ ;
		s_^e_E_ ; s_^r_R_ ; s_^ä_Ä_ ; s_^õ_Õ_ ;
		s_^f_F_ ; s_^s_S_ ; s_^å_Å_ ; s_^ö_Ö_ ;
		s_^g_G_ ; s_^t_T_ ; s_^è_È_ ; s_^ù_Ù_ ;
		s_^h_H_ ; s_^u_U_ ; s_^é_É_ ; s_^ú_Ú_ ;
		s_^i_I_ ; s_^v_V_ ; s_^ê_Ê_ ; s_^û_Û_ ;
		s_^j_J_ ; s_^w_W_ ; s_^ë_Ë_ ; s_^ü_Ü_ ;
		s_^k_K_ ; s_^x_X_ ; s_^ì_Ì_ ; s_^ç_Ç_ ;
		s_^l_L_ ; s_^y_Y_ ; s_^í_Í_ ; s_^ñ_Ñ_ ;
		s_^m_M_ ; s_^z_Z_ ; s_^î_Î_ ;
	'
	# Filtro que converte pra maiúsculas a primeira letra de cada palavra.
	# Note que o delimitador usado no s///g foi o espaço em branco.
	todas="
		s \($x\)a \1A g ; s \($x\)n \1N g ; s \($x\)à \1À g ; s \($x\)ï \1Ï g ;
		s \($x\)b \1B g ; s \($x\)o \1O g ; s \($x\)á \1Á g ; s \($x\)ò \1Ò g ;
		s \($x\)c \1C g ; s \($x\)p \1P g ; s \($x\)â \1Â g ; s \($x\)ó \1Ó g ;
		s \($x\)d \1D g ; s \($x\)q \1Q g ; s \($x\)ã \1Ã g ; s \($x\)ô \1Ô g ;
		s \($x\)e \1E g ; s \($x\)r \1R g ; s \($x\)ä \1Ä g ; s \($x\)õ \1Õ g ;
		s \($x\)f \1F g ; s \($x\)s \1S g ; s \($x\)å \1Å g ; s \($x\)ö \1Ö g ;
		s \($x\)g \1G g ; s \($x\)t \1T g ; s \($x\)è \1È g ; s \($x\)ù \1Ù g ;
		s \($x\)h \1H g ; s \($x\)u \1U g ; s \($x\)é \1É g ; s \($x\)ú \1Ú g ;
		s \($x\)i \1I g ; s \($x\)v \1V g ; s \($x\)ê \1Ê g ; s \($x\)û \1Û g ;
		s \($x\)j \1J g ; s \($x\)w \1W g ; s \($x\)ë \1Ë g ; s \($x\)ü \1Ü g ;
		s \($x\)k \1K g ; s \($x\)x \1X g ; s \($x\)ì \1Ì g ; s \($x\)ç \1Ç g ;
		s \($x\)l \1L g ; s \($x\)y \1Y g ; s \($x\)í \1Í g ; s \($x\)ñ \1Ñ g ;
		s \($x\)m \1M g ; s \($x\)z \1Z g ; s \($x\)î \1Î g ;
	"

	# Aplicando a opção -1, caso informada
	test $soh_primeira -eq 1 && todas=''

	filtros="$primeira $todas"

	# Texto via STDIN ou argumentos
	# Primeiro converte tudo pra minúsculas, depois capitaliza as iniciais
	zztool multi_stdin "$@" | zzminusculas | sed "$filtros"
}

# ----------------------------------------------------------------------------
# zzcaracoroa
# Exibe 'cara' ou 'coroa' aleatoriamente.
# Uso: zzcaracoroa
# Ex.: zzcaracoroa
#
# Autor: Angelito M. Goulart, www.angelitomg.com
# Desde: 2012-12-06
# Versão: 1
# Licença: GPL
# Requisitos: zzaleatorio
# ----------------------------------------------------------------------------
zzcaracoroa ()
{

	# Comando especial das funcoes ZZ
	zzzz -h caracoroa "$1" && return

	# Gera um numero aleatorio entre 0 e 1. 0 -> Cara, 1 -> Coroa
	local NUM="$(zzaleatorio 1)"

	# Verifica o numero gerado e exibe o resultado
	if test $NUM -eq 0
	then
		echo "Cara"
	else
		echo "Coroa"
	fi

}

# ----------------------------------------------------------------------------
# zzcarnaval
# Mostra a data da terça-feira de Carnaval para qualquer ano.
# Obs.: Se o ano não for informado, usa o atual.
# Regra: 47 dias antes do domingo de Páscoa.
# Uso: zzcarnaval [ano]
# Ex.: zzcarnaval
#      zzcarnaval 1999
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-23
# Versão: 1
# Licença: GPL
# Requisitos: zzdata zzpascoa
# Tags: data
# ----------------------------------------------------------------------------
zzcarnaval ()
{
	zzzz -h carnaval "$1" && return

	local ano="$1"

	# Se o ano não for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Validação
	zztool -e testa_ano $ano || return 1

	# Ah, como é fácil quando se tem as ferramentas certas ;)
	zzdata $(zzpascoa $ano) - 47
}

# ----------------------------------------------------------------------------
# zzcbn
# http://cbn.globoradio.com.br
# Busca e toca os últimos comentários dos comentaristas da radio CBN.
# Uso: zzcbn [--audio] [num_audio] -c COMENTARISTA [-d data] ou  zzcbn --lista
# Ex.: zzcbn -c max-gehringer -d ontem
#      zzcbn -c juca-kfouri -d 13/05/09
#      zzcbn -c miriam
#      zzcbn --audio 2 -c  mario-sergio-cortella
#
# Autor: Rafael Machado Casali <rmcasali (a) gmail com>
# Desde: 2009-04-16
# Versão: 6
# Licença: GPL
# Requisitos: zzecho zzplay zzcapitalize zzdatafmt zzxml
# ----------------------------------------------------------------------------
zzcbn ()
{
	zzzz -h cbn "$1" && return

	local cache=$(zztool cache cbn)
	local url='http://cbn.globoradio.globo.com'
	local audio=0
	local num_audio=1
	local nome comentarista link fonte rss podcast ordem data_coment data_audio

	#Verificacao dos parâmetros
	test -n "$1" || { zztool -e uso cbn; return 1; }

	# Cache com parametros para nomes e links
	if ! test -s "$cache" || test $(tail -n 1 "$cache") != $(date +%F)
	then
		$ZZWWWHTML "$url" |
		sed -n '/lista-menu-item comentaristas/,/lista-menu-item boletins/p' |
		zzxml --tag a |
		sed -n '/http:..cbn.globoradio.globo.com.comentaristas./{s/.*="//;s/">//;/-e-/d;p;}' |
		awk -F "/" '{url = $0;gsub(/-/," ", $6); gsub(/\.htm/,"", $6);printf "%s;%s;%s\n", $6, $5, url }'|
		while read linha
		do
			nome=$(echo "$linha" | cut -d ";" -f 1 | zzcapitalize )
			comentarista=$(echo "$linha" | cut -d ";" -f 2 )
			link=$(echo "$linha" | cut -d ";" -f 3 )
			fonte=$($ZZWWWHTML "$link")
			rss=$(
				echo "$fonte" |
				grep 'cbn/rss' |
				sed 's/.*href="//;s/".*//'
			)
			podcast=$(
				echo "$fonte" |
				grep 'cbn/podcast' |
				sed 's/.*href="//;s/".*//'
			)
			echo "$nome | $comentarista | $rss | $podcast"
		done > "$cache"
		zzdatafmt --iso hoje >> "$cache"
	fi

	# Listagem dos comentaristas
	if test "$1" = "--lista"
	then
		sed '$d' "$cache" | awk -F " [|] " '{print $2 "\t => " $1}' | expand -t 28
		return
	fi

# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-c)
				comentarista="$2"
				shift
				shift
			;;
			-d)
				data_coment=$(zzdatafmt --en -f "SSS, DD MMM AAAA" "$2")
				data_audio=$(zzdatafmt -f "_AAMMDD" "$2")
				shift
				shift
			;;
			--audio)
				audio=1
				shift
				if test -n "$1"
				then
					if zztool testa_numero "$1"
					then
						num_audio="$1"
						shift
					fi
				fi
			;;
			*)
				zztool erro "Opção inválida!!"
				return 1
			;;
		esac
	done

	# Audio ou comentários feitos pelo comentarista selecionado
	if test "$audio" -eq 1
	then
		podcast=$(
			sed -n "/$comentarista/p" "$cache" |
			cut -d'|' -f 4| tr -d ' '
		)
		if test -n "$podcast"
		then
			podcast=$($ZZWWWHTML "$podcast" | grep 'media:content')
			zztool eco "Áudios diponíveis:"
			echo "$podcast" |
			sed 's/.*_//; s/\.mp3.*//; s/\(..\)\(..\)\(..\)/\3\/\2\/20\1/' |
			awk '{ print NR ".", $0}'

			podcast=$(
				echo "$podcast" |
				sed -n "${num_audio}p" |
				sed 's|.*audio=|http://download.sgr.globo.com/sgr-mp3/cbn/|' |
				sed 's/\.mp3.*/.mp3/'
			)

			test -n "$podcast" && zzplay "$podcast" mplayer || zzecho -l vermelho "Sem comentários em áudio."
		else
			zzecho -l vermelho "Sem comentários em áudio."
		fi

	else
		rss=$(
			sed -n "/$comentarista/p" "$cache" |
			cut -d'|' -f 3 | tr -d ' '
		)

		if test -n "$rss"
		then
			$ZZWWWHTML "$rss" |
			zzxml --tag item |
			zzxml --tag title --tag description --tag pubDate |
			sed 's/<title>/-----/' |
			zzxml --untag |
			sed '/^$/d; s/ [0-2][0-9]:.*//' |
			if test -n "$data_coment"
			then
				grep -B 3 "$data_coment"
			else
				cat -
			fi
		else
			zzecho -l vermelho "Sem comentários."
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzcep
# http://www.achecep.com.br
# Busca o CEP de qualquer rua de qualquer cidade do país ou vice-versa.
# Pode-se fornecer apenas o CEP, ou o estado com endereço.
# Uso: zzcep <estado endereço | CEP>
# Ex.: zzcep SP Rua Santa Ifigênia
#      zzcep 01310-000
#
# Autor: Aurélio Marinho Jargas, www.aurelio.net
# Desde: 2000-11-08
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzcep ()
{
	zzzz -h cep "$1" && return

	local r e query
	local url='http://www.achecep.com.br'

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso cep; return 1; }

	# Testando se parametro é o CEP
	echo "$1" | tr -d '-' | grep -E '[0-9]{8}' > /dev/null
	if test $? -eq 0
	then
		query=$(echo "q=$1" | tr -d '-')
	fi

	# Conferindo se é sigla do Estado e endereço
	if test -z $query && test -n "$2"
	then
		echo $1 | grep -E '[a-zA-Z]{2}' > /dev/null
		if test $? -eq 0
		then
			e="$1"
			shift
			r=$(echo "$*"| sed "$ZZSEDURL")
			query="uf=${e}&q=$r"
		else
			zztool -e uso cep; return 1;
		fi
	fi

	# Testando se formou a query string
	test -n "$query" || { zztool -e uso cep; return 1; }

	echo "$query" | $ZZWWWPOST "$url" |
	sed -n '/^[[:blank:]]*CEP/,/^[[:blank:]]*$/p'| sed 's/^ *//g;$d'
}

# ----------------------------------------------------------------------------
# zzchavepgp
# http://pgp.mit.edu
# Busca a identificação da chave PGP, fornecido o nome ou e-mail da pessoa.
# Uso: zzchavepgp nome|e-mail
# Ex.: zzchavepgp Carlos Oliveira da Silva
#      zzchavepgp carlos@dominio.com.br
#
# Autor: Rodrigo Missiaggia
# Desde: 2001-10-01
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzchavepgp ()
{
	zzzz -h chavepgp "$1" && return

	local url='http://pgp.mit.edu:11371'
	local padrao=$(echo $* | sed "$ZZSEDURL")

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso chavepgp; return 1; }

	$ZZWWWDUMP "http://pgp.mit.edu:11371/pks/lookup?search=$padrao&op=index" |
		sed 1,2d |
		sed '
			# Remove linhas em branco
			/^$/ d
			# Remove linhas ____________________
			/^ *___*$/ d'
}

# ----------------------------------------------------------------------------
# zzchecamd5
# Checa o md5sum de arquivos baixados da net.
# Nota: A função checa o arquivo no diretório corrente (./)
# Uso: zzchecamd5 arquivo md5sum
# Ex.: zzchecamd5 ./ubuntu-8.10.iso f9e0494e91abb2de4929ef6e957f7753
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-10-31
# Versão: 3
# Licença: GPLv2
# Requisitos: zzmd5
# ----------------------------------------------------------------------------
zzchecamd5 ()
{

	# Variaveis locais
	local arquivo valor_md5 md5_site

	# Help da funcao zzchecamd5
	zzzz -h checamd5 "$1" && return

	# Faltou argumento mostrar como se usa a zzchecamd5
	if test $# != "2";then
		zztool -e uso checamd5
		return 1
	fi

	# Foi passado o caminho errado do arquivo
	if test ! -f $1 ;then
		zztool erro "Nao foi encontrado: $1"
		return 1
	fi

	# Setando variaveis
	arquivo=./$1
	md5_site=$2
	valor_md5=$(cat "$arquivo" | zzmd5)

	# Verifica se o arquivo nao foi corrompido
	if test "$md5_site" = "$valor_md5"; then
		echo "Imagem OK"
	else
		zztool erro "O md5sum nao confere!!"
		return 1
	fi
}

# ----------------------------------------------------------------------------
# zzcidade
# http://pt.wikipedia.org/wiki/Lista_de_munic%C3%ADpios_do_Brasil
# Lista completa com todas as 5.500+ cidades do Brasil, com busca.
# Obs.: Sem argumentos, mostra uma cidade aleatória.
#
# Uso: zzcidade [palavra|regex]
# Ex.: zzcidade              # mostra uma cidade qualquer
#      zzcidade campos       # mostra as cidades com "Campos" no nome
#      zzcidade '(SE)'       # mostra todas as cidades de Sergipe
#      zzcidade ^X           # mostra as cidades que começam com X
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-21
# Versão: 3
# Licença: GPL
# Requisitos: zzlinha
# ----------------------------------------------------------------------------
zzcidade ()
{
	zzzz -h cidade "$1" && return

	local url='http://pt.wikipedia.org/wiki/Lista_de_munic%C3%ADpios_do_Brasil'
	local cache=$(zztool cache cidade)
	local padrao="$*"

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		# Exemplo:^     * Aracaju (SE)
		$ZZWWWDUMP "$url" | sed -n 's/^  *\* \(.* (..)\)$/\1/p' > "$cache"
	fi

	if test -z "$padrao"
	then
		# Mostra uma cidade qualquer
		zzlinha -t . "$cache"
	else
		# Faz uma busca nas cidades
		grep -h -i -- "$padrao" "$cache"
	fi
}

# ----------------------------------------------------------------------------
# zzcinclude
# Acha as funções de uma biblioteca da linguagem C (arquivos .h).
# Obs.: O diretório padrão de procura é o /usr/include.
# Uso: zzcinclude nome-biblioteca
# Ex.: zzcinclude stdio
#      zzcinclude /minha/rota/alternativa/stdio.h
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-12-15
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzcinclude ()
{
	zzzz -h cinclude "$1" && return

	local arquivo="$1"

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso cinclude; return 1; }

	# Se não começar com / (caminho relativo), coloca path padrão
	test "${arquivo#/}" = "$arquivo" && arquivo="/usr/include/$arquivo.h"

	# Verifica se o arquivo existe
	zztool arquivo_legivel "$arquivo" || return

	# Saída ordenada, com um Sed mágico para limpar a saída do cpp
	cpp -E "$arquivo" |
		sed '
			/^ *$/d
			/^# /d
			/^typedef/d
			/^[^a-z]/d
			s/ *(.*//
			s/.* \*\{0,1\}//' |
		sort
}

# ----------------------------------------------------------------------------
# zzcinemais
# http://www.cinemais.com.br
# Busca horários das sessões dos filmes no site do Cinemais.
# Cidades disponíveis:
#   Uberaba                -   9
#   Patos de Minas         -  11
#   Guaratingueta          -  21
#   Anapolis               -  32
#   Resende                -  33
#   Monte Carlos           -  34
#   Juiz de Fora           -  35
#
# Uso: zzcinemais [cidade]
# Ex.: zzcinemais milenium
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-08-25
# Versão: 7
# Licença: GPLv2
# Requisitos: zzecho zzsemacento zzminusculas zztrim zzutf8
# ----------------------------------------------------------------------------
zzcinemais ()
{
	zzzz -h cinemais "$1" && return

	test -n "$1" || { zztool -e uso cinemais; return 1; }

	local cidade cidades codigo

	cidade=$(echo "$*" | zzsemacento | zzminusculas | zztrim | sed 's/ /_/g')

	cidades="9:uberaba:Uberaba  - MG
	11:patos_de_minas:Patos de Minas - MG
	21:guaratingueta:Guaratinguetá - SP
	32:anapolis:Anápolis - GO
	33:resende:Resende - RJ
	34:monte_carlos:Montes Claros - MG
	35:juiz_de_fora:Juiz de Fora - MG"

	codigo=$(echo "$cidades" | grep "${cidade}:" 2>/dev/null | cut -f 1 -d ":")

	# Necessário fazer uso do argumento -useragent="Mozilla/5.0", pois o site se recusa a funcionar com lynx, links, curl e w3m.
	# Uma ridícula implementação do site :( ( Desculpe pelo protesto! )
	if test -n "$codigo"
	then
		zzecho -N -l ciano $(echo "$cidades" | grep "${cidade}:" | cut -f 3 -d ":")
		$ZZWWWHTML -useragent="Mozilla/5.0" "http://www.cinemais.com.br/programacao/cinema.php?cc=$codigo" 2>/dev/null |
		zzutf8 |
		grep -E '(<td><a href|<td><small|[0-9] a [0-9])' |
		zztrim |
		sed 's/<[^>]*>//g;s/Programa.* - //' |
		awk '{print}; NR%2==1 {print ""}' | sed '$d'
	fi
}

# ----------------------------------------------------------------------------
# zzcinemark
# http://cinemark.com.br/programacao
# Exibe a programação dos cinemas Cinemark de sua cidade.
# Sem argumento lista todas as cidades e todas as salas mostrando os códigos.
# Com o cógigo da cidade lista as salas dessa cidade.
# Com o código das salas mostra os filmes do dia.
# Um segundo argumento caso pode ser a data, para listar os filmes desse dia.
# As datas devem ser futuras e conforme a padrão zzdata
#
# Uso: zzcinemark [codigo_cidade | codigo_cinema] [data]
# Ex.: zzcinemark 1            # Lista os cinemas de São Paulo
#      zzcinemark 662 sab      # Filmes de Raposo Shopping no sábado
#
# Autor: Thiago Moura Witt <thiago.witt (a) gmail.com> <@thiagowitt>
# Desde: 2011-07-05
# Versão: 2
# Licença: GPL
# Requisitos: zzdatafmt zzxml zzunescape zztrim zzcolunar
# ----------------------------------------------------------------------------
zzcinemark ()
{
	zzzz -h cinemark "$1" && return

	local cache=$(zztool cache cinemark)
	local url="http://cinemark.com.br/programacao"
	local cidade codigo dia

	if test "$1" = '--atualiza'
	then
		zztool atualiza cinemark
		shift
	fi

	if ! test -s "$cache"
	then
		# Lista de Cidades
		$ZZWWWHTML "$url" |
		grep '_Cidades\[' |
		sed "s/.*'\([0-9]\{1,2\}\)'/ \1/;s/] = '/:/;s/'.*//" > $cache

		# Lista de Salas por cidade
		$ZZWWWHTML "$url" |
		grep '_Cinemas\[' |
		sed "s/.*'\([0-9]\{1,2\}\)'/\1/;s/');//;s/].*( '/:/;s/'[^']*'/:/g" >> $cache
	fi

	if test $# = 0
	then
		# mostra opções
		echo "                                   Cidades e Salas disponíveis                                   "
		echo "================================================================================================="
		cat $cache |
		sed 's/^ /0/' |
		sort -n |
		awk -F ":" '
			NF==2 {printf "\n%s (Cod: %02d)\n", $2, $1}
			NF>2 {
				for (i=2;i<=NF;i+=2) {
					printf " %4s) %s\n", $i, $(i+1)
				}
			}
		' | zzcolunar 2
		return 0
	elif zztool testa_numero $1 && test $1 -lt 100
	then
		grep "^ *$1:" $cache |
		sort -n |
		awk -F ":" '
			NF==2 {printf "%s (Cod: %02d)\n", $2, $1}
			NF>2 {
				for (i=2;i<=NF;i+=2) {
					printf " %4s) %s\n", $i, $(i+1)
				}
			}
		'
		return 0
	elif zztool testa_numero $1 && test $1 -ge 100
	then
		if test -n "$2"
		then
			case "$2" in
					# apelidos
					hoje | amanh[ãa])
						dia=$(zzdatafmt -f "DD-MM-AAAA" $2)
					;;
					# semana (curto)
					dom | seg | ter | qua | qui | sex | sab)
						dia=$(zzdatafmt -f "DD-MM-AAAA" $2)
					;;
					# semana (longo)
					domingo | segunda | ter[cç]a | quarta | quinta | sexta | s[aá]bado)
						dia=$(zzdatafmt -f "DD-MM-AAAA" $2)
					;;
			esac

			if test -z "$dia"
			then
				if zztool testa_data $2
				then
					dia=$(zzdatafmt -f "DD-MM-AAAA" $2)
				else
					dia=$(zzdatafmt -f "DD-MM-AAAA" hoje)
				fi
			fi
		else
			dia=$(zzdatafmt -f "DD-MM-AAAA" hoje)
		fi

		zztool eco $(grep ":$1:" $cache | sed "s/.*:$1://;s/:.*//")

		$ZZWWWHTML "${url}/cinema/$1" |
		sed -n '/class="date-tab-content"/,/_Cidades/p' |
		sed -n '/class="date-tab-content"/p;/<h4>/p;/[0-9]h[0-9]/p;/images\/\(exibicao\|censura\)\//p' |
		awk '{
			if ($0 ~ /images/) {reserva=$0 }
			else if ($0 ~ /date-tab-content/) {print; print ""}
			else if ($0 ~ /[0-9]h[0-9]/){ print reserva; print; print "" }
			else print
			}' |
		sed '/date-/{s/.*date-\(....\)-\(..\)-\(..\).*/Dia: \3-\2-\1/}' |
		sed '/class="exibicao"/d;s/<[^>]*alt="\([A-Za-z0-9 ]*\)">/\1  /g' |
		zztrim |
		sed -n "/${dia}/,/Dia: /p" | sed '$d' |
		zzxml --untag | zzunescape --html
	fi
}

# ----------------------------------------------------------------------------
# zzcinepolis
# http://www.cinepolis.com.br/
# Exibe a programação dos cinemas Cinepólis de sua cidade.
# Se não for passado nenhum parâmetro, são listadas as cidades e cinemas.
# Uso: zzcinepolis [cidade | codigo_cinema]
# Ex.: zzcinepolis barueri
#      zzcinepolis 36
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2015-02-22
# Versão: 1
# Licença: GPL
# Requisitos: zzminusculas zzsemacento zzjuntalinhas zzcolunar zztrim zzecho zzutf8
# ----------------------------------------------------------------------------
zzcinepolis ()
{
	zzzz -h cinepolis "$1" && return

	local cache=$(zztool cache cinepolis)
	local url='http://www.cinepolis.com.br/programacao'
	local cidade codigo codigos

	if test "$1" = '--atualiza'
	then
		zztool atualiza cinepolis
		shift
	fi

	# Necessário fazer uso do argumento -useragent="Mozilla/5.0", pois o site se recusa a funcionar com lynx, links, curl e w3m.
	# Uma ridícula implementação do site :( ( Desculpe pelo protesto, de novo! )
	if ! test -s "$cache"
	then
		$ZZWWWHTML -useragent="Mozilla/5.0" "$url" 2>/dev/null |
		grep -E '(class="amarelo"|\?cc=)' |
		zzutf8 |
		sed '/img /d;/>Estreias</d;s/.*"amarelo">//;s/.*cc=/ /;s/".*">/) /' |
		sed 's/<[^>]*>//' |
		sed 's/^\([A-Z]\)\(.*\)$/\
\1\2:/' > $cache
	fi

	if test $# = 0; then
		# mostra opções
		zztool eco "Cidades e cinemas disponíveis:"
		zzcolunar 2 $cache
		return 0
	fi

	cidade=$(echo "$*" | zzsemacento | zzminusculas | zztrim | sed 's/ 0/ /g;s/  */_/g')

	codigo=$(
		cat "$cache" |
		while read linha
		do
			echo "$linha" | grep ':$' >/dev/null &&
			echo "$linha" | zzminusculas | zzsemacento | tr ' ' '_' ||
			echo "$linha" | sed 's/).*//'
		done
		)

	# passou código
	if zztool testa_numero ${cidade}; then
		# testa se código é válido
		echo "$codigo" | grep "$cidade" >/dev/null && codigos="$cidade"
	else
		# passou nome da cidade
		codigos=$(
			echo "$codigo" |
			sed -n "/${cidade}.*:$/,/^$/{/:/d;p;}" |
			zzjuntalinhas
			)
	fi

	# se não recebeu cidade ou código válido, sai
	test -z "$codigos" && { zztool -e uso cinepolis; return 1; }

	for codigo in $codigos
	do
		zzecho -N -l ciano $(grep " ${codigo})" $cache | sed 's/.*) //')
		$ZZWWWDUMP -useragent="Mozilla/5.0" "${url}/cinema.php?cc=${codigo}" 2>/dev/null |
		sed -n '/  [0-9]\{1,2\}  /p;/[0-9]h[0-9]/p' |
		sed 's/\(.*h[0-9][0-9]\).*/\1/;s/\^.//g;/OBS\.: /d' |
		sed 's/^ *\([0-9]\)* *   /\1 /' |
		awk '$1 ~ /[0-9]{1,}/ {printf "Sala: ";$1=$1 " -"}; {print}; NR%2==0 {print ""}'
	done  | sed '$d'
}

# ----------------------------------------------------------------------------
# zzcineuci
# http://www.ucicinemas.com.br
# Exibe a programação dos cinemas UCI de sua cidade.
# Se não for passado nenhum parâmetro, são listadas as cidades e cinemas.
# Uso: zzcineuci [cidade | codigo_cinema]
# Ex.: zzcineuci recife
#      zzcineuci 14
#
# Autor: Rodrigo Pereira da Cunha <rodrigopc (a) gmail.com>
# Desde: 2009-05-04
# Versão: 8
# Licença: GPL
# Requisitos: zzminusculas zzsemacento zzxml zzcapitalize zzjuntalinhas zztrim
# ----------------------------------------------------------------------------
zzcineuci ()
{
	zzzz -h cineuci "$1" && return

	local cache=$(zztool cache cineuci)
	local cidade codigo codigos
	local url="http://www.ucicinemas.com.br/controles/listaFilmeCinemaHome.aspx?cinemaID="

	if test "$1" = '--atualiza'
	then
		zztool atualiza cineuci
		shift
	fi

	if ! test -s "$cache"
	then
		$ZZWWWHTML "http://www.ucicinemas.com.br/localizacao+e+precos" |
		zzxml --tidy |
		sed -n "/\(class=.heading-bg.\|class=.btn-holder.\)/{n;p;}" |
		sed '
			s/.*cinema-/ /
			s/uci/UCI/
			s/-/) /
			s/.>//
			s/+/ /g
			s/ \([1-9]\))/ 0\1)/
			s/^\([A-Z]\)\(.*\)$/\
\1\2:/' |
		zzcapitalize > "$cache"
	fi

	if test $# = 0; then
		# mostra opções
		printf "Cidades e cinemas disponíveis\n=============================\n"
		cat "$cache"
		return 0
	fi

	cidade=$(echo "$*" | zzsemacento | zzminusculas | zztrim | sed 's/ 0/ /g;s/  */_/g')

	codigo=$(
		cat "$cache" |
		while read linha
		do
			echo "$linha" | grep ':$' >/dev/null &&
			echo "$linha" | zzminusculas | zzsemacento | tr ' ' '_' ||
			echo "$linha" | sed 's/).*//'
		done
		)

	# passou código
	if zztool testa_numero ${cidade}; then
		# testa se código é válido
		cidade=$(printf "%02d" $cidade)
		echo "$codigo" | grep "$cidade" >/dev/null && codigos="$cidade"
	else
		# passou nome da cidade
		codigos=$(
			echo "$codigo" |
			sed -n "/${cidade}:/,/^$/{/:/d;p;}" |
			zzjuntalinhas
			)
	fi

	# se não recebeu cidade ou código válido, sai
	test -z "$codigos" && return 1

	for codigo in $codigos
	do
		$ZZWWWDUMP "$url$codigo" | sed '

			# Faxina
			s/^  *//
			/^$/ d
			/^Horários para/ d

			# Destaque ao redor do nome do cinema, quebra linha após
			1 i\
=================================================
			1 a\
=================================================\


			# Quebra linha após o horário
			/^Sala / G
		'
	done
}

# ----------------------------------------------------------------------------
# zzcnpj
# Cria, valida ou formata um número de CNPJ.
# Obs.: O CNPJ informado pode estar formatado (pontos e hífen) ou não.
# Uso: zzcnpj [-f] [cnpj]
# Ex.: zzcnpj 12.345.678/0001-95      # valida o CNPJ informado
#      zzcnpj 12345678000195          # com ou sem pontuação
#      zzcnpj                         # gera um CNPJ válido (aleatório)
#      zzcnpj -f 12345678000195       # formata, adicionando pontuação
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-12-23
# Versão: 3
# Licença: GPL
# Requisitos: zzaleatorio
# ----------------------------------------------------------------------------
zzcnpj ()
{
	zzzz -h cnpj "$1" && return

	local i n somatoria digito1 digito2 cnpj base

	# Atenção:
	# Essa função é irmã-quase-gêmea da zzcpf, que está bem
	# documentada, então não vou repetir aqui os comentários.
	#
	# O cálculo dos dígitos verificadores também é idêntico,
	# apenas com uma máscara numérica maior, devido à quantidade
	# maior de dígitos do CNPJ em relação ao CPF.

	cnpj=$(echo "$*" | tr -d -c 0123456789)

	# Talvez só precisamos formatar e nada mais?
	if test "$1" = '-f'
	then
		cnpj=$(echo "$cnpj" | sed 's/^0*//')
		: ${cnpj:=0}

		if test ${#cnpj} -gt 14
		then
			zztool erro 'CNPJ inválido (passou de 14 dígitos)'
			return 1
		fi

		cnpj=$(printf %014d "$cnpj")
		echo $cnpj | sed '
			s|.|&-|12
			s|.|&/|8
			s|.|&.|5
			s|.|&.|2
		'
		return 0
	fi

	if test -n "$cnpj"
	then
		# CNPJ do usuário

		if test ${#cnpj} -ne 14
		then
			zztool erro 'CNPJ inválido (deve ter 14 dígitos)'
			return 1
		fi

		if test $cnpj -eq 0
		then
			zztool erro 'CNPJ inválido (não pode conter apenas zeros)'
			return 1
		fi

		base="${cnpj%??}"
	else
		# CNPJ gerado aleatoriamente

		while test ${#cnpj} -lt 8
		do
			cnpj="$cnpj$(zzaleatorio 8)"
		done

		cnpj="${cnpj}0001"
		base="$cnpj"
	fi

	# Cálculo do dígito verificador 1

	set - $(echo "$base" | sed 's/./& /g')

	somatoria=0
	for i in 5 4 3 2 9 8 7 6 5 4 3 2
	do
		n="$1"
		somatoria=$((somatoria + (i * n)))
		shift
	done

	digito1=$((11 - (somatoria % 11)))
	test $digito1 -ge 10 && digito1=0

	# Cálculo do dígito verificador 2

	set - $(echo "$base" | sed 's/./& /g')

	somatoria=0
	for i in 6 5 4 3 2 9 8 7 6 5 4 3 2
	do
		n="$1"
		somatoria=$((somatoria + (i * n)))
		shift
	done
	somatoria=$((somatoria + digito1 * 2))

	digito2=$((11 - (somatoria % 11)))
	test $digito2 -ge 10 && digito2=0

	# Mostra ou valida o CNPJ
	if test ${#cnpj} -eq 12
	then
		echo "$cnpj$digito1$digito2" |
			sed 's|\(..\)\(...\)\(...\)\(....\)|\1.\2.\3/\4-|'
	else
		if test "${cnpj#????????????}" = "$digito1$digito2"
		then
			echo 'CNPJ válido'
		else
			# Boa ação do dia: mostrar quais os verificadores corretos
			echo "CNPJ inválido (deveria terminar em $digito1$digito2)"
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzcoin
# Retorna a cotação de criptomoedas em Reais (bitcoin e litecoins).
# Opções: btc ou bitecoin / ltc ou litecoin.
# Com as opções -a ou --all, várias criptomoedas cotadas em dólar.
# Uso: zzcoin [btc|bitcoin|ltc|litecoin|-a|--all]
# Ex.: zzcoin
#      zzcoin btc
#      zzcoin litecoin
#      zzcoin -a
#
# Autor: Tárcio Zemel <tarciozemel (a) gmail com>
# Desde: 2014-03-24
# Versão: 4
# Licença: GPL
# Requisitos: zzminusculas zzsemacento zznumero
# ----------------------------------------------------------------------------
zzcoin ()
{
	zzzz -h coin "$1" && return

	# Variáveis gerais
	local moeda_informada=$(echo "${1:--a}" | zzminusculas | zzsemacento)
	local url="https://www.mercadobitcoin.com.br/api"

	# Se não informou moeda válida, termina
	case "$moeda_informada" in
		btc | bitcoin  )
			# Monta URL a ser consultada
			url="${url}/ticker"
			$ZZWWWHTML "$url" |
			sed 's/.*"last"://;s/,"buy.*//' |
			zznumero -m
		;;
		ltc | litecoin  )
			# Monta URL a ser consultada
			url="${url}/ticker_litecoin"
			$ZZWWWHTML "$url" |
			sed 's/.*"last"://;s/,"buy.*//' |
			zznumero -m
		;;
		-a | --all )
			url="http://coinmarketcap.com/mineable.html"
			$ZZWWWDUMP "$url" |
			sed -n '/#/,/Last updated/{
				/^ *\*/d;
				/^ *$/d;
				s/Total Market Cap/Valor Total de Mercado/;
				s/Last updated/Última atualização/;
				s/ %//;
				s/\$ //g;
				s/  Name /Nome /;
				s/ Market Cap/Valor Mercado/;
				s/     Price/Preço/;
				s/Total Supply/Total Oferta/;
				s/ (24h)/(24h)/g;
				s/Change(24h)/%Var(24h)/;
				s/ Market Cap Graph (7d)//;
				s/ Price Graph (7d)//;
				/______/d;
				p;
				}' |
			awk '
				function espacos(  tamanho, saida, i) {
					for(i=1;i<=tamanho;i++)
						saida = saida " "
					return saida
				}
				NR==1 {print}
				NR>=2 {
					if($2 == $3) {
						atual = $2 " " $3
						novo = $2 " " espacos(length($3))
						sub(atual, novo)
						print
					}
					else if($2 == $4 && $3 == $5) {
						gsub(/\)/,"_"); gsub(/\(/,"_")
						atual = $2 " " $3 " " $4 " " $5
						novo = $2 " " $3 " " espacos(length($4)+length($5)+1)
						sub(atual, novo)
						gsub(/_/," "); gsub(/_/," ")
						print
					}
					else { print }
				}'
			return
		;;
		* ) return 1;;
	esac
}

# ----------------------------------------------------------------------------
# zzcolunar
# Transforma uma lista simples, em uma lista de múltiplas colunas.
# É necessário informar a quantidade de colunas como argumento.
#
# Mas opcionalmente pode informar o formato da distribuição das colunas:
# -z:
#   1  2  3
#   4  5  6
#   7  8  9
#   10
#
# -n: (padrão)
#   1  5  9
#   2  6  10
#   3  7
#   4  8
#
# As opções -l, --left, -e, --esquerda alinham as colunas a esquerda (padrão).
# As opções -r, --right, -d, --direita alinham as colunas a direita.
# As opções -c, --center, --centro centralizam as colunas.
# A opção -j justifica as colunas.
#
# As opções -w, --width, --largura seguido de um número,
# determinam a largura que as colunas terão.
#
# Uso: zzcolunar [-n|-z] [-l|-r|-c] [-w <largura>] <colunas> arquivo
# Ex.: zzcolunar 3 arquivo.txt
#      zzcolunar -c -w 20 5 arquivo.txt
#      cat arquivo.txt | zzcolunar -z 4
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-04-24
# Versão: 3
# Licença: GPL
# Requisitos: zzalinhar zztrim
# ----------------------------------------------------------------------------
zzcolunar ()
{
	zzzz -h colunar "$1" && return

	test -n "$1" || { zztool -e uso colunar; return 1; }

	local formato='n'
	local alinhamento='-l'
	local largura=0
	local colunas

	while test "${1#-}" != "$1"
	do
		case "$1" in
		-[nN]) formato='n';shift ;;
		-[zZ]) formato='z';shift ;;
		-l | --left | -e | --esqueda)  alinhamento='-l'; shift ;;
		-r | --right | -d | --direita) alinhamento='-r'; shift ;;
		-c | --center | --centro)      alinhamento='-c'; shift ;;
		-j)                            alinhamento='-j'; shift ;;
		-w | --width | --largura)
			zztool testa_numero "$2" && largura="$2" || { zztool erro "Largura inválida: $2"; return 1; }
			shift
			shift
		;;
		-*) zztool erro "Opção inválida: $1"; return 1 ;;
		*) break;;
		esac
	done

	if zztool testa_numero "$1"
	then
		colunas="$1"
		shift
	else
		zztool -e uso colunar
		return 1
	fi

	zztool file_stdin "$@" |
	zzalinhar -w $largura ${alinhamento} |
	awk -v cols=$colunas -v formato=$formato '

		{ linha[NR] = $0 }

		END {
			lin = ( int(NR/cols)==(NR/cols) ? NR/cols : int(NR/cols)+1 )

			# Formato N ( na verdade é И )
			if (formato == "n") {
				for ( i=1; i <= lin; i++ ) {
					linha_saida = ""

					for ( j = 0; j < cols; j++ ) {
							if ( i + (j * lin ) <= NR )
								linha_saida = linha_saida (j==0 ? "" : " ") linha[ i + ( j * lin ) ]
					}

					print linha_saida
				}
			}

			# Formato Z
			if (formato == "z") {
				i = 1
				while ( i <= NR )
				{
					for ( j = 1; j <= cols; j++ ) {
						if ( i <= NR )
							linha_saida = linha_saida (j==1 ? "" : " ") linha[i]

						if (j == cols || i == NR) {
							print linha_saida
							linha_saida = ""
						}

						i++
					}
				}
			}
		}
	' | zztrim -V
}

# ----------------------------------------------------------------------------
# zzcontapalavra
# Conta o número de vezes que uma palavra aparece num arquivo.
# Obs.: É diferente do grep -c, que não conta várias palavras na mesma linha.
# Opções: -i  ignora a diferença de maiúsculas/minúsculas
#         -p  busca parcial, conta trechos de palavras
# Uso: zzcontapalavra [-i|-p] palavra arquivo(s)
# Ex.: zzcontapalavra root /etc/passwd
#      zzcontapalavra -i -p a /etc/passwd      # Compare com grep -ci a
#      cat /etc/passwd | zzcontapalavra root
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-10-02
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzcontapalavra ()
{
	zzzz -h contapalavra "$1" && return

	local padrao ignora
	local inteira=1

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-p) inteira=  ;;
			-i) ignora=1  ;;
			* ) break     ;;
		esac
		shift
	done

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso contapalavra; return 1; }

	padrao=$1
	shift

	# Contorna a limitação do grep -c pesquisando pela palavra
	# e quebrando o resultado em uma palavra por linha (tr).
	# Então pode-se usar o grep -c para contar.
	# Nota: Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |
		grep -h ${ignora:+-i} ${inteira:+-w} -- "$padrao" |
		tr '\t./ -,:-@[-_{-~' '\n' |
		grep -c ${ignora:+-i} ${inteira:+-w} -- "$padrao"
}

# ----------------------------------------------------------------------------
# zzcontapalavras
# Conta o número de vezes que cada palavra aparece em um texto.
#
# Opções: -i       Trata maiúsculas e minúsculas como iguais, FOO = Foo = foo
#         -n NÚM   Mostra apenas as NÚM palavras mais frequentes
#
# Uso: zzcontapalavras [-i] [-n N] [arquivo(s)]
# Ex.: zzcontapalavras arquivo.txt
#      zzcontapalavras -i arquivo.txt
#      zzcontapalavras -i -n 10 /etc/passwd
#      cat arquivo.txt | zzcontapalavras
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-07
# Versão: 1
# Licença: GPL
# Requisitos: zzminusculas
# ----------------------------------------------------------------------------
zzcontapalavras ()
{
	zzzz -h contapalavras "$1" && return

	local ignore_case
	local tab=$(printf '\t')
	local limite='$'

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-i)
				ignore_case=1
				shift
			;;
			-n)
				limite="$2"
				shift
				shift
			;;
			*)
				break
			;;
		esac
	done

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |

		# Remove caracteres que não são parte de palavras
		sed 's/[^A-Za-z0-9ÀàÁáÂâÃãÉéÊêÍíÓóÔôÕõÚúÇç_-]/ /g' |

		# Deixa uma palavra por linha, formando uma lista
		tr -s ' ' '\n' |

		# Converte tudo pra minúsculas?
		if test -n "$ignore_case"
		then
			zzminusculas
		else
			cat -
		fi |

		# Limpa a lista de palavras
		sed '
			# Remove linhas em branco
			/^$/d

			# Remove linhas somente com números e traços
			/^[0-9_-][0-9_-]*$/d
			' |

		# Faz a contagem com o uniq -c
		sort |
		uniq -c |

		# Ordena o resultado, primeiro vem a de maior contagem
		sort -n -r |

		# Temos limite no número de resultados?
		sed "$limite q" |

		# Formata o resultado para Número-Tab-Palavra
		sed "s/^[ $tab]*\([0-9]\{1,\}\)[ $tab]\{1,\}\(.*\)/\1$tab\2/"
}

# ----------------------------------------------------------------------------
# zzconverte
# Faz várias conversões como: caracteres, temperatura e distância.
#          cf = (C)elsius             para (F)ahrenheit
#          fc = (F)ahrenheit          para (C)elsius
#          ck = (C)elsius             para (K)elvin
#          kc = (K)elvin              para (C)elsius
#          fk = (F)ahrenheit          para (K)elvin
#          kf = (K)elvin              para (F)ahrenheit
#          km = (K)Quilômetros        para (M)ilhas
#          mk = (M)ilhas              para (K)Quilômetros
#          db = (D)ecimal             para (B)inário
#          bd = (B)inário             para (D)ecimal
#          cd = (C)aractere           para (D)ecimal
#          dc = (D)ecimal             para (C)aractere
#          hc = (H)exadecimal         para (C)aractere
#          ch = (C)aractere           para (H)exadecimal
#          dh = (D)ecimal             para (H)exadecimal
#          hd = (H)exadecimal         para (D)ecimal
# Uso: zzconverte <cf|fc|ck|kc|fk|kf|mk|km|db|bd|cd|dc|hc|ch|dh|hd> número
# Ex.: zzconverte cf 5
#      zzconverte dc 65
#      zzconverte db 32
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2003-10-02
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzconverte ()
{
	zzzz -h converte "$1" && return

	local s2='scale=2'
	local operacao=$1

	# Verificação dos parâmetros
	test -n "$2" || { zztool -e uso converte; return 1; }

	shift
	while test -n "$1"
	do
		case "$operacao" in
			cf)
				echo "$1 C = $(echo "$s2;($1*9/5)+32"     | bc) F"
			;;
			fc)
				echo "$1 F = $(echo "$s2;($1-32)*5/9"     | bc) C"
			;;
			ck)
				echo "$1 C = $(echo "$s2;$1+273.15"       | bc) K"
			;;
			kc)
				echo "$1 K = $(echo "$s2;$1-273.15"       | bc) C"
			;;
			kf)
				echo "$1 K = $(echo "$s2;($1*1.8)-459.67" | bc) F"
			;;
			fk)
				echo "$1 F = $(echo "$s2;($1+459.67)/1.8" | bc) K"
			;;
			km)
				echo "$1 km = $(echo "$s2;$1*0.6214"      | bc) milhas"
				# ^ resultado com 4 casas porque bc usa o mesmo do 0.6214
			;;
			mk)
				echo "$1 milhas = $(echo "$s2;$1*1.609"   | bc) km"
				# ^ resultado com 3 casas porque bc usa o mesmo do 1.609
			;;
			db)
				echo "obase=2;$1" | bc -l
			;;
			bd)
				#echo "$((2#$1))"
				echo "ibase=2;$1" | bc -l
			;;
			cd)
				printf "%d\n" "'$1"
			;;
			dc)
				if zztool testa_numero "$1" && test "$1" -gt 0
				then
					# echo -e $(printf "\\\x%x" $1)
					awk 'BEGIN {printf "%c\n", '$1'}'
				fi
			;;
			ch)
				printf "%x\n" "'$1"
			;;
			hc)
				#echo -e "\x${1#0x}"
				printf '%d\n' "0x${1#0x}" | awk '{printf "%c\n", $1}'
			;;
			dh)
				printf '%x\n' "$1"
			;;
			hd)
				printf '%d\n' "0x${1#0x}"
			;;
		esac
		shift
	done
}

# ----------------------------------------------------------------------------
# zzcores
# Mostra todas as combinações de cores possíveis no console.
# Também mostra os códigos ANSI para obter tais combinações.
# Uso: zzcores
# Ex.: zzcores
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-12-11
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzcores ()
{
	zzzz -h cores "$1" && return

	local frente fundo negrito cor

	for frente in 0 1 2 3 4 5 6 7
	do
		for negrito in '' ';1' # alterna entre linhas sem e com negrito
		do
			for fundo in 0 1 2 3 4 5 6 7
			do
				# Compõe o par de cores: NN;NN
				cor="4$fundo;3$frente"

				# Mostra na tela usando caracteres de controle: ESC[ NN m
				printf "\033[$cor${negrito}m $cor${negrito:-  } \033[m"
			done
			echo
		done
	done
}

# ----------------------------------------------------------------------------
# zzcorpuschristi
# Mostra a data de Corpus Christi para qualquer ano.
# Obs.: Se o ano não for informado, usa o atual.
# Regra: 60 dias depois do domingo de Páscoa.
# Uso: zzcorpuschristi [ano]
# Ex.: zzcorpuschristi
#      zzcorpuschristi 2009
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-11-21
# Versão: 1
# Licença: GPL
# Requisitos: zzdata zzpascoa
# Tags: data
# ----------------------------------------------------------------------------
zzcorpuschristi ()
{
	zzzz -h corpuschristi "$1" && return

	local ano="$1"

	# Se o ano não for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Validação
	zztool -e testa_ano $ano || return 1

	# Ah, como é fácil quando se tem as ferramentas certas ;)
	# e quando já temos o código e só precisamos mudar os numeros
	# tambem é bom :D ;)
	zzdata $(zzpascoa $ano) + 60
}

# ----------------------------------------------------------------------------
# zzcotacao
# http://www.infomoney.com.br
# Busca cotações do dia de algumas moedas em relação ao Real (compra e venda).
# Uso: zzcotacao
# Ex.: zzcotacao
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-19
# Versão: 3
# Licença: GPL
# Requisitos: zzsemacento
# ----------------------------------------------------------------------------
zzcotacao ()
{
	zzzz -h cotacao "$1" && return

	$ZZWWWDUMP "http://www.infomoney.com.br/mercados/cambio" |
	sed -n '/^Real vs. Moedas/,/^Cota/p' |
	sed -n '3p;/^   [DLPFIE]/p' |
	sed 's/Venda  *Var/Venda Var/;s/\[//g;s/\]//g' |
	zzsemacento |
	awk '{
		if ( NR == 1 ) printf "%18s  %6s  %6s   %6s\n", "", $2, $3, $4
		if ( NR >  1 ) {
			if (NF == 4) printf "%-18s  %6s  %6s  %6s\n", $1, $2, $3, $4
			if (NF == 5) printf "%-18s  %6s  %6s  %6s\n", $1 " " $2, $3, $4, $5
		}
	}'
}

# ----------------------------------------------------------------------------
# zzcpf
# Cria, valida ou formata um número de CPF.
# Obs.: O CPF informado pode estar formatado (pontos e hífen) ou não.
# Uso: zzcpf [-f] [cpf]
# Ex.: zzcpf 123.456.789-09          # valida o CPF informado
#      zzcpf 12345678909             # com ou sem pontuação
#      zzcpf                         # gera um CPF válido (aleatório)
#      zzcpf -f 12345678909          # formata, adicionando pontuação
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-12-23
# Versão: 3
# Licença: GPL
# Requisitos: zzaleatorio
# ----------------------------------------------------------------------------
zzcpf ()
{
	zzzz -h cpf "$1" && return

	local i n somatoria digito1 digito2 cpf base

	# Remove pontuação do CPF informado, deixando apenas números
	cpf=$(echo "$*" | tr -d -c 0123456789)

	# Talvez só precisamos formatar e nada mais?
	if test "$1" = '-f'
	then
		# Remove os zeros do início (senão é considerado um octal)
		cpf=$(echo "$cpf" | sed 's/^0*//')

		# Se o CPF estiver vazio, define com zero
		: ${cpf:=0}

		if test ${#cpf} -gt 11
		then
			zztool erro 'CPF inválido (passou de 11 dígitos)'
			return 1
		fi

		# Completa com zeros à esquerda, caso necessário
		cpf=$(printf %011d "$cpf")

		# Formata com um sed esperto
		echo $cpf | sed '
			s/./&-/9
			s/./&./6
			s/./&./3
		'

		# Tudo certo, podemos ir embora
		return 0
	fi

	# Extrai os números da base do CPF:
	# Os 9 primeiros, sem os dois dígitos verificadores.
	# Esses dois dígitos serão calculados adiante.
	if test -n "$cpf"
	then
		# Faltou ou sobrou algum número...
		if test ${#cpf} -ne 11
		then
			zztool erro 'CPF inválido (deve ter 11 dígitos)'
			return 1
		fi

		if test $cpf -eq 0
		then
			zztool erro 'CPF inválido (não pode conter apenas zeros)'
			return 1
		fi

		# Apaga os dois últimos dígitos
		base="${cpf%??}"
	else
		# Não foi informado nenhum CPF, vamos gerar um escolhendo
		# nove dígitos aleatoriamente para formar a base
		while test ${#cpf} -lt 9
		do
			cpf="$cpf$(zzaleatorio 8)"
		done
		base="$cpf"
	fi

	# Truque para cada dígito da base ser guardado em $1, $2, $3, ...
	set - $(echo "$base" | sed 's/./& /g')

	# Explicação do algoritmo de geração/validação do CPF:
	#
	# Os primeiros 9 dígitos são livres, você pode digitar quaisquer
	# números, não há seqüência. O que importa é que os dois últimos
	# dígitos, chamados verificadores, estejam corretos.
	#
	# Estes dígitos são calculados em cima dos 9 primeiros, seguindo
	# a seguinte fórmula:
	#
	# 1) Aplica a multiplicação de cada dígito na máscara de números
	#    que é de 10 a 2 para o primeiro dígito e de 11 a 3 para o segundo.
	# 2) Depois tira o módulo de 11 do somatório dos resultados.
	# 3) Diminui isso de 11 e se der 10 ou mais vira zero.
	# 4) Pronto, achou o primeiro dígito verificador.
	#
	# Máscara   : 10    9    8    7    6    5    4    3    2
	# CPF       :  2    2    5    4    3    7    1    0    1
	# Multiplica: 20 + 18 + 40 + 28 + 18 + 35 +  4 +  0 +  2 = Somatória
	#
	# Para o segundo é praticamente igual, porém muda a máscara (11 - 3)
	# e ao somatório é adicionado o dígito 1 multiplicado por 2.

	### Cálculo do dígito verificador 1
	# Passo 1
	somatoria=0
	for i in 10 9 8 7 6 5 4 3 2 # máscara
	do
		# Cada um dos dígitos da base ($n) é multiplicado pelo
		# seu número correspondente da máscara ($i) e adicionado
		# na somatória.
		n="$1"
		somatoria=$((somatoria + (i * n)))
		shift
	done
	# Passo 2
	digito1=$((11 - (somatoria % 11)))
	# Passo 3
	test $digito1 -ge 10 && digito1=0

	### Cálculo do dígito verificador 2
	# Tudo igual ao anterior, primeiro setando $1, $2, $3, etc e
	# depois fazendo os cálculos já explicados.
	#
	set - $(echo "$base" | sed 's/./& /g')
	# Passo 1
	somatoria=0
	for i in 11 10 9 8 7 6 5 4 3
	do
		n="$1"
		somatoria=$((somatoria + (i * n)))
		shift
	done
	# Passo 1 e meio (o dobro do verificador 1 entra na somatória)
	somatoria=$((somatoria + digito1 * 2))
	# Passo 2
	digito2=$((11 - (somatoria % 11)))
	# Passo 3
	test $digito2 -ge 10 && digito2=0

	# Mostra ou valida
	if test ${#cpf} -eq 9
	then
		# Esse CPF foi gerado aleatoriamente pela função.
		# Apenas adiciona os dígitos verificadores e mostra na tela.
		echo "$cpf$digito1$digito2" |
			sed 's/\(...\)\(...\)\(...\)/\1.\2.\3-/' # nnn.nnn.nnn-nn
	else
		# Esse CPF foi informado pelo usuário.
		# Compara os verificadores informados com os calculados.
		if test "${cpf#?????????}" = "$digito1$digito2"
		then
			echo 'CPF válido'
		else
			# Boa ação do dia: mostrar quais os verificadores corretos
			zztool erro "CPF inválido (deveria terminar em $digito1$digito2)"
			return 1
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzdado
# Dado virtual.
# Sem argumento, exibe um número aleatório entre 1 e 6.
# Com o argumento -f ou --faces, pode mudar a quantidade de lados do dado.
#
# Uso: zzdado
# Ex.: zzdado
#      zzdado -f 20
#      zzdado --faces 12
#
# Autor: Angelito M. Goulart, www.angelitomg.com
# Desde: 2012-12-05
# Versão: 2
# Licença: GPL
# Requisitos: zzaleatorio
# ----------------------------------------------------------------------------
zzdado ()
{

	local n_faces=6

	# Comando especial das funcoes ZZ
	zzzz -h dado "$1" && return

	while test "${1#-}" != "$1"
	do
		case "$1" in
			-f|--faces)
				if zztool testa_numero $2
				then
					n_faces="$2"
				else
					zztool erro "Numero inválido"
					return 1
				fi
			;;
			*)
				zztool erro "Opção inválida"
				return 2
			;;
		esac
		shift
	done

	# Gera e exibe um numero aleatorio entre 1 e o total de faces
	zzaleatorio 1 $n_faces
}

# ----------------------------------------------------------------------------
# zzdata
# Calculadora de datas, trata corretamente os anos bissextos.
# Você pode somar ou subtrair dias, meses e anos de uma data qualquer.
# Você pode informar a data dd/mm/aaaa ou usar palavras como: hoje, ontem.
# Usar a palavra dias informa número de dias desde o começo do ano corrente.
# Ou os dias da semana como: domingo, seg, ter, qua, qui, sex, sab, dom.
# Na diferença entre duas datas, o resultado é o número de dias entre elas.
# Se informar somente uma data, converte para número de dias (01/01/1970 = 0).
# Se informar somente um número (de dias), converte de volta para a data.
# Esta função também pode ser usada para validar uma data.
#
# Uso: zzdata [data [+|- data|número<d|m|a>]]
# Ex.: zzdata                           # que dia é hoje?
#      zzdata anteontem                 # que dia foi anteontem?
#      zzdata dom                       # que dia será o próximo domingo?
#      zzdata hoje + 15d                # que dia será daqui 15 dias?
#      zzdata hoje - 40d                # e 40 dias atrás, foi quando?
#      zzdata 31/12/2010 + 100d         # 100 dias após a data informada
#      zzdata 29/02/2001                # data inválida, ano não-bissexto
#      zzdata 29/02/2000 + 1a           # 28/02/2001 <- respeita bissextos
#      zzdata 01/03/2000 - 11/11/1999   # quantos dias há entre as duas?
#      zzdata hoje - 07/10/1977         # quantos dias desde meu nascimento?
#      zzdata 21/12/2012 - hoje         # quantos dias para o fim do mundo?
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-02-07
# Versão: 5
# Licença: GPL
# Tags: data, cálculo
# ----------------------------------------------------------------------------
zzdata ()
{
	zzzz -h data "$1" && return

	local yyyy mm dd mmdd i m y op dias_ano dias_mes dias_neste_mes
	local valor operacao quantidade grandeza
	local tipo tipo1 tipo2
	local data data1 data2
	local dias dias1 dias2
	local delta delta1 delta2
	local epoch=1970
	local dias_mes_ok='31 28 31 30 31 30 31 31 30 31 30 31'  # jan-dez
	local dias_mes_rev='31 30 31 30 31 31 30 31 30 31 28 31' # dez-jan
	local valor1="$1"
	local operacao="$2"
	local valor2="$3"

	# Verificação dos parâmetros
	case $# in
		0)
			# Sem argumentos, mostra a data atual
			zzdata hoje
			return
		;;
		1)
			# Delta sozinho é relativo ao dia atual
			case "$1" in
				[0-9]*[dma])
					zzdata hoje + "$1"
					return
				;;
			esac
		;;
		3)
			# Validação rápida
			if test "$operacao" != '-' -a "$operacao" != '+'
			then
				zztool erro "Operação inválida '$operacao'. Deve ser + ou -."
				return 1
			fi
		;;
		*)
			zztool -e uso data
			return 1
		;;
	esac

	# Validação do conteúdo de $valor1 e $valor2
	# Formato válidos: 31/12/1999, 123, -123, 5d, 5m, 5a, hoje
	#
	# Este bloco é bem importante, pois além de validar os dados
	# do usuário, também povoa as variáveis que serão usadas na
	# tomada de decisão adiante. São elas:
	# $tipo1 $tipo2 $data1 $data2 $dias1 $dias2 $delta1 $delta2
	#
	# Nota: é o eval quem salva estas variáveis.

	for i in 1 2
	do
		# Obtém o conteúdo de $valor1 ou $valor2
		eval "valor=\$valor$i"

		# Cancela se i=2 e só temos um valor
		test -z "$valor" && break

		# Identifica o tipo do valor e faz a validação
		case "$valor" in

			# Data no formato dd/mm/aaaa
			??/??/?*)

				tipo='data'
				yyyy="${valor##*/}"
				ddmm="${valor%/*}"

				# Data em formato válido?
				zztool -e testa_data "$valor" || return 1

				# 29/02 em um ano não-bissexto?
				if test "$ddmm" = '29/02' && ! zztool testa_ano_bissexto "$yyyy"
				then
					zztool erro "Data inválida '$valor', pois $yyyy não é um ano bissexto."
					return 1
				fi
			;;

			# Delta de dias, meses ou anos: 5d, 5m, 5a
			[0-9]*[dma])

				tipo='delta'

				# Validação
				if ! echo "$valor" | grep '^[0-9][0-9]*[dma]$' >/dev/null
				then
					zztool erro "Delta inválido '$valor'. Deve ser algo como 5d, 5m ou 5a."
					return 1
				fi
			;;

			# Número negativo ou positivo
			-[0-9]* | [0-9]*)

				tipo='dias'

				# Validação
				if ! zztool testa_numero_sinal "$valor"
				then
					zztool erro "Número inválido '$valor'"
					return 1
				fi
			;;

			# Apelidos: hoje, ontem, etc
			[a-z]*)

				tipo='data'

				# Converte apelidos em datas
				case "$valor" in
					today | hoje)
						valor=$(date +%d/%m/%Y)
					;;
					yesterday | ontem)
						valor=$(zzdata hoje - 1)
					;;
					anteontem)
						valor=$(zzdata hoje - 2)
					;;
					tomorrow | amanh[aã])
						valor=$(zzdata hoje + 1)
					;;
					dom | domingo)
						valor=$(zzdata hoje + $(echo "7 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					sab | s[aá]bado)
						valor=$(zzdata hoje + $(echo "6 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					sex | sexta)
						valor=$(zzdata hoje + $(echo "5 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					qui | quinta)
						valor=$(zzdata hoje + $(echo "4 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					qua | quarta)
						valor=$(zzdata hoje + $(echo "3 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					ter | ter[cç]a)
						valor=$(zzdata hoje + $(echo "2 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					seg | segunda)
						valor=$(zzdata hoje + $(echo "1 $(date +%u)" | awk '{ print ($1 >= $2 ? $1 - $2 : 7 + ($1 - $2)) }'))
					;;
					days | dias)
						# Quantidade transcorridos de dias do ano.
						valor=$(date +%j)
					;;
					fim)
						valor=21/12/2012  # ;)
					;;
					*)
						zztool erro "Data inválida '$valor', deve ser dd/mm/aaaa"
						return 1
				esac

				# Exceção: se este é o único argumento, mostra a data e sai
				if test $# -eq 1
				then
					echo "$valor"
					return 0
				fi
			;;
			*)
				zztool erro "Data inválida '$valor', deve ser dd/mm/aaaa"
				return 1
			;;
		esac

		# Salva as variáveis $data/$dias/$delta e $tipo,
		# todas com os sufixos 1 ou 2 no nome. Por isso o eval.
		# Exemplo: data1=01/01/1970; tipo1=data
		eval "$tipo$i=$valor; tipo$i=$tipo"
	done

	# Validação: Se há um delta, o outro valor deve ser uma data ou número
	if test "$tipo1" = 'delta' -a "$tipo2" = 'delta'
	then
		zztool -e uso data
		return 1
	fi

	# Se chamada com um único argumento, é uma conversão simples.
	# Se veio uma data, converta para um número.
	# Se veio um número, converta para uma data.
	# E pronto.

	if test $# -eq 1
	then
		case $tipo1 in

			data)
				#############################################################
				### Conversão DATA -> NÚMERO
				#
				# A data dd/mm/aaaa é transformada em um número inteiro.
				# O resultado é o número de dias desde $epoch (01/01/1970).
				# Se a data for anterior a $epoch, o número será negativo.
				# Anos bissextos são tratados corretamente.
				#
				# Exemplos:
				#      30/12/1969 = -2
				#      31/12/1969 = -1
				#      01/01/1970 = 0
				#      02/01/1970 = 1
				#      03/01/1970 = 2
				#
				#      01/02/1970 = 31    (31 dias do mês de janeiro)
				#      01/01/1971 = 365   (um ano)
				#      01/01/1980 = 3652  (365 * 10 anos + 2 bissextos)

				data="$data1"

				# Extrai os componentes da data: ano, mês, dia
				yyyy=${data##*/}
				mm=${data#*/}
				mm=${mm%/*}
				dd=${data%%/*}

				# Retira os zeros à esquerda (pra não confundir com octal)
				mm=${mm#0}
				dd=${dd#0}
				yyyy=$(echo "$yyyy" | sed 's/^00*//; s/^$/0/')

				# Define o marco inicial e a direção dos cálculos
				if test $yyyy -ge $epoch
				then
					# +Epoch: Inicia em 01/01/1970 e avança no tempo
					y=$epoch          # ano
					m=1               # mês
					op='+'            # direção
					dias=0            # 01/01/1970 == 0
					dias_mes="$dias_mes_ok"
				else
					# -Epoch: Inicia em 31/12/1969 e retrocede no tempo
					y=$((epoch - 1))  # ano
					m=12              # mês
					op='-'            # direção
					dias=-1           # 31/12/1969 == -1
					dias_mes="$dias_mes_rev"
				fi

				# Ano -> dias
				while :
				do
					# Sim, os anos bissextos são levados em conta!
					dias_ano=365
					zztool testa_ano_bissexto $y && dias_ano=366

					# Vai somando (ou subtraindo) até chegar no ano corrente
					test $y -eq $yyyy && break
					dias=$(($dias $op $dias_ano))
					y=$(($y $op 1))
				done

				# Meses -> dias
				for i in $dias_mes
				do
					# Fevereiro de ano bissexto tem 29 dias
					test $dias_ano -eq 366 -a $i -eq 28 && i=29

					# Vai somando (ou subtraindo) até chegar no mês corrente
					test $m -eq $mm && break
					m=$(($m $op 1))
					dias=$(($dias $op $i))
				done
				dias_neste_mes=$i

				# -Epoch: o número de dias indica o quanto deve-se
				# retroceder à partir do último dia do mês
				test $op = '-' && dd=$(($dias_neste_mes - $dd))

				# Somando os dias da data aos anos+meses já contados.
				dias=$(($dias $op $dd))

				# +Epoch: É subtraído um do resultado pois 01/01/1970 == 0
				test $op = '+' && dias=$((dias - 1))

				# Feito, só mostrar o resultado
				echo "$dias"
			;;

			dias)
				#############################################################
				### Conversão NÚMERO -> DATA
				#
				# O número inteiro é convertido para a data dd/mm/aaaa.
				# Se o número for positivo, temos uma data DEPOIS de $epoch.
				# Se o número for negativo, temos uma data ANTES de $epoch.
				# Anos bissextos são tratados corretamente.
				#
				# Exemplos:
				#      -2 = 30/12/1969
				#      -1 = 31/12/1969
				#       0 = 01/01/1970
				#       1 = 02/01/1970
				#       2 = 03/01/1970

				dias="$dias1"

				if test $dias -ge 0
				then
					# POSITIVO: Inicia em 01/01/1970 e avança no tempo
					y=$epoch          # ano
					mm=1              # mês
					op='+'            # direção
					dias_mes="$dias_mes_ok"
				else
					# NEGATIVO: Inicia em 31/12/1969 e retrocede no tempo
					y=$((epoch - 1))  # ano
					mm=12             # mês
					op='-'            # direção
					dias_mes="$dias_mes_rev"

					# Valor negativo complica, vamos positivar: abs()
					dias=$((0 - dias))
				fi

				# O número da Epoch é zero-based, agora vai virar one-based
				dd=$(($dias $op 1))

				# Dias -> Ano
				while :
				do
					# Novamente, o ano bissexto é levado em conta
					dias_ano=365
					zztool testa_ano_bissexto $y && dias_ano=366

					# Vai descontando os dias de cada ano para saber quantos anos cabem

					# Não muda o ano se o número de dias for insuficiente
					test $dd -lt $dias_ano && break

					# Se for exatamente igual ao total de dias, não muda o
					# ano se estivermos indo adiante no tempo (> Epoch).
					# Caso contrário vai mudar pois cairemos no último dia
					# do ano anterior.
					test $dd -eq $dias_ano -a $op = '+' && break

					dd=$(($dd - $dias_ano))
					y=$(($y $op 1))
				done
				yyyy=$y

				# Dias -> mês
				for i in $dias_mes
				do
					# Fevereiro de ano bissexto tem 29 dias
					test $dias_ano -eq 366 -a $i -eq 28 && i=29

					# Calcula quantos meses cabem nos dias que sobraram

					# Não muda o mês se o número de dias for insuficiente
					test $dd -lt $i && break

					# Se for exatamente igual ao total de dias, não muda o
					# mês se estivermos indo adiante no tempo (> Epoch).
					# Caso contrário vai mudar pois cairemos no último dia
					# do mês anterior.
					test $dd -eq $i -a $op = '+' && break

					dd=$(($dd - $i))
					mm=$(($mm $op 1))
				done
				dias_neste_mes=$i

				# Ano e mês estão OK, agora sobraram apenas os dias

				# Se estivermos antes de Epoch, os número de dias indica quanto
				# devemos caminhar do último dia do mês até o primeiro
				test $op = '-' && dd=$(($dias_neste_mes - $dd))

				# Restaura o zero dos meses e dias menores que 10
				test $dd -le 9 && dd="0$dd"
				test $mm -le 9 && mm="0$mm"

				# E finalmente mostra o resultado em formato de data
				echo "$dd/$mm/$yyyy"
			;;

			*)
				zztool erro "Tipo inválido '$tipo1'. Isso não deveria acontecer :/"
				return 1
			;;
		esac
		return 0
	fi

	# Neste ponto só chega se houver mais de um parâmetro.
	# Todos os valores já foram validados.

	#############################################################
	### Cálculos com datas
	#
	# Temos dois valores informadas pelo usuário: $valor1 e $valor2.
	# Cada valor pode ser uma data dd/mm/aaaa, um número inteiro
	# ou um delta de dias, meses ou anos.
	#
	# Exemplos: 31/12/1999, 123, -123, 5d, 5m, 5a
	#
	# O usuário pode fazer qualquer combinação entre estes valores.
	#
	# Se o cálculo envolver deltas m|a, é usada a data dd/mm/aaaa.
	# Senão, é usado o número inteiro que representa a data.
	#
	# O tipo de cada valor é guardado em $tipo1-2.
	# Dependendo do tipo, o valor foi guardado nas variáveis
	# $data1-2, $dias1-2 ou $delta1-2.
	# Use estas variáveis no bloco seguinte para tomar decisões.

	# Cálculo com delta.
	if test $tipo1 = 'delta' -o $tipo2 = 'delta'
	then
		# Nunca haverá dois valores do mesmo tipo, posso abusar:
		delta="$delta1$delta2"
		data="$data1$data2"
		dias="$dias1$dias2"

		quantidade=$(echo "$delta" | sed 's/[^0-9]//g')
		grandeza=$(  echo "$delta" | sed 's/[^dma]//g')

		case $grandeza in
			d)
				# O cálculo deve ser feito utilizando o número
				test -z "$dias" && dias=$(zzdata "$data")  # data2n

				# Soma ou subtrai o delta
				dias=$(($dias $operacao $quantidade))

				# Converte o resultado para dd/mm/aaaa
				zzdata $dias
				return
			;;
			m | a)
				# O cálculo deve ser feito utilizando a data
				test -z "$data" && data=$(zzdata "$dias")  # n2data

				# Extrai os componentes da data: ano, mês, dia
				yyyy=${data##*/}
				mm=${data#*/}
				mm=${mm%/*}
				dd=${data%%/*}

				# Retira os zeros à esquerda (pra não confundir com octal)
				mm=${mm#0}
				dd=${dd#0}
				yyyy=$(echo "$yyyy" | sed 's/^00*//; s/^$/0/')

				# Anos
				if test $grandeza = 'a'
				then
					yyyy=$(($yyyy $operacao $quantidade))

				# Meses
				else
					mm=$(($mm $operacao $quantidade))

					# Se houver excedente no mês (>12), recalcula mês e ano
					yyyy=$(($yyyy + $mm / 12))
					mm=$(($mm % 12))

					# Se negativou, ajusta os cálculos (voltou um ano)
					if test $mm -le 0
					then
						yyyy=$(($yyyy - 1))
						mm=$((12 + $mm))
					fi
				fi

				# Se o resultado for 29/02 em um ano não-bissexto, muda pra 28/02
				test $dd -eq 29 -a $mm -eq 2 &&	! zztool testa_ano_bissexto $yyyy && dd=28

				# Restaura o zero dos meses e dias menores que 10
				test $dd -le 9 && dd="0$dd"
				test $mm -le 9 && mm="0$mm"

				# Tá feito, basta montar a data
				echo "$dd/$mm/$yyyy"
				return 0
			;;
		esac

	# Cálculo normal, sem delta
	else
		# Ambas as datas são sempre convertidas para inteiros
		test "$tipo1" != 'dias' && dias1=$(zzdata "$data1")
		test "$tipo2" != 'dias' && dias2=$(zzdata "$data2")

		# Soma ou subtrai os valores
		dias=$(($dias1 $operacao $dias2))

		# Se as duas datas foram informadas como dd/mm/aaaa,
		# o resultado é o próprio número de dias. Senão converte
		# o resultado para uma data.
		if test "$tipo1$tipo2" = 'datadata'
		then
			echo "$dias"
		else
			zzdata "$dias"  # n2data
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzdataestelar
# http://scifibrasil.com.br/data/
# Calcula a data estelar, a partir de uma data e horário.
#
# Sem argumentos calcula com a data e hora atual.
#
# Com um argumento, calcula conforme descrito:
#   Se for uma data válida, usa 0h 0min 0seg do dia.
#   Se for um horário, usa a data atual.
#
# Com dois argumentos sendo data seguida da hora.
#
# Uso: zzdataestelar [[data|hora] | data hora]
# Ex.: zzdataestelar
#      zzdataestelar hoje
#      zzdataestelar 25/01/2000
#      zzdataestelar 13:47:26
#      zzdataestelar 08/03/2010 14:25
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-10-28
# Versão: 1
# Licença: GPL
# Requisitos: zzdata zzdatafmt zznumero zzhora
# ----------------------------------------------------------------------------
zzdataestelar ()
{
	zzzz -h dataestelar "$1" && return

	local ano mes dia hora minuto segundo dias
	local tz=$(date "+%:z")

	case "$#" in
	0)
		# Sem agumento usa a data e hora atual UTC
		set - $(date -u "+%Y %m %d %H %M %S")
		ano=$1
		mes=$2
		dia=$3
		hora=$4
		minuto=$5
		segundo=$6
	;;
	1)
		if zzdata "$1" >/dev/null 2>&1
		then
			set - $(zzdatafmt -f "AAAA MM DD" "$1")
			ano=$1
			mes=$2
			dia=$3
			hora=0
			minuto=0
			segundo=0
		fi

		if zztool grep_var ':' "$1"
		then
			set - $(echo "$1" | sed 's/:/ /g')
			segundo=${3:-0}

			set - $(zzhora ${1}:${2} - $tz | sed 's/:/ /g')
			hora=$1
			minuto=$2

			set - $(zzdatafmt -f "AAAA MM DD" hoje)
			ano=$1
			mes=$2
			dia=$3
		fi
	;;
	2)
		if zzdata $1 >/dev/null 2>&1 && zztool grep_var ':' "$2"
		then
			set - $(zzdatafmt -f "AAAA MM DD $2" "$1" | sed 's/:/ /g')
			ano=$1
			mes=$2
			dia=$3
			segundo=${6:-0}

			set - $(zzhora "${4}:${5}" - "$tz" | sed 's/:/ /g')
			hora=$1
			minuto=$2
		fi
	;;
	esac

	if zztool testa_numero $ano
	then
		dias=$(zzdata ${dia}/${mes}/${ano} - 01/01/${ano})
		dias=$((dias + 1))

		echo "scale=6;(($ano + 4712) * 365.25) - 13.375 + ($dias * (1+59.2/86400)) + ($hora/24) + ($minuto/1440) + ($segundo/86400)" |
		bc -l | cut -c 3- | zznumero -f "%.2f" | tr ',' '.'
	else
		zztool -e uso dataestelar
		return 1
	fi
}

# ----------------------------------------------------------------------------
# zzdatafmt
# Muda o formato de uma data, com várias opções de personalização.
# Reconhece datas em vários formatos, como aaaa-mm-dd, dd.mm.aaaa e dd/mm.
# Obs.: Se você não informar o ano, será usado o ano corrente.
#
# Use a opção -f para mudar o formato de saída (o padrão é DD/MM/AAAA):
#
#      Código   Exemplo     Descrição
#      --------------------------------------------------------------
#      AAAA     2003        Ano com 4 dígitos
#      AA       03          Ano com 2 dígitos
#      A        3           Ano sem zeros à esquerda (1 ou 2 dígitos)
#      MM       02          Mês com 2 dígitos
#      M        2           Mês sem zeros à esquerda
#      DD       01          Dia com 2 dígitos
#      D        1           Dia sem zeros à esquerda
#      --------------------------------------------------------------
#      ANO      dois mil    Ano por extenso
#      MES      fevereiro   Nome do mês
#      MMM      fev         Nome do mês com três letras
#      DIA      vinte um    Dia por extenso
#      SEMANA   Domingo     Dia da semana por extenso
#      SSS      Dom         Dia da semana com três letras
#
# Use as opções de idioma para alterar os nomes dos meses. Estas opções também
# mudam o formato padrão da data de saída, caso a opção -f não seja informada.
#     --pt para português     --de para alemão
#     --en para inglês        --fr para francês
#     --es para espanhol      --it para italiano
#     --ptt português textual incluindo os números
#     --iso formato AAAA-MM-DD
#
# Uso: zzdatafmt [-f formato] [data]
# Ex.: zzdatafmt 2011-12-31                 # 31/12/2011
#      zzdatafmt 31.12.11                   # 31/12/2011
#      zzdatafmt 31/12                      # 31/12/2011     (ano atual)
#      zzdatafmt -f MES hoje                # maio           (mês atual)
#      zzdatafmt -f MES --en hoje           # May            (em inglês)
#      zzdatafmt -f AAAA 31/12/11           # 2011
#      zzdatafmt -f MM/DD/AA 31/12/2011     # 12/31/11       (BR -> US)
#      zzdatafmt -f D/M/A 01/02/2003        # 1/2/3
#      zzdatafmt -f "D de MES" 01/05/95     # 1 de maio
#      echo 31/12/2011 | zzdatafmt -f MM    # 12             (via STDIN)
#      zzdatafmt 31 de jan de 2013          # 31/01/2013     (entrada textual)
#      zzdatafmt --de 19/03/2012            # 19. März 2012  (Das ist gut!)
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-24
# Versão: 10
# Licença: GPL
# Requisitos: zzdata zzminusculas zznumero
# Tags: data
# ----------------------------------------------------------------------------
zzdatafmt ()
{
	zzzz -h datafmt "$1" && return

	local data data_orig fmt
	local ano_atual ano aaaa aa a
	local meses mes mmm mm m
	local semanas semana sem sss
	local dia dd d
	local meses_pt='janeiro fevereiro março abril maio junho julho agosto setembro outubro novembro dezembro'
	local meses_en='January February March April May June July August September October November December'
	local meses_es='Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre'
	local meses_de='Januar Februar März April Mai Juni Juli August September Oktober November Dezember'
	local meses_fr='Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre'
	local meses_it='Gennaio Febbraio Marzo Aprile Maggio Giugno Luglio Agosto Settembre Ottobre Novembre Dicembre'
	local semana_pt='Domingo Segunda-feira Terça-feira Quarta-feira Quinta-feira Sexta-feira Sábado'
	local semana_en='Sunday Monday Tuesday Wednesday Thursday Friday Saturday'
	local semana_es='Domingo Lunes Martes Miércoles Jueves Viernes Sábado'
	local semana_de='Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag'
	local semana_fr='Dimanche Lundi Mardi Mercredi Juedi Vendredi Samedi'
	local semana_it='Domenica Lunedi Martedi Mercoledi Giovedi Venerdi Sabato'

	# Idioma padrão
	meses="$meses_pt"
	semanas="$semana_pt"

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			--en)
				meses=$meses_en
				semanas=$semana_en
				test -n "$fmt" || fmt='MES, DD AAAA'
				shift
			;;
			--it)
				meses=$meses_it
				semanas=$semana_it
				test -n "$fmt" || fmt='DD da MES AAAA'
				shift
			;;
			--es)
				meses=$meses_es
				semanas=$semana_es
				test -n "$fmt" || fmt='DD de MES de AAAA'
				shift
			;;
			--pt)
				meses=$meses_pt
				semanas=$semana_pt
				test -n "$fmt" || fmt='DD de MES de AAAA'
				shift
			;;
			--ptt)
				meses=$meses_pt
				semanas=$semana_pt
				test -n "$fmt" || fmt='DIA de MES de ANO'
				shift
			;;
			--de)
				meses=$meses_de
				semanas=$semana_de
				test -n "$fmt" || fmt='DD. MES AAAA'
				shift
			;;
			--fr)
				meses=$meses_fr
				semanas=$semana_fr
				test -n "$fmt" || fmt='Le DD MES AAAA'
				shift
			;;
			--iso)
				fmt="AAAA-MM-DD"; shift;;
			-f)
				fmt="$2"
				shift
				shift
			;;
			*) break ;;
		esac
	done

	# Data via STDIN ou argumentos
	data=$(zztool multi_stdin "$@")
	data_orig="$data"

	# Converte datas estranhas para o formato brasileiro ../../..
	case "$data" in
		# apelidos
		hoje | ontem | anteontem | amanh[ãa] | today | yesterday | tomorrow)
			data=$(zzdata "$data")
		;;
		# semana (curto)
		dom | seg | ter | qua | qui | sex | sab)
			data=$(zzdata "$data")
		;;
		# semana (longo)
		domingo | segunda | ter[cç]a | quarta | quinta | sexta | s[aá]bado)
			data=$(zzdata "$data")
		;;
		# data possivelmente em formato textual
		*[A-Za-z]*)
			# 31 de janeiro de 2013
			# 31 de jan de 2013
			# 31/jan/2013
			# 31-jan-2013
			# 31.jan.2013
			# 31 jan 2013

			# Primeiro converte tudo pra 31/jan/2013 ou 31/janeiro/2013
			data=$(echo "$data" | zzminusculas | sed 's| de |/|g' | tr ' .-' ///)

			# Agora converte o nome do mês para número
			mes=$(echo "$data" | cut -d / -f 2)
			mm=$(echo "$meses_pt" |
				zzminusculas |
				awk '{for (i=1;i<=NF;i++){ if (substr($i,1,3) == substr("'$mes'",1,3) ) printf "%02d\n", i}}')
			zztool testa_numero "$mm" && data=$(echo "$data" | sed "s/$mes/$mm/")
			unset mes mm
		;;
		# aaaa-mm-dd (ISO)
		????-??-??)
			data=$(echo "$data" | sed 's|\(....\)-\(..\)-\(..\)|\3/\2/\1|')
		;;
		# d-m-a, d-m
		# d.m.a, d.m
		*-* | *.*)
			data=$(echo "$data" | tr .- //)
		;;
		# ddmmaaaa
		[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])
			data=$(echo "$data" | sed 's|.|&/|4 ; s|.|&/|2')
		;;
		# ddmmaa
		[0-9][0-9][0-9][0-9][0-9][0-9])
			data=$(echo "$data" | sed 's|.|&/|4 ; s|.|&/|2')
		;;
	esac

	### Aqui só chegam datas com a barra / como delimitador
	### Mas elas podem ser parcias, como: dia/mês

	# Completa elementos que estão faltando na data
	case "$data" in
		# d/m, dd/m, d/mm, dd/mm
		# Adiciona o ano atual
		[0-9]/[0-9] | [0-9][0-9]/[0-9] | [0-9]/[0-9][0-9] | [0-9][0-9]/[0-9][0-9])
			ano_atual=$(zzdata hoje | cut -d / -f 3)
			data="$data/$ano_atual"
		;;
	esac

	### Aqui só chegam datas completas, com os três elementos: n/n/n
	### Devo acertar o padding delas pra nn/nn/nnnn

	# Valida o formato da data
	if ! echo "$data" | grep '^[0-9][0-9]\{0,1\}/[0-9][0-9]\{0,1\}/[0-9]\{1,4\}$' >/dev/null
	then
		zztool erro "Erro: Data em formato desconhecido '$data_orig'"
		return 1
	fi

	# Extrai os valores da data
	dia=$(echo "$data" | cut -d / -f 1)
	mes=$(echo "$data" | cut -d / -f 2)
	ano=$(echo "$data" | cut -d / -f 3)

	# Faz padding nos valores
	case "$ano" in
		?         ) aaaa="200$ano";;  # 2000-2009
		[0-3][0-9]) aaaa="20$ano";;   # 2000-2039
		[4-9][0-9]) aaaa="19$ano";;   # 1940-1999
		???       ) aaaa="0$ano";;    # 0000-0999
		????      ) aaaa="$ano";;
	esac
	case "$mes" in
		?)  mm="0$mes";;
		??) mm="$mes";;
	esac
	case "$dia" in
		?)  dd="0$dia";;
		??) dd="$dia";;
	esac

	# Ok, agora a data está no formato correto: dd/mm/aaaa
	data="$dd/$mm/$aaaa"

	# Valida a data
	zztool -e testa_data "$data" || return 1

	# O usuário especificou um formato novo?
	if test -n "$fmt"
	then
		aaaa="${data##*/}"
		mm="${data#*/}"; mm="${mm%/*}"
		dd="${data%%/*}"
		aa="${aaaa#??}"
		a="${aa#0}"
		m="${mm#0}"
		d="${dd#0}"
		mes=$(echo "$meses" | cut -d ' ' -f "$m" 2>/dev/null)
		mmm=$(echo "$mes" | sed 's/\(...\).*/\1/')
		sem=$(date -j -f "%Y-%m-%d" "$aaaa-$mm-$dd" +%w 2>/dev/null || date -d "$aaaa-$mm-$dd" +%w 2>/dev/null)
		sem=$((sem + 1))
		semana=$(echo "$semanas" | cut -d ' ' -f "$sem" 2>/dev/null)
		sss=$(echo "$semana" | sed 's/\(...\).*/\1/')

		# Percorre o formato e vai expandindo, da esquerda para a direita
		while test -n "$fmt"
		do
			# Atenção à ordem das opções do case: AAAA -> AAA -> AA
			# Sempre do maior para o menor para evitar matches parciais
			case "$fmt" in
				SEMANA*)
					printf %s "$semana"
					fmt="${fmt#SEMANA}";;
				SSS*  ) printf %s "$sss"; fmt="${fmt#SSS}";;
				ANO*  )
					printf "$(zznumero --texto $aaaa)"
					fmt="${fmt#ANO}";;
				DIA*  )
					printf "$(zznumero --texto $dd)"
					fmt="${fmt#DIA}";;
				MES*  ) printf %s "$mes" ; fmt="${fmt#MES}";;
				AAAA* ) printf %s "$aaaa"; fmt="${fmt#AAAA}";;
				AA*   ) printf %s "$aa"  ; fmt="${fmt#AA}";;
				A*    ) printf %s "$a"   ; fmt="${fmt#A}";;
				MMM*  ) printf %s "$mmm" ; fmt="${fmt#MMM}";;
				MM*   ) printf %s "$mm"  ; fmt="${fmt#MM}";;
				M*    ) printf %s "$m"   ; fmt="${fmt#M}";;
				DD*   ) printf %s "$dd"  ; fmt="${fmt#DD}";;
				D*    ) printf %s "$d"   ; fmt="${fmt#D}";;
				*     ) printf %c "$fmt" ; fmt="${fmt#?}";;  # 1char
			esac
		done
		echo

	# Senão, é só mostrar no formato normal
	else
		echo "$data"
	fi
}

# ----------------------------------------------------------------------------
# zzdefinr
# http://definr.com
# Busca o significado de um termo, palavra ou expressão no site Definr.
# Uso: zzdefinr termo
# Ex.: zzdefinr headphone
#      zzdefinr in force
#
# Autor: Felipe Arruda <felipemiguel (a) gmail com>
# Desde: 2008-08-15
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzdefinr ()
{
	zzzz -h definr "$1" && return

	test -n "$1" || { zztool -e uso definr; return 1; }

	local word=$(echo "$*" | sed 's/ /%20/g')

	$ZZWWWHTML "http://definr.com/$word" |
		sed '
			/<div id="meaning">/,/<\/div>/!d
			s/<[^>]*>//g
			s/&nbsp;/ /g
			/^$/d'
}

# ----------------------------------------------------------------------------
# zzdiadasemana
# Mostra qual o dia da semana de uma data qualquer.
# Com a opção -n mostra o resultado em forma numérica (domingo=1).
# Obs.: Se a data não for informada, usa a data atual.
# Uso: zzdiadasemana [-n] [data]
# Ex.: zzdiadasemana
#      zzdiadasemana 31/12/2010          # sexta-feira
#      zzdiadasemana -n 31/12/2010       # 6
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-24
# Versão: 3
# Licença: GPL
# Requisitos: zzdata
# Tags: data
# ----------------------------------------------------------------------------
zzdiadasemana ()
{
	zzzz -h diadasemana "$1" && return

	local data delta dia
	local dias="quinta- sexta- sábado domingo segunda- terça- quarta-"
	local dias_rev="quinta- quarta- terça- segunda- domingo sábado sexta-"
	local dias_n="5 6 7 1 2 3 4"
	local dias_n_rev="5 4 3 2 1 7 6"
	# 1=domingo, assim os números são similares aos nomes: 2=segunda

	# Opção de linha de comando
	if test "$1" = '-n'
	then
		dias="$dias_n"
		dias_rev="$dias_n_rev"
		shift
	fi

	data="$1"

	# Se a data não foi informada, usa a atual
	test -z "$data" && data=$(date +%d/%m/%Y)

	# Validação
	zztool -e testa_data "$data" || return 1

	# O cálculo se baseia na data ZERO (01/01/1970), que é quinta-feira.
	# Basta dividir o delta (intervalo de dias até a data ZERO) por 7.
	# O resto da divisão é o dia da semana, sendo 0=quinta e 6=quarta.
	#
	# A função zzdata considera 01/01/1970 a data zero, e se chamada
	# apenas com uma data, retorna o número de dias de diferença para
	# o dia zero. O número será negativo se o ano for inferior a 1970.
	#
	delta=$(zzdata $data)
	dia=$(( ${delta#-} % 7))  # remove o sinal negativo (se tiver)

	# Se a data é anterior a 01/01/1970, conta os dias ao contrário
	test $delta -lt 0 && dias="$dias_rev"

	# O cut tem índice inicial um e não zero, por isso dia+1
	echo "$dias" |
		cut -d ' ' -f $((dia+1)) |
		sed 's/-/-feira/'
}

# ----------------------------------------------------------------------------
# zzdiasuteis
# Calcula o número de dias úteis entre duas datas, inclusive ambas.
# Chamada sem argumentos, mostra os total de dias úteis no mês atual.
# Obs.: Não leva em conta feriados.
#
# Uso: zzdiasuteis [data-inicial data-final]
# Ex.: zzdiasuteis                          # Fevereiro de 2013 tem 20 dias …
#      zzdiasuteis 01/01/2011 31/01/2011    # 21
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-20
# Versão: 2
# Licença: GPL
# Requisitos: zzdata zzdiadasemana zzdatafmt zzcapitalize
# Tags: data, cálculo
# ----------------------------------------------------------------------------
zzdiasuteis ()
{
	zzzz -h diasuteis "$1" && return

	local data dias dia1 semanas avulsos ini fim hoje mes ano
	local avulsos_uteis=0
	local uteis="0111110"  # D S T Q Q S S
	local data1="$1"
	local data2="$2"

	# Verificação dos parâmetros
	if test $# -eq 0
	then
		# Sem argumentos, calcula para o mês atual
		# Exemplo para fev/2013: zzdiasuteis 01/02/2013 28/02/2013
		hoje=$(zzdata hoje)
		data1=$(zzdatafmt -f 01/MM/AAAA $hoje)
		data2=$(zzdata $(zzdata $data1 + 1m) - 1)
		mes=$(zzdatafmt -f MES $hoje | zzcapitalize)
		ano=$(zzdatafmt -f AAAA $hoje)
		echo "$mes de $ano tem $(zzdiasuteis $data1 $data2) dias úteis."
		return 0

	elif test $# -ne 2
	then
		zztool -e uso diasuteis
		return 1
	fi

	# Valida o formato das datas
	zztool -e testa_data "$data1" || return 1
	zztool -e testa_data "$data2" || return 1

	# Quantos dias há entre as duas datas?
	dias=$(zzdata $data2 - $data1)

	# O usuário inverteu a ordem das datas?
	if test $dias -lt 0
	then
		# Tudo bem, a gente desinverte.
		dias=$((0 - $dias))  # abs()
		data=$data1
		data1=$data2
		data2=$data
	fi

	# A zzdata conta a diferença, então precisamos fazer +1 para incluir
	# ambas as datas no resultado.
	dias=$((dias + 1))

	# Qual dia da semana cai a data inicial?
	dia1=$(zzdiadasemana -n $data1)  # 1=domingo

	# Quantas semanas e quantos dias avulsos?
	semanas=$((dias / 7))
	avulsos=$((dias % 7))

	# Dos avulsos, quantos são úteis?
	#
	# Montei uma matriz de 14 posições ($uteis * 2) que contém 0's
	# e 1's, sendo que os 1's marcam os dias úteis. Faço um recorte
	# nessa matriz que inicia no $dia1 e tem o tamanho do total de
	# dias avulsos ($avulsos, max=6). As variáveis $ini e $fim são
	# usadas no cut e traduzem este recorte. Por fim, removo os
	# zeros e conto quantos 1's sobraram, que são os dias úteis.
	#
	if test $avulsos -gt 0
	then
		ini=$dia1
		fim=$(($dia1 + $avulsos - 1))
		avulsos_uteis=$(
			echo "$uteis$uteis" |
			cut -c $ini-$fim |
			tr -d 0)
		avulsos_uteis=${#avulsos_uteis}  # wc -c
	fi

	# Com os dados na mão, basta calcular
	echo $(($semanas * 5 + $avulsos_uteis))
}

# ----------------------------------------------------------------------------
# zzdicantonimos
# http://www.antonimos.com.br/
# Procura antônimos para uma palavra.
# Uso: zzdicantonimos palavra
# Ex.: zzdicantonimos bom
#
# Autor: gabriell nascimento <gabriellhrn (a) gmail com>
# Desde: 2013-04-15
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzdicantonimos ()
{

	zzzz -h dicantonimos "$1" && return

	local url='http://www.antonimos.com.br/busca.php'
	local palavra="$*"
	local palavra_busca=$( echo "$palavra" | sed "$ZZSEDURL" )

	# Verifica se recebeu parâmetros
	if test -z "$1"
	then
		zztool -e uso dicantonimos
		return 1
	fi

	# Faz a busca do termo no site, deixando somente os antônimos
	$ZZWWWDUMP "${url}?q=${palavra_busca}" |
		sed -n "/[0-9]\{1,\} antônimos\{0,1\} d/,/«/ {
			/[0-9]\{1,\} antônimos\{0,1\} d/d
			/«/d
			/^$/d
			s/^ *//
			p
		}"
}

# ----------------------------------------------------------------------------
# zzdicasl
# http://www.dicas-l.unicamp.br
# Procura por dicas sobre determinado assunto na lista Dicas-L.
# Obs.: As opções do grep podem ser usadas (-i já é padrão).
# Uso: zzdicasl [opção-grep] palavra(s)
# Ex.: zzdicasl ssh
#      zzdicasl -w vi
#      zzdicasl -vEw 'windows|unix|emacs'
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-08-08
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzdicasl ()
{
	zzzz -h dicasl "$1" && return

	local opcao_grep
	local url='http://www.dicas-l.com.br/arquivo/'

	# Guarda as opções para o grep (caso informadas)
	test -n "${1##-*}" || {
		opcao_grep=$1
		shift
	}

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso dicasl; return 1; }

	# Faz a consulta e filtra o resultado
	zztool eco "$url"
	$ZZWWWHTML "$url" |
		zztool texto_em_iso |
		grep -i $opcao_grep "$*" |
		sed -n 's@^<LI><A HREF=/arquivo/\([^>]*\)> *\([^ ].*\)</A>@\1@p'
}

# ----------------------------------------------------------------------------
# zzdicbabylon
# http://www.babylon.com
# Tradução de uma palavra em inglês para vários idiomas.
# Francês, alemão, japonês, italiano, hebreu, espanhol, holandês e português.
# Se nenhum idioma for informado, o padrão é o português.
# Uso: zzdicbabylon [idioma] palavra   #idioma:dut fre ger heb ita jap ptg spa
# Ex.: zzdicbabylon hardcore
#      zzdicbabylon jap tree
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzdicbabylon ()
{
	zzzz -h dicbabylon "$1" && return

	local idioma='ptg'
	local idiomas=' dut fre ger heb ita jap ptg spa '
	local tab=$(printf %b '\t')

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso dicbabylon; return 1; }

	# O primeiro argumento é um idioma?
	if test "${idiomas% $1 *}" != "$idiomas"
	then
		idioma=$1
		shift
	fi

	$ZZWWWHTML "http://online.babylon.com/cgi-bin/trans.cgi?lang=$idioma&word=$1" |
		sed "
			/OT_CopyrightStyle/,$ d
			/definition/,/<\/div>/!d
			/GA_google/d
			s/^[$tab ]*//
			s/<[^>]*>//g
			/^$/d
			N;s/\n/ /
			s/      / /
			" |
		zztool texto_em_utf8
}

# ----------------------------------------------------------------------------
# zzdicesperanto
# http://glosbe.com
# Dicionário de Esperanto em inglês, português e alemão.
# Possui busca por palavra nas duas direções. O padrão é português-esperanto.
#
# Uso: zzdicesperanto [-d pt|en|de|eo] [-p pt|en|de|eo] palavra
# Ex.: zzdicesperanto esperança
#      zzdicesperanto -d en job
#      zzdicesperanto -d eo laboro
#      zzdicesperanto -p en trabalho
#
# Autor: Fernando Aires <fernandoaires (a) gmail com>
# Desde: 2005-05-20
# Versão: 4
# Licença: GPL
# ----------------------------------------------------------------------------
zzdicesperanto ()
{
	zzzz -h dicesperanto "$1" && return

	test -n "$1" || { zztool -e uso dicesperanto; return 1; }

	local de_ling='pt'
	local para_ling='eo'
	local url="http://glosbe.com/"
	local pesquisa

	while test "${1#-}" != "$1"
	do
		case "$1" in
			-d)
				case "$2" in
					pt|en|de|eo)
						de_ling=$2
						shift

						if test $de_ling = "eo"
						then
							para_ling="pt"
						fi
					;;

					*)
						zztool erro "Lingua de origem não suportada"
						return 1
					;;
				esac
			;;

			-p)
				case "$2" in
					pt|en|de|eo)
						para_ling=$2
						shift
					;;

					*)
						zztool erro "Lingua de destino não suportada"
						return 2
					;;
				esac
			;;

			*)
				zztool erro "Parametro desconecido"
				return 3
			;;
		esac
		shift
	done

	pesquisa="$1"

	$ZZWWWHTML $url/$de_ling/$para_ling/$pesquisa |
		sed -n 's/.*class=" phr">\([^<]*\)<.*/\1/p'
}

# ----------------------------------------------------------------------------
# zzdicjargon
# http://catb.org/jargon/
# Dicionário de jargões de informática, em inglês.
# Uso: zzdicjargon palavra(s)
# Ex.: zzdicjargon vi
#      zzdicjargon all your base are belong to us
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Versão: 1
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zzdicjargon ()
{
	zzzz -h dicjargon "$1" && return

	local achei achei2 num mais
	local url='http://catb.org/jargon/html'
	local cache=$(zztool cache dicjargon)
	local padrao=$(echo "$*" | sed 's/ /-/g')

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso dicjargon; return 1; }

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		$ZZWWWLIST "$url/go01.html" |
			sed '
				/^ *[0-9][0-9]*\. /!d
				s@.*/html/@@
				/^[A-Z0]\//!d' > "$cache"
	fi

	achei=$(grep -i "$padrao" $cache)
	num=$(echo "$achei" | sed -n '$=')

	test -n "$achei" || return

	if test $num -gt 1
	then
		mais=$achei
		achei2=$(echo "$achei" | grep -w "$padrao" | sed 1q)
		test -n "$achei2" && achei="$achei2" && num=1
	fi

	if test $num -eq 1
	then
		$ZZWWWDUMP -width=72 "$url/$achei" |
			sed '1,/_\{9\}/d;/_\{9\}/,$d;/^$/d' | zztrim -l
		test -n "$mais" && zztool eco '\nTermos parecidos:'
	else
		zztool eco 'Achei mais de um! Escolha qual vai querer:'
	fi

	test -n "$mais" && echo "$mais" | sed 's/..// ; s/\.html$//'
}

# ----------------------------------------------------------------------------
# zzdicportugues
# http://www.dicio.com.br
# Dicionário de português.
# Definição de palavras e conjugação verbal
# Fornecendo uma "palavra" como argumento retorna seu significado e sinônimo.
# Se for seguida do termo "def", retorna suas definições.
# Se for seguida do termo "conj", retorna todas as formas de conjugação.
# Pode-se filtrar pelos modos de conjugação, fornecendo após o "conj" o modo
# desejado:
# ind (indicativo), sub (subjuntivo), imp (imperativo), inf (infinitivo)
#
# Uso: zzdicportugues palavra [def|conj [ind|sub|conj|imp|inf]]
# Ex.: zzdicportugues bolacha
#      zzdicportugues verbo conj sub
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-02-26
# Versão: 10
# Licença: GPL
# Requisitos: zzsemacento zzminusculas zztrim
# ----------------------------------------------------------------------------
zzdicportugues ()
{
	zzzz -h dicportugues "$1" && return

	local url='http://dicio.com.br'
	local ini='^Significado de '
	local fim='^Definição de '
	local palavra=$(echo "$1" | zzminusculas)
	local padrao=$(echo "$palavra" | zzsemacento)
	local contador=1
	local resultado conteudo

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso dicportugues; return 1; }

	# Verificando se a palavra confere na pesquisa
	until test "$resultado" = "$palavra"
	do
		conteudo=$($ZZWWWDUMP "$url/$padrao")
		resultado=$(
		echo "$conteudo" |
			sed -n "
			/^Significado de /{
				s/^Significado de //
				s/ *$//
				p
				}" |
			zzminusculas
			)
		test -n "$resultado" || { zztool erro "Palavra não encontrada"; return 1; }

		# Incrementando o contador no padrão
		padrao=$(echo "$padrao" | sed 's/_[0-9]*$//')
		contador=$((contador + 1))
		padrao=${padrao}_${contador}
	done

	case "$2" in
	def) ini='^Definição de '; fim=' escrit[ao] ao contrário: ' ;;
	conj)
		ini='^ *Infinitivo:';  fim='(Rimas com |Anagramas de )'
		case "$3" in
			ind)        ini='^ *Indicativo'; fim='^ *Subjuntivo' ;;
			sub | conj) ini='^ *Subjuntivo'; fim='^ *Imperativo' ;;
			imp)        ini='^ *Imperativo'; fim='^ *Infinitivo' ;;
			inf)        ini='^ *Infinitivo *$' ;;
		esac
	;;
	esac

	case "$2" in
	conj)
		echo "$conteudo" |
		awk '/'"$ini"'/, /'"$fim"'/ ' |
			sed '
				{
				/^ *INDICATIVO *$/d;
				/^ *Indicativo *$/d;
				/^ *SUBJUNTIVO *$/d;
				/^ *Subjuntivo *$/d;
				#/^ *CONJUNTIVO *$/d
				#/^ *Conjuntivo *$/d
				/^ *IMPERATIVO *$/d;
				/^ *Imperativo *$/d;
				/^ *INFINITIVO *$/d;
				/^ *Infinitivo *$/d;
				/Rimas com /d;
				/Anagramas de /d;
				/^ *$/d;
				s/^ *//;
				s/^\*/\
&/;
				#s/ do Indicativo/&\
#/;
				#s/ do Subjuntivo/&\
#/;
				#s/ do Conjuntivo/&\
#/;
				#s/\* Imperativo Afirmativo/&\
#/;
				#s/\* Imperativo Negativo/&\
#/;
				#s/\* Imperativo/&\
#/;
				#s/\* Infinitivo Pessoal/&\
#/;
				s/^[a-z]/ &/g;
				#p
				}' |
				zztrim
	;;
	*)
		echo "$conteudo" |
		awk '/'"$ini"'/, /'"$fim"'/ ' |
			sed "
				1d
				/^Definição de /d
				/^Sinônimos de /{N;d;}
				/Mais sinônimos /d
				/^Antônimos de /{N;d;}
				/Mais antônimos /d" |
			zztrim
	;;
	esac
}

# ----------------------------------------------------------------------------
# zzdicsinonimos
# http://www.sinonimos.com.br/
# Procura sinônimos para um termo.
# Uso: zzdicsinonimos termo
# Ex.: zzdicsinonimos deste modo
#
# Autor: gabriell nascimento <gabriellhrn (a) gmail com>
# Desde: 2013-04-15
# Versão: 3
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zzdicsinonimos ()
{

	zzzz -h dicsinonimos "$1" && return

	local url='http://www.sinonimos.com.br/busca.php'
	local palavra="$*"
	local parametro_busca=$( echo "$palavra" | sed "$ZZSEDURL" )

	# Verifica se recebeu parâmetros
	if test -z "$1"
	then
		zztool -e uso dicsinonimos
		return 1
	fi

	# Faz a busca do termo e limpa, deixando somente os sinônimos
	# O sed no final separa os sentidos, caso a palavra tenha mais de um
	$ZZWWWDUMP "${url}?q=${parametro_busca}" |
		sed -n "
			/[0-9]\{1,\} sinônimos\{0,1\} d/,/«/ {
				/[0-9]\{1,\} sinônimos\{0,1\} d/d
				/«/d
				/^$/d

				# Linhas em branco antes de Foo:
				/^ *[A-Z]/ { x;p;x; }

				p
			}" |
		zztrim
}

# ----------------------------------------------------------------------------
# zzdiffpalavra
# Mostra a diferença entre dois textos, palavra por palavra.
# Útil para conferir revisões ortográficas ou mudanças pequenas em frases.
# Obs.: Se tiver muitas *linhas* diferentes, use o comando diff.
# Uso: zzdiffpalavra arquivo1 arquivo2
# Ex.: zzdiffpalavra texto-orig.txt texto-novo.txt
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-07-23
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzdiffpalavra ()
{
	zzzz -h diffpalavra "$1" && return

	local esc
	local tmp1=$(zztool mktemp diffpalavra)
	local tmp2=$(zztool mktemp diffpalavra)
	local n=$(printf '\a')

	# Verificação dos parâmetros
	test $# -ne 2 && { zztool -e uso diffpalavra; return 1; }

	# Verifica se os arquivos existem
	zztool arquivo_legivel "$1" || return 1
	zztool arquivo_legivel "$2" || return 1

	# Deixa uma palavra por linha e marca o início de parágrafos
	sed "s/^[[:blank:]]*$/$n$n/;" "$1" | tr ' ' '\n' > "$tmp1"
	sed "s/^[[:blank:]]*$/$n$n/;" "$2" | tr ' ' '\n' > "$tmp2"

	# Usa o diff para comparar as diferenças e formata a saída,
	# agrupando as palavras para facilitar a leitura do resultado
	diff -U 100 "$tmp1" "$tmp2" |
		sed 's/^ /=/' |
		sed '
			# Script para agrupar linhas consecutivas de um mesmo tipo.
			# O tipo da linha é o seu primeiro caractere. Ele não pode
			# ser um espaço em branco.
			#     +um
			#     +dois
			#     .one
			#     .two
			# vira:
			#     +um dois
			#     .one two

			# Apaga os cabeçalhos do diff
			1,3 d

			:join

			# Junta linhas consecutivas do mesmo tipo
			N

			# O espaço em branco é o separador
			s/\n/ /

			# A linha atual é do mesmo tipo da anterior?
			/^\(.\).* \1[^ ]*$/ {

				# Se for a última linha, mostra tudo e sai
				$ s/ ./ /g
				$ q

				# Caso contrário continua juntando...
				b join
			}
			# Opa, linha diferente (antiga \n antiga \n ... \n nova)

			# Salva uma cópia completa
			h

			# Apaga a última linha (nova) e mostra as anteriores
			s/\(.*\) [^ ]*$/\1/
			s/ ./ /g
			p

			# Volta a cópia, apaga linhas antigas e começa de novo
			g
			s/.* //
			$ !b join
			# Mas se for a última linha, acabamos por aqui' |
		sed 's/^=/ /' |

		# Restaura os parágrafos
		tr "$n" '\n' |

		# Podemos mostrar cores?
		if test "$ZZCOR" = 1
		then
			# Pinta as linhas antigas de vermelho e as novas de azul
			esc=$(printf '\033')
			sed "
				s/^-.*/$esc[31;1m&$esc[m/
				s/^+.*/$esc[36;1m&$esc[m/"
		else
			# Sem cores? Que chato. Só mostra então.
			cat -
		fi

	rm -f "$tmp1" "$tmp2"
}

# ----------------------------------------------------------------------------
# zzdistro
# Lista o ranking das distribuições no DistroWatch.
# Sem argumentos lista dos últimos 6 meses
# Se o argumento for 1, 3, 6 ou 12 é a ranking nos meses correspondente.
# Se o argumento for 2002 até o ano passado, é a ranking final desse ano.
# Se o primeiro argumento for -l, lista os links da distribuição no site.
#
# Uso: zzdistro [-l] [meses|ano]
# Ex.: zzdistro
#      zzdistro 2010  # Ranking em 2010
#      zzdistro 3     # Ranking dos últimos 3 meses.
#      zzdistro       # Ranking dos últimos 6 meses, com os links.
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-06-15
# Versão: 2
# Licença: GPL
# Requisitos: zzcolunar
# ----------------------------------------------------------------------------
zzdistro ()
{
	zzzz -h distro "$1" && return

	local url="http://distrowatch.com/"
	local lista=0
	local meses="1 4
3 13
6 26
12 52"

	test "$1" = "-l" && { lista=1; shift; }
	case $1 in
	1 | 3 | 6 | 12) url="${url}index.php?dataspan=$(echo "$meses" | awk '$1=='$1' {print $2}')"; shift ;;
	*)
	zztool testa_numero $1 && test $1 -ge 2002 -a $1 -lt $(date +%Y) && url="${url}index.php?dataspan=$1" && shift ;;
	esac

	test -n "$1" && { zztool -e uso distro; return 1; }

	$ZZWWWHTML "$url" | sed '1,/>Rank</d' |
	awk -F'"' '
		/phr1/ || /<th class="News">[0-9]{1,3}<\/th>/ {
			printf "%s\t", $3
			getline
			printf "%s\thttp://distrowatch.com/%s\n", $5, $4
		}
	' |
	sed 's/<[^>]*>//g;s/>//g' |
	if [ $lista -eq 1 ]
	then
		expand -t 4,18 | zzcolunar -w 60 2
	else
		sed 's/ *http.*//' | expand -t 4 | zzcolunar 4
	fi
}

# ----------------------------------------------------------------------------
# zzdivisores
# Lista todos os divisores de um número inteiro e positivo, maior que 2.
#
# Uso: zzdivisores <número>
# Ex.: zzdivisores 1400
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-25
# Versão: 3
# Licença: GPL
# Requisitos: zzfatorar
# ----------------------------------------------------------------------------
zzdivisores ()
{
	zzzz -h divisores "$1" && return

	test -n "$1" || { zztool -e uso divisores; return 1; }

	local fatores fator divisores_temp divisor divisor_atual
	local divisores="1"

	if zztool testa_numero "$1" && test $1 -ge 2
	then
		# Decompõe o número em fatores primos
		fatores=$(zzfatorar --no-bc $1 | cut -f 2 -d "|" | zztool lines2list)

		# Se for primo informa 1 e ele mesmo
		zztool grep_var 'primo' "$fatores" && { echo "1 $1"; return; }

		for fator in $fatores
		do
			# Para cada fator primo, multiplica-se pelos divisores já conhecidos
			for divisor in $divisores
			do
				divisor_atual=$(($fator * $divisor))

				# Apenas armazenando se divisor não existir
				echo "$divisores_temp" | zztool list2lines | grep "^${divisor_atual}$" > /dev/null
				if test $? -eq 1
				then
					divisores_temp=$( echo "$divisores_temp $divisor_atual")
				fi
			done

			# Reabastece a variável divisores eliminando repetições
			divisores=$(echo "$divisores $divisores_temp" | zztool list2lines | sort -n | uniq | zztool lines2list)
		done

		# Elimina-se as repetições e ordena-se os divisores encontrados
		echo $divisores | zztool list2lines | sort -n | uniq | zztool lines2list | zztool nl_eof
	else
		# Se não for um número válido exibe a ajuda
		zzdivisores -h
	fi
}

# ----------------------------------------------------------------------------
# zzdolar
# http://economia.uol.com.br/cotacoes
# Busca a cotação do dia do dólar (comercial, turismo).
# Uso: zzdolar
# Ex.: zzdolar
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Versão: 5
# Licença: GPL
# ----------------------------------------------------------------------------
zzdolar ()
{
	zzzz -h dolar "$1" && return

	# Faz a consulta e filtra o resultado
	$ZZWWWDUMP 'http://economia.uol.com.br/cotacoes' |
		egrep  'Dólar (com\.|tur\.|comercial)' |
		sed '
			# Linha original:
			# Dólar com. 2,6203 2,6212 -0,79%

			# faxina
			s/com\./Comercial/
			s/tur\./Turismo /
			s/^  *Dólar //
			s/^  *CAPTION: Dólar comercial -/  Compra Venda Variação/
		' |
		tr ' ' '\t'
}

# ----------------------------------------------------------------------------
# zzdominiopais
# http://www.ietf.org/timezones/data/iso3166.tab
# Busca a descrição de um código de país da internet (.br, .ca etc).
# Uso: zzdominiopais [.]código|texto
# Ex.: zzdominiopais .br
#      zzdominiopais br
#      zzdominiopais republic
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-15
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzdominiopais ()
{
	zzzz -h dominiopais "$1" && return

	local url='http://www.ietf.org/timezones/data/iso3166.tab'
	local cache=$(zztool cache dominiopais)
	local sistema='/usr/share/zoneinfo/iso3166.tab'
	local padrao=$1
	local arquivo

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso dominiopais; return 1; }

	# Se o padrão inicia com ponto, retira-o e casa somente códigos
	if test "${padrao#.}" != "$padrao"
	then
		padrao="^${padrao#.}"
	fi

	# Se já temos o arquivo de dados no sistema, tudo certo
	# Senão, baixa da internet
	if test -f "$sistema"
	then
		arquivo="$sistema"
	else
		arquivo="$cache"

		# Se o cache está vazio, baixa listagem da Internet
		if ! test -s "$cache"
		then
			$ZZWWWDUMP "$url" > "$cache"
		fi
	fi

	# O formato padrão de saída é BR - Brazil
	grep -i "$padrao" "$arquivo" |
		tr -s '\t ' ' ' |
		sed '/^#/d ; / - /! s/ / - /'
}

# ----------------------------------------------------------------------------
# zzdos2unix
# Converte arquivos texto no formato Windows/DOS (CR+LF) para o Unix (LF).
# Obs.: Também remove a permissão de execução do arquivo, caso presente.
# Uso: zzdos2unix arquivo(s)
# Ex.: zzdos2unix frases.txt
#      cat arquivo.txt | zzdos2unix
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzdos2unix ()
{
	zzzz -h dos2unix "$1" && return

	local arquivo
	local tmp=$(zztool mktemp dos2unix)
	local control_m=$(printf '\r')  # ^M, CR, \r

	# Sem argumentos, lê/grava em STDIN/STDOUT
	if test $# -eq 0
	then
		sed "s/$control_m*$//"

		# Facinho, terminou já
		return
	fi

	# Usuário passou uma lista de arquivos
	# Os arquivos serão sobrescritos, todo cuidado é pouco
	for arquivo
	do
		# O arquivo existe?
		zztool arquivo_legivel "$arquivo" || continue

		# Remove o \r
		cp "$arquivo" "$tmp" &&
		sed "s/$control_m*$//" "$tmp" > "$arquivo"

		# Segurança
		if test $? -ne 0
		then
			zztool erro "Ops, algum erro ocorreu em $arquivo"
			zztool erro "Seu arquivo original está guardado em $tmp"
			return 1
		fi

		# Remove a permissão de execução, comum em arquivos DOS
		chmod -x "$arquivo"

		echo "Convertido $arquivo"
	done

	# Remove o arquivo temporário
	rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# zzecho
# Mostra textos coloridos, sublinhados e piscantes no terminal (códigos ANSI).
# Opções: -f, --fundo       escolhe a cor de fundo
#         -l, --letra       escolhe a cor da letra
#         -p, --pisca       texto piscante
#         -s, --sublinhado  texto sublinhado
#         -N, --negrito     texto em negrito (brilhante em alguns terminais)
#         -n, --nao-quebra  não quebra a linha no final, igual ao echo -n
# Cores: preto vermelho verde amarelo azul roxo ciano branco
# Obs.: \t, \n e amigos são sempre interpretados (igual ao echo -e).
# Uso: zzecho [-f cor] [-l cor] [-p] [-s] [-N] [-n] [texto]
# Ex.: zzecho -l amarelo Texto em amarelo
#      zzecho -f azul -l branco -N Texto branco em negrito, com fundo azul
#      zzecho -p -s Texto piscante e sublinhado
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-09-02
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzecho ()
{
	zzzz -h echo "$1" && return

	local letra fundo negrito cor pisca sublinhado
	local quebra_linha='\n'

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-l | --letra)
				case "$2" in
					# Permite versões femininas também (--letra preta)
					pret[oa]       ) letra=';30' ;;
					vermelh[oa]    ) letra=';31' ;;
					verde          ) letra=';32' ;;
					amarel[oa]     ) letra=';33' ;;
					azul           ) letra=';34' ;;
					rox[oa] | rosa ) letra=';35' ;;
					cian[oa]       ) letra=';36' ;;
					branc[oa]      ) letra=';37' ;;
					*) zztool -e uso echo; return 1 ;;
				esac
				shift
			;;
			-f | --fundo)
				case "$2" in
					preto       ) fundo='40' ;;
					vermelho    ) fundo='41' ;;
					verde       ) fundo='42' ;;
					amarelo     ) fundo='43' ;;
					azul        ) fundo='44' ;;
					roxo | rosa ) fundo='45' ;;
					ciano       ) fundo='46' ;;
					branco      ) fundo='47' ;;
					*) zztool -e uso echo; return 1 ;;
				esac
				shift
			;;
			-N | --negrito    ) negrito=';1'    ;;
			-p | --pisca      ) pisca=';5'      ;;
			-s | --sublinhado ) sublinhado=';4' ;;
			-n | --nao-quebra ) quebra_linha='' ;;
			*) break ;;
		esac
		shift
	done

	test -n "$1" || { zztool -e uso echo; return 1; }

	# Mostra códigos ANSI somente quando necessário (e quando ZZCOR estiver ligada)
	if test "$ZZCOR" != '1' -o "$fundo$letra$negrito$pisca$sublinhado" = ''
	then
		printf -- "$*$quebra_linha"
	else
		printf -- "\033[$fundo$letra$negrito$pisca${sublinhado}m$*\033[m$quebra_linha"
	fi
}

# ----------------------------------------------------------------------------
# zzencoding
# Informa qual a codificação de um arquivo (ou texto via STDIN).
#
# Uso: zzencoding [arquivo]
# Ex.: zzencoding /etc/passwd          # us-ascii
#      zzencoding index-iso.html       # iso-8859-1
#      echo FooBar | zzencoding        # us-ascii
#      echo Bênção | zzencoding        # utf-8
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2015-03-21
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzencoding ()
{
	zzzz -h encoding "$1" && return

	zztool file_stdin "$@" |
		# A opção --mime é portável, -i/-I não
		# O - pode não ser portável, mas /dev/stdin não funciona
		file -b --mime - |
		sed -n 's/.*charset=//p'
}

# ----------------------------------------------------------------------------
# zzenglish
# http://www.dict.org
# Busca definições em inglês de palavras da língua inglesa em DICT.org.
# Uso: zzenglish palavra-em-inglês
# Ex.: zzenglish momentum
#
# Autor: Luciano ES
# Desde: 2008-09-07
# Versão: 6
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zzenglish ()
{
	zzzz -h english "$1" && return

	test -n "$1" || { zztool -e uso english; return 1; }

	local cinza verde amarelo fecha
	local url="http://www.dict.org/bin/Dict/"
	local query="Form=Dict1&Query=$1&Strategy=*&Database=*&submit=Submit query"

	if test $ZZCOR -eq 1
	then
		cinza=$(  printf '\033[0;34m')
		verde=$(  printf '\033[0;32;1m')
		amarelo=$(printf '\033[0;33;1m')
		fecha=$(  printf '\033[m')
	fi

	echo "$query" |
		$ZZWWWPOST "$url" |
		sed "
			# pega o trecho da página que nos interessa
			/[0-9]\{1,\} definitions\{0,1\} found/,/_______________/!d
			s/____*//

			# protege os colchetes dos sinônimos contra o cinza escuro
			s/\[syn:/@SINONIMO@/g

			# aplica cinza escuro em todos os colchetes (menos sinônimos)
			s/\[/$cinza[/g

			# aplica verde nos colchetes dos sinônimos
			s/@SINONIMO@/$verde[syn:/g

			# 'fecha' as cores de todos os sinônimos
			s/\]/]$fecha/g

			# # pinta a pronúncia de amarelo - pode estar delimitada por \\ ou //
			s/\\\\[^\\]\{1,\}\\\\/$amarelo&$fecha/g
			s|/[^/]\{1,\}/|$amarelo&$fecha|g

			# cabeçalho para tornar a separação entre várias consultas mais visível no terminal
			/[0-9]\{1,\} definitions\{0,1\} found/ {
				H
				s/.*/==================== DICT.ORG ====================/
				p
				x
			}" |
		zztrim -V -r
}

# ----------------------------------------------------------------------------
# zzenviaemail
# Envia email via ssmtp.
# Opções:
#   -h, --help     exibe a ajuda.
#   -v, --verbose  exibe informações para debug durante o processamento.
#   -V, --version  exibe a versão.
#   -f, --from     email do remetente.
#   -t, --to       email dos destinatários (separe com vírgulas, sem espaço).
#   -c, --cc       email dos destinatários em cópia (vírgulas, sem espaço).
#   -b, --bcc      emails em cópia oculta (vírgulas, sem espaço).
#   -s, --subject  o assunto do email.
#   -e, --mensagem arquivo que contém a mensagem/corpo do email.
# Uso: zzenviaemail -f email -t email [-c email] [-b email] -s assunto -m msg
# Ex.: zzenviaemail -f quem_envia@dominio.com -t quem_recebe@dominio.com \
#      -s "Teste de e-mail" -m "./arq_msg.eml"
#
# Autor: Lauro Cavalcanti de Sa <lauro (a) ecdesa com>
# Desde: 2009-09-17
# Versão: 2
# Licença: GPLv2
# Requisitos: ssmtp
# ----------------------------------------------------------------------------
zzenviaemail ()
{
	zzzz -h enviaemail "$1" && return

	# Declara variaveis.
	local fromail tomail ccmail bccmail subject msgbody
	local envia_data=`date +"%Y%m%d_%H%M%S_%N"`
	local script_eml=$(zztool cache enviaemail "${envia_data}.eml")
	local nparam=0

	# Opcoes de linha de comando
	while test $# -ge 1
	do
		case "$1" in
			-f | --from)
				test -n "$2" || { zztool -e uso enviaemail; set +x; return 1; }
				fromail=$2
				nparam=$(($nparam + 1))
				shift
				;;
			-t | --to)
				test -n "$2" || { zztool -e uso enviaemail; set +x; return 1; }
				tomail=$2
				nparam=$(($nparam + 1))
				shift
				;;
			-c | --cc)
				test -n "$2" || { zztool -e uso enviaemail; set +x; return 1; }
				ccmail=$2
				shift
				;;
			-b | --bcc)
				test -n "$2" || { zztool -e uso enviaemail; set +x; return 1; }
				bccmail=$2
				shift
				;;
			-s | --subject)
				test -n "$2" || { zztool -e uso enviaemail; set +x; return 1; }
				subject=$2
				nparam=$(($nparam + 1))
				shift
				;;
			-m | --mensagem)
				test -n "$2" || { zztool -e uso enviaemail; set +x; return 1; }
				mensagem=$2
				nparam=$(($nparam + 1))
				shift
				;;
			-v | --verbose)
				set -x
				;;
			*) { zztool -e uso enviaemail; set +x; return 1; } ;;
		esac
		shift
	done

	# Verifica numero minimo de parametros.
	if test "${nparam}" != 4 ; then
		{ zztool -e uso enviaemail; set +x; return 1; }
	fi

	# Verifica se o arquivo existe.
	zztool arquivo_existe "${mensagem}"

	# Monta e-mail padrao para envio via SMTP.
	echo "From: ${fromail} <${fromail}>" > ${script_eml}
	echo "To: ${tomail}" >> ${script_eml}
	echo "Cc: ${ccmail}" >> ${script_eml}
	echo "Bcc: ${bccmail}" >> ${script_eml}
	echo "Subject: ${subject}" >> ${script_eml}
	cat ${mensagem} >> ${script_eml}
	ssmtp -F ${fromail} ${tomail} ${ccmail} ${bccmail} < ${script_eml}
	if test -s "${script_eml}" ; then
		zztool cache rm enviaemail
	fi

	set +x
}

# ----------------------------------------------------------------------------
# zzestado
# Lista os estados do Brasil e suas capitais.
# Obs.: Sem argumentos, mostra a lista completa.
#
# Opções: --sigla        Mostra somente as siglas
#         --nome         Mostra somente os nomes
#         --capital      Mostra somente as capitais
#         --slug         Mostra somente os slugs (nome simplificado)
#         --formato FMT  Você escolhe o formato de saída, use os tokens:
#                        {sigla}, {nome}, {capital}, {slug}, \n , \t
#         --python       Formata como listas/dicionários do Python
#         --javascript   Formata como arrays do JavaScript
#         --php          Formata como arrays do PHP
#         --html         Formata usando a tag <SELECT> do HTML
#         --xml          Formata como arquivo XML
#         --url,--url2   Exemplos simples de uso da opção --formato
#
# Uso: zzestado [opção]
# Ex.: zzestado                      # [mostra a lista completa]
#      zzestado --sigla              # AC AL AP AM BA …
#      zzestado --html               # <option value="AC">AC - Acre</option> …
#      zzestado --python             # siglas = ['AC', 'AL', 'AP', …
#      zzestado --formato '{sigla},'             # AC,AL,AP,AM,BA,…
#      zzestado --formato '{sigla} - {nome}\n'   # AC - Acre …
#      zzestado --formato '{capital}-{sigla}\n'  # Rio Branco-AC …
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-21
# Versão: 5
# Licença: GPL
# Requisitos: zzpad
# ----------------------------------------------------------------------------
zzestado ()
{
	zzzz -h estado "$1" && return

	local sigla nome slug capital fmt resultado

	# {sigla}:{nome}:{slug}:{capital}
	local dados="\
AC:Acre:acre:Rio Branco
AL:Alagoas:alagoas:Maceió
AP:Amapá:amapa:Macapá
AM:Amazonas:amazonas:Manaus
BA:Bahia:bahia:Salvador
CE:Ceará:ceara:Fortaleza
DF:Distrito Federal:distrito-federal:Brasília
ES:Espírito Santo:espirito-santo:Vitória
GO:Goiás:goias:Goiânia
MA:Maranhão:maranhao:São Luís
MT:Mato Grosso:mato-grosso:Cuiabá
MS:Mato Grosso do Sul:mato-grosso-do-sul:Campo Grande
MG:Minas Gerais:minas-gerais:Belo Horizonte
PA:Pará:para:Belém
PB:Paraíba:paraiba:João Pessoa
PR:Paraná:parana:Curitiba
PE:Pernambuco:pernambuco:Recife
PI:Piauí:piaui:Teresina
RJ:Rio de Janeiro:rio-de-janeiro:Rio de Janeiro
RN:Rio Grande do Norte:rio-grande-do-norte:Natal
RS:Rio Grande do Sul:rio-grande-do-sul:Porto Alegre
RO:Rondônia:rondonia:Porto Velho
RR:Roraima:roraima:Boa Vista
SC:Santa Catarina:santa-catarina:Florianópolis
SP:São Paulo:sao-paulo:São Paulo
SE:Sergipe:sergipe:Aracaju
TO:Tocantins:tocantins:Palmas"


	case "$1" in
		--sigla  ) echo "$dados" | cut -d : -f 1 ;;
		--nome   ) echo "$dados" | cut -d : -f 2 ;;
		--slug   ) echo "$dados" | cut -d : -f 3 ;;
		--capital) echo "$dados" | cut -d : -f 4 ;;

		--formato)
			fmt="$2"
			echo "$dados" |
				while IFS=':' read sigla nome slug capital
				do
					resultado=$(printf %s "$fmt" | sed "
						s/{sigla}/$sigla/g
						s/{nome}/$nome/g
						s/{slug}/$slug/g
						s/{capital}/$capital/g
					")
					printf "$resultado"
				done
		;;
		--python | --py)
			sigla=$(  zzestado --formato "'{sigla}', "   | sed 's/, $//')
			nome=$(   zzestado --formato "'{nome}', "    | sed 's/, $//')
			capital=$(zzestado --formato "'{capital}', " | sed 's/, $//')

			printf   'siglas = [%s]\n\n' "$sigla"
			printf    'nomes = [%s]\n\n' "$nome"
			printf 'capitais = [%s]\n\n' "$capital"

			echo 'estados = {'
			zzestado --formato "  '{sigla}': '{nome}',\n"
			echo '}'
			echo
			echo 'estados = {'
			zzestado --formato "  '{sigla}': ('{nome}', '{capital}', '{slug}'),\n"
			echo '}'
		;;
		--php)
			sigla=$(  zzestado --formato '"{sigla}", '   | sed 's/, $//')
			nome=$(   zzestado --formato '"{nome}", '    | sed 's/, $//')
			capital=$(zzestado --formato '"{capital}", ' | sed 's/, $//')

			printf   '$siglas = array(%s);\n\n' "$sigla"
			printf    '$nomes = array(%s);\n\n' "$nome"
			printf '$capitais = array(%s);\n\n' "$capital"

			echo '$estados = array('
			zzestado --formato '  "{sigla}" => "{nome}",\n'
			echo ');'
			echo
			echo '$estados = array('
			zzestado --formato '  "{sigla}" => array("{nome}", "{capital}", "{slug}"),\n'
			echo ');'
		;;
		--javascript | --js)
			sigla=$(  zzestado --formato "'{sigla}', "   | sed 's/, $//')
			nome=$(   zzestado --formato "'{nome}', "    | sed 's/, $//')
			capital=$(zzestado --formato "'{capital}', " | sed 's/, $//')

			printf   'var siglas = [%s];\n\n' "$sigla"
			printf    'var nomes = [%s];\n\n' "$nome"
			printf 'var capitais = [%s];\n\n' "$capital"

			echo 'var estados = {'
			zzestado --formato "  {sigla}: '{nome}',\n" | sed '$ s/,$//'
			echo '};'
			echo
			echo 'var estados = {'
			zzestado --formato "  {sigla}: ['{nome}', '{capital}', '{slug}'],\n" | sed '$ s/,$//'
			echo '}'
		;;
		--html)
			echo '<select>'
			zzestado --formato '  <option value="{sigla}">{sigla} - {nome}</option>\n'
			echo '</select>'
		;;
		--xml)
			echo '<estados>'
			zzestado --formato '\t<uf sigla="{sigla}">\n\t\t<nome>{nome}</nome>\n\t\t<capital>{capital}</capital>\n\t\t<slug>{slug}</slug>\n\t</uf>\n'
			echo '</estados>'
		;;
		--url)
			zzestado --formato 'http://foo.{sigla}.gov.br\n' | tr '[A-Z]' '[a-z]'
		;;
		--url2)
			zzestado --formato 'http://foo.com.br/{slug}/\n'
		;;
		*)
			echo "$dados" |
				while IFS=':' read sigla nome slug capital
				do
					echo "$sigla    $(zzpad 22 $nome) $capital"
				done
		;;
	esac
}

# ----------------------------------------------------------------------------
# zzextensao
# Informa a extensão de um arquivo.
# Obs.: Caso o arquivo não possua extensão, retorna vazio "".
# Uso: zzextensao arquivo
# Ex.: zzextensao /tmp/arquivo.txt       # resulta em "txt"
#      zzextensao /tmp/arquivo           # resulta em ""
#
# Autor: Lauro Cavalcanti de Sa <lauro (a) ecdesa com>
# Desde: 2009-09-21
# Versão: 3
# Licença: GPLv2
# ----------------------------------------------------------------------------
zzextensao ()
{
	zzzz -h extensao "$1" && return

	# Declara variaveis.
	local nome_arquivo extensao arquivo

	test -n "$1" || { zztool -e uso extensao; return 1; }


	arquivo="$1"

	# Extrai a extensao.
	nome_arquivo=`echo "$arquivo" | awk 'BEGIN { FS = "/" } END { print $NF }'`
	extensao=`echo "$nome_arquivo" | awk 'BEGIN { FS = "." } END { print $NF }'`
	if test "$extensao" = "$nome_arquivo" -o ".$extensao" = "$nome_arquivo" ; then
		extensao=""
	fi

	test -n "$extensao" && echo "$extensao"
}

# ----------------------------------------------------------------------------
# zzfatorar
# http://www.primos.mat.br
# Fatora um número em fatores primos.
# Com as opções:
#   --atualiza: atualiza o cache com 10 mil primos (padrão e rápida).
#   --atualiza-1m: atualiza o cache com 1 milhão de primos (mais lenta).
#   --bc: saída apenas da expressão, que pode ser usado no bc, awk ou etc.
#   --no-bc: saída apenas do fatoramento.
#    por padrão exibe tanto o fatoramento como a expressão.
#
# Se o número for primo, é exibido a mensagem apenas.
#
# Uso: zzfatorar [--atualiza|--atualiza-1m] [--bc|--no-bc] <número>
# Ex.: zzfatorar 1458
#      zzfatorar --bc 1296
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-14
# Versão: 3
# Licença: GPL
# Requisitos: zzjuntalinhas zzdos2unix
# ----------------------------------------------------------------------------
zzfatorar ()
{
	zzzz -h fatorar "$1" && return

	local url='http://www.primos.mat.br/primeiros_10000_primos.txt'
	local cache=$(zztool cache fatorar)
	local linha_atual=1
	local primo_atual=2
	local bc=0
	local num_atual saida tamanho indice

	test -n "$1" || { zztool -e uso fatorar; return 1; }

	while  test "${1#-}" != "$1"
	do
		case "$1" in
		'--atualiza')
			# Força atualizar o cache
			zztool atualiza fatorar
			shift
		;;
		'--atualiza-1m')
			# Atualiza o cache com uma listagem com 1 milhão de números primos.
			# É um processo bem mais lento, devendo ser usado quando o cache normal não atende.
			rm -f "$cache"
			if which 7z >/dev/null 2>&1 && ! which factor >/dev/null 2>&1
			then
				zztool eco "Atualizando cache."
				wget -q http://www.primos.mat.br/dados/50M_part1.7z -O /tmp/primos.7z
				7z e /tmp/primos.7z >/dev/null 2>&1
				rm -f /tmp/primos.7z
				awk '{for(i=1;i<=NF;i++) print $i }' 50M_part1.txt > "$cache"
				rm -f 50M_part1.txt
				zzdos2unix "$cache" >/dev/null 2>&1
				zztool eco "Cache atualizado."
			fi
			shift
		;;
		'--bc')
			# Apenas sai a expressão matemática que pode ser usado no bc ou awk
			test "$bc" -eq 0 && bc=1
			shift
		;;
		'--no-bc')
			# Apenas sai a fatoração
			test "$bc" -eq 0 && bc=2
			shift
		;;
		*) break;;
		esac
	done

	# Apenas para numeros inteiros
	if zztool testa_numero "$1" && test $1 -ge 2
	then

		if which factor >/dev/null 2>&1
		then
			# Se existe o camando factor usa-o
			factor $1 | sed 's/.*: //g' | awk '{for(i=1;i<=NF;i++) print $i }' | uniq > "$cache"
			primo_atual=$(head -n 1 "$cache")
		elif ! test -s "$cache"
		then
			# Se o cache está vazio, baixa listagem da Internet
			$ZZWWWDUMP "$url" | awk '{for(i=1;i<=NF;i++) print $i }' > "$cache"
		fi

		# Se o número fornecido for primo, retorna-o e sai
		grep "^${1}$" ${cache} > /dev/null
		test "$?" = "0" && { echo "$1 é um número primo."; return; }

		num_atual="$1"
		tamanho=${#1}

		# Enquanto a resultado for maior que o número primo continua, ou dentro dos primos listados no cache.
		while test ${num_atual} -gt ${primo_atual} -a ${linha_atual} -le $(zztool num_linhas "$cache")
		do

			# Repetindo a divisão pelo número primo atual, enquanto for exato
			while test $((${num_atual} % ${primo_atual})) -eq 0
			do
				test "$bc" != "1" && printf "%${tamanho}s | %s\n" ${num_atual} ${primo_atual}
				num_atual=$((${num_atual} / ${primo_atual}))
				saida="${saida} ${primo_atual}"
				test "$bc" != "1" -a "${num_atual}" = "1" && { printf "%${tamanho}s |\n" 1; break; }
			done

			# Se o número atual é primo
			grep "^${num_atual}$" ${cache} > /dev/null
			if test "$?" = "0"
			then
				saida="${saida} ${num_atual}"
				if test "$bc" != "1"
				then
					printf "%${tamanho}s | %s\n" ${num_atual} ${num_atual}
					printf "%${tamanho}s |\n" 1
				fi
				break
			fi

			# Definindo o número primo a ser usado
			if test "${num_atual}" != "1"
			then
				linha_atual=$((${linha_atual} + 1))
				primo_atual=$(sed -n "${linha_atual}p" "$cache")
				test ${#primo_atual} -eq 0 && { zztool erro "Valor não fatorável nessa configuração do script!"; return 1; }
			fi
		done

		if test "$bc" != "2"
		then
			saida=$(echo "$saida " | sed 's/ /&\
/g' | sed '/^ *$/d;s/^ *//g' | uniq -c | awk '{ if ($1==1) {print $2} else {print $2 "^" $1} }' | zzjuntalinhas -d ' * ')
			test "$bc" -eq "1" || echo
			echo "$1 = $saida"
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzfeed
# Leitor de Feeds RSS, RDF e Atom.
# Se informar a URL de um feed, são mostradas suas últimas notícias.
# Se informar a URL de um site, mostra a URL do(s) Feed(s).
# Obs.: Use a opção -n para limitar o número de resultados (Padrão é 10).
# Para uso via pipe digite dessa forma: "zzfeed -", mesma forma que o cat.
#
# Uso: zzfeed [-n número] URL...
# Ex.: zzfeed http://aurelio.net/feed/
#      zzfeed -n 5 aurelio.net/feed/          # O http:// é opcional
#      zzfeed aurelio.net funcoeszz.net       # Mostra URL dos feeds
#      cat arquivo.rss | zzfeed -             # Para uso via pipe
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-03
# Versão: 7
# Licença: GPL
# Requisitos: zzxml zzunescape zztrim zzutf8
# ----------------------------------------------------------------------------
zzfeed ()
{
	zzzz -h feed "$1" && return

	local url formato tag_mae tmp
	local limite=10

	# Opções de linha de comando
	if test "$1" = '-n'
	then
		limite=$2
		shift
		shift
	fi

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso feed; return 1; }

	# Verificação básica
	if ! zztool testa_numero "$limite"
	then
		zztool erro "Número inválido para a opção -n: $limite"
		return 1
	fi

	# Zero notícias? Tudo bem.
	test $limite -eq 0 && return 0

	#-----------------------------------------------------------------
	# ATOM:
	# <?xml version="1.0" encoding="utf-8"?>
	# <feed xmlns="http://www.w3.org/2005/Atom">
	#     <title>Example Feed</title>
	#     <subtitle>A subtitle.</subtitle>
	#     <link href="http://example.org/" />
	#     ...
	#     <entry>
	#         <title>Atom-Powered Robots Run Amok</title>
	#         <link href="http://example.org/2003/12/13/atom03" />
	#         ...
	#     </entry>
	# </feed>
	#-----------------------------------------------------------------
	# RSS:
	# <?xml version="1.0" encoding="UTF-8" ?>
	# <rss version="2.0">
	# <channel>
	#     <title>RSS Title</title>
	#     <description>This is an example of an RSS feed</description>
	#     <link>http://www.someexamplerssdomain.com/main.html</link>
	#     ...
	#     <item>
	#         <title>Example entry</title>
	#         <link>http://www.wikipedia.org/</link>
	#         ...
	#     </item>
	# </channel>
	# </rss>
	#-----------------------------------------------------------------

	# Para cada URL que o usuário informou...
	for url
	do
		tmp=$(zztool mktemp feed)

		# Só mostra a url se houver mais de uma
		test $# -gt 1 && zztool eco "* $url"

		# Baixa e limpa o conteúdo do feed
		if test "$1" = "-"
		then
			zztool file_stdin "$@"
		else
			$ZZWWWHTML "$url"
		fi |
			zzutf8 |
			zzxml --tidy > "$tmp"

		# Tenta identificar o formato: <feed> é Atom, <rss> é RSS
		formato=$(grep -e '^<feed[ >]' -e '^<rss[ >]' -e '^<rdf[:>]' "$tmp")

		# Afinal, isso é um feed ou não?
		if test -n "$formato"
		then
			### É um feed, vamos mostrar as últimas notícias.
			# Atom ou RSS, as manchetes estão sempre na tag <title>,
			# que por sua vez está dentro de <item> ou <entry>.

			if zztool grep_var '<feed' "$formato"
			then
				tag_mae='entry'
			else
				tag_mae='item'
			fi

			# Extrai as tags <title> e formata o resultado
			zzxml --tag $tag_mae "$tmp" |
				zzxml --tag title --untag |
				sed "$limite q" |
				zzunescape --html |
				zztrim
		else
			### Não é um feed, pode ser um site normal.
			# Vamos tentar descobrir o endereço do(s) Feed(s).
			# <link rel="alternate" type="application/rss+xml" href="http://...">

			cat "$tmp" |
				grep -i \
					-e '^<link .*application/rss+xml' \
					-e '^<link .*application/rdf+xml' \
					-e '^<link .*application/atom+xml' |
				# Se não tiver href= não vale (o site do Terra é um exemplo)
				grep -i 'href=' |
				# Extrai a URL, apagando o que tem ao redor
				sed "
					s/.*[Hh][Rr][Ee][Ff]=//
					s/[ >].*//
					s/['\"]//g"
		fi

		rm -f "$tmp"

		# Linha em branco para separar resultados
		[ $# -gt 1 ] && echo
	done
}

# ----------------------------------------------------------------------------
# zzferiado
# Verifica se a data passada por parâmetro é um feriado ou não.
# Caso não seja passado nenhuma data é pego a data atual.
# Pode-se configurar a variável ZZFERIADO para os feriados regionais.
# O formato é o dd/mm:descrição, por exemplo: 20/11:Consciência negra.
# Uso: zzferiado -l [ano] | [data]
# Ex.: zzferiado 25/12/2008
#      zzferiado -l
#      zzferiado -l 2010
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-11-21
# Versão: 6
# Licença: GPLv2
# Requisitos: zzcarnaval zzcorpuschristi zzdiadasemana zzsextapaixao zzsemacento
# Tags: data
# ----------------------------------------------------------------------------
zzferiado ()
{
	zzzz -h feriado "$1" && return

	local feriados carnaval corpuschristi
	local hoje data sextapaixao ano listar
	local dia diasemana descricao linha

	hoje=$(date '+%d/%m/%Y')

	# Verifica se foi passado o parâmetro -l
	if test "$1" = "-l"; then
		# Se não for passado $2 pega o ano atual
		ano=${2:-$(basename $hoje)}

		# Seta a flag listar
		listar=1

		# Teste da variável ano
		zztool -e testa_ano $ano || return 1
	else
		# Se não for passada a data é pega a data de hoje
		data=${1:-$hoje}

		# Verifica se a data é valida
		zztool -e testa_data "$data" || return 1

		# Uma coisa interessante, como data pode ser usada com /(20/11/2008)
		# podemos usar o basename e dirname para pegar o que quisermos
		# Ex.: dirname 25/12/2008 ->  25/12
		#      basename 25/12/2008 -> 2008
		#
		# Pega só o dia e o mes no formato: dd/mm
		data=$(dirname $data)
		ano=$(basename ${1:-$hoje})
	fi

	# Para feriados Estaduais ou regionais Existe a variável de
	# ambiente ZZFERIADO que pode ser configurada no $HOME/.bashrc e
	# colocar as datas com dd/mm:descricao
	carnaval=$(dirname $(zzcarnaval $ano ) )
	sextapaixao=$(dirname $(zzsextapaixao $ano ) )
	corpuschristi=$(dirname $(zzcorpuschristi $ano ) )
	feriados="01/01:Confraternização Universal $carnaval:Carnaval $sextapaixao:Sexta-ferida da Paixao 21/04:Tiradentes 01/05:Dia do Trabalho $corpuschristi:Corpu Christi 07/09:Independência do Brasil 12/10:Nossa Sra. Aparecida 02/11:Finados 15/11:Proclamação da República 25/12:Natal $ZZFERIADO"

	# Verifica se lista ou nao, caso negativo verifica se a data escolhida é feriado
	if test "$listar" = "1"; then

		# Pega os dados, coloca 1 por linha, inverte dd/mm para mm/dd,
		# ordena, inverte mm/dd para dd/mm
		echo $feriados |
		sed 's# \([0-3]\)#~\1#g' |
		tr '~' '\n' |
		sed 's#^\(..\)/\(..\)#\2/\1#g' |
		sort -n |
		sed 's#^\(..\)/\(..\)#\2/\1#g' |
		while read linha; do
			dia=$(echo $linha | cut -d: -f1)
			diasemana=$(zzdiadasemana $dia/$ano | zzsemacento)
			descricao=$(echo $linha | cut -d: -f2)
			printf "%s %-15s %s\n" "$dia" "$diasemana" "$descricao" |
				sed 's/terca-feira/terça-feira/ ; s/ sabado / sábado /'
			# ^ Estou tirando os acentos do dia da semana e depois recolocando
			# pois o printf não lida direito com acentos. O %-15s não fica
			# exatamente com 15 caracteres quando há acentos.
		done
	else
		# Verifica se a data está dentro da lista de feriados
		# e imprime o resultado
		if zztool grep_var "$data" "$feriados"; then
			echo "É feriado: $data/$ano"
		else
			echo "Não é feriado: $data/$ano"
		fi
	fi

	return 0
}

# ----------------------------------------------------------------------------
# zzfoneletra
# Conversão de telefones contendo letras para apenas números.
# Uso: zzfoneletra telefone
# Ex.: zzfoneletra 2345-LINUX              # Retorna 2345-54689
#      echo 5555-HELP | zzfoneletra        # Retorna 5555-4357
#
# Autor: Rodolfo de Faria <rodolfo faria (a) fujifilm com br>
# Desde: 2006-10-17
# Versão: 1
# Licença: GPL
# Requisitos: zzmaiusculas
# ----------------------------------------------------------------------------
zzfoneletra ()
{
	zzzz -h foneletra "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |
		zzmaiusculas |
		sed y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/
		# Um Sed faz tudo, é uma tradução letra a letra
}

# ----------------------------------------------------------------------------
# zzfrenteverso2pdf
# Combina 2 arquivos, frentes.pdf e versos.pdf, em um único frenteverso.pdf.
# Opções:
#   -rf, --frentesreversas  informa ordem reversa no arquivo frentes.pdf.
#   -rv, --versosreversos   informa ordem reversa no arquivo versos.pdf.
#    -d, --diretorio        informa o diretório de entrada/saída. Padrão=".".
#    -v, --verbose          exibe informações de debug durante a execução.
# Uso: zzfrenteverso2pdf [-rf] [-rv] [-d diretorio]
# Ex.: zzfrenteverso2pdf
#      zzfrenteverso2pdf -rf
#      zzfrenteverso2pdf -rv -d "/tmp/dir_teste"
#
# Autor: Lauro Cavalcanti de Sa <lauro (a) ecdesa com>
# Desde: 2009-09-17
# Versão: 3
# Licença: GPLv2
# Requisitos: pdftk
# ----------------------------------------------------------------------------
zzfrenteverso2pdf ()
{
	zzzz -h frenteverso2pdf "$1" && return

	# Declara variaveis.
	local n_frentes n_versos dif n_pag_frente n_pag_verso
	local sinal_frente="+"
	local sinal_verso="+"
	local dir="."
	local arq_frentes="frentes.pdf"
	local arq_versos="versos.pdf"
	local ini_frente=0
	local ini_verso=0
	local numberlist=""
	local n_pag=1

	# Determina o diretorio que estao os arquivos a serem mesclados.
	# Opcoes de linha de comando
	while test $# -ge 1
	do
		case "$1" in
			-rf | --frentesreversas) sinal_frente="-" ;;
			-rv | --versosreversos) sinal_verso="-" ;;
			-d | --diretorio)
				test -n "$2" || { zztool -e uso frenteverso2pdf; return 1; }
				dir=$2
				shift
				;;
			-v | --verbose)
				set -x
				;;
			*) { zztool -e uso frenteverso2pdf; set +x; return 1; } ;;
		esac
		shift
	done

	# Verifica se os arquivos existem.
	if test ! -s "$dir/$arq_frentes" -o ! -s "$dir/$arq_versos" ; then
		zztool erro "ERRO: Um dos arquivos $dir/$arq_frentes ou $dir/$arq_versos nao existe!"
		return 1
	fi

	# Determina o numero de paginas de cada arquivo.
	n_frentes=`pdftk "$dir/$arq_frentes" dump_data | grep "NumberOfPages" | cut -d" " -f2`
	n_versos=`pdftk "$dir/$arq_versos" dump_data | grep "NumberOfPages" | cut -d" " -f2`

	# Verifica a compatibilidade do numero de paginas entre os dois arquivos.
	dif=`expr $n_frentes - $n_versos`
	if test $dif -lt 0 -o $dif -gt 1 ; then
		echo "CUIDADO: O numero de paginas dos arquivos nao parecem compativeis!"
	fi

	# Cria ordenacao das paginas.
	if test "$sinal_frente" = "-" ; then
		ini_frente=`expr $n_frentes + 1`
	fi
	if test "$sinal_verso" = "-" ; then
		ini_verso=`expr $n_versos + 1`
	fi

	while test $n_pag -le $n_frentes ; do
		n_pag_frente=`expr $ini_frente $sinal_frente $n_pag`
		numberlist="$numberlist A$n_pag_frente"
		n_pag_verso=`expr $ini_verso $sinal_verso $n_pag`
		if test $n_pag -le $n_versos; then
			numberlist="$numberlist B$n_pag_verso"
		fi
		n_pag=$(($n_pag + 1))
	done

	# Cria arquivo mesclado.
	pdftk A="$dir/$arq_frentes" B="$dir/$arq_versos" cat $numberlist output "$dir/frenteverso.pdf" dont_ask

}

# ----------------------------------------------------------------------------
# zzfutebol
# http://esporte.uol.com.br/futebol/agenda-de-jogos
# Mostra todos os jogos de futebol marcados para os próximos dias.
# Ou os resultados de jogos recentes.
# Além de mostrar os times que jogam, o script também mostra o dia,
# o horário e por qual campeonato será ou foi o jogo.
#
# Suporta um argumento que pode ser um dos dias da semana, como:
#  hoje, amanhã, segunda, terça, quarta, quinta, sexta, sábado, domingo.
#
# Ou um ou dois argumentos para ver resultados do jogos:
#   resultado ou placar, que pode ser acompanhado de hoje, ontem, anteontem.
#
# Um filtro com nome do campeonato, nome do time, ou horário de uma partida.
#
# Uso: zzfutebol [resultado | placar ] [ argumento ]
# Ex.: zzfutebol                 # Todas as partidas nos próximos dias.
#      zzfutebol hoje            # Partidas que acontecem hoje.
#      zzfutebol sabado          # Partidas que acontecem no sábado.
#      zzfutebol libertadores    # Próximas partidas da Libertadores.
#      zzfutebol 21h             # Partidas que começam entre 21 e 22h.
#      zzfutebol resultado       # Placar dos jogos já ocorridos.
#      zzfutebol placar ontem    # Placar dos jogos de ontem.
#      zzfutebol placar espanhol # Placar dos jogos do Campeonato Espanhol.
#
# Autor: Jefferson Fausto Vaz (www.faustovaz.com)
# Desde: 2014-04-08
# Versão: 8
# Licença: GPL
# Requisitos: zzdata zzdatafmt zztrim zzpad
# ----------------------------------------------------------------------------
zzfutebol ()
{

	zzzz -h futebol "$1" && return
	local url="http://esporte.uol.com.br/futebol/central-de-jogos/proximos-jogos"
	local linha campeonato time1 time2

	case "$1" in
		resultado | placar) url="http://esporte.uol.com.br/futebol/central-de-jogos/resultados"; shift;;
		ontem | anteontem)  url="http://esporte.uol.com.br/futebol/central-de-jogos/resultados";;
	esac

	$ZZWWWDUMP "$url" |
	sed -n '/[0-9]h[0-9]/{N;N;p;}' |
	sed '
		s/[A-Z][A-Z][A-Z] //
		s/__*//
		/º / { s/.*\([0-9]\{1,\}º\)/\1/ }' |
	zztrim |
	awk '
		NR % 3 == 1 { campeonato = $0 }
		NR % 3 == 2 { time1 = $0; if ($(NF-1) ~ /^[0-9]{1,}$/) { penais1=$(NF -1)} else {penais1=""} }
		NR % 3 == 0 {
			if ($NF ~ /^[0-9]{1,}$/) { reserva=$NF " "; $NF=""; } else { reserva="" }
			if ($(NF-1) ~ /^[0-9]{1,}$/ ) { penais2=$(NF -1)} else {penais2=""}
			if (length(penais1)>0 && length(penais2)>0) {
				sub(" " penais1, "", time1)
				sub(" " penais2, "")
				penais1 = " ( " penais1
				penais2 = penais2 " ) "
			}
			else {penais1="";penais2=""}
			print campeonato ":" time1 penais1 ":" penais2 reserva $0
		}
		' |
	case "$1" in
		hoje | amanh[aã] | segunda | ter[cç]a | quarta | quinta | sexta | s[aá]bado | domingo | ontem | anteontem)
			grep --color=never -e $( zzdata $1 | zzdatafmt -f 'DD/MM/AA' )
			;;
		*)
			grep --color=never -i "${1:-.}"
			;;
	esac |
	while read linha
	do
		campeonato=$(echo $linha | cut -d":" -f 1)
		time1=$(echo $linha | cut -d":" -f 2)
		time2=$(echo $linha | cut -d":" -f 3 | zztrim)
		echo "$(zzpad -r 40 $campeonato) $(zzpad -l 25 $time1) x $time2"
	done
}

# ----------------------------------------------------------------------------
# zzgeoip
# Localiza geograficamente seu IP de Internet ou um que seja informado.
# Uso: zzgeoip [ip]
# Ex.: zzgeoip
#      zzgeoip 187.75.22.192
#
# Autor: Alexandre Magno <alexandre.mbm (a) gmail com>
# Desde: 2013-07-06
# Versão: 3
# Licença: GPLv2
# Requisitos: zzxml zzipinternet zzecho zzminiurl
# ----------------------------------------------------------------------------
zzgeoip ()
{
	zzzz -h geoip "$1" && return

	local ip pagina latitude longintude cidade uf pais mapa
	local url='http://geoip.s12.com.br'

	if test $# -ge 2
	then
		zztool -e uso geoip
		return 1
	elif test -n "$1"
	then
		zztool -e testa_ip "$1"
		test $? -ne 0 && zztool -e uso geoip && return 1
		ip="$1"
	else
		ip=$(zzipinternet)
	fi

	pagina=$(
		$ZZWWWHTML http://geoip.s12.com.br?ip=$ip |
			zzxml --tidy --untag --tag td |
			sed '/^[[:blank:]]*$/d;/&/d' |
			awk '{if ($0 ~ /:/) { printf "\n%s",$0 } else printf $0}'
	)

	cidade=$(   echo "$pagina" | grep 'Cidade:'    | cut -d : -f 2         )
 	uf=$(       echo "$pagina" | grep 'Estado:'    | cut -d : -f 2         )
	pais=$(     echo "$pagina" | grep 'País:'      | cut -d : -f 2         )
	latitude=$( echo "$pagina" | grep 'Latitude:'  | cut -d : -f 2 | tr , .)
	longitude=$(echo "$pagina" | grep 'Longitude:' | cut -d : -f 2 | tr , .)

	mapa=$(zzminiurl "$url/mapa.asp?lat=$latitude&lon=$longitude&cidade=$cidade&estado=$uf")

	zzecho -n '       IP: '; zzecho -l verde -N "${ip:- }"
	zzecho -n '   Cidade: '; zzecho -N "${cidade:- }"
	zzecho -n '   Estado: '; zzecho -N "${uf:- }"
	zzecho -n '     País: '; zzecho -N "${pais:- }"
	zzecho -n ' Latitude: '; zzecho -l amarelo "${latitude:- }"
	zzecho -n 'Longitude: '; zzecho -l amarelo "${longitude:- }"
	zzecho -n '     Mapa: '; zzecho -l azul "${mapa:- }"
}

# ----------------------------------------------------------------------------
# zzglobo
# Mostra a programação da Rede Globo do dia.
# Uso: zzglobo
# Ex.: zzglobo
#
# Autor: Vinícius Venâncio Leite <vv.leite (a) gmail com>
# Desde: 2007-11-30
# Versão: 5
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zzglobo ()
{
	zzzz -h globo "$1" && return

	local url="http://vejonatv.com.br/programacao/globo-rede.html"

	$ZZWWWDUMP "$url" |
		sed -n "/Hoje \[[0-9]*\-[0-9]*\-[0-9]*\]/,/Amanhã .*/p" |
		sed '$d' |
		uniq |
		zztrim
}

# ----------------------------------------------------------------------------
# zzgoogle
# http://google.com
# Pesquisa no Google diretamente pela linha de comando.
# Uso: zzgoogle [-n <número>] palavra(s)
# Ex.: zzgoogle receita de bolo de abacaxi
#      zzgoogle -n 5 ramones papel higiênico cachorro
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-04-03
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
# FIXME: zzgoogle rato roeu roupa rei roma [PPS], [PDF]
zzgoogle ()
{
	zzzz -h google "$1" && return

	local padrao
	local limite=10
	local url='http://www.google.com.br/search'

	# Opções de linha de comando
	if test "$1" = '-n'
	then
		limite="$2"
		shift
		shift

		zztool -e testa_numero "$limite" || return 1
	fi

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso google; return 1; }

	# Prepara o texto a ser pesquisado
	padrao=$(echo "$*" | sed "$ZZSEDURL")
	test -n "$padrao" || return 0

	# Pesquisa, baixa os resultados e filtra
	#
	# O Google condensa tudo em um única longa linha, então primeiro é preciso
	# inserir quebras de linha antes de cada resultado. Identificadas as linhas
	# corretas, o filtro limpa os lixos e formata o resultado.

	$ZZWWWHTML -cookies "$url?q=$padrao&num=$limite&ie=UTF-8&oe=UTF-8&hl=pt-BR" |
		sed 's/<p>/\
@/g' |
		sed '
			/^@<a href="\([^"]*\)">/!d
			s|^@<a href="/url?q=||
			s/<\/a>.*//

			s/<table.*//
			/^http/!d
			s/&amp;sa.*">/ /

			# Remove tags HTML
			s/<[^>]*>//g

			# Restaura os caracteres especiais
			s/&gt;/>/g
			s/&lt;/</g
			s/&quot;/"/g
			s/&nbsp;/ /g
			s/&amp;/\&/g

			# Restaura caracteres url encoded
			s/%3F/?/g
			s/%3D/\=/g
			s/%26/\&/g

			s/\([^ ]*\) \(.*\)/\2\
  \1\
/'
}

# ----------------------------------------------------------------------------
# zzgravatar
# http://www.gravatar.com
# Monta a URL completa para o Gravatar do email informado.
#
# Opções: -t, --tamanho N      Tamanho do avatar (padrão 80, máx 512)
#         -d, --default TIPO   Tipo do avatar substituto, se não encontrado
#
# Se não houver um avatar para o email, a opção --default informa que tipo
# de avatar substituto será usado em seu lugar:
#     mm          Mistery Man, a silhueta de uma pessoa (não muda)
#     identicon   Padrão geométrico, muda conforme o email
#     monsterid   Monstros, muda cores e rostos
#     wavatar     Rostos, muda características e cores
#     retro       Rostos pixelados, tipo videogame antigo 8-bits
# Veja exemplos em http://gravatar.com/site/implement/images/
#
# Uso: zzgravatar [--tamanho N] [--default tipo] email
# Ex.: zzgravatar fulano@dominio.com.br
#      zzgravatar -t 128 -d mm fulano@dominio.com.br
#      zzgravatar --tamanho 256 --default retro fulano@dominio.com.br
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-06
# Versão: 1
# Licença: GPL
# Requisitos: zzmd5 zzminusculas zztrim
# ----------------------------------------------------------------------------
zzgravatar ()
{
	zzzz -h gravatar "$1" && return

	# Instruções de implementação:
	# http://gravatar.com/site/implement/
	#
	# Exemplo de URL do Gravatar, com tamanho de 96 e MisteryMan:
	# http://www.gravatar.com/avatar/e583bca48acb877efd4a29229bf7927f?size=96&default=mm

	local email default extra codigo
	local tamanho=80  # padrão caso não informado é 80
	local tamanho_maximo=512
	local defaults="mm:identicon:monsterid:wavatar:retro"
	local url='http://www.gravatar.com/avatar/'

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-t | --tamanho)
				tamanho="$2"
				extra="$extra&size=$tamanho"
				shift
				shift
			;;
			-d | --default)
				default="$2"
				extra="$extra&default=$default"
				shift
				shift
			;;
			*)
				break
			;;
		esac
	done

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso gravatar; return 1; }

	# Guarda o email informado, sempre em minúsculas
	email=$(zztrim "$1" | zzminusculas)

	# Foi passado um número mesmo?
	if ! zztool testa_numero "$tamanho" || test "$tamanho" = 0
	then
		zztool erro "Número inválido para a opção -t: $tamanho"
		return 1
	fi

	# Temos uma limitação de tamanho
	if test $tamanho -gt $tamanho_maximo
	then
		zztool erro "O tamanho máximo para a imagem é $tamanho_maximo"
		return 1
	fi

	# O default informado é válido?
	if test -n "$default" && ! zztool grep_var ":$default:"  ":$defaults:"
	then
		zztool erro "Valor inválido para a opção -d: '$default'"
		return 1
	fi

	# Calcula o hash do email
	codigo=$(printf "$email" | zzmd5)

	# Verifica o hash e o coloca na URL
	if test -n "$codigo"
	then
		url="$url$codigo"
	else
		zztool erro "Houve um erro na geração do código MD5 do email"
		return 1
	fi

	# Adiciona as opções extras na URL
	if test -n "$extra"
	then
		url="$url?${extra#&}"
	fi

	# Tá feito, essa é a URL final
	echo "$url"
}

# ----------------------------------------------------------------------------
# zzhastebin
# http://hastebin.com/
# Gera link para arquivos de texto em geral.
#
# Uso: zzhastebin [arquivo]
# Ex.: zzhastebin helloworld.sh
#
# Autor: Jones Dias <diasjones07 (a) gmail.com>
# Desde: 2015-02-12
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzhastebin ()
{

	zzzz -h hastebin "$1" && return

	local hst="http://hastebin.com/"
	local uri
	local ext=$(basename $1 | cut -d\. -f2)

	# Verifica o parametro da função
	if ! zztool arquivo_legivel "$1"
	then
		zztool -e uso hastebin
		return 1
	fi

	# Retorna o ID
	uri="$(curl -s --data-binary @$1 ${hst}documents | cut -d\" -f 4)"

	# Imprime link
	echo "$hst$uri.$ext"
}

# ----------------------------------------------------------------------------
# zzhexa2str
# Converte os bytes em hexadecimal para a string equivalente.
# Uso: zzhexa2str [bytes]
# Ex.: zzhexa2str 40 4d 65 6e 74 65 42 69 6e 61 72 69 61   # sem prefixo
#      zzhexa2str 0x42 0x69 0x6E                           # com prefixo 0x
#      echo 0x42 0x69 0x6E | zzhexa2str
#
# Autor: Fernando Mercês <fernando (a) mentebinaria.com.br>
# Desde: 2012-02-24
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzhexa2str ()
{
	zzzz -h hexa2str "$1" && return

	local hexa

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

		# Um hexa por linha
		tr -s '\t ' '\n' |

		# Remove o prefixo opcional
		sed 's/^0x//' |

		# hexa -> str
		while read hexa
		do
			printf "\\x$hexa"
		done

	# Quebra de linha final
	echo
}

# ----------------------------------------------------------------------------
# zzhora
# Faz cálculos com horários.
# A opção -r torna o cálculo relativo à primeira data, por exemplo:
#   02:00 - 03:30 = -01:30 (sem -r) e 22:30 (com -r)
#
# Uso: zzhora [-r] hh:mm [+|- hh:mm] ...
# Ex.: zzhora 8:30 + 17:25        # preciso somar dois horários
#      zzhora 12:00 - agora       # quando falta para o almoço?
#      zzhora -12:00 + -5:00      # horas negativas!
#      zzhora 1000                # quanto é 1000 minutos?
#      zzhora -r 5:30 - 8:00      # que horas ir dormir para acordar às 5:30?
#      zzhora -r agora + 57:00    # e daqui 57 horas, será quando?
#      zzhora 1:00 + 2:00 + 3:00 - 4:00 - 0:30   # cálculos múltiplos
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Versão: 4
# Licença: GPL
# ----------------------------------------------------------------------------
zzhora ()
{
	zzzz -h hora "$1" && return

	local hhmm1 hhmm2 operacao hhmm1_orig hhmm2_orig
	local hh1 mm1 hh2 mm2 n1 n2 resultado parcial exitcode negativo
	local horas minutos dias horas_do_dia hh mm hh_dia extra
	local relativo=0
	local neg1=0
	local neg2=0

	# Opções de linha de comando
	if test "$1" = '-r'
	then
		relativo=1
		shift
	fi

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso hora; return 1; }

	# Cálculos múltiplos? Exemplo: 1:00 + 2:00 + 3:00 - 4:00
	if test $# -gt 3
	then
		if test $relativo -eq 1
		then
			zztool erro "A opção -r não suporta cálculos múltiplos"
			return 1
		fi

		# A zzhora continua simples, suportando apenas dois números
		# e uma única operação entre eles. O que fiz para suportar
		# múltiplos, é chamar a própria zzhora várias vezes, a cada
		# número novo, usando o resultado do cálculo anterior.
		#
		# Início  : parcial = $1
		# Rodada 1: parcial = zzhora $parcial $2 $3
		# Rodada 2: parcial = zzhora $parcial $4 $5
		# Rodada 3: parcial = zzhora $parcial $6 $7
		# e assim vai.
		#
		parcial="$1"
		shift

		# Daqui pra frente é de dois em dois: operador (+-) e a hora.
		# Se tiver um número ímpar de argumentos, tem algo errado.
		#
		if test $(($# % 2)) -eq 1
		then
			zztool -e uso hora
			return 1
		fi

		# Agora sim, vamos fazer o loop e calcular todo mundo
		while test $# -ge 2
		do
			resultado=$(zzhora "$parcial" "$1" "$2")
			exitcode=$?

			# Salva somente o horário. Ex: 02:59 (0d 2h 59m)
			parcial=$(echo "$resultado" | cut -d ' ' -f 1)

			# Esses dois já foram. Venham os próximos!
			shift
			shift
		done

		# Loop terminou, então já temos o total final.
		# Basta mostrar e encerrar, saindo com o exitcode retornado
		# pela execução da última zzhora. Vai que deu erro?
		#
		if test $exitcode -ne 0
		then
			echo "$resultado"
		else
			zztool erro "$resultado"
		fi
		return $exitcode
	fi

	# Dados informados pelo usuário (com valores padrão)
	hhmm1="$1"
	operacao="${2:-+}"
	hhmm2="${3:-0}"
	hhmm1_orig="$hhmm1"
	hhmm2_orig="$hhmm2"

	# Somente adição e subtração são permitidas
	if test "$operacao" != '-' -a "$operacao" != '+'
	then
		zztool erro "Operação inválida '$operacao'. Deve ser + ou -."
		return 1
	fi

	# Remove possíveis sinais de negativo do início
	hhmm1="${hhmm1#-}"
	hhmm2="${hhmm2#-}"

	# Guarda a informação de quem era negativo no início
	test "$hhmm1" != "$hhmm1_orig" && neg1=1
	test "$hhmm2" != "$hhmm2_orig" && neg2=1

	# Atalhos bacanas para a hora atual
	test "$hhmm1" = 'agora' -o "$hhmm1" = 'now' && hhmm1=$(date +%H:%M)
	test "$hhmm2" = 'agora' -o "$hhmm2" = 'now' && hhmm2=$(date +%H:%M)

	# Se as horas não foram informadas, coloca zero
	test "${hhmm1#*:}" = "$hhmm1" && hhmm1="0:$hhmm1"
	test "${hhmm2#*:}" = "$hhmm2" && hhmm2="0:$hhmm2"

	# Extrai horas e minutos para variáveis separadas
	hh1="${hhmm1%:*}"
	mm1="${hhmm1#*:}"
	hh2="${hhmm2%:*}"
	mm2="${hhmm2#*:}"

	# Retira o zero das horas e minutos menores que 10
	hh1="${hh1#0}"
	mm1="${mm1#0}"
	hh2="${hh2#0}"
	mm2="${mm2#0}"

	# Se tiver algo faltando, salva como zero
	hh1="${hh1:-0}"
	mm1="${mm1:-0}"
	hh2="${hh2:-0}"
	mm2="${mm2:-0}"

	# Validação dos dados
	if ! (zztool testa_numero "$hh1" && zztool testa_numero "$mm1")
	then
		zztool erro "Horário inválido '$hhmm1_orig', deve ser HH:MM"
		return 1
	fi
	if ! (zztool testa_numero "$hh2" && zztool testa_numero "$mm2")
	then
		zztool erro "Horário inválido '$hhmm2_orig', deve ser HH:MM"
		return 1
	fi

	# Os cálculos são feitos utilizando apenas minutos.
	# Então é preciso converter as horas:minutos para somente minutos.
	n1=$((hh1*60 + mm1))
	n2=$((hh2*60 + mm2))

	# Restaura o sinal para as horas negativas
	test $neg1 -eq 1 && n1="-$n1"
	test $neg2 -eq 1 && n2="-$n2"

	# Tudo certo, hora de fazer o cálculo
	resultado=$(($n1 $operacao $n2))

	# Resultado negativo, seta a flag e remove o sinal de menos "-"
	if test $resultado -lt 0
	then
		negativo='-'
		resultado="${resultado#-}"
	fi

	# Agora é preciso converter o resultado para o formato hh:mm

	horas=$((resultado/60))
	minutos=$((resultado%60))
	dias=$((horas/24))
	horas_do_dia=$((horas%24))

	# Restaura o zero dos minutos/horas menores que 10
	hh="$horas"
	mm="$minutos"
	hh_dia="$horas_do_dia"
	test $hh -le 9 && hh="0$hh"
	test $mm -le 9 && mm="0$mm"
	test $hh_dia -le 9 && hh_dia="0$hh_dia"

	# Decide como mostrar o resultado para o usuário.
	#
	# Relativo:
	#   $ zzhora -r 10:00 + 48:00            $ zzhora -r 12:00 - 13:00
	#   10:00 (2 dias)                       23:00 (ontem)
	#
	# Normal:
	#   $ zzhora 10:00 + 48:00               $ zzhora -r 12:00 - 13:00
	#   58:00 (2d 10h 0m)                    -01:00 (0d 1h 0m)
	#
	if test $relativo -eq 1
	then

		# Relativo

		# Somente em resultados negativos o relativo é útil.
		# Para valores positivos não é preciso fazer nada.
		if test -n "$negativo"
		then
			# Para o resultado negativo é preciso refazer algumas contas
			minutos=$(( (60-minutos) % 60))
			dias=$((horas/24 + (minutos>0) ))
			hh_dia=$(( (24 - horas_do_dia - (minutos>0)) % 24))
			mm="$minutos"

			# Zeros para dias e minutos menores que 10
			test $mm -le 9 && mm="0$mm"
			test $hh_dia -le 9 && hh_dia="0$hh_dia"
		fi

		# "Hoje", "amanhã" e "ontem" são simpáticos no resultado
		case $negativo$dias in
			1)
				extra='amanhã'
			;;
			-1)
				extra='ontem'
			;;
			0 | -0)
				extra='hoje'
			;;
			*)
				extra="$negativo$dias dias"
			;;
		esac

		echo "$hh_dia:$mm ($extra)"
	else

		# Normal

		echo "$negativo$hh:$mm (${dias}d ${horas_do_dia}h ${minutos}m)"
	fi
}

# ----------------------------------------------------------------------------
# zzhoracerta
# http://www.worldtimeserver.com
# Mostra a hora certa de um determinado local.
# Se nenhum parâmetro for passado, são listados as localidades disponíveis.
# O parâmetro pode ser tanto a sigla quando o nome da localidade.
# A opção -s realiza a busca somente na sigla.
# Uso: zzhoracerta [-s] local
# Ex.: zzhoracerta rio grande do sul
#      zzhoracerta -s br
#      zzhoracerta rio
#      zzhoracerta us-ny
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-03-29
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzhoracerta ()
{
	zzzz -h horacerta "$1" && return

	local codigo localidade localidades
	local cache=$(zztool cache horacerta)
	local url='http://www.worldtimeserver.com'

	# Opções de linha de comando
	if test "$1" = '-s'
	then
		shift
		codigo="$1"
	else
		localidade="$*"
	fi

	# Se o cache está vazio, baixa listagem da Internet
	# De: <li><a href="current_time_in_AR-JY.aspx">Jujuy</a></li>
	# Para: AR-JY -- Jujuy
	if ! test -s "$cache"
	then
		$ZZWWWHTML "$url/country.html" |
			grep 'current_time_in_' |
			sed 's/.*_time_in_// ; s/\.aspx">/ -- / ; s/<.*//' > "$cache"
	fi

	# Se nenhum parâmetro for passado, são listados os países disponíveis
	if ! test -n "$localidade$codigo"
	then
		cat "$cache"
		return
	fi

	# Faz a pesquisa por codigo ou texto
	if test -n "$codigo"
	then
		localidades=$(grep -i "^[^ ]*$codigo" "$cache")
	else
		localidades=$(grep -i "$localidade" "$cache")
	fi

	# Se mais de uma localidade for encontrada, mostre-as
	if test $(echo "$localidades" | sed -n '$=') != 1
	then
		echo "$localidades"
		return
	fi

	# A localidade existe?
	if ! test -n "$localidades"
	then
		zztool erro "Localidade \"$localidade$codigo\" não encontrada"
		return 1
	fi

	# Grava o código da localidade (BR-RS -- Rio Grande do Sul -> BR-RS)
	localidade=$(echo "$localidades" | sed 's/ .*//')

	# Faz a consulta e filtra o resultado
	$ZZWWWDUMP "$url/current_time_in_$localidade.aspx" |
		grep 'The current time' -B 2 -A 5
}

# ----------------------------------------------------------------------------
# zzhoramin
# Converte horas em minutos.
# Obs.: Se não informada a hora, usa o horário atual para o cálculo.
# Uso: zzhoramin [hh:mm]
# Ex.: zzhoramin
#      zzhoramin 10:53       # Retorna 653
#      zzhoramin -10:53      # Retorna -653
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-12-05
# Versão: 4
# Licença: GPLv2
# Requisitos: zzhora
# ----------------------------------------------------------------------------
zzhoramin ()
{

	zzzz -h horamin "$1" && return

	local mintotal hh mm hora operacao

	operacao='+'

	# Testa se o parâmetro passado é uma hora valida
	if ! zztool testa_hora "${1#-}"; then
		hora=$(zzhora agora | cut -d ' ' -f 1)
	else
		hora="$1"
	fi

	# Verifica se a hora é positiva ou negativa
	if test "${hora#-}" != "$hora"; then
		operacao='-'
	fi

	# passa a hora para hh e minuto para mm
	hh="${hora%%:*}"
	mm="${hora##*:}"

	# Retira o zero das horas e minutos menores que 10
	hh="${hh#0}"
	mm="${mm#0}"

	# Se tiver algo faltando, salva como zero
	hh="${hh:-0}"
	mm="${mm:-0}"

	# faz o cálculo
	mintotal=$(($hh * 60 $operacao $mm))

	# Tcharã!!!!
	echo "$mintotal"
}

# ----------------------------------------------------------------------------
# zzhorariodeverao
# Mostra as datas de início e fim do horário de verão.
# Obs.: Ano de 2008 em diante. Se o ano não for informado, usa o atual.
# Regra: 3º domingo de outubro/fevereiro, exceto carnaval (4º domingo).
# Uso: zzhorariodeverao [ano]
# Ex.: zzhorariodeverao
#      zzhorariodeverao 2009
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-24
# Versão: 1
# Licença: GPL
# Requisitos: zzcarnaval zzdata zzdiadasemana
# Tags: data
# ----------------------------------------------------------------------------
zzhorariodeverao ()
{
	zzzz -h horariodeverao "$1" && return

	local inicio fim data domingo_carnaval
	local dias_3a_semana="15 16 17 18 19 20 21"
	local ano="$1"

	# Se o ano não for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Validação
	zztool -e testa_ano "$ano" || return 1

	# Só de 2008 em diante...
	if test "$ano" -lt 2008
	then
		zztool erro 'Antes de 2008 não havia regra fixa para o horário de verão'
		return 1
	fi

	# Encontra os dias de início e término do horário de verão.
	# Sei que o algoritmo não é eficiente, mas é simples de entender.
	#
	for dia in $dias_3a_semana
	do
		data="$dia/10/$ano"
		test $(zzdiadasemana $data) = 'domingo' && inicio="$data"

		data="$dia/02/$((ano+1))"
		test $(zzdiadasemana $data) = 'domingo' && fim="$data"
	done

	# Exceção à regra: Se o domingo de término do horário de verão
	# coincidir com o Carnaval, adia o término para o próximo domingo.
	#
	domingo_carnaval=$(zzdata $(zzcarnaval $((ano+1)) ) - 2)
	test "$fim" = "$domingo_carnaval" && fim=$(zzdata $fim + 7)

	# Datas calculadas, basta mostrar o resultado
	echo "$inicio"
	echo "$fim"
}

# ----------------------------------------------------------------------------
# zzhowto
# http://www.ibiblio.org
# Procura documentos do tipo HOWTO.
# Uso: zzhowto [--atualiza] palavra
# Ex.: zzhowto apache
#      zzhowto --atualiza
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-08-27
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzhowto ()
{
	zzzz -h howto "$1" && return

	local padrao
	local cache=$(zztool cache howto)
	local url='http://www.ibiblio.org/pub/Linux/docs/HOWTO/other-formats/html_single/'

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso howto; return 1; }

	# Força atualização da listagem apagando o cache
	if test "$1" = '--atualiza'
	then
		zztool atualiza howto
		shift
	fi

	padrao=$1

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		$ZZWWWDUMP "$url" |
			grep 'text/html' |
			sed 's/^  *//; s/ [0-9][0-9]:.*//' > "$cache"
	fi

	# Pesquisa o termo (se especificado)
	if test -n "$padrao"
	then
		zztool eco "$url"
		grep -i "$padrao" "$cache"
	fi
}

# ----------------------------------------------------------------------------
# zziostat
# Monitora a utilização dos discos no Linux.
#
# Opções:
#   -t [número]    Mostra apenas os discos mais utilizados
#   -i [segundos]  Intervalo em segundos entre as coletas
#   -d [discos]    Mostra apenas os discos que começam com a string passada
#                  O padrão é 'sd'
#   -o [trwT]      Ordena os discos por:
#                      t (tps)
#                      r (read/s)
#                      w (write/s)
#                      T (total/s = read/s+write/s)
#
# Obs.: Se não for usada a opção -t, é mostrada a soma da utilização
#       de todos os discos.
#
# Uso: zziostat [-t número] [-i segundos] [-d discos] [-o trwT]
# Ex.: zziostat
#      zziostat -t 10
#      zziostat -i 5 -o T
#      zziostat -d emcpower
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2015-02-17
# Versão: 1
# Licença: GPL
# Requisitos: iostat
# ----------------------------------------------------------------------------
zziostat ()
{
	zzzz -h iostat "$1" && return

	local top line cycle tps reads writes totals
	local delay=2
	local orderby='t'
	local disk='sd'

	# Opcoes de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			-t )
				shift; top=$1
				zztool testa_numero $top || { echo "Número inválido $top"; return 1; }
				;;
			-i )
				shift; delay=$1
				zztool testa_numero $delay || { echo "Número inválido $delay"; return 1; }
				;;
			-d )
				shift; disk=$1
				;;
			-o )
				shift; orderby=$1
				if ! echo $orderby | grep -qs '^[rwtT]$'; then
					echo "Opção inválida '$orderby'"
					return 1
				fi
				;;
			 * )
				echo "Opção inválida $1"; return 1;;
		esac
		shift
	done

	# Coluna para ordenacao:
	# Device tps MB_read/s MB_wrtn/s MB_read MB_wrtn MB_total/s
	[ "$orderby" = "t" ] && orderby=2
	[ "$orderby" = "r" ] && orderby=3
	[ "$orderby" = "w" ] && orderby=4
	[ "$orderby" = "T" ] && orderby=7

	# Executa o iostat, le a saida e agrupa cada "ciclo de execucao"
	# -d device apenas, -m mostra saida em MB/s
	iostat -d -m $delay |
	while read line; do
		# faz o append da linha do iostat
		if [ "$line" ]; then
			cycle="$cycle
$line"
		# se for line for vazio, terminou de ler o ciclo de saida do iostat
		# mostra a saida conforme opcoes usadas
		else
			if [ "$top" ]; then
				clear
				date '+%d/%m/%y - %H:%M:%S'
				echo 'Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn        MB_total/s'
				echo "$cycle" |
					sed -n "/^${disk}[a-zA-Z]\+[[:blank:]]/p" |
					awk '{print $0"         "$3+$4}' |
					sort -k $orderby -r -n |
					head -$top
			else
				cycle=$(echo "$cycle" | sed -n "/^${disk}[a-zA-Z]\+[[:blank:]]/p")
				tps=$(echo "$cycle" | awk '{ sum += $2 } END { print sum }')
				reads=$(echo "$cycle" | awk '{ sum += $3 } END { print sum }')
				writes=$(echo "$cycle" | awk '{ sum += $4 } END { print sum }')
				totals=$(echo $reads $writes | awk '{print $1+$2}')
				echo "$(date '+%d/%m/%y - %H:%M:%S') TPS = $tps; Read = $reads MB/s; Write = $writes MB/s ; Total = $totals MB/s"
			fi
			cycle='' # zera ciclo
		fi
	done
}

# ----------------------------------------------------------------------------
# zzipinternet
# http://www.getip.com
# Mostra o seu número IP (externo) na Internet.
# Uso: zzipinternet
# Ex.: zzipinternet
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2005-09-01
# Versão: 4
# Licença: GPL
# ----------------------------------------------------------------------------
zzipinternet ()
{
	zzzz -h ipinternet "$1" && return

	local url='http://www.getip.com'

	# O resultado já vem pronto!
	$ZZWWWDUMP "$url" | sed -n 's/^Current IP: //p'
}

# ----------------------------------------------------------------------------
# zzjoin
# Junta as linhas de 2 ou mais arquivos, mantendo a sequência.
# Opções:
#  -o <arquivo> - Define o arquivo de saída.
#  -m - Toma como base o arquivo com menos linhas.
#  -M - Toma como base o arquivo com mais linhas.
#  -<numero> - Toma como base o arquivo na posição especificada.
#  -d - Define o separador entre as linhas dos arquivos juntados (padrão TAB).
#
# Sem opção, toma como base o primeiro arquivo declarado.
#
# Uso: zzjoin [-m | -M | -<numero>] [-o <arq>] [-d <sep>] arq1 arq2 [arqN] ...
# Ex.: zzjoin -m arq1 arq2 arq3      # Base no arquivo com menos linhas
#      zzjoin -2 arq1 arq2 arq3      # Base no segundo arquivo
#      zzjoin -o out.txt arq1 arq2   # Juntando para o arquivo out.txt
#      zzjoin -d ":" arq1 arq2       # Juntando linhas separadas por ":"
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-12-05
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzjoin ()
{
	zzzz -h join "$1" && return

	local lin_arq arquivo arq_saida sep
	local linhas=0
	local tipo=1

	# Opção -m ou -M, -numero ou -o
	while test "${1#-}" != "$1"
	do
		if test "$1" = "-o"
		then
			arq_saida="$2"
			shift
		elif test "$1" = "-d"
		then
			sep="$2"
			shift
		else
			tipo="${1#-}"
		fi
		shift
	done

	test -n "$2" || { zztool -e uso join; return 1; }

	for arquivo
	do
		# Especificar se vai se orientar pelo arquivo com mais ou menos linhas
		if test "$tipo" = "m" || test "$tipo" = "M"
		then
			lin_arq=$(zztool num_linhas "$arquivo")
			if test "$tipo" = "M" && test $lin_arq -gt $linhas
			then
				linhas=$lin_arq
			fi
			if test "$tipo" = "m" && (test $lin_arq -lt $linhas || test $linhas -eq 0)
			then
				linhas=$lin_arq
			fi
		fi

		# Verifica se arquivos são legíveis
		zztool arquivo_legivel "$arquivo" || { zztool erro "Um ou mais arquivos inexistentes ou ilegíveis."; return 1; }
	done

	# Se opção é um numero, o arquivo base para as linhas é o mesmo da posição equivalente
	if zztool testa_numero $tipo && test $tipo -le $#
	then
		arquivo=$(awk -v arg=$tipo 'BEGIN { print ARGV[arg] }' $* 2>/dev/null)
		linhas=$(zztool num_linhas "$arquivo")
	fi

	# Sem quantidade de linhas mínima não há junção.
	test "$linhas" -eq 0 && { zztool erro "Não há linhas para serem \"juntadas\"."; return 1; }

	# Onde a "junção" ocorre efetivamente.
	awk -v linhas_awk=$linhas -v saida_awk="$arq_saida" -v sep_awk="$sep" '
	BEGIN {
		sep_awk = (length(sep_awk)>0 ? sep_awk : "	")

		for (i = 1; i <= linhas_awk; i++) {
			for(j = 1; j < ARGC; j++) {
				if ((getline linha < ARGV[j]) > 0) {
					if (j > 1)
						saida = saida sep_awk linha
					else
						saida = linha
				}
			}
			if (length(saida_awk)>0)
				print saida >> saida_awk
			else
				print saida

			saida = ""
		}
	}' $* 2>/dev/null
}

# ----------------------------------------------------------------------------
# zzjquery
# Exibe a descrição da função jQuery informada.
#
# Opções:
#   --categoria[s]: Lista as Categorias da funções.
#   --lista: Lista todas as funções.
#   --lista <categoria>: Listas as funções dentro da categoria informada.
#
# Caso não seja passado o nome, serão exibidas informações acerca do $().
# Se usado o argumento -s, será exibida somente a sintaxe.
# Uso: zzjquery [-s] função
# Ex.: zzjquery gt
#      zzjquery -s gt
#
# Autor: Felipe Nascimento Silva Pena <felipensp (a) gmail com>
# Desde: 2007-12-04
# Versão: 5
# Licença: GPL
# Requisitos: zzcapitalize zzlimpalixo zzunescape zzxml
# ----------------------------------------------------------------------------
zzjquery ()
{
	zzzz -h jquery "$1" && return

	local url="http://api.jquery.com/"
	local url_aux lista_cat
	local sintaxe=0

	case "$1" in
	--lista)

		if test -n "$2"
		then
			lista_cat=$(echo "$2" | zzcapitalize)
			test "$lista_cat" = "Css" && lista_cat="CSS"
			url_aux=$(
				$ZZWWWHTML "$url" |
				awk '/<aside/,/aside>/{print}' |
				sed "/<ul class='children'>/,/<\/ul>/d" |
				zzxml --untag=aside --tag a |
				awk -F '"' '/href/ {printf $2 " "; getline; print}' |
				awk '$2 ~ /'$lista_cat'/ { print $1 }'
			)
			test -n "$url_aux" && url="$url_aux" || url=''
		fi

		zztool grep_var 'http:' "$url" || url="http:$url"

		if test -n "$url"
		then
			$ZZWWWHTML "$url" |
			sed -n '/title="Permalink to /{s/^[[:blank:]]*//;s/<[^>]*>//g;s/()//;p;}' |
			zzunescape --html
		fi

	;;
	--categoria | --categorias)

		$ZZWWWHTML "$url" |
		awk '/<aside/,/aside>/{print}' |
		sed "/<ul class='children'>/,/<\/ul>/d" |
		zzxml --tag li --untag  | zzlimpalixo | zzunescape --html

	;;
	*)
		test "$1" = "-s" && { sintaxe=1; shift; }

		if test -n "$1"
		then
			url_aux=$(
				$ZZWWWHTML "$url" |
				sed -n '/title="Permalink to /{s/^[[:blank:]]*//;s/()//g;p;}' |
				zzunescape --html |
				awk -F '[<>"]' '{print "http:" $3, $9 }' |
				awk '$2 ~ /^[.:]{0,1}'$1'[^a-z]*$/ { print $1 }'
			)
			test -n "$url_aux" && url="$url_aux" || url=''
		else
			url=${url}jQuery
		fi

		if test -n "$url"
		then
			for url_aux in $url
			do
				zztool grep_var 'http://' "$url_aux" || url_aux="http://$url_aux"
				zztool eco ${url_aux#*com/} | tr -d '/'
				$ZZWWWHTML "$url_aux" |
				zzxml --tag article |
				awk '/class="entry(-content| method)"/,/<\/article>/{ print }' |
				if test "$sintaxe" = "1"
				then
					awk '/<ul class="signatures">/,/<div class="longdesc"/ { print }' | awk '/<span class="name">/,/<\/span>/ { print }; /<h4 class="name">/,/<\/h4>/ { print };'
				else
					awk '
							/<ul class="signatures">/,/(<div class="longdesc"|<section class="entry-examples")/ { if ($0 ~ /<\/h4>/ || $0 ~ /<\/span>/ || $0 ~ /<\/div>/) { print } else { printf $0 }}
							/<span class="name">/,/<\/span>/ { if ($0 ~ /<span class="name">/) { printf "--\n\n" }; print $0 }
							/<p class="desc"/,/<\/p>/ { if ($0 ~ /<\/p>/) { print } else { printf $0 }}
						'
				fi|
				zzxml --untag | zzlimpalixo |
				awk '{if ($0 ~ /: *$/) { printf $0; getline; print} else print }' |
				sed 's/version added: .*//;s/^--//g;/Type: /d'
				echo
			done
		fi

	;;
	esac
}

# ----------------------------------------------------------------------------
# zzjuntalinhas
# Junta várias linhas em uma só, podendo escolher o início, fim e separador.
#
# Melhorias em relação ao comando paste -s:
# - Trata corretamente arquivos no formato Windows (CR+LF)
# - Lê arquivos ISO-8859-1 sem erros no Mac (o paste dá o mesmo erro do tr)
# - O separador pode ser uma string, não está limitado a um caractere
# - Opções -i e -f para delimitar somente um trecho a ser juntado
#
# Opções: -d sep        Separador a ser colocado entre as linhas (padrão: Tab)
#         -i, --inicio  Início do trecho a ser juntado (número ou regex)
#         -f, --fim     Fim do trecho a ser juntado (número ou regex)
#
# Uso: zzjuntalinhas [-d separador] [-i texto] [-f texto] arquivo(s)
# Ex.: zzjuntalinhas arquivo.txt
#      zzjuntalinhas -d @@@ arquivo.txt             # junta toda as linhas
#      zzjuntalinhas -d : -i 10 -f 20 arquivo.txt   # junta linhas 10 a 20
#      zzjuntalinhas -d : -i 10 arquivo.txt         # junta linha 10 em diante
#      cat /etc/named.conf | zzjuntalinhas -d '' -i '^[a-z]' -f '^}'
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-02
# Versão: 3
# Licença: GPL
# Requisitos: zzdos2unix
# ----------------------------------------------------------------------------
zzjuntalinhas ()
{
	zzzz -h juntalinhas "$1" && return

	local separador=$(printf '\t')  # tab
	local inicio='1'
	local fim='$'

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-d           ) separador="$2"; shift; shift;;
			-i | --inicio) inicio="$2"   ; shift; shift;;
			-f | --fim   ) fim="$2"      ; shift; shift;;
			*) break ;;
		esac
	done

	# Formata dados para o sed
	inicio=$(zztool endereco_sed "$inicio")
	fim=$(zztool endereco_sed "$fim")
	separador=$(echo "$separador" | sed 's:/:\\\/:g')

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |
		zzdos2unix |
		sed "
			# Exceção: Início e fim na mesma linha, mostra a linha e pronto
			$inicio {
				$fim {
					p
					d
				}
			}

			# O algoritmo é simples: ao entrar no trecho escolhido ($inicio)
			# vai guardando as linhas. Quando chegar no fim do trecho ($fim)
			# faz a troca das quebras de linha pelo $separador.

			$inicio, $fim {
				H
				$fim {
					s/.*//
					x
					s/^\n//
					s/\n/$separador/g
					p
					d
				}

				# Exceção: Não achei $fim e estou na última linha.
				# Este trecho não será juntado.
				$ {
					x
					s/^\n//
					p
				}

				d
			}"
}

# ----------------------------------------------------------------------------
# zzjuros
# Mostra a listagem de taxas de juros que o Banco Central acompanha.
# São instituições financeiras, que estão sob a supervisão do Banco Central.
# Com argumento numérico, detalha a listagem solicitada.
# A numeração fica entre 1 e 27
#
# Uso: zzjuros [numero consulta]
# Ex.: zzjuros
#      zzjuros 19  # Mostra as taxas de desconto de cheque para pessoa física.
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-05-06
# Versão: 2
# Licença: GPL
# Requisitos: zzxml zzunescape
# ----------------------------------------------------------------------------
zzjuros ()
{
	zzzz -h juros "$1" && return

	local nome
	local url='http://www.bcb.gov.br/pt-br/sfn/infopban/txcred/txjuros/Paginas/default.aspx'
	local cache=$(
				$ZZWWWHTML "$url" |
				sed -n '/Modalidades de/,/Histórico/p'|
				zzxml --tag a --tag strong |
				sed '/Historico.aspx/,$d;/^<\//d' |
				awk '/href|strong/ {
					printf $0 "|"
					getline
					print
					}' |
				sed '1d;$d;s/.*="//;s/">//' |
				awk '{if ($0 ~ /pt-br/) { print $0 "|" ++item } else print }'
				)

	# Testa se foi fornecido um numero dentre as opções disponiveis.
	if zztool testa_numero $1
	then
		test $1 -gt 27 -o $1 -lt 1 && { zztool -e uso juros; return 1; }

		# Buscando o nome e a url a ser pesquisada
		nome=$(echo "$cache" | grep "|${1}$" | cut -f 2 -d "|")
		url=$(echo "$cache" | grep "|${1}$" | zzunescape --html | cut -f 1 -d "|")
		url="http://www.bcb.gov.br${url}"

		# Fazendo a busca e filtrando no site do Banco Central.
		zztool eco "$nome"
		$ZZWWWDUMP "$url" |
		sed -n '/^ *Posição *$/,/^ *Atendimento/p' | sed '$d' |
		awk '{
			gsub(/  */," ")
			if (NR % 4 == 1) {linha1 = $0}
			if (NR % 4 == 2) {linha2 = $0}
			if (NR % 4 == 3) {linha3 = $0}
			if (NR % 4 == 0) {
				linha4 = $0
				printf "%-7s %-40s %8s %8s\n", linha1, linha2, linha3, linha4
			}
		}'

	else

		echo "$cache" |
		awk -F "|" '{
			if ($1 ~ /strong/) {
				if ($2 ~ /jurídica/) print ""
				print $2
			} else {
				printf "%3s. %s\n", $3, $2
			}
		}'

	fi
}

# ----------------------------------------------------------------------------
# zzkill
# Mata processos pelo nome do seu comando de origem.
# Com a opção -n, apenas mostra o que será feito, mas não executa.
# Se nenhum argumento for informado, mostra a lista de processos ativos.
# Uso: zzkill [-n] [comando [comando2 ...]]
# Ex.: zzkill
#      zzkill netscape
#      zzkill netsc soffice startx
#
# Autor: Ademar de Souza Reis Jr.
# Desde: 2000-05-15
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzkill ()
{
	zzzz -h kill "$1" && return

	local nao comandos comando processos pid chamada

	# Opções de linha de comando
	if test "$1" = '-n'
	then
		nao='[-n]\t'
		shift
	fi

	while :
	do
		comando="$1"

		# Tenta obter a lista de processos nos formatos Linux e BSD
		processos=$(ps xw --format pid,comm 2>/dev/null) ||
		processos=$(ps xw -o pid,command 2>/dev/null)

		# Diga não ao suicídio
		processos=$(echo "$processos" | grep -vw '\(zz\)*kill')

		# Sem argumentos, apenas mostra a listagem e sai
		if ! test -n "$1"
		then
			echo "$processos"
			return 0
		fi

		# Filtra a lista, extraindo e matando os PIDs
		echo "$processos" |
			grep -i "$comando" |
			while read pid chamada
			do
				print '%b\n' "$nao$pid\t$chamada"
				test -n "$nao" || kill $pid
			done

		# Próximo da fila!
		shift
		test -n "$1" || break
	done
}

# ----------------------------------------------------------------------------
# zzlblank
# Elimina espaços excedentes no início, mantendo alinhamento.
# por padrão transforma todos os TABs em 4 espaços para uniformização.
# Um número como argumento especifica a quantidade de espaços para cada TAB.
# Caso use a opção -s, apenas espaços iniciais serão considerados.
# Caso use a opção -t, apenas TABs iniciais serão considerados.
#  Obs.: Com as opções -s e -t não há a conversão de tabs para espaço.
#
# Uso: zzlblank [-s|-t|<número>] arquivo.txt
# Ex.: zzlblank arq.txt     # Espaços e tabs iniciais
#      zzlblank -s arq.txt  # Apenas espaços iniciais
#      zzlblank -t arq.txt  # Apenas tabs iniciais
#      zzlblank 12 arq.txt  # Tabs são convertidos em 12 espaços
#      cat arq.txt | zzlblank
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-05-11
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzlblank ()
{
	zzzz -h lblank "$1" && return

	local tipo_blank=0
	local tab_spa=4

	while test "${1#-}" != "$1"
	do
		case "$1" in
			-s) tipo_blank=1; shift;;
			-t) tipo_blank=2; shift;;
			* ) break;;
		esac
	done

	if test -n $1
	then
		zztool testa_numero $1 && { tab_spa=$1; shift; }
	fi

	zztool file_stdin "$@" |
	awk -v tipo=$tipo_blank '
		function subs() {
			if (tipo == 2) { sub(/^\t*/, "", $0) }
			else { sub(/^ */, "", $0) }
		}

		BEGIN {
			for (i=1; i<='$tab_spa'; i++)
				espacos = espacos " "
		}

		{
			if ( tipo == 0 ) gsub(/\t/, espacos)
			linha[NR] = $0
			if ( length($0) > 0 ) {
				if ( length(qtde) == 0 ) {
					subs()
					qtde = length(linha[NR]) - length($0)
				}
				else {
					subs()
					qtde_temp = length(linha[NR]) - length($0)
					qtde = qtde <= qtde_temp ? qtde : qtde_temp
				}
			}
		}

		END {
			for (j=1; j<=NR; j++) {
				for (k=1; k<=qtde; k++) {
					if ( tipo == 2 )
						sub(/^\t/, "", linha[j])
					else
						sub(/^ /, "", linha[j])
				}
				print linha[j]
			}
		}
	'
}

# ----------------------------------------------------------------------------
# zzlembrete
# Sistema simples de lembretes: cria, apaga e mostra.
# Uso: zzlembrete [texto]|[número [d]]
# Ex.: zzlembrete                      # Mostra todos
#      zzlembrete 5                    # Mostra o 5º lembrete
#      zzlembrete 5d                   # Deleta o 5º lembrete
#      zzlembrete Almoço com a sogra   # Adiciona lembrete
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-22
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzlembrete ()
{
	zzzz -h lembrete "$1" && return

	local numero tmp
	local arquivo="$HOME/.zzlembrete"

	# Assegura-se que o arquivo de lembretes existe
	test -f "$arquivo" || touch "$arquivo"

	# Sem argumentos, mostra todos os lembretes
	if test $# -eq 0
	then
		cat -n "$arquivo"

	# Tem argumentos, que podem ser para mostrar, apagar ou adicionar
	elif echo "$*" | tr -s '\t ' ' ' | grep '^ *[0-9]\{1,\} *d\{0,1\} *$' >/dev/null
	then
		# Extrai o número da linha
		numero=$(echo "$*" | tr -d -c 0123456789)

		if zztool grep_var d "$*"
		then
			# zzlembrete 5d: Apaga linha 5
			tmp=$(zztool mktemp lembrete)
			cp "$arquivo" "$tmp" &&
			sed "${numero:-0} d" "$tmp" > "$arquivo" || {
				zztool erro "Ops, deu algum erro no arquivo $arquivo"
				zztool erro "Uma cópia dele está em $tmp"
				return 1
			}
			rm -f "$tmp"
		else
			# zzlembrete 5: Mostra linha 5
			sed -n "$numero p" "$arquivo"
		fi
	else
		# zzlembrete texto: Adiciona o texto
		echo "$*" >> "$arquivo" || {
			zztool erro "Ops, não consegui adicionar esse lembrete"
			return 1
		}
	fi
}

# ----------------------------------------------------------------------------
# zzlibertadores
# Mostra a classificação e jogos do torneio Libertadores da América.
# Opções:
#  <número> | <fase>: Mostra jogos da fase selecionada
#    fases: pre ou primeira, grupos ou segunda, oitavas
#  -g <número>: Jogos da segunda fase do grupo selecionado
#  -c [número]: Mostra a classificação, nos grupos da segunda fase
#  -cg <número> ou -gc <número>: Classificação e jogos do grupo selecionado.
#
# As fases podem ser:
#  pré, pre, primeira ou 1, para a fase pré-libertadores
#  grupos, segunda ou 2, para a fase de grupos da libertadores
#  oitavas ou 3
#  quartas ou 4
#  semi, semi-final ou 5
#  final ou 6
#
# Nomenclatura:
#  PG  - Pontos Ganhos
#  J   - Jogos
#  V   - Vitórias
#  E   - Empates
#  D   - Derrotas
#  GP  - Gols Pró
#  GC  - Gols Contra
#  SG  - Saldo de Gols
#  (%) - Aproveitamento (pontos)
#
# Obs.: Se a opção for --atualiza, o cache usado é renovado
#
# Uso: zzlibertadores [ fase | -c [número] | -g <número> ]
# Ex.: zzlibertadores 2     # Jogos da Fase 2 (Grupos)
#      zzlibertadores -g 5  # Jogos do grupo 5 da fase 2
#      zzlibertadores -c    # Classificação de todos os grupos
#      zzlibertadores -c 3  # Classificação no grupo 3
#      zzlibertadores -cg 7 # Classificação e jogos do grupo 7
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-17
# Versão: 13
# Licença: GPL
# Requisitos: zzecho zzpad zzdatafmt
# ----------------------------------------------------------------------------
zzlibertadores ()
{
	zzzz -h libertadores "$1" && return

	local ano=$(date +%Y)
	local cache=$(zztool cache libertadores)
	local url="http://esporte.uol.com.br/futebol/campeonatos/libertadores/jogos/"
	local awk_jogo='
		NR % 3 == 1 { time1=$0; if ($(NF-1) ~ /^[0-9]{1,}$/) { penais1=$(NF -1)} else {penais1=""} }
		NR % 3 == 2 {
			if ($NF ~ /^[0-9-]{1,}$/) { reserva=$NF " "; $NF=""; } else reserva=""
			time2=reserva $0
			if ($(NF-1) ~ /^[0-9]{1,}$/ ) { penais2=$(NF -1)} else {penais2=""}
			if (length(penais1)>0 && length(penais2)>0) {
				sub(" " penais1, "", time1)
				sub(" " penais2, "", time2)
				penais1 = " ( " penais1
				penais2 = penais2 " ) "
			}
			else {penais1="";penais2=""}
		}
		NR % 3 == 0 { sub(/  *$/,""); print time1 penais1 "|" penais2 time2 "|" $0 }
		'
	local sed_mata='
		1d; $d
		/Confronto/d;/^ *$/d;
		s/pós[ -]jogo//; s/^ *//; s/__*//g; s/[A-Z][A-Z][A-Z] //;
		s/\([0-9]\{1,\}\) *pênaltis *\([0-9]\{1,\}\)\(.*\) X \(.*$\)/\3 (\1 X \2) \4/g
	'
	local time1 time2 horario linha

	test -n "$1" || { zztool -e uso libertadores; return 1; }

	# Tempo de resposta do site está elevando, usando cache para minimizar efeito
	test "$1" = "--atualiza" && { zztool cache rm libertadores; shift; }
	if ! test -s "$cache" || test $(head -n 1 "$cache") != $(zzdatafmt --iso hoje)
	then
		zzdatafmt --iso hoje > "$cache"
		$ZZWWWDUMP "$url" >> "$cache"
	fi

	# Mostrando os jogos
	# Escolhendo as fases
	# Fase 1 (Pré-libertadores)
	case "$1" in
	1 | pr[eé] | primeira)
		sed -n '/PRIMEIRA FASE/,/SEGUNDA/p' "$cache" |
		sed "$sed_mata" |
		awk "$awk_jogo" |
		while read linha
		do
			time1=$(  echo $linha | cut -d"|" -f 1 )
			time2=$(  echo $linha | cut -d"|" -f 2 )
			horario=$(echo $linha | cut -d"|" -f 3 )
			echo "$(zzpad -l 28 $time1) X $(zzpad -r 28 $time2) $horario"
		done
	;;
	# Fase 2 (Fase de Grupos)
	2 | grupos | segunda)
		for grupo in 1 2 3 4 5 6 7 8
		do
			zzlibertadores -g $grupo
			echo
		done
	;;
	3 | oitavas)
		sed -n '/^OITAVAS DE FINAL/,/^ *\*/p' "$cache" |
		sed "$sed_mata" |
		sed 's/.*\([0-9]º\)/\1/' |
		awk "$awk_jogo" |
		while read linha
		do
			time1=$(  echo $linha | cut -d"|" -f 1 )
			time2=$(  echo $linha | cut -d"|" -f 2 )
			horario=$(echo $linha | cut -d"|" -f 3 )
			echo "$(zzpad -l 28 $time1) X $(zzpad -r 28 $time2) $horario"
		done
	;;
	4 | quartas | 5 | semi | semi-final | 6 | final)
		case $1 in
		4 | quartas)
			sed -n '/^QUARTAS DE FINAL/,/^OITAVAS DE FINAL/p' "$cache";;
		5 | semi | semi-final)
			sed -n '/^SEMIFINAIS/,/^QUARTAS DE FINAL/p' "$cache";;
		6 | final)
			sed -n '/^FINAL/,/^SEMIFINAIS/p' "$cache";;
		esac |
		sed "$sed_mata" |
		sed 's/.*Vencedor/Vencedor/' |
		awk "$awk_jogo" |
		while read linha
		do
			time1=$(  echo $linha | cut -d"|" -f 1 )
			time2=$(  echo $linha | cut -d"|" -f 2 )
			horario=$(echo $linha | cut -d"|" -f 3 )
			echo "$(zzpad -l 28 $time1) X $(zzpad -r 28 $time2) $horario"
		done
	;;
	esac

	# Escolhendo o grupo para os jogos
	if test "$1" = "-g" && zztool testa_numero $2 && test $2 -le 8  -a $2 -ge 1
	then
		echo "Grupo $2"
		sed -n "/^ *Grupo $2/,/Grupo /p"  "$cache"|
		sed '
			/Rodada [2-9]/d;
			/Classificados para as oitavas de final/,$d
			1,5d' |
		sed "$sed_mata" |
		awk "$awk_jogo" |
		sed 's/\(h[0-9][0-9]\).*$/\1/' |
		while read linha
		do
			time1=$(  echo $linha | cut -d"|" -f 1 )
			time2=$(  echo $linha | cut -d"|" -f 2 )
			horario=$(echo $linha | cut -d"|" -f 3 )
			echo "$(zzpad -l 28 $time1) X $(zzpad -r 28 $time2) $horario"
		done
	fi

	# Mostrando a classificação (Fase de grupos)
	if test "$1" = "-c" -o "$1" = "-cg" -o "$1" = "-gc"
	then
		if zztool testa_numero $2 && test $2 -le 8  -a $2 -ge 1
		then
			grupo="$2"
			sed -n "/^ *Grupo $2/,/Rodada 1/p" "$cache" | sed -n '/PG/p;/°/p' |
			sed 's/[^-][A-Z][A-Z][A-Z] //;s/ [A-Z][A-Z][A-Z]//' |
			awk -v cor_awk="$ZZCOR" '{
				if (NF <  10) { print }
				if (NF == 10) {
					printf "%-28s", $1
					for (i=2;i<=10;i++) { printf " %3s", $i }
					print ""
				}
				if (NF > 10) {
					if (cor_awk==1 && ($1 == "1°" || $1 == "2°")) { printf "\033[42;30m" }
					time=""
					for (i=1;i<NF-8;i++) { time=time " " $i }
					printf "%-28s", time
					for (i=NF-8;i<=NF;i++) { printf " %3s", $i }
					if (cor_awk==1) { printf "\033[m\n" } else {print ""}
				}
			}'
			test "$1" = "-cg" -o "$1" = "-gc" && { echo; zzlibertadores -g $2 | sed '1d'; }
		else
			for grupo in 1 2 3 4 5 6 7 8
			do
				zzlibertadores -c $grupo -n
				test "$1" = "-cg" -o "$1" = "-gc" && { echo; zzlibertadores -g $grupo | sed '1d'; }
				echo
			done
		fi
		if test $ZZCOR -eq 1
		then
			test "$3" != "-n" && { echo ""; zzecho -f verde -l preto " Oitavas de Final "; }
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzlimpalixo
# Retira linhas em branco e comentários.
# Para ver rapidamente quais opções estão ativas num arquivo de configuração.
# Além do tradicional #, reconhece comentários de vários tipos de arquivos.
#  vim, asp, asm, ada, sql, e, bat, tex, c, css, html, cc, d, js, php, scala.
# E inclui os comentários multilinhas (/* ... */), usando opção --multi.
# Obs.: Aceita dados vindos da entrada padrão (STDIN).
# Uso: zzlimpalixo [--multi] [arquivos]
# Ex.: zzlimpalixo ~/.vimrc
#      cat /etc/inittab | zzlimpalixo
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-04-24
# Versão: 3
# Licença: GPL
# Requisitos: zzjuntalinhas
# ----------------------------------------------------------------------------
zzlimpalixo ()
{
	zzzz -h limpalixo "$1" && return

	local comentario='#'
	local multi=0
	local comentario_ini='\/\*'
	local comentario_fim='\*\/'

	# Para comentários multilinhas: /* ... */
	if test "$1" = "--multi"
	then
		multi=1
		shift
	fi

	# Reconhecimento de comentários
	# Incluida opção de escolher o tipo, pois o arquivo pode vir via pipe, e não seria possível reconhecer a extensão do arquivo
	case "$1" in
		*.vim | *.vimrc*)			comentario='"';;
		--vim)					comentario='"';shift;;
		*.asp)					comentario="'";;
		--asp)					comentario="'";shift;;
		*.asm)					comentario=';';;
		--asm)					comentario=';';shift;;
		*.ada | *.sql | *.e)			comentario='--';;
		--ada | --sql | --e)			comentario='--';shift;;
		*.bat)					comentario='rem';;
		--bat)					comentario='rem';shift;;
		*.tex)					comentario='%';;
		--tex)					comentario='%';shift;;
		*.c | *.css)				multi=1;;
		--c | --css)				multi=1;shift;;
		*.html | *.htm | *.xml)			comentario_ini='<!--'; comentario_fim='-->'; multi=1;;
		--html | --htm | --xml)			comentario_ini='<!--'; comentario_fim='-->'; multi=1;shift;;
		*.jsp)					comentario_ini='<%--'; comentario_fim='-->'; multi=1;;
		--jsp)					comentario_ini='<%--'; comentario_fim='-->'; multi=1;shift;;
		*.cc | *.d | *.js | *.php | *.scala)	comentario='\/\/';;
		--cc | --d | --js | --php | --scala)	comentario='\/\/';shift;;
	esac

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |

	# Junta os comentários multilinhas
	if test $multi -eq 1
	then
		zzjuntalinhas -i "$comentario_ini" -f "$comentario_fim" |
		sed "/^[[:blank:]]*${comentario_ini}/d"

	else
		cat -
	fi |

		# Remove comentários e linhas em branco
		sed "
			/^[[:blank:]]*$comentario/ d
			/^[[:blank:]]*$/ d" |
		uniq
}

# ----------------------------------------------------------------------------
# zzlinha
# Mostra uma linha de um texto, aleatória ou informada pelo número.
# Obs.: Se passado um argumento, restringe o sorteio às linhas com o padrão.
# Uso: zzlinha [número | -t texto] [arquivo(s)]
# Ex.: zzlinha /etc/passwd           # mostra uma linha qualquer, aleatória
#      zzlinha 9 /etc/passwd         # mostra a linha 9 do arquivo
#      zzlinha -2 /etc/passwd        # mostra a penúltima linha do arquivo
#      zzlinha -t root /etc/passwd   # mostra uma das linhas com "root"
#      cat /etc/passwd | zzlinha     # o arquivo pode vir da entrada padrão
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-12-23
# Versão: 2
# Licença: GPL
# Requisitos: zzaleatorio
# ----------------------------------------------------------------------------
zzlinha ()
{
	zzzz -h linha "$1" && return

	local arquivo n padrao resultado num_linhas

	# Opções de linha de comando
	if test "$1" = '-t'
	then
		padrao="$2"
		shift
		shift
	fi

	# Talvez o $1 é o número da linha desejada?
	if zztool testa_numero_sinal "$1"
	then
		n="$1"
		shift
	fi

	# Se informado um ou mais arquivos, eles existem?
	for arquivo in "$@"
	do
		zztool arquivo_legivel "$arquivo" || return 1
	done

	if test -n "$n"
	then
		# Se foi informado um número, mostra essa linha.
		# Nota: Suporte a múltiplos arquivos ou entrada padrão (STDIN)
		for arquivo in "${@:--}"
		do
			# Usando cat para ler do arquivo ou da STDIN
			cat "$arquivo" |
				if test "$n" -lt 0
				then
					tail -n "${n#-}" | sed 1q
				else
					sed -n "${n}p"
				fi
		done
	else
		# Se foi informado um padrão (ou nenhum argumento),
		# primeiro grepa as linhas, depois mostra uma linha
		# aleatória deste resultado.
		# Nota: Arquivos via STDIN ou argumentos
		resultado=$(zztool file_stdin "$@" | grep -h -i -- "${padrao:-.}")
		num_linhas=$(echo "$resultado" | sed -n '$=')
		n=$(zzaleatorio 1 $num_linhas)
		echo "$resultado" | sed -n "${n}p"
	fi
}

# ----------------------------------------------------------------------------
# zzlinux
# http://www.kernel.org/kdist/finger_banner
# Mostra as versões disponíveis do Kernel Linux.
# Uso: zzlinux
# Ex.: zzlinux
#
# Autor: Diogo Gullit <guuuuuuuuuullit (a) yahoo com br>
# Desde: 2008-05-01
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzlinux ()
{
	zzzz -h linux "$1" && return

	$ZZWWWDUMP http://www.kernel.org/kdist/finger_banner | grep -v '^$'
}

# ----------------------------------------------------------------------------
# zzlinuxnews
# Busca as últimas notícias sobre Linux em sites em inglês.
# Obs.: Cada site tem uma letra identificadora que pode ser passada como
#       parâmetro, para informar quais sites você quer pesquisar:
#
#          S)lashDot            Linux T)oday
#          O)S News             Linux W)eekly News
#          Linux I)nsider       Linux N)ews
#          Linux J)ournal       X) LXer Linux News
#
# Uso: zzlinuxnews [sites]
# Ex.: zzlinuxnews
#      zzlinuxnews ts
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-11-07
# Versão: 6
# Licença: GPL
# Requisitos: zzfeed
# ----------------------------------------------------------------------------
zzlinuxnews ()
{
	zzzz -h linuxnews "$1" && return

	local url limite
	local n=5
	local sites='stwoxijn'

	limite="sed ${n}q"

	test -n "$1" && sites="$1"

	# Slashdot
	if zztool grep_var s "$sites"
	then
		url='http://rss.slashdot.org/Slashdot/slashdot'
		echo
		zztool eco "* SlashDot ($url):"
		zzfeed -n $n "$url"
	fi

	# Linux Today
	if zztool grep_var t "$sites"
	then
		url='http://linuxtoday.com/backend/biglt.rss'
		echo
		zztool eco "* Linux Today ($url):"
		zzfeed -n $n "$url"
	fi

	# LWN
	if zztool grep_var w "$sites"
	then
		url='http://lwn.net/headlines/newrss'
		echo
		zztool eco "* Linux Weekly News - ($url):"
		zzfeed -n $n "$url"
	fi

	# OS News
	if zztool grep_var o "$sites"
	then
		url='http://www.osnews.com/files/recent.xml'
		echo
		zztool eco "* OS News - ($url):"
		zzfeed -n $n "$url"
	fi

	# LXer Linux News
	if zztool grep_var x "$sites"
	then
		url='http://lxer.com/module/newswire/headlines.rss'
		echo
		zztool eco "*  LXer Linux News- ($url):"
		zzfeed -n $n "$url"
	fi

	# Linux Insider
	if zztool grep_var i "$sites"
	then
		url='http://www.linuxinsider.com/perl/syndication/rssfull.pl'
		echo
		zztool eco "* Linux Insider - ($url):"
		zzfeed -n $n "$url"
	fi

	# Linux Journal
	if zztool grep_var j "$sites"
	then
		url='http://feeds.feedburner.com/linuxjournalcom'
		echo
		zztool eco "* Linux Journal - ($url):"
		zzfeed -n $n "$url"
	fi

	# Linux News
	if zztool grep_var n "$sites"
	then
		url='https://www.linux.com/feeds/all-content'
		echo
		zztool eco "* Linux News - ($url):"
		zzfeed -n $n "$url"
	fi
}

# ----------------------------------------------------------------------------
# zzlocale
# Busca o código do idioma (locale) - por exemplo, português é pt_BR.
# Com a opção -c, pesquisa somente nos códigos e não em sua descrição.
# Uso: zzlocale [-c] código|texto
# Ex.: zzlocale chinese
#      zzlocale -c pt
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2005-06-30
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzlocale ()
{
	zzzz -h locale "$1" && return

	local url='https://raw.githubusercontent.com/funcoeszz/funcoeszz/master/local/zzlocale.txt'
	local cache=$(zztool cache locale)
	local padrao="$1"

	# Opções de linha de comando
	if test "$1" = '-c'
	then
		# Padrão de pesquisa válido para última palavra da linha (código)
		padrao="$2[^ ]*$"
		shift
	fi

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso locale; return 1; }

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		$ZZWWWDUMP "$url" > "$cache"
	fi

	# Faz a consulta
	grep -i -- "$padrao" "$cache"
}

# ----------------------------------------------------------------------------
# zzlorem
# Gerador de texto de teste, em latim (Lorem ipsum...).
# Texto obtido em http://br.lipsum.com/
#
# Uso: zzlorem [número-de-palavras]
# Ex.: zzlorem 10
#
# Autor: Angelito M. Goulart, www.angelitomg.com
# Desde: 2012-12-11
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzlorem ()
{

	# Comando especial das funcoes ZZ
	zzzz -h lorem "$1" && return

	# Contador para repetição do texto quando maior que mil
	local contador

	# Conteudo do texto que sera usado pelo script
	local TEXTO="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin euismod blandit pharetra. Vestibulum eu neque eget lorem gravida commodo a cursus massa. Fusce sit amet lorem sem. Donec eu quam leo. Suspendisse consequat risus in ante fringilla sit amet facilisis felis hendrerit. Suspendisse potenti. Pellentesque enim quam, cursus vestibulum porta ac, pharetra vitae ipsum. Sed ullamcorper odio eget diam egestas lacinia. Aenean aliquam tortor quis dolor sollicitudin suscipit. Etiam nec libero vitae magna dignissim molestie. Pellentesque volutpat euismod justo id congue. Proin nibh magna, blandit quis posuere at, sollicitudin nec lectus. Vivamus ut erat erat, in egestas lacus. Vivamus vel nunc elit, ut aliquam nisi.

Vivamus convallis, mi eu consequat scelerisque, lacus lorem elementum quam, vel varius augue lectus sit amet nulla. Integer porta ligula eu risus rhoncus sit amet blandit nulla tincidunt. Nullam fringilla lectus scelerisque elit suscipit venenatis. Donec in ante nec tortor mollis adipiscing. Aliquam id tellus bibendum orci ultricies scelerisque sit amet ut elit. Sed quis turpis molestie tortor consectetur dapibus. Donec hendrerit diam sit amet nibh porta a pellentesque tortor dictum. Curabitur justo libero, rhoncus vitae facilisis nec, vulputate at ipsum. Quisque iaculis diam eget mi tincidunt id sollicitudin diam fermentum.

Vivamus sed orci non nisl elementum adipiscing in et tortor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. In hac habitasse platea dictumst. Phasellus a dictum magna. Duis vel erat in lacus tempor fermentum sit amet sed felis. Vestibulum arcu libero, convallis sed euismod sit amet, condimentum in orci. Nulla tempus venenatis justo, et porttitor metus pellentesque ut. Nunc vel turpis a risus mollis tempor. Suspendisse purus risus, pharetra eu tincidunt non, adipiscing vitae libero. Nam ut quam sed metus laoreet sagittis vel non risus. Pellentesque vestibulum vehicula porttitor. Donec aliquet lorem nec ipsum auctor laoreet. Nunc pellentesque ligula sed felis venenatis dictum. Donec ut mauris eget purus ornare rhoncus. Integer pellentesque elementum nisi, at consectetur orci placerat eu.

Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec rutrum fermentum mi, id faucibus libero volutpat id. Suspendisse tristique lobortis ligula quis suscipit. Pellentesque velit tellus, aliquet eu cursus a, blandit ac leo. Proin diam ante, iaculis quis commodo vitae, placerat at lacus. In ipsum nisi, aliquam in aliquet ac, congue a nunc. Fusce ut semper erat. Sed fermentum nulla nec tellus convallis ac vestibulum tortor feugiat. Quisque sed est sem, quis adipiscing ipsum. In non velit nibh. Fusce in libero vitae sem dignissim ultrices ac sed mi. Quisque laoreet ipsum eget metus consequat vestibulum. Quisque ornare accumsan nisl sed eleifend.

Donec lacinia lacus sapien. Nunc condimentum volutpat justo, nec euismod justo varius a. Aliquam mattis faucibus interdum. Suspendisse et lorem at odio fringilla lobortis. Nunc ut purus et tortor dignissim lobortis sit amet quis nisl. Aliquam a nulla in est eleifend imperdiet non eu ipsum. Sed diam neque, vehicula id consequat sit amet, lobortis at orci. Etiam et purus ipsum. Sed aliquam eros nec quam faucibus non faucibus velit sollicitudin. Nam tincidunt ullamcorper mattis.

Fusce odio velit, sodales id gravida vel, laoreet at lorem. Fusce malesuada mauris sed enim convallis non pulvinar dui egestas. Nullam sodales cursus quam sed lacinia. Praesent ac lorem ut erat feugiat molestie. Integer quis nisl et libero luctus ornare at vel ante. Integer magna nisi, vestibulum ac aliquam quis, iaculis eget massa. Integer ut venenatis ante. Duis fermentum neque elit, iaculis sagittis dui. Nam faucibus elementum nisl sit amet pulvinar. Duis fringilla, nulla ut porttitor rutrum, diam dolor sagittis neque, a placerat arcu diam nec libero. Nulla dolor tellus, consectetur eget consectetur ac, dapibus quis est. Aenean adipiscing volutpat lectus vitae consequat.

Cras ultrices lacus vitae metus dictum quis iaculis nulla bibendum. Duis aliquam, tellus id pharetra bibendum, dui est condimentum mauris, semper condimentum odio massa vitae nisl. Suspendisse non ipsum mauris. Vestibulum tempor consequat lacus quis commodo. Pellentesque eros urna, adipiscing ut faucibus id, sagittis non purus. Curabitur dignissim, urna id iaculis viverra, tortor libero congue sapien, eget tincidunt diam dolor at odio. Ut vitae lacus velit.

Pellentesque non tellus eget ipsum molestie placerat. Quisque sagittis, mauris facilisis tincidunt aliquet, erat nulla commodo turpis, nec porttitor dolor magna sit amet neque. Etiam ornare lobortis sagittis. Curabitur sit amet nunc at arcu consequat pellentesque at et tortor. Fusce vehicula, ante ut euismod dignissim, eros tellus tincidunt turpis, sit amet placerat nunc tortor ut dui. Cras lacus tortor, congue eget gravida sed, dapibus sed tortor. In hac habitasse platea dictumst. Vivamus ante felis, cursus quis interdum porta, accumsan non nulla. Maecenas lacus lacus, malesuada et lobortis a, ullamcorper ac odio. Sed ac neque massa, eget pharetra justo. Vivamus cursus eleifend nisl vel adipiscing. Sed eget lectus nisi. Donec sed lacus justo, sed semper dolor. Vestibulum mollis fermentum metus, quis hendrerit odio cursus nec.

Sed ac tempor nulla. Nunc eget nunc sit amet magna porta malesuada. Vivamus pharetra lorem vel enim pretium lacinia. Etiam vitae turpis turpis, quis ullamcorper libero. Aenean quis dui id nibh pellentesque eleifend. Cras commodo lectus a sapien laoreet venenatis. Donec facilisis hendrerit diam nec blandit. Duis lectus quam, aliquet quis fringilla non, posuere sit amet massa. Duis pharetra lacinia facilisis.

In gravida, neque a mattis tincidunt, velit arcu cursus nisi, eu blandit risus ligula eget ligula. Aenean faucibus tincidunt bibendum. Nulla nec urna lorem. Suspendisse non lorem in sapien cursus dignissim interdum non ligula. Suspendisse potenti. Sed rutrum libero ut odio varius a condimentum nulla commodo. Etiam in eros diam, vel lobortis nibh. Aliquam quam felis, blandit sit amet placerat non, tristique sit amet nisi. Pellentesque sit amet magna rutrum odio varius volutpat. Quisque consequat, elit ac blandit varius, turpis odio pellentesque urna, eu ultricies elit quam eget elit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nam vel sem sem, vitae vehicula tortor. Etiam ut dui diam. Duis id libero nunc, pharetra bibendum tellus. Praesent accumsan tempus euismod. Vestibulum ante ipsum primis in faucibus orci luctus et."

	if test "$#" -ne 1
	then

		# Se nao for passado um numero de palavras, exibe o texto todo
		echo $TEXTO

	elif zztool testa_numero "$1"
	then

		# Se o parametro for maior e igual a 1000, repete os múltiplos de 1000.
		contador=$(($1 / 1000))
		while test $contador -gt 0
		do
			echo $TEXTO
			contador=$(($contador -1))
		done

		# Se o resto do parâmetro for maior que zero, corta o texto no local certo, até esse limite ou ponto.
		contador=$(($1 % 1000))
		test $contador -gt 0 && echo $TEXTO | cut -d " " -f 1-"$contador" | sed '$s/\.[^.]*$/\./'

	else

		# Caso o parametro nao seja um numero, exibe o modo de utilizacao
		zztool -e uso lorem
		return 1
	fi

}

# ----------------------------------------------------------------------------
# zzloteria
# http://www1.caixa.gov.br/loterias
# Resultados da quina, megasena, duplasena, lotomania, lotofácil, federal, timemania e loteca.
#
# Se o 2º argumento for um número, pesquisa o resultado filtrando o concurso.
# Se nenhum argumento for passado, todas as loterias são mostradas.
#
# Uso: zzloteria [[loteria suportada] concurso]
# Ex.: zzloteria
#      zzloteria quina megasena
#      zzloteria loteca 550
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2004-05-18
# Versão: 12
# Licença: GPL
# Requisitos: zzseq zzjuntalinhas zzdatafmt
# ----------------------------------------------------------------------------
zzloteria ()
{
	zzzz -h loteria "$1" && return

	local dump numero_concurso data resultado acumulado tipo ZZWWWDUMP2
	local resultado_val resultado_num num_con sufixo faixa download
	local url='http://www1.caixa.gov.br/loterias/loterias'
	local tipos='quina megasena duplasena lotomania lotofacil federal timemania loteca'
	local cache=$(zztool cache loteria)
	local tab=$(printf '\t')

	if which links >/dev/null 2>&1
	then
		ZZWWWDUMP2='links -dump'
		download='links -source'
	else
		zztool erro 'Para esta função funcionar, é necessário instalar o navegador de modo texto "links", "links2" ou "elinks".'
		return 1
	fi

	# Caso o segundo argumento seja um numero, filtra pelo concurso equivalente
	zztool testa_numero "$2"
	if (test $? -eq 0)
	then
		tipos="$1"
		case $tipos in
			duplasena | federal | timemania | loteca)
				num_con="?submeteu=sim&opcao=concurso&txtConcurso=$2"
			;;
			*) num_con=$2 ;;
		esac
	else
	# Caso contrario mostra todos os tipos, ou alguns selecionados
		unset num_con
		test -n "$1" && tipos="$*"
	fi

	# Para cada tipo de loteria...
	for tipo in $tipos
	do

		# Há várias pegadinhas neste código. Alguns detalhes:
		# - A variável $dump é um cache local do resultado
		# - É usado ZZWWWDUMP2+filtros (e não ZZWWWHTML) para forçar a saída em UTF-8
		# - O resultado é deixado como uma única longa linha
		# - O resultado são vários campos separados por pipe |
		# - Cada tipo de loteria traz os dados em posições (e formatos) diferentes :/

		case "$tipo" in
			duplasena)
				sufixo="_pesquisa_new.asp"
			;;
			*)
				sufixo="_pesquisa.asp"
			;;
		esac

		dump=$($ZZWWWDUMP2 "$url/$tipo/${tipo}${sufixo}$num_con" |
				tr -d \\n |
				sed 's/  */ /g ; s/^ //')

		# O número do concurso é sempre o primeiro campo
		numero_concurso=$(echo "$dump" | cut -d '|' -f 1)

		case "$tipo" in
			lotomania)
			faixa=$(zzseq -f "\t%d ptos\n" 20 1 16)
			printf %b "${faixa}\n\t 0 ptos" > "${cache}"
			if ! zztool testa_numero "$num_con"
			then
				# O resultado vem separado em campos distintos. Exemplo:
				# |01|04|06|12|21|25|27|36|42|44|50|51|53|59|68|69|74|78|87|91|91|

				data=$(     echo "$dump" | cut -d '|' -f 42)
				acumulado=$(echo "$dump" | awk -F "|" '{print $(NF-1) "|" $NF}')
				resultado=$(echo "$dump" | cut -d '|' -f 7-26 |
					sed 's/|/@/10 ; s/|/ - /g' |
					tr @ '\n'
				)
				echo "$dump" | cut -d '|' -f 28,30,32,34,36,38 | tr '|' '\n' > "${cache}.num"
				echo "$dump" | cut -d '|' -f 29,31,33,35,37,39 | tr '|' '\n' > "${cache}.val"
			else
				if ! test -e ${ZZTMP}.lotomania.htm || ! $(grep "^$num_com " ${ZZTMP}.lotomania.htm >/dev/null)
				then
					$download "http://www1.caixa.gov.br/loterias/_arquivos/loterias/D_lotoma.zip" > "${ZZTMP}.lotomania.zip" 2>/dev/null
					unzip -q -o "${ZZTMP}.lotomania.zip" -d "${ZZTMP%/*}" 2>/dev/null
					mv -f "${ZZTMP%/*}/D_LOTMAN.HTM" ${ZZTMP}.lotomania.htm
					rm -f ${ZZTMP}.lotomania.zip ${ZZTMP%/*}/T11.GIF
				fi
				numero_concurso=$num_con
				dump=$($ZZWWWDUMP2 ${ZZTMP}.lotomania.htm | awk '$1=='$num_con)
				data=$(echo "$dump" | awk '{print $2}')
				acumulado=$(echo "$dump" |
					awk '{
							pos=29
							limite=0
							while (limite<=13){
								if ($pos ~ /[0-9],[0-9]+$/) { limite++ }
								if (limite==13) { print $pos; break }
								pos++
							}
						}')
				resultado=$(echo "$dump" |
					awk '{for (i=3;i<=22;i++) printf $i " " } END { print "" }' |
					while read resultado_val
					do
						echo "$resultado_val" | zztool list2lines | sort -n | zztool lines2list
					done |
					sed 's/ /\
/10' | sed 's/ *$//'
					)
				resultado=$(echo "$resultado" | sed 's/ / - /g')
				echo "$dump" |
					awk '{
							print $24
							pos=25
							limite=1
							while (limite<=5) {
								if ($pos ~ /^[0-9]+$/) { printf $pos " " ; limite++ }
								pos++
							}
						}' | zztool list2lines > "${cache}.num"
				echo "$dump" |
					awk '{
							pos=29
							limite=1
							while (limite<=6) {
								if ($pos ~ /[0-9],[0-9]+$/) { printf $pos " " ; limite++ }
								pos++
							}
						}' | tr ' ' '\n' > "${cache}.val"
			fi
			;;
			lotof[áa]cil)
				# O resultado vem separado em campos distintos. Exemplo:
				# |01|04|07|08|09|10|12|14|15|16|21|22|23|24|25|

				faixa=$(zzseq -f "\t%d ptos\n" 15 1 11)
				echo "$faixa" > "${cache}"
				if ! zztool testa_numero "$num_con"
				then
					resultado=$(echo "$dump" | cut -d '|' -f 4-18 |
						sed 's/|/@/10 ; s/|/@/5 ; s/|/ - /g' |
						tr @ '\n'
					)
					echo "$dump" | cut -d '|' -f 19,21,23,25,27 | tr '|' '\n' > "${cache}.num"
					echo "$dump" | cut -d '|' -f 20,22,24,26,28 | tr '|' '\n' > "${cache}.val"
					dump=$(    echo "$dump" | sed 's/.*Estimativa de Pr//')
					data=$(     echo "$dump" | cut -d '|' -f 6)
					acumulado=$(echo "$dump" | cut -d '|' -f 25,26)
				else
					if ! test -e ${ZZTMP}.lotofacil.htm || ! $(grep "^$num_com " ${ZZTMP}.lotofacil.htm >/dev/null)
					then
						$download "http://www1.caixa.gov.br/loterias/_arquivos/loterias/D_lotfac.zip" > "${ZZTMP}.lotofacil.zip" 2>/dev/null
						unzip -q -o "${ZZTMP}.lotofacil.zip" -d "${ZZTMP%/*}" 2>/dev/null
						mv -f "${ZZTMP%/*}/D_LOTFAC.HTM" ${ZZTMP}.lotofacil.htm
						rm -f ${ZZTMP}.lotofacil.zip ${ZZTMP%/*}/LOTFACIL.GIF
					fi
					numero_concurso=$num_con
					dump=$($ZZWWWDUMP2 ${ZZTMP}.lotofacil.htm | awk '$1=='$num_con)
					data=$(echo "$dump" | awk '{print $2}')
					acumulado=$(echo "$dump" | awk '{print $(NF-2)}')
					resultado=$(echo "$dump" |
						awk '{print $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17}' |
						while read resultado_val
						do
							echo "$resultado_val" | zztool list2lines | sort -n | zztool lines2list
						done |
						sed 's/ /\
/5;s/ /\
/9'
						)
					resultado=$(echo "$resultado" | sed 's/ / - /g')
					echo "$dump" | awk '{print $19;     print $(NF-11); print $(NF-10); print $(NF-9); print $(NF-8)}' > "${cache}.num"
					echo "$dump" | awk '{print $(NF-7); print $(NF-6); print $(NF-5); print $(NF-4); print $(NF-3)}' > "${cache}.val"
				fi
			;;
			megasena)
				# O resultado vem separado por asteriscos. Exemplo:
				# | * 16 * 58 * 43 * 37 * 52 * 59 |

				faixa=$(printf '%b' "\tSena\n\tQuina\n\tQuadra\n")
				echo "$faixa" > "${cache}"
				if ! zztool testa_numero "$num_con"
				then
					data=$(     echo "$dump" | cut -d '|' -f 12)
					acumulado=$(echo "$dump" | cut -d '|' -f 22,23)
					resultado=$(echo "$dump" | cut -d '|' -f 21 |
						tr '*' '-'  |
						tr '|' '\n' |
						sed 's/^ - //'
					)
					echo "$dump" | cut -d '|' -f 4,6,8 | tr '|' '\n' > "${cache}.num"
					echo "$dump" | cut -d '|' -f 5,7,9 | tr '|' '\n' > "${cache}.val"
				else
					if ! test -e ${ZZTMP}.mega.htm || ! $(grep "^$num_com " ${ZZTMP}.mega.htm >/dev/null)
					then
						$download "http://www1.caixa.gov.br/loterias/_arquivos/loterias/D_mgsasc.zip" > "${ZZTMP}.mega.zip" 2>/dev/null
						unzip -q -o "${ZZTMP}.mega.zip" -d "${ZZTMP%/*}" 2>/dev/null
						mv -f "${ZZTMP%/*}/d_megasc.htm" ${ZZTMP}.mega.htm
						rm -f ${ZZTMP}.mega.zip ${ZZTMP%/*}/T2.GIF
					fi
					numero_concurso=$num_con
					dump=$($ZZWWWDUMP2 ${ZZTMP}.mega.htm | awk '$1=='$num_con)
					data=$(echo "$dump" | awk '{print $2}')
					acumulado=$(echo "$dump" | awk '{print $(NF-2)}')
					resultado=$(echo "$dump" | awk '{print $3, $4, $5, $6, $7, $8}')
					resultado=$(echo "$resultado" | sed 's/ / - /g')
					echo "$dump" | awk '{print $10;     print $(NF-7); print $(NF-5)}' > "${cache}.num"
					echo "$dump" | awk '{print $(NF-8); print $(NF-6); print $(NF-4)}' > "${cache}.val"
				fi
			;;
			duplasena)
				# O resultado vem separado por asteriscos, tendo dois grupos
				# numéricos: o primeiro e segundo resultado. Exemplo:
				# | * 05 * 07 * 09 * 21 * 38 * 40 | * 05 * 17 * 20 * 22 * 31 * 45 |

				data=$(     echo "$dump" | cut -d '|' -f 18)
				acumulado=$(echo "$dump" | cut -d '|' -f 23,24)
				resultado=$(echo "$dump" | cut -d '|' -f 4,5 |
					tr '*' '-'  |
					tr '|' '\n' |
					sed 's/^ - //'
				)
				faixa=$(printf %b "\t1a Sena\n\t1a Quina\n\t1a Quadra\n\n\t2a Sena\n\t2a Quina\n\t2a Quadra\n")
				echo "$faixa" > "${cache}"
				echo "$dump" | awk 'BEGIN {FS="|";OFS="\n"} {print $7,$26,$28,"",$9,$10,$13}' > "${cache}.num"
				echo "$dump" | awk 'BEGIN {FS="|";OFS="\n"} {print $8,$27,$29,"",$11,$12,$14}' > "${cache}.val"
			;;
			quina)
				# O resultado vem separado por asteriscos. Exemplo:
				# | * 07 * 13 * 42 * 56 * 69 |

				faixa=$(printf %b "\tQuina\n\tQuadra\n\tTerno\n")
				echo "$faixa" > "${cache}"
				if ! zztool testa_numero "$num_con"
				then
					dump=$(     echo "$dump" | zzjuntalinhas)
					data=$(     echo "$dump" | cut -d '|' -f 17)
					acumulado=$(echo "$dump" | cut -d '|' -f 18,19)
					resultado=$(echo "$dump" | cut -d '|' -f 15 |
						tr '*' '-'  |
						sed 's/^ - //'
					)
					echo "$dump" | cut -d '|' -f 7,9,11 | tr '|' '\n' > "${cache}.num"
					echo "$dump" | cut -d '|' -f 8,10,12 | tr '|' '\n' > "${cache}.val"
				else
					if ! test -e ${ZZTMP}.quina.htm || ! $(grep "^$num_com " ${ZZTMP}.quina.htm >/dev/null)
					then
						$download "http://www1.caixa.gov.br/loterias/_arquivos/loterias/D_quina.zip" > "${ZZTMP}.quina.zip" 2>/dev/null
						unzip -q -o "${ZZTMP}.quina.zip" -d "${ZZTMP%/*}" 2>/dev/null
						mv -f "${ZZTMP%/*}/D_QUINA.HTM" ${ZZTMP}.quina.htm
						rm -f ${ZZTMP}.quina.zip ${ZZTMP%/*}/T7.GIF
					fi
					numero_concurso=$num_con
					dump=$($ZZWWWDUMP2 ${ZZTMP}.quina.htm | awk '$1=='$num_con)
					data=$(echo "$dump" | awk '{print $2}')
					acumulado=$(echo "$dump" | awk '{print $(NF-2)}')
					resultado=$(echo "$dump" | awk '{print $3, $4, $5, $6, $7}' | zztool list2lines | sort -n | zztool lines2list)
					resultado=$(echo "$resultado" | sed 's/ / - /g')
					echo "$dump" | awk '{print $9;     print $(NF-7); print $(NF-5)}' > "${cache}.num"
					echo "$dump" | awk '{print $(NF-8); print $(NF-6); print $(NF-4)}' > "${cache}.val"
				fi
			;;
			federal)
				data=$(     echo "$dump" | cut -d '|' -f 17)
				numero_concurso=$(echo "$dump" | cut -d '|' -f 3)
				unset acumulado

				echo "$dump" | cut -d '|' -f 7,9,11,13,15 |
					tr '*' '-'  |
					tr '|' '\n' |
					sed 's/^ - //' > "${cache}.num"

				echo "$dump" | cut -d '|' -f 8,10,12,14,16 |
					tr '*' '-'  |
					tr '|' '\n' |
					sed 's/^ - //' > "${cache}.val"

				zzseq -f "%do Prêmio\n" 1 1 5 > $cache

				resultado=$(paste "$cache" "${cache}.num" "${cache}.val")
				unset faixa resultado_num resultado_val
			;;
			timemania)
				data=$(     echo "$dump" | cut -d '|' -f 2)
				acumulado=$(echo "$dump" | cut -d '|' -f 24)
				acumulado=${acumulado}"|"$(echo "$dump" | cut -d '|' -f 23 | zzdatafmt)
				resultado=$(echo "$dump" | cut -d '|' -f 8 |
					tr '*' '-'  |
					tr '|' '\n' |
					sed 's/^ - //'
				)
				resultado=$(printf %b "${resultado}\nTime: "$(echo "$dump" | cut -d '|' -f 9))
				faixa=$(zzseq -f "\t%d ptos\n" 7 1 3)
				echo "$faixa" > "${cache}"
				echo "$dump" | cut -d '|' -f 10,12,14,16,18 | tr '|' '\n' > "${cache}.num"
				echo "$dump" | cut -d '|' -f 11,13,15,17,19 | tr '|' '\n' > "${cache}.val"
			;;
			loteca)
				dump=$(     echo "$dump" | sed 's/[A-Z]|[A-Z]/-/g')
				data=$(     echo "$dump" | awk -F"|" '{print $(NF-4)}' )
				acumulado=$(echo "$dump" | awk -F"|" '{print $(NF-1) "|" $(NF)}' )
				acumulado="${acumulado}_Acumulado para a 1a faixa "$(echo "$dump" | awk -F"|" '{print $(NF-5)}' )
				acumulado="${acumulado}_"$(echo "$dump" | awk -F"|" '{print $(NF-2)}' )
				acumulado=$(echo "${acumulado}" | sed 's/_/\
   /g;s/ Valor //' )
				resultado=$($ZZWWWDUMP2 "$url/$tipo/${tipo}${sufixo}$num_con" |
				sed -n '3,/|/p' |
				awk '
					NR == 1 { sub("Data","Coluna"); sub(" X ","   ") }
					NR >= 2 {
						if (NF > 5) {
							if ( $2 > $(NF-1) )  { coluna = "Col.  1" }
							if ( $2 == $(NF-1) ) { coluna = "Col. Meio" }
							if ( $2 < $(NF-1) )  { coluna = "Col.  2" }
							sub($NF "  ", coluna)
						}
					}
					{if (NF > 5) print }
				')
				case $(echo "$num_con" | sed 's/.*=//;s/ *//g') in
					[1-9] | [1-8][0-9]) faixa=$(zzseq -f '\t%d\n' 14 12);;
					*) faixa=$(zzseq -f '\t%d\n' 14 13);;
				esac
				echo "$faixa" > "${cache}"
				echo "$dump" | cut -d '|' -f 5 | sed 's/ [123].\{1,2\} (1[234] acertos)/\
/g;' | sed '1d' | sed "s/[0-9] /&${tab}/g" > "${cache}.num"
				echo '' > "${cache}.val"; echo '' >> "${cache}.val"
			;;
		esac

		# Mostra o resultado na tela (caso encontrado algo)
		if test -n "$resultado"
		then
			zztool eco $tipo:
			echo "$resultado" | sed 's/^/   /'
			data=$(echo "$data" | zzdatafmt)
			echo "   Concurso $numero_concurso ($data)"
			test -n "$acumulado" && echo "   Acumulado em R$ $acumulado" | sed 's/|/ para /'
			if test -n "$faixa"
			then
				printf %b "\tFaixa\tQtde.\tPrêmio\n" | expand -t 5,17,32
				paste "${cache}" "${cache}.num" "${cache}.val"| expand -t 5,17,32
			fi
			echo
		fi
	done
}

# ----------------------------------------------------------------------------
# zzlua
# http://www.lua.org/manual/5.1/pt/manual.html
# Lista de funções da linguagem Lua.
# com a opção -d ou --detalhe busca mais informação da função
# com a opção --atualiza força a atualização do cache local
#
# Uso: zzlua <palavra|regex>
# Ex.: zzlua --atualiza        # Força atualização do cache
#      zzlua file              # mostra as funções com "file" no nome
#      zzlua -d debug.debug    # mostra descrição da função debug.debug
#      zzlua ^d                # mostra as funções que começam com d
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-09
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzlua ()
{
	zzzz -h lua "$1" && return

	local url='http://www.lua.org/manual/5.1/pt/manual.html'
	local cache=$(zztool cache lua)
	local padrao="$*"

	# Força atualização da listagem apagando o cache
	if test "$1" = '--atualiza'
	then
		zztool atualiza lua
		shift
	fi

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		$ZZWWWDUMP "$url" | sed -n '/^4.1/,/^ *6/p' | sed '/^ *[4-6]/,/^ *__*$/{/^ *__*$/!d;}' > "$cache"
	fi

	if test "$1" = '-d' -o "$1" = '--detalhe'
	then
		# Detalhe de uma função específica
		if test -n "$2"
		then
			sed -n "/  $2/,/^ *__*$/p" "$cache" | sed '/^ *__*$/d'
		fi
	elif test -n "$padrao"
	then
		# Busca a(s) função(ões)
		sed -n '/^ *__*$/,/^ *[a-z_]/p' "$cache" |
		sed '/^ *__*$/d;/^ *$/d;s/^  //g;s/\([^ ]\) .*$/\1/g' |
		grep -h -i -- "$padrao"
	else
		# Lista todas as funções
		sed -n '/^ *__*$/,/^ *[a-z_]/p' "$cache" |
		sed '/^ *__*$/d;/^ *$/d;s/\([^ ]\) .*$/\1/g'
	fi
}

# ----------------------------------------------------------------------------
# zzmaiores
# Acha os maiores arquivos/diretórios do diretório atual (ou outros).
# Opções: -r  busca recursiva nos subdiretórios
#         -f  busca somente os arquivos e não diretórios
#         -n  número de resultados (o padrão é 10)
# Uso: zzmaiores [-r] [-f] [-n <número>] [dir1 dir2 ...]
# Ex.: zzmaiores
#      zzmaiores /etc /tmp
#      zzmaiores -r -n 5 ~
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-08-28
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzmaiores ()
{
	zzzz -h maiores "$1" && return

	local pastas recursivo modo tab resultado
	local limite=10

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-n)
				limite=$2
				shift; shift
			;;
			-f)
				modo='f'
				shift
				# Até queria fazer um -d também para diretórios somente,
				# mas o du sempre mostra os arquivos quando está recursivo
				# e o find não mostra o tamanho total dos diretórios...
			;;
			-r)
				recursivo=1
				shift
			;;
			*)
				break
			;;
		esac
	done

	if test "$modo" = 'f'
	then
		# Usuário só quer ver os arquivos e não diretórios.
		# Como o 'du' não tem uma opção para isso, usaremos o 'find'.

		# Se forem várias pastas, compõe a lista glob: {um,dois,três}
		# Isso porque o find não aceita múltiplos diretórios sem glob.
		# Caso contrário tenta $1 ou usa a pasta corrente "."
		if test -n "$2"
		then
			pastas=$(echo {$*} | tr -s ' ' ',')
		else
			pastas=${1:-.}
			test "$pastas" = '*' && pastas='.'
		fi

		tab=$(printf %b '\t')
		test -n "$recursivo" && recursivo= || recursivo='-maxdepth 1'

		resultado=$(
			find $pastas $recursivo -type f -ls |
				tr -s ' ' |
				cut -d' ' -f7,11- |
				sed "s/ /$tab/" |
				sort -nr |
				sed "$limite q"
		)
	else
		# Tentei de várias maneiras juntar o glob com o $@
		# para que funcionasse com o ponto e sem argumentos,
		# mas no fim é mais fácil chamar a função de novo...
		pastas="$@"
		if test -z "$pastas" -o "$pastas" = '.'
		then
			zzmaiores ${recursivo:+-r} -n $limite * .[^.]*
			return

		fi

		# O du sempre mostra arquivos e diretórios, bacana
		# Basta definir se vai ser recursivo (-a) ou não (-s)
		test -n "$recursivo" && recursivo='-a' || recursivo='-s'

		# Estou escondendo o erro para caso o * ou o .* não expandam
		# Bash2: nullglob, dotglob
		resultado=$(
			du $recursivo "$@" 2>/dev/null |
				sort -nr |
				awk '{if (NR==1 && $0 ~ /^[0-9]+[	 ]+total$/){} else print}' |
				sed "$limite q"
		)
	fi
	# TODO é K (nem é, só se usar -k -- conferir no SF) se vier do du e bytes se do find
	echo "$resultado"
	# | while read tamanho arquivo
	# do
	# 		echo -e "$(zzbyte $tamanho)\t$arquivo"
	# done
}

# ----------------------------------------------------------------------------
# zzmaiusculas
# Converte todas as letras para MAIÚSCULAS, inclusive acentuadas.
# Uso: zzmaiusculas [texto]
# Ex.: zzmaiusculas eu quero gritar                # via argumentos
#      echo eu quero gritar | zzmaiusculas         # via STDIN
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-06-12
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzmaiusculas ()
{
	zzzz -h maiusculas "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	sed '
		y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/
		y/àáâãäåèéêëìíîïòóôõöùúûüçñ/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ/'
}

# ----------------------------------------------------------------------------
# zzmariadb
# Lista alguns dos comandos já traduzidos do banco MariaDB, numerando-os.
# Pesquisa detalhe dos comando, ao fornecer o número na listagem a esquerda.
# E filtra a busca se fornecer um texto.
#
# Uso: zzmariadb [ código | filtro ]
# Ex.: zzmariadb        # Lista os comandos disponíveis
#      zzmariadb 18     # Consulta o comando DROP USER
#      zzmariadb alter  # Filtra os comandos que possuam alter na declaração
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-07-03
# Versão: 3
# Licença: GPL
# Requisitos: zzminusculas zzsemacento zztrim
# ----------------------------------------------------------------------------
zzmariadb ()
{
	zzzz -h mariadb "$1" && return

	local url='https://kb.askmonty.org/pt-br'
	local cache=$(zztool cache mariadb)
	local comando

	if test "$1" = "--atualiza"
	then
		zztool atualiza mariadb
		shift
	fi

	if ! test -s "$cache"
	then
		$ZZWWWDUMP "${url}/mariadb-brazilian-portuguese" |
		sed -n '/^[A-Z]\{4,\}/p' |
		awk '{print NR, $0}'> $cache
	fi

	if test -n "$1"
	then
		if zztool testa_numero $1
		then
			comando=$(sed -n "${1}p" $cache | sed "s/^${1} //;s| / |-|g;s/ - /-/g;s/ /-/g;s/\.//g" | zzminusculas | zzsemacento)
			$ZZWWWDUMP "${url}/${comando}" |
			sed -n '/^Localized Versions/,/* ←/p' |
			sed '1d;2d;/^  *\*.*\]$/d;/^ *Tweet */d;/^ *\* *$/d;$d' |
			zztrim -V
		else
			grep -i $1 $cache
		fi
	else
		cat "$cache"
	fi
}

# ----------------------------------------------------------------------------
# zzmat
# Uma coletânea de funções matemáticas simples.
# Se o primeiro argumento for um '-p' seguido de número sem espaço
# define a precisão dos resultados ( casas decimais ), o padrão é 6
# Em cada função foi colocado um pequeno help um pouco mais detalhado,
# pois ficou muito extenso colocar no help do zzmat apenas.
#
# Funções matemáticas disponíveis.
# Aritméticas:                     Trigonométricas:
#  mmc mdc                          sen cos tan
#  somatoria produtoria             csc sec cot
#  media soma produto               asen acos atan
#  log ln
#  raiz, pow, potencia ou elevado
#
# Combinatória:             Sequências:          Funções:
#  fat                       pa pa2 pg lucas      area volume r3
#  arranjo arranjo_r         fibonacci ou fib     det vetor d2p
#  combinacao combinacao_r   tribonacci ou trib
#
# Equações:                  Auxiliares:
#  eq2g egr err                converte
#  egc egc3p ege               abs int sem_zeros
#  newton ou binomio_newton    aleatorio random
#  conf_eq                     compara_num
#
# Mais detalhes: zzmat função
#
# Uso: zzmat [-pnumero] funções [número] [número]
# Ex.: zzmat mmc 8 12
#      zzmat media 5[2] 7 4[3]
#      zzmat somatoria 3 9 2x+3
#      zzmat -p3 sen 60g
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2011-01-19
# Versão: 19
# Licença: GPL
# Requisitos: zzcalcula zzseq zzaleatorio zztrim
# ----------------------------------------------------------------------------
zzmat ()
{
	zzzz -h mat "$1" && return

	local funcao num precisao
	local pi=3.1415926535897932384626433832795
	local LANG=en

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso mat; return 1; }

	# Definindo a precisão dos resultados qdo é pertinente. Padrão é 6.
	echo "$1" | grep '^-p' >/dev/null
	if test "$?" = "0"
	then
		precisao="${1#-p}"
		zztool testa_numero $precisao || precisao="6"
		shift
	else
		precisao="6"
	fi

	funcao="$1"

	# Atalhos para funções pow e fat, usando operadores unários
	if zztool grep_var '^' "$funcao" && zzmat testa_num "${funcao%^*}" && zzmat testa_num "${funcao#*^}"
	then
		zzmat -p${precisao} pow "${funcao%^*}" "${funcao#*^}"
		return
	elif zztool grep_var '!' "$funcao" && zztool testa_numero "${funcao%\!}"
	then
		zzmat -p${precisao} fat "${funcao%\!}" $2
		return
	fi

	case "$funcao" in
	testa_num)
		# Testa se $2 é um número não coberto pela zztool testa_numero*
		echo "$2" | sed 's/^-[\.,]/-0\./;s/^[\.,]/0\./' |
		grep '^[+-]\{0,1\}[0-9]\{1,\}[,.]\{0,1\}[0-9]*$' >/dev/null
	;;
	testa_num_exp)
		local num1 num2 num3
		echo "$2" | grep -E '(e|E)' >/dev/null
		if test $? -eq 0
		then
			num3=$(echo "$2" | tr 'E,' 'e.')
			num1=${num3%e*}
			num2=${num3#*e}
			if zzmat testa_num $num1 && zztool testa_numero_sinal $num2 2>/dev/null 1>/dev/null
			then
				return 0
			else
				return 1
			fi
		else
			return 1
		fi
	;;
	sem_zeros)
		# Elimina o zeros nao significativos
		local num1
		shift
		num1=$(zztool multi_stdin "$@" | tr ',' '.')
		num1=$(echo "$num1" | sed 's/^[[:blank:].0]*$/zero/;s/^[[:blank:]0]*//;s/zero/0/')
		if test $precisao -gt 0
			then
			echo "$num1" | grep '\.' > /dev/null
			if test "$?" = "0"
			then
				num1=$(echo "$num1" | sed 's/[0[:blank:]]*$//' | sed 's/\.$//')
			fi
		fi
		num1=$(echo "$num1" | sed 's/^\./0\./')
		echo "$num1"
	;;
	compara_num)
		if (test $# -eq "3" && zzmat testa_num $2 && zzmat testa_num $3)
		then
			local num1 num2 retorno
			num1=$(echo "$2" | tr ',' '.')
			num2=$(echo "$3" | tr ',' '.')
			retorno=$(
			awk 'BEGIN {
				if ('$num1' > '$num2') {print "maior"}
				if ('$num1' == '$num2') {print "igual"}
				if ('$num1' < '$num2') {print "menor"}
			}')
			echo "$retorno"
		else
			zztool erro " zzmat $funcao: Compara 2 numeros"
			zztool erro " Retorna o texto 'maior', 'menor' ou 'igual'"
			zztool erro " Uso: zzmat $funcao numero numero"
			return 1
		fi
	;;
	int)
		local num1
		if test "$2" = "-h"
		then
			zztool erro " zzmat $funcao: Valor Inteiro"
			zztool erro " Uso: zzmat $funcao numero"
			zztool erro "      echo numero | zzmat $funcao"
			return
		fi
		shift
		num1=$(zztool multi_stdin "$@" | tr ',' '.')
		if zzmat testa_num $num1
		then
			echo $num1 | sed 's/\..*$//'
		fi
	;;
	abs)
		local num1
		if test "$2" = "-h"
		then
			zztool erro " zzmat $funcao: Valor Absoluto"
			zztool erro " Uso: zzmat $funcao numero"
			zztool erro "      echo numero | zzmat $funcao"
			return
		fi
		shift
		num1=$(zztool multi_stdin "$@" | tr ',' '.')
		if zzmat testa_num $num1
		then
			echo "$num1" | sed 's/^[-+]//'
		fi
	;;
	converte)
		if (test $# -eq "3" && zzmat testa_num $3)
		then
			local num1
			num1=$(echo "$3" | tr ',' '.')
			case $2 in
			gr) num="$num1*$pi/180";;
			rg) num="$num1*180/$pi";;
			dr) num="$num1*$pi/200";;
			rd) num="$num1*200/$pi";;
			dg) num="$num1*0.9";;
			gd) num="$num1/0.9";;
			??)
				local grandeza1 grandeza2 fator divisor potencia letra
				local grandezas="y z a f p n u m c d 1 D H K M G T P E Z Y"
				local potencias="-24 -21 -18 -15 -12 -9 -6 -3 -2 -1 0 1 2 3 6 9 12 15 18 21 24"
				local posicao='1'

				precisao=24
				grandeza1=$(echo "$2" | sed 's/\([[:alpha:]1]\)[[:alpha:]1]/\1/')
				grandeza2=$(echo "$2" | sed 's/[[:alpha:]1]\([[:alpha:]1]\)/\1/')
				if (test "$grandeza1" != "$grandeza2")
				then
					for letra in $(echo "$grandezas")
					do
						potencia=$(echo "$potencias" | awk '{print $'$posicao'}')
						test "$grandeza1" = "$letra" && fator=$potencia
						test "$grandeza2" = "$letra" && divisor=$potencia
						posicao=$((posicao + 1))
					done
					if (test -n "$fator" && test -n "$divisor")
					then
						precisao=$(zzmat abs $(($fator - $divisor)))
						potencia=$(echo "$precisao" | awk '{printf 1;for (i=1;i<=$1;i++) {printf 0 }}')
						case $(zzmat compara_num 0 $(($fator - $divisor))) in
							'menor') letra='*';;
							'maior') letra='/';;
						esac
						echo "scale=$precisao;${num1} ${letra} ${potencia}" | bc -l |
						awk '{printf "%.'${precisao}'f\n", $1}' |
						zzmat -p${precisao} sem_zeros
					fi
				fi
			;;
			esac
		else
			zztool erro " zzmat $funcao: Conversões de unidades (não contempladas no zzconverte)"
			zztool erro " Sub-funções:
	gr: graus para radiano
	rg: radiano para graus
	dr: grado para radiano
	rd: radiano para grado
	dg: grado para graus
	gd: graus para grado
	ou com os pares do Sistema Internacional de Unidade
	(y z a f p n u m c d 1 D H K M G T P E Z Y)
	usando a combição dessa letras em pares, sendo na ordem 'de' 'para'.
	Obs: o 1 no centro representa a unidade de medida que não possui prefixo.
	Atenção: Dependendo do computador, arquitetura e a precisao do sistema
			podem haver distorções em valores muito distantes entre si.
	Exempo: Kd converte de Kilo para deci."
			zztool erro " Uso: zzmat $funcao sub-função número"
			return 1
		fi
	;;
	sen | cos | tan | csc | sec | cot)
		if (test $# -eq "2")
		then
			local num1 num2 ang
			num1=$(echo "$2" | sed 's/g$//; s/gr$//; s/rad$//' | tr , .)
			ang=${2#$num1}
			echo "$2" | grep -E '(g|rad|gr)$' >/dev/null
			if (test "$?" -eq "0" && zzmat testa_num $num1)
			then
				case $ang in
				g)   num2=$(zzmat converte gr $num1);;
				gr)  num2=$(zzmat converte dr $num1);;
				rad) num2=$num1;;
				esac

				case $funcao in
				sen) num1=$(awk 'BEGIN {printf "%.'${precisao}'f\n", sin('$num2')}');;
				cos) num1=$(awk 'BEGIN {printf "%.'${precisao}'f\n", cos('$num2')}');;
				tan)
					num1=$(awk 'BEGIN {div=sprintf("%.6f", cos('$num2'));if (div!="0.000000") printf "%.'${precisao}'f\n", sin('$num2')/cos('$num2');}');;
				sec)
					num1=$(awk 'BEGIN {div=sprintf("%.6f", cos('$num2'));if (div!="0.000000") printf "%.'${precisao}'f\n", 1/cos('$num2');}');;
				csc)
					num1=$(awk 'BEGIN {div=sprintf("%.6f", sin('$num2'));if (div!="0.000000") printf "%.'${precisao}'f\n", 1/sin('$num2');}');;
				cot)
					num1=$(awk 'BEGIN {div=sprintf("%.6f", sin('$num2'));if (div!="0.000000") printf "%.'${precisao}'f\n", cos('$num2')/sin('$num2');}');;
				esac

				test -n "$num1" && num="$num1"
			else
				echo " Uso: zzmat $funcao número(g|rad|gr) {graus|radianos|grado}"
			fi
		else
			zztool erro " zzmat Função Trigonométrica:
	sen: Seno
	cos: Cosseno
	tan: Tangente
	sec: Secante
	csc: Cossecante
	cot: Cotangente"
			zztool erro " Uso: zzmat $funcao número(g|rad|gr) {graus|radianos|grado}"
			return 1
		fi
	;;
	asen | acos | atan)
		if test $# -ge "2" && test $# -le "4" && zzmat testa_num $2
		then
			local num1 num2 num3 sinal
			num1=$(echo "$2" | tr ',' '.')
			test "$funcao" != "atan" && num2=$(awk 'BEGIN {if ('$num1'>1 || '$num1'<-1) print "erro"}')
			if test "$num2" = "erro"
			then
				zzmat $funcao -h >&2;return 1
			fi

			echo "$num1" | grep '^-' >/dev/null && sinal="-" || unset sinal
			num1=$(zzmat abs $num1)

			case $funcao in
			atan)
				num2=$(echo "a(${num1})" | bc -l)
				test -n "$sinal" && num2=$(echo "($pi)-($num2)" | bc -l)
				echo "$4" | grep '2' >/dev/null && num2=$(echo "($num2)+($pi)" | bc -l)
			;;
			asen)
				num3=$(echo "sqrt(1-${num1}^2)" | bc -l | awk '{printf "%.'${precisao}'f\n", $1}')
				if test "$num3" = $(printf '%.'${precisao}'f' 0 | tr ',' '.')
				then
					num2=$(echo "$pi/2" | bc -l)
				else
					num2=$(echo "a(${num1}/sqrt(1-${num1}^2))" | bc -l)
				fi
				echo "$4" | grep '2' >/dev/null && num2=$(echo "($pi)-($num2)" | bc -l)
				test -n "$sinal" && num2=$(echo "($pi)+($num2)" | bc -l)
			;;
			acos)
				num3=$(echo "$num1" | bc -l | awk '{printf "%.'${precisao}'f\n", $1}')
				if test "$num3" = $(printf '%.'${precisao}'f' 0 | tr ',' '.')
				then
					num2=$(echo "$pi/2" | bc -l)
				else
					num2=$(echo "a(sqrt(1-${num1}^2)/${num1})" | bc -l)
				fi
				test -n "$sinal" && num2=$(echo "($pi)-($num2)" | bc -l)
				echo "$4" | grep '2' >/dev/null && num2=$(echo "2*($pi)-($num2)" | bc -l)
			;;
			esac

			echo "$4" | grep 'r' >/dev/null && num2=$(echo "($num2)-2*($pi)" | bc -l)

			case $3 in
			g)        num=$(zzmat converte rg $num2);;
			gr)       num=$(zzmat converte rd $num2);;
			rad | "") num="$num2";;
			esac
		else
			zztool erro " zzmat Função Trigonométrica:
	asen: Arco-Seno
	acos: Arco-Cosseno
	atan: Arco-Tangente"
			zztool erro " Retorna o angulo em radianos, graus ou grado."
			zztool erro " Se não for definido retorna em radianos."
			zztool erro " Valores devem estar entre -1 e 1, para arco-seno e arco-cosseno."
			zztool erro " Caso a opção seja '2' retorna o segundo ângulo possível do valor."
			zztool erro " E se for 'r' retorna o ângulo no sentido invertido (replementar)."
			zztool erro " As duas opções poder ser combinadas: r2 ou 2r."
			zztool erro " Uso: zzmat $funcao número [[g|rad|gr] [opção]]"
			return 1
		fi
	;;
	log | ln)
		if (test $# -ge "2" && test $# -le "3" && zzmat testa_num $2)
		then
			local num1 num2
			num1=$(echo "$2" | tr ',' '.')
			zzmat testa_num "$3" && num2=$(echo "$3" | tr ',' '.')
			if test -n "$num2"
			then
				num="l($num1)/l($num2)"
			elif test "$funcao" = "log"
			then
				num="l($num1)/l(10)"
			else
				num="l($num1)"
			fi
		else
			zztool erro " Se não definir a base no terceiro argumento:"
			zztool erro " zzmat log: Logaritmo base 10"
			zztool erro " zzmat ln: Logaritmo Natural base e"
			zztool erro " Uso: zzmat $funcao numero [base]"
			return 1
		fi
	;;
	raiz)
		if (test $# -eq "3" && zzmat testa_num "$3")
		then
			local num1 num2
			case "$2" in
			quadrada)  num1=2;;
			c[úu]bica) num1=3;;
			*)         num1="$2";;
			esac
			num2=$(echo "$3" | tr ',' '.')
			if test $(($num1 % 2)) -eq 0
			then
				if echo "$num2" | grep '^-' > /dev/null
				then
					zztool erro " Não há solução nos números reais para radicando negativo e índice par."
					return 1
				fi
			fi
			if zzmat testa_num $num1
			then
				num=$(awk 'BEGIN {printf "%.'${precisao}'f\n", '$num2'^(1/'$num1')}')
			else
				echo " Uso: zzmat $funcao <quadrada|cubica|numero> numero"
			fi
		else
			zztool erro " zzmat $funcao: Raiz enesima de um número"
			zztool erro " Uso: zzmat $funcao <quadrada|cubica|numero> numero"
			return 1
		fi
	;;
	potencia | elevado | pow)
		if (test $# -eq "3" && zzmat testa_num "$2" && zzmat testa_num "$3")
		then
			local num1 num2
			num1=$(echo "$2" | tr ',' '.')
			num2=$(echo "$3" | tr ',' '.')
			if zztool testa_numero $num2
			then
				num=$(echo "scale=${precisao};${num1}^${num2}" | bc -l | awk '{ printf "%.'${precisao}'f\n", $1 }')
			else
				num=$(awk 'BEGIN {printf "%.'${precisao}'f\n", ('$num1')^('$num2')}')
			fi
		else
			zztool erro " zzmat $funcao: Um número elevado a um potência"
			zztool erro " Uso: zzmat $funcao número potência"
			zztool erro " Uso: zzmat número^potência"
			zztool erro " Ex.: zzmat $funcao 4 3"
			zztool erro " Ex.: zzmat 3^7"
			return 1
		fi
	;;
	area)
		if (test $# -ge "2")
		then
			local num1 num2 num3
			case "$2" in
			triangulo)
				if(zzmat testa_num $3 && zzmat testa_num $4)
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="${num1}*${num2}/2"
				else
					zztool erro " Uso: zzmat $funcao $2 base altura";return 1
				fi
			;;
			retangulo | losango)
				if(zzmat testa_num $3 && zzmat testa_num $4)
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="${num1}*${num2}"
				else
					printf " Uso: zzmat %s %s " $funcao $2 >&2
					test "$2" = "retangulo" && echo "base altura" >&2 || echo "diagonal_maior diagonal_menor" >&2
					return 1
				fi
			;;
			trapezio)
				if(zzmat testa_num $3 && zzmat testa_num $4 && zzmat testa_num $5)
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num3=$(echo "$5" | tr ',' '.')
					num="((${num1}+${num2})/2)*${num3}"
				else
					zztool erro " Uso: zzmat $funcao $2 base_maior base_menor altura";return 1
				fi
			;;
			toro)
				if(zzmat testa_num $3 && zzmat testa_num $4 && test $(zzmat compara_num $3 $4) != "igual")
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="4*${pi}^2*${num1}*${num2}"
				else
					zztool erro " Uso: zzmat $funcao $2 raio1 raio2";return 1
				fi
			;;
			tetraedro | cubo | octaedro | dodecaedro | icosaedro | quadrado | circulo | esfera | cuboctaedro | rombicuboctaedro | rombicosidodecaedro | icosidodecaedro)
				if (test -n "$3")
				then
					if(zzmat testa_num $3)
					then
						num1=$(echo "$3" | tr ',' '.')
						case $2 in
						tetraedro)           num="sqrt(3)*${num1}^2";;
						cubo)                num="6*${num1}^2";;
						octaedro)            num="sqrt(3)*2*${num1}^2";;
						dodecaedro)          num="sqrt(25+10*sqrt(5))*3*${num1}^2";;
						icosaedro)           num="sqrt(3)*5*${num1}^2";;
						quadrado)            num="${num1}^2";;
						circulo)             num="$pi*(${num1})^2";;
						esfera)              num="4*$pi*(${num1})^2";;
						cuboctaedro)         num="(6+2*sqrt(3))*${num1}^2";;
						rombicuboctaedro)    num="2*(9+sqrt(3))*${num1}^2";;
						icosidodecaedro)     num="(5*sqrt(3)+3*sqrt(5)*sqrt(5+2*sqrt(5)))*${num1}^2";;
						rombicosidodecaedro) num="(30+sqrt(30*(10+3*sqrt(5)+sqrt(15*(2+2*sqrt(5))))))*${num1}^2";;
						esac
					elif (test $3 = "truncado" && zzmat testa_num $4)
					then
						num1=$(echo "$4" | tr ',' '.')
						case $2 in
						tetraedro)       num="7*sqrt(3)*${num1}^2";;
						cubo)            num="2*${num1}^2*(6+6*sqrt(2)+6*sqrt(3))";;
						octaedro)        num="(6+sqrt(3)*12)*${num1}^2";;
						dodecaedro)      num="(sqrt(3)+6*sqrt(5+2*sqrt(5)))*5*${num1}^2";;
						icosaedro)       num="3*(10*sqrt(3)+sqrt(5)*sqrt(5+2*sqrt(5)))*${num1}^2";;
						cuboctaedro)     num="12*(2+sqrt(2)+sqrt(3))*${num1}^2";;
						icosidodecaedro) num="30*(1+sqrt(2*sqrt(4+sqrt(5)+sqrt(15+6*sqrt(6)))))*${num1}^2";;
						esac
					elif (test $3 = "snub" && zzmat testa_num $4)
					then
						num1=$(echo "$4" | tr ',' '.')
						case $2 in
						cubo)       num="${num1}^2*(6+8*sqrt(3))";;
						dodecaedro) num="55.286744956*${num1}^2";;
						esac
					else
						zztool erro " Uso: zzmat $funcao $2 lado|raio";return 1
					fi
				else
					zztool erro " Uso: zzmat $funcao $2 lado|raio";return 1
				fi
			;;
			esac
		else
			zztool erro " zzmat $funcao: Cálculo da área de figuras planas e superfícies"
			zztool erro " Uso: zzmat area <triangulo|quadrado|retangulo|losango|trapezio|circulo> numero"
			zztool erro " Uso: zzmat area <esfera|rombicuboctaedro|rombicosidodecaedro> numero"
			zztool erro " Uso: zzmat area <tetraedo|cubo|octaedro|dodecaedro|icosaedro|cuboctaedro|icosidodecaedro> [truncado] numero"
			zztool erro " Uso: zzmat area <cubo|dodecaedro> snub numero"
			zztool erro " Uso: zzmat area toro numero numero"
			return 1
		fi
	;;
	volume)
		if (test $# -ge "2")
		then
			local num1 num2 num3
			case "$2" in
			paralelepipedo)
				if(zzmat testa_num $3 && zzmat testa_num $4 && zzmat testa_num $5)
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num3=$(echo "$5" | tr ',' '.')
					num="${num1}*${num2}*${num3}"
				else
					zztool erro " Uso: zzmat $funcao $2 comprimento largura altura";return 1
				fi
			;;
			cilindro)
				if(zzmat testa_num $3 && zzmat testa_num $4)
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="($pi*(${num1})^2)*${num2}"
				else
					zztool erro " Uso: zzmat $funcao $2 raio altura";return 1
				fi
			;;
			cone)
				if(zzmat testa_num $3 && zzmat testa_num $4)
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="($pi*(${num1})^2)*${num2}/3"
				else
					zztool erro " Uso: zzmat $funcao $2 raio altura";return 1
				fi
			;;
			prisma)
				if(zzmat testa_num $3 && zzmat testa_num $4)
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="${num1}*${num2}"
				else
					zztool erro " Uso: zzmat $funcao $2 area_base altura";return 1
				fi
			;;
			piramide)
				if(zzmat testa_num $3 && zzmat testa_num $4)
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					num="${num1}*${num2}/3"
				else
					zztool erro " Uso: zzmat $funcao $2 area_base altura";return 1
				fi
			;;
			toro)
				local num_maior num_menor
				if(zzmat testa_num $3 && zzmat testa_num $4 && test $(zzmat compara_num $3 $4) != "igual")
				then
					num1=$(echo "$3" | tr ',' '.')
					num2=$(echo "$4" | tr ',' '.')
					test $num1 -gt $num2 && num_maior=$num1 || num_maior=$num2
					test $num1 -lt $num2 && num_menor=$num1 || num_menor=$num2
					num="2*${pi}^2*${num_menor}^2*${num_maior}"
				else
					zztool erro " Uso: zzmat $funcao $2 raio1 raio2";return 1
				fi
			;;
			tetraedro | cubo | octaedro | dodecaedro | icosaedro | esfera | cuboctaedro | rombicuboctaedro | rombicosidodecaedro | icosidodecaedro)
				if test -n "$3"
				then
					if(zzmat testa_num $3)
					then
						num1=$(echo "$3" | tr ',' '.')
						case $2 in
						tetraedro)           num="sqrt(2)/12*${num1}^3";;
						cubo)                num="${num1}^3";;
						octaedro)            num="sqrt(2)/3*${num1}^3";;
						dodecaedro)          num="(15+7*sqrt(5))*${num1}^3/4";;
						icosaedro)           num="(3+sqrt(5))*${num1}^3*5/12";;
						esfera)              num="$pi*(${num1})^3*4/3";;
						cuboctaedro)         num="5/3*sqrt(2)*${num1}^3";;
						rombicuboctaedro)    num="(2*(6+5*sqrt(2))*${num1}^3)/3";;
						icosidodecaedro)     num="((45+17*sqrt(5))*${num1}^3)/6";;
						rombicosidodecaedro) num="(60+29*sqrt(5))/3*${num1}^3";;
						esac
					elif (test $3 = "truncado" && zzmat testa_num $4)
					then
						num1=$(echo "$4" | tr ',' '.')
						case $2 in
						tetraedro)       num="23*sqrt(2)/12*${num1}^3";;
						cubo)            num="(7*${num1}^3*(3+2*sqrt(2)))/3";;
						octaedro)        num="8*sqrt(2)*${num1}^3";;
						dodecaedro)      num="5*(99+47*sqrt(5))/12*${num1}^3";;
						icosaedro)       num="(125+43*sqrt(5))*${num1}^3*1/4";;
						cuboctaedro)     num="(22+14*sqrt(2))*${num1}^3";;
						icosidodecaedro) num="(90+50*sqrt(5))*${num1}^3";;
						esac
					elif (test $3 = "snub" && zzmat testa_num $4)
					then
						num1=$(echo "$4" | tr ',' '.')
						case $2 in
						cubo)       num="7.8894774*${num1}^3";;
						dodecaedro) num="37.61664996*${num1}^3";;
						esac
					else
						zztool erro " Uso: zzmat $funcao $2 lado|raio";return 1
					fi
				else
					zztool erro " Uso: zzmat $funcao $2 lado|raio";return 1
				fi
			;;
			esac
		else
			zztool erro " zzmat $funcao: Cálculo de volume de figuras geométricas"
			zztool erro " Uso: zzmat volume <paralelepipedo|cilindro|esfera|cone|prisma|piramide|rombicuboctaedro|rombicosidodecaedro> numero"
			zztool erro " Uso: zzmat volume <tetraedo|cubo|octaedro|dodecaedro|icosaedro|cuboctaedro|icosidodecaedro> [truncado] numero"
			zztool erro " Uso: zzmat volume <cubo|dodecaedro> snub numero"
			zztool erro " Uso: zzmat volume toro numero numero"
			return 1
		fi
	;;
	mmc | mdc)
		if test $# -ge "3"
		then
			local num_maior num_menor resto mdc mmc num2
			local num1=$2
			shift
			shift
			for num2 in $*
			do
				if (zztool testa_numero $num1 && zztool testa_numero $num2)
				then
					test "$num1" -gt "$num2" && num_maior=$num1 || num_maior=$num2
					test "$num1" -lt "$num2" && num_menor=$num1 || num_menor=$num2

					while test "$num_menor" -ne "0"
					do
						resto=$((${num_maior}%${num_menor}))
						num_maior=$num_menor
						num_menor=$resto
					done

					mdc=$num_maior
					mmc=$((${num1}*${num2}/${mdc}))
				fi
				shift
				test "$funcao" = "mdc" && num1="$mdc" || num1="$mmc"
			done

			case $funcao in
			mmc) echo "$mmc";;
			mdc) echo "$mdc";;
			esac
		else
			zztool erro " zzmat mmc: Menor Múltiplo Comum"
			zztool erro " zzmat mdc: Maior Divisor Comum"
			zztool erro " Uso: zzmat $funcao numero numero ..."
			return 1
		fi
	;;
	somatoria | produtoria)
		#colocar x como a variavel a ser substituida
		if (test $# -eq "4")
		then
			zzmat $funcao $2 $3 1 $4
		elif (test $# -eq "5" && zzmat testa_num $2 && zzmat testa_num $3 &&
			zzmat testa_num $4 && zztool grep_var "x" $5 )
		then
			local equacao numero operacao sequencia num1 num2
			equacao=$(echo "$5" | sed 's/\[/(/g;s/\]/)/g')
			test "$funcao" = "somatoria" && operacao='+' || operacao='*'
			if (test $(zzmat compara_num $2 $3) = 'maior')
			then
				num1=$2; num2=$3
			else
				num1=$3; num2=$2
			fi
			sequencia=$(zzmat pa $num2 $4 $(zzcalcula "(($num1 - $num2)/$4)+1" | zzmat int) | tr ' ' '\n')
			num=$(for numero in $sequencia
			do
				echo "($equacao)" | sed "s/^[x]/($numero)/;s/\([(+-]\)x/\1($numero)/g;s/\([0-9]\)x/\1\*($numero)/g;s/x/$numero/g"
			done | paste -s -d"$operacao" -)
		else
			zztool erro " zzmat $funcao: Soma ou Produto de expressão"
			zztool erro " Uso: zzmat $funcao limite_inferior limite_superior equacao"
			zztool erro " Uso: zzmat $funcao limite_inferior limite_superior razao equacao"
			zztool erro " Usar 'x' como variável na equação"
			zztool erro " Usar '[' e ']' respectivamente no lugar de '(' e ')', ou proteger"
			zztool erro " a fórmula com aspas duplas(\") ou simples(')"
			return 1
		fi
	;;
	media | soma | produto)
		if (test $# -ge "2")
		then
			local soma=0
			local qtde=0
			local produto=1
			local peso=1
			local valor
			shift
			while test $# -ne "0"
			do
				if (zztool grep_var "[" "$1" && zztool grep_var "]" "$1")
				then
					valor=$(echo "$1" | sed 's/\([0-9]\{1,\}\)\[.*/\1/' | tr ',' '.')
					peso=$(echo "$1" | sed 's/.*\[//;s/\]//')
					if (zzmat testa_num "$valor" && zztool testa_numero "$peso")
					then
						if test $funcao = 'produto'
						then
							produto=$(echo "$produto*(${valor}^${peso})" | bc -l)
						else
							soma=$(echo "$soma+($valor*$peso)" | bc -l)
							qtde=$(($qtde+$peso))
						fi
					fi
				elif zzmat testa_num "$1"
				then
					if test $funcao = 'produto'
					then
						produto=$(echo "($produto) * ($1)" | tr ',' '.' | bc -l)
					else
						soma=$(echo "($soma) + ($1)" | tr ',' '.' | bc -l)
						qtde=$(($qtde+1))
					fi
				else
					zztool -e uso mat; return 1;
				fi
				shift
			done

			case "$funcao" in
			media)   num="${soma}/${qtde}";;
			soma)    num="${soma}";;
			produto) num="${produto}";;
			esac
		else
			zztool erro " zzmat $funcao:Soma, Produto ou Média Aritimética e Ponderada"
			zztool erro " Uso: zzmat $funcao numero[[peso]] [numero[peso]] ..."
			zztool erro " Usar o peso entre '[' e ']', justaposto ao número."
			return 1
		fi
	;;
	fat)
		if (test $# -eq "2" -o $# -eq "3" && zztool testa_numero "$2" && test "$2" -ge "1")
		then
			if test "$3" = "s"
			then
				local num1 num2
				num2=1
				for num1 in $(zzseq $2)
				do
					num2=$(echo "$num1 * $num2" | bc | tr -d '\n\\')
					printf "%s " $num2
				done | zztrim -r
				echo
			else
				zzseq $2 | paste -s -d* - | bc | tr -d '\n\\'
				echo
			fi
		else
			zztool erro " zzmat $funcao: Resultado do produto de 1 ao numero atual (fatorial)"
			zztool erro " Com o argumento 's' imprime a sequência até a posição."
			zztool erro " Uso: zzmat $funcao numero [s]"
			zztool erro " Uso: zzmat numero! [s]"
			zztool erro " Ex.: zzmat $funcao 4"
			zztool erro "      zzmat 5!"
			return 1
		fi
	;;
	arranjo | combinacao | arranjo_r | combinacao_r)
		if (test $# -eq "3" && zztool testa_numero "$2" && zztool testa_numero "$3" &&
			test "$2" -ge "$3" && test "$3" -ge "1")
		then
			local n p dnp
			n=$(zzmat fat $2)
			p=$(zzmat fat $3)
			dnp=$(zzmat fat $(($2-$3)))
			case "$funcao" in
			arranjo)    test "$2" -gt "$3" && num="${n}/${dnp}" || return 1;;
			arranjo_r)  zzmat elevado "$2" "$3";;
			combinacao) test "$2" -gt "$3" && num="${n}/(${p}*${dnp})" || return 1;;
			combinacao_r)
				if (test "$2" -gt "$3")
				then
					n=$(zzmat fat $(($2+$3-1)))
					dnp=$(zzmat fat $(($2-1)))
					num="${n}/(${p}*${dnp})"
				else
					return 1
				fi
			;;
			esac
		else
			zztool erro " zzmat arranjo: n elementos tomados em grupos de p (considera ordem)"
			zztool erro " zzmat arranjo_r: n elementos tomados em grupos de p com repetição (considera ordem)"
			zztool erro " zzmat combinacao: n elementos tomados em grupos de p (desconsidera ordem)"
			zztool erro " zzmat combinacao_r: n elementos tomados em grupos de p com repetição (desconsidera ordem)"
			zztool erro " Uso: zzmat $funcao total_numero quantidade_grupo"
			return 1
		fi
	;;
	newton | binomio_newton)
		if (test "$#" -ge "2")
		then
			local num1 num2 grau sinal parcela coeficiente
			num1="a"
			num2="b"
			sinal="+"
			zztool testa_numero "$2" && grau="$2"
			if test -n "$3"
			then
				if test "$3" = "+" -o "$3" = "-"
				then
					sinal="$3"
					test -n "$4" && num1="$4"
					test -n "$5" && num2="$5"
				else
					test -n "$3" && num1="$3"
					test -n "$4" && num2="$4"
				fi
			fi
			echo "($num1)^$grau"
			for parcela in $(zzseq $((grau-1)))
			do
				coeficiente=$(zzmat combinacao $grau $parcela)
				test "$sinal" = "-" -a $((parcela%2)) -eq 1 && printf "%s" "- " || printf "%s" "+ "
				printf "%s * " "$coeficiente"
				echo "($num1)^$(($grau-$parcela)) * ($num2)^$parcela" | sed 's/\^1\([^0-9]\)/\1/g;s/\^1$//'
			done
			test "$sinal" = "-" -a $((grau%2)) -eq 1 && printf "%s" "- " || printf "%s" "+ "
			echo "($num2)^$grau"
		else
			echo " zzmat $funcao: Exibe o desdobramento do binônimo de Newton."
			echo " Exemplo no grau 3: (a + b)^3 = a^3 + 2a^2b + 2ab^2 + b^3"
			echo " Se nenhum sinal for especificado será assumido '+'"
			echo " Se não declarar variáveis serão assumidos 'a' e 'b'"
			echo " Uso: zzmat $funcao grau [+|-] [variavel(a) [variavel(b)]]"
		fi
	;;
	pa | pa2 | pg)
		if (test $# -eq "4" && zzmat testa_num "$2" &&
		zzmat testa_num "$3" && zztool testa_numero "$4")
		then
			local num_inicial razao passo valor
			num_inicial=$(echo "$2" | tr ',' '.')
			razao=$(echo "$3" | tr ',' '.')
			passo=0
			valor=$num_inicial
			while (test $passo -lt $4)
			do
				if test "$funcao" = "pa"
				then
					valor=$(echo "$num_inicial + ($razao * $passo)" | bc -l |
					awk '{printf "%.'${precisao}'f\n", $1}')
				elif test "$funcao" = "pa2"
				then
					valor=$(echo "$valor + ($razao * $passo)" | bc -l |
					awk '{printf "%.'${precisao}'f\n", $1}')
				else
					valor=$(echo "$num_inicial * $razao^$passo" | bc -l |
					awk '{printf "%.'${precisao}'f\n", $1}')
				fi
				valor=$(echo "$valor" | zzmat -p${precisao} sem_zeros)
				test $passo -lt $(($4 - 1)) && printf "%s " "$valor" || printf "%s" "$valor"
				passo=$(($passo+1))
			done
			echo
		else
			zztool erro " zzmat pa:  Progressão Aritmética"
			zztool erro " zzmat pa2: Progressão Aritmética de Segunda Ordem"
			zztool erro " zzmat pg:  Progressão Geométrica"
			zztool erro " Uso: zzmat $funcao inicial razao quantidade_elementos"
			return 1
		fi
	;;
	fibonacci | fib | lucas)
	# Sequência ou número de fibonacci
		if zztool testa_numero "$2"
		then
			awk 'BEGIN {
					seq = ( "'$3'" == "s" ? 1 : 0 )
					num1 = ( "'$funcao'" == "lucas" ? 2 : 0 )
					num2 = 1
					for ( i = 0; i < '$2' + seq; i++ ) {
						if ( seq == 1 ) { printf "%s ", num1 }
						num3 = num1 + num2
						num1 = num2
						num2 = num3
					}
					if ( seq != 1 ) { printf "%s ", num1 }
				}' |
				zztrim -r |
				zztool nl_eof
		else
			echo " Número de fibonacci ou lucas, na posição especificada."
			echo " Com o argumento 's' imprime a sequência até a posição."
			echo " Uso: zzmat $funcao <número> [s]"
		fi
	;;
	tribonacci | trib)
	# Sequência ou número Tribonacci
		if zztool testa_numero "$2"
		then
			awk 'BEGIN {
					seq = ( "'$3'" == "s" ? 1 : 0 )
					num1 = 0
					num2 = 1
					num3 = 1
					for ( i = 0; i < '$2' + seq; i++ ) {
						if ( seq == 1 ) { printf "%s ", num1 }
						num4 = num1 + num2 + num3
						num1 = num2
						num2 = num3
						num3 = num4
					}
					if ( seq != 1 ) { printf "%s ", num1 }
				}' |
				zztrim -r |
				zztool nl_eof
		else
			echo " Número de tribonacci, na posição especificada."
			echo " Com o argumento 's' imprime a sequência até a posição."
			echo " Uso: zzmat $funcao <número> [s]"
		fi
	;;
	r3)
		shift
		if test -n "$1"
		then
			local num num1 num2 ind
			local num3=0
			local num4=0
			while test -n "$1"
			do
				num="$1"
				ind=1
				zztool grep_var "i" "$1" && ind=0 && num=$(echo "$1" | sed 's/i//')
				if (zzmat testa_num ${num%/*} || test ${num%/*} = 'x') && (zzmat testa_num ${num#*/} || test ${num#*/} = 'x')
				then
					num3=$((num3+1))
					if test $((num3%2)) -eq $ind
					then
						test ${num%/*} != 'x' && num1="$num1 ${num%/*}" || num4=$((num4+1))
						test ${num#*/} != 'x' && num2="$num2 ${num#*/}" || num4=$((num4+1))
					else
						test ${num%/*} != 'x' && num2="$num2 ${num%/*}" || num4=$((num4+1))
						test ${num#*/} != 'x' && num1="$num1 ${num#*/}" || num4=$((num4+1))
					fi
				fi
				shift
			done

			unset num
			if test $num4 -eq 1 && test -n "$num1" && test -n "$num2"
			then
				case $(zzmat compara_num $(echo "$num1" | awk '{print NF}') $(echo "$num2" | awk '{print NF}')) in
				maior)
					num=$(echo $(zzmat produto $num1)"/"$(zzmat produto $num2))
				;;
				menor)
					num=$(echo $(zzmat produto $num2)"/"$(zzmat produto $num1))
				;;
				*)
					zzmat $funcao
				;;
				esac
			else
				zzmat $funcao
			fi
		else
			echo " Calcula o valor de 'x', usando a regra de 3 simples ou composta."
			echo " Se alguma das frações tiver a letra i justaposta, é considerada inversamente proporcional."
			echo " Obs.: o i pode ser antes ou depois, mas não pode haver espaço em relação a fração."
			echo "       no local do valor a ser encontrado, digite apenas 'x', e somente uma vez."
			echo " Uso: zzmat $funcao <fração1>[i] <fração2>[i] [<fração3>[i] ...]"
		fi
	;;
	eq2g)
	#Equação do Segundo Grau: Raizes e Vértice
		if (test $# = "4" && zzmat testa_num $2 && zzmat testa_num $3 && zzmat testa_num $4)
		then
			local delta num_raiz vert_x vert_y raiz1 raiz2
			delta=$(echo "$2 $3 $4" | tr ',' '.' | awk '{valor=$2^2-(4*$1*$3); print valor}')
			num_raiz=$(awk 'BEGIN { if ('$delta' > 0)  {print "2"}
									if ('$delta' == 0) {print "1"}
									if ('$delta' < 0)  {print "0"}}')

			vert_x=$(echo "$2 $3" | tr ',' '.' |
			awk '{valor=((-1 * $2)/(2 * $1)); printf "%.'${precisao}'f\n", valor}' |
			zzmat -p${precisao} sem_zeros )

			vert_y=$(echo "$2 $delta" | tr ',' '.' |
			awk '{valor=((-1 * $2)/(4 * $1)); printf "%.'${precisao}'f\n", valor}' |
			zzmat -p${precisao} sem_zeros )

			case $num_raiz in
			0) raiz1="Sem raiz";;
			1) raiz1=$vert_x;;
			2)
				raiz1=$(echo "$2 $3 $delta" | tr ',' '.' |
				awk '{valor=((-1 * $2)-sqrt($3))/(2 * $1); printf "%.'${precisao}'f\n", valor}' |
				zzmat -p${precisao} sem_zeros )

				raiz2=$(echo "$2 $3 $delta" | tr ',' '.' |
				awk '{valor=((-1 * $2)+sqrt($3))/(2 * $1); printf "%.'${precisao}'f\n", valor}' |
				zzmat -p${precisao} sem_zeros )
			;;
			esac
			test "$num_raiz" = "2" && printf "%b\n" "X1: ${raiz1}\nX2: ${raiz2}" || echo "X: $raiz1"
			echo "Vertice: (${vert_x}, ${vert_y})"
		else
			zztool erro " zzmat $funcao: Equação do Segundo Grau (Raízes e Vértice)"
			zztool erro " Uso: zzmat $funcao A B C"
			return 1
		fi
	;;
	d2p)
		if (test $# = "3" && zztool grep_var "," "$2" && zztool grep_var "," "$3")
		then
			local x1 y1 z1 x2 y2 z2 a b
			x1=$(echo "$2" | cut -f1 -d,)
			y1=$(echo "$2" | cut -f2 -d,)
			z1=$(echo "$2" | cut -f3 -d,)
			x2=$(echo "$3" | cut -f1 -d,)
			y2=$(echo "$3" | cut -f2 -d,)
			z2=$(echo "$3" | cut -f3 -d,)
			if (zzmat testa_num $x1 && zzmat testa_num $y1 &&
				zzmat testa_num $x2 && zzmat testa_num $y2 )
			then
				a=$(echo "(($y1)-($y2))^2" | bc -l)
				b=$(echo "(($x1)-($x2))^2" | bc -l)
				if (zzmat testa_num $z1 && zzmat testa_num $z2)
				then
					num="sqrt((($z1)-($z2))^2+$a+$b)"
				else
					num="sqrt($a+$b)"
				fi
			else
				zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(x,y)";return 1
			fi
		else
			zztool erro " zzmat $funcao: Distância entre 2 pontos"
			zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(x,y)"
			return 1
		fi
	;;
	vetor)
		if (test $# -ge "3")
		then
			local valor ang teta fi oper tipo num1 saida
			local x1=0
			local y1=0
			local z1=0
			shift

			test "$1" = "-e" -o "$1" = "-c" && tipo="$1" || tipo="-e"
			oper="+"
			saida=$(echo "$*" | awk '{print $NF}')

			while (test $# -ge "1")
			do
				valor=$(echo "$1" | cut -f1 -d,)
				zztool grep_var "," $1 && teta=$(echo "$1" | cut -f2 -d,)
				zztool grep_var "," $1 && fi=$(echo "$1" | cut -f3 -d,)

				if (test -n "$fi" && zzmat testa_num $valor)
				then
					num1=$(echo "$fi" | sed 's/g$//; s/gr$//; s/rad$//')
					ang=${fi#$num1}
					echo "$fi" | grep -E '(g|rad|gr)$' >/dev/null
					if (test "$?" -eq "0" && zzmat testa_num $num1)
					then
						case $ang in
						g)   fi=$(zzmat converte gr $num1);;
						gr)  fi=$(zzmat converte dr $num1);;
						rad) fi=$num1;;
						esac
						z1=$(echo "$z1 $oper $(zzmat cos ${fi}rad) * $valor" | bc -l)
					elif zzmat testa_num $num1
					then
						z1="$num1"
					fi
				fi

				if (test -n "$teta" && zzmat testa_num $valor)
				then
					num1=$(echo "$teta" | sed 's/g$//; s/gr$//; s/rad$//')
					ang=${teta#$num1}
					echo "$teta" | grep -E '(g|rad|gr)$' >/dev/null
					if (test "$?" -eq "0" && zzmat testa_num $num1)
					then
						case $ang in
						g)   teta=$(zzmat converte gr $num1);;
						gr)  teta=$(zzmat converte dr $num1);;
						rad) teta=$num1;;
						esac
					else
						unset teta
					fi
				fi

				if zzmat testa_num $valor
				then
					test -n "$fi" && num1=$(echo "$(zzmat sen ${fi}rad)*$valor" | bc -l) ||
						num1=$valor
					test -n "$teta" && x1=$(echo "$x1 $oper $(zzmat cos ${teta}rad) * $num1" | bc -l) ||
						x1=$(echo "($x1) $oper ($num1)" | bc -l)
					test -n "$teta" && y1=$(echo "$y1 $oper $(zzmat sen ${teta}rad) * $num1" | bc -l)
				fi
				shift
			done

			valor=$(echo "sqrt(${x1}^2+${y1}^2+${z1}^2)" | bc -l)
			teta=$(zzmat asen $(echo "${y1}/sqrt(${x1}^2+${y1}^2)" | bc -l))
			fi=$(zzmat acos $(echo "${z1}/${valor}" | bc -l))

			case $saida in
			g)
				teta=$(zzmat converte rg $teta)
				fi=$(zzmat converte rg $fi)
			;;
			gr)
				teta=$(zzmat converte rd $teta)
				fi=$(zzmat converte rd $fi)
			;;
			*) saida="rad";;
			esac

			teta=$(awk 'BEGIN {printf "%.'${precisao}'f\n", '$teta'}' | zzmat -p${precisao} sem_zeros )
			fi=$(awk 'BEGIN {printf "%.'${precisao}'f\n", '$fi'}' | zzmat -p${precisao} sem_zeros )

			if test "$tipo" = "-c"
			then
				valor=$(echo "sqrt(${valor}^2-$z1^2)" | bc -l |
					awk '{printf "%.'${precisao}'f\n", $1}' | zzmat -p${precisao} sem_zeros )
				echo "${valor}, ${teta}${saida}, ${z1}"
			else
				valor=$(echo "$valor" | bc -l |
					awk '{printf "%.'${precisao}'f\n", $1}' | zzmat -p${precisao} sem_zeros )
				echo "${valor}, ${teta}${saida}, ${fi}${saida}"
			fi
		else
			zztool erro " zzmat $funcao: Operação entre vetores"
			zztool erro " Tipo de saída podem ser: padrão (-e)"
			zztool erro "  -e: vetor em coordenadas esférica: valor[,teta(g|rad|gr),fi(g|rad|gr)];"
			zztool erro "  -c: vetor em coordenada cilindrica: raio[,teta(g|rad|gr),altura]."
			zztool erro " Os angulos teta e fi tem sufixos g(graus), rad(radianos) ou gr(grados)."
			zztool erro " Os argumentos de entrada seguem o mesmo padrão do tipo de saída."
			zztool erro " E os tipos podem ser misturados em cada argumento."
			zztool erro " Unidade angular é o angulo de saida usado para o vetor resultante,"
			zztool erro " e pode ser escolhida entre g(graus), rad(radianos) ou gr(grados)."
			zztool erro " Não use separador de milhar. Use o ponto(.) como separador decimal."
			zztool erro " Uso: zzmat $funcao [tipo saida] vetor [vetor2] ... [unidade angular]"
			return 1
		fi
	;;
	egr | err)
	#Equação Geral da Reta
	#ax + by + c = 0
	#y1 – y2 = a
	#x2 – x1 = b
	#x1y2 – x2y1 = c
		if (test $# = "3" && zztool grep_var "," "$2" && zztool grep_var "," "$3")
		then
			local x1 y1 x2 y2 a b c redutor m
			x1=$(echo "$2" | cut -f1 -d,)
			y1=$(echo "$2" | cut -f2 -d,)
			x2=$(echo "$3" | cut -f1 -d,)
			y2=$(echo "$3" | cut -f2 -d,)
			if (zzmat testa_num $x1 && zzmat testa_num $y1 &&
				zzmat testa_num $x2 && zzmat testa_num $y2 )
			then
				a=$(awk 'BEGIN {valor=('$y1')-('$y2'); printf "%.'${precisao}'f\n", valor}' | zzmat -p${precisao} sem_zeros)
				b=$(awk 'BEGIN {valor=('$x2')-('$x1');  printf "%+.'${precisao}'f\n", valor}' | zzmat -p${precisao} sem_zeros)
				c=$(zzmat det $x1 $y1 $x2 $y2 | awk '{printf "%+.'${precisao}'f\n", $1}' | zzmat -p${precisao} sem_zeros)
				m=$(awk 'BEGIN {valor=(('$y2'-'$y1')/('$x2'-'$x1')); printf "%.'${precisao}'f\n", valor}' | zzmat -p${precisao} sem_zeros)
				if (zztool testa_numero_sinal $a &&
					zztool testa_numero_sinal $b &&
					zztool testa_numero_sinal $c)
				then
					redutor=$(zzmat mdc $(zzmat abs $a) $(zzmat abs $b) $(zzmat abs $c))
					a=$(awk 'BEGIN {valor=('$a')/('$redutor'); print valor}')
					b=$(awk 'BEGIN {valor=('$b')/('$redutor');  print (valor<0?"":"+") valor}')
					c=$(awk 'BEGIN {valor=('$c')/('$redutor');  print (valor<0?"":"+") valor}')
				fi

				case "$funcao" in
				egr)
					echo "${a}x${b}y${c}=0" |
					sed 's/\([+-]\)1\([xy]\)/\1\2/g;s/[+]\{0,1\}0[xy]//g;s/+0=0/=0/;s/^+//';;
				err)
					redutor=$(awk 'BEGIN {printf "%+.'${precisao}'f\n", -('$m'*'$x1')+'$y1'}' | zzmat -p${precisao} sem_zeros)
					echo "y=${m}x${redutor}";;
				esac
			else
				zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(x,y)";return 1
			fi
		else
			printf " zzmat %s: " $funcao
			case "$funcao" in
			egr) echo "Equação Geral da Reta.";;
			err) echo "Equação Reduzida da Reta.";;
			esac
			zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(x,y)"
			return 1
		fi
	;;
	egc)
	#Equação Geral da Circunferência: Centro e Raio ou Centro e Ponto
	#x2 + y2 - 2ax - 2by + a2 + b2 - r2 = 0
	#A=-2ax | B=-2by | C=a2+b2-r2
	#r=raio | a=coordenada x do centro | b=coordenada y do centro
		if (test $# = "3" && zztool grep_var "," "$2")
		then
			local a b r A B C
			if zztool grep_var "," "$3"
			then
				r=$(zzmat d2p $2 $3)
			elif zzmat testa_num "$3"
			then
				r=$(echo "$3" | tr ',' '.')
			else
				zztool erro " Uso: zzmat $funcao centro(a,b) (numero|ponto(x,y))";return 1
			fi
			a=$(echo "$2" | cut -f1 -d,)
			b=$(echo "$2" | cut -f2 -d,)
			A=$(awk 'BEGIN {valor=-2*('$a'); print (valor<0?"":"+") valor}')
			B=$(awk 'BEGIN {valor=-2*('$b'); print (valor<0?"":"+") valor}')
			C=$(awk 'BEGIN {valor=('$a')^2+('$b')^2-('$r')^2; print (valor<0?"":"+") valor}')
			echo "x^2+y^2${A}x${B}y${C}=0" | sed 's/\([+-]\)1\([xy]\)/\1\2/g;s/[+]0[xy]//g;s/+0=0/=0/'
		else
			zztool erro " zzmat $funcao: Equação Geral da Circunferência (Centro e Raio ou Centro e Ponto)"
			zztool erro " Uso: zzmat $funcao centro(a,b) (numero|ponto(x,y))"
			return 1
		fi
	;;
	egc3p)
	#Equação Geral da Circunferência: 3 Pontos
		if (test $# = "4" && zztool grep_var "," "$2" &&
			zztool grep_var "," "$3" && zztool grep_var "," "$4")
		then
			local x1 y1 x2 y2 x3 y3 A B C D
			x1=$(echo "$2" | cut -f1 -d,)
			y1=$(echo "$2" | cut -f2 -d,)
			x2=$(echo "$3" | cut -f1 -d,)
			y2=$(echo "$3" | cut -f2 -d,)
			x3=$(echo "$4" | cut -f1 -d,)
			y3=$(echo "$4" | cut -f2 -d,)

			if (test $(zzmat det $x1 $y1 1 $x2 $y2 1 $x3 $y3 1) -eq 0)
			then
				zztool erro "Pontos formam uma reta."
				return 1
			fi

			if (! zzmat testa_num $x1 || ! zzmat testa_num $x2 || ! zzmat testa_num $x3)
			then
				zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(c,d) ponto(x,y)";return 1
			fi

			if (! zzmat testa_num $y1 || ! zzmat testa_num $y2 || ! zzmat testa_num $y3)
			then
				zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(c,d) ponto(x,y)";return 1
			fi

			D=$(zzmat det $x1 $y1 1 $x2 $y2 1 $x3 $y3 1)
			A=$(zzmat det -$(echo "$x1^2+$y1^2" | bc) $y1 1 -$(echo "$x2^2+$y2^2" | bc) $y2 1 -$(echo "$x3^2+$y3^2" | bc) $y3 1)
			B=$(zzmat det $x1 -$(echo "$x1^2+$y1^2" | bc) 1 $x2 -$(echo "$x2^2+$y2^2" | bc) 1 $x3 -$(echo "$x3^2+$y3^2" | bc) 1)
			C=$(zzmat det $x1 $y1 -$(echo "$x1^2+$y1^2" | bc) $x2 $y2 -$(echo "$x2^2+$y2^2" | bc) $x3 $y3 -$(echo "$x3^2+$y3^2" | bc))

			A=$(awk 'BEGIN {valor='$A'/'$D';print (valor<0?"":"+") valor}')
			B=$(awk 'BEGIN {valor='$B'/'$D';print (valor<0?"":"+") valor}')
			C=$(awk 'BEGIN {valor='$C'/'$D';print (valor<0?"":"+") valor}')

			x1=$(awk 'BEGIN {valor='$A'/2*-1;print valor}')
			y1=$(awk 'BEGIN {valor='$B'/2*-1;print valor}')

			echo "x^2+y^2${A}x${B}y${C}=0" |
			sed 's/\([+-]\)1\([xy]\)/\1\2/g;s/[+]0[xy]//g;s/+0=0/=0/'
			echo "Centro: (${x1}, ${y1})"
		else
			zztool erro " zzmat $funcao: Equação Geral da Circunferência (3 pontos)"
			zztool erro " Uso: zzmat $funcao ponto(a,b) ponto(c,d) ponto(x,y)"
			return 1
		fi
	;;
	ege)
	#Equação Geral da Esfera: Centro e Raio ou Centro e Ponto
	#x2 + y2 + z2 - 2ax - 2by -2cz + a2 + b2 + c2 - r2 = 0
	#A=-2ax | B=-2by | C=-2cz | D=a2+b2+c2-r2
	#r=raio | a=coordenada x do centro | b=coordenada y do centro | c=coordenada z do centro
		if (test $# = "3" && zztool grep_var "," "$2")
		then
			local a b c r A B C D
			if zztool grep_var "," "$3"
			then
				r=$(zzmat d2p $2 $3)
			elif zzmat testa_num "$3"
			then
				r=$(echo "$3" | tr ',' '.')
			else
				zztool erro " Uso: zzmat $funcao centro(a,b,c) (numero|ponto(x,y,z))";return 1
			fi
			a=$(echo "$2" | cut -f1 -d,)
			b=$(echo "$2" | cut -f2 -d,)
			c=$(echo "$2" | cut -f3 -d,)

			if(! zzmat testa_num $a || ! zzmat testa_num $b || ! zzmat testa_num $c)
			then
				zztool erro " Uso: zzmat $funcao centro(a,b,c) (numero|ponto(x,y,z))";return 1
			fi
			A=$(awk 'BEGIN {valor=-2*('$a'); print (valor<0?"":"+") valor}')
			B=$(awk 'BEGIN {valor=-2*('$b'); print (valor<0?"":"+") valor}')
			C=$(awk 'BEGIN {valor=-2*('$c'); print (valor<0?"":"+") valor}')
			D=$(awk 'BEGIN {valor='$a'^2+'$b'^2+'$c'^2-'$r'^2;print (valor<0?"":"+") valor}')
			echo "x^2+y^2+z^2${A}x${B}y${C}z${D}=0" |
			sed 's/\([+-]\)1\([xyz]\)/\1\2/g;s/[+]0[xyz]//g;s/+0=0/=0/'
		else
			zztool erro " zzmat $funcao: Equação Geral da Esfera (Centro e Raio ou Centro e Ponto)"
			zztool erro " Uso: zzmat $funcao centro(a,b,c) (numero|ponto(x,y,z))"
			return 1
		fi
	;;
	aleatorio | random)
		#Gera um numero aleatorio (randomico)
		local min=0
		local max=1
		local qtde=1
		local n_temp

		if test "$2" = "-h"
		then
			echo " zzmat $funcao: Gera um número aleatório."
			echo " Sem argumentos gera números entre 0 e 1."
			echo " Com 1 argumento numérico este fica como limite superior."
			echo " Com 2 argumentos numéricos estabelecem os limites inferior e superior, respectivamente."
			echo " Com 3 argumentos numéricos, o último é a quantidade de número aleatórios gerados."
			echo " Usa padrão de 6 casas decimais. Use -p0 logo após zzmat para números inteiros."
			echo " Uso: zzmat $funcao [[minimo] maximo] [quantidade]"
			return
		fi

		if (zzmat testa_num $3)
		then
			max=$(echo "$3" | tr ',' '.')
			if zzmat testa_num $2;then min=$(echo "$2" | tr ',' '.');fi
		elif (zzmat testa_num $2)
		then
			max=$(echo "$2" | tr ',' '.')
		fi

		if test $(zzmat compara_num $max $min) = "menor"
		then
			n_temp=$max
			max=$min
			min=$n_temp
			unset n_temp
		fi

		if test -n "$4" && zztool testa_numero $4;then qtde=$4;fi

		case "$funcao" in
		aleatorio)
			awk 'BEGIN {srand();for(i=1;i<='$qtde';i++) { printf "%.'${precisao}'f\n", sprintf("%.'${precisao}'f\n",'$min'+rand()*('$max'-'$min'))}}' |
			zzmat -p${precisao} sem_zeros
			sleep 1
		;;
		random)
			n_temp=1
			while test $n_temp -le $qtde
			do
				zzaleatorio | awk '{ printf "%.'${precisao}'f\n", sprintf("%.'${precisao}'f\n",'$min'+($1/32767)*('$max'-'$min'))}' |
				zzmat -p${precisao} sem_zeros
				n_temp=$((n_temp + 1))
			done
		;;
		esac
	;;
	det)
		# Determinante de matriz (2x2 ou 3x3)
		if (test $# -ge "5" && test $# -le "10")
		then
			local num
			shift
			for num in $*
			do
				if ! zzmat testa_num "$num"
				then
					zztool erro " Uso: zzmat $funcao numero1 numero2 numero3 numero4 [numero5 numero6 numero7 numero8 numero9]"
					return 1
				fi
			done
			case $# in
			4) num=$(echo "($1*$4)-($2*$3)" | tr ',' '.');;
			9) num=$(echo "(($1*$5*$9)+($7*$2*$6)+($4*$8*$3)-($7*$5*$3)-($4*$2*$9)-($1*$8*$6))" | tr ',' '.');;
			*)   zztool erro " Uso: zzmat $funcao numero1 numero2 numero3 numero4 [numero5 numero6 numero7 numero8 numero9]"; return 1;;
			esac
		else
			echo " zzmat $funcao: Calcula o valor da determinante de uma matriz 2x2 ou 3x3."
			echo " Uso: zzmat $funcao numero1 numero2 numero3 numero4 [numero5 numero6 numero7 numero8 numero9]"
			echo " Ex:  zzmat det 1 3 2 4"
		fi
	;;
	conf_eq)
		# Confere equação
		if (test $# -ge "2")
		then
			equacao=$(echo "$2" | sed 's/\[/(/g;s/\]/)/g')
			local x y z eq
			shift
			shift
			while (test $# -ge "1")
			do
				x=$(echo "$1" | cut -f1 -d,)
				zztool grep_var "," $1 && y=$(echo "$1" | cut -f2 -d,)
				zztool grep_var "," $1 && z=$(echo "$1" | cut -f3 -d,)
				eq=$(echo $equacao | sed "s/^[x]/$x/;s/\([(+-]\)x/\1($x)/g;s/\([0-9]\)x/\1\*($x)/g;s/x/$x/g" |
					sed "s/^[y]/$y/;s/\([(+-]\)y/\1($y)/g;s/\([0-9]\)y/\1\*($y)/g;s/y/$y/g" |
					sed "s/^[z]/$z/;s/\([(+-]\)z/\1($z)/g;s/\([0-9]\)z/\1\*($z)/g;s/z/$z/g")
				echo "$eq" | bc -l
				unset x y z eq
				shift
			done
		else
			zztool erro " zzmat $funcao: Confere ou resolve equação."
			zztool erro " As variáveis a serem consideradas são x, y ou z nas fórmulas."
			zztool erro " As variáveis são justapostas em cada argumento separados por vírgula."
			zztool erro " Cada argumento adicional é um novo conjunto de variáveis na fórmula."
			zztool erro " Usar '[' e ']' respectivamente no lugar de '(' e ')', ou proteger"
			zztool erro " a fórmula com aspas duplas(\") ou simples(')"
			zztool erro " Potenciação é representado com o uso de '^', ex: 3^2."
			zztool erro " Não use separador de milhar. Use o ponto(.) como separador decimal."
			zztool erro " Uso: zzmat $funcao equacao numero|ponto(x,y[,z])"
			zztool erro " Ex:  zzmat conf_eq x^2+3*[y-1]-2z+5 7,6.8,9 3,2,5.1"
			return 1
		fi
	;;
	*)
	zzmat -h
	;;
	esac

	if test "$?" -ne "0"
	then
		return 1
	elif test -n "$num"
	then
		echo "$num" | bc -l | awk '{printf "%.'${precisao}'f\n", $1}' | zzmat -p${precisao} sem_zeros
	fi
}

# ----------------------------------------------------------------------------
# zzmd5
# Calcula o código MD5 dos arquivos informados, ou de um texto via STDIN.
# Obs.: Wrapper portável para os comandos md5 (Mac) e md5sum (Linux).
#
# Uso: zzmd5 [arquivo(s)]
# Ex.: zzmd5 arquivo.txt
#      cat arquivo.txt | zzmd5
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-06
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzmd5 ()
{
	zzzz -h md5 "$1" && return

	local tab=$(printf '\t')

	# Testa se o comando existe
	if which md5 >/dev/null 2>&1
	then
		comando="md5"

	elif which md5sum >/dev/null 2>&1
	then
		comando="md5sum"
	else
		zztool erro "Erro: Não encontrei um comando para cálculo MD5 em seu sistema"
		return 1
	fi


	##### Diferenças na saída dos comandos
	###
	### $comando_md5 /a/www/favicon.*
	#
	# Linux (separador é 2 espaços):
	# d41d8cd98f00b204e9800998ecf8427e  /a/www/favicon.gif
	# 902591ef89dbe5663dc7ae44a5e3e27a  /a/www/favicon.ico
	#
	# Mac:
	# MD5 (/a/www/favicon.gif) = d41d8cd98f00b204e9800998ecf8427e
	# MD5 (/a/www/favicon.ico) = 902591ef89dbe5663dc7ae44a5e3e27a
	#
	# zzmd5 (separador é Tab):
	# d41d8cd98f00b204e9800998ecf8427e	/a/www/favicon.gif
	# 902591ef89dbe5663dc7ae44a5e3e27a	/a/www/favicon.ico
	#
	###
	### echo abcdef | $comando_md5
	#
	# Linux:
	# 5ab557c937e38f15291c04b7e99544ad  -
	#
	# Mac:
	# 5ab557c937e38f15291c04b7e99544ad
	#
	# zzmd5:
	# 5ab557c937e38f15291c04b7e99544ad
	#
	###
	### CONCLUSÃO
	### A zzmd5 usa o formato do Mac quando o texto vem pela STDIN,
	### que é mostrar somente o hash e mais nada. Já quando os arquivos
	### são informados via argumentos na linha de comando, a zzmd5 usa
	### um formato parecido com o do Linux, com o hash primeiro e depois
	### o nome do arquivo. A diferença é no separador: um Tab em vez de
	### dois espaços em branco.
	###
	### Considero que a saída da zzmd5 é a mais limpa e fácil de extrair
	### os dados usando ferramentas Unix.


	# Executa o comando do cálculo MD5 e formata a saída conforme
	# explicado no comentário anterior: HASH ou HASH-Tab-Arquivo
	$comando "$@" |
		sed "
			# Mac
			s/^MD5 (\(.*\)) = \(.*\)$/\2$tab\1/

			# Linux
			s/^\([0-9a-f]\{1,\}\)  -$/\1/
			s/^\([0-9a-f]\{1,\}\)  \(.*\)$/\1$tab\2/
		"
}

# ----------------------------------------------------------------------------
# zzminiurl
# http://migre.me
# Encurta uma URL utilizando o site migre.me.
# Obs.: Se a URL não tiver protocolo no início, será colocado http://
# Uso: zzminiurl URL
# Ex.: zzminiurl http://www.funcoeszz.net
#      zzminiurl www.funcoeszz.net         # O http:// no início é opcional
#
# Autor: Vinícius Venâncio Leite <vv.leite (a) gmail com>
# Desde: 2010-04-26
# Versão: 4
# Licença: GPL
# ----------------------------------------------------------------------------
zzminiurl ()
{
	zzzz -h miniurl "$1" && return

	test -n "$1" || { zztool -e uso miniurl; return 1; }

	local url="$1"
	local prefixo='http://'

	# Se o usuário não informou o protocolo, adiciona o padrão
	echo "$url" | egrep '^(https?|ftp|mms)://' >/dev/null || url="$prefixo$url"

	$ZZWWWHTML "http://migre.me/api.txt?url=$url" 2>/dev/null
	echo
}

# ----------------------------------------------------------------------------
# zzminusculas
# Converte todas as letras para minúsculas, inclusive acentuadas.
# Uso: zzminusculas [texto]
# Ex.: zzminusculas NÃO ESTOU GRITANDO             # via argumentos
#      echo NÃO ESTOU GRITANDOO | zzminusculas     # via STDIN
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-06-12
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzminusculas ()
{
	zzzz -h minusculas "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	sed '
		y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
		y/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ/àáâãäåèéêëìíîïòóôõöùúûüçñ/'
}

# ----------------------------------------------------------------------------
# zzmix
# Mistura linha a linha 2 ou mais arquivos, mantendo a sequência.
# Opções:
#  -o <arquivo> - Define o arquivo de saída.
#  -m - Toma como base o arquivo com menos linhas.
#  -M - Toma como base o arquivo com mais linhas.
#  -<numero> - Toma como base o arquivo na posição especificada.
#  -p <relação de linhas> - numero de linhas de cada arquivo de origem.
#    Obs1.: A relação são números de linhas de cada arquivo correspondente na
#           sequência, justapostos separados por vírgula (,).
#    Obs2.: Se a quantidade de linhas na relação for menor que a quantidade de
#           arquivos, os arquivos excedentes adotam a último valor na relação.
#
# Sem opção, toma como base o primeiro arquivo declarado.
#
# Uso: zzmix [-m | -M | -<num>] [-o <arq>] [-p <relação>] arq1 arq2 [arqN] ...
# Ex.: zzmix -m arquivo1 arquivo2 arquivo3  # Base no arquivo com menos linhas
#      zzmix -2 arquivo1 arquivo2 arquivo3  # Base no segundo arquivo
#      zzmix -o out.txt arquivo1 arquivo2   # Mixando para o arquivo out.txt
#      zzmix -p 2,5,6 arq1 arq2 arq3
#      # 2 linhas do arq1, 5 linhas do arq2 e 6 linhas do arq3,
#      # e repete a sequência até o final.
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-11-01
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzmix ()
{
	zzzz -h mix "$1" && return

	local lin_arq arquivo arq_saida arq_ref
	local passos=1
	local linhas=0
	local tipo=1

	# Opção -m ou -M, -numero ou -o
	while test "${1#-}" != "$1"
	do
		if test "$1" = "-o"
		then
			arq_saida="$2"
			shift
		elif test "$1" = "-p"
		then
			passos="$2"
			shift
		else
			tipo="${1#-}"
		fi
		shift
	done

	test -n "$2" || { zztool -e uso mix; return 1; }

	for arquivo
	do
		# Especificar se vai se orientar pelo arquivo com mais ou menos linhas
		if test "$tipo" = "m" || test "$tipo" = "M"
		then
			lin_arq=$(zztool num_linhas "$arquivo")
			if test "$tipo" = "M" && test $lin_arq -gt $linhas
			then
				linhas=$lin_arq
				arq_ref=$arquivo
			fi
			if test "$tipo" = "m" && (test $lin_arq -lt $linhas || test $linhas -eq 0)
			then
				linhas=$lin_arq
				arq_ref=$arquivo
			fi
		fi

		# Verifica se arquivos são legíveis
		zztool arquivo_legivel "$arquivo" || { zztool erro "Um ou mais arquivos inexistentes ou ilegíveis."; return 1; }
	done

	# Se opção é um numero, o arquivo base para as linhas é o mesmo da posição equivalente
	if zztool testa_numero $tipo && test $tipo -le $#
	then
		arq_ref=$(awk -v arg=$tipo 'BEGIN { print ARGV[arg] }' $* 2>/dev/null)
		linhas=$(zztool num_linhas "$arq_ref")
	fi

	# Sem quantidade de linhas mínima não há mistura.
	test "$linhas" -eq 0 && { zztool erro "Não há linhas para serem \"mixadas\"."; return 1; }

	# Onde a "mixagem" ocorre efetivamente.
	awk -v linhas_awk=$linhas -v passos_awk="$passos" -v arq_ref_awk="$arq_ref" -v saida_awk="$arq_saida" '
	BEGIN {
		qtde_passos = split(passos_awk, passo, ",")

		if (qtde_passos < ARGC)
		{
			ultimo_valor = passo[qtde_passos]
			for (i = qtde_passos+1; i <= ARGC; i++) {
				passo[i] = ultimo_valor
			}
		}

		div_linhas = 1
		for (i = 1; i <= ARGC-1; i++) {
			if (arq_ref_awk == ARGV[i]) {
				div_linhas = passo[i]
			}
		}

		bloco_linhas=int(linhas_awk/div_linhas) + (linhas_awk/div_linhas==int(linhas_awk/div_linhas)?0:1)

		for (i = 1; i <= bloco_linhas; i++) {
			for(j = 1; j < ARGC; j++) {
				for (k = 1; k <= passo[j]; k++)
				{
					if ((getline linha < ARGV[j]) > 0) {
						if (length(saida_awk)>0)
							print linha >> saida_awk
						else
							print linha
					}
				}
			}
		}
	}' $* 2>/dev/null
}

# ----------------------------------------------------------------------------
# zzmoneylog
# Consulta lançamentos do Moneylog, com pesquisa avançada e saldo total.
# Obs.: Chamado sem argumentos, pesquisa o mês corrente.
# Obs.: Não expande lançamentos recorrentes e parcelados.
#
# Uso: zzmoneylog [-d data] [-v valor] [-t tag] [--total] [texto]
# Ex.: zzmoneylog                       # Todos os lançamentos deste mês
#      zzmoneylog mercado               # Procure por mercado
#      zzmoneylog -t mercado            # Lançamentos com a tag mercado
#      zzmoneylog -t mercado -d 2011    # Tag mercado em 2011
#      zzmoneylog -t mercado --total    # Saldo total da tag mercado
#      zzmoneylog -d 31/01/2011         # Todos os lançamentos desta data
#      zzmoneylog -d 2011               # Todos os lançamentos de 2011
#      zzmoneylog -d ontem              # Todos os lançamentos de ontem
#      zzmoneylog -d mes                # Todos os lançamentos deste mês
#      zzmoneylog -d mes --total        # Saldo total deste mês
#      zzmoneylog -d 2011-0[123]        # Regex: que casa Jan/Fev/Mar de 2011
#      zzmoneylog -v /                  # Todos os pagamentos parcelados
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-25
# Versão: 1
# Licença: GPL
# Requisitos: zzcalcula zzdatafmt zzdos2unix
# ----------------------------------------------------------------------------
zzmoneylog ()
{
	zzzz -h moneylog "$1" && return

	local data valor tag total
	local arquivo=$ZZMONEYLOG

	# Chamado sem argumentos, mostra o mês corrente
	test $# -eq 0 && data=$(zzdatafmt -f AAAA-MM hoje)

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-t | --tag    ) shift; tag="$1";;
			-d | --data   ) shift; data="$1";;
			-v | --valor  ) shift; valor="$1";;
			-a | --arquivo) shift; arquivo="$1";;
			--total) total=1;;
			--) shift; break;;
			-*) zztool erro "Opção inválida $1"; return 1;;
			*) break;;
		esac
		shift
	done

	# O-oh
	if test -z "$arquivo"
	then
		zztool erro 'Ops, não sei onde encontrar seu arquivo de dados do Moneylog.'
		zztool erro 'Use a variável $ZZMONEYLOG para indicar o caminho.'
		zztool erro
		zztool erro 'Se você usa a versão tudo-em-um, indique o arquivo HTML:'
		zztool erro '    export ZZMONEYLOG=/home/fulano/moneylog.html'
		zztool erro
		zztool erro 'Se você usa vários arquivos TXT, indique a pasta:'
		zztool erro '    export ZZMONEYLOG=/home/fulano/moneylog/'
		zztool erro
		zztool erro 'Além da variável, você também pode usar a opção --arquivo.'
		return 1
	fi

	# Consigo ler o arquivo? (Se não for pasta nem STDIN)
	if ! test -d "$arquivo" && test "$arquivo" != '-'
	then
		zztool arquivo_legivel "$arquivo" || return 1
	fi

	### DATA
	# Formata (se necessário) a data informada.
	# A data não é validada, assim o usuário pode fazer pesquisas parciais,
	# ou ainda usar expressões regulares, exemplo: 2011-0[123].
	if test -n "$data"
	then
		# Para facilitar a vida, alguns formatos comuns são mapeados
		# para o formato do moneylog. Assim, para pesquisar o mês
		# de janeiro do 2011, pode-se fazer: 2011-01 ou 1/2011.
		case "$data" in
			# m/aaaa -> aaaa-mm
			[1-9]/[12][0-9][0-9][0-9])
				data=$(zzdatafmt -f "AAAA-MM" 01/$data)
			;;
			# mm/aaaa -> aaaa-mm
			[01][0-9]/[12][0-9][0-9][0-9])
				data=$(zzdatafmt -f "AAAA-MM" 01/$data)
			;;
			# data com barras -> aaaa-mm-dd
			*/*)
				data=$(zzdatafmt -f "AAAA-MM-DD" $data)
			;;
			# apelidos especiais zzmoneylog
			ano)
				data=$(zzdatafmt -f "AAAA" hoje)
			;;
			mes | mês)
				data=$(zzdatafmt -f "AAAA-MM" hoje)
			;;
			dia)
				data=$(zzdatafmt -f "AAAA-MM-DD" hoje)
			;;
			# apelidos comuns: hoje, ontem, anteontem, etc
			[a-z]*)
				data=$(zzdatafmt -f "AAAA-MM-DD" $data)
			;;
		esac

		# Deu pau no case?
		if test $? -ne 0
		then
			zztool erro "$data" # Mensagem de erro
			return 1
		fi
	fi

	### VALOR
	# É necessário formatar um pouco o texto do usuário para a pesquisa
	# ficar mais poderosa, pois o formato do Moneylog é bem flexível.
	# Assim o usuário não precisa se preocupar com as pequenas diferenças.
	if test -n "$valor"
	then
		valor=$(echo "$valor" | sed '
			# Escapa o símbolo de recorrência: * vira [*]
			s|[*]|[*]|g

			# Remove espaços em branco
			s/ //g

			# Pesquisa vai funcionar com ambos separadores: . e ,
			s/,/[,.]/

			# É possível ter espaços após o sinal
			s/^[+-]/& */

			# O sinal de + é opcional
			s/^+/+*/

			# Busca por ,99 deve funcionar
			# Lembre-se que é possível haver espaços antes do valor
			s/^/[0-9 ,.+-]*/
		')
	fi

	# Começamos mostrando todos os dados, seja do arquivo HTML, do TXT
	# ou de vários TXT. Os IFs seguintes filtrarão estes dados conforme
	# as opções escolhidas pelo usuário.

	if test -d "$arquivo"
	then
		cat "$arquivo"/*.txt
	else
		cat "$arquivo" |
			# Remove código HTML, caso exista
			sed '/^<!DOCTYPE/,/<pre id="data">/ d'
	fi |

	# Remove linhas em branco.
	# Comentários são mantidos, pois podem ser úteis na pesquisa
	zzdos2unix | sed '/^[	 ]*$/ d' |

	# Filtro: data
	if test -n "$data"
	then
		grep "^[^	]*$data"
	else
		cat -
	fi |

	# Filtro: valor
	if test -n "$valor"
	then
		grep -i "^[^	]*	$valor"
	else
		cat -
	fi |

	# Filtro: tag
	if test -n "$tag"
	then
		grep -i "^[^	]*	[^	]*	[^|]*$tag[^|]*|"
	else
		cat -
	fi |

	# Filtro geral, aplicado na linha toda (default=.)
	grep -i "${*:-.}" |

	# Ordena o resultado por data
	sort -n |

	# Devo mostrar somente o total ou o resultado da busca?
	if test -n "$total"
	then
		cut -f 2 | zzcalcula --soma
	else
		cat -
	fi
}

# ----------------------------------------------------------------------------
# zzmudaprefixo
# Move os arquivos que tem um prefixo comum para um novo prefixo.
# Opções:
#   -a, --antigo informa o prefixo antigo a ser trocado.
#   -n, --novo   informa o prefixo novo a ser trocado.
# Uso: zzmudaprefixo -a antigo -n novo
# Ex.: zzmudaprefixo -a "antigo_prefixo" -n "novo_prefixo"
#      zzmudaprefixo -a "/tmp/antigo_prefixo" -n "/tmp/novo_prefixo"
#
# Autor: Lauro Cavalcanti de Sa <lauro (a) ecdesa com>
# Desde: 2009-09-21
# Versão: 2
# Licença: GPLv2
# ----------------------------------------------------------------------------
zzmudaprefixo ()
{

	#set -x

	zzzz -h mudaprefixo "$1" && return

	# Verifica numero minimo de parametros.
	if test $# -lt 4 ; then
		zztool -e uso mudaprefixo
		return 1
	fi

	# Declara variaveis.
	local antigo novo n_sufixo_ini sufixo

	# Opcoes de linha de comando
	while test $# -ge 1
	do
		case "$1" in
			-a | --antigo)
				test -n "$2" || { zztool -e uso mudaprefixo; return 1; }
				antigo=$2
				shift
				;;
			-n | --novo)
				test -n "$2" || { zztool -e uso mudaprefixo; return 1; }
				novo=$2
				shift
				;;
			*) { zztool -e uso mudaprefixo; return 1; } ;;
		esac
		shift
	done

	# Renomeia os arquivos.
	n_sufixo_ini=`echo ${#antigo}`
	n_sufixo_ini=`expr ${n_sufixo_ini} + 1`
	for sufixo in `ls -1 "${antigo}"* | cut -c${n_sufixo_ini}-`;
	do
		# Verifica se eh arquivo mesmo.
		if test -f "${antigo}${sufixo}" -a ! -s "${novo}${sufixo}" ; then
			mv -v "${antigo}${sufixo}" "${novo}${sufixo}"
		else
			zztool erro "CUIDADO: Arquivo ${antigo}${sufixo} nao foi movido para ${novo}${sufixo} porque ou nao eh ordinario, ou destino ja existe!"
			return 1
		fi
	done

}

# ----------------------------------------------------------------------------
# zznarrativa
# http://translate.google.com
# Narra frases em português usando o Google Tradutor.
#
# Uso: zznarrativa palavras
# Ex.: zznarrativa regex é legal
#
# Autor: Kl0nEz <kl0nez (a) wifi org br>
# Desde: 2011-08-23
# Versão: 4
# Licença: GPLv2
# Requisitos: zzplay
# ----------------------------------------------------------------------------
zznarrativa ()
{
	zzzz -h narrativa "$1" && return

	test -n "$1" || { zztool -e uso narrativa; return 1; }

	# Variaveis locais
	local padrao
	local url='http://translate.google.com.br'
	local charset_para='UTF-8'
	local audio_file=$(zztool cache narrativa "$$.wav")

	# Narrativa
	padrao=$(echo "$*" | sed "$ZZSEDURL")
	local audio="translate_tts?ie=$charset_para&q=$padrao&tl=pt"
	$ZZWWWHTML "$url/$audio" > $audio_file && zzplay $audio_file mplayer
	zztool cache rm narrativa
}

# ----------------------------------------------------------------------------
# zznatal
# http://www.ibb.org.br/vidanet
# A mensagem "Feliz Natal" em vários idiomas.
# Uso: zznatal [palavra]
# Ex.: zznatal                   # busca um idioma aleatório
#      zznatal russo             # Feliz Natal em russo
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-12-23
# Versão: 1
# Licença: GPL
# Requisitos: zzlinha
# ----------------------------------------------------------------------------
zznatal ()
{
	zzzz -h natal "$1" && return

	local url='http://www.vidanet.org.br/mensagens/feliz-natal-em-varios-idiomas'
	local cache=$(zztool cache natal)
	local padrao=$1

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		$ZZWWWDUMP "$url" | sed '
			1,10d
			77,179d
			s/^  *//
			s/^(/Chinês  &/
			s/  */: /' > "$cache"
	fi

	# Mostra uma linha qualquer (com o padrão, se informado)
	printf %s '"Feliz Natal" em '
	zzlinha -t "${padrao:-.}" "$cache"
}

# ----------------------------------------------------------------------------
# zznome
# http://www.significado.origem.nom.br/
# Dicionário de nomes, com sua origem, numerologia e arcanos do tarot.
# Pode-se filtrar por significado, origem, letra (primeira letra), tarot
# marca (no mundo), numerologia ou tudo - como segundo argumento (opcional).
# Por padrão lista origem e significado.
#
# Uso: zznome nome [significado|origem|letra|marca|numerologia|tarot|tudo]
# Ex.: zznome maria
#      zznome josé origem
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2011-04-22
# Versão: 4
# Licença: GPL
# Requisitos: zzsemacento zzminusculas
# ----------------------------------------------------------------------------
zznome ()
{
	zzzz -h nome "$1" && return

	local url='http://www.significado.origem.nom.br'
	local ini='Qual a origem do nome '
	local fim='Analise da Primeira Letra do Nome:'
	local nome=$(echo "$1" | zzminusculas | zzsemacento)

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso nome; return 1; }

	case "$2" in
		origem)
			ini='Qual a origem do nome '
			fim='^ *$'
		;;
		significado)
			ini='Qual o significado do nome '
			fim='^ *$'
		;;
		letra)
			ini='Analise da Primeira Letra do Nome:'
			fim='Sua marca no mundo!'
		;;
		marca)
			ini='Sua marca no mundo!'
			fim='Significado - Numerologia - Expressão'
		;;
		numerologia)
			ini='Significado - Numerologia - Expressão'
			fim=' - Arcanos do Tarot'
		;;
		tarot)
			ini=' - Arcanos do Tarot'
			fim='^VEJA TAMBÉM'
		;;
		tudo)
			ini='Qual a origem do nome '
			fim='^VEJA TAMBÉM'
		;;
	esac

	$ZZWWWDUMP "$url/nomes/?q=$nome" |
		sed -n "
		/$ini/,/$fim/ {
			/$fim/d
			/\[.*: :.*\]/d
			/\[[0-9]\{1,\}\.jpg\]/d
			s/^ *//g
			s/^Qual a origem/Origem/
			s/^Qual o significado/Significado/
			/^Significado de / {
				N
				d
			}
			p
		}" 2>/dev/null
		# Escondendo erros pois a codificação do site é estranha
		# https://github.com/aureliojargas/funcoeszz/issues/27
}

# ----------------------------------------------------------------------------
# zznomealeatorio
# Gera um nome aleatório de N caracteres, alternando consoantes e vogais.
# Obs.: Se nenhum parâmetro for passado, gera um nome de 6 caracteres.
# Uso: zznomealeatorio [N]
# Ex.: zznomealeatorio
#      zznomealeatorio 8
#
# Autor: Guilherme Magalhães Gall <gmgall (a) gmail com> twitter: @gmgall
# Desde: 2013-03-03
# Versão: 2
# Licença: GPL
# Requisitos: zzseq zzaleatorio
# ----------------------------------------------------------------------------
zznomealeatorio ()
{
	zzzz -h nomealeatorio "$1" && return

	local vogais='aeiou'
	local consoantes='bcdfghjlmnpqrstvxz'
	# Sem parâmetros, gera nome de 6 caracteres.
	local entrada=${1:-6}
	local contador
	local letra
	local nome
	local posicao
	local lista

	# Se a quantidade de parâmetros for incorreta ou não for número
	# inteiro positivo, mostra mensagem de uso e sai.
	(test $# -gt 1 || ! zztool testa_numero "$entrada") && {
		zztool -e uso nomealeatorio
		return 1
	}

	# Se o usuário quer um nome de 0 caracteres, basta retornar.
	test "$entrada" -eq 0 && return

	# Gera nome aleatório com $entrada caracteres. Alterna consoantes e
	# vogais. Algoritmo baseado na função randomName() do código da
	# página http://geradordenomes.com
	for contador in $(zzseq "$entrada")
	do
		if test $((contador%2)) -eq 1
		then
			lista="$consoantes"
		else
			lista="$vogais"
		fi
		posicao=$(zzaleatorio 1 ${#lista})
		letra=$(echo "$lista" | cut -c "$posicao")
		nome="$nome$letra"
	done
	echo "$nome"
}

# ----------------------------------------------------------------------------
# zznomefoto
# Renomeia arquivos do diretório atual, arrumando a seqüência numérica.
# Obs.: Útil para passar em arquivos de fotos baixadas de uma câmera.
# Opções: -n  apenas mostra o que será feito, não executa
#         -i  define a contagem inicial
#         -d  número de dígitos para o número
#         -p  prefixo padrão para os arquivos
#         --dropbox  renomeia para data+hora da foto, padrão Dropbox
# Uso: zznomefoto [-n] [-i N] [-d N] [-p TXT] arquivo(s)
# Ex.: zznomefoto -n *                        # tire o -n para renomear!
#      zznomefoto -n -p churrasco- *.JPG      # tire o -n para renomear!
#      zznomefoto -n -d 4 -i 500 *.JPG        # tire o -n para renomear!
#      zznomefoto -n --dropbox *.JPG          # tire o -n para renomear!
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-11-10
# Versão: 3
# Licença: GPL
# Requisitos: zzminusculas
# ----------------------------------------------------------------------------
zznomefoto ()
{
	zzzz -h nomefoto "$1" && return

	local arquivo prefixo contagem extensao nome novo nao previa
	local dropbox exif_info exif_cmd
	local i=1
	local digitos=3

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-p)
				prefixo="$2"
				shift; shift
			;;
			-i)
				i=$2
				shift; shift
			;;
			-d)
				digitos=$2
				shift; shift
			;;
			-n)
				nao='[-n] '
				shift
			;;
			--dropbox)
				dropbox=1
				shift
			;;
			*)
				break
			;;
		esac
	done

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso nomefoto; return 1; }

	if ! zztool testa_numero "$digitos"
	then
		zztool erro "Número inválido para a opção -d: $digitos"
		return 1
	fi
	if ! zztool testa_numero "$i"
	then
		zztool erro "Número inválido para a opção -i: $i"
		return 1
	fi
	if test "$dropbox" = 1
	then
		if which "exiftool" >/dev/null 2>&1
		then
			exif_cmd=1
		elif which "exiftime" >/dev/null 2>&1
		then
			exif_cmd=2
		elif which "identify" >/dev/null 2>&1
		then
			exif_cmd=3
		else
			zztool erro "A opção --dropbox requer o comando 'exiftool', 'exiftime' ou 'identify', instale um deles."
			zztool erro "O comando 'exiftime' pode fazer parte do pacote 'exiftags'."
			zztool erro "O comando 'identify' faz parte do pacote ImageMagick."
			return 1
		fi
	fi

	# Para cada arquivo que o usuário informou...
	for arquivo
	do
		# O arquivo existe?
		zztool arquivo_legivel "$arquivo" || continue

		# Componentes do nome novo
		contagem=$(printf "%0${digitos}d" $i)

		# Se tiver extensão, guarda para restaurar depois
		if zztool grep_var . "$arquivo"
		then
			extensao=".${arquivo##*.}"
		else
			extensao=
		fi

		# Nome do arquivo no formato do Camera Uploads do Dropbox,
		# que usa a data e hora em que a foto foi tirada. Exemplo:
		#
		#     2010-04-05 09.02.11.jpg
		#
		# A data é extraída do campo EXIF chamado DateTimeOriginal.
		# Outra opção seria o campo CreateDate. Veja mais informações em:
		# http://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/EXIF.html
		#
		if test "$dropbox" = 1
		then
			# Extrai a data+hora em que a foto foi tirada conforme o comamdo disponível no sistema
			case $exif_cmd in
				1) exif_info=$(exiftool -s -S -DateTimeOriginal -d '%Y-%m-%d %H.%M.%S' "$arquivo") ;;
				2)
					exif_info=$(exiftime -tg "$arquivo" 2>/dev/null |
					awk -F':' '{print $2 "-" $3 "-" $4 "." $5 "." $6}' |
					sed 's/^ *//') ;;
				3)
					exif_info=$(identify -verbose "$arquivo" |
					awk -F':' '/DateTimeOriginal/ {print $3 "-" $4 "-" $5 "." $6 "." $7}' |
					sed 's/^ *//') ;;
			esac

			# A extensão do arquivo é em minúsculas
			extensao=$(echo "$extensao" | zzminusculas)

			novo="$exif_info$extensao"

			# Será que deu problema na execução do comando?
			if test -z "$exif_info"
			then
				echo "Ignorando $arquivo (não possui dados EXIF)"
				continue
			fi

			# Se o arquivo já está com o nome OK, ignore-o
			if test "$novo" = "$arquivo"
			then
				echo "Arquivo $arquivo já está com o nome correto (nada a fazer)"
				continue
			fi

		# Renomeação normal
		else
			# O nome começa com o prefixo, se informado pelo usuário
			if test -n "$prefixo"
			then
				nome=$prefixo

			# Se não tiver prefixo, usa o nome base do arquivo original,
			# sem extensão nem números no final (se houver).
			# Exemplo: DSC123.JPG -> DSC
			else
				nome=$(echo "${arquivo%.*}" | sed 's/[0-9][0-9]*$//')
			fi

			# Compõe o nome novo
			novo="$nome$contagem$extensao"
		fi

		# Mostra na tela a mudança
		previa="$nao$arquivo -> $novo"

		if test "$novo" = "$arquivo"
		then
			# Ops, o arquivo novo tem o mesmo nome do antigo
			echo "$previa" | sed "s/^\[-n\]/[-ERRO-]/"
		else
			echo "$previa"
		fi

		# Atualiza a contagem (Ah, sério?)
		i=$((i+1))

		# Se não tiver -n, vamos renomear o arquivo
		if ! test -n "$nao"
		then
			# Não sobrescreve arquivos já existentes
			zztool arquivo_vago "$novo" || return

			# E finalmente, renomeia
			mv -- "$arquivo" "$novo"
		fi
	done
}

# ----------------------------------------------------------------------------
# zznoticiaslinux
# Busca as últimas notícias sobre Linux em sites nacionais.
# Obs.: Cada site tem uma letra identificadora que pode ser passada como
#       parâmetro, para informar quais sites você quer pesquisar:
#
#         B)r Linux            N)otícias linux
#         V)iva o Linux        U)nder linux
#
# Uso: zznoticiaslinux [sites]
# Ex.: zznoticiaslinux
#      zznoticiaslinux yn
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-12-17
# Versão: 6
# Licença: GPL
# Requisitos: zzfeed
# ----------------------------------------------------------------------------
zznoticiaslinux ()
{
	zzzz -h noticiaslinux "$1" && return

	local url limite
	local n=5
	local sites='byvucin'

	limite="sed ${n}q"

	test -n "$1" && sites="$1"

	# Viva o Linux
	if zztool grep_var v "$sites"
	then
		url='http://www.vivaolinux.com.br/index.rdf'
		echo
		zztool eco "* Viva o Linux ($url):"
		zzfeed -n $n "$url"
	fi

	# Br Linux
	if zztool grep_var b "$sites"
	then
		url='http://br-linux.org/feed/'
		echo
		zztool eco "* BR-Linux ($url):"
		zzfeed -n $n "$url"
	fi

	# UnderLinux
	if zztool grep_var u "$sites"
	then
		url='https://under-linux.org/external.php?do=rss&type=newcontent&sectionid=1&days=120'
		echo
		zztool eco "* UnderLinux ($url):"
		zzfeed -n $n "$url"
	fi

	# Notícias Linux
	if zztool grep_var n "$sites"
	then
		url='http://feeds.feedburner.com/NoticiasLinux'
		echo
		zztool eco "* Notícias Linux ($url):"
		zzfeed -n $n "$url"
	fi
}

# ----------------------------------------------------------------------------
# zznoticiassec
# Busca as últimas notícias em sites especializados em segurança.
# Obs.: Cada site tem uma letra identificadora que pode ser passada como
#       parâmetro, para informar quais sites você quer pesquisar:
#
#       Linux Security B)rasil    Linux T)oday - Security
#       Linux S)ecurity           Security F)ocus
#       C)ERT/CC
#
# Uso: zznoticiassec [sites]
# Ex.: zznoticiassec
#      zznoticiassec bcf
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2003-07-13
# Versão: 4
# Licença: GPL
# Requisitos: zzfeed
# ----------------------------------------------------------------------------
zznoticiassec ()
{
	zzzz -h noticiassec "$1" && return

	local url limite
	local n=5
	local sites='bsctf'

	limite="sed ${n}q"

	test -n "$1" && sites="$1"

	# LinuxSecurity Brasil
	if zztool grep_var b "$sites"
	then
		url='http://www.linuxsecurity.com.br/share.php'
		echo
		zztool eco "* LinuxSecurity Brasil ($url):"
		zzfeed -n $n "$url"
	fi

	# Linux Security
	if zztool grep_var s "$sites"
	then
		url='http://www.linuxsecurity.com/linuxsecurity_advisories.rdf'
		echo
		zztool eco "* Linux Security ($url):"
		zzfeed -n $n "$url"
	fi

	# CERT/CC
	if zztool grep_var c "$sites"
	then
		url='http://www.us-cert.gov/channels/techalerts.rdf'
		echo
		zztool eco "* CERT/CC ($url):"
		zzfeed -n $n "$url"
	fi

	# Linux Today - Security
	if zztool grep_var t "$sites"
	then
		url='http://feeds.feedburner.com/linuxtoday/linux'
		echo
		zztool eco "* Linux Today - Security ($url):"
		zzfeed -n $n "$url"
	fi

	# Security Focus
	if zztool grep_var f "$sites"
	then
		url='http://www.securityfocus.com/bid'
		echo
		zztool eco "* SecurityFocus Vulns Archive ($url):"
		$ZZWWWDUMP "$url" |
			sed -n '
				/^ *\([0-9]\{4\}-[0-9][0-9]-[0-9][0-9]\)/ {
					G
					s/^ *//
					s/\n//p
				}
				h' |
			$limite
	fi
}

# ----------------------------------------------------------------------------
# zznumero
# Formata um número como: inteiro, moeda, por extenso, entre outros.
# Nota: Por extenso suporta 81 dígitos inteiros e até 26 casas decimais.
#
# Opções:
#   -f <padrão|número>  Padrão de formatação do printf, incluindo %'d e %'.f
#                       ou precisão se apenas informado um número
#   -p <prefixo>        Um prefixo para o número, se for R$ igual a opção -m
#   -s <sufixo>         Um sufixo para o número
#   -m | --moeda        Trata valor monetário, sobrepondo as configurações de
#                       -p, -s e -f
#   -t                  Número parcialmente por extenso, ex: 2 milhões 350 mil
#   --texto             Número inteiramente por extenso, ex: quatro mil e cem
#   -l                  Uma classe numérica por linha, quando optar no número
#                       por extenso
#   --de <formato>      Formato de entrada
#   --para <formato>    Formato de saída
#   --int               Parte inteira do número, sem arredondamento
#   --frac              Parte fracionária do número
#
# Formatos para as opções --de e --para:
#   pt ou pt-br => português (brasil)
#   en          => inglês (americano)
#
# Uso: zznumero [opções] <número>
# Ex.: zznumero 12445.78                      # 12.445,78
#      zznumero --texto 4567890,213           # quatro milhões, quinhentos...
#      zznumero -m 85,345                     # R$ 85,34
#      echo 748 | zznumero -f "%'.3f"         # 748,000
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-05
# Versão: 13
# Licença: GPL
# Requisitos: zzvira
# ----------------------------------------------------------------------------
zznumero ()
{
	zzzz -h numero "$1" && return

	local texto=0
	local prec='-'
	local linha=0
	local sufixo=''
	local num_part=0
	local milhar_de='.'
	local decimal_de=','
	local milhar_para='.'
	local decimal_para=','
	local numero qtde_v qtde_p n_formato num_int num_frac num_saida prefixo sinal n_temp

	# Zero a Novecentos e noventa e nove (base para as demais classes)
	local ordem1="\
0:::
1:um::cento
2:dois:vinte:duzentos
3:três:trinta:trezentos
4:quatro:quarenta:quatrocentos
5:cinco:cinquenta:quinhentos
6:seis:sessenta:seiscentos
7:sete:setenta:setecentos
8:oito:oitenta:oitocentos
9:nove:noventa:novecentos
10:dez::
11:onze::
12:doze::
13:treze::
14:catorze::
15:quinze::
16:dezesseis::
17:dezessete::
18:dezoito::
19:dezenove::"

	# Ordem de grandeza x 1000 (Classe)
	local ordem2="\
0:
1:mil
2:milhões
3:bilhões
4:trilhões
5:quadrilhões
6:quintilhões
7:sextilhões
8:septilhões
9:octilhões
10:nonilhões
11:decilhões
12:undecilhões
13:duodecilhões
14:tredecilhões
15:quattuordecilhões
16:quindecilhões
17:sexdecilhões
18:septendecilhões
19:octodecilhões
20:novendecilhões
21:vigintilhões
22:unvigintilhões
23:douvigintilhões
24:tresvigintilhões
25:quatrivigintilhões
26:quinquavigintilhões"

	# Ordem de grandeza base para a ordem4
	local ordem3="\
1:décimos
2:centésimos"

	# Ordem de grandeza / 1000 (Classe)
	local ordem4="\
1:milésimos
2:milionésimos
3:bilionésimos
4:trilionésimos
5:quadrilionésimos
6:quintilionésimos
7:sextilionésimos
8:septilionésimos"

	# Opções
	while  test "${1#-}" != "$1"
	do
		case "$1" in
		-f)
			# Formato estabelecido pelo usuário conforme printf ou precisão
			# Precisão no formato do printf (esperado)
			n_formato="$2"

			# Sem limites de precisão
			if test "$2" = "-"
			then
				prec="$2"
				unset n_formato
			fi

			# Precisão definida
			if zztool testa_numero "$2"
			then
				prec="$2"
				unset n_formato
			fi
			shift
			shift
		;;

		--de)
			# Formato de entrada
			if test "$2" = "pt" -o "$2" = "pt-br"
			then
				milhar_de='.'
				decimal_de=','
				shift
			elif test "$2" = "en"
			then
				milhar_de=','
				decimal_de='.'
				shift
			fi
			shift
		;;

		--para)
			# Formato de saída
			if test "$2" = "pt" -o "$2" = "pt-br"
			then
				milhar_para='.'
				decimal_para=','
				shift
			elif test "$2" = "en"
			then
				milhar_para=','
				decimal_para='.'
				shift
			fi
			shift
		;;

		# Define qual parte do número a exibir
		# 0 = sem restrição(padrão)  1 = só parte inteira  2 = só parte fracionária
		--int) num_part=1; shift;;
		--frac) num_part=2; shift;;

		-p)
			# Prefixo escolhido pelo usuário
			prefixo="$2"
			echo "$2" | grep '^ *[rR]$ *$' > /dev/null && prefixo='R$ '
			shift
			shift
		;;

		-s)
			# Sufixo escolhido pelo usuário
			sufixo="$2"
			shift
			shift
		;;

		-t | --texto)
			# Variável para número por extenso
			# Flag para formato por extenso
			test "$1" = "-t" && texto=1
			test "$1" = "--texto" && texto=2
			shift
		;;

		-l)
			# No modo texto, uma classe numérica por linha
			linha=1
			shift
		;;

		-m | --moeda)
			# Solicitando formato moeda (sobrepõe as opções de prefixo, sufixo e formato)
			prec=2
			prefixo='R$ '
			unset sufixo
			unset n_formato
			shift
		;;

		*) break;;
		esac
	done

	# Habilitar entrada direta ou através de pipe
	n_temp=$(zztool multi_stdin "$@")

	# Adequando entrada do valor a algumas possíveis armadilhas
	set - $n_temp
	n_temp=$(echo "$1" | sed 's/[.,]$//')
	n_temp=$(echo "$n_temp" | sed 's/^\([.,]\)/0\1/')

	# Verificando se a entrada é apenas numérica, incluindo ponto (.) e vírgula (,)
	test $(printf -- "$n_temp" | tr -d [+0-9.,-] | wc -m) -eq 0 || return 1
	# Verificando se há números
	test $(printf -- "$n_temp" | tr -d -c [0-9] | wc -m) -gt 0 || return 1
	set - $n_temp

	# Armazenando o sinal, se presente
	sinal=$(echo "$1" | cut -c1)
	if test "$sinal" = "+" -o "$sinal" = "-"
	then
		set - $(echo "$1" | sed 's/^[+-]//')
	else
		unset sinal
	fi

	# Trocando o símbolo de milhar de entrada por "m" e depois por . (ponto)
	# Trocando o símbolo de decimal de entrada por "d" e depois , (vírgula)
	n_temp=$(echo "$1" | tr "${milhar_de}" 'm' | tr "${decimal_de}" 'd')
	n_temp=$(echo "$n_temp" | tr 'm' '.' | tr 'd' ',')

	set - $n_temp

	if zztool testa_numero "$1" && ! zztool grep_var 'R$' "$prefixo"
	then
	# Testa se o número é um numero inteiro sem parte fracionária ou separador de milhar
		if test ${#n_formato} -gt 0
		then
			numero=$(printf "${n_formato}" "$1" 2>/dev/null)
		else
			numero=$(echo "$1" | zzvira | sed 's/.../&./g;s/\.$//' | zzvira)
		fi
		num_int="$1"
		if test "$num_part" != "2"
		then
			num_saida="${sinal}${numero}"

			# Aplicando o formato conforme opção --para
			num_saida=$(echo "$num_saida" | tr '.' "${milhar_para}")
		fi

	else

		# Testa se o número é um numero inteiro sem parte fracionária ou separador de milhar
		# e que tem o prefixo 'R$', caracterizando como moeda
		if zztool testa_numero "$1" && zztool grep_var 'R$' "$prefixo"
		then
			numero="${1},00"
		fi

		# Quantidade de pontos ou vírgulas no número informado
		qtde_p=$(echo "$1" | tr -cd '.'); qtde_p=${#qtde_p}
		qtde_v=$(echo "$1" | tr -cd ','); qtde_v=${#qtde_v}

		# Número com o "ponto decimal" separando a parte fracionária, sem separador de milhar
		# Se for padrão 999.999, é considerado um inteiro
		if test $qtde_p -eq 1 -a $qtde_v -eq 0 && zztool testa_numero_fracionario "$1"
		then
			if echo "$1" | grep '^[0-9]\{1,3\}\.[0-9]\{3\}$' >/dev/null
			then
				numero=$(echo "$1" | tr -d '.')
			else
				numero=$(echo "$1" | tr '.' ',')
			fi
		fi

		# Número com a "vírgula" separando da parte fracionária, sem separador de milhares
		if test $qtde_v -eq 1 -a $qtde_p -eq 0 && zztool testa_numero_fracionario "$1"
		then
			numero="$1"
		fi

		# Número com o "ponto" como separador de milhar, e sem parte fracionária
		if (test $qtde_p -gt 1 -a $qtde_v -eq 0 && test -z $numero )
		then
			echo $1 | grep '^[0-9]\{1,3\}\(\.[0-9]\{3\}\)\{1,\}$' >/dev/null
			test $? -eq 0  && numero=$(echo $1 | tr -d '.')
		fi

		# Número com a "vírgula" como separador de milhar, e sem parte fracionária
		if (test $qtde_v -gt 1 -a $qtde_p -eq 0 && test -z $numero )
		then
			echo $1 | grep '^[0-9]\{1,3\}\(,[0-9]\{3\}\)\{1,\}$' >/dev/null
			test $? -eq 0  && numero=$(echo $1 | tr -d ',')
		fi

		# Número com uma "vírgula" e um "ponto", nesse caso tem separador de millhar e parte facionária
		if (test $qtde_p -eq 1 -a $qtde_v -eq 1 && test -z $numero )
		then
			numero=$(echo $1 | sed 's/[.,]//' | tr '.' ',')
		fi

		# Numero começando com ponto ou vírgula, sendo considerado só fracionário
		if test -z $numero
		then
			echo $1 | grep '^[,.][0-9]\{1,\}$' >/dev/null
			test $? -eq 0  && numero=$(echo "0${1}" | tr '.' ',')
		fi

		if test -z $numero
		then
		# Deixando o número com o formato 0000,00 (sem separador de milhar)
			# Número com o "ponto" separando a parte fracionária e vírgula como separador de milhar
			echo $1 | grep '^[0-9]\{1,3\}\(,[0-9]\{3\}\)\{1,\}\.[0-9]\{1,\}$' >/dev/null
			test $? -eq 0  && numero=$(echo $1 | tr -d ',' | tr '.' ',')

			# Número com a "vírgula" separando a parte fracionária e ponto como separador de milhar
			echo $1 | grep '^[0-9]\{1,3\}\(\.[0-9]\{3\}\)\{1,\},[0-9]\{1,\}$' >/dev/null
			test $? -eq 0  && numero=$(echo $1 | tr -d '.')
		fi

		if test -n $numero
		then
			# Separando componentes dos números
			num_int=${numero%,*}
			zztool grep_var ',' "$numero" && num_frac=${numero#*,}

			# Tirando os zeros não significativos
			num_int=$(echo "$num_int" | sed 's/^0*//')
			test ${#num_int} -eq 0 && num_int=0

			test ${#num_frac} -gt 0 && num_frac=$(echo "$num_frac" | sed 's/0*$//')

			if test ${#num_frac} -gt 0
			then
				zztool testa_numero $num_frac || { zztool -e uso numero; return 1; }
			fi

			# Se houver precisão estabelecida pela opção -f
			if test "$prec" != "-" && test $prec -ge 0 && test ${#n_formato} -eq 0
			then
				# Para arredondamento usa-se a seguinte regra:
				#  Se o próximo número além da precisão for maior que 5 arredonda-se para cima
				#  Se o próximo número além da precisão for menor que 5 arredonda-se para baixo
				#  Se o próximo número além da precisão for 5, vai depender do número anterior
				#    Se for par arredonda-se para baixo
				#    Se for ímpar arredonda-se para cima
				if test ${#num_frac} -gt $prec
				then

					# Quando for -f 0, sem casas decimais, guardamos o ultimo digito do num_int (parte inteira)
					unset n_temp
					if test $prec -eq 0
					then
						n_temp=${#num_int}
						n_temp=$(echo "$num_int" | cut -c $n_temp)
					fi

					num_frac=$(echo "$num_frac" | cut -c 1-$((prec + 1)))

					if test $(echo "$num_frac" | cut -c $((prec + 1))) -ge 6
					then
						# Último número maior que cinco (além da precisão), arredonda pra cima
						if test $prec -eq 0
						then
							unset num_frac
							num_int=$(echo "$num_int + 1" | bc)
						else
							num_frac=$(echo "$num_frac" | cut -c 1-${prec})
							if echo "$num_frac" | grep -E '^9{1,}$' > /dev/null
							then
								num_int=$(echo "$num_int + 1" | bc)
								num_frac=0
							else
								num_frac=$(echo "$num_frac + 1" | bc)
							fi
						fi

					elif test $(echo "$num_frac" | cut -c $((prec + 1))) -le 4
					then
						# Último número menor que cinco (além da precisão), arredonda pra baixo (trunca)
						if test $prec -eq 0
						then
							unset num_frac
						else
							num_frac=$(echo "$num_frac" | cut -c 1-${prec})
						fi

					else
						if test $prec -eq 0
						then
							unset num_frac
							# Se o último número do num_int for ímpar, arredonda-se para cima
							if test $(($n_temp % 2)) -eq 1
							then
								num_int=$(echo "$num_int + 1" | bc)
							fi
						else
						# Determinando último número dentro da precisão é par
							if test $(echo $(($(echo $num_frac | cut -c ${prec}) % 2))) -eq 0
							then
								# Se sim arredonda-se para baixo (trunca)
								num_frac=$(echo "$num_frac" | cut -c 1-${prec})
							else
								# Se não arredonda-se para cima
								num_frac=$(echo "$num_frac" | cut -c 1-${prec})

								# Exceção: Se num_frac for 9*, vira 0* e aumenta num_int em mais 1
								echo "$num_frac" | cut -c 1-${prec} | grep '^9\{1,\}$' > /dev/null
								if test $? -eq 0
								then
									unset num_frac
									num_int=$(echo "$num_int + 1" | bc)
								else
									num_frac=$(echo "$num_frac + 1" | bc)
								fi
							fi
						fi
					fi

					# Restaurando o tamanho do num_frac
					while test ${#num_frac} -lt $prec -a ${#num_frac} -gt 0
					do
						num_frac="0${num_frac}"
					done
				fi

				# Tirando os zeros não significativos
				num_frac=$(echo "$num_frac" | sed 's/0*$//')
			fi

			test "$num_part" = "1" && unset num_frac
			test "$num_part" = "2" && unset num_int

			if zztool grep_var 'R$' "$prefixo"
			then
			# Caso especial para opção -m, --moedas ou prefixo 'R$'
			# Formato R$ 0.000,00 (sempre)
				# Arredondamento para 2 casas decimais
				test ${#num_frac} -eq 0 -a $texto -eq 0 && num_frac="00"
				test ${#num_frac} -eq 1 && num_frac="${num_frac}0"
				test ${#num_int} -eq 0 -a $texto -eq 0 && num_int=0

				numero=$(echo "${num_int}" | zzvira | sed 's/.../&\./g;s/\.$//' | zzvira)
				num_saida="${numero},${num_frac}"

				# Aplicando o formato conforme opção --para
				num_saida=$(echo "$num_saida" | tr '.' 'm' | tr ',' 'd')
				num_saida=$(echo "$num_saida" | tr 'm' "${milhar_para}" | tr 'd' "${decimal_para}")

			elif test ${#n_formato} -gt 0
			then

			# Conforme formato solicitado pelo usuário
				if test ${#num_frac} -gt 0
				then
				# Se existir parte fracionária

					# Para shell configurado para vírgula como separador da parte decimal
					numero=$(printf "${n_formato}" "${num_int},${num_frac}" 2>/dev/null)
					# Para shell configurado para ponto como separador da parte decimal
					test $? -ne 0 && numero=$(printf "${n_formato}" "${num_int}.${num_frac}" 2>/dev/null)
				else
				# Se tiver apenas a parte inteira
					numero=$(printf "${n_formato}" "${num_int}" 2>/dev/null)
				fi
				num_saida=$numero
			else
				numero=$(echo "${num_int}" | zzvira | sed 's/.../&\./g;s/\.$//' | zzvira)
				num_saida="${numero},${num_frac}"

				# Aplicando o formato conforme opção --para
				num_saida=$(echo "$num_saida" | tr '.' 'm' | tr ',' 'd')
				num_saida=$(echo "$num_saida" | tr 'm' "${milhar_para}" | tr 'd' "${decimal_para}")
			fi

			if zztool grep_var 'R$' "$prefixo"
			then
				num_saida=$(echo "${sinal}${prefixo}${num_saida}" | sed 's/[,.]$//')
			else
				num_saida=$(echo "${sinal}${num_saida}" | sed 's/[,.]$//')
			fi

		fi
	fi

	if test $texto -eq 1 -o $texto -eq 2
	then

		######################################################################

		# Escrevendo a parte inteira. (usando a variável qtde_p emprestada)
		qtde_p=$(((${#num_int}-1) / 3))

		# Colocando os números como argumentos
		set - $(echo "${num_int}" | zzvira | sed 's/.../&\ /g' | zzvira)

		# Liberando as variáveis numero e num_saida para receber o número por extenso
		unset numero
		unset num_saida

		# Caso especial para o 0 (zero)
		if test "$num_int" = "0"
		then
			test $texto -eq 1 && num_saida=$num_int
			test $texto -eq 2 && num_saida='zero'
		fi

		while test -n "$1"
		do
			# Emprestando a variável qtde_v para cada conjunto de 3 números do número original (ordem de grandeza)
			# Tirando os zeros não significativos nesse contexto

			qtde_v=$(echo "$1" | sed 's/^[ 0]*//')

			if test ${#qtde_v} -gt 0
			then
				# Emprestando a variável n_formato para guardar a descrição da ordem2
				n_formato=$(echo "$ordem2" | grep "^${qtde_p}:" 2>/dev/null | cut -f2 -d":")
				test "$qtde_v" = "1" && n_formato=$(echo "$n_formato" | sed 's/ões/ão/')

				if test $texto -eq 2
				then
				# Números também por extenso

					case ${#qtde_v} in
						1)
							# Número unitario, captura direta do texto no segundo campo
							numero=$(echo "$ordem1" | grep "^${qtde_v}:" | cut -f2 -d":")
						;;
						2)
							if test $(echo "$qtde_v" | cut -c1) -eq 1
							then
								# Entre 10 e 19, captura direta do texto no segundo campo
								numero=$(echo "$ordem1" | grep "^${qtde_v}:" | cut -f2 -d":")
							elif test $(echo "$qtde_v" | cut -c2) -eq 0
							then
								# Dezenas, captura direta do texto no terceiro campo
								n_temp=$(echo "$qtde_v" | cut -c1)
								numero=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f3 -d":")
							else
								# 21 a 99, excluindo as dezenas terminadas em zero
								# Dezena
								n_temp=$(echo "$qtde_v" | cut -c1)
								numero=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f3 -d":")

								# Unidade
								n_temp=$(echo "$qtde_v" | cut -c2)
								n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f2 -d":")

								# Numero dessa classe
								numero="$numero e $n_temp"
							fi
						;;
						3)
							if test $qtde_v -eq 100
							then
								# Exceção para o número cem
								numero="cem"
							else
								# 101 a 999
								# Centena
								n_temp=$(echo "$qtde_v" | cut -c1)
								numero=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f4 -d":")

								# Dezena
								n_temp=$(echo "$qtde_v" | cut -c2)
								if test "$n_temp" != "0"
								then
									if test "$n_temp" = "1"
									then
										n_temp=$(echo "$qtde_v" | cut -c2-3)
										n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f2 -d":")
										numero="$numero e $n_temp"
									else
										n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f3 -d":")
										numero="$numero e $n_temp"
									fi
								fi

								# Unidade
								n_temp=$(echo "$qtde_v" | cut -c2)
								if test "$n_temp" != "1"
								then
									n_temp=$(echo "$qtde_v" | cut -c3)
									if test "$n_temp" != "0"
									then
										n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f2 -d":")
										numero="$numero e $n_temp"
									fi
								fi
							fi
						;;
					esac
				fi

				if test $texto -eq 2
				then
					if test -n "$n_formato"
					then
						test -n "$num_saida" && num_saida="${num_saida}, ${numero} ${n_formato}" || num_saida="${numero} ${n_formato}"
					else
						num_saida="${num_saida} ${numero}"
						num_saida=$(echo "${num_saida}" | sed 's/ilhões  *\([a-z]\)/ilhões, \1/;s/ilhão  *\([a-z]\)/ilhão, \1/')
					fi
				else
					num_saida="${num_saida} ${qtde_v} ${n_formato}"
				fi
			fi

			qtde_p=$((qtde_p - 1))
			shift
		done
		test -n "$num_saida" && num_saida=$(echo "${num_saida}" | sed 's/ *$//;s/ \{1,\}/ /g')

		# Milhar seguido de uma centena terminada em 00.
		# Milhar seguida de uma unidade ou dezena
		# Caso "Um mil" em desuso, apenas "mil" usa-se
		if zztool grep_var ' mil' "${num_saida}"
		then
			# Colocando o "e" entre o mil seguido de 1 ao 19
			for n_temp in $(echo "$ordem1" | cut -f 2 -d: | sed '/^ *$/d')
			do
				num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed "s/ mil $n_temp$/ mil e $n_temp/")
				num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed "s/^ *mil $n_temp$/ mil e $n_temp/")
			done

			# Colocando o "e" entre o mil seguido de dezenas terminadas em 0
			for n_temp in $(echo "$ordem1" | cut -f 3 -d: | sed '/^ *$/d' )
			do
				num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed "s/ mil $n_temp$/ mil e $n_temp/")
				num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed "s/^ *mil $n_temp$/ mil e $n_temp/")
			done

			# Colocando o "e" entre o mil seguido de dezenas não terminadas em 0
			# usando as variáveis milhar_para e decimal_para emprestada para esse laço
			for milhar_para in $(echo "$ordem1" | sed -n '3,10p' | cut -f3 -d:)
			do
				for decimal_para in $(echo "$ordem1" | sed -n '2,10p' | cut -f2 -d:)
				do
					n_temp="$milhar_para e $decimal_para"
					num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed "s/ mil $n_temp$/ mil e $n_temp/")
					num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed "s/^ *mil $n_temp$/ mil e $n_temp/")
				done
			done

			# Trabalhando o contexto do e entre classe do milhar e unidade.
			num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed 's/\( mil \)\([a-z]*\)entos$/\1 e \2entos/')
			num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed 's/ mil cem$/ mil e cem/')

			# Tabalhando o contexto do "um mil"
			num_saida=$(echo "${num_saida}" | sed 's/^ *//;s/ *$//' | sed 's/^ *um mil /mil /;s/^ *um mil *$/mil/')
			num_saida=$(echo "${num_saida}" | sed 's/, *um mil /, mil /')

			# Substituindo a última vírgula "e", nos casos sem a classe milhar.
			if ! zztool grep_var ' mil ' "$num_saida"
			then
				qtde_v=$(echo "$num_saida" | sed 's/./&\n/g' | grep -c ",")
				test $qtde_v -gt 0 && num_saida=$(echo "${num_saida}" | sed "s/,/ e /${qtde_v}")
			fi
		fi

		# Colocando o sufixo
		num_saida="${num_saida} inteiros"
		test "$num_int" = "1" && num_saida=$(echo "${num_saida}" | sed 's/inteiros/inteiro/')

		######################################################################

		# Validando as parte fracionária do número
		if test ${#num_frac} -gt 0
		then
			zztool testa_numero $num_frac || { zztool -e uso numero; return 1; }
		fi

		# Escrevendo a parte fracionária. (usando a variável qtde_p emprestada)
		qtde_p=$(((${#num_frac}-1) / 3))

		# Colocando os números como argumentos
		set - $(echo "${num_frac}" | zzvira | sed 's/.../&\ /g' | zzvira)

		# Liberando as variáveis numero para receber o número por extenso
		unset numero

		if test -n "$1"
		then
			# Tendo parte fracionário, e inteiro sendo 0 (zero), parte inteira é apagada.
			test "$num_int" = "0" && unset num_saida

			# Tendo parte fracionária, conecta com o "e"
			test -n "$num_saida" && num_saida="${num_saida} e "
		fi

		while test -n "$1"
		do
			# Emprestando a variável qtde_v para cada conjunto de 3 números do número original (ordem de grandeza)
			# Tirando os zeros não significativos nesse contexto
			qtde_v=$(echo "$1" | sed 's/^[ 0]*//')

			if test ${#qtde_v} -gt 0
			then
				# Emprestando a variável n_formato para guardar a descrição da ordem2
				n_formato=$(echo "$ordem2" | grep "^${qtde_p}:" 2>/dev/null | cut -f2 -d":")
				test "$qtde_v" = "1" && n_formato=$(echo "$n_formato" | sed 's/ões/ão/')
				n_formato=$(echo "$n_formato" | sed 's/inteiros//')

				if test $texto -eq 2
				then
				# Numeros também por extenso
					case ${#qtde_v} in
						1)
							# Número unitario, captura direta do texto no segundo campo
							numero=$(echo "$ordem1" | grep "^${qtde_v}:" | cut -f2 -d":")
						;;
						2)
							if test $(echo "$qtde_v" | cut -c1) -eq 1
							then
								# Entre 10 e 19, captura direta do texto no segundo campo
								numero=$(echo "$ordem1" | grep "^${qtde_v}:" | cut -f2 -d":")
							elif test $(echo "$qtde_v" | cut -c2) -eq 0
							then
								# Dezenas, captura direta do texto no terceiro campo
								n_temp=$(echo "$qtde_v" | cut -c1)
								numero=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f3 -d":")
							else
								# 21 a 99, excluindo as dezenas terminadas em zero
								# Dezena
								n_temp=$(echo "$qtde_v" | cut -c1)
								numero=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f3 -d":")

								# Unidade
								n_temp=$(echo "$qtde_v" | cut -c2)
								n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f2 -d":")

								# Número dessa classe
								numero="$numero e $n_temp"
							fi
						;;
						3)
							if test $qtde_v -eq 100
							then
								# Exceção para o número cem
								numero="cem"
							else
								# 101 a 999
								# Centena
								n_temp=$(echo "$qtde_v" | cut -c1)
								numero=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f4 -d":")

								# Dezena
								n_temp=$(echo "$qtde_v" | cut -c2)
								if test "$n_temp" != "0"
								then
									if test "$n_temp" = "1"
									then
										n_temp=$(echo "$qtde_v" | cut -c2-3)
										n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f2 -d":")
										numero="$numero e $n_temp"
									else
										n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f3 -d":")
										numero="$numero e $n_temp"
									fi
								fi

								# Unidade
								n_temp=$(echo "$qtde_v" | cut -c2)
								if test "$n_temp" != "1"
								then
									n_temp=$(echo "$qtde_v" | cut -c3)
									if test "$n_temp" != "0"
									then
										n_temp=$(echo "$ordem1" | grep "^${n_temp}:" | cut -f2 -d":")
										numero="$numero e $n_temp"
									fi
								fi
							fi
						;;
					esac
				fi

				if test $texto -eq 2
				then
					num_saida="${num_saida} ${numero} ${n_formato}"
				else
					num_saida="${num_saida} ${qtde_v} ${n_formato}"
				fi
			fi

			qtde_p=$((qtde_p - 1))
			shift
		done

		if test ${#num_frac} -gt 0
		then
			# Primeiro sub-nível (ordem)
			n_temp=$((${#num_frac} % 3))
			n_temp=$(echo "$ordem3" | grep "^${n_temp}:" | cut -f2 -d":")
			num_saida="${num_saida} ${n_temp}"

			# Segundo sub-nível (classes)
			n_temp=$(((${#num_frac}-1) / 3))
			test $((${#num_frac} % 3)) -eq 0  && n_temp=$((n_temp + 1))
			n_temp=$(echo "$ordem4" | grep "^${n_temp}:" | cut -f2 -d":")
			num_saida="${num_saida} ${n_temp}"

			num_saida=$(echo "$num_saida" |
				sed 's/décimos \([a-z]\)/décimos de \1/;s/centésimos \([a-z]\)/centésimos de \1/' |
				sed 's/ *$//;s/ \{1,\}/ /g')

			# Ajuste para valor unitário na parte fracionária
			$(echo $num_frac | grep '^0\{1,\}1$' > /dev/null) && num_saida=$(echo $num_saida | sed 's/imos/imo/g')
		fi

		######################################################################

		# Zero (0) não é positivo e nem negativo
		n_temp=$(echo "$num_saida" | sed 's/inteiros//' | tr -d ' ')
		if test "$n_temp" != "0" -a "$n_temp" != "zero"
		then
			test "$sinal" = '-' && num_saida="$num_saida negativos"
			test "$sinal" = '+' && num_saida="$num_saida positivos"
		fi

		# Para o caso de ser o número 1, colocar no singular
		if test "$num_int" = "1"
		then
			if test ${#num_frac} -eq 0
			then
				num_saida=$(echo $num_saida | sed 's/s$//')
			elif test "$num_frac" = "00"
			then
				num_saida=$(echo $num_saida | sed 's/s$//')
			fi
		fi

		# Sufixo dependendo se for valor monetário
		if zztool grep_var 'R$' "$prefixo"
		then
			num_saida=$(echo "$num_saida" | sed 's/inteiros/reais/;s/inteiro/real/;s/centésimo/centavo/')
		else
			num_saida=$(echo "$num_saida" | sed "s/inteiros/${sufixo}/;s/inteiro/${sufixo}/")
		fi

		num_saida=$(echo "$num_saida" | sed 's/ e  *e / e /g; s/  */ /g' | sed 's/^ *e //; s/ e *$//; s/^ *//g')

		# Uma classe numérica por linha
		if test $linha -eq 1
		then
			case $texto in
			1)
				num_saida=$(echo " $num_saida" |
				sed 's/ [0-9]/\
&/g' | sed '/^ *$/d')
			;;
			2)
				num_saida=$(echo " $num_saida" |
				sed 's/ilhões/&\
/g;s/ilhão/&\
/g;s/mil /&\
/' |
				sed 's/inteiros*/&\
/;s/rea[li]s*/&\
/')
			;;
			esac
		fi

		zztool grep_var 'R$' "$prefixo" && unset prefixo
		test -n "$prefixo" && num_saida="${prefixo} ${num_saida}"
		echo "${num_saida}" | sed 's/ *$//g;s/ \{1,\}/ /g;s/^[ ,]*//g'

	else
		# Zero (0) não é positivo e nem negativo
		n_temp=$(echo "$num_saida" | sed 's/^[+-]//')
		if test "$n_temp" = "0" -o "$n_temp" = "R$ 0"
		then
			num_saida=$n_temp
		fi

		zztool grep_var 'R$' "$prefixo" && unset prefixo
		test ${#num_saida} -gt 0 && echo ${prefixo}${num_saida}${sufixo}
	fi
}

# ----------------------------------------------------------------------------
# zzoperadora
# http://consultaoperadora.com.br
# Consulta operadora de um número de telefone fixo/celular.
# O formato utilizado é: <DDD><NÚMERO>
# Não utilize espaços, (), -
# Uso: zzoperadora [número]
# Ex.: zzoperadora 1934621026
#
# Autor: Mauricio Calligaris <mauriciocalligaris@gmail.com>
# Desde: 2013-06-19
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------

zzoperadora ()
{
	zzzz -h operadora "$1" && return

	local url="http://consultaoperadora.com.br"
	local post="numero=$1"

	# Verifica o paramentro
	if (! zztool testa_numero "$1" || test "$1" -eq 0)
	then
		zztool -e uso operadora
		return 1
	fi

	# Faz a consulta no site
	echo "${post}&tipo=consulta" |
	$ZZWWWPOST "$url" |
	sed -n '/Número:/p' |
	awk '{print $1, $2; print $3, $4; for(i=6;i<=NF;i++) {printf  $i " "}; print ""}'
}

# ----------------------------------------------------------------------------
# zzora
# http://ora-code.com
# Retorna a descrição do erro Oracle (ORA-NNNNN).
# Uso: zzora numero_erro
# Ex.: zzora 1234
#
# Autor: Rodrigo Pereira da Cunha <rodrigopc (a) gmail.com>
# Desde: 2005-11-03
# Versão: 5
# Licença: GPL
# ----------------------------------------------------------------------------
zzora ()
{
	zzzz -h ora "$1" && return

	test $# -ne 1 && { zztool -e uso ora; return 1; } # deve receber apenas um argumento
	zztool -e testa_numero "$1" || return 1 # e este argumento deve ser numérico

	local url="http://ora-$1.ora-code.com"

	$ZZWWWDUMP "$url" | sed '
		s/  //g
		s/^ //
		/^$/ d
		/Subject Replies/,$d
		1,5d
		s/^Cause:/\
Cause:/
		s/^Action:/\
Action:/
		/Google Search/,$d
		/^o /d
		/\[1\.gif\]/,$d
		'
}

# ----------------------------------------------------------------------------
# zzpad
# Preenche um texto para um certo tamanho com outra string.
#
# Opções:
#   -d, -r     Preenche à direita (padrão)
#   -e, -l     Preenche à esquerda
#   -a, -b     Preenche em ambos os lados
#   -x STRING  String de preenchimento (padrão=" ")
#
# Uso: zzpad [-d | -e | -a] [-x STRING] <tamanho> [texto]
# Ex.: zzpad -x 'NO' 21 foo     # fooNONONONONONONONONO
#      zzpad -a -x '_' 9 foo    # ___foo___
#      zzpad -d -x '♥' 9 foo    # foo♥♥♥♥♥♥
#      zzpad -e -x '0' 9 123    # 000000123
#      cat arquivo.txt | zzpad -x '_' 99
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-05-18
# Versão: 5
# Licença: GPL
# ----------------------------------------------------------------------------
zzpad ()
{
	zzzz -h pad "$1" && return

	local largura
	local posicao='r'
	local str_pad=' '

	# Opções da posição do padding (left, right, both | esquerda, direita, ambos)
	while test "${1#-}" != "$1"
	do
		case "$1" in
		-l | -e) posicao='l'; shift ;;
		-r | -d) posicao='r'; shift ;;
		-b | -a) posicao='b'; shift ;;
		-x     ) str_pad="$2"; shift; shift ;;
		-*) zztool erro "Opção inválida: $1"; return 1 ;;
		*) break;;
		esac
	done

	# Tamanho da string
	if zztool testa_numero "$1" && test $1 -gt 0
	then
		largura="$1"
		shift
	else
		zztool -e uso pad
		return 1
	fi

	if test -z "$str_pad"
	then
		zztool erro "A string de preenchimento está vazia"
		return 1
	fi

	# Escapa caracteres especiais no s/// do sed: \ / &
	str_pad=$(echo "$str_pad" | sed 's,\\,\\\\,g; s,/,\\/,g; s,&,\\&,g')

	zztool multi_stdin "$@" |
		zztool nl_eof |
		case "$posicao" in
			l) sed -e ':loop' -e "/^.\{$largura\}/ b" -e "s/^/$str_pad/" -e 'b loop';;
			r) sed -e ':loop' -e "/^.\{$largura\}/ b" -e "s/$/$str_pad/" -e 'b loop';;
			b) sed -e ':loop' -e "/^.\{$largura\}/ b" -e "s/$/$str_pad/" \
			                  -e "/^.\{$largura\}/ b" -e "s/^/$str_pad/" -e 'b loop';;
		esac

	### Explicação do algoritmo sed
	# Os três comandos são similares, é um loop que só é quebrado quando o
	# tamanho atual do buffer satisfaz o tamanho desejado ($largura).
	# A cada volta do loop, é adicionado o texto de padding $str_pad antes
	# (s/^/…/) e/ou depois (s/$/…/) do texto atual.
}

# ----------------------------------------------------------------------------
# zzpais
# http://pt.wikipedia.org/wiki/Lista_de_pa%C3%ADses_e_capitais_em_l%C3%ADnguas_locais
# Lista os países.
# Opções:
#  -a: Todos os países
#  -i: Informa o(s) idioma(s)
#  -o: Exibe o nome do país e capital no idioma nativo
# Outra opção qualquer é usado como filtro para pesquisar entre os países.
# Obs.: Sem argumentos, mostra um país qualquer.
#
# Uso: zzpais [palavra|regex]
# Ex.: zzpais              # mostra um pais qualquer
#      zzpais unidos       # mostra os países com "unidos" no nome
#      zzpais -o nova      # mostra o nome original de países com "nova".
#      zzpais ^Z           # mostra os países que começam com Z
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-29
# Versão: 3
# Licença: GPL
# Requisitos: zzlinha
# ----------------------------------------------------------------------------
zzpais ()
{
	zzzz -h pais "$1" && return

	local url='http://pt.wikipedia.org/wiki/Lista_de_pa%C3%ADses_e_capitais_em_l%C3%ADnguas_locais'
	local cache=$(zztool cache pais)
	local original=0
	local idioma=0
	local padrao

	# Se o cache está vazio, baixa-o da Internet
	if ! test -s "$cache"
	then
		$ZZWWWHTML "$url" |
		sed -n '/class="wikitable"/,/<\/table>/p' |
		sed '/<th/d;s|</td>|:|g;s|</tr>|--n--|g;s|<br */*>|, |g;s/<[^>]*>//g;s/([^)]*)//g;s/\[.\]//g' |
		awk '{
			if ($0 == "--n--"){ print ""}
			else {printf "%s", $0}
		}' |
		sed 's/, *:/:/g;s/^ *//g;s/ *, *,/,/g;s/ *$//g;s/[,:] *$//g;/Taiuã:/d;/^ *$/d' > "$cache"
	fi

	while test "${1#-}" != "$1"
	do
		case "$1" in
			# Mostra idioma
			-i) idioma=1; shift;;
			# Mostra nome e capital do país no idioma nativo
			-o) original=1; shift;;
			# Lista todos os países
			-a) padrao='.'; shift;;
			*) break;;
		esac
	done

	test "${#padrao}" -eq 0 && padrao="$*"
	if test -z "$padrao"
	then
		# Mostra um país qualquer
		zzlinha -t . "$cache" |
		awk -v idioma_awk="$idioma" -v original_awk="$original" '
			BEGIN {
				FS=":"
				if (original_awk == 0) {
					printf "%-42s %-35s\n", "País", "Capital"
					print "------------------------------------------ ----------------------------------"
				}
			}
			{
			if (original_awk == 0) { printf "%-42s %-35s\n", $1, $2 }
			else {
				print "País     : " $3
				print "Capital  : " $4
			}
			if (idioma_awk == 1) { print "Idioma(s):", $5 }
			}'
	else
		# Faz uma busca nos países
		padrao=$(echo $padrao | sed 's/\$$/:.*:.*:.*:.*\$/')
		padrao=$(echo $padrao | sed 's/[^$]$/&.*:.*:.*:.*:.*/')
		grep -h -i -- "$padrao" "$cache" |
		awk -v idioma_awk="$idioma" -v original_awk="$original" '
			BEGIN {FS=":"}
			{	if (NR==1 && original_awk == 0) {
					printf "%-42s %-35s\n", "País", "Capital"
					print "------------------------------------------ ----------------------------------"
				}
				if (original_awk == 0) { printf "%-42s %-35s\n", $1, $2 }
				else {
					print "País     : " $3
					print "Capital  : " $4
				}
				if (idioma_awk == 1) { print "Idioma(s):", $5 }
				if (idioma_awk == 1 || original_awk == 1) print ""
			}'
	fi
}

# ----------------------------------------------------------------------------
# zzpalpite
# Palpites de jogos para várias loterias: quina, megasena, lotomania, etc.
# Aqui está a lista completa de todas as loterias suportadas:
# quina, megasena, duplasena, lotomania, lotofácil, timemania, federal, loteca
#
# Uso: zzpalpite [quina|megasena|duplasena|lotomania|lotofacil|federal|timemania|loteca]
# Ex.: zzpalpite
#      zzpalpite megasena
#      zzpalpite megasena federal lotofacil
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2012-06-03
# Versão: 5
# Licença: GPL
# Requisitos: zzminusculas zzsemacento zzseq zzaleatorio
# ----------------------------------------------------------------------------
zzpalpite ()
{
	zzzz -h palpite "$1" && return

	local tipo num posicao numeros palpites inicial final i
	local qtde=0
	local tipos='quina megasena duplasena lotomania lotofacil federal timemania loteca'

	# Escolhe as loteria
	test -n "$1" && tipos=$(echo "$*" | zzminusculas | zzsemacento)

	for tipo in $tipos
	do
		# Cada loteria
		case "$tipo" in
			lotomania)
				inicial=0
				final=99
				qtde=50
			;;
			lotofacil | facil)
				inicial=1
				final=25
				qtde=15
			;;
			megasena | mega)
				inicial=1
				final=60
				qtde=6
			;;
			duplasena | dupla)
				inicial=1
				final=50
				qtde=6
			;;
			quina)
				inicial=1
				final=80
				qtde=5
			;;
			federal)
				inicial=0
				final=99999
				numero=$(zzaleatorio $inicial $final)
				zztool eco $tipo:
				printf " %0.5d\n\n" $numero
				qtde=0
				unset num posicao numeros palpites inicial final i
			;;
			timemania | time)
				inicial=1
				final=80
				qtde=10
			;;
			loteca)
				i=1
				zztool eco $tipo:
				while test "$i" -le "14"
				do
					printf " Jogo %0.2d: Coluna %d\n" $i $(zzaleatorio 0 2) | sed 's/ 0$/ do Meio/g'
					i=$((i + 1))
				done
				echo
				qtde=0
				unset num posicao numeros palpites inicial final i
			;;
		esac

		# Todos os numeros da loteria seleciona
		if test "$qtde" -gt "0"
		then
			numeros=$(zzseq -f '%0.2d ' $inicial $final)
		fi

		# Loop para gerar os palpites
		i="$qtde"
		while test "$i" -gt "0"
		do
			# Posicao a ser escolhida
			posicao=$(zzaleatorio $inicial $final)
			test $tipo = "lotomania" && posicao=$((posicao + 1))

			# Extrai o numero na posicao selecionada
			num=$(echo $numeros | cut -f $posicao -d ' ')

			palpites=$(echo "$palpites $num")

			# Elimina o numero escolhido
			numeros=$(echo "$numeros" | sed "s/$num //")

			# Diminuindo o contador e quantidade de itens em "numeros"
			i=$((i - 1))
			final=$((final - 1))
		done

		if test "${#palpites}" -gt 0
		then
			palpites=$(echo "$palpites" | tr ' ' '\n' | sort -n -t ' ' | tr '\n' ' ')
			if test $(echo " $palpites" | wc -w ) -ge "10"
			then
				palpites=$(echo "$palpites" | sed 's/\(\([0-9]\{2\} \)\{5\}\)/\1\
 /g')
			fi
		fi

		# Exibe palpites
		if test "$qtde" -gt "0"
		then
			zztool eco $tipo:
			echo "$palpites" | sed '/^ *$/d;s/  *$//g'
			echo

			#Zerando as variaveis
			unset num posicao numeros palpites inicial final i
			qtde=0
		fi
	done | sed '$d'
}

# ----------------------------------------------------------------------------
# zzpascoa
# Mostra a data do domingo de Páscoa para qualquer ano.
# Obs.: Se o ano não for informado, usa o atual.
# Regra: Primeiro domingo após a primeira lua cheia a partir de 21 de março.
# Uso: zzpascoa [ano]
# Ex.: zzpascoa
#      zzpascoa 1999
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-23
# Versão: 1
# Licença: GPL
# Tags: data
# ----------------------------------------------------------------------------
zzpascoa ()
{
	zzzz -h pascoa "$1" && return

	local dia mes a b c d e f g h i k l m p q
	local ano="$1"

	# Se o ano não for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Validação
	zztool -e testa_ano $ano || return 1

	# Algoritmo de Jean Baptiste Joseph Delambre (1749-1822)
	# conforme citado em http://www.ghiorzi.org/portug2.htm
	#
	if test $ano -lt 1583
	then
		a=$(( ano % 4 ))
		b=$(( ano % 7 ))
		c=$(( ano % 19 ))
		d=$(( (19*c + 15) % 30 ))
		e=$(( (2*a + 4*b - d + 34) % 7 ))
		f=$(( (d + e + 114) / 31 ))
		g=$(( (d + e + 114) % 31 ))

		dia=$(( g+1 ))
		mes=$f
	else
		a=$(( ano % 19 ))
		b=$(( ano / 100 ))
		c=$(( ano % 100 ))
		d=$(( b / 4 ))
		e=$(( b % 4 ))
		f=$(( (b + 8) / 25 ))
		g=$(( (b - f + 1) / 3 ))
		h=$(( (19*a + b - d - g + 15) % 30 ))
		i=$(( c / 4 ))
		k=$(( c % 4 ))
		l=$(( (32 + 2*e + 2*i - h - k) % 7 ))
		m=$(( (a + 11*h + 22*l) / 451 ))
		p=$(( (h + l - 7*m + 114) / 31 ))
		q=$(( (h + l - 7*m + 114) % 31 ))

		dia=$(( q+1 ))
		mes=$p
	fi

	# Adiciona zeros à esquerda, se necessário
	test $dia -lt 10 && dia="0$dia"
	test $mes -lt 10 && mes="0$mes"

	echo "$dia/$mes/$ano"
}

# ----------------------------------------------------------------------------
# zzpgsql
# Lista os comandos SQL no PostgreSQL, numerando-os.
# Pesquisa detalhe dos comando, ao fornecer o número na listagem a esquerda.
# E filtra a busca se fornecer um texto.
#
# Uso: zzpgsql [ código | filtro ]
# Ex.: zzpgsql        # Lista os comandos disponíveis
#      zzpgsql 20     # Consulta o comando ALTER SCHEMA
#      zzpgsql alter  # Filtra os comandos que possuam alter na declaração
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-05-11
# Versão: 2
# Licença: GPL
# Requisitos: zzunescape
# ----------------------------------------------------------------------------
zzpgsql ()
{
	zzzz -h pgsql "$1" && return

	local url='http://www.postgresql.org/docs/current/static'
	local cache=$(zztool cache pgsql)
	local comando

	if ! test -s "$cache"
	then
		$ZZWWWHTML "${url}/sql-commands.html" |
		awk '{printf "%s",$0; if ($0 ~ /<\/dt>/) {print ""} }'|
		zzunescape --html | sed -n '/<dt>/p' | sed 's/  */ /g' |
		awk -F'"' '{ printf "%3s %s\n", NR, substr($3,2) ":" $2 }' |
		sed 's/<[^>]*>//g;s/^>/ /g' > $cache
	fi

	if test -n "$1"
	then
		if zztool testa_numero $1
		then
			comando=$(cat $cache | sed -n "/^ *${1} /p" | cut -f2 -d":")
			$ZZWWWDUMP "${url}/${comando}" | sed -n '/^ *__*/,/^ *__*/p' | sed '1d;$d'
		else
			grep -i $1 $cache | cut -f1 -d":"
		fi
	else
		cat "$cache" | cut -f1 -d":"
	fi
}

# ----------------------------------------------------------------------------
# zzphp
# http://www.php.net/manual/pt_BR/indexes.functions.php
# Lista completa com funções do PHP.
# com a opção -d ou --detalhe busca mais informação da função
# com a opção --atualiza força a atualização co cache local
#
# Uso: zzphp <palavra|regex>
# Ex.: zzphp --atualiza              # Força atualização do cache
#      zzphp array                   # mostra as funções com "array" no nome
#      zzphp -d mysql_fetch_object   # mostra descrição do  mysql_fetch_object
#      zzphp ^X                      # mostra as funções que começam com X
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-06
# Versão: 2
# Licença: GPL
# Requisitos: zzunescape
# ----------------------------------------------------------------------------
zzphp ()
{
	zzzz -h php "$1" && return

	local url='http://www.php.net/manual/pt_BR/indexes.functions.php'
	local cache=$(zztool cache php)
	local padrao="$*"
	local end funcao

	# Força atualização da listagem apagando o cache
	if test "$1" = '--atualiza'
	then
		zztool atualiza php
		shift
	fi

	if test "$1" = '-d' -o "$1" = '--detalhe'
	then
		url='http://www.php.net/manual/pt_BR'
		if test -n "$2"
		then
			funcao=$(echo "$2" | sed 's/ .*//')
			end=$(cat "$cache" | grep -h -i -- "^$funcao " | cut -f 2 -d"|")
			# Prevenir casos como do zlib://
			funcao=$(echo "$funcao" | sed 's|//||g')
			test $? -eq 0 && $ZZWWWDUMP "${url}/${end}" | sed -n "/^${funcao}/,/add a note add a note/p" | sed '$d;/___*$/,$d'
		fi
	else
		# Se o cache está vazio, baixa listagem da Internet
		if ! test -s "$cache"
		then
			# Formato do arquivo:
			# nome da função - descrição da função : link correspondente
			$ZZWWWHTML "$url" | sed -n '/class="index"/p' |
			awk -F'"' '{print substr($5,2) "|" $2}' |
			sed 's/<[^>]*>//g' |
			zzunescape --html > "$cache"
		fi

		if test -n "$padrao"
		then
			# Busca a(s) função(ões)
			cat "$cache" | cut -f 1 -d"|" | grep -h -i -- "$padrao"
		else
			cat "$cache" | cut -f 1 -d"|"
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzpiada
# http://www.xalexandre.com.br/
# Mostra uma piada diferente cada vez que é chamada.
# Uso: zzpiada
# Ex.: zzpiada
#
# Autor: Alexandre Brodt Fernandes, www.xalexandre.com.br
# Desde: 2008-12-29
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzpiada ()
{
	zzzz -h piada "$1" && return
	$ZZWWWDUMP 'http://www.xalexandre.com.br/piadasAleiatorias/' |
		sed 's/^ *//'
}

# ----------------------------------------------------------------------------
# zzplay
# Toca o arquivo de áudio, escolhendo o player mais adequado instalado.
# Também pode tocar lista de reprodução (playlist).
# Pode-se escolher o player principal passando-o como segundo argumento.
# - Os players possíveis para cada tipo são:
#   wav, au, aiff        afplay, play, mplayer, cvlc, avplay, ffplay
#   mp2, mp3             afplay, mpg321, mpg123, mplayer, cvlc, avplay, ffplay
#   ogg                  ogg123, mplayer, cvlc, avplay, ffplay
#   aac, wma, mka        mplayer, cvlc, avplay, ffplay
#   pls, m3u, xspf, asx  mplayer, cvlc
#
# Uso: zzplay <arquivo-de-áudio> [player]
# Ex.: zzplay os_seminovos_escolha_ja_seu_nerd.mp3
#      zzplay os_seminovos_eu_nao_tenho_iphone.mp3 cvlc   # priorizando o cvlc
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-13
# Versão: 6
# Licença: GPL
# Requisitos: zzextensao zzminusculas zzunescape zzxml
# ----------------------------------------------------------------------------
zzplay ()
{
	zzzz -h play "$1" && return

	local tipo play_cmd player play_lista
	local lista=0
	local cache="zzplay.pls"

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso play; return 1; }

	tipo=$(zzextensao "$1" | zzminusculas)

	# Para cada tipo de arquivo de audio ou playlist, seleciona o player disponivel
	case "$tipo" in
		wav | au | aiff )        play_lista="afplay play mplayer cvlc avplay ffplay";;
		mp2 | mp3 )              play_lista="afplay mpg321 mpg123 mplayer cvlc avplay ffplay";;
		ogg )                    play_lista="ogg123 mplayer cvlc avplay ffplay";;
		aac | wma | mka )        play_lista="mplayer cvlc avplay ffplay";;
		pls | m3u | xspf | asx ) play_lista="mplayer cvlc"; lista=1;;
		*) zzplay -h && return;;
	esac

	# Coloca player selecionado como prioritário.
	if test -n "$2" && zztool grep_var "$2" "$play_lista"
	then
		play_lista=$(echo "$play_lista" | sed "s/$2//")
		play_lista="$2 $play_lista"
	fi

	# Testa sequencialmente até encontrar o player disponível
	for play_cmd in $play_lista
	do
		if which $play_cmd >/dev/null 2>&1
		then
			player="$play_cmd"
			break
		fi
	done

	if test -n "$player"
	then
		# Mensagens de ajuda se estiver usando uma lista de reprodução
		if test "$player" = "mplayer" -a $lista -eq 1
		then
			zztool eco "Tecla 'q' para sair."
			zztool eco "Tecla '<' para música anterior na playlist."
			zztool eco "Tecla '>' para próxima música na playlist."
			player="$player -playlist"
		elif test "$player" = "cvlc" -a $lista -eq 1
		then
			zztool eco "Digitar Crtl+C para sair."
			zztool eco "Tecla '1' para música anterior na playlist."
			zztool eco "Tecla '2' para próxima música na playlist."
			player="$player --global-key-next 2 --global-key-prev 1"
		elif test "$player" = "avplay" -o "$player" = "ffplay"
		then
			player="$player -vn -nodisp"
		fi

		# Transforma os vários formatos de lista de reprodução numa versão simples de pls
		case "$tipo" in
			m3u)
				sed '/^[[:blank:]]*$/d;/^#/d;s/^[[:blank:]]*//g' "$1" |
				awk 'BEGIN { print "[playlist]" } { print "File" NR "=" $0 }' |
				sed 's/%\([0-9A-F][0-9A-F]\)/\\\\x\1/g' |
				while read linha
				do
					printf "%b\n" "$linha"
				done >> $cache
			;;
			xspf)
				zzxml --indent --tag location "$1" | zzxml --untag | zzunescape --html |
				sed '/^[[:blank:]]*$/d;s/^[[:blank:]]*//g' | sed 's|file://||g' |
				awk 'BEGIN { print "[playlist]" } { print "File" NR "=" $0 }' |
				sed 's/%\([0-9A-F][0-9A-F]\)/\\\\x\1/g' |
				while read linha
				do
					printf "%b\n" "$linha"
				done >> $cache
			;;
			asx)
				zzxml --indent --tag ref "$1" | zzunescape --html | sed '/^[[:blank:]]*$/d' |
				awk -F'""' 'BEGIN { print "[playlist]" } { print "File" NR "=" $2 }' |
				sed 's/%\([0-9A-F][0-9A-F]\)/\\\\x\1/g' |
				while read linha
				do
					printf "%b\n" "$linha"
				done >> $cache
			;;
		esac

		test -s "$cache" && $player "$cache" >/dev/null 2>&1 || $player "$1" >/dev/null 2>&1
	fi

	rm -f "$cache"
}

# ----------------------------------------------------------------------------
# zzporcento
# Calcula porcentagens.
# Se informado um número, mostra sua tabela de porcentagens.
# Se informados dois números, mostra a porcentagem relativa entre eles.
# Se informados um número e uma porcentagem, mostra o valor da porcentagem.
# Se informados um número e uma porcentagem com sinal, calcula o novo valor.
#
# Uso: zzporcento valor [valor|[+|-]porcentagem%]
# Ex.: zzporcento 500           # Tabela de porcentagens de 500
#      zzporcento 500.0000      # Tabela para número fracionário (.)
#      zzporcento 500,0000      # Tabela para número fracionário (,)
#      zzporcento 5.000,00      # Tabela para valor monetário
#      zzporcento 500 25        # Mostra a porcentagem de 25 para 500 (5%)
#      zzporcento 500 1000      # Mostra a porcentagem de 1000 para 500 (200%)
#      zzporcento 500,00 2,5%   # Mostra quanto é 2,5% de 500,00
#      zzporcento 500,00 +2,5%  # Mostra quanto é 500,00 + 2,5%
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-12-11
# Versão: 6
# Licença: GPL
# ----------------------------------------------------------------------------
zzporcento ()
{
	zzzz -h porcento "$1" && return

	local i porcentagem sinal
	local valor1="$1"
	local valor2="$2"
	local escala=0
	local separador=','
	local tabela='200 150 125 100 90 80 75 70 60 50 40 30 25 20 15 10 9 8 7 6 5 4 3 2 1'

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso porcento; return 1; }

	# Remove os pontos dos dinheiros para virarem fracionários (1.234,00 > 1234,00)
	zztool testa_dinheiro "$valor1" && valor1=$(echo "$valor1" | sed 's/\.//g')
	zztool testa_dinheiro "$valor2" && valor2=$(echo "$valor2" | sed 's/\.//g')

	### Vamos analisar o primeiro valor

	# Número fracionário (1.2345 ou 1,2345)
	if zztool testa_numero_fracionario "$valor1"
	then
		separador=$(echo "$valor1" | tr -d 0-9)
		escala=$(echo "$valor1" | sed 's/.*[.,]//')
		escala="${#escala}"

		# Sempre usar o ponto como separador interno (para os cálculos)
		valor1=$(echo "$valor1" | sed 'y/,/./')

	# Número inteiro ou erro
	else
		zztool -e testa_numero "$valor1" || return 1
	fi

	### Vamos analisar o segundo valor

	# O segundo argumento é uma porcentagem
	if test $# -eq 2 && zztool grep_var % "$valor2"
	then
		# O valor da porcentagem é guardado sem o caractere %
		porcentagem=$(echo "$valor2" | tr -d %)

		# Sempre usar o ponto como separador interno (para os cálculos)
		porcentagem=$(echo "$porcentagem" | sed 'y/,/./')

		# Há um sinal no início?
		if test "${porcentagem#[+-]}" != "$porcentagem"
		then
			sinal=$(printf %c $porcentagem)  # pega primeiro char
			porcentagem=${porcentagem#?}     # remove primeiro char
		fi

		# Porcentagem fracionada
		if zztool testa_numero_fracionario "$porcentagem"
		then
			# Se o valor é inteiro (escala=0) e a porcentagem fracionária,
			# é preciso forçar uma escala para que o resultado apareça correto.
			test $escala -eq 0 && escala=2 valor1="$valor1.00"

		# Porcentagem inteira ou erro
		elif ! zztool testa_numero "$porcentagem"
		then
			zztool erro "O valor da porcentagem deve ser um número. Exemplos: 2 ou 2,5."
			return 1
		fi

	# O segundo argumento é um número
	elif test $# -eq 2
	then
		# Ao mostrar a porcentagem entre dois números, a escala é fixa
		escala=2

		# O separador do segundo número é quem "manda" na saída
		# Sempre usar o ponto como separador interno (para os cálculos)

		# Número fracionário
		if zztool testa_numero_fracionario "$valor2"
		then
			separador=$(echo "$valor2" | tr -d 0-9)
			valor2=$(echo "$valor2" | sed 'y/,/./')

		# Número normal ou erro
		else
			zztool -e testa_numero "$valor2" || return 1
		fi
	fi

	# Ok. Dados coletados, analisados e formatados. Agora é hora dos cálculos.

	# Mostra tabela
	if test $# -eq 1
	then
		for i in $tabela
		do
			printf "%s%%\t%s\n" $i $(echo "scale=$escala; $valor1*$i/100" | bc)
		done

	# Mostra porcentagem
	elif test $# -eq 2
	then
		# Mostra a porcentagem relativa entre dois números
		if ! zztool grep_var % "$valor2"
		then
			echo "scale=$escala; $valor2*100/$valor1" | bc | sed 's/$/%/'

		# valor + n% é igual a…
		elif test "$sinal" = '+'
		then
			echo "scale=$escala; $valor1+$valor1*$porcentagem/100" | bc

		# valor - n% é igual a…
		elif test "$sinal" = '-'
		then
			echo "scale=$escala; $valor1-$valor1*$porcentagem/100" | bc

		# n% do valor é igual a…
		else
			echo "scale=$escala; $valor1*$porcentagem/100" | bc

			### Saída antiga, uma mini tabelinha
			# printf "%s%%\t%s\n" "+$porcentagem" $(echo "scale=$escala; $valor1+$valor1*$porcentagem/100" | bc)
			# printf "%s%%\t%s\n"  100          "$valor1"
			# printf "%s%%\t%s\n" "-$porcentagem" $(echo "scale=$escala; $valor1-$valor1*$porcentagem/100" | bc)
			# echo
			# printf "%s%%\t%s\n"  "$porcentagem" $(echo "scale=$escala; $valor1*$porcentagem/100" | bc)
			#
			# | sed "s/\([^0-9]\)\./\10./ ; s/^\./0./; y/./$separador/"
		fi
	fi |

	# Assegura 0.123 (em vez de .123) e restaura o separador original
	sed "s/^\./0./; y/./$separador/"
}

# ----------------------------------------------------------------------------
# zzporta
# http://pt.wikipedia.org/wiki/Lista_de_portas_de_protocolos
# Mostra uma lista das portas de protocolos usados na internet.
# Se houver um número como argumento, a listagem é filtrada pelo mesmo.
#
# Uso: zzporta [porta]
# Ex.: zzporta
#      zzporta 513
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-11-15
# Versão: 2
# Licença: GPL
# Requisitos: zzjuntalinhas
# ----------------------------------------------------------------------------
zzporta ()
{
	zzzz -h porta "$1" && return

	local url="http://pt.wikipedia.org/wiki/Lista_de_portas_de_protocolos"
	local port=$1
	zztool testa_numero $port || port='.'

	$ZZWWWHTML "$url" |
	awk '/"wikitable"/,/<\/table>/ { sub (/ bgcolor.*>/,">"); print }' |
	zzjuntalinhas -d '' -i '<tr>' -f '</tr>' |
	awk -F '</?t[^>]+>' 'BEGIN {OFS="\t"}{ print $3, $5 }' |
	expand -t 18 |
	sed '
		1d
		# Retira os links
		s/<[^>]*>//g
		3,${
			/^Porta/d
			/^[[:blank:]]*$/d
			/\/IP /d
		}' |
	awk 'NR==1;NR>1 && /'$port'/'
}

# ----------------------------------------------------------------------------
# zzpronuncia
# http://www.m-w.com
# Fala a pronúncia correta de uma palavra em inglês.
# Uso: zzpronuncia palavra
# Ex.: zzpronuncia apple
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-04-10
# Versão: 3
# Licença: GPL
# Requisitos: zzplay
# ----------------------------------------------------------------------------
zzpronuncia ()
{
	zzzz -h pronuncia "$1" && return

	local wav_file wav_dir wav_url
	local palavra=$1
	local cache=$(zztool cache pronuncia "$palavra.wav")
	local url='http://www.m-w.com/dictionary'
	local url2='http://cougar.eb.com/soundc11'

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso pronuncia; return 1; }

	# O 'say' é um comando do Mac OS X, aí não precisa baixar nada
	if test -x /usr/bin/say
	then
		say $*
		return
	fi

	# Busca o arquivo WAV na Internet caso não esteja no cache
	if ! test -f "$cache"
	then
		# Extrai o nome do arquivo no site do dicionário
		wav_file=$(
			$ZZWWWHTML "$url/$palavra" |
			sed -n "/.*return au('\([a-z0-9]\{1,\}\)'.*/{s//\1/p;q;}")

		# Ops, não extraiu nada
		if test -z "$wav_file"
		then
			zztool erro "$palavra: palavra não encontrada"
			return 1
		else
			wav_file="${wav_file}.wav"
		fi

		# O nome da pasta é a primeira letra do arquivo (/a/apple001.wav)
		# Ou "number" se iniciar com um número (/number/9while01.wav)
		wav_dir=$(echo $wav_file | cut -c1)
		echo $wav_dir | grep '[0-9]' >/dev/null && wav_dir='number'

		# Compõe a URL do arquivo e salva-o localmente (cache)
		wav_url="$url2/$wav_dir/$wav_file"
		echo "URL: $wav_url"
		$ZZWWWHTML "$wav_url" > "$cache"
		echo "Gravado o arquivo '$cache'"
	fi

	# Fala que eu te escuto
	zzplay "$cache"
}

# ----------------------------------------------------------------------------
# zzquimica
# Exibe a relação dos elementos químicos.
# Pesquisa na Wikipédia se informado o número atômico ou símbolo do elemento.
#
# Uso: zzquimica [número|símbolo]
# Ex.: zzquimica       # Lista de todos os elementos químicos
#      zzquimica He    # Pesquisa o Hélio na Wikipédia
#      zzquimica 12    # Pesquisa o Magnésio na Wikipédia
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-22
# Versão: 7
# Licença: GPL
# Requisitos: zzcapitalize zzwikipedia zzxml zzpad
# ----------------------------------------------------------------------------
zzquimica ()
{

	zzzz -h quimica "$1" && return

	local elemento linha numero nome simbolo massa orbital familia
	local cache=$(zztool cache quimica)

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		$ZZWWWHTML "http://www.tabelaperiodicacompleta.com/" |
		awk '/class="elemento/,/<\/td>/{print}'|
		zzxml --untag=br | zzxml --tidy |
		sed '/id="57-71"/,/<\/td>/d;/id="89-103"/,/<\/td>/d' |
		awk 'BEGIN {print "N.º:Nome:Símbolo:Massa:Orbital:Classificação (estado)"; OFS=":" }
			/^<td /     {
				info["familia"] = $5
					sub(/ao/, "ão", info["familia"])
					sub(/nideo/, "nídeo", info["familia"])
					sub(/gas/, "gás", info["familia"])
					sub(/genio/, "gênio", info["familia"])
					sub(/l[-]t/, "l de t", info["familia"])
					if (info["familia"] ~ /[los][-][rmn]/)
						sub(/-/, " ", info["familia"])

					info["familia"] = info["familia"] ($6 ~ /13$/ ? " [família do boro]":"")
					info["familia"] = info["familia"] ($6 ~ /14$/ ? " [família do carbono]":"")
					info["familia"] = info["familia"] ($6 ~ /15$/ ? " [família do nitrogênio]":"")
					info["familia"] = info["familia"] ($6 ~ /16$/ ? " [calcogênio]":"")

				info["estado"] = $7
					sub(/.>/, "", info["estado"])
					sub(/solido/, "sólido", info["estado"])
					sub(/liquido/, "líquido", info["estado"])
				}
			/^<a /      { info["url"] = $0; sub(/.*href=./, "", info["url"]); sub(/".*/, "", info["url"]) }
			/^<strong / { getline info["numero"] }
			/^<abbr/    { getline info["simbolo"]; sub(/ */, "", info["simbolo"]) }
			/^<em/      { getline info["nome"] }
			/^<i/       { getline info["massa"] }
			/^<small/   { getline info["orbital"]; gsub(/ /, "-", info["orbital"]) }
			/^<\/td>/ { print info["numero"], info["nome"], info["simbolo"], info["massa"], info["orbital"], info["familia"] " (" info["estado"] ")" }
		' |
		sort -n |
		while IFS=':' read numero nome simbolo massa orbital familia
		do
			echo "$(zzpad 4 $numero) $(zzpad 13 $nome) $(zzpad 7 $simbolo) $(zzpad 12 $massa) $(zzpad 18 $orbital) $familia"
		done > "$cache"
	fi

	if test -n "$1"
	then
		if zztool testa_numero "$1"
		then
			# Testando se forneceu o número atômico
			elemento=$(awk ' $1 ~ /'$1'/ { print $2 }' "$cache")
		else
			# Ou se forneceu o símbolo do elemento químico
			elemento=$(awk '{ if ($3 == "'$(zzcapitalize "$1")'") print $2 }' "$cache")
		fi

		# Se encontrado, pesquisa-o na wikipedia
		if test ${#elemento} -gt 0
		then
			test "$elemento" = "Rádio" -o "$elemento" = "Índio" && elemento="${elemento}_(elemento_químico)"
			zzwikipedia "$elemento"
		else
			zztool -e uso quimica
			return 1
		fi

	else
		# Lista todos os elementos químicos
		cat "$cache" | zzcapitalize | sed 's/ D\([eo]\) / d\1 /g'
	fi
}

# ----------------------------------------------------------------------------
# zzramones
# http://aurelio.net/doc/ramones.txt
# Mostra uma frase aleatória, das letras de músicas da banda punk Ramones.
# Obs.: Informe uma palavra se quiser frases sobre algum assunto especifico.
# Uso: zzramones [palavra]
# Ex.: zzramones punk
#      zzramones
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-07-24
# Versão: 1
# Licença: GPL
# Requisitos: zzlinha
# ----------------------------------------------------------------------------
zzramones ()
{
	zzzz -h ramones "$1" && return

	local url='http://aurelio.net/doc/ramones.txt'
	local cache=$(zztool cache ramones)
	local padrao=$1

	# Se o cache está vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		$ZZWWWDUMP "$url" > "$cache"
	fi

	# Mostra uma linha qualquer (com o padrão, se informado)
	zzlinha -t "${padrao:-.}" "$cache"
}

# ----------------------------------------------------------------------------
# zzrandbackground
# Muda aleatoriamente o background do GNOME.
# A opção -l faz o script entrar em loop.
# ATENÇÃO: o caminho deve conter a última / para que funcione:
#   /wallpaper/ <- funciona
#   /wallpaper  <- não funciona
#
# Uso: zzrandbackground -l <caminho_wallpapers> <segundo>
# Ex.: zzrandbackground /media/wallpaper/
#      zzrandbackground -l /media/wallpaper/ 5
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-12-12
# Versão: 1
# Licença: GPLv2
# Requisitos: zzshuffle gconftool
# ----------------------------------------------------------------------------
zzrandbackground ()
{

	zzzz -h randbackground "$1" && return

	local caminho tempo papeisdeparede background
	local opcao caminho segundos loop

	# Tratando os parametros
	# foi passado -l
	if test "$1" = "-l";then

		# Tem todos os parametros, caso negativo
		# mostra o uso da funcao
		if test $# != "3"; then
			zztool -e uso randbackground
			return 1
		fi

		# Ok é loop
		loop=1

		# O caminho é valido, caso negativo
		# mostra o uso da funcao
		if test -d $2; then
			caminho=$2
		else
			zztool -e uso randbackground
			return 1
		fi

		# A quantidade de segundos é inteira
		# caso negativo mostra o uso da funcao
		if zztool testa_numero $3; then
			segundos=$3
		else
			zztool -e uso randbackground
			return 1
		fi
	else
		# Caso nao seja passado o -l, só tem o camiho
		# caso negativo mostra o uso da funcao
		if test $# != "1"; then
			zztool -e uso randbackground
			return 1
		fi

		# O caminho é valido, caso negativo
		# mostra o uso da funcao
		if test -d $2; then
			caminho=$1
		else
			zztool -e uso randbackground
			return 1
		fi
	fi

	# Ok parametros tratados, vamos pegar
	# as imagens dentro do "$caminho"
	papeisdeparede=$(
				find -L $caminho -type f -exec file {} \; |
				grep -i image |
				cut -d: -f1
			)

	# Agora a execução
	# Foi passado -l, então entra em loop infinito
	if test -n "$loop";then
		while test "1"
		do
			background=$( echo "$papeisdeparede" |
				zzshuffle |
				head -1
				)
			gconftool-2 --type string --set /desktop/gnome/background/picture_filename "$background"
			sleep $segundos
		done

	# não, não foi passado -l, então só troca 1x.
	else
		background=$( echo "$papeisdeparede" |
				zzshuffle |
				head -1
			)
		gconftool-2 --type string --set /desktop/gnome/background/picture_filename "$background"
	fi
}

# ----------------------------------------------------------------------------
# zzrastreamento
# http://www.correios.com.br
# Acompanha encomendas via rastreamento dos Correios.
# Uso: zzrastreamento <código_da_encomenda> ...
# Ex.: zzrastreamento RK995267899BR
#      zzrastreamento RK995267899BR RA995267899CN
#
# Autor: Frederico Freire Boaventura <anonymous (a) galahad com br>
# Desde: 2007-06-25
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzrastreamento ()
{
	zzzz -h rastreamento "$1" && return

	test -n "$1" || { zztool -e uso rastreamento; return 1; }

	local url='http://websro.correios.com.br/sro_bin/txect01$.QueryList'

	# Para cada código recebido...
	for codigo
	do
		# Só mostra o código se houver mais de um
		test $# -gt 1 && zztool eco "**** $codigo"

		$ZZWWWDUMP "$url?P_LINGUA=001&P_TIPO=001&P_COD_UNI=$codigo" |
			sed '
				/ Data /,/___/ !d
				/___/d
				s/^   //'

		# Linha em branco para separar resultados
		test $# -gt 1 && echo
	done
}

# ----------------------------------------------------------------------------
# zzrelansi
# Coloca um relógio digital (hh:mm:ss) no canto superior direito do terminal.
# Uso: zzrelansi [-s|--stop]
# Ex.: zzrelansi
#
# Autor: Arkanon <arkanon (a) lsd org br>
# Desde: 2009-09-17
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzrelansi ()
{

	zzzz -h relansi "$1" && return

	case $1 in
	-s | --stop)
		shopt -q
		if test -n "$relansi_pid"
		then
			kill $relansi_pid
			relansi_write
			unset relansi_cols relansi_pid relansi_write
		else
			echo "RelANSI não está sendo executado"
		fi
	;;
	*)
		if test -n "$relansi_pid"
		then
			echo "RelANSI já está sendo executado pelo processo $relansi_pid"
		else
			relansi_cols=$(tput cols)
			relansi_write()
				{
				tput sc
				tput cup 0 $[$relansi_cols-8]
				test -n "$1" && date +'%H:%M:%S' || echo '        '
				tput rc
				}
			exec 3>&2 2> /dev/null
			while true
			do
				relansi_write start
				sleep 1
			done &
			relansi_pid=$!
			disown $relansi_pid # RESTRICAO: builtin no bash e zsh, mas nao no csh e ksh
			exec 2>&3
		fi
	;;
	esac

}

# ----------------------------------------------------------------------------
# zzromanos
# Conversor de números romanos para indo-arábicos e vice-versa.
# Uso: zzromanos número
# Ex.: zzromanos 1987                # Retorna: MCMLXXXVII
#      zzromanos XLIII               # Retorna: 43
#
# Autor: Guilherme Magalhães Gall <gmgall (a) gmail com> twitter: @gmgall
# Desde: 2011-07-19
# Versão: 3
# Licença: GPL
# Requisitos: zzmaiusculas zztac
# ----------------------------------------------------------------------------
zzromanos ()
{
	zzzz -h romanos "$1" && return

	local arabicos_romanos="\
	1000:M
	900:CM
	500:D
	400:CD
	100:C
	90:XC
	50:L
	40:XL
	10:X
	9:IX
	5:V
	4:IV
	1:I"

	# Deixa o usuário usar letras maiúsculas ou minúsculas
	local entrada=$(echo "$1" | zzmaiusculas)
	local saida=""
	local indice=1
	local comprimento
	# Regex que valida um número romano de acordo com
	# http://diveintopython.org/unit_testing/stage_5.html
	local regex_validacao='^M?M?M?(CM|CD|D?C?C?C?)(XC|XL|L?X?X?X?)(IX|IV|V?I?I?I?)$'

	# Se nenhum argumento for passado, mostra lista de algarismos romanos
	# e seus correspondentes indo-arábicos
	if test $# -eq 0
	then
		echo "$arabicos_romanos" |
		grep -v :.. | tr -d '\t' | tr : '\t' |
		zztac

	# Se é um número inteiro positivo, transforma para número romano
	elif zztool testa_numero "$entrada"
	then
		echo "$arabicos_romanos" | { while IFS=: read arabico romano
		do
			while test "$entrada" -ge "$arabico"
			do
				saida="$saida$romano"
				entrada=$((entrada-arabico))
			done
		done
		echo "$saida"
		}

	# Se é uma string que representa um número romano válido,
	# converte para indo-arábico
	elif echo "$entrada" | egrep "$regex_validacao" > /dev/null
	then
		saida=0
		# Baseado em http://diveintopython.org/unit_testing/stage_4.html
		echo "$arabicos_romanos" | { while IFS=: read arabico romano
		do
			comprimento="${#romano}"
			while test "$(echo "$entrada" | cut -c$indice-$((indice+comprimento-1)))" = "$romano"
			do
				indice=$((indice+comprimento))
				saida=$((saida+arabico))
			done
		done
		echo "$saida"
		}

	# Se não é inteiro posivo ou string que representa número romano válido,
	# imprime mensagem de uso.
	else
		zztool -e uso romanos
		return 1
	fi
}

# ----------------------------------------------------------------------------
# zzrot13
# Codifica/decodifica um texto utilizando a cifra ROT13.
# Uso: zzrot13 texto
# Ex.: zzrot13 texto secreto               # Retorna: grkgb frpergb
#      zzrot13 grkgb frpergb               # Retorna: texto secreto
#      echo texto secreto | zzrot13        # Retorna: grkgb frpergb
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-07-23
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzrot13 ()
{
	zzzz -h rot13 "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Um tr faz tudo, é uma tradução letra a letra
	# Obs.: Dados do tr entre colchetes para funcionar no Solaris
	tr '[a-zA-Z]' '[n-za-mN-ZA-M]'
}

# ----------------------------------------------------------------------------
# zzrot47
# Codifica/decodifica um texto utilizando a cifra ROT47.
# Uso: zzrot47 texto
# Ex.: zzrot47 texto secreto               # Retorna: E6IE@ D64C6E@
#      zzrot47 E6IE@ D64C6E@               # Retorna: texto secreto
#      echo texto secreto | zzrot47        # Retorna: E6IE@ D64C6E@
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-07-23
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzrot47 ()
{
	zzzz -h rot47 "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Um tr faz tudo, é uma tradução letra a letra
	# Obs.: Os colchetes são parte da tabela, o tr não funcionará no Solaris
	tr '!-~' 'P-~!-O'
}

# ----------------------------------------------------------------------------
# zzrpmfind
# http://rpmfind.net/linux
# Procura por pacotes RPM em várias distribuições de Linux.
# Obs.: A arquitetura padrão de procura é a i386.
# Uso: zzrpmfind pacote [distro] [arquitetura]
# Ex.: zzrpmfind sed
#      zzrpmfind lilo mandr i586
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-02-22
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzrpmfind ()
{
	zzzz -h rpmfind "$1" && return

	local url='http://rpmfind.net/linux/rpm2html/search.php'
	local pacote=$1
	local distro=$2
	local arquitetura=${3:-i386}

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso rpmfind; return 1; }

	# Faz a consulta e filtra o resultado
	resultado=$(
		$ZZWWWLIST "$url?query=$pacote&submit=Search+...&system=$distro&arch=$arquitetura" |
			sed -n '/ftp:\/\/rpmfind/ s@^[^A-Z]*/linux/@  @p' |
			sort
	)

	if test -n "$resultado"
	then
		zztool eco 'ftp://rpmfind.net/linux/'
		echo "$resultado"
	fi
}

# ----------------------------------------------------------------------------
# zzsecurity
# Mostra os últimos 5 avisos de segurança de sistemas de Linux/UNIX.
# Suportados:
#  Debian, Ubuntu, FreeBSD, NetBSD, Gentoo, Arch, Mandriva, Mageia,
#  Slackware, Suse (OpenSuse), RedHat, Fedora.
# Uso: zzsecurity [distros]
# Ex.: zzsecutiry
#      zzsecurity mandriva
#      zzsecurity debian gentoo
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-12-23
# Versão: 11
# Licença: GPL
# Requisitos: zzminusculas zzfeed zztac zzurldecode zzdata zzdatafmt
# ----------------------------------------------------------------------------
zzsecurity ()
{
	zzzz -h security "$1" && return

	local url limite distros
	local n=5
	local ano=$(date '+%Y')
	local distros='debian freebsd gentoo mandriva slackware suse opensuse ubuntu redhat arch mageia netbsd fedora'

	limite="sed ${n}q"

	test -n "$1" && distros=$(echo $* | zzminusculas)

	# Debian
	if zztool grep_var debian "$distros"
	then
		url='http://www.debian.org'
		echo
		zztool eco '** Atualizações Debian'
		echo "$url"
		$ZZWWWDUMP "$url" |
			sed -n '
				/Security Advisories/,/_______/ {
					/\[[0-9]/ s/^ *//p
				}' |
			$limite
	fi

	# Slackware
	if zztool grep_var slackware "$distros"
	then
		echo
		zztool eco '** Atualizações Slackware'
		url="http://www.slackware.com/security/list.php?l=slackware-security&y=$ano"
		echo "$url"
		$ZZWWWDUMP "$url" |
			sed '
				/[0-9]\{4\}-[0-9][0-9]/!d
				s/\[sla.*ty\]//
				s/^  *//' |
			$limite
	fi

	# Gentoo
	if zztool grep_var gentoo "$distros"
	then
		echo
		zztool eco '** Atualizações Gentoo'
		url='http://www.gentoo.org/security/en/index.xml'
		echo "$url"
		$ZZWWWDUMP "$url" |
			sed -n '
				s/^  *//
				/^GLSA/, /^$/ !d
				/[0-9]\{4\}/ {
					s/\([-0-9]* \) *[a-zA-Z]* *\(.*[^ ]\)  *[0-9][0-9]* *$/\1\2/
					p
				}' |
			$limite
	fi

	# Mandriva
	if zztool grep_var mandriva "$distros"
	then
		echo
		zztool eco '** Atualizações Mandriva'
		url='http://www.mandriva.com/en/support/security/advisories/feed/'
		echo "$url"
		zzfeed -n $n "$url"
	fi

	# Suse
	if zztool grep_var suse "$distros" || zztool grep_var opensuse "$distros"
	then
		echo
		zztool eco '** Atualizações Suse'
		url='https://www.suse.com/support/update/'
		echo "$url"
		$ZZWWWDUMP "$url" |
			grep 'SUSE-SU' |
			sed 's/^.*\(SUSE-SU\)/ \1/;s/\(.*\) \([A-Z].. .., ....\)$/\2\1/ ; s/  *$//' |
			$limite

		echo
		zztool eco '** Atualizações Opensuse'
		url="http://lists.opensuse.org/opensuse-updates/$(zzdata hoje - 1m | zzdatafmt -f AAAA-MM) http://lists.opensuse.org/opensuse-updates/$(zzdatafmt -f AAAA-MM hoje)"
		echo "$url"
		$ZZWWWDUMP $url |
			grep 'SUSE-SU' |
			sed 's/^ *\* //;s/ [0-9][0-9]:[0-9][0-9]:[0-9][0-9] GMT/,/;s/  *$//' |
			zztac |
			$limite
	fi

	# FreeBSD
	if zztool grep_var freebsd "$distros"
	then
		echo
		zztool eco '** Atualizações FreeBSD'
		url='http://www.freebsd.org/security/advisories.rdf'
		echo "$url"
		zzfeed -n $n "$url"
	fi

	# NetBSD
	if zztool grep_var netbsd "$distros"
	then
		echo
		zztool eco '** Atualizações NetBSD'
		url='http://ftp.netbsd.org/pub/NetBSD/packages/vulns/pkg-vulnerabilities'
		echo "$url"
		$ZZWWWDUMP "$url" |
			zzurldecode |
			sed '1,27d;/#CHECKSUM /,$d;s/ *https*:.*//' |
			zztac |
			$limite
	fi

	# Ubuntu
	if zztool grep_var ubuntu "$distros"
	then
		url='http://www.ubuntu.com/usn/rss.xml'
		echo
		zztool eco '** Atualizações Ubuntu'
		echo "$url"
		zzfeed -n $n "$url"
	fi

	# Red Hat
	if zztool grep_var redhat "$distros"
	then
		url='https://access.redhat.com/security/cve'
		echo
		zztool eco '** Atualizações Red Hat'
		echo "$url"
		$ZZWWWDUMP "$url" |
			sed -n '
				/^ *CVE-/ {
					/\* RESERVED \*/ d
					/Details pending/ d
					s/ [[:alpha:]]\{1,\} [0-9-]\{1,\}$//
					s/^  *//
					p
				}' |
			zztac |
			$limite |
			sed 's/ /:\
	/'
	fi

	# Fedora
	if zztool grep_var fedora "$distros"
	then
		echo
		zztool eco '** Atualizações Fedora'
		url='http://lwn.net/Alerts/Fedora/'
		echo "$url"
		$ZZWWWDUMP "$url" |
			grep 'FEDORA-' |
			sed 's/^ *//' |
			$limite
	fi

	# Arch
	if zztool grep_var arch "$distros"
	then
		url="https://wiki.archlinux.org/index.php/CVE"
		echo
		zztool eco '** Atualizações Archlinux'
		echo "$url"
		$ZZWWWDUMP "$url" |
			sed -n "/^ *CVE-${ano}-[0-9]/{s/templink //;p;}" |
			$limite
	fi

	# Mageia
	if zztool grep_var mageia "$distros"
	then
		url='http://advisories.mageia.org/advisories.rss'
		echo
		zztool eco '** Atualizações Mageia'
		echo "$url"
		zzfeed -n $n "$url"
	fi
}

# ----------------------------------------------------------------------------
# zzsemacento
# Tira os acentos de todas as letras (áéíóú vira aeiou).
# Uso: zzsemacento texto
# Ex.: zzsemacento AÇÃO 1ª bênção           # Retorna: ACAO 1a bencao
#      echo AÇÃO 1ª bênção | zzsemacento    # Retorna: ACAO 1a bencao
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2010-05-24
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzsemacento ()
{
	zzzz -h semacento "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Remove acentos
	sed '
		y/àáâãäåèéêëìíîïòóôõöùúûü/aaaaaaeeeeiiiiooooouuuu/
		y/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜ/AAAAAAEEEEIIIIOOOOOUUUU/
		y/çÇñÑß¢Ðð£Øø§µÝý¥¹²³ªº/cCnNBcDdLOoSuYyY123ao/
	'
}

# ----------------------------------------------------------------------------
# zzsenha
# Gera uma senha aleatória de N caracteres.
# Obs.: Sem opções, a senha é gerada usando letras e números.
#
# Opções: -p, --pro   Usa letras, números e símbolos para compor a senha
#         -n, --num   Usa somente números para compor a senha
#         -u, --uniq  Gera senhas com caracteres únicos (não repetidos)
#
# Uso: zzsenha [--pro|--num] [n]     (padrão n=8)
# Ex.: zzsenha
#      zzsenha 10
#      zzsenha --num 9
#      zzsenha --pro 30
#      zzsenha --uniq 10
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-11-07
# Versão: 4
# Licença: GPL
# Requisitos: zzaleatorio
# ----------------------------------------------------------------------------
zzsenha ()
{
	zzzz -h senha "$1" && return

	local posicao letra senha uniq
	local n=8
	local alpha='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	local num='0123456789'
	local pro='-/:;()$&@.,?!'  # teclado do iPhone, exceto aspas
	local lista="$alpha$num"   # senha padrão: letras e números

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-p | --pro ) shift; lista="$alpha$num$pro";;
			-n | --num ) shift; lista="$num";;
			-u | --uniq) shift; uniq=1;;
			*) break ;;
		esac
	done

	# Guarda o número informado pelo usuário (se existente)
	test -n "$1" && n="$1"

	# Foi passado um número mesmo?
	zztool -e testa_numero "$n" || return 1

	# Quando não se repete caracteres, há uma limitação de tamanho
	if test -n "$uniq" -a "$n" -gt "${#lista}"
	then
		zztool erro "O tamanho máximo desse tipo de senha é ${#lista}"
		return 1
	fi

	# Esquema de geração da senha:
	# A cada volta é escolhido um número aleatório que indica uma
	# posição dentro de $lista. A letra dessa posição é mostrada na
	# tela. Caso --uniq seja usado, a letra é removida de $lista,
	# para que não seja reutilizada.
	while test "$n" -ne 0
	do
		n=$((n-1))
		posicao=$(zzaleatorio 1 ${#lista})
		letra=$(printf "$lista" | cut -c "$posicao")
		test -n "$uniq" && lista=$(echo "$lista" | tr -d "$letra")
		senha="$senha$letra"
	done

	# Mostra a senha
	test -n "$senha" && echo "$senha"
}

# ----------------------------------------------------------------------------
# zzseq
# Mostra uma seqüência numérica, um número por linha, ou outro formato.
# É uma emulação do comando seq, presente no Linux.
# Opções:
#   -f    Formato de saída (printf) para cada número, o padrão é '%d\n'
# Uso: zzseq [-f formato] [número-inicial [passo]] número-final
# Ex.: zzseq 10                   # de 1 até 10
#      zzseq 5 10                 # de 5 até 10
#      zzseq 10 5                 # de 10 até 5 (regressivo)
#      zzseq 0 2 10               # de 0 até 10, indo de 2 em 2
#      zzseq 10 -2 0              # de 10 até 0, indo de 2 em 2
#      zzseq -f '%d:' 5           # 1:2:3:4:5:
#      zzseq -f '%0.4d:' 5        # 0001:0002:0003:0004:0005:
#      zzseq -f '(%d)' 5          # (1)(2)(3)(4)(5)
#      zzseq -f 'Z' 5             # ZZZZZ
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-12-06
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzseq ()
{
	zzzz -h seq "$1" && return

	local operacao='+'
	local inicio=1
	local passo=1
	local formato='%d\n'
	local fim i

	# Se tiver -f, guarda o formato e limpa os argumentos
	if test "$1" = '-f'
	then
		formato="$2"
		shift
		shift
	fi

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso seq; return 1; }

	# Se houver só um número, vai "de um ao número"
	fim="$1"

	# Se houver dois números, vai "do primeiro ao segundo"
	test -n "$2" && inicio="$1" fim="$2"

	# Se houver três números, vai "do primeiro ao terceiro em saltos"
	test -n "$3" && inicio="$1" passo="$2" fim="$3"

	# Verificações básicas
	zztool -e testa_numero_sinal "$inicio" || return 1
	zztool -e testa_numero_sinal "$passo"  || return 1
	zztool -e testa_numero_sinal "$fim"    || return 1
	if test "$passo" -eq 0
	then
		zztool erro "O passo não pode ser zero."
		return 1
	fi

	# Internamente o passo deve ser sempre positivo para simplificar
	# Assim mesmo que o usuário faça 0 -2 10, vai funcionar
	test "$passo" -lt 0 && passo=$((0 - passo))

	# Se o primeiro for maior que o segundo, a contagem é regressiva
	test "$inicio" -gt "$fim" && operacao='-'

	# Loop que mostra o número e aumenta/diminui a contagem
	i="$inicio"
	while (
		test "$inicio" -lt "$fim" -a "$i" -le "$fim" ||
		test "$inicio" -gt "$fim" -a "$i" -ge "$fim")
	do
		printf "$formato" "$i"
		i=$(($i $operacao $passo))  # +n ou -n
	done

	# Caso especial: início e fim são iguais
	test "$inicio" -eq "$fim" && echo "$inicio"
}

# ----------------------------------------------------------------------------
# zzsextapaixao
# Mostra a data da sexta-feira da paixão para qualquer ano.
# Obs.: Se o ano não for informado, usa o atual.
# Regra: 2 dias antes do domingo de Páscoa.
# Uso: zzsextapaixao [ano]
# Ex.: zzsextapaixao
#      zzsextapaixao 2008
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-11-21
# Versão: 1
# Licença: GPL
# Requisitos: zzdata zzpascoa
# Tags: data
# ----------------------------------------------------------------------------
zzsextapaixao ()
{
	zzzz -h sextapaixao "$1" && return

	local ano="$1"

	# Se o ano não for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Validação
	zztool -e testa_ano $ano || return 1

	# Ah, como é fácil quando se tem as ferramentas certas ;)
	# e quando já temos o código e só precisamos mudar os numeros
	# tambem é bom :D ;)
	zzdata $(zzpascoa $ano) - 2
}

# ----------------------------------------------------------------------------
# zzshuffle
# Desordena as linhas de um texto (ordem aleatória).
# Uso: zzshuffle [arquivo(s)]
# Ex.: zzshuffle /etc/passwd         # desordena o arquivo de usuários
#      cat /etc/passwd | zzshuffle   # o arquivo pode vir da entrada padrão
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-06-19
# Versão: 1
# Licença: GPL
# Requisitos: zzaleatorio
# ----------------------------------------------------------------------------
zzshuffle ()
{
	zzzz -h shuffle "$1" && return

	local linha

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |

		# Um número aleatório é colocado no início de cada linha,
		# depois o sort ordena numericamente, bagunçando a ordem
		# original. Então os números são removidos.
		while read linha
		do
			echo "$(zzaleatorio) $linha"
		done |
		sort |
		cut -d ' ' -f 2-
}

# ----------------------------------------------------------------------------
# zzsigla
# http://www.acronymfinder.com
# Dicionário de siglas, sobre qualquer assunto (como DVD, IMHO, WYSIWYG).
# Obs.: Há um limite diário de consultas por IP, pode parar temporariamente.
# Uso: zzsigla sigla
# Ex.: zzsigla RTFM
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-02-21
# Versão: 3
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zzsigla ()
{
	zzzz -h sigla "$1" && return

	local url='http://www.acronymfinder.com/af-query.asp'

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso sigla; return 1; }

	local sigla=$1
	# Pesquisa, baixa os resultados e filtra
	# O novo retorno do site retorna todas as opções com três espaços
	#  antes da sigla, e vários ou um espaço depois dependendo do
	#  tamanho da sigla. Assim, o grep utiliza aspas duplas para entender
	#  a filtragem
	$ZZWWWDUMP "$url?acronym=$sigla" |
		grep -i "   $sigla " |
		zztrim -l |
		sed 's/  */   /'
}

# ----------------------------------------------------------------------------
# zzsplit
# Separa um arquivo linha a linha alternadamente em 2 ou mais arquivos.
# Usa o mesmo nome do arquivo, colocando sufixo numérico sequencial.
#
# Opção:
#  -p <relação de linhas> - numero de linhas de cada arquivo de destino.
#    Obs1.: A relação são números de linhas de cada arquivo correspondente na
#           sequência, justapostos separados por vírgula (,).
#    Obs2.: Se a quantidade de linhas na relação for menor que a quantidade de
#           arquivos, os arquivos excedentes adotam a último valor na relação.
#    Obs3.: Os números negativos na relação, saltam as linha informadas
#           sem repassar ao arquivo destino.
#
# Uso: zzsplit -p <relação> [<numero>] | <numero> <arquivo>
# Ex.: zzsplit 3 arq.txt  # Separa em 3: arq.txt.1, arq.txt.2, arq.txt.3
#      zzsplit -p 3,5,4 5 arq.txt  # Separa em 5 arquivos
#      # 3 linhas no arq.txt.1, 5 linhas no arq.txt.2 e 4 linhas nos demais.
#      zzsplit -p 3,4,2 arq.txt    # Separa em 3 arquivos
#      # 3 linhas no arq.txt.1, 4 linhas no arq.txt.2 e 2 linhas no arq.txt.3
#      zzsplit -p 2,-3,4 arq.txt   # Separa em 2 arquivos
#      # 2 linhas no arq.txt.1, pula 3 linhas e 4 linhas no arq.txt.3
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-11-10
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zzsplit ()
{
	zzzz -h split "$1" && return

	local passos=1
	local qtde=0

	test -n "$1" || { zztool -e uso split; return 1; }

	# Quantidade de arquivo a serem separados
	# Estipulando as quantidades de linhas para cada arquivo de saída
	if test "$1" = "-p"
	then
		passos="$2"
		qtde=$(echo "$passos" | awk -F"," '{ print NF }')
		shift
		shift
	fi
	# Estipilando a quantidade de arquivos de saída diretamente
	if zztool testa_numero $1
	then
		qtde=$1
		shift
	fi

	# Garantindo separar em 2 arquivos ou mais
	test "$qtde" -gt "1" || { zztool -e uso split; return 1; }

	# Conferindo se arquivo existe e é legível
	zztool arquivo_legivel "$1" || { zztool -e uso split; return 1; }

	# Onde a "separação" ocorre efetivamente.
	awk -v qtde_awk=$qtde -v passos_awk="$passos" '
		BEGIN {
			tamanho = length(qtde_awk)

			qtde_passos = split(passos_awk, passo, ",")
			if (qtde_passos < qtde_awk) {
				ultimo_valor = passo[qtde_passos]
				for (i = qtde_passos + 1; i <= qtde_awk; i++) {
					passo[i] = ultimo_valor
				}
			}

			ordem = 1
		}

		{
			if (ordem > qtde_awk)
				ordem = 1

			val_abs = passo[ordem] >= 0 ? passo[ordem] : passo[ordem] * -1

			sufixo = sprintf("%0" tamanho "d", ordem)

			if (passo[ordem] > 0)
				print $0 >> (FILENAME "." sufixo)

			if (val_abs > 1) {
				for (i = 2; i <= val_abs; i++) {
					if (getline > 0) {
						if (passo[ordem] > 0)
							print $0 >> (FILENAME "." sufixo)
					}
				}
			}

			ordem++
		}
	' "$1"
}

# ----------------------------------------------------------------------------
# zzss
# Protetor de tela (Screen Saver) para console, com cores e temas.
# Temas: mosaico, espaco, olho, aviao, jacare, alien, rosa, peixe, siri.
# Obs.: Aperte Ctrl+C para sair.
# Uso: zzss [--rapido|--fundo] [--tema <tema>] [texto]
# Ex.: zzss
#      zzss fui ao banheiro
#      zzss --rapido /
#      zzss --fundo --tema peixe
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-06-12
# Versão: 1
# Licença: GPL
# Requisitos: zzaleatorio zztrim
# ----------------------------------------------------------------------------
zzss ()
{
	zzzz -h ss "$1" && return

	local mensagem tamanho_mensagem mensagem_colorida
	local cor_fixo cor_muda negrito codigo_cores fundo
	local linha coluna dimensoes
	local linhas=25
	local colunas=80
	local tema='mosaico'
	local pausa=1

	local temas='
		mosaico	#
		espaco	.
		olho	00
		aviao	--o-0-o--
		jacare	==*-,,--,,--
		alien	/-=-\\
		rosa	--/--\-<@
		peixe	>-)))-D
		siri	(_).-=''=-.(_)
	'

	# Tenta obter as dimensões atuais da tela/janela
	dimensoes=$(stty size 2>/dev/null)
	if test -n "$dimensoes"
	then
		linhas=${dimensoes% *}
		colunas=${dimensoes#* }
	fi

	# Opções de linha de comando
	while test $# -ge 1
	do
		case "$1" in
			--fundo)
				fundo=1
			;;
			--rapido)
				unset pausa
			;;
			--tema)
				test -n "$2" || { zztool -e uso ss; return 1; }
				tema=$2
				shift
			;;
			*)
				mensagem="$*"
				unset tema
				break
			;;
		esac
		shift
	done

	# Extrai a mensagem (desenho) do tema escolhido
	if test -n "$tema"
	then
		mensagem=$(
			echo "$temas" |
				grep -w "$tema" |
				zztrim |
				cut -f2
		)

		if ! test -n "$mensagem"
		then
			zztool erro "Tema desconhecido '$tema'"
			return 1
		fi
	fi

	# O 'mosaico' é um tema especial que precisa de ajustes
	if test "$tema" = 'mosaico'
	then
		# Configurações para mostrar retângulos coloridos frenéticos
		mensagem=' '
		fundo=1
		unset pausa
	fi

	# Define se a parte fixa do código de cores será fundo ou frente
	if test -n "$fundo"
	then
		cor_fixo='30;4'
	else
		cor_fixo='40;3'
	fi

	# Então vamos começar, primeiro limpando a tela
	clear

	# O 'trap' mapeia o Ctrl-C para sair do Screen Saver
	( trap "clear;return" 2

	tamanho_mensagem=${#mensagem}

	while :
	do
		# Posiciona o cursor em um ponto qualquer (aleatório) da tela (X,Y)
		# Detalhe: A mensagem sempre cabe inteira na tela ($coluna)
		linha=$(zzaleatorio 1 $linhas)
		coluna=$(zzaleatorio 1 $((colunas - tamanho_mensagem + 1)))
		printf "\033[$linha;${coluna}H"

		# Escolhe uma cor aleatória para a mensagem (ou o fundo): 1 - 7
		cor_muda=$(zzaleatorio 1 7)

		# Usar negrito ou não também é escolhido ao acaso: 0 - 1
		negrito=$(zzaleatorio 1)

		# Podemos usar cores ou não?
		if test "$ZZCOR" = 1
		then
			codigo_cores="$negrito;$cor_fixo$cor_muda"
			mensagem_colorida="\033[${codigo_cores}m$mensagem\033[m"
		else
			mensagem_colorida="$mensagem"
		fi

		# Mostra a mensagem/desenho na tela e (talvez) espera 1s
		printf "$mensagem_colorida"
		${pausa:+sleep 1}
	done )
}

# ----------------------------------------------------------------------------
# zzstr2hexa
# Converte string em bytes em hexadecimal equivalente.
# Uso: zzstr2hexa [string]
# Ex.: zzstr2hexa @MenteBrilhante    # 40 4d 65 6e 74 65 42 72 69 6c 68 61 6e…
#      zzstr2hexa bin                # 62 69 6e
#      echo bin | zzstr2hexa         # 62 69 6e
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2012-03-30
# Versão: 9
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zzstr2hexa ()
{
	zzzz -h str2hexa "$1" && return

	local string caractere
	local nl=$(printf '\n')

	# String vem como argumento ou STDIN?
	# Nota: não use zztool multi_stdin, adiciona \n no final do argumento
	if test $# -ne 0
	then
		string="$*"
	else
		string=$(cat /dev/stdin)
	fi

	# Loop a cada caractere, e o printf o converte para hexa
	printf %s "$string" |
		while IFS= read -r -n 1 caractere
		do
			if test "$caractere" = "$nl"
			then
				# Exceção para contornar um bug:
				#   printf %x 'c retorna 0 quando c=\n
				printf '0a '
			else
				printf '%02x ' "'$caractere"
			fi
		done |
		zztrim -r |
		zztool nl_eof
}

# ----------------------------------------------------------------------------
# zzsubway
# Mostra uma sugestão de sanduíche para pedir na lanchonete Subway.
# Obs.: Se não gostar da sugestão, chame a função novamente para ter outra.
# Uso: zzsubway
# Ex.: zzsubway
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-12-02
# Versão: 1
# Licença: GPL
# Requisitos: zzshuffle zzaleatorio
# ----------------------------------------------------------------------------
zzsubway ()
{
	zzzz -h subway "$1" && return

	local linha quantidade categoria opcoes

	# O formato é quantidade:categoria:opção1:...:opçãoN
	cardapio="\
	1:recheio:(1) B.M.T. Italiano:(2) Atum:(3) Vegetariano:(4) Frutos do Mar Subway:(5) Frango Teriaki:(6) Peru, Presunto & Bacon:(7) Almôndegas:(8) Carne e Queijo:(9) Peru, Presunto & Roast Beef:(10) Peito de Peru:(11) Rosbife:(12) Peito de Peru e Presunto
	1:pão:italiano branco:integral:parmesão e orégano:três queijos:integral aveia e mel
	1:tamanho:15 cm:30 cm
	1:queijo:suíço:prato:cheddar
	1:extra:nenhum:bacon:tomate seco:cream cheese
	1:tostado:sim:não
	*:salada:alface:tomate:pepino:cebola:pimentão:azeitona preta:picles:rúcula
	1:molho:mostarda e mel:cebola agridoce:barbecue:parmesão:chipotle:mostarda:maionese
	*:tempero:sal:vinagre:azeite de oliva:pimenta calabresa:pimenta do reino"

	echo "$cardapio" | while read linha; do
		quantidade=$(echo "$linha" | cut -d : -f 1 | tr -d '\t')
		categoria=$( echo "$linha" | cut -d : -f 2)
		opcoes=$(    echo "$linha" | cut -d : -f 3- | tr : '\n')

		# Que tipo de ingrediente mostraremos agora? Recheio? Pão? Tamanho? ...
		printf "%s\t: " "$categoria"

		# Quantos ingredientes opcionais colocaremos no pão?
		# O asterisco indica "qualquer quantidade", então é escolhido um
		# número qualquer dentre as opções disponíveis.
		if test "$quantidade" = '*'
		then
			quantidade=$(echo "$opcoes" | sed -n '$=')
			quantidade=$(zzaleatorio 1 $quantidade)
		fi

		# Hora de mostrar os ingredientes.
		# Escolhidos ao acaso (zzshuffle), são pegos N itens ($quantidade).
		# Obs.: Múltiplos itens são mostrados em uma única linha (paste+sed).
		echo "$opcoes" |
			zzshuffle |
			head -n $quantidade |
			paste -s -d : - |
			sed 's/:/, /g'
	done
}

# ----------------------------------------------------------------------------
# zztabuada
# Exibe a tabela de tabuada de um número.
# Com 1 argumento:
#  Tabuada de qualquer número inteiro de 1 a 10.
#
# Com 2 argumentos:
#  Tabuada de qualquer número inteiro de 1 ao segundo argumento.
#  O segundo argumento só pode ser um número positivo de 1 até 99, inclusive.
#
# Se não for informado nenhum argumento será impressa a tabuada de 1 a 9.
#
# Uso: zztabuada [número [número]]
# Ex.: zztabuada
#      zztabuada 2
#      zztabuada -176
#      zztabuada 5 15  # Tabuada do 5, mas multiplicado de 1 até o 15.
#
# Autor: Kl0nEz <kl0nez (a) wifi org br>
# Desde: 2011-08-23
# Versão: 6
# Licença: GPLv2
# Requisitos: zzseq
# ----------------------------------------------------------------------------
zztabuada ()
{
	zzzz -h tabuada "$1" && return

	local i j
	local numeros='0 1 2 3 4 5 6 7 8 9 10'
	local linha="+--------------+--------------+--------------+"

	case "$#" in
		1 | 2)
			if zztool testa_numero_sinal "$1"
			then
				if zztool testa_numero "$2" && test $2 -le 99
				then
					numeros=$(zzseq -f '%d ' 0 $2)
				fi

				for i in $numeros
				do
					if test $i -eq 0 && ! zztool testa_numero "$1"
					then
						printf '%d x %-2d = %d\n' "$1" "$i" $(($1*$i)) | sed 's/= 0/=  0/'
					else
						printf '%d x %-2d = %d\n' "$1" "$i" $(($1*$i))
					fi
				done
			else
				zztool -e uso tabuada
				return 1
			fi
		;;
		0)
			for i in 1 4 7
			do
				echo "$linha"
				echo "| Tabuada do $i | Tabuada do $((i+1)) | Tabuada do $((i+2)) |"
				echo "$linha"
				for j in 0 1 2 3 4 5 6 7 8 9 10
				do
					printf '| %d x %-2d = %-3d ' "$i"     "$j" $((i*j))
					printf '| %d x %-2d = %-3d ' $((i+1)) "$j" $(((i+1)*j))
					printf '| %d x %-2d = %-3d ' $((i+2)) "$j" $(((i+2)*j))
					printf '|\n'
				done
				echo "$linha"
				echo
			done | sed '$d'
		;;
		*)
			zztool -e uso tabuada
			return 1
		;;
	esac
}

# ----------------------------------------------------------------------------
# zztac
# Inverte a ordem das linhas, mostrando da última até a primeira.
# É uma emulação (portável) do comando tac, presente no Linux.
#
# Uso: zztac [arquivos]
# Ex.: zztac /etc/passwd
#      zztac arquivo.txt outro.txt
#      cat /etc/passwd | zztac
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-24
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zztac ()
{
	zzzz -h tac "$1" && return

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" | sed '1!G;h;$!d'

	# Explicação do sed:
	#   A versão simplificada dele é: G;h;d. Esta sequência de comandos
	#   vai empilhando as linhas na ordem inversa no buffer reserva.
	#
	# Supondo o arquivo:
	#   um
	#   dois
	#   três
	#
	# Funcionará assim:
	#                            [principal]            [reserva]
	# --------------------------------------------------------------
	#   Lê a linha 1             um
	#   h                        um                     um
	#   d                                               um
	#   Lê a linha 2             dois
	#   G                        dois\num
	#   h                        dois\num               dois\num
	#   d                                               dois\num
	#   Lê a linha 3             três
	#   h                        três\ndois\num         dois\num
	#   FIM DO ARQUIVO
	#   Mostra o conteúdo do [principal], as linhas invertidas.
}

# ----------------------------------------------------------------------------
# zztempo
# http://weather.noaa.gov/
# Mostra as condições do tempo (clima) em um determinado local.
# Se nenhum parâmetro for passado, são listados os países disponíveis.
# Se só o país for especificado, são listadas as suas localidades.
# As siglas também podem ser usadas, por exemplo SBPA = Porto Alegre.
# Uso: zztempo <país> <localidade>
# Ex.: zztempo 'United Kingdom' 'London City Airport'
#      zztempo brazil 'Curitiba Aeroporto'
#      zztempo brazil SBPA
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-02-19
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zztempo ()
{
	zzzz -h tempo "$1" && return

	local codigo_pais codigo_localidade localidades
	local pais="$1"
	local localidade="$2"
	local cache_paises=$(zztool cache tempo)
	local cache_localidades=$(zztool cache tempo)
	local url='http://weather.noaa.gov'

	# Se o cache de países está vazio, baixa listagem da Internet
	if ! test -s "$cache_paises"
	then
		$ZZWWWHTML "$url" | sed -n '
			/="country"/,/\/select/ {
				s/.*="\([a-zA-Z]*\)">\(.*\) <.*/\1 \2/p
			}' > "$cache_paises"
	fi

	# Se nenhum parâmetro for passado, são listados os países disponíveis
	if ! test -n "$pais"
	then
		sed 's/^[^ ]*  *//' "$cache_paises"
		return
	fi

	# Grava o código deste país (BR  Brazil -> BR)
	codigo_pais=$(grep -i "$1" "$cache_paises" | sed 's/  .*//' | sed 1q)

	# O país existe?
	if ! test -n "$codigo_pais"
	then
		zztool erro "País \"$pais\" não encontrado"
		return 1
	fi

	# Se o cache de locais está vazio, baixa listagem da Internet
	cache_localidades=$cache_localidades.$codigo_pais
	if ! test -s "$cache_localidades"
	then
		$ZZWWWHTML "$url/weather/${codigo_pais}_cc.html" | sed -n '
			/="cccc"/,/\/select/ {
				//d
				s/.*="\([a-zA-Z]*\)">/\1 /p
			}' > "$cache_localidades"
	fi

	# Se só o país for especificado, são listadas as localidades deste país
	if ! test -n "$localidade"
	then
		cat "$cache_localidades"
		return
	fi

	# Pesquisa nas localidades
	localidades=$(grep -i "$localidade" "$cache_localidades")

	# A localidade existe?
	if ! test -n "$localidades"
	then
		zztool erro "Localidade \"$localidade\" não encontrada"
		return 1
	fi

	# Se mais de uma localidade for encontrada, mostre-as
	if test $(echo "$localidades" | sed -n '$=') != 1
	then
		echo "$localidades"
		return 0
	fi

	# Grava o código do local (SBCO  Porto Alegre -> SBCO)
	codigo_localidade=$(echo "$localidades" | sed 's/  .*//')

	# Faz a consulta e filtra o resultado
	echo
	$ZZWWWDUMP "$url/weather/current/${codigo_localidade}.html" | sed -n '
		/Current Weather/,/24 Hour/ {
			//d
			/____*/d
			p
		}'
}

# ----------------------------------------------------------------------------
# zztradutor
# http://translate.google.com
# Google Tradutor, para traduzir frases para vários idiomas.
# Caso não especificado o idioma, a tradução será português -> inglês.
# Use a opção -l ou --lista para ver todos os idiomas disponíveis.
# Use a opção -a ou --audio para ouvir a frase na voz feminina do google.
#
# Alguns idiomas populares são:
#      pt = português         fr = francês
#      en = inglês            it = italiano
#      es = espanhol          de = alemão
#
# Uso: zztradutor [de-para] palavras
# Ex.: zztradutor o livro está na mesa    # the book is on the table
#      zztradutor pt-en livro             # book
#      zztradutor pt-es livro             # libro
#      zztradutor pt-de livro             # Buch
#      zztradutor de-pt Buch              # livro
#      zztradutor de-es Buch              # Libro
#      cat arquivo | zztradutor           # Traduz o conteúdo do arquivo
#      zztradutor --lista                 # Lista todos os idiomas
#      zztradutor --lista eslo            # Procura por "eslo" nos idiomas
#      zztradutor --audio                 # Gera um arquivo OUT.WAV
#      echo "teste" | zztradutor          # test
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-09-02
# Versão: 12
# Licença: GPLv2
# Requisitos: zzxml zzplay zzunescape
# ----------------------------------------------------------------------------
zztradutor ()
{
	zzzz -h tradutor "$1" && return

	# Variaveis locais
	local padrao
	local url='http://translate.google.com.br'
	local lang_de='pt'
	local lang_para='en'
	local charset_para='UTF-8'
	local audio_file=$(zztool cache tradutor "$$.wav")

	case "$1" in
		# O usuário informou um par de idiomas, como pt-en
		[a-z][a-z]-[a-z][a-z])
			lang_de=${1%-??}
			lang_para=${1#??-}
			shift
		;;
		-l | --lista)
			# Uma tag por linha, então extrai e formata as opções do <SELECT>
			$ZZWWWHTML "$url" |
			zzxml --tag option |
			sed -n '/<option value=af>/,/<option value=yi>/p' |
			zztool texto_em_iso | sort -u |
			sed 's/.*value=\([^>]*\)>\([^<]*\)<.*/\1: \2/g;s/zh-CN/cn/g' |
			grep ${2:-:}
			return
		;;
		-a | --audio)
			# Narrativa
				shift
				padrao=$(echo "$*" | sed "$ZZSEDURL")
				local audio="translate_tts?ie=$charset_para&q=$padrao&tl=pt&prev=input"
				$ZZWWWHTML "$url/$audio" > $audio_file && zzplay $audio_file mplayer
				rm -f $audio_file
				return
		;;
	esac

	padrao=$(zztool multi_stdin "$@" | awk '{ if (NR==1) { printf $0 } else { printf "%0a" $0 } }' | sed "$ZZSEDURL")

	# Exceção para o chinês, que usa um código diferente
	test $lang_para = 'cn' && lang_para='zh-CN'

	# Baixa a URL, coloca cada tag em uma linha, pega a linha desejada
	# e limpa essa linha para estar somente o texto desejado.
	$ZZWWWHTML "$url?tr=$lang_de&hl=$lang_para&text=$padrao" |
		zztool texto_em_iso |
		zzxml --tidy |
		sed -n '/id=result_box/,/<\/div>/p' |
		zzxml --untag |
		sed '/span title=/d;/onmouseout=/d;/^ *$/d' |
		zzunescape --html
}

# ----------------------------------------------------------------------------
# zztranspor
# Trocar linhas e colunas de um arquivo, fazendo uma simples transposição.
# Opções:
#   -d, --fs separador   define o separador de campos na entrada.
#   --ofs separador      define o separador de campos na saída.
#
# O separador na entrada pode ser 1 ou mais caracteres ou uma ER.
# Se não for declarado assume-se espaços em branco como separador.
# Conforme padrão do awk, o default seria FS = "[ \t]+".
#
# Se o separador de saída não for declarado, assume o mesmo da entrada.
# Caso a entrada também não seja declarada assume-se como um espaço.
# Conforme padrão do awk, o default é OFS = " ".
#
# Se o separador da entrada é uma ER, é bom declarar o separador de saída.
#
# Uso: zztranspor [-d | --fs <separador>] [--ofs <separador>] <arquivo>
# Ex.: zztranspor -d ":" --ofs "-" num.txt
#      sed -n '2,5p' num.txt | zztranspor --fs '[\t:]' --ofs '\t'
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-09-03
# Versão: 1
# Licença: GPL
# Requisitos: zztrim
# ----------------------------------------------------------------------------
zztranspor ()
{
	zzzz -h transpor "$1" && return

	local sep ofs

	while test "${1#-}" != "$1"
	do
		case "$1" in
			-d | --fs)
			# Separador de campos no arquivo de entrada
				sep="$2"
				shift
				shift
			;;
			--ofs)
			# Separador de campos na saída
				ofs="$2"
				shift
				shift
			;;
			*) break;;
		esac
	done

	zztool file_stdin "$@" |
	awk -v sep_awk="$sep" -v ofs_awk="$ofs" '
	BEGIN {
		# Definindo o separador de campo na entrada do awk
		if (length(sep_awk)>0)
			FS = sep_awk

		# Definindo o separador de campo na saída do awk
		ofs_awk = (length(ofs_awk)>0?ofs_awk:FS)
	}

	{
		# Descobrindo a maior quantidade de campos
		if (max_nf < NF)
			max_nf = NF

		# Criando um array indexado por número do campo e número da linha, nessa ordem
		for (i = 1; i <= NF; i++)
			vetor[i, NR] = $i
	}

	END {
		# Transformando o campo em linha
		for (i = 1; i <= max_nf; i++) {
			# Transformando a linha em campo
			for (j = 1; j <= NR; j++)
				linha = sprintf("%s%s%s", linha, vetor[i, j], ofs_awk)

			# Tirando o separador ao final da linha
			print substr(linha, 1, length(linha) - length(ofs_awk))

			# Limpando a variável para a próxima iteração
			linha=""
		}
	}' | zztrim -r
}

# ----------------------------------------------------------------------------
# zztrim
# Apaga brancos (" " \t \n) ao redor do texto: direita, esquerda, cima, baixo.
# Obs.: Linhas que só possuem espaços e tabs são consideradas em branco.
#
# Opções:
#   -t, --top         Apaga as linhas em branco do início do texto
#   -b, --bottom      Apaga as linhas em branco do final do texto
#   -l, --left        Apaga os brancos do início de todas as linhas
#   -r, --right       Apaga os brancos do final de todas as linhas
#   -V, --vertical    Apaga as linhas em branco do início e final (-t -b)
#   -H, --horizontal  Apaga os brancos do início e final das linhas (-l -r)
#
# Uso: zztrim [opções] [texto]
# Ex.: zztrim "   foo bar   "           # "foo bar"
#      zztrim -l "   foo bar   "        # "foo bar   "
#      zztrim -r "   foo bar   "        # "   foo bar"
#      echo "   foo bar   " | zztrim    # "foo bar"
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2015-03-05
# Versão: 3
# Licença: GPL
# ----------------------------------------------------------------------------
zztrim ()
{
	zzzz -h trim "$1" && return

	local top left right bottom
	local delete_top delete_left delete_right delete_bottom

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			-l | --left      ) shift; left=1;;
			-r | --right     ) shift; right=1;;
			-t | --top       ) shift; top=1;;
			-b | --bottom    ) shift; bottom=1;;
			-H | --horizontal) shift; left=1; right=1;;
			-V | --vertical  ) shift; top=1; bottom=1;;
			--*) zztool erro "Opção inválida $1"; return 1;;
			*) break;;
		esac
	done

	# Comportamento padrão, quando nenhuma opção foi informada
	if test -z "$top$bottom$left$right"
	then
		top=1
		bottom=1
		left=1
		right=1
	fi

	# Compõe os comandos sed para apagar os brancos,
	# levando em conta quais são as opções ativas
	test -n "$top"    && delete_top='/[^[:blank:]]/,$!d;'
	test -n "$left"   && delete_left='s/^[[:blank:]]*//;'
	test -n "$right"  && delete_right='s/[[:blank:]]*$//;'
	test -n "$bottom" && delete_bottom='
		:loop
		/^[[:space:]]*$/ {
			$ d
			N
			b loop
		}
	'

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |
		# Aplica os filtros
		sed "$delete_top $delete_left $delete_right" |
		# Este deve vir sozinho, senão afeta os outros (comando N)
		sed "$delete_bottom"

		# Nota: Não há problema se as variáveis estiverem vazias,
		#       sed "" é um comando nulo e não fará alterações.
}

# ----------------------------------------------------------------------------
# zztrocaarquivos
# Troca o conteúdo de dois arquivos, mantendo suas permissões originais.
# Uso: zztrocaarquivos arquivo1 arquivo2
# Ex.: zztrocaarquivos /etc/fstab.bak /etc/fstab
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-06-12
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zztrocaarquivos ()
{
	zzzz -h trocaarquivos "$1" && return

	# Um terceiro arquivo é usado para fazer a troca
	local tmp=$(zztool mktemp trocaarquivos)

	# Verificação dos parâmetros
	test $# -eq 2 || { zztool -e uso trocaarquivos; return 1; }

	# Verifica se os arquivos existem
	zztool arquivo_legivel "$1" || return
	zztool arquivo_legivel "$2" || return

	# Tiro no pé? Não, obrigado
	test "$1" = "$2" && return

	# A dança das cadeiras
	cat "$2"   > "$tmp"
	cat "$1"   > "$2"
	cat "$tmp" > "$1"

	# E foi
	rm -f "$tmp"
	echo "Feito: $1 <-> $2"
}

# ----------------------------------------------------------------------------
# zztrocaextensao
# Troca a extensão dos arquivos especificados.
# Com a opção -n, apenas mostra o que será feito, mas não executa.
# Uso: zztrocaextensao [-n] antiga nova arquivo(s)
# Ex.: zztrocaextensao -n .doc .txt *          # tire o -n para renomear!
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-15
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zztrocaextensao ()
{
	zzzz -h trocaextensao "$1" && return

	local ext1 ext2 arquivo base novo nao

	# Opções de linha de comando
	if test "$1" = '-n'
	then
		nao='[-n] '
		shift
	fi

	# Verificação dos parâmetros
	test -n "$3" || { zztool -e uso trocaextensao; return 1; }

	# Guarda as extensões informadas
	ext1="$1"
	ext2="$2"
	shift; shift

	# Tiro no pé? Não, obrigado
	test "$ext1" = "$ext2" && return

	# Para cada arquivo que o usuário informou...
	for arquivo
	do
		# O arquivo existe?
		zztool arquivo_legivel "$arquivo" || continue

		base="${arquivo%$ext1}"
		novo="$base$ext2"

		# Testa se o arquivo possui a extensão antiga
		test "$base" != "$arquivo" || continue

		# Mostra o que será feito
		echo "$nao$arquivo -> $novo"

		# Se não tiver -n, vamos renomear o arquivo
		if test ! -n "$nao"
		then
			# Não sobrescreve arquivos já existentes
			zztool arquivo_vago "$novo" || return

			# Vamos lá
			mv -- "$arquivo" "$novo"
		fi
	done
}

# ----------------------------------------------------------------------------
# zztrocapalavra
# Troca uma palavra por outra, nos arquivos especificados.
# Obs.: Além de palavras, é possível usar expressões regulares.
# Uso: zztrocapalavra antiga nova arquivo(s)
# Ex.: zztrocapalavra excessão exceção *.txt
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-04
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zztrocapalavra ()
{
	zzzz -h trocapalavra "$1" && return

	local arquivo antiga_escapada nova_escapada
	local antiga="$1"
	local nova="$2"

	# Precisa do temporário pois nem todos os Sed possuem a opção -i
	local tmp=$(zztool mktemp trocapalavra)

	# Verificação dos parâmetros
	test -n "$3" || { zztool -e uso trocapalavra; return 1; }

	# Escapando a barra "/" dentro dos textos de pesquisa
	antiga_escapada=$(echo "$antiga" | sed 's,/,\\/,g')
	nova_escapada=$(  echo "$nova"   | sed 's,/,\\/,g')

	shift; shift

	# Para cada arquivo que o usuário informou...
	for arquivo
	do
		# O arquivo existe?
		zztool arquivo_legivel "$arquivo" || continue

		# Um teste rápido para saber se o arquivo tem a palavra antiga,
		# evitando gravar o temporário desnecessariamente
		grep "$antiga" "$arquivo" >/dev/null 2>&1 || continue

		# Uma seqüência encadeada de comandos para garantir que está OK
		cp "$arquivo" "$tmp" &&
		sed "s/$antiga_escapada/$nova_escapada/g" "$tmp" > "$arquivo" && {
			echo "Feito $arquivo" # Está retornando 1 :/
			continue
		}

		# Em caso de erro, recupera o conteúdo original
		zztool erro "Ops, deu algum erro no arquivo $arquivo"
		zztool erro "Uma cópia dele está em $tmp"
		cat "$tmp" > "$arquivo"
		return 1
	done
	rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# zztv
# Mostra a programação da TV, diária ou semanal, com escolha de emissora.
#
# Opções:
#  canais - lista os canais com seus códigos para consulta.
#
#  <código canal> - Programação do canal escolhido.
#  Obs.: Se for seguido de "semana" ou "s" mostra toda programação semanal.
#
#  cod <número> - mostra um resumo do programa.
#   Obs: número obtido pelas listagens da programação do canal consultado.
#
# Programação corrente:
#  doc ou documentario, esportes ou futebol, filmes, infantil, variedades
#  series ou seriados, aberta, todos ou agora (padrão).
#
# Uso: zztv <código canal> [semana|s]  ou  zztv cod <número>
# Ex.: zztv CUL          # Programação da TV Cultura
#      zztv cod 3235238
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-02-19
# Versão: 11
# Licença: GPL
# Requisitos: zzunescape zzdos2unix zzcolunar
# ----------------------------------------------------------------------------
zztv ()
{
	zzzz -h tv "$1" && return

	local DATA=$(date +%d\\/%m)
	local URL="http://meuguia.tv/programacao"
	local cache=$(zztool cache tv)
	local codigo desc linhas largura

	# 0 = lista canal especifico
	# 1 = lista programas de vários canais no horário
	local flag=0

	if ! test -s "$cache"
	then
		$ZZWWWHTML ${URL}/categoria/Todos |
		sed -n '/programacao\/canal/p;/^ *|/p' |
		awk -F '("| [|] )' '{print $2, $6 }' |
		sed 's/<[^>]*>//g;s|^.*/||' |
		zzdos2unix |
		sort >> $cache
	fi
	linhas=$(echo "scale=0; ($(zztool num_linhas $cache) + 1)/ 4 " | bc)
	largura=$(awk '{print length}' $cache | sort -n | sed -n '$p')

	if test -n "$1" && grep -i "^$1" $cache >/dev/null 2>/dev/null
	then
		codigo=$(grep -i "^$1" $cache | sed "s/ .*//")
		desc=$(grep -i "^$1" $cache | sed "s/^[A-Z0-9]\{3\} *//")

		zztool eco $desc
		$ZZWWWHTML "${URL}/canal/$codigo" |
		sed -n '/<li class/{N;p;}' |
		sed '/^[[:space:]]*$/d;/.*<\/*li/s/<[^>]*>//g' |
		sed 's/^.*programa\///g;s/".*title="/_/g;s/">//g;s/<span .*//g;s/<[^>]*>/ /g;s/amp;//g' |
		sed 's/^[[:space:]]*/ /g' |
		sed '/^[[:space:]]*$/d' |
		if test "$2" = "semana" -o "$2" = "s"
		then
			sed "/^ \([STQD].*[0-9][0-9]\/[0-9][0-9]\)/ { x; p ; x; s//\1/; }" |
			sed 's/^ \(.*\)_\(.*\)\([0-9][0-9]h[0-9][0-9]\)/ \3 \2 Cod: \1/g'
		else
			sed -n "/, $DATA/,/^ [STQD].*[0-9][0-9]\/[0-9][0-9]/p" |
			sed '$d;1s/^ *//;2,$s/^ \(.*\)_\(.*\)\([0-9][0-9]h[0-9][0-9]\)/ \3 \2 Cod: \1/g'
		fi |
		zzunescape --html |
		awk -F " Cod: " '{ if (NF==2) { printf "%-64s Cod: %s\n", substr($1,1,63), substr($2, 1, index($2, "-")-1) } else print }'
		return
	fi

	case "$1" in
	canais) zzcolunar 4 $cache;;
	aberta)                        URL="${URL}/categoria/Aberta"; flag=1; desc="Aberta";;
	doc | documentario)            URL="${URL}/categoria/Documentarios"; flag=1; desc="Documentários";;
	esporte | esportes | futebol)  URL="${URL}/categoria/Esportes"; flag=1; desc="Esportes";;
	filmes)                        URL="${URL}/categoria/Filmes"; flag=1; desc="Filmes";;
	infantil)                      URL="${URL}/categoria/Infantil"; flag=1; desc="Infantil";;
	noticias)                      URL="${URL}/categoria/Noticias"; flag=1; desc="Notícias";;
	series | seriados)             URL="${URL}/categoria/Series"; flag=1; desc="Séries";;
	variedades)                    URL="${URL}/categoria/Variedades"; flag=1; desc="Variedades";;
	cod)                           URL="${URL}/programa/$2"; flag=2;;
	todos | agora | *)             URL="${URL}/categoria/Todos"; flag=1; desc="Agora";;
	esac

	if test $flag -eq 1
	then
		zztool eco $desc
		$ZZWWWHTML "$URL" | sed -n '/<li style/{N;p;}' |
		sed '/^[[:space:]]*$/d;/.*<\/*li/s/<[^>]*>//g' |
		sed 's/.*title="//g;s/">.*<br \/>/ | /g;s/<[^>]*>/ /g' |
		sed 's/[[:space:]]\{1,\}/ /g' |
		sed '/^[[:space:]]*$/d' |
		zzunescape --html |
		awk -F "|" '{ printf "%5s%-57s%s\n", $2, substr($1,1,56), $3 }'
	elif test "$1" = "cod"
	then
		zztool eco "Código: $2"
		$ZZWWWHTML "$URL" | sed -n '/<span class="tit">/,/Compartilhe:/p' |
		sed 's/<span class="tit">/Título: /;s/<span class="tit_orig">/Título Original: /' |
		sed 's/<[^>]*>/ /g;s/amp;//g;s/\&ccedil;/ç/g;s/\&atilde;/ã/g;s/.*str="//;s/";//;s/[\|] //g' |
		sed 's/^[[:space:]]*/ /g' |
		sed '/^[[:space:]]*$/d;/document.write/d;/str == ""/d;$d' |
		zzunescape --html
	fi
}

# ----------------------------------------------------------------------------
# zztweets
# Busca as mensagens mais recentes de um usuário do Twitter.
# Use a opção -n para informar o número de mensagens (padrão é 5, máx 20).
# Com a opção -r após o nome do usuário, lista também tweets respostas.
#
# Uso: zztweets [-n N] username [-r]
# Ex.: zztweets oreio
#      zztweets -n 10 oreio
#      zztweets oreio -r
#
# Autor: Eri Ramos Bastos <bastos.eri (a) gmail.com>
# Desde: 2009-07-30
# Versão: 8
# Licença: GPL
# ----------------------------------------------------------------------------
zztweets ()
{
	zzzz -h tweets "$1" && return

	test -n "$1" || { zztool -e uso tweets; return 1; }

	local name
	local limite=5
	local url="https://twitter.com"

	# Opções de linha de comando
	if test "$1" = '-n'
	then
		limite="$2"
		shift
		shift

		zztool -e testa_numero "$limite" || return 1
	fi

	# Informar o @ é opcional
	name=$(echo "$1" | tr -d @)
	url="${url}/${name}"
	test "$2" = '-r' && url="${url}/with_replies"

	$ZZWWWDUMP $url |
		sed '1,70 d' |
		sed '1,/ View Tweets$/d;/(BUTTON) Try again/,$d' |
		awk '
			/ @'$name'/, /\* \(BUTTON\)/ { if(NF>1) print }
			/Retweeted by /, /\* \(BUTTON\)/ { if(NF>1) print }
			/retweeted$/, /\* \(BUTTON\)/ { if(NF>1) print }' |
		sed "
			/Retweeted by /d
			/retweeted$/d
			/  ·  /{s/  ·  .*$/>:/;s/^.*@/@/}
			/@$name/d
			/(BUTTON)/d
			/View summary/d
			/View conversation/d
			/^ *YouTube$/d
			/^ *Play$/d
			/^ *View more photos and videos$/d
			/^ *Embedded image permalink$/d
			/[0-9,]\{1,\} retweets\{0,1\} [0-9,]\{1,\} favorite/d
			/Twitter may be over capacity or experiencing a momentary hiccup/d
			s/\[DEL: \(.\) :DEL\] /\1/g
			s/^ *//g
		" |
		awk '{ if (/>:$/){ sub(/>:$/,": "); printf $0; getline;print } else print }' |
		sed "$limite q" |
		sed G

	# Apagando as 70 primeiras linhas usando apenas números,
	# pois o sed do BSD capota se tentar ler o conteúdo destas
	# linhas. Leia mais no issue #28.
}

# ----------------------------------------------------------------------------
# zzunescape
# Restaura caracteres codificados como entidades HTML e XML (&lt; &#62; ...).
# Entende entidades (&gt;), códigos decimais (&#62;) e hexadecimais (&#x3E;).
#
# Opções: --html  Restaura caracteres HTML
#         --xml   Restaura caracteres XML
#
# Uso: zzunescape [--html] [--xml] [arquivo(s)]
# Ex.: zzunescape --xml arquivo.xml
#      zzunescape --html arquivo.html
#      cat arquivo.html | zzunescape --html
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-03
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzunescape ()
{
	zzzz -h unescape "$1" && return

	local xml html
	local filtro=''

	# http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
	xml="
		s/&#0*34;/\"/g;     s/&#x0*22;/\"/g;    s/&quot;/\"/g;
		s/&#0*38;/\&/g;     s/&#x0*26;/\&/g;    s/&amp;/\&/g;
		s/&#0*39;/'/g;      s/&#x0*27;/'/g;     s/&apos;/'/g;
		s/&#0*60;/</g;      s/&#x0*3C;/</g;     s/&lt;/</g;
		s/&#0*62;/>/g;      s/&#x0*3E;/>/g;     s/&gt;/>/g;
	"

	# http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
	## pattern: ^(.*)\t(.*)\tU\+0*(\w+) \((\d+)\)\t.*$
	## replace: s/&#0*$4;/$2/g;\ts/&#x0*$3;/$2/g;\ts/&$1;/$2/g;
	## expand -t 20
	## Escapar na mão: \& e \"
	html="
		s/&#0*34;/\"/g;     s/&#x0*22;/\"/g;    s/&quot;/\"/g;
		s/&#0*38;/\&/g;     s/&#x0*26;/\&/g;    s/&amp;/\&/g;
		s/&#0*39;/'/g;      s/&#x0*27;/'/g;     s/&apos;/'/g;
		s/&#0*60;/</g;      s/&#x0*3C;/</g;     s/&lt;/</g;
		s/&#0*62;/>/g;      s/&#x0*3E;/>/g;     s/&gt;/>/g;
		s/&#0*160;/ /g;     s/&#x0*A0;/ /g;     s/&nbsp;/ /g;
		s/&#0*161;/¡/g;     s/&#x0*A1;/¡/g;     s/&iexcl;/¡/g;
		s/&#0*162;/¢/g;     s/&#x0*A2;/¢/g;     s/&cent;/¢/g;
		s/&#0*163;/£/g;     s/&#x0*A3;/£/g;     s/&pound;/£/g;
		s/&#0*164;/¤/g;     s/&#x0*A4;/¤/g;     s/&curren;/¤/g;
		s/&#0*165;/¥/g;     s/&#x0*A5;/¥/g;     s/&yen;/¥/g;
		s/&#0*166;/¦/g;     s/&#x0*A6;/¦/g;     s/&brvbar;/¦/g;
		s/&#0*167;/§/g;     s/&#x0*A7;/§/g;     s/&sect;/§/g;
		s/&#0*168;/¨/g;     s/&#x0*A8;/¨/g;     s/&uml;/¨/g;
		s/&#0*169;/©/g;     s/&#x0*A9;/©/g;     s/&copy;/©/g;
		s/&#0*170;/ª/g;     s/&#x0*AA;/ª/g;     s/&ordf;/ª/g;
		s/&#0*171;/«/g;     s/&#x0*AB;/«/g;     s/&laquo;/«/g;
		s/&#0*172;/¬/g;     s/&#x0*AC;/¬/g;     s/&not;/¬/g;
		s/&#0*173;/ /g;     s/&#x0*AD;/ /g;     s/&shy;/ /g;
		s/&#0*174;/®/g;     s/&#x0*AE;/®/g;     s/&reg;/®/g;
		s/&#0*175;/¯/g;     s/&#x0*AF;/¯/g;     s/&macr;/¯/g;
		s/&#0*176;/°/g;     s/&#x0*B0;/°/g;     s/&deg;/°/g;
		s/&#0*177;/±/g;     s/&#x0*B1;/±/g;     s/&plusmn;/±/g;
		s/&#0*178;/²/g;     s/&#x0*B2;/²/g;     s/&sup2;/²/g;
		s/&#0*179;/³/g;     s/&#x0*B3;/³/g;     s/&sup3;/³/g;
		s/&#0*180;/´/g;     s/&#x0*B4;/´/g;     s/&acute;/´/g;
		s/&#0*181;/µ/g;     s/&#x0*B5;/µ/g;     s/&micro;/µ/g;
		s/&#0*182;/¶/g;     s/&#x0*B6;/¶/g;     s/&para;/¶/g;
		s/&#0*183;/·/g;     s/&#x0*B7;/·/g;     s/&middot;/·/g;
		s/&#0*184;/¸/g;     s/&#x0*B8;/¸/g;     s/&cedil;/¸/g;
		s/&#0*185;/¹/g;     s/&#x0*B9;/¹/g;     s/&sup1;/¹/g;
		s/&#0*186;/º/g;     s/&#x0*BA;/º/g;     s/&ordm;/º/g;
		s/&#0*187;/»/g;     s/&#x0*BB;/»/g;     s/&raquo;/»/g;
		s/&#0*188;/¼/g;     s/&#x0*BC;/¼/g;     s/&frac14;/¼/g;
		s/&#0*189;/½/g;     s/&#x0*BD;/½/g;     s/&frac12;/½/g;
		s/&#0*190;/¾/g;     s/&#x0*BE;/¾/g;     s/&frac34;/¾/g;
		s/&#0*191;/¿/g;     s/&#x0*BF;/¿/g;     s/&iquest;/¿/g;
		s/&#0*192;/À/g;     s/&#x0*C0;/À/g;     s/&Agrave;/À/g;
		s/&#0*193;/Á/g;     s/&#x0*C1;/Á/g;     s/&Aacute;/Á/g;
		s/&#0*194;/Â/g;     s/&#x0*C2;/Â/g;     s/&Acirc;/Â/g;
		s/&#0*195;/Ã/g;     s/&#x0*C3;/Ã/g;     s/&Atilde;/Ã/g;
		s/&#0*196;/Ä/g;     s/&#x0*C4;/Ä/g;     s/&Auml;/Ä/g;
		s/&#0*197;/Å/g;     s/&#x0*C5;/Å/g;     s/&Aring;/Å/g;
		s/&#0*198;/Æ/g;     s/&#x0*C6;/Æ/g;     s/&AElig;/Æ/g;
		s/&#0*199;/Ç/g;     s/&#x0*C7;/Ç/g;     s/&Ccedil;/Ç/g;
		s/&#0*200;/È/g;     s/&#x0*C8;/È/g;     s/&Egrave;/È/g;
		s/&#0*201;/É/g;     s/&#x0*C9;/É/g;     s/&Eacute;/É/g;
		s/&#0*202;/Ê/g;     s/&#x0*CA;/Ê/g;     s/&Ecirc;/Ê/g;
		s/&#0*203;/Ë/g;     s/&#x0*CB;/Ë/g;     s/&Euml;/Ë/g;
		s/&#0*204;/Ì/g;     s/&#x0*CC;/Ì/g;     s/&Igrave;/Ì/g;
		s/&#0*205;/Í/g;     s/&#x0*CD;/Í/g;     s/&Iacute;/Í/g;
		s/&#0*206;/Î/g;     s/&#x0*CE;/Î/g;     s/&Icirc;/Î/g;
		s/&#0*207;/Ï/g;     s/&#x0*CF;/Ï/g;     s/&Iuml;/Ï/g;
		s/&#0*208;/Ð/g;     s/&#x0*D0;/Ð/g;     s/&ETH;/Ð/g;
		s/&#0*209;/Ñ/g;     s/&#x0*D1;/Ñ/g;     s/&Ntilde;/Ñ/g;
		s/&#0*210;/Ò/g;     s/&#x0*D2;/Ò/g;     s/&Ograve;/Ò/g;
		s/&#0*211;/Ó/g;     s/&#x0*D3;/Ó/g;     s/&Oacute;/Ó/g;
		s/&#0*212;/Ô/g;     s/&#x0*D4;/Ô/g;     s/&Ocirc;/Ô/g;
		s/&#0*213;/Õ/g;     s/&#x0*D5;/Õ/g;     s/&Otilde;/Õ/g;
		s/&#0*214;/Ö/g;     s/&#x0*D6;/Ö/g;     s/&Ouml;/Ö/g;
		s/&#0*215;/×/g;     s/&#x0*D7;/×/g;     s/&times;/×/g;
		s/&#0*216;/Ø/g;     s/&#x0*D8;/Ø/g;     s/&Oslash;/Ø/g;
		s/&#0*217;/Ù/g;     s/&#x0*D9;/Ù/g;     s/&Ugrave;/Ù/g;
		s/&#0*218;/Ú/g;     s/&#x0*DA;/Ú/g;     s/&Uacute;/Ú/g;
		s/&#0*219;/Û/g;     s/&#x0*DB;/Û/g;     s/&Ucirc;/Û/g;
		s/&#0*220;/Ü/g;     s/&#x0*DC;/Ü/g;     s/&Uuml;/Ü/g;
		s/&#0*221;/Ý/g;     s/&#x0*DD;/Ý/g;     s/&Yacute;/Ý/g;
		s/&#0*222;/Þ/g;     s/&#x0*DE;/Þ/g;     s/&THORN;/Þ/g;
		s/&#0*223;/ß/g;     s/&#x0*DF;/ß/g;     s/&szlig;/ß/g;
		s/&#0*224;/à/g;     s/&#x0*E0;/à/g;     s/&agrave;/à/g;
		s/&#0*225;/á/g;     s/&#x0*E1;/á/g;     s/&aacute;/á/g;
		s/&#0*226;/â/g;     s/&#x0*E2;/â/g;     s/&acirc;/â/g;
		s/&#0*227;/ã/g;     s/&#x0*E3;/ã/g;     s/&atilde;/ã/g;
		s/&#0*228;/ä/g;     s/&#x0*E4;/ä/g;     s/&auml;/ä/g;
		s/&#0*229;/å/g;     s/&#x0*E5;/å/g;     s/&aring;/å/g;
		s/&#0*230;/æ/g;     s/&#x0*E6;/æ/g;     s/&aelig;/æ/g;
		s/&#0*231;/ç/g;     s/&#x0*E7;/ç/g;     s/&ccedil;/ç/g;
		s/&#0*232;/è/g;     s/&#x0*E8;/è/g;     s/&egrave;/è/g;
		s/&#0*233;/é/g;     s/&#x0*E9;/é/g;     s/&eacute;/é/g;
		s/&#0*234;/ê/g;     s/&#x0*EA;/ê/g;     s/&ecirc;/ê/g;
		s/&#0*235;/ë/g;     s/&#x0*EB;/ë/g;     s/&euml;/ë/g;
		s/&#0*236;/ì/g;     s/&#x0*EC;/ì/g;     s/&igrave;/ì/g;
		s/&#0*237;/í/g;     s/&#x0*ED;/í/g;     s/&iacute;/í/g;
		s/&#0*238;/î/g;     s/&#x0*EE;/î/g;     s/&icirc;/î/g;
		s/&#0*239;/ï/g;     s/&#x0*EF;/ï/g;     s/&iuml;/ï/g;
		s/&#0*240;/ð/g;     s/&#x0*F0;/ð/g;     s/&eth;/ð/g;
		s/&#0*241;/ñ/g;     s/&#x0*F1;/ñ/g;     s/&ntilde;/ñ/g;
		s/&#0*242;/ò/g;     s/&#x0*F2;/ò/g;     s/&ograve;/ò/g;
		s/&#0*243;/ó/g;     s/&#x0*F3;/ó/g;     s/&oacute;/ó/g;
		s/&#0*244;/ô/g;     s/&#x0*F4;/ô/g;     s/&ocirc;/ô/g;
		s/&#0*245;/õ/g;     s/&#x0*F5;/õ/g;     s/&otilde;/õ/g;
		s/&#0*246;/ö/g;     s/&#x0*F6;/ö/g;     s/&ouml;/ö/g;
		s/&#0*247;/÷/g;     s/&#x0*F7;/÷/g;     s/&divide;/÷/g;
		s/&#0*248;/ø/g;     s/&#x0*F8;/ø/g;     s/&oslash;/ø/g;
		s/&#0*249;/ù/g;     s/&#x0*F9;/ù/g;     s/&ugrave;/ù/g;
		s/&#0*250;/ú/g;     s/&#x0*FA;/ú/g;     s/&uacute;/ú/g;
		s/&#0*251;/û/g;     s/&#x0*FB;/û/g;     s/&ucirc;/û/g;
		s/&#0*252;/ü/g;     s/&#x0*FC;/ü/g;     s/&uuml;/ü/g;
		s/&#0*253;/ý/g;     s/&#x0*FD;/ý/g;     s/&yacute;/ý/g;
		s/&#0*254;/þ/g;     s/&#x0*FE;/þ/g;     s/&thorn;/þ/g;
		s/&#0*255;/ÿ/g;     s/&#x0*FF;/ÿ/g;     s/&yuml;/ÿ/g;
		s/&#0*338;/Œ/g;     s/&#x0*152;/Œ/g;    s/&OElig;/Œ/g;
		s/&#0*339;/œ/g;     s/&#x0*153;/œ/g;    s/&oelig;/œ/g;
		s/&#0*352;/Š/g;     s/&#x0*160;/Š/g;    s/&Scaron;/Š/g;
		s/&#0*353;/š/g;     s/&#x0*161;/š/g;    s/&scaron;/š/g;
		s/&#0*376;/Ÿ/g;     s/&#x0*178;/Ÿ/g;    s/&Yuml;/Ÿ/g;
		s/&#0*402;/ƒ/g;     s/&#x0*192;/ƒ/g;    s/&fnof;/ƒ/g;
		s/&#0*710;/ˆ/g;     s/&#x0*2C6;/ˆ/g;    s/&circ;/ˆ/g;
		s/&#0*732;/˜/g;     s/&#x0*2DC;/˜/g;    s/&tilde;/˜/g;
		s/&#0*913;/Α/g;     s/&#x0*391;/Α/g;    s/&Alpha;/Α/g;
		s/&#0*914;/Β/g;     s/&#x0*392;/Β/g;    s/&Beta;/Β/g;
		s/&#0*915;/Γ/g;     s/&#x0*393;/Γ/g;    s/&Gamma;/Γ/g;
		s/&#0*916;/Δ/g;     s/&#x0*394;/Δ/g;    s/&Delta;/Δ/g;
		s/&#0*917;/Ε/g;     s/&#x0*395;/Ε/g;    s/&Epsilon;/Ε/g;
		s/&#0*918;/Ζ/g;     s/&#x0*396;/Ζ/g;    s/&Zeta;/Ζ/g;
		s/&#0*919;/Η/g;     s/&#x0*397;/Η/g;    s/&Eta;/Η/g;
		s/&#0*920;/Θ/g;     s/&#x0*398;/Θ/g;    s/&Theta;/Θ/g;
		s/&#0*921;/Ι/g;     s/&#x0*399;/Ι/g;    s/&Iota;/Ι/g;
		s/&#0*922;/Κ/g;     s/&#x0*39A;/Κ/g;    s/&Kappa;/Κ/g;
		s/&#0*923;/Λ/g;     s/&#x0*39B;/Λ/g;    s/&Lambda;/Λ/g;
		s/&#0*924;/Μ/g;     s/&#x0*39C;/Μ/g;    s/&Mu;/Μ/g;
		s/&#0*925;/Ν/g;     s/&#x0*39D;/Ν/g;    s/&Nu;/Ν/g;
		s/&#0*926;/Ξ/g;     s/&#x0*39E;/Ξ/g;    s/&Xi;/Ξ/g;
		s/&#0*927;/Ο/g;     s/&#x0*39F;/Ο/g;    s/&Omicron;/Ο/g;
		s/&#0*928;/Π/g;     s/&#x0*3A0;/Π/g;    s/&Pi;/Π/g;
		s/&#0*929;/Ρ/g;     s/&#x0*3A1;/Ρ/g;    s/&Rho;/Ρ/g;
		s/&#0*931;/Σ/g;     s/&#x0*3A3;/Σ/g;    s/&Sigma;/Σ/g;
		s/&#0*932;/Τ/g;     s/&#x0*3A4;/Τ/g;    s/&Tau;/Τ/g;
		s/&#0*933;/Υ/g;     s/&#x0*3A5;/Υ/g;    s/&Upsilon;/Υ/g;
		s/&#0*934;/Φ/g;     s/&#x0*3A6;/Φ/g;    s/&Phi;/Φ/g;
		s/&#0*935;/Χ/g;     s/&#x0*3A7;/Χ/g;    s/&Chi;/Χ/g;
		s/&#0*936;/Ψ/g;     s/&#x0*3A8;/Ψ/g;    s/&Psi;/Ψ/g;
		s/&#0*937;/Ω/g;     s/&#x0*3A9;/Ω/g;    s/&Omega;/Ω/g;
		s/&#0*945;/α/g;     s/&#x0*3B1;/α/g;    s/&alpha;/α/g;
		s/&#0*946;/β/g;     s/&#x0*3B2;/β/g;    s/&beta;/β/g;
		s/&#0*947;/γ/g;     s/&#x0*3B3;/γ/g;    s/&gamma;/γ/g;
		s/&#0*948;/δ/g;     s/&#x0*3B4;/δ/g;    s/&delta;/δ/g;
		s/&#0*949;/ε/g;     s/&#x0*3B5;/ε/g;    s/&epsilon;/ε/g;
		s/&#0*950;/ζ/g;     s/&#x0*3B6;/ζ/g;    s/&zeta;/ζ/g;
		s/&#0*951;/η/g;     s/&#x0*3B7;/η/g;    s/&eta;/η/g;
		s/&#0*952;/θ/g;     s/&#x0*3B8;/θ/g;    s/&theta;/θ/g;
		s/&#0*953;/ι/g;     s/&#x0*3B9;/ι/g;    s/&iota;/ι/g;
		s/&#0*954;/κ/g;     s/&#x0*3BA;/κ/g;    s/&kappa;/κ/g;
		s/&#0*955;/λ/g;     s/&#x0*3BB;/λ/g;    s/&lambda;/λ/g;
		s/&#0*956;/μ/g;     s/&#x0*3BC;/μ/g;    s/&mu;/μ/g;
		s/&#0*957;/ν/g;     s/&#x0*3BD;/ν/g;    s/&nu;/ν/g;
		s/&#0*958;/ξ/g;     s/&#x0*3BE;/ξ/g;    s/&xi;/ξ/g;
		s/&#0*959;/ο/g;     s/&#x0*3BF;/ο/g;    s/&omicron;/ο/g;
		s/&#0*960;/π/g;     s/&#x0*3C0;/π/g;    s/&pi;/π/g;
		s/&#0*961;/ρ/g;     s/&#x0*3C1;/ρ/g;    s/&rho;/ρ/g;
		s/&#0*962;/ς/g;     s/&#x0*3C2;/ς/g;    s/&sigmaf;/ς/g;
		s/&#0*963;/σ/g;     s/&#x0*3C3;/σ/g;    s/&sigma;/σ/g;
		s/&#0*964;/τ/g;     s/&#x0*3C4;/τ/g;    s/&tau;/τ/g;
		s/&#0*965;/υ/g;     s/&#x0*3C5;/υ/g;    s/&upsilon;/υ/g;
		s/&#0*966;/φ/g;     s/&#x0*3C6;/φ/g;    s/&phi;/φ/g;
		s/&#0*967;/χ/g;     s/&#x0*3C7;/χ/g;    s/&chi;/χ/g;
		s/&#0*968;/ψ/g;     s/&#x0*3C8;/ψ/g;    s/&psi;/ψ/g;
		s/&#0*969;/ω/g;     s/&#x0*3C9;/ω/g;    s/&omega;/ω/g;
		s/&#0*977;/ϑ/g;     s/&#x0*3D1;/ϑ/g;    s/&thetasym;/ϑ/g;
		s/&#0*978;/ϒ/g;     s/&#x0*3D2;/ϒ/g;    s/&upsih;/ϒ/g;
		s/&#0*982;/ϖ/g;     s/&#x0*3D6;/ϖ/g;    s/&piv;/ϖ/g;
		s/&#0*8194;/ /g;    s/&#x0*2002;/ /g;   s/&ensp;/ /g;
		s/&#0*8195;/ /g;    s/&#x0*2003;/ /g;   s/&emsp;/ /g;
		s/&#0*8201;/ /g;    s/&#x0*2009;/ /g;   s/&thinsp;/ /g;
		s/&#0*8204;/ /g;    s/&#x0*200C;/ /g;   s/&zwnj;/ /g;
		s/&#0*8205;/ /g;    s/&#x0*200D;/ /g;   s/&zwj;/ /g;
		s/&#0*8206;/ /g;    s/&#x0*200E;/ /g;   s/&lrm;/ /g;
		s/&#0*8207;/ /g;    s/&#x0*200F;/ /g;   s/&rlm;/ /g;
		s/&#0*8211;/–/g;    s/&#x0*2013;/–/g;   s/&ndash;/–/g;
		s/&#0*8212;/—/g;    s/&#x0*2014;/—/g;   s/&mdash;/—/g;
		s/&#0*8216;/‘/g;    s/&#x0*2018;/‘/g;   s/&lsquo;/‘/g;
		s/&#0*8217;/’/g;    s/&#x0*2019;/’/g;   s/&rsquo;/’/g;
		s/&#0*8218;/‚/g;    s/&#x0*201A;/‚/g;   s/&sbquo;/‚/g;
		s/&#0*8220;/“/g;    s/&#x0*201C;/“/g;   s/&ldquo;/“/g;
		s/&#0*8221;/”/g;    s/&#x0*201D;/”/g;   s/&rdquo;/”/g;
		s/&#0*8222;/„/g;    s/&#x0*201E;/„/g;   s/&bdquo;/„/g;
		s/&#0*8224;/†/g;    s/&#x0*2020;/†/g;   s/&dagger;/†/g;
		s/&#0*8225;/‡/g;    s/&#x0*2021;/‡/g;   s/&Dagger;/‡/g;
		s/&#0*8226;/•/g;    s/&#x0*2022;/•/g;   s/&bull;/•/g;
		s/&#0*8230;/…/g;    s/&#x0*2026;/…/g;   s/&hellip;/…/g;
		s/&#0*8240;/‰/g;    s/&#x0*2030;/‰/g;   s/&permil;/‰/g;
		s/&#0*8242;/′/g;    s/&#x0*2032;/′/g;   s/&prime;/′/g;
		s/&#0*8243;/″/g;    s/&#x0*2033;/″/g;   s/&Prime;/″/g;
		s/&#0*8249;/‹/g;    s/&#x0*2039;/‹/g;   s/&lsaquo;/‹/g;
		s/&#0*8250;/›/g;    s/&#x0*203A;/›/g;   s/&rsaquo;/›/g;
		s/&#0*8254;/‾/g;    s/&#x0*203E;/‾/g;   s/&oline;/‾/g;
		s/&#0*8260;/⁄/g;    s/&#x0*2044;/⁄/g;   s/&frasl;/⁄/g;
		s/&#0*8364;/€/g;    s/&#x0*20AC;/€/g;   s/&euro;/€/g;
		s/&#0*8465;/ℑ/g;    s/&#x0*2111;/ℑ/g;   s/&image;/ℑ/g;
		s/&#0*8472;/℘/g;    s/&#x0*2118;/℘/g;   s/&weierp;/℘/g;
		s/&#0*8476;/ℜ/g;    s/&#x0*211C;/ℜ/g;   s/&real;/ℜ/g;
		s/&#0*8482;/™/g;    s/&#x0*2122;/™/g;   s/&trade;/™/g;
		s/&#0*8501;/ℵ/g;    s/&#x0*2135;/ℵ/g;   s/&alefsym;/ℵ/g;
		s/&#0*8592;/←/g;    s/&#x0*2190;/←/g;   s/&larr;/←/g;
		s/&#0*8593;/↑/g;    s/&#x0*2191;/↑/g;   s/&uarr;/↑/g;
		s/&#0*8594;/→/g;    s/&#x0*2192;/→/g;   s/&rarr;/→/g;
		s/&#0*8595;/↓/g;    s/&#x0*2193;/↓/g;   s/&darr;/↓/g;
		s/&#0*8596;/↔/g;    s/&#x0*2194;/↔/g;   s/&harr;/↔/g;
		s/&#0*8629;/↵/g;    s/&#x0*21B5;/↵/g;   s/&crarr;/↵/g;
		s/&#0*8656;/⇐/g;    s/&#x0*21D0;/⇐/g;   s/&lArr;/⇐/g;
		s/&#0*8657;/⇑/g;    s/&#x0*21D1;/⇑/g;   s/&uArr;/⇑/g;
		s/&#0*8658;/⇒/g;    s/&#x0*21D2;/⇒/g;   s/&rArr;/⇒/g;
		s/&#0*8659;/⇓/g;    s/&#x0*21D3;/⇓/g;   s/&dArr;/⇓/g;
		s/&#0*8660;/⇔/g;    s/&#x0*21D4;/⇔/g;   s/&hArr;/⇔/g;
		s/&#0*8704;/∀/g;    s/&#x0*2200;/∀/g;   s/&forall;/∀/g;
		s/&#0*8706;/∂/g;    s/&#x0*2202;/∂/g;   s/&part;/∂/g;
		s/&#0*8707;/∃/g;    s/&#x0*2203;/∃/g;   s/&exist;/∃/g;
		s/&#0*8709;/∅/g;    s/&#x0*2205;/∅/g;   s/&empty;/∅/g;
		s/&#0*8711;/∇/g;    s/&#x0*2207;/∇/g;   s/&nabla;/∇/g;
		s/&#0*8712;/∈/g;    s/&#x0*2208;/∈/g;   s/&isin;/∈/g;
		s/&#0*8713;/∉/g;    s/&#x0*2209;/∉/g;   s/&notin;/∉/g;
		s/&#0*8715;/∋/g;    s/&#x0*220B;/∋/g;   s/&ni;/∋/g;
		s/&#0*8719;/∏/g;    s/&#x0*220F;/∏/g;   s/&prod;/∏/g;
		s/&#0*8721;/∑/g;    s/&#x0*2211;/∑/g;   s/&sum;/∑/g;
		s/&#0*8722;/−/g;    s/&#x0*2212;/−/g;   s/&minus;/−/g;
		s/&#0*8727;/∗/g;    s/&#x0*2217;/∗/g;   s/&lowast;/∗/g;
		s/&#0*8730;/√/g;    s/&#x0*221A;/√/g;   s/&radic;/√/g;
		s/&#0*8733;/∝/g;    s/&#x0*221D;/∝/g;   s/&prop;/∝/g;
		s/&#0*8734;/∞/g;    s/&#x0*221E;/∞/g;   s/&infin;/∞/g;
		s/&#0*8736;/∠/g;    s/&#x0*2220;/∠/g;   s/&ang;/∠/g;
		s/&#0*8743;/∧/g;    s/&#x0*2227;/∧/g;   s/&and;/∧/g;
		s/&#0*8744;/∨/g;    s/&#x0*2228;/∨/g;   s/&or;/∨/g;
		s/&#0*8745;/∩/g;    s/&#x0*2229;/∩/g;   s/&cap;/∩/g;
		s/&#0*8746;/∪/g;    s/&#x0*222A;/∪/g;   s/&cup;/∪/g;
		s/&#0*8747;/∫/g;    s/&#x0*222B;/∫/g;   s/&int;/∫/g;
		s/&#0*8756;/∴/g;    s/&#x0*2234;/∴/g;   s/&there4;/∴/g;
		s/&#0*8764;/∼/g;    s/&#x0*223C;/∼/g;   s/&sim;/∼/g;
		s/&#0*8773;/≅/g;    s/&#x0*2245;/≅/g;   s/&cong;/≅/g;
		s/&#0*8776;/≈/g;    s/&#x0*2248;/≈/g;   s/&asymp;/≈/g;
		s/&#0*8800;/≠/g;    s/&#x0*2260;/≠/g;   s/&ne;/≠/g;
		s/&#0*8801;/≡/g;    s/&#x0*2261;/≡/g;   s/&equiv;/≡/g;
		s/&#0*8804;/≤/g;    s/&#x0*2264;/≤/g;   s/&le;/≤/g;
		s/&#0*8805;/≥/g;    s/&#x0*2265;/≥/g;   s/&ge;/≥/g;
		s/&#0*8834;/⊂/g;    s/&#x0*2282;/⊂/g;   s/&sub;/⊂/g;
		s/&#0*8835;/⊃/g;    s/&#x0*2283;/⊃/g;   s/&sup;/⊃/g;
		s/&#0*8836;/⊄/g;    s/&#x0*2284;/⊄/g;   s/&nsub;/⊄/g;
		s/&#0*8838;/⊆/g;    s/&#x0*2286;/⊆/g;   s/&sube;/⊆/g;
		s/&#0*8839;/⊇/g;    s/&#x0*2287;/⊇/g;   s/&supe;/⊇/g;
		s/&#0*8853;/⊕/g;    s/&#x0*2295;/⊕/g;   s/&oplus;/⊕/g;
		s/&#0*8855;/⊗/g;    s/&#x0*2297;/⊗/g;   s/&otimes;/⊗/g;
		s/&#0*8869;/⊥/g;    s/&#x0*22A5;/⊥/g;   s/&perp;/⊥/g;
		s/&#0*8901;/⋅/g;    s/&#x0*22C5;/⋅/g;   s/&sdot;/⋅/g;
		s/&#0*8968;/⌈/g;    s/&#x0*2308;/⌈/g;   s/&lceil;/⌈/g;
		s/&#0*8969;/⌉/g;    s/&#x0*2309;/⌉/g;   s/&rceil;/⌉/g;
		s/&#0*8970;/⌊/g;    s/&#x0*230A;/⌊/g;   s/&lfloor;/⌊/g;
		s/&#0*8971;/⌋/g;    s/&#x0*230B;/⌋/g;   s/&rfloor;/⌋/g;
		s/&#0*10216;/〈/g;   s/&#x0*27E8;/〈/g;   s/&lang;/〈/g;
		s/&#0*10217;/〉/g;   s/&#x0*27E9;/〉/g;   s/&rang;/〉/g;
		s/&#0*9674;/◊/g;    s/&#x0*25CA;/◊/g;   s/&loz;/◊/g;
		s/&#0*9824;/♠/g;    s/&#x0*2660;/♠/g;   s/&spades;/♠/g;
		s/&#0*9827;/♣/g;    s/&#x0*2663;/♣/g;   s/&clubs;/♣/g;
		s/&#0*9829;/♥/g;    s/&#x0*2665;/♥/g;   s/&hearts;/♥/g;
		s/&#0*9830;/♦/g;    s/&#x0*2666;/♦/g;   s/&diams;/♦/g;
	"

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			--html)
				filtro="$filtro$html";
				shift
			;;
			--xml)
				filtro="$filtro$xml";
				shift
			;;
			*) break ;;
		esac
	done

	# Faz a conversão
	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" | sed "$filtro"
}

# ----------------------------------------------------------------------------
# zzunicode2ascii
# Converte caracteres Unicode (UTF-8) para seus similares ASCII (128).
#
# Uso: zzunicode2ascii [arquivo(s)]
# Ex.: zzunicode2ascii arquivo.txt
#      cat arquivo.txt | zzunicode2ascii
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-06
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zzunicode2ascii ()
{
	zzzz -h unicode2ascii "$1" && return

	# Tentei manter o sentido do caractere original na tradução.
	# Outros preferi manter o original a fazer um tradução dúbia.
	# Aceito sugestões de melhorias! @oreio

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" | sed "

	# Nota: Mesma tabela de dados da zzunescape.

	# s \" \" g
	# s & & g
	# s ' ' g
	# s < < g
	# s > > g
	# s/ / /g
	s ¡ i g
	s ¢ c g
	# s £ £ g
	# s ¤ ¤ g
	s ¥ Y g
	s ¦ | g
	# s § § g
	s ¨ \" g
	s © (C) g
	s ª a g
	s « << g
	# s ¬ ¬ g
	s ­ - g
	s ® (R) g
	s ¯ - g
	# s ° ° g
	s ± +- g
	s ² 2 g
	s ³ 3 g
	s ´ ' g
	s µ u g
	# s ¶ ¶ g
	s · . g
	s ¸ , g
	s ¹ 1 g
	s º o g
	s » >> g
	s ¼ 1/4 g
	s ½ 1/2 g
	s ¾ 3/4 g
	# s ¿ ¿ g
	s À A g
	s Á A g
	s Â A g
	s Ã A g
	s Ä A g
	s Å A g
	s Æ AE g
	s Ç C g
	s È E g
	s É E g
	s Ê E g
	s Ë E g
	s Ì I g
	s Í I g
	s Î I g
	s Ï I g
	s Ð D g
	s Ñ N g
	s Ò O g
	s Ó O g
	s Ô O g
	s Õ O g
	s Ö O g
	s × x g
	s Ø O g
	s Ù U g
	s Ú U g
	s Û U g
	s Ü U g
	s Ý Y g
	s Þ P g
	s ß B g
	s à a g
	s á a g
	s â a g
	s ã a g
	s ä a g
	s å a g
	s æ ae g
	s ç c g
	s è e g
	s é e g
	s ê e g
	s ë e g
	s ì i g
	s í i g
	s î i g
	s ï i g
	s ð d g
	s ñ n g
	s ò o g
	s ó o g
	s ô o g
	s õ o g
	s ö o g
	s ÷ / g
	s ø o g
	s ù u g
	s ú u g
	s û u g
	s ü u g
	s ý y g
	s þ p g
	s ÿ y g
	s Œ OE g
	s œ oe g
	s Š S g
	s š s g
	s Ÿ Y g
	s ƒ f g
	s ˆ ^ g
	s ˜ ~ g
	s Α A g
	s Β B g
	# s Γ Γ g
	# s Δ Δ g
	s Ε E g
	s Ζ Z g
	s Η H g
	# s Θ Θ g
	s Ι I g
	s Κ K g
	# s Λ Λ g
	s Μ M g
	s Ν N g
	# s Ξ Ξ g
	s Ο O g
	# s Π Π g
	s Ρ P g
	# s Σ Σ g
	s Τ T g
	s Υ Y g
	# s Φ Φ g
	s Χ X g
	# s Ψ Ψ g
	# s Ω Ω g
	s α a g
	s β b g
	# s γ γ g
	# s δ δ g
	s ε e g
	# s ζ ζ g
	s η n g
	# s θ θ g
	# s ι ι g
	s κ k g
	# s λ λ g
	s μ u g
	s ν v g
	# s ξ ξ g
	s ο o g
	# s π π g
	s ρ p g
	s ς s g
	# s σ σ g
	s τ t g
	s υ u g
	# s φ φ g
	s χ x g
	# s ψ ψ g
	s ω w g
	# s ϑ ϑ g
	# s ϒ ϒ g
	# s ϖ ϖ g
	s/ / /g
	s/ / /g
	s/ / /g
	s/‌/ /g
	s/‍/ /g
	s/‎/ /g
	s/‏/ /g
	s – - g
	s — - g
	s ‘ ' g
	s ’ ' g
	s ‚ , g
	s “ \" g
	s ” \" g
	s „ \" g
	# s † † g
	# s ‡ ‡ g
	s • * g
	s … ... g
	# s ‰ ‰ g
	s ′ ' g
	s ″ \" g
	s ‹ < g
	s › > g
	s ‾ - g
	s ⁄ / g
	s € E g
	# s ℑ ℑ g
	# s ℘ ℘ g
	s ℜ R g
	s ™ TM g
	# s ℵ ℵ g
	s ← <- g
	# s ↑ ↑ g
	s → -> g
	# s ↓ ↓ g
	s ↔ <-> g
	# s ↵ ↵ g
	s ⇐ <= g
	# s ⇑ ⇑ g
	s ⇒ => g
	# s ⇓ ⇓ g
	s ⇔ <=> g
	# s ∀ ∀ g
	# s ∂ ∂ g
	# s ∃ ∃ g
	# s ∅ ∅ g
	# s ∇ ∇ g
	# s ∈ ∈ g
	# s ∉ ∉ g
	# s ∋ ∋ g
	# s ∏ ∏ g
	# s ∑ ∑ g
	s − - g
	s ∗ * g
	# s √ √ g
	# s ∝ ∝ g
	# s ∞ ∞ g
	# s ∠ ∠ g
	s ∧ ^ g
	s ∨ v g
	# s ∩ ∩ g
	# s ∪ ∪ g
	# s ∫ ∫ g
	# s ∴ ∴ g
	s ∼ ~ g
	s ≅ ~= g
	s ≈ ~~ g
	# s ≠ ≠ g
	# s ≡ ≡ g
	s ≤ <= g
	s ≥ >= g
	# s ⊂ ⊂ g
	# s ⊃ ⊃ g
	# s ⊄ ⊄ g
	# s ⊆ ⊆ g
	# s ⊇ ⊇ g
	s ⊕ (+) g
	s ⊗ (x) g
	# s ⊥ ⊥ g
	s ⋅ . g
	# s ⌈ ⌈ g
	# s ⌉ ⌉ g
	# s ⌊ ⌊ g
	# s ⌋ ⌋ g
	s ⟨ < g
	s ⟩ > g
	s ◊ <> g
	# s ♠ ♠ g
	# s ♣ ♣ g
	s ♥ <3 g
	s ♦ <> g
	"
}

# ----------------------------------------------------------------------------
# zzuniq
# Retira as linhas repetidas, consecutivas ou não.
# Obs.: Não altera a ordem original das linhas, diferente do sort|uniq.
#
# Uso: zzuniq [arquivo(s)]
# Ex.: zzuniq /etc/inittab
#      cat /etc/inittab | zzuniq
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-06-22
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzuniq ()
{
	zzzz -h uniq "$1" && return

	# Nota: as linhas do arquivo são numeradas para guardar a ordem original

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |
		cat -n  |      # Numera as linhas do arquivo
		sort -k2 -u |  # Ordena e remove duplos, ignorando a numeração
		sort -n |      # Restaura a ordem original
		cut -f 2-      # Remove a numeração

	# Versão SED, mais lenta para arquivos grandes, mas só precisa do SED
	# PATT: LINHA ATUAL \n LINHA-1 \n LINHA-2 \n ... \n LINHA #1 \n
	# sed "G ; /^\([^\n]*\)\n\([^\n]*\n\)*\1\n/d ; h ; s/\n.*//" $1
}

# ----------------------------------------------------------------------------
# zzunix2dos
# Converte arquivos texto no formato Unix (LF) para o Windows/DOS (CR+LF).
# Uso: zzunix2dos arquivo(s)
# Ex.: zzunix2dos frases.txt
#      cat arquivo.txt | zzunix2dos
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzunix2dos ()
{
	zzzz -h unix2dos "$1" && return

	local arquivo
	local tmp=$(zztool mktemp unix2dos)
	local control_m=$(printf '\r')  # ^M, CR, \r

	# Sem argumentos, lê/grava em STDIN/STDOUT
	if test $# -eq 0
	then
		sed "s/$control_m*$/$control_m/"

		# Facinho, terminou já
		return
	fi

	# Usuário passou uma lista de arquivos
	# Os arquivos serão sobrescritos, todo cuidado é pouco
	for arquivo
	do
		# O arquivo existe?
		zztool arquivo_legivel "$arquivo" || continue

		# Adiciona um único CR no final de cada linha
		cp "$arquivo" "$tmp" &&
		sed "s/$control_m*$/$control_m/" "$tmp" > "$arquivo"

		# Segurança
		if test $? -ne 0
		then
			zztool erro "Ops, algum erro ocorreu em $arquivo"
			zztool erro "Seu arquivo original está guardado em $tmp"
			return 1
		fi

		echo "Convertido $arquivo"
	done

	# Remove o arquivo temporário
	rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# zzurldecode
# http://en.wikipedia.org/wiki/Percent-encoding
# Decodifica textos no formato %HH, geralmente usados em URLs (%40 → @).
#
# Uso: zzurldecode [texto]
# Ex.: zzurldecode '%73%65%67%72%65%64%6F'
#      echo 'http%3A%2F%2F' | zzurldecode
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2014-03-14
# Versão: 2
# Licença: GPL
# ----------------------------------------------------------------------------
zzurldecode ()
{
	zzzz -h urldecode "$1" && return

	# Converte os %HH para \xHH, que são expandidos pelo printf %b
	printf '%b\n' $(
		zztool multi_stdin "$@" |
		sed 's/%\([0-9A-Fa-f]\{2\}\)/\\x\1/g'
	)

}

# ----------------------------------------------------------------------------
# zzurlencode
# http://en.wikipedia.org/wiki/Percent-encoding
# Codifica o texto como %HH, para ser usado numa URL (a/b → a%2Fb).
# Obs.: Por padrão, letras, números e _.~- não são codificados (RFC 3986)
#
# Opções:
#   -t, --todos  Codifica todos os caracteres, sem exceção
#   -n STRING    Informa caracteres adicionais que não devem ser codificados
#
# Uso: zzurlencode [texto]
# Ex.: zzurlencode http://www            # http%3A%2F%2Fwww
#      zzurlencode -n : http://www       # http:%2F%2Fwww
#      zzurlencode -t http://www         # %68%74%74%70%3A%2F%2F%77%77%77
#      zzurlencode -t -n w/ http://www   # %68%74%74%70%3A//www
#
# Autor: Guilherme Magalhães Gall <gmgall (a) gmail com>
# Desde: 2013-03-19
# Versão: 4
# Licença: GPL
# Requisitos: zzmaiusculas
# ----------------------------------------------------------------------------
zzurlencode ()
{
	zzzz -h urlencode "$1" && return

	local resultado undo

	# RFC 3986, unreserved - Estes nunca devem ser convertidos (exceto se --all)
	local nao_converter='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.~-'

	while test -n "$1"
	do
		case "$1" in
			-t | --todos | -a | --all)
				nao_converter=''
				shift
			;;
			-n)
				if test -z "$2"
				then
					zztool erro 'Faltou informar o valor da opção -n'
					return 1
				fi

				nao_converter="$nao_converter$2"
				shift
				shift
			;;
			--) shift; break;;
			-*) zztool erro "Opção inválida: $1"; return 1;;
			*) break;;
		esac
	done

	# Codifica todos os caracteres, sem exceção
	# foo → %66%6F%6F
	resultado=$(
		if test -n "$1"
		then printf %s "$*"  # texto via argumentos
		else cat -           # texto via STDIN
		fi |
		# Usa o comando od para descobrir o valor hexa de cada caractere.
		# É portável e suporta UTF-8, decompondo cada caractere em seus bytes.
		od -v -A n -t x1 |
		# Converte os números hexa para o formato %HH, sem espaços
		tr -d ' \n\t' |
		sed 's/../%&/g' |
		zzmaiusculas
	)

	# Há caracteres protegidos, que não devem ser convertidos?
	if test -n "$nao_converter"
	then
		# Desfaz a conversão de alguns caracteres (usando magia)
		#
		# Um sed é aplicado no resultado original "desconvertendo"
		# alguns dos %HH de volta para caracteres normais. Mas como
		# fazer isso somente para os caracteres de $nao_converter?
		#
		# É usada a própria zzurlencode para codificar a lista dos
		# protegidos, e um sed formata esse resultado, compondo outro
		# script sed, que será aplicado no resultado original trocando
		# os %HH por \xHH.
		#
		# $ zzurlencode -t -- "ab" | sed 's/%\(..\)/s,&,\\\\x\1,g; /g'
		# s,%61,\\x61,g; s,%62,\\x62,g;
		#
		# Essa string manipulada será mostrada pelo printf %b, que
		# expandirá os \xHH tornando-os caracteres normais novamente.
		# Ufa! :)
		#
		undo=$(zzurlencode -t -- "$nao_converter" | sed 's/%\(..\)/s,&,\\\\x\1,g; /g')
		printf '%b\n' $(echo "$resultado" | sed "$undo")
	else
		printf '%s\n' "$resultado"
	fi
}

# ----------------------------------------------------------------------------
# zzutf8
# Converte o texto para UTF-8, se necessário.
# Obs.: Caso o texto já seja UTF-8, não há conversão.
#
# Uso: zzutf8 [arquivo]
# Ex.: zzutf8 /etc/passwd
#      zzutf8 index-iso.html
#      echo Bênção | zzutf8        # Bênção
#      printf '\341\n' | zzutf8    # á
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2015-03-21
# Versão: 2
# Licença: GPL
# Requisitos: zzencoding
# ----------------------------------------------------------------------------
zzutf8 ()
{
	zzzz -h utf8 "$1" && return

	local encoding
	local tmp=$(zztool mktemp utf8)

	# Guarda o texto de entrada
	zztool file_stdin "$@" > "$tmp"

	# Qual a sua codificação atual?
	encoding=$(zzencoding "$tmp")

	case "$encoding" in

		# Encoding já compatível com UTF-8, nada a fazer
		utf-8 | us-ascii)
			cat "$tmp"
		;;

		# Arquivo vazio ou encoding desconhecido, não mexe
		'')
			cat "$tmp"
		;;

		# Encoding detectado, converte pra UTF-8
		*)
			iconv -f "$encoding" -t utf-8 "$tmp"
		;;
	esac

	rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# zzvdp
# http://vidadeprogramador.com.br
# Mostra o texto das últimas tirinhas de Vida de Programador.
# Se fornecer uma data, mostra a tirinha do dia escolhido.
# Você pode informar a data dd/mm/aaaa ou usar palavras: hoje, (ante)ontem.
# Usando a mesma sintaxe do zzdata
#
# Uso: zzvdp [data [+|- data|número<d|m|a>]]
# Ex.: zzvdp
#      zzvdp anteontem
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-03-25
# Versão: 5
# Licença: GPL
# Requisitos: zzunescape zzdatafmt
# ----------------------------------------------------------------------------
zzvdp ()
{
	zzzz -h vdp "$1" && return

	local url="http://vidadeprogramador.com.br"

	if test -n "$1" && zztool testa_data $(zzdatafmt "$1")
	then
		url="${url}/"$(zzdatafmt -f 'AAAA/MM/DD' $1)
	fi

	$ZZWWWHTML $url | sed -n '/category-tirinhas/,/<\/article>/p' |
	sed -n '/<!-- post title -->/,/<!-- \/post title -->/p;/class="transcription"/,/<\/article>/p' |
	sed 's/<[^>]*>//g;s/^[[:blank:]]*//g' |
	sed '/^ *Camiseta .*/ a \
----------------------------------------------------------------------------' |
	zzunescape --html | uniq
}

# ----------------------------------------------------------------------------
# zzve
# Busca vários indicadores econômicos e financeiros, da Valor Econômico.
# As opções são categorizadas conforme segue:
#
# 1. Indicadores Financeiros
# 2. Índices Macroeconômicos
# 3. Mercado Externo
# 4. Bolsas
# 5. Commodities
#
# Para mais detalhes digite: zzve <número>
#
# moedas       Variações de moedas internacionais
#
# Uso: zzve <opção>
# Ex.: zzve tr         # Tabela de Taxa Referencial, Poupança e TBF.
#      zzve moedas     # Cotações do Dólar, Euro e outras moedas.
#      zzve 3          # Mais detalhes de ajuda sobre "Mercado Externo".
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2013-07-28
# Versão: 3
# Licença: GPL
# Requisitos: zzuniq
# ----------------------------------------------------------------------------
zzve ()
{
	zzzz -h ve "$1" && return

	test -n "$1" || { zztool -e uso ve; return 1; }

	case $1 in
	1)
		echo "Indicadores Financeiros:
	contas ou indicadores              Variação dos indicadores no período
	crédito                            Linhas de crédito
	tr, poupança ou tbf                Taxa Referencial, Poupança e TBF
	custo ou dinheiro                  Custo do dinheiro
	aplicações                         Evolução das aplicações financeiras
	ima ou anbima                      IMA - Índices de Mercado Anbima
	mercado                            Indicadores do mercado
	renda_fixa ou insper               Índice de Renda Fixa Valor/Insper
	futuro                             Mercado futuro
	estoque_cetip                      Estoque CETIP
	volume_cetip                       Volume CETIP
	cetip                              Estoque e Volume CETIP" | expand -t 2
		return
	;;
	2)
		echo "Índices Macroeconômicos:
	atividade                          Atividade econômica
	inflação                           Variação da Inflação
	produção ou investimento           Produção e investimento
	dívida_pública ou pública          Dívida e necessidades de financiamento
	receitas_tributária ou tributária  Principais receitas tributárias
	resultado_fiscal ou fiscal         Resultado fiscal do governo central
	previdenciaria ou previdência      Contribuição previdenciária
	ir_fonte                           IR na fonte
	ir_quota                           Imposto de Renda Pessoa Física" | expand -t 2
		return
	;;
	3)
		echo "Mercado Externo:
	bonus                              Bônus corporativo
	captação                           Captações de recursos no exterior
	juros_externos                     Juros externos
	cds                                Prêmio de risco do CDS
	reservas_internacionais            Reservas internacionais" | expand -t 2
		return
	;;
	4)
		echo "Bolsa Nacional:
	cotações                           Cotações intradia
	investimento                       Investimentos, debêntures e títulos
	direitos                           Direitos e recibos
	imobiliário                        Fundo imobiliário
	vista                              Mercado à vista
	compra                             Opções de compra
	venda                              Opções de venda
	venda_indice                       Opções de venda de índice
	recuperação                        Recuperação judicial

Bolsas Internacionais:
	adr_brasil ou adr                  ADR Brasil
	adr_indices                        ADR - Índices
	bolsas                             Bolsas de valores internacionais" | expand -t 2
		return
	;;
	5)
		echo "Commodities:
	agrícolas                          Indicadores
	óleo_soja                          Óleo de Soja
	farelo ou farelo_soja              Farelo de Soja
	óleo_vegetal                       Óleos Vegetais
	suco_laranja                       Suco de Laranja
	estoque_metais                     Estoques de Metais

	Outro itens em commodities:
		açucar       algodão      arroz              batata
		bezerro      boi          cacau              ovos
		café         cebola       etanol             feijão
		frango       laranja      laticínios         madeira
		madioca      milho        trigo              soja
		suínos ou porcos
		metais       cobre        outros_metais      petróleo" | expand -t 2
		return
	;;
	esac

	local url_base='http://www.valor.com.br/valor-data'
	local fim='Ver tabela completa'
	local url_atual url inicio

	# Índices Financeiros - Créditos e Taxas
	url_atual="${url_base}/indices-financeiros/creditos-e-taxas-referenciais"
	case "$1" in
		contas | indicadores)   inicio='Variação dos indicadores no período'; url=$url_atual;;
		cr[eé]dito)             inicio='Crédito *$'; url=$url_atual;;
		tr | poupan[çc]a | tbf) inicio='Taxa Referencial, Poupança e TBF'; url=$url_atual;;
	esac

	# Índides Financeiros - Mercado
	url_atual="${url_base}/indices-financeiros/indicadores-de-mercado"
	case "$1" in
		custo | dinheiro)                   inicio='Custo do dinheiro'; url=$url_atual;;
		aplica[çc][ãa]o | aplica[çc][oõ]es) inicio='Evolução das aplicações financeiras'; url=$url_atual;;
		ima | anbima)                       inicio='IMA - Índices de Mercado Anbima'; url=$url_atual;;
		mercado)                            inicio='Indicadores do mercado'; url=$url_atual;;
		renda_fixa | insper)                inicio='Índice de Renda Fixa Valor'; url=$url_atual;;
		futuro)                             inicio='Mercado futuro'; url=$url_atual;;
		estoque_cetip)                      inicio='Estoque CETIP'; url=$url_atual;;
		volume_cetip)                       inicio='Volume CETIP'; url=$url_atual;;
		cetip)
			zzve estoque_cetip
			echo
			zzve volume_cetip
			return
		;;
	esac

	# Índices Macroeconômicos - Atividade Econômica
	url_atual="${url_base}/indices-macroeconomicos/atividade-economica"
	case "$1" in
		atividade)                     inicio='Atividade econômica'; url=$url_atual;;
		infla[çc][ãa]o)                inicio='Inflação'; url=$url_atual;;
		produ[çc][ãa]o | investimento) inicio='Produção e investimento'; url=$url_atual;;
	esac

	# Índices Macroeconômicos - Finanças Públicas
	url_atual="${url_base}/indices-macroeconomicos/financas-publicas"
	case "$1" in
		d[íi]vida_p[úu]blica | p[úu]blica)      inicio='Dívida e necessidades de financiamento'; url=$url_atual;;
		receitas_tribut[áa]ria | tribut[áa]ria) inicio='Principais receitas tributárias'; url=$url_atual;;
		resultado_fiscal | fiscal)              inicio='Resultado fiscal do governo central'; url=$url_atual;;
	esac

	# Índice Macroeconômicos - Tributos
	url_atual="${url_base}/indices-macroeconomicos/tributos"
	case "$1" in
		previdenciaria | previd[êe]ncia) inicio='Contribuição previdenciária'; url=$url_atual;;
		ir_fonte)                        inicio='IR na fonte'; url=$url_atual;;
		ir_quota)                        inicio='Imposto de Renda Pessoa Física'; url=$url_atual;;
	esac

	# Commodities - Agrícolas
	url_atual="${url_base}/commodities/agricolas"
	case "$1" in
		agr[íi]colas)         inicio='Indicadores *$'; url=$url_atual;;
		a[çc]ucar)            inicio='Açúcar'; url=$url_atual;;
		algod[ãa]o)           inicio='Algodão'; url=$url_atual;;
		arroz)                inicio='Arroz'; url=$url_atual;;
		batata)               inicio='Batata'; url=$url_atual;;
		bezerro)              inicio='Bezerro'; url=$url_atual;;
		boi)                  inicio='Boi'; url=$url_atual;;
		cacau)                inicio='Cacau'; url=$url_atual;;
		caf[ée])              inicio='Café *$'; url=$url_atual;;
		cebola)               inicio='Cebola'; url=$url_atual;;
		etanol)               inicio='Etanol'; url=$url_atual;;
		farelo | farelo_soja) inicio='Farelo de Soja'; url=$url_atual;;
		[óo]leo_soja)         inicio='Óleo de Soja'; url=$url_atual;;
		feij[ãa]o)            inicio='Feijão'; url=$url_atual;;
		frango)               inicio='Frango'; url=$url_atual;;
		laranja)              inicio='Laranja'; url=$url_atual;;
		latic[íi]nios)        inicio='Laticínios'; url=$url_atual;;
		madeira)              inicio='Madeira'; url=$url_atual;;
		mandioca)             inicio='Mandioca'; url=$url_atual;;
		milho)                inicio='Milho'; url=$url_atual;;
		[óo]leo_vegetal)      inicio='Óleos Vegetais'; url=$url_atual;;
		ovos)                 inicio='Ovos'; url=$url_atual;;
		soja)                 inicio='Soja *$'; url=$url_atual;;
		suco_laranja)         inicio='Suco de Laranja'; url=$url_atual;;
		su[íi]nos | porcos)   inicio='Suínos'; url=$url_atual;;
		trigo)                inicio='Trigo'; url=$url_atual;;
	esac

	# Commodities - Minerais
	url_atual="${url_base}/commodities/minerais"
	case "$1" in
		cobre)          inicio='Cobre'; url=$url_atual;;
		estoque_metais) inicio='Estoques de Metais'; url=$url_atual;;
		metais)         inicio='Metais'; url=$url_atual;;
		outros_metais)  inicio='Outros metais'; url=$url_atual;;
		petr[óo]leo)    inicio='Petróleo'; url=$url_atual;;
	esac

	# Mercado Externo - Captações de Recursos no Exterior
	url_atual="${url_base}/internacional/mercado-externo"
	case "$1" in
		bonus)                   inicio='Bônus corporativo';url=$url_atual;;
		capta[çc][ãa]o)          inicio='Captações de recursos no exterior'; url=$url_atual;;
		juros_externos)          inicio='Juros externos'; url=$url_atual;;
		cds)                     inicio='Prêmio de risco do CDS'; url=$url_atual;;
		reservas_internacionais) inicio='Reservas internacionais'; url=$url_atual;;
	esac

	# Bolsa Nacional
	url_atual="${url_base}/bolsas/nacionais"
	case "$1" in
		cota[cç][oõ]es)    inicio='Cotações intradia';url=$url_atual;;
		investimento)      inicio='Certificados de investimentos, debêntures e outros títulos';url=$url_atual;;
		direitos)          inicio='Direitos e recibos';url=$url_atual;;
		imobili[aá]rio)    inicio='Fundo imobiliário';url=$url_atual;;
		vista)             inicio='Mercado à vista';url=$url_atual;;
		compra)            inicio='Opções de compra';url=$url_atual;;
		venda)             inicio='Opções de venda';url=$url_atual;;
		venda_indice)      inicio='Opções de venda de índice';url=$url_atual;;
		recupera[cç][aã]o) inicio='Recuperação judicial';url=$url_atual;;
	esac

	# Bolsas Internacionais
	url_atual="${url_base}/bolsas/internacionais"
	case "$1" in
		adr_brasil| adr) inicio='ADR Brasil';url=$url_atual;;
		adr_indices)     inicio='ADR - Índices';url=$url_atual;;
		bolsas)          inicio='Bolsas de valores internacionais';url=$url_atual;;
	esac

	# Moedas estrangeiras
	case "$1" in
		moedas)
			inicio='Dólar & Euro'
			fim='Valor'
			url="${url_base}/moedas"
		;;
	esac

	$ZZWWWDUMP "$url" |
		sed -n "/^ *${inicio}/,/^ *${fim}/p" |
		if test "$1" = "investimento"
		then
			zzuniq
		else
			cat -
		fi |
		sed '/^[:space:]*$/d;$d' |
		awk '{
			if ($0 ~ /^ *Fonte/) { print ""; print $0; print ""}
			else {print $0}
		}'
}

# ----------------------------------------------------------------------------
# zzvira
# Vira um texto, de trás pra frente (rev) ou de ponta-cabeça.
# Ideia original de: http://www.revfad.com/flip.html (valeu @andersonrizada)
#
# Uso: zzvira [-X] texto
# Ex.: zzvira Inverte tudo             # odut etrevnI
#      zzvira -X De pernas pro ar      # ɹɐ oɹd sɐuɹǝd ǝp
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2010-05-24
# Versão: 2
# Licença: GPL
# Requisitos: zzsemacento zzminusculas
# ----------------------------------------------------------------------------
zzvira ()
{
	zzzz -h vira "$1" && return

	local rasteira

	if test "$1" = '-X'
	then
		rasteira=1
		shift
	fi

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Vira o texto de trás pra frente (rev)
	sed '
		/\n/!G
		s/\(.\)\(.*\n\)/&\2\1/
		//D
		s/.//' |

	if test -n "$rasteira"
	then
		zzsemacento |
		zzminusculas |
			sed 'y@abcdefghijklmnopqrstuvwxyz._!?(){}<>@ɐqɔpǝɟƃɥıɾʞlɯuodbɹsʇnʌʍxʎz˙‾¡¿)(}{><@' |
			sed "y/'/,/" |
			sed 's/\[/X/g ; s/]/[/g ; s/X/]/g'
	else
		cat -
	fi
}

# ----------------------------------------------------------------------------
# zzwikipedia
# http://www.wikipedia.org
# Procura na Wikipédia, a enciclopédia livre.
# Obs.: Se nenhum idioma for especificado, é utilizado o português.
#
# Idiomas: de (alemão)    eo (esperanto)  es (espanhol)  fr (francês)
#          it (italiano)  ja (japonês)    la (latin)     pt (português)
#
# Uso: zzwikipedia [-idioma] palavra(s)
# Ex.: zzwikipedia sed
#      zzwikipedia Linus Torvalds
#      zzwikipedia -pt Linus Torvalds
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-10-28
# Versão: 4
# Licença: GPL
# ----------------------------------------------------------------------------
zzwikipedia ()
{
	zzzz -h wikipedia "$1" && return

	local url
	local idioma='pt'

	# Se o idioma foi informado, guarda-o, retirando o hífen
	if test "${1#-}" != "$1"
	then
		idioma="${1#-}"
		shift
	fi

	# Verificação dos parâmetros
	test -n "$1" || { zztool -e uso wikipedia; return 1; }

	# Faz a consulta e filtra o resultado, paginando
	url="http://$idioma.wikipedia.org/wiki/"
	$ZZWWWDUMP "$url$(echo "$*" | sed 's/  */_/g')" |
		sed '
			# Limpeza do conteúdo
			/^Views$/,$ d
			/^Vistas$/,$ d
			/^Ferramentas pessoais$/,$ d
			/^.\{0,1\}Ligações externas/,$ d
			/^  *#Wikipedia (/d
			/^  *#alternat/d
			/Click here for more information.$/d
			/^  *#Editar Wikip.dia /d
			/^  *From Wikipedia,/d
			/^  *Origem: Wikipédia,/d
			/^  *Jump to: /d
			/^  *Ir para: /d
			/^  *This article does not cite any references/d
			/^  *Este artigo ou se(c)ção/d
			/^  *Esta página ou secção/d
			/^  *Please help improve this article/d
			/^  *Por favor, melhore este artigo/d
			/^  *—*Encontre fontes: /d
			/\.svg$/d
			/^  *Categorias* ocultas*:/,$d
			/^  *Hidden categories:/,$d
			/^  *Wikipedia does not have an article with this exact name./q
			s/\[edit\]//; s/\[edit[^]]*\]//
			s/\[editar\]//; s/\[editar[^]]*\]//

			# Guarda URL da página e mostra no final, após Categorias
			# Também adiciona linha em branco antes de Categorias
			/^   Obtid[ao] de "/ { H; d; }
			/^   Retrieved from "/ { H; d; }
			/^   Categor[a-z]*: / { G; x; s/.*//; G; }' |
		cat -s
}

# ----------------------------------------------------------------------------
# zzxml
# Parser simples (e limitado) para arquivos XML/HTML.
# Obs.: Este parser é usado pelas Funções ZZ, não serve como parser genérico.
# Obs.: Necessário pois não há ferramenta portável para lidar com XML no Unix.
#
# Opções: --tidy        Reorganiza o código, deixando uma tag por linha
#         --tag NOME    Extrai (grep) todas as tags NOME e seu conteúdo
#         --notag NOME  Exclui (grep -v) todas as tags NOME e seu conteúdo
#         --list        Lista sem repetição as tags existentes no arquivo
#         --indent      Promove a indentação das tags
#         --untag       Remove todas as tags, deixando apenas texto
#         --untag=NOME  Remove apenas a tag NOME, deixando o seu conteúdo
#         --unescape    Converte as entidades &foo; para caracteres normais
# Obs.: --notag tem precedência sobre --tag e --untag.
#       --untag tem precedência sobre --tag.
#
# Uso: zzxml <opções> [arquivo(s)]
# Ex.: zzxml --tidy arquivo.xml
#      zzxml --untag --unescape arq.xml                   # xml -> txt
#      zzxml --untag=item arq.xml                         # Apaga tags "item"
#      zzxml --tag title --untag --unescape arq.xml       # títulos
#      cat arq.xml | zzxml --tag item | zzxml --tag title # aninhado
#      zzxml --tag item --tag title arq.xml               # tags múltiplas
#      zzxml --notag link arq.xml                         # Sem tag e conteúdo
#      zzxml --indent arq.xml                             # tags indentadas
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-03
# Versão: 13
# Licença: GPL
# Requisitos: zzjuntalinhas zzuniq
# ----------------------------------------------------------------------------
zzxml ()
{
	zzzz -h xml "$1" && return

	local tag notag semtag ntag sed_notag
	local tidy=0
	local untag=0
	local unescape=0
	local indent=0
	local cache_tag=$(zztool mktemp xml.tag)
	local cache_notag=$(zztool mktemp xml.notag)

	# Opções de linha de comando
	while test "${1#-}" != "$1"
	do
		case "$1" in
			--tidy    ) shift; tidy=1;;
			--untag   ) shift; untag=1;;
			--unescape) shift; unescape=1;;
			--notag   )
				tidy=1
				shift
				notag="$notag $1"
				shift
			;;
			--tag     )
				tidy=1
				shift
				tag="$tag $1"
				shift
			;;
			--untag=* )
				semtag="$semtag ${1#*=}"
				shift
			;;
			--indent  )
				shift
				tidy=1
				indent=1
			;;
			--list    )
				shift
				zztool file_stdin "$@" |
				# Eliminando comentários ( não deveria existir em arquivos xml! :-/ )
				zzjuntalinhas -i "<!--" -f "-->" | sed '/<!--/d' |
				# Filtrando apenas as tags válidas
				sed '
					# Eliminando texto entre tags
					s/\(>\)[^><]*\(<\)/\1\2/g
					# Eliminando texto antes das tags
					s/^[^<]*//g
					# Eliminado texto depois das tags
					s/[^>]*$//g
					# Eliminando as tags de fechamento
					s|</[^>]*>||g
					# Colocando uma tag por linha
					s/</\
&/g
					# Eliminando < e >
					s/<[?]*//g
					s|[/]*>||g
					# Eliminando os atributos das tags
					s/ .*//g' |
				sed '/^$/d' |
				zzuniq
				return
			;;
			--*       ) zztool erro "Opção inválida $1"; return 1;;
			*         ) break;;
		esac
	done

	# Montando script awk para excluir tags
	if test -n "$notag"
	then
		echo 'BEGIN { notag=0 } {' > $cache_notag
		for ntag in $notag
		do
			echo '
				if ($0 ~ /<'$ntag'[^\/>]* >/) { notag++ }
				if ($0 ~ /<\/'$ntag' >/) { notag--; if (notag==0) { next } }
			' >> $cache_notag
			sed_notag="$sed_notag /<${ntag}[^/>]*\/>/d;"
		done
		echo 'if (notag==0) { nolinha[NR] = $0 } }' >> $cache_notag
	fi

	# Montando script awk para selecionar tags
	if test -n "$tag"
	then
		echo 'BEGIN {' > $cache_tag
		for ntag in $tag
		do
			echo 'tag['$ntag']=0' >> $cache_tag
		done
		echo '} {' >> $cache_tag
		for ntag in $tag
		do
			echo '
				if ($0 ~ /^<'$ntag'[^><]*\/>$/) { linha[NR] = $0 }
				if ($0 ~ /^<'$ntag'[^><]*[^\/><]+>/) { tag['$ntag']++ }
				if (tag['$ntag']>=1) { linha[NR] = $0 }
				if ($0 ~ /^<\/'$ntag' >/) { tag['$ntag']-- }
			' >> $cache_tag
		done
		echo '}' >> $cache_tag
	fi

	# Montando script sed para apagar determinadas tags
	if test -n "$semtag"
	then
		for ntag in $semtag
		do
			sed_notag="$sed_notag s|<[/]\{0,1\}${ntag}[^>]*>||g;"
		done
	fi

	# Caso indent=1 mantém uma tag por linha para possibilitar indentação.
	if test -n "$tag" 
	then
		if test $tidy -eq 0
		then
			echo 'END { for (lin=1;lin<=NR;lin++) { if (lin in linha) printf "%s", linha[lin] } print ""}' >> $cache_tag
		else
			echo 'END { for (lin=1;lin<=NR;lin++) { if (lin in linha) print linha[lin] } }' >> $cache_tag
		fi
	fi
	if test -n "$notag" 
	then
		if test $tidy -eq 0
		then
			echo 'END { for (lin=1;lin<=NR;lin++) { if (lin in nolinha) printf "%s", nolinha[lin] } print ""}' >> $cache_notag
		else
			echo 'END { for (lin=1;lin<=NR;lin++) { if (lin in nolinha) print nolinha[lin] } }' >> $cache_notag
		fi
	fi

	# O código seguinte é um grande filtro, com diversos blocos de comando
	# IF interligados via pipe (logo após o FI). Cada IF pode aplicar um
	# filtro (sed, grep, etc) ao código XML, ou passá-lo adiante inalterado
	# (cat -). Por esta natureza, a ordem dos filtros importa. O tidy deve
	# ser sempre o primeiro, para organizar. O unescape deve ser o último,
	# pois ele pode fazer surgir < e > no código.
	#
	# Essa estrutura toda de IFs interligados é bizarra e não tenho certeza
	# se funciona em versões bem antigas do bash, mas acredito que sim. Fiz
	# assim para evitar ficar lendo e gravando arquivos temporários para
	# cada filtro. Como está, é tudo um grande fluxo de texto, que não usa
	# arquivos externos. Mas se esta função precisar crescer, todo este
	# esquema precisará ser revisto.

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |

	zzjuntalinhas -i "<!--" -f "-->" |

		# --tidy
		if test $tidy -eq 1
		then
			# Deixa somente uma tag por linha.
			# Tags multilinha ficam em somente uma linha.
			# Várias tags em uma mesma linha ficam multilinha.
			# Isso facilita a extração de dados com grep, sed, awk...
			#
			#   ANTES                    DEPOIS
			#   --------------------------------------------------------
			#   <a                       <a href="foo.html" title="Foo">
			#   href="foo.html"
			#   title="Foo">
			#   --------------------------------------------------------
			#   <p>Foo <b>bar</b></p>    <p>
			#                            Foo 
			#                            <b>
			#                            bar
			#                            </b>
			#                            </p>

			zzjuntalinhas -d ' ' |
			sed '
				# quebra linha na abertura da tag
				s/</\
</g
				# quebra linha após fechamento da tag
				s/>/ >\
/g' | sed 's|/ >|/>|g' |
			# Rejunta o conteúdo do <![CDATA[...]]>, que pode ter tags
			zzjuntalinhas -i '^<!\[CDATA\[' -f ']]>$' -d '' |

			# Remove linhas em branco (as que adicionamos)
			sed '/^[[:blank:]]*$/d'
		else
			cat -
		fi |

		# --notag
		# É sempre usada em conjunto com --tidy (automaticamente)
		if test -n "$notag"
		then
			awk -f "$cache_notag"
		else
			cat -
		fi |

		# --notag ou --notag <tag> ou untag=<tag>
		if test -n "$sed_notag"
		then
			sed "$sed_notag"
		else
			cat -
		fi |

		# --tag
		# É sempre usada em conjunto com --tidy (automaticamente)
		if test -n "$tag"
		then
			awk -f "$cache_tag"
		else
			cat -
		fi |

		# --tidy (segunda parte)
		# Eliminando o espaço adicional colocado antes do fechamento da tag.
		if test $tidy -eq 1
		then
			sed 's| >|>|g'
		else
			cat -
		fi |

		# --indent
		# Indentando conforme as tags que aparecem, mantendo alinhamento.
		# É sempre usada em conjunto com --tidy (automaticamente)
		if test $indent -eq 1
		then
			sed '/^<[^/]/s@/@|@g' | sed 's@|>$@/>@g' |
			awk '
				# Para quantificar as tabulações em cada nível.
				function tabs(t,  saida, i) {
					saida = ""
					if (t>0) {
						for (i=1;i<=t;i++) {
							saida="	" saida
						}
					}
					return saida
				}
				BEGIN {
					# Definições iniciais
					ntab = 0
					tag_ini_regex = "^<[^?!/<>]*>$"
					tag_fim_regex = "^</[^/<>]*>$"
				}
				$0 ~ tag_fim_regex { ntab-- }
				{
					# Suprimindo espaços iniciais da linha
					sub(/^[\t ]+/,"")

					# Saindo com a linha formatada
					print tabs(ntab) $0
				}
				$0 ~ tag_ini_regex { ntab++ }
			' |
			sed '/^[[:blank:]]*<[^/]/s@|@/@g'
		else
			cat -
		fi |

		# --untag
		if test $untag -eq 1
		then
			sed '
				# Caso especial: <![CDATA[Foo bar.]]>
				s/<!\[CDATA\[//g
				s/]]>//g

				# Evita linhas vazias inúteis na saída
				/^[[:blank:]]*<[^>]*>[[:blank:]]*$/ d

				# Remove as tags inline
				s/<[^>]*>//g'
		else
			cat -
		fi |

		# --unescape
		if test $unescape -eq 1
		then
			sed "
				s/&quot;/\"/g
				s/&amp;/\&/g
				s/&apos;/'/g
				s/&lt;/</g
				s/&gt;/>/g
				"
		else
			cat -
		fi

	# Limpeza
	rm -f "$cache_tag" "$cache_notag"
}


ZZDIR=

##############################################################################
#
#                             Texto de ajuda
#                             --------------
#
#

# Função temporária para extrair o texto de ajuda do cabeçalho das funções
# Passe o arquivo com as funções como parâmetro
_extrai_ajuda() {
	# Extrai somente os cabeçalhos, já removendo o # do início
	sed -n '/^# -----* *$/, /^# -----* *$/ s/^# \{0,1\}//p' "$1" |
		# Agora remove trechos que não podem aparecer na ajuda
		sed '
			# Apaga a metadata (Autor, Desde, Versao, etc)
			/^Autor:/, /^------/ d

			# Apaga a linha em branco apos Ex.:
			/^Ex\.:/, /^------/ {
				/^ *$/d
			}'
}

# Limpa conteúdo do arquivo de ajuda
> "$ZZAJUDA"

# Salva o texto de ajuda das funções deste arquivo
test -r "$ZZPATH" && _extrai_ajuda "$ZZPATH" >> "$ZZAJUDA"


##############################################################################
#
#                    Carregamento das funções do $ZZDIR
#                    ----------------------------------
#
# O carregamento é feito em dois passos para ficar mais robusto:
# 1. Obtenção da lista completa de funções, ativadas e desativadas.
# 2. Carga de cada função ativada, salvando o texto de ajuda.
#
# Com a opção --tudo-em-um, o passo 2 é alterado para mostrar o conteúdo
# da função em vez de carregá-la.
#

### Passo 1

# Limpa arquivos temporários que guardam as listagens
> "$ZZTMP.on"
> "$ZZTMP.off"

# A pasta das funções existe?
if test -n "$ZZDIR" -a -d "$ZZDIR"
then
	# Melhora a lista off: um por linha, sem prefixo zz
	zz_off=$(echo "$ZZOFF" | zztool list2lines | sed 's/^zz//')

	# Primeiro salva a lista de funções disponíveis
	for zz_arquivo in "${ZZDIR%/}"/zz*
	do
		# Só ativa funções que podem ser lidas
		if test -r "$zz_arquivo"
		then
			zz_nome="${zz_arquivo##*/}"  # remove path
			zz_nome="${zz_nome%.sh}"     # remove extensão

			# O usuário desativou esta função?
			echo "$zz_off" | grep "^${zz_nome#zz}$" >/dev/null ||
				# Tudo certo, essa vai ser carregada
				echo "$zz_nome"
		fi
	done >> "$ZZTMP.on"

	# Lista das funções desativadas (OFF = Todas - ON)
	(
	cd "$ZZDIR" &&
	ls -1 zz* |
		sed 's/\.sh$//' |
		grep -v -f "$ZZTMP.on"
	) >> "$ZZTMP.off"
fi

# echo ON ; cat "$ZZTMP.on"  | zztool lines2list
# echo OFF; cat "$ZZTMP.off" | zztool lines2list
# exit

### Passo 2

# Vamos juntar todas as funções em um único arquivo?
if test "$1" = '--tudo-em-um'
then
	# Verifica se a pasta das funções existe
	if test -z "$ZZDIR" -o ! -d "$ZZDIR"
	then
		(
		echo "Ops! Não encontrei as funções na pasta '$ZZDIR'."
		echo 'Informe a localização correta na variável $ZZDIR.'
		echo
		echo 'Exemplo: export ZZDIR="$HOME/zz"'
		) >&2
		exit 1
		# Posso usar exit porque a chamada é pelo executável, e não source
	fi

	# Primeira metade deste arquivo, até #@
	sed '/^#@$/q' "$ZZPATH"

	# Mostra cada função (ativa), inserindo seu nome na linha 2 do cabeçalho
	while read zz_nome
	do
		zz_arquivo="${ZZDIR%/}"/$zz_nome.sh

		# Suporte legado aos arquivos sem a extensão .sh
		test -r "$zz_arquivo" || zz_arquivo="${zz_arquivo%.sh}"

		sed 1q "$zz_arquivo"
		echo "# $zz_nome"
		sed 1d "$zz_arquivo"

		# Linha em branco separadora
		# Também garante quebra se faltar \n na última linha da função
		echo
	done < "$ZZTMP.on"

	# Desliga suporte ao diretório de funções
	echo
	echo 'ZZDIR='

	# Segunda metade deste arquivo, depois de #@
	sed '1,/^#@$/d' "$ZZPATH"

	# Tá feito, simbora.
	exit 0
fi

# Carregamento das funções ativas, salvando texto de ajuda
while read zz_nome
do
	zz_arquivo="${ZZDIR%/}"/$zz_nome.sh

	# Se o arquivo não existir, tenta encontrá-lo sem a extensao .sh.
	# No futuro este suporte às funções sem extensão pode ser removido.
	if ! test -r "$zz_arquivo"
	then
		if test -r "${zz_arquivo%.sh}"
		then
			# Não achei zzfoo.sh, mas achei o zzfoo
			# Vamos usá-lo então.
			zz_arquivo="${zz_arquivo%.sh}"
		else
			# Não achei zzfoo.sh nem zzfoo
			# Cancelaremos o carregamento desta função.
			continue
		fi
	fi

	# Inclui a função na shell atual
	. "$zz_arquivo"

	# Extrai o texto de ajuda
	_extrai_ajuda "$zz_arquivo" |
		# Insere o nome da função na segunda linha
		sed "2 { h; s/.*/$zz_nome/; G; }"

done < "$ZZTMP.on" >> "$ZZAJUDA"

# Separador final do arquivo, com exatamente 77 hífens (7x11)
echo '-------' | sed 's/.*/&&&&&&&&&&&/' >> "$ZZAJUDA"


# Modo --tudo-em-um
# Todas as funções já foram carregadas por estarem dentro deste arquivo.
# Agora faremos o desligamento "manual" das funções ZZOFF.
#
if test -z "$ZZDIR" -a -n "$ZZOFF"
then

	# Lista de funções a desligar: uma por linha, com prefixo zz, exceto ZZBASE
	zz_off=$(
		echo "$ZZOFF" |
		zztool list2lines |
		sed 's/^zz// ; s/^/zz/' |
		egrep -v "$(echo $ZZBASE | sed 's/ /|/g')"
	)

	# Desliga todas em uma só linha (note que não usei aspas)
	unset $zz_off

	# Agora apaga os textos da ajuda, montando um script em sed e aplicando
	# Veja issue 5 para mais detalhes:
	# https://github.com/funcoeszz/funcoeszz/issues/5
	zz_sed=$(echo "$zz_off" | sed 's@.*@/^&$/,/^----*$/d;@')  # /^zzfoo$/,/^----*$/d
	cp "$ZZAJUDA" "$ZZAJUDA.2" &&
	sed "$zz_sed" "$ZZAJUDA.2" > "$ZZAJUDA"
	rm "$ZZAJUDA.2"
fi


### Carregamento terminado, funções já estão disponíveis

# Limpa variáveis e funções temporárias
# Nota: prefixo zz_ para não conflitar com variáveis da shell atual
unset zz_arquivo
unset zz_nome
unset zz_off
unset zz_sed
unset -f _extrai_ajuda


##----------------------------------------------------------------------------
## Lidando com a chamada pelo executável

# Se há parâmetros, é porque o usuário está nos chamando pela
# linha de comando, e não pelo comando source.
if test -n "$1"
then

	case "$1" in

		# Mostra a tela de ajuda
		-h | --help)

			cat - <<-FIM

				Uso: funcoeszz <função> [<parâmetros>]

				Lista de funções:
				    funcoeszz zzzz
				    funcoeszz zzajuda --lista

				Ajuda:
				    funcoeszz zzajuda
				    funcoeszz zzcores -h
				    funcoeszz zzcalcula -h

				Instalação:
				    funcoeszz zzzz --bashrc
				    source ~/.bashrc
				    zz<TAB><TAB>

				Saiba mais:
				    http://funcoeszz.net

			FIM
		;;

		# Mostra a versão das funções
		-v | --version)
			echo "Funções ZZ v$ZZVERSAO"
		;;

		-*)
			echo "Opção inválida '$1' (tente --help)"
		;;

		# Chama a função informada em $1, caso ela exista
		*)
			zz_func="$1"

			# Garante que a zzzz possa ser chamada por zz somente
			test "$zz_func" = 'zz' && zz_func='zzzz'

			# O prefixo zz é opcional: zzdata e data funcionam
			zz_func="zz${zz_func#zz}"

			# A função existe?
			if type $zz_func >/dev/null 2>&1
			then
				shift
				$zz_func "$@"
			else
				echo "Função inexistente '$zz_func' (tente --help)"
			fi

			unset zz_func
		;;
	esac
fi
