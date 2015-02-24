# Fontes do site das Funções ZZ

Aqui estão os fontes do site das Funções ZZ, no ar em <http://funcoeszz.net>.

**Correções e sugestões são muito bem-vindas!**

No final de cada página do site há um link direto para o seu arquivo-fonte no GitHub, pronto para você editar.

> Recomendo editar estes arquivos diretamente pelo site do GitHub em vez de baixá-los para sua máquina. É mais rápido e mais fácil.

## Nerdices

* O site é hospedado diretamente no GitHub, usando o esquema de [GitHub Pages](https://pages.github.com/).

* Após cada commit neste repositório, o site é reconstruído automaticamente e a alteração já vai pro ar.

* A ferramenta que constrói o site, convertendo os arquivos Markdown para HTML e aplicando o template em todas as páginas é o [Jekyll](http://jekyllrb.com/).

* No template e nas páginas Markdown e HTML, é possível usar uma linguagem simples chamada [Liquid](https://github.com/Shopify/liquid/wiki/Liquid-for-Designers), para fazer loops, condicionais e filtros, quando necessário. As tags são `{% … %}` para comandos e `{{ … }}` para inserir texto na página. Exemplo usado no [list.html](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/list.html):

  ```html
  {% for item in site.data.list %}
  <tr>
      <td>{{ forloop.index }}</td>
      <td><a href="man.html#{{ item[0] }}">{{ item[0] }}</a></td>
      <td>{{ item[1] | escape }}</td>
  </tr>
  {% endfor %}
  ```

* No final, temos um site 100% estático usando somente arquivos HTML. Não há PHP nem qualquer processamento no servidor.

* O que precisa ser PHP, como a versão online das funções e o ZZ a la carte, ficam em subdomínios, hospedados no DreamHost.


## Estrutura do site

* [css/site.css](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/css/site.css) – Arquivo CSS com os estilos do site.

* [css/monokai.css](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/css/monokai.css) – Syntax highlight para os códigos e linhas de comando nas tags `<PRE>`.

* [_layouts/default.html](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/_layouts/default.html) – Template usado em todas as páginas. Aqui se edita o formato geral e o menu.

* [_data/*](https://github.com/funcoeszz/funcoeszz.github.io/tree/master/_data) – [Arquivos de dados](http://jekyllrb.com/docs/datafiles/) no formato [YAML](http://pt.wikipedia.org/wiki/YAML), com a lista completa de todas as funções disponíveis e sua descrição e texto de ajuda. Estes dados são usados para construir algumas páginas, como a que lista as funções ([fontes](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/list.html), [resultado](http://funcoeszz.net/list.html)) e a man page ([fontes](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/man.html), [resultado](http://funcoeszz.net/man.html)). Estes arquivos YAML são gerados automaticamente pelos scripts `.sh` na mesma pasta, execute-os sempre que novas funções forem criadas.

* [_config.yml](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/_config.yml) – Arquivo de configuração do site, usado pelo Jekyll.

* [Gemfile](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/Gemfile), [Gemfile.lock](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/Gemfile.lock) – Esquema da linguagem Ruby para especificar os plugins usados pelo site. É necessário para poder rodar o site localmente, usando o mesmo ambiente do servidor. Mas você não precisa se preocupar com isso, pode ignorar estes arquivos.

* O resto são os arquivos normais de conteúdo do site, alguns em Markdown, alguns já em HTML.


## Desenvolvimento local

É melhor editar os arquivos direto pelo site do GitHub, mas se fizer questão de rodar localmente:

```console
$ bundle install                # Instalar plugins
$ bundle update github-pages    # Atualizar plugins
$ bundle exec jekyll serve      # Rodar o site localmente
```
