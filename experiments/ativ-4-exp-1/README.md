### Atividade 4 - Experimento 1

- Adiciona algumas imagens do kcachegrind utilizadas para traçar o perfil do gromacs;
- Adiciona o *script-build.sh* para fazer o build do gramocs no modo Debug ou Release;
- Adiciona o *script-config.sh* que realiza a configuração para a execução do experimento;
- Adiciona o *script-exp.sh* que realiza a execução do experimento;

Deve-se tomar cuidado com a variável **DIR** do *script-build.sh* pois ela deve conter o caminho para o *gromacs*.
A seguir é detalhado cada script desenvolvido.

#### script-build.sh
Implementado em *bash script*, esse *script* realiza a compilação do *gromacs* de acordo com o modo escolhido. Para a compilação no modo *Debug*, basta executar o comando a seguir:

```
./script-build.sh Debug
```

Já para a compilação no modo *Release*, basta executar:

```
./script-build.sh Release
```

Para compilar no modo *Release* sem paralelismo:

```
./script-build.sh No-Parallel
```

#### script-config.sh

Implementado em *bash script*, esse *script* realiza a configuração necessário para realizar a simulação para encontrar o ponto de energia mínima da estrutura de cristal de uma cadeia de repetição HR2 do novo 2019-nCoV (Corona Virus) solvido em água e íons. Esse *script* necessita dos arquivos *6LVN.pdb* e  *ions.mdp* na pasta *config*. Não é necessário nenhum parâmetro extra e ele é responsável pela geração da pasta *experiments*, com as configurações do experimento.

#### script-exp.sh

Implementado em *bash script*, esse *script* realiza o experimento executando o *gromacs* compilado na pasta *build/release* na raiz do repositório.
Esse *script* depende da execução do **script-config.sh**. Ele realiza 3 execuções da aplicação (uma sem ferramenta, outra com o perf e outra com o valgrind), 
gerando três arquivos com o tempo de execução: *output.txt*, *output-perf.txt* e *output-valgrind.txt*. Para executar esse *script* basta executar:

```
./script-exp.sh
```

Os arquivos de saída são armazenados na pasta *experiments* criada pelo *script* anterior.
Caso a versão compilada seja sem OPEN-MP, basta executar:

```
./script-exp.sh no-openmp
```
### Exemplo

Um exemplo de experimento seria a execução dos seguintes comandos:

```
./script-build.sh Release
./script-config.sh
./script-exp.sh
```
