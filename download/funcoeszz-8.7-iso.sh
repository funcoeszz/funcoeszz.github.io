#!/bin/bash
# funcoeszz
#
# INFORMA��ES: www.funcoeszz.net
# NASCIMENTO : 22 de Fevereiro de 2000
# AUTORES    : Aur�lio Marinho Jargas <verde (a) aurelio net>
#              Thobias Salazar Trevisan <thobias (a) thobias org>
# DESCRI��O  : Fun��es de uso geral para o shell Bash, que buscam
#              informa��es em arquivos locais e fontes na Internet
# LICEN�A    : GPL v2
# CHANGELOG  : www.funcoeszz.net/changelog.html
#
ZZVERSAO=8.7
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
#      $ZZCOR    - Liga/Desliga as mensagens coloridas (1 e 0)
#      $ZZPATH   - Caminho completo para o arquivo das fun��es
#      $ZZEXTRA  - Caminho completo para o arquivo com fun��es adicionais
#      $ZZTMPDIR - Diret�rio para armazenar arquivos tempor�rios
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
ZZEXTRA_DFT="$HOME/.zzextra"      # rota absoluta do arquivo de extras
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
[ "$ZZPATH" ] || echo 'AVISO: $ZZPATH vazia. zzajuda e zzzz n�o funcionar�o'
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
# Miniferramentas para auxiliar as fun��es.
# Uso: zztool ferramenta [argumentos]
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
		testa_numero)
			# Testa se $2 � um n�mero positivo
			echo "$2" | grep '^[0-9]\{1,\}$' >/dev/null
			
			# TODO Usar em *todas* as fun��es que recebem n�meros
		;;
		testa_numero_sinal)
			# Testa se $2 � um n�mero (pode ter sinal: -2 +2)
			echo "$2" | grep '^[+-]\{0,1\}[0-9]\{1,\}$' >/dev/null
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
# Mostra uma tela de ajuda com explica��o e sintaxe de todas as fun��es.
# Uso: zzajuda
# ----------------------------------------------------------------------------
zzajuda ()
{

	zzzz -h ajuda $1 && return

	# Salva a configura��o original de cores
	local zzcor_orig=$ZZCOR

	# Desliga cores para os paginadores antigos
	if [ "$PAGER" = 'less' -o "$PAGER" = 'more' ]
	then
		ZZCOR=0
	fi

	# Mostra ajuda das fun��es padr�o e das extras
	cat $ZZPATH $ZZEXTRA |

		# Magia negra para extrair somente os textos de descri��o
		sed '
			1 {
				s/.*/** Ajuda das Fun��es ZZ (tecla Q sai)/
				G
				p
			}
			/^# --*$/,/^# --*$/ {
				s/-\{20,\}/-------/
				s/^# //p
			}
			d' |
		uniq |
		sed 's/^-\{7\}/&&&&&&&&&&&/' |
		zztool acha 'zz[a-z0-9]\{2,\}' |
		${PAGER:-less -r}
		
	# Restaura configura��o de cores
	ZZCOR=$zzcor_orig
}


# ----------------------------------------------------------------------------
# Mostra informa��es sobre as fun��es, como vers�o e localidade.
# Op��es: --atualiza  baixa a vers�o mais nova das fun��es
#         --teste     testa se a codifica��o e os pr�-requisitos est�o OK
#         --bashrc    instala as fun��es no ~/.bashrc
#         --tcshrc    instala as fun��es no ~/.tcshrc
# Uso: zzzz [--atualiza|--teste|--bashrc|--tcshrc]
# Ex.: zzzz
#      zzzz --teste
# ----------------------------------------------------------------------------
zzzz ()
{
	local nome_func arg_func padrao
	local info_instalado info_cor info_utf8 versao_remota
	local arquivo_aliases arquivo_zz extra
	local bashrc="$HOME/.bashrc"
	local tcshrc="$HOME/.tcshrc"
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
				padrao="Uso: [^ ]*zz$nome_func \{0,1\}"

				# Um xunxo bonito: filtra a sa�da da zzajuda, mostrando
				# apenas a fun��o informada.
				zzajuda |
					grep -C15 "^$padrao\b" |
					sed -n "
						H
						/^---/ {
						 	x
							/zz$nome_func/ {
							 	s/----*//gp
								q
							}
						}"
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
			local comandos='awk- bc cat chmod- clear- cp cpp- cut diff- du- find- grep iconv- lynx mv od- play- ps- rm sed sleep sort tail- tr uniq'

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
				(
					echo
					echo "# $instal_msg"
					echo "source $ZZPATH"
					echo "export ZZPATH=$ZZPATH"
				) >> "$bashrc"
				
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
				(
					echo
					echo "# $instal_msg"
					echo "source $arquivo_aliases"
					echo "setenv ZZPATH $ZZPATH"
				) >> "$tcshrc"
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
			
			# Informa��es, uma por linha
			zztool acha '^[^)]*)' "( local) $ZZPATH"
			zztool acha '^[^)]*)' "(vers�o) $ZZVERSAO ($info_utf8)"
			zztool acha '^[^)]*)' "( cores) $info_cor"
			zztool acha '^[^)]*)' "(   tmp) $ZZTMP"
			zztool acha '^[^)]*)' "(bashrc) $info_instalado"
			zztool acha '^[^)]*)' "(extras) ${ZZEXTRA:-nenhum}"
			zztool acha '^[^)]*)' "(  site) $url_site"
						
			# Lista de todas as fun��es
			for arquivo_zz in "$ZZPATH" "$ZZEXTRA"
			do
				if [ "$arquivo_zz" -a -f "$arquivo_zz" ]
				then
					echo
					zztool eco "(( fun��es dispon�veis ${extra:+EXTRA }))"
					# Nota: zzzz --tcshrc procura por " fu"
					
					# Sed m�gico que extrai e formata os nomes de fun��es
					# limitando as linhas em 60 colunas
					sed -n '/^zz\([a-z0-9]\{1,\}\) *(.*/s//\1/p' "$arquivo_zz" |
						sort |
						sed -e ':a' -e '$b' -e 'N; s/\n/, /; /.\{60\}/{p;d;};ba'
						
					# Flag tosca para identificar a segunda volta do loop
					extra=1
				fi
			done
		;;
	esac
}



