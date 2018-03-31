---
title: Funções ZZ
title_suffix: false
redirect_from: /exemplos.html
---

<style>
    #content li em {
        color: green;
        font-style: normal;
    }
    #content pre {
        padding: 1.5em 5px;
    }
</style>


<div class="alert">
    LANÇAMENTO: Funções ZZ versão 18.3 →
    <a href="anuncio-18.3.html">anúncio</a>,
    <a href="/download/">download</a>
</div>


<!--
<div class="alert">
    Comemoração:
    <a href="http://aurelio.net/blog/2013/02/28/13-anos-de-funcoes-zz/">13 anos de Funções ZZ</a>
</div>
-->

<!-- [![](img/icon/128.png)](logo.html) -->

Funções ZZ é uma coletânea com [{{ site.data.list.size }} miniaplicativos](list.html) de utilidades diversas, [acessíveis](acessivel.html) e prontos para serem usados na linha de comando de sistemas tipo UNIX (Linux, BSD, Mac OS X, Cygwin, entre outros).

<!--
Entre as funcionalidades, destacam-se:

* Consulta automatizada a sites (rastreamento, notícias, cotações, resultados, dicionários, tradutores)
* Cálculos e conversões (CPF, porcentagem, datas, horários, unidades de medida)
* Manipulação de dados (estatísticas, filtros, geração de senhas)
* Manipulação de arquivos (alterar nome, extensão, conteúdo)
* [Veja a lista completa dos miniaplicativos disponíveis](list.html)
-->

* Qual a cotação do dólar? *zzdolar*.
* Qual o resultado da Mega Sena? *zzloteria*.
* O que vai passar na TV nas próximas horas? *zztv*.
* E o timão, vai bem? *zzbrasileirao*.
* Não sabe o que pedir no Subway? *zzsubway*.
* Quando começa o horário de verão? *zzhorariodeverao*.
* Vai encurtar uma URL? *zzminiurl*.
* Precisa somar horas? *zzhora*.
* Precisa usar o Google Tradutor? *zztradutor*.
* Cálculos complicados com porcentagens? *zzporcento*.
* Precisa tomar uma decisão importante? *zzcaracoroa* ;)
* E aquela sua encomenda que não chega nunca? *zzrastreamento*.

[![](img/canivete-funcoeszz.png)](logo.html)

