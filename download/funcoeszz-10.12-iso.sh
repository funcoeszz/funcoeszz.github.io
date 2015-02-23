#!/usr/bin/env bash
# funcoeszz
#
# INFORMA��ES: www.funcoeszz.net
# NASCIMENTO : 22 de Fevereiro de 2000
# AUTORES    : Aur�lio Marinho Jargas <verde (a) aurelio net>
#              Thobias Salazar Trevisan <thobias (a) thobias org>
# DESCRI��O  : Fun��es de uso geral para o shell Bash, que buscam
#              informa��es em arquivos locais e fontes na Internet
# LICEN�A    : GPLv2
# CHANGELOG  : www.funcoeszz.net/changelog.html
#
ZZVERSAO=10.12
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
# Uso: zztool ferramenta [argumentos]
# Ex.: zztool grep_var foo $var
#      zztool eco Minha mensagem colorida
#      zztool testa_numero $num
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-03-01
# ----------------------------------------------------------------------------
zztool ()
{
	case "$1" in
		uso)
			# Extrai a mensagem de uso da fun��o $2, usando seu --help
			zzzz -h $2 -h | grep Uso
		;;
		eco)
			shift
			# Mostra mensagem colorida caso $ZZCOR esteja ligada
			if [ "$ZZCOR" != '1' ]
			then
				echo -e "$*"
			else
				echo -e "\033[${ZZCODIGOCOR}m$*\033[m"
			fi
		;;
		acha)
			# Destaca o padr�o $2 no texto via STDIN ou $3
			# O padr�o pode ser uma regex no formato BRE (grep/sed)
			local esc=$(printf '\033')
			local padrao=$(echo "$2" | sed 's,/,\\/,g') # escapa /
			shift; shift
			zztool multi_stdin "$@" |
				if [ "$ZZCOR" != '1' ]
				then
					cat -
				else
		 			sed "s/$padrao/$esc[${ZZCODIGOCOR}m&$esc[m/g"
				fi
		;;
		grep_var)
			# $2 est� presente em $3?
			test "${3#*$2}" != "$3"
		;;
		index_var)
			# $2 est� em qual posi��o em $3?
			local padrao="$2"
			local texto="$3"
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
			if test -e "$2"
			then
				echo "Arquivo $2 j� existe. Abortando."
				return 1
			fi
		;;
		arquivo_legivel)
			# Verifica se o arquivo existe e � leg�vel
			if ! test -r "$2"
			then
				echo "N�o consegui ler o arquivo $2"
				return 1
			fi
			
			# TODO Usar em *todas* as fun��es que l�em arquivos
		;;
		num_linhas)
			# Informa o n�mero de linhas, sem formata��o 
			shift
			zztool file_stdin "$@" |
				wc -l |
				tr -d ' \t'
		;;
		testa_numero)
			# Testa se $2 � um n�mero positivo
			echo "$2" | grep '^[0-9]\{1,\}$' >/dev/null
			
			# TODO Usar em *todas* as fun��es que recebem n�meros
		;;
		testa_numero_sinal)
			# Testa se $2 � um n�mero (pode ter sinal: -2 +2)
			echo "$2" | grep '^[+-]\{0,1\}[0-9]\{1,\}$' >/dev/null
		;;
		testa_numero_fracionario)
			# Testa se $2 � um n�mero fracion�rio (1.234 ou 1,234)
			# regex: \d+[,.]\d+
			echo "$2" | grep '^[0-9]\{1,\}[,.][0-9]\{1,\}$' >/dev/null
		;;
		testa_dinheiro)
			# Testa se $2 � um valor monet�rio (1.234,56 ou 1234,56)
			# regex: (  \d{1,3}(\.\d\d\d)+  |  \d+  ),\d\d
			echo "$2" | grep '^\([0-9]\{1,3\}\(\.[0-9][0-9][0-9]\)\{1,\}\|[0-9]\{1,\}\),[0-9][0-9]$' >/dev/null
		;;
		testa_binario)
			# Testa se $2 � um n�mero bin�rio
			echo "$2" | grep '^[01]\{1,\}$' >/dev/null
		;;
		testa_ip)
			# Testa se $2 � um n�mero IP (nnn.nnn.nnn.nnn)
			local nnn="\([0-9]\{1,2\}\|1[0-9][0-9]\|2[0-4][0-9]\|25[0-5]\)" # 0-255
			echo "$2" | grep "^$nnn\.$nnn\.$nnn\.$nnn$" >/dev/null
		;;
		testa_data)
			# Testa se $2 � uma data (dd/mm/aaaa)
			local d29='\(0[1-9]\|[12][0-9]\)/\(0[1-9]\|1[012]\)'
			local d30='30/\(0[13-9]\|1[012]\)'
			local d31='31/\(0[13578]\|1[02]\)'
			echo "$2" | grep "^\($d29\|$d30\|$d31\)/[0-9]\{1,\}$" >/dev/null
		;;
		testa_hora)
			# Testa se $2 � uma hora (hh:mm)
			echo "$2" | grep "^\(0\{0,1\}[0-9]\|1[0-9]\|2[0-3]\):[0-5][0-9]$" >/dev/null
		;;
		multi_stdin)
			# Mostra na tela os argumentos *ou* a STDIN, nesta ordem
			# �til para fun��es/comandos aceitarem dados das duas formas:
			#     echo texto | funcao
			# ou
			#     funcao texto
			shift
			if [ "$1" ]
			then
				 	echo "$*"
			else
					cat -
			fi
		;;
		file_stdin)
			# Mostra na tela o conte�do do arquivo *ou* da STDIN, nesta ordem
			# �til para fun��es/comandos aceitarem dados das duas formas:
			#     cat arquivo | funcao
			# ou
			#     funcao arquivo
			shift
			if [ "$1" ]
			then
				 	cat "$*"
			else
					cat -
			fi
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
			shift
			zztool multi_stdin "$@" |
		 		sed 's/^[[:blank:]]*// ; s/[[:blank:]]*$//'
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-04
# ----------------------------------------------------------------------------
zzajuda ()
{
	zzzz -h ajuda $1 && return

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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2002-01-07
# ----------------------------------------------------------------------------
zzzz ()
{
	local nome_func arg_func padrao
	local info_instalado info_cor info_utf8 info_base versao_remota
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
		#     zzzz -h beep $1 && return
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
			zzzz -h $3 $2
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
			echo $cod_sistema

			printf 'Verificando a codifica��o das Fun��es ZZ... '
			test $ZZUTF = 1 && cod_funcoeszz='UTF-8'
			echo $cod_funcoeszz
			
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
			for func in $(ZZCOR=0 zzzz | sed '1,/^(( fu/d; /^(/d; s/,//g')
			do
				echo "alias zz$func 'funcoeszz zz$func'" >> "$arquivo_aliases"
			done
			echo
			echo "Aliases atualizados no $arquivo_aliases"
		;;

		# Cria aliases para as fun��es no arquivo .zshrc
		--zshrc)
			arquivo_aliases="$HOME/.zzzshrc"
			
			# Chama o arquivo dos aliases no final do .tcshrc
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
			for func in $(ZZCOR=0 zzzz | sed '1,/^(( fu/d; /^(/d; s/,//g')
			do
				echo "alias zz$func='funcoeszz zz$func'" >> "$arquivo_aliases"
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
			
			# Formata fun��es essenciais
			info_base=$(echo $ZZBASE | sed 's/ /, /g')
			
			# Informa��es, uma por linha
			zztool acha '^[^)]*)' "(script) $ZZPATH"
			zztool acha '^[^)]*)' "( pasta) $ZZDIR"
			zztool acha '^[^)]*)' "(vers�o) $ZZVERSAO ($info_utf8)"
			zztool acha '^[^)]*)' "( cores) $info_cor"
			zztool acha '^[^)]*)' "(   tmp) $ZZTMP"
			zztool acha '^[^)]*)' "(bashrc) $info_instalado"
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
				grep -q zz "$ZZTMP.off" || return
				
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
#
# Uso: zzalfabeto [--TIPO] [palavra]
# Ex.: zzalfabeto --militar
#      zzalfabeto --militar cambio
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-07-23
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzalfabeto ()
{
	zzzz -h alfabeto $1 && return

	local char letra

	local coluna=1
	local dados="\
A:Alpha:Apples:Ack:Ace:Apple:Able/Affirm:Able:Aveiro:Alan:Adam
B:Bravo:Butter:Beer:Beer:Beer:Baker:Baker:Bragan�a:Bobby:Boy
C:Charlie:Charlie:Charlie:Charlie:Charlie:Charlie:Charlie:Coimbra:Charlie:Charles
D:Delta:Duff:Don:Don:Dog:Dog:Dog:Dafundo:David:David
E:Echo:Edward:Edward:Edward:Edward:Easy:Easy:�vora:Edward:Edward
F:Foxtrot:Freddy:Freddie:Freddie:Freddy:Fox:Fox:Faro:Frederick:Frank
G:Golf:George:Gee:George:George:George:George:Guarda:George:George
H:Hotel:Harry:Harry:Harry:Harry:How:How:Horta:Howard:Henry
I:India:Ink:Ink:Ink:In:Item/Interrogatory:Item:It�lia:Isaac:Ida
J:Juliet:Johnnie:Johnnie:Johnnie:Jug/Johnny:Jig/Johnny:Jig:Jos�:James:John
K:Kilo:King:King:King:King:King:King:Kilograma:Kevin:King
L:Lima:London:London:London:Love:Love:Love:Lisboa:Larry:Lincoln
M:Mike:Monkey:Emma:Monkey:Mother:Mike:Mike:Maria:Michael:Mary
N:November:Nuts:Nuts:Nuts:Nuts:Nab/Negat:Nan:Nazar�:Nicholas:Nora
O:Oscar:Orange:Oranges:Orange:Orange:Oboe:Oboe:Ovar:Oscar:Ocean
P:Papa:Pudding:Pip:Pip:Peter:Peter/Prep:Peter:Porto:Peter:Paul
Q:Quebec:Queenie:Queen:Queen:Queen:Queen:Queen:Queluz:Quincy:Queen
R:Romeo:Robert:Robert:Robert:Roger/Robert:Roger:Roger:Rossio:Robert:Robert
S:Sierra:Sugar:Esses:Sugar:Sugar:Sugar:Sugar:Set�bal:Stephen:Sam
T:Tango:Tommy:Toc:Toc:Tommy:Tare:Tare:Tavira:Trevor:Tom
U:Uniform:Uncle:Uncle:Uncle:Uncle:Uncle:Uncle:Unidade:Ulysses:Union
V:Victor:Vinegar:Vic:Vic:Vic:Victor:Victor:Viseu:Vincent:Victor
W:Whiskey:Willie:William:William:William:William:William:Washington:William:William
X:X-ray/Xadrez:Xerxes:X-ray:X-ray:X-ray:X-ray:X-ray:Xavier:Xavier:X-ray
Y:Yankee:Yellow:Yorker:Yorker:Yoke/Yorker:Yoke:Yoke:York:Yaakov:Young
Z:Zulu:Zebra:Zebra:Zebra:Zebra:Zebra:Zebra:Zulmira:Zebedee:Zebra"

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
	esac

	if test "$1"
	then
		# Texto informado, vamos fazer a convers�o
		# Deixa uma letra por linha e procura seu c�digo equivalente
		echo $* |
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
# zzanatel
# http://sistemas.anatel.gov.br/SIPT/Atualizacao/N_ConsultaTarifas/tela.asp
# Busca as tarifas das operadoras no plano b�sico para liga��es DDD.
# Uso: zzanatel DDD_Origem Prefixo_Origem DDD_Destino Prefixo_Destino
# Ex.: zzanatel 48 3224 12 3943
#
# Autor: Rafael Machado Casali <rmcasali (a) gmail com>
# Desde: 2005-04-14
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzanatel ()
{
	zzzz -h anatel $1 && return

	[ "$1" ] || { zztool uso anatel; return; }
	
	local URL='http://sistemas.anatel.gov.br/SIPT/Atualizacao/N_ConsultaTarifas/tela.asp'
	
	case "`date +%u`" in
		0)
			PERIODO='d';;
		6)
			PERIODO='b';;
		*) 
			PERIODO='s';;
	esac
	echo "acao=c&pCNOrigem=$1&pPrefixoOrigem=$2&pCNDestino=$3&pPrefixoDestino=$4&pPeriodo=$PERIODO&pConsulta=2&LDN=true" |
	$ZZWWWPOST $URL |
	sed 's/[ ]*\([0-9][0-9]:\)/\1/g' |
	sed '/^[0-9]/!d'
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-09-02
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzansi2html ()
{
	zzzz -h ansi2html $1 && return
	
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
	" "$@"
	# Esse argumento serve para ler os dados de um arquivo (opcional)
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2001-07-23
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzarrumanome ()
{
	zzzz -h arrumanome $1 && return

	local arquivo caminho antigo novo recursivo pastas nao i

	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			-d) pastas=1    ;;
			-r) recursivo=1 ;;
			-n) nao="[-n] " ;;
			 *) break       ;;
		esac
		shift
	done
	
	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso arrumanome; return; }
	
	# Para cada arquivo que o usu�rio informou...
	for arquivo in "$@"
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
			return
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2002-12-06
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzascii ()
{
	zzzz -h ascii $1 && return

	local referencias decimais decimal hexa octal caractere
	local num_colunas=${1:-5}
	local largura=${2:-78}
	local linha=0
	
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-04-24
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzbeep ()
{
	zzzz -h beep $1 && return
	
	local minutos frequencia
	
	# Sem argumentos, apenas restaura a "configura��o de f�brica" do beep
	[ "$1" ] || {
		printf '\033[10;750]\033[11;100]\a'
		return
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
# zzblist
# Mostra se o IP passado est� em alguma blacklist  (SBL, PBL e XBL).
# Uso: zzblist IP
# Ex.: zzblist 200.199.198.197
#
# Autor: Vin�cius Ven�ncio Leite <vv.leite (a) gmail com>
# Desde: 2008-10-16
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzblist ()
{
	zzzz -h blist $1 && return

	[ "$1" ] || { zztool uso blist; return; }

	local URL="http://www.spamblock.com.br/rblcheck.php?ip="

	$ZZWWWDUMP "$URL"$1 | grep [Rr]elat.rio
	$ZZWWWDUMP "$URL"$1 | sed -n '/O IP /,/^$/p'
}
# ----------------------------------------------------------------------------
# zzbolsas
# http://br.finance.yahoo.com
# Pesquisa �ndices de bolsas e cota��es de a��es.
# Sem par�metros mostra a lista de bolsas dispon�veis (c�digos).
# Com o par�metro -l apenas mostra as bolsas dispon�veis e seus nomes.
# Com o par�metro sendo um c�digo de bolsa ou a��o mostra sua �ltima
# cota��o. Seguido de 1 ou 2 datas, pesquisa as cota��es nos dias.
# Com o par�metro sendo um c�digo de bolsa seguido de um texto qualquer
# pesquisa-o no nome ou c�digo das a��es dispon�ves na bolsa citada.
# Com o par�metro -l seguido do c�digo da bolsa, lista as a��es (c�digos).
# Com o par�metro --lista seguido do c�digo da bolsa, lista as a��es com
# nome e �ltima cota��o.
# Uso: zzbolsas [-l|--lista] [bolsa|a��o] [data1|pesquisa] [data2]
# Ex.: zzbolsas                  # Lista das bolsas (c�digos)
#      zzbolsas -l               # Lista das bolsas (nomes)
#      zzbolsas -l ^BVSP         # Lista as a��es do �ndice Bovespa (c�digo)
#      zzbolsas --lista ^BVSP    # Lista as a��es do �ndice Bovespa (nomes)
#      zzbolsas ^BVSP loja       # Procura a��es com "loja" no nome ou c�digo
#      zzbolsas ^BVSP            # Cota��o do �ndice Bovespa
#      zzbolsas PETR4.SA         # Cota��o das a��es da Petrobr�s
#      zzbolsas PETR4.SA 21/12/2010  # Cota��o da Petrobr�s nesta data
#
# Autor: Itamar <itamarnet (a) yahoo com br>
# Desde: 2009-10-04
# Vers�o: 4
# Licen�a: GPL
# Requisitos: zzmaiusculas
# ----------------------------------------------------------------------------
zzbolsas ()
{
	zzzz -h bolsas $1 && return

	local url='http://br.finance.yahoo.com'
	local dj='^DWC'
	local new_york='^NYA ^NYI ^NYY ^NY ^NYL'
	local nasdaq='^IXIC ^IXBK ^NBI ^IXK ^IXF ^IXID ^IXIS ^IXFN ^IXUT ^IXTR ^NDX'
	local sp='^GSPC ^OEX ^MID ^SPSUPX ^SML'
	local amex='^XAX ^IIX ^NWX ^XMI'
	local ind_nac='^IBX50 ^IVBX ^IGCX'
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
						sed 's/[0-9]*,*[0-9]*\.[0-9].*//g'|
						awk '{ printf " %-10s ", $1; for(i=2; i<=NF-1; i++) printf "%s ",$i; print $NF}'
				done
				zztool eco "\nDow Jones :"
				$ZZWWWDUMP "$url/usindices"|
					sed -n '/�ltima/,/_/p'|sed '/Componentes,/!d'|
					sed 's/[0-9]*,*[0-9]*\.[0-9].*//g'|
					awk '{ printf " %-10s ", $1; for(i=2; i<=NF-1; i++) printf "%s ",$i; print $NF}'
					printf " %-10s " "$dj";$ZZWWWDUMP "$url/q?s=$dj"|
					sed -n "/($dj)/p"|sed "s/^ *//;s/ *($dj)//"

				zztool eco "\nNYSE :"
				for bolsa in $new_york;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa"|
					sed -n "/($bolsa)/p"|sed "s/^ *//;s/ *($bolsa)//"
				done

				zztool eco "\nNasdaq :"
				for bolsa in $nasdaq;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa"|
					sed -n "/($bolsa)/p"|sed "s/^ *//;s/ *($bolsa)//"
				done

				zztool eco "\nStandard & Poors :"
				for bolsa in $sp;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa"|
					sed -n "/($bolsa)/p"|sed "s/^ *//;s/ *($bolsa)//"
				done

				zztool eco "\nAmex :"
				for bolsa in $amex;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa"|
					sed -n "/($bolsa)/p"|sed "s/^ *//;s/ *($bolsa)//"
				done

				zztool eco "\nOutros �ndices Nacionais :"
				for bolsa in $ind_nac;
				do
					printf " %-10s " "$bolsa";$ZZWWWDUMP "$url/q?s=$bolsa"|
					sed -n "/($bolsa)/p"|sed "s/^ *//;s/ *($bolsa)//"
				done
			;;
			*)
				bolsa=$(echo "$1"|zzmaiusculas)
				# �ltimo �ndice da bolsa citada
				if zztool grep_var "^" "$1"
				then
					$ZZWWWDUMP "$url/q?s=$bolsa"|
					sed -n "/($bolsa)/p;/Valor do �ndice:/,/Em 52 semanas:/p"|tr '.,' ',.' |
					sed '/As pessoas que viram/d' |
					sed '/Cota��es atrasadas. salvo indica��o/q'
					
				else
				# �ltima cota��o da a��o
					$ZZWWWDUMP "$url/q?s=$bolsa"|
					sed -n "/($bolsa)/p;/:$bolsa/p;/^ *$/d;/�ltima transa��o:/,/\[Chart\]/p"|
					sed "/\[Chart\]/d;s/.*(\(.*\):$bolsa.*$/\1/"|
					sed 's/^ */   /g;s/\([0-9]\+\),\([0-9]\+\)/\1�\2/g;s/\([0-9]\+\)\.\([0-9]\+\)/\1,\2/g;s/\([0-9]\+\)�\([0-9]\+\)/\1\.\2/g'|
					sed '/Varia��o do dia/,$s/: /:   /g' |
					sed '/Cota��es atrasadas, salvo indica��o/q'
					 #/Dividendos e rendimentos/p"
				fi
				;;
			esac
		;;
		2 | 3)
			# Lista as a��es de uma bolsa especificada
			if test "$1" = "-l" -o "$1" = "--lista" && zztool grep_var "^" "$2"
			then
				bolsa=$(echo "$2"|zzmaiusculas)
				pag_final=$($ZZWWWDUMP "$url/q/cp?s=$bolsa"|sed -n '/Primeiro/p;/Primeiro/q'|sed "s/^ *//g;s/.*of *\([0-9]\+\) .*/\1/")
				pags=$(echo "scale=0;($pag_final - 1) / 50"|bc)
				#pags=$((($pag_final-1)/50 ))
				for ((pag=0;pag<=$pags;pag++))
				do
					if test "$1" = "--lista"
					then
						# Listar as a��es com descri��o e suas �ltimas posi��es
						$ZZWWWDUMP "$url/q/cp?s=$bolsa&c=$pag"|
						sed -n 's/^ *//g;/S�mbolo /,/Primeiro/p'|
						sed '/S�mbolo /d;/Primeiro/d;/^[ ]*$/d' |
						sed '/^Tudo / q'
					else
						# Lista apenas os c�digos das a��es
						$ZZWWWDUMP "$url/q/cp?s=$bolsa&c=$pag"|
						sed -n 's/^ *//g;/S�mbolo /,/Primeiro/p'|
						sed '/S�mbolo /d;/Primeiro/d;/^[ ]*$/d'|
						awk '{printf "%s  ",$1}' |
						sed 's/Tudo  .*//'
						echo
					fi
				done
			
			# Valores de uma bolsa ou a��o em uma data especificada (hist�rico)
			elif zztool testa_data "$2" && zztool grep_var / "$2"
			then
				yyyy=${2##*/}
				mm=${2#*/}
				mm=${mm%/*}
				mm=$(echo "scale=0;${mm}-1"|bc)
				dd=${2%%/*}
				yyyy=$(echo "2*10^(3-${#yyyy})"|bc)$yyyy
				yyyy=${yyyy#0}
				data1="${dd}/$((${mm} + 1))/${yyyy}"
				bolsa=$(echo "$1"|zzmaiusculas)
					# Emprestando as variaves pag, pags e pag_atual efeito est�ico apenas
					pag=$($ZZWWWDUMP "$url/q/hp?s=$bolsa&a=${mm}&b=${dd}&c=${yyyy}&d=${mm}&e=${dd}&f=${yyyy}&g=d"|
					sed -n "/($bolsa)/p;/Data Abertura/,/* Pre�o/p"|sed 's/Data/    /;/* Pre�o/d'| 
					sed 's/^ */ /g')
					pags=$(echo "$pag" | sed -n '2p' | sed 's/ [A-Z]/\n\t&/g;s/Fechamento ajustado/Ajustado/'| sed '/^ *$/d' | awk '{printf "  %-12s\n", $1}')
					pag_atual=$(echo "$pag" | sed -n '3p' | sed 's/ [0-9]/\n&/g' | sed '/^ *$/d' | tr '.,' ',.' | awk '{printf " %14s\n", $1}')
					echo "$pag" | sed -n '1p'
					
					if zztool grep_var "/" "$3" && zztool testa_data "$3" && test $# -eq 3
					then
						yyyy=${3##*/}
						mm=${3#*/}
						mm=${mm%/*}
						mm=$(echo "scale=0;${mm}-1"|bc)
						dd=${3%%/*}
						yyyy=$(echo "2*10^(3-${#yyyy})"|bc)$yyyy
						yyyy=${yyyy#0}
						data2="${dd}/$((${mm} + 1))/${yyyy}"
						pag=$($ZZWWWDUMP "$url/q/hp?s=$bolsa&a=${mm}&b=${dd}&c=${yyyy}&d=${mm}&e=${dd}&f=${yyyy}&g=d"|
						sed -n "/($bolsa)/p;/Data Abertura/,/* Pre�o/p"|sed 's/Data/    /;/* Pre�o/d'| 
						sed 's/^ */ /g' | sed -n '3p' | sed 's/ [0-9]/\n&/g' | sed '/^ *$/d' |
						tr '.,' ',.'| awk '{printf " %14s\n", $1}')
						paste <(printf "  %-12s" "Data") <(echo "      $data1") <(echo "      $data2") <(echo "     Varia��o") <(echo "Var (%)")
						
						vartemp=$(while read data1 data2
						do
							echo "$data1 $data2"| 
							awk '{ printf "%13.2f\t", $2-$1; if ($1 != 0) {printf "%5.2f%", (($2-$1)/$1)*100}; print ""}' 2>/dev/null|
							tr '.' ','
						done < <(paste <(echo "$pag_atual"|tr -d '.'|tr ',' '.') <(echo "$pag"|tr -d '.'|tr ',' '.')))
						
						paste <(echo "$pags") <(echo "$pag_atual") <(echo "$pag") <(echo "$vartemp")
					else
						paste <(printf "  %-12s" "Data") <(echo "      $data1")
						paste <(echo "$pags") <(echo "$pag_atual")
					fi
			
			# Pesquisa o texto nas a��es (c�digo e nomes) de todas bolsas
			#elif test "$1" = "-p"
			#then
			#					
			# Pesquisa o texto nas a��es (c�digo e nomes) da bolsa atual
			else
				bolsa=$(echo "$1"|zzmaiusculas)
				pag_final=$($ZZWWWDUMP "$url/q/cp?s=$bolsa"|sed -n '/Primeiro/p;/Primeiro/q'|sed 's/^ *//g;s/.*of *\([0-9]\+\) .*/\1/')
				pags=$(echo "scale=0;($pag_final - 1) / 50"|bc)
				#pags=$((($pag_final-1)/50 ))
				for ((pag=0;pag<=$pags;pag++))
				do
					$ZZWWWDUMP "$url/q/cp?s=$bolsa&c=$pag"|
					sed -n 's/^ *//g;/S�mbolo /,/Primeiro/p'|
					sed '/S�mbolo /d;/Primeiro/d;/^[ ]*$/d'|
					grep -i "$2"
				done
			fi
			
		;;
		esac
	
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-03-01
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzbyte ()
{
	zzzz -h byte $1 && return

	local i i_entrada i_saida diferenca operacao passo falta
	local unidades='BKMGTPEZY' # kilo, mega, giga, etc
	local n=$1
	local entrada=${2:-B}
	local saida=${3:-.}
	
	# Sejamos amig�veis com o usu�rio permitindo min�sculas tamb�m
	entrada=$(echo $entrada | zzmaiusculas)
	saida=$(  echo $saida   | zzmaiusculas)

	# Verifica��es b�sicas
	if ! zztool testa_numero $n
	then
		zztool uso byte
		return
	fi
	if ! zztool grep_var $entrada "$unidades"
	then
		echo "Unidade inv�lida '$entrada'"
		return
	fi
	if ! zztool grep_var $saida ".$unidades"
	then
		echo "Unidade inv�lida '$saida'"
		return
	fi
	
 	# Extrai os n�meros (�ndices) das unidades de entrada e sa�da
	i_entrada=$(zztool index_var $entrada $unidades)
	i_saida=$(  zztool index_var $saida   $unidades)
		
	# Sem $3, a unidade de sa�da ser� otimizada
	[ $i_saida -eq 0 ] && i_saida=15

	# A diferen�a entre as unidades guiar� os c�lculos
	diferenca=$((i_saida - i_entrada))
	if [ $diferenca -lt 0 ]
	then
	 	operacao='*'
	 	passo='-'
	else
		operacao='/'
		passo='+'
	fi
	
	i=$i_entrada
	while [ $i -ne $i_saida ]
	do
		# Sa�da autom�tica (sem $3)
		# Chegamos em um n�mero menor que 1024, hora de sair
		[ $n -lt 1024 -a $i_saida -eq 15 ] && break
		
		# N�o ultrapasse a unidade m�xima (Yota)
		[ $i -eq ${#unidades} -a $passo = '+' ] && break
		
		# 0 < n < 1024 para unidade crescente, por exemplo: 1 B K
		# � hora de dividir com float e colocar zeros � esquerda
		if [ $n -gt 0 -a $n -lt 1024 -a $passo = '+' ]
		then
			# Quantos d�gitos ainda faltam?
			falta=$(( (i_saida - i - 1) * 3))
						
			# Pulamos direto para a unidade final
			i=$i_saida
			
			# C�lculo preciso usando o bc (Retorna algo como .090)
			n=$(echo "scale=3; $n / 1024" | bc)
			[ $n = '0' ] && break # 1 / 1024 = 0

			# Completa os zeros que faltam
			[ $falta -gt 0 ] && n=$(printf "%0.${falta}f%s" 0 ${n#.})
			
			# Coloca o zero na frente, caso necess�rio
			[ "${n#.}" != "$n" ] && n=0$n
			
			break
		fi
		
		# Terminadas as exce��es, este � o processo normal
		# Aumenta/diminui a unidade e divide/multiplica por 1024
		eval "i=$((i $passo 1))"
		eval "n=$((n $operacao 1024))"
	done
	
	# Mostra o resultado
	echo $n$(echo $unidades | cut -c$i)
}
# ----------------------------------------------------------------------------
# zzcalcula
# Calculadora.
# Os operadores principais s�o + - / * ^ %, veja outros em "man bc".
# Obs.: N�meros fracionados podem vir com v�rgulas ou pontos: 1,5 ou 1.5.
# Uso: zzcalcula n�mero opera��o n�mero
# Ex.: zzcalcula 2,20 + 3.30          # v�rgulas ou pontos, tanto faz
#      zzcalcula '2^2*(4-1)'          # 2 ao quadrado vezes 4 menos 1
#      echo 2 + 2 | zzcalcula         # lendo da entrada padr�o (STDIN)
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-04
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcalcula ()
{
	zzzz -h calcula $1 && return
	
	local parametros=$(zztool multi_stdin "$@")

	# Entrada de n�meros com v�rgulas ou pontos, sa�da sempre com v�rgulas
	echo "scale=2;$parametros" | sed y/,/./ | bc | sed y/./,/
}
# ----------------------------------------------------------------------------
# zzcalculaip
# Calcula os endere�os de rede e broadcast � partir do IP e m�scara da rede.
# Obs.: Se n�o for especificado a m�scara, � assumido a 255.255.255.0.
# Uso: zzcalculaip ip [netmask]
# Ex.: zzcalculaip 127.0.0.1 24
#      zzcalculaip 10.0.0.0/8
#      zzcalculaip 192.168.10.0 255.255.255.240
#      zzcalculaip 10.10.10.0
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2005-09-01
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcalculaip ()
{
	zzzz -h calculaip $1 && return

	local endereco mascara rede broadcast
	local mascara_binario mascara_decimal mascara_ip
	local i ip1 ip2 ip3 ip4 nm1 nm2 nm3 nm4 componente

	# Verifica��o dos par�metros
	[ $# -eq 0 -o $# -gt 2 ] && { zztool uso calculaip; return; }

	# Obt�m a m�scara da rede (netmask)
	if zztool grep_var / "$1"
	then
		endereco=${1%/*}
		mascara="${1#*/}"
	else
		endereco=$1
		mascara=${2:-24}
	fi

	# Verifica��es b�sicas
	if ! zztool testa_ip $endereco
	then
		echo "IP inv�lido: $endereco"
		return
	fi
	if ! (zztool testa_ip $mascara || (
	      zztool testa_numero $mascara && test $mascara -le 32))
	then
		echo "M�scara inv�lida: $mascara"
		return
	fi

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
	if ! (zztool testa_binario $mascara_binario &&
	      test ${#mascara_binario} -eq 32)
	then
		echo 'M�scara inv�lida'
		return
	fi
	
	mascara_decimal=$(echo $mascara_binario | tr -d 0)
	mascara_decimal=${#mascara_decimal}
	mascara_ip="$((2#$nm1)).$((2#$nm2)).$((2#$nm3)).$((2#$nm4))"
	
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
# zzcarnaval
# Mostra a data da ter�a-feira de Carnaval para qualquer ano.
# Obs.: Se o ano n�o for informado, usa o atual.
# Regra: 47 dias antes do domingo de P�scoa.
# Uso: zzcarnaval [ano]
# Ex.: zzcarnaval
#      zzcarnaval 1999
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-23
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcarnaval ()
{
	zzzz -h carnaval $1 && return

	local ano="$1"

	# Se o ano n�o for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Verifica��o b�sica
	if ! zztool testa_numero $ano
	then
		zztool uso carnaval
		return
	fi

	# Ah, como � f�cil quando se tem as ferramentas certas ;)
	zzdata $(zzpascoa $ano) - 47
}
# ----------------------------------------------------------------------------
# zzcbn
# http://cbn.globoradio.com.br
# Busca e toca os �ltimos coment�rios dos comentaristas da radio CBN.
# Uso: zzcbn [-mp3] [-c COMENTARISTA] [-d data]  ou  zzcbn -lista
# Ex.: zzcbn -c max -d ontem
#      zzcbn -c mauro -d tudo 
#      zzcbn -c juca -d 13/05/09
#      zzcbn -c miriam
#      zzcbn -mp3 -c max  
#
# Autor: Rafael Machado Casali <rmcasali (a) gmail com>
# Desde: 2009-04-16
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcbn ()
{
	zzzz -h cbn $1 && return
	
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
[ "$1" ] || { zztool uso cbn; return; }

if [ "$1" == "-lista" ]
then
  for i in $COMENTARISTAS
  do
     echo `echo $i | cut -d';' -f1`
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
			-mp3)
				EXT="mp3"
				MP3="http://download3.globo.com/sgr-$EXT/cbn/"
				;;
			*) 
				zzecho -l vermelha "Op��o inv�lida!!"
				return
				;;
		esac
		shift
	done

	linha=`echo $COMENTARISTAS | tr ' ' '\n' | sed  "/$comentarista/!d"`
        autor=`echo $linha | cut -d';' -f 3`
#        [ "$data" ] || data=`LANG=en.US date "+%d %b %Y"`
#	echo "$RSS`echo $linha | cut -d';' -f 2`.xml"
	$ZZWWWHTML "$RSS`echo $linha | cut -d';' -f 2`.xml"  | sed -n "/title/p;/pubDate/p" | sed "s/.*A\[\(.*\)]].*/\1/g" | sed "s/.*>\(.*\)<\/.*/\1/g" | sed "2d" > /tmp/comentarios
	
	zzecho -l ciano `cat /tmp/comentarios | sed -n '1p'`

	case  "$data" in 
		"ontem")
			datafile=`date -d "yesterday" +%y%m%d`
		        data=`LANG=en date -d "yesterday" "+%d %b %Y"`
			cat /tmp/comentarios | sed -n "/$data/{H;x;p;};h" > /tmp/coment
		;;
	 	"tudo")
			cat /tmp/comentarios | sed '1d' > /tmp/coment
		;;
		"")
			datafile=`date '+%y%m%d'`
		        data=`LANG=en date "+%d %b %Y"`
			cat /tmp/comentarios | sed -n "/$data/{H;x;p;};h" > /tmp/coment
		;;
		*)
			if ! ( zztool testa_data "$data" || zztool testa_numero "$data" )
                        then
                                echo "Data inv�lida '$data', deve ser dd/mm/aaaa"
                                return
                        fi
     			data="`echo $data | sed 's/\([0-9]*\)\/\([0-9]*\)\/\([0-9]*\)/\3-\2-\1/g'`"
			datafile=`date -d $data +%y%m%d`
		        data=`LANG=en date -d $data "+%d %b %Y"`
			cat /tmp/comentarios | sed -n "/$data/{H;x;p;};h" > /tmp/coment


	esac
	Tlinhas=`cat /tmp/coment| sed -n '$='`
	[ "$Tlinhas" ] ||  { zzecho -l vermelho "Sem coment�rios"; return; } 
	for ((l=1;$l<=$Tlinhas;l=$l+2))
	do
		P=`expr $l + 1`
		titulo=`cat /tmp/coment| sed "$l!d"`
		data=`cat /tmp/coment| sed "$P!d"`
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
	rm /tmp/comentarios
	rm /tmp/coment
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
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzchavepgp ()
{
	zzzz -h chavepgp $1 && return

	local url='http://pgp.mit.edu:11371'
	local padrao=$(echo $*| sed "$ZZSEDURL")

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso chavepgp; return; }

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
# Vers�o: 2
# Licen�a: GPLv2
# ----------------------------------------------------------------------------
zzchecamd5 ()
{

	# Variaveis locais
	local arquivo valor_md5 md5_site

	# Help da funcao zzchecamd5
	zzzz -h checamd5 $1 && return

	# Faltou argumento mostrar como se usa a zzchecamd5
	if [ "$#" != "2" ];then
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
	valor_md5="`md5sum $arquivo | cut -d' ' -f1`"
	md5_site=$2

	# Verifica se o arquivo nao foi corrompido
	if [ "$md5_site" = "$valor_md5" ]; then
		echo "Imagem OK" 
	else
		echo "O md5sum nao confere!!"
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-12-15
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcinclude ()
{
	zzzz -h cinclude $1 && return
	
	local arquivo="$1"
	
	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso cinclude; return; }

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
# zzcinemais
# http://www.cinemais.com.br
# Busca hor�rios das sess�es dos filmes no site do Cinemais.
# Cidades dispon�veis:
#   Anapolis               -  32
#   Cuiaba                 -  10
#   Guaratingueta          -  21
#   Milenium               -  29
#   Manaus Plaza           -  20
#   Marilia                -  17
#   Patos de Minas         -  11
#   Ribeirao Preto         -  13
#   Sao Jose do Rio Preto  -  30
#   Sertaozinho            -  28
#   Tangara da Serra       -  12
#   Uberaba                -   9
#   Uberlandia             -   8
#
# Uso: zzcinemais [cidade]
# Ex.: zzcinemais Uberaba
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-08-25
# Vers�o: 5
# Licen�a: GPLv2
# ----------------------------------------------------------------------------
zzcinemais ()
{
	zzzz -h cinemais $1 && return
	
	[ "$1" ] || { zztool uso cinemais; return; }
	
	local codigo cidade sessoes

	cidade=$(echo $* | sed 's/ /_/g')

	case "$cidade" in
		Anapolis)
			codigo=32
			zztool eco "An�polis-GO:"
		;;
		Cuiaba)
			codigo=10
			zztool eco "Cuiab�-MT:"
		;;
		Guaratingueta)
			codigo=21
			zztool eco "Guaratinguet�-SP:"
		;;
		Milenium)
			codigo=29
			zztool eco "Milenium-AM:"
		;;
		Manaus_Plaza)
			codigo=20
			zztool eco "Manaus Plaza-AM:"
		;;
		Marilia)
			codigo=17
			zztool eco "Mar�lia-SP:"
		;;
		Patos_de_Minas)
			codigo=11
			zztool eco "Pato de Minas-MG:"
		;;
		Sao_Jose_do_Rio_Preto)
			codigo=13
			zztool eco "S�o Jos� do Rio Preto-SP:"
		;;
		Sertaozinho)
			codigo=28
			zztool eco "Sert�ozinho-SP:"
		;;
		Tangara_da_Serra)
			codigo=12
			zztool eco "Tangar� da Serra-SP:"
		;;
		Uberaba)
			codigo=9
			zztool eco "Uberaba-SP:"
		;;
		Uberlandia)
			codigo=8
			zztool eco "Uberl�ndia-SP:"
		;;
		*)
			echo "Cidade n�o cadastrada. Use a op��o -h para ver a lista de cidades."
			return
		;;
	esac

	sessoes=$(
			$ZZWWWHTML "http://www.cinemais.com.br/programacao/cinema.php?cod=$codigo" | 
			iconv --from-code=ISO-8859-1 --to-code=ISO-8859-1 |
			grep -A 5 '+[1-8]<' | 
			sed 's/<[^>]*>//g;s/^[ \t]*//g'
		)

	hora=`date +%Hh%M | cut -d'h' -f1`
	minuto=`date +%Hh%M | cut -d'h' -f2`
 
	for i in $sessoes; do 
		if [[ $i =~ \+[1-8] ]]; then 
			echo -ne "\n $i | " 
		elif [[ $i =~ Liv\.|[0-9][0-9]a  ]]; then
			echo -ne "\033[G\033[24C| $i |      -  "
		elif [[ $i =~ Dub|Leg  ]]; then
			echo -ne "\033[G\033[31C| $i  "
		elif [[ $i =~ [0-9][0-9][h][0-9][0-9] ]];then 
			ih=`echo $i | cut -d'h' -f1`
			im=`echo $i | cut -d'h' -f2 | sed 's/,//g;s/[A-K]//g' | tr -d '\015'`

			if [ "$hora" -lt "$ih"  ];then
				zzecho -n -l verde -N "$i "
			elif [ "$hora" -eq "$ih" -a "$minuto" -lt "$im" ];then
				zzecho -n -l verde -N "$i "
			else
				zzecho -n -l vermelho -N "$i "
			fi
		elif [[ $i =~ Obs ]]; then
			echo -ne "\n$i "
		else
			echo -ne "$i "
		fi
	done

	echo
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
# Autor: Aur�lio ou Thobias
# Desde: 2004-12-23
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcnpj ()
{
	zzzz -h cnpj $1 && return

	local i n somatoria digito1 digito2 cnpj base

	# Aten��o:
	# Essa fun��o � irm�-quase-g�mea da zzcpf, que est� bem
	# documentada, ent�o n�o vou repetir aqui os coment�rios.
	#
	# O c�lculo dos d�gitos verificadores tamb�m � id�ntico,
	# apenas com uma m�scara num�rica maior, devido � quantidade
	# maior de d�gitos do CNPJ em rela��o ao CPF.

	cnpj="$(echo $* | tr -d -c 0123456789)"
	
	if [ "$cnpj" ]
	then
		# CNPJ do usu�rio

		if [ ${#cnpj} -ne 14 ]
		then
			echo 'CNPJ inv�lido (deve ter 14 d�gitos)'
			return
		fi

		base=${cnpj%??}
	else
		# CNPJ gerado aleatoriamente

		while [ ${#cnpj} -lt 8 ]
		do
			cnpj="$cnpj$((RANDOM % 9))"
		done

		cnpj="${cnpj}0001"
		base=$cnpj
	fi

	# C�lculo do d�gito verificador 1

	set - $(echo $base | sed 's/./& /g')

	somatoria=0
	for i in 5 4 3 2 9 8 7 6 5 4 3 2
	do
		n=$1
		somatoria=$((somatoria + (i * n)))
		shift
	done

	digito1=$((11 - (somatoria % 11)))
	[ $digito1 -ge 10 ] && digito1=0

	# C�lculo do d�gito verificador 2

	set - $(echo $base | sed 's/./& /g')
	
	somatoria=0
	for i in 6 5 4 3 2 9 8 7 6 5 4 3 2
	do
		n=$1
		somatoria=$((somatoria + (i * n)))
		shift
	done
	somatoria=$((somatoria + digito1 * 2))

	digito2=$((11 - (somatoria % 11)))
	[ $digito2 -ge 10 ] && digito2=0

	# Mostra ou valida o CNPJ
	if [ ${#cnpj} -eq 12 ]
	then
		echo $cnpj$digito1$digito2 |
		 	sed 's|\(..\)\(...\)\(...\)\(....\)|\1.\2.\3/\4-|'
	else
		if [ "${cnpj#????????????}" = "$digito1$digito2" ]
		then
			echo CNPJ v�lido
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
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2003-10-02
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcontapalavra ()
{
	zzzz -h contapalavra $1 && return

	local padrao ignora
	local inteira=1
	
	# Op��es de linha de comando
	while [ "${1#-}" != "$1" ]
	do
		case "$1" in
			-p) inteira=  ;;
			-i) ignora=1  ;;
			 *) break     ;;
		esac
		shift
	done

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso contapalavra; return; }
	
	padrao=$1
	shift
	
	# Contorna a limita��o do grep -c pesquisando pela palavra
	# e quebrando o resultado em uma palavra por linha (tr).
	# Ent�o pode-se usar o grep -c para contar.
	grep -h ${ignora:+-i} ${inteira:+-w} -- "$padrao" "$@" |
		tr '\t./ -,:-@[-_{-~' '\n' |
		grep -c ${ignora:+-i} ${inteira:+-w} -- "$padrao"
}
# ----------------------------------------------------------------------------
# zzconverte
# Faz v�rias convers�es como: caracteres, temperatura e dist�ncia.
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
#          dh = (D)ecimal      para (H)exadecimal
#          hd = (H)exadecimal  para (D)ecimal
# Uso: zzconverte <cf|fc|ck|kc|fk|kf|mk|km|db|bd|cd|dh|hd> n�mero
# Ex.: zzconverte cf 5
#      zzconverte dc 65
#      zzconverte db 32
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2003-10-02
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzconverte ()
{
	zzzz -h converte $1 && return

	local s2='scale=2'
	local operacao=$1
	
	# Verifica��o dos par�metros
	[ "$2" ] || { zztool uso converte; return; }
	
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
			;;
			mk)
			 	echo "$1 milhas = $(echo "$s2;$1*1.609"   | bc) km"
			;;
			db)
			 	echo "obase=2;$1" | bc -l
			;;
			bd)
			 	echo "$((2#$1))"
			;;
			cd)
			 	echo -n "$1" |
			 		od -d |
			 		tr -s '\t ' ' ' |
					cut -d' ' -f2- |
					sed 's/ *$// ; 1q'
			;;
			dc)
			 	awk "BEGIN { printf(\"%c\n\", $1) }"
			
				# XXX " TextMate syntax gotcha (n�o remover)
			;;
			dh)
				printf '%X\n' "$1"
			;;
			hd)
				printf '%d\n' "0x$1"
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2001-12-11
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcores ()
{
	zzzz -h cores $1 && return

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
# Licen�a: GPL
# Requisitos: zzdata, zzpascoa
# ----------------------------------------------------------------------------
zzcorpuschristi ()
{
        zzzz -h corpuschristi $1 && return

        local ano="$1"

        # Se o ano n�o for informado, usa o atual
        test -z "$ano" && ano=$(date +%Y)

        # Verifica��o b�sica
        if ! zztool testa_numero $ano
        then
                zztool uso corpuschristi
                return
        fi

        # Ah, como � f�cil quando se tem as ferramentas certas ;)
        # e quando j� temos o c�digo e s� precisamos mudar os numeros
        # tambem � bom :D ;)
        zzdata $(zzpascoa $ano) + 60
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
# Autor: Aur�lio ou Thobias
# Desde: 2004-12-23
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzcpf ()
{
	zzzz -h cpf $1 && return

	local i n somatoria digito1 digito2 cpf base

	# Remove pontua��o do CPF informado, deixando apenas n�meros
	cpf="$(echo $* | tr -d -c 0123456789)"
	
	# Extrai os n�meros da base do CPF:
	# Os 9 primeiros, sem os dois d�gitos verificadores.
	# Esses dois d�gitos ser�o calculados adiante.
	if [ "$cpf" ]
	then
		# Faltou ou sobrou algum n�mero...
		if [ ${#cpf} -ne 11 ]
		then
			echo 'CPF inv�lido (deve ter 11 d�gitos)'
			return
		fi
		
		# Apaga os dois �ltimos d�gitos
		base=${cpf%??}
	else
		# N�o foi informado nenhum CPF, vamos gerar um escolhendo
		# nove d�gitos aleatoriamente para formar a base
		while [ ${#cpf} -lt 9 ]
		do
			cpf="$cpf$((RANDOM % 9))"
		done
		base=$cpf
	fi
	
	# Truque para cada d�gito da base ser guardado em $1, $2, $3, ...
	set - $(echo $base | sed 's/./& /g')

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
		n=$1
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
	set - $(echo $base | sed 's/./& /g')
	# Passo 1
	somatoria=0
	for i in 11 10 9 8 7 6 5 4 3
	do
		n=$1
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
		echo $cpf$digito1$digito2 |
		 	sed 's/\(...\)\(...\)\(...\)/\1.\2.\3-/' # nnn.nnn.nnn-nn
	else
		# Esse CPF foi informado pelo usu�rio.
		# Compara os verificadores informados com os calculados.
		if [ "${cpf#?????????}" = "$digito1$digito2" ]
		then
			echo CPF v�lido
		else
			# Boa a��o do dia: mostrar quais os verificadores corretos
			echo "CPF inv�lido (deveria terminar em $digito1$digito2)"
		fi
	fi
}
# ----------------------------------------------------------------------------
# zzdata
# Faz c�lculos com datas e/ou converte data->num e num->data.
# Que dia vai ser daqui 45 dias? Quantos dias h� entre duas datas? zzdata!
# Quando chamada com apenas um par�metro funciona como conversor de data
# para n�mero inteiro (N dias passados desde Epoch) e vice-versa.
# Obs.: Leva em conta os anos bissextos     (Epoch = 01/01/1970, edit�vel)
# Uso: zzdata data|num [+|- data|num]
# Ex.: zzdata 22/12/1999 + 69
#      zzdata hoje - 5
#      zzdata 01/03/2000 - 11/11/1999
#      zzdata hoje - dd/mm/aaaa         <---- use sua data de nascimento
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2003-02-07
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdata ()
{
	zzzz -h data $1 && return

	local yyyy mm dd dias_ano data dias i n y op
	local epoch=1970
	local primeira_data=1
	local dias_mes='31 28 31 30 31 30 31 31 30 31 30 31'
	local data1=$1
	local operacao=$2
	local data2=$3
	local n1=$data1
	local n2=$data2

	# Refer�ncias para ano bissexto:
	#
	# A year is a leap year if it is evenly divisible by 4
	# ...but not if it's evenly divisible by 100
	# ...unless it's also evenly divisible by 400
	# http://timeanddate.com
	# http://www.delorie.com/gnu/docs/gcal/gcal_34.html
	
	# Verifica��o dos par�metros
	[ $# -eq 3 -o $# -eq 1 ] || { zztool uso data; return; }

	# Esse bloco gigante define $n1 e $n2 baseado nas datas $data1 e $data2.
	# A data � transformada em um n�mero inteiro (dias desde $epoch).
	# Exemplo: 27/07/2007 -> 13721
	# Este � numero usado para fazer os c�lculos.
	for data in $data1 $data2
	do
		dias=0 # Guarda o total que ir� para $n1 e $n2
		
		# Atalhos �teis para o dia atual
		if [ "$data" = 'hoje' -o "$data" = 'today' ]
		then
			# Qual a data de hoje?
			data=$(date +%d/%m/%Y)
			[ "$primeira_data" ] && data1=$data || data2=$data
		else
			# Valida o formato da data
			if ! ( zztool testa_data "$data" || zztool testa_numero "$data" )
			then
				echo "Data inv�lida '$data', deve ser dd/mm/aaaa"
				return
			fi
		fi
		
		# Se tem /, ent�o � uma data e deve ser transformado em n�mero
		if zztool grep_var / "$data"
		then
			n=1
			y=$epoch
			yyyy=${data##*/}
			mm=${data#*/}
			mm=${mm%/*}
			dd=${data%%/*}

			# Retira o zero dos dias e meses menores que 10
			mm=${mm#0}
			dd=${dd#0}

			# Define qual ser� a opera��o: adi��o ou subtra��o
			op=+
			[ $yyyy -lt $epoch ] && op=-
			
			# Ano -> dias
			while :
			do
				# Sim, os anos bissextos s�o levados em conta!
				dias_ano=365
				[ $((y%4)) -eq 0 ] && [ $((y%100)) -ne 0 ] || [ $((y%400)) -eq 0 ] && dias_ano=366
				
				# Vai somando (ou subtraindo) at� chegar no ano corrente
				[ $y -eq $yyyy ] && break
				dias=$((dias $op dias_ano))
				y=$((y $op 1))
			done
			
			# Meses -> dias
			for i in $dias_mes
			do
				[ $n -eq $mm ] && break
				n=$((n+1))
				
				# Fevereiro de ano bissexto tem 29 dias
				[ $dias_ano -eq 366 -a $i -eq 28 ] && i=29
				
				dias=$((dias+$i))
			done
			
			# Somando os dias da data aos anos+meses j� contados (-1)
			dias=$((dias+dd-1))
			
			[ "$primeira_data" ] && n1=$dias || n2=$dias
		fi
		primeira_data=
	done
	
	# Agora que ambas as datas s�o n�meros inteiros, a conta � feita
	dias=$(($n1 $operacao $n2))
	
	# Se as duas datas foram informadas como dd/mm/aaaa,
	# o resultado � o pr�prio n�mero de dias, ent�o terminamos.
	if [ "${data1##??/*}" = "${data2##??/*}" ]
	then
		echo $dias
		return
	fi
	
	# Como n�o ca�mos no IF anterior, ent�o o resultado ser� uma data.
	# � preciso converter o n�mero inteiro para dd/mm/aaaa.
	
	y=$epoch
	mm=1
	dd=$((dias+1))
	
	# Dias -> Ano
	while :
	do
		# Novamente, o ano bissexto � levado em conta
		dias_ano=365
		[ $((y%4)) -eq 0 ] && [ $((y%100)) -ne 0 ] || [ $((y%400)) -eq 0 ] && dias_ano=366
		
		# Vai descontando os dias de cada ano para saber quantos anos cabem
		[ $dd -le $dias_ano ] && break
		dd=$((dd-dias_ano))
		y=$((y+1))
	done
	yyyy=$y
	
	# Dias -> m�s
	for i in $dias_mes
	do
		# Fevereiro de ano bissexto tem 29 dias
		[ $dias_ano -eq 366 -a $i -eq 28 ] && i=29
	
		# Calcula quantos meses cabem nos dias que sobraram
		[ $dd -le $i ] && break
		dd=$((dd-i))
		mm=$((mm+1))
	done
	
	# Restaura o zero dos meses menores que 10
	[ $dd -le 9 ] && dd=0$dd
	[ $mm -le 9 ] && mm=0$mm
	
	# E finalmente mostra o resultado em formato de data
	echo $dd/$mm/$yyyy
}
# ----------------------------------------------------------------------------
# zzdatabarras
# Transforma data do formato DDMMYYYY para DD/MM/YYYY.
# Op��es:
#   -d, --data     data no formato DDMMYYYY.
#   -v, --verbose  exibe informa��es para debug durante o processamento.
# Uso: zzdatabarras -d data
# Ex.: zzdatabarras -d 28012010               # resposta: "28/01/2010"
#
# Autor: Lauro Cavalcanti de Sa <lauro (a) ecdesa com>
# Desde: 2010-01-28
# Vers�o: 20100128
# Licen�a: GPLv2
# ----------------------------------------------------------------------------
zzdatabarras ()
{
	#set -x
	
	zzzz -h databarras $1 && return
	
	# Declara variaveis.
	local data_barras_1 data_barras_2 data_barras_3 data_barras_4
	
	# Opcoes de linha de comando
	while [ $# -ge 1 ]
	do
		case "$1" in
			-d | --data)
				[ "$2" ] || { zztool uso databarras; return; }
				data=$2
				shift
				;;
			-v | --verbose)
				set -x
				;;
			*)
				zztool uso databarras
				set +x
				return 1
				;;
		esac
		shift
	done
	
	if [ ${#data} -ne 8 ]
	then
		zztool uso databarras
		set +x
		return 1
	fi
	
	data_barras_1=`echo ${data} | cut -c1-2`
	data_barras_2=`echo ${data} | cut -c3-4`
	data_barras_3=`echo ${data} | cut -c5-8`
	data_barras_4=`echo ${data} | cut -c9-`
	echo "${data_barras_1}/${data_barras_2}/${data_barras_3}${data_barras_4}"

}
# ----------------------------------------------------------------------------
# zzdefine
# http://www.google.com
# Retorno da fun��o "define:" do Google.
# Idiomas dispon�veis: en pt es de fr it. O idioma padr�o � "all".
# Uso: zzdefine [idioma] palavra_ou_sigla
# Ex.: zzdefine imho
#      zzdefine pt imho
#
# Autor: Fernando Aires <fernandoaires (a) gmail com>
# Desde: 2005-05-23
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdefine ()
{
	zzzz -h define $1 && return

	[ "$1" ] || { zztool uso define; return; }
	
	local L='all' I='en pt es de fr it all '

	[ "${I% $1 *}" != "$I" ] && L=$1 && shift

	$ZZWWWDUMP -width=78 "http://www.google.com/search?q=define:$1&hl=pt-br&ie=ISO-8859-1&defl=$L" |
		sed '1, /^ *Web$/ d' |
		sed '/Encontrar defini��es de imho em:/,$ d' |
		sed '/P�gina Inicial do Google/,$ d'
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
	zzzz -h definr $1 && return

	[ "$1" ] || { zztool uso definr; return; }
	
	local word="$@"

	word=$(echo $word | sed 's/ /%20/g')

	$ZZWWWHTML "http://definr.com/$word" |
		sed '
			/<div id="meaning">/,/<\/div>/!d
			s/<[^>]*>//g
			s/&nbsp;/ /g
			/^$/d'
}
# ----------------------------------------------------------------------------
# zzdelicious
# Lista as URLs de uma dada tag de um determinado usu�rio.
# Obs.: Se n�o informada a tag, ser�o listadas as �ltimas URLs.
# Uso: zzdelicious usuario [tag]
# Ex.: zzdelicious felipensp
#      zzdelicious felipensp php
#
# Autor: Felipe Nascimento Silva Pena <felipensp (a) gmail com>
# Desde: 2007-12-04
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdelicious ()
{
	zzzz -h delicious $1 && return

 	[ "$1" ] || { zztool uso delicious; return; }

 	$ZZWWWHTML "http://www.delicious.com/$1/$2" |
		grep 'taggedlink' |
		sed '
			# Deixa como: http://... Nome do link
			s/.*href="//
			s/" >/ /
			s|</a>||
			
			# Inverte a ordem e quebra a linha
			s/^\([^ ]*\) \(.*\)/\2\
\1\
/'
}
# ----------------------------------------------------------------------------
# zzdetransp
# http://www.detran.sp.gov.br
# Consulta d�bitos do ve�culo, como licenciamento, IPVA e multas (Detran-SP).
# Uso: zzdetransp n�mero-renavam
# Ex.: zzdetransp 123456789
#
# Autor: Elton Sim�es Baptista <elton (a) inso com br>
# Desde: 2001-12-06
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdetransp ()
{
	zzzz -h detransp $1 && return

	local url='http://www.detran.sp.gov.br/multas-site/detran/resultMultas.asp'

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso detransp; return; }
	
	# Faz a consulta e filtra o resultado
	echo "renavam=$1&submit=Pesquisar" |
		$ZZWWWPOST "$url" |
		sed '
			1d
			s/^  *//
			/^\[/d
			/^Esta pesquisa tem /, $ d'
}
# ----------------------------------------------------------------------------
# zzdiadasemana
# Mostra qual o dia da semana de uma data qualquer.
# Obs.: Se a data n�o for informada, usa a data atual.
# Uso: zzdiadasemana [data]
# Ex.: zzdiadasemana
#      zzdiadasemana 31/12/2000
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-24
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdiadasemana ()
{
	zzzz -h diadasemana $1 && return

	local delta dia
	local dias="quinta- sexta- s�bado domingo segunda- ter�a- quarta-"
	local data="$1"

	# Se a data n�o foi informada, usa a atual
	test -z "$data" && data=$(date +%d/%m/%Y)

	# Valida o formato da data
	if ! zztool testa_data "$data"
	then
		echo "Data inv�lida '$data', deve ser dd/mm/aaaa"
		return
	fi

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

	# O cut tem �ndice inicial um e n�o zero, por isso dia+1
	echo $dias |
	 	cut -d ' ' -f $((dia+1)) |
	 	sed 's/-/-feira/'
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2001-08-08
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdicasl ()
{
	zzzz -h dicasl $1 && return

	local opcao_grep
	local url='http://www.dicas-l.com.br/arquivo/'

	# Guarda as op��es para o grep (caso informadas)
	[ "${1##-*}" ] || {
		opcao_grep=$1
		shift
	}

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dicasl; return; }

	# Faz a consulta e filtra o resultado
	zztool eco "$url"
	$ZZWWWHTML "$url" |
		zztool texto_em_iso |
		grep -i $opcao_grep "$*" |
		sed -n 's@^<LI><A HREF=/arquivo/\([^>]*\)> *\([^ ].*\)</A>@\1@p'
}
# ----------------------------------------------------------------------------
# zzdicbabelfish
# http://babelfish.altavista.digital.com
# Faz tradu��es de palavras/frases/textos entre idiomas.
# Basta especificar quais os idiomas de origem e destino e a frase.
# Obs.: Se os idiomas forem omitidos, a tradu��o ser� ingl�s -> portugu�s.
#
# Idiomas: pt_en pt_fr es_en es_fr it_en it_fr de_en de_fr
#          fr_en fr_de fr_el fr_it fr_pt fr_nl fr_es
#          ja_en ko_en zh_en zt_en el_en el_fr nl_en nl_fr ru_en
#          en_zh en_zt en_nl en_fr en_de en_el en_it en_ja
#          en_ko en_pt en_ru en_es
#
# Uso: zzdicbabelfish [idiomas] palavra(s)
# Ex.: zzdicbabelfish my dog is green
#      zzdicbabelfish pt_en falc�o � massa
#      zzdicbabelfish en_de my hovercraft if full of eels
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdicbabelfish ()
{
	zzzz -h dicbabelfish $1 && return
	
	local padrao
	local url='http://babelfish.yahoo.com/translate_txt'
	local extra='ei=ISO-8859-1&eo=ISO-8859-1&doit=done&fr=bf-home&intl=1&tt=urltext'
	local lang=en_pt

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dicbabelfish; return; }

	if [ "${1#[a-z][a-z]_[a-z][a-z]}" = '' ]
	then
		lang=$1
		shift
	elif [ "$1" = 'i' ]
	then
		lang=pt_en
		shift
	fi

	padrao=$(echo "$*" | sed "$ZZSEDURL")
	$ZZWWWHTML "$url?$extra&trtext=$padrao&lp=$lang" |
		sed -n '
			/<div id="result">/ {
		 		s/<[^>]*>//g
				s/^ *//p
			}'
}
# ----------------------------------------------------------------------------
# zzdicbabylon
# http://www.babylon.com
# Tradu��o de UMA PALAVRA em ingl�s para v�rios idiomas.
# Franc�s, alem�o, japon�s, italiano, hebreu, espanhol, holand�s e portugu�s.
# Se nenhum idioma for informado, o padr�o � o portugu�s.
# Uso: zzdicbabylon [idioma] palavra   #idioma:dut fre ger heb ita jap ptg spa
# Ex.: zzdicbabylon hardcore
#      zzdicbabylon jap tree
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdicbabylon ()
{
	zzzz -h dicbabylon $1 && return

	local idioma='ptg'
	local idiomas=' dut fre ger heb ita jap ptg spa '
	local tab=$(echo -e \\t)

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dicbabylon; return; }
	
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
# zzdicesperanto
# http://wwwtios.cs.utwente.nl/traduk/
# Dicion�rio de Esperanto em ingl�s, portugu�s e alem�o.
# Possui busca por palavra nas duas dire��es. O padr�o � portugu�s-esperanto.
# Uso: zzdicesperanto [idioma] palavra
# Ex.: zzdicesperanto disquete
#      zzdicesperanto EO-PT espero
#
# Autor: Fernando Aires <fernandoaires (a) gmail com>
# Desde: 2005-05-20
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdicesperanto ()
{
	zzzz -h dicesperanto $1 && return

	[ "$1" ] || { zztool uso dicesperanto; return; }
	
	local L='PT-EO'
	local I='DE-EO EN-EO EO-DE EO-EN EO-PT PT-EO '

	[ "${I% $1 *}" != "$I" ] && L=$1 && shift

	$ZZWWWDUMP "http://wwwtios.cs.utwente.nl/traduk/$L/Traduku/?$1" |
		grep -v ^THE_ |
		grep -v ___ |
		grep -v /cxefpagxo\] |
		grep -v Traduku:\ $1
}
# ----------------------------------------------------------------------------
# zzdicjargon
# http://catb.org/jargon/
# Dicion�rio de jarg�es de inform�tica, em ingl�s.
# Uso: zzdicjargon palavra(s)
# Ex.: zzdicjargon vi
#      zzdicjargon all your base are belong to us
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdicjargon ()
{
	zzzz -h dicjargon $1 && return
	
	local achei achei2 num mais
	local url='http://catb.org/jargon/html'
	local cache="$ZZTMP.jargonfile"
	local padrao=$(echo "$*" | sed 's/ /-/g')

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dicjargon; return; }

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
# Uso: zzdicportugues palavra
# Ex.: zzdicportugues bolacha
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2003-02-26
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdicportugues ()
{
	zzzz -h dicportugues $1 && return

	local url='http://dicio.com.br/pesquisa.php'
	local ini='^Significado de '
	local fim='^Defini��o de '
	local padrao=$(echo $* | sed "$ZZSEDURL")

	# TODO XXX N�o consegui fazer funcionar com palavras acentuadas :(
	# O site � iso-8859-1.
	# padrao="ma��"
	# padrao=$(echo ma�� | iconv -f utf-8 -t iso-8859-1)
	# padrao='ma&ccedil;&agrave;'
	# padrao='ma%E7%E3'
	# ZZWWWDUMP='lynx -dump -nolist -width=300 -accept_all_cookies -assume_unrec_charset=iso-8859-1'

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dicportugues; return; }

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
# zzdictodos
# Usa todas as fun��es de dicion�rio e tradu��o de uma vez.
# Uso: zzdictodos palavra
# Ex.: zzdictodos Linux
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdictodos ()
{
	zzzz -h dictodos $1 && return

	local dic
	
	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dictodos; return; }
	
	for dic in babelfish babylon jargon portugues
	do
		zztool eco "zzdic$dic:"
		zzdic$dic $1
	done
}
# ----------------------------------------------------------------------------
# zzdiffpalavra
# Mostra a diferen�a entre dois textos, palavra por palavra.
# �til para conferir revis�es ortogr�ficas ou mudan�as pequenas em frases.
# Obs.: Se tiver muitas *linhas* diferentes, use o comando diff.
# Uso: zzdiffpalavra arquivo1 arquivo2
# Ex.: zzdiffpalavra texto-orig.txt texto-novo.txt
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2001-07-23
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdiffpalavra ()
{
	zzzz -h diffpalavra $1 && return
	
	local esc
 	local tmp1="$ZZTMP.diffpalavra.1.$$"
	local tmp2="$ZZTMP.diffpalavra.2.$$"
	local n=$(printf '\a')

	# Verifica��o dos par�metros
	[ $# -ne 2 ] && { zztool uso diffpalavra; return; }

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
# http://br.invertia.com
# Busca a cota��o do dia do d�lar (comercial, paralelo e turismo).
# Obs.: As cota��es s�o atualizadas de 10 em 10 minutos.
# Uso: zzdolar
# Ex.: zzdolar
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdolar ()
{
	zzzz -h dolar $1 && return

	# Faz a consulta e filtra o resultado
	$ZZWWWDUMP 'http://br.invertia.com/mercados/divisas/tiposdolar.aspx' |
		sed '
			# Voc� acredita que essa sopa de letrinhas funciona?
			# Pois �, eu tamb�m n�o... Mas funciona :)

			s/^ *//
			/Data:/,/Turismo/!d
			/percent/d
			s/  */ /g
			s/.*Data: \(.*\)/\1 compra   venda   hora/
			s|^[1-9]/|0&|
			s@^\([0-9][0-9]\)/\([0-9]/\)@\1/0\2@
			s/^D.lar //
			s/- Corretora//
			s/ SP//g
			s/ [-+]\{0,1\}[0-9.,]\{1,\}  *%$//
			s/al /& /
			s/lo /&   /
			s/mo /&	/
			s/ \([0-9]\) / \1.000 /
			s/\.[0-9]\>/&0/g
			s/\.[0-9][0-9]\>/&0/g
			/^[^0-9]/s/[0-9] /&  /g
			/Var\.%/d
			s/Turismo../Turismo     /' |
		sed '/^Compra/d'
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-15
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdominiopais ()
{
	zzzz -h dominiopais $1 && return

	local url='http://www.iana.org/root-whois/index.html'
	local cache="$ZZTMP.dominiopais"
	local cache_sistema='/usr/share/zoneinfo/iso3166.tab'
	local padrao=$1

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dominiopais; return; }
	
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
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzdos2unix ()
{
	zzzz -h dos2unix $1 && return

	local arquivo
	local tmp="$ZZTMP.dos2unix.$$"

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dos2unix; return; }
	
	for arquivo in "$@"
	do
		# O arquivo existe?
		zztool arquivo_legivel "$arquivo" || continue
		
		# Remove o famigerado CR \r ^M
		cp "$arquivo" "$tmp" &&
		tr -d '\015' < "$tmp" > "$arquivo"
		
		# Seguran�a
		if [ $? -ne 0 ]
		then
			echo "Ops, algum erro ocorreu em $arquivo"
			echo "Seu arquivo original est� guardado em $tmp"
			return
		fi
		
		# Remove a permiss�o de execu��o, comum em arquivos DOS
		chmod -x "$arquivo"
		
 		echo "Convertido $arquivo"
	done
	
	# Remove o arquivo tempor�rio
	rm "$tmp"
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
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzecho ()
{
	zzzz -h echo $1 && return

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
		 			*) zztool uso echo; return ;;
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
					branco	  ) fundo='47' ;;
					*) zztool uso echo; return ;;
				esac
				shift
			;;
			-N|--negrito    ) negrito=';1'    ;;
			-p|--pisca      ) pisca=';5'      ;;
			-s|--sublinhado ) sublinhado=';4' ;;
			-n|--nao-quebra ) quebra_linha='' ;;
			*) zztool uso echo; return ;;
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
 	zzzz -h english $1 && return

	[ "$1" ] || { zztool uso english; return; }
	
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
	zzzz -h enviaemail $1 && return
	
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
# zzeuro
# http://cotacoes.agronegocios-e.com.br/
# Busca a cota��o atual do EURO com rela��o ao D�lar e ao Real.
# Uso: zzeuro
# Ex.: zzeuro
#
# Autor: Kyller Costa Gorg�nio <kyllercg (a) gmail com>
# Desde: 2006-01-10
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzeuro ()
{
	zzzz -h euro $1 && return

	$ZZWWWDUMP 'http://cotacoes.agronegocios-e.com.br/investimentos/conteudoi.asp?option=dolar&title=%20Euro' |
		sed '
			s/^ *//
			/Compra/,/Euro x D/!d
			/^D.*/d
			s/Compra/                 Compra/g'
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
# Vers�o: 20101222
# Licen�a: GPLv2
# ----------------------------------------------------------------------------
zzextensao ()
{
	zzzz -h extensao $1 && return
	
	# Declara variaveis.
	local nome_arquivo extensao arquivo
	
	[ "$1" ] || zztool uso extensao

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
# Vers�o: 4
# Licen�a: GPLv2
# ----------------------------------------------------------------------------
zzferiado ()
{
	zzzz -h feriado $1 && return

	local feriados carnaval corpuschristi
	local hoje data sextapaixao ano listar
	local dia diasemana descricao LINHA
	local pulaparacoluna22

	hoje=$(date '+%d/%m/%Y')

	# Verifica se foi passado o par�metro -l
	if [ "$1" = "-l" ]; then
		# Se n�o for passado $2 pega o ano atual
		ano=${2:-$(basename $hoje)}

		# Seta a flag listar
		listar=1

		# Teste da vari�vel ano
		if ! zztool testa_numero $ano; then
			zztool uso feriado
			return
		fi
	else
		# Se n�o for passada a data � pega a data de hoje
		data=${1:-$hoje}

		# Verifica se a data � valida
		if ! zztool testa_data $data; then
        	        zztool uso feriado
        	        return 
        	fi

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

		# Vari�vel que contem os caracteres de controle para que a listagem
		# possa sair formatada corretamente
		pulaparacoluna22="\033[22G"

		# Pega os dados, coloca 1 por linha, inverte dd/mm para mm/dd,
		# ordena, inverte mm/dd para dd/mm
		echo $feriados |
                sed '   
                        s# \([0-3]\)#\n\1#g
                        s#\(..\)/\(..\)#\2/\1#g
                ' |
                sort -n |
                sed 's#\(..\)/\(..\)#\2/\1#g' |
		while read LINHA; do
			dia=$(echo $LINHA | cut -d: -f1)
			diasemana=$(zzdiadasemana $dia/$ano)
			descricao=$(echo $LINHA | cut -d: -f2)
			echo -e "$dia $diasemana $pulaparacoluna22 $descricao"
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
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzfoneletra ()
{
	zzzz -h foneletra $1 && return

	# Um Sed faz tudo, � uma tradu��o letra a letra
	zztool multi_stdin "$@" |
	 	zzmaiusculas |
	 	sed y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/
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
	zzzz -h frenteverso2pdf $1 && return
	
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
				[ "$2" ] || { zztool uso frenteverso2pdf; return; }
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-09-20
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzfreshmeat ()
{
	zzzz -h freshmeat $1 && return
	
	local url='http://freshmeat.net/search/'
	local padrao=$1
	
	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso freshmeat; return; }
	
	# Faz a consulta e filtra o resultado
	$ZZWWWLIST "$url?q=$padrao" |
		sed -n 's@.*\(http://freshmeat.net/projects/.*\)@\1@p' |
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
# Vers�o: 1.3
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzglobo ()
{
	zzzz -h globo $1 && return

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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2003-04-03
# Licen�a: GPL
# ----------------------------------------------------------------------------
# FIXME: zzgoogle rato roeu roupa rei roma [PPS], [PDF]
zzgoogle ()
{
	zzzz -h google $1 && return

	local padrao
	local limite=10
	local url='http://www.google.com.br/search'

	# Op��es de linha de comando
	if [ "$1" = '-n' ]
	then
		limite=$2
		shift; shift
	fi

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso google; return; }

	# Prepara o texto a ser pesquisado
	padrao=$(echo "$*" | sed "$ZZSEDURL")
	[ "$padrao" ] || return 0
	
	# Pesquisa, baixa os resultados e filtra
	#
	# O Google condensa tudo em um �nica longa linha, ent�o primeiro � preciso
	# inserir quebras de linha antes de cada resultado. Identificadas as linhas
	# corretas, o filtros limpa os lixos e formata o resultado.
	
	$ZZWWWHTML "$url?q=$padrao&num=$limite&ie=ISO-8859-1&oe=ISO-8859-1&hl=pt-BR" |
		sed 's/<h3 class="r">/\
@/g' |
		sed '
			/^@<a href="\([^"]*\)" class=l>/!d
			s/^@<a href="//
			s/" class=l>/ /
			s/<\/a>.*//
			
			# Remove tags HTML
			s/<[^>]*>//g
			
			# Restaura os caracteres especiais
			s/&gt;/>/g
			s/&lt;/</g
			s/&quot;/"/g
			s/&nbsp;/ /g
			s/&amp;/\&/g
			
			s/\([^ ]*\) \(.*\)/\2\
  \1\
/'
}
# ----------------------------------------------------------------------------
# zzhora
# Faz c�lculos com hor�rios.
# A op��o -r torna o c�lculo relativo � primeira data, por exemplo:
#   02:00 - 03:30 = -01:30 (sem -r) e 22:30 (com -r)
# Uso: zzhora [-r] hh:mm [+|- hh:mm]
# Ex.: zzhora 8:30 + 17:25        # preciso somar duas horas!
#      zzhora 12:00 - agora       # quando falta para o almo�o?
#      zzhora -12:00 + -5:00      # horas negativas!
#      zzhora 1000                # quanto � 1000 minutos?
#      zzhora -r 5:30 - 8:00      # que horas ir dormir para acordar �s 5:30?
#      zzhora -r agora + 57:00    # e daqui 57 horas, ser� quando?
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzhora ()
{
	zzzz -h hora $1 && return

	local hhmm1 hhmm2 operacao
	local hh1 mm1 hh2 mm2 n1 n2 resultado negativo
	local horas minutos dias horas_do_dia hh mm hh_dia extra
	local relativo=0

	# Op��es de linha de comando
	if [ "$1" = '-r' ]
	then
		relativo=1
		shift
	fi
	
	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso hora; return; }
	
	# Dados informados pelo usu�rio (com valores padr�o)
	hhmm1="$1"
	operacao="${2:-+}"
	hhmm2="${3:-00}"

	# Somente adi��o e subtra��o s�o permitidas
	if [ "${operacao#[+-]}" ]
	then
	 	echo "Opera��o Inv�lida: $operacao"
		return
	fi
	
	# Atalhos bacanas para a hora atual
	[ "$hhmm1" = 'agora' -o "$hhmm1" = 'now' ] && hhmm1=$(date +%H:%M)
	[ "$hhmm2" = 'agora' -o "$hhmm2" = 'now' ] && hhmm2=$(date +%H:%M)
	
	# Se as horas n�o foram informadas, coloca 00
	[ "${hhmm1#*:}" = "$hhmm1" ] && hhmm1=00:$hhmm1
	[ "${hhmm2#*:}" = "$hhmm2" ] && hhmm2=00:$hhmm2
	
	# Extrai horas e minutos para vari�veis separadas
	hh1=${hhmm1%:*}
	mm1=${hhmm1#*:}
	hh2=${hhmm2%:*}
	mm2=${hhmm2#*:}
	
	# Retira o zero das horas e minutos menores que 10
	hh1=${hh1#0}
	mm1=${mm1#0}
	hh2=${hh2#0}
	mm2=${mm2#0}
	
	# Os c�lculos s�o feitos utilizando apenas minutos.
	# Ent�o � preciso converter as horas:minutos para somente minutos.
	n1=$((hh1*60+mm1))
	n2=$((hh2*60+mm2))
	
	# Tudo certo, hora de fazer o c�lculo
	resultado=$(($n1 $operacao $n2))
	
	# Resultado negativo, seta a flag e remove o sinal de menos "-"
	if [ $resultado -lt 0 ]
	then
	 	negativo=-
		resultado=${resultado#-}
	fi
	
	# Agora � preciso converter o resultado para o formato hh:mm

	horas=$((resultado/60))
	minutos=$((resultado%60))
	dias=$((horas/24))
	horas_do_dia=$((horas%24))
	
	# Restaura o zero dos minutos/horas menores que 10
	hh=$horas
	mm=$minutos
	hh_dia=$horas_do_dia
	[ $hh -le 9 ] && hh=0$hh
	[ $mm -le 9 ] && mm=0$mm
	[ $hh_dia -le 9 ] && hh_dia=0$hh_dia
	
	#TODO: usar um exemplo com horas negativas
	# Decide como mostrar o resultado para o usu�rio.
	#
	# Relativo:
	#   $ zzhora -r 10:00 + 48:00
	#   10:00 (2 dias)
	#
	# Normal:
	#   $ zzhora 10:00 + 48:00
	#   58:00 (2d 10h 0m)
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
			mm=$minutos

			# Zeros para dias e minutos menores que 10
			[ $mm -le 9 ] && mm=0$mm
			[ $hh_dia -le 9 ] && hh_dia=0$hh_dia
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
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzhoracerta ()
{
	zzzz -h horacerta $1 && return

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
		return
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
# Vers�o: 2
# Licen�a: GPLv2
# ----------------------------------------------------------------------------
zzhoramin ()
{

	zzzz -h horamin $1 && return

	local mintotal hh mm hora operacao

	operacao='+'

	# Testa se o par�metro passado � uma hora valida
	if ! zztool testa_hora ${1#-}; then
                hora=$(zzhora agora | cut -d' ' -f1)
        else
                hora=$1
        fi

	# Verifica se a hora � positiva ou negativa
	if [ "${hora#-}" != "$hora" ]; then
		operacao='-'
	fi

	# passa a hora para hh e minuto para mm
	hh=${hora%%:*}
	mm=${hora##*:}

	# faz o c�lculo
	mintotal=$(expr $hh \* 60 $operacao $mm)

	# Tchar�!!!!
	echo $mintotal

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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-24
# Licen�a: GPL
# Requisitos: zzcarnaval, zzdata, zzdiadasemana
# ----------------------------------------------------------------------------
zzhorariodeverao ()
{
	zzzz -h horariodeverao $1 && return

	local inicio fim data domingo_carnaval
	local dias_3a_semana="15 16 17 18 19 20 21"
	local ano="$1"

	# Se o ano n�o for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Verifica��o b�sica
	if ! zztool testa_numero $ano
	then
		zztool uso horariodeverao
		return
	fi

	# S� de 2008 em diante...
	if test $ano -lt 2008
	then
		echo 'Antes de 2008 n�o havia regra fixa para o hor�rio de ver�o'
		return
	fi

	# Encontra os dias de in�cio e t�rmino do hor�rio de ver�o.
	# Sei que o algoritmo n�o � eficiente, mas � simples de entender.
	#
	for dia in $dias_3a_semana
	do
		data=$dia/10/$ano
		test $(zzdiadasemana $data) = 'domingo' && inicio=$data

		data=$dia/02/$((ano+1))
		test $(zzdiadasemana $data) = 'domingo' && fim=$data
	done

	# Exce��o � regra: Se o domingo de t�rmino do hor�rio de ver�o
	# coincidir com o Carnaval, adia o t�rmino para o pr�ximo domingo.
	#
	domingo_carnaval=$(zzdata $(zzcarnaval $((ano+1)) ) - 2)
	test $fim = $domingo_carnaval && fim=$(zzdata $fim + 7)

	# Datas calculadas, basta mostrar o resultado
	echo $inicio
	echo $fim
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
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzhowto ()
{
	zzzz -h howto $1 && return

	local padrao
	local cache="$ZZTMP.howto"
	local url='http://www.ibiblio.org/pub/Linux/docs/HOWTO/other-formats/html_single/'

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso howto; return; }

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
		$ZZWWWHTML "$url" |
			sed -n '/alt="\[TXT\]"/ {
				s/^.*href="\([^"]*\).*/\1/
				p
			}' > "$cache"
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
# http://www.whatismyip.com
# Mostra o seu n�mero IP (externo) na Internet.
# Uso: zzipinternet
# Ex.: zzipinternet
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2005-09-01
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzipinternet ()
{
	zzzz -h ipinternet $1 && return

	local url='http://whatismyip.com/automation/n09230945.asp'

	# O resultado j� vem pronto!
	$ZZWWWHTML "$url"
	echo
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
# Vers�o: 1
# Licen�a: GPL
# Requisitos: GNU sed
# ----------------------------------------------------------------------------
zzjquery ()
{
	zzzz -h jquery $1 && return

	local er
	local er1="s/\s*<h1>\([\$.]*$2(.*\)<\/h1>\s*/- \1/p;"
	local er2="
		/\s*<h1>\([\$.]*$1(.*\)<\/h1>/ {
			s//\1:/p
			n
			s/\s*<p>\|<\/p>/ /g
			p
			n
			:a
			/<\/\?p>\|<h2>/! {
				s/^\s*/  /g
				p
				n
				ba
			}
		}"
	
	[ "$1" = '-s' ] && er="$er1" || er="$er2"

	$ZZWWWHTML "http://visualjquery.com/1.1.2.html" | sed -nu "$er"
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-15
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzkill ()
{
	zzzz -h kill $1 && return

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
			return
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-22
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzlembrete ()
{
	zzzz -h lembrete $1 && return

	local arquivo="$HOME/.zzlembrete"
	local tmp="$ZZTMP.lembrete.$$"
	local numero

	# Assegura-se que o arquivo de lembretes existe
	test -f "$arquivo" || touch "$arquivo"

	# Sem argumentos, mostra todos os lembretes
	if test -z "$1"
	then
		cat -n "$arquivo"

	# Tem argumentos, que podem ser para mostrar, apagar ou adicionar
	elif echo "$*" | tr -s '\t ' ' ' | grep '^ *[0-9]\{1,\} *d\{0,1\} *$' >/dev/null
	then
		# Extrai o n�mero da linha
		numero=$(echo $* | tr -d -c 0123456789)

		if zztool grep_var d "$*"
		then
			# zzlembrete 5d: Apaga linha 5
		        cp "$arquivo" "$tmp" &&
		 	sed "${numero:-0} d" "$tmp" > "$arquivo" || {
			        echo "Ops, deu algum erro no arquivo $arquivo"
			        echo "Uma c�pia dele est� em $tmp"
			        return
			}
		else
			# zzlembrete 5: Mostra linha 5
			cat "$arquivo" | sed -n "$numero p"
		fi
	else
		# zzlembrete texto: Adiciona o texto
		echo "$*" >> "$arquivo" || {
			echo "Ops, n�o consegui adicionar esse lembrete"
			return
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-04-24
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzlimpalixo ()
{
	zzzz -h limpalixo $1 && return

	local comentario='#'

	# Reconhecimento de coment�rios do Vim
	case "$1" in
		*.vim | *.vimrc*)
			comentario='"'
		;;
	esac

	# Remove coment�rios e linhas em branco
	cat "${@:--}" |
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2004-12-23
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzlinha ()
{
	zzzz -h linha $1 && return

	local arquivo n padrao resultado num_linhas

	# Op��es de linha de comando
	if [ "$1" = '-t' ]
	then
		padrao="$2"
		shift; shift
	fi
	
	# Talvez o $1 � o n�mero da linha desejada?
	if zztool testa_numero_sinal "$1"
	then
		n=$1
		shift
	fi

	if [ "$n" ]
	then
		# Se foi informado um n�mero, mostra essa linha.
		# Nota: Suporte a m�ltiplos arquivos e entrada padr�o (STDIN)
		for arquivo in "${@:--}"
		do
			# O arquivo existe?
			zztool arquivo_legivel "$arquivo" || continue
			
			if [ "$n" -lt 0 ]
			then
				tail -n ${n#-} "$arquivo" | sed 1q
			else
				sed -n ${n}p "$arquivo"
			fi
		done
	else
		# TODO: usar zztool multi_stdin e arquivo_legivel
		
		# Se foi informado um padr�o (ou nenhum argumento),
		# primeiro grepa as linhas, depois mostra uma linha
		# aleat�ria deste resultado.
		# Nota: Suporte a m�ltiplos arquivos e entrada padr�o (STDIN)
		resultado=$(grep -h -i -- "${padrao:-.}" "${@:--}")
		num_linhas=$(echo "$resultado" | sed -n '$=')
		n=$(( (RANDOM % num_linhas) + 1))
		[ $n -eq 0 ] && n=1
		echo "$resultado" | sed -n ${n}p
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
	zzzz -h linux $1 && return

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
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzlinuxnews ()
{
	zzzz -h linuxnews $1 && return

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
		$ZZWWWHTML "$url" |
			sed -n '1,/<entry>/d;s@.*<title>\(.*\)</title>@\1@p' |
			$limite
	fi

	# Slashdot
	if zztool grep_var s "$sites"
	then
		url='http://rss.slashdot.org/Slashdot/slashdot'
		echo
		zztool eco "* SlashDot ($url):"
		$ZZWWWHTML "$url" |
			sed '/<title>/!d ; s@.*<title>@@ ; s@</title>.*@@p' |
			uniq |
			$limite
	fi

	# Linux Today
	if zztool grep_var t "$sites"
	then
		url='http://linuxtoday.com/backend/biglt.rss'
		echo
		zztool eco "* Linux Today ($url):"
		$ZZWWWHTML "$url" |
			sed -n '1,/<item>/d;s@.*<title>\(.*\)</title>@\1@p' |
			$limite
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
		url='http://osnews.com'
		echo
		zztool eco "* OS News - ($url):"
		$ZZWWWDUMP "$url" |
			sed -n '/^ *By /{g;s/^ *//;p;};h' |
			$limite
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2005-06-30
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzlocale ()
{
	zzzz -h locale $1 && return
	
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
	[ "$1" ] || { zztool uso locale; return; }
	
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2004-05-18
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzloteria ()
{
	zzzz -h loteria $1 && return

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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2001-08-28
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzmaiores ()
{
	zzzz -h maiores $1 && return

	local pastas recursivo modo
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
# Uso: zzmaiusculas [arquivo]
# Ex.: zzmaiusculas /etc/passwd
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2003-06-12
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzmaiusculas ()
{
	zzzz -h maiusculas $1 && return
	
	sed '
		y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/
	 	y/�������������������������/�������������������������/' "$@"
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
# Vers�o: 3
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzminiurl ()
{
	zzzz -h miniurl $1 && return
	
	[ "$1" ] || { zztool uso miniurl; return; }
	
	local url="$1"
	local prefixo='http://'
	
	# Se o usu�rio n�o informou o protocolo, adiciona o padr�o
	echo "$url" | egrep '^(https?|ftp|mms)://' >/dev/null || url="$prefixo$url"
	
   	curl "http://migre.me/api.txt?url=$url" 2> /dev/null |
		sed 's/IP:.*//'
}
# ----------------------------------------------------------------------------
# zzminusculas
# Converte todas as letras para min�sculas, inclusive acentuadas.
# Uso: zzminusculas [arquivo]
# Ex.: echo N�O ESTOU GRITANDO | zzminusculas
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2003-06-12
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzminusculas ()
{
	zzzz -h minusculas $1 && return
	
	sed '
		y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
	 	y/�������������������������/�������������������������/' "$@"
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2004-03-29
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzmoeda ()
{
	zzzz -h moeda $1 && return

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
			/[0-9][0-9]$/!d
			
			# Apaga varia��o (deixa apenas varia��o-%)
			s/\(.*\) -\{0,1\}[0-9][0-9]*,[0-9]\{4\}/\1/
			
			# Adiciona '-' nas colunas vazias de compra
			/[0-9][,.][0-9]\{4\}.*[0-9][,.][0-9]\{4\}/!s/[0-9][0-9]*[,.][0-9]\{4\}/-  &/

			# Tira espa�o da sigla do Peso Mexicano (MXP 24H)
			s/ \([24][48]H\) /-\1 /

			# Separa os campos por @, do fim ao in�cio da linha
			s/  */ /g
			s/\(.*\) /\1@/
			s/\(.*\) /\1@/
			s/\(.*\) /\1@/
			s/\(.*\) /\1@/
			s/\(.*\) /\1@/
			
			# Manda o nome da moeda l� pro final da linha
			# No in�cio desalinha, o printf %s conta UTF errado
			s/\([^@]*\)@\(.*\)/\2@\1/
			
			# Espa�os viram _ para n�o atrapalharem
			y/ /_/' |
		tr @ \\t |
		grep -i "$padrao"
	)
	
	# Pescamos algo?
	[ "$dados" ] || return
	
	# Sim! Ent�o formate uma tabela bonitinha com o resultado
	formato='%-7s %12s %12s %6s %11s  %s'

	printf "$formato\n" Sigla Compra Venda Var.% Hora Moeda
	
	echo "$dados" |
		while read linha
		do
			printf "$formato\n" $linha | tr _ ' '
		done
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
	
	zzzz -h mudaprefixo $1 && return
	
	# Verifica numero minimo de parametros.
	if [ $# -lt 4 ] ; then
		{ zztool uso mudaprefixo; return; }
	fi
	
	# Declara variaveis.
	local antigo novo n_sufixo_ini sufixo
	
	# Opcoes de linha de comando
	while [ $# -ge 1 ]
	do
		case "$1" in
			-a | --antigo)
				[ "$2" ] || { zztool uso mudaprefixo; return; }
				antigo=$2
				shift
				;;
			-n | --novo)
				[ "$2" ] || { zztool uso mudaprefixo; return; }
				novo=$2
				shift
				;;
			*) { zztool uso mudaprefixo; return; } ;;
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
# zznatal
# http://www.ibb.org.br/vidanet
# A mensagem "Feliz Natal" em v�rios idiomas.
# Uso: zznatal [palavra]
# Ex.: zznatal                   # busca um idioma aleat�rio
#      zznatal russo             # Feliz Natal em russo
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2004-12-23
# Licen�a: GPL
# ----------------------------------------------------------------------------
zznatal ()
{
	zzzz -h natal $1 && return

	local url='http://www.ibb.org.br/vidanet/outras/msg239.htm'
	local cache="$ZZTMP.natal"
	local padrao=$1

	# Se o cache est� vazio, baixa listagem da Internet
	if ! test -s "$cache"
	then
		$ZZWWWDUMP "$url" | sed '
			/^      /!d
			/\[/d
			s/^  *//
			/^Outras/d
			s/^(/Chin�s  &/
			s/  */: /' > "$cache"
	fi

	# Mostra uma linha qualquer (com o padr�o, se informado)
	echo -n '"Feliz Natal" em '
	zzlinha -t "${padrao:-.}" "$cache"
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2004-11-10
# Licen�a: GPL
# ----------------------------------------------------------------------------
zznomefoto ()
{
	zzzz -h nomefoto $1 && return
	
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
	[ "$1" ] || { zztool uso nomefoto; return; }

	if ! zztool testa_numero "$digitos"
	then
		echo "N�mero inv�lido para a op��o -d: $digitos"
		return
	fi
	if ! zztool testa_numero "$i"
	then
		echo "N�mero inv�lido para a op��o -i: $i"
		return
	fi
	
	# Para cada arquivo que o usu�rio informou...
	for arquivo in "$@"
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2001-12-17
# Licen�a: GPL
# ----------------------------------------------------------------------------
zznoticiaslinux ()
{
	zzzz -h noticiaslinux $1 && return

	local url limite
	local n=5
	local sites='byvucin'

	limite="sed ${n}q"
	
	[ "$1" ] && sites="$1"
	
	# Yahoo
	if zztool grep_var y "$sites"
	then
		url='http://br.news.yahoo.com/tecnologia/linux'
		echo
		zztool eco "* Yahoo Linux ($url):"
		$ZZWWWHTML "$url" |
			sed -n '
				/topheadline/ {
					n
					s,</a>.*,,
					s/<[^>]*>//gp
				}
				/^      <a href=/ s/<[^>]*>//gp' |
			sed 's/^[[:blank:]]*//' |
			zztool texto_em_utf8 |
			$limite
	fi
	
	# Viva o Linux
	if zztool grep_var v "$sites"
	then
		url='http://www.vivaolinux.com.br'
		echo
		zztool eco "* Viva o Linux ($url):"
		
		# TODO Em alguns sistemas as not�cias v�m gzipadas, tendo que
		# abrir com gzip -d. Reportado por Rodrigo Azevedo.
		
		$ZZWWWHTML "$url/index.rdf" |
			sed -n '1,/<item>/d;s@.*<title>\(.*\)</title>@\1@p' |
			zztool texto_em_utf8 |
			$limite
	fi
	
	# Br Linux
	if zztool grep_var b "$sites"
	then
		url='http://br-linux.org/feed/'
		echo
		zztool eco "* BR-Linux ($url):"
		$ZZWWWHTML "$url" |
			sed -n '1,/<item>/d ; s/.*<title>// ; s@</title>@@p' |
			sed 's/&#822[01];/"/g ; s/&#8211;/-/g' |
			zztool texto_em_utf8 |
			$limite
	fi
	
	# UnderLinux
	if zztool grep_var u "$sites"
	then
		url='http://feeds.feedburner.com/underlinux'
		echo
		zztool eco "* UnderLinux ($url):"
		$ZZWWWHTML "$url" |
			sed -n '1,/<item>/d ; s/.*<title>// ; s@</title>@@p' |
			zztool texto_em_utf8 |
			$limite
	fi
	
	# Not�cias Linux
	if zztool grep_var n "$sites"
	then
		url='http://www.noticiaslinux.com.br'
		echo
		zztool eco "* Not�cias Linux ($url):"
		$ZZWWWHTML "$url" |
			sed -n '/<[hH]3>/{s/<[^>]*>//g;s/^[[:blank:]]*//g;p;}' |
			zztool texto_em_iso |
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
# Licen�a: GPL
# ----------------------------------------------------------------------------
zznoticiassec ()
{
	zzzz -h noticiassec $1 && return

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
			sed -n '/item/,$ s@.*<title>\(.*\)</title>@\1@p' |
			zztool texto_em_iso |
			$limite
	fi

	# Linux Security
	if zztool grep_var s "$sites"
	then
		url='http://www.linuxsecurity.com/linuxsecurity_advisories.rdf'
		echo
		zztool eco "* Linux Security ($url):"
		$ZZWWWHTML "$url" |
			sed -n '/item/,$ s@.*<title>\(.*\)</title>@\1@p' |
			$limite
	fi

	# CERT/CC
	if zztool grep_var c "$sites"
	then
		url='http://www.us-cert.gov/channels/techalerts.rdf'
		echo
		zztool eco "* CERT/CC ($url):"
		$ZZWWWHTML "$url" |
			sed -n '/item/,$ s@.*<title>\(.*\)</title>@\1@p' |
			$limite
	fi

	# Linux Today - Security
	if zztool grep_var t "$sites"
	then
		url='http://linuxtoday.com/security/index.html'
		echo
		zztool eco "* Linux Today - Security ($url):"
		$ZZWWWHTML "$url" |
			sed -n '/class="nav"><B>/s/<[^>]*>//gp' |
			$limite
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
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzora ()
{ 
	zzzz -h ora $1 && return

	[ $# != 1 ] && zztool uso ora && return 1 # deve receber apenas um argumento
	! zztool testa_numero "$1" && zztool uso ora && return 1 # e este argumento deve ser num�rico

	local url="http://ora-$1.ora-code.com"

	$ZZWWWDUMP "$url" | sed '
		s/  //g
		s/^ //g
		/Subject Replies/,$d
		1,5d
		s/^Cause:/\nCause:/g
		s/^Action:/\nAction:/g
		/Google Search/,$d
		/^o /d
		/\[1.gif\]/,$d
		s/^$*//'
	
	return 0
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-10-23
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzpascoa ()
{
	zzzz -h pascoa $1 && return

	local dia mes a b c d e f g h i k l m p q
	local ano="$1"

	# Se o ano n�o for informado, usa o atual
	test -z "$ano" && ano=$(date +%Y)

	# Verifica��o b�sica
	if ! zztool testa_numero $ano
	then
		zztool uso pascoa
		return
	fi

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
	zzzz -h piada $1 && return
	$ZZWWWDUMP 'http://www.xalexandre.com.br/piadasAleiatorias/'
}
# ----------------------------------------------------------------------------
# zzporcento
# Calcula porcentagens.
# Se informado um n�mero, mostra sua tabela de porcentagens.
# Se informados dois n�meros, mostra a porcentagem relativa entre eles.
# Se informados um n�mero e uma porcentagem, mostra os valores da porcentagem.
#
# Uso: zzporcento valor [valor|porcentagem%]
# Ex.: zzporcento 500           # Tabela de porcentagens de 500
#      zzporcento 500.0000      # Tabela para n�mero fracion�rio (.)
#      zzporcento 500,0000      # Tabela para n�mero fracion�rio (,)
#      zzporcento 5.000,00      # Tabela para valor monet�rio
#      zzporcento 500 25        # Mostra a porcentagem de 25 para 500 (5%)
#      zzporcento 500 1000      # Mostra a porcentagem de 1000 para 500 (200%)
#      zzporcento 500,00 25%    # Mostra quanto � 25% de 500,00
#      zzporcento 500,00 2,5%   # Mostra quanto � 2,5% de 500,00
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-12-11
# Vers�o: 4
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzporcento ()
{
	zzzz -h porcento $1 && return

	local i porcentagem

	local valor1=$1
	local valor2=$2
	local escala=0
	local separador=','
	local tabela='200 150 125 100 90 80 75 70 60 50 40 30 25 20 15 10 9 8 7 6 5 4 3 2 1'

	# Remove os pontos dos dinheiros para virarem fracion�rios (1.234,00 > 1234,00)
	zztool testa_dinheiro $valor1 && valor1=$(echo $valor1 | sed 's/\.//g')
	zztool testa_dinheiro $valor2 && valor2=$(echo $valor2 | sed 's/\.//g')

	### Vamos analisar o primeiro valor
	
	# N�mero fracion�rio (1.2345 ou 1,2345)
	if zztool testa_numero_fracionario $valor1
	then
		separador=$(echo $valor1 | tr -d 0-9)
		escala=$(echo $valor1 | sed 's/.*[.,]//')
		escala=${#escala}

		# Sempre usar o ponto como separador interno (para os c�lculos)
		valor1=$(echo $valor1 | sed 'y/,/./')

	# N�mero inteiro ou erro
	elif ! zztool testa_numero $valor1
	then
		zztool uso porcento
		return
	fi

	### Vamos analisar o segundo valor

	# O segundo argumento � uma porcentagem
	if test $# -eq 2 && zztool grep_var % $valor2
	then
		# O valor da porcentagem � guardado sem o caractere %
		porcentagem=$(echo $valor2 | tr -d %)
		# Sempre usar o ponto como separador interno (para os c�lculos)			
		porcentagem=$(echo $porcentagem | sed 'y/,/./')

		# Porcentagem fracionada
		if zztool testa_numero_fracionario $porcentagem
		then
			# Se o valor � inteiro (escala=0) e a porcentagem fracion�ria,
			# � preciso for�ar uma escala para que o resultado apare�a correto.
			test $escala -eq 0 && escala=2 valor1=$valor1.00			

		# Porcentagem inteira ou erro
		elif ! zztool testa_numero $porcentagem
		then
			echo "O valor da porcentagem deve ser um n�mero. Exemplos: 2 ou 2,5."
			return
		fi

	# O segundo argumento � um n�mero
	elif test $# -eq 2
	then
		# Ao mostrar a porcentagem entre dois n�meros, a escala � fixa
		escala=2

		# O separador do segundo n�mero � quem "manda" na sa�da
		# Sempre usar o ponto como separador interno (para os c�lculos)

		# N�mero fracion�rio
		if zztool testa_numero_fracionario $valor2
		then
			separador=$(echo $valor2 | tr -d 0-9)
			valor2=$(echo $valor2 | sed 'y/,/./')

		# N�mero normal ou erro
		elif ! zztool testa_numero $valor2
		then
			zztool uso porcento
			return
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
		if ! zztool grep_var % $valor2
		then
			echo "scale=$escala; $valor2*100/$valor1" | bc | sed 's/$/%/'

		# Mostra valores para a porcentagem informada
		else
			printf "%s%%\t%s\n" +$porcentagem $(echo "scale=$escala; $valor1+$valor1*$porcentagem/100" | bc)
			printf "%s%%\t%s\n"  100          $valor1
			printf "%s%%\t%s\n" -$porcentagem $(echo "scale=$escala; $valor1-$valor1*$porcentagem/100" | bc)
			echo
			printf "%s%%\t%s\n"  $porcentagem $(echo "scale=$escala; $valor1*$porcentagem/100" | bc)
		fi
	fi |

	# Assegura 0.123 (em vez de .123) e restaura o separador original
	sed "s/\([^0-9]\)\./\10./ ; y/./$separador/"
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
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzpronuncia ()
{
	zzzz -h pronuncia $1 && return

	local wav_file wav_dir wav_url
	local palavra=$1
	local cache="$ZZTMP.$palavra.wav"
	local url='http://www.m-w.com/dictionary'
	local url2='http://cougar.eb.com/soundc11'

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso pronuncia; return; }

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
			return
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2001-07-24
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzramones ()
{
	zzzz -h ramones $1 && return

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
# Requisitos: zzshuffle, gconftool
# ----------------------------------------------------------------------------
zzrandbackground ()
{

	zzzz -h randbackground $1 && return

	local caminho tempo papeisdeparede background
	local opcao caminho segundos loop

	# Tratando os parametros
	# foi passado -l
	if [ "$1" = "-l" ];then

		# Tem todos os parametros, caso negativo
		# mostra o uso da funcao
		if [ "$#" != "3" ]; then
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
		fi

		# A quantidade de segundos � inteira
		# caso negativo mostra o uso da funcao
		if zztool testa_numero $3; then
			segundos=$3
		else
			zztool uso randbackground
		fi
	else
		# Caso nao seja passado o -l, s� tem o camiho
		# caso negativo mostra o uso da funcao
		if [ "$#" != "1" ]; then
                        zztool uso randbackground
                        return 1
                fi

		# O caminho � valido, caso negativo
		# mostra o uso da funcao
		if test -d $2; then
			caminho=$1
		else
			zztool uso randbackground
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
# Acompanha uma encomenda nacional via rastreamento dos Correios.
# Uso: zzrastreamento <c�digo_da_encomenda>
# Ex.: zzrastreamento RK995267899BR
#
# Autor: Frederico Freire Boaventura <anonymous (a) galahad com br>
# Desde: 2007-06-25
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzrastreamento ()
{
	zzzz -h rastreamento $1 && return

	[ "$1" ] || { zztool uso rastreamento; return; }

	local url='http://websro.correios.com.br/sro_bin/txect01$.QueryList'
	local codigo="$1"

	$ZZWWWDUMP "$url?P_LINGUA=001&P_TIPO=001&P_COD_UNI=$codigo" |
		sed '
			/ Data /,/___/ !d
			/___/d
			s/^   //'
}
# ----------------------------------------------------------------------------
# zzrelansi
# Coloca um rel�gio digital (hh:mm:ss) no canto superior direito do terminal.
# Uso: zzrelansi [-s|--stop]
# Ex.: zzrelansi
#
# Autor: Arkanon <arkanon (a) lsd org br>
# Desde: 2009-09-17
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzrelansi ()
{
	zzzz -h relansi $1 && return
	
	local lock="/tmp/relansi-$$"
	
	trap "rm -f $lock" 0 1 2 3 15
	
	case $1 in
	-s|--stop)
		shopt -q
		# TODO: 'zzrelansi -s' apresenta na tela o c�digo do loop em bg
		rm -f $lock
		sleep 1
		tput sc
		tput cup 0 $[`tput cols`-8]
		echo "				"
		tput rc
	;;
	*)
		if test -e $lock
		then
			echo "RelANSI j� foi executado pelo processo $$"
		else
			touch $lock
			while test -e $lock
			do
				tput sc
				tput cup 0 $[`tput cols`-8]
				date +'%H:%M:%S'
				tput rc
				sleep 1
			done &
		fi
	;;
	esac
}
# ----------------------------------------------------------------------------
# zzrot13
# Codifica/decodifica um texto utilizando a cifra ROT13.
# Uso: zzrot13 texto
# Ex.: zzrot13 texto secreto               # Retorna: grkgb frpergb
#      zzrot13 grkgb frpergb               # Retorna: texto secreto
#      echo texto secreto | zzrot13        # Retorna: grkgb frpergb
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-07-23
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzrot13 ()
{
	zzzz -h rot13 $1 && return

	# Um tr faz tudo, � uma tradu��o letra a letra
	# Obs.: Dados do tr entre colchetes para funcionar no Solaris
	zztool multi_stdin "$@" |
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-07-23
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzrot47 ()
{
	zzzz -h rot47 $1 && return

	# Um tr faz tudo, � uma tradu��o letra a letra
	# Obs.: Os colchetes s�o parte da tabela, o tr n�o funcionar� no Solaris
	zztool multi_stdin "$@" |
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
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzrpmfind ()
{
	zzzz -h rpmfind $1 && return

	local url='http://rpmfind.net/linux/rpm2html/search.php'
	local pacote=$1
	local distro=$2
	local arquitetura=${3:-i386}
	
	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso rpmfind; return; }
	
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
# Suportados: Debian Fedora FreeBSD Gentoo Mandriva Slackware Suse Ubuntu.
# Uso: zzsecurity [distros]
# Ex.: zzsecutiry
#      zzsecurity fedora
#      zzsecurity debian gentoo
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2004-12-23
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzsecurity ()
{
	zzzz -h security $1 && return

	local url limite distros
	local n=5
	local ano=$(date '+%Y')
	local distros='debian fedora freebsd gentoo mandriva slackware suse ubuntu'
	
	limite="sed ${n}q"

	[ "$1" ] && distros="$(echo $* | zzminusculas)"
	
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
		url='http://www.mandriva.com/en/rss/feed/security'
		echo "$url"
		$ZZWWWHTML "$url" |
			sed -n '/<title>/{
				s/<[^>]*>//g
				s/^ *//
				/^Mandriva/d
				p
			}' |
			$limite
	fi

	# Suse
	if zztool grep_var suse "$distros"
	then
		echo
		zztool eco '** Atualiza��es Suse'
		url='http://www.novell.com/linux/security/advisories.html'
		echo "$url"
		$ZZWWWDUMP "$url" |
			sed -n 's/^.* \([0-9][0-9] *... *[0-9][0-9][0-9][0-9]\)/\1/p' |
			$limite
	fi

	# Fedora
	if zztool grep_var fedora "$distros"
	then
		echo
		zztool eco '** Atualiza��es Fedora'
		url='http://www.linuxsecurity.com/content/blogcategory/89/102/'
		echo "$url"
		$ZZWWWHTML "$url" |
			sed -n '
				/contentpagetitle/ {
					# O t�tulo est� na pr�xima linha
					n
					# Remove TABs e espa�os do in�cio
					s/^[^A-Za-z0-9]*//
					# Remove </a>
					s|</a>||
					# Mostra o resultado
					p
				}' |
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
			sed -n '
				/<title>/ {
					s/<[^>]*>//g
					s/^ *//
					/BSD-SA/p
				}' |
			$limite
	fi
	
	# Ubuntu
	if zztool grep_var ubuntu "$distros"
	then
		url='http://www.ubuntu.com/usn/rss.xml'
		echo
		zztool eco '** Atualiza��es Ubuntu'
		echo "$url"
		$ZZWWWHTML "$url" |
			sed -n '/item/,$ s@.*<title>\(.*\)</title>@\1@p' |
			$limite
	fi
}
# ----------------------------------------------------------------------------
# zzsemacento
# Tira os acentos de todas as letras (����� vira aeiou).
# Uso: zzsemacento texto
# Ex.: zzsemacento A��O 1� b�n��o           # Retorna: ACAO 1a bencao
#      echo A��O 1� b�n��o | zzsemacento    # Retorna: ACAO 1a bencao
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2010-05-24
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzsemacento ()
{
	zzzz -h semacento $1 && return

	# L� texto do usu�rio
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
# Gera uma senha aleat�ria de N caracteres formada por letras e n�meros.
# Obs.: A senha gerada n�o possui caracteres repetidos.
# Uso: zzsenha [n]     (padr�o n=6)
# Ex.: zzsenha
#      zzsenha 8
#
# Autor: Thobias Salazar Trevisan, www.thobias.org
# Desde: 2002-11-07
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzsenha ()
{
	zzzz -h senha $1 && return

	local posicao letra
	local n=6
	local alpha='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
	local maximo=${#alpha}

	# Guarda o n�mero informado pelo usu�rio (se existente)
	[ "$1" ] && n=$1
	
	# Foi passado um n�mero mesmo?
	if ! zztool testa_numero "$n"
	then
		zztool uso senha
		return
	fi

	# J� que n�o repete as letras, temos uma limita��o de tamanho
	if [ $n -gt $maximo ]
	then
		echo "O tamanho m�ximo da senha � $maximo"
		return
	fi
	
	# Esquema de gera��o da senha:
	# A cada volta � escolhido um n�mero aleat�rio que indica uma
	# posi��o dentro do $alpha. A letra dessa posi��o � mostrada na
	# tela e removida do $alpha para n�o ser reutilizada.
	while [ $n -ne 0 ]
	do
		n=$((n-1))
		posicao=$((RANDOM % ${#alpha} + 1))
		letra=$(echo -n "$alpha" | cut -c$posicao)
		alpha=$(echo $alpha | tr -d $letra)
		echo -n $letra
	done
	echo
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2002-12-06
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzseq ()
{
	zzzz -h seq $1 && return

	local operacao='+'
	local inicio=1
	local passo=1
	local formato='%d\n'
	local fim

	# Se tiver -f, guarda o formato e limpa os argumentos
	if test "$1" = '-f'
	then
		formato="$2"
		shift
		shift
	fi
	
	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso seq; return; }
	
	# Se houver s� um n�mero, vai "de um ao n�mero"
	fim=$1
	
	# Se houver dois n�meros, vai "do primeiro ao segundo"
	[ "$2" ] && inicio=$1 fim=$2
	
	# Se houver tr�s n�meros, vai "do primeiro ao terceiro em saltos"
	[ "$3" ] && inicio=$1 passo=$2 fim=$3

	# Verifica��es b�sicas
	if ! (zztool testa_numero_sinal "$inicio" &&
	      zztool testa_numero_sinal "$passo" &&
	      zztool testa_numero_sinal "$fim" &&
	      test $passo -ne 0)
	then
		zztool uso seq
		return
	fi
	
	# Internamente o passo deve ser sempre positivo para simplificar
	# Assim mesmo que o usu�rio fa�a 0 -2 10, vai funcionar
	[ $passo -lt 0 ] && passo=$((0 - passo))
	
	# Se o primeiro for maior que o segundo, a contagem � regressiva
	[ $inicio -gt $fim ] && operacao='-'
	
	# Loop que mostra o n�mero e aumenta/diminui a contagem
	i=$inicio
	while (test $inicio -lt $fim -a $i -le $fim ||
	       test $inicio -gt $fim -a $i -ge $fim)
	do
		printf "$formato" $i
		eval "i=\$((i $operacao passo))" # +n ou -n
	done
	
	# Caso especial: in�cio e fim s�o iguais
	test $inicio -eq $fim && echo $inicio
}
# ----------------------------------------------------------------------------
# zzsextapaixao
# Mostra a data da sexta-feira da paixao para qualquer ano.
# Obs.: Se o ano n�o for informado, usa o atual.
# Regra: 2 dias antes do domingo de P�scoa.
# Uso: zzsextapaixao [ano]
# Ex.: zzsextapaixao
#      zzsextapaixao 2008
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-11-21
# Licen�a: GPL
# Requisitos: zzdata, zzpascoa
# ----------------------------------------------------------------------------
zzsextapaixao ()
{
        zzzz -h sextapaixao $1 && return

        local ano="$1"

        # Se o ano n�o for informado, usa o atual
        test -z "$ano" && ano=$(date +%Y)

        # Verifica��o b�sica
        if ! zztool testa_numero $ano
        then
                zztool uso sextapaixao
                return
        fi

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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-06-19
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzshuffle ()
{
	zzzz -h shuffle $1 && return

	local linha

	# Suporte a m�ltiplos arquivos (cat $@) e entrada padr�o (cat -)
	cat "${@:--}" |
	
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
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzsigla ()
{
	zzzz -h sigla $1 && return
	
	local url=http://www.acronymfinder.com/af-query.asp

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso sigla; return; }

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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2003-06-12
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzss ()
{
	zzzz -h ss $1 && return

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
				[ "$2" ] || { zztool uso ss; return; }
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
			return
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
# zzsubway
# Mostra uma sugest�o de sandu�che para pedir na lanchonete Subway.
# Obs.: Se n�o gostar da sugest�o, chame a fun��o novamente para ter outra.
# Uso: zzsubway
# Ex.: zzsubway
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2008-12-02
# Vers�o: 1
# Licen�a: GPL
# Requisitos: zzshuffle
# ----------------------------------------------------------------------------
zzsubway ()
{
	zzzz -h subway $1 && return

	local linha quantidade categoria opcoes

	# O formato � quantidade:categoria:op��o1:...:op��oN
	cardapio="\
	1:recheio:(1) B.M.T. Italiano:(2) Atum:(3) Vegetariano:(4) Frutos do Mar Subway:(5) Frango Teriaki:(6) Peru, Presunto & Bacon:(7) Alm�ndegas:(8) Carne e Queijo:(9) Peru, Presunto & Roast Beef:(10) Peito de Peru:(11) Rosbife:(12) Peito de Peru e Presunto
	1:p�o:italiano:integral:parmes�o e or�gano:gergelim:tr�s queijos:integral com aveia e mel
	1:tamanho:15 cm:30 cm
	1:tostado:sim:n�o
	1:queijo:su��o:cheddar:prato
	1:extra:nenhum:bacon:dobro de queijo:dobro de recheio
	*:salada:tomate:alface:azeitona preta:cebola:piment�o:picles:r�cula:pepino
	1:molho:italiano:parmes�o:caesar:french:chipotle:mostarda e mel:sweet onion
	*:condim.:mostarda:maionese:azeite de oliva:sal:or�gano:pimenta do reino:pimenta calabresa"

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
# Licen�a: GPL
# ----------------------------------------------------------------------------
zztempo ()
{
	zzzz -h tempo $1 && return

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
		return
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
		return
	fi	
	
	# Se mais de uma localidade for encontrada, mostre-as
	if test $(echo "$localidades" | sed -n '$=') != 1
	then
		echo "$localidades"
		return
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
# Use a op��o --lista para ver todos os idiomas dispon�veis.
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
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-09-02
# Vers�o: 5
# Licen�a: GPLv2
# Requisitos: iconv
# ----------------------------------------------------------------------------
zztradutor ()
{
	zzzz -h tradutor $1 && return

	[ "$1" ] || { zztool uso tradutor; return; }

	# Variaveis locais
	local padrao
	local url='http://translate.google.com.br'
	local lang_de='pt'
	local lang_para='en'
	local charset_de='ISO-8859-1'
	local charset_para='UTF-8'

	case "$1" in 
		# O usu�rio informou um par de idiomas, como pt-en
		[a-z][a-z]-[a-z][a-z])
			lang_de=${1%-??}
			lang_para=${1#??-}
			shift
		;;
		-l | --lista)
			# Uma tag por linha, ent�o extrai e formata as op��es do <SELECT>
			$ZZWWWHTML "$url" |
				awk 'gsub("<", "\n&")' |
				sed -n '
					/^<select id=gt-sl /, /^<\/select>/ {
						s/zh-CN/cn/
						s/.*value="\(..\)">\(.*\)/\1 = \2/p
					}' |
				# O c�digo da p�gina vem em ISO em vez de UTF-8 :/
				iconv --from-code=$charset_de --to-code=$charset_para |
				# Filtra a lista com o texto de pesquisa, ou mostra ela toda
				grep ${2:-=}
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-06-12
# Licen�a: GPL
# ----------------------------------------------------------------------------
zztrocaarquivos ()
{
	zzzz -h trocaarquivos $1 && return
	
	# Um terceiro arquivo � usado para fazer a troca
	local tmp="$ZZTMP.trocaarquivos.$$"

	# Verifica��o dos par�metros
	[ "$#" -eq 2 ] || { zztool uso trocaarquivos; return; }

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
	rm "$tmp"
	echo "Feito: $1 <-> $2"
}
# ----------------------------------------------------------------------------
# zztrocaextensao
# Troca a extens�o dos arquivos especificados.
# Com a op��o -n, apenas mostra o que ser� feito, mas n�o executa.
# Uso: zztrocaextensao [-n] antiga nova arquivo(s)
# Ex.: zztrocaextensao -n .doc .txt *          # tire o -n para renomear!
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-15
# Licen�a: GPL
# ----------------------------------------------------------------------------
zztrocaextensao ()
{
	zzzz -h trocaextensao $1 && return
	
	local ext1 ext2 arquivo base novo nao

	# Op��es de linha de comando
	if [ "$1" = '-n' ]
	then
		nao='[-n] '
		shift
	fi

	# Verifica��o dos par�metros
	[ "$3" ] || { zztool uso trocaextensao; return; }
	
	# Guarda as extens�es informadas
	ext1="$1"
	ext2="$2"
	shift; shift
	
	# Tiro no p�? N�o, obrigado
	[ "$ext1" = "$ext2" ] && return
	
	# Para cada arquivo informado...
	for arquivo in "$@"
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
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-04
# Licen�a: GPL
# ----------------------------------------------------------------------------
# TODO -r (ver zzarrumanome)
zztrocapalavra ()
{
	zzzz -h trocapalavra $1 && return
	
	local arquivo antiga_escapada nova_escapada
	local antiga="$1"
	local nova="$2"

	# Precisa do tempor�rio pois nem todos os Sed possuem a op��o -i
	local tmp="$ZZTMP.trocapalavra.$$"
	
	# Verifica��o dos par�metros
	[ "$3" ] || { zztool uso trocapalavra; return; }

	# Escapando a barra "/" dentro dos textos de pesquisa
	antiga_escapada=$(echo "$antiga" | sed 's,/,\\/,g')
	nova_escapada=$(  echo "$nova"   | sed 's,/,\\/,g')

	shift; shift
	for arquivo in "$@"
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
		return
	done
	rm -f "$tmp"
}
# ----------------------------------------------------------------------------
# zztweets
# Busca os �ltimos 5 tweets de um usu�rio.
# Uso: zztweets @username
# Ex.: zztweets @oreio
#
# Autor: Eri Ramos Bastos <bastos.eri (a) gmail.com>
# Desde: 2009-07-30
# Vers�o: 2
# Licen�a: GPL
# ----------------------------------------------------------------------------
zztweets ()
{
	zzzz -h tweets $1 && return

	[ "$1" ] || { zztool uso tweets; return; }

	local url="http://twitter.com"
	local name=$(echo $1 | tr -d "@")
	local result_raw result_show 

	result_raw=$($ZZWWWDUMP $url/$name) 

	result_show=$(echo "$result_raw"| grep "^ *[1-5]\. ")
	test -n "$result_show" && echo "$result_show" && return

	result_show=$(echo "$result_raw"| grep "That page doesn't exist!")
	test -n "$result_show" && echo "Usu�rio @$name n�o encontrado!" && return

	echo "O Twitter n�o p�de responder essa requisi��o"
	return
}
# ----------------------------------------------------------------------------
# zzuniq
# Retira as linhas repetidas, consecutivas ou n�o.
# Obs.: N�o altera a ordem original das linhas, diferente do sort|uniq.
# Uso: zzuniq [arquivo]
# Ex.: zzuniq /etc/inittab
#      cat /etc/inittab | zzuniq
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2002-06-22
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzuniq ()
{
	zzzz -h uniq $1 && return

	# As linhas do arquivo s�o numeradas para guardar a ordem original
	cat -n "${1:--}" |     # Numera as linhas do arquivo
		sort -k2 -u |  # Ordena e remove duplos, ignorando a numera��o
		sort -n |      # Restaura a ordem original
		cut -f2-       # Remove a numera��o

	# Vers�o SED, mais lenta para arquivos grandes, mas s� precisa do SED
	# PATT: LINHA ATUAL \n LINHA-1 \n LINHA-2 \n ... \n LINHA #1 \n
	# sed "G ; /^\([^\n]*\)\n\([^\n]*\n\)*\1\n/d ; h ; s/\n.*//" $1
		
}
# ----------------------------------------------------------------------------
# zzunix2dos
# Converte arquivos texto no formato Unix (LF) para o Windows/DOS (CR+LF).
# Uso: zzunix2dos arquivo(s)
# Ex.: zzunix2dos frases.txt
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzunix2dos ()
{
	zzzz -h unix2dos $1 && return

	local arquivo
	local tmp="$ZZTMP.unix2dos.$$"
	local control_m=$(printf '\r') # ^M / CR

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso unix2dos; return; }
	
	for arquivo in "$@"
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
			return
		fi
				
 		echo "Convertido $arquivo"
	done
	
	# Remove o arquivo tempor�rio
	rm "$tmp"
}
# ----------------------------------------------------------------------------
# zzvira
# Vira um texto, de tr�s pra frente (rev) ou de ponta-cabe�a.
# Ideia original de: http://www.revfad.com/flip.html (valeu @andersonrizada)
# Uso: zzvira [-X] texto
# Ex.: zzvira Inverte tudo             # odut etrevnI
#      zzvira -X De pernas pro ar      #  od sud p
#
# Autor: Aur�lio Marinho Jargas, www.aurelio.net
# Desde: 2010-05-24
# Vers�o: 1
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzvira ()
{
	zzzz -h vira $1 && return

	local rasteira
	
	if test "$1" = '-X'
	then
		rasteira=1
		shift
	fi

	# L� texto do usu�rio
	zztool multi_stdin "$@" |

	# Vira o texto de tr�s pra frente (rev)
	sed '/\n/!G;s/\(.\)\(.*\n\)/&\2\1/;//D;s/.//' |
	
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
# zzwhoisbr
# http://registro.br
# Mostra informa��es sobre dom�nios brasileiros (.com.br, .org.br, etc).
# Uso: zzwhoisbr dom�nio
# Ex.: zzwhoisbr abc.com.br
#      zzwhoisbr www.abc.com.br
#
# Autor: Marcelo Subtil Mar�al
# Desde: 2001-12-14
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzwhoisbr ()
{
	zzzz -h whoisbr $1 && return

	local url='http://registro.br/cgi-bin/whois/'
	local dominio="${1#www.}" # tira www do in�cio

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso whoisbr; return; }

	# Faz a consulta e filtra o resultado
	$ZZWWWDUMP "$url?qr=$dominio" |
		sed '
			s/^  *//
			1,/^%/d
			/^remarks/,$d
			/^%/d
			/^alterado/d
			/atualizado /d
			/^$/d'
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
# Licen�a: GPL
# ----------------------------------------------------------------------------
zzwikipedia ()
{
	zzzz -h wikipedia $1 && return

	local url
	local idioma='pt'

	# Se o idioma foi informado, guarda-o, retirando o h�fen
	if [ "${1#-}" != "$1" ]
	then
		idioma="${1#-}"
		shift
	fi
	
	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso wikipedia; return; }

	# Faz a consulta e filtra o resultado, paginando
	url="http://$idioma.wikipedia.org/wiki/"
	$ZZWWWDUMP "$url$(echo $* | sed 's/  */_/g')" |
		sed '
			# Limpeza do conte�do
			/^Views$/,$ d
			/^Vistas$/,$ d
			/^Ferramentas pessoais$/,$ d
			/^   #Wikipedia (/d
			/^   #Editar Wikipedia /d
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

			# O usu�rio desativou esta fun��o?
			echo "$zz_off" | grep -q "^${zz_nome#zz}$" ||
				# Tudo certo, essa vai ser carregada
				echo "$zz_nome"
		fi
	done >> "$ZZTMP.on"

	# Lista das fun��es desativadas (OFF = Todas - ON)
	(
	cd "$ZZDIR" &&
 	ls -1 zz* |
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
		zz_arquivo="${ZZDIR%/}"/$zz_nome
		
		sed 1q "$zz_arquivo"
		echo "# $zz_nome"
		sed 1d "$zz_arquivo"
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
	zz_arquivo="${ZZDIR%/}"/$zz_nome

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
	# Veja issue 5 para mais detalhes.
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