# ----------------------------------------------------------------------------
# #### D I V E R S O S
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Mostra uma seq��ncia num�rica, um n�mero por linha.
# Obs.: Emula��o do comando seq, presente no Linux.
# Uso: zzseq [n�mero-inicial] n�mero-final
# Ex.: zzseq 5
#      zzseq 10 5
# ----------------------------------------------------------------------------
# TODO aceitar terceiro par�metro, igual no Linux: 10 -2 0 (in�cio step fim)
zzseq ()
{
	zzzz -h seq $1 && return

	local operacao='+'
	local inicio=1
	local fim=$1

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso seq; return; }
	
	# Se houver dois n�meros, vai "do primeiro ao segundo"
	[ "$2" ] && inicio=$1 fim=$2

	# Verifica��es b�sicas
	if ! (zztool testa_numero_sinal "$inicio" &&
	      zztool testa_numero_sinal "$fim")
	then
		zztool uso seq
		return
	fi
	
	# Se o primeiro for maior que o segundo, a contagem � regressiva
	[ $inicio -gt $fim ] && operacao='-'
	
	# Loop que mostra o n�mero e aumenta/diminui a contagem
	while [ $inicio -ne $fim ]
	do
		echo $inicio
		eval "inicio=\$((inicio $operacao 1))" # +1 ou -1
	done
	echo $inicio
}


# ----------------------------------------------------------------------------
# Convers�o entre grandezas de bytes (mega, giga, tera, etc).
# Uso: zzbyte N [unidade-entrada] [unidade-saida]  # BKMGTPEZY
# Ex.: zzbyte 2048                    # Quanto � 2048 bytes?  -- 2K
#      zzbyte 2048 K                  # Quanto � 2048KB?      -- 2M
#      zzbyte 7 K M                   # Quantos megas em 7KB? -- 0.006M
#      zzbyte 7 G B                   # Quantos bytes em 7GB? -- 7516192768B
#      for u in b k m g t p e z y; do zzbyte 2 t $u; done
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
# Aguarda N minutos e dispara uma sirene usando o 'speaker'.
# �til para lembrar de eventos pr�ximos no mesmo dia.
# Sem argumentos, restaura o 'beep' para o seu tom e dura��o originais.
# Obs.: A sirene tem 4 toques, sendo 2 tons no modo texto e apenas 1 no Xterm.
# Uso: zzbeep [n�meros]
# Ex.: zzbeep 0
#      zzbeep 1 5 15    # espere 1 minuto, depois mais 5, e depois 15
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
# Retira linhas em branco e coment�rios.
# Para ver rapidamente quais op��es est�o ativas num arquivo de configura��o.
# Al�m do tradicional #, reconhece coment�rios de arquivos .vim.
# Obs.: Aceita dados vindos da entrada padr�o (STDIN).
# Uso: zzlimpalixo [arquivos]
# Ex.: zzlimpalixo ~/.vimrc
#      cat /etc/inittab | zzlimpalixo
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
# Convers�o de letras entre min�sculas e MAI�SCULAS, inclusive acentuadas.
# Uso: zzmaiusculas [arquivo]
# Uso: zzminusculas [arquivo]
# Ex.: zzmaiusculas /etc/passwd
#      echo N�O ESTOU GRITANDO | zzminusculas
# ----------------------------------------------------------------------------
zzminusculas ()
{
	zzzz -h minusculas $1 && return
	
	sed '
		y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
	 	y/�������������������������/�������������������������/' "$@"
}
zzmaiusculas ()
{
	zzzz -h maiusculas $1 && return
	
	sed '
		y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/
	 	y/�������������������������/�������������������������/' "$@"
}


