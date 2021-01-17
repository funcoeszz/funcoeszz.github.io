---
title: Download e instalação
redirect_from:
  - /download.html
  - /instalacao.html
  - /passado/
---

<!-- > Dica: Sabia que você também também pode usar as Funções ZZ [direto no navegador](http://funcoeszz.net/online/), ou [em seu iPhone](http://itunes.apple.com/br/app/funcoes-zz/id492258680?mt=8)? -->

<!-- > Dica: Manja de git? Então [baixe o repositório completo](https://github.com/funcoeszz/funcoeszz) e seja feliz! -->

<!-- > Vá no [Funções ZZ à la carte](/a-la-carte/?zz=*), escolha as funções desejadas e aperte o botão *Baixar arquivo*. Um arquivo chamado `funcoeszz.sh` será baixado para o seu computador. -->

Baixe o arquivão com todas as Funções ZZ: [funcoeszz-{{ site.data.versions.last }}.sh](/download/funcoeszz-{{ site.data.versions.last }}.sh)

Vá na pasta onde o arquivo foi baixado e teste seu funcionamento:

```console
$ cd ~/Downloads
$ bash funcoeszz-{{ site.data.versions.last }}.sh zzcalcula 10+5
15
$
```

Para facilitar o uso, renomeie o arquivo para somente `funcoeszz` e torne-o executável:

```console
$ mv funcoeszz-{{ site.data.versions.last }}.sh funcoeszz
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
$ zzconverte mk 100
100 milhas = 160.900 km
$ zzmaiusculas tá funcionando
TÁ FUNCIONANDO
$
```


## Funções ZZ no Windows

Se você usa Windows, baixe e instale o [Cygwin](http://aurelio.net/cygwin/) ou o [Git](http://git-scm.com/downloads) (que vem com o Git Bash) para poder usar as Funções ZZ.


## Acentuação

Se der problema com a acentuação nos resultados das funções, use o script [release/2iso.sh](https://github.com/funcoeszz/funcoeszz/blob/master/release/2iso.sh) para converter o arquivo das funções para o formato antigo (ISO-8859-1), especial para terminais que ainda não migraram para a codificação UTF-8.


## -bash: zzcalcula: command not found

Se este erro aparecer, certifique-se que há uma chamada para o `.bashrc` dentro de seu `~/.bash_profile`. Se não houver, simplesmente adicione esta linha no final do `~/.bash_profile`:

```
source ~/.bashrc
```


## Versão GitHub

Se você manja de Git, pode clonar [o repositório completo](https://github.com/funcoeszz/funcoeszz) para usar a versão mais recente das funções, que conta com todas as correções.


## Versões antigas

Para fins históricos somente, não são mais utilizáveis.

<ul>
{% for version in site.data.versions %}
  {% unless forloop.last %}
    <li><a href="/download/funcoeszz-{{ version }}.sh">{{ version }}</a></li>
  {% endunless %}
{% endfor %}
</ul>
