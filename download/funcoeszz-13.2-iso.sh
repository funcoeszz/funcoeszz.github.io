#!/usr/bin/env bash
# funcoeszz
#
# INFORMA��ES: http://www.funcoeszz.net
# NASCIMENTO : 22 de Fevereiro de 2000
# AUTORES    : Aurelio Marinho Jargas <verde (a) aurelio net>
#              Thobias Salazar Trevisan <thobias (a) thobias org>
# DESCRI��O  : Fun��es de uso geral para o shell Bash, que buscam
#              informa��es em arquivos locais e fontes na Internet
# LICEN�A    : GPLv2
# CHANGELOG  : http://www.funcoeszz.net/changelog.html
#
ZZVERSAO=13.2
ZZUTF=0
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
#      $ZZCOR      - Liga/Desliga as mensagens coloridas (1 e 0)
#      $ZZPATH     - Caminho completo para o arquivo principal (funcoeszz)
#      $ZZDIR      - Caminho completo para o diret�rio com as fun��es
#      $ZZTMPDIR   - Diret�rio para armazenar arquivos tempor�rios
#      $ZZOFF      - Lista das fun��es que voc� n�o quer carregar
#
# Nota: Se voc� � paran�ico com seguran�a, configure a ZZTMPDIR para
#       um diret�rio dentro do seu HOME.
#
### Configura��o fixa neste arquivo (hardcoded)
#
# A configura��o tamb�m pode ser feita diretamente neste arquivo, se voc�
# puder fazer altera��es nele.
#
ZZCOR_DFT=1                       # colorir mensagens? 1 liga, 0 desliga
ZZPATH_DFT="/usr/bin/funcoeszz"   # rota absoluta deste arquivo
ZZDIR_DFT="$HOME/zz"              # rota absoluta do diret�rio com as fun��es
ZZTMPDIR_DFT="${TMPDIR:-/tmp}"    # diret�rio tempor�rio
#
#
##############################################################################
#
#                               Inicializa��o
#                               -------------
#
#
# Vari�veis auxiliares usadas pelas Fun��es ZZ.
# N�o altere nada aqui.
#
#

ZZWWWDUMP='lynx -dump      -nolist -width=300 -accept_all_cookies -display_charset=ISO-8859-1'
ZZWWWLIST='lynx -dump              -width=300 -accept_all_cookies -display_charset=ISO-8859-1'
ZZWWWPOST='lynx -post-data -nolist -width=300 -accept_all_cookies -display_charset=ISO-8859-1'
ZZWWWHTML='lynx -source'
ZZCODIGOCOR='36;1'            # use zzcores para ver os c�digos
ZZSEDURL='s| |+|g;s|&|%26|g;s|@|%40|g'
ZZBASE='zzajuda zztool zzzz'  # Fun��es essenciais, guardadas neste script


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
[ "${ZZPATH#/}" = "$ZZPATH" ] && ZZPATH="$PWD/${ZZPATH#./}"

[ "$ZZDIR" ] || ZZDIR=$ZZDIR_DFT
#
### �ltimos ajustes
#
ZZCOR="${ZZCOR:-$ZZCOR_DFT}"
ZZTMP="${ZZTMPDIR:-$ZZTMPDIR_DFT}"
ZZTMP="${ZZTMP%/}/zz"  # prefixo comum a todos os arquivos tempor�rios
ZZAJUDA="$ZZTMP.ajuda"
unset ZZCOR_DFT ZZPATH_DFT ZZDIR_DFT ZZTMPDIR_DFT
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
# Miniferramentas para auxiliar as fun��es.
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
			# Extrai a mensagem de uso da fun��o $1, usando seu --help
			zzzz -h "$1" -h | grep Uso
		;;
		eco)
			# Mostra mensagem colorida caso $ZZCOR esteja ligada
			if [ "$ZZCOR" != '1' ]
			then
				echo -e "$*"
			else
				echo -e "\033[${ZZCODIGOCOR}m$*\033[m"
			fi
		;;
		acha)
			# Destaca o padr�o $1 no texto via STDIN ou $2
			# O padr�o pode ser uma regex no formato BRE (grep/sed)
			local esc=$(printf '\033')
			local padrao=$(echo "$1" | sed 's,/,\\/,g') # escapa /
			shift
			zztool multi_stdin "$@" |
				if [ "$ZZCOR" != '1' ]
				then
					cat -
				else
					sed "s/$padrao/$esc[${ZZCODIGOCOR}m&$esc[m/g"
				fi
		;;
		grep_var)
			# $1 est� presente em $2?
			test "${2#*$1}" != "$2"
		;;
		index_var)
			# $1 est� em qual posi��o em $2?
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
			# Verifica se o nome de arquivo informado est� vago
			if test -e "$1"
			then
				echo "Arquivo $1 j� existe. Abortando."
				return 1
			fi
		;;
		arquivo_legivel)
			# Verifica se o arquivo existe e � leg�vel
			if ! test -r "$1"
			then
				echo "N�o consegui ler o arquivo $1"
				return 1
			fi

			# TODO Usar em *todas* as fun��es que l�em arquivos
		;;
		num_linhas)
			# Informa o n�mero de linhas, sem formata��o
			zztool file_stdin "$@" |
				wc -l |
				tr -d ' \t'
		;;
		testa_ano)
			# Testa se $1 � um ano v�lido: 1-9999
			# O ano zero nunca existiu, foi de -1 para 1
			# Ano maior que 9999 pesa no processamento
			echo "$1" | grep -v '^00*$' | grep '^[0-9]\{1,4\}$' >/dev/null && return 0

			test -n "$erro" && echo "Ano inv�lido '$1'"
			return 1
		;;
		testa_ano_bissexto)
			# Testa se $1 � um ano bissexto
			#
			# A year is a leap year if it is evenly divisible by 4
			# ...but not if it's evenly divisible by 100
			# ...unless it's also evenly divisible by 400
			# http://timeanddate.com
			# http://www.delorie.com/gnu/docs/gcal/gcal_34.html
			# http://en.wikipedia.org/wiki/Leap_year
			#
			local y=$1
			[ $((y%4)) -eq 0 ] && [ $((y%100)) -ne 0 ] || [ $((y%400)) -eq 0 ]
			test $? -eq 0 && return 0

			test -n "$erro" && echo "Ano bissexto inv�lido '$1'"
			return 1
		;;
		testa_numero)
			# Testa se $1 � um n�mero positivo
			echo "$1" | grep '^[0-9]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && echo "N�mero inv�lido '$1'"
			return 1

			# TODO Usar em *todas* as fun��es que recebem n�meros
		;;
		testa_numero_sinal)
			# Testa se $1 � um n�mero (pode ter sinal: -2 +2)
			echo "$1" | grep '^[+-]\{0,1\}[0-9]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && echo "N�mero inv�lido '$1'"
			return 1
		;;
		testa_numero_fracionario)
			# Testa se $1 � um n�mero fracion�rio (1.234 ou 1,234)
			# regex: \d+[,.]\d+
			echo "$1" | grep '^[0-9]\{1,\}[,.][0-9]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && echo "N�mero inv�lido '$1'"
			return 1
		;;
		testa_dinheiro)
			# Testa se $1 � um valor monet�rio (1.234,56 ou 1234,56)
			# regex: (  \d{1,3}(\.\d\d\d)+  |  \d+  ),\d\d
			echo "$1" | grep '^\([0-9]\{1,3\}\(\.[0-9][0-9][0-9]\)\{1,\}\|[0-9]\{1,\}\),[0-9][0-9]$' >/dev/null && return 0

			test -n "$erro" && echo "Valor inv�lido '$1'"
			return 1
		;;
		testa_binario)
			# Testa se $1 � um n�mero bin�rio
			echo "$1" | grep '^[01]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && echo "N�mero bin�rio inv�lido '$1'"
			return 1
		;;
		testa_ip)
			# Testa se $1 � um n�mero IP (nnn.nnn.nnn.nnn)
			local nnn="\([0-9]\{1,2\}\|1[0-9][0-9]\|2[0-4][0-9]\|25[0-5]\)" # 0-255
			echo "$1" | grep "^$nnn\.$nnn\.$nnn\.$nnn$" >/dev/null && return 0

			test -n "$erro" && echo "N�mero IP inv�lido '$1'"
			return 1
		;;
		testa_data)
			# Testa se $1 � uma data (dd/mm/aaaa)
			local d29='\(0[1-9]\|[12][0-9]\)/\(0[1-9]\|1[012]\)'
			local d30='30/\(0[13-9]\|1[012]\)'
			local d31='31/\(0[13578]\|1[02]\)'
			echo "$1" | grep "^\($d29\|$d30\|$d31\)/[0-9]\{1,4\}$" >/dev/null && return 0

			test -n "$erro" && echo "Data inv�lida '$1', deve ser dd/mm/aaaa"
			return 1
		;;
		testa_hora)
			# Testa se $1 � uma hora (hh:mm)
			echo "$1" | grep "^\(0\{0,1\}[0-9]\|1[0-9]\|2[0-3]\):[0-5][0-9]$" >/dev/null && return 0

			test -n "$erro" && echo "Hora inv�lida '$1'"
			return 1
		;;
		multi_stdin)
			# Mostra na tela os argumentos *ou* a STDIN, nesta ordem
			# �til para fun��es/comandos aceitarem dados das duas formas:
			#     echo texto | funcao
			# ou
			#     funcao texto

			if [ "$1" ]
			then
				echo "$*"  # security: always quote to avoid shell expansion
			else
				cat -
			fi
		;;
		file_stdin)
			# Mostra na tela o conte�do dos arquivos *ou* da STDIN, nesta ordem
			# �til para fun��es/comandos aceitarem dados das duas formas:
			#     cat arquivo1 arquivo2 | funcao
			#     cat arquivo1 arquivo2 | funcao -
			# ou
			#     funcao arquivo1 arquivo2
			#
			# Note que o uso de - para indicar STDIN n�o � port�vel, mas esta
			# ferramenta o torna port�vel, pois o cat o suporta no Unix.

			cat "${@:--}"  # Traduzindo: cat $@ ou cat -
		;;
		list2lines)
			# Limpa lista da STDIN e retorna um item por linha
			# Lista: um dois tr�s | um, dois, tr�s | um;dois;tr�s
			sed 's/[;,]/ /g' |
				tr -s '\t ' '  ' |
				tr ' ' '\n' |
				grep .
		;;
		lines2list)
			# Recebe linhas em STDIN e retorna: linha1 linha2 linha3
			# Ignora linhas em branco e remove espa�os desnecess�rios
			grep . |
				tr '\n' ' ' |
				sed 's/^ // ; s/ $//'
		;;
		trim)
			zztool multi_stdin "$@" |
				sed 's/^[[:blank:]]*// ; s/[[:blank:]]*$//'
		;;
		endereco_sed)
			# Formata um texto para ser usado como endere�o no sed.
			# N�meros e $ n�o s�o alterados, resto fica /entre barras/
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
		# Ferramentas inexistentes s�o simplesmente ignoradas
		esac
}


# ----------------------------------------------------------------------------
# zzajuda
# Mostra uma tela de ajuda com explica��o e sintaxe de todas as fun��es.
# Op��es: --lista  lista de todas as fun��es, com sua descri��o
#         --uso    resumo de todas as fun��es, com a sintaxe de uso
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
		echo "Ops! N�o encontrei o texto de ajuda em '$ZZAJUDA'." >&2
		echo "Para recri�-lo basta executar o script 'funcoeszz' sem argumentos." >&2
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
			# Lista de todas as fun��es no formato: nome descri��o
			grep -A2 ^zz "$ZZAJUDA" |
				grep -v ^http |
				sed '
					/^zz/ {
						# Padding: o nome deve ter 15 caracteres
						:pad
						s/^.\{1,14\}$/& /
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
			[ "$PAGER" = 'less' -o "$PAGER" = 'more' ] && zzcor_pager=0

			# Mostra a ajuda de todas as fun��es, paginando
			cat "$ZZAJUDA" |
				ZZCOR=${zzcor_pager:-$ZZCOR} zztool acha 'zz[a-z0-9]\{2,\}' |
				${PAGER:-less -r}
		;;
	esac
}


# ----------------------------------------------------------------------------
# zzzz
# Mostra informa��es sobre as fun��es, como vers�o e localidade.
# Op��es: --atualiza  baixa a vers�o mais nova das fun��es
#         --teste     testa se a codifica��o e os pr�-requisitos est�o OK
#         --bashrc    instala as fun��es no ~/.bashrc
#         --tcshrc    instala as fun��es no ~/.tcshrc
#         --zshrc     instala as fun��es no ~/.zshrc
# Uso: zzzz [--atualiza|--teste|--bashrc|--tcshrc|--zshrc]
# Ex.: zzzz
#      zzzz --teste
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-01-07
# ----------------------------------------------------------------------------
zzzz ()
{
	local nome_func arg_func padrao
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

		# Aten��o: Prepare-se para viajar um pouco que � meio complicado :)
		#
		# Todas as fun��es possuem a op��o -h e --help para mostrar um
		# texto r�pido de ajuda. Normalmente cada fun��o teria que
		# implementar o c�digo para verificar se recebeu uma destas op��es
		# e caso sim, mostrar o texto na tela. Para evitar a repeti��o de
		# c�digo, estas tarefas est�o centralizadas aqui.
		#
		# Chamando a zzzz com a op��o -h seguido do nome de uma fun��o e
		# seu primeiro par�metro recebido, o teste � feito e o texto �
		# mostrado caso necess�rio.
		#
		# Assim cada fun��o s� precisa colocar a seguinte linha no in�cio:
		#
		#     zzzz -h beep "$1" && return
		#
		# Ao ser chamada, a zzzz vai mostrar a ajuda da fun��o zzbeep caso
		# o valor de $1 seja -h ou --help. Se no $1 estiver qualquer outra
		# op��o da zzbeep ou argumento, nada acontece.
		#
		# Com o "&& return" no final, a fun��o zzbeep pode sair imediatamente
		# caso a ajuda tenha sido mostrada (retorno zero), ou continuar seu
		# processamento normal caso contr�rio (retorno um).
		#
		# Se a zzzz -h for chamada sem nenhum outro argumento, � porque o
		# usu�rio quer ver a ajuda da pr�pria zzzz.
		#
		# Nota: Ao inv�s de "beep" literal, poder�amos usar $FUNCNAME, mas
		#       o Bash vers�o 1 n�o possui essa vari�vel.

		-h | --help)

			nome_func=${2#zz}
			arg_func=$3

			# Nenhum argumento, mostre a ajuda da pr�pria zzzz
			if ! [ "$nome_func" ]
			then
				nome_func='zz'
				arg_func='-h'
			fi

			# Se o usu�rio informou a op��o de ajuda, mostre o texto
			if [ "$arg_func" = '-h' -o "$arg_func" = '--help'  ]
			then
				# Um xunxo bonito: filtra a sa�da da zzajuda, mostrando
				# apenas a fun��o informada.
				echo
				ZZCOR=0 zzajuda |
					sed -n "/^zz$nome_func$/,/^----*$/ {
						s/^----*$//
						p
					}" |
					zztool acha zz$nome_func
				return 0
			else

				# Alarme falso, o argumento n�o � nem -h nem --help
				return 1
			fi
		;;

		# Garantia de compatibilidade do -h com o formato antigo (-z):
		# zzzz -z -h zzbeep
		-z)
			zzzz -h "$3" "$2"
		;;

		# Testes de ambiente para garantir o funcionamento das fun��es
		--teste)

			### Todos os comandos necess�rios est�o instalados?

			local comando tipo_comando comandos_faltando
			local comandos='awk- bc cat chmod- clear- cp cpp- cut diff- du- find- fmt grep iconv- lynx mv od- play- ps- rm sed sleep sort tail- tr uniq'

			for comando in $comandos
			do
				# Este � um comando essencial ou opcional?
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
					zztool eco "Comando $tipo_comando '$comando' n�o encontrado"
					comandos_faltando="$comando_faltando $tipo_comando"
				fi
			done

			if [ "$comandos_faltando" ]
			then
				echo
				zztool eco "**Aten��o**"
				if zztool grep_var ESSENCIAL "$comandos_faltando"
				then
					echo 'H� pelo menos um comando essencial faltando.'
					echo 'Voc� precisa instal�-lo para usar as Fun��es ZZ.'
				else
					echo 'A falta de um comando opcional quebra uma �nica fun��o.'
					echo 'Talvez voc� n�o precise instal�-lo.'
				fi
				echo
			fi

			### Tudo certo com a codifica��o do sistema e das ZZ?

			local cod_sistema='ISO-8859-1'
			local cod_funcoeszz='ISO-8859-1'

			printf 'Verificando a codifica��o do sistema... '
			zztool terminal_utf8 && cod_sistema='UTF-8'
			echo "$cod_sistema"

			printf 'Verificando a codifica��o das Fun��es ZZ... '
			test $ZZUTF = 1 && cod_funcoeszz='UTF-8'
			echo "$cod_funcoeszz"

			# Se um dia precisar de um teste direto no arquivo:
			# sed 1d "$ZZPATH" | file - | grep UTF-8

			if test "$cod_sistema" != "$cod_funcoeszz"
			then
				# Deixar sem acentua��o mesmo, pois eles n�o v�o aparecer
				echo
				zztool eco "**Atencao**"
				echo 'Ha uma incompatibilidade de codificacao.'
				echo "Baixe as Funcoes ZZ versao $cod_sistema."
			fi
		;;

		# Baixa a vers�o nova, caso diferente da local
		--atualiza)

			echo 'Procurando a vers�o nova, aguarde.'
			versao_remota=$($ZZWWWDUMP "$url_site/v")
			echo "vers�o local : $ZZVERSAO"
			echo "vers�o remota: $versao_remota"
			echo

			# Aborta caso n�o encontrou a vers�o nova
			[ "$versao_remota" ] || return

			# Compara e faz o download
			if [ "$ZZVERSAO" != "$versao_remota" ]
			then
				# Vamos baixar a vers�o ISO-8859-1?
				[ $ZZUTF != '1' ] && url_exe="${url_exe}-iso"

				echo -n 'Baixando a vers�o nova... '
				$ZZWWWHTML "$url_exe" > "funcoeszz-$versao_remota"
				echo 'PRONTO!'
				echo "Arquivo 'funcoeszz-$versao_remota' baixado, instale-o manualmente."
				echo "O caminho atual � $ZZPATH"
			else
				echo 'Voc� j� est� com a vers�o mais recente.'
			fi
		;;

		# Instala as fun��es no arquivo .bashrc
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
				echo "As Fun��es ZZ foram instaladas no $bashrc"
			else
				echo "Nada a fazer. As Fun��es ZZ j� est�o no $bashrc"
			fi
		;;

		# Cria aliases para as fun��es no arquivo .tcshrc
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
				echo "As Fun��es ZZ foram instaladas no $tcshrc"
			else
				echo "Nada a fazer. As Fun��es ZZ j� est�o no $tcshrc"
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

		# Cria aliases para as fun��es no arquivo .zshrc
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
				echo "As Fun��es ZZ foram instaladas no $zshrc"
			else
				echo "Nada a fazer. As Fun��es ZZ j� est�o no $zshrc"
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

		# Mostra informa��es sobre as fun��es
		*)
			# As fun��es est�o configuradas para usar cores?
			[ "$ZZCOR" = '1' ] && info_cor='sim' || info_cor='n�o'

			# A codifica��o do arquivo das fun��es � UTF-8?
			[ "$ZZUTF" = 1 ] && info_utf8='UTF-8' || info_utf8='ISO-8859-1'

			# As fun��es est�o instaladas no bashrc?
			if grep "^[^#]*${ZZPATH:-zzpath_vazia}" "$bashrc" >/dev/null 2>&1
			then
				info_instalado="$bashrc"
			else
				info_instalado='n�o instalado'
			fi

			# As fun��es est�o instaladas no zshrc?
			if grep "^[^#]*${ZZPATH:-zzpath_vazia}" "$zshrc" >/dev/null 2>&1
			then
				info_instalado_zsh="$zshrc"
			else
				info_instalado_zsh='n�o instalado'
			fi

			# Formata fun��es essenciais
			info_base=$(echo $ZZBASE | sed 's/ /, /g')

			# Informa��es, uma por linha
			zztool acha '^[^)]*)' "(script) $ZZPATH"
			zztool acha '^[^)]*)' "( pasta) $ZZDIR"
			zztool acha '^[^)]*)' "(vers�o) $ZZVERSAO ($info_utf8)"
			zztool acha '^[^)]*)' "( cores) $info_cor"
			zztool acha '^[^)]*)' "(   tmp) $ZZTMP"
			zztool acha '^[^)]*)' "(bashrc) $info_instalado"
			zztool acha '^[^)]*)' "( zshrc) $info_instalado_zsh"
			zztool acha '^[^)]*)' "(  base) $info_base"
			zztool acha '^[^)]*)' "(  site) $url_site"

			# Lista de todas as fun��es

			# Sem $ZZDIR, provavelmente usando --tudo-em-um
			# Tentarei obter a lista de fun��es carregadas na shell atual
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
				zztool eco "(( $n_on fun��es dispon�veis ))"
				cat "$ZZTMP.on" |
					sed 's/^zz//' |
					zztool lines2list |
					sed 's/ /, /g' |
					fmt -w 70
			else
				echo
				echo "N�o consegui obter a lista de fun��es dispon�veis."
				echo "Para recri�-la basta executar o script 'funcoeszz' sem argumentos."
			fi

			# S� mostra se encontrar o arquivo...
			if test -r "$ZZTMP.off"
			then
				# ...e se ele tiver ao menos uma zz
				grep zz "$ZZTMP.off" >/dev/null || return

				echo
				n_off=$(zztool num_linhas "$ZZTMP.off")
				zztool eco "(( $n_off fun��es desativadas ))"
				cat "$ZZTMP.off" |
					sed 's/^zz//' |
					zztool lines2list |
					sed 's/ /, /g' |
					fmt -w 70
			else
				echo
				echo "N�o consegui obter a lista de fun��es desativadas."
				echo "Para recri�-la basta executar o script 'funcoeszz' sem argumentos."
			fi
		;;
	esac
}

# A linha seguinte � usada pela op��o --tudo-em-um
#@
# ----------------------------------------------------------------------------
# zzalfabeto
# Central de alfabetos (romano, militar, radiotelef�nico, OTAN, RAF, etc).
# Obs.: Sem argumentos mostra a tabela completa, sen�o traduz uma palavra.
#
# Tipos reconhecidos:
#
#    --militar | --radio | --fone | --otan | --icao | --ansi
#                            Alfabeto radiotelef�nico internacional
#    --romano | --latino     A B C D E F...
#    --royal-navy            Marinha Real - Reino Unido, 1914-1918
#    --signalese             Primeira Guerra, 1914-1918
#    --raf24                 For�a A�rea Real - Reino Unido, 1924-1942
#    --raf42                 For�a A�rea Real - Reino Unido, 1942-1943
#    --raf                   For�a A�rea Real - Reino Unido, 1943-1956
#    --us                    Alfabeto militar norte-americano, 1941-1956
#    --portugal              Lugares de Portugal
#    --names                 Nomes de pessoas, em ingl�s
#    --lapd                  Pol�cia de Los Angeles (EUA)
#    --morse                 C�digo Morse
#
# Uso: zzalfabeto [--TIPO] [palavra]
# Ex.: zzalfabeto --militar
#      zzalfabeto --militar cambio
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-07-23
# Vers�o: 2
# Licen�a: GPL
# Requisitos: zzmaiusculas
# ----------------------------------------------------------------------------
zzalfabeto ()
{
	zzzz -h alfabeto "$1" && return

	local char letra

	local coluna=1
	local dados="\
A:Alpha:Apples:Ack:Ace:Apple:Able/Affirm:Able:Aveiro:Alan:Adam:.-
B:Bravo:Butter:Beer:Beer:Beer:Baker:Baker:Bragan�a:Bobby:Boy:-...
C:Charlie:Charlie:Charlie:Charlie:Charlie:Charlie:Charlie:Coimbra:Charlie:Charles:-.-.
D:Delta:Duff:Don:Don:Dog:Dog:Dog:Dafundo:David:David:-..
E:Echo:Edward:Edward:Edward:Edward:Easy:Easy:�vora:Edward:Edward:.
F:Foxtrot:Freddy:Freddie:Freddie:Freddy:Fox:Fox:Faro:Frederick:Frank:..-.
G:Golf:George:Gee:George:George:George:George:Guarda:George:George:--.
H:Hotel:Harry:Harry:Harry:Harry:How:How:Horta:Howard:Henry:....
I:India:Ink:Ink:Ink:In:Item/Interrogatory:Item:It�lia:Isaac:Ida:..
J:Juliet:Johnnie:Johnnie:Johnnie:Jug/Johnny:Jig/Johnny:Jig:Jos�:James:John:.---
K:Kilo:King:King:King:King:King:King:Kilograma:Kevin:King:-.-
L:Lima:London:London:London:Love:Love:Love:Lisboa:Larry:Lincoln:.-..
M:Mike:Monkey:Emma:Monkey:Mother:Mike:Mike:Maria:Michael:Mary:--
N:November:Nuts:Nuts:Nuts:Nuts:Nab/Negat:Nan:Nazar�:Nicholas:Nora:-.
O:Oscar:Orange:Oranges:Orange:Orange:Oboe:Oboe:Ovar:Oscar:Ocean:---
P:Papa:Pudding:Pip:Pip:Peter:Peter/Prep:Peter:Porto:Peter:Paul:.--.
Q:Quebec:Queenie:Queen:Queen:Queen:Queen:Queen:Queluz:Quincy:Queen:--.-
R:Romeo:Robert:Robert:Robert:Roger/Robert:Roger:Roger:Rossio:Robert:Robert:.-.
S:Sierra:Sugar:Esses:Sugar:Sugar:Sugar:Sugar:Set�bal:Stephen:Sam:...
T:Tango:Tommy:Toc:Toc:Tommy:Tare:Tare:Tavira:Trevor:Tom:-
U:Uniform:Uncle:Uncle:Uncle:Uncle:Uncle:Uncle:Unidade:Ulysses:Union:..-
V:Victor:Vinegar:Vic:Vic:Vic:Victor:Victor:Viseu:Vincent:Victor:...-
W:Whiskey:Willie:William:William:William:William:William:Washington:William:William:.--
X:X-ray/Xadrez:Xerxes:X-ray:X-ray:X-ray:X-ray:X-ray:Xavier:Xavier:X-ray:-..-
Y:Yankee:Yellow:Yorker:Yorker:Yoke/Yorker:Yoke:Yoke:York:Yaakov:Young:-.--
Z:Zulu:Zebra:Zebra:Zebra:Zebra:Zebra:Zebra:Zulmira:Zebedee:Zebra:--.."

	# Escolhe o alfabeto a ser utilizado
	case "$1" in
		--militar|--radio|--fone|--telefone|--otan|--nato|--icao|--itu|--imo|--faa|--ansi)
			coluna=2 ; shift ;;
		--romano|--latino           ) coluna=1  ; shift ;;
		--royal|--royal-navy        ) coluna=3  ; shift ;;
		--signalese|--western-front ) coluna=4  ; shift ;;
		--raf24                     ) coluna=5  ; shift ;;
		--raf42                     ) coluna=6  ; shift ;;
		--raf43|--raf               ) coluna=7  ; shift ;;
		--us41|--us                 ) coluna=8  ; shift ;;
		--pt|--portugal             ) coluna=9  ; shift ;;
		--name|--names              ) coluna=10 ; shift ;;
		--lapd                      ) coluna=11 ; shift ;;
		--morse                     ) coluna=12 ; shift ;;
	esac

	if test "$1"
	then
		# Texto informado, vamos fazer a convers�o
		# Deixa uma letra por linha e procura seu c�digo equivalente
		echo "$*" |
			zzmaiusculas |
			sed 's/./&\
				/g' |
			while read char
			do
				letra=$(echo "$char" | sed 's/[^A-Z]//g')
				if test "$letra"
				then
					echo "$dados" | grep "^$letra" | cut -d : -f $coluna
				else
					echo "$char"
				fi
			done
	else
		# Apenas mostre a tabela
		echo "$dados" | cut -d : -f $coluna
	fi
}

# ----------------------------------------------------------------------------
# zzansi2html
# Converte para HTML o texto colorido do terminal (c�digos ANSI).
# �til para mostrar a sa�da do terminal em sites e blogs, sem perder as cores.
# Obs.: Exemplos de texto ANSI est�o na sa�da das fun��es zzcores e zzecho.
# Obs.: Use o comando script para guardar a sa�da do terminal em um arquivo.
# Uso: zzansi2html [arquivo]
# Ex.: zzecho --letra verde -s -p -N testando | zzansi2html
#      ls --color /etc | zzansi2html > ls.html
#      zzcores | zzansi2html > cores.html
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-09-02
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzansi2html ()
{
	zzzz -h ansi2html "$1" && return

	local esc=$(printf '\033')

	# Um �nico sed toma conta de toda a tarefa de convers�o.
	#
	# Esta fun��o cria um SPAN dentro do outro, sem fechar, pois os c�digos ANSI
	# s�o cumulativos: abrir um novo n�o desliga os anteriores.
	#    echo -e '\e[4mFOO\e[33mBAR'  # BAR � amarelo *e* sublinhado
	#
	# No CSS, o text-decoration � cumulativo para sub-elementos (FF, Safari), veja:
	# <span style=text-decoration:underline>FOO<span style=text-decoration:none>BAR
	# O BAR tamb�m vai aparecer sublinhado, o 'none' no SPAN filho n�o o desliga.
	# Por isso � preciso uma outra t�tica para desligar sublinhado e blink.
	#
	# Uma alternativa seria fechar todos os SPANs no ^[0m, mas � dif�cil no sed
	# saber quantos SPANs est�o abertos (multilinha). A solu��o foi usar DIVs,
	# que ao serem fechados desligam todos os SPANs anteriores.
	#    ^[0m  -->  </div><div style="display:inline">
	#

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |
	sed "
		# Engloba o c�digo na tag PRE para preservar espa�os
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

			# Isola os n�meros (ex: 33;41;1) da *primeira* ocorr�ncia
			s/\($esc\[[0-9;]*\)m.*/\1/
			s/.*$esc\[\([0-9;]*\)$/\1/

			# Se vazio (^[m) vira zero
			s/^$/0/

			# Adiciona separadores no in�cio e fim
			s/.*/;&;/

			# Zero limpa todos os atributos
			#
			# XXX
			# Note que 33;0;4 (amarelo, reset, sublinhado) vira reset,
			# mas deveria ser reset+sublinhado. � um caso dif�cil de
			# encontrar, ent�o vamos conviver com essa limita��o.
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

			# Define a formata��o
			s/;1;/;font-weight:bold;/g
			s/;4;/;text-decoration:underline;/g
			s/;5;/;text-decoration:blink;/g

			# For�a remo��o da formata��o, caso n�o especificado
			/font-weight/! s/$/;font-weight:normal/
			/text-decoration/! s/$/;text-decoration:none/

			# Remove c�digos de texto reverso
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

			# Troca o c�digo ANSI pela tag SPAN
			s/$esc\[[0-9;]*m\(.*\)\n\(.*\)/\2\1/

			# E come�a tudo de novo, at� acabar todos da linha
			b ini
		}
	"
}

# ----------------------------------------------------------------------------
# zzarrumacidade
# Arruma o nome da cidade informada: mai�sculas, abrevia��es, acentos, etc.
#
# Uso: zzarrumacidade [cidade]
# Ex.: zzarrumacidade SAO PAULO                     # S�o Paulo
#      zzarrumacidade rj                            # Rio de Janeiro
#      zzarrumacidade Floripa                       # Florian�polis
#      echo Floripa | zzarrumacidade                # Florian�polis
#      cat cidades.txt | zzarrumacidade             # [uma cidade por linha]
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-21
# Vers�o: 3
# Licen�a: GPL
# Requisitos: zzcapitalize
# ----------------------------------------------------------------------------
zzarrumacidade ()
{
	zzzz -h arrumacidade "$1" && return

	# 1. Texto via STDIN ou argumentos
	# 2. Deixa todas as iniciais em mai�sculas
	# 3. sed m�gico�
	zztool multi_stdin "$@" | zzcapitalize | sed "

		# Volta algumas iniciais para min�sculas
		s/ E / e /g
		s/ De / de /g
		s/ Da / da /g
		s/ Do / do /g
		s/ Das / das /g
		s/ Dos / dos /g

		# Expande abrevia��es comuns
		s/^Sp$/S�o Paulo/
		s/^Rj$/Rio de Janeiro/
		s/^Bh$/Belo Horizonte/
		s/^Bsb$/Bras�lia/
		s/^Rio$/Rio de Janeiro/
		s/^Sampa$/S�o Paulo/
		s/^Floripa$/Florian�polis/
		# s/^Poa$/Porto Alegre/  # Perigoso, pois existe: Po� - SP


		### Restaura acentua��o de maneira pontual:

		# Restaura acentua��o �s capitais
		s/^Belem$/Bel�m/
		s/^Brasilia$/Bras�lia/
		s/^Cuiaba$/Cuiab�/
		s/^Florianopolis$/Florian�polis/
		s/^Goiania$/Goi�nia/
		s/^Joao Pessoa$/Jo�o Pessoa/
		s/^Macapa$/Macap�/
		s/^Maceio$/Macei�/
		s/^S[�a]o Lu[i�][sz]$/S�o Lu�s/
		s/^Vitoria$/Vit�ria/

		# Muitas cidades emprestam o nome do estado
		#   Santana do Piau�
		#   Teresina de Goi�s
		#   Pontal do Paran�
		# ent�o � �til acentuar os nomes de estados.
		#
		s/Amapa$/Amap�/
		s/Ceara$/Cear�/
		s/Goias$/Goi�s/
		s/Maranhao$/Maranh�o/
		s/Para$/Par�/
		s/Paraiba$/Para�ba/
		s/Parana$/Paran�/
		s/Piaui$/Piau�/
		s/Rondonia$/Rond�nia/

		# O nome de alguns estados pode aparecer no in�cio/meio
		#   Para�ba do Sul
		#   Par� de Minas
		#
		s/Amapa /Amap� /
		s/Espirito /Esp�rito /
		s/Para /Par� /
		s/Paraiba /Para�ba /


		### Restaura acentua��o de maneira gen�rica:
		
		# Uberl�ndia, Rol�ndia
		s/landia /l�ndia /g
		s/landia$/l�ndia/
		
		# Florian�polis, Virgin�polis
		s/opolis /�polis /g
		s/opolis$/�polis/
		
		# Palavras terminadas em 'ao' viram '�o'.
		# Exemplos: S�o, Jo�o, Ribeir�o, Cap�o
		#
		# N�o achei nenhum caso de cidade com 'ao' no final:
		#   $ zzcidade 'ao '
		#   $
		#
		# Exce��o: duas cidades com a�:
		#   $ zzcidade 'a� '
		#   Alto Capara� (MG)
		#   Capara� (MG)
		#   $
		#
		# Exce��o da exce��o: algum Capar�o?
		#   $ zzcidade Capar�o
		#   $
		#
		# Ent�o resolvida a exce��o Capara�, � seguro fazer a troca.
		#
		s/Caparao$/Capara�/
		s/ao /�o /g
		s/ao$/�o/


		### Exce��es pontuais:

		# Morro Cabe�a no Tempo
		s/ No / no /g

		# Passa-e-Fica
		s/-E-/-e-/g

		# S�o Jo�o del-Rei
		s/ Del-Rei/ del-Rei/g

		# Xangri-l�: Wikip�dia
		# Xangri-L�: http://www.xangrila.rs.gov.br
		# ** Vou ignorar a Wikip�dia, n�o precisa arrumar este

		# Nomes de Papas
		s/^Pedro Ii$/Pedro II/
		s/^Pio Ix$/Pio IX/
		s/^Pio Xii$/Pio XII/

		# Estrela d'Oeste
		# S�tio d'Abadia
		# Dias d'�vila
		# 
		s/ D'/ d'/g

		# S�o Jo�o do Pau-d'Alho
		# Olhos-d'�gua
		# Pau-d'Arco
		# 
		s/-D'/-d'/g
	"
}

# ----------------------------------------------------------------------------
# zzarrumanome
# Renomeia arquivos do diret�rio atual, arrumando nomes estranhos.
# Obs.: Ele deixa tudo em min�sculas, retira acentua��o e troca espa�os em
#       branco, s�mbolos e pontua��o pelo sublinhado _.
# Op��es: -n  apenas mostra o que ser� feito, n�o executa
#         -d  tamb�m renomeia diret�rios
#         -r  funcionamento recursivo (entra nos diret�rios)
# Uso: zzarrumanome [-n] [-d] [-r] arquivo(s)
# Ex.: zzarrumanome *
#      zzarrumanome -n -d -r .                   # tire o -n para renomear!
#      zzarrumanome "DOCUMENTO MAL�O!.DOC"       # fica documento_malao.doc
#      zzarrumanome "RAMONES - Don't Go.mp3"     # fica ramones-dont_go.mp3
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-07-23
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzarrumanome zzminusculas
# ----------------------------------------------------------------------------
zzarrumanome ()
{
	zzzz -h arrumanome "$1" && return

	local arquivo caminho antigo novo recursivo pastas nao i

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			-d) pastas=1    ;;
			-r) recursivo=1 ;;
			-n) nao="[-n] " ;;
			* ) break       ;;
		esac
		shift
	done

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso arrumanome; return 1; }

	# Para cada arquivo que o usu�rio informou...
	for arquivo
	do
		# Tira a barra no final do nome da pasta
		[ "$arquivo" != / ] && arquivo=${arquivo%/}

		# Ignora arquivos e pastas n�o existentes
		[ -f "$arquivo" -o -d "$arquivo" ] || continue

		# Se for uma pasta...
		if test -d "$arquivo"
		then
			# Arruma arquivos de dentro dela (-r)
			[ "${recursivo:-0}" -eq 1 ] &&
				zzarrumanome -r ${pastas:+-d} ${nao:+-n} "$arquivo"/*

			# N�o renomeia nome da pasta (se n�o tiver -d)
			[ "${pastas:-0}" -ne 1 ] && continue
		fi

		# A pasta vai ser a corrente ou o 'dirname' do arquivo (se tiver)
		caminho='.'
		zztool grep_var / "$arquivo" && caminho="${arquivo%/*}"

		# $antigo � o arquivo sem path (basename)
		antigo="${arquivo##*/}"

		# $novo � o nome arrumado com a magia negra no Sed
		novo=$(
			echo "$antigo" |
			tr -s '\t ' ' ' |  # Squeeze: TABs e espa�os viram um espa�o
			zzminusculas |
			sed -e "
				# Remove aspas
				s/[\"']//g

				# Remove espa�os do in�cio e do fim
				s/^  *//
				s/  *$//

				# Remove acentos
				y/�����������������������/aaaaaaeeeeiiiiooooouuuu/
				y/��ߢУ����������/cnbcdloosuyyy123/

				# Qualquer caractere estranho vira sublinhado
				s/[^a-z0-9._-]/_/g

				# Remove sublinhados consecutivos
				s/__*/_/g

				# Remove sublinhados antes e depois de pontos e h�fens
				s/_\([.-]\)/\1/g
				s/\([.-]\)_/\1/g

				# H�fens no in�cio do nome s�o proibidos
				s/^-/_/

				# N�o permite nomes vazios
				s/^$/_/"
		)

		# Se der problema com a codifica��o, � o y/// do Sed anterior quem estoura
		if [ $? -ne 0 ]
		then
			echo "Ops. Problemas com a codifica��o dos caracteres."
			echo "O arquivo original foi preservado: $arquivo"
			return 1
		fi

		# Nada mudou, ent�o o nome atual j� certo
		[ "$antigo" = "$novo" ] && continue

		# Se j� existir um arquivo/pasta com este nome, vai
		# colocando um n�mero no final, at� o nome ser �nico.
		if test -e "$caminho/$novo"
		then
			i=1
			while test -e "$caminho/$novo.$i"
			do
				i=$((i+1))
			done
			novo="$novo.$i"
		fi

		# Tudo certo, temos um nome novo e �nico

		# Mostra o que ser� feito
		echo "$nao$arquivo -> $caminho/$novo"

		# E faz
		[ "$nao" ] || mv -- "$arquivo" "$caminho/$novo"
	done
}

# ----------------------------------------------------------------------------
# zzascii
# Mostra a tabela ASCII com todos os caracteres imprim�veis (32-126,161-255).
# O formato utilizando �: <decimal> <hexa> <octal> <ascii>.
# O n�mero de colunas e a largura da tabela s�o configur�veis.
# Uso: zzascii [colunas] [largura]
# Ex.: zzascii
#      zzascii 4
#      zzascii 7 100
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-12-06
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzseq
# ----------------------------------------------------------------------------
zzascii ()
{
	zzzz -h ascii "$1" && return

	local referencias decimais decimal hexa octal caractere
	local num_colunas="${1:-5}"
	local largura="${2:-78}"
	local max_colunas=20
	local max_largura=500
	local linha=0

	# Verifica��es b�sicas
	if (
		! zztool testa_numero "$num_colunas" ||
		! zztool testa_numero "$largura" ||
		test "$num_colunas" -eq 0 ||
		test "$largura" -eq 0)
	then
		zztool uso ascii
		return 1
	fi
	if test $num_colunas -gt $max_colunas
	then
		echo "O n�mero m�ximo de colunas � $max_colunas"
		return 1
	fi
	if test $largura -gt $max_largura
	then
		echo "A largura m�xima � de $max_largura"
		return 1
	fi

	# Estamos em um terminal UTF-8?
	if zztool terminal_utf8
	then
		decimais=$(zzseq 32 126)
	else
		# Se o sistema for ISO-8859-1, mostra a tabela extendida,
		# com caracteres acentuados
		decimais=$(zzseq 32 126 ; zzseq 161 255)
	fi

	# C�lculos das dimens�es da tabela
	local colunas=$(zzseq 0 $((num_colunas - 1)))
	local largura_coluna=$((largura / num_colunas))
	local num_caracteres=$(echo "$decimais" | sed -n '$=')
	local num_linhas=$((num_caracteres / num_colunas + 1))

	# Mostra as dimens�es
	echo $num_caracteres caracteres, $num_colunas colunas, $num_linhas linhas, $largura de largura

	# Linha a linha...
	while [ $linha -lt $num_linhas ]
	do
		linha=$((linha+1))

		# Extrai as refer�ncias (n�mero da linha dentro do $decimais)
		# para cada caractere que ser� mostrado nesta linha da tabela.
		# � montado um comando Sed com eles: 5p; 10p; 13p;
		referencias=''
		for col in $colunas
		do
			referencias="$referencias $((num_linhas * col + linha))p;"
		done

		# Usando as refer�ncias coletadas, percorre cada decimal
		# que ser� usado nesta linha da tabela
		for decimal in $(echo "$decimais" | sed -n "$referencias")
		do
			hexa=$( printf '%X'   $decimal)
			octal=$(printf '%03o' $decimal) # NNN
			caractere=$(printf "\x$hexa")

			# Mostra a c�lula atual da tabela
			printf "%${largura_coluna}s" "$decimal $hexa $octal $caractere"
		done
		echo
	done
}

# ----------------------------------------------------------------------------
# zzbeep
# Aguarda N minutos e dispara uma sirene usando o 'speaker'.
# �til para lembrar de eventos pr�ximos no mesmo dia.
# Sem argumentos, restaura o 'beep' para o seu tom e dura��o originais.
# Obs.: A sirene tem 4 toques, sendo 2 tons no modo texto e apenas 1 no Xterm.
# Uso: zzbeep [n�meros]
# Ex.: zzbeep 0
#      zzbeep 1 5 15    # espere 1 minuto, depois mais 5, e depois 15
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-04-24
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzbeep ()
{
	zzzz -h beep "$1" && return

	local minutos frequencia

	# Sem argumentos, apenas restaura a "configura��o de f�brica" do beep
	[ "$1" ] || {
		printf '\033[10;750]\033[11;100]\a'
		return 0
	}

	# Para cada quantidade informada pelo usu�rio...
	for minutos in $*
	do
		# Aguarda o tempo necess�rio
		echo -n "Vou bipar em $minutos minutos... "
		sleep $((minutos*60))

		# Ajusta o beep para toque longo (Linux modo texto)
		printf '\033[11;900]'

		# Alterna entre duas freq��ncias, simulando uma sirene (Linux)
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
# Com um n�mero como argumento indica o bicho e o grupo.
# Se o for um n�mero entre 1 e 25 seguido de "g", lista os n�meros do grupo.
# Sem argumento ou com apenas "g" lista todos os grupos de bichos.
#
# Uso: zzbicho [numero] [g]
# Ex.: zzbicho 123456
#      zzbicho 14 g
#      zzbicho g
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2012-08-27
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzbicho ()
{
	zzzz -h bicho "$1" && return

	# Verifica��o dos par�metros: se h� $1, ele deve ser 'g' ou um n�mero
	if [ $# -gt 0 ] && [ "$1" != 'g' ] && ! zztool testa_numero "$1"
	then
		zztool uso bicho
		return 1
	fi

	echo "$*" |
	awk '{
		grupo[01]="Avestruz"
		grupo[02]="�guia"
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
		grupo[15]="Jacar�"
		grupo[16]="Le�o"
		grupo[17]="Macaco"
		grupo[18]="Porco"
		grupo[19]="Pav�o"
		grupo[20]="Peru"
		grupo[21]="Touro"
		grupo[22]="Tigre"
		grupo[23]="Urso"
		grupo[24]="Veado"
		grupo[25]="Vaca"

		if ($2=="g" && $1 >= 1 && $1 <= 25) {
			numero = $1 * 4
			for (numero = ($1 * 4) - 3;numero <= ($1 *4); numero++) {
				printf " %.2d", substr(numero,length(numero)-1,2)
			}
			print ""
		}
		else if ($1 == "g" || $1 == "") {
			for (num=1;num<=25;num++) {
				printf " %.2d %s\n",num, grupo[num]
			}
		}
		else {
			numero = substr($1,length($1)-1,2)=="00"?25:int((substr($1,length($1)-1,2) + 3) / 4)
			print "", grupo[numero], "(" numero ")"
		}
	}'
}

# ----------------------------------------------------------------------------
# zzbissexto
# Diz se o ano informado � bissexto ou n�o.
# Obs.: Se o ano n�o for informado, usa o atual.
# Uso: zzbissexto [ano]
# Ex.: zzbissexto
#      zzbissexto 2000
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-21
# Vers�o: 1
# Licen�a: GPL
# Tags: data
# ----------------------------------------------------------------------------
zzbissexto ()
{
	zzzz -h bissexto "$1" && return

	local ano="$1"

	# Se o ano n�o for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Valida��o
	zztool -e testa_ano "$ano" || return 1

	if zztool testa_ano_bissexto "$ano"
	then
		echo "$ano � bissexto"
	else
		echo "$ano n�o � bissexto"
	fi
}

# ----------------------------------------------------------------------------
# zzblist
# Mostra se o IP informado est� em alguma blacklist (SBL, PBL e XBL).
# Uso: zzblist IP
# Ex.: zzblist 200.199.198.197
#
# Autor: Vin�cius Ven�ncio Leite <vv.leite (a) gmail com>
# Desde: 2008-10-16
# Vers�o: 3
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzblist ()
{
	zzzz -h blist "$1" && return

	local URL="http://www.spamblock.com.br/rblcheck.php?ip="
	local ip="$1"

	[ "$1" ] || { zztool uso blist; return 1; }

	zztool -e testa_ip "$ip" || return 1

	$ZZWWWDUMP "$URL$ip" | sed -n '
		/[Rr]elat.rio/ p
		/O IP /,/^$/ p'
}

# ----------------------------------------------------------------------------
# zzbolsas
# http://br.finance.yahoo.com
# Pesquisa �ndices de bolsas e cota��es de a��es.
# Sem par�metros mostra a lista de bolsas dispon�veis (c�digos).
# Com 1 par�metro:
#  -l: apenas mostra as bolsas dispon�veis e seus nomes.
#  commodities: produtos de origem prim�ria nas bolsas.
#  taxas_fixas ou moedas: exibe tabela de compara��o de c�mbio (pricipais).
#  taxas_cruzadas: exibe a tabela cartesiana do c�mbio.
#  nome_moedas ou moedas_nome: lista c�digos e nomes das moedas usadas.
#  servicos, economia ou politica: mostra not�cias relativas a esse assuntos.
#  noticias: junta as not�cias de servicos e economia.
#  volume: lista a��es l�deres em volume de neg�cios na Bovespa.
#  alta ou baixa: lista as a��es nessa condi��o na BMFBovespa.
#  "c�digo de bolsa ou a��o": mostra sua �ltima cota��o.
#
# Com 2 par�metros:
#  -l e c�digo de bolsa: lista as a��es (c�digos).
#  --lista e "c�digo de bolsa": lista as a��es com nome e �ltima cota��o.
#  taxas_fixas ou moedas <principais|europa|asia|latina>: exibe tabela de
#   compara��o de c�mbio dessas regi�es.
#  "c�digo de bolsa" e um texto: pesquisa-o no nome ou c�digo das a��es
#    dispon�veis na bolsa citada.
#  "c�digo de bolsa ou a��o" e data: pesquisa a cota��o no dia.
#  noticias e "c�digo de a��o": Noticias relativas a essa a��o (s� Bovespa)
#
# Com 3 par�metros ou mais:
#  "c�digo de bolsa ou a��o" e 2 datas: pesquisa as cota��es nos dias com
#    compara��es entre datas e varia��es da a��o ou bolsa pesquisada.
#  vs (ou comp) e 2 c�digos de bolsas ou a��es: faz a compara��o entre as duas
#   a��es ou bolsas. Se houver um quarto parametro como uma data faz essa
#   compara�ao na data especificada. Mas n�o compara a��es com bolsas.
#
# Uso: zzbolsas [-l|--lista] [bolsa|a��o] [data1|pesquisa] [data2]
# Ex.: zzbolsas                  # Lista das bolsas (c�digos)
#      zzbolsas -l               # Lista das bolsas (nomes)
#      zzbolsas -l ^BVSP         # Lista as a��es do �ndice Bovespa (c�digo)
#      zzbolsas --lista ^BVSP    # Lista as a��es do �ndice Bovespa (nomes)
#      zzbolsas ^BVSP loja       # Procura a��es com "loja" no nome ou c�digo
#      zzbolsas ^BVSP            # Cota��o do �ndice Bovespa
#      zzbolsas PETR4.SA         # Cota��o das a��es da Petrobr�s
#      zzbolsas PETR4.SA 21/12/2010  # Cota��o da Petrobr�s nesta data
#      zzbolsas commodities      # Tabela de commodities
#      zzbolsas altas            # Lista a��es em altas na Bovespa
#      zzbolsas volume           # Lista a��es em alta em volume de neg�cios
#      zzbolsas taxas_fixas
#      zzbolsas taxas_cruzadas
#      zzbolsas noticias         # Noticias recentes do mercado financeiro
#      zzbolsas vs petr3.sa vale5.sa # Compara ambas cota��es
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2009-10-04
# Vers�o: 13
# Licen�a: GPL
# Requisitos: zzmaiusculas zzsemacento zzdatafmt zzuniq
# ----------------------------------------------------------------------------
zzbolsas ()
{
	zzzz -h bolsas "$1" && return

	local url='http://br.finance.yahoo.com'
	local dj='^DWC'
	local new_york='^NYA ^NYI ^NYY ^NY ^NYL'
	local nasdaq='^IXIC ^IXBK ^NBI ^IXK ^IXF ^IXID ^IXIS ^IXFN ^IXUT ^IXTR ^NDX'
	local sp='^GSPC ^OEX ^MID ^SPSUPX ^SML'
	local amex='^XAX ^IIX ^NWX ^XMI'
	local ind_nac='^IBX50 ^IVBX ^IGCX ^IEE ^ITEL INDX.SA'
	local bolsa pag pags pag_atual data1 data2 vartemp

	case $# in
		0)
			# Lista apenas os c�digos das bolsas dispon�veis
			for bolsa in americas europe asia africa
			do
				zztool eco "\n$bolsa :"
				$ZZWWWDUMP "$url/intlindices?e=$bolsa"|
					sed -n '/�ltima/,/_/p'|sed '/Componentes,/!d'|
					awk '{ printf "%s ", $1}';echo
			done

			zztool eco "\nDow Jones :"
			$ZZWWWDUMP "$url/usindices"|
				sed -n '/�ltima/,/_/p'|sed '/Componentes,/!d'|
				awk '{ printf "%s ", $1}'
				printf "%s " "$dj";echo

			zztool eco "\nNYSE :"
			for bolsa in $new_york; do printf "%s " "$bolsa"; done;echo

			zztool eco "\nNasdaq :"
			for bolsa in $nasdaq; do printf "%s " "$bolsa"; done;echo

			zztool eco "\nStandard & Poors :"
			for bolsa in $sp; do printf "%s " "$bolsa"; done;echo

			zztool eco "\nAmex :"
			for bolsa in $amex; do printf "%s " "$bolsa"; done;echo

			zztool eco "\nOutros �ndices Nacionais :"
			for bolsa in $ind_nac; do printf "%s " "$bolsa"; done;echo
		;;
		1)
			# Lista os c�digos da bolsas e seus nomes
			case "$1" in
			-l | --lista)
				for bolsa in americas europe asia africa
				do
					zztool eco "\n$bolsa :"
					$ZZWWWDUMP "$url/intlindices?e=$bolsa"|
						sed -n '/�ltima/,/_/p'|sed '/Componentes,/!d'|
						sed 's/[0-9]*\.*[0-9]*,[0-9].*//g'|
						awk '{ printf " %-10s ", $1; for(i=2; i<=NF-1; i++) printf "%s ",$i; print $NF}'
				done

				zztool eco "\nDow Jones :"
				$ZZWWWDUMP "$url/usindices"|
					sed -n '/�ltima/,/_/p'|sed '/Componentes,/!d'|
					sed 's/[0-9]*\.*[0-9]*,[0-9].*//g'|
					awk '{ printf " %-10s ", $1; for(i=2; i<=NF-1; i++) printf "%s ",$i; print $NF}'
					printf " %-10s " "$dj";$ZZWWWDUMP "$url/q?s=$dj"|
					sed -n "/($dj)/{p;q;}"|sed "s/^ *//;s/ *($dj)//"

				zztool eco "\nNYSE :"
				for bolsa in $new_york;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa"|
					sed -n "/($bolsa)/{p;q;}"|sed "s/^ *//;s/ *($bolsa)//"
				done

				zztool eco "\nNasdaq :"
				for bolsa in $nasdaq;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa"|
					sed -n "/($bolsa)/{p;q;}"|sed "s/^ *//;s/ *($bolsa)//"
				done

				zztool eco "\nStandard & Poors :"
				for bolsa in $sp;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa"|
					sed -n "/($bolsa)/{p;q;}"|sed "s/^ *//;s/ *($bolsa)//"
				done

				zztool eco "\nAmex :"
				for bolsa in $amex;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa"|
					sed -n "/($bolsa)/{p;q;}"|sed "s/^ *//;s/ *($bolsa)//"
				done

				zztool eco "\nOutros �ndices Nacionais :"
				for bolsa in $ind_nac;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa"|
					sed -n "/($bolsa)/{p;q;}"|sed "s/^ *//;s/ *($bolsa)//;s/ *-$//"
				done
			;;
			commodities)
				zztool eco  "  Commodities"
				$ZZWWWDUMP "$url/moedas/mercado.html" |
				sed -n '/^Commodities/,/Mais commodities/p' |
				sed '1d;$d;/^ *$/d;s/CAPTION: //g;s/ *Metais/\n&/'
			;;
			taxas_fixas|moedas)
				zzbolsas $1 principais
			;;
			taxas_cruzadas)
				zztool eco " Taxas Cruzadas"
				$ZZWWWDUMP "$url/moedas/principais" |
				sed -n '/CAPTION: Taxas cruzadas/,/Not.cias e coment.rios/p' |
				sed '1d;/^[[:space:]]*$/d;$d;s/ .ltima transa��o /                  /g'
			;;
			moedas_nome|nome_moedas)
				zztool eco " BRL - Real
 USD - Dolar Americano
 EUR - Euro
 GBP - Libra Esterlina
 CHF - Franco Suico
 CNH - Yuan Chines
 HKD - Dolar decHong Kong
 SGD - Dolar de Singapura
 MXN - Peso Mexicano
 ARS - Peso Argentino
 UYU - Peso Uruguaio
 CLP - Peso Chileno
 PEN - Nuevo Sol (Peru)"
			;;
			noticias | economia | politica | servicos)
				case "$1" in
				economia | politica) vartemp=$($ZZWWWDUMP "$url/noticias/categoria-economia-politica-governo") ;;
				servicos) vartemp=$($ZZWWWDUMP "$url/noticias/setor-servicos") ;;
				noticias)
					zztool eco "Economia - Pol�tica - Governo"
					zzbolsas economia
					zztool eco "Setor de Servi�os"
					zzbolsas servicos
					return
				;;
				esac
				echo "$vartemp" |
				sed -n '/^[[:space:]]\+.*\(atr�s\|BRT\)[[:space:]]*$/p' |
				sed 's/^[[:space:]]\+/ /g'| zzuniq
			;;
			volume|alta|baixa)
				case "$1" in
					volume) pag='actives';;
					alta)	pag='gainers';;
					baixa)	pag='losers';;
				esac
				zztool eco  " Maiores ${1}s"
				$ZZWWWDUMP "$url/${pag}?e=sa" |
				sed -n '/Informa��es relacionadas/,/^[[:space:]]*$/p' |
				sed '1d;s/\(Down \| de \)/-/g;s/Up /+/g;s/Gr�fico, .*//g' |
				awk 'BEGIN {
							printf " %-10s  %-21s  %-20s  %-16s  %-10s\n","S�mbolo","Nome","�ltima Transa��o","Varia��o","Volume"
						}
					{
						if (NF > 6) {
							nome = ""
							printf " %-10s ", $1;
							for(i=2; i<=NF-5; i++) {nome = nome sprintf( "%s ", $i)};
							printf " %-22s ", nome;
							for(i=NF-4; i<=NF-3; i++) printf " %-6s ", $i;
							printf "  "
							printf " %-6s ", $(NF-2); printf " %-9s ", $(NF-1);
							printf " %10s", $NF
							print ""
						}
					}'
			;;
			*)
				bolsa=$(echo "$1"|zzmaiusculas)
				# �ltimo �ndice da bolsa citada ou cota��o da a��o
				vartemp=$($ZZWWWDUMP "$url/q?s=$bolsa"|
				sed -n "/($bolsa)/,/Cota��es atrasadas, salvo indica��o/p"|
				sed '{
						/^[[:space:]]*$/d
						/IFRAME:/d;
						/^[[:space:]]*-/d
						/Adicionar ao portf�lio/d
						/As pessoas que viram/d
						/Cota��es atrasadas, salvo indica��o/,$d
					}' |
				zzsemacento)
				paste -d"|" <(echo "$vartemp"|cut -f1 -d:|sed 's/^[[:space:]]\+//g;s/[[:space:]]\+$//g') <(echo "$vartemp"|cut -f2- -d:|sed 's/^[[:space:]]\+//g')|
				awk -F"|" '{if ( $1 != $2 ) {printf " %-20s %s\n", $1 ":", $2} else { print $1 } }'
			;;
			esac
		;;
		2 | 3 | 4)
			# Lista as a��es de uma bolsa especificada
			bolsa=$(echo "$2"|zzmaiusculas)
			if [ "$1" = "-l" -o "$1" = "--lista" ] && (zztool grep_var "$bolsa" "$dj $new_york $nasdaq $sp $amex $ind_nac" || zztool grep_var "^" "$bolsa")
			then
				pag_final=$($ZZWWWDUMP "$url/q/cp?s=$bolsa"|sed -n '/Primeira/p;/Primeira/q'|sed "s/^ *//g;s/.* \(of\|de\) *\([0-9]\+\) .*/\2/")
				pags=$(echo "scale=0;($pag_final - 1) / 50"|bc)

				for ((pag=0;pag<=$pags;pag++))
				do
					if test "$1" = "--lista"
					then
						# Listar as a��es com descri��o e suas �ltimas posi��es
						$ZZWWWDUMP "$url/q/cp?s=$bolsa&c=$pag"|
						sed -n 's/^ *//g;/S�mbolo /,/^Tudo /p'|
						sed '/S�mbolo /d;/^Tudo /d;/^[ ]*$/d'
					else
						# Lista apenas os c�digos das a��es
						$ZZWWWDUMP "$url/q/cp?s=$bolsa&c=$pag"|
						sed -n 's/^ *//g;/S�mbolo /,/^Tudo /p'|
						sed '/S�mbolo /d;/^Tudo /d;/^[ ]*$/d'|
						awk '{printf "%s  ",$1}'

						if test "$pag" = "$pags";then echo;fi
					fi
				done

			# Valores de uma bolsa ou a��o em uma data especificada (hist�rico)
			elif zztool testa_data $(zzdatafmt "$2")
			then
				read dd mm yyyy data1 < <(zzdatafmt -f "DD MM AAAA DD/MM/AAAA" "$2")
				mm=$(echo "scale=0;${mm}-1"|bc)
				bolsa=$(echo "$1"|zzmaiusculas)
					# Emprestando as variaves pag, pags e pag_atual efeito est�tico apenas
					pag=$($ZZWWWDUMP "$url/q/hp?s=$bolsa&a=${mm}&b=${dd}&c=${yyyy}&d=${mm}&e=${dd}&f=${yyyy}&g=d"|
					sed -n "/($bolsa)/p;/Abertura/,/* Pre�o/p"|sed 's/Data/    /;/* Pre�o/d'|
					sed 's/^ */ /g')
					pags=$(echo "$pag" | sed -n '2p' | sed 's/ [A-Z]/\n\t&/g;s/Enc ajustado/Ajustado/'| sed '/^ *$/d' | awk '{printf "  %-12s\n", $1}')
					pag_atual=$(echo "$pag" | sed -n '3p' | cut -f7- -d" " | sed 's/ [0-9]/\n&/g' | sed '/^ *$/d' |  awk '{printf " %14s\n", $1}')
					echo "$pag" | sed -n '1p'

					if [ "$3" ] && zztool testa_data $(zzdatafmt "$3")
					then
						read dd mm yyyy data2 < <(zzdatafmt -f "DD MM AAAA DD/MM/AAAA" "$3")
						mm=$(echo "scale=0;${mm}-1"|bc)
						pag=$($ZZWWWDUMP "$url/q/hp?s=$bolsa&a=${mm}&b=${dd}&c=${yyyy}&d=${mm}&e=${dd}&f=${yyyy}&g=d"|
						sed -n "/($bolsa)/p;/Abertura/,/* Pre�o/p"|sed 's/Data/    /;/* Pre�o/d'|
						sed 's/^ */ /g' | sed -n '3p' | cut -f7- -d" " |sed 's/ [0-9]/\n&/g' |
						sed '/^ *$/d' | awk '{printf " %14s\n", $1}')
						paste <(printf "  %-12s" "Data") <(echo "     $data1") <(echo "     $data2") <(echo "       Varia��o") <(echo " Var (%)")

						vartemp=$(while read data1 data2
						do
							echo "$data1 $data2" | tr -d '.' | tr ',' '.' |
							awk '{ printf "%15.2f\t", $2-$1; if ($1 != 0) {printf "%7.2f%", (($2-$1)/$1)*100}}' 2>/dev/null
							echo
						done < <(paste <(echo "$pag_atual") <(echo "$pag")))

						paste <(echo "$pags") <(echo "$pag_atual") <(echo "$pag") <(echo "$vartemp")
					else
						paste <(printf "  %-12s" "Data") <(echo "     $data1")
						paste <(echo "$pags") <(echo "$pag_atual")
					fi
			# Compara duas a��es ou bolsas diferentes
			elif ([ "$1" = "vs" -o "$1" = "comp" ])
			then
				if (zztool grep_var "^" "$2" && zztool grep_var "^" "$3")
				then
					vartemp="0"
				elif (! zztool grep_var "^" "$2" && ! zztool grep_var "^" "$3")
				then
					vartemp="0"
				fi
				if [ "$vartemp" ]
				then
					# Compara numa data especifica as a��es ou bolsas
					if ([ "$4" ] && zztool testa_data $(zzdatafmt "$4"))
					then
						pag=$(zzbolsas "$2" "$4" | sed '/Proxima data de anuncio/d')
						pags=$(zzbolsas "$3" "$4" |
						sed '/Proxima data de anuncio/d;s/^[[:space:]]*//g;s/[[:space:]]*$//g' |
						sed '2,$s/[^[:space:]]*[[:space:]]\+//g')
					# Ultima cota�ao das a�oes ou bolsas comparadas
					else
						pag=$(zzbolsas "$2" | sed '/Proxima data de anuncio/d')
						pags=$(zzbolsas "$3" | sed '/Proxima data de anuncio/d' |
						sed 's/^[[:space:]]*//g;3,$s/.*:[[:space:]]*//g')
					fi
					# Imprime efetivamente a compara��o
					if [ $(echo "$pag"|awk 'END {print NR}') -ge 4 -a $(echo "$pags"|awk 'END {print NR}') -ge 4 ]
					then
						echo
						while read data1
						do
							let vartemp++
							printf " %-45s " "$data1"
							sed -n "${vartemp}p" <(echo "$pags")
						done < <(echo "$pag")
						echo
					fi
				fi
			# Noticias relacionadas a uma a��o especifica
			elif ([ "$1" = "noticias" ] && ! zztool grep_var "^" "$2")
			then
				$ZZWWWDUMP "$url/q/h?s=$bolsa" |
				sed -n '/^[[:blank:]]\+\*.*\(Agencia\|at noodls\).*)$/p' |
				sed 's/^[[:blank:]]*/ /g;s/\(Agencia\|at noodls\)/ &/g'
			elif ([ "$1" = "taxas_fixas" ] || [ "$1" = "moedas" ])
			then
				case $2 in
				asia)
					url="$url/moedas/asia-pacifico"
					zztool eco  "   $(echo $1 | sed 'y/tfm_/TFM /') - �sia-Pac�fico"
				;;
				latina)
					url="$url/moedas/america-latina"
					zztool eco  "   $(echo $1 | sed 'y/tfm_/TFM /') - Am�rica Latina"
				;;
				europa)
					url="$url/moedas/europa"
					zztool eco  "   $(echo $1 | sed 'y/tfm_/TFM /') - Europa"
				;;
				principais|*)
					url="$url/moedas/principais"
					zztool eco  "   $(echo $1 | sed 'y/tfm_/TFM /') - Principais"
				;;
				esac
				
				$ZZWWWDUMP "$url" |
				sed -n '/CAPTION: Taxas fixas/,/CAPTION: Taxas cruzadas/p' |
				sed '
						/CAPTION: /d
						/^[[:space:]]\{5\}/d
						/^[[:space:]]*$/d
						s/ *Visualiza��o do gr�fico//g
						s/ *Par cambial/\n&/g
						s/ Inverter pares /                /g
					'|sed '3,$s/Par cambial          /Par cambial invertido/;1d'
			else
				bolsa=$(echo "$1"|zzmaiusculas)
				pag_final=$($ZZWWWDUMP "$url/q/cp?s=$bolsa"|sed -n '/Primeira/p;/Primeira/q'|sed 's/^ *//g;s/.* \(of\|de\) *\([0-9]\+\) .*/\2/')
				pags=$(echo "scale=0;($pag_final - 1) / 50"|bc)
				for ((pag=0;pag<=$pags;pag++))
				do
					$ZZWWWDUMP "$url/q/cp?s=$bolsa&c=$pag"|
					sed -n 's/^ *//g;/S�mbolo /,/Primeira/p'|
					sed '/S�mbolo /d;/Primeira/d;/^[ ]*$/d'|
					grep -i "$2"
				done
			fi
		;;
	esac
}

# ----------------------------------------------------------------------------
# zzbrasileirao
# http://esporte.uol.com.br/
# Mostra a tabela atualizada do Campeonato Brasileiro - S�rie A, B ou C.
# Se for fornecido um numero mostra os jogos da rodada, com resultados.
# Com argumento -l lista os todos os clubes da s�rie A e B.
# Se o argumento -l for seguido do nome do clube, lista todos os jogos j�
# ocorridos do clube desde o come�o do ano de qualquer campeonato, e os
# pr�ximos jogos no brasileir�o.
#
# Nomenclatura:
#	PG  - Pontos Ganhos
#	J   - Jogos
#	V   - Vit�rias
#	E   - Empates
#	D   - Derrotas
#	GP  - Gols Pr�
#	GC  - Gols Contra
#	SG  - Saldo de Gols
#	(%) - Aproveitamento (pontos)
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
# Autor: Itamar - original: Alexandre Brodt Fernandes, www.xalexandre.com.br
# Desde: 2011-05-28
# Vers�o: 12
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzbrasileirao ()
{
	zzzz -h brasileirao "$1" && return

	local rodada serie ano urls
	local url="http://esporte.uol.com.br"
	
	[ $(date +%Y%m%d) -lt 20130526 ] && { zztool eco " Brasileir�o 2013 s� a partir de 26 de Maio"; return 1; }

	[ $# -gt 2 ] && { zztool uso brasileirao; return 1; }

	serie='a'
	[ "$1" = "a" -o "$1" = "b" -o "$1" = "c" ] && { serie="$1"; shift; }

	if [ "$1" = "-l" ]
	then
		if [ "$2" ]
		then
			$ZZWWWDUMP "${url}/futebol/clubes/$2/resultados" | sed 's/^ *$//g' |
			sed -n '/^\(Janeiro\|Fevereiro\|Mar�o\|Abril\|Maio\|Junho\|Julho\|Agosto\|Setembro\|Outubro\|Novembro\|Dezembro\| *Data *Hora\| *[0-9][0-9]\/[0-9][0-9]\)/p'|sed 's/  *-  *Leia.*//g'

			$ZZWWWDUMP "${url}/futebol/clubes/$2/proximos-jogos" | sed 's/^ *$//g' |
			sed -n '/^\(Janeiro\|Fevereiro\|Mar�o\|Abril\|Maio\|Junho\|Julho\|Agosto\|Setembro\|Outubro\|Novembro\|Dezembro\| *Data *Hora\| *[0-9][0-9]\/[0-9][0-9]\)/p'
			return 0
		else
			$ZZWWWHTML "$url/futebol/clubes/" |
			sed -n '/<li class="aba \(show\|hide\) serie-[ab]">/,/<\/ul>$/p' |
			sed -n '/<li class=".*"><a rel="menu"/p'| awk -F'"' '{print $2}' | sort
			return 0
		fi
	else
		if [ "$1" ]
		then
			zztool testa_numero "$1" && rodada="$1" || { zztool uso brasileirao; return 1; }
		fi
	fi

	ano=$(date +%Y)

	url="${url}/futebol/campeonatos/brasileiro/${ano}/serie-${serie}"
	if [ "$rodada" ]
	then
		zztool testa_numero $rodada || { zztool uso brasileirao; return 1; }
		url="${url}/tabela-de-jogos/tabela-de-jogos-${rodada}a-rodada.htm"
		$ZZWWWDUMP $url | sed -n "/ RODADA - /,/Todas as rodadas/p"|
		sed "s/ *RELATO.*//g;s/ *Ler o relato.*//g" | sed '$d'
	else
		urls="${url}/classificacao/classificacao.htm"

		[ "$serie" = "a" ] && zztool eco "S�rie A"
		[ "$serie" = "b" ] && zztool eco "S�rie B"
		if [ "$serie" = "c" ]
		then
			zztool eco "S�rie C"
			urls="${url}/classificacao/classificacao-grupo-a.htm ${url}/classificacao/classificacao-grupo-b.htm"
		fi

		for url in $urls
		do
			if [ "$serie" = "c" ]
			then
				echo
				echo "$url"|sed 's/.*grupo-/Grupo /;s/\.htm//'| tr 'ab' 'AB'
			fi

			$ZZWWWDUMP $url | sed  -n "/^ *Time *PG/,/^ *\* /p;"|
			sed '/^ *$/d' | sed '/^ *[0-9]\+ *$/{N;N;s/\n//g;}' | sed 's/\([0-9]\+\) */\1 /g;/^ *PG/d' |
			awk -v cor_awk="$ZZCOR" -v serie_awk="$serie" '{ time=""; for(ind=1;ind<=(NF-9);ind++) { time = time sprintf(" %3s",$ind) }

			if (cor_awk==1)
			{
				cor="\033[m"

				if (NR >= 18 && NR <=21)
					cor="\033[41;30m"

				if (NR >= 6 && NR <=13)
					cor=(serie_awk=="a"?"\033[46;30m":"\033[m")

				if (NR >=10 && NR <= 11 && serie_awk=="c")
					cor="\033[41;30m"

				if (NR >= 2 && NR <=5)
					cor="\033[42;30m"
			}

			gsub(/ +/," ",time)
			sub (/^ [0-9] /, " &", time)
			if (NF>9)
			printf "%s%-23s %3s %3s %3s %3s %3s %3s %3s %3s %4s \033[m\n", cor, time, $(NF-8), $(NF-7), $(NF-6), $(NF-5), $(NF-4), $(NF-3), $(NF-2), $(NF-1), $NF}'

			if [ "$ZZCOR" = "1" ]
			then
				echo
				if [ "$serie" = "a" ]
				then
					printf "\033[42;30m Libertadores \033[m"
					printf "\033[46;30m Sul-Americana \033[m"
				elif [ "$serie" = "b" ]
				then
					printf "\033[42;30m   S�rie  A   \033[m"
				else
					printf "\033[42;30m  Classifica  \033[m"
				fi
				printf "\033[41;30m Rebaixamento \033[m\n"
			fi

		done
	fi
}

# ----------------------------------------------------------------------------
# zzbyte
# Convers�o entre grandezas de bytes (mega, giga, tera, etc).
# Uso: zzbyte N [unidade-entrada] [unidade-saida]  # BKMGTPEZY
# Ex.: zzbyte 2048                    # Quanto � 2048 bytes?  -- 2K
#      zzbyte 2048 K                  # Quanto � 2048KB?      -- 2M
#      zzbyte 7 K M                   # Quantos megas em 7KB? -- 0.006M
#      zzbyte 7 G B                   # Quantos bytes em 7GB? -- 7516192768B
#      for u in b k m g t p e z y; do zzbyte 2 t $u; done
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-03-01
# Vers�o: 1
# Licen�a: GPL
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

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso byte; return 1; }

	# Sejamos amig�veis com o usu�rio permitindo min�sculas tamb�m
	entrada=$(echo "$entrada" | zzmaiusculas)
	saida=$(  echo "$saida"   | zzmaiusculas)

	# Verifica��es b�sicas
	if ! zztool grep_var "$entrada" "$unidades"
	then
		echo "Unidade inv�lida '$entrada'"
		return 1
	fi
	if ! zztool grep_var "$saida" ".$unidades"
	then
		echo "Unidade inv�lida '$saida'"
		return 1
	fi
	zztool -e testa_numero "$n" || return 1

	# Extrai os n�meros (�ndices) das unidades de entrada e sa�da
	i_entrada=$(zztool index_var "$entrada" "$unidades")
	i_saida=$(  zztool index_var "$saida"   "$unidades")

	# Sem $3, a unidade de sa�da ser� otimizada
	[ $i_saida -eq 0 ] && i_saida=15

	# A diferen�a entre as unidades guiar� os c�lculos
	diferenca=$((i_saida - i_entrada))
	if [ "$diferenca" -lt 0 ]
	then
		operacao='*'
		passo='-'
	else
		operacao='/'
		passo='+'
	fi

	i="$i_entrada"
	while [ "$i" -ne "$i_saida" ]
	do
		# Sa�da autom�tica (sem $3)
		# Chegamos em um n�mero menor que 1024, hora de sair
		[ "$n" -lt 1024 -a "$i_saida" -eq 15 ] && break

		# N�o ultrapasse a unidade m�xima (Yota)
		[ "$i" -eq ${#unidades} -a "$passo" = '+' ] && break

		# 0 < n < 1024 para unidade crescente, por exemplo: 1 B K
		# � hora de dividir com float e colocar zeros � esquerda
		if [ "$n" -gt 0 -a "$n" -lt 1024 -a "$passo" = '+' ]
		then
			# Quantos d�gitos ainda faltam?
			falta=$(( (i_saida - i - 1) * 3))

			# Pulamos direto para a unidade final
			i="$i_saida"

			# C�lculo preciso usando o bc (Retorna algo como .090)
			n=$(echo "scale=3; $n / 1024" | bc)
			[ "$n" = '0' ] && break # 1 / 1024 = 0

			# Completa os zeros que faltam
			[ "$falta" -gt 0 ] && n=$(printf "%0.${falta}f%s" 0 "${n#.}")

			# Coloca o zero na frente, caso necess�rio
			[ "${n#.}" != "$n" ] && n="0$n"

			break
		fi

		# Terminadas as exce��es, este � o processo normal
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
# Obs.: N�meros fracionados podem vir com v�rgulas ou pontos: 1,5 ou 1.5.
# Use a op��o --soma para somar uma lista de n�meros vindos da STDIN.
#
# Uso: zzcalcula opera��o|--soma
# Ex.: zzcalcula 2,20 + 3.30          # v�rgulas ou pontos, tanto faz
#      zzcalcula '2^2*(4-1)'          # 2 ao quadrado vezes 4 menos 1
#      echo 2 + 2 | zzcalcula         # lendo da entrada padr�o (STDIN)
#      zzseq 5 | zzcalcula --soma     # soma n�meros da STDIN
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-04
# Vers�o: 3
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcalcula ()
{
	zzzz -h calcula "$1" && return

	local soma

	# Op��o de linha de comando
	if test "$1" = '--soma'
	then
		soma=1
		shift
	fi

	# A op��o --soma s� l� dados da STDIN, n�o deve ter argumentos
	if test -n "$soma" -a $# -gt 0
	then
		zztool uso calcula
		return 1
	fi

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Limpeza nos dados para chegarem bem no bc
	sed '
		# Espa�os s� atrapalham (tab+espa�o)
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

			# N�meros sem sinal s�o positivos
			s/^[0-9]/+&/

			# Se o primeiro da lista tiver sinal + d� erro no bc
			1 s/^+//' |
		# Junta as linhas num �nica tripa, exemplo: 5+7-3+1-2
		#tr -d '\n'
		paste -s -d ' ' - | sed 's/ //g'
	else
		cat -
	fi |

	# O resultado deve ter somente duas casas decimais
	sed 's/^/scale=2;/' |

	# Entrada de n�meros com v�rgulas ou pontos, sa�da sempre com v�rgulas
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
# Calcula os endere�os de rede e broadcast � partir do IP e m�scara da rede.
# Obs.: Se n�o especificada, ser� usada a m�scara padr�o (RFC 1918) ou 24.
# Uso: zzcalculaip ip [netmask]
# Ex.: zzcalculaip 127.0.0.1 24
#      zzcalculaip 10.0.0.0/8
#      zzcalculaip 192.168.10.0 255.255.255.240
#      zzcalculaip 10.10.10.0
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2005-09-01
# Vers�o: 2
# Licen�a: GPL
# Requisitos: zzconverte
# ----------------------------------------------------------------------------
zzcalculaip ()
{
	zzzz -h calculaip "$1" && return

	local endereco mascara rede broadcast
	local mascara_binario mascara_decimal mascara_ip
	local i ip1 ip2 ip3 ip4 nm1 nm2 nm3 nm4 componente

	# Verifica��o dos par�metros
	[ $# -eq 0 -o $# -gt 2 ] && { zztool uso calculaip; return 1; }

	# Obt�m a m�scara da rede (netmask)
	if zztool grep_var / "$1"
	then
		endereco=${1%/*}
		mascara="${1#*/}"
	else
		endereco=$1

		# Use a m�scara informada pelo usu�rio ou a m�scara padr�o
		if [ $# -gt 1 ]
		then
			mascara=$2
		else
			# A m�scara padr�o � determinada pela RFC 1918 (valeu jonerworm)
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

	# Verifica��es b�sicas
	if ! (
		zztool testa_ip $mascara || (
		zztool testa_numero $mascara && test $mascara -le 32))
	then
		echo "M�scara inv�lida: $mascara"
		return 1
	fi
	zztool -e testa_ip $endereco || return 1

	# Guarda os componentes da m�scara em $1, $2, ...
	# Ou � um ou quatro componentes: 24 ou 255.255.255.0
	set - $(echo $mascara | tr . ' ')

	# M�scara no formato NN
	if [ $# -eq 1 ]
	then
		# Converte de decimal para bin�rio
		# Coloca N n�meros 1 grudados '1111111' (N=$1)
		# e completa com zeros � direita at� 32, com pontos:
		# $1=12 vira 11111111.11110000.00000000.00000000
		mascara=$(printf "%$1s" 1 | tr ' ' 1)
		mascara=$(
			printf '%-32s' $mascara |
			tr ' ' 0 |
			sed 's/./&./24 ; s/./&./16 ; s/./&./8'
		)
	fi

	# Convers�o de decimal para bin�rio nos componentes do IP e netmask
	for i in 1 2 3 4
	do
		componente=$(echo $endereco | cut -d'.' -f $i)
		eval ip$i=$(printf '%08d' $(zzconverte db $componente))

		componente=$(echo $mascara | cut -d'.' -f $i)
		if [ "$2" ]
		then
			eval nm$i=$(printf '%08d' $(zzconverte db $componente))
		else
			eval nm$i=$componente
		fi
	done

	# Uma verifica��o na m�scara depois das convers�es
	mascara_binario=$nm1$nm2$nm3$nm4
	if ! (
		zztool testa_binario $mascara_binario &&
		test ${#mascara_binario} -eq 32)
	then
		echo 'M�scara inv�lida'
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

	# C�lculo do endere�o de rede
	endereco=""
	for i in 1 2 3 4
	do
		ip1=$((rede & 255))
		rede=$((rede >> 8))
		endereco="$ip1.$endereco"
	done

	echo "Rede     : ${endereco%.} / $mascara_decimal"

	# C�lculo do endere�o de broadcast
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
# Altera Um Texto Para Deixar Todas As Iniciais De Palavras Em Mai�sculas.
# Use a op��o -1 para converter somente a primeira letra de cada linha.
# Use a op��o -w para adicionar caracteres de palavra (Padr�o: A-Za-z0-9���)
#
# Uso: zzcapitalize [texto]
# Ex.: zzcapitalize root                                 # Root
#      zzcapitalize kung fu panda                        # Kung Fu Panda
#      zzcapitalize -1 kung fu panda                     # Kung fu panda
#      zzcapitalize quero-quero                          # Quero-Quero
#      echo eu_uso_camel_case | zzcapitalize             # Eu_Uso_Camel_Case
#      echo "i don't care" | zzcapitalize                # I Don'T Care
#      echo "i don't care" | zzcapitalize -w \'          # I Don't Care
#      cat arquivo.txt | zzcapitalize
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-21
# Vers�o: 5
# Licen�a: GPL
# Requisitos: zzminusculas
# ----------------------------------------------------------------------------
zzcapitalize ()
{
	zzzz -h capitalize "$1" && return

	local primeira todas filtros extra x
	local acentuadas='��������������������������������������������������'
	local palavra='A-Za-z0-9'
	local soh_primeira=0

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			-1)
				soh_primeira=1
				shift
			;;
			-w)
				# Escapa a " pra n�o dar problema no sed adiante
				extra=$(echo "$2" | sed 's/"/\\"/g')
				shift
				shift
			;;
			*) break ;;
		esac
	done

	# Aqui est� a lista de caracteres que comp�em uma palavra.
	# Estes caracteres *n�o* disparam a capitaliza��o da letra seguinte.
	# Esta regex � usada na vari�vel $todas, a seguir.
	x="[^$palavra$acentuadas$extra]"

	# Filtro que converte pra mai�sculas somente a primeira letra da linha
	primeira='
		s_^a_A_ ; s_^n_N_ ; s_^�_�_ ; s_^�_�_ ;
		s_^b_B_ ; s_^o_O_ ; s_^�_�_ ; s_^�_�_ ;
		s_^c_C_ ; s_^p_P_ ; s_^�_�_ ; s_^�_�_ ;
		s_^d_D_ ; s_^q_Q_ ; s_^�_�_ ; s_^�_�_ ;
		s_^e_E_ ; s_^r_R_ ; s_^�_�_ ; s_^�_�_ ;
		s_^f_F_ ; s_^s_S_ ; s_^�_�_ ; s_^�_�_ ;
		s_^g_G_ ; s_^t_T_ ; s_^�_�_ ; s_^�_�_ ;
		s_^h_H_ ; s_^u_U_ ; s_^�_�_ ; s_^�_�_ ;
		s_^i_I_ ; s_^v_V_ ; s_^�_�_ ; s_^�_�_ ;
		s_^j_J_ ; s_^w_W_ ; s_^�_�_ ; s_^�_�_ ;
		s_^k_K_ ; s_^x_X_ ; s_^�_�_ ; s_^�_�_ ;
		s_^l_L_ ; s_^y_Y_ ; s_^�_�_ ; s_^�_�_ ;
		s_^m_M_ ; s_^z_Z_ ; s_^�_�_ ;
	'
	# Filtro que converte pra mai�sculas a primeira letra de cada palavra.
	# Note que o delimitador usado no s///g foi o espa�o em branco.
	todas="
		s \($x\)a \1A g ; s \($x\)n \1N g ; s \($x\)� \1� g ; s \($x\)� \1� g ;
		s \($x\)b \1B g ; s \($x\)o \1O g ; s \($x\)� \1� g ; s \($x\)� \1� g ;
		s \($x\)c \1C g ; s \($x\)p \1P g ; s \($x\)� \1� g ; s \($x\)� \1� g ;
		s \($x\)d \1D g ; s \($x\)q \1Q g ; s \($x\)� \1� g ; s \($x\)� \1� g ;
		s \($x\)e \1E g ; s \($x\)r \1R g ; s \($x\)� \1� g ; s \($x\)� \1� g ;
		s \($x\)f \1F g ; s \($x\)s \1S g ; s \($x\)� \1� g ; s \($x\)� \1� g ;
		s \($x\)g \1G g ; s \($x\)t \1T g ; s \($x\)� \1� g ; s \($x\)� \1� g ;
		s \($x\)h \1H g ; s \($x\)u \1U g ; s \($x\)� \1� g ; s \($x\)� \1� g ;
		s \($x\)i \1I g ; s \($x\)v \1V g ; s \($x\)� \1� g ; s \($x\)� \1� g ;
		s \($x\)j \1J g ; s \($x\)w \1W g ; s \($x\)� \1� g ; s \($x\)� \1� g ;
		s \($x\)k \1K g ; s \($x\)x \1X g ; s \($x\)� \1� g ; s \($x\)� \1� g ;
		s \($x\)l \1L g ; s \($x\)y \1Y g ; s \($x\)� \1� g ; s \($x\)� \1� g ;
		s \($x\)m \1M g ; s \($x\)z \1Z g ; s \($x\)� \1� g ;
	"

	# Aplicando a op��o -1, caso informada
	test $soh_primeira -eq 1 && todas=''

	filtros="$primeira $todas"

	# Texto via STDIN ou argumentos
	# Primeiro converte tudo pra min�sculas, depois capitaliza as iniciais
	zztool multi_stdin "$@" | zzminusculas | sed "$filtros"
}

# ----------------------------------------------------------------------------
# zzcarnaval
# Mostra a data da ter�a-feira de Carnaval para qualquer ano.
# Obs.: Se o ano n�o for informado, usa o atual.
# Regra: 47 dias antes do domingo de P�scoa.
# Uso: zzcarnaval [ano]
# Ex.: zzcarnaval
#      zzcarnaval 1999
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-23
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzdata zzpascoa
# Tags: data
# ----------------------------------------------------------------------------
zzcarnaval ()
{
	zzzz -h carnaval "$1" && return

	local ano="$1"

	# Se o ano n�o for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Valida��o
	zztool -e testa_ano $ano || return 1

	# Ah, como � f�cil quando se tem as ferramentas certas ;)
	zzdata $(zzpascoa $ano) - 47
}

# ----------------------------------------------------------------------------
# zzcbn
# http://cbn.globoradio.com.br
# Busca e toca os �ltimos coment�rios dos comentaristas da radio CBN.
# Uso: zzcbn [--mp3] [-c COMENTARISTA] [-d data]  ou  zzcbn --lista
# Ex.: zzcbn -c max -d ontem
#      zzcbn -c mauro -d tudo
#      zzcbn -c juca -d 13/05/09
#      zzcbn -c miriam
#      zzcbn --mp3 -c max
#
# Autor: Rafael Machado Casali <rmcasali (a) gmail com>
# Desde: 2009-04-16
# Vers�o: 2
# Licen�a: GPL
# Requisitos: zzecho
# ----------------------------------------------------------------------------
zzcbn ()
{
	zzzz -h cbn "$1" && return

	local COMENTARISTAS MP3 RSS data comentarista datafile

#Comentaristas;RSS;Download
COMENTARISTAS="Andr�_Trigueiro;andretrigueiro;andre-trigueiro;mundo
Arnaldo_Jabor;arnaldojabor;arnaldo-jabor;jabor
Carlos_Alberto_Sardenberg;carlosalbertosardenberg;sardenberg
Cony_&_Xex�o;conyxexeo;conyxexeo
Ethevaldo_Siqueira;ethevaldosiqueira;digital
Gilberto_Dimenstein;gilbertodimenstein;dimenstein
Juca_Kfouri;jucakfouri;jkfouri
Lucia_Hippolito;luciahippolito;lucia
Luis_Fernando_Correia;luisfernandocorreia;saudefoco
Mara_Luquet;maraluquet;mara
Marcos_Petrucelli;marcospetrucelli;petrucelli
Mauro_Halfeld;maurohalfeld;halfeld
Max_Gehringer;maxgehringer;max
Merval_Pereira;mervalpereira;merval
Miriam_Leit�o;miriamleitao;mleitao
Renato_Machado;renatomachado;rmachado
S�rgio_Abranches;sergioabranches;ecopolitica"

RSS="http://imagens.globoradio.globo.com/cbn/rss/comentaristas/"
#MP3="http://download3.globo.com/sgr-$EXT/cbn/"
#EXT="mp3"
MP3="mms://wm-sgr-ondemand.globo.com/_aberto/sgr/1/cbn/"
EXT="wma"

#Verificacao dos par�metros
[ "$1" ] || { zztool uso cbn; return 1; }

if [ "$1" == "--lista" ]
then
	for i in $COMENTARISTAS
	do
		echo `echo $i | sed 's/;/ ou /g' # cut -d';' -f1`
	done
	return
fi

# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			-c)
				shift
				comentarista="$1"
				;;
			-d)
				shift
				data="$1"
				;;
			--mp3)
				EXT="mp3"
				#MP3="http://download3.globo.com/sgr-$EXT/cbn/"
				MP3="http://download.sgr.globo.com/sgr-$EXT/cbn/"
				;;
			*)
				zzecho -l vermelha "Op��o inv�lida!!"
				return 1
				;;
		esac
		shift
	done

	linha=`echo $COMENTARISTAS | tr ' ' '\n' | sed  "/$comentarista/!d"`
	autor=`echo $linha | cut -d';' -f 3`
#	[ "$data" ] || data=`LANG=en.US date "+%d %b %Y"`
#	echo "$RSS`echo $linha | cut -d';' -f 2`.xml"
	$ZZWWWHTML "$RSS`echo $linha | cut -d';' -f 2`.xml"  | sed -n "/title/p;/pubDate/p" | sed "s/.*A\[\(.*\)]].*/\1/g" | sed "s/.*>\(.*\)<\/.*/\1/g" | sed "2d" > "$ZZTMP.cbn.comentarios"

	zzecho -l ciano `cat "$ZZTMP.cbn.comentarios" | sed -n '1p'`

	case  "$data" in
		"ontem")
			datafile=`date -d "yesterday" +%y%m%d`
			data=`LANG=en date -d "yesterday" "+%d %b %Y"`
			cat "$ZZTMP.cbn.comentarios" | sed -n "/$data/{H;x;p;};h" > "$ZZTMP.cbn.coment"
		;;
		"tudo")
			cat "$ZZTMP.cbn.comentarios" | sed '1d' > "$ZZTMP.cbn.coment"
		;;
		"")
			datafile=`date '+%y%m%d'`
			data=`LANG=en date "+%d %b %Y"`
			cat "$ZZTMP.cbn.comentarios" | sed -n "/$data/{H;x;p;};h" > "$ZZTMP.cbn.coment"
		;;
		*)
			if ! ( zztool testa_data "$data" || zztool testa_numero "$data" )
			then
				echo "Data inv�lida '$data', deve ser dd/mm/aaaa"
				return 1
			fi
			data="`echo $data | sed 's/\([0-9]*\)\/\([0-9]*\)\/\([0-9]*\)/\3-\2-\1/g'`"
			datafile=`date -d $data +%y%m%d`
			data=`LANG=en date -d $data "+%d %b %Y"`
			cat "$ZZTMP.cbn.comentarios" | sed -n "/$data/{H;x;p;};h" > "$ZZTMP.cbn.coment"


	esac
	Tlinhas=`cat "$ZZTMP.cbn.coment"| sed -n '$='`
	[ "$Tlinhas" ] ||  { zzecho -l vermelho "Sem coment�rios"; return; }
	for ((l=1;$l<=$Tlinhas;l=$l+2))
	do
		P=`expr $l + 1`
		titulo=`cat "$ZZTMP.cbn.coment"| sed "$l!d"`
		data=`cat "$ZZTMP.cbn.coment"| sed "$P!d"`
		datafile=`date -d "$data" "+%y%m%d"`
		hora=`LANG=en date -d "$data" "+%p"`
		data=`LANG=en date -d "$data" "+%d %b %Y %H:%m"`
		dois="_"
		if [ "$hora" == "PM" ]
		then
			case "$autor" in
			"sardenberg"|"mleitao"|"halfeld")
				dois="2_"
				;;
			esac
		fi
		zzecho -l verde "(q) para pr�ximo; CTRL+C para sair"
		#echo $MP3`date +%Y`/colunas/$autor$dois$datafile.$EXT
		echo $titulo - $data
		mplayer $MP3`date +%Y`/colunas/$autor$dois$datafile.$EXT 1>/dev/null 2>/dev/null || return
	done
	if [ "$Tlinhas" == "0" ]
	then
		zzecho -l vermelho "Sem coment�rios"
	fi
	rm -f "$ZZTMP.cbn.comentarios"
	rm -f "$ZZTMP.cbn.coment"
}

# ----------------------------------------------------------------------------
# zzchavepgp
# http://pgp.mit.edu
# Busca a identifica��o da chave PGP, fornecido o nome ou e-mail da pessoa.
# Uso: zzchavepgp nome|e-mail
# Ex.: zzchavepgp Carlos Oliveira da Silva
#      zzchavepgp carlos@dominio.com.br
#
# Autor: Rodrigo Missiaggia
# Desde: 2001-10-01
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzchavepgp ()
{
	zzzz -h chavepgp "$1" && return

	local url='http://pgp.mit.edu:11371'
	local padrao=$(echo $*| sed "$ZZSEDURL")

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso chavepgp; return 1; }

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
# Nota: A fun��o checa o arquivo no diret�rio corrente (./)
# Uso: zzchecamd5 arquivo md5sum
# Ex.: zzchecamd5 ./ubuntu-8.10.iso f9e0494e91abb2de4929ef6e957f7753
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-10-31
# Vers�o: 3
# Licen�a: GPLv2
# Requisitos: zzmd5
# ----------------------------------------------------------------------------
zzchecamd5 ()
{

	# Variaveis locais
	local arquivo valor_md5 md5_site

	# Help da funcao zzchecamd5
	zzzz -h checamd5 "$1" && return

	# Faltou argumento mostrar como se usa a zzchecamd5
	if [ $# != "2" ];then
		zztool uso checamd5
		return 1
	fi

	# Foi passado o caminho errado do arquivo
	if [ ! -f $1  ];then
		echo "Nao foi encontrado: $1"
		return 1
	fi

	# Setando variaveis
	arquivo=./$1
	md5_site=$2
	valor_md5=$(cat "$arquivo" | zzmd5)

	# Verifica se o arquivo nao foi corrompido
	if [ "$md5_site" = "$valor_md5" ]; then
		echo "Imagem OK"
	else
		echo "O md5sum nao confere!!"
	fi
}

# ----------------------------------------------------------------------------
# zzcidade
# http://pt.wikipedia.org/wiki/Anexo:Lista_de_munic%C3%ADpios_do_Brasil
# Lista completa com todas as 5.500+ cidades do Brasil, com busca.
# Obs.: Sem argumentos, mostra uma cidade aleat�ria.
#
# Uso: zzcidade [palavra|regex]
# Ex.: zzcidade              # mostra uma cidade qualquer
#      zzcidade campos       # mostra as cidades com "Campos" no nome
#      zzcidade '(SE)'       # mostra todas as cidades de Sergipe
#      zzcidade ^X           # mostra as cidades que come�am com X
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-21
# Vers�o: 2
# Licen�a: GPL
# Requisitos: zzlinha
# ----------------------------------------------------------------------------
zzcidade ()
{
	zzzz -h cidade "$1" && return

	local url='http://pt.wikipedia.org/wiki/Anexo:Lista_de_munic%C3%ADpios_do_Brasil'
	local cache="$ZZTMP.cidade"
	local padrao="$*"

	# Se o cache est� vazio, baixa listagem da Internet
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
# Acha as fun��es de uma biblioteca da linguagem C (arquivos .h).
# Obs.: O diret�rio padr�o de procura � o /usr/include.
# Uso: zzcinclude nome-biblioteca
# Ex.: zzcinclude stdio
#      zzcinclude /minha/rota/alternativa/stdio.h
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-12-15
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcinclude ()
{
	zzzz -h cinclude "$1" && return

	local arquivo="$1"

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso cinclude; return 1; }

	# Se n�o come�ar com / (caminho relativo), coloca path padr�o
	[ "${arquivo#/}" = "$arquivo" ] && arquivo="/usr/include/$arquivo.h"

	# Verifica se o arquivo existe
	zztool arquivo_legivel "$arquivo" || return

	# Sa�da ordenada, com um Sed m�gico para limpar a sa�da do cpp
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
# zzcinemark15h
# http://cinemark.com.br/programacao/cidade/1
# Exibe os filmes com sess�o �s 15h (mais barata) no Cinemark da sua cidade.
# Uso: zzcinemark15h [cidade | codigo_cinema]
# Ex.: zzcinemark15h sao paulo
#
# Autor: Thiago Moura Witt <thiago.witt (a) gmail.com> <@thiagowitt>
# Desde: 2011-07-05
# Vers�o: 2
# Licen�a: GPL
# Requisitos: zzminusculas zzsemacento
# ----------------------------------------------------------------------------
zzcinemark15h ()
{
	zzzz -h cinemark15h "$1" && return

	if [ $# = 0 ]; then # mostra op��es
		printf "Cidades dispon�veis\n=============================\n"
		printf "Aracaju\n"
		printf "Barueri\n"
		printf "Belo Horizonte\n"
		printf "Bras�lia\n"
		printf "Campinas\n"
		printf "Campo Grande\n"
		printf "Canoas\n"
		printf "Cotia\n"
		printf "Curitiba\n"
		printf "Florian�polis\n"
		printf "Goi�nia\n"
		printf "Guarulhos\n"
		printf "Jacare�\n"
		printf "Manaus\n"
		printf "Natal\n"
		printf "Niter�i\n"
		printf "Osasco\n"
		printf "Palmas\n"
		printf "Porto Alegre\n"
		printf "Ribeir�o Preto\n"
		printf "Rio de Janeiro\n"
		printf "Salvador\n"
		printf "Santo Andr�\n"
		printf "Santos\n"
		printf "S�o Bernardo do Campo\n"
		printf "S�o Jos� dos Campos\n"
		printf "S�o Jos� dos Pinhais\n"
		printf "S�o Paulo\n"
		printf "Taguatinga\n"
		printf "Vit�ria\n"
		return 0
	fi

	#converte nome da cidade para min�scula e retira espa�os
	local cidade=$(echo $* | sed 's/ /_/g' | zzminusculas | zzsemacento)
	local codigo=""

	if zztool testa_numero ${cidade}; then # passou c�digo
		if [ "$cidade" -ge 1 -a "$cidade" -le 31 ]; then
			codigo="$cidade" # testa se c�digo � v�lido
		else
			echo "C�digo de cidade inv�lido"
			return 1
		fi
	else # passou nome da cidade
		case $cidade in
			aracaju) codigo=10;;
			barueri) codigo=4;;
			belo_horizonte) codigo=21;;
			brasilia) codigo=14;;
			campinas) codigo=16;;
			campo_grande) codigo=13;;
			canoas) codigo=12;;
			cotia) codigo=30;;
			curitiba) codigo=18;;
			florianopolis) codigo=24;;
			goiania) codigo=23;;
			guarulhos) codigo=27;;
			jacarei) codigo=19;;
			manaus) codigo=15;;
			natal) codigo=22;;
			niteroi) codigo=20;;
			osasco) codigo=29;;
			palmas) codigo=31;;
			porto_alegre) codigo=11;;
			ribeirao_preto) codigo=6;;
			rio_de_janeiro) codigo=9;;
			salvador) codigo=26;;
			santo_andre) codigo=2;;
			santos) codigo=8;;
			sao_bernardo_do_campo) codigo=3;;
			sao_jose_dos_campos) codigo=5;;
			sao_jose_dos_pinhais) codigo=28;;
			sao_paulo) codigo=1;;
			taguatinga) codigo=17;;
			vitoria) codigo=25;;
			*) echo "Cidade inv�lida" && return 1;;
		esac
	fi

	# URL com query para api YQL do Yahoo, que extrai os dados da pagina do
	# Cinemark e retorna so o que interessa
	local url=$(echo "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22http%3A%2F%2Fcinemark.com.br%2Fprogramacao%2Fcidade%2F<CIDADE>%22%20and%20xpath%3D'%2F%2Fh3%20%7C%20%2F%2Fdiv%5B%40class%3D%22filme%22%20and%20div%2Fp%2Fspan%3D%2215h00%22%5D%2Fdiv%2Fh4%2Fa'&diagnostics=true" | sed "s/<CIDADE>/$codigo/")

	# Os primeiros dois comandos (-e) do sed sao para remover todas as
	# quebras de linha. O ultimo comando remove a parte que nao interessa,
	# depois extrai e formata os resultados
	result=$($ZZWWWHTML $url | sed -e :a -e '$!N; s/\n/ /; ta' \
	-e '/<results\/>/d;s/<?.*<results>//;s/<.results>.*//;s/<h3>\([^<]*\)<.h3>/\
\1:\
/g;s/<a[^>]*>\([^<]*\)<.a>/	\1\
/g')

	[ -z "$result" ] && result="Nenhuma sess�o com promo��o na sua cidade."

	echo "$result"
	echo
}

# ----------------------------------------------------------------------------
# zzcineuci
# http://www.ucicinemas.com.br
# Exibe a programa��o dos cinemas UCI de sua cidade.
# Se n�o for passado nenhum par�metro, s�o listadas as cidades e cinemas.
# Obs.: n�o utilize acentos: digite "Sao Paulo", e n�o "S�o Paulo"
# Uso: zzcineuci [cidade | codigo_cinema]
# Ex.: zzcineuci recife
#      zzcineuci 14
#
# Autor: Rodrigo Pereira da Cunha <rodrigopc (a) gmail.com>
# Desde: 2009-05-04
# Vers�o: 6
# Licen�a: GPL
# Requisitos: zzminusculas zzsemacento
# ----------------------------------------------------------------------------
zzcineuci ()
{
	zzzz -h cineuci "$1" && return

	local codigo codigos
	local url="http://www.ucicinemas.com.br/controles/listaFilmeCinemaHome.aspx?cinemaID="
	local cidade=$(echo "$*" | zzminusculas | zzsemacento)

	[ $# -gt 1 ] && zztool uso cineuci && return 1

	if [ $# = 0 ]; then # mostra op��es
		printf "Cidades e cinemas dispon�veis\n=============================\n"
		printf "\nCuritiba:\n\t01) UCI Esta��o\n\t15) UCI Palladium\n"
		printf "\nFortaleza:\n\t10) Multiplex UCI Ribeiro Iguatemi Fortaleza\n"
		printf "\nJuiz de Fora:\n\t12) UCI Kinoplex Independ�ncia\n"
		printf "\nRecife:\n\t04) Multiplex UCI Ribeiro Recife\n\t05) Multiplex UCI Ribeiro Tacaruna\n\t14) UCI Kinoplex Shop Plaza Casa Forte Recife\n"
		printf "\nSantana:\n\t13) UCI Santana Parque Shopping\n"
		printf "\nS�o Paulo:\n\t08) UCI Jardim Sul\n\t09) UCI An�lia Franco\n"
		printf "\nRibeir�o Preto:\n\t02) UCI Ribeir�o\n"
		printf "\nRio de Janeiro:\n\t07) UCI New York City Center\n\t11) UCI Kinoplex NorteShopping\n"
		printf "\nSalvador:\n\t03) Multiplex Iguatemi Salvador\n\t06) UCI Aeroclube\n\t17) UCI Orient Paralela\n"
		return 0
	fi

	if zztool testa_numero ${cidade}; then # passou c�digo
		[ "$cidade" -ge 1 -a "$cidade" -le 17 ] && codigos="$cidade" # testa se c�digo � v�lido
	else # passou nome da cidade
		case $cidade in
			curitiba      ) codigos="1 15" ;;
			fortaleza     ) codigos="10" ;;
			juiz_de_fora  ) codigos="12" ;;
			recife        ) codigos="4 5 14" ;;
			ribeirao_preto) codigos="2" ;;
			rio_de_janeiro)	codigos="7 11" ;;
			santana       ) codigos="13" ;;
			sao_paulo     ) codigos="8 9" ;;
			salvador      ) codigos="3 6 17" ;;
		esac
	fi

	[ -z "$codigos" ] && return 1 # se n�o recebeu cidade ou c�digo v�lido, sai

	for codigo in $codigos
	do
		$ZZWWWDUMP "$url$codigo" | sed '

			# Faxina
			s/^  *//
			/^$/ d
			/^Hor�rios para/ d

			# Destaque ao redor do nome do cinema, quebra linha ap�s
			1 i\
=================================================
			1 a\
=================================================\


			# Quebra linha ap�s o hor�rio
			/^Sala / G
		'
	done
	return 0
}

# ----------------------------------------------------------------------------
# zzcnpj
# Gera um CNPJ v�lido aleat�rio ou valida um CNPJ informado.
# Obs.: O CNPJ informado pode estar formatado (pontos e h�fen) ou n�o.
# Uso: zzcnpj [cnpj]
# Ex.: zzcnpj 12.345.678/0001-95      # valida o CNPJ
#      zzcnpj 12345678000195          # com ou sem formatadores
#      zzcnpj                         # gera um CNPJ v�lido
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-12-23
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcnpj ()
{
	zzzz -h cnpj "$1" && return

	local i n somatoria digito1 digito2 cnpj base

	# Aten��o:
	# Essa fun��o � irm�-quase-g�mea da zzcpf, que est� bem
	# documentada, ent�o n�o vou repetir aqui os coment�rios.
	#
	# O c�lculo dos d�gitos verificadores tamb�m � id�ntico,
	# apenas com uma m�scara num�rica maior, devido � quantidade
	# maior de d�gitos do CNPJ em rela��o ao CPF.

	cnpj=$(echo "$*" | tr -d -c 0123456789)

	if [ "$cnpj" ]
	then
		# CNPJ do usu�rio

		if [ ${#cnpj} -ne 14 ]
		then
			echo 'CNPJ inv�lido (deve ter 14 d�gitos)'
			return 1
		fi

		base="${cnpj%??}"
	else
		# CNPJ gerado aleatoriamente

		while [ ${#cnpj} -lt 8 ]
		do
			cnpj="$cnpj$((RANDOM % 9))"
		done

		cnpj="${cnpj}0001"
		base="$cnpj"
	fi

	# C�lculo do d�gito verificador 1

	set - $(echo "$base" | sed 's/./& /g')

	somatoria=0
	for i in 5 4 3 2 9 8 7 6 5 4 3 2
	do
		n="$1"
		somatoria=$((somatoria + (i * n)))
		shift
	done

	digito1=$((11 - (somatoria % 11)))
	[ $digito1 -ge 10 ] && digito1=0

	# C�lculo do d�gito verificador 2

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
	[ $digito2 -ge 10 ] && digito2=0

	# Mostra ou valida o CNPJ
	if [ ${#cnpj} -eq 12 ]
	then
		echo "$cnpj$digito1$digito2" |
			sed 's|\(..\)\(...\)\(...\)\(....\)|\1.\2.\3/\4-|'
	else
		if [ "${cnpj#????????????}" = "$digito1$digito2" ]
		then
			echo 'CNPJ v�lido'
		else
			# Boa a��o do dia: mostrar quais os verificadores corretos
			echo "CNPJ inv�lido (deveria terminar em $digito1$digito2)"
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzcontapalavra
# Conta o n�mero de vezes que uma palavra aparece num arquivo.
# Obs.: � diferente do grep -c, que n�o conta v�rias palavras na mesma linha.
# Op��es: -i  ignora a diferen�a de mai�sculas/min�sculas
#         -p  busca parcial, conta trechos de palavras
# Uso: zzcontapalavra [-i|-p] palavra arquivo(s)
# Ex.: zzcontapalavra root /etc/passwd
#      zzcontapalavra -i -p a /etc/passwd      # Compare com grep -ci a
#      cat /etc/passwd | zzcontapalavra root
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-10-02
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcontapalavra ()
{
	zzzz -h contapalavra "$1" && return

	local padrao ignora
	local inteira=1

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			-p) inteira=  ;;
			-i) ignora=1  ;;
			* ) break     ;;
		esac
		shift
	done

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso contapalavra; return 1; }

	padrao=$1
	shift

	# Contorna a limita��o do grep -c pesquisando pela palavra
	# e quebrando o resultado em uma palavra por linha (tr).
	# Ent�o pode-se usar o grep -c para contar.
	# Nota: Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |
		grep -h ${ignora:+-i} ${inteira:+-w} -- "$padrao" |
		tr '\t./ -,:-@[-_{-~' '\n' |
		grep -c ${ignora:+-i} ${inteira:+-w} -- "$padrao"
}

# ----------------------------------------------------------------------------
# zzcontapalavras
# Conta o n�mero de vezes que cada palavra aparece em um texto.
#
# Op��es: -i       Trata mai�sculas e min�sculas como iguais, FOO = Foo = foo
#         -n N�M   Mostra apenas as N�M palavras mais frequentes
#
# Uso: zzcontapalavras [-i] [-n N] [arquivo(s)]
# Ex.: zzcontapalavras arquivo.txt
#      zzcontapalavras -i arquivo.txt
#      zzcontapalavras -i -n 10 /etc/passwd
#      cat arquivo.txt | zzcontapalavras
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-07
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzminusculas
# ----------------------------------------------------------------------------
zzcontapalavras ()
{
	zzzz -h contapalavras "$1" && return

	local ignore_case
	local tab=$(printf '\t')
	local limite='$'

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
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

		# Remove caracteres que n�o s�o parte de palavras
		sed 's/[^A-Za-z0-9������������������������_-]/ /g' |

		# Deixa uma palavra por linha, formando uma lista
		tr -s ' ' '\n' |

		# Converte tudo pra min�sculas?
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

			# Remove linhas somente com n�meros e tra�os
			/^[0-9_-][0-9_-]*$/d
			' |

		# Faz a contagem com o uniq -c
		sort |
		uniq -c |

		# Ordena o resultado, primeiro vem a de maior contagem
		sort -n -r |

		# Temos limite no n�mero de resultados?
		sed "$limite q" |

		# Formata o resultado para N�mero-Tab-Palavra
		sed "s/^[ $tab]*\([0-9]\{1,\}\)[ $tab]\{1,\}\(.*\)/\1$tab\2/"
}

# ----------------------------------------------------------------------------
# zzconverte
# Faz v�rias convers�es como: caracteres, temperatura e dist�ncia.
#          cf = (C)elsius             para (F)ahrenheit
#          fc = (F)ahrenheit          para (C)elsius
#          ck = (C)elsius             para (K)elvin
#          kc = (K)elvin              para (C)elsius
#          fk = (F)ahrenheit          para (K)elvin
#          kf = (K)elvin              para (F)ahrenheit
#          km = (K)Quil�metros        para (M)ilhas
#          mk = (M)ilhas              para (K)Quil�metros
#          db = (D)ecimal             para (B)in�rio
#          bd = (B)in�rio             para (D)ecimal
#          cd = (C)aractere           para (D)ecimal
#          dc = (D)ecimal             para (C)aractere
#          hc = (H)exadecimal         para (C)aractere
#          ch = (C)aractere           para (H)exadecimal
#          dh = (D)ecimal             para (H)exadecimal
#          hd = (H)exadecimal         para (D)ecimal
# Uso: zzconverte <cf|fc|ck|kc|fk|kf|mk|km|db|bd|cd|dc|hc|ch|dh|hd> n�mero
# Ex.: zzconverte cf 5
#      zzconverte dc 65
#      zzconverte db 32
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2003-10-02
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzconverte ()
{
	zzzz -h converte "$1" && return

	local s2='scale=2'
	local operacao=$1

	# Verifica��o dos par�metros
	[ "$2" ] || { zztool uso converte; return 1; }

	shift
	while [ "$1" ]
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
				echo "$((2#$1))"
			;;
			cd)
				printf "%d\n" "'$1"
			;;
			dc)
				echo -e $(printf "\\\x%x" $1)
			;;
			ch)
				printf "%x\n" "'$1"
			;;
			hc)
				echo -e "\x${1#0x}"
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
# Mostra todas as combina��es de cores poss�veis no console.
# Tamb�m mostra os c�digos ANSI para obter tais combina��es.
# Uso: zzcores
# Ex.: zzcores
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-12-11
# Vers�o: 1
# Licen�a: GPL
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
				# Comp�e o par de cores: NN;NN
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
# Obs.: Se o ano n�o for informado, usa o atual.
# Regra: 60 dias depois do domingo de P�scoa.
# Uso: zzcorpuschristi [ano]
# Ex.: zzcorpuschristi
#      zzcorpuschristi 2009
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-11-21
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzdata zzpascoa
# Tags: data
# ----------------------------------------------------------------------------
zzcorpuschristi ()
{
	zzzz -h corpuschristi "$1" && return

	local ano="$1"

	# Se o ano n�o for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Valida��o
	zztool -e testa_ano $ano || return 1

	# Ah, como � f�cil quando se tem as ferramentas certas ;)
	# e quando j� temos o c�digo e s� precisamos mudar os numeros
	# tambem � bom :D ;)
	zzdata $(zzpascoa $ano) + 60
}

# ----------------------------------------------------------------------------
# zzcorrida
# Mostra a classifica��o dos pilotos em v�rias corridas (F1, Indy, GP, ...).
#
#  Use as seguintes combina��es para as corridas
#   F�rmula 1: f1 ou formula1
#   F�rmula Indy: indy ou formula_indy
#   GP2: gp2
#   F�rmula Truck: truck ou formula_truck
#   F�rmula Truck Sul-Americana: truck_sul
#   Stock Car: stock ou stock_car
#   Moto GP: moto ou moto_gp
#   Moto 2: moto2
#   Moto 3: moto3
#   Rali: rali
#   Sprint Cup (Nascar): nascar ou nascar1 ou sprint ou sprint_cup
#   Truck Series (Nascar): nascar2 ou truck_series
#
# Uso: zzcorrida <f1|indy|gp2|truck|truck_sul|stock|rali>
# Uso: zzcorrida <moto|moto_gp|moto2|moto3>
# Uso: zzcorrida <nascar|nascar1|sprint|nascar2|truck_series>
# Ex.: zzcorrida truck
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2011-11-02
# Vers�o: 5
# Licen�a: GPL
# Requisitos: zzmaiusculas
# ----------------------------------------------------------------------------
zzcorrida ()
{
	zzzz -h corrida "$1" && return

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso corrida; return 1; }

	local corridas
	local url="http://tazio.uol.com.br/classificacoes"

	case "$1" in
		f1|formula1)			corridas="f1";;
		indy|formula_indy)		corridas="indy";;
		gp2)				corridas="gp2";;
		nascar|nascar1|nascar2)		corridas="nascar";;
		sprint|sprint_cup|truck_series)	corridas="nascar";;
		truck|formula_truck|truck_sul)	corridas="formula-truck";;
		rali)				corridas="rali";;
		stock|stock_car)		corridas="stock-car";;
		moto|moto_gp|moto2|moto3)	corridas="moto";;
		*)				zztool uso corrida; return 1;;
	esac

	echo "$1"|sed 's/_/ /'|zzmaiusculas

	case "$1" in
		nascar|nascar1|sprint|sprint_cup)
			$ZZWWWDUMP "$url/$corridas" | sed -n '/Pos.*Piloto/,/Data/p' |
			sed '1,/Data/!d;s/ Pontos/Pontos/' | sed 's/\[.*\]/        /;$d'
		;;
		nascar2|truck_series)
			$ZZWWWDUMP "$url/$corridas" | sed -n '/Pos.*Piloto/,/Data/p' |
			sed '1,/Data/d;s/ Pontos/Pontos/' | sed 's/\[.*\]/        /;$d'
		;;
		truck|formula_truck)
			$ZZWWWDUMP "$url/$corridas" | sed -n '/Pos.*Piloto/,/Pos.*Piloto/p' |
			sed 's/ Pontos/Pontos/;$d' | sed 's/\[.*\]/        /'
		;;
		truck_sul)
			$ZZWWWDUMP "$url/$corridas" | sed -n '/Pos.*Piloto/,/Data/p' |
			sed '2,/Pos.*Piloto/d;s/ Pontos/Pontos/;$d' | sed 's/\[.*\]/        /'
		;;
		moto|moto_gp)
			$ZZWWWDUMP "$url/$corridas" | sed -n '/Pos.*Piloto/,/^ *$/p' |
			sed '1p;2,/Pos.*Piloto/!d' | sed 's/ Pontos/Pontos/;$d' | sed 's/\[.*\]/        /'
		;;
		moto2)
			$ZZWWWDUMP "$url/$corridas" | sed '1,/Pos.*Piloto/ d' |
			sed -n '/Pos.*Piloto/,/Pos.*Piloto/ p' |
			sed 's/ Pontos/Pontos/;$d' | sed 's/\[.*\]/        /'
		;;
		moto3)
			$ZZWWWDUMP "$url/$corridas" | sed '1,/Pos.*Piloto/ d' | sed '1,/Pos.*Piloto/ d' |
			sed -n '/Pos.*Piloto/,/^ *$/ p' |
			sed 's/ Pontos/Pontos/;$d' | sed 's/\[.*\]/        /'
		;;
		*)
			$ZZWWWDUMP "$url/$corridas" | sed -n '/Pos.*Piloto/,$ p' |
			sed '/^ *Data/ q' | sed '/^ *Pos\. *Equipe/ q' |
			sed 's/ Pontos/Pontos/;$d' | sed 's/\[.*\]/        /'
		;;
	esac
}

# ----------------------------------------------------------------------------
# zzcpf
# Gera um CPF v�lido aleat�rio ou valida um CPF informado.
# Obs.: O CPF informado pode estar formatado (pontos e h�fen) ou n�o.
# Uso: zzcpf [cpf]
# Ex.: zzcpf 123.456.789-09          # valida o CPF
#      zzcpf 12345678909             # com ou sem formatadores
#      zzcpf                         # gera um CPF v�lido
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-12-23
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcpf ()
{
	zzzz -h cpf "$1" && return

	local i n somatoria digito1 digito2 cpf base

	# Remove pontua��o do CPF informado, deixando apenas n�meros
	cpf=$(echo "$*" | tr -d -c 0123456789)

	# Extrai os n�meros da base do CPF:
	# Os 9 primeiros, sem os dois d�gitos verificadores.
	# Esses dois d�gitos ser�o calculados adiante.
	if [ "$cpf" ]
	then
		# Faltou ou sobrou algum n�mero...
		if [ ${#cpf} -ne 11 ]
		then
			echo 'CPF inv�lido (deve ter 11 d�gitos)'
			return 1
		fi

		# Apaga os dois �ltimos d�gitos
		base="${cpf%??}"
	else
		# N�o foi informado nenhum CPF, vamos gerar um escolhendo
		# nove d�gitos aleatoriamente para formar a base
		while [ ${#cpf} -lt 9 ]
		do
			cpf="$cpf$((RANDOM % 9))"
		done
		base="$cpf"
	fi

	# Truque para cada d�gito da base ser guardado em $1, $2, $3, ...
	set - $(echo "$base" | sed 's/./& /g')

	# Explica��o do algoritmo de gera��o/valida��o do CPF:
	#
	# Os primeiros 9 d�gitos s�o livres, voc� pode digitar quaisquer
	# n�meros, n�o h� seq��ncia. O que importa � que os dois �ltimos
	# d�gitos, chamados verificadores, estejam corretos.
	#
	# Estes d�gitos s�o calculados em cima dos 9 primeiros, seguindo
	# a seguinte f�rmula:
	#
	# 1) Aplica a multiplica��o de cada d�gito na m�scara de n�meros
	#    que � de 10 a 2 para o primeiro d�gito e de 11 a 3 para o segundo.
	# 2) Depois tira o m�dulo de 11 do somat�rio dos resultados.
	# 3) Diminui isso de 11 e se der 10 ou mais vira zero.
	# 4) Pronto, achou o primeiro d�gito verificador.
	#
	# M�scara   : 10    9    8    7    6    5    4    3    2
	# CPF       :  2    2    5    4    3    7    1    0    1
	# Multiplica: 20 + 18 + 40 + 28 + 18 + 35 +  4 +  0 +  2 = Somat�ria
	#
	# Para o segundo � praticamente igual, por�m muda a m�scara (11 - 3)
	# e ao somat�rio � adicionado o d�gito 1 multiplicado por 2.

	### C�lculo do d�gito verificador 1
	# Passo 1
	somatoria=0
	for i in 10 9 8 7 6 5 4 3 2 # m�scara
	do
		# Cada um dos d�gitos da base ($n) � multiplicado pelo
		# seu n�mero correspondente da m�scara ($i) e adicionado
		# na somat�ria.
		n="$1"
		somatoria=$((somatoria + (i * n)))
		shift
	done
	# Passo 2
	digito1=$((11 - (somatoria % 11)))
	# Passo 3
	[ $digito1 -ge 10 ] && digito1=0

	### C�lculo do d�gito verificador 2
	# Tudo igual ao anterior, primeiro setando $1, $2, $3, etc e
	# depois fazendo os c�lculos j� explicados.
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
	# Passo 1 e meio (o dobro do verificador 1 entra na somat�ria)
	somatoria=$((somatoria + digito1 * 2))
	# Passo 2
	digito2=$((11 - (somatoria % 11)))
	# Passo 3
	[ $digito2 -ge 10 ] && digito2=0

	# Mostra ou valida
	if [ ${#cpf} -eq 9 ]
	then
		# Esse CPF foi gerado aleatoriamente pela fun��o.
		# Apenas adiciona os d�gitos verificadores e mostra na tela.
		echo "$cpf$digito1$digito2" |
			sed 's/\(...\)\(...\)\(...\)/\1.\2.\3-/' # nnn.nnn.nnn-nn
	else
		# Esse CPF foi informado pelo usu�rio.
		# Compara os verificadores informados com os calculados.
		if [ "${cpf#?????????}" = "$digito1$digito2" ]
		then
			echo 'CPF v�lido'
		else
			# Boa a��o do dia: mostrar quais os verificadores corretos
			echo "CPF inv�lido (deveria terminar em $digito1$digito2)"
		fi
	fi
}

# ----------------------------------------------------------------------------
# zzdata
# Calculadora de datas, trata corretamente os anos bissextos.
# Voc� pode somar ou subtrair dias, meses e anos de uma data qualquer.
# Voc� pode informar a data dd/mm/aaaa ou usar palavras como: hoje, ontem.
# Na diferen�a entre duas datas, o resultado � o n�mero de dias entre elas.
# Se informar somente uma data, converte para n�mero de dias (01/01/1970 = 0).
# Se informar somente um n�mero (de dias), converte de volta para a data.
# Esta fun��o tamb�m pode ser usada para validar uma data.
#
# Uso: zzdata [data [+|- data|n�mero<d|m|a>]]
# Ex.: zzdata                           # que dia � hoje?
#      zzdata anteontem                 # que dia foi anteontem?
#      zzdata hoje + 15d                # que dia ser� daqui 15 dias?
#      zzdata hoje - 40d                # e 40 dias atr�s, foi quando?
#      zzdata 31/12/2010 + 100d         # 100 dias ap�s a data informada
#      zzdata 29/02/2001                # data inv�lida, ano n�o-bissexto
#      zzdata 29/02/2000 + 1a           # 28/02/2001 <- respeita bissextos
#      zzdata 01/03/2000 - 11/11/1999   # quantos dias h� entre as duas?
#      zzdata hoje - 07/10/1977         # quantos dias desde meu nascimento?
#      zzdata 21/12/2012 - hoje         # quantos dias para o fim do mundo?
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-02-07
# Vers�o: 4
# Licen�a: GPL
# Tags: data, c�lculo
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

	# Verifica��o dos par�metros
	case $# in
		0)
			# Sem argumentos, mostra a data atual
			zzdata hoje
			return
		;;
		1)
			# Delta sozinho � relativo ao dia atual
			case "$1" in
				[0-9]*[dma])
					zzdata hoje + "$1"
					return
				;;
			esac
		;;
		3)
			# Valida��o r�pida
			if test "$operacao" != '-' -a "$operacao" != '+'
			then
				echo "Opera��o inv�lida '$operacao'. Deve ser + ou -."
				return 1
			fi
		;;
		*)
			zztool uso data
			return 1
		;;
	esac

	# Valida��o do conte�do de $valor1 e $valor2
	# Formato v�lidos: 31/12/1999, 123, -123, 5d, 5m, 5a, hoje
	#
	# Este bloco � bem importante, pois al�m de validar os dados
	# do usu�rio, tamb�m povoa as vari�veis que ser�o usadas na
	# tomada de decis�o adiante. S�o elas:
	# $tipo1 $tipo2 $data1 $data2 $dias1 $dias2 $delta1 $delta2
	#
	# Nota: � o eval quem salva estas vari�veis.

	for i in 1 2
	do
		# Obt�m o conte�do de $valor1 ou $valor2
		eval "valor=\$valor$i"

		# Cancela se i=2 e s� temos um valor
		test -z "$valor" && break

		# Identifica o tipo do valor e faz a valida��o
		case "$valor" in

			# Data no formato dd/mm/aaaa
			??/??/?*)

				tipo='data'
				yyyy="${valor##*/}"
				ddmm="${valor%/*}"

				# Data em formato v�lido?
				zztool -e testa_data "$valor" || return 1

				# 29/02 em um ano n�o-bissexto?
				if test "$ddmm" = '29/02' && ! zztool testa_ano_bissexto "$yyyy"
				then
					echo "Data inv�lida '$valor', pois $yyyy n�o � um ano bissexto"
					return 1
				fi
			;;

			# Delta de dias, meses ou anos: 5d, 5m, 5a
			[0-9]*[dma])

				tipo='delta'

				# Valida��o
				if ! echo "$valor" | grep '^[0-9][0-9]*[dma]$' >/dev/null
				then
					echo "Delta inv�lido '$valor'. Deve ser algo como 5d, 5m ou 5a."
					return 1
				fi
			;;

			# N�mero negativo ou positivo
			-[0-9]*|[0-9]*)

				tipo='dias'

				# Valida��o
				if ! zztool testa_numero_sinal "$valor"
				then
					echo "N�mero inv�lido '$valor'"
					return 1
				fi
			;;

			# Apelidos: hoje, ontem, etc
			[a-z]*)

				tipo='data'

				# Converte apelidos em datas
				case "$valor" in
					today|hoje)
						valor=$(date +%d/%m/%Y)
					;;
					yesterday|ontem)
						valor=$(zzdata hoje - 1)
					;;
					anteontem)
						valor=$(zzdata hoje - 2)
					;;
					tomorrow|amanh[a�])
						valor=$(zzdata hoje + 1)
					;;
					fim)
						valor=21/12/2012  # ;)
					;;
					*)
						echo "Data inv�lida '$valor', deve ser dd/mm/aaaa"
						return 1
				esac

				# Exce��o: se este � o �nico argumento, mostra a data e sai
				if test $# -eq 1
				then
					echo "$valor"
					return 0
				fi
			;;
			*)
				echo "Data inv�lida '$valor', deve ser dd/mm/aaaa"
				return 1
			;;
		esac

		# Salva as vari�veis $data/$dias/$delta e $tipo,
		# todas com os sufixos 1 ou 2 no nome. Por isso o eval.
		# Exemplo: data1=01/01/1970; tipo1=data
		eval "$tipo$i=$valor; tipo$i=$tipo"
	done

	# Valida��o: Se h� um delta, o outro valor deve ser uma data ou n�mero
	if test "$tipo1" = 'delta' -a "$tipo2" = 'delta'
	then
		zztool uso data
		return 1
	fi

	# Se chamada com um �nico argumento, � uma convers�o simples.
	# Se veio uma data, converta para um n�mero.
	# Se veio um n�mero, converta para uma data.
	# E pronto.

	if test $# -eq 1
	then
		case $tipo1 in

			data)
				#############################################################
				### Convers�o DATA -> N�MERO
				#
				# A data dd/mm/aaaa � transformada em um n�mero inteiro.
				# O resultado � o n�mero de dias desde $epoch (01/01/1970).
				# Se a data for anterior a $epoch, o n�mero ser� negativo.
				# Anos bissextos s�o tratados corretamente.
				#
				# Exemplos:
				#      30/12/1969 = -2
				#      31/12/1969 = -1
				#      01/01/1970 = 0
				#      02/01/1970 = 1
				#      03/01/1970 = 2
				#
				#      01/02/1970 = 31    (31 dias do m�s de janeiro)
				#      01/01/1971 = 365   (um ano)
				#      01/01/1980 = 3652  (365 * 10 anos + 2 bissextos)

				data="$data1"

				# Extrai os componentes da data: ano, m�s, dia
				yyyy=${data##*/}
				mm=${data#*/}
				mm=${mm%/*}
				dd=${data%%/*}

				# Retira os zeros � esquerda (pra n�o confundir com octal)
				mm=${mm#0}
				dd=${dd#0}
				yyyy=$(echo "$yyyy" | sed 's/^00*//; s/^$/0/')

				# Define o marco inicial e a dire��o dos c�lculos
				if [ $yyyy -ge $epoch ]
				then
					# +Epoch: Inicia em 01/01/1970 e avan�a no tempo
					y=$epoch          # ano
					m=1               # m�s
					op='+'            # dire��o
					dias=0            # 01/01/1970 == 0
					dias_mes="$dias_mes_ok"
				else
					# -Epoch: Inicia em 31/12/1969 e retrocede no tempo
					y=$((epoch - 1))  # ano
					m=12              # m�s
					op='-'            # dire��o
					dias=-1           # 31/12/1969 == -1
					dias_mes="$dias_mes_rev"
				fi

				# Ano -> dias
				while :
				do
					# Sim, os anos bissextos s�o levados em conta!
					dias_ano=365
					zztool testa_ano_bissexto $y && dias_ano=366

					# Vai somando (ou subtraindo) at� chegar no ano corrente
					[ $y -eq $yyyy ] && break
					dias=$(($dias $op $dias_ano))
					y=$(($y $op 1))
				done

				# Meses -> dias
				for i in $dias_mes
				do
					# Fevereiro de ano bissexto tem 29 dias
					[ $dias_ano -eq 366 -a $i -eq 28 ] && i=29

					# Vai somando (ou subtraindo) at� chegar no m�s corrente
					[ $m -eq $mm ] && break
					m=$(($m $op 1))
					dias=$(($dias $op $i))
				done
				dias_neste_mes=$i

				# -Epoch: o n�mero de dias indica o quanto deve-se
				# retroceder � partir do �ltimo dia do m�s
				[ $op = '-' ] && dd=$(($dias_neste_mes - $dd))

				# Somando os dias da data aos anos+meses j� contados.
				dias=$(($dias $op $dd))

				# +Epoch: � subtra�do um do resultado pois 01/01/1970 == 0
				[ $op = '+' ] && dias=$((dias - 1))

				# Feito, s� mostrar o resultado
				echo "$dias"
			;;

			dias)
				#############################################################
				### Convers�o N�MERO -> DATA
				#
				# O n�mero inteiro � convertido para a data dd/mm/aaaa.
				# Se o n�mero for positivo, temos uma data DEPOIS de $epoch.
				# Se o n�mero for negativo, temos uma data ANTES de $epoch.
				# Anos bissextos s�o tratados corretamente.
				#
				# Exemplos:
				#      -2 = 30/12/1969
				#      -1 = 31/12/1969
				#       0 = 01/01/1970
				#       1 = 02/01/1970
				#       2 = 03/01/1970

				dias="$dias1"

				if [ $dias -ge 0 ]
				then
					# POSITIVO: Inicia em 01/01/1970 e avan�a no tempo
					y=$epoch          # ano
					mm=1              # m�s
					op='+'            # dire��o
					dias_mes="$dias_mes_ok"
				else
					# NEGATIVO: Inicia em 31/12/1969 e retrocede no tempo
					y=$((epoch - 1))  # ano
					mm=12             # m�s
					op='-'            # dire��o
					dias_mes="$dias_mes_rev"

					# Valor negativo complica, vamos positivar: abs()
					dias=$((0 - dias))
				fi

				# O n�mero da Epoch � zero-based, agora vai virar one-based
				dd=$(($dias $op 1))

				# Dias -> Ano
				while :
				do
					# Novamente, o ano bissexto � levado em conta
					dias_ano=365
					zztool testa_ano_bissexto $y && dias_ano=366

					# Vai descontando os dias de cada ano para saber quantos anos cabem

					# N�o muda o ano se o n�mero de dias for insuficiente
					[ $dd -lt $dias_ano ] && break

					# Se for exatamente igual ao total de dias, n�o muda o
					# ano se estivermos indo adiante no tempo (> Epoch).
					# Caso contr�rio vai mudar pois cairemos no �ltimo dia
					# do ano anterior.
					[ $dd -eq $dias_ano -a $op = '+' ] && break

					dd=$(($dd - $dias_ano))
					y=$(($y $op 1))
				done
				yyyy=$y

				# Dias -> m�s
				for i in $dias_mes
				do
					# Fevereiro de ano bissexto tem 29 dias
					[ $dias_ano -eq 366 -a $i -eq 28 ] && i=29

					# Calcula quantos meses cabem nos dias que sobraram

					# N�o muda o m�s se o n�mero de dias for insuficiente
					[ $dd -lt $i ] && break

					# Se for exatamente igual ao total de dias, n�o muda o
					# m�s se estivermos indo adiante no tempo (> Epoch).
					# Caso contr�rio vai mudar pois cairemos no �ltimo dia
					# do m�s anterior.
					[ $dd -eq $i -a $op = '+' ] && break

					dd=$(($dd - $i))
					mm=$(($mm $op 1))
				done
				dias_neste_mes=$i

				# Ano e m�s est�o OK, agora sobraram apenas os dias

				# Se estivermos antes de Epoch, os n�mero de dias indica quanto
				# devemos caminhar do �ltimo dia do m�s at� o primeiro
				[ $op = '-' ] && dd=$(($dias_neste_mes - $dd))

				# Restaura o zero dos meses e dias menores que 10
				[ $dd -le 9 ] && dd="0$dd"
				[ $mm -le 9 ] && mm="0$mm"

				# E finalmente mostra o resultado em formato de data
				echo "$dd/$mm/$yyyy"
			;;

			*)
				echo "Tipo inv�lido '$tipo1'. Isso n�o deveria acontecer :/"
				return 1
			;;
		esac
		return 0
	fi

	# Neste ponto s� chega se houver mais de um par�metro.
	# Todos os valores j� foram validados.

	#############################################################
	### C�lculos com datas
	#
	# Temos dois valores informadas pelo usu�rio: $valor1 e $valor2.
	# Cada valor pode ser uma data dd/mm/aaaa, um n�mero inteiro
	# ou um delta de dias, meses ou anos.
	#
	# Exemplos: 31/12/1999, 123, -123, 5d, 5m, 5a
	#
	# O usu�rio pode fazer qualquer combina��o entre estes valores.
	#
	# Se o c�lculo envolver deltas m|a, � usada a data dd/mm/aaaa.
	# Sen�o, � usado o n�mero inteiro que representa a data.
	#
	# O tipo de cada valor � guardado em $tipo1-2.
	# Dependendo do tipo, o valor foi guardado nas vari�veis
	# $data1-2, $dias1-2 ou $delta1-2.
	# Use estas vari�veis no bloco seguinte para tomar decis�es.

	# C�lculo com delta.
	if test $tipo1 = 'delta' -o $tipo2 = 'delta'
	then
		# Nunca haver� dois valores do mesmo tipo, posso abusar:
		delta="$delta1$delta2"
		data="$data1$data2"
		dias="$dias1$dias2"

		quantidade=$(echo "$delta" | sed 's/[^0-9]//g')
		grandeza=$(  echo "$delta" | sed 's/[^dma]//g')

		case $grandeza in
			d)
				# O c�lculo deve ser feito utilizando o n�mero
				test -z "$dias" && dias=$(zzdata "$data")  # data2n

				# Soma ou subtrai o delta
				dias=$(($dias $operacao $quantidade))

				# Converte o resultado para dd/mm/aaaa
				zzdata $dias
				return
			;;
			m|a)
				# O c�lculo deve ser feito utilizando a data
				test -z "$data" && data=$(zzdata "$dias")  # n2data

				# Extrai os componentes da data: ano, m�s, dia
				yyyy=${data##*/}
				mm=${data#*/}
				mm=${mm%/*}
				dd=${data%%/*}

				# Retira os zeros � esquerda (pra n�o confundir com octal)
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

					# Se houver excedente no m�s (>12), recalcula m�s e ano
					yyyy=$(($yyyy + $mm / 12))
					mm=$(($mm % 12))

					# Se negativou, ajusta os c�lculos (voltou um ano)
					if test $mm -le 0
					then
						yyyy=$(($yyyy - 1))
						mm=$((12 + $mm))
					fi
				fi

				# Se o resultado for 29/02 em um ano n�o-bissexto, muda pra 28/02
				test $dd -eq 29 -a $mm -eq 2 &&	! zztool testa_ano_bissexto $yyyy && dd=28

				# Restaura o zero dos meses e dias menores que 10
				[ $dd -le 9 ] && dd="0$dd"
				[ $mm -le 9 ] && mm="0$mm"

				# T� feito, basta montar a data
				echo "$dd/$mm/$yyyy"
				return 0
			;;
		esac

	# C�lculo normal, sem delta
	else
		# Ambas as datas s�o sempre convertidas para inteiros
		test "$tipo1" != 'dias' && dias1=$(zzdata "$data1")
		test "$tipo2" != 'dias' && dias2=$(zzdata "$data2")

		# Soma ou subtrai os valores
		dias=$(($dias1 $operacao $dias2))

		# Se as duas datas foram informadas como dd/mm/aaaa,
		# o resultado � o pr�prio n�mero de dias. Sen�o converte
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
# zzdatafmt
# Muda o formato de uma data, com v�rias op��es de personaliza��o.
# Reconhece datas em v�rios formatos, como aaaa-mm-dd, dd.mm.aaaa e dd/mm.
# Obs.: Se voc� n�o informar o ano, ser� usado o ano corrente.
# Use a op��o --en para usar nomes de meses em ingl�s.
# Use a op��o -f para mudar o formato de sa�da (o padr�o � DD/MM/AAAA):
#
#      C�digo   Exemplo     Descri��o
#      --------------------------------------
#      AAAA     2003        Ano com 4 d�gitos
#      AA       03          Ano com 2 d�gitos
#      A        3           Ano sem zeros � esquerda (1 ou 2 d�gitos)
#      MES      fevereiro   Nome do m�s
#      MMM      fev         Nome do m�s com tr�s letras
#      MM       02          M�s com 2 d�gitos
#      M        2           M�s sem zeros � esquerda
#      DD       01          Dia com 2 d�gitos
#      D        1           Dia sem zeros � esquerda
#
# Uso: zzdatafmt [-f formato] [data]
# Ex.: zzdatafmt 2011-12-31                 # 31/12/2011
#      zzdatafmt 31.12.11                   # 31/12/2011
#      zzdatafmt 31/12                      # 31/12/2011    (ano atual)
#      zzdatafmt -f MES hoje                # maio          (m�s atual)
#      zzdatafmt -f MES --en hoje           # May           (em ingl�s)
#      zzdatafmt -f AAAA 31/12/11           # 2011
#      zzdatafmt -f MM/DD/AA 31/12/2011     # 12/31/11
#      zzdatafmt -f D/M/A 01/02/2003        # 1/2/3
#      zzdatafmt -f "D de MES" 01/05/95     # 1 de maio
#      echo 31/12/2011 | zzdatafmt -f MM    # 12            (via STDIN)
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-24
# Vers�o: 4
# Licen�a: GPL
# Requisitos: zzdata
# Tags: data
# ----------------------------------------------------------------------------
zzdatafmt ()
{
	zzzz -h datafmt "$1" && return

	local data data_orig fmt ano mes dia aaaa aa mm dd a m d ano_atual
	local meses='janeiro fevereiro mar�o abril maio junho julho agosto setembro outubro novembro dezembro'
	local meses_en='January February March April May June July August September October November December'

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			--en)
				meses="$meses_en"
				shift
			;;
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
		hoje|ontem|anteontem|amanh[�a])
			data=$(zzdata "$data")
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

	### Aqui s� chegam datas com a barra / como delimitador
	### Mas elas podem ser parcias, como: dia/m�s

	# Completa elementos que est�o faltando na data
	case "$data" in
		# d/m, dd/m, d/mm, dd/mm
		# Adiciona o ano atual
		[0-9]/[0-9] | [0-9][0-9]/[0-9] | [0-9]/[0-9][0-9] | [0-9][0-9]/[0-9][0-9])
			ano_atual=$(zzdata hoje | cut -d / -f 3)
			data="$data/$ano_atual"
		;;
	esac

	### Aqui s� chegam datas completas, com os tr�s elementos: n/n/n
	### Devo acertar o padding delas pra nn/nn/nnnn

	# Valida o formato da data
	if ! echo "$data" | grep '^[0-9][0-9]\{0,1\}/[0-9][0-9]\{0,1\}/[0-9]\{1,4\}$' >/dev/null
	then
		echo "Erro: Data em formato desconhecido '$data_orig'"
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

	# Ok, agora a data est� no formato correto: dd/mm/aaaa
	data="$dd/$mm/$aaaa"

	# Valida a data
	zztool -e testa_data "$data" || return 1

	# O usu�rio especificou um formato novo?
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
		mmm=$(echo "$mes" | cut -c 1-3)

		# Percorre o formato e vai expandindo, da esquerda para a direita
		while test -n "$fmt"
		do
			case "$fmt" in
				AAAA*) printf %s "$aaaa"; fmt="${fmt#AAAA}";;
				AA*  ) printf %s "$aa"  ; fmt="${fmt#AA}";;
				A*   ) printf %s "$a"   ; fmt="${fmt#A}";;
				MES* ) printf %s "$mes" ; fmt="${fmt#MES}";;
				MMM* ) printf %s "$mmm" ; fmt="${fmt#MMM}";;
				MM*  ) printf %s "$mm"  ; fmt="${fmt#MM}";;
				M*   ) printf %s "$m"   ; fmt="${fmt#M}";;
				DD*  ) printf %s "$dd"  ; fmt="${fmt#DD}";;
				D*   ) printf %s "$d"   ; fmt="${fmt#D}";;
				*    ) printf %c "$fmt" ; fmt="${fmt#?}";;  # 1char
			esac
		done
		echo

	# Sen�o, � s� mostrar no formato normal
	else
		echo "$data"
	fi
}

# ----------------------------------------------------------------------------
# zzdefinr
# http://definr.com
# Busca o significado de um termo, palavra ou express�o no site Definr.
# Uso: zzdefinr termo
# Ex.: zzdefinr headphone
#      zzdefinr in force
#
# Autor: Felipe Arruda <felipemiguel (a) gmail com>
# Desde: 2008-08-15
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdefinr ()
{
	zzzz -h definr "$1" && return

	[ "$1" ] || { zztool uso definr; return 1; }

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
# Com a op��o -n mostra o resultado em forma num�rica (domingo=1).
# Obs.: Se a data n�o for informada, usa a data atual.
# Uso: zzdiadasemana [-n] [data]
# Ex.: zzdiadasemana
#      zzdiadasemana 31/12/2010          # sexta-feira
#      zzdiadasemana -n 31/12/2010       # 6
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-24
# Vers�o: 3
# Licen�a: GPL
# Requisitos: zzdata
# Tags: data
# ----------------------------------------------------------------------------
zzdiadasemana ()
{
	zzzz -h diadasemana "$1" && return

	local data delta dia
	local dias="quinta- sexta- s�bado domingo segunda- ter�a- quarta-"
	local dias_rev="quinta- quarta- ter�a- segunda- domingo s�bado sexta-"
	local dias_n="5 6 7 1 2 3 4"
	local dias_n_rev="5 4 3 2 1 7 6"
	# 1=domingo, assim os n�meros s�o similares aos nomes: 2=segunda

	# Op��o de linha de comando
	if test "$1" = '-n'
	then
		dias="$dias_n"
		dias_rev="$dias_n_rev"
		shift
	fi

	data="$1"

	# Se a data n�o foi informada, usa a atual
	test -z "$data" && data=$(date +%d/%m/%Y)

	# Valida��o
	zztool -e testa_data "$data" || return 1

	# O c�lculo se baseia na data ZERO (01/01/1970), que � quinta-feira.
	# Basta dividir o delta (intervalo de dias at� a data ZERO) por 7.
	# O resto da divis�o � o dia da semana, sendo 0=quinta e 6=quarta.
	#
	# A fun��o zzdata considera 01/01/1970 a data zero, e se chamada
	# apenas com uma data, retorna o n�mero de dias de diferen�a para
	# o dia zero. O n�mero ser� negativo se o ano for inferior a 1970.
	#
	delta=$(zzdata $data)
	dia=$(( ${delta#-} % 7))  # remove o sinal negativo (se tiver)

	# Se a data � anterior a 01/01/1970, conta os dias ao contr�rio
	test $delta -lt 0 && dias="$dias_rev"

	# O cut tem �ndice inicial um e n�o zero, por isso dia+1
	echo "$dias" |
		cut -d ' ' -f $((dia+1)) |
		sed 's/-/-feira/'
}

# ----------------------------------------------------------------------------
# zzdiasuteis
# Calcula o n�mero de dias �teis entre duas datas, inclusive ambas.
# Chamada sem argumentos, mostra os total de dias �teis no m�s atual.
# Obs.: N�o leva em conta feriados.
#
# Uso: zzdiasuteis [data-inicial data-final]
# Ex.: zzdiasuteis                          # Fevereiro de 2013 tem 20 dias 
#      zzdiasuteis 01/01/2011 31/01/2011    # 21
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-20
# Vers�o: 2
# Licen�a: GPL
# Requisitos: zzdata zzdiadasemana zzdatafmt zzcapitalize
# Tags: data, c�lculo
# ----------------------------------------------------------------------------
zzdiasuteis ()
{
	zzzz -h diasuteis "$1" && return

	local data dias dia1 semanas avulsos ini fim hoje mes ano
	local avulsos_uteis=0
	local uteis="0111110"  # D S T Q Q S S
	local data1="$1"
	local data2="$2"

	# Verifica��o dos par�metros
	if test $# -eq 0
	then
		# Sem argumentos, calcula para o m�s atual
		# Exemplo para fev/2013: zzdiasuteis 01/02/2013 28/02/2013
		hoje=$(zzdata hoje)
		data1=$(zzdatafmt -f 01/MM/AAAA $hoje)
		data2=$(zzdata $(zzdata $data1 + 1m) - 1)
		mes=$(zzdatafmt -f MES $hoje | zzcapitalize)
		ano=$(zzdatafmt -f AAAA $hoje)
		echo "$mes de $ano tem $(zzdiasuteis $data1 $data2) dias �teis."
		return 0

	elif test $# -ne 2
	then
		zztool uso diasuteis
		return 1
	fi

	# Valida o formato das datas
	zztool -e testa_data "$data1" || return 1
	zztool -e testa_data "$data2" || return 1

	# Quantos dias h� entre as duas datas?
	dias=$(zzdata $data2 - $data1)

	# O usu�rio inverteu a ordem das datas?
	if test $dias -lt 0
	then
		# Tudo bem, a gente desinverte.
		dias=$((0 - $dias))  # abs()
		data=$data1
		data1=$data2
		data2=$data
	fi

	# A zzdata conta a diferen�a, ent�o precisamos fazer +1 para incluir
	# ambas as datas no resultado.
	dias=$((dias + 1))

	# Qual dia da semana cai a data inicial?
	dia1=$(zzdiadasemana -n $data1)  # 1=domingo

	# Quantas semanas e quantos dias avulsos?
	semanas=$((dias / 7))
	avulsos=$((dias % 7))

	# Dos avulsos, quantos s�o �teis?
	#
	# Montei uma matriz de 14 posi��es ($uteis * 2) que cont�m 0's
	# e 1's, sendo que os 1's marcam os dias �teis. Fa�o um recorte
	# nessa matriz que inicia no $dia1 e tem o tamanho do total de
	# dias avulsos ($avulsos, max=6). As vari�veis $ini e $fim s�o
	# usadas no cut e traduzem este recorte. Por fim, removo os
	# zeros e conto quantos 1's sobraram, que s�o os dias �teis.
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

	# Com os dados na m�o, basta calcular
	echo $(($semanas * 5 + $avulsos_uteis))
}

# ----------------------------------------------------------------------------
# zzdicasl
# http://www.dicas-l.unicamp.br
# Procura por dicas sobre determinado assunto na lista Dicas-L.
# Obs.: As op��es do grep podem ser usadas (-i j� � padr�o).
# Uso: zzdicasl [op��o-grep] palavra(s)
# Ex.: zzdicasl ssh
#      zzdicasl -w vi
#      zzdicasl -vEw 'windows|unix|emacs'
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-08-08
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdicasl ()
{
	zzzz -h dicasl "$1" && return

	local opcao_grep
	local url='http://www.dicas-l.com.br/arquivo/'

	# Guarda as op��es para o grep (caso informadas)
	[ "${1##-*}" ] || {
		opcao_grep=$1
		shift
	}

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dicasl; return 1; }

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
# Tradu��o de uma palavra em ingl�s para v�rios idiomas.
# Franc�s, alem�o, japon�s, italiano, hebreu, espanhol, holand�s e portugu�s.
# Se nenhum idioma for informado, o padr�o � o portugu�s.
# Uso: zzdicbabylon [idioma] palavra   #idioma:dut fre ger heb ita jap ptg spa
# Ex.: zzdicbabylon hardcore
#      zzdicbabylon jap tree
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdicbabylon ()
{
	zzzz -h dicbabylon "$1" && return

	local idioma='ptg'
	local idiomas=' dut fre ger heb ita jap ptg spa '
	local tab=$(echo -e \\t)

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dicbabylon; return 1; }

	# O primeiro argumento � um idioma?
	if [ "${idiomas% $1 *}" != "$idiomas" ]
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
# zzdicjargon
# http://catb.org/jargon/
# Dicion�rio de jarg�es de inform�tica, em ingl�s.
# Uso: zzdicjargon palavra(s)
# Ex.: zzdicjargon vi
#      zzdicjargon all your base are belong to us
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdicjargon ()
{
	zzzz -h dicjargon "$1" && return

	local achei achei2 num mais
	local url='http://catb.org/jargon/html'
	local cache="$ZZTMP.dicjargon"
	local padrao=$(echo "$*" | sed 's/ /-/g')

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dicjargon; return 1; }

	# Se o cache est� vazio, baixa listagem da Internet
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

	[ "$achei" ] || return

	if [ $num -gt 1 ]
	then
		mais=$achei
		achei2=$(echo "$achei" | grep -w "$padrao" | sed 1q)
		[ "$achei2" ] && achei="$achei2" && num=1
	fi

	if [ $num -eq 1 ]
	then
		$ZZWWWDUMP -width=72 "$url/$achei" |
			sed '1,/_\{9\}/d;/_\{9\}/,$d'
		[ "$mais" ] && zztool eco '\nTermos parecidos:'
	else
		zztool eco 'Achei mais de um! Escolha qual vai querer:'
	fi

	[ "$mais" ] && echo "$mais" | sed 's/..// ; s/\.html$//'
}

# ----------------------------------------------------------------------------
# zzdicportugues
# http://www.dicio.com.br
# Dicion�rio de portugu�s.
# Obs.: Ainda n�o funciona com palavras acentuadas :( [issue #41]
# Uso: zzdicportugues palavra
# Ex.: zzdicportugues bolacha
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-02-26
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdicportugues ()
{
	zzzz -h dicportugues "$1" && return

	local url='http://dicio.com.br/pesquisa.php'
	local ini='^Significado de '
	local fim='^Defini��o de '
	local padrao=$(echo $* | sed "$ZZSEDURL")

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dicportugues; return 1; }

	$ZZWWWDUMP "$url?q=$padrao" |
		sed -n "
			/$ini/,/$fim/ {
				/$ini/d
				/$fim/d
				s/^ *//
				p
			}"
}

# ----------------------------------------------------------------------------
# zzdicportugues2
# http://www.dicio.com.br
# Dicion�rio de portugu�s.
# Defini��o de palavras e conjuga��o verbal
# Fornecendo uma "palavra" como argumento retorna seu significado e sin�nimo.
# Se for seguida do termo "def", retorna suas defini��es.
# Se for seguida do termo "conj", retorna todas as formas de conjuga��o.
# Pode-se filtrar pelos modos de conjuga��o, fornecendo ap�s o "conj" o modo
# desejado:
# ind (indicativo), sub (subjuntivo), imp (imperativo), inf (infinitivo)
#
# Uso: zzdicportugues2 palavra [def|conj [ind|sub|conj|imp|inf]]
# Ex.: zzdicportugues2 bolacha
#      zzdicportugues2 verbo conj sub
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net - modicado por Itamar
# Desde: 2011-04-16
# Vers�o: 4
# Licen�a: GPL
# Requisitos: zzsemacento zzminusculas
# ----------------------------------------------------------------------------
zzdicportugues2 ()
{
	zzzz -h dicportugues2 "$1" && return

	local url='http://dicio.com.br'
	local ini='^Significado de '
	local fim='^Defini��o de '
	local palavra=$(echo "$1"| zzminusculas)
	local padrao=$(echo "$palavra" | zzsemacento)
	local contador=1
	local resultado

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dicportugues2; return 1; }

	# Verificando se a palavra confere na pesquisa
	until [ "$resultado" = "$palavra" ]
	do
		resultado=$(
		$ZZWWWDUMP "$url/$padrao" |
			sed -n "
			/$ini/{
				s/$ini//
				s/ *$//
				p
				}" |
			zzminusculas
			)
		[ "$resultado" ] || { zztool eco "Palavra n�o encontrada"; return 1; }

		# Incrementando o contador no padr�o
		padrao=$(echo "$padrao"|sed 's/_[0-9]*$//')
		let contador++
		padrao=${padrao}_${contador}
	done

	# Restabelecendo o contador
	padrao=$(echo "$padrao"|sed 's/_[0-9]*$//')
	let contador--
	padrao=$(echo "${padrao}_${contador}"|sed 's/_1$//')

	case "$2" in
	def) ini='^Defini��o de '; fim=' escrita ao contr�rio: ' ;;
	conj)
		ini='Infinitivo:'; fim='\(Rimas com \|Anagramas de \)'
		case "$3" in
			ind) ini=' *\(INDICATIVO\|Indicativo\)'; fim='^ *\(SUBJUNTIVO\|Subjuntivo\)' ;;
			sub|conj) ini='^ *\(SUBJUNTIVO\|Subjuntivo\)'; fim='^ *\(IMPERATIVO\|Imperativo\)' ;;
			imp) ini='^ *\(IMPERATIVO\|Imperativo\)'; fim='^ *\(INFINITIVO\|Infinitivo\)' ;;
			inf) ini='^ *\(INFINITIVO\|Infinitivo\) *$' ;;
		esac
	;;
	esac

	case "$2" in
	conj)
		$ZZWWWDUMP "$url/$padrao" |
			sed -n "
			/$ini/,/$fim/ {
				/^ *\(INDICATIVO\|Indicativo\) *$/d
				/^ *\(SUBJUNTIVO\|Subjuntivo\) *$/d
				#/^ *\(CONJUNTIVO\|Conjuntivo\) *$/d
				/^ *\(IMPERATIVO\|Imperativo\) *$/d
				/^ *\(INFINITIVO\|Infinitivo\) *$/d
				/\(Rimas com \|Anagramas de \)/d
				/^ *$/d
				s/^ *//
				s/^\*/\n&/
				#s/ do \(Indicativo\|Subjuntivo\|Conjuntivo\)/&\n/
				#s/\* Imperativo \(Afirmativo\|Negativo\)/&\n/
				#s/\* Imperativo/&\n/
				#s/\* Infinitivo Pessoal/&\n/
				s/^[a-z]/ &/g
				p
				}"
	;;
	*)
		$ZZWWWDUMP "$url/$padrao" |
			sed -n "
			/$ini/,/$fim/ {
				/$ini/d
				/^Defini��o de /d
				p
				}
			/Infinitivo:/,/Partic�pio passado:/p"
	;;
	esac
}

# ----------------------------------------------------------------------------
# zzdiffpalavra
# Mostra a diferen�a entre dois textos, palavra por palavra.
# �til para conferir revis�es ortogr�ficas ou mudan�as pequenas em frases.
# Obs.: Se tiver muitas *linhas* diferentes, use o comando diff.
# Uso: zzdiffpalavra arquivo1 arquivo2
# Ex.: zzdiffpalavra texto-orig.txt texto-novo.txt
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-07-23
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdiffpalavra ()
{
	zzzz -h diffpalavra "$1" && return

	local esc
	local tmp1="$ZZTMP.diffpalavra.$$.1"
	local tmp2="$ZZTMP.diffpalavra.$$.2"
	local n=$(printf '\a')

	# Verifica��o dos par�metros
	[ $# -ne 2 ] && { zztool uso diffpalavra; return 1; }

	# Verifica se os arquivos existem
	zztool arquivo_legivel "$1" || return
	zztool arquivo_legivel "$2" || return

	# Deixa uma palavra por linha e marca o in�cio de par�grafos
	sed "s/^[[:blank:]]*$/$n$n/;" "$1" | tr ' ' '\n' > "$tmp1"
	sed "s/^[[:blank:]]*$/$n$n/;" "$2" | tr ' ' '\n' > "$tmp2"

	# Usa o diff para comparar as diferen�as e formata a sa�da,
	# agrupando as palavras para facilitar a leitura do resultado
	diff -U 100 "$tmp1" "$tmp2" |
		sed 's/^ /=/' |
		sed '
			# Script para agrupar linhas consecutivas de um mesmo tipo.
			# O tipo da linha � o seu primeiro caractere. Ele n�o pode
			# ser um espa�o em branco.
			#     +um
			#     +dois
			#     .one
			#     .two
			# vira:
			#     +um dois
			#     .one two

			# Apaga os cabe�alhos do diff
			1,3 d

			:join

			# Junta linhas consecutivas do mesmo tipo
			N

			# O espa�o em branco � o separador
			s/\n/ /

			# A linha atual � do mesmo tipo da anterior?
			/^\(.\).* \1[^ ]*$/ {

				# Se for a �ltima linha, mostra tudo e sai
				$ s/ ./ /g
				$ q

				# Caso contr�rio continua juntando...
				b join
			}
			# Opa, linha diferente (antiga \n antiga \n ... \n nova)

			# Salva uma c�pia completa
			h

			# Apaga a �ltima linha (nova) e mostra as anteriores
			s/\(.*\) [^ ]*$/\1/
			s/ ./ /g
			p

			# Volta a c�pia, apaga linhas antigas e come�a de novo
			g
			s/.* //
			$ !b join
			# Mas se for a �ltima linha, acabamos por aqui' |
		sed 's/^=/ /' |

		# Restaura os par�grafos
		tr "$n" '\n' |

		# Podemos mostrar cores?
		if [ "$ZZCOR" = 1 ]
		then
			# Pinta as linhas antigas de vermelho e as novas de azul
			esc=$(printf '\033')
			sed "
				s/^-.*/$esc[31;1m&$esc[m/
				s/^+.*/$esc[36;1m&$esc[m/"
		else
			# Sem cores? Que chato. S� mostra ent�o.
			cat -
		fi

	rm -f "$tmp1" "$tmp2"
}

# ----------------------------------------------------------------------------
# zzdolar
# http://economia.terra.com.br
# Busca a cota��o do dia do d�lar (comercial, turismo e PTAX).
# Uso: zzdolar
# Ex.: zzdolar
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Vers�o: 4
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdolar ()
{
	zzzz -h dolar "$1" && return

	local resultado

	# Faz a consulta e filtra o resultado
	resultado=$(
		$ZZWWWDUMP 'http://economia.terra.com.br/stock/divisas.aspx' |
		egrep  'D�lar (Comercial|Turismo|PTAX)�' |
		sed 3q |
		sed '
			# Linha original:
			# D�lar Comercial� DOLCM   1,9733 1,9738 0,00 -0,03 %  03h09

			# faxina
			s/^  *D�lar //
			s/�/ /

			# espa�amento dos valores
			s/ [0-9],[0-9][0-9][0-9][0-9]/  &/g

			# remove varia��o percentual 
			s/ -\{0,1\}[0-9],[0-9][0-9] .*%  */   /
		'
	)

	if test "$resultado"
	then
		echo '                     Compra   Venda'
		echo "$resultado"
	fi
}

# ----------------------------------------------------------------------------
# zzdominiopais
# http://www.iana.org/cctld/cctld-whois.htm
# Busca a descri��o de um c�digo de pa�s da internet (.br, .ca etc).
# Uso: zzdominiopais [.]c�digo|texto
# Ex.: zzdominiopais .br
#      zzdominiopais br
#      zzdominiopais republic
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-15
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdominiopais ()
{
	zzzz -h dominiopais "$1" && return

	local url='http://www.iana.org/root-whois/index.html'
	local cache="$ZZTMP.dominiopais"
	local cache_sistema='/usr/share/zoneinfo/iso3166.tab'
	local padrao=$1

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dominiopais; return 1; }

	# Se o padr�o inicia com ponto, retira-o e casa somente c�digos
	if [ "${padrao#.}" != "$padrao" ]
	then
		padrao="^${padrao#.}"
	fi

	# Primeiro tenta encontrar no cache do sistema
	if test -f "$cache_sistema"
	then
		# O formato padr�o de sa�da � BR - Brazil
		grep -i "$padrao" $cache_sistema |
			tr -s '\t ' ' ' |
			sed '/^#/d ; / - /!s/ / - /'
		return
	fi

	# Ops, n�o h� cache do sistema, ent�o tentamos o cache da Internet

	# Se o cache est� vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		$ZZWWWDUMP "$url" |
			sed -n 's/^  *\.// ; s/country-code/-/p' > "$cache"
	fi

	# Pesquisa no cache
	grep -i "$padrao" "$cache"
}

# ----------------------------------------------------------------------------
# zzdos2unix
# Converte arquivos texto no formato Windows/DOS (CR+LF) para o Unix (LF).
# Obs.: Tamb�m remove a permiss�o de execu��o do arquivo, caso presente.
# Uso: zzdos2unix arquivo(s)
# Ex.: zzdos2unix frases.txt
#      cat arquivo.txt | zzdos2unix
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdos2unix ()
{
	zzzz -h dos2unix "$1" && return

	local arquivo
	local tmp="$ZZTMP.dos2unix.$$"
	local control_m=$(printf '\r')  # ^M, CR, \r

	# Sem argumentos, l�/grava em STDIN/STDOUT
	if test $# -eq 0
	then
		sed "s/$control_m*$//"

		# Facinho, terminou j�
		return
	fi

	# Usu�rio passou uma lista de arquivos
	# Os arquivos ser�o sobrescritos, todo cuidado � pouco
	for arquivo
	do
		# O arquivo existe?
		zztool arquivo_legivel "$arquivo" || continue

		# Remove o \r
		cp "$arquivo" "$tmp" &&
		sed "s/$control_m*$//" "$tmp" > "$arquivo"

		# Seguran�a
		if [ $? -ne 0 ]
		then
			echo "Ops, algum erro ocorreu em $arquivo"
			echo "Seu arquivo original est� guardado em $tmp"
			return 1
		fi

		# Remove a permiss�o de execu��o, comum em arquivos DOS
		chmod -x "$arquivo"

		echo "Convertido $arquivo"
	done

	# Remove o arquivo tempor�rio
	rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# zzecho
# Mostra textos coloridos, sublinhados e piscantes no terminal (c�digos ANSI).
# Op��es: -f, --fundo       escolhe a cor de fundo
#         -l, --letra       escolhe a cor da letra
#         -p, --pisca       texto piscante
#         -s, --sublinhado  texto sublinhado
#         -N, --negrito     texto em negrito (brilhante em alguns terminais)
#         -n, --nao-quebra  n�o quebra a linha no final, igual ao echo -n
# Cores: preto vermelho verde amarelo azul roxo ciano branco
# Obs.: \t, \n e amigos s�o sempre interpretados (igual ao echo -e).
# Uso: zzecho [-f cor] [-l cor] [-p] [-s] [-N] [-n] [texto]
# Ex.: zzecho -l amarelo Texto em amarelo
#      zzecho -f azul -l branco -N Texto branco em negrito, com fundo azul
#      zzecho -p -s Texto piscante e sublinhado
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-09-02
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzecho ()
{
	zzzz -h echo "$1" && return

	local letra fundo negrito cor pisca sublinhado
	local quebra_linha='\n'

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			-l|--letra)
				case "$2" in
					# Permite vers�es femininas tamb�m (--letra preta)
					pret[oa]     ) letra=';30' ;;
					vermelh[oa]  ) letra=';31' ;;
					verde        ) letra=';32' ;;
					amarel[oa]   ) letra=';33' ;;
					azul         ) letra=';34' ;;
					rox[oa]|rosa ) letra=';35' ;;
					cian[oa]     ) letra=';36' ;;
					branc[oa]    ) letra=';37' ;;
					*) zztool uso echo; return 1 ;;
				esac
				shift
			;;
			-f|--fundo)
				case "$2" in
					preto     ) fundo='40' ;;
					vermelho  ) fundo='41' ;;
					verde     ) fundo='42' ;;
					amarelo   ) fundo='43' ;;
					azul      ) fundo='44' ;;
					roxo|rosa ) fundo='45' ;;
					ciano     ) fundo='46' ;;
					branco    ) fundo='47' ;;
					*) zztool uso echo; return 1 ;;
				esac
				shift
			;;
			-N|--negrito    ) negrito=';1'    ;;
			-p|--pisca      ) pisca=';5'      ;;
			-s|--sublinhado ) sublinhado=';4' ;;
			-n|--nao-quebra ) quebra_linha='' ;;
			*) zztool uso echo; return 1 ;;
		esac
		shift
	done

	# Mostra c�digos ANSI somente quando necess�rio (e quando ZZCOR estiver ligada)
	if [ "$ZZCOR" != '1' -o "$fundo$letra$negrito$pisca$sublinhado" = '' ]
	then
		printf "$*$quebra_linha"
	else
		printf "\033[$fundo$letra$negrito$pisca${sublinhado}m$*\033[m$quebra_linha"
	fi
}

# ----------------------------------------------------------------------------
# zzenglish
# http://www.dict.org
# Busca defini��es em ingl�s de palavras da l�ngua inglesa em DICT.org.
# Uso: zzenglish palavra-em-ingl�s
# Ex.: zzenglish momentum
#
# Autor: Luciano ES
# Desde: 2008-09-07
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzenglish ()
{
	zzzz -h english "$1" && return

	[ "$1" ] || { zztool uso english; return 1; }

	local url="http://www.dict.org/bin/Dict/"
	local query="Form=Dict1&Query=$1&Strategy=*&Database=*&submit=Submit query"

	echo "$query" |
		$ZZWWWPOST "$url" |
		sed "
			# pega o trecho da p�gina que nos interessa
			/[0-9]\{1,\} definitions\{0,1\} found/,/_______________/!d
			s/____*//

			# protege os colchetes dos sin�nimos contra o cinza escuro
			s/\[syn:/@SINONIMO@/g

			# aplica cinza escuro em todos os colchetes (menos sin�nimos)
			s/\[/$(printf '\033[0;34m')[/g

			# aplica verde nos colchetes dos sin�nimos
			s/@SINONIMO@/$(printf '\033[0;32;1m')[syn:/g

			# \"fecha\" as cores de todos os sin�nimos
			s/\]/]$(printf '\033[m')/g

			# pinta a pron�ncia de amarelo - pode estar delimitada por \\ ou //
			s/\(\\\\[^\\]\{1,\}\\\\\)/$(printf '\033[0;33;1m')\\1\\$(printf '\033[m')/g
			s|\(/[^/]\+/\)|$(printf '\033[0;33;1m')\1$(printf '\033[m')|g

			# cabe�alho para tornar a separa��o entre v�rias consultas mais vis�vel no terminal
			/[0-9]\{1,\} definitions\{0,1\} found/ {
				H
				s/.*/==================== DICT.ORG ====================/
				p
				x
			}"
}

# ----------------------------------------------------------------------------
# zzenviaemail
# Envia email via ssmtp.
# Op��es:
#   -h, --help     exibe a ajuda.
#   -v, --verbose  exibe informa��es para debug durante o processamento.
#   -V, --version  exibe a vers�o.
#   -f, --from     email do remetente.
#   -t, --to       email dos destinat�rios (separe com v�rgulas, sem espa�o).
#   -c, --cc       email dos destinat�rios em c�pia (v�rgulas, sem espa�o).
#   -b, --bcc      emails em c�pia oculta (v�rgulas, sem espa�o).
#   -s, --subject  o assunto do email.
#   -e, --mensagem arquivo que cont�m a mensagem/corpo do email.
# Uso: zzenviaemail -f email -t email [-c email] [-b email] -s assunto -m msg
# Ex.: zzenviaemail -f quem_envia@dominio.com -t quem_recebe@dominio.com \
#      -s "Teste de e-mail" -m "./arq_msg.eml"
#
# Autor: Lauro Cavalcanti de Sa <lauro (a) ecdesa com>
# Desde: 2009-09-17
# Vers�o: 20091010
# Licen�a: GPLv2
# Requisitos: ssmtp
# ----------------------------------------------------------------------------
zzenviaemail ()
{
	zzzz -h enviaemail "$1" && return

	# Declara variaveis.
	local fromail tomail ccmail bccmail subject msgbody
	local envia_data=`date +"%Y%m%d_%H%M%S_%N"`
	local script_eml="${ZZTMPDIR}/.${FUNCNAME}_${envia_data}.eml"
	local nparam=0

	# Opcoes de linha de comando
	while [ $# -ge 1 ]
	do
		case "$1" in
			-f | --from)
				[ "$2" ] || { zztool uso enviaemail; set +x; return 1; }
				fromail=$2
				nparam=$(($nparam + 1))
				shift
				;;
			-t | --to)
				[ "$2" ] || { zztool uso enviaemail; set +x; return 1; }
				tomail=$2
				nparam=$(($nparam + 1))
				shift
				;;
			-c | --cc)
				[ "$2" ] || { zztool uso enviaemail; set +x; return 1; }
				ccmail=$2
				shift
				;;
			-b | --bcc)
				[ "$2" ] || { zztool uso enviaemail; set +x; return 1; }
				bccmail=$2
				shift
				;;
			-s | --subject)
				[ "$2" ] || { zztool uso enviaemail; set +x; return 1; }
				subject=$2
				nparam=$(($nparam + 1))
				shift
				;;
			-m | --mensagem)
				[ "$2" ] || { zztool uso enviaemail; set +x; return 1; }
				mensagem=$2
				nparam=$(($nparam + 1))
				shift
				;;
			-v | --verbose)
				set -x
				;;
			*) { zztool uso enviaemail; set +x; return 1; } ;;
		esac
		shift
	done

	# Verifica numero minimo de parametros.
	if [ "${nparam}" != 4 ] ; then
		{ zztool uso enviaemail; set +x; return 1; }
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
	ssmtp -F ${1} ${tomail} ${ccmail} ${bccmail} < ${script_eml}
	if [ -s "${script_eml}" ] ; then
		rm -f "${script_eml}"
	fi

	set +x
}

# ----------------------------------------------------------------------------
# zzestado
# Lista os estados do Brasil e suas capitais.
# Obs.: Sem argumentos, mostra a lista completa.
#
# Op��es: --sigla        Mostra somente as siglas
#         --nome         Mostra somente os nomes
#         --capital      Mostra somente as capitais
#         --slug         Mostra somente os slugs (nome simplificado)
#         --formato FMT  Voc� escolhe o formato de sa�da, use os tokens:
#                        {sigla}, {nome}, {capital}, {slug}, \n , \t
#         --python       Formata como listas/dicion�rios do Python
#         --javascript   Formata como arrays do JavaScript
#         --php          Formata como arrays do PHP
#         --html         Formata usando a tag <SELECT> do HTML
#         --url,--url2   Exemplos simples de uso da op��o --formato
#
# Uso: zzestado [--OP��O]
# Ex.: zzestado                      # [mostra a lista completa]
#      zzestado --sigla              # AC AL AP AM BA 
#      zzestado --html               # <option value="AC">AC - Acre</option> 
#      zzestado --python             # siglas = ['AC', 'AL', 'AP', 
#      zzestado --formato '{sigla},'             # AC,AL,AP,AM,BA,
#      zzestado --formato '{sigla} - {nome}\n'   # AC - Acre 
#      zzestado --formato '{capital}-{sigla}\n'  # Rio Branco-AC 
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-21
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzestado ()
{
	zzzz -h estado "$1" && return

	local sigla nome slug capital fmt resultado

	# {sigla}:{nome}:{slug}:{capital}
	local dados="\
AC:Acre:acre:Rio Branco
AL:Alagoas:alagoas:Macei�
AP:Amap�:amapa:Macap�
AM:Amazonas:amazonas:Manaus
BA:Bahia:bahia:Salvador
CE:Cear�:ceara:Fortaleza
DF:Distrito Federal:distrito-federal:Bras�lia
ES:Esp�rito Santo:espirito-santo:Vit�ria
GO:Goi�s:goias:Goi�nia
MA:Maranh�o:maranhao:S�o Lu�s
MT:Mato Grosso:mato-grosso:Cuiab�
MS:Mato Grosso do Sul:mato-grosso-do-sul:Campo Grande
MG:Minas Gerais:minas-gerais:Belo Horizonte
PA:Par�:para:Bel�m
PB:Para�ba:paraiba:Jo�o Pessoa
PR:Paran�:parana:Curitiba
PE:Pernambuco:pernambuco:Recife
PI:Piau�:piaui:Teresina
RJ:Rio de Janeiro:rio-de-janeiro:Rio de Janeiro
RN:Rio Grande do Norte:rio-grande-do-norte:Natal
RS:Rio Grande do Sul:rio-grande-do-sul:Porto Alegre
RO:Rond�nia:rondonia:Porto Velho
RR:Roraima:roraima:Boa Vista
SC:Santa Catarina:santa-catarina:Florian�polis
SP:S�o Paulo:sao-paulo:S�o Paulo
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
			(
				IFS=:
				while read sigla nome slug capital
				do
					resultado=$(echo "$fmt" | sed "
						s/{sigla}/$sigla/g
						s/{nome}/$nome/g
						s/{slug}/$slug/g
						s/{capital}/$capital/g
					")
					printf "$resultado"
				done
			)
		;;
		--python|--py)
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
		--javascript|--js)
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
		--url)
			zzestado --formato 'http://foo.{sigla}.gov.br\n' | tr '[A-Z]' '[a-z]'
		;;
		--url2)
			zzestado --formato 'http://foo.com.br/{slug}/\n'
		;;
		*)
			zzestado --formato '{sigla}\t{nome}\t{capital}\n' | expand -t 6,29
		;;
	esac
}

# ----------------------------------------------------------------------------
# zzextensao
# Informa a extens�o de um arquivo.
# Obs.: Caso o arquivo n�o possua extens�o, retorna vazio "".
# Uso: zzextensao arquivo
# Ex.: zzextensao /tmp/arquivo.txt       # resulta em "txt"
#      zzextensao /tmp/arquivo           # resulta em ""
#
# Autor: Lauro Cavalcanti de Sa <lauro (a) ecdesa com>
# Desde: 2009-09-21
# Vers�o: 2
# Licen�a: GPLv2
# ----------------------------------------------------------------------------
zzextensao ()
{
	zzzz -h extensao "$1" && return

	# Declara variaveis.
	local nome_arquivo extensao arquivo

	[ "$1" ] || { zztool uso extensao; return 1; }


	arquivo="$1"

	# Extrai a extensao.
	nome_arquivo=`echo "$arquivo" | awk 'BEGIN { FS = "/" } END { print $NF }'`
	extensao=`echo "$nome_arquivo" | awk 'BEGIN { FS = "." } END { print $NF }'`
	if [ "$extensao" = "$nome_arquivo" -o ".$extensao" = "$nome_arquivo" ] ; then
		extensao=""
	fi
	echo "$extensao"
}

# ----------------------------------------------------------------------------
# zzfeed
# Leitor de Feeds RSS e Atom.
# Se informar a URL de um feed, s�o mostradas suas �ltimas not�cias.
# Se informar a URL de um site, mostra a URL do(s) Feed(s).
# Obs.: Use a op��o -n para limitar o n�mero de resultados (Padr�o � 10).
#
# Uso: zzfeed [-n n�mero] URL...
# Ex.: zzfeed http://aurelio.net/feed/
#      zzfeed -n 5 aurelio.net/feed/          # O http:// � opcional
#      zzfeed aurelio.net funcoeszz.net       # Mostra URL dos feeds
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-03
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzxml zzunescape
# ----------------------------------------------------------------------------
zzfeed ()
{
	zzzz -h feed "$1" && return

	local url formato tag_mae
	local limite=10
	local tmp="$ZZTMP.feed.$$"

	# Op��es de linha de comando
	if test "$1" = '-n'
	then
		limite=$2
		shift
		shift
	fi

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso feed; return 1; }

	# Verifica��o b�sica
	if ! zztool testa_numero "$limite"
	then
		echo "N�mero inv�lido para a op��o -n: $limite"
		return 1
	fi

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

	# Para cada URL que o usu�rio informou...
	for url
	do
		# S� mostra a url se houver mais de uma
		[ $# -gt 1 ] && zztool eco "* $url"

		# Baixa e limpa o conte�do do feed
		$ZZWWWHTML "$url" | zzxml --tidy > "$tmp"

		# Tenta identificar o formato: <feed> � Atom, <rss> � RSS
		formato=$(grep -e '^<feed[ >]' -e '^<rss[ >]' "$tmp")

		# Afinal, isso � um feed ou n�o?
		if test -n "$formato"
		then
			### � um feed, vamos mostrar as �ltimas not�cias.
			# Atom ou RSS, as manchetes est�o sempre na tag <title>,
			# que por sua vez est� dentro de <item> ou <entry>.

			if zztool grep_var '<rss' "$formato"
			then
				tag_mae='item'
			else
				tag_mae='entry'
			fi

			# Extrai as tags <title> e formata o resultado
			cat "$tmp" |
				zzxml --tag $tag_mae |
				zzxml --tag 'title' --untag |
				sed "$limite q" |
				zzunescape --html |
				zztool trim
		else
			### N�o � um feed, pode ser um site normal.
			# Vamos tentar descobrir o endere�o do(s) Feed(s).
			# <link rel="alternate" type="application/rss+xml" href="http://...">

			cat "$tmp" |
				grep -i \
					-e '^<link .*application/rss+xml' \
					-e '^<link .*application/atom+xml' |
				# Se n�o tiver href= n�o vale (o site do Terra � um exemplo)
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

		# Tem mais de um site pra procurar?
		continue
	done
}

# ----------------------------------------------------------------------------
# zzferiado
# Verifica se a data passada por par�metro � um feriado ou n�o.
# Caso n�o seja passado nenhuma data � pego a data atual.
# Pode-se configurar a vari�vel ZZFERIADO para os feriados regionais.
# O formato � o dd/mm:descri��o, por exemplo: 20/11:Consci�ncia negra.
# Uso: zzferiado -l [ano] | [data]
# Ex.: zzferiado 25/12/2008
#      zzferiado -l
#      zzferiado -l 2010
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-11-21
# Vers�o: 6
# Licen�a: GPLv2
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

	# Verifica se foi passado o par�metro -l
	if [ "$1" = "-l" ]; then
		# Se n�o for passado $2 pega o ano atual
		ano=${2:-$(basename $hoje)}

		# Seta a flag listar
		listar=1

		# Teste da vari�vel ano
		zztool -e testa_ano $ano || return 1
	else
		# Se n�o for passada a data � pega a data de hoje
		data=${1:-$hoje}

		# Verifica se a data � valida
		zztool -e testa_data "$data" || return 1

		# Uma coisa interessante, como data pode ser usada com /(20/11/2008)
		# podemos usar o basename e dirname para pegar o que quisermos
		# Ex.: dirname 25/12/2008 ->  25/12
		#      basename 25/12/2008 -> 2008
		#
		# Pega s� o dia e o mes no formato: dd/mm
		data=$(dirname $data)
		ano=$(basename ${1:-$hoje})
	fi

	# Para feriados Estaduais ou regionais Existe a vari�vel de
	# ambiente ZZFERIADO que pode ser configurada no $HOME/.bashrc e
	# colocar as datas com dd/mm:descricao
	carnaval=$(dirname $(zzcarnaval $ano ) )
	sextapaixao=$(dirname $(zzsextapaixao $ano ) )
	corpuschristi=$(dirname $(zzcorpuschristi $ano ) )
	feriados="01/01:Confraterniza��o Universal $carnaval:Carnaval $sextapaixao:Sexta-ferida da Paixao 21/04:Tiradentes 01/05:Dia do Trabalho $corpuschristi:Corpu Christi 07/09:Independ�ncia do Brasil 12/10:Nossa Sra. Aparecida 02/11:Finados 15/11:Proclama��o da Rep�blica 25/12:Natal $ZZFERIADO"

	# Verifica se lista ou nao, caso negativo verifica se a data escolhida � feriado
	if [ "$listar" = "1" ]; then

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
				sed 's/terca-feira/ter�a-feira/ ; s/ sabado / s�bado /'
			# ^ Estou tirando os acentos do dia da semana e depois recolocando
			# pois o printf n�o lida direito com acentos. O %-15s n�o fica
			# exatamente com 15 caracteres quando h� acentos.
		done
	else
		# Verifica se a data est� dentro da lista de feriados
		# e imprime o resultado
		if zztool grep_var "$data" "$feriados"; then
			echo "� feriado: $data/$ano"
		else
			echo "N�o � feriado: $data/$ano"
		fi
	fi

	return 0
}

# ----------------------------------------------------------------------------
# zzfoneletra
# Convers�o de telefones contendo letras para apenas n�meros.
# Uso: zzfoneletra telefone
# Ex.: zzfoneletra 2345-LINUX              # Retorna 2345-54689
#      echo 5555-HELP | zzfoneletra        # Retorna 5555-4357
#
# Autor: Rodolfo de Faria <rodolfo faria (a) fujifilm com br>
# Desde: 2006-10-17
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzmaiusculas
# ----------------------------------------------------------------------------
zzfoneletra ()
{
	zzzz -h foneletra "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |
		zzmaiusculas |
		sed y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/
		# Um Sed faz tudo, � uma tradu��o letra a letra
}

# ----------------------------------------------------------------------------
# zzfrenteverso2pdf
# Combina 2 arquivos, frentes.pdf e versos.pdf, em um �nico frenteverso.pdf.
# Op��es:
#   -rf, --frentesreversas  informa ordem reversa no arquivo frentes.pdf.
#   -rv, --versosreversos   informa ordem reversa no arquivo versos.pdf.
#    -d, --diretorio        informa o diret�rio de entrada/sa�da. Padrao=".".
#    -v, --verbose          exibe informa��es de debug durante a execu��o.
# Uso: zzfrenteverso2pdf [-rf] [-rv] [-d diretorio]
# Ex.: zzfrenteverso2pdf
#      zzfrenteverso2pdf -rf
#      zzfrenteverso2pdf -rv -d "/tmp/dir_teste"
#
# Autor: Lauro Cavalcanti de Sa <lauro (a) ecdesa com>
# Desde: 2009-09-17
# Vers�o: 20101222
# Licen�a: GPLv2
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
	while [ $# -ge 1 ]
	do
		case "$1" in
			-rf | --frentesreversas) sinal_frente="-" ;;
			-rv | --versosreversos) sinal_verso="-" ;;
			-d | --diretorio)
				[ "$2" ] || { zztool uso frenteverso2pdf; return 1; }
				dir=$2
				shift
				;;
			-v | --verbose)
				set -x
				;;
			*) { zztool uso frenteverso2pdf; set +x; return 1; } ;;
		esac
		shift
	done

	# Verifica se os arquivos existem.
	if [ ! -s "$dir/$arq_frentes" -o ! -s "$dir/$arq_versos" ] ; then
		echo "ERRO: Um dos arquivos $dir/$arq_frentes ou $dir/$arq_versos nao existe!"
		return 1
	fi

	# Determina o numero de paginas de cada arquivo.
	n_frentes=`pdftk "$dir/$arq_frentes" dump_data | grep "NumberOfPages" | cut -d" " -f2`
	n_versos=`pdftk "$dir/$arq_versos" dump_data | grep "NumberOfPages" | cut -d" " -f2`

	# Verifica a compatibilidade do numero de paginas entre os dois arquivos.
	dif=`expr $n_frentes - $n_versos`
	if [ $dif -lt 0 -o $dif -gt 1 ] ; then
		echo "CUIDADO: O numero de paginas dos arquivos nao parecem compativeis!"
	fi

	# Cria ordenacao das paginas.
	if [ "$sinal_frente" = "-" ] ; then
		ini_frente=`expr $n_frentes + 1`
	fi
	if [ "$sinal_verso" = "-" ] ; then
		ini_verso=`expr $n_versos + 1`
	fi

	while [ $n_pag -le $n_frentes ] ; do
		n_pag_frente=`expr $ini_frente $sinal_frente $n_pag`
		numberlist="$numberlist A$n_pag_frente"
		n_pag_verso=`expr $ini_verso $sinal_verso $n_pag`
		if [ $n_pag -le $n_versos ]; then
			numberlist="$numberlist B$n_pag_verso"
		fi
		n_pag=$(($n_pag + 1))
	done

	# Cria arquivo mesclado.
	pdftk A="$dir/$arq_frentes" B="$dir/$arq_versos" cat $numberlist output "$dir/frenteverso.pdf" dont_ask

}

# ----------------------------------------------------------------------------
# zzfreshmeat
# http://freshmeat.net
# Procura por programas na base do site Freshmeat.
# Uso: zzfreshmeat programa
# Ex.: zzfreshmeat tetris
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-09-20
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzfreshmeat ()
{
	zzzz -h freshmeat "$1" && return

	local url='http://freecode.com/search/'
	local padrao=$1

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso freshmeat; return 1; }

	# Faz a consulta e filtra o resultado
	$ZZWWWLIST "$url?q=$padrao" |
		sed -n 's@.*\(http://freecode.com/projects/.*\)@\1@p' |
		grep -v '/projects/new' |
		sort |
		uniq
}

# ----------------------------------------------------------------------------
# zzglobo
# Mostra a programa��o Rede Globo do dia.
# Uso: zzglobo
# Ex.: zzglobo
#
# Autor: Vin�cius Ven�ncio Leite <vv.leite (a) gmail com>
# Desde: 2007-11-30
# Vers�o: 3
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzglobo ()
{
	zzzz -h globo "$1" && return

	local DATA=`date +%d | sed 's/^0//'`
	local URL="http://diversao.terra.com.br/tv/noticias/0,,OI3512347-EI13439,00-Programacao+da+TV+Globo.html"

	$ZZWWWDUMP "$URL" |
		sed -n "/[Segunda|Ter�a|Quarta|Quinta|Sexta|S�bado|Domingo], $DATA de /,/[Segunda|Ter�a|Quarta|Quinta|Sexta|S�bado|Domingo], .*/p" | sed '$d' |
		uniq
}

# ----------------------------------------------------------------------------
# zzgoogle
# http://google.com
# Pesquisa no Google diretamente pela linha de comando.
# Uso: zzgoogle [-n <n�mero>] palavra(s)
# Ex.: zzgoogle receita de bolo de abacaxi
#      zzgoogle -n 5 ramones papel higi�nico cachorro
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-04-03
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
# FIXME: zzgoogle rato roeu roupa rei roma [PPS], [PDF]
zzgoogle ()
{
	zzzz -h google "$1" && return

	local padrao
	local limite=10
	local url='http://www.google.com.br/search'

	# Op��es de linha de comando
	if [ "$1" = '-n' ]
	then
		limite="$2"
		shift
		shift

		zztool -e testa_numero "$limite" || return 1
	fi

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso google; return 1; }

	# Prepara o texto a ser pesquisado
	padrao=$(echo "$*" | sed "$ZZSEDURL")
	[ "$padrao" ] || return 0

	# Pesquisa, baixa os resultados e filtra
	#
	# O Google condensa tudo em um �nica longa linha, ent�o primeiro � preciso
	# inserir quebras de linha antes de cada resultado. Identificadas as linhas
	# corretas, o filtro limpa os lixos e formata o resultado.

	$ZZWWWHTML -cookies "$url?q=$padrao&num=$limite&ie=ISO-8859-1&oe=ISO-8859-1&hl=pt-BR" |
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
# Op��es: -t, --tamanho N      Tamanho do avatar (padr�o 80, m�x 512)
#         -d, --default TIPO   Tipo do avatar substituto, se n�o encontrado
#
# Se n�o houver um avatar para o email, a op��o --default informa que tipo
# de avatar substituto ser� usado em seu lugar:
#     mm          Mistery Man, a silhueta de uma pessoa (n�o muda)
#     identicon   Padr�o geom�trico, muda conforme o email
#     monsterid   Monstros, muda cores e rostos
#     wavatar     Rostos, muda caracter�sticas e cores
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
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzmd5 zzminusculas
# ----------------------------------------------------------------------------
zzgravatar ()
{
	zzzz -h gravatar "$1" && return

	# Instru��es de implementa��o:
	# http://gravatar.com/site/implement/
	#
	# Exemplo de URL do Gravatar, com tamanho de 96 e MisteryMan:
	# http://www.gravatar.com/avatar/e583bca48acb877efd4a29229bf7927f?size=96&default=mm

	local email default extra codigo
	local tamanho=80  # padr�o caso n�o informado � 80
	local tamanho_maximo=512
	local defaults="mm:identicon:monsterid:wavatar:retro"
	local url='http://www.gravatar.com/avatar/'

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			-t|--tamanho)
				tamanho="$2"
				extra="$extra&size=$tamanho"
				shift
				shift
			;;
			-d| --default)
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

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso gravatar; return 1; }

	# Guarda o email informado, sempre em min�sculas
	email=$(zztool trim "$1" | zzminusculas)

	# Foi passado um n�mero mesmo?
	if ! zztool testa_numero "$tamanho" || test "$tamanho" = 0
	then
		echo "N�mero inv�lido para a op��o -t: $tamanho"
		return 1
	fi

	# Temos uma limita��o de tamanho
	if [ $tamanho -gt $tamanho_maximo ]
	then
		echo "O tamanho m�ximo para a imagem � $tamanho_maximo"
		return 1
	fi

	# O default informado � v�lido?
	if test -n "$default" && ! zztool grep_var ":$default:"  ":$defaults:"
	then
		echo "Valor inv�lido para a op��o -d: '$default'"
		return 1
	fi

	# Calcula o hash do email
	codigo=$(printf "$email" | zzmd5)

	# Verifica o hash e o coloca na URL
	if test -n "$codigo"
	then
		url="$url$codigo"
	else
		echo "Houve um erro na gera��o do c�digo MD5 do email"
		return 1
	fi

	# Adiciona as op��es extras na URL
	if test -n "$extra"
	then
		url="$url?${extra#&}"
	fi

	# T� feito, essa � a URL final
	echo "$url"
}

# ----------------------------------------------------------------------------
# zzhexa2str
# Converte os bytes em hexadecimal para a string equivalente.
# Uso: zzhexa2str [bytes]
# Ex.: zzhexa2str 40 4d 65 6e 74 65 42 69 6e 61 72 69 61   # sem prefixo
#      zzhexa2str 0x42 0x69 0x6E                           # com prefixo 0x
#      echo 0x42 0x69 0x6E | zzhexa2str
#
# Autor: Fernando Merc�s <fernando (a) mentebinaria.com.br>
# Desde: 2012-02-24
# Vers�o: 3
# Licen�a: GPL
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
# Faz c�lculos com hor�rios.
# A op��o -r torna o c�lculo relativo � primeira data, por exemplo:
#   02:00 - 03:30 = -01:30 (sem -r) e 22:30 (com -r)
#
# Uso: zzhora [-r] hh:mm [+|- hh:mm] ...
# Ex.: zzhora 8:30 + 17:25        # preciso somar dois hor�rios
#      zzhora 12:00 - agora       # quando falta para o almo�o?
#      zzhora -12:00 + -5:00      # horas negativas!
#      zzhora 1000                # quanto � 1000 minutos?
#      zzhora -r 5:30 - 8:00      # que horas ir dormir para acordar �s 5:30?
#      zzhora -r agora + 57:00    # e daqui 57 horas, ser� quando?
#      zzhora 1:00 + 2:00 + 3:00 - 4:00 - 0:30   # c�lculos m�ltiplos
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Vers�o: 4
# Licen�a: GPL
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

	# Op��es de linha de comando
	if [ "$1" = '-r' ]
	then
		relativo=1
		shift
	fi

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso hora; return 1; }

	# C�lculos m�ltiplos? Exemplo: 1:00 + 2:00 + 3:00 - 4:00
	if test $# -gt 3
	then
		if test $relativo -eq 1
		then
			echo "A op��o -r n�o suporta c�lculos m�ltiplos"
			return 1
		fi

		# A zzhora continua simples, suportando apenas dois n�meros
		# e uma �nica opera��o entre eles. O que fiz para suportar
		# m�ltiplos, � chamar a pr�pria zzhora v�rias vezes, a cada
		# n�mero novo, usando o resultado do c�lculo anterior.
		#
		# In�cio  : parcial = $1
		# Rodada 1: parcial = zzhora $parcial $2 $3
		# Rodada 2: parcial = zzhora $parcial $4 $5
		# Rodada 3: parcial = zzhora $parcial $6 $7
		# e assim vai.
		#
		parcial="$1"
		shift

		# Daqui pra frente � de dois em dois: operador (+-) e a hora.
		# Se tiver um n�mero �mpar de argumentos, tem algo errado.
		#
		if test $(($# % 2)) -eq 1
		then
			zztool uso hora
			return 1
		fi

		# Agora sim, vamos fazer o loop e calcular todo mundo
		while test $# -ge 2
		do
			resultado=$(zzhora "$parcial" "$1" "$2")
			exitcode=$?

			# Salva somente o hor�rio. Ex: 02:59 (0d 2h 59m) 
			parcial=$(echo "$resultado" | cut -d ' ' -f 1)

			# Esses dois j� foram. Venham os pr�ximos!
			shift
			shift
		done

		# Loop terminou, ent�o j� temos o total final.
		# Basta mostrar e encerrar, saindo com o exitcode retornado
		# pela execu��o da �ltima zzhora. Vai que deu erro?
		#
		echo "$resultado"
		return $exitcode
	fi

	# Dados informados pelo usu�rio (com valores padr�o)
	hhmm1="$1"
	operacao="${2:-+}"
	hhmm2="${3:-0}"
	hhmm1_orig="$hhmm1"
	hhmm2_orig="$hhmm2"

	# Somente adi��o e subtra��o s�o permitidas
	if test "$operacao" != '-' -a "$operacao" != '+'
	then
		echo "Opera��o inv�lida '$operacao'. Deve ser + ou -."
		return 1
	fi

	# Remove poss�veis sinais de negativo do in�cio
	hhmm1="${hhmm1#-}"
	hhmm2="${hhmm2#-}"

	# Guarda a informa��o de quem era negativo no in�cio
	[ "$hhmm1" != "$hhmm1_orig" ] && neg1=1
	[ "$hhmm2" != "$hhmm2_orig" ] && neg2=1

	# Atalhos bacanas para a hora atual
	[ "$hhmm1" = 'agora' -o "$hhmm1" = 'now' ] && hhmm1=$(date +%H:%M)
	[ "$hhmm2" = 'agora' -o "$hhmm2" = 'now' ] && hhmm2=$(date +%H:%M)

	# Se as horas n�o foram informadas, coloca zero
	[ "${hhmm1#*:}" = "$hhmm1" ] && hhmm1="0:$hhmm1"
	[ "${hhmm2#*:}" = "$hhmm2" ] && hhmm2="0:$hhmm2"

	# Extrai horas e minutos para vari�veis separadas
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

	# Valida��o dos dados
	if ! (zztool testa_numero "$hh1" && zztool testa_numero "$mm1")
	then
		echo "Hor�rio inv�lido '$hhmm1_orig', deve ser HH:MM"
		return 1
	fi
	if ! (zztool testa_numero "$hh2" && zztool testa_numero "$mm2")
	then
		echo "Hor�rio inv�lido '$hhmm2_orig', deve ser HH:MM"
		return 1
	fi

	# Os c�lculos s�o feitos utilizando apenas minutos.
	# Ent�o � preciso converter as horas:minutos para somente minutos.
	n1=$((hh1*60 + mm1))
	n2=$((hh2*60 + mm2))

	# Restaura o sinal para as horas negativas
	[ $neg1 -eq 1 ] && n1="-$n1"
	[ $neg2 -eq 1 ] && n2="-$n2"

	# Tudo certo, hora de fazer o c�lculo
	resultado=$(($n1 $operacao $n2))

	# Resultado negativo, seta a flag e remove o sinal de menos "-"
	if [ $resultado -lt 0 ]
	then
		negativo='-'
		resultado="${resultado#-}"
	fi

	# Agora � preciso converter o resultado para o formato hh:mm

	horas=$((resultado/60))
	minutos=$((resultado%60))
	dias=$((horas/24))
	horas_do_dia=$((horas%24))

	# Restaura o zero dos minutos/horas menores que 10
	hh="$horas"
	mm="$minutos"
	hh_dia="$horas_do_dia"
	[ $hh -le 9 ] && hh="0$hh"
	[ $mm -le 9 ] && mm="0$mm"
	[ $hh_dia -le 9 ] && hh_dia="0$hh_dia"

	# Decide como mostrar o resultado para o usu�rio.
	#
	# Relativo:
	#   $ zzhora -r 10:00 + 48:00            $ zzhora -r 12:00 - 13:00
	#   10:00 (2 dias)                       23:00 (ontem)
	#
	# Normal:
	#   $ zzhora 10:00 + 48:00               $ zzhora -r 12:00 - 13:00
	#   58:00 (2d 10h 0m)                    -01:00 (0d 1h 0m)
	#
	if [ $relativo -eq 1 ]
	then

		# Relativo

		# Somente em resultados negativos o relativo � �til.
		# Para valores positivos n�o � preciso fazer nada.
		if [ "$negativo" ]
		then
			# Para o resultado negativo � preciso refazer algumas contas
			minutos=$(( (60-minutos) % 60))
			dias=$((horas/24 + (minutos>0) ))
			hh_dia=$(( (24 - horas_do_dia - (minutos>0)) % 24))
			mm="$minutos"

			# Zeros para dias e minutos menores que 10
			[ $mm -le 9 ] && mm="0$mm"
			[ $hh_dia -le 9 ] && hh_dia="0$hh_dia"
		fi

		# "Hoje", "amanh�" e "ontem" s�o simp�ticos no resultado
		case $negativo$dias in
			1)
				extra='amanh�'
			;;
			-1)
				extra='ontem'
			;;
			0|-0)
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
# Se nenhum par�metro for passado, s�o listados as localidades dispon�veis.
# O par�metro pode ser tanto a sigla quando o nome da localidade.
# A op��o -s realiza a busca somente na sigla.
# Uso: zzhoracerta [-s] local
# Ex.: zzhoracerta rio grande do sul
#      zzhoracerta -s br
#      zzhoracerta rio
#      zzhoracerta us-ny
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-03-29
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzhoracerta ()
{
	zzzz -h horacerta "$1" && return

	local codigo localidade localidades
	local cache="$ZZTMP.horacerta"
	local url='http://www.worldtimeserver.com'

	# Op��es de linha de comando
	if [ "$1" = '-s' ]
	then
		shift
		codigo="$1"
	else
		localidade="$*"
	fi

	# Se o cache est� vazio, baixa listagem da Internet
	# De: <li><a href="current_time_in_AR-JY.aspx">Jujuy</a></li>
	# Para: AR-JY -- Jujuy
	if ! test -s "$cache"
	then
		$ZZWWWHTML "$url/country.html" |
			grep 'current_time_in_' |
			sed 's/.*_time_in_// ; s/\.aspx">/ -- / ; s/<.*//' > "$cache"
	fi

	# Se nenhum par�metro for passado, s�o listados os pa�ses dispon�veis
	if ! [ "$localidade$codigo" ]
	then
		cat "$cache"
		return
	fi

	# Faz a pesquisa por codigo ou texto
	if [ "$codigo" ]
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
	if ! [ "$localidades" ]
	then
		echo "Localidade \"$localidade$codigo\" n�o encontrada"
		return 1
	fi

	# Grava o c�digo da localidade (BR-RS -- Rio Grande do Sul -> BR-RS)
	localidade=$(echo "$localidades" | sed 's/ .*//')

	# Faz a consulta e filtra o resultado
	$ZZWWWDUMP "$url/current_time_in_$localidade.aspx" |
		sed -n '/The current time/,/UTC/p'
}

# ----------------------------------------------------------------------------
# zzhoramin
# Converte horas em minutos.
# Obs.: Se n�o informada a hora, usa o hor�rio atual para o c�lculo.
# Uso: zzhoramin [hh:mm]
# Ex.: zzhoramin
#      zzhoramin 10:53       # Retorna 653
#      zzhoramin -10:53      # Retorna -653
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-12-05
# Vers�o: 3
# Licen�a: GPLv2
# Requisitos: zzhora
# ----------------------------------------------------------------------------
zzhoramin ()
{

	zzzz -h horamin "$1" && return

	local mintotal hh mm hora operacao

	operacao='+'

	# Testa se o par�metro passado � uma hora valida
	if ! zztool testa_hora "${1#-}"; then
		hora=$(zzhora agora | cut -d ' ' -f 1)
	else
		hora="$1"
	fi

	# Verifica se a hora � positiva ou negativa
	if [ "${hora#-}" != "$hora" ]; then
		operacao='-'
	fi

	# passa a hora para hh e minuto para mm
	hh="${hora%%:*}"
	mm="${hora##*:}"

	# faz o c�lculo
	mintotal=$(($hh * 60 $operacao $mm))

	# Tchar�!!!!
	echo "$mintotal"
}

# ----------------------------------------------------------------------------
# zzhorariodeverao
# Mostra as datas de in�cio e fim do hor�rio de ver�o.
# Obs.: Ano de 2008 em diante. Se o ano n�o for informado, usa o atual.
# Regra: 3� domingo de outubro/fevereiro, exceto carnaval (4� domingo).
# Uso: zzhorariodeverao [ano]
# Ex.: zzhorariodeverao
#      zzhorariodeverao 2009
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-24
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzcarnaval zzdata zzdiadasemana
# Tags: data
# ----------------------------------------------------------------------------
zzhorariodeverao ()
{
	zzzz -h horariodeverao "$1" && return

	local inicio fim data domingo_carnaval
	local dias_3a_semana="15 16 17 18 19 20 21"
	local ano="$1"

	# Se o ano n�o for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Valida��o
	zztool -e testa_ano "$ano" || return 1

	# S� de 2008 em diante...
	if test "$ano" -lt 2008
	then
		echo 'Antes de 2008 n�o havia regra fixa para o hor�rio de ver�o'
		return 1
	fi

	# Encontra os dias de in�cio e t�rmino do hor�rio de ver�o.
	# Sei que o algoritmo n�o � eficiente, mas � simples de entender.
	#
	for dia in $dias_3a_semana
	do
		data="$dia/10/$ano"
		test $(zzdiadasemana $data) = 'domingo' && inicio="$data"

		data="$dia/02/$((ano+1))"
		test $(zzdiadasemana $data) = 'domingo' && fim="$data"
	done

	# Exce��o � regra: Se o domingo de t�rmino do hor�rio de ver�o
	# coincidir com o Carnaval, adia o t�rmino para o pr�ximo domingo.
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
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzhowto ()
{
	zzzz -h howto "$1" && return

	local padrao
	local cache="$ZZTMP.howto"
	local url='http://www.ibiblio.org/pub/Linux/docs/HOWTO/other-formats/html_single/'

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso howto; return 1; }

	# For�a atualiza��o da listagem apagando o cache
	if [ "$1" = '--atualiza' ]
	then
		rm -f "$cache"
		shift
	fi

	padrao=$1

	# Se o cache est� vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		$ZZWWWDUMP "$url" |
			grep 'text/html' |
			sed 's/^  *//; s/ [0-9][0-9]:.*//' > "$cache"
	fi

	# Pesquisa o termo (se especificado)
	if [ "$padrao" ]
	then
		zztool eco "$url"
		grep -i "$padrao" "$cache"
	fi
}

# ----------------------------------------------------------------------------
# zzipinternet
# http://www.getip.com
# Mostra o seu n�mero IP (externo) na Internet.
# Uso: zzipinternet
# Ex.: zzipinternet
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2005-09-01
# Vers�o: 4
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzipinternet ()
{
	zzzz -h ipinternet "$1" && return

	local url='http://www.getip.com'

	# O resultado j� vem pronto!
	$ZZWWWDUMP "$url" | sed -n 's/^Current IP: //p'
}

# ----------------------------------------------------------------------------
# zzjquery
# Exibe a descri��o da fun��o JQuery informada.
# Caso n�o seja passado o nome, ser�o exibidas informa��es acerca do $().
# Se usado o argumento -s, ser� exibida somente a sintaxe.
# Uso: zzjquery [-s] funcao
# Ex.: zzjquery gt
#      zzjquery -s gt
#
# Autor: Felipe Nascimento Silva Pena <felipensp (a) gmail com>
# Desde: 2007-12-04
# Vers�o: 3
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzjquery ()
{
	zzzz -h jquery "$1" && return

	local er
	local cache="$ZZTMP.jquery"
	local er1="s/^ *<h1>\([\$.]*$2(.*\)<\/h1> *$/- \1/p;"  # <h1>gt(pos)</h1>
	local er2="
	/^ *<h1>\([\$.]*$1(.*\)<\/h1> *$/ {
		
		# Mostra o nome da fun��o e vai pra pr�xima linha
		s//\1:/p
		n

		### A descri��o est� numa �nica linha.
		#
		# <h1>$.get(url, params, callback)</h1>
		# <p>Load a remote page using an HTTP GET request.</p>
		#
		# O comando G adiciona uma linha ap�s a descri��o.
		# O comando b pula pro final, j� terminamos com esse.
		#
		/^ *<p>\(.*\)<\/p> *$/ {
			s//  \1/
			G
			p
			b
		}
		
		### A descri��o est� em v�rias linhas.
		#
	        # <h1>gt(pos)</h1>
	        # <p>Reduce the set of matched elements to all elements after a given position.
	        #    The position of the element in the set of matched elements
	        #    starts at 0 and goes to length - 1.
	        # </p>
		#
		# Esse � mais chato, temos que pegar todo o texto at� o </p>.
		# � feito um loop que termina quando achar o </p>.
		#
		:multi
		/<\/p>/ {
			s///p
			b
		}
		s/^ *<p>//
		s/^ */  /p
		n
		b multi
	}
	"

	[ "$1" = '-s' ] && er="$er1" || er="$er2"

	# Se o cache est� vazio, baixa o conte�do
	if ! test -s "$cache"
	then
		$ZZWWWHTML "http://visualjquery.com/1.1.2.html" > "$cache"
	fi

	# Faz a pesquisa e filtra o resultado
	sed -n "$er" "$cache"
}

# ----------------------------------------------------------------------------
# zzjuntalinhas
# Junta v�rias linhas em uma s�, podendo escolher o in�cio, fim e separador.
#
# Melhorias em rela��o ao comando paste -s:
# - Trata corretamente arquivos no formato Windows (CR+LF)
# - L� arquivos ISO-8859-1 sem erros no Mac (o paste d� o mesmo erro do tr)
# - O separador pode ser uma string, n�o est� limitado a um caractere
# - Op��es -i e -f para delimitar somente um trecho a ser juntado
#
# Op��es: -d sep        Separador a ser colocado entre as linhas (padr�o: Tab)
#         -i, --inicio  In�cio do trecho a ser juntado (n�mero ou regex)
#         -f, --fim     Fim do trecho a ser juntado (n�mero ou regex)
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
# Vers�o: 3
# Licen�a: GPL
# Requisitos: zzdos2unix
# ----------------------------------------------------------------------------
zzjuntalinhas ()
{
	zzzz -h juntalinhas "$1" && return

	local separador=$(printf '\t')  # tab
	local inicio='1'
	local fim='$'

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			-d         ) separador="$2"; shift; shift;;
			-i|--inicio) inicio="$2"   ; shift; shift;;
			-f|--fim   ) fim="$2"      ; shift; shift;;
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
			# Exce��o: In�cio e fim na mesma linha, mostra a linha e pronto
			$inicio {
				$fim {
					p
					d
				}
			}

			# O algoritmo � simples: ao entrar no trecho escolhido ($inicio)
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

				# Exce��o: N�o achei $fim e estou na �ltima linha.
				# Este trecho n�o ser� juntado.
				$ {
					x
					s/^\n//
					p
				}

				d
			}"
}

# ----------------------------------------------------------------------------
# zzkill
# Mata processos pelo nome do seu comando de origem.
# Com a op��o -n, apenas mostra o que ser� feito, mas n�o executa.
# Se nenhum argumento for informado, mostra a lista de processos ativos.
# Uso: zzkill [-n] [comando [comando2 ...]]
# Ex.: zzkill
#      zzkill netscape
#      zzkill netsc soffice startx
#
# Autor: Ademar de Souza Reis Jr.
# Desde: 2000-05-15
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzkill ()
{
	zzzz -h kill "$1" && return

	local nao comandos comando processos pid chamada

	# Op��es de linha de comando
	if [ "$1" = '-n' ]
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

		# Diga n�o ao suic�dio
		processos=$(echo "$processos" | grep -vw '\(zz\)*kill')

		# Sem argumentos, apenas mostra a listagem e sai
		if ! [ "$1" ]
		then
			echo "$processos"
			return 0
		fi

		# Filtra a lista, extraindo e matando os PIDs
		echo "$processos" |
			grep -i "$comando" |
			while read pid chamada
			do
				echo -e "$nao$pid\t$chamada"
				[ "$nao" ] || kill $pid
			done

		# Pr�ximo da fila!
		shift
		[ "$1" ] || break
	done
}

# ----------------------------------------------------------------------------
# zzlembrete
# Sistema simples de lembretes: cria, apaga e mostra.
# Uso: zzlembrete [texto]|[n�mero [d]]
# Ex.: zzlembrete                      # Mostra todos
#      zzlembrete 5                    # Mostra o 5� lembrete
#      zzlembrete 5d                   # Deleta o 5� lembrete
#      zzlembrete Almo�o com a sogra   # Adiciona lembrete
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-22
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzlembrete ()
{
	zzzz -h lembrete "$1" && return

	local arquivo="$HOME/.zzlembrete"
	local tmp="$ZZTMP.lembrete.$$"
	local numero

	# Assegura-se que o arquivo de lembretes existe
	test -f "$arquivo" || touch "$arquivo"

	# Sem argumentos, mostra todos os lembretes
	if test $# -eq 0
	then
		cat -n "$arquivo"

	# Tem argumentos, que podem ser para mostrar, apagar ou adicionar
	elif echo "$*" | tr -s '\t ' ' ' | grep '^ *[0-9]\{1,\} *d\{0,1\} *$' >/dev/null
	then
		# Extrai o n�mero da linha
		numero=$(echo "$*" | tr -d -c 0123456789)

		if zztool grep_var d "$*"
		then
			# zzlembrete 5d: Apaga linha 5
			cp "$arquivo" "$tmp" &&
			sed "${numero:-0} d" "$tmp" > "$arquivo" || {
				echo "Ops, deu algum erro no arquivo $arquivo"
				echo "Uma c�pia dele est� em $tmp"
				return 1
			}
		else
			# zzlembrete 5: Mostra linha 5
			sed -n "$numero p" "$arquivo"
		fi
	else
		# zzlembrete texto: Adiciona o texto
		echo "$*" >> "$arquivo" || {
			echo "Ops, n�o consegui adicionar esse lembrete"
			return 1
		}
	fi
}

# ----------------------------------------------------------------------------
# zzlimpalixo
# Retira linhas em branco e coment�rios.
# Para ver rapidamente quais op��es est�o ativas num arquivo de configura��o.
# Al�m do tradicional #, reconhece coment�rios de arquivos .vim.
# Obs.: Aceita dados vindos da entrada padr�o (STDIN).
# Uso: zzlimpalixo [arquivos]
# Ex.: zzlimpalixo ~/.vimrc
#      cat /etc/inittab | zzlimpalixo
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-04-24
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzlimpalixo ()
{
	zzzz -h limpalixo "$1" && return

	local comentario='#'

	# Reconhecimento de coment�rios do Vim
	case "$1" in
		*.vim | *.vimrc*)
			comentario='"'
		;;
	esac

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |

		# Remove coment�rios e linhas em branco
		sed "
			/^[[:blank:]]*$comentario/ d
			/^[[:blank:]]*$/ d" |
		uniq
}

# ----------------------------------------------------------------------------
# zzlinha
# Mostra uma linha de um texto, aleat�ria ou informada pelo n�mero.
# Obs.: Se passado um argumento, restringe o sorteio �s linhas com o padr�o.
# Uso: zzlinha [n�mero | -t texto] [arquivo(s)]
# Ex.: zzlinha /etc/passwd           # mostra uma linha qualquer, aleat�ria
#      zzlinha 9 /etc/passwd         # mostra a linha 9 do arquivo
#      zzlinha -2 /etc/passwd        # mostra a pen�ltima linha do arquivo
#      zzlinha -t root /etc/passwd   # mostra uma das linhas com "root"
#      cat /etc/passwd | zzlinha     # o arquivo pode vir da entrada padr�o
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-12-23
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzlinha ()
{
	zzzz -h linha "$1" && return

	local arquivo n padrao resultado num_linhas

	# Op��es de linha de comando
	if [ "$1" = '-t' ]
	then
		padrao="$2"
		shift
		shift
	fi

	# Talvez o $1 � o n�mero da linha desejada?
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

	if [ "$n" ]
	then
		# Se foi informado um n�mero, mostra essa linha.
		# Nota: Suporte a m�ltiplos arquivos ou entrada padr�o (STDIN)
		for arquivo in "${@:--}"
		do
			# Usando cat para ler do arquivo ou da STDIN
			cat "$arquivo" |
				if [ "$n" -lt 0 ]
				then
					tail -n "${n#-}" | sed 1q
				else
					sed -n "${n}p"
				fi
		done
	else
		# Se foi informado um padr�o (ou nenhum argumento),
		# primeiro grepa as linhas, depois mostra uma linha
		# aleat�ria deste resultado.
		# Nota: Arquivos via STDIN ou argumentos
		resultado=$(zztool file_stdin "$@" | grep -h -i -- "${padrao:-.}")
		num_linhas=$(echo "$resultado" | sed -n '$=')
		n=$(( (RANDOM % num_linhas) + 1))
		[ $n -eq 0 ] && n=1
		echo "$resultado" | sed -n "${n}p"
	fi
}

# ----------------------------------------------------------------------------
# zzlinux
# http://www.kernel.org/kdist/finger_banner
# Mostra as vers�es dispon�veis do Kernel Linux.
# Uso: zzlinux
# Ex.: zzlinux
#
# Autor: Diogo Gullit <guuuuuuuuuullit (a) yahoo com br>
# Desde: 2008-05-01
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzlinux ()
{
	zzzz -h linux "$1" && return

	$ZZWWWDUMP http://www.kernel.org/kdist/finger_banner
}

# ----------------------------------------------------------------------------
# zzlinuxnews
# http://... - v�rios
# Busca as �ltimas not�cias sobre linux em sites em ingl�s.
# Obs.: Cada site tem uma letra identificadora que pode ser passada como
#       par�metro, para informar quais sites voc� quer pesquisar:
#
#          F)reshMeat         Linux T)oday
#          S)lashDot          Linux W)eekly News
#          O)S News
#
# Uso: zzlinuxnews [sites]
# Ex.: zzlinuxnews
#      zzlinuxnews fs
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-11-07
# Vers�o: 3
# Licen�a: GPL
# Requisitos: zzfeed
# ----------------------------------------------------------------------------
zzlinuxnews ()
{
	zzzz -h linuxnews "$1" && return

	local url limite
	local n=5
	local sites='fsntwo'

	limite="sed ${n}q"

	[ "$1" ] && sites="$1"

	# Freshmeat
	if zztool grep_var f "$sites"
	then
		url='http://freshmeat.net/?format=atom'
		echo
		zztool eco "* FreshMeat ($url):"
		zzfeed -n $n "$url"
	fi

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
		url='http://lwn.net/Articles'
		echo
		zztool eco "* Linux Weekly News - ($url):"
		$ZZWWWHTML "$url" |
			sed '/class="Headline"/!d;s/^ *//;s/<[^>]*>//g' |
			$limite
	fi

	# OS News
	if zztool grep_var o "$sites"
	then
		url='http://www.osnews.com/files/recent.xml'
		echo
		zztool eco "* OS News - ($url):"
		zzfeed -n $n "$url"
	fi
}

# ----------------------------------------------------------------------------
# zzlocale
# http://funcoeszz.net/locales.txt
# Busca o c�digo do idioma (locale) - por exemplo, portugu�s � pt_BR.
# Com a op��o -c, pesquisa somente nos c�digos e n�o em sua descri��o.
# Uso: zzlocale [-c] c�digo|texto
# Ex.: zzlocale chinese
#      zzlocale -c pt
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2005-06-30
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzlocale ()
{
	zzzz -h locale "$1" && return

	local url='http://funcoeszz.net/locales.txt'
	local cache="$ZZTMP.locale"
	local padrao="$1"

	# Op��es de linha de comando
	if [ "$1" = '-c' ]
	then
		# Padr�o de pesquisa v�lido para �ltima palavra da linha (c�digo)
		padrao="$2[^ ]*$"
		shift
	fi

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso locale; return 1; }

	# Se o cache est� vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		$ZZWWWDUMP "$url" > "$cache"
	fi

	# Faz a consulta
	grep -i -- "$padrao" "$cache"
}

# ----------------------------------------------------------------------------
# zzloteria
# http://www1.caixa.gov.br/loterias
# Consulta os resultados da quina, megasena, duplasena, lotomania e lotof�cil.
# Obs.: Se nenhum argumento for passado, todas as loterias s�o mostradas.
# Uso: zzloteria [quina | megasena | duplasena | lotomania | lotofacil]
# Ex.: zzloteria
#      zzloteria quina megasena
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-05-18
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzloteria ()
{
	zzzz -h loteria "$1" && return

	local dump numero_concurso data resultado acumulado tipo sufixo
	local url='http://www1.caixa.gov.br/loterias/loterias'
	local tipos='quina megasena duplasena lotomania lotofacil'

	# O padr�o � mostrar todos os tipos, mas o usu�rio pode informar alguns
	[ "$1" ] && tipos=$*

	# Para cada tipo de loteria...
	for tipo in $tipos
	do
		zztool eco $tipo:

		# H� v�rias pegadinhas neste c�digo. Alguns detalhes:
		# - A vari�vel $dump � um cache local do resultado
		# - � usado ZZWWWDUMP+filtros (e n�o ZZWWWHTML) para for�ar a sa�da em UTF-8
		# - O resultado � deixado como uma �nica longa linha
		# - O resultado s�o v�rios campos separados por pipe |
		# - Cada tipo de loteria traz os dados em posi��es (e formatos) diferentes :/

		if test "$tipo" = 'duplasena'
		then
			sufixo='_pesquisa_new.asp'
		else
			sufixo='_pesquisa.asp'
		fi

		dump=$($ZZWWWDUMP "$url/$tipo/$tipo$sufixo" |
			tr -d \\n |
			sed 's/  */ /g ; s/^ //')

		# O n�mero do concurso � sempre o primeiro campo
		numero_concurso=$(echo "$dump" | cut -d '|' -f 1)

		case "$tipo" in
			lotomania)
				# O resultado vem separado em campos distintos. Exemplo:
				# |01|04|06|12|21|25|27|36|42|44|50|51|53|59|68|69|74|78|87|91|91|

				data=$(     echo "$dump" | cut -d '|' -f 42)
				acumulado=$(echo "$dump" | cut -d '|' -f 70,71)
				resultado=$(echo "$dump" | cut -d '|' -f 7-26 |
					sed 's/|/@/10 ; s/|/ - /g' |
					tr @ '\n'
				)
			;;
			lotofacil)
				# O resultado vem separado em campos distintos. Exemplo:
				# |01|04|07|08|09|10|12|14|15|16|21|22|23|24|25|

				data=$(     echo "$dump" | cut -d '|' -f 39)
				acumulado=$(echo "$dump" | cut -d '|' -f 58,59)
				resultado=$(echo "$dump" | cut -d '|' -f 4-18 |
					sed 's/|/@/10 ; s/|/@/5 ; s/|/ - /g' |
					tr @ '\n'
				)
			;;
			megasena)
				# O resultado vem separado por asteriscos. Exemplo:
				# | * 16 * 58 * 43 * 37 * 52 * 59 |

				data=$(     echo "$dump" | cut -d '|' -f 12)
				acumulado=$(echo "$dump" | cut -d '|' -f 22,23)
				resultado=$(echo "$dump" | cut -d '|' -f 21 |
					tr '*' '-'  |
					tr '|' '\n' |
					sed 's/^ - //'
				)
			;;
			duplasena)
				# O resultado vem separado por asteriscos, tendo dois grupos
				# num�ricos: o primeiro e segundo resultado. Exemplo:
				# | * 05 * 07 * 09 * 21 * 38 * 40 | * 05 * 17 * 20 * 22 * 31 * 45 |

				data=$(     echo "$dump" | cut -d '|' -f 18)
				acumulado=$(echo "$dump" | cut -d '|' -f 23,24)
				resultado=$(echo "$dump" | cut -d '|' -f 4,5 |
					tr '*' '-'  |
					tr '|' '\n' |
					sed 's/^ - //'
				)
			;;
			quina)
				# O resultado vem duplicado em um �nico campo, sendo a segunda
				# parte o resultado ordenado numericamente. Exemplo:
				# | * 69 * 42 * 13 * 56 * 07 * 07 * 13 * 42 * 56 * 69 |

				data=$(     echo "$dump" | cut -d '|' -f 17)
				acumulado=$(echo "$dump" | cut -d '|' -f 18,19)
				resultado=$(echo "$dump" | cut -d '|' -f 15 |
					sed 's/\* /|/6' |
					tr '*' '-'  |
					tr '|' '\n' |
					sed 's/^ - // ; 1d'
				)
			;;
		esac

		# Mostra o resultado na tela (caso encontrado algo)
		if [ "$resultado" ]
		then
			echo "$resultado" | sed 's/^/   /'
			echo "   Concurso $numero_concurso ($data)"
			[ "$acumulado" ] && echo "   Acumulado em R$ $acumulado" | sed 's/|/ para /'
			echo
		fi
	done
}

# ----------------------------------------------------------------------------
# zzloteria2
# Resultados da quina, megasena, duplasena, lotomania, lotof�cil, federal e timemania.
# Se o 2� argumento for um n�mero, pesquisa o resultado filtrando o concurso.
# Se nenhum argumento for passado, todas as loterias s�o mostradas.
#
# Uso: zzloteria2 [[quina|megasena|duplasena|lotomania|lotofacil|federal|timemania|loteca] concurso]
# Ex.: zzloteria2
#      zzloteria2 quina megasena
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2009-10-04
# Vers�o: 4
# Licen�a: GPL
# Requisitos: zzseq zzsemacento
# ----------------------------------------------------------------------------
zzloteria2 ()
{
	zzzz -h loteria2 "$1" && return

	local dump numero_concurso data resultado acumulado tipo ZZWWWDUMP2
	local resultado_val resultado_num num_con sufixo faixa
	local url='http://www1.caixa.gov.br/loterias/loterias'
	local tipos='quina megasena duplasena lotomania lotofacil federal timemania loteca'

	if type links >/dev/null 2>&1
	then
		ZZWWWDUMP2='links -dump'
	else
		ZZWWWDUMP2=$ZZWWWDUMP
		#echo 'Favor instalar o "links"'
		#echo 'Site da caixa n�o responde com o "lynx" usado na vari�vel $ZZWWWDUMP'
		#return 1
	fi

	# Caso o segundo argumento seja um numero, filtra pelo concurso equivalente
	zztool testa_numero "$2"
	if ([ $? -eq 0 ])
	then
		num_con="?submeteu=sim&opcao=concurso&txtConcurso=$2"
		tipos="$1"
	else
	# Caso contrario mostra todos os tipos, ou alguns selecionados
		unset num_con
		[ "$1" ] && tipos="$*"
	fi

	# Para cada tipo de loteria...
	for tipo in $tipos
	do

		# H� v�rias pegadinhas neste c�digo. Alguns detalhes:
		# - A vari�vel $dump � um cache local do resultado
		# - � usado ZZWWWDUMP2+filtros (e n�o ZZWWWHTML) para for�ar a sa�da em UTF-8
		# - O resultado � deixado como uma �nica longa linha
		# - O resultado s�o v�rios campos separados por pipe |
		# - Cada tipo de loteria traz os dados em posi��es (e formatos) diferentes :/

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

		# O n�mero do concurso � sempre o primeiro campo
		numero_concurso=$(echo "$dump" | cut -d '|' -f 1)

		case "$tipo" in
			lotomania)
				# O resultado vem separado em campos distintos. Exemplo:
				# |01|04|06|12|21|25|27|36|42|44|50|51|53|59|68|69|74|78|87|91|91|

				data=$(     echo "$dump" | cut -d '|' -f 42)
				acumulado=$(echo "$dump" | cut -d '|' -f 69,70)
				resultado=$(echo "$dump" | cut -d '|' -f 7-26 |
					sed 's/|/@/10 ; s/|/ - /g' |
					tr @ '\n'
				)
				faixa=$(zzseq -f "\t%d ptos\n" 20 1 16)
				faixa=$(echo "${faixa}\n\t 0 ptos")
				resultado_num=$(echo "$dump" | cut -d '|' -f 28,30,32,34,36,38 | tr '|' '\n')
				resultado_val=$(echo "$dump" | cut -d '|' -f 29,31,33,35,37,39 | tr '|' '\n')
			;;
			lotofacil)
				# O resultado vem separado em campos distintos. Exemplo:
				# |01|04|07|08|09|10|12|14|15|16|21|22|23|24|25|
				resultado=$(echo "$dump" | cut -d '|' -f 4-18 |
					sed 's/|/@/10 ; s/|/@/5 ; s/|/ - /g' |
					tr @ '\n'
				)
				faixa=$(zzseq -f "\t%d ptos\n" 15 1 11)
				resultado_num=$(echo "$dump" | cut -d '|' -f 19,21,23,25,27 | tr '|' '\n')
				resultado_val=$(echo "$dump" | cut -d '|' -f 20,22,24,26,28 | tr '|' '\n')
				dump=$(    echo "$dump" | sed 's/.*Estimativa de Pr//')
				data=$(     echo "$dump" | cut -d '|' -f 6)
				acumulado=$(echo "$dump" | cut -d '|' -f 25,26)
			;;
			megasena)
				# O resultado vem separado por asteriscos. Exemplo:
				# | * 16 * 58 * 43 * 37 * 52 * 59 |

				data=$(     echo "$dump" | cut -d '|' -f 12)
				acumulado=$(echo "$dump" | cut -d '|' -f 22,23)
				resultado=$(echo "$dump" | cut -d '|' -f 21 |
					tr '*' '-'  |
					tr '|' '\n' |
					sed 's/^ - //'
				)
				faixa=$(echo "\tSena|\tQuina|\tQuadra"| tr '|' '\n')
				resultado_num=$(echo "$dump" | cut -d '|' -f 4,6,8 | tr '|' '\n')
				resultado_val=$(echo "$dump" | cut -d '|' -f 5,7,9 | tr '|' '\n')
			;;
			duplasena)
				# O resultado vem separado por asteriscos, tendo dois grupos
				# num�ricos: o primeiro e segundo resultado. Exemplo:
				# | * 05 * 07 * 09 * 21 * 38 * 40 | * 05 * 17 * 20 * 22 * 31 * 45 |

				data=$(     echo "$dump" | cut -d '|' -f 18)
				acumulado=$(echo "$dump" | cut -d '|' -f 23,24)
				resultado=$(echo "$dump" | cut -d '|' -f 4,5 |
					tr '*' '-'  |
					tr '|' '\n' |
					sed 's/^ - //'
				)
				faixa=$(echo "\t1� Sena|\t1� Quina|\t1� Quadra||\t2� Sena|\t2� Quina|\t2� Quadra"| tr '|' '\n')
				resultado_num=$(echo "$dump" | awk 'BEGIN {FS="|";OFS="\n"} {print $7,$26,$28,"",$9,$10,$13}')
				resultado_val=$(echo "$dump" | awk 'BEGIN {FS="|";OFS="\n"} {print $8,$27,$29,"",$11,$12,$14}')
			;;
			quina)
				# O resultado vem duplicado em um �nico campo, sendo a segunda
				# parte o resultado ordenado numericamente. Exemplo:
				# | * 69 * 42 * 13 * 56 * 07 * 07 * 13 * 42 * 56 * 69 |

				data=$(     echo "$dump" | cut -d '|' -f 17)
				acumulado=$(echo "$dump" | cut -d '|' -f 18,19)
				resultado=$(echo "$dump" | cut -d '|' -f 15 |
					sed 's/\* /|/6' |
					tr '*' '-'  |
					tr '|' '\n' |
					sed 's/^ - // ; 1d'
				)
				faixa=$(echo "\tQuina|\tQuadra|\tTerno"| tr '|' '\n')
				resultado_num=$(echo "$dump" | cut -d '|' -f 7,9,11 | tr '|' '\n')
				resultado_val=$(echo "$dump" | cut -d '|' -f 8,10,12 | tr '|' '\n')
			;;
			federal)
				data=$(     echo "$dump" | cut -d '|' -f 17)
				numero_concurso=$(echo "$dump" | cut -d '|' -f 3)
				unset acumulado
				resultado_num=$(echo "$dump" | cut -d '|' -f 7,9,11,13,15 |
					tr '*' '-'  |
					tr '|' '\n' |
					sed 's/^ - //'
				)
				resultado_val=$(echo "$dump" | cut -d '|' -f 8,10,12,14,16 |
					tr '*' '-'  |
					tr '|' '\n' |
					sed 's/^ - //'
				)

				resultado=$(paste <(zzseq -f "%d� Pr�mio\n" 1 1 5) <(echo "$resultado_num") <(echo "$resultado_val"))
				unset faixa resultado_num resultado_val
			;;
			timemania)
				data=$(     echo "$dump" | cut -d '|' -f 2)
				acumulado=$(echo "$dump" | cut -d '|' -f 24)
				acumulado=${acumulado}"|"$(echo "$dump" | cut -d '|' -f 23)
				resultado=$(echo "$dump" | cut -d '|' -f 8 |
					tr '*' '-'  |
					tr '|' '\n' |
					sed 's/^ - //'
				)
				resultado=$(echo -e ${resultado}"\nTime: "$(echo "$dump" | cut -d '|' -f 9))
				faixa=$(zzseq -f "\t%d ptos\n" 7 1 3)
				resultado_num=$(echo "$dump" | cut -d '|' -f 10,12,14,16,18 | tr '|' '\n')
				resultado_val=$(echo "$dump" | cut -d '|' -f 11,13,15,17,19 | tr '|' '\n')
			;;
			loteca)
				dump=$(     echo "$dump" | sed 's/[A-Z]|[A-Z]/-/g')
				data=$(     echo "$dump" | awk -F"|" '{print $(NF-4)}' )
				acumulado=$(echo "$dump" | awk -F"|" '{print $(NF-1) "|" $(NF)}' )
				acumulado="${acumulado}_Acumulado para a 1� faixa "$(echo "$dump" | awk -F"|" '{print $(NF-5)}' )
				acumulado="${acumulado}_"$(echo "$dump" | awk -F"|" '{print $(NF-2)}' )
				acumulado=$(echo "${acumulado}" | sed 's/_/\n   /g;s/ Valor //' )
				resultado=$(printf "$dump" | cut -d '|' -f 4 |
				sed 's/ [0-9] [0-9]* /\n &/g;s/ [0-9]\{2\} [0-9]*/\n&/g' |
				sed '1d' |
				zzsemacento |
				sed 's|\(/[A-Z]\{2\}\) \(JUNIOR\)|-JR\1|g'|
				awk '{
					printf "Jogo %02d ", $1
						Time=""
						for (i = 3; i < NF-1; i++)
							{
							Time = Time " " $i
							if (index($i,"/")>0)
								{
								if (i < NF-2)  printf "%-24s %2s X %-2s", Time, $2, $(NF-1)
								if (i == NF-2) printf "%24s", Time
								Time=""
								}
							}
					if ( length(Time)>0 ) {
						if (split(Time, arr_time) == 2)
							printf " %-23s %2s X %-2s %23s", arr_time[1], $2, $(NF-1), arr_time[2]
						else
							printf "%2s X %-2s %-47s ", $2, $(NF-1), "(" Time " )"
						}
					if ( $2 > $(NF-1) ) printf " %s\n", "- Col.  1 "
					if ( $2 == $(NF-1) ) printf " %s\n", "- Col. Meio"
					if ( $2 < $(NF-1) ) printf " %s\n", "- Col.  2"
					#printf " %-3s\n", $(NF)

					}')
				faixa=$(zzseq -f '\t%d\n' 14 13)
				resultado_num=$(echo "$dump" | cut -d '|' -f 5 | sed 's/ [12].\{1,2\} (1[34] acertos)/\n/g;' |sed '1d' | sed 's/[0-9] /&\t/g')
				unset resultado_val
			;;
		esac

		# Mostra o resultado na tela (caso encontrado algo)
		if [ "$resultado" ]
		then
			zztool eco $tipo:
			echo "$resultado" | sed 's/^/   /'
			echo "   Concurso $numero_concurso ($data)"
			[ "$acumulado" ] && echo "   Acumulado em R$ $acumulado" | sed 's/|/ para /'
			if [ "$faixa" ]
			then
				echo -e "\tFaixa\tQtde.\tPr�mio"|expand -t 5,17,32
				paste <(echo -e "$faixa"|zzsemacento) <(echo -e "$resultado_num") <(echo -e "$resultado_val")|expand -t 5,17,32
			fi
			echo
		fi
	done
}

# ----------------------------------------------------------------------------
# zzmaiores
# Acha os maiores arquivos/diret�rios do diret�rio atual (ou outros).
# Op��es: -r  busca recursiva nos subdiret�rios
#         -f  busca somente os arquivos e n�o diret�rios
#         -n  n�mero de resultados (o padr�o � 10)
# Uso: zzmaiores [-r] [-f] [-n <n�mero>] [dir1 dir2 ...]
# Ex.: zzmaiores
#      zzmaiores /etc /tmp
#      zzmaiores -r -n 5 ~
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-08-28
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzmaiores ()
{
	zzzz -h maiores "$1" && return

	local pastas recursivo modo tab resultado
	local limite=10

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			-n)
				limite=$2
				shift; shift
			;;
			-f)
				modo='f'
				shift
				# At� queria fazer um -d tamb�m para diret�rios somente,
				# mas o du sempre mostra os arquivos quando est� recursivo
				# e o find n�o mostra o tamanho total dos diret�rios...
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

	if [ "$modo" = 'f' ]
	then
		# Usu�rio s� quer ver os arquivos e n�o diret�rios.
		# Como o 'du' n�o tem uma op��o para isso, usaremos o 'find'.

		# Se forem v�rias pastas, comp�e a lista glob: {um,dois,tr�s}
		# Isso porque o find n�o aceita m�ltiplos diret�rios sem glob.
		# Caso contr�rio tenta $1 ou usa a pasta corrente "."
		if [ "$2" ]
		then
			pastas=$(echo {$*} | tr -s ' ' ',')
		else
			pastas=${1:-.}
			[ "$pastas" = '*' ] && pastas='.'
		fi

		tab=$(echo -e '\t')
		[ "$recursivo" ] && recursivo= || recursivo='-maxdepth 1'

		resultado=$(
			find $pastas $recursivo -type f -ls |
				tr -s ' ' |
				cut -d' ' -f7,11- |
				sed "s/ /$tab/" |
				sort -nr |
				sed "$limite q"
		)
	else
		# Tentei de v�rias maneiras juntar o glob com o $@
		# para que funcionasse com o ponto e sem argumentos,
		# mas no fim � mais f�cil chamar a fun��o de novo...
		pastas="$@"
		if [ ! "$pastas" -o "$pastas" = '.' ]
		then
			zzmaiores ${recursivo:+-r} -n $limite * .[^.]*
			return

		fi

		# O du sempre mostra arquivos e diret�rios, bacana
		# Basta definir se vai ser recursivo (-a) ou n�o (-s)
		[ "$recursivo" ] && recursivo='-a' || recursivo='-s'

		# Estou escondendo o erro para caso o * ou o .* n�o expandam
		# Bash2: nullglob, dotglob
		resultado=$(
			du $recursivo "$@" 2>/dev/null |
				sort -nr |
				sed "$limite q"
		)
	fi
	# TODO � K (nem �, s� se usar -k -- conferir no SF) se vier do du e bytes se do find
	echo "$resultado"
	# | while read tamanho arquivo
	# do
	# 		echo -e "$(zzbyte $tamanho)\t$arquivo"
	# done
}

# ----------------------------------------------------------------------------
# zzmaiusculas
# Converte todas as letras para MAI�SCULAS, inclusive acentuadas.
# Uso: zzmaiusculas [texto]
# Ex.: zzmaiusculas eu quero gritar                # via argumentos
#      echo eu quero gritar | zzmaiusculas         # via STDIN
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-06-12
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzmaiusculas ()
{
	zzzz -h maiusculas "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	sed '
		y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/
		y/�������������������������/�������������������������/'
}

# ----------------------------------------------------------------------------
# zzmat
# Uma colet�nea de fun��es matem�ticas simples.
# Se o primeiro argumento for um '-p' seguido de n�mero sem espa�o
# define a precis�o dos resultados ( casas decimais ), o padr�o � 6
# Em cada fun��o foi colocado um pequeno help um pouco mais detalhado,
# pois ficou muito extenso colocar no help do zzmat apenas.
#
# Fun��es matem�ticas dispon�veis.
# mmc mdc somatoria produtoria media soma fat arranjo arranjo_r combinacao
# combinacao_r pa pa2 pg area volume eq2g d2p egr err egc egc3p ege vetor
# converte sen cos tan csc sec cot asen acos atan log ln abs
# raiz potencia pow elevado aleatorio random det conf_eq sem_zeros
# fibonacci (fib) lucas tribonacci (trib) newton binomio_newton
# Mais detalhes: zzmat fun��o
#
# Uso: zzmat [-pnumero] funcoes [n�mero] [n�mero]
# Ex.: zzmat mmc 8 12
#      zzmat media 5[2] 7 4[3]
#      zzmat somatoria 3 9 2x+3
#      zzmat -p3 sen 60g
#
# Autor: Itamar
# Desde: 2011-01-19
# Vers�o: 12
# Licen�a: GPL
# Requisitos: zzcalcula zzseq
# ----------------------------------------------------------------------------
zzmat ()
{
	zzzz -h mat "$1" && return

	local funcao num precisao
	local pi=3.1415926535897932384626433832795
	local LANG=en

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso mat; return 1; }

	# Definindo a precis�o dos resultados qdo � pertinente. Padr�o � 6.
	echo "$1" | grep '^-p' >/dev/null
	if [ "$?" = "0" ]
	then
		precisao="${1#-p}"
		zztool testa_numero $precisao || precisao="6"
		shift
	else
		precisao="6"
	fi

	funcao="$1"

	case "$funcao" in
	testa_num)
		# Testa se $2 � um n�mero n�o coberto pela zztool testa_numero*
		echo "$2"|sed 's/^-[\.,]/-0\./;s/^[\.,]/0\./'|
		grep '^[+-]\{0,1\}[0-9]\{1,\}[,.]\{0,1\}[0-9]*$' >/dev/null
	;;
	testa_num_exp)
		local num1 num2 num3
		echo "$2"|grep -E '(e|E)' >/dev/null
		if [ $? -eq 0 ]
		then
			num3=$(echo "$2"|tr 'E,' 'e.')
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
		if [ $precisao -gt 0 ]
			then
			echo "$num1"|grep '\.' > /dev/null
			if [ "$?" = "0" ]
			then
				num1=$(echo "$num1" | sed 's/[0[:blank:]]*$//' | sed 's/\.$//')
			fi
		fi
		num1=$(echo "$num1"|sed 's/^\./0\./')
		echo "$num1"
	;;
	compara_num)
		if ([ $# -eq "3" ] && zzmat testa_num $2 && zzmat testa_num $3)
		then
			local num1 num2 retorno
			num1=$(echo "$2"|tr ',' '.')
			num2=$(echo "$3"|tr ',' '.')
			retorno=$(
			awk 'BEGIN {
				if ('$num1' > '$num2') {print "maior"}
				if ('$num1' == '$num2') {print "igual"}
				if ('$num1' < '$num2') {print "menor"}
			}')
			echo "$retorno"
		else
			echo " zzmat $funcao: Compara 2 numeros"
			echo " Retorna o texto 'maior', 'menor' ou 'igual'"
			echo " Uso: zzmat $funcao numero numero"
			return 1
		fi
	;;
	int)
		local num1
		shift
		num1=$(zztool multi_stdin "$@" | tr ',' '.')
		if zzmat testa_num $num1
		then
			echo $num1 | sed 's/\..*$//'
		else
			echo " zzmat $funcao: Valor Inteiro"
			echo " Uso: zzmat $funcao numero"
			echo "      echo numero | zzmat $funcao"
			return 1
		fi
	;;
	abs)
		local num1
		shift
		num1=$(zztool multi_stdin "$@" | tr ',' '.')
		if zzmat testa_num $num1
		then
			echo "$num1" | sed 's/^[-+]//'
		else
			echo " zzmat $funcao: Valor Absoluto"
			echo " Uso: zzmat $funcao numero"
			echo "      echo numero | zzmat $funcao"
			return 1
		fi
	;;
	converte)
		if ([ $# -eq "3" ] && zzmat testa_num $3)
		then
			local num1
			num1=$(echo "$3"|tr ',' '.')
			case $2 in
			gr) num="$num1*$pi/180";;
			rg) num="$num1*180/$pi";;
			dr) num="$num1*$pi/200";;
			rd) num="$num1*200/$pi";;
			dg) num="$num1*0.9";;
			gd) num="$num1/0.9";;
			??)
				local grandeza1 grandeza2 fator divisor potencia
				local grandezas="y z a f p n u m c d 1 D H K M G T P E Z Y"
				local potencias="-24 -21 -18 -15 -12 -9 -6 -3 -2 -1 0 1 2 3 6 9 12 15 18 21 24"
				local posicao='1'
				precisao=24
				grandeza1=$(echo "$2" | sed 's/\([[:alpha:]1]\)[[:alpha:]1]/\1/')
				grandeza2=$(echo "$2" | sed 's/[[:alpha:]1]\([[:alpha:]1]\)/\1/')
				if ([ "$grandeza1" != "$grandeza2" ])
				then
					for letra in $(echo "$grandezas")
					do
						potencia=$(echo "$potencias"|awk '{print $'$posicao'}')
						[ "$grandeza1" = "$letra" ] && fator=$(zzmat -p${precisao} elevado 10 $potencia)
						[ "$grandeza2" = "$letra" ] && divisor=$(zzmat -p${precisao} elevado 10 $potencia)
						let posicao++
					done
					if ([ "$fator" ] && [ "$divisor" ])
					then
						echo "$num1 $fator $divisor" |
						awk '{printf "%.'$precisao'f\n", $1*$2/$3}' |
						zzmat -p${precisao} sem_zeros
					fi
				fi
			;;
			esac
		else
			echo " zzmat $funcao: Convers�es de unidades (n�o contempladas no zzconverte)"
			echo " Sub-fun��es:
	gr: graus para radiano
	rg: radiano para graus
	dr: grado para radiano
	rd: radiano para grado
	dg: grado para graus
	gd: graus para grado
	ou com os pares do Sistema Internacional de Unidade
	(y z a f p n u m c d 1 D H K M G T P E Z Y)
	usando a combi��o dessa letras em pares, sendo na ordem 'de' 'para'.
	Obs: o 1 no centro representa a unidade de medida que n�o possui prefixo.
	Aten��o: Dependendo do computador, arquitetura e a precisao do sistema
			podem haver distor��es em valores muito distantes entre si.
	Exempo: Kd converte de Kilo para deci."
			echo " Uso: zzmat $funcao sub-fun��o n�mero"
			return 1
		fi
	;;
	sen|cos|tan|csc|sec|cot)
		if ([ $# -eq "2" ])
		then
			local num1 num2 ang
			num1=$(echo "$2" | sed 's/g$//; s/gr$//; s/rad$//' | tr , .)
			ang=${2#$num1}
			echo "$2"|grep -E '(g|rad|gr)$' >/dev/null
			if ([ "$?" -eq "0" ] && zzmat testa_num $num1)
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

				[ "$num1" ] && num="$num1"
			else
				echo " Uso: zzmat $funcao n�mero(g|rad|gr) {graus|radianos|grado}"
			fi
		else
			echo " zzmat Fun��o Trigonom�trica:
	sen: Seno
	cos: Cosseno
	tan: Tangente
	sec: Secante
	csc: Cossecante
	cot: Cotangente"
			echo " Uso: zzmat $funcao n�mero(g|rad|gr) {graus|radianos|grado}"
			return 1
		fi
	;;
	asen|acos|atan)
		if [ $# -ge "2" ] && [ $# -le "4" ] && zzmat testa_num $2
		then
			local num1 num2 num3 sinal
			num1=$(echo "$2"|tr ',' '.')
			[ "$funcao" != "atan" ] && num2=$(awk 'BEGIN {if ('$num1'>1 || '$num1'<-1) print "erro"}')
			if [ "$num2" = "erro" ]
			then
				zzmat $funcao -h;return 1
			fi

			echo "$num1"|grep '^-' >/dev/null && sinal="-" || unset sinal
			num1=$(zzmat abs $num1)

			case $funcao in
			atan)
				num2=$(echo "a(${num1})"|bc -l)
				[ "$sinal" ] && num2=$(echo "($pi)-($num2)"|bc -l)
				echo "$4"|grep '2' >/dev/null && num2=$(echo "($num2)+($pi)"|bc -l)
			;;
			asen)
				num3=$(echo "sqrt(1-${num1}^2)"|bc -l|awk '{printf "%.'${precisao}'f\n", $1}')
				if [ "$num3" = $(printf '%.'${precisao}'f' 0|tr ',' '.') ]
				then
					num2=$(echo "$pi/2"|bc -l)
				else
					num2=$(echo "a(${num1}/sqrt(1-${num1}^2))"|bc -l)
				fi
				echo "$4"|grep '2' >/dev/null && num2=$(echo "($pi)-($num2)"|bc -l)
				[ "$sinal" ] && num2=$(echo "($pi)+($num2)"|bc -l)
			;;
			acos)
				num3=$(echo "$num1"|bc -l|awk '{printf "%.'${precisao}'f\n", $1}')
				if [ "$num3" = $(printf '%.'${precisao}'f' 0|tr ',' '.') ]
				then
					num2=$(echo "$pi/2"|bc -l)
				else
					num2=$(echo "a(sqrt(1-${num1}^2)/${num1})"|bc -l)
				fi
				[ "$sinal" ] && num2=$(echo "($pi)-($num2)"|bc -l)
				echo "$4"|grep '2' >/dev/null && num2=$(echo "2*($pi)-($num2)"|bc -l)
			;;
			esac

			echo "$4"|grep 'r' >/dev/null && num2=$(echo "($num2)-2*($pi)"|bc -l)

			case $3 in
			g)      num=$(zzmat converte rg $num2);;
			gr)     num=$(zzmat converte rd $num2);;
			rad|"") num="$num2";;
			esac
		else
			echo " zzmat Fun��o Trigonom�trica:
	asen: Arco-Seno
	acos: Arco-Cosseno
	atan: Arco-Tangente"
			echo " Retorna o angulo em radianos, graus ou grado."
			echo " Se n�o for definido retorna em radianos."
			echo " Valores devem estar entre -1 e 1, para arco-seno e arco-cosseno."
			echo " Caso a op��o seja '2' retorna o segundo �ngulo poss�vel do valor."
			echo " E se for 'r' retorna o �ngulo no sentido invertido (replementar)."
			echo " As duas op��es poder ser combinadas: r2 ou 2r."
			echo " Uso: zzmat $funcao n�mero [[g|rad|gr] [op��o]]"
			return 1
		fi
	;;
	log|ln)
		if ([ $# -ge "2" ] && [ $# -le "3" ] && zzmat testa_num $2)
		then
			local num1 num2
			num1=$(echo "$2" | tr ',' '.')
			zzmat testa_num "$3" && num2=$(echo "$3" | tr ',' '.')
			if [ "$num2" ]
			then
				num="l($num1)/l($num2)"
			elif [ "$funcao" = "log" ]
			then
				num="l($num1)/l(10)"
			else
				num="l($num1)"
			fi
		else
			echo " Se n�o definir a base no terceiro argumento:"
			echo " zzmat log: Logaritmo base 10"
			echo " zzmat ln: Logaritmo Natural base e"
			echo " Uso: zzmat $funcao numero [base]"
			return 1
		fi
	;;
	raiz)
		if ([ $# -eq "3" ] && zzmat testa_num "$3")
		then
			local num1 num2
			case "$2" in
			quadrada) num1=2;;
			cubica)   num1=3;;
			*)          num1="$2";;
			esac
			num2=$(echo "$3"|tr ',' '.')
			if zzmat testa_num $num1
			then
				num=$(awk 'BEGIN {printf "%.'${precisao}'f\n", '$num2'^(1/'$num1')}')
			else
				echo " Uso: zzmat $funcao <quadrada|cubica|numero> numero"
			fi
		else
			echo " zzmat $funcao: Raiz enesima de um n�mero"
			echo " Uso: zzmat $funcao <quadrada|cubica|numero> numero"
			return 1
		fi
	;;
	potencia|elevado|pow)
		if ([ $# -eq "3" ] && zzmat testa_num "$2" && zzmat testa_num "$3")
		then
			local num1 num2
			num1=$(echo "$2"|tr ',' '.')
			num2=$(echo "$3"|tr ',' '.')
			num=$(awk 'BEGIN {printf "%.'${precisao}'f\n", ('$num1')^('$num2')}')
		else
			echo " zzmat $funcao: Um n�mero elevado a um pot�ncia"
			echo " Uso: zzmat $funcao n�mero potencia"
			return 1
		fi
	;;
	area)
		if ([ $# -ge "2" ])
		then
			local num1 num2 num3
			case "$2" in
			triangulo)
				if(zzmat testa_num $3 && zzmat testa_num $4)
				then
					num1=$(echo "$3"|tr ',' '.')
					num2=$(echo "$4"|tr ',' '.')
					num="${num1}*${num2}/2"
				else
					echo " Uso: zzmat $funcao $2 base altura";return 1
				fi
			;;
			retangulo|losango)
				if(zzmat testa_num $3 && zzmat testa_num $4)
				then
					num1=$(echo "$3"|tr ',' '.')
					num2=$(echo "$4"|tr ',' '.')
					num="${num1}*${num2}"
				else
					printf " Uso: zzmat %s %s " $funcao $2
					[ "$2" = "retangulo" ] && echo "base altura" || echo "diagonal_maior diagonal_menor"
					return 1
				fi
			;;
			trapezio)
				if(zzmat testa_num $3 && zzmat testa_num $4 && zzmat testa_num $5)
				then
					num1=$(echo "$3"|tr ',' '.')
					num2=$(echo "$4"|tr ',' '.')
					num3=$(echo "$5"|tr ',' '.')
					num="((${num1}+${num2})/2)*${num3}"
				else
					echo " Uso: zzmat $funcao $2 base_maior base_menor altura";return 1
				fi
			;;
			toro)
				if(zzmat testa_num $3 && zzmat testa_num $4 && [ $(zzmat compara_num $3 $4) != "igual" ])
				then
					num1=$(echo "$3"|tr ',' '.')
					num2=$(echo "$4"|tr ',' '.')
					num="4*${pi}^2*${num1}*${num2}"
				else
					echo " Uso: zzmat $funcao $2 raio1 raio2";return 1
				fi
			;;
			tetraedro|cubo|octaedro|dodecaedro|icosaedro|quadrado|circulo|esfera|cuboctaedro|rombicuboctaedro|rombicosidodecaedro|icosidodecaedro)
				if ([ "$3" ])
				then
					if(zzmat testa_num $3)
					then
						num1=$(echo "$3"|tr ',' '.')
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
					elif ([ $3 = "truncado" ] && zzmat testa_num $4)
					then
						num1=$(echo "$4"|tr ',' '.')
						case $2 in
						tetraedro)       num="7*sqrt(3)*${num1}^2";;
						cubo)            num="2*${num1}^2*(6+6*sqrt(2)+6*sqrt(3))";;
						octaedro)        num="(6+sqrt(3)*12)*${num1}^2";;
						dodecaedro)      num="(sqrt(3)+6*sqrt(5+2*sqrt(5)))*5*${num1}^2";;
						icosaedro)       num="3*(10*sqrt(3)+sqrt(5)*sqrt(5+2*sqrt(5)))*${num1}^2";;
						cuboctaedro)     num="12*(2+sqrt(2)+sqrt(3))*${num1}^2";;
						icosidodecaedro) num="30*(1+sqrt(2*sqrt(4+sqrt(5)+sqrt(15+6*sqrt(6)))))*${num1}^2";;
						esac
					elif ([ $3 = "snub" ] && zzmat testa_num $4)
					then
						num1=$(echo "$4"|tr ',' '.')
						case $2 in
						cubo)       num="${num1}^2*(6+8*sqrt(3))";;
						dodecaedro) num="55.286744956*${num1}^2";;
						esac
					else
						echo " Uso: zzmat $funcao $2 lado|raio";return 1
					fi
				else
					echo " Uso: zzmat $funcao $2 lado|raio";return 1
				fi
			;;
			esac
		else
			echo " zzmat $funcao: C�lculo da �rea de figuras planas e superf�cies"
			echo " Uso: zzmat area <triangulo|quadrado|retangulo|losango|trapezio|circulo> numero"
			echo " Uso: zzmat area <esfera|rombicuboctaedro|rombicosidodecaedro> numero"
			echo " Uso: zzmat area <tetraedo|cubo|octaedro|dodecaedro|icosaedro|cuboctaedro|icosidodecaedro> [truncado] numero"
			echo " Uso: zzmat area <cubo|dodecaedro> snub numero"
			echo " Uso: zzmat area toro numero numero"
			return 1
		fi
	;;
	volume)
		if ([ $# -ge "2" ])
		then
			local num1 num2 num3
			case "$2" in
			paralelepipedo)
				if(zzmat testa_num $3 && zzmat testa_num $4 && zzmat testa_num $5)
				then
					num1=$(echo "$3"|tr ',' '.')
					num2=$(echo "$4"|tr ',' '.')
					num3=$(echo "$5"|tr ',' '.')
					num="${num1}*${num2}*${num3}"
				else
					echo " Uso: zzmat $funcao $2 comprimento largura altura";return 1
				fi
			;;
			cilindro)
				if(zzmat testa_num $3 && zzmat testa_num $4)
				then
					num1=$(echo "$3"|tr ',' '.')
					num2=$(echo "$4"|tr ',' '.')
					num="($pi*(${num1})^2)*${num2}"
				else
					echo " Uso: zzmat $funcao $2 raio altura";return 1
				fi
			;;
			cone)
				if(zzmat testa_num $3 && zzmat testa_num $4)
				then
					num1=$(echo "$3"|tr ',' '.')
					num2=$(echo "$4"|tr ',' '.')
					num="($pi*(${num1})^2)*${num2}/3"
				else
					echo " Uso: zzmat $funcao $2 raio altura";return 1
				fi
			;;
			prisma)
				if(zzmat testa_num $3 && zzmat testa_num $4)
				then
					num1=$(echo "$3"|tr ',' '.')
					num2=$(echo "$4"|tr ',' '.')
					num="${num1}*${num2}"
				else
					echo " Uso: zzmat $funcao $2 area_base altura";return 1
				fi
			;;
			piramide)
				if(zzmat testa_num $3 && zzmat testa_num $4)
				then
					num1=$(echo "$3"|tr ',' '.')
					num2=$(echo "$4"|tr ',' '.')
					num="${num1}*${num2}/3"
				else
					echo " Uso: zzmat $funcao $2 area_base altura";return 1
				fi
			;;
			toro)
				local num_maior num_menor
				if(zzmat testa_num $3 && zzmat testa_num $4 && [ $(zzmat compara_num $3 $4) != "igual" ])
				then
					num1=$(echo "$3"|tr ',' '.')
					num2=$(echo "$4"|tr ',' '.')
					[ $num1 -gt $num2 ] && num_maior=$num1 || num_maior=$num2
					[ $num1 -lt $num2 ] && num_menor=$num1 || num_menor=$num2
					num="2*${pi}^2*${num_menor}^2*${num_maior}"
				else
					echo " Uso: zzmat $funcao $2 raio1 raio2";return 1
				fi
			;;
			tetraedro|cubo|octaedro|dodecaedro|icosaedro|esfera|cuboctaedro|rombicuboctaedro|rombicosidodecaedro|icosidodecaedro)
				if [ "$3" ]
				then
					if(zzmat testa_num $3)
					then
						num1=$(echo "$3"|tr ',' '.')
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
					elif ([ $3 = "truncado" ] && zzmat testa_num $4)
					then
						num1=$(echo "$4"|tr ',' '.')
						case $2 in
						tetraedro)       num="23*sqrt(2)/12*${num1}^3";;
						cubo)            num="(7*${num1}^3*(3+2*sqrt(2)))/3";;
						octaedro)        num="8*sqrt(2)*${num1}^3";;
						dodecaedro)      num="5*(99+47*sqrt(5))/12*${num1}^3";;
						icosaedro)       num="(125+43*sqrt(5))*${num1}^3*1/4";;
						cuboctaedro)     num="(22+14*sqrt(2))*${num1}^3";;
						icosidodecaedro) num="(90+50*sqrt(5))*${num1}^3";;
						esac
					elif ([ $3 = "snub" ] && zzmat testa_num $4)
					then
						num1=$(echo "$4"|tr ',' '.')
						case $2 in
						cubo)       num="7.8894774*${num1}^3";;
						dodecaedro) num="37.61664996*${num1}^3";;
						esac
					else
						echo " Uso: zzmat $funcao $2 lado|raio";return 1
					fi
				else
					echo " Uso: zzmat $funcao $2 lado|raio";return 1
				fi
			;;
			esac
		else
			echo " zzmat $funcao: C�lculo de volume de figuras geom�tricas"
			echo " Uso: zzmat volume <paralelepipedo|cilindro|esfera|cone|prisma|piramide|rombicuboctaedro|rombicosidodecaedro> numero"
			echo " Uso: zzmat volume <tetraedo|cubo|octaedro|dodecaedro|icosaedro|cuboctaedro|icosidodecaedro> [truncado] numero"
			echo " Uso: zzmat volume <cubo|dodecaedro> snub numero"
			echo " Uso: zzmat volume toro numero numero"
			return 1
		fi
	;;
	mmc|mdc)
		if [ $# -ge "3" ]
		then
			local num_maior num_menor resto mdc mmc num2
			local num1=$2
			shift
			shift
			for num2 in $*
			do
				if (zztool testa_numero $num1 && zztool testa_numero $num2)
				then
					[ "$num1" -gt "$num2" ] && num_maior=$num1 || num_maior=$num2
					[ "$num1" -lt "$num2" ] && num_menor=$num1 || num_menor=$num2

					while [ "$num_menor" -ne "0" ]
					do
						resto=$((${num_maior}%${num_menor}))
						num_maior=$num_menor
						num_menor=$resto
					done

					mdc=$num_maior
					mmc=$((${num1}*${num2}/${mdc}))
				fi
				shift
				[ "$funcao" = "mdc" ] && num1="$mdc" || num1="$mmc"
			done

			case $funcao in
			mmc) echo "$mmc";;
			mdc) echo "$mdc";;
			esac
		else
			echo " zzmat mmc: Menor M�ltiplo Comum"
			echo " zzmat mdc: Maior Divisor Comum"
			echo " Uso: zzmat $funcao numero numero ..."
			return 1
		fi
	;;
	somatoria|produtoria)
		#colocar x como a variavel a ser substituida
		if ([ $# -eq "4" ])
		then
			zzmat $funcao $2 $3 1 $4
		elif ([ $# -eq "5" ] && zzmat testa_num $2 && zzmat testa_num $3 && 
			zzmat testa_num $4 && zztool grep_var "x" $5 )
		then
			local equacao numero operacao sequencia num1 num2
			equacao=$(echo "$5"|sed 's/\[/(/g;s/\]/)/g')
			[ "$funcao" = "somatoria" ] && operacao='+' || operacao='*'
			if ([ $(zzmat compara_num $2 $3) = 'maior' ])
			then
				num1=$2; num2=$3
			else
				num1=$3; num2=$2
			fi
			sequencia=$(zzmat pa $num2 $4 $(zzcalcula "(($num1 - $num2)/$4)+1" | zzmat int)| tr ' ' '\n')
			num=$(for numero in $sequencia
			do
				echo "($equacao)"|sed "s/^[x]/($numero)/;s/\([(+-]\)x/\1($numero)/g;s/\([0-9]\)x/\1\*($numero)/g;s/x/$numero/g"
			done|paste -s -d"$operacao" -)
		else
			echo " zzmat $funcao: Soma ou Produto de express�o"
			echo " Uso: zzmat $funcao limite_inferior limite_superior equacao"
			echo " Uso: zzmat $funcao limite_inferior limite_superior razao equacao"
			echo " Usar 'x' como vari�vel na equa��o"
			echo " Usar '[' e ']' respectivamente no lugar de '(' e ')', ou proteger"
			echo " a f�rmula com aspas duplas(\") ou simples(')"
			return 1
		fi
	;;
	media|soma)
		if ([ $# -ge "2" ])
		then
			local soma=0
			local qtde=0
			local peso=1
			local valor
			shift
			while [ $# -ne "0" ]
			do
				if (zztool grep_var "[" "$1" && zztool grep_var "]" "$1")
				then
					valor=$(echo "$1"|sed 's/\([0-9]\{1,\}\)\[.*/\1/'|tr ',' '.')
					peso=$(echo "$1"|sed 's/.*\[//;s/\]//')
					if (zzmat testa_num "$valor" && zztool testa_numero "$peso")
					then
						soma=$(echo "$soma+($valor*$peso)"|bc -l)
						qtde=$(($qtde+$peso))
					fi
				elif zzmat testa_num "$1"
				then
					soma=$(echo "($soma) + ($1)"|tr ',' '.'|bc -l)
					qtde=$(($qtde+1))
				else
					zztool uso mat; return 1;
				fi
				shift
			done
			case "$funcao" in
			media) num="${soma}/${qtde}";;
			soma)  num="${soma}";;
			esac
		else
			echo " zzmat $funcao:Soma ou M�dia Aritim�tica e Ponderada"
			echo " Uso: zzmat $funcao numero[[peso]] [numero[peso]] ..."
			echo " Usar o peso entre '[' e ']', justaposto ao n�mero."
			return 1
		fi
	;;
	fat)
		if ([ $# -eq "2" ] && zztool testa_numero "$2" && [ "$2" -ge "1" ])
		then
			zzseq 1 $2 | paste -s -d* - | bc -l
		else
			echo " zzmat $funcao: Resultado do produto de 1 ao numero atual (fatorial)"
			echo " Uso: zzmat $funcao numero"
			return 1
		fi
	;;
	arranjo|combinacao|arranjo_r|combinacao_r)
		if ([ $# -eq "3" ] && zztool testa_numero "$2" && zztool testa_numero "$3" &&
			[ "$2" -ge "$3" ] && [ "$3" -ge "1" ])
		then
			local n p dnp
			n=$(zzmat fat $2)
			p=$(zzmat fat $3)
			dnp=$(zzmat fat $(($2-$3)))
			case "$funcao" in
			arranjo)    [ "$2" -gt "$3" ] && num="${n}/${dnp}" || return 1;;
			arranjo_r)	zzmat elevado "$2" "$3";;
			combinacao) [ "$2" -gt "$3" ] && num="${n}/(${p}*${dnp})" || return 1;;
			combinacao_r)
				if ([ "$2" -gt "$3" ])
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
			echo " zzmat arranjo: n elementos tomados em grupos de p (considera ordem)"
			echo " zzmat arranjo_r: n elementos tomados em grupos de p com repeti��o (considera ordem)"
			echo " zzmat combinacao: n elementos tomados em grupos de p (desconsidera ordem)"
			echo " zzmat combinacao_r: n elementos tomados em grupos de p com repeti��o (desconsidera ordem)"
			echo " Uso: zzmat $funcao total_numero quantidade_grupo"
			return 1
		fi
	;;
	newton|binomio_newton)
		if ([ "$#" -ge "2" ])
		then
			local num1 num2 grau sinal parcela coeficiente
			num1="a"
			num2="b"
			sinal="+"
			zztool testa_numero "$2" && grau="$2"
			if [ "$3" ]
			then
				if [ "$3" = "+" -o "$3" = "-" ]
				then
					sinal="$3"
					[ "$4" ] && num1="$4"
					[ "$5" ] && num2="$5"
				else
					[ "$3" ] && num1="$3"
					[ "$4" ] && num2="$4"
				fi
			fi
			echo "($num1)^$grau"
			for parcela in $(seq 1 $((grau-1)))
			do
				coeficiente=$(zzmat combinacao $grau $parcela)
				[ "$sinal" = "-" -a $((parcela%2)) -eq 1 ] && printf "%s" "-" || printf "%s" "+"
				printf "%s" "$coeficiente"
				echo "($num1)^$(($grau-$parcela))($num2)^$parcela"|sed 's/\^1\([^0-9]\)/\1/g;s/\^1$//'
			done
			[ "$sinal" = "-" -a $((grau%2)) -eq 1 ] && printf "%s" "-" || printf "%s" "+"
			echo "($num2)^$grau"
		else
			echo " zzmat $funcao: Exibe o desdobramento do bin�nimo de Newton."
			echo " Exemplo no grau 3: (a + b)^3 = a^3 + 2a^2b + 2ab^2 + b^3"
			echo " Se nenhum sinal for especificado ser� assumido '+'"
			echo " Se n�o declarar vari�veis ser�o assumidos 'a' e 'b'"
			echo " Uso: zzmat $funcao grau [+|-] [variavel(a) [variavel(b)]]"
		fi
	;;
	pa|pa2|pg)
		if ([ $# -eq "4" ] && zzmat testa_num "$2" &&
		zzmat testa_num "$3" && zztool testa_numero "$4")
		then
			local num_inicial razao passo valor
			num_inicial=$(echo "$2"|tr ',' '.')
			razao=$(echo "$3"|tr ',' '.')
			passo=0
			valor=$num_inicial
			while ([ $passo -lt $4 ])
			do
				if [ "$funcao" = "pa" ]
				then
					valor=$(echo "$num_inicial + ($razao * $passo)"|bc -l|
					awk '{printf "%.'${precisao}'f\n", $1}')
				elif [ "$funcao" = "pa2" ]
				then
					valor=$(echo "$valor + ($razao * $passo)"|bc -l|
					awk '{printf "%.'${precisao}'f\n", $1}')
				else
					valor=$(echo "$num_inicial * $razao^$passo"|bc -l|
					awk '{printf "%.'${precisao}'f\n", $1}')
				fi
				valor=$(echo "$valor"|zzmat -p${precisao} sem_zeros)
				printf " %s" "$valor"
				passo=$(($passo+1))
			done
			echo
		else
			echo " zzmat pa:  Progress�o Aritm�tica"
			echo " zzmat pa2: Progress�o Aritm�tica de Segunda Ordem"
			echo " zzmat pg:  Progress�o Geom�trica"
			echo " Uso: zzmat $funcao inicial razao quantidade_elementos"
			return 1
		fi
	;;
	fibonacci|fib|lucas)
	# Sequ�ncia ou n�mero de fibonacci
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
				}'
			echo
		else
			echo " N�mero de fibonacci ou lucas, na posi��o especificada."
			echo " Com o argumento 's' imprime a sequ�ncia at� a posi��o."
			echo " Uso: zzmat $funcao <n�mero> [s]"
		fi
	;;
	tribonacci|trib)
	# Sequ�ncia ou n�mero Tribonacci
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
				}'
			echo
		else
			echo " N�mero de tribonacci, na posi��o especificada."
			echo " Com o argumento 's' imprime a sequ�ncia at� a posi��o."
			echo " Uso: zzmat $funcao <n�mero> [s]"
		fi
	;;
	eq2g)
	#Equa��o do Segundo Grau: Raizes e V�rtice
		if ([ $# = "4" ] && zzmat testa_num $2 && zzmat testa_num $3 && zzmat testa_num $4)
		then
			local delta num_raiz vert_x vert_y raiz1 raiz2
			delta=$(echo "$2 $3 $4"|tr ',' '.'|awk '{valor=$2^2-(4*$1*$3); print valor}')
			num_raiz=$(awk 'BEGIN { if ('$delta' > 0)  {print "2"}
									if ('$delta' == 0) {print "1"}
									if ('$delta' < 0)  {print "0"}}')

			vert_x=$(echo "$2 $3"|tr ',' '.'|
			awk '{valor=((-1 * $2)/(2 * $1)); printf "%.'${precisao}'f\n", valor}' |
			zzmat -p${precisao} sem_zeros )

			vert_y=$(echo "$2 $delta"|tr ',' '.'|
			awk '{valor=((-1 * $2)/(4 * $1)); printf "%.'${precisao}'f\n", valor}' |
			zzmat -p${precisao} sem_zeros )

			case $num_raiz in
			0) raiz1="Sem raiz";;
			1) raiz1=$vert_x;;
			2)
				raiz1=$(echo "$2 $3 $delta"|tr ',' '.'|
				awk '{valor=((-1 * $2)-sqrt($3))/(2 * $1); printf "%.'${precisao}'f\n", valor}' |
				zzmat -p${precisao} sem_zeros )

				raiz2=$(echo "$2 $3 $delta"|tr ',' '.'|
				awk '{valor=((-1 * $2)+sqrt($3))/(2 * $1); printf "%.'${precisao}'f\n", valor}' |
				zzmat -p${precisao} sem_zeros )
			;;
			esac
			[ "$num_raiz" = "2" ] && echo -e " X1: $raiz1 \n X2: $raiz2" || echo " X: $raiz1"
			echo " Vertice: (${vert_x}, ${vert_y})"
		else
			echo " zzmat $funcao: Equa��o do Segundo Grau (Ra�zes e V�rtice)"
			echo " Uso: zzmat $funcao A B C"
			return 1
		fi
	;;
	d2p)
		if ([ $# = "3" ] && zztool grep_var "," "$2" && zztool grep_var "," "$3")
		then
			local x1 y1 z1 x2 y2 z2 a b
			x1=$(echo "$2"|cut -f1 -d,)
			y1=$(echo "$2"|cut -f2 -d,)
			z1=$(echo "$2"|cut -f3 -d,)
			x2=$(echo "$3"|cut -f1 -d,)
			y2=$(echo "$3"|cut -f2 -d,)
			z2=$(echo "$3"|cut -f3 -d,)
			if (zzmat testa_num $x1 && zzmat testa_num $y1 &&
				zzmat testa_num $x2 && zzmat testa_num $y2 )
			then
				a=$(echo "(($y1)-($y2))^2"|bc -l)
				b=$(echo "(($x1)-($x2))^2"|bc -l)
				if (zzmat testa_num $z1 && zzmat testa_num $z2)
				then
					num="sqrt((($z1)-($z2))^2+$a+$b)"
				else
					num="sqrt($a+$b)"
				fi
			else
				echo " Uso: zzmat $funcao ponto(a,b) ponto(x,y)";return 1
			fi
		else
			echo " zzmat $funcao: Dist�ncia entre 2 pontos"
			echo " Uso: zzmat $funcao ponto(a,b) ponto(x,y)"
			return 1
		fi
	;;
	vetor)
		if ([ $# -ge "3" ])
		then
			local valor ang teta fi oper tipo num1 saida
			local x1=0
			local y1=0
			local z1=0
			shift

			[ "$1" = "-e" -o "$1" = "-c" ] && tipo="$1" || tipo="-e"
			oper="+"
			saida=$(echo "$*"|awk '{print $NF}')

			while ([ $# -ge "1" ])
			do
				valor=$(echo "$1"|cut -f1 -d,)
				zztool grep_var "," $1 && teta=$(echo "$1"|cut -f2 -d,)
				zztool grep_var "," $1 && fi=$(echo "$1"|cut -f3 -d,)

				if ([ "$fi" ] && zzmat testa_num $valor)
				then
					num1=$(echo "$fi" | sed 's/g$//; s/gr$//; s/rad$//')
					ang=${fi#$num1}
					echo "$fi"|grep -E '(g|rad|gr)$' >/dev/null
					if ([ "$?" -eq "0" ] && zzmat testa_num $num1)
					then
						case $ang in
						g)   fi=$(zzmat converte gr $num1);;
						gr)  fi=$(zzmat converte dr $num1);;
						rad) fi=$num1;;
						esac
						z1=$(echo "$z1 $oper $(zzmat cos ${fi}rad) * $valor"|bc -l)
					elif zzmat testa_num $num1
					then
						z1="$num1"
					fi
				fi

				if ([ "$teta" ] && zzmat testa_num $valor)
				then
					num1=$(echo "$teta" | sed 's/g$//; s/gr$//; s/rad$//')
					ang=${teta#$num1}
					echo "$teta"|grep -E '(g|rad|gr)$' >/dev/null
					if ([ "$?" -eq "0" ] && zzmat testa_num $num1)
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
					[ "$fi" ] && num1=$(echo "$(zzmat sen ${fi}rad)*$valor"|bc -l) ||
						num1=$valor
					[ "$teta" ] && x1=$(echo "$x1 $oper $(zzmat cos ${teta}rad) * $num1"|bc -l) ||
						x1=$(echo "($x1) $oper ($num1)"|bc -l)
					[ "$teta" ] && y1=$(echo "$y1 $oper $(zzmat sen ${teta}rad) * $num1"|bc -l)
				fi
				shift
			done

			valor=$(echo "sqrt(${x1}^2+${y1}^2+${z1}^2)"|bc -l)
			teta=$(zzmat asen $(echo "${y1}/sqrt(${x1}^2+${y1}^2)"|bc -l))
			fi=$(zzmat acos $(echo "${z1}/${valor}"|bc -l))

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

			teta=$(awk 'BEGIN {printf "%.'${precisao}'f\n", '$teta'}'| zzmat -p${precisao} sem_zeros )
			fi=$(awk 'BEGIN {printf "%.'${precisao}'f\n", '$fi'}'| zzmat -p${precisao} sem_zeros )

			if [ "$tipo" = "-c" ]
			then
				valor=$(echo "sqrt(${valor}^2-$z1^2)"|bc -l|
					awk '{printf "%.'${precisao}'f\n", $1}'| zzmat -p${precisao} sem_zeros )
				echo "${valor},${teta}${saida},${z1}"
			else
				valor=$(echo "$valor"|bc -l|
					awk '{printf "%.'${precisao}'f\n", $1}'| zzmat -p${precisao} sem_zeros )
				echo "${valor},${teta}${saida},${fi}${saida}"
			fi
		else
			echo " zzmat $funcao: Opera��o entre vetores"
			echo " Tipo de sa�da podem ser: padr�o (-e)"
			echo "  -e: vetor em coordenadas esf�rica: valor[,teta(g|rad|gr),fi(g|rad|gr)];"
			echo "  -c: vetor em coordenada cilindrica: raio[,teta(g|rad|gr),altura]."
			echo " Os angulos teta e fi tem sufixos g(graus), rad(radianos) ou gr(grados)."
			echo " Os argumentos de entrada seguem o mesmo padr�o do tipo de sa�da."
			echo " E os tipos podem ser misturados em cada argumento."
			echo " Unidade angular � o angulo de saida usado para o vetor resultante,"
			echo " e pode ser escolhida entre g(graus), rad(radianos) ou gr(grados)."
			echo " N�o use separador de milhar. Use o ponto(.) como separador decimal."
			echo " Uso: zzmat $funcao [tipo saida] vetor [vetor2] ... [unidade angular]"
			return 1
		fi
	;;
	egr|err)
	#Equa��o Geral da Reta
	#ax + by + c = 0
	#y1  y2 = a
	#x2  x1 = b
	#x1y2  x2y1 = c
		if ([ $# = "3" ] && zztool grep_var "," "$2" && zztool grep_var "," "$3")
		then
			local x1 y1 x2 y2 a b c redutor m
			x1=$(echo "$2"|cut -f1 -d,)
			y1=$(echo "$2"|cut -f2 -d,)
			x2=$(echo "$3"|cut -f1 -d,)
			y2=$(echo "$3"|cut -f2 -d,)
			if (zzmat testa_num $x1 && zzmat testa_num $y1 &&
				zzmat testa_num $x2 && zzmat testa_num $y2 )
			then
				a=$(awk 'BEGIN {valor=('$y1')-('$y2'); printf "%.'${precisao}'f\n", valor}'| zzmat -p${precisao} sem_zeros)
				b=$(awk 'BEGIN {valor=('$x2')-('$x1');  printf "%+.'${precisao}'f\n", valor}'| zzmat -p${precisao} sem_zeros)
				c=$(zzmat det $x1 $y1 $x2 $y2|awk '{printf "%+.'${precisao}'f\n", $1}'| zzmat -p${precisao} sem_zeros)
				m=$(awk 'BEGIN {valor=(('$y2'-'$y1')/('$x2'-'$x1')); printf "%.'${precisao}'f\n", valor}'| zzmat -p${precisao} sem_zeros)
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
					echo "${a}x${b}y${c}=0"|
					sed 's/\([+-]\)1\([xy]\)/\1\2/g;s/[+]\{0,1\}0[xy]//g;s/+0=0/=0/;s/^+//';;
				err)
					redutor=$(awk 'BEGIN {printf "%+.'${precisao}'f\n", -('$m'*'$x1')+'$y1'}'| zzmat -p${precisao} sem_zeros)
					echo "y=${m}x${redutor}";;
				esac
			else
				echo " Uso: zzmat $funcao ponto(a,b) ponto(x,y)";return 1
			fi
		else
			printf " zzmat %s: " $funcao
			case "$funcao" in
			egr) echo "Equa��o Geral da Reta.";;
			err) echo "Equa��o Reduzida da Reta.";;
			esac
			echo " Uso: zzmat $funcao ponto(a,b) ponto(x,y)"
			return 1
		fi
	;;
	egc)
	#Equa��o Geral da Circunfer�ncia: Centro e Raio ou Centro e Ponto
	#x2 + y2 - 2ax - 2by + a2 + b2 - r2 = 0
	#A=-2ax | B=-2by | C=a2+b2-r2
	#r=raio | a=coordenada x do centro | b=coordenada y do centro
		if ([ $# = "3" ] && zztool grep_var "," "$2")
		then
			local a b r A B C
			if zztool grep_var "," "$3"
			then
				r=$(zzmat d2p $2 $3)
			elif zzmat testa_num "$3"
			then
				r=$(echo "$3"|tr ',' '.')
			else
				echo " Uso: zzmat $funcao centro(a,b) (numero|ponto(x,y))";return 1
			fi
			a=$(echo "$2"|cut -f1 -d,)
			b=$(echo "$2"|cut -f2 -d,)
			A=$(awk 'BEGIN {valor=-2*('$a'); print (valor<0?"":"+") valor}')
			B=$(awk 'BEGIN {valor=-2*('$b'); print (valor<0?"":"+") valor}')
			C=$(awk 'BEGIN {valor=('$a')^2+('$b')^2-('$r')^2; print (valor<0?"":"+") valor}')
			echo "x^2+y^2${A}x${B}y${C}=0"|sed 's/\([+-]\)1\([xy]\)/\1\2/g;s/[+]0[xy]//g;s/+0=0/=0/'
		else
			echo " zzmat $funcao: Equa��o Geral da Circunfer�ncia (Centro e Raio ou Centro e Ponto)"
			echo " Uso: zzmat $funcao centro(a,b) (numero|ponto(x,y))"
			return 1
		fi
	;;
	egc3p)
	#Equa��o Geral da Circunfer�ncia: 3 Pontos
		if ([ $# = "4" ] && zztool grep_var "," "$2" &&
			zztool grep_var "," "$3" && zztool grep_var "," "$4")
		then
			local x1 y1 x2 y2 x3 y3 A B C D
			x1=$(echo "$2"|cut -f1 -d,)
			y1=$(echo "$2"|cut -f2 -d,)
			x2=$(echo "$3"|cut -f1 -d,)
			y2=$(echo "$3"|cut -f2 -d,)
			x3=$(echo "$4"|cut -f1 -d,)
			y3=$(echo "$4"|cut -f2 -d,)

			if ([ $(zzmat det $x1 $y1 1 $x2 $y2 1 $x3 $y3 1) -eq 0 ])
			then
				echo "Pontos formam uma reta."
				return 1
			fi

			if (! zzmat testa_num $x1 || ! zzmat testa_num $x2 || ! zzmat testa_num $x3)
			then
				echo " Uso: zzmat $funcao ponto(a,b) ponto(c,d) ponto(x,y)";return 1
			fi

			if (! zzmat testa_num $y1 || ! zzmat testa_num $y2 || ! zzmat testa_num $y3)
			then
				echo " Uso: zzmat $funcao ponto(a,b) ponto(c,d) ponto(x,y)";return 1
			fi

			D=$(zzmat det $x1 $y1 1 $x2 $y2 1 $x3 $y3 1)
			A=$(zzmat det -$(echo "$x1^2+$y1^2"|bc) $y1 1 -$(echo "$x2^2+$y2^2"|bc) $y2 1 -$(echo "$x3^2+$y3^2"|bc) $y3 1)
			B=$(zzmat det $x1 -$(echo "$x1^2+$y1^2"|bc) 1 $x2 -$(echo "$x2^2+$y2^2"|bc) 1 $x3 -$(echo "$x3^2+$y3^2"|bc) 1)
			C=$(zzmat det $x1 $y1 -$(echo "$x1^2+$y1^2"|bc) $x2 $y2 -$(echo "$x2^2+$y2^2"|bc) $x3 $y3 -$(echo "$x3^2+$y3^2"|bc))

			A=$(awk 'BEGIN {valor='$A'/'$D';print (valor<0?"":"+") valor}')
			B=$(awk 'BEGIN {valor='$B'/'$D';print (valor<0?"":"+") valor}')
			C=$(awk 'BEGIN {valor='$C'/'$D';print (valor<0?"":"+") valor}')

			x1=$(awk 'BEGIN {valor='$A'/2*-1;print valor}')
			y1=$(awk 'BEGIN {valor='$B'/2*-1;print valor}')

			echo "x^2+y^2${A}x${B}y${C}=0"|
			sed 's/\([+-]\)1\([xy]\)/\1\2/g;s/[+]0[xy]//g;s/+0=0/=0/'
			echo "Centro: (${x1}, ${y1})"
		else
			echo " zzmat $funcao: Equa��o Geral da Circunfer�ncia (3 pontos)"
			echo " Uso: zzmat $funcao ponto(a,b) ponto(c,d) ponto(x,y)"
			return 1
		fi
	;;
	ege)
	#Equa��o Geral da Esfera: Centro e Raio ou Centro e Ponto
	#x2 + y2 + z2 - 2ax - 2by -2cz + a2 + b2 + c2 - r2 = 0
	#A=-2ax | B=-2by | C=-2cz | D=a2+b2+c2-r2
	#r=raio | a=coordenada x do centro | b=coordenada y do centro | c=coordenada z do centro
		if ([ $# = "3" ] && zztool grep_var "," "$2")
		then
			local a b c r A B C D
			if zztool grep_var "," "$3"
			then
				r=$(zzmat d2p $2 $3)
			elif zzmat testa_num "$3"
			then
				r=$(echo "$3"|tr ',' '.')
			else
				echo " Uso: zzmat $funcao centro(a,b,c) (numero|ponto(x,y,z))";return 1
			fi
			a=$(echo "$2"|cut -f1 -d,)
			b=$(echo "$2"|cut -f2 -d,)
			c=$(echo "$2"|cut -f3 -d,)

			if(! zzmat testa_num $a || ! zzmat testa_num $b || ! zzmat testa_num $c)
			then
				echo " Uso: zzmat $funcao centro(a,b,c) (numero|ponto(x,y,z))";return 1
			fi
			A=$(awk 'BEGIN {valor=-2*('$a'); print (valor<0?"":"+") valor}')
			B=$(awk 'BEGIN {valor=-2*('$b'); print (valor<0?"":"+") valor}')
			C=$(awk 'BEGIN {valor=-2*('$c'); print (valor<0?"":"+") valor}')
			D=$(awk 'BEGIN {valor='$a'^2+'$b'^2+'$c'^2-'$r'^2;print (valor<0?"":"+") valor}')
			echo "x^2+y^2+z^2${A}x${B}y${C}z${D}=0"|
			sed 's/\([+-]\)1\([xyz]\)/\1\2/g;s/[+]0[xyz]//g;s/+0=0/=0/'
		else
			echo " zzmat $funcao: Equa��o Geral da Esfera (Centro e Raio ou Centro e Ponto)"
			echo " Uso: zzmat $funcao centro(a,b,c) (numero|ponto(x,y,z))"
			return 1
		fi
	;;
	aleatorio|random)
		#Gera um numero aleatorio (randomico)
		local min=0
		local max=1
		local qtde=1
		local n_temp

		if [ "$2" = "-h" ]
		then
			echo " zzmat $funcao: Gera um n�mero aleat�rio."
			echo " Sem argumentos gera n�meros entre 0 e 1."
			echo " Com 1 argumento num�rico este fica como limite superior."
			echo " Com 2 argumentos num�ricos estabelecem os limites inferior e superior, respectivamente."
			echo " Com 3 argumentos num�ricos, o �ltimo � a quantidade de n�mero aleat�rios gerados."
			echo " Usa padr�o de 6 casas decimais. Use -p0 logo ap�s zzmat para n�meros inteiros."
			echo " Uso: zzmat $funcao [[minimo] maximo] [quantidade]"
			return
		fi

		if (zzmat testa_num $3)
		then
			max=$(echo "$3"|tr ',' '.')
			if zzmat testa_num $2;then min=$(echo "$2"|tr ',' '.');fi
		elif (zzmat testa_num $2)
		then
			max=$(echo "$2"|tr ',' '.')
		fi

		if [ $(zzmat compara_num $max $min) = "menor" ]
		then
			n_temp=$max
			max=$min
			min=$n_temp
			unset n_temp
		fi

		if [ "$4" ] && zztool testa_numero $4;then qtde=$4;fi

		case "$funcao" in
		aleatorio)
			awk 'BEGIN {srand();for(i=1;i<='$qtde';i++) { printf "%.'${precisao}'f\n", sprintf("%.'${precisao}'f\n",'$min'+rand()*('$max'-'$min'))}}'|
			zzmat -p${precisao} sem_zeros
			sleep 1
		;;
		random)
			n_temp=1
			while [ $n_temp -le $qtde ]
			do
				echo "$RANDOM"|awk '{ printf "%.'${precisao}'f\n", sprintf("%.'${precisao}'f\n",'$min'+($1/32766)*('$max'-'$min'))}'|
				zzmat -p${precisao} sem_zeros
				let n_temp++
			done
		;;
		esac
	;;
	det)
		# Determinante de matriz (2x2 ou 3x3)
		if ([ $# -ge "5" ] && [ $# -le "10" ])
		then
			local num
			shift
			for num in $*
			do
				if ! zzmat testa_num "$num"
				then
					echo " Uso: zzmat $funcao numero1 numero2 numero3 numero4 [numero5 numero6 numero7 numero8 numero9]"
					return 1
				fi
			done
			case $# in
			4) num=$(echo "($1*$4)-($2*$3)"|tr ',' '.');;
			9) num=$(echo "(($1*$5*$9)+($7*$2*$6)+($4*$8*$3)-($7*$5*$3)-($4*$2*$9)-($1*$8*$6))"|tr ',' '.');;
			*)   echo " Uso: zzmat $funcao numero1 numero2 numero3 numero4 [numero5 numero6 numero7 numero8 numero9]"; return 1;;
			esac
		else
			echo " zzmat $funcao: Calcula o valor da determinante de uma matriz 2x2 ou 3x3."
			echo " Uso: zzmat $funcao numero1 numero2 numero3 numero4 [numero5 numero6 numero7 numero8 numero9]"
			echo " Ex:  zzmat det 1 3 2 4"
		fi
	;;
	conf_eq)
		# Confere equa��o
		if ([ $# -ge "2" ])
		then
			equacao=$(echo "$2"|sed 's/\[/(/g;s/\]/)/g')
			local x y z eq
			shift
			shift
			while ([ $# -ge "1" ])
			do
				x=$(echo "$1" | cut -f1 -d,)
				zztool grep_var "," $1 && y=$(echo "$1"|cut -f2 -d,)
				zztool grep_var "," $1 && z=$(echo "$1"|cut -f3 -d,)
				eq=$(echo $equacao | sed "s/^[x]/$x/;s/\([(+-]\)x/\1($x)/g;s/\([0-9]\)x/\1\*($x)/g;s/x/$x/g"|
					sed "s/^[y]/$y/;s/\([(+-]\)y/\1($y)/g;s/\([0-9]\)y/\1\*($y)/g;s/y/$y/g"|
					sed "s/^[z]/$z/;s/\([(+-]\)z/\1($z)/g;s/\([0-9]\)z/\1\*($z)/g;s/z/$z/g")
				echo "$eq" | bc -l
				unset x y z eq
				shift
			done
		else
			echo " zzmat $funcao: Confere ou resolve equa��o."
			echo " As vari�veis a serem consideradas s�o x, y ou z nas f�rmulas."
			echo " As vari�veis s�o justapostas em cada argumento separados por v�rgula."
			echo " Cada argumento adicional � um novo conjunto de vari�veis na f�rmula."
			echo " Usar '[' e ']' respectivamente no lugar de '(' e ')', ou proteger"
			echo " a f�rmula com aspas duplas(\") ou simples(')"
			echo " Potencia��o � representado com o uso de '^', ex: 3^2."
			echo " N�o use separador de milhar. Use o ponto(.) como separador decimal."
			echo " Uso: zzmat $funcao equacao numero|ponto(x,y[,z])"
			echo " Ex:  zzmat conf_eq x^2+3*[y-1]-2z+5 7,6.8,9 3,2,5.1"
			return 1
		fi
	;;
	*)
	zzmat -h
	;;
	esac

	if [ "$?" -ne "0" ]
	then
		return 1
	elif [ "$num" ]
	then
		echo "$num"|bc -l|awk '{printf "%.'${precisao}'f\n", $1}'|zzmat -p${precisao} sem_zeros
	fi
}

# ----------------------------------------------------------------------------
# zzmd5
# Calcula o c�digo MD5 dos arquivos informados, ou de um texto via STDIN.
# Obs.: Wrapper port�vel para os comandos md5 (Mac) e md5sum (Linux).
#
# Uso: zzmd5 [arquivo(s)]
# Ex.: zzmd5 arquivo.txt
#      cat arquivo.txt | zzmd5
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-06
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzmd5 ()
{
	zzzz -h md5 "$1" && return

	local tab=$(printf '\t')

	# Testa se o comando existe
	if type md5 >/dev/null 2>&1
	then
		comando="md5"

	elif type md5sum >/dev/null 2>&1
	then
		comando="md5sum"
	else
		echo "Erro: N�o encontrei um comando para c�lculo MD5 em seu sistema"
		return 1
	fi


	##### Diferen�as na sa�da dos comandos
	###
	### $comando_md5 /a/www/favicon.*
	#
	# Linux (separador � 2 espa�os):
	# d41d8cd98f00b204e9800998ecf8427e  /a/www/favicon.gif
	# 902591ef89dbe5663dc7ae44a5e3e27a  /a/www/favicon.ico
	#
	# Mac:
	# MD5 (/a/www/favicon.gif) = d41d8cd98f00b204e9800998ecf8427e
	# MD5 (/a/www/favicon.ico) = 902591ef89dbe5663dc7ae44a5e3e27a
	#
	# zzmd5 (separador � Tab):
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
	### CONCLUS�O
	### A zzmd5 usa o formato do Mac quando o texto vem pela STDIN,
	### que � mostrar somente o hash e mais nada. J� quando os arquivos
	### s�o informados via argumentos na linha de comando, a zzmd5 usa
	### um formato parecido com o do Linux, com o hash primeiro e depois
	### o nome do arquivo. A diferen�a � no separador: um Tab em vez de
	### dois espa�os em branco.
	###
	### Considero que a sa�da da zzmd5 � a mais limpa e f�cil de extrair
	### os dados usando ferramentas Unix.


	# Executa o comando do c�lculo MD5 e formata a sa�da conforme
	# explicado no coment�rio anterior: HASH ou HASH-Tab-Arquivo
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
# Obs.: Se a URL n�o tiver protocolo no in�cio, ser� colocado http://
# Uso: zzminiurl URL
# Ex.: zzminiurl http://www.funcoeszz.net
#      zzminiurl www.funcoeszz.net         # O http:// no in�cio � opcional
#
# Autor: Vin�cius Ven�ncio Leite <vv.leite (a) gmail com>
# Desde: 2010-04-26
# Vers�o: 4
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzminiurl ()
{
	zzzz -h miniurl "$1" && return

	[ "$1" ] || { zztool uso miniurl; return 1; }

	local url="$1"
	local prefixo='http://'

	# Se o usu�rio n�o informou o protocolo, adiciona o padr�o
	echo "$url" | egrep '^(https?|ftp|mms)://' >/dev/null || url="$prefixo$url"

	$ZZWWWHTML "http://migre.me/api.txt?url=$url" 2>/dev/null
	echo
}

# ----------------------------------------------------------------------------
# zzminusculas
# Converte todas as letras para min�sculas, inclusive acentuadas.
# Uso: zzminusculas [texto]
# Ex.: zzminusculas N�O ESTOU GRITANDO             # via argumentos
#      echo N�O ESTOU GRITANDOO | zzminusculas     # via STDIN
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-06-12
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzminusculas ()
{
	zzzz -h minusculas "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	sed '
		y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
		y/�������������������������/�������������������������/'
}

# ----------------------------------------------------------------------------
# zzmoeda
# http://br.invertia.com
# Busca a cota��o de v�rias moedas (mais de 100!) em rela��o ao d�lar.
# Com a op��o -t, mostra TODAS as moedas, sem ela, apenas as principais.
# � poss�vel passar v�rias palavras de pesquisa para filtrar o resultado.
# Obs.: Hora GMT, D�lares por unidade monet�ria para o Euro e a Libra.
# Uso: zzmoeda [-t] [pesquisa]
# Ex.: zzmoeda
#      zzmoeda -t
#      zzmoeda euro libra
#      zzmoeda -t peso
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-03-29
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzmoeda ()
{
	zzzz -h moeda "$1" && return

	local extra dados formato linha
	local url='http://br.invertia.com/mercados/divisas'
	local padrao='.'

	# Devemos mostrar todas as moedas?
	if [ "$1" = '-t' ]
	then
		extra='divisasregion.aspx?idtel=TODAS'
		shift
	fi

	# Prepara o filtro para pesquisar todas as palavras informadas (OU)
	[ "$1" ] && padrao=$(echo $* | sed 's/ /\\|/g')

	# Faz a consulta e filtra o resultado
	dados=$(
		$ZZWWWDUMP "$url/$extra" |
		sed '
			# Limpeza
			/IFRAME:/d
			s/\[.*]//
			s/^  *//
			/h[0-9][0-9]$/!d

			# Move nome completo da moeda para o fim da linha
			s/^\([^�]*\)�  *\([^ ].*\)/\2   \1/
		' |
		grep -i "$padrao"
	)

	# Pescamos algo?
	[ "$dados" ] || return

	echo "        Compra     Venda        Varia��o"
	echo "$dados"
}

# ----------------------------------------------------------------------------
# zzmoneylog
# Consulta lan�amentos do Moneylog, com pesquisa avan�ada e saldo total.
# Obs.: Chamado sem argumentos, pesquisa o m�s corrente
# Obs.: N�o expande lan�amentos recorrentes e parcelados.
#
# Uso: zzmoneylog [-d data] [-v valor] [-t tag] [--total] [texto]
# Ex.: zzmoneylog                       # Todos os lan�amentos deste m�s
#      zzmoneylog mercado               # Procure por mercado
#      zzmoneylog -t mercado            # Lan�amentos com a tag mercado
#      zzmoneylog -t mercado -d 2011    # Tag mercado em 2011
#      zzmoneylog -t mercado --total    # Saldo total da tag mercado
#      zzmoneylog -d 31/01/2011         # Todos os lan�amentos desta data
#      zzmoneylog -d 2011               # Todos os lan�amentos de 2011
#      zzmoneylog -d ontem              # Todos os lan�amentos de ontem
#      zzmoneylog -d mes                # Todos os lan�amentos deste m�s
#      zzmoneylog -d mes --total        # Saldo total deste m�s
#      zzmoneylog -d 2011-0[123]        # Regex: que casa Jan/Fev/Mar de 2011
#      zzmoneylog -v /                  # Todos os pagamentos parcelados
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-25
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzcalcula zzdatafmt zzdos2unix
# ----------------------------------------------------------------------------
zzmoneylog ()
{
	zzzz -h moneylog "$1" && return

	local data valor tag total
	local arquivo=$ZZMONEYLOG

	# Chamado sem argumentos, mostra o m�s corrente
	test $# -eq 0 && data=$(zzdatafmt -f AAAA-MM hoje)

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			-t|--tag    ) shift; tag="$1";;
			-d|--data   ) shift; data="$1";;
			-v|--valor  ) shift; valor="$1";;
			-a|--arquivo) shift; arquivo="$1";;
			--total) total=1;;
			--) shift; break;;
			-*) echo "Op��o inv�lida $1"; return 1;;
			*) break;;
		esac
		shift
	done

	# O-oh
	if test -z "$arquivo"
	then
		echo 'Ops, n�o sei onde encontrar seu arquivo de dados do Moneylog.'
		echo 'Use a vari�vel $ZZMONEYLOG para indicar o caminho.'
		echo
		echo 'Se voc� usa a vers�o tudo-em-um, indique o arquivo HTML:'
		echo '    export ZZMONEYLOG=/home/fulano/moneylog.html'
		echo
		echo 'Se voc� usa v�rios arquivos TXT, indique a pasta:'
		echo '    export ZZMONEYLOG=/home/fulano/moneylog/'
		echo
		echo 'Al�m da vari�vel, voc� tamb�m pode usar a op��o --arquivo.'
		return 1
	fi

	# Consigo ler o arquivo? (Se n�o for pasta nem STDIN)
	if ! test -d "$arquivo" && test "$arquivo" != '-'
	then
		zztool arquivo_legivel "$arquivo" || return 1
	fi

	### DATA
	# Formata (se necess�rio) a data informada.
	# A data n�o � validada, assim o usu�rio pode fazer pesquisas parciais,
	# ou ainda usar express�es regulares, exemplo: 2011-0[123].
	if test -n "$data"
	then
		# Para facilitar a vida, alguns formatos comuns s�o mapeados
		# para o formato do moneylog. Assim, para pesquisar o m�s
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
			mes|m�s)
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
			echo "$data"  # Mensagem de erro
			return 1
		fi
	fi

	### VALOR
	# � necess�rio formatar um pouco o texto do usu�rio para a pesquisa
	# ficar mais poderosa, pois o formato do Moneylog � bem flex�vel.
	# Assim o usu�rio n�o precisa se preocupar com as pequenas diferen�as.
	if test -n "$valor"
	then
		valor=$(echo "$valor" | sed '
			# Escapa o s�mbolo de recorr�ncia: * vira [*]
			s|[*]|[*]|g

			# Remove espa�os em branco
			s/ //g

			# Pesquisa vai funcionar com ambos separadores: . e ,
			s/,/[,.]/

			# � poss�vel ter espa�os ap�s o sinal
			s/^[+-]/& */

			# O sinal de + � opcional
			s/^+/+*/

			# Busca por ,99 deve funcionar
			# Lembre-se que � poss�vel haver espa�os antes do valor
			s/^/[0-9 ,.+-]*/
		')
	fi

	# Come�amos mostrando todos os dados, seja do arquivo HTML, do TXT
	# ou de v�rios TXT. Os IFs seguintes filtrar�o estes dados conforme
	# as op��es escolhidas pelo usu�rio.

	if test -d "$arquivo"
	then
		cat "$arquivo"/*.txt
	else
		cat "$arquivo" |
			# Remove c�digo HTML, caso exista
			sed '/^<!DOCTYPE/,/<pre id="data">/ d'
	fi |

	# Remove linhas em branco.
	# Coment�rios s�o mantidos, pois podem ser �teis na pesquisa
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
# Op��es:
#   -a, --antigo informa o prefixo antigo a ser trocado.
#   -n, --novo   informa o prefixo novo a ser trocado.
# Uso: zzmudaprefixo -a antigo -n novo
# Ex.: zzmudaprefixo -a "antigo_prefixo" -n "novo_prefixo"
#      zzmudaprefixo -a "/tmp/antigo_prefixo" -n "/tmp/novo_prefixo"
#
# Autor: Lauro Cavalcanti de Sa <lauro (a) ecdesa com>
# Desde: 2009-09-21
# Vers�o: 2
# Licen�a: GPLv2
# ----------------------------------------------------------------------------
zzmudaprefixo ()
{

	#set -x

	zzzz -h mudaprefixo "$1" && return

	# Verifica numero minimo de parametros.
	if [ $# -lt 4 ] ; then
		zztool uso mudaprefixo
		return 1
	fi

	# Declara variaveis.
	local antigo novo n_sufixo_ini sufixo

	# Opcoes de linha de comando
	while [ $# -ge 1 ]
	do
		case "$1" in
			-a | --antigo)
				[ "$2" ] || { zztool uso mudaprefixo; return 1; }
				antigo=$2
				shift
				;;
			-n | --novo)
				[ "$2" ] || { zztool uso mudaprefixo; return 1; }
				novo=$2
				shift
				;;
			*) { zztool uso mudaprefixo; return 1; } ;;
		esac
		shift
	done

	# Renomeia os arquivos.
	n_sufixo_ini=`echo ${#antigo}`
	n_sufixo_ini=`expr ${n_sufixo_ini} + 1`
	for sufixo in `ls -1 "${antigo}"* | cut -c${n_sufixo_ini}-`;
	do
		# Verifica se eh arquivo mesmo.
		if [ -f "${antigo}${sufixo}" -a ! -s "${novo}${sufixo}" ] ; then
			mv -v "${antigo}${sufixo}" "${novo}${sufixo}"
		else
			echo "CUIDADO: Arquivo ${antigo}${sufixo} nao foi movido para ${novo}${sufixo} porque ou nao eh ordinario, ou destino ja existe!"
		fi
	done

}

# ----------------------------------------------------------------------------
# zznarrativa
# http://translate.google.com
# Narra frases em portugu�s usando o Google Tradutor.
#
# Uso: zznarrativa palavras
# Ex.: zznarrativa regex � legal
#
# Autor: Kl0nEz <kl0nez (a) wifi org br>
# Desde: 2011-08-23
# Vers�o: 2
# Licen�a: GPLv2
# Requisitos: mpg123 ou afplay
# ----------------------------------------------------------------------------
zznarrativa ()
{
	zzzz -h narrativa "$1" && return

	[ "$1" ] || { zztool uso narrativa; return 1; }

	# Variaveis locais
	local padrao play_cmd
	local url='http://translate.google.com.br'
	local charset_para='UTF-8'
	local audio_file="/tmp/$$.WAV"

	if test -f /usr/bin/afplay
	then
		play_cmd='afplay'     # mac
	else
		play_cmd='mpg123 -q'  # linux
	fi

	# Narrativa
	padrao=$(echo "$*" | sed "$ZZSEDURL")
	local audio="translate_tts?ie=$charset_para&q=$padrao&tl=pt&prev=input"
	$ZZWWWHTML "$url/$audio" > $audio_file && $play_cmd $audio_file && rm -rf $audio_file
}

# ----------------------------------------------------------------------------
# zznatal
# http://www.ibb.org.br/vidanet
# A mensagem "Feliz Natal" em v�rios idiomas.
# Uso: zznatal [palavra]
# Ex.: zznatal                   # busca um idioma aleat�rio
#      zznatal russo             # Feliz Natal em russo
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-12-23
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzlinha
# ----------------------------------------------------------------------------
zznatal ()
{
	zzzz -h natal "$1" && return

	local url='http://www.vidanet.org.br/mensagens/feliz-natal-em-varios-idiomas'
	local cache="$ZZTMP.natal"
	local padrao=$1

	# Se o cache est� vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		$ZZWWWDUMP "$url" | sed '
			1,10d
			77,179d
			s/^  *//
			s/^(/Chin�s  &/
			s/  */: /' > "$cache"
	fi

	# Mostra uma linha qualquer (com o padr�o, se informado)
	echo -n '"Feliz Natal" em '
	zzlinha -t "${padrao:-.}" "$cache"
}

# ----------------------------------------------------------------------------
# zznome
# http://www.significado.origem.nom.br/
# Dicion�rio de nomes, com sua origem, numerologia e arcanos do tarot.
# Pode-se filtrar por significado, origem, letra (primeira letra), tarot
# marca (no mundo), numerologia ou tudo - como segundo argumento (opcional).
# Por padr�o lista origem e significado.
#
# Uso: zznome nome [significado|origem|letra|marca|numerologia|tarot|tudo]
# Ex.: zznome maria
#      zznome jos� origem
#
# Autor: Itamar
# Desde: 2011-04-22
# Vers�o: 4
# Licen�a: GPL
# Requisitos: zzsemacento zzminusculas
# ----------------------------------------------------------------------------
zznome ()
{
	zzzz -h nome "$1" && return

	local url='http://www.significado.origem.nom.br'
	local ini='Qual a origem do nome '
	local fim='Analise da Primeira Letra do Nome:'
	local nome=$(echo "$1" | zzminusculas | zzsemacento)

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso nome; return 1; }

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
			fim='Significado - Numerologia - Express�o'
		;;
		numerologia)
			ini='Significado - Numerologia - Express�o'
			fim=' - Arcanos do Tarot'
		;;
		tarot)
			ini=' - Arcanos do Tarot'
			fim='^VEJA TAMB�M'
		;;
		tudo)
			ini='Qual a origem do nome '
			fim='^VEJA TAMB�M'
		;;
	esac

	$ZZWWWDUMP "$url/nomes/?q=$nome" |
		sed -n "
		/$ini/,/$fim/ {
			/$fim/d
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
		# Escondendo erros pois a codifica��o do site � estranha
		# https://github.com/aureliojargas/funcoeszz/issues/27
}

# ----------------------------------------------------------------------------
# zznomefoto
# Renomeia arquivos do diret�rio atual, arrumando a seq��ncia num�rica.
# Obs.: �til para passar em arquivos de fotos baixadas de uma c�mera.
# Op��es: -n  apenas mostra o que ser� feito, n�o executa
#         -i  define a contagem inicial
#         -d  n�mero de d�gitos para o n�mero
#         -p  prefixo padr�o para os arquivos
# Uso: zznomefoto [-n] [-i N] [-d N] [-p TXT] arquivo(s)
# Ex.: zznomefoto -n *                        # tire o -n para renomear!
#      zznomefoto -n -p churrasco- *.JPG      # tire o -n para renomear!
#      zznomefoto -n -d 4 -i 500 *.JPG        # tire o -n para renomear!
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2004-11-10
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zznomefoto ()
{
	zzzz -h nomefoto "$1" && return

	local arquivo prefixo contagem extensao nome novo nao previa
	local i=1
	local digitos=3

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
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
			*)
				break
			;;
		esac
	done

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso nomefoto; return 1; }

	if ! zztool testa_numero "$digitos"
	then
		echo "N�mero inv�lido para a op��o -d: $digitos"
		return 1
	fi
	if ! zztool testa_numero "$i"
	then
		echo "N�mero inv�lido para a op��o -i: $i"
		return 1
	fi

	# Para cada arquivo que o usu�rio informou...
	for arquivo
	do
		# O arquivo existe?
		zztool arquivo_legivel "$arquivo" || continue

		# Componentes do nome novo
		contagem=$(printf "%0${digitos}d" $i)

		# Se tiver extens�o, guarda para restaurar depois
		if zztool grep_var . "$arquivo"
		then
			extensao=".${arquivo##*.}"
		else
			extensao=
		fi

		# O nome come�a com o prefixo, se informado pelo usu�rio
		if [ "$prefixo" ]
		then
			nome=$prefixo
		else
			# Se n�o tiver prefixo, usa o nome base do arquivo original,
			# sem extens�o nem n�meros no final (se houver).
			# Exemplo: DSC123.JPG -> DSC
			nome=$(echo "${arquivo%.*}" | sed 's/[0-9][0-9]*$//')
		fi

		# Comp�e o nome novo e mostra na tela a mudan�a
		novo="$nome$contagem$extensao"
		previa="$nao$arquivo -> $novo"

		if [ "$novo" = "$arquivo" ]
		then
			# Ops, o arquivo novo tem o mesmo nome do antigo
			echo "$previa" | sed "s/^\[-n\]/[-ERRO-]/"
		else
			echo "$previa"
		fi

		# Atualiza a contagem (Ah, s�rio?)
		i=$((i+1))

		# Se n�o tiver -n, vamos renomear o arquivo
		if ! [ "$nao" ]
		then
			# N�o sobrescreve arquivos j� existentes
			zztool arquivo_vago "$novo" || return

			# E finalmente, renomeia
			mv -- "$arquivo" "$novo"
		fi
	done
}

# ----------------------------------------------------------------------------
# zznoticiaslinux
# http://... - v�rios
# Busca as �ltimas not�cias sobre Linux em sites nacionais.
# Obs.: Cada site tem uma letra identificadora que pode ser passada como
#       par�metro, para informar quais sites voc� quer pesquisar:
#
#         Y)ahoo Linux         B)r Linux
#         V)iva o Linux        U)nder linux
#         N)ot�cias linux
#
# Uso: zznoticiaslinux [sites]
# Ex.: zznoticiaslinux
#      zznoticiaslinux yn
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-12-17
# Vers�o: 3
# Licen�a: GPL
# Requisitos: zzfeed zzxml
# ----------------------------------------------------------------------------
zznoticiaslinux ()
{
	zzzz -h noticiaslinux "$1" && return

	local url limite
	local n=5
	local sites='byvucin'

	limite="sed ${n}q"

	[ "$1" ] && sites="$1"

	# Yahoo
	if zztool grep_var y "$sites"
	then
		url='http://br.noticias.yahoo.com/rss/linux'
		echo
		zztool eco "* Yahoo Linux ($url):"
		zzfeed -n $n "$url"
	fi

	# Viva o Linux
	if zztool grep_var v "$sites"
	then
		url='http://www.vivaolinux.com.br'
		echo
		zztool eco "* Viva o Linux ($url):"

		$ZZWWWHTML "$url/index.rdf" |
			zztool texto_em_iso |
			zzxml --tag title --untag --unescape |
			sed '1,2 d' |
			$limite
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
		url='https://under-linux.org/external.php?do=rss&type=newcontent'
		echo
		zztool eco "* UnderLinux ($url):"
		zzfeed -n $n "$url"
	fi

	# Not�cias Linux
	if zztool grep_var n "$sites"
	then
		url='http://feeds.feedburner.com/NoticiasLinux'
		echo
		zztool eco "* Not�cias Linux ($url):"
		$ZZWWWHTML "$url" |
			zztool texto_em_iso |
			zzxml --tag title --untag --unescape |
			sed 1d |
			$limite
	fi
}

# ----------------------------------------------------------------------------
# zznoticiassec
# http://... - v�rios
# Busca as �ltimas not�cias em sites especializados em seguran�a.
# Obs.: Cada site tem uma letra identificadora que pode ser passada como
#       par�metro, para informar quais sites voc� quer pesquisar:
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
# Vers�o: 3
# Licen�a: GPL
# Requisitos: zzfeed zzxml
# ----------------------------------------------------------------------------
zznoticiassec ()
{
	zzzz -h noticiassec "$1" && return

	local url limite
	local n=5
	local sites='bsctf'

	limite="sed ${n}q"

	[ "$1" ] && sites="$1"

	# LinuxSecurity Brasil
	if zztool grep_var b "$sites"
	then
		url='http://www.linuxsecurity.com.br/share.php'
		echo
		zztool eco "* LinuxSecurity Brasil ($url):"
		$ZZWWWHTML "$url" |
			zztool texto_em_iso |
			zzxml --tag title --untag --unescape |
			sed 1d |
			$limite
	fi

	# Linux Security
	if zztool grep_var s "$sites"
	then
		url='http://www.linuxsecurity.com/linuxsecurity_advisories.rdf'
		echo
		zztool eco "* Linux Security ($url):"
		$ZZWWWHTML "$url" |
			zzxml --tag title --untag --unescape |
			sed 1d |
			$limite
	fi

	# CERT/CC
	if zztool grep_var c "$sites"
	then
		url='http://www.us-cert.gov/channels/techalerts.rdf'
		echo
		zztool eco "* CERT/CC ($url):"
		$ZZWWWHTML "$url" |
			zzxml --tag title --untag --unescape |
			sed 1d |
			$limite
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
# zzora
# http://ora-code.com
# Retorna a descri��o do erro Oracle (ORA-NNNNN).
# Uso: zzora numero_erro
# Ex.: zzora 1234
#
# Autor: Rodrigo Pereira da Cunha <rodrigopc (a) gmail.com>
# Desde: 2005-11-03
# Vers�o: 4
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzora ()
{
	zzzz -h ora "$1" && return

	[ $# -ne 1 ] && { zztool uso ora; return 1; } # deve receber apenas um argumento
	zztool -e testa_numero "$1" || return 1 # e este argumento deve ser num�rico

	local url="http://ora-$1.ora-code.com"

	$ZZWWWDUMP "$url" | sed '
		s/  //g
		s/^ //
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
	return 0
}

# ----------------------------------------------------------------------------
# zzpalpite
# Palpites de jogos para v�rias loterias: quina, megasena, lotomania, etc.
# Aqui est� a lista completa de todas as loterias suportadas:
# quina, megasena, duplasena, lotomania, lotof�cil, timemania, federal, loteca
#
# Uso: zzpalpite [quina|megasena|duplasena|lotomania|lotofacil|federal|timemania|loteca]
# Ex.: zzpalpite
#      zzpalpite megasena
#      zzpalpite megasena federal lotofacil
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2012-06-03
# Vers�o: 4
# Licen�a: GPL
# Requisitos: zzminusculas zzsemacento zzseq
# ----------------------------------------------------------------------------
zzpalpite ()
{
	zzzz -h palpite "$1" && return

	local tipo num posicao numeros palpites inicial final i
	local qtde=0
	local tipos='quina megasena duplasena lotomania lotofacil federal timemania loteca'

	# Escolhe as loteria
	[ "$1" ] && tipos=$(echo "$*" | zzminusculas | zzsemacento)

	for tipo in $tipos
	do
		# Cada loteria
		case "$tipo" in
			lotomania)
				inicial=0
				final=99
				qtde=50
			;;
			lotofacil|facil)
				inicial=1
				final=25
				qtde=15
			;;
			megasena|mega)
				inicial=1
				final=60
				qtde=6
			;;
			duplasena|dupla)
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
				numero=$(echo "$inicial + ( ${RANDOM} / 32766 ) * ( $final - $inicial )" | bc -l | sed 's/\..*$//g')
				zztool eco $tipo:
				printf " %0.5d\n\n" $numero
				qtde=0
				unset num posicao numeros palpites inicial final i
			;;
			timemania|time)
				inicial=1
				final=80
				qtde=10
			;;
			loteca)
				i=1
				zztool eco $tipo:
				while [ "$i" -le "14" ]
				do
					printf " Jogo %0.2d: Coluna %d\n" $i $(($RANDOM % 3)) | sed 's/Coluna 0/Coluna do Meio/g'
					let i++
				done
				echo
				qtde=0
				unset num posicao numeros palpites inicial final i
			;;
		esac

		# Todos os numeros da loteria seleciona
		if [ "$qtde" -gt "0" ]
		then
			numeros=$(zzseq -f '%0.2d ' $inicial $final)
		fi

		# Loop para gerar os palpites
		i="$qtde"
		while [ "$i" -gt "0" ]
		do
			# Posicao a ser escolhida
			posicao=$(echo "$inicial + ( ${RANDOM} / 32766 ) * ( $final - $inicial )" | bc -l | sed 's/\..*$//g')
			[ $tipo = "lotomania" ] && let posicao++

			# Extrai o numero na posicao selecionada
			num=$(echo $numeros | cut -f $posicao -d ' ')

			palpites=$(echo "$palpites $num")

			# Elimina o numero escolhido
			numeros=$(echo "$numeros" | sed "s/$num //")

			# Diminuindo o contador e quantidade de itens em "numeros"
			let i--
			let final--
		done

		if [ "$palpites" ]
		then
			palpites=$(echo "$palpites" | tr ' ' '\n' | sort -n -t ' ' | tr '\n' ' ')
			if [ $(echo " $palpites" | wc -w ) -ge "10" ]
			then
				palpites=$(echo "$palpites" | sed 's/\(\([0-9]\{2\} \)\{5\}\)/\1\
 /g')
			fi
		fi

		# Exibe palpites
		if [ "$qtde" -gt "0" ]
		then
			zztool eco $tipo:
			echo "$palpites"|sed '/^ *$/d'
			echo

			#Zerando as variaveis
			unset num posicao numeros palpites inicial final qtde i
		fi
	done
}

# ----------------------------------------------------------------------------
# zzpascoa
# Mostra a data do domingo de P�scoa para qualquer ano.
# Obs.: Se o ano n�o for informado, usa o atual.
# Regra: Primeiro domingo ap�s a primeira lua cheia a partir de 21 de mar�o.
# Uso: zzpascoa [ano]
# Ex.: zzpascoa
#      zzpascoa 1999
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-23
# Vers�o: 1
# Licen�a: GPL
# Tags: data
# ----------------------------------------------------------------------------
zzpascoa ()
{
	zzzz -h pascoa "$1" && return

	local dia mes a b c d e f g h i k l m p q
	local ano="$1"

	# Se o ano n�o for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Valida��o
	zztool -e testa_ano $ano || return 1

	# Algoritmo de Jean Baptiste Joseph Delambre (1749-1822)
	# conforme citado em http://www.ghiorzi.org/portug2.htm
	#
	if [ $ano -lt 1583 ]
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

	# Adiciona zeros � esquerda, se necess�rio
	[ $dia -lt 10 ] && dia="0$dia"
	[ $mes -lt 10 ] && mes="0$mes"

	echo "$dia/$mes/$ano"
}

# ----------------------------------------------------------------------------
# zzpiada
# http://www.xalexandre.com.br/
# Mostra uma piada diferente cada vez que � chamada.
# Uso: zzpiada
# Ex.: zzpiada
#
# Autor: Alexandre Brodt Fernandes, www.xalexandre.com.br
# Desde: 2008-12-29
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzpiada ()
{
	zzzz -h piada "$1" && return
	$ZZWWWDUMP 'http://www.xalexandre.com.br/piadasAleiatorias/'
}

# ----------------------------------------------------------------------------
# zzporcento
# Calcula porcentagens.
# Se informado um n�mero, mostra sua tabela de porcentagens.
# Se informados dois n�meros, mostra a porcentagem relativa entre eles.
# Se informados um n�mero e uma porcentagem, mostra o valor da porcentagem.
# Se informados um n�mero e uma porcentagem com sinal, calcula o novo valor.
#
# Uso: zzporcento valor [valor|[+|-]porcentagem%]
# Ex.: zzporcento 500           # Tabela de porcentagens de 500
#      zzporcento 500.0000      # Tabela para n�mero fracion�rio (.)
#      zzporcento 500,0000      # Tabela para n�mero fracion�rio (,)
#      zzporcento 5.000,00      # Tabela para valor monet�rio
#      zzporcento 500 25        # Mostra a porcentagem de 25 para 500 (5%)
#      zzporcento 500 1000      # Mostra a porcentagem de 1000 para 500 (200%)
#      zzporcento 500,00 2,5%   # Mostra quanto � 2,5% de 500,00
#      zzporcento 500,00 +2,5%  # Mostra quanto � 500,00 + 2,5%
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-12-11
# Vers�o: 6
# Licen�a: GPL
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

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso porcento; return 1; }

	# Remove os pontos dos dinheiros para virarem fracion�rios (1.234,00 > 1234,00)
	zztool testa_dinheiro "$valor1" && valor1=$(echo "$valor1" | sed 's/\.//g')
	zztool testa_dinheiro "$valor2" && valor2=$(echo "$valor2" | sed 's/\.//g')

	### Vamos analisar o primeiro valor

	# N�mero fracion�rio (1.2345 ou 1,2345)
	if zztool testa_numero_fracionario "$valor1"
	then
		separador=$(echo "$valor1" | tr -d 0-9)
		escala=$(echo "$valor1" | sed 's/.*[.,]//')
		escala="${#escala}"

		# Sempre usar o ponto como separador interno (para os c�lculos)
		valor1=$(echo "$valor1" | sed 'y/,/./')

	# N�mero inteiro ou erro
	else
		zztool -e testa_numero "$valor1" || return 1
	fi

	### Vamos analisar o segundo valor

	# O segundo argumento � uma porcentagem
	if test $# -eq 2 && zztool grep_var % "$valor2"
	then
		# O valor da porcentagem � guardado sem o caractere %
		porcentagem=$(echo "$valor2" | tr -d %)

		# Sempre usar o ponto como separador interno (para os c�lculos)
		porcentagem=$(echo "$porcentagem" | sed 'y/,/./')

		# H� um sinal no in�cio?
		if test "${porcentagem#[+-]}" != "$porcentagem"
		then
			sinal=$(printf %c $porcentagem)  # pega primeiro char
			porcentagem=${porcentagem#?}     # remove primeiro char
		fi

		# Porcentagem fracionada
		if zztool testa_numero_fracionario "$porcentagem"
		then
			# Se o valor � inteiro (escala=0) e a porcentagem fracion�ria,
			# � preciso for�ar uma escala para que o resultado apare�a correto.
			test $escala -eq 0 && escala=2 valor1="$valor1.00"

		# Porcentagem inteira ou erro
		elif ! zztool testa_numero "$porcentagem"
		then
			echo "O valor da porcentagem deve ser um n�mero. Exemplos: 2 ou 2,5."
			return 1
		fi

	# O segundo argumento � um n�mero
	elif test $# -eq 2
	then
		# Ao mostrar a porcentagem entre dois n�meros, a escala � fixa
		escala=2

		# O separador do segundo n�mero � quem "manda" na sa�da
		# Sempre usar o ponto como separador interno (para os c�lculos)

		# N�mero fracion�rio
		if zztool testa_numero_fracionario "$valor2"
		then
			separador=$(echo "$valor2" | tr -d 0-9)
			valor2=$(echo "$valor2" | sed 'y/,/./')

		# N�mero normal ou erro
		else
			zztool -e testa_numero "$valor2" || return 1
		fi
	fi

	# Ok. Dados coletados, analisados e formatados. Agora � hora dos c�lculos.

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
		# Mostra a porcentagem relativa entre dois n�meros
		if ! zztool grep_var % "$valor2"
		then
			echo "scale=$escala; $valor2*100/$valor1" | bc | sed 's/$/%/'

		# valor + n% � igual a
		elif test "$sinal" = '+'
		then
			echo "scale=$escala; $valor1+$valor1*$porcentagem/100" | bc

		# valor - n% � igual a
		elif test "$sinal" = '-'
		then
			echo "scale=$escala; $valor1-$valor1*$porcentagem/100" | bc

		# n% do valor � igual a
		else
			echo "scale=$escala; $valor1*$porcentagem/100" | bc

			### Sa�da antiga, uma mini tabelinha
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
# zzpronuncia
# http://www.m-w.com
# Fala a pron�ncia correta de uma palavra em ingl�s.
# Uso: zzpronuncia palavra
# Ex.: zzpronuncia apple
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-04-10
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzpronuncia ()
{
	zzzz -h pronuncia "$1" && return

	local wav_file wav_dir wav_url
	local palavra=$1
	local cache="$ZZTMP.pronuncia.$palavra.wav"
	local url='http://www.m-w.com/dictionary'
	local url2='http://cougar.eb.com/soundc11'

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso pronuncia; return 1; }

	# O 'say' � um comando do Mac OS X, a� n�o precisa baixar nada
	if test -x /usr/bin/say
	then
		say $*
		return
	fi

	# Busca o arquivo WAV na Internet caso n�o esteja no cache
	if ! test -f "$cache"
	then
		# Extrai o nome do arquivo no site do dicion�rio
		wav_file=$(
			$ZZWWWHTML "$url/$palavra" |
			sed -n "/.*audio.pl?\([a-z0-9]*\.wav\)=$palavra.*/{s//\1/p;q;}")

		# Ops, n�o extraiu nada
		if test -z "$wav_file"
		then
			echo "$palavra: palavra n�o encontrada"
			return 1
		fi

		# O nome da pasta � a primeira letra do arquivo (/a/apple001.wav)
		# Ou "number" se iniciar com um n�mero (/number/9while01.wav)
		wav_dir=$(echo $wav_file | cut -c1)
		echo $wav_dir | grep '[0-9]' >/dev/null && wav_dir='number'

		# Comp�e a URL do arquivo e salva-o localmente (cache)
		wav_url="$url2/$wav_dir/$wav_file"
		echo "URL: $wav_url"
		$ZZWWWHTML "$wav_url" > $cache
		echo "Gravado o arquivo '$cache'"
	fi

	# Fala que eu te escuto
	play $cache
}

# ----------------------------------------------------------------------------
# zzramones
# http://aurelio.net/doc/ramones.txt
# Mostra uma frase aleat�ria, das letras de m�sicas da banda punk Ramones.
# Obs.: Informe uma palavra se quiser frases sobre algum assunto especifico.
# Uso: zzramones [palavra]
# Ex.: zzramones punk
#      zzramones
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2001-07-24
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzlinha
# ----------------------------------------------------------------------------
zzramones ()
{
	zzzz -h ramones "$1" && return

	local url='http://aurelio.net/doc/ramones.txt'
	local cache="$ZZTMP.ramones"
	local padrao=$1

	# Se o cache est� vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		$ZZWWWDUMP "$url" > "$cache"
	fi

	# Mostra uma linha qualquer (com o padr�o, se informado)
	zzlinha -t "${padrao:-.}" "$cache"
}

# ----------------------------------------------------------------------------
# zzrandbackground
# Muda aleatoriamente o background do GNOME.
# A op��o -l faz o script entrar em loop.
# ATEN��O: o caminho deve conter a �ltima / para que funcione:
#   /wallpaper/ <- funciona
#   /wallpaper  <- n�o funciona
#
# Uso: zzrandbackground -l <caminho_wallpapers> <segundo>
# Ex.: zzrandbackground /media/wallpaper/
#      zzrandbackground -l /media/wallpaper/ 5
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-12-12
# Vers�o: 1
# Licen�a: GPLv2
# Requisitos: zzshuffle gconftool
# ----------------------------------------------------------------------------
zzrandbackground ()
{

	zzzz -h randbackground "$1" && return

	local caminho tempo papeisdeparede background
	local opcao caminho segundos loop

	# Tratando os parametros
	# foi passado -l
	if [ "$1" = "-l" ];then

		# Tem todos os parametros, caso negativo
		# mostra o uso da funcao
		if [ $# != "3" ]; then
			zztool uso randbackground
			return 1
		fi

		# Ok � loop
		loop=1

		# O caminho � valido, caso negativo
		# mostra o uso da funcao
		if test -d $2; then
			caminho=$2
		else
			zztool uso randbackground
			return 1
		fi

		# A quantidade de segundos � inteira
		# caso negativo mostra o uso da funcao
		if zztool testa_numero $3; then
			segundos=$3
		else
			zztool uso randbackground
			return 1
		fi
	else
		# Caso nao seja passado o -l, s� tem o camiho
		# caso negativo mostra o uso da funcao
		if [ $# != "1" ]; then
			zztool uso randbackground
			return 1
		fi

		# O caminho � valido, caso negativo
		# mostra o uso da funcao
		if test -d $2; then
			caminho=$1
		else
			zztool uso randbackground
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

	# Agora a execu��o
	# Foi passado -l, ent�o entra em loop infinito
	if [ "$loop" ];then
		while test "1"
		do
			background=$( echo "$papeisdeparede" |
				zzshuffle |
				head -1
				)
			gconftool-2 --type string --set /desktop/gnome/background/picture_filename "$background"
			sleep $segundos
		done

	# n�o, n�o foi passado -l, ent�o s� troca 1x.
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
# Uso: zzrastreamento <c�digo_da_encomenda> ...
# Ex.: zzrastreamento RK995267899BR
#      zzrastreamento RK995267899BR RA995267899CN
#
# Autor: Frederico Freire Boaventura <anonymous (a) galahad com br>
# Desde: 2007-06-25
# Vers�o: 3
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzrastreamento ()
{
	zzzz -h rastreamento "$1" && return

	[ "$1" ] || { zztool uso rastreamento; return 1; }

	local url='http://websro.correios.com.br/sro_bin/txect01$.QueryList'

	# Para cada c�digo recebido...
	for codigo
	do
		# S� mostra o c�digo se houver mais de um
		[ $# -gt 1 ] && zztool eco "**** $codigo"

		$ZZWWWDUMP "$url?P_LINGUA=001&P_TIPO=001&P_COD_UNI=$codigo" |
			sed '
				/ Data /,/___/ !d
				/___/d
				s/^   //'

		# Linha em branco para separar resultados
		[ $# -gt 1 ] && echo
	done
}

# ----------------------------------------------------------------------------
# zzrelansi
# Coloca um rel�gio digital (hh:mm:ss) no canto superior direito do terminal.
# Uso: zzrelansi [-s|--stop]
# Ex.: zzrelansi
#
# Autor: Arkanon <arkanon (a) lsd org br>
# Desde: 2009-09-17
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzrelansi ()
{

	zzzz -h relansi "$1" && return

	case $1 in
	-s|--stop)
		shopt -q
		if [ "$relansi_pid" ]
		then
			kill $relansi_pid
			relansi_write
			unset relansi_cols relansi_pid relansi_write
		else
			echo "RelANSI n�o est� sendo executado"
		fi
	;;
	*)
		if [ "$relansi_pid" ]
		then
			echo "RelANSI j� est� sendo executado pelo processo $relansi_pid"
		else
			relansi_cols=$(tput cols)
			relansi_write()
		        {
				tput sc
				tput cup 0 $[$relansi_cols-8]
				[ "$1" ] && date +'%H:%M:%S' || echo '        '
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
# Conversor de n�meros romanos para indo-ar�bicos e vice-versa.
# Uso: zzromanos n�mero
# Ex.: zzromanos 1987                # Retorna: MCMLXXXVII
#      zzromanos XLIII               # Retorna: 43
#
# Autor: Guilherme Magalh�es Gall <gmgall (a) gmail com> twitter: @gmgall
# Desde: 2011-07-19
# Vers�o: 3
# Licen�a: GPL
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

	# Deixa o usu�rio usar letras mai�sculas ou min�sculas
	local entrada=$(echo "$1" | zzmaiusculas)
	local saida=""
	local indice=1
	local comprimento
	# Regex que valida um n�mero romano de acordo com
	# http://diveintopython.org/unit_testing/stage_5.html
	local regex_validacao='^M?M?M?(CM|CD|D?C?C?C?)(XC|XL|L?X?X?X?)(IX|IV|V?I?I?I?)$'

	# Se nenhum argumento for passado, mostra lista de algarismos romanos
	# e seus correspondentes indo-ar�bicos
	if [ $# -eq 0 ]
	then
		echo "$arabicos_romanos" |
		grep -v :.. | tr -d '\t' | tr : '\t' |
		zztac

	# Se � um n�mero inteiro positivo, transforma para n�mero romano
	elif zztool testa_numero "$entrada"
	then
		echo "$arabicos_romanos" | { while IFS=: read arabico romano
		do
			while [ "$entrada" -ge "$arabico" ]
			do
				saida="$saida$romano"
				entrada=$((entrada-arabico))
			done
		done
		echo "$saida"
		}

	# Se � uma string que representa um n�mero romano v�lido,
	# converte para indo-ar�bico
	elif echo "$entrada" | egrep "$regex_validacao" > /dev/null
	then
		saida=0
		# Baseado em http://diveintopython.org/unit_testing/stage_4.html
		echo "$arabicos_romanos" | { while IFS=: read arabico romano
		do
			comprimento="${#romano}"
			while [ "$(echo "$entrada" | cut -c$indice-$((indice+comprimento-1)))" = "$romano" ]
			do
				indice=$((indice+comprimento))
				saida=$((saida+arabico))
			done
		done
		echo "$saida"
		}

	# Se n�o � inteiro posivo ou string que representa n�mero romano v�lido,
	# imprime mensagem de uso.
	else
		zztool uso romanos
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
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzrot13 ()
{
	zzzz -h rot13 "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Um tr faz tudo, � uma tradu��o letra a letra
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
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzrot47 ()
{
	zzzz -h rot47 "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Um tr faz tudo, � uma tradu��o letra a letra
	# Obs.: Os colchetes s�o parte da tabela, o tr n�o funcionar� no Solaris
	tr '!-~' 'P-~!-O'
}

# ----------------------------------------------------------------------------
# zzrpmfind
# http://rpmfind.net/linux
# Procura por pacotes RPM em v�rias distribui��es de Linux.
# Obs.: A arquitetura padr�o de procura � a i386.
# Uso: zzrpmfind pacote [distro] [arquitetura]
# Ex.: zzrpmfind sed
#      zzrpmfind lilo mandr i586
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-02-22
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzrpmfind ()
{
	zzzz -h rpmfind "$1" && return

	local url='http://rpmfind.net/linux/rpm2html/search.php'
	local pacote=$1
	local distro=$2
	local arquitetura=${3:-i386}

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso rpmfind; return 1; }

	# Faz a consulta e filtra o resultado
	zztool eco 'ftp://rpmfind.net/linux/'
	$ZZWWWLIST "$url?query=$pacote&submit=Search+...&system=$distro&arch=$arquitetura" |
		sed -n '/ftp:\/\/rpmfind/ s@^[^A-Z]*/linux/@  @p' |
		sort
}

# ----------------------------------------------------------------------------
# zzsecurity
# http://... - v�rios
# Mostra os �ltimos 5 avisos de seguran�a de sistemas de Linux/UNIX.
# Suportados: Debian FreeBSD Gentoo Mandriva Slackware Suse Ubuntu.
# Uso: zzsecurity [distros]
# Ex.: zzsecutiry
#      zzsecurity mandriva
#      zzsecurity debian gentoo
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-12-23
# Vers�o: 5
# Licen�a: GPL
# Requisitos: zzminusculas zzxml zzfeed
# ----------------------------------------------------------------------------
zzsecurity ()
{
	zzzz -h security "$1" && return

	local url limite distros
	local n=5
	local ano=$(date '+%Y')
	local distros='debian freebsd gentoo mandriva slackware suse ubuntu'

	limite="sed ${n}q"

	[ "$1" ] && distros=$(echo $* | zzminusculas)

	# Debian
	if zztool grep_var debian "$distros"
	then
		url='http://www.debian.org'
		echo
		zztool eco '** Atualiza��es Debian woody'
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
		zztool eco '** Atualiza��es Slackware'
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
		zztool eco '** Atualiza��es Gentoo'
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
		zztool eco '** Atualiza��es Mandriva'
		url='http://www.mandriva.com/en/support/security/advisories/feed/'
		echo "$url"
		zzfeed -n $n "$url"
	fi

	# Suse
	if zztool grep_var suse "$distros"
	then
		echo
		zztool eco '** Atualiza��es Suse'
		url='https://www.suse.com/support/update/'
		echo "$url"
		$ZZWWWDUMP "$url" |
			grep 'SUSE-SU' |
			sed 's/\(.*\) \([A-Z].. .., ....\)$/\2\1/ ; s/  *$//' |
			$limite
	fi

	# FreeBSD
	if zztool grep_var freebsd "$distros"
	then
		echo
		zztool eco '** Atualiza��es FreeBSD'
		url='http://www.freebsd.org/security/advisories.rdf'
		echo "$url"
		$ZZWWWDUMP "$url" |
			zzxml --tag title --untag --unescape |
			sed 1d |
			$limite
	fi

	# Ubuntu
	if zztool grep_var ubuntu "$distros"
	then
		url='http://www.ubuntu.com/usn/rss.xml'
		echo
		zztool eco '** Atualiza��es Ubuntu'
		echo "$url"
		zzfeed -n $n "$url"
	fi
}

# ----------------------------------------------------------------------------
# zzsemacento
# Tira os acentos de todas as letras (����� vira aeiou).
# Uso: zzsemacento texto
# Ex.: zzsemacento A��O 1� b�n��o           # Retorna: ACAO 1a bencao
#      echo A��O 1� b�n��o | zzsemacento    # Retorna: ACAO 1a bencao
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2010-05-24
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzsemacento ()
{
	zzzz -h semacento "$1" && return

	# Dados via STDIN ou argumentos
	zztool multi_stdin "$@" |

	# Remove acentos
	sed '
		y/�����������������������/aaaaaaeeeeiiiiooooouuuu/
		y/�����������������������/AAAAAAEEEEIIIIOOOOOUUUU/
		y/����ߢ��������������/cCnNBcDdLOoSuYyY123ao/
	'
}

# ----------------------------------------------------------------------------
# zzsenha
# Gera uma senha aleat�ria de N caracteres �nicos (n�o repetidos).
# Obs.: Sem op��es, a senha � gerada usando letras e n�meros.
#
# Op��es: -p, --pro   Usa letras, n�meros e s�mbolos para compor a senha
#         -n, --num   Usa somente n�meros para compor a senha
#
# Uso: zzsenha [--pro|--num] [n]     (padr�o n=8)
# Ex.: zzsenha
#      zzsenha 10
#      zzsenha --num 9
#      zzsenha --pro 30
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-11-07
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzsenha ()
{
	zzzz -h senha "$1" && return

	local posicao letra maximo senha
	local n=8
	local alpha='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
	local num='0123456789'
	local pro='-/:;()$&@.,?!'  # teclado do iPhone, exceto aspas
	local lista="$alpha$num"   # senha padr�o: letras e n�meros

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			-p|--pro) shift; lista="$alpha$num$pro";;
			-n|--num) shift; lista="$num";;
			*) break ;;
		esac
	done

	# Guarda o n�mero informado pelo usu�rio (se existente)
	[ "$1" ] && n="$1"

	# Foi passado um n�mero mesmo?
	zztool -e testa_numero "$n" || return 1

	# J� que n�o repete as letras, temos uma limita��o de tamanho
	maximo="${#lista}"
	if [ "$n" -gt "$maximo" ]
	then
		echo "O tamanho m�ximo desse tipo de senha � $maximo"
		return 1
	fi

	# Esquema de gera��o da senha:
	# A cada volta � escolhido um n�mero aleat�rio que indica uma
	# posi��o dentro do $lista. A letra dessa posi��o � mostrada na
	# tela e removida do $lista para n�o ser reutilizada.
	while [ "$n" -ne 0 ]
	do
		n=$((n-1))
		posicao=$((RANDOM % ${#lista} + 1))
		letra=$(echo -n "$lista" | cut -c "$posicao")
		lista=$(echo "$lista" | tr -d "$letra")
		senha="$senha$letra"
	done

	# Mostra a senha
	echo "$senha"
}

# ----------------------------------------------------------------------------
# zzseq
# Mostra uma seq��ncia num�rica, um n�mero por linha, ou outro formato.
# � uma emula��o do comando seq, presente no Linux.
# Op��es:
#   -f    Formato de sa�da (printf) para cada n�mero, o padr�o � '%d\n'
# Uso: zzseq [-f formato] [n�mero-inicial [passo]] n�mero-final
# Ex.: zzseq 10                   # de 1 at� 10
#      zzseq 5 10                 # de 5 at� 10
#      zzseq 10 5                 # de 10 at� 5 (regressivo)
#      zzseq 0 2 10               # de 0 at� 10, indo de 2 em 2
#      zzseq 10 -2 0              # de 10 at� 0, indo de 2 em 2
#      zzseq -f '%d:' 5           # 1:2:3:4:5:
#      zzseq -f '%0.4d:' 5        # 0001:0002:0003:0004:0005:
#      zzseq -f '(%d)' 5          # (1)(2)(3)(4)(5)
#      zzseq -f 'Z' 5             # ZZZZZ
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-12-06
# Vers�o: 1
# Licen�a: GPL
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

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso seq; return 1; }

	# Se houver s� um n�mero, vai "de um ao n�mero"
	fim="$1"

	# Se houver dois n�meros, vai "do primeiro ao segundo"
	[ "$2" ] && inicio="$1" fim="$2"

	# Se houver tr�s n�meros, vai "do primeiro ao terceiro em saltos"
	[ "$3" ] && inicio="$1" passo="$2" fim="$3"

	# Verifica��es b�sicas
	zztool -e testa_numero_sinal "$inicio" || return 1
	zztool -e testa_numero_sinal "$passo"  || return 1
	zztool -e testa_numero_sinal "$fim"    || return 1
	if test "$passo" -eq 0
	then
		echo "O passo n�o pode ser zero."
		return 1
	fi

	# Internamente o passo deve ser sempre positivo para simplificar
	# Assim mesmo que o usu�rio fa�a 0 -2 10, vai funcionar
	[ "$passo" -lt 0 ] && passo=$((0 - passo))

	# Se o primeiro for maior que o segundo, a contagem � regressiva
	[ "$inicio" -gt "$fim" ] && operacao='-'

	# Loop que mostra o n�mero e aumenta/diminui a contagem
	i="$inicio"
	while (
		test "$inicio" -lt "$fim" -a "$i" -le "$fim" ||
		test "$inicio" -gt "$fim" -a "$i" -ge "$fim")
	do
		printf "$formato" "$i"
		i=$(($i $operacao $passo))  # +n ou -n
	done

	# Caso especial: in�cio e fim s�o iguais
	test "$inicio" -eq "$fim" && echo "$inicio"
}

# ----------------------------------------------------------------------------
# zzsextapaixao
# Mostra a data da sexta-feira da paix�o para qualquer ano.
# Obs.: Se o ano n�o for informado, usa o atual.
# Regra: 2 dias antes do domingo de P�scoa.
# Uso: zzsextapaixao [ano]
# Ex.: zzsextapaixao
#      zzsextapaixao 2008
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-11-21
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzdata zzpascoa
# Tags: data
# ----------------------------------------------------------------------------
zzsextapaixao ()
{
	zzzz -h sextapaixao "$1" && return

	local ano="$1"

	# Se o ano n�o for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Valida��o
	zztool -e testa_ano $ano || return 1

	# Ah, como � f�cil quando se tem as ferramentas certas ;)
	# e quando j� temos o c�digo e s� precisamos mudar os numeros
	# tambem � bom :D ;)
	zzdata $(zzpascoa $ano) - 2
}

# ----------------------------------------------------------------------------
# zzshuffle
# Desordena as linhas de um texto (ordem aleat�ria).
# Uso: zzshuffle [arquivo(s)]
# Ex.: zzshuffle /etc/passwd         # desordena o arquivo de usu�rios
#      cat /etc/passwd | zzshuffle   # o arquivo pode vir da entrada padr�o
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-06-19
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzshuffle ()
{
	zzzz -h shuffle "$1" && return

	local linha

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |

		# Um n�mero aleat�rio � colocado no in�cio de cada linha,
		# depois o sort ordena numericamente, bagun�ando a ordem
		# original. Ent�o os n�meros s�o removidos.
		while read linha
		do
			echo "$RANDOM $linha"
		done |
		sort |
		cut -d ' ' -f 2-
}

# ----------------------------------------------------------------------------
# zzsigla
# http://www.acronymfinder.com
# Dicion�rio de siglas, sobre qualquer assunto (como DVD, IMHO, WYSIWYG).
# Obs.: H� um limite di�rio de consultas por IP, pode parar temporariamente.
# Uso: zzsigla sigla
# Ex.: zzsigla RTFM
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-02-21
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzsigla ()
{
	zzzz -h sigla "$1" && return

	local url=http://www.acronymfinder.com/af-query.asp

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso sigla; return 1; }

	# Pesquisa, baixa os resultados e filtra
	$ZZWWWDUMP "$url?String=exact&Acronym=$1&Find=Find" |
		grep '\*\*\*\*' |
		sed '
			s/more info from.*//
			s/\[[a-z0-9]*\.gif\]//
			s/  *$//
			s/^ *\*\** *//'
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
# Vers�o: 1
# Licen�a: GPL
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

	# Tenta obter as dimens�es atuais da tela/janela
	dimensoes=$(stty size 2>/dev/null)
	if [ "$dimensoes" ]
	then
		linhas=${dimensoes% *}
		colunas=${dimensoes#* }
	fi

	# Op��es de linha de comando
	while [ $# -ge 1 ]
	do
		case "$1" in
			--fundo)
				fundo=1
			;;
			--rapido)
				unset pausa
			;;
			--tema)
				[ "$2" ] || { zztool uso ss; return 1; }
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
	if [ "$tema" ]
	then
		mensagem=$(
			echo "$temas" |
				grep -w "$tema" |
				zztool trim |
				cut -f2
		)

		if ! [ "$mensagem" ]
		then
			echo "Tema desconhecido '$tema'"
			return 1
		fi
	fi

	# O 'mosaico' � um tema especial que precisa de ajustes
	if [ "$tema" = 'mosaico' ]
	then
		# Configura��es para mostrar ret�ngulos coloridos fren�ticos
		mensagem=' '
		fundo=1
		unset pausa
	fi

	# Define se a parte fixa do c�digo de cores ser� fundo ou frente
	if [ "$fundo" ]
	then
		cor_fixo='30;4'
	else
		cor_fixo='40;3'
	fi

	# Ent�o vamos come�ar, primeiro limpando a tela
	clear

	# O 'trap' mapeia o Ctrl-C para sair do Screen Saver
	( trap "clear;return" 2

	tamanho_mensagem=${#mensagem}

	while :
	do
		# Posiciona o cursor em um ponto qualquer (aleat�rio) da tela (X,Y)
		# Detalhe: A mensagem sempre cabe inteira na tela ($coluna)
		linha=$((RANDOM % linhas + 1))
		coluna=$((RANDOM % (colunas - tamanho_mensagem + 1) + 1))
		printf "\033[$linha;${coluna}H"

		# Escolhe uma cor aleat�ria para a mensagem (ou o fundo): 1 - 7
		cor_muda=$((RANDOM % 7 + 1))

		# Usar negrito ou n�o tamb�m � escolhido ao acaso: 0 - 1
		negrito=$((RANDOM % 2))

		# Podemos usar cores ou n�o?
		if [ "$ZZCOR" = 1 ]
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
# Ex.: zzstr2hexa @MenteBrilhante    # 40 4d 65 6e 74 65 42 72 69 6c 68 61 6e
#      zzstr2hexa bin                # 62 69 6e
#      echo bin | zzstr2hexa         # 62 69 6e
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2012-03-30
# Vers�o: 7
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzstr2hexa ()
{
	zzzz -h str2hexa "$1" && return

	local string caractere
	local nl=$(printf '\n')

	# String vem como argumento ou STDIN?
	# Nota: n�o use zztool multi_stdin, adiciona \n no final do argumento
	if test $# -ne 0
	then
		string="$*"
	else
		string=$(cat /dev/stdin)
	fi

	# Loop a cada caractere, e o printf o converte para hexa
	printf %s "$string" | while IFS= read -r -n 1 caractere
	do
		if test "$caractere" = "$nl"
		then
			# Exce��o para contornar um bug:
			#   printf %x 'c retorna 0 quando c=\n
			printf '0a '
		else
			printf '%02x ' "'$caractere"
		fi
	done |
		# Remove o espa�o que sobra no final e quebra a linha
		sed 's/ $//'
}

# ----------------------------------------------------------------------------
# zzsubway
# Mostra uma sugest�o de sandu�che para pedir na lanchonete Subway.
# Obs.: Se n�o gostar da sugest�o, chame a fun��o novamente para ter outra.
# Uso: zzsubway
# Ex.: zzsubway
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-12-02
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzshuffle
# ----------------------------------------------------------------------------
zzsubway ()
{
	zzzz -h subway "$1" && return

	local linha quantidade categoria opcoes

	# O formato � quantidade:categoria:op��o1:...:op��oN
	cardapio="\
	1:recheio:(1) B.M.T. Italiano:(2) Atum:(3) Vegetariano:(4) Frutos do Mar Subway:(5) Frango Teriaki:(6) Peru, Presunto & Bacon:(7) Alm�ndegas:(8) Carne e Queijo:(9) Peru, Presunto & Roast Beef:(10) Peito de Peru:(11) Rosbife:(12) Peito de Peru e Presunto
	1:p�o:italiano branco:integral:parmes�o e or�gano:tr�s queijos:integral aveia e mel
	1:tamanho:15 cm:30 cm
	1:queijo:su��o:prato:cheddar
	1:extra:nenhum:bacon:tomate seco:cream cheese
	1:tostado:sim:n�o
	*:salada:alface:tomate:pepino:cebola:piment�o:azeitona preta:picles:r�cula
	1:molho:mostarda e mel:cebola agridoce:barbecue:parmes�o:chipotle:mostarda:maionese
	*:tempero:sal:vinagre:azeite de oliva:pimenta calabresa:pimenta do reino"

	echo "$cardapio" | while read linha; do
		quantidade=$(echo "$linha" | cut -d : -f 1 | tr -d '\t')
		categoria=$( echo "$linha" | cut -d : -f 2)
		opcoes=$(    echo "$linha" | cut -d : -f 3- | tr : '\n')

		# Que tipo de ingrediente mostraremos agora? Recheio? P�o? Tamanho? ...
		printf "%s\t: " "$categoria"

		# Quantos ingredientes opcionais colocaremos no p�o?
		# O asterisco indica "qualquer quantidade", ent�o � escolhido um
		# n�mero qualquer dentre as op��es dispon�veis.
		if test "$quantidade" = '*'
		then
			quantidade=$(echo "$opcoes" | sed -n '$=')
			quantidade=$((RANDOM % quantidade + 1))
		fi

		# Hora de mostrar os ingredientes.
		# Escolhidos ao acaso (zzshuffle), s�o pegos N itens ($quantidade).
		# Obs.: M�ltiplos itens s�o mostrados em uma �nica linha (paste+sed).
		echo "$opcoes" |
			zzshuffle |
			head -n $quantidade |
			paste -s -d : - |
			sed 's/:/, /g'
	done
}

# ----------------------------------------------------------------------------
# zztabuada
# Imprime a tabuada de um n�mero de 1 a 10.
# Se n�o for informado nenhum argumento ser� impressa a tabuada de 1 a 9.
# O argumento pode ser entre 0 a 99.
#
# Uso: zztabuada [n�mero]
# Ex.: zztabuada
#      zztabuada 2
#
# Autor: Kl0nEz <kl0nez (a) wifi org br> modif:Itamar(itamarnet@yahoo.com.br)
# Desde: 2011-08-23
# Vers�o: 4
# Licen�a: GPLv2
# ----------------------------------------------------------------------------
zztabuada ()
{
	zzzz -h tabuada "$1" && return

	local i j calcula
	local linha="+--------------+--------------+--------------+"

	case "$1" in
		[0-9] | [0-9][0-9])
			for i in 0 1 2 3 4 5 6 7 8 9 10
			do
				printf '%d x %-2d = %d\n' "$1" "$i" $(($1*$i))
			done
		;;
		*)
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
			done
		;;
	esac
}

# ----------------------------------------------------------------------------
# zztac
# Inverte a ordem das linhas, mostrando da �ltima at� a primeira.
# � uma emula��o (port�vel) do comando tac, presente no Linux.
#
# Uso: zztac [arquivos]
# Ex.: zztac /etc/passwd
#      zztac arquivo.txt outro.txt
#      cat /etc/passwd | zztac
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2013-02-24
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zztac ()
{
	zzzz -h tac "$1" && return

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" | sed '1!G;h;$!d'

	# Explica��o do sed:
	#   A vers�o simplificada dele �: G;h;d. Esta sequ�ncia de comandos
	#   vai empilhando as linhas na ordem inversa no buffer reserva.
	#
	# Supondo o arquivo:
	#   um
	#   dois
	#   tr�s
	#
	# Funcionar� assim:
	#                            [principal]            [reserva]
	# --------------------------------------------------------------
	#   L� a linha 1             um
	#   h                        um                     um
	#   d                                               um
	#   L� a linha 2             dois
	#   G                        dois\num
	#   h                        dois\num               dois\num
	#   d                                               dois\num
	#   L� a linha 3             tr�s
	#   h                        tr�s\ndois\num         dois\num
	#   FIM DO ARQUIVO
	#   Mostra o conte�do do [principal], as linhas invertidas.
}

# ----------------------------------------------------------------------------
# zztempo
# http://weather.noaa.gov/
# Mostra as condi��es do tempo (clima) em um determinado local.
# Se nenhum par�metro for passado, s�o listados os pa�ses dispon�veis.
# Se s� o pa�s for especificado, s�o listadas as suas localidades.
# As siglas tamb�m podem ser usadas, por exemplo SBPA = Porto Alegre.
# Uso: zztempo <pa�s> <localidade>
# Ex.: zztempo 'United Kingdom' 'London City Airport'
#      zztempo brazil 'Curitiba Aeroporto'
#      zztempo brazil SBPA
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-02-19
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zztempo ()
{
	zzzz -h tempo "$1" && return

	local codigo_pais codigo_localidade localidades
	local pais="$1"
	local localidade="$2"
	local cache_paises="$ZZTMP.tempo"
	local cache_localidades="$ZZTMP.tempo"
	local url='http://weather.noaa.gov'

	# Se o cache de pa�ses est� vazio, baixa listagem da Internet
	if ! test -s "$cache_paises"
	then
		$ZZWWWHTML "$url" | sed -n '
			/="country"/,/\/select/ {
				s/.*="\([a-zA-Z]*\)">\(.*\) <.*/\1 \2/p
			}' > "$cache_paises"
	fi

	# Se nenhum par�metro for passado, s�o listados os pa�ses dispon�veis
	if ! [ "$pais" ]
	then
		sed 's/^[^ ]*  *//' "$cache_paises"
		return
	fi

	# Grava o c�digo deste pa�s (BR  Brazil -> BR)
	codigo_pais=$(grep -i "$1" "$cache_paises" | sed 's/  .*//' | sed 1q)

	# O pa�s existe?
	if ! [ "$codigo_pais" ]
	then
		echo "Pa�s \"$pais\" n�o encontrado"
		return 1
	fi

	# Se o cache de locais est� vazio, baixa listagem da Internet
	cache_localidades=$cache_localidades.$codigo_pais
	if ! test -s "$cache_localidades"
	then
		$ZZWWWHTML "$url/weather/${codigo_pais}_cc.html" | sed -n '
			/="cccc"/,/\/select/ {
				//d
				s/.*="\([a-zA-Z]*\)">/\1 /p
			}' > "$cache_localidades"
	fi

	# Se s� o pa�s for especificado, s�o listadas as localidades deste pa�s
	if ! [ "$localidade" ]
	then
		cat "$cache_localidades"
		return
	fi

	# Pesquisa nas localidades
	localidades=$(grep -i "$localidade" "$cache_localidades")

	# A localidade existe?
	if ! [ "$localidades" ]
	then
		echo "Localidade \"$localidade\" n�o encontrada"
		return 1
	fi

	# Se mais de uma localidade for encontrada, mostre-as
	if test $(echo "$localidades" | sed -n '$=') != 1
	then
		echo "$localidades"
		return 0
	fi

	# Grava o c�digo do local (SBCO  Porto Alegre -> SBCO)
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
# Google Tradutor, para traduzir frases para v�rios idiomas.
# Caso n�o especificado o idioma, a tradu��o ser� portugu�s -> ingl�s.
# Use a op��o -l ou --lista para ver todos os idiomas dispon�veis.
# Use a op��o -a ou --audio para ouvir a frase na voz feminina do google.
#
# Alguns idiomas populares s�o:
#      pt = portugu�s         fr = franc�s
#      en = ingl�s            it = italiano
#      es = espanhol          de = alem�o
#
# Uso: zztradutor [de-para] palavras
# Ex.: zztradutor o livro est� na mesa    # the book is on the table
#      zztradutor pt-en livro             # book
#      zztradutor pt-es livro             # libro
#      zztradutor pt-de livro             # Buch
#      zztradutor de-pt Buch              # livro
#      zztradutor de-es Buch              # Libro
#      zztradutor --lista                 # Lista todos os idiomas
#      zztradutor --lista eslo            # Procura por "eslo" nos idiomas
#      zztradutor --audio                 # Gera um arquivo OUT.WAV
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-09-02
# Vers�o: 6
# Licen�a: GPLv2
# Requisitos: iconv
# ----------------------------------------------------------------------------
zztradutor ()
{
	zzzz -h tradutor "$1" && return

	[ "$1" ] || { zztool uso tradutor; return 1; }

	# Variaveis locais
	local padrao
	local url='http://translate.google.com.br'
	local lang_de='pt'
	local lang_para='en'
	local charset_de='ISO-8859-1'
	local charset_para='UTF-8'
	local audio_file="/tmp/$$.WAV"
	local play_cmd='mpg123 -q'

	case "$1" in
		# O usu�rio informou um par de idiomas, como pt-en
		[a-z][a-z]-[a-z][a-z])
			lang_de=${1%-??}
			lang_para=${1#??-}
			shift

			# Pega exce��o: zztradutor pt-en  (sem mais argumentos)
			[ "$1" ] || { zztool uso tradutor; return 1; }
		;;
		-l | --lista)
			# Uma tag por linha, ent�o extrai e formata as op��es do <SELECT>
			$ZZWWWHTML "$url" |
			sed 's/</\n&/g'  |
			sed -n '/<option value=af>/,/<option value=yi>/p' |
			sed -n '1p;2,/value=af/p' | sed -n '$d;1~2p' |
			sed 's/<option .*value=/ /g;s/>/: /g;s/zh-CN/cn/g'|
			iconv -f $charset_de -t $charset_para |
			grep ${2:-:}
			return
		;;
		-a | --audio)
			# Narrativa
				shift
				padrao=$(echo "$*" | sed "$ZZSEDURL")
				local audio="translate_tts?ie=$charset_para&q=$padrao&tl=pt&prev=input"
				$ZZWWWHTML "$url/$audio" > $audio_file && $play_cmd $audio_file && rm -rf $audio_file
				return
		;;
	esac

	padrao=$(echo "$*" | sed "$ZZSEDURL")

	# Exce��o para o chin�s, que usa um c�digo diferente
	test $lang_para = 'cn' && lang_para='zh-CN'

	# Baixa a URL, coloca cada tag em uma linha, pega a linha desejada
	# e limpa essa linha para estar somente o texto desejado.
	$ZZWWWHTML "$url?tr=$lang_de&hl=$lang_para&text=$padrao" |
		iconv --from-code=$charset_de --to-code=$charset_para |
		awk 'gsub("<[^/]", "\n&")' |
		grep '<span title' |
		sed 's/<[^>]*>//g'
}

# ----------------------------------------------------------------------------
# zztrocaarquivos
# Troca o conte�do de dois arquivos, mantendo suas permiss�es originais.
# Uso: zztrocaarquivos arquivo1 arquivo2
# Ex.: zztrocaarquivos /etc/fstab.bak /etc/fstab
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-06-12
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zztrocaarquivos ()
{
	zzzz -h trocaarquivos "$1" && return

	# Um terceiro arquivo � usado para fazer a troca
	local tmp="$ZZTMP.trocaarquivos.$$"

	# Verifica��o dos par�metros
	[ $# -eq 2 ] || { zztool uso trocaarquivos; return 1; }

	# Verifica se os arquivos existem
	zztool arquivo_legivel "$1" || return
	zztool arquivo_legivel "$2" || return

	# Tiro no p�? N�o, obrigado
	[ "$1" = "$2" ] && return

	# A dan�a das cadeiras
	cat "$2"   > "$tmp"
	cat "$1"   > "$2"
	cat "$tmp" > "$1"

	# E foi
	rm -f "$tmp"
	echo "Feito: $1 <-> $2"
}

# ----------------------------------------------------------------------------
# zztrocaextensao
# Troca a extens�o dos arquivos especificados.
# Com a op��o -n, apenas mostra o que ser� feito, mas n�o executa.
# Uso: zztrocaextensao [-n] antiga nova arquivo(s)
# Ex.: zztrocaextensao -n .doc .txt *          # tire o -n para renomear!
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-15
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zztrocaextensao ()
{
	zzzz -h trocaextensao "$1" && return

	local ext1 ext2 arquivo base novo nao

	# Op��es de linha de comando
	if [ "$1" = '-n' ]
	then
		nao='[-n] '
		shift
	fi

	# Verifica��o dos par�metros
	[ "$3" ] || { zztool uso trocaextensao; return 1; }

	# Guarda as extens�es informadas
	ext1="$1"
	ext2="$2"
	shift; shift

	# Tiro no p�? N�o, obrigado
	[ "$ext1" = "$ext2" ] && return

	# Para cada arquivo que o usu�rio informou...
	for arquivo
	do
		# O arquivo existe?
		zztool arquivo_legivel "$arquivo" || continue

		base="${arquivo%$ext1}"
		novo="$base$ext2"

		# Testa se o arquivo possui a extens�o antiga
		[ "$base" != "$arquivo" ] || continue

		# Mostra o que ser� feito
		echo "$nao$arquivo -> $novo"

		# Se n�o tiver -n, vamos renomear o arquivo
		if [ ! "$nao" ]
		then
			# N�o sobrescreve arquivos j� existentes
			zztool arquivo_vago "$novo" || return

			# Vamos l�
			mv -- "$arquivo" "$novo"
		fi
	done
}

# ----------------------------------------------------------------------------
# zztrocapalavra
# Troca uma palavra por outra, nos arquivos especificados.
# Obs.: Al�m de palavras, � poss�vel usar express�es regulares.
# Uso: zztrocapalavra antiga nova arquivo(s)
# Ex.: zztrocapalavra excess�o exce��o *.txt
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-04
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zztrocapalavra ()
{
	zzzz -h trocapalavra "$1" && return

	local arquivo antiga_escapada nova_escapada
	local antiga="$1"
	local nova="$2"

	# Precisa do tempor�rio pois nem todos os Sed possuem a op��o -i
	local tmp="$ZZTMP.trocapalavra.$$"

	# Verifica��o dos par�metros
	[ "$3" ] || { zztool uso trocapalavra; return 1; }

	# Escapando a barra "/" dentro dos textos de pesquisa
	antiga_escapada=$(echo "$antiga" | sed 's,/,\\/,g')
	nova_escapada=$(  echo "$nova"   | sed 's,/,\\/,g')

	shift; shift

	# Para cada arquivo que o usu�rio informou...
	for arquivo
	do
		# O arquivo existe?
		zztool arquivo_legivel "$arquivo" || continue

		# Um teste r�pido para saber se o arquivo tem a palavra antiga,
		# evitando gravar o tempor�rio desnecessariamente
		grep "$antiga" "$arquivo" >/dev/null 2>&1 || continue

		# Uma seq��ncia encadeada de comandos para garantir que est� OK
		cp "$arquivo" "$tmp" &&
		sed "s/$antiga_escapada/$nova_escapada/g" "$tmp" > "$arquivo" && {
			echo "Feito $arquivo" # Est� retornando 1 :/
			continue
		}

		# Em caso de erro, recupera o conte�do original
		echo
		echo "Ops, deu algum erro no arquivo $arquivo"
		echo "Uma c�pia dele est� em $tmp"
		cat "$tmp" > "$arquivo"
		return 1
	done
	rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# zztv
# Mostra a programa��o da TV, di�ria ou semanal, com escolha de emissora.
#
# Canais:
# adulto                 espn_brasil        megapix       sony_spin
# ae                     espn_mais          megapix_hd    space
# ae_hd                  esporte_interativo mgm           space_hd
# amazon                 eurochannel        mix_tv        sport_tv
# animal                 film_arts          mtv           sport_tv2
# arte1                  for_man            multishow     sport_tv3
# axn                    fox                nat_geo       studio_universal
# axn_hd                 fox_hd             nat_geo_hd    super_rede
# baby                   fox_life           nbr           syfy
# band                   fox_news           nhk           tbs
# band_espotes           fox_sports         nickelodeon   tcm
# band_news              futura             nick_hd       telecine
# bbc                    fx                 nick_jr       telecine_action
# bbc_hd                 gazeta             off           telecine_action_hd
# biography              glitz              playboy       telecine_cult
# bis_hd                 globo              playboy_tv    telecine_fun
# bloomberg              globo_bahia        ppv1          telecine_hd
# boomerang              globo_campinas     ppv2          telecine_pipoca
# canal_21               globo_df           ppv3          telecine_pipoca_hd
# canal_boi              globo_eptv         ppv4          telecine_premium
# canal_brasil           globo_goias        ppv5          tele_sur
# cancao_nova            globo_minas        ppv6          terra_viva
# cartoon                globo_news         premiere_fc   tnt
# casa_clube             globo_poa          private_gold  tnt_hd
# cinemax                globo_rj           rai           tooncast
# climatempo             globo_sp           ra_tim_bum    travel
# cnn                    gloob              record        trutv
# cnn_espanhol           gnt                record_news   trutv_hd
# cnt                    golf               redetv        tv5_monde
# combate                hbo                rede_familia  tv_brasil
# comedy                 hbo2               rede_genesis  tv_brasil_central
# concert                hbo_family         rede_vida     tv_camara
# corinthians            hbo_hd             rit           tv_escola
# cultura                hbo_plus           rtp           tv_espanha
# discovery              hbo_plus_e         rural         tv_justica
# discovery_civilization hbo_signature      rush_hd       tv_uniao
# discovery_hd           history            santa_cecilia universal
# discovery_kids         history_hd         sbt           venus
# discovery_science      home_health        senac         vh1
# discovery_turbo        htv                senado        vh1_hd
# disney                 investigacao       sesc          vh1_mega
# disney_hd              isat               sexy_hot      viva
# disney_jr              lbv                sexy_prive    warner
# disney_xd              max                shoptime      warner_hd
# dwtv                   max_hd             sic           woohoo
# entertainment          max_prime          sony
# espn                   max_prime_e        sony_hd
#
# Programa��o corrente:
# doc, esportes, filmes, infantil, series, variedades, todos, agora (padr�o).
#
# Se o segundo argumento for "semana" ou "s" mostra toda programa��o semanal.
# Op��o s� � v�lida para os canais.
# Se o primeiro argumento � cod seguido de um n�mero, obtido pelas listagens
# citadas anteriormente, com segundo argumento, mostra um resumo do programa.
#
# Uso: zztv <emissora> [semana|s]  ou  zztv cod <numero>
# Ex.: zztv cultura
#      zztv cod 3235238
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net - revisado por Itamar.
# Desde: 2002-02-19
# Vers�o: 7
# Licen�a: GPL
# ----------------------------------------------------------------------------
zztv ()
{
	zzzz -h tv "$1" && return

	local DATA=$(date +%d\\/%m)
	local URL="http://meuguia.tv/programacao"
	local desc

	# 0 = lista canal especifico
	# 1 = lista programas de v�rios canais no hor�rio
	local flag=0

	case "$1" in
	adulto)                       URL="${URL}/canal/CAD";desc="Canal Adulto";;
	ae)                           URL="${URL}/canal/MDO";desc="A&E";;
	ae_hd)                        URL="${URL}/canal/MDH";desc="A&E HD";;
	amazon)                       URL="${URL}/canal/AMZ";desc="Amazon Sat";;
	animal)                       URL="${URL}/canal/APL";desc="Animal Planet";;
	arte1)                        URL="${URL}/canal/BQ5";desc="Arte 1";;
	axn_hd)                       URL="${URL}/canal/AXH";desc="AXN HD";;
	axn)                          URL="${URL}/canal/AXN";desc="AXN";;
	baby)                         URL="${URL}/canal/BAB";desc="Baby TV";;
	bandeirantes|band)            URL="${URL}/canal/BAN";desc="Band Rede";;
	band_espotes)                 URL="${URL}/canal/BSP";desc="Band Esportes";;
	band_news)                    URL="${URL}/canal/NEW";desc="Band News";;
	bbc)                          URL="${URL}/canal/BBC";desc="BBC World News";;
	bbc_hd)                       URL="${URL}/canal/BHD";desc="BBC HD";;
	biography)                    URL="${URL}/canal/BIO";desc="Biography Channel";;
	bis_hd)                       URL="${URL}/canal/MSH";desc="Bis HD";;
	bloomberg)                    URL="${URL}/canal/BIT";desc="Bloomberg";;
	boomerang)                    URL="${URL}/canal/BMG";desc="Boomerang";;
	canal_21)                     URL="${URL}/canal/C21";desc="Play TV (Canal 21)";;
	canal_brasil)                 URL="${URL}/canal/CBR";desc="Canal Brasil";;
	cancao_nova)                  URL="${URL}/canal/CNV";desc="Can��o Nova";;
	cartoon)                      URL="${URL}/canal/CAR";desc="Cartoon Network";;
	casa_clube)                   URL="${URL}/canal/CCL";desc="Casa Club TV";;
	max)                          URL="${URL}/canal/MXE";desc="Max";;
	canal_boi|boi)                URL="${URL}/canal/BOI";desc="Canal do Boi";;
	cinemax)                      URL="${URL}/canal/MNX";desc="Cinemax";;
	climatempo)                   URL="${URL}/canal/CLI";desc="Climatempo";;
	cnn_espanhol)                 URL="${URL}/canal/CNE";desc="CNN Espanhol";;
	cnn)                          URL="${URL}/canal/CNN";desc="CNN International";;
	cnt)                          URL="${URL}/canal/CNT";desc="CNT";;
	comedy)                       URL="${URL}/canal/CCE";desc="Comedy Central";;
	combate)                      URL="${URL}/canal/135";desc="Combatevh1";; 
	concert)                      URL="${URL}/canal/100";desc="Concert Channel";;
	cultura)                      URL="${URL}/canal/CUL";desc="TV Cultura";;
	corinthians)                  URL="${URL}/canal/TCO";desc="TV Corinthians";;
	discovery_civilization|civil) URL="${URL}/canal/DCI";desc="Discovery Civilization";;
	discovery_hd)                 URL="${URL}/canal/DHD";desc="Discovery HD Theater";;
	discovery_kids|kids)          URL="${URL}/canal/DIK";desc="Discovery Kids";;
	discovery_science)            URL="${URL}/canal/DSC";desc="Discovery Science";;
	discovery_turbo)              URL="${URL}/canal/DTU";desc="Discovery Turbo";;
	discovery)                    URL="${URL}/canal/DIS";desc="Discovery Channel";;
	disney)                       URL="${URL}/canal/DNY";desc="Disney Channel";;
	disney_hd)                    URL="${URL}/canal/DNH";desc="Disney Channel HD";;
	disney_jr)                    URL="${URL}/canal/PHD";desc="Disney Junior";;
	disney_xd)                    URL="${URL}/canal/DXD";desc="Disney XD";;
	dwtv|deutsche)                URL="${URL}/canal/DWL";desc="Deutsche Welle";;
	entertainment)                URL="${URL}/canal/EET";desc="E! Entertainment Television";;
	espanha|tv_espanha)           URL="${URL}/canal/TVE";desc="TVE Espanha";;
	espn_brasil)                  URL="${URL}/canal/ESB";desc="ESPN Brasil";;
	espn)                         URL="${URL}/canal/ESP";desc="ESPN";;
	espn_mais)                    URL="${URL}/canal/ESH";desc="ESPN+";;
	esporte_interativo)           URL="${URL}/canal/SPI";desc="Esporte Interativo";;
	eurochannel|euro)             URL="${URL}/canal/EUR";desc="Eurochannel";;
	familia|rede_familia)         URL="${URL}/canal/REF";desc="Rede Fam�lia";;
	film_arts)                    URL="${URL}/canal/BRA";desc="Film & Arts";;
	for_man)                      URL="${URL}/canal/GLS";desc="For Man";;
	fox_hd)                       URL="${URL}/canal/FHD";desc="Fox HD";;
	fox_life)                     URL="${URL}/canal/FLI";desc="Fox Life";;
	fox_news)                     URL="${URL}/canal/FNE";desc="Fox News";;
	fox_sports)                   URL="${URL}/canal/FSP";desc="Fox Sports";;
	fox)                          URL="${URL}/canal/FOX";desc="Fox";;
	futura)                       URL="${URL}/canal/FUT";desc="Canal Futura";;
	fx)                           URL="${URL}/canal/CFX";desc="FX";;
	gazeta)                       URL="${URL}/canal/GAZ";desc="TV Gazeta";;
	genesis|rede_genesis)         URL="${URL}/canal/TVG";desc="Rede G�nesis";;
	glitz)                        URL="${URL}/canal/FAS";desc="Glitz*";;
	globo_bahia)                  URL="${URL}/canal/GBB";desc="Globo - Rede Bahia";;
	globo_campinas)               URL="${URL}/canal/GRC";desc="Globo - EPTV Campinas";;
	globo_df)                     URL="${URL}/canal/GHB";desc="Globo - Bras�lia";;
	globo_eptv|eptv)              URL="${URL}/canal/GRP";desc="Globo - EPTV Ribeir�o Preto";;
	globo_goias)                  URL="${URL}/canal/GBG";desc="Globo - TV Anhanguera Goi�s";;
	globo_minas)                  URL="${URL}/canal/GBM";desc="Globo - Minas Gerais";;
	globo_news)                   URL="${URL}/canal/GLN";desc="Globo News";;
	globo_poa)                    URL="${URL}/canal/POA";desc="Globo - Porto Alegre";;
	globo_rj)                     URL="${URL}/canal/GRJ";desc="Globo - Rio de Janeiro";;
	globo_sp)                     URL="${URL}/canal/GSP";desc="Globo - S�o Paulo";;
	globo)                        URL="${URL}/canal/GRD";desc="Globo - Sat�lite";;
	gloob)                        URL="${URL}/canal/GOB";desc="Gloob";;
	gnt)                          URL="${URL}/canal/GNT";desc="Canal GNT";;
	golf)                         URL="${URL}/canal/TGC";desc="The Golf Channel";;
	hbo2)                         URL="${URL}/canal/HB2";desc="HBO 2";;
	hbo_signature)                URL="${URL}/canal/HFE";desc="HBO Signature";;
	hbo_family)                   URL="${URL}/canal/HFA";desc="HBO Family";;
	hbo_hd)                       URL="${URL}/canal/HBH";desc="HBO HD";;
	hbo_plus_e)                   URL="${URL}/canal/HPE";desc="HBO Plus *e";;
	hbo_plus)                     URL="${URL}/canal/HPL";desc="HBO Plus";;
	hbo)                          URL="${URL}/canal/HBO";desc="HBO";;
	home_health|health)           URL="${URL}/canal/HEA";desc="Discovery Home & Health";;
	htv)                          URL="${URL}/canal/HTV";desc="Etcetera";;
	history|history_channel)      URL="${URL}/canal/HIS";desc="History Channel";;
	history_hd)                   URL="${URL}/canal/HIH";desc="History Channel HD";;
	investigacao)                 URL="${URL}/canal/LIV";desc="Investiga��o Discovery";;
	isat|sat)                     URL="${URL}/canal/SAT";desc="i-Sat";;
	max_hd)                       URL="${URL}/canal/MHD";desc="Max HD";;
	max_prime_e)                  URL="${URL}/canal/MPE";desc="Max Prime *e";;
	max_prime)                    URL="${URL}/canal/MAP";desc="Max Prime";;
	megapix_hd)                   URL="${URL}/canal/MPH";desc="Megapix HD";;
	megapix)                      URL="${URL}/canal/MPX";desc="Megapix";;
	mgm)                          URL="${URL}/canal/MGM";desc="MGM";;
	mix|mix_tv)                   URL="${URL}/canal/MIX";desc="Mix TV";;
	mtv)                          URL="${URL}/canal/MTV";desc="MTV Brasil";;
	multishow)                    URL="${URL}/canal/MSW";desc="Multishow";;
	lbv)                          URL="${URL}/canal/LBV";desc="Boa Vontade TV";;
	national|nat_geo)             URL="${URL}/canal/SUP";desc="National Geography";;
	nat_geo_hd)                   URL="${URL}/canal/NGH";desc="Nat Geo Wild HD";;
	nbr)                          URL="${URL}/canal/NBR";desc="NBR";;
	nhk)                          URL="${URL}/canal/NHK";desc="NHK World";;
	nickelodeon)                  URL="${URL}/canal/NIC";desc="Nickelodeon";;
	nick_hd)                      URL="${URL}/canal/NIH";desc="Nick HD";;
	nick_jr)                      URL="${URL}/canal/NJR";desc="Nick Jr.";;
	off)                          URL="${URL}/canal/OFF";desc="Canal Off";;
	playboy_tv)                   URL="${URL}/canal/PLA";desc="Playboy TV";;
	playboy)                      URL="${URL}/canal/HEC";desc="Playboy TV Movies";;
	ppv1)                         URL="${URL}/canal/PV1";desc="PPV 1 DLA";;
	ppv2)                         URL="${URL}/canal/PV2";desc="PPV 2 DLA";;
	ppv3)                         URL="${URL}/canal/PV3";desc="PPV 3 DLA";;
	ppv4)                         URL="${URL}/canal/PV4";desc="PPV 4 DLA";;
	ppv5)                         URL="${URL}/canal/PV5";desc="PPV 5 DLA";;
	ppv6)                         URL="${URL}/canal/PV6";desc="PPV 6 DLA";;
	premiere_fc)                  URL="${URL}/canal/121";desc="PremiereFC";;
	private_gold)                 URL="${URL}/canal/ADM";desc="Private Gold";;
	rai)                          URL="${URL}/canal/RAI";desc="RAI International";;
	ra_tim_bum)                   URL="${URL}/canal/RTB";desc="TV R�-tim-bum";;
	record_news|recordnews|rnews) URL="${URL}/canal/RCN";desc="Record News";;
	record)                       URL="${URL}/canal/REC";desc="Record";;
	redetv|rede_tv)               URL="${URL}/canal/RTV";desc="Rede TV";;
	rede_vida|vida)               URL="${URL}/canal/VDA";desc="Rede Vida";;
	rit)                          URL="${URL}/canal/RIT";desc="Rede Internacional de TV";;
	rtp)                          URL="${URL}/canal/RTP";desc="RTP Internacional";;
	rural)                        URL="${URL}/canal/RUR";desc="Canal Rural";;
	rush_hd)                      URL="${URL}/canal/RSH";desc="Rush HD";;
	santa_cecilia)                URL="${URL}/canal/STC";desc="Santa Cec�lia TV";;
	sbt)                          URL="${URL}/canal/SBT";desc="SBT";;
	senado)                       URL="${URL}/canal/SEN";desc="TV Senado";;
	sesc|senac)                   URL="${URL}/canal/NAC";desc="SESC TV";;
	sexy_hot)                     URL="${URL}/canal/HOT";desc="Sexy Hot";;
	sexy_prive)                   URL="${URL}/canal/SEX";desc="Sex Priv� Brasileirinhas";;
	shoptime)                     URL="${URL}/canal/SHO";desc="Shoptime";;
	sic)                          URL="${URL}/canal/SIC";desc="SIC Internacional";;
	sony_hd)                      URL="${URL}/canal/SEH";desc="Sony HD";;
	sony_spin)                    URL="${URL}/canal/ANX";desc="Sony Spin";;
	sony)                         URL="${URL}/canal/SET";desc="Sony Entertainment TV";;
	space_hd)                     URL="${URL}/canal/SPH";desc="Space HD";;
	space)                        URL="${URL}/canal/SPA";desc="Space";;
	sporttv2|sport_tv2)           URL="${URL}/canal/SP2";desc="SporTV 2";;
	sporttv3|sport_tv3)           URL="${URL}/canal/SP3";desc="SporTV 3";;
	sporttv|sport_tv)             URL="${URL}/canal/SPO";desc="SporTV";;
	studio_universal|studio)      URL="${URL}/canal/HAL";desc="Studio Universal";;
	super_rede)                   URL="${URL}/canal/SRD";desc="Rede Super de Televis�o";;
	syfy)                         URL="${URL}/canal/SCI";desc="SyFy";;
	tbs)                          URL="${URL}/canal/TBS";desc="TBS";;
	tcm)                          URL="${URL}/canal/TCM";desc="TCM - Turner Classic Movies";;
	telecine_action)              URL="${URL}/canal/TC2";desc="Telecine Action";;
	telecine_action_hd)           URL="${URL}/canal/T2H";desc="Telecine Action HD";;
	telecine_cult)                URL="${URL}/canal/TC5";desc="Telecine Cult";;
	telecine_hd)                  URL="${URL}/canal/TCH";desc="Telecine Premuim HD";;
	telecine_fun)                 URL="${URL}/canal/TC6";desc="Telecine Fun";;
	telecine_pipoca)              URL="${URL}/canal/TC4";desc="Telecine Pipoca";;
	telecine_pipoca_hd)           URL="${URL}/canal/T4H";desc="Telecine Pipoca HD";;
	telecine_premium)             URL="${URL}/canal/TC1";desc="Telecine Premium";;
	telecine)                     URL="${URL}/canal/TC3";desc="Telecine Touch";;
	tele_sur)                     URL="${URL}/canal/TLS";desc="Tele Sur";;
	terra_viva)                   URL="${URL}/canal/TVV";desc="Terra Viva";;
	tnt)                          URL="${URL}/canal/TNT";desc="TNT";;
	tnt_hd)                       URL="${URL}/canal/TNH";desc="TNT HD";;
	tooncast)                     URL="${URL}/canal/TOC";desc="Tooncast";;
	travel)                       URL="${URL}/canal/TRV";desc="Travel & Living";;
	trutv_hd)                     URL="${URL}/canal/TRH";desc="TruTV HD";;
	trutv)                        URL="${URL}/canal/TRU";desc="TruTV";;
	tv5_monde|monde|tv5)          URL="${URL}/canal/TV5";desc="TV5 Monde";;
	tv_brasil|tvbrasil)           URL="${URL}/canal/TED";desc="TV Brasil";;
	tv_brasil_central|central)    URL="${URL}/canal/TBC";desc="TV Brasil Central";;
	tv_camara)                    URL="${URL}/canal/CAM";desc="TV C�mara";;
	tv_escola|escola)             URL="${URL}/canal/ESC";desc="TV Escola";;
	tv_justica|justica)           URL="${URL}/canal/JUS";desc="TV Justi�a";;
	tv_uniao)                     URL="${URL}/canal/TVU";desc="TV Uni�o";;
	universal)                    URL="${URL}/canal/USA";desc="Universal";;
	venus)                        URL="${URL}/canal/THF";desc="V�nus XXL";;
	vh1)                          URL="${URL}/canal/VH1";desc="VH1";;
	vh1_hd)                       URL="${URL}/canal/VHD";desc="VH1 HD";;
	vh1_mega)                     URL="${URL}/canal/MTH";desc="VH1 Mega Hits";;
	viva)                         URL="${URL}/canal/VIV";desc="Viva";;
	warner)                       URL="${URL}/canal/WBT";desc="Warner Channel";;
	warner_hd)                    URL="${URL}/canal/WBH";desc="Warner Channel HD";;
	woohoo)                       URL="${URL}/canal/WOO";desc="WooHoo";;
	doc|documentario)             URL="${URL}/categoria/Documentarios";flag=1;;
	esporte|esportes|futebol)     URL="${URL}/categoria/Esportes";flag=1;;
	filmes)                       URL="${URL}/categoria/Filmes";flag=1;;
	infantil)                     URL="${URL}/categoria/Infantil";flag=1;;
	series|seriados)              URL="${URL}/categoria/Series";flag=1;;
	variedades)                   URL="${URL}/categoria/Variedades";flag=1;;
	cod)                          URL="${URL}/programa/$2";flag=2;;
	todos|agora|*)                URL="${URL}/categoria/Todos";flag=1;;
	esac

	case "$2" in
	semana|s)
		echo $desc
		$ZZWWWHTML "$URL" | sed -n '/<li class/{N;p;}'|sed '/^[[:space:]]*$/d;/.*<\/*li/s/<[^>]*>//g'|
		sed 's/^.*programa\///g;s/".*title="/_/g;s/">//g;s/<span .*//g;s/<[^>]*>/ /g;s/amp;//g'|
		sed 's/^[[:space:]]*/ /g'|sed '/^[[:space:]]*$/d'|
		sed "/^ \([STQD].*[0-9][0-9]\/[0-9][0-9]\)/ { x; p ; x; s//\1/; }"|
		sed 's/^ \(.*\)_\(.*\)\([0-9][0-9]h[0-9][0-9]\)/ \3 \2 Cod: \1/g'
	;;
	*)
		if [ $flag -eq 0 ]
		then
			echo $desc
			$ZZWWWHTML "$URL" | sed -n '/<li class/{N;p;}'|sed '/^[[:space:]]*$/d;/.*<\/*li/s/<[^>]*>//g'|
			sed 's/^.*programa\///g;s/".*title="/_/g;s/">//g;s/<span .*//g;s/<[^>]*>/ /g;s/amp;//g'|
			sed 's/^[[:space:]]*/ /g'|sed '/^[[:space:]]*$/d'|
			sed -n "/, $DATA/,/^ [STQD].*[0-9][0-9]\/[0-9][0-9]/p"|sed '$d'|
			sed '1s/^ *//;2,$s/^ \(.*\)_\(.*\)\([0-9][0-9]h[0-9][0-9]\)/ \3 \2 Cod: \1/g' |
			sed -e ':a' -e '/^.\{25,70\}$/ { s/ Cod: / &/; ta' -e '}'
		elif [ $flag -eq 1 ]
		then
			$ZZWWWHTML "$URL" | sed -n '/<li style/{N;p;}'|sed '/^[[:space:]]*$/d;/.*<\/*li/s/<[^>]*>//g'|
			sed 's/^.*programa\///g;s/".*title="/_/g;s/">.*<br \/>//g;s/<[^>]*>/ /g;s/amp;//g'|
			sed 's/^[[:space:]]*/ /g'|sed '/^[[:space:]]*$/d'|
			sed 's/^ \(.*\)_\(.*\)\([0-9][0-9]h[0-9][0-9]\)/ \3 \2 Cod: \1/g'
		else
			$ZZWWWHTML "$URL" | sed -n '/<span class="tit">/,/a seguir neste canal/p'|
			sed 's/<span class="tit">/T�tulo:/;s/<span class="tit_orig">/T�tulo Original:/'|
			sed 's/<[^>]*>/ /g;s/amp;//g;s/\&ccedil;/�/g;s/\&atilde;/�/g;s/.*str="//;s/";//;s/[\|] //g'|
			sed 's/^[[:space:]]*/ /g'|sed '/^[[:space:]]*$/d;/document.write/d;$d'
		fi
	;;
	esac
}

# ----------------------------------------------------------------------------
# zztweets
# Busca as mensagens mais recentes de um usu�rio do Twitter.
# Use a op��o -n para informar o n�mero de mensagens (padr�o � 5, m�x 20).
#
# Uso: zztweets [-n N] username
# Ex.: zztweets oreio
#      zztweets -n 10 oreio
#
# Autor: Eri Ramos Bastos <bastos.eri (a) gmail.com>
# Desde: 2009-07-30
# Vers�o: 6
# Licen�a: GPL
# ----------------------------------------------------------------------------
zztweets ()
{
	zzzz -h tweets "$1" && return

	[ "$1" ] || { zztool uso tweets; return 1; }

	local name
	local limite=5
	local url="https://twitter.com"

	# Op��es de linha de comando
	if [ "$1" = '-n' ]
	then
		limite="$2"
		shift
		shift

		zztool -e testa_numero "$limite" || return 1
	fi

	# Informar o @ � opcional
	name=$(echo "$1" | tr -d @)

	$ZZWWWDUMP $url/$name |
		sed '1,50 d' |
		sed -n '/ .*[0-9]\{1,2\}\./{n;p;}' |
		sed 's/\[DEL: \(.\) :DEL\] /\1/g; s/^ *//g' |
		sed "$limite q" |
		sed G

	# Apagando as 50 primeiras linhas usando apenas n�meros,
	# pois o sed do BSD capota se tentar ler o conte�do destas
	# linhas. Leia mais no issue #28.
}

# ----------------------------------------------------------------------------
# zzunescape
# Restaura caracteres codificados como entidades HTML e XML (&lt; &#62; ...).
# Entende entidades (&gt;), c�digos decimais (&#62;) e hexadecimais (&#x3E;).
#
# Op��es: --html  Restaura caracteres HTML
#         --xml   Restaura caracteres XML
#
# Uso: zzunescape [--html] [--xml] [arquivo(s)]
# Ex.: zzunescape --xml arquivo.xml
#      zzunescape --html arquivo.html
#      cat arquivo.html | zzunescape --html
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-03
# Vers�o: 2
# Licen�a: GPL
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
	## Escapar na m�o: \& e \"
	html="
		s/&#0*34;/\"/g;     s/&#x0*22;/\"/g;    s/&quot;/\"/g;
		s/&#0*38;/\&/g;     s/&#x0*26;/\&/g;    s/&amp;/\&/g;
		s/&#0*39;/'/g;      s/&#x0*27;/'/g;     s/&apos;/'/g;
		s/&#0*60;/</g;      s/&#x0*3C;/</g;     s/&lt;/</g;
		s/&#0*62;/>/g;      s/&#x0*3E;/>/g;     s/&gt;/>/g;
		s/&#0*160;/ /g;     s/&#x0*A0;/ /g;     s/&nbsp;/ /g;
		s/&#0*161;/�/g;     s/&#x0*A1;/�/g;     s/&iexcl;/�/g;
		s/&#0*162;/�/g;     s/&#x0*A2;/�/g;     s/&cent;/�/g;
		s/&#0*163;/�/g;     s/&#x0*A3;/�/g;     s/&pound;/�/g;
		s/&#0*164;/�/g;     s/&#x0*A4;/�/g;     s/&curren;/�/g;
		s/&#0*165;/�/g;     s/&#x0*A5;/�/g;     s/&yen;/�/g;
		s/&#0*166;/�/g;     s/&#x0*A6;/�/g;     s/&brvbar;/�/g;
		s/&#0*167;/�/g;     s/&#x0*A7;/�/g;     s/&sect;/�/g;
		s/&#0*168;/�/g;     s/&#x0*A8;/�/g;     s/&uml;/�/g;
		s/&#0*169;/�/g;     s/&#x0*A9;/�/g;     s/&copy;/�/g;
		s/&#0*170;/�/g;     s/&#x0*AA;/�/g;     s/&ordf;/�/g;
		s/&#0*171;/�/g;     s/&#x0*AB;/�/g;     s/&laquo;/�/g;
		s/&#0*172;/�/g;     s/&#x0*AC;/�/g;     s/&not;/�/g;
		s/&#0*173;/ /g;     s/&#x0*AD;/ /g;     s/&shy;/ /g;
		s/&#0*174;/�/g;     s/&#x0*AE;/�/g;     s/&reg;/�/g;
		s/&#0*175;/�/g;     s/&#x0*AF;/�/g;     s/&macr;/�/g;
		s/&#0*176;/�/g;     s/&#x0*B0;/�/g;     s/&deg;/�/g;
		s/&#0*177;/�/g;     s/&#x0*B1;/�/g;     s/&plusmn;/�/g;
		s/&#0*178;/�/g;     s/&#x0*B2;/�/g;     s/&sup2;/�/g;
		s/&#0*179;/�/g;     s/&#x0*B3;/�/g;     s/&sup3;/�/g;
		s/&#0*180;/�/g;     s/&#x0*B4;/�/g;     s/&acute;/�/g;
		s/&#0*181;/�/g;     s/&#x0*B5;/�/g;     s/&micro;/�/g;
		s/&#0*182;/�/g;     s/&#x0*B6;/�/g;     s/&para;/�/g;
		s/&#0*183;/�/g;     s/&#x0*B7;/�/g;     s/&middot;/�/g;
		s/&#0*184;/�/g;     s/&#x0*B8;/�/g;     s/&cedil;/�/g;
		s/&#0*185;/�/g;     s/&#x0*B9;/�/g;     s/&sup1;/�/g;
		s/&#0*186;/�/g;     s/&#x0*BA;/�/g;     s/&ordm;/�/g;
		s/&#0*187;/�/g;     s/&#x0*BB;/�/g;     s/&raquo;/�/g;
		s/&#0*188;/�/g;     s/&#x0*BC;/�/g;     s/&frac14;/�/g;
		s/&#0*189;/�/g;     s/&#x0*BD;/�/g;     s/&frac12;/�/g;
		s/&#0*190;/�/g;     s/&#x0*BE;/�/g;     s/&frac34;/�/g;
		s/&#0*191;/�/g;     s/&#x0*BF;/�/g;     s/&iquest;/�/g;
		s/&#0*192;/�/g;     s/&#x0*C0;/�/g;     s/&Agrave;/�/g;
		s/&#0*193;/�/g;     s/&#x0*C1;/�/g;     s/&Aacute;/�/g;
		s/&#0*194;/�/g;     s/&#x0*C2;/�/g;     s/&Acirc;/�/g;
		s/&#0*195;/�/g;     s/&#x0*C3;/�/g;     s/&Atilde;/�/g;
		s/&#0*196;/�/g;     s/&#x0*C4;/�/g;     s/&Auml;/�/g;
		s/&#0*197;/�/g;     s/&#x0*C5;/�/g;     s/&Aring;/�/g;
		s/&#0*198;/�/g;     s/&#x0*C6;/�/g;     s/&AElig;/�/g;
		s/&#0*199;/�/g;     s/&#x0*C7;/�/g;     s/&Ccedil;/�/g;
		s/&#0*200;/�/g;     s/&#x0*C8;/�/g;     s/&Egrave;/�/g;
		s/&#0*201;/�/g;     s/&#x0*C9;/�/g;     s/&Eacute;/�/g;
		s/&#0*202;/�/g;     s/&#x0*CA;/�/g;     s/&Ecirc;/�/g;
		s/&#0*203;/�/g;     s/&#x0*CB;/�/g;     s/&Euml;/�/g;
		s/&#0*204;/�/g;     s/&#x0*CC;/�/g;     s/&Igrave;/�/g;
		s/&#0*205;/�/g;     s/&#x0*CD;/�/g;     s/&Iacute;/�/g;
		s/&#0*206;/�/g;     s/&#x0*CE;/�/g;     s/&Icirc;/�/g;
		s/&#0*207;/�/g;     s/&#x0*CF;/�/g;     s/&Iuml;/�/g;
		s/&#0*208;/�/g;     s/&#x0*D0;/�/g;     s/&ETH;/�/g;
		s/&#0*209;/�/g;     s/&#x0*D1;/�/g;     s/&Ntilde;/�/g;
		s/&#0*210;/�/g;     s/&#x0*D2;/�/g;     s/&Ograve;/�/g;
		s/&#0*211;/�/g;     s/&#x0*D3;/�/g;     s/&Oacute;/�/g;
		s/&#0*212;/�/g;     s/&#x0*D4;/�/g;     s/&Ocirc;/�/g;
		s/&#0*213;/�/g;     s/&#x0*D5;/�/g;     s/&Otilde;/�/g;
		s/&#0*214;/�/g;     s/&#x0*D6;/�/g;     s/&Ouml;/�/g;
		s/&#0*215;/�/g;     s/&#x0*D7;/�/g;     s/&times;/�/g;
		s/&#0*216;/�/g;     s/&#x0*D8;/�/g;     s/&Oslash;/�/g;
		s/&#0*217;/�/g;     s/&#x0*D9;/�/g;     s/&Ugrave;/�/g;
		s/&#0*218;/�/g;     s/&#x0*DA;/�/g;     s/&Uacute;/�/g;
		s/&#0*219;/�/g;     s/&#x0*DB;/�/g;     s/&Ucirc;/�/g;
		s/&#0*220;/�/g;     s/&#x0*DC;/�/g;     s/&Uuml;/�/g;
		s/&#0*221;/�/g;     s/&#x0*DD;/�/g;     s/&Yacute;/�/g;
		s/&#0*222;/�/g;     s/&#x0*DE;/�/g;     s/&THORN;/�/g;
		s/&#0*223;/�/g;     s/&#x0*DF;/�/g;     s/&szlig;/�/g;
		s/&#0*224;/�/g;     s/&#x0*E0;/�/g;     s/&agrave;/�/g;
		s/&#0*225;/�/g;     s/&#x0*E1;/�/g;     s/&aacute;/�/g;
		s/&#0*226;/�/g;     s/&#x0*E2;/�/g;     s/&acirc;/�/g;
		s/&#0*227;/�/g;     s/&#x0*E3;/�/g;     s/&atilde;/�/g;
		s/&#0*228;/�/g;     s/&#x0*E4;/�/g;     s/&auml;/�/g;
		s/&#0*229;/�/g;     s/&#x0*E5;/�/g;     s/&aring;/�/g;
		s/&#0*230;/�/g;     s/&#x0*E6;/�/g;     s/&aelig;/�/g;
		s/&#0*231;/�/g;     s/&#x0*E7;/�/g;     s/&ccedil;/�/g;
		s/&#0*232;/�/g;     s/&#x0*E8;/�/g;     s/&egrave;/�/g;
		s/&#0*233;/�/g;     s/&#x0*E9;/�/g;     s/&eacute;/�/g;
		s/&#0*234;/�/g;     s/&#x0*EA;/�/g;     s/&ecirc;/�/g;
		s/&#0*235;/�/g;     s/&#x0*EB;/�/g;     s/&euml;/�/g;
		s/&#0*236;/�/g;     s/&#x0*EC;/�/g;     s/&igrave;/�/g;
		s/&#0*237;/�/g;     s/&#x0*ED;/�/g;     s/&iacute;/�/g;
		s/&#0*238;/�/g;     s/&#x0*EE;/�/g;     s/&icirc;/�/g;
		s/&#0*239;/�/g;     s/&#x0*EF;/�/g;     s/&iuml;/�/g;
		s/&#0*240;/�/g;     s/&#x0*F0;/�/g;     s/&eth;/�/g;
		s/&#0*241;/�/g;     s/&#x0*F1;/�/g;     s/&ntilde;/�/g;
		s/&#0*242;/�/g;     s/&#x0*F2;/�/g;     s/&ograve;/�/g;
		s/&#0*243;/�/g;     s/&#x0*F3;/�/g;     s/&oacute;/�/g;
		s/&#0*244;/�/g;     s/&#x0*F4;/�/g;     s/&ocirc;/�/g;
		s/&#0*245;/�/g;     s/&#x0*F5;/�/g;     s/&otilde;/�/g;
		s/&#0*246;/�/g;     s/&#x0*F6;/�/g;     s/&ouml;/�/g;
		s/&#0*247;/�/g;     s/&#x0*F7;/�/g;     s/&divide;/�/g;
		s/&#0*248;/�/g;     s/&#x0*F8;/�/g;     s/&oslash;/�/g;
		s/&#0*249;/�/g;     s/&#x0*F9;/�/g;     s/&ugrave;/�/g;
		s/&#0*250;/�/g;     s/&#x0*FA;/�/g;     s/&uacute;/�/g;
		s/&#0*251;/�/g;     s/&#x0*FB;/�/g;     s/&ucirc;/�/g;
		s/&#0*252;/�/g;     s/&#x0*FC;/�/g;     s/&uuml;/�/g;
		s/&#0*253;/�/g;     s/&#x0*FD;/�/g;     s/&yacute;/�/g;
		s/&#0*254;/�/g;     s/&#x0*FE;/�/g;     s/&thorn;/�/g;
		s/&#0*255;/�/g;     s/&#x0*FF;/�/g;     s/&yuml;/�/g;
		s/&#0*338;//g;     s/&#x0*152;//g;    s/&OElig;//g;
		s/&#0*339;//g;     s/&#x0*153;//g;    s/&oelig;//g;
		s/&#0*352;//g;     s/&#x0*160;//g;    s/&Scaron;//g;
		s/&#0*353;//g;     s/&#x0*161;//g;    s/&scaron;//g;
		s/&#0*376;//g;     s/&#x0*178;//g;    s/&Yuml;//g;
		s/&#0*402;//g;     s/&#x0*192;//g;    s/&fnof;//g;
		s/&#0*710;//g;     s/&#x0*2C6;//g;    s/&circ;//g;
		s/&#0*732;//g;     s/&#x0*2DC;//g;    s/&tilde;//g;
		s/&#0*913;//g;     s/&#x0*391;//g;    s/&Alpha;//g;
		s/&#0*914;//g;     s/&#x0*392;//g;    s/&Beta;//g;
		s/&#0*915;//g;     s/&#x0*393;//g;    s/&Gamma;//g;
		s/&#0*916;//g;     s/&#x0*394;//g;    s/&Delta;//g;
		s/&#0*917;//g;     s/&#x0*395;//g;    s/&Epsilon;//g;
		s/&#0*918;//g;     s/&#x0*396;//g;    s/&Zeta;//g;
		s/&#0*919;//g;     s/&#x0*397;//g;    s/&Eta;//g;
		s/&#0*920;//g;     s/&#x0*398;//g;    s/&Theta;//g;
		s/&#0*921;//g;     s/&#x0*399;//g;    s/&Iota;//g;
		s/&#0*922;//g;     s/&#x0*39A;//g;    s/&Kappa;//g;
		s/&#0*923;//g;     s/&#x0*39B;//g;    s/&Lambda;//g;
		s/&#0*924;//g;     s/&#x0*39C;//g;    s/&Mu;//g;
		s/&#0*925;//g;     s/&#x0*39D;//g;    s/&Nu;//g;
		s/&#0*926;//g;     s/&#x0*39E;//g;    s/&Xi;//g;
		s/&#0*927;//g;     s/&#x0*39F;//g;    s/&Omicron;//g;
		s/&#0*928;//g;     s/&#x0*3A0;//g;    s/&Pi;//g;
		s/&#0*929;//g;     s/&#x0*3A1;//g;    s/&Rho;//g;
		s/&#0*931;//g;     s/&#x0*3A3;//g;    s/&Sigma;//g;
		s/&#0*932;//g;     s/&#x0*3A4;//g;    s/&Tau;//g;
		s/&#0*933;//g;     s/&#x0*3A5;//g;    s/&Upsilon;//g;
		s/&#0*934;//g;     s/&#x0*3A6;//g;    s/&Phi;//g;
		s/&#0*935;//g;     s/&#x0*3A7;//g;    s/&Chi;//g;
		s/&#0*936;//g;     s/&#x0*3A8;//g;    s/&Psi;//g;
		s/&#0*937;//g;     s/&#x0*3A9;//g;    s/&Omega;//g;
		s/&#0*945;//g;     s/&#x0*3B1;//g;    s/&alpha;//g;
		s/&#0*946;//g;     s/&#x0*3B2;//g;    s/&beta;//g;
		s/&#0*947;//g;     s/&#x0*3B3;//g;    s/&gamma;//g;
		s/&#0*948;//g;     s/&#x0*3B4;//g;    s/&delta;//g;
		s/&#0*949;//g;     s/&#x0*3B5;//g;    s/&epsilon;//g;
		s/&#0*950;//g;     s/&#x0*3B6;//g;    s/&zeta;//g;
		s/&#0*951;//g;     s/&#x0*3B7;//g;    s/&eta;//g;
		s/&#0*952;//g;     s/&#x0*3B8;//g;    s/&theta;//g;
		s/&#0*953;//g;     s/&#x0*3B9;//g;    s/&iota;//g;
		s/&#0*954;//g;     s/&#x0*3BA;//g;    s/&kappa;//g;
		s/&#0*955;//g;     s/&#x0*3BB;//g;    s/&lambda;//g;
		s/&#0*956;//g;     s/&#x0*3BC;//g;    s/&mu;//g;
		s/&#0*957;//g;     s/&#x0*3BD;//g;    s/&nu;//g;
		s/&#0*958;//g;     s/&#x0*3BE;//g;    s/&xi;//g;
		s/&#0*959;//g;     s/&#x0*3BF;//g;    s/&omicron;//g;
		s/&#0*960;//g;     s/&#x0*3C0;//g;    s/&pi;//g;
		s/&#0*961;//g;     s/&#x0*3C1;//g;    s/&rho;//g;
		s/&#0*962;//g;     s/&#x0*3C2;//g;    s/&sigmaf;//g;
		s/&#0*963;//g;     s/&#x0*3C3;//g;    s/&sigma;//g;
		s/&#0*964;//g;     s/&#x0*3C4;//g;    s/&tau;//g;
		s/&#0*965;//g;     s/&#x0*3C5;//g;    s/&upsilon;//g;
		s/&#0*966;//g;     s/&#x0*3C6;//g;    s/&phi;//g;
		s/&#0*967;//g;     s/&#x0*3C7;//g;    s/&chi;//g;
		s/&#0*968;//g;     s/&#x0*3C8;//g;    s/&psi;//g;
		s/&#0*969;//g;     s/&#x0*3C9;//g;    s/&omega;//g;
		s/&#0*977;//g;     s/&#x0*3D1;//g;    s/&thetasym;//g;
		s/&#0*978;//g;     s/&#x0*3D2;//g;    s/&upsih;//g;
		s/&#0*982;//g;     s/&#x0*3D6;//g;    s/&piv;//g;
		s/&#0*8194;//g;    s/&#x0*2002;//g;   s/&ensp;//g;
		s/&#0*8195;//g;    s/&#x0*2003;//g;   s/&emsp;//g;
		s/&#0*8201;//g;    s/&#x0*2009;//g;   s/&thinsp;//g;
		s/&#0*8204;/ /g;    s/&#x0*200C;/ /g;   s/&zwnj;/ /g;
		s/&#0*8205;/ /g;    s/&#x0*200D;/ /g;   s/&zwj;/ /g;
		s/&#0*8206;/ /g;    s/&#x0*200E;/ /g;   s/&lrm;/ /g;
		s/&#0*8207;/ /g;    s/&#x0*200F;/ /g;   s/&rlm;/ /g;
		s/&#0*8211;//g;    s/&#x0*2013;//g;   s/&ndash;//g;
		s/&#0*8212;//g;    s/&#x0*2014;//g;   s/&mdash;//g;
		s/&#0*8216;//g;    s/&#x0*2018;//g;   s/&lsquo;//g;
		s/&#0*8217;//g;    s/&#x0*2019;//g;   s/&rsquo;//g;
		s/&#0*8218;//g;    s/&#x0*201A;//g;   s/&sbquo;//g;
		s/&#0*8220;//g;    s/&#x0*201C;//g;   s/&ldquo;//g;
		s/&#0*8221;//g;    s/&#x0*201D;//g;   s/&rdquo;//g;
		s/&#0*8222;//g;    s/&#x0*201E;//g;   s/&bdquo;//g;
		s/&#0*8224;//g;    s/&#x0*2020;//g;   s/&dagger;//g;
		s/&#0*8225;//g;    s/&#x0*2021;//g;   s/&Dagger;//g;
		s/&#0*8226;//g;    s/&#x0*2022;//g;   s/&bull;//g;
		s/&#0*8230;//g;    s/&#x0*2026;//g;   s/&hellip;//g;
		s/&#0*8240;//g;    s/&#x0*2030;//g;   s/&permil;//g;
		s/&#0*8242;//g;    s/&#x0*2032;//g;   s/&prime;//g;
		s/&#0*8243;//g;    s/&#x0*2033;//g;   s/&Prime;//g;
		s/&#0*8249;//g;    s/&#x0*2039;//g;   s/&lsaquo;//g;
		s/&#0*8250;//g;    s/&#x0*203A;//g;   s/&rsaquo;//g;
		s/&#0*8254;//g;    s/&#x0*203E;//g;   s/&oline;//g;
		s/&#0*8260;//g;    s/&#x0*2044;//g;   s/&frasl;//g;
		s/&#0*8364;//g;    s/&#x0*20AC;//g;   s/&euro;//g;
		s/&#0*8465;//g;    s/&#x0*2111;//g;   s/&image;//g;
		s/&#0*8472;//g;    s/&#x0*2118;//g;   s/&weierp;//g;
		s/&#0*8476;//g;    s/&#x0*211C;//g;   s/&real;//g;
		s/&#0*8482;//g;    s/&#x0*2122;//g;   s/&trade;//g;
		s/&#0*8501;//g;    s/&#x0*2135;//g;   s/&alefsym;//g;
		s/&#0*8592;//g;    s/&#x0*2190;//g;   s/&larr;//g;
		s/&#0*8593;//g;    s/&#x0*2191;//g;   s/&uarr;//g;
		s/&#0*8594;//g;    s/&#x0*2192;//g;   s/&rarr;//g;
		s/&#0*8595;//g;    s/&#x0*2193;//g;   s/&darr;//g;
		s/&#0*8596;//g;    s/&#x0*2194;//g;   s/&harr;//g;
		s/&#0*8629;//g;    s/&#x0*21B5;//g;   s/&crarr;//g;
		s/&#0*8656;//g;    s/&#x0*21D0;//g;   s/&lArr;//g;
		s/&#0*8657;//g;    s/&#x0*21D1;//g;   s/&uArr;//g;
		s/&#0*8658;//g;    s/&#x0*21D2;//g;   s/&rArr;//g;
		s/&#0*8659;//g;    s/&#x0*21D3;//g;   s/&dArr;//g;
		s/&#0*8660;//g;    s/&#x0*21D4;//g;   s/&hArr;//g;
		s/&#0*8704;//g;    s/&#x0*2200;//g;   s/&forall;//g;
		s/&#0*8706;//g;    s/&#x0*2202;//g;   s/&part;//g;
		s/&#0*8707;//g;    s/&#x0*2203;//g;   s/&exist;//g;
		s/&#0*8709;//g;    s/&#x0*2205;//g;   s/&empty;//g;
		s/&#0*8711;//g;    s/&#x0*2207;//g;   s/&nabla;//g;
		s/&#0*8712;//g;    s/&#x0*2208;//g;   s/&isin;//g;
		s/&#0*8713;//g;    s/&#x0*2209;//g;   s/&notin;//g;
		s/&#0*8715;//g;    s/&#x0*220B;//g;   s/&ni;//g;
		s/&#0*8719;//g;    s/&#x0*220F;//g;   s/&prod;//g;
		s/&#0*8721;//g;    s/&#x0*2211;//g;   s/&sum;//g;
		s/&#0*8722;//g;    s/&#x0*2212;//g;   s/&minus;//g;
		s/&#0*8727;//g;    s/&#x0*2217;//g;   s/&lowast;//g;
		s/&#0*8730;//g;    s/&#x0*221A;//g;   s/&radic;//g;
		s/&#0*8733;//g;    s/&#x0*221D;//g;   s/&prop;//g;
		s/&#0*8734;//g;    s/&#x0*221E;//g;   s/&infin;//g;
		s/&#0*8736;//g;    s/&#x0*2220;//g;   s/&ang;//g;
		s/&#0*8743;//g;    s/&#x0*2227;//g;   s/&and;//g;
		s/&#0*8744;//g;    s/&#x0*2228;//g;   s/&or;//g;
		s/&#0*8745;//g;    s/&#x0*2229;//g;   s/&cap;//g;
		s/&#0*8746;//g;    s/&#x0*222A;//g;   s/&cup;//g;
		s/&#0*8747;//g;    s/&#x0*222B;//g;   s/&int;//g;
		s/&#0*8756;//g;    s/&#x0*2234;//g;   s/&there4;//g;
		s/&#0*8764;//g;    s/&#x0*223C;//g;   s/&sim;//g;
		s/&#0*8773;//g;    s/&#x0*2245;//g;   s/&cong;//g;
		s/&#0*8776;//g;    s/&#x0*2248;//g;   s/&asymp;//g;
		s/&#0*8800;//g;    s/&#x0*2260;//g;   s/&ne;//g;
		s/&#0*8801;//g;    s/&#x0*2261;//g;   s/&equiv;//g;
		s/&#0*8804;//g;    s/&#x0*2264;//g;   s/&le;//g;
		s/&#0*8805;//g;    s/&#x0*2265;//g;   s/&ge;//g;
		s/&#0*8834;//g;    s/&#x0*2282;//g;   s/&sub;//g;
		s/&#0*8835;//g;    s/&#x0*2283;//g;   s/&sup;//g;
		s/&#0*8836;//g;    s/&#x0*2284;//g;   s/&nsub;//g;
		s/&#0*8838;//g;    s/&#x0*2286;//g;   s/&sube;//g;
		s/&#0*8839;//g;    s/&#x0*2287;//g;   s/&supe;//g;
		s/&#0*8853;//g;    s/&#x0*2295;//g;   s/&oplus;//g;
		s/&#0*8855;//g;    s/&#x0*2297;//g;   s/&otimes;//g;
		s/&#0*8869;//g;    s/&#x0*22A5;//g;   s/&perp;//g;
		s/&#0*8901;//g;    s/&#x0*22C5;//g;   s/&sdot;//g;
		s/&#0*8968;//g;    s/&#x0*2308;//g;   s/&lceil;//g;
		s/&#0*8969;//g;    s/&#x0*2309;//g;   s/&rceil;//g;
		s/&#0*8970;//g;    s/&#x0*230A;//g;   s/&lfloor;//g;
		s/&#0*8971;//g;    s/&#x0*230B;//g;   s/&rfloor;//g;
		s/&#0*10216;//g;   s/&#x0*27E8;//g;   s/&lang;//g;
		s/&#0*10217;//g;   s/&#x0*27E9;//g;   s/&rang;//g;
		s/&#0*9674;//g;    s/&#x0*25CA;//g;   s/&loz;//g;
		s/&#0*9824;//g;    s/&#x0*2660;//g;   s/&spades;//g;
		s/&#0*9827;//g;    s/&#x0*2663;//g;   s/&clubs;//g;
		s/&#0*9829;//g;    s/&#x0*2665;//g;   s/&hearts;//g;
		s/&#0*9830;//g;    s/&#x0*2666;//g;   s/&diams;//g;
	"

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
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

	# Faz a convers�o
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
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzunicode2ascii ()
{
	zzzz -h unicode2ascii "$1" && return

	# Tentei manter o sentido do caractere original na tradu��o.
	# Outros preferi manter o original a fazer um tradu��o d�bia.
	# Aceito sugest�es de melhorias! @oreio

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" | sed "

	# Nota: Mesma tabela de dados da zzunescape.

	# s \" \" g
	# s & & g
	# s ' ' g
	# s < < g
	# s > > g
	# s/ / /g
	s � i g
	s � c g
	# s � � g
	# s � � g
	s � Y g
	s � | g
	# s � � g
	s � \" g
	s � (C) g
	s � a g
	s � << g
	# s � � g
	s � - g
	s � (R) g
	s � - g
	# s � � g
	s � +- g
	s � 2 g
	s � 3 g
	s � ' g
	s � u g
	# s � � g
	s � . g
	s � , g
	s � 1 g
	s � o g
	s � >> g
	s � 1/4 g
	s � 1/2 g
	s � 3/4 g
	# s � � g
	s � A g
	s � A g
	s � A g
	s � A g
	s � A g
	s � A g
	s � AE g
	s � C g
	s � E g
	s � E g
	s � E g
	s � E g
	s � I g
	s � I g
	s � I g
	s � I g
	s � D g
	s � N g
	s � O g
	s � O g
	s � O g
	s � O g
	s � O g
	s � x g
	s � O g
	s � U g
	s � U g
	s � U g
	s � U g
	s � Y g
	s � P g
	s � B g
	s � a g
	s � a g
	s � a g
	s � a g
	s � a g
	s � a g
	s � ae g
	s � c g
	s � e g
	s � e g
	s � e g
	s � e g
	s � i g
	s � i g
	s � i g
	s � i g
	s � d g
	s � n g
	s � o g
	s � o g
	s � o g
	s � o g
	s � o g
	s � / g
	s � o g
	s � u g
	s � u g
	s � u g
	s � u g
	s � y g
	s � p g
	s � y g
	s  OE g
	s  oe g
	s  S g
	s  s g
	s  Y g
	s  f g
	s  ^ g
	s  ~ g
	s  A g
	s  B g
	# s   g
	# s   g
	s  E g
	s  Z g
	s  H g
	# s   g
	s  I g
	s  K g
	# s   g
	s  M g
	s  N g
	# s   g
	s  O g
	# s   g
	s  P g
	# s   g
	s  T g
	s  Y g
	# s   g
	s  X g
	# s   g
	# s   g
	s  a g
	s  b g
	# s   g
	# s   g
	s  e g
	# s   g
	s  n g
	# s   g
	# s   g
	s  k g
	# s   g
	s  u g
	s  v g
	# s   g
	s  o g
	# s   g
	s  p g
	s  s g
	# s   g
	s  t g
	s  u g
	# s   g
	s  x g
	# s   g
	s  w g
	# s   g
	# s   g
	# s   g
	s// /g
	s// /g
	s// /g
	s// /g
	s// /g
	s// /g
	s// /g
	s  - g
	s  - g
	s  ' g
	s  ' g
	s  , g
	s  \" g
	s  \" g
	s  \" g
	# s   g
	# s   g
	s  * g
	s  ... g
	# s   g
	s  ' g
	s  \" g
	s  < g
	s  > g
	s  - g
	s  / g
	s  E g
	# s   g
	# s   g
	s  R g
	s  TM g
	# s   g
	s  <- g
	# s   g
	s  -> g
	# s   g
	s  <-> g
	# s   g
	s  <= g
	# s   g
	s  => g
	# s   g
	s  <=> g
	# s   g
	# s   g
	# s   g
	# s   g
	# s   g
	# s   g
	# s   g
	# s   g
	# s   g
	# s   g
	s  - g
	s  * g
	# s   g
	# s   g
	# s   g
	# s   g
	s  ^ g
	s  v g
	# s   g
	# s   g
	# s   g
	# s   g
	s  ~ g
	s  ~= g
	s  ~~ g
	# s   g
	# s   g
	s  <= g
	s  >= g
	# s   g
	# s   g
	# s   g
	# s   g
	# s   g
	s  (+) g
	s  (x) g
	# s   g
	s  . g
	# s   g
	# s   g
	# s   g
	# s   g
	s  < g
	s  > g
	s  <> g
	# s   g
	# s   g
	s  <3 g
	s  <> g
	"
}

# ----------------------------------------------------------------------------
# zzuniq
# Retira as linhas repetidas, consecutivas ou n�o.
# Obs.: N�o altera a ordem original das linhas, diferente do sort|uniq.
#
# Uso: zzuniq [arquivo(s)]
# Ex.: zzuniq /etc/inittab
#      cat /etc/inittab | zzuniq
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-06-22
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzuniq ()
{
	zzzz -h uniq "$1" && return

	# Nota: as linhas do arquivo s�o numeradas para guardar a ordem original

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |
		cat -n  |      # Numera as linhas do arquivo
		sort -k2 -u |  # Ordena e remove duplos, ignorando a numera��o
		sort -n |      # Restaura a ordem original
		cut -f 2-      # Remove a numera��o

	# Vers�o SED, mais lenta para arquivos grandes, mas s� precisa do SED
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
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzunix2dos ()
{
	zzzz -h unix2dos "$1" && return

	local arquivo
	local tmp="$ZZTMP.unix2dos.$$"
	local control_m=$(printf '\r')  # ^M, CR, \r

	# Sem argumentos, l�/grava em STDIN/STDOUT
	if test $# -eq 0
	then
		sed "s/$control_m*$/$control_m/"

		# Facinho, terminou j�
		return
	fi

	# Usu�rio passou uma lista de arquivos
	# Os arquivos ser�o sobrescritos, todo cuidado � pouco
	for arquivo
	do
		# O arquivo existe?
		zztool arquivo_legivel "$arquivo" || continue

		# Adiciona um �nico CR no final de cada linha
		cp "$arquivo" "$tmp" &&
		sed "s/$control_m*$/$control_m/" "$tmp" > "$arquivo"

		# Seguran�a
		if [ $? -ne 0 ]
		then
			echo "Ops, algum erro ocorreu em $arquivo"
			echo "Seu arquivo original est� guardado em $tmp"
			return 1
		fi

		echo "Convertido $arquivo"
	done

	# Remove o arquivo tempor�rio
	rm -f "$tmp"
}

# ----------------------------------------------------------------------------
# zzvira
# Vira um texto, de tr�s pra frente (rev) ou de ponta-cabe�a.
# Ideia original de: http://www.revfad.com/flip.html (valeu @andersonrizada)
#
# Uso: zzvira [-X] texto
# Ex.: zzvira Inverte tudo             # odut etrevnI
#      zzvira -X De pernas pro ar      #  od sud p
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2010-05-24
# Vers�o: 2
# Licen�a: GPL
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

	# Vira o texto de tr�s pra frente (rev)
	sed '
		/\n/!G
		s/\(.\)\(.*\n\)/&\2\1/
		//D
		s/.//' |

	if [ "$rasteira" ]
	then
		zzsemacento |
		zzminusculas |
			sed 'y@abcdefghijklmnopqrstuvwxyz._!?(){}<>@qpluodbsnxz��)(}{><@' |
			sed "y/'/,/" |
			sed 's/\[/X/g ; s/]/[/g ; s/X/]/g'
	else
		cat -
	fi
}

# ----------------------------------------------------------------------------
# zzwikipedia
# http://www.wikipedia.org
# Procura na Wikip�dia, a enciclop�dia livre.
# Obs.: Se nenhum idioma for especificado, � utilizado o portugu�s.
#
# Idiomas: de (alem�o)    eo (esperanto)  es (espanhol)  fr (franc�s)
#          it (italiano)  ja (japon�s)    la (latin)     pt (portugu�s)
#
# Uso: zzwikipedia [-idioma] palavra(s)
# Ex.: zzwikipedia sed
#      zzwikipedia Linus Torvalds
#      zzwikipedia -pt Linus Torvalds
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-10-28
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzwikipedia ()
{
	zzzz -h wikipedia "$1" && return

	local url
	local idioma='pt'

	# Se o idioma foi informado, guarda-o, retirando o h�fen
	if [ "${1#-}" != "$1" ]
	then
		idioma="${1#-}"
		shift
	fi

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso wikipedia; return 1; }

	# Faz a consulta e filtra o resultado, paginando
	url="http://$idioma.wikipedia.org/wiki/"
	$ZZWWWDUMP "$url$(echo "$*" | sed 's/  */_/g')" |
		sed '
			# Limpeza do conte�do
			/^Views$/,$ d
			/^Vistas$/,$ d
			/^Ferramentas pessoais$/,$ d
			/^   #Wikipedia (/d
			/^   #Editar Wikip.dia /d
			/^   From Wikipedia,/d
			/^   Origem: Wikip�dia,/d
			/^   Jump to: /d
			/^   Ir para: /d
			/^   This article does not cite any references/d
			/^   Please help improve this article/d
			/^   Wikipedia does not have an article with this exact name./q
			s/^\[edit\] //
			s/^\[editar\] //

			# Guarda URL da p�gina e mostra no final, ap�s Categorias
			# Tamb�m adiciona linha em branco antes de Categorias
			/^   Obtid[ao] de "/ { H; d; }
			/^   Retrieved from "/ { H; d; }
			/^   Categor[a-z]*: / { G; x; s/.*//; G; }' |
		cat -s
}

# ----------------------------------------------------------------------------
# zzxml
# Parser simples (e limitado) para arquivos XML/HTML.
# Obs.: Este parser � usado pelas Fun��es ZZ, n�o serve como parser gen�rico.
# Obs.: Necess�rio pois n�o h� ferramenta port�vel para lidar com XML no Unix.
#
# Op��es: --tidy      Reorganiza o c�digo, deixando uma tag por linha
#         --tag       Extrai (grep) uma tag espec�fica
#         --untag     Remove todas as tags, deixando apenas texto
#         --unescape  Converte as entidades &foo; para caracteres normais
#
# Uso: zzxml [--tidy] [--tag NOME] [--untag] [--unescape] [arquivo(s)]
# Ex.: zzxml --tidy arquivo.xml
#      zzxml --untag --unescape arquivo.xml                     # xml -> txt
#      zzxml --tag title --untag --unescape arquivo.xml         # t�tulos
#      cat arquivo.xml | zzxml --tag item | zzxml --tag title   # aninhado
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2011-05-03
# Vers�o: 2
# Licen�a: GPL
# Requisitos: zzjuntalinhas
# ----------------------------------------------------------------------------
zzxml ()
{
	zzzz -h xml "$1" && return

	local tag
	local tidy=0
	local untag=0
	local unescape=0

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			--tidy    ) shift; tidy=1;;
			--untag   ) shift; untag=1;;
			--unescape) shift; unescape=1;;
			--tag     ) shift; tidy=1 tag="$1"; shift;;
			--*       ) echo "Op��o inv�lida $1"; return 1;;
			*         ) break;;
		esac
	done

	# O c�digo seguinte � um grande filtro, com diversos blocos de comando
	# IF interligados via pipe (logo ap�s o FI). Cada IF pode aplicar um
	# filtro (sed, grep, etc) ao c�digo XML, ou pass�-lo adiante inalterado
	# (cat -). Por esta natureza, a ordem dos filtros importa. O tidy deve
	# ser sempre o primeiro, para organizar. O unescape deve ser o �ltimo,
	# pois ele pode fazer surgir < e > no c�digo.
	#
	# Essa estrutura toda de IFs interligados � bizarra e n�o tenho certeza
	# se funciona em vers�es bem antigas do bash, mas acredito que sim. Fiz
	# assim para evitar ficar lendo e gravando arquivos tempor�rios para
	# cada filtro. Como est�, � tudo um grande fluxo de texto, que n�o usa
	# arquivos externos. Mas se esta fun��o precisar crescer, todo este
	# esquema precisar� ser revisto.

	# Arquivos via STDIN ou argumentos
	zztool file_stdin "$@" |

		# --tidy
		if test $tidy -eq 1
		then
			# Deixa somente uma tag por linha.
			# Tags multilinha ficam em somente uma linha.
			# V�rias tags em uma mesma linha ficam multilinha.
			# Isso facilita a extra��o de dados com grep, sed, awk...
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
				# quebra linha ap�s fechamento da tag
				s/>/>\
/g' |
			# Rejunta o conte�do do <![CDATA[...]]>, que pode ter tags
			zzjuntalinhas -i '^<!\[CDATA\[' -f ']]>$' -d '' |

			# Remove linhas em branco (as que adicionamos)
			sed '/^$/d'
		else
			cat -
		fi |

		# --tag
		# � sempre usada em conjunto com --tidy (automaticamente)
		if test -n "$tag"
		then
			sed -n "
				# Tags de uma linha
				# <foo bar='1' />
				/^<$tag[> ].*\/>$/ p

				# Tags multilinha
				# <p>Foo
				# <b>bar
				# </b>
				# </p>
				/^<$tag[> ]/, /^<\/$tag>/ {
					H
					/^<\/$tag>/ {
						s/.*//
						x
						s/\n//g
						p
					}
				}"
		else
			cat -
		fi |

		# --untag
		if test $untag -eq 1
		then
			# Caso especial: <![CDATA[Foo bar.]]>
			sed 's/<!\[CDATA\[//g ; s/]]>//g ; s/<[^>]*>//g'
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
}


ZZDIR=

##############################################################################
#
#                             Texto de ajuda
#                             --------------
#
#

# Fun��o tempor�ria para extrair o texto de ajuda do cabe�alho das fun��es
# Passe o arquivo com as fun��es como par�metro
_extrai_ajuda() {
	# Extrai somente os cabe�alhos, j� removendo o # do in�cio
	sed -n '/^# -----* *$/, /^# -----* *$/ s/^# \{0,1\}//p' "$1" |
		# Agora remove trechos que n�o podem aparecer na ajuda
		sed '
			# Apaga a metadata (Autor, Desde, Versao, etc)
			/^Autor:/, /^------/ d

			# Apaga a linha em branco apos Ex.:
			/^Ex\.:/, /^------/ {
				/^ *$/d
			}'
}

# Limpa conte�do do arquivo de ajuda
> "$ZZAJUDA"

# Salva o texto de ajuda das fun��es deste arquivo
test -r "$ZZPATH" && _extrai_ajuda "$ZZPATH" >> "$ZZAJUDA"


##############################################################################
#
#                    Carregamento das fun��es do $ZZDIR
#                    ----------------------------------
#
# O carregamento � feito em dois passos para ficar mais robusto:
# 1. Obten��o da lista completa de fun��es, ativadas e desativadas.
# 2. Carga de cada fun��o ativada, salvando o texto de ajuda.
#
# Com a op��o --tudo-em-um, o passo 2 � alterado para mostrar o conte�do
# da fun��o em vez de carreg�-la.
#

### Passo 1

# Limpa arquivos tempor�rios que guardam as listagens
> "$ZZTMP.on"
> "$ZZTMP.off"

# A pasta das fun��es existe?
if test -n "$ZZDIR" -a -d "$ZZDIR"
then
	# Melhora a lista off: um por linha, sem prefixo zz
	zz_off=$(echo "$ZZOFF" | zztool list2lines | sed 's/^zz//')

	# Primeiro salva a lista de fun��es dispon�veis
	for zz_arquivo in "${ZZDIR%/}"/zz*
	do
		# S� ativa fun��es que podem ser lidas
		if test -r "$zz_arquivo"
		then
			zz_nome="${zz_arquivo##*/}"  # remove path
			zz_nome="${zz_nome%.sh}"     # remove extens�o

			# O usu�rio desativou esta fun��o?
			echo "$zz_off" | grep "^${zz_nome#zz}$" >/dev/null ||
				# Tudo certo, essa vai ser carregada
				echo "$zz_nome"
		fi
	done >> "$ZZTMP.on"

	# Lista das fun��es desativadas (OFF = Todas - ON)
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

# Vamos juntar todas as fun��es em um �nico arquivo?
if test "$1" = '--tudo-em-um'
then
	# Verifica se a pasta das fun��es existe
	if test -z "$ZZDIR" -o ! -d "$ZZDIR"
	then
		(
		echo "Ops! N�o encontrei as fun��es na pasta '$ZZDIR'."
		echo 'Informe a localiza��o correta na vari�vel $ZZDIR.'
		echo
		echo 'Exemplo: export ZZDIR="$HOME/zz"'
		) >&2
		exit 1
		# Posso usar exit porque a chamada � pelo execut�vel, e n�o source
	fi

	# Primeira metade deste arquivo, at� #@
	sed '/^#@$/q' "$ZZPATH"

	# Mostra cada fun��o (ativa), inserindo seu nome na linha 2 do cabe�alho
	while read zz_nome
	do
		zz_arquivo="${ZZDIR%/}"/$zz_nome.sh

		# Suporte legado aos arquivos sem a extens�o .sh
		test -r "$zz_arquivo" || zz_arquivo="${zz_arquivo%.sh}"

		sed 1q "$zz_arquivo"
		echo "# $zz_nome"
		sed 1d "$zz_arquivo"

		# Linha em branco separadora
		# Tamb�m garante quebra se faltar \n na �ltima linha da fun��o
		echo
	done < "$ZZTMP.on"

	# Desliga suporte ao diret�rio de fun��es
	echo
	echo 'ZZDIR='

	# Segunda metade deste arquivo, depois de #@
	sed '1,/^#@$/d' "$ZZPATH"

	# T� feito, simbora.
	exit 0
fi

# Carregamento das fun��es ativas, salvando texto de ajuda
while read zz_nome
do
	zz_arquivo="${ZZDIR%/}"/$zz_nome.sh

	# Se o arquivo n�o existir, tenta encontr�-lo sem a extensao .sh.
	# No futuro este suporte �s fun��es sem extens�o pode ser removido.
	if ! test -r "$zz_arquivo"
	then
		if test -r "${zz_arquivo%.sh}"
		then
			# N�o achei zzfoo.sh, mas achei o zzfoo
			# Vamos us�-lo ent�o.
			zz_arquivo="${zz_arquivo%.sh}"
		else
			# N�o achei zzfoo.sh nem zzfoo
			# Cancelaremos o carregamento desta fun��o.
			continue
		fi
	fi

	# Inclui a fun��o na shell atual
	source "$zz_arquivo"

	# Extrai o texto de ajuda
	_extrai_ajuda "$zz_arquivo" |
		# Insere o nome da fun��o na segunda linha
		sed "2 { h; s/.*/$zz_nome/; G; }"

done < "$ZZTMP.on" >> "$ZZAJUDA"

# Separador final do arquivo, com exatamente 77 h�fens (7x11)
echo '-------' | sed 's/.*/&&&&&&&&&&&/' >> "$ZZAJUDA"


# Modo --tudo-em-um
# Todas as fun��es j� foram carregadas por estarem dentro deste arquivo.
# Agora faremos o desligamento "manual" das fun��es ZZOFF.
#
if test -z "$ZZDIR" -a -n "$ZZOFF"
then

	# Lista de fun��es a desligar: uma por linha, com prefixo zz, exceto ZZBASE
	zz_off=$(
		echo "$ZZOFF" |
		zztool list2lines |
		sed 's/^zz// ; s/^/zz/' |
		egrep -v "$(echo $ZZBASE | sed 's/ /|/g')"
	)

	# Desliga todas em uma s� linha (note que n�o usei aspas)
	unset $zz_off

	# Agora apaga os textos da ajuda, montando um script em sed e aplicando
	# Veja issue 5 para mais detalhes:
	# https://github.com/aureliojargas/funcoeszz/issues/5
	zz_sed=$(echo "$zz_off" | sed 's@.*@/^&$/,/^----*$/d;@')  # /^zzfoo$/,/^----*$/d
	cp "$ZZAJUDA" "$ZZAJUDA.2" &&
	sed "$zz_sed" "$ZZAJUDA.2" > "$ZZAJUDA"
	rm "$ZZAJUDA.2"
fi


### Carregamento terminado, fun��es j� est�o dispon�veis

# Limpa vari�veis e fun��es tempor�rias
# Nota: prefixo zz_ para n�o conflitar com vari�veis da shell atual
unset zz_arquivo
unset zz_nome
unset zz_off
unset zz_sed
unset _extrai_ajuda


##----------------------------------------------------------------------------
## Lidando com a chamada pelo execut�vel

# Se h� par�metros, � porque o usu�rio est� nos chamando pela
# linha de comando, e n�o pelo comando source.
if [ "$1" ]
then

	case "$1" in

		# Mostra a tela de ajuda
		-h | --help)

			cat - <<-FIM

				Uso: funcoeszz <fun��o> [<par�metros>]

				Lista de fun��es:
				    funcoeszz zzzz
				    funcoeszz zzajuda --lista

				Ajuda:
				    funcoeszz zzajuda
				    funcoeszz zzcores -h
				    funcoeszz zzcalcula -h

				Instala��o:
				    funcoeszz zzzz --bashrc
				    source ~/.bashrc
				    zz<TAB><TAB>

				Saiba mais:
				    http://funcoeszz.net

			FIM
		;;

		# Mostra a vers�o das fun��es
		-v | --version)
			echo "Fun��es ZZ v$ZZVERSAO"
		;;

		-*)
			echo "Op��o inv�lida '$1' (tente --help)"
		;;

		# Chama a fun��o informada em $1, caso ela exista
		*)
			func="$1"

			# Garante que a zzzz possa ser chamada por zz somente
			[ "$func" = 'zz' ] && func='zzzz'

			# O prefixo zz � opcional: zzdata e data funcionam
			func="zz${func#zz}"

			# A fun��o existe?
			if type $func >/dev/null 2>&1
			then
				shift
				$func "$@"
			else
				echo "Fun��o inexistente '$func' (tente --help)"
			fi
		;;
	esac
fi