# ----------------------------------------------------------------------------
# Retira as linhas repetidas, consecutivas ou n�o.
# Obs.: N�o altera a ordem original das linhas, diferente do sort|uniq.
# Uso: zzuniq [arquivo]
# Ex.: zzuniq /etc/inittab
#      cat /etc/inittab | zzuniq
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
# Mata processos pelo nome do seu comando de origem.
# Com a op��o -n, apenas mostra o que ser� feito, mas n�o executa.
# Uso: zzkill [-n] comando [comando2 ...]
# Ex.: zzkill netscape
#      zzkill netsc soffice startx
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
# Mostra todas as combina��es de cores poss�veis no console.
# Tamb�m mostra os c�digos ANSI para obter tais combina��es.
# Uso: zzcores
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
# Gera uma senha aleat�ria de N caracteres formada por letras e n�meros.
# Obs.: A senha gerada n�o possui caracteres repetidos.
# Uso: zzsenha [n]     (padr�o n=6)
# Ex.: zzsenha
#      zzsenha 8
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
# Mostra a tabela ASCII com todos os caracteres imprim�veis (32-126,161-255).
# O formato utilizando �: <decimal> <hexa> <octal> <ascii>.
# O n�mero de colunas e a largura da tabela s�o configur�veis.
# Uso: zzascii [colunas] [largura]
# Ex.: zzascii
#      zzascii 4
#      zzascii 7 100
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
# Protetor de tela (Screen Saver) para console, com cores e temas.
# Temas: mosaico, espaco, olho, aviao, jacare, alien, rosa, peixe, siri.
# Obs.: Aperte Ctrl+C para sair.
# Uso: zzss [--rapido|--fundo] [--tema <tema>] [texto]
# Ex.: zzss
#      zzss fui ao banheiro
#      zzss --rapido /
#      zzss --fundo --tema peixe
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
# Convers�o de telefones contendo letras para apenas n�meros.
# Autor: Rodolfo de Faria <rodolfo faria (a) fujifilm com br>
# Uso: zzfoneletra telefone
# Ex.: zzfoneletra 2345-LINUX              # Retorna 2345-54689
#      echo 5555-HELP | zzfoneletra        # Retorna 5555-4357
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
# Codifica/decodifica um texto utilizando a cifra ROT13
# Uso: zzrot13 texto
# Ex.: zzrot13 texto secreto               # Retorna: grkgb frpergb
#      zzrot13 grkgb frpergb               # Retorna: texto secreto
#      echo texto secreto | zzrot13        # Retorna: grkgb frpergb
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
# Codifica/decodifica um texto utilizando a cifra ROT47
# Uso: zzrot47 texto
# Ex.: zzrot47 texto secreto               # Retorna: E6IE@ D64C6E@
#      zzrot47 E6IE@ D64C6E@               # Retorna: texto secreto
#      echo texto secreto | zzrot47        # Retorna: E6IE@ D64C6E@
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
# #### A R Q U I V O S
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Converte arquivos texto no formato Windows/DOS (CR+LF) para o Unix (LF).
# Obs.: Tamb�m remove a permiss�o de execu��o do arquivo, caso presente.
# Uso: zzdos2unix arquivo(s)
# Ex.: zzdos2unix frases.txt
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
# Converte arquivos texto no formato Unix (LF) para o Windows/DOS (CR+LF).
# Uso: zzunix2dos arquivo(s)
# Ex.: zzunix2dos frases.txt
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
# Troca a extens�o dos arquivos especificados.
# Com a op��o -n, apenas mostra o que ser� feito, mas n�o executa.
# Uso: zztrocaextensao [-n] antiga nova arquivo(s)
# Ex.: zztrocaextensao -n .doc .txt *          # tire o -n para renomear!
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
# Troca o conte�do de dois arquivos, mantendo suas permiss�es originais.
# Uso: zztrocaarquivos arquivo1 arquivo2
# Ex.: zztrocaarquivos /etc/fstab.bak /etc/fstab
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
# Troca uma palavra por outra, nos arquivos especificados.
# Obs.: Al�m de palavras, � poss�vel usar express�es regulares.
# Uso: zztrocapalavra antiga nova arquivo(s)
# Ex.: zztrocapalavra excess�o exce��o *.txt
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
			echo $antigo | # Sem aspas para aproveitar o 'squeeze'
			zzminusculas |
			sed -e "
				# Remove aspas
				s/[\"']//g
				
				# H�fens no in�cio do nome s�o proibidos
				s/^-/_/
				
				# Remove acentos
				y/�����������������������/aaaaaaeeeeiiiiooooouuuu/
				y/��ߢУ����������/cnbcdloosuyyy123/
				
				# Qualquer caractere estranho vira sublinhado
				s/[^a-z0-9._-]/_/g
				
				# Remove sublinhados consecutivos
				s/__*/_/g
				
				# Remove sublinhados antes e depois de pontos e h�fens
				s/_\([.-]\)/\1/g
				s/\([.-]\)_/\1/g"
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
# Mostra a diferen�a entre dois textos, palavra por palavra.
# �til para conferir revis�es ortogr�ficas ou mudan�as pequenas em frases.
# Obs.: Se tiver muitas *linhas* diferentes, use o comando diff.
# Uso: zzdiffpalavra arquivo1 arquivo2
# Ex.: zzdiffpalavra texto-orig.txt texto-novo.txt
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
# Acha as fun��es de uma biblioteca da linguagem C (arquivos .h).
# Obs.: O diret�rio padr�o de procura � o /usr/include.
# Uso: zzcinclude nome-biblioteca
# Ex.: zzcinclude stdio
#      zzcinclude /minha/rota/alternativa/stdio.h
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
# Acha os maiores arquivos/diret�rios do diret�rio atual (ou outros).
# Op��es: -r  busca recursiva nos subdiret�rios
#         -f  busca somente os arquivos e n�o diret�rios
#         -n  n�mero de resultados (o padr�o � 10)
# Uso: zzmaiores [-r] [-f] [-n <n�mero>] [dir1 dir2 ...]
# Ex.: zzmaiores
#      zzmaiores /etc /tmp
#      zzmaiores -r -n 5 ~
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
			du $recursivo $pastas 2>/dev/null |
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
# Conta o n�mero de vezes que uma palavra aparece num arquivo.
# Obs.: � diferente do grep -c, que n�o conta v�rias palavras na mesma linha.
# Op��es: -i  ignora a diferen�a de mai�sculas/min�sculas
#         -p  busca parcial, conta trechos de palavras
# Uso: zzcontapalavra [-i|-p] palavra arquivo(s)
# Ex.: zzcontapalavra root /etc/passwd
#      zzcontapalavra -i -p a /etc/passwd      # Compare com grep -ci a
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
# Mostra uma linha de um texto, aleat�ria ou informada pelo n�mero.
# Obs.: Se passado um argumento, restringe o sorteio �s linhas com o padr�o.
# Uso: zzlinha [n�mero | -t texto] [arquivo(s)]
# Ex.: zzlinha /etc/passwd           # mostra uma linha qualquer, aleat�ria
#      zzlinha 9 /etc/passwd         # mostra a linha 9 do arquivo
#      zzlinha -2 /etc/passwd        # mostra a pen�ltima linha do arquivo
#      zzlinha -t root /etc/passwd   # mostra uma das linhas com "root"
#      cat /etc/passwd | zzlinha     # o arquivo pode vir da entrada padr�o
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
# Desordena as linhas de um texto (ordem aleat�ria)
# Uso: zzshuffle [arquivo(s)]
# Ex.: zzshuffle /etc/passwd         # desordena o arquivo de usu�rios
#      cat /etc/passwd | zzlinha     # o arquivo pode vir da entrada padr�o
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
# #### C � L C U L O
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Calculadora.
# Os operadores principais s�o + - / * ^ %, veja outros em "man bc".
# Obs.: N�meros fracionados podem vir com v�rgulas ou pontos: 1,5 ou 1.5.
# Uso: zzcalcula n�mero opera��o n�mero
# Ex.: zzcalcula 2,20 + 3.30          # v�rgulas ou pontos, tanto faz
#      zzcalcula '2^2*(4-1)'          # 2 ao quadrado vezes 4 menos 1
#      echo 2 + 2 | zzcalcula         # lendo da entrada padr�o (STDIN)
# ----------------------------------------------------------------------------
zzcalcula ()
{
	zzzz -h calcula $1 && return
	
	local parametros=$(zztool multi_stdin "$@")

	# Entrada de n�meros com v�rgulas ou pontos, sa�da sempre com v�rgulas
	echo "scale=2;$parametros" | sed y/,/./ | bc | sed y/./,/
}


# ----------------------------------------------------------------------------
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
			# TODO Muito fraquinho, usar regex (zztool)
			if [ "${data##*[^0-9/]}" != "$data" ]
			then
				echo "Data inv�lida '$data'"
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
# Gera um CPF v�lido aleat�rio ou valida um CPF informado.
# Obs.: O CPF informado pode estar formatado (pontos e h�fen) ou n�o.
# Uso: zzcpf [cpf]
# Ex.: zzcpf 123.456.789-09          # valida o CPF
#      zzcpf 12345678909             # com ou sem formatadores
#      zzcpf                         # gera um CPF v�lido
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
# Gera um CNPJ v�lido aleat�rio ou valida um CNPJ informado.
# Obs.: O CNPJ informado pode estar formatado (pontos e h�fen) ou n�o.
# Uso: zzcnpj [cnpj]
# Ex.: zzcnpj 12.345.678/0001-95      # valida o CNPJ
#      zzcnpj 12345678000195          # com ou sem formatadores
#      zzcnpj                         # gera um CNPJ v�lido
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
# Calcula os endere�os de rede e broadcast � partir do IP e m�scara da rede.
# Obs.: Se n�o for especificado a m�scara, � assumido a 255.255.255.0.
# Uso: zzcalculaip ip [netmask]
# Ex.: zzcalculaip 127.0.0.1 24
#      zzcalculaip 10.0.0.0/8
#      zzcalculaip 192.168.10.0 255.255.255.240
#      zzcalculaip 10.10.10.0
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



#-----------8<---------- Daqui pra baixo, fun��es que fazem busca na Internet.
#----------------------- Podem parar de funcionar se os sites mudarem.


# ----------------------------------------------------------------------------
# #### C O N S U L T A S                                         (Internet)
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# http://br.invertia.com
# Busca a cota��o do dia do d�lar (comercial, paralelo e turismo).
# Obs.: As cota��es s�o atualizadas de 10 em 10 minutos.
# Uso: zzdolar
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


# DESATIVADA: Agora os sites usam AJAX :(
# # ----------------------------------------------------------------------------
# # http://www.itautrade.com.br e http://www.bovespa.com.br
# # Busca a cota��o de uma a��o na Bovespa.
# # Obs.: As cota��es t�m delay de 15 min em rela��o ao pre�o atual no preg�o
# #       Com a op��o -i, � mostrado o �ndice bovespa
# # Autor: Denis Dias de Lima <denis (a) concatenum com>
# # Uso: zzbovespa [-i] c�digo-da-a��o
# # Ex.: zzbovespa petr4
# #      zzbovespa -i
# #      zzbovespa
# # ----------------------------------------------------------------------------
# zzbovespa ()
# {
# 	zzzz -h bovespa $1 && return
#
# 	local url='http://www.bovespa.com.br/'
#
# 	[ "$1" ] || {
# 		$ZZWWWDUMP "$url/Indices/CarteiraP.asp?Indice=Ibovespa" |
# 			sed '/^ *C�d/,/^$/!d'
# 		return
# 	}
# 	[ "$1" = "-i" ] && {
# 		$ZZWWWHTML "$url/Home/HomeNoticias.asp" |
# 			sed -n '
# 				/Ibovespa -->/,/IBrX/ {
# 					//d
# 					s/<[^>]*>//g
# 					s/[[:space:]]*//g
# 					s/^&.*\;//
# 					/^$/d
# 					p
# 				}' |
# 			sed '
# 				/^Pon/ {
# 					N
# 					s/^/		   /
# 					s/\n/   /
# 					b
# 				}
#
# 				/^IBO/ N
# 				N
# 				s/\n/  /g
# 				/^<.-- /d
#
# 				:a
# 				s/^\([^0-9]\{1,10\}\)\([0-9][0-9]*\)/\1 \2/
# 				ta'
# 		return
# 	}
# 	url='http://www.itautrade.com.br/itautradenet/Finder/Finder.aspx?Papel='
# 	$ZZWWWDUMP "$url$1" |
# 		sed '
# 			/A��o/,/Oferta/!d
# 			/Fracion�rio/,/Oferta/!d
# 			//d
# 			/\.gif/d
# 			s/^ *//
# 			/Milhares/q'
# }


# ----------------------------------------------------------------------------
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
			/^   #Wikipedia (/d
			/^   #Editar Wikipedia /d
			/^From Wikipedia,/d
			/^Origem: Wikip�dia,/d
			/^   Jump to: /d
			/^   Ir para: /d
			/^   This article does not cite any references/d
			/^   Please help improve this article/d
			/^   Wikipedia does not have an article with this exact name./q
			s/^\[edit\] //
			s/^\[editar\] //
			
			# Guarda URL da p�gina e mostra no final, ap�s Categorias
			/^   Obtido em "/ { H; d; }
			/^   Retrieved from "/ { H; d; }
			/^   Categor[a-z]*: /G' |
		cat -s
}