Criado por [Aurelio Jargas](http://aurelio.net), este é um software livre 100% nacional e maduro, que já completou [18 anos de existência](hist.html). É o resultado do trabalho voluntário e não remunerado de [vários brasileiros](thanks.html) que colaboram em suas horas vagas, por prazer. Feito com muito carinho, bash, sed, awk, dedicação, expressões regulares, grep e ♥.

<!--
mostrar o -h

$ zzsenha --pro 30
pBZ-m1M507tu4:HxQDJh9fWi;CvqGU

$ zzsenha --num 10
9083157246

$ zzdiasuteis
Março de 2013 tem 21 dias úteis.
-->

```console
$ zzipinternet                         # qual meu endereço IP?
201.15.253.210

$ zzsenha
qyYx5mat

$ zzsenha 30
QVz2UFgJAE19wMqX5BOdGoP3DjSp8C

$ zzhorariodeverao
20/10/2013
16/02/2014

$ zzdiadasemana 07/10/1977             # eu nasci numa…
sexta-feira

$ zzloteria megasena
megasena:
Concurso: 2026	(28/03/2018)
	10	23	31	33	51	52

Sena	0	R$ 0,00
Quina	105	R$ 24.755,26
Quadra	6.365	R$ 583,39

Valor acumulado: R$ 30.731.445,06
Acumulado Mega da Virada: R$ 18.704.458,15

$ zzrastreamento SA488387146BR
Data             Local                           Situação
15/02/2013 17:22 CEE BRASILIA SUL - BRASILIA/DF  Entrega Efetuada
15/02/2013 10:12 CEE BRASILIA SUL - BRASILIA/DF  Saiu para entrega
15/02/2013 09:04 CTE BRASILIA - BRASILIA/DF      Encaminhado
                 Em trânsito para CEE BRASILIA SUL - BRASILIA/DF
14/02/2013 20:47 CTE FLORIANOPOLIS - SAO JOSE/SC Encaminhado
                 Em trânsito para CTE BRASILIA - BRASILIA/DF
13/02/2013 16:45 AGF SAGUACU - JOINVILLE/SC      Encaminhado
                 Em trânsito para CTE FLORIANOPOLIS - SAO JOSE/SC
13/02/2013 11:59 AGF SAGUACU - JOINVILLE/SC      Postado

$ zzconverte mk 100
100 milhas = 160.900 km

$ zzporcento 1.749,00 -20%             # iPad com 20% de desconto
1399,20

$ zzarrumanome *
RAMONES - I Dont Care.mp3 -> ramones-i_dont_care.mp3
Toy Dolls - Wakey, Wakey!.mp3 -> toy_dolls-wakey_wakey.mp3

$ zzfeed -n 7 http://br-linux.org/feed/
O media center Android da Samsung
Consulta pública sobre Sistemas de Gestão de Conteúdo
Cursos Elastix Online noturno (04 a 08/03/13)
Campinas: Formação Completa SysAdmin Linux aos sábados
Funcionários do PTI conhecem as novidades do Expresso
Evernote no Linux: Everpad 2.5
Samsung nega interesse no Firefox OS
```

## Cotações

<!-- zzmoneylog -->

```console
$ zzdolar 
29/03/2018	16h59 
		Compra	Venda	Variação
Comercial	3,2994	3,3001	-0,93%
Turismo		3,1700	3,4400	-0,86%
```

## Validação de CPF e CNPJ

```console
$ zzcpf 123.456.789-00
CPF inválido (deveria terminar em 09)

$ zzcpf 123.456.789-09
CPF válido

$ zzcpf                                # cria um CPF aleatório
277.422.212-50

$ zzcnpj                               # cria um CNPJ aleatório
80.401.741/0001-13

$ zzcnpj 80.401.741/0001-99
CNPJ inválido (deveria terminar em 13)

$ zzcpf -f 987654349
009.876.543-49
```

## Manipulação de texto

```console
$ zzsemacento ÁGUA bênção              # tira acentos
AGUA bencao

$ zzmaiusculas um dois três            # sobe
UM DOIS TRÊS

$ zzminusculas UM DOIS TRÊS            # desce
um dois três

$ zzcapitalize UM DOIS TRÊS            # iniciais
Um Dois Três

$ zzvira texto secreto                 # inverte
oterces otxet

$ zzvira -X texto secreto              # ponta-cabeça
oʇǝɹɔǝs oʇxǝʇ

$ zzrot13 texto secreto                # esconde (ROT13)
grkgb frpergb

$ zzrot13 grkgb frpergb                # mostra
texto secreto

$ zzstr2hexa texto secreto             # hexadecimal
74 65 78 74 6f 20 73 65 63 72 65 74 6f

$ zzhexa2str 74 65 78 74 6f 20 73 65 63 72 65 74 6f
texto secreto

$ zzseq 5                              # contador
1
2
3
4
5

$ zzseq 5 | zztac                      # inversor
5
4
3
2
1

$ zzseq 5 | zzshuffle                  # misturador
1
5
2
4
3

$ zzseq 9 | zzjuntalinhas -d ' => '    # juntador
1 => 2 => 3 => 4 => 5 => 6 => 7 => 8 => 9

$ zzseq -f 'oi ' 13                    # repetidor
oi oi oi oi oi oi oi oi oi oi oi oi oi

$ echo a a a a b b b c c d | zzcontapalavras
4       a
3       b
2       c
1       d
```

## Unicode

```console
$ echo μη¡¢øÐε | zzunicode2ascii
unicoDe

$ echo © ® ² ª ½ » → ⇒ ♦ | zzunicode2ascii
(C) (R) 2 a 1/2 >> -> => <>

$ echo '&lt; &#60; &#x3C;' | zzunescape --xml
< < <

$ echo '&clubs; &hearts; &spades; &diams;' | zzunescape --html
♣ ♥ ♠ ♦
```

## Datas

<!--
myPS1=$PS1
PS1='\nprompt$ '
zzbissexto
zzcarnaval
zzsextapaixao
zzpascoa
zzcorpuschristi
zzhorariodeverao
zzdiadasemana 07/10/1977             # eu nasci numa…
zzdata                               # que dia é hoje?
#zzdiadasemana                        # e o dia da semana?
#zzdatafmt -f MES hoje                # e o mês?
zzdata hoje + 15                     # daqui 15 dias será…
zzdata hoje - 07/10/1977             # quantos dias já vivi?
zzdata 22/12/1999 + 69               # data + 69 dias
zzdata 01/03/2000 - 11/11/1999       # quantos dias entre…
zzdiasuteis 01/03/2013 31/03/2013    # quantos dias úteis?
zzdatafmt 1999-12-31                 # ISO -> Brasil
zzdatafmt -f AAAA-MM-DD 31/12/1999   # Brasil -> ISO
zzdatafmt -f AAAA 31/12/1999         # extrair o ano
zzdatafmt -f MES 31/12/1999          # nome do mês
zzdatafmt -f "D de MES de AAAA" 31/12/1999
#PS1=$myPS1
#zzferiado
-->

```console
$ zzbissexto
2015 não é bissexto

$ zzcarnaval
17/02/2015

$ zzsextapaixao
03/04/2015

$ zzpascoa
05/04/2015

$ zzcorpuschristi
04/06/2015

$ zzhorariodeverao
18/10/2015
21/02/2016

$ zzdiadasemana 07/10/1977             # eu nasci numa…
sexta-feira

$ zzdata                               # que dia é hoje?
12/02/2015

$ zzdata hoje + 15                     # daqui 15 dias será…
27/02/2015

$ zzdata hoje - 07/10/1977             # quantos dias já vivi?
13642

$ zzdata 22/12/1999 + 69               # data + 69 dias
29/02/2000

$ zzdata 01/03/2000 - 11/11/1999       # quantos dias entre…
111

$ zzdiasuteis 01/03/2013 31/03/2013    # quantos dias úteis?
21

$ zzdatafmt 1999-12-31                 # ISO -> Brasil
31/12/1999

$ zzdatafmt -f AAAA-MM-DD 31/12/1999   # Brasil -> ISO
1999-12-31

$ zzdatafmt -f AAAA 31/12/1999         # extrair o ano
1999

$ zzdatafmt -f MES 31/12/1999          # nome do mês
dezembro

$ zzdatafmt -f "D de MES de AAAA" 31/12/1999
31 de dezembro de 1999
```

## Horas

```console
$ zzhora agora                         # que horas são?
11:09 (0d 11h 09m)

$ zzhora 12:00 - agora                 # quanto falta pro almoço?
00:51 (0d 0h 51m)

$ zzhora 54:45 + 32:51                 # somando horas
87:36 (3d 15h 36m)

$ zzhora -r agora + 30:00              # daqui 30 horas, será…
17:09 (amanhã)

$ zzhora 1000                          # minutos -> horário
16:40 (0d 16h 40m)

$ zzhoramin 16:40                      # horário -> minutos
1000

$ zzhoracerta france 
France
4:59:07 AM
Saturday, March 31, 2018
Central European Summer Time (CEST) +0200 UTC
UTC/GMT is 02:59 on Saturday, March 31, 2018
```

## Esportes

```console
$ zzbrasileirao a
Série A
 Time                    PG   J   V   E   D  GP  GC  SG  (%)
  1 Fluminense           77  38  22  11   5  61  33  28   68
  2 Atlético-MG 1        72  38  20  12   6  64  37  27   63
  3 Grêmio -1            71  38  20  11   7  56  33  23   62
  4 São Paulo            66  38  20   6  12  59  37  22   58
  5 Vasco 1              58  38  16  10  12  45  44   1   51
  6 Corinthians -1       57  38  15  12  11  51  39  12   50
  7 Botafogo             55  38  15  10  13  60  50  10   48
  8 Santos 2             53  38  13  14  11  50  44   6   46
  9 Cruzeiro -1          52  38  15   7  16  47  51  -4   46
 10 Internacional -1     52  38  13  13  12  44  40   4   46
 11 Flamengo             50  38  12  14  12  39  46  -7   44
 12 Náutico 1            49  38  14   7  17  44  51  -7   43
 13 Coritiba 1           48  38  14   6  18  53  60  -7   42
 14 Ponte Preta -2       48  38  12  12  14  37  44  -7   42
 15 Bahia 1              47  38  11  14  13  37  41  -4   41
 16 Portuguesa -1        45  38  10  15  13  39  41  -2   39
 17 Sport                41  38  10  11  17  39  56 -17   36
 18 Palmeiras            34  38   9   7  22  39  54 -15   30
 19 Atlético-GO          30  38   7   9  22  37  67 -30   26
 20 Figueirense          30  38   7   9  22  39  72 -33   26

$ zzfutebol hoje
24/08/14 14h00 Copa da Itália          Virtus Lanciano   X   Genoa
24/08/14 14h00 Espanhol                Eibar   X   Real Sociedad
24/08/14 15h30 Copa da Itália          Brescia   X   Latina
24/08/14 15h30 Copa da Itália          Lazio   X   Bassano Virtus
24/08/14 15h30 Copa da Itália          Hellas Verona   X   Cremonese
24/08/14 15h30 Português               Boavista-POR   X   Benfica
24/08/14 15h45 Copa da Itália          Sampdoria   X   Como
24/08/14 15h45 Copa da Itália          Cesena   X   Casertana
24/08/14 16h00 Brasileirão             Criciúma   X   Flamengo
24/08/14 16h00 Brasileirão             São Paulo   X   Santos
24/08/14 16h00 Brasileirão             Vitória   X   Figueirense
24/08/14 16h00 Brasileirão             Fluminense   X   Sport
24/08/14 16h00 Brasileirão             Grêmio   X   Corinthians
24/08/14 16h00 Copa da Itália          Udinese   X   Ternana
24/08/14 16h00 Espanhol                Barcelona   X   Elche
24/08/14 16h00 Espanhol                Celta   X   Getafe
24/08/14 16h00 Francês                 Nantes   X   Monaco
24/08/14 16h00 Série C                 São Caetano   X   Caxias
24/08/14 16h00 Série C                 CRAC-GO   X   CRB
24/08/14 16h00 Série C                 Salgueiro   X   Botafogo-PB
24/08/14 16h00 Série D                 Londrina-PR   X   Boavista-RJ
24/08/14 16h00 Série D                 Baraúnas-RN   X   Campinense-PB
24/08/14 16h00 Série D                 Coruripe-AL   X   Central
24/08/14 16h00 Série D                 Confiança-SE   X   Globo-RN
24/08/14 16h00 Série D                 Porto-PE   X   Betim-MG
24/08/14 16h00 Série D                 Metropolitano   X   Penapolense
24/08/14 16h00 Série D                 Villa Nova-MG   X   Estrela-ES
24/08/14 16h00 Série D                 Itaporã   X   Brasiliense-DF
24/08/14 17h00 Série C                 Treze-PB   X   Cuiabá-MT
24/08/14 17h00 Série D                 River-PI   X   Interporto-TO
24/08/14 17h00 Série D                 Guarany de Sobral   X   Remo
24/08/14 18h00 Espanhol                Levante   X   Villarreal
24/08/14 18h30 Brasileirão             Atlético-PR   X   Bahia
24/08/14 18h30 Brasileirão             Goiás   X   Cruzeiro
24/08/14 19h00 Série C                 ASA   X   Paysandu
24/08/14 19h00 Série D                 Genus   X   Santos-AP
24/08/14 19h00 Série D                 Atlético Acreano   X   Rio Branco-AC
```

## Loterias

```console
$ zzloteria quina megasena federal     # E aí, ficou milionário?
quina:
Concurso: 4642	(29/03/2018)
	02	27	39	53	80

Quina	1	R$ 3.600.441,78
Quadra	73	R$ 6.241,27
Terno	5.926	R$ 115,61
Duque	154.312	R$ 2,44

Valor acumulado: R$ 0,00
Acumulado Especial de São João: R$ 82.215.261,04

megasena:
Concurso: 2026	(28/03/2018)
	10	23	31	33	51	52

Sena	0	R$ 0,00
Quina	105	R$ 24.755,26
Quadra	6.365	R$ 583,39

Valor acumulado: R$ 30.731.445,06
Acumulado Mega da Virada: R$ 18.704.458,15

federal:
Concurso: 5270	(28/03/2018)

	1º Prêmio	50084	R$ 350.000,00
	2º Prêmio	24959	R$ 18.000,00
	3º Prêmio	24391	R$ 15.000,00
	4º Prêmio	75161	R$ 12.000,00
	5º Prêmio	51564	R$ 10.023,00

$ zzpalpite                            # Sugestões aleatórias de jogo
quina:
 12 15 39 43 67

megasena:
 08 11 29 31 49 52

duplasena:
 01 03 17 19 35 37

lotomania:
 02 03 06 07 10
 11 12 14 15 18
 19 23 24 27 28
 29 33 34 37 38
 41 42 45 46 47
 49 51 53 55 58
 59 63 64 67 68
 71 72 75 76 77
 79 81 83 85 88
 89 92 93 97 98

lotofacil:
 01 02 05 06 07
 09 10 13 14 15
 17 18 21 23 24

federal:
 53475

timemania:
 03 06 09 30 33
 37 54 57 61 65

loteca:
 Jogo 01: Coluna do Meio
 Jogo 02: Coluna 2
 Jogo 03: Coluna 2
 Jogo 04: Coluna 1
 Jogo 05: Coluna 1
 Jogo 06: Coluna 1
 Jogo 07: Coluna 1
 Jogo 08: Coluna do Meio
 Jogo 09: Coluna do Meio
 Jogo 10: Coluna 2
 Jogo 11: Coluna 2
 Jogo 12: Coluna 2
 Jogo 13: Coluna 1
 Jogo 14: Coluna 1

$ zzbicho
 01 Avestruz
 02 Águia
 03 Burro
 04 Borboleta
 05 Cachorro
 06 Cabra
 07 Carneiro
 08 Camelo
 09 Cobra
 10 Coelho
 11 Cavalo
 12 Elefante
 13 Galo
 14 Gato
 15 Jacaré
 16 Leão
 17 Macaco
 18 Porco
 19 Pavão
 20 Peru
 21 Touro
 22 Tigre
 23 Urso
 24 Veado
 25 Vaca

$ zzbicho 8 g                          # números do camelo
 29 30 31 32
```

## Cálculos

```console
$ zzporcento 1.749,00                  # tabela de porcentagens
200%    3498,00
150%    2623,50
125%    2186,25
100%    1749,00
90%     1574,10
80%     1399,20
75%     1311,75
70%     1224,30
60%     1049,40
50%     874,50
40%     699,60
30%     524,70
25%     437,25
20%     349,80
15%     262,35
10%     174,90
9%      157,41
8%      139,92
7%      122,43
6%      104,94
5%      87,45
4%      69,96
3%      52,47
2%      34,98
1%      17,49

$ zzporcento 1.749,00 -10%             # preço do iPad com 10% de desconto
1574,10

$ zzporcento 1.749,00 10%              # quanto economizarei?
174,90

$ zzporcento 1749 1500                 # achei um por 1500
85,76%

$ zzcalcula 100 - 85,76                # isso dá 14% de desconto
14,24

$ seq 5 | zzcalcula --soma             # soma números da STDIN
15

$ zztabuada 77
77 x 0  = 0
77 x 1  = 77
77 x 2  = 154
77 x 3  = 231
77 x 4  = 308
77 x 5  = 385
77 x 6  = 462
77 x 7  = 539
77 x 8  = 616
77 x 9  = 693
77 x 10 = 770

$ zzromanos
1       I
5       V
10      X
50      L
100     C
500     D
1000    M

$ zzromanos 1977
MCMLXXVII

$ zzromanos MCMLXXVII
1977

$ zzbyte 1 K B                         # quantos bytes em 1KB?
1024B

$ zzbyte 2 G M                         # quantos megas em 2GB?
2048M

$ zzcalculaip 10.0.0.1
End. IP  : 10.0.0.1
Mascara  : 255.255.255.0 = 24
Rede     : 10.0.0.0 / 24
Broadcast: 10.0.0.255

$ zzcalculaip 10.0.0.1 8
End. IP  : 10.0.0.1
Mascara  : 255.0.0.0 = 8
Rede     : 10.0.0.0 / 8
Broadcast: 10.255.255.255

$ zzconverte km 100                    # distância
100 km = 62.1400 milhas

$ zzconverte mk 100
100 milhas = 160.900 km

$ zzconverte cf 37                     # temperatura
37 C = 98.60 F

$ zzconverte db 77                     # decimal -> binário
1001101

$ zzconverte dh 77                     # decimal -> hexadecimal
4d
```

## Funções matemáticas

<!--
$ zzmat -p2 asen 0.866026 g   # Valor do angulo em graus de um valor de seno dado, com precisão de 2 casas decimais, no máximo.
60.00
-->

```console
$ zzmat mdc 36 30 48              # Maior divisor comum
6

$ zzmat mmc 36 30 48              # Menor múltiplo comum
720

$ zzmat converte gr 60            # Ângulos: de graus para radianos
1.047198

$ zzmat sen 60g                   # Seno de 60°
0.866026

$ zzmat raiz 4 81                 # Raiz quarta de 81
3

$ zzmat area trapezio 100 80 40   # Área do trapézio
3600

$ zzmat volume esfera 12          # Volume de uma esfera
7238.229474

$ zzmat somatoria 4 15 1.1 x+2    # Somatória baseada na equação
126.5

$ zzmat d2p 4,3 7,10              # Distância entre dois pontos
7.615773

$ zzmat egr 4,3 7,10              # Equação Geral da Reta
-7x+3y+19=0

$ zzmat err 4,3 7,10              # Equação Resumida da Reta
y=2.333333x-6.333332

$ zzmat ege 4,3,5 7,10,7          # Equação Geral da Esfera
x^2+y^2+z^2-8x-6y-10z-12=0

$ zzmat egc 4,3 7,10              # Equação Geral da Circunferência
x^2+y^2-8x-6y-33=0

$ zzmat egc3p 4,3 7,10 5,7        # Equação Geral da Circunferência (3 pontos)
x^2+y^2-30.6x-4.6y+111.2=0
Centro: (15.3, 2.3)

$ zzmat eq2g -2 5 8               # Solução de equação do 2º grau
 X1: 3.608495
 X2: -1.108495
 Vertice: (1.25, 11.125)

$ zzmat det 3 2 9 8 7 3 0 1 5     # Determinante de uma matriz 3x3
88
```

## Cidades e estados brasileiros

```console
$ zzarrumacidade SAO PAULO
São Paulo

$ zzarrumacidade bh
Belo Horizonte

$ zzarrumacidade floripa
Florianópolis

$ zzcidade senhora
Livramento de Nossa Senhora (BA)
Nossa Senhora Aparecida (SE)
Nossa Senhora da Glória (SE)
Nossa Senhora das Dores (SE)
Nossa Senhora das Graças (PR)
Nossa Senhora de Lourdes (SE)
Nossa Senhora de Nazaré (PI)
Nossa Senhora do Livramento (MT)
Nossa Senhora do Socorro (SE)
Nossa Senhora dos Remédios (PI)
Senhora de Oliveira (MG)
Senhora do Porto (MG)
Senhora dos Remédios (MG)

$ zzestado
AC    Acre                   Rio Branco
AL    Alagoas                Maceió
AP    Amapá                  Macapá
AM    Amazonas               Manaus
BA    Bahia                  Salvador
CE    Ceará                  Fortaleza
DF    Distrito Federal       Brasília
ES    Espírito Santo         Vitória
GO    Goiás                  Goiânia
...

$ zzestado --formato '{sigla} - {nome}\n'
AC - Acre
AL - Alagoas
AP - Amapá
AM - Amazonas
BA - Bahia
CE - Ceará
DF - Distrito Federal
ES - Espírito Santo
GO - Goiás
...

$ zzestado --html
<select>
  <option value="AC">AC - Acre</option>
  <option value="AL">AL - Alagoas</option>
  <option value="AP">AP - Amapá</option>
  <option value="AM">AM - Amazonas</option>
  <option value="BA">BA - Bahia</option>
  <option value="CE">CE - Ceará</option>
  <option value="DF">DF - Distrito Federal</option>
  <option value="ES">ES - Espírito Santo</option>
...

$ zzestado --javascript
var siglas = ['AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', ...

var nomes = ['Acre', 'Alagoas', 'Amapá', 'Amazonas', 'Bahia', ...

var estados = {
  AC: 'Acre',
  AL: 'Alagoas',
  AP: 'Amapá',
  AM: 'Amazonas',
  BA: 'Bahia',
  CE: 'Ceará',
  DF: 'Distrito Federal',
  ES: 'Espírito Santo',
...
```

## Notícias (feeds)

<!--
zzlinuxnews
zznoticiaslinux.sh
zznoticiassec.sh
zzsecurity
-->

```console
$ zzfeed aurelio.net                   # Descobre os feeds do site
http://aurelio.net/feed/
http://aurelio.net/comments/feed/

$ zzfeed -n 5 aurelio.net/feed/        # Últimas notícias do feed
Os 5 melhores podcasts que escuto hoje
piazinho4: Pré-venda AUTOGRAFADA
Eu no podcast do Rudá
Rotina de escritor
Piazinho no Facebook (e sorteio!)
```

## TV e cinema

```console
$ zzglobo 
Sex, 30 de março

05:00: Hora Um
06:00: Bom Dia local
07:30: Bom Dia Brasil
08:50: Mais Você
10:10: Bem Estar
10:50: Encontro com Fátima Bernardes
12:00: Praça TV - 1ª Edição
12:47: Globo Esporte
13:20: Jornal Hoje
13:59: Vídeo Show
15:07: Sessão da Tarde
16:44: Vale a Pena Ver de Novo
17:50: Malhação - Vidas Brasileiras
18:24: Orgulho e Paixão
19:11: Praça TV - 2ª Edição
19:32: Deus Salve o Rei
20:30: Jornal Nacional
21:16: O Outro Lado do Paraíso
22:19: Big Brother Brasil 18
22:52: Globo Repórter
23:42: Jornal da Globo
00:19: Empire
01:05: Corujão
02:49: Corujão
04:05: Corujão

$ zztv cul
TV Cultura
Sábado, 31/03
00:30 Brasil Migrante                                    cod: 586782
01:30 Ensaio                                             cod: 18256
02:30 Jornal da Cultura                                  cod: 91182
03:30 Panorama                                           cod: 601605
04:00 Mosaicos                                           cod: 134592
05:00 Nossa Língua                                       cod: 164564
05:30 Índios no Brasil                                   cod: 83672
06:00 Conhecendo Museus                                  cod: 267917
06:30 Nova Amazônia                                      cod: 301035
07:00 Vento Sul                                          cod: 578937
08:00 Ordem do Dia                                       cod: 477190
08:30 #partiu Brasil                                     cod: 641977
08:40 Nino: Viagem ao Conhecimento                       cod: 605358
08:45 Um Filme de Cinema                                 cod: 604043
09:00 Robô TV                                            cod: 615295
09:15 Astrobaldo                                         cod: 586779
09:30 Thomas e Seus Amigos                               cod: 472145
10:00 Dora e seus Amigos na Cidade                       cod: 422193
10:30 O Pequeno Reino de Ben e Holly                     cod: 578472
10:45 Contos De Tinga Tinga                              cod: 547378
11:00 Campus Em Ação                                     cod: 576010
11:30 Momento Papo de Mãe                                cod: 593518
12:30 Jazz Sinfônica Brasil                              cod: 629301
13:30 Sésamo                                             cod: 578481
14:00 Moranguinho: Aventuras Em Tutti Frutti             cod: 550303
14:30 Quintal da Cultura                                 cod: 237370
16:00 Matinê Cultura                                     cod: 265174
17:30 Turma da Mônica                                    cod: 324448
17:45 Shaun, o Carneiro                                  cod: 172119
18:00 D.P.A. - Detetives do Prédio Azul                  cod: 578446
18:15 Carrapatos e Catapultas                            cod: 547377
18:30 Oswaldo                                            cod: 614610
18:45 Planetorama                                        cod: 615475
19:00 As Aventuras De Fujiwara Manchester                cod: 577026
19:15 Os Under-undergrounds                              cod: 595969
19:30 Os Cupins                                          cod: 289472
19:45 Tá Certo?                                          cod: 607901
20:15 Manos e Minas                                      cod: 146090
21:15 Jornal da Cultura                                  cod: 91182
22:00 Inspira BB                                         cod: 551911
22:15 Clássicos                                          cod: 323499
23:45 Cine Brasil                                        cod: 8980

$ zzcineuci 4
UCI Kinoplex Recife Shopping
Filme                                  Duração(min)                           Gênero                                 Censura
UMA DOBRA NO TEMPO                     100                                    Fantasia                               10 anos
NADA A PERDER - CONTRA TUDO. POR TODOS 130                                    Drama                                  10 anos
JOGADOR Nº1                            100                                    Ação                                   12 anos
PANTERA NEGRA                          134                                    Ação                                   14 anos
MARIA MADALENA                         119                                    Drama                                  12 anos
OS FAROFEIROS                          104                                    Comédia                                12 anos
CÍRCULO DE FOGO: A REVOLTA             111                                    Aventura                               12 anos
PEDRO COELHO                           95                                     Aventura                               Livre
OPERAÇÃO RED SPARROW                   140                                    Suspense                               16 anos
TOMB RAIDER - A ORIGEM                 124                                    Aventura                               14 anos
A MALDIÇÃO DA CASA WINCHESTER          99                                     Terror                                 14 anos
UM LUGAR SILENCIOSO                    95                                     Terror                                 14 anos
ATTACK ON TITAN                        99                                     Ação                                   16 anos
ATTACK ON TITAN: FIM DO MUNDO          89                                     Ação                                   16 anos
VINGADORES: GUERRA INFINITA            110                                    Ação                                   12 anos
O HOMEM DAS CAVERNAS                   140                                    Animação                               Livre
COM AMOR                               8259                                   Comédia Dramática                      12 anos

$ zzcinemais 38
Lorena - SP
29/03 a 04/04/2018

Círculo de Fogo: A Revolta
Dub. - 15h30, 19h20

Círculo de Fogo: A Revolta
Leg. - 21h40

Jogador Nº1
Dub. - 15h20, 21h30 

Jogador Nº1
Leg. - 18h50 

Nada a Perder - Contra Tudo. Por Todos
15h00, 17h30, 20h00

Pedro Coelho
Dub. - 15h10, 19h00, 21h00
```

## Manipulação de arquivos

<!-- zztrocaarquivos -->

```console
$ zzmaiores ~/a/*
1292716 /Users/aurelio/a/video
1281672 /Users/aurelio/a/wii
636652  /Users/aurelio/a/site
599680  /Users/aurelio/a/becape
592876  /Users/aurelio/a/livro
550032  /Users/aurelio/a/www
367060  /Users/aurelio/a/blog
340868  /Users/aurelio/a/txt2tags
129928  /Users/aurelio/a/conectiva

$ zztrocapalavra excessão exceção *.txt
Feito TCC.txt
Feito curriculo.txt

$ zztrocaextensao .HTM .html *
about.HTM -> about.html
download.HTM -> download.html
index.HTM -> index.html

$ zzarrumanome *
RAMONES - I Dont Care.mp3 -> ramones-i_dont_care.mp3
Toy Dolls - Wakey, Wakey!.mp3 -> toy_dolls-wakey_wakey.mp3

$ zznomefoto -p festa- -d 2 *.JPG
DSC0234.JPG -> festa-01.JPG
DSC0239.JPG -> festa-02.JPG
DSC0243.JPG -> festa-03.JPG
DSC0255.JPG -> festa-04.JPG
DSC0260.JPG -> festa-05.JPG

$ zzlinha -2 /etc/passwd               # penúltima linha
_netbios:*:222:222:NetBIOS:/var/empty:/usr/bin/false

$ zzlimpalixo /etc/inetd.conf          # esconde comentários
ftp     stream  tcp     nowait  root    /usr/sbin/tcpd  in.ftpd -l -a
talk    dgram   udp     wait    root    /usr/sbin/tcpd  in.talkd
pop-3   stream  tcp     nowait  root    /usr/sbin/tcpd  ipop3d
```

## E muito mais!

<!--
zzxml
-->

```console
$ zztempo -s -m
Previsão do tempo para: Brasilia, Brazil

    \  /       Parcialmente nublado
  _ /"".-.     18 °C          
    \_(   ).   ↓ 0 km/h       
    /(___(__)  10 km          
               0.4 mm         
                        ┌─────────────┐                        
┌───────────────────────┤  Sáb 31 Mar ├───────────────────────┐
│           Meio-dia    └──────┬──────┘      Noite            │
├──────────────────────────────┼──────────────────────────────┤
│  _`/"".-.     Possibilidade …│    \  /       Parcialmente n…│
│   ,\_(   ).   26-27 °C       │  _ /"".-.     21 °C          │
│    /(___(__)  ↙ 14-17 km/h   │    \_(   ).   ↙ 4-8 km/h     │
│      ‘ ‘ ‘ ‘  17 km          │    /(___(__)  16 km          │
│     ‘ ‘ ‘ ‘   0.3 mm | 77%   │               0.0 mm | 0%    │
└──────────────────────────────┴──────────────────────────────┘
                        ┌─────────────┐                        
┌───────────────────────┤  Dom 01 Abr ├───────────────────────┐
│           Meio-dia    └──────┬──────┘      Noite            │
├──────────────────────────────┼──────────────────────────────┤
│  _`/"".-.     Aguaceiros fra…│    \  /       Parcialmente n…│
│   ,\_(   ).   25-27 °C       │  _ /"".-.     21 °C          │
│    /(___(__)  ↙ 13-19 km/h   │    \_(   ).   ↓ 1-2 km/h     │
│      ‘ ‘ ‘ ‘  16 km          │    /(___(__)  16 km          │
│     ‘ ‘ ‘ ‘   1.7 mm | 84%   │               0.0 mm | 0%    │
└──────────────────────────────┴──────────────────────────────┘
                        ┌─────────────┐                        
┌───────────────────────┤  Seg 02 Abr ├───────────────────────┐
│           Meio-dia    └──────┬──────┘      Noite            │
├──────────────────────────────┼──────────────────────────────┤
│  _`/"".-.     Aguaceiros fra…│  _`/"".-.     Aguaceiros mod…│
│   ,\_(   ).   25-26 °C       │   ,\_(   ).   21 °C          │
│    /(___(__)  ↓ 11-17 km/h   │    /(___(__)  ↓ 3-5 km/h     │
│      ‘ ‘ ‘ ‘  15 km          │    ‚‘‚‘‚‘‚‘   14 km          │
│     ‘ ‘ ‘ ‘   2.4 mm | 76%   │    ‚’‚’‚’‚’   5.8 mm | 67%   │
└──────────────────────────────┴──────────────────────────────┘


$ zztradutor pt-en o livro está na mesa
the book is on the table

$ zztradutor pt-es o livro está na mesa
el libro está sobre la mesa

$ zztradutor pt-fr o livro está na mesa
le livre est sur la table

$ zztradutor pt-it o livro está na mesa
il libro è sul tavolo

$ zztradutor pt-de o livro está na mesa
Das Buch liegt auf dem Tisch

$ zzsubway
recheio : (12) Peito de Peru e Presunto
pão     : integral
tamanho : 15 cm
queijo  : prato
extra   : cream cheese
tostado : sim
salada  : tomate, picles, alface, rúcula, cebola, azeitona preta
molho   : cebola agridoce
tempero : sal, vinagre, azeite de oliva, pimenta do reino

$ zznome aurelio
Origem do nome Aurelio: LATIM

Significado do nome Aurelio: DOURADO.

$ zzminiurl https://github.com/funcoeszz/funcoeszz/
https://goo.gl/fRw4jz

$ zzjquery -s get
- get()
- get(num)
- $.get(url, params, callback)

$ zzjquery $.get
 $.get(url, params, callback):
  Load a remote page using an HTTP GET request.

$ zzfoneletra 0800-BIN-BASH            # ligue djá!
0800-246-2274

$ zzgravatar verde@aurelio.net         # URL do Gravatar
http://www.gravatar.com/avatar/e583bca48acb877efd4a29229bf7927f

$ zzextensao /tmp/arquivo.txt
txt

$ zzecho -f azul -l branco Texto branco, com fundo azul
Texto branco, com fundo azul

$ zzpronuncia shoot
URL: http://www.m-w.com/sound/s/shoot001.wav
Gravado o arquivo '/tmp/zz.shoot.wav'
playing /tmp/zz.shoot.wav

$ zzdominiopais cx
CX - Christmas Island

$ zznatal esl
"Feliz Natal" em Eslovaco: Sretan Bozic or Vesele vianoce

$ zzramones show
Sent to spy on a Cuban talent show

$ zzsigla BASH
BASH Bourne Again Shell (Unix/Linux)
BASH Bird/wildlife Aircraft Strike Hazard (military/aviation)
BASH Bridged Amplifier Switching Hybrid
BASH Bandwidth Sharing
BASH Bay Area Siberian Husky Club
BASH Blue Ash YMCA (Cincinnati, Ohio)

$ zzalfabeto --militar cambio
Charlie
Alpha
Mike
Bravo
India
Oscar

$ zzascii 5 70
95 caracteres, 5 colunas, 20 linhas, 70 de largura
   32 20 040     52 34 064 4   72 48 110 H   92 5C 134 \  112 70 160 p
   33 21 041 !   53 35 065 5   73 49 111 I   93 5D 135 ]  113 71 161 q
   34 22 042 "   54 36 066 6   74 4A 112 J   94 5E 136 ^  114 72 162 r
   35 23 043 #   55 37 067 7   75 4B 113 K   95 5F 137 _  115 73 163 s
   36 24 044 $   56 38 070 8   76 4C 114 L   96 60 140 `  116 74 164 t
   37 25 045 %   57 39 071 9   77 4D 115 M   97 61 141 a  117 75 165 u
   38 26 046 &   58 3A 072 :   78 4E 116 N   98 62 142 b  118 76 166 v
   39 27 047 '   59 3B 073 ;   79 4F 117 O   99 63 143 c  119 77 167 w
   40 28 050 (   60 3C 074 <   80 50 120 P  100 64 144 d  120 78 170 x
   41 29 051 )   61 3D 075 =   81 51 121 Q  101 65 145 e  121 79 171 y
   42 2A 052 *   62 3E 076 >   82 52 122 R  102 66 146 f  122 7A 172 z
   43 2B 053 +   63 3F 077 ?   83 53 123 S  103 67 147 g  123 7B 173 {
   44 2C 054 ,   64 40 100 @   84 54 124 T  104 68 150 h  124 7C 174 |
   45 2D 055 -   65 41 101 A   85 55 125 U  105 69 151 i  125 7D 175 }
   46 2E 056 .   66 42 102 B   86 56 126 V  106 6A 152 j  126 7E 176 ~
   47 2F 057 /   67 43 103 C   87 57 127 W  107 6B 153 k
   48 30 060 0   68 44 104 D   88 58 130 X  108 6C 154 l
   49 31 061 1   69 45 105 E   89 59 131 Y  109 6D 155 m
   50 32 062 2   70 46 106 F   90 5A 132 Z  110 6E 156 n
   51 33 063 3   71 47 107 G   91 5B 133 [  111 6F 157 o
```

Curtiu? Use a [versão online](/online/) ou [instale](/download/) em sua máquina e aproveite!

Manja de shell? Então ajuda nóis → [GitHub](https://github.com/funcoeszz/funcoeszz)
