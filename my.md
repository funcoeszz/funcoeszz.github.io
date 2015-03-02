---
title: Crie sua própria função
redirect_from:
  - /minhazz.html
  - /ajude.html
---

<style>
    #content pre b {
        color: yellow;
        font-weight: normal;
    }
</style>


Você manja de [shell script](http://aurelio.net/shell/)? Então que tal fazer a sua própria função ZZ? Siga os passos abaixo e veja como é simples!


## 1. Faça um shell script normal

Esqueça Funções ZZ por enquanto. Primeiro faça o seu programa
funcionar como um script Shell normal. Preocupe-se em testar situações inesperadas e tente antecipar erros do usuário para certificar-se que seu programa não contém bugs.


## 2. Coloque seu script numa função

Tudo funcionando? Então agora coloque todo o seu script dentro de uma função e declare todas as variáveis utilizadas como locais.

Supondo que o seu script é o `chaves.sh`, com este conteúdo:

```
#!/bin/bash

mensagem="Foi sem querer querendo..."
repita=3

i=0
while [ $i -lt $repita ]
do
        echo "$mensagem"
        i=$((i+1))
done
```

Ele deve ficar assim:


<pre>
#!/bin/bash

<b>chaves ()
{</b>
    <b>local</b> mensagem="Foi sem querer querendo..."
    <b>local</b> repita=3
    <b>local</b> i=0

    while [ $i -lt $repita ]
    do
        echo "$mensagem"
        i=$((i+1))
    done
<b>}</b>

<b>chaves "$@"</b>
</pre>


Note que o comando `local` é usando antes da declaração de cada variável. NÃO use variáveis globais dentro de funções.

A função foi declarada e a última linha é a sua chamada. Então como a lógica não foi alterada, o programa continua funcionando da mesma maneira. Se não estiver, reveja os passos e o deixe funcional.


## 3. Transforme a função numa ZZ

<pre>
#!/bin/bash
<b>
source /usr/bin/funcoeszz   # inclui o ambiente ZZ
ZZPATH=$PWD/chaves.sh       # o PATH desse script

# ----------------------------------------------------------------------------
# Repete a fala do Chaves.
# Uso: zzchaves
# Ex.: zzchaves
#
# Autor: Fulano da Silva, @fulano
# Versão: 1
# Licença: GPL
# ----------------------------------------------------------------------------
zz</b>chaves ()
{

    <b>zzzz -h chaves "$1" && return</b>

    local mensagem="Foi sem querer querendo..."
    local repita=3
    local i=0

    while [ $i -lt $repita ]
    do
        echo $mensagem
        i=$((i+1))
    done
}
</pre>


Acompanhe o que foi feito:

* As Funções ZZ originais foram incluídas no script, com o comando `source`. Assim simulamos o "ambiente ZZ" em nosso script.

* Redefinimos a variável `ZZPATH` para o caminho completo de nosso script. Isso é necessário para o funcionamento do `--help`.

* O prefixo "zz" foi adicionado ao nome da função, ficando `zzchaves`.

* A chamada à função que existia na última linha foi retirada. Agora chamaremos a função diretamente pela linha de comando.

* Foi adicionada uma chamada à função `zzzz` na primeira linha da nossa função. Essa linha é sempre igual, mudando apenas o nome da função. Essa linha serve para que funcione o `--help` de sua função.

* Por falar em `--help`, notou que foram adicionados comentários antes da função? É desses comentários que o texto de ajuda é extraído. É um formato padrão que deve ser seguido à risca. Na dúvida copie e cole um já existente e somente altere o texto.

Descrição do formato:

1. Uma linha separadora com "`# ----------------`"
1. A URL do site pesquisado (se aplicável)
1. A descrição do que faz a função, **em uma linha**, com ponto final.
1. Pode haver linhas extras para detalhar melhor a função
1. A linha com a sintaxe de uso "`# Uso: zz...`"
1. A linha com o exemplo de uso "`# Ex.: zz...`"
1. A linha vazia
1. A linha com as informações do autor (nome completo e e-mail/site/twitter)
1. A linha com a versão da função (número inteiro e sequencial, inicia em 1)
1. A linha com a licença da função
1. Uma linha separadora com "`# ----------------`"


## 4. Corra para o abraço!

```console
$ source chaves.sh
$ zzchaves
Foi sem querer querendo...
Foi sem querer querendo...
Foi sem querer querendo...
$ zzchaves -h

Repete a fala do Chaves
Autor: Fulano da Silva, @fulano
Versão: 1
Uso: zzchaves
Ex.: zzchaves

$
```

:)


## 5. Disponibilize para a comunidade

Sua função pode ser útil para outras pessoas? Então adicione ela no projeto!

1. Vai [lá no GitHub](https://github.com/funcoeszz/funcoeszz)
1. [Dá um fork](http://help.github.com/fork-a-repo/)
1. Adicione a função nova
1. Confira se ela se encaixa no [Coding Style](https://github.com/funcoeszz/funcoeszz/wiki/Coding-Style)
1. Confira se ela [é portável](https://github.com/funcoeszz/funcoeszz/wiki/Portabilidade)
1. [Mande um pull request](http://help.github.com/send-pull-requests/)
1. \o/