# DESATIVADA: Consultar 2003 � in�til e os anos atuais � travado com CAPTCHA
# # ----------------------------------------------------------------------------
# # http://www.receita.fazenda.gov.br
# # Consulta os lotes de restitui��o do imposto de renda.
# # Obs.: Funciona para os anos de 2001, 2002 e 2003.
# # Uso: zzirpf ano n�mero-cpf
# # Ex.: zzirpf 2003 123.456.789-69
# # ----------------------------------------------------------------------------
# zzirpf ()
# {
# 	zzzz -h irpf $1 && return
# 	
# 	local url='http://www.receita.fazenda.gov.br/Scripts/srf/irpf'
# 	local ano=$1
# 	local z=${ano#200}
#
# 	# Verifica��o dos par�metros
# 	[ "$2" ] || { zztool uso irpf; return; }
# 	
# 	[ "$z" != 1 -a "$z" != 2 -a "$z" != 3 ] && {
# 		echo "Ano inv�lido '$ano'. Deve ser 2001, 2002 ou 2003."
# 		return
# 	}
# 	$ZZWWWDUMP "$url/$ano/irpf$ano.dll?VerificaDeclaracao&CPF=$2" |
# 		sed '1,8d; s/^ */  /; /^  \[BUTTON\]/,$d'
# }


