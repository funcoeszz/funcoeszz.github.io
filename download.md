---
title: Download e instalação das Funções ZZ
redirect_from: /instalacao.html
---

<!-- > Dica: Sabia que você também também pode usar as Funções ZZ [direto no navegador](http://funcoeszz.net/online/), ou [em seu iPhone](http://itunes.apple.com/br/app/funcoes-zz/id492258680?mt=8)? -->

<!-- > Dica: Manja de git? Então [baixe o repositório completo](https://github.com/funcoeszz/funcoeszz) e seja feliz! -->

<!-- > Vá no [Funções ZZ à la carte](a-la-carte/?zz=*), escolha as funções desejadas e aperte o botão *Baixar arquivo*. Um arquivo chamado `funcoeszz.sh` será baixado para o seu computador. -->

Baixe o arquivão com todas as Funções ZZ: [funcoeszz-13.2.sh](download/funcoeszz-13.2.sh)

Vá na pasta onde o arquivo foi baixado e teste seu funcionamento:

```console
$ cd ~/Downloads
$ bash funcoeszz-13.2.sh zzcalcula 10+5
15
$
```

Para facilitar o uso, renomeie o arquivo para somente `funcoeszz` e torne-o executável:

```console
$ mv funcoeszz-13.2.sh funcoeszz
$ chmod +x funcoeszz
```

Agora você pode chamar o arquivo diretamente:

```console
$ ./funcoeszz zzcalcula 10+5
15
$
```

Mas bom mesmo é poder chamar cada função individualmente, sem burocracia. Basta rodar o seguinte comando para algumas linhas mágicas serem adicionadas no final de seu arquivo `~/.bashrc`

```console
$ ./funcoeszz zzzz --bashrc
Feito!
As Funções ZZ foram instaladas no /Users/aurelio/.bashrc
$
```

Agora sim, você pode usar as Funções ZZ em toda a sua glória. Abra um novo terminal e divirta-se!

```console
$ zzcalcula 10+5
15
$ zzbissexto
2012 é bissexto
$ zzmaiusculas tá funcionando
TÁ FUNCIONANDO
$
```


## Funções ZZ no Windows

Se você usa Windows, baixe e instale o [Cygwin](http://aurelio.net/cygwin/) ou o [Git](http://git-scm.com/downloads) (que vem com o Git Bash) para poder usar as Funções ZZ.


## Acentuação

Se der problema com a acentuação, baixe a [versão alternativa (iso-8859-1)](download/funcoeszz-13.2-iso.sh) das funções, especial para terminais que ainda não migraram para a codificação UTF-8.


## -bash: zzcalcula: command not found

Se este erro aparecer, certifique-se que há uma chamada para o `.bashrc` dentro de seu `~/.bash_profile`. Se não houver, simplesmente adicione esta linha no final do `~/.bash_profile`:

```
source ~/.bashrc
```


## Versão GitHub

Se você manja de Git, pode clonar [o repositório completo](https://github.com/funcoeszz/funcoeszz) para usar a versão mais recente das funções, que conta com todas as correções.
