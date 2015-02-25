# Arquivos de dados YAML

### help.yml

* Lista de todas as funções e seus textos de ajuda.
* Este arquivo é gerado automaticamente pelo script [help.yml.sh](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/_data/help.yml.sh).
* Usado na página de manual: [fontes](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/man.html), [resultado](http://funcoeszz.net/man.html).

### list.yml

* Lista de todas as funções e suas descrições.
* Este arquivo é gerado automaticamente pelo script [list.yml.sh](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/_data/list.yml.sh).
* Usado na página que lista as funções: [fontes](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/list.html), [resultado](http://funcoeszz.net/list.html).

### versions.yml

* Guarda todas as versões das Funções ZZ que estão disponíveis para download.
* A ordem é crescente, então o último item é a versão mais recente.
* Usado na página de download: [fontes](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/download/index.md), [resultado](http://funcoeszz.net/download/).


## Instruções

Os arquivos de dados estão no formato [YAML](http://pt.wikipedia.org/wiki/YAML), usados pelo [Jekyll](http://jekyllrb.com/) para construir as páginas do site.

> Saiba mais: <http://jekyllrb.com/docs/datafiles/>

O YAML é similar ao JSON, e serve para definir Arrays (lista de valores) e Hashes (chave:valor). Na prática, estes arquivos servem como um banco de dados simples.

Há uma sintaxe especial para inserir estes dados nas páginas do site, e ferramentas para manipulá-los. É o sistema de templates  [Liquid](https://github.com/Shopify/liquid/wiki/Liquid-for-Designers).


## Arrays (listas)

No arquivo [versions.yml](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/_data/versions.yml) está a lista das versões da Funções ZZ. É um Array simples, com vários itens. Veja um trecho:

```yaml
- "6.11"
- "7.7"
- "8.3"
- "8.6"
- "8.7"
- "8.9"
- "8.10"
- "10.12"
- "13.2"
```

Dentro da página do site, seja ela Markdown ou HTML, você pode referenciar este arquivo pelo seu path, usando uma notação de objetos, e sem o `.yml`: `_data/versions.yml` vira `site.data.versions`. Como este arquivo representa um array, podemos usar os métodos especiais para arrays, como `size`, `first`, `last` ou fazer um loop.

Exemplo de uso:

```html
<p>Há um total de {{ site.data.versions.size }} versões registradas.</p>

<p>A versão mais recente é a {{ site.data.versions.last }}.</p>

<p>Segue a lista de links para todas as versões:</p>

<ul>
    {% for version in site.data.versions %}
        <li><a href="/download/funcoeszz-{{ version }}.sh">{{ version }}</a></li>
    {% endfor %}
</ul>
```

No Liquid as tags são `{% … %}` para comandos e `{{ … }}` para inserir texto na página.


## Hashes (dicionários)

O arquivo  [list.yml](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/_data/list.yml) é um Hash, ou seja, um dicionário de chave:valor que usamos para guardar o nome da função e a sua descrição. Veja um trecho:

```yaml
zzajuda:        "Mostra uma tela de ajuda com explicação e sintaxe de todas as funções."
zzaleatorio:    "Gera um número aleatório, conforme o $RANDOM no bash."
zzalfabeto:     "Central de alfabetos (romano, militar, radiotelefônico, OTAN, RAF, etc)."
zzalinhar:      "Alinha um texto a esquerda, direita, centro ou justificado."
zzansi2html:    "Converte para HTML o texto colorido do terminal (códigos ANSI)."
zzarrumacidade: "Arruma o nome da cidade informada: maiúsculas, abreviações, acentos, etc."
zzarrumanome:   "Renomeia arquivos do diretório atual, arrumando nomes estranhos."
zzascii:        "Mostra a tabela ASCII com todos os caracteres imprimíveis (32-126,161-255)."
```

Igual no exemplo anterior, a notação para acessá-lo é o seu path: `site.data.list`. Como ele é um Hash, podemos acessar suas chaves diretamente:

```html
<p>A descrição da zzascii é: {{ site.data.list.zzascii }}</p>
```

Também é possível fazer loops em Hashes. A ordem original dos dados é preservada e dentro do loop, a chave é o `item[0]` e o valor é `item[1]`. Veja um exemplo, mostrando a lista completa das funções e suas descrições:

```html
<ul>
    {% for item in site.data.list %}
        <li><b>{{ item[0] }}</b>: {{ item[1] | escape }}</li>
    {% endfor %}
</ul>
```