# DESATIVADA: Agora o site dos Correios usa AJAX :(
# # ----------------------------------------------------------------------------
# # http://www.correios.com.br/servicos/cep
# # Busca o CEP de qualquer rua de qualquer cidade do pa�s ou vice-versa.
# # Uso: zzcep estado cidade rua
# # Ex.: zzcep PR curitiba rio gran
# #      zzcep RJ 'Rio de Janeiro' Vinte de
# # ----------------------------------------------------------------------------
# zzcep ()
# {
# 	zzzz -h cep $1 && return
#
# 	local r c
# 	local url='http://www.correios.com.br/servicos/cep'
# 	local e="$1"
#
# 	# Verifica��o dos par�metros
# 	[ "$3" ] || { zztool uso cep; return; }
#
# 	c=$(echo "$2"| sed "$ZZSEDURL")
# 	shift
# 	shift
# 	r=$(echo "$*"| sed "$ZZSEDURL")
# 	echo "UF=$e&Localidade=$c&Tipo=&Logradouro=$r" |
# 		$ZZWWWPOST "$url" |
# 		sed -n '
# 			/^ *UF:/,/^$/ {
# 				/P�gina Anter/d
# 				s/.*�xima P�g.*/...CONTINUA/
# 				p
# 			}'
# }


# DESATIVADA: Agora a consulta � travada com CAPTCHA
# # ----------------------------------------------------------------------------
# # http://www.pr.gov.br/detran
# # Consulta d�bitos do ve�culo, como licenciamento, IPVA e multas (detran-PR)
# # Uso: zzdetranpr n�mero-renavam
# # Ex.: zzdetranpr 123456789
# # ----------------------------------------------------------------------------
# zzdetranpr ()
# {
# 	zzzz -h detranpr $1 && return
#
# 	local url='http://celepar7.pr.gov.br/detran_novo/consultas/veiculos/deb_novo.asp'
#
# 	# Verifica��o dos par�metros
# 	[ "$1" ] || { zztool uso detranpr; return; }
#
# 	# Faz a consulta e filtra o resultado (usando magia negra)
# 	$ZZWWWDUMP "$url?ren=$1" |
# 		sed 's/^  *//' |
# 		sed '
# 			# Remove linhas em branco
# 			/^$/ d
#
# 			# Transforma barra horizontal em linha em branco
# 			s/___*//
#
# 			# Apaga a lixarada
# 			1,/^Data: / d
# 			/^Informa..es do Ve.culo/ d
# 			/^Discrimina..o dos D.bitos/ d
# 			/\[BUTTON\]/,$ d
# 			/^Discrimina..o das Multas/,/^Resumo das Multas/ d
#
# 			# Quebra a linha para dados da segunda coluna da tabela
# 			s/Renavam:/@&/
# 			s/Ano de Fab/@&/
# 			s/Combust.vel:/@&/
# 			s/Cor:/@&/
# 			' |
# 		tr @ '\n'
# }


# ----------------------------------------------------------------------------
# http://www.detran.sp.gov.br
# Consulta d�bitos do ve�culo, como licenciamento, IPVA e multas (Detran-SP).
# Autor: Elton Sim�es Baptista <elton (a) inso com br>
# Uso: zzdetransp n�mero-renavam
# Ex.: zzdetransp 123456789
# ----------------------------------------------------------------------------
zzdetransp ()
{
	zzzz -h detransp $1 && return

	local url='http://www1.ssp.sp.gov.br/multas/detran/resultMultas.asp'

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
# http://www1.caixa.gov.br/loterias
# Consulta os resultados da quina, megasena, duplasena, lotomania e lotof�cil.
# Obs.: Se nenhum argumento for passado, todas as loterias s�o mostradas.
# Uso: zzloteria [quina | megasena | duplasena | lotomania | lotofacil]
# Ex.: zzloteria
#      zzloteria quina megasena
# ----------------------------------------------------------------------------
zzloteria ()
{
	zzzz -h loteria $1 && return

	local dump numero_concurso data resultado acumulado tipo
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
		
		dump=$($ZZWWWDUMP "$url/$tipo/${tipo}_pesquisa.asp" |
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
			;;
			lotofacil)
				# O resultado vem separado em campos distintos. Exemplo:
				# |01|04|07|08|09|10|12|14|15|16|21|22|23|24|25|
				
				data=$(     echo "$dump" | cut -d '|' -f 35)
				acumulado=$(echo "$dump" | cut -d '|' -f 54,55)
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
# #### P R O G R A M A S                                         (Internet)
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# http://freshmeat.net
# Procura por programas na base do site Freshmeat.
# Uso: zzfreshmeat programa
# Ex.: zzfreshmeat tetris
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
		sed -n 's@.*\(http.*freshmeat.net/projects/.*\)/@\1@p'
}


# ----------------------------------------------------------------------------
# http://rpmfind.net/linux
# Procura por pacotes RPM em v�rias distribui��es de Linux.
# Obs.: A arquitetura padr�o de procura � a i386.
# Uso: zzrpmfind pacote [distro] [arquitetura]
# Ex.: zzrpmfind sed
#      zzrpmfind lilo mandr i586
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
# #### D I V E R S O S                                           (Internet)
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# http://www.iana.org/cctld/cctld-whois.htm
# Busca a descri��o de um c�digo de pa�s da internet (.br, .ca etc).
# Uso: zzdominiopais [.]c�digo|texto
# Ex.: zzdominiopais .br
#      zzdominiopais br
#      zzdominiopais republic
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
# http://funcoeszz.net/locales.txt
# Busca o c�digo do idioma (locale). Por exemplo, portugu�s � pt_BR.
# Com a op��o -c, pesquisa somente nos c�digos e n�o em sua descri��o.
# Uso: zzlocale [-c] c�digo|texto
# Ex.: zzlocale chinese
#      zzlocale -c pt
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
# http://pgp.mit.edu
# Busca a identifica��o da chave PGP, fornecido o nome ou e-mail da pessoa.
# Uso: zzchavepgp nome|e-mail
# Ex.: zzchavepgp Carlos Oliveira da Silva
#      zzchavepgp carlos@dominio.com.br
# ----------------------------------------------------------------------------
zzchavepgp ()
{
	zzzz -h chavepgp $1 && return

	local url='http://pgp.mit.edu:11371'
	local padrao=$(echo $*| sed "$ZZSEDURL")

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso chavepgp; return; }

	$ZZWWWDUMP "http://pgp.mit.edu:11371/pks/lookup?search=$padrao&op=index" |
		sed 1,2d
}


