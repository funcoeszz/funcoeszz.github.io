# Fontes do site das Funções ZZ

Aqui estão os fontes do site das Funções ZZ, no ar em <https://funcoeszz.net>.

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

* O que precisa ser PHP, como a API das funções e o ZZ a la carte, ficam em subdomínios, hospedados no DreamHost.


## Estrutura do site

* [css/site.css](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/css/site.css) – Arquivo CSS com os estilos do site.

* [css/monokai.css](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/css/monokai.css) – Syntax highlight para os códigos e linhas de comando nas tags `<PRE>`.

* [_layouts/default.html](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/_layouts/default.html) – Template usado em todas as páginas. Aqui se edita o formato geral e o menu.

* [_data/*](https://github.com/funcoeszz/funcoeszz.github.io/tree/master/_data) – Arquivos de dados no formato YAML, usados para construir algumas páginas. Veja detalhes no [_data/README.md](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/_data/README.md).

* [_config.yml](https://github.com/funcoeszz/funcoeszz.github.io/blob/master/_config.yml) – Arquivo de configuração do site, usado pelo Jekyll.

* O resto são os arquivos normais de conteúdo do site, alguns em Markdown, alguns já em HTML.


## Desenvolvimento local

É melhor editar os arquivos direto pelo site do GitHub, mas se fizer questão de rodar localmente para ver como fica, há algumas opções.

- Use um contêiner Docker que tenha a gem `github-pages` instalada numa versão recente, para não precisar instalar nada em sua máquina. [Este por exemplo](https://github.com/Starefossen/docker-github-pages):

        docker run -it --rm -v "$PWD":/usr/src/app -p 4000:4000 starefossen/github-pages

- Use a gem `github-pages` para instalar em sua máquina todos os requisitos. Instruções em https://github.com/github/pages-gem.
