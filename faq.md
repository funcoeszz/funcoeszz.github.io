---
title: FAQ das Funções ZZ
---

<div class="toc">
    <ul>
    <li><a href="#nome">Por que o nome Funções ZZ?</a></li>
    <li><a href="#lista-funcoes">Quais são as funções disponíveis?</a></li>
    <li><a href="#opcoes">Quais opções posso usar em uma função?</a></li>
    <li><a href="#requisitos">Como saber se eu possuo todos os comandos necessários?</a></li>
    <li><a href="#outro-shell">Como usar as Funções ZZ no ksh, csh ou outro shell?</a></li>
    <li><a href="#comando-faltando">Erro: Comando não encontrado (command not found)</a></li>
    <li><a href="#lynx-post-data">Erro: lynx: Opção desconhecida -post-data</a></li>
    <li><a href="#proxy">Minha empresa usa proxy!</a></li>
    <li><a href="#proxy-senha">Minha empresa usa proxy autenticado com senha!</a></li>
    <li><a href="#utf-vs-iso">Não entendi nada desse negócio de UTF-8 e ISO-8859-1</a></li>
    </ul>
</div>




<h2 id="nome">Por que o nome Funções ZZ?</h2>

O nome é Funções ZZ porque todas as funções chamam-se zz-alguma-coisa :)

Já este prefixo zz, é necessário para evitar que o nome de uma função seja confundido com algum comando já existente no sistema. Na época (ano de 2000), não achei nenhum comando em minha máquina (Linux), que começava com zz. Por isso escolhi este prefixo.




<h2 id="lista-funcoes">Quais são as funções disponíveis?</h2>

Veja a [lista completa](list.html) aqui no site.

Em sua máquina, chame a função `zzzz`, que lista todas as funções. Ou ainda, digite zz e aperte o TAB duas vezes:

```console
$ zz<tab><tab>
```




<h2 id="opcoes">Quais opções posso usar em uma função?</h2>

Chame a função e use a opção `-h` (ou `--help`) para ver o texto de ajuda. Por exemplo:

```console
$ zzsenha -h

zzsenha
Gera uma senha aleatória de N caracteres únicos (não repetidos).
Obs.: Sem opções, a senha é gerada usando letras e números.

Opções: -p, --pro   Usa letras, números e símbolos para compor a senha
        -n, --num   Usa somente números para compor a senha

Uso: zzsenha [--pro|--num] [n]     (padrão n=8)
Ex.: zzsenha
     zzsenha 10
     zzsenha --num 9
     zzsenha --pro 30

$
```




<h2 id="requisitos">Como saber se eu possuo todos os comandos necessários?</h2>

Use a opção `--teste` da função zzzz para que seja feita uma verificação de todos os comandos necessários para o funcionamento das Funções ZZ.

```console
$ zzzz --teste
Procurando o comando awk...   OK
Procurando o comando bc...    OK
Procurando o comando cat...   OK
Procurando o comando chmod... OK
Procurando o comando clear... OK
Procurando o comando cp...    OK
Procurando o comando cpp...   OK
Procurando o comando cut...   OK
Procurando o comando diff...  OK
Procurando o comando du...    OK
Procurando o comando find...  OK
Procurando o comando grep...  OK
Procurando o comando lynx...  OK
Procurando o comando mv...    OK
Procurando o comando od...    OK
Procurando o comando play...  OK
Procurando o comando rm...    OK
Procurando o comando sed...   OK
Procurando o comando sleep... OK
Procurando o comando sort...  OK
Procurando o comando tr...    OK
Procurando o comando uniq...  OK
Verificando a codificação do sistema... UTF-8
Verificando a codificação das Funções ZZ... UTF-8
$
```




<h2 id="outro-shell">Como usar as Funções ZZ no ksh, csh ou outro shell?</h2>

Se você usa outro shell, ainda assim pode utilizar as Funções ZZ, desde que o shell Bash também esteja instalado em sua máquina.

### tcsh

Use o seguinte comando para instalar as funções em seu `~/.tcshrc`:

```console
$ zzzz --tcshrc
```

### zsh

Use o seguinte comando para instalar as funções em seu `~/.zshrc`:

```console
$ zzzz --zshrc
```

### Outros

Crie um alias para as funções, chamado zz:

```bash
alias zz="/home/FULANO/bin/funcoeszz"
```

> Nota: Use a sintaxe do seu shell. Este exemplo está em Bash.

Feito o alias, agora você pode chamar as funções dessa maneira:

```console
$ zz cores
$ zz calcula 2 + 2
$ zz ipinternet
```

E assim por diante, é só lembrar do espaço após o zz.




<h2 id="comando-faltando">Erro: Comando não encontrado (command not found)</h2>

As funções utilizam vários comandos do sistema para desempenhar suas tarefas. Eles precisam estar instalados em sua máquina para que as funções funcionem corretamente.

Se apareceu uma mensagem na tela dizendo quem um comando não foi encontrado, será preciso instalá-lo.

Para saber quais comandos estão faltando em seu sistema, faça:

```console
$ zzzz --teste
```

[Saiba mais...](#requisitos)




<h2 id="lynx-post-data">Erro: lynx: Opção desconhecida -post-data</h2>

Você possui uma versão antiga do navegador lynx, que ainda não entende a  opção `-post-data`, necessária para o funcionamento de algumas funções.

Atualize o programa lynx para a versão 2.8.4 ou outra mais recente.




<h2 id="proxy">Minha empresa usa proxy!</h2>

Caso você utilize proxy para acesso à Internet, o lynx precisa saber disso. Coloque as seguintes linhas no final de seu arquivo `~/.bashrc`, indicando o endereço do servidor proxy (pode ser o domínio ou o endereço IP) e a porta:

```bash
export http_proxy=http://proxy.dominio.com.br:3128
export https_proxy=https://proxy.dominio.com.br:3128
```




<h2 id="proxy-senha">Minha empresa usa proxy autenticado com senha!</h2>

Primeiro, defina o endereço e porta do proxy, como explicado na dica anterior. Então crie um alias em seu `~/.bashrc` para que o lynx sempre seja chamado com seu usuário e senha, de maneira transparente:

```bash
alias lynx="lynx -pauth=usuario:senha"
```

Se você usa wget em vez do lynx, a sintaxe é esta:

```bash
wget --proxy-user="usuario" --proxy-password="senha"
```




<h2 id="utf-vs-iso">Não entendi nada desse negócio de UTF-8 e ISO-8859-1</h2>

Tudo bem, não é preciso :)

Se as letras acentuadas áéíóú aparecem normalmente, você está com a versão certa das Funções ZZ. Mas se os acentos aparecem estranhos, será preciso baixar outra versão.

Para tirar a dúvida, execute o comando zzzz --teste e veja os resultados do teste de codificação:

```console
$ zzzz --teste
...
Verificando a codificação do sistema... UTF-8
Verificando a codificação das Funções ZZ... UTF-8
$
```

Quando as codificações do sistema e das funções estão iguais, tudo vai funcionar corretamente. Neste exemplo, ambas estavam em UTF-8.

Quando há uma incompatibilidade, será mostrada uma mensagem informando se você deve baixar as funções na versão UTF-8 ou ISO-8859-1. Veja um exemplo:

```console
$ zzzz --teste
...
Verificando a codificaÃ§Ã£o do sistema... ISO-8859-1
Verificando a codificaÃ§Ã£o das FunÃ§Ãµes ZZ... UTF-8

**Atencao**
Ha uma incompatibilidade de codificacao.
Baixe as Funcoes ZZ versao ISO-8859-1.

$
```
