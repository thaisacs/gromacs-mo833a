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
2. *simulation-setup*: gera os arquivos necessários para a simulação (incluindo o *hostfile*);
3. *run*: executa o GROMACS e redireciona a saída padrão do comando para o arquivo chamado `experiment/gmx.out`. Também redireciona a saída de erro para um arquivo chamado *experiment/gmx.err*. Além disso, essa *action* precisa da variável *amount*;
4. *fetch-result*: faz o download do resultado da simulação e dos tempos de execução das paramount iterations (dos arquivos gmx.out e gmx.err) 
para dentro do `~/.clap/fetch_out` e `~/.clap/fetch_err`;

As *actions* podem ser conferidas no diretório `groups/gromacs/` e no arquivo `groups/actions.d/gromacs.ymml`.

#### 4. Clusters

Foi criado três arquivos de configuração de cluster:

1. **cluster-t2.micro-2x:** É um cluster com duas máquinas *t2.micro*.
2. **cluster-t2.micro-4x:** É um cluster com quatro máquinas *t2.micro*.
3. **cluster-t2.micro-8x:** É um cluster com oito máquinas *t2.micro*.

O *cluster-t2.micro-2x.yml* foi responsável por definir os *setups* desses três *clusters*. Esse arquivo é apresentado a seguir.

```
setups:
  config-my-slave:
    groups:
    - name: gromacs/slave

  config-my-master:
    groups:
    - name: gromacs/master

  config-my-after-all:
    actions:
    - type: action
      name: simulation-setup
      group: gromacs

clusters:
  cluster-t2.micro-2x:
    nodes:
      slave:
        type: type-a
        count: 1
        setups:
        - config-my-slave
      master:
        type: type-a
        count: 1
        setups:
        - config-my-master
    after_all:
    - config-my-after-all
```

#### 4. Reprodutibilidade

Para reproduzir este experimento, basta executar os seguintes comandos:

 ```
ssh-keygen -f ~/.clap/private/id_rsa

clapp cluster start cluster-t2.micro-2x
clapp cluster action <cluster-id> gromacs run --extra="amount=2"
clapp cluster action <cluster-id>  gromacs fetch-result
mkdir cluster2
mv fetch-* cluster2
clapp cluster stop <cluster-id>

clapp cluster start cluster-t2.micro-4x
clapp cluster action <cluster-id> gromacs run --extra="amount=4"
clapp cluster action <cluster-id>  gromacs fetch-result
mkdir cluster4
mv fetch-* cluster4
clapp cluster stop <cluster-id>

clapp cluster start cluster-t2.micro-8x
clapp cluster action <cluster-id> gromacs run --extra="amount=8"
clapp cluster action <cluster-id>  gromacs fetch-result
mkdir cluster8
mv fetch-* cluster8
clapp cluster stop <cluster-id>
 ```

A *action fetch-result* transfere para `~/.clap/fetch-out` e `*~/.clap/fetch-err` os arquivos de saída da execução, salvos em `experiments/ativ-7-exp-1/experiment`.

### Resultados

Como cada nó possui `slots=1`, para os *clusters* 2, 4 e 8 foram utilizados **np** com 2, 4 e 8, respectivamente. A seguir é apresentado
o gráfico com os resultados coletados para os três *clusters*.

<p align="center">
  <img width="640" height="480" src="https://raw.githubusercontent.com/thaisacs/gromacs-mo833a/ativ-7-exp-1/experiments/ativ-7-exp-1/results/result.png">
</p>

Os resultados podem ser conferidos na planilha: https://docs.google.com/spreadsheets/d/1HPmszFxJVQt8OPdZFXliWsEdAVEbMoq6rBucTquQQUc/edit?usp=sharing.

##### Cluster 2x

Os resultados podem ser encontrados em *results/cluster2/*. O resumo dos resultados é apresentado na tabela a seguir.

| Iteração | Tempo PI |
|:--------:|:--------------:|
|     1    |     0.0726979  |
|     2    |     0.0635591  |
|     3    |     0.0631659  |
|     4    |     0.061939   |
|     5    |     0.0629649  |
|     6    |     0.0619841  |
|     7    |     0.062887   |
|     8    |     0.0625131  |
|     9    |     0.0628109  |
|    10    |     0.0626581  |
|   Média  |     0.067678   |

##### Cluster 4x

Os resultados podem ser encontrados em *results/cluster4/*. O resumo dos resultados é apresentado na tabela a seguir.

| Iteração | Tempo PI |
|:--------:|:--------------:|
|     1    |     0.037277   |
|     2    |     0.033906   |
|     3    |     0.0337508  |
|     4    |     0.034075   |
|     5    |     0.0338831  |
|     6    |     0.0335238  |
|     7    |     0.0335271  |
|     8    |     0.0339069  |
|     9    |     0.0339868  |
|    10    |     0.0337179  |
|   Média  |     0.03549745 |

##### Cluster 8x

Os resultados podem ser encontrados em *results/cluster8/*. O resumo dos resultados é apresentado na tabela a seguir.

| Iteração | Tempo PI |
|:--------:|:--------------:|
|     1    |     0.021596   |
|     2    |     0.0200899  |
|     3    |     0.0198989  |
|     4    |     0.0201089  |
|     5    |     0.020417   |
|     6    |     0.0200429  |
|     7    |     0.0218711  |
|     8    |     0.021605   |
|     9    |     0.0216119  |
|    10    |     0.0198371  |
|   Média  |     0.02071655 |