# ----------------------------------------------------------------------------
# http://www.dicas-l.unicamp.br
# Procura por dicas sobre determinado assunto na lista Dicas-L.
# Obs.: As op��es do grep podem ser usadas (-i j� � padr�o).
# Uso: zzdicasl [op��o-grep] palavra(s)
# Ex.: zzdicasl ssh
#      zzdicasl -w vi
#      zzdicasl -vEw 'windows|unix|emacs'
# ----------------------------------------------------------------------------
zzdicasl ()
{
	zzzz -h dicasl $1 && return

	local opcao_grep
	local url='http://www.dicas-l.com.br/dicas-l/'

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
		sed -n 's@^<LI><A HREF=\([^>]*\)> *\([^ ].*\)</A>@\1: \2@p'
}


# ----------------------------------------------------------------------------
# http://registro.br
# Mostra informa��es sobre dom�nios brasileiros (.com.br, .org.br, etc).
# Uso: zzwhoisbr dom�nio
# Ex.: zzwhoisbr abc.com.br
#      zzwhoisbr www.abc.com.br
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
			/atualizado /d'
}


# ----------------------------------------------------------------------------
# http://www.whatismyip.com
# Mostra o seu n�mero IP (externo) na Internet.
# Uso: zzipinternet
# Ex.: zzipinternet
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
# http://www.ibiblio.org
# Procura documentos do tipo HOWTO.
# Uso: zzhowto [--atualiza] palavra
# Ex.: zzhowto apache
#      zzhowto --atualiza
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
# http://... - v�rios
# Busca as �ltimas not�cias sobre Linux em sites nacionais.
# Obs.: Cada site tem uma letra identificadora que pode ser passada como
#       par�metro, para informar quais sites voc� quer pesquisar:
#
#         Y)ahoo Linux         B)r Linux
#         C)ipsga              N)ot�cias linux
#         V)iva o Linux        U)nder linux
#
# Uso: zznoticiaslinux [sites]
# Ex.: zznoticiaslinux
#      zznoticiaslinux yn
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
	
	# Cipsga
	if zztool grep_var c "$sites"
	then
		url='http://www.cipsga.org.br'
		echo
		zztool eco "* CIPSGA ($url):"
		$ZZWWWDUMP "$url" |
			cat -s |
		 	sed '1,/vantagens exclusivas/d' |
		  	sed -n '/^$/{ n; p; }' |
		 	sed '/^$/q ; s/^  *//' |
			$limite
	fi
	
	# Br Linux
	if zztool grep_var b "$sites"
	then
		url='http://br-linux.org/feed/'
		echo
		zztool eco "* BR Linux ($url):"
		$ZZWWWHTML "$url" |
			sed -n '1,/<item>/d ; s/.*<title>// ; s@</title>@@p' |
			sed 's/&#822[01];/"/g' |
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
# http://... - v�rios
# Busca as �ltimas not�cias sobre linux em sites em ingl�s.
# Obs.: Cada site tem uma letra identificadora que pode ser passada como
#       par�metro, para informar quais sites voc� quer pesquisar:
#
#          F)reshMeat         Linux T)oday
#          S)lashDot          Linux W)eekly News
#          N)ewsForge         O)S News
#
# Uso: zzlinuxnews [sites]
# Ex.: zzlinuxnews
#      zzlinuxnews fsn
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
		url='http://freshmeat.net'
		echo
		zztool eco "* FreshMeat ($url):"
		$ZZWWWHTML "$url" |
			sed '/href="\/releases/!d;s/<[^>]*>//g;s/&nbsp;//g;s/^ *- //' |
			$limite
	fi

	# Slashdot
	if zztool grep_var s "$sites"
	then
		url='http://slashdot.org'
		echo
		zztool eco "* SlashDot ($url):"
		$ZZWWWHTML "$url" |
			sed -n '/<div class="title">/,/<\/div>/{/slashdot/{
		  s/<[^>]*>//g;s/^[[:blank:]]*//;p;};}' |
			$limite
	fi

	# Newsforge
	if zztool grep_var n "$sites"
	then
		url='http://www.newsforge.com'
		echo
		zztool eco "* NewsForge - ($url):"
		$ZZWWWHTML "$url" |
			sed -n '/<h3>/{ n; s/<[^>]*>//gp; }' |
			sed 's/^  *//' |
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
# http://... - v�rios
# Mostra os �ltimos 5 avisos de seguran�a de sistemas de Linux/UNIX.
# Suportados: Debian Fedora FreeBSD Gentoo Mandriva Slackware Suse Ubuntu.
# Uso: zzsecurity [distros]
# Ex.: zzsecutiry
#      zzsecurity fedora
#      zzsecurity debian gentoo
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
		$ZZWWWDUMP "$url" |
			sed -n 's/^ *\([Ff]edora *[0-9]\{1,\} *[Uu]pdate.*:.*\) *$/\1/p' |
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
		url='http://www.ubuntu.com/taxonomy/term/2/0/feed'
		echo
		zztool eco '** Atualiza��es Ubuntu'
		echo "$url"
		$ZZWWWDUMP "$url" |
			sed -n '/item/,$ s@.*<title>\(.*\)</title>@\1@p' |
			$limite
	fi
}


