### Atividade 3 - Experimento 1

Esta feature adiciona os seguintes itens:

- Mensura e reporta o tempo de execução da chamada da função runner.mdrunner() no arquivo src/programs/mdrun/mdrun.cpp;
- Adiciona o *script-build.sh* para fazer o build do gramocs no modo Debug ou Release;
- Adiciona o *script-config.sh* que realiza a configuração para a execução do experimento;
- Adiciona o *script-exp.sh* que realiza a execução do experimento;
- Adiciona o *script-analyze.py* que realiza a geração dos gráficos;

Deve-se tomar cuidado com a variavel **DIR** do *script-build.sh* pois ela deve conter o caminho para o *gromacs*.
A seguir é detalhado cada script desenvolvido.

### Experimentos

Para realizar os experimentos foi desenvolvido 4 scripts: **script-build.sh**, **script-config.sh**, **script-exp.sh** e **script-analyze.py**.

#### script-build.sh
Implementado em *bash script*, esse *script* realiza a compilação do *gromacs* de acordo com o modo escolhido. Para a compilação no modo *Debug*, basta executar o comando a seguir:

```
./script-build.sh Debug
```

Já para a compilação no modo *Release*, basta executar:

```
./script-build.sh Release
```

#### script-config.sh

Implementado em *bash script*, esse *script* realiza a configuração necessário para realizar a simulação para encontrar o ponto de energia mínima da estrutura de cristal de uma cadeia de repetição HR2 do novo 2019-nCoV (Corona Virus) solvido em água e íons. Esse *script* necessita dos arquivos *6LVN.pdb* e  *ions.mdp* na pasta *config*. Não é necessário nenhum parâmetro extra e ele é responsável pela geração da pasta *experiments*, com as configurações do experimento.

#### script-exp.sh

Implementado em *bash script*, esse *script* realiza o experimento executando o *gromacs* compilado na pasta *build* na raiz do repositório. Esse *script* depende da execução do **script-config.sh**. Ele realiza 99 execuções da simulação, gerando um arquivo *output.txt* com as saídas da instrumentação e um arquivo csv, com o nome passado por parâmetro, apenas com os dados coletados. Para executar esse *script* basta executar:

```
./script-exp.sh <csv-file-name>
```

onde, *csv-file-name* é o nome do arquivo csv que será gerado com os dados resultantes do experimento. Os arquivos de saída são armazenados na pasta *experiments* criada pelo *script* anterior.

#### script-analyze.py

Implementado em *python3*, este script é responsável pela geração do gráfico de regressão linear com intervalo de confiança de 95% e a geração de um histograma normalizado. Esse script possui as seguintes dependências:  *seaborn*, *matplotlib*, *pandas* e *numpy*. Para gerar um gráfico basta executar o seguinte comando:

```
python3 script-analyze.py <csv-file-path> <opção>
```

onde, *csv-file-path* é o caminho até o arquivo .csv com os dados e a opção pode ser: 1 (regressão linear) ou 2 (histograma).

### Exemplo

Um exemplo de experimento seria a execução dos seguintes comandos:

```
./script-build.sh Release
./script-config.sh
./script-exp.sh release.csv
python3 script-analyze.py experiments/release.csv 1
python3 script-analyze.py experiments/release.csv 2
```
