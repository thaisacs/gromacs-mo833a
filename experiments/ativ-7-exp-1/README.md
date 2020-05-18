# Atividade 7 - Experimento 1


Nesta atividade o objetivo foi desenvolver *scripts* para automatizar a criação de nós na nuvem computacional e a execução da aplicação gmx (que foi modificada para reportar o tempo das paramount iterations na atividade 6) com o CLAP. Para isso foi necessário a execução das seguintes atividades:

1. Alterar a classe **KernelStats** da atividade 6;
2. Instrumentar o GROMACS para terminar as *paramount iterations* com 10 iterações;
3. Criação do grupo GROMACS no CLAP;
4. Criação dos *clusters* no CLAP;

A seguir é detalhado cada atividade e os resultados encontrados.

#### 1. **KernelStats**


Como para instrumentar a aplicação foi criada a classe **KernelStats** na atividade 6. Foi necessário que essa classe permitisse acessar o atributo *iterations*. Para isso, foi necessário adicionar o *get* desse atributo. A seguir é apresentado o `usr/kernelstats/kernel_stats.h` com a alteração feita.

```
#include <sys/time.h>

namespace gmx {
  class KernelStats {
    int iteration = 0;
    double init_time;
    double begin_time;

    double get_time();
  public:
    void init_timestep();
    void begin_timestep();
    void end_timestep();
    int get_iteration();
  };
}

gmx::KernelStats KS;
```

A implementação do *get_iteration* feita no `usr/kernelstats/kernel_stats.cpp` é apresentada a seguir.

```
int KernelStats::get_iteration() {
  return iteration;
}
```

#### 2. Instrumentação

Para evitar que a simulação seja executada até o final e fazer com que o GROMACS pare após executar 10 iterações, foi adicionado no final da *paramount iteration*
(loop dentro da `LegacySimulator::do_steep()` no arquivo `src/gromacs/mdrun/minimize.cpp`) o seguinte código.

```
if(KS.get_iteration() == 10) {
  bDone  = TRUE;
}
```

#### 3. Grupo GROMACS

O grupo GROMACS foi criado com as seguintes *actions*: *setup*, *simulation-setup*, *run* e *fetch-result*. Onde,

1. *setup*: configura a máquina virtual com todas as bibliotecas necessárias e instala o GROMACS;
2. *simulation-setup*: gera os arquivos necessários para a simulação;
3. *run*: executa o GROMACS e redireciona a saída padrão do comando para o arquivo chamado `experiment/gmx.out`. Também redireciona a saída de erro para um arquivo chamado *experiment/gmx.err*. Além disso, essa *action* precisa da variável *amount*;
4. *fetch-result*: faz o download do resultado da simulação e dos tempos de execução das paramount iterations (dos arquivos gmx.out e gmx.err) 
para dentro do `~/.clap/fetch_out` e `~/.clap/fetch_err`;

Além dessas *actions*, também implementei a *config-host* que após a inicialização do *cluster*, gera o arquivo *hostfile* com o *private ip* de todos os *hosts* em todos os nós. 

#### 4. Clusters

Foi criado três arquivos de configuração de cluster:

1. **cluster-t2.micro-2x:** É um cluster com duas máquinas *t2.micro*.
2. **cluster-t2.micro-4x:** É um cluster com quatro máquinas *t2.micro*.
3. **cluster-t2.micro-8x:** É um cluster com oito máquinas *t2.micro*.

O *cluster-t2.micro-2x.yml* foi responsável por definir os *setups* desses três *cluster*. Esse arquivo é apresentado a seguir.

```
setups:
  config-my-node:
    groups:
    - name: gromacs

    actions:
    - type: action
      name: simulation-setup
      group: gromacs

  config-my-after-all:
    actions:
    - type: action
      name: config-host
      group: gromacs

clusters:
  cluster-t2.micro-2x:
    nodes:
      slave:
        type: type-a
        count: 1
        setups:
        - config-my-node
      master:
        type: type-a
        count: 1
        setups:
        - config-my-node
    after_all:
    - config-my-after-all
```


