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
    LANÇAMENTO: Funções ZZ versão 21.1 →
    <a href="anuncio-21.1.html">anúncio</a>,
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

* Consulta automatizada a sites (rastreamento, notícias, cotações, resultados, dicionários)
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
* Cálculos complicados com porcentagens? *zzporcento*.
* Precisa tomar uma decisão importante? *zzcaracoroa* ;)
* E aquela sua encomenda que não chega nunca? *zzrastreamento*.

[![](img/canivete-funcoeszz.png)](logo.html)

Criado por [Aurelio Jargas](http://aurelio.net), este é um software livre ([GPL-2.0-only](https://spdx.org/licenses/GPL-2.0-only.html)) 100% nacional e maduro, que já completou [21 anos de existência](hist.html). É o resultado do trabalho voluntário e não remunerado de [vários brasileiros](thanks.html) que colaboram em suas horas vagas, por prazer. Feito com muito carinho, bash, sed, awk, dedicação, expressões regulares, grep e ♥.

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
160.900

$ zzporcento 1.749,00 -20%             # iPad com 20% de desconto
1399,20

$ zzarrumanome *
RAMONES - I Dont Care.mp3 -> ramones-i_dont_care.mp3
Toy Dolls - Wakey, Wakey!.mp3 -> toy_dolls-wakey_wakey.mp3

$ zzfeed -n 7 aurelio.net/feed
Minha experiência na ContaAzul
Serei papai \o/
Tela Preta episódio 9: Contar palavras com egrep|sort|uniq
Palestra “Shell Script Moderno” no FISL17
Raridade: teve ensaio da banda
Palestra “O poder da linha de comando” no SC Dev Summit 2016
Tenho três empregos
```

## Cotações

<!-- zzmoneylog -->

```console
$ zzdolar
           	Compra	Venda 	Var(%)
Comercial  	5,207	5,208	-1,920
Turismo    	5,227	5,367	-2,000
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
$ zzbrasileirao A
Série A
Classificação
#   Time                 P    J    V    E    D    GP   GC   SG
1   São Paulo            56   29   16   8    5    49   27   +22
2   Internacional        53   29   15   8    6    44   26   +18
3   Atlético Mineiro     50   28   15   5    8    48   36   +12
4   Flamengo             49   28   14   7    7    47   39   +8
5   Grêmio               49   28   12   13   3    37   23   +14
6   Palmeiras            47   27   13   8    6    38   25   +13
7   Fluminense           43   29   12   7    10   39   37   +2
8   Corinthians          42   28   11   9    8    35   30   +5
9   Santos               42   28   11   9    8    39   35   +4
10  Ceará                39   29   10   9    10   40   39   +1
11  Athletico Paranaense 38   29   11   5    13   26   28   -2
12  Atlético Goianiense  36   29   8    12   9    26   33   -7
13  Red Bull Bragantino  35   29   8    11   10   37   35   +2
14  Sport                32   29   9    5    15   24   37   -13
15  Vasco                32   28   8    8    12   29   39   -10
16  Fortaleza            32   29   7    11   11   24   26   -2
17  Bahia                29   29   8    5    16   35   51   -16
18  Goiás                26   29   6    8    15   29   44   -15
19  Botafogo             23   29   4    11   14   25   44   -19
20  Coritiba             22   29   5    7    17   22   39   -17

$ zzfutebol amanhã
15/01/2021 16:30       1. FC Union Berlin       vs       Bayer Leverkusen         1. Bundesliga 20/21
15/01/2021 16:45                    Lazio       vs       Roma                     Campeonato Italiano 2020/21
15/01/2021 17:00              Montpellier       vs       Monaco                   Campeonato Francês 2020/21
15/01/2021 17:30              Figueirense       vs       GE Brasil                Série B 2020
15/01/2021 18:00                 FC Porto       vs       Benfica                  Liga Portuguesa 2020/21
15/01/2021 19:15           Sampaio Corrêa       vs       Paraná                   Série B 2020
15/01/2021 21:30                Palmeiras       vs       Grêmio                   Brasileirão 2020
15/01/2021 21:30          América Mineiro       vs       Botafogo-SP              Série B 2020
```

## Loterias

```console
$ zzloteria quina megasena federal     # E aí, ficou milionário?
quina:
Concurso 5465 (13/01/2021)
	26	29	47	68	80

	Quina	-	-	
	Quadra	42	11.242,31	
	Terno	3755	189,09	
	Duque	99662	3,91	

Acumulado próximo concurso
 R$ 1.594.108,94

 Acumulado para Sorteio Especial de São João
 R$ 78.902.788,69

Arrecadação total
 R$ 8.189.630,00

megasena:
Concurso 2334 (13/01/2021)
	04	13	20	22	25	60

	Sena	1	11.854.874,71	
	Quina	66	34.602,68	
	Quadra	4609	707,86	

Acumulado próximo concurso
 R$ 7.451.635,52

Acumulado próximo concurso final (2335)
 R$ 7.451.635,52

Acumulado Mega da Virada
 R$ 1.693.553,58

Arrecadação total
 R$ 39.610.737,00

federal:
Concurso 5529 (13/01/2021)
1º	96148	1	500.000,00
2º	88596	1	27.000,00
3º	57538	1	24.000,00
4º	57810	1	19.000,00
5º	02927	1	18.329,00

$ zzpalpite                            # Sugestões aleatórias de jogo
quina:
 20 35 58 69 73

megasena:
 09 18 25 39 42 59

duplasena:
 01 22 37 39 41 44

lotomania:
 06 07 08 09 15
 17 18 21 22 24
 25 26 27 28 30
 32 33 40 41 42
 43 45 49 51 52
 53 55 56 57 58
 63 65 66 67 70
 71 72 77 78 81
 82 84 87 93 94
 95 96 97 98 99

lotofacil:
 02 03 06 08 09
 10 11 13 14 16
 17 19 20 23 24

federal:
 35230

timemania:
 02 09 20 26 31
 35 53 65 69 79

sorte:
 05 06 09 14 19 20 22

sete:
 2 6 2 3 8 2 6

loteca:
 Jogo 01: Coluna 1
 Jogo 02: Coluna do Meio
 Jogo 03: Coluna 2
 Jogo 04: Coluna 2
 Jogo 05: Coluna do Meio
 Jogo 06: Coluna do Meio
 Jogo 07: Coluna do Meio
 Jogo 08: Coluna 2
 Jogo 09: Coluna 1
 Jogo 10: Coluna 1
 Jogo 11: Coluna 1
 Jogo 12: Coluna do Meio
 Jogo 13: Coluna do Meio
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
62.1400

$ zzconverte mk 100
160.90

$ zzconverte cf 37                     # temperatura
98.60

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
/feed/

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
TV Globo
Quinta, 14/01
20∶30 Jornal Nacional
21∶40 A Força do Querer
22∶45 A Cor do Poder
23∶40 Shippados

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
https://bit.ly/3igmQBq

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