# ----------------------------------------------------------------------------
# http://google.com
# Pesquisa no Google diretamente pela linha de comando.
# Uso: zzgoogle [-n <n�mero>] palavra(s)
# Ex.: zzgoogle receita de bolo de abacaxi
#      zzgoogle -n 5 ramones papel higi�nico cachorro
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
		sed 's/class=g/\
/g' |
		sed '
			/^><a href="\([^"]*\)" class=l>/!d
			s/^><a href="//
			s/" class=l>/ /
			s/<\/a>.*//
			
			# Remove tags HTML
			s/<[^>]*>//g
			
			# Restaura os caracteres especiais
			s/&gt;/>/g
			s/&lt;/</g
			s/&quot;/"/g
			s/&nbsp;/ /g
			
			s/\([^ ]*\) \(.*\)/\2\
  \1\
/'
}


# DESATIVADA: N�o funciona. � preciso encontrar outro site e fazer o filtro.
# # ----------------------------------------------------------------------------
# # http://letssingit.com
# # Busca letras de m�sicas, procurando pelo nome da m�sica.
# # Obs.: Se encontrar mais de uma, mostra a lista de possibilidades.
# # Uso: zzletrademusica texto
# # Ex.: zzletrademusica punkrock
# #      zzletrademusica kkk took my baby
# # ----------------------------------------------------------------------------
# zzletrademusica ()
# {
# 	zzzz -h letrademusica $1 && return
# 	
# 	local padrao=$(echo "$*" | sed "$ZZSEDURL")
# 	local url=http://letssingit.com/cgi-exe/am.cgi
#
# 	# Verifica��o dos par�metros
# 	[ "$1" ] || { zztool uso letrademusica; return; }
# 	
# 	$ZZWWWDUMP "$url?a=search&p=1&s=$padrao&l=song" |
# 		sed -n 's/^ *//;/^artist /,/Page :/p;/^Artist *:/,${/IFRAME\|^\[params/d;p;}'
# }


# DESATIVADA: N�o funciona (404).
# # ----------------------------------------------------------------------------
# # http://tudoparana.globo.com/gazetadopovo/cadernog/tv.html
# # Consulta a programa��o do dia dos canais abertos da TV.
# # Pode-se passar os canais e o hor�rio que se quer consultar.
# #   Identificadores: B)and, C)nt, E)ducativa, G)lobo, R)ecord, S)bt, cU)ltura
# # Uso: zztv canal [hor�rio]
# # Ex.: zztv bsu 19       # band, sbt e cultura, depois das 19:00
# #      zztv . 00         # todos os canais, depois da meia-noite
# #      zztv .            # todos os canais, o dia todo
# # ----------------------------------------------------------------------------
# zztv ()
# {
# 	zzzz -h tv $1 && return
# 	
# 	local a c h
# 	local url='http://tudoparana.globo.com/gazetadopovo/cadernog'
#
# 	# Verifica��o dos par�metros
# 	[ "$1" ] || { zztool uso tv; return; }
#
# 	h=$(echo $2 | sed 's/^\(..\).*/\1/;s/[^0-9]//g')
# 	h="($h|$((h+1))|$((h+2)))"
# 	h=$(echo $h | sed 's/24/00/;s/25/01/;s/26/02/;s/\<[0-9]\>/0&/g;s@[(|)]@\\\\&@g')
# 	c=$(
# 		echo $1 |
# 		sed '
# 			s/b/2,/;s/s/4,/;s/c/6,/;
# 			s/r/7,/;s/u/9,/;s/g/12,/;s/e/59,/
# 			s/,$//;s@,@\\\\|@g'
# 	)
# 	c=$(echo $c | sed 's/^\.$/..\\?/')
# 	a=$(
# 		$ZZWWWHTML "$url/capa.phtml" |
# 		sed -n '/ana11azul.*conteudo.phtml?id=.*[tT][vV]/{ s/.*href=\"[^\"]*\/\([^\"]*\)\".*/\1/p;}'
# 	)
# 	[ "$a" ] || {
# 		echo "Programa��o de hoje n�o disponivel"
# 		return
# 	}
# 	$ZZWWWDUMP "$url/$a" |
# 		sed -e 's/^ *//;s/[Cc][Aa][Nn][Aa][Ll]/CANAL/;/^[012C]/!d;/^C[^A]/d;/^C/i \' -e . |
# 		sed "/^CANAL \($c\) *$/,/^.$/!d;/^C/,/^$h/{/^C\|^$h/!d;};s/^\.//"
# }