Note que a *action config-host* é executada no *after_all*.
Ao mesmo tempo, os nós *slaves* e *master* além de executarem a *setup* no início, também executam o *simulation-setup*.
Além disso, as *actions* do *group* GROMACS foram definidas em `groups/gromacs`.

#### 4. Scripts

Para iniciar um cluster com os templates dessa atividade basta configurar o *script-clap.sh*. Que possui o seguinte template.

 ```
ssh-keygen -f ~/.clap/private/id_rsa
clapp cluster start cluster-t2.micro-[2-4-8]x
clapp cluster action <cluster-id> gromacs run --extra="amount=NUMBER" --nodes <master-id>
clapp cluster action <cluster-id>  gromacs fetch-result --nodes <master-id>
 ```

onde, [2-4-8] deve ser substituído apenas para um dos três valores; NUMBER é o parâmetro **np** do MPI; cluster-id e master-id são o id
do cluster e do nó master, respectivamente. A *action fetch-result* transfere para `~/.clap/fetch-out` e `*~/.clap/fetch-err` os arquivos de
saída da execução, salvos em `experiments/ativ-7-exp-1/experiment`.

### Resultados

Como cada nó possui `slots=2`, para os *clusters* 2, 4 e 8 foram utilizados **np** com 4, 8 e 16, respectivamente. A seguir é apresentado
o gráfico com os resultados coletados para os três *clusters*.

<p align="center">
  <img width="640" height="480" src="https://raw.githubusercontent.com/thaisacs/gromacs-mo833a/ativ-7-exp-1/experiments/ativ-7-exp-1/results/result.png">
</p>

##### Cluster 2x

Os resultados podem ser encontrados em *results/cluster2/*. O resumo dos resultados é apresentado na tabela a seguir.

| Iteração | Média do Tempo |
|:--------:|:--------------:|
|     1    |     0.0969     |
|     2    |     0.1008     |
|     3    |     0.1025     |
|     4    |     0.1067     |
|     5    |     0.1107     |
|     6    |     0.1107     |
|     7    |     0.1118     |
|     8    |     0.1119     |
|     9    |     0.1119     |
|    10    |     0.1151     |
|   Média  |     0.1079     |

##### Cluster 4x

Os resultados podem ser encontrados em *results/cluster4/*. O resumo dos resultados é apresentado na tabela a seguir.

| Iteração | Média do Tempo |
|:--------:|:--------------:|
|     1    |     0.1004     |
|     2    |     0.1017     |
|     3    |     0.1026     |
|     4    |     0.1033     |
|     5    |     0.1038     |
|     6    |     0.1049     |
|     7    |     0.1053     |
|     8    |     0.1059     |
|     9    |     0.1051     |
|    10    |     0.1061     |
|   Média  |     0.1039     |

##### Cluster 8x

Os resultados podem ser encontrados em *results/cluster8/*. O resumo dos resultados é apresentado na tabela a seguir.

| Iteração | Média do Tempo |
|:--------:|:--------------:|
|     1    |     0.0747     |
|     2    |     0.0755     |
|     3    |     0.0765     |
|     4    |     0.0774     |
|     5    |     0.0782     |
|     6    |     0.0787     |
|     7    |     0.0789     |
|     8    |     0.0797     |
|     9    |     0.0805     |
|    10    |     0.0816     |
|   Média  |     0.0782     |

##### Inicialização

Uma informação importante é o fato de que quanto maior a quantidade de nós, maior o tempo de inicialização. Isso pode ser observado na tabela a seguir.

| Cluster | Média do Tempo |
|:-------:|:--------------:|
|    2x   |    0.6975395   |
|    4x   |    1.314955    |
|    8x   |    1.654835    |