# ----------------------------------------------------------------------------
# http://www.acronymfinder.com
# Dicion�rio de siglas, sobre qualquer assunto (como DVD, IMHO, WYSIWYG).
# Obs.: H� um limite di�rio de consultas por IP, pode parar temporariamente.
# Uso: zzsigla sigla
# Ex.: zzsigla RTFM
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
# http://www.m-w.com
# Fala a pron�ncia correta de uma palavra em ingl�s.
# Uso: zzpronuncia palavra
# Ex.: zzpronuncia apple
# ----------------------------------------------------------------------------
zzpronuncia ()
{
	zzzz -h pronuncia $1 && return

	local wav_file wav_dir wav_url
	local palavra=$1
	local cache="$ZZTMP.$palavra.wav"
	local url='http://www.m-w.com/cgi-bin/dictionary'
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
			$ZZWWWHTML "$url?va=$palavra" |
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
# http://weather.noaa.gov/
# Mostra as condi��es do tempo (clima) em um determinado local.
# Se nenhum par�metro for passado, s�o listados os pa�ses dispon�veis.
# Se s� o pa�s for especificado, s�o listadas as suas localidades.
# As siglas tamb�m podem ser usadas, por exemplo SBPA = Porto Alegre.
# Uso: zztempo <pa�s> <localidade>
# Ex.: zztempo 'United Kingdom' 'London City Airport'
#      zztempo brazil 'Curitiba Aeroporto'
#      zztempo brazil SBPA
# ----------------------------------------------------------------------------
zztempo ()
{
	zzzz -h tempo $1 && return

	local codigo_pais codigo_localidade localidades
	local pais="$1"
	local localidade="$2"
	local cache_paises=$ZZTMP.tempo
	local cache_localidades=$ZZTMP.tempo
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
# ----------------------------------------------------------------------------
zzhoracerta ()
{
	zzzz -h horacerta $1 && return

	local codigo localidade localidades
	local cache=$ZZTMP.horacerta
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
	if ! test -s "$cache"
	then
		$ZZWWWHTML "$url/country.html" |
			sed -n 's/.*current_time_in_\([^.]*\)\.aspx">\([^<]*\)<.*/\1 -- \2/p' > "$cache"
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


# DESATIVADA: Agora a consulta � travada com CAPTCHA
# # ----------------------------------------------------------------------------
# # http://www.nextel.com.br
# # Envia uma mensagem para um telefone NEXTEL (via r�dio).
# # Obs.: O n�mero especificado � o n�mero pr�prio do telefone (n�o o ID!).
# # Uso: zznextel de para mensagem
# # Ex.: zznextel aur�lio 554178787878 minha mensagem mala
# # ----------------------------------------------------------------------------
# zznextel ()
# {
# 	zzzz -h nextel $1 && return
# 	
# 	local msg
# 	local url=http://page.nextel.com.br/cgi-bin/sendPage_v3.cgi
# 	local subj=zznextel
# 	local from="$1"
# 	local to="$2"
#
# 	# Verifica��o dos par�metros
# 	[ "$3" ] || { zztool uso nextel; return; }
#
# 	shift; shift
# 	msg=$(echo "$*" | sed "$ZZSEDURL")
#
# 	echo "to=$to&from=$from&subject=$subj&message=$msg&count=0&Enviar=Enviar" |
# 		$ZZWWWPOST "$url" |
# 		sed '1,/^ *CENTRAL/d ; s/.*Individual/ / ; N ; q'
# }



# ----------------------------------------------------------------------------
# #### T R A D U T O R E S   e   D I C I O N � R I O S           (Internet)
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
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
# http://www.babylon.com
# Tradu��o de UMA PALAVRA em ingl�s para v�rios idiomas.
# Franc�s, alem�o, japon�s, italiano, hebreu, espanhol, holand�s e portugu�s.
# Se nenhum idioma for informado, o padr�o � o portugu�s.
# Uso: zzdicbabylon [idioma] palavra   #idioma:dut fre ger heb ita jap ptg spa
# Ex.: zzdicbabylon hardcore
#      zzdicbabylon jap tree
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
			/SEARCH RESULT/,/<\/td>/!d
			s/^[$tab ]*//
			s/<[^>]*>//g
			/^$/d" |
		zztool texto_em_iso
}


# ----------------------------------------------------------------------------
# http://www.portoeditora.pt/dol
# Dicion�rio de portugu�s (de Portugal).
# Uso: zzdicportugues palavra
# Ex.: zzdicportugues bolacha
# ----------------------------------------------------------------------------
zzdicportugues ()
{
	zzzz -h dicportugues $1 && return

	local url='http://www.priberam.pt/dlpo/definir_resultados.aspx'
	local ini='^\(N�o \)\{0,1\}[Ff]oi\{0,1\}\(ram\)\{0,1\} encontrad'
	local fim='^Imprimir *$'

	# TODO Verificar alternativa brasileira (enviada por Luciano ES)
	# local URL=http://www.agal-gz.org/estraviz/modules.php
	# local parm='name=Dictionary&file=pesquisar&searchType=exact&dicSearch=ma��'

	# Verifica��o dos par�metros
	[ "$1" ] || { zztool uso dicportugues; return; }

	$ZZWWWDUMP "$url?pal=$1" |
		sed -n "
			s/^ *//
			/^$/d
			s/\[transparent.gif]//
			/$ini/,/$fim/ {
				/$ini/d
				/$fim/d
				/Duplo clique nas palavras/d
				/^ *$/d
				p
			}" |
		sed '
			/\(.*\.\),$/ {
		 		s//[\1]/
				H
				s/.*//
				x
			}' # \n + [categoria]
}


# ----------------------------------------------------------------------------
# http://catb.org/jargon/
# Dicion�rio de jarg�es de inform�tica, em ingl�s.
# Uso: zzdicjargon palavra(s)
# Ex.: zzdicjargon vi
#      zzdicjargon all your base are belong to us
# ----------------------------------------------------------------------------
zzdicjargon ()
{
	zzzz -h dicjargon $1 && return
	
	local achei achei2 num mais
	local url='http://catb.org/jargon/html'
	local cache=$ZZTMP.jargonfile
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
# Usa todas as fun��es de dicion�rio e tradu��o de uma vez.
# Uso: zzdictodos palavra
# Ex.: zzdictodos Linux
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
# http://aurelio.net/doc/misc/ramones.txt
# Mostra uma frase aleat�ria, das letras de m�sicas da banda punk Ramones.
# Obs.: Informe uma palavra se quiser frases sobre algum assunto especifico.
# Uso: zzramones [palavra]
# Ex.: zzramones punk
#      zzramones
# ----------------------------------------------------------------------------
zzramones ()
{
	zzzz -h ramones $1 && return

	local url='http://aurelio.net/doc/misc/ramones.txt'
	local cache=$ZZTMP.ramones
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
# http://www.ibb.org.br/vidanet
# A mensagem "Feliz Natal" em v�rios idiomas.
# Uso: zznatal [palavra]
# Ex.: zznatal                   # busca um idioma aleat�rio
#      zznatal russo             # Feliz Natal em russo
# ----------------------------------------------------------------------------
zznatal ()
{
	zzzz -h natal $1 && return

	local url='http://www.ibb.org.br/vidanet/outras/msg239.htm'
	local cache=$ZZTMP.natal
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
## Incluindo as fun��es extras
[ "$ZZEXTRA" -a -f "$ZZEXTRA" ] && source "$ZZEXTRA"


# ----------------------------------------------------------------------------
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
				     funcoeszz <fun��o> --help

				Dica: Inclua as Fun��es ZZ no seu login shell,
				      e depois chame-as diretamente pelo nome:

				    prompt$ funcoeszz zzzz --bashrc
				    prompt$ source ~/.bashrc
				    prompt$ zz<TAB><TAB>

				Lista das fun��es:

				    prompt$ funcoeszz zzzz

			FIM
		;;

		# Mostra a vers�o das fun��es
		-v | --version)
			echo "Fun��es ZZ v$ZZVERSAO"
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
