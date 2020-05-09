## Atividade 6- Experimento 1

Esta atividade visa instrumentar o código para imprimir o tempo de inicialização (tempo do início da função main até o início da primeira paramount iteration) e o tempo de cada *paramount iteration*.

### KernelStats

A classe **KernelStats** foi adicionada no diretório *usr/kernelstats*. Essa classe possui três métodos púbicos: *init_timestep*, *begin_timestep* e *end_time step*. O método *init_timestep* deve ser chamado pela *main*, pois é responsável por coletar o tempo de inicialização da *main* e armazenar no atributo *init_time*. Após isso, ela envia para a saída *std::cout* o tempo coletado. Já o método *begin_timestep* deve ser chamado para começar a medir o tempo da *paramount iteration*. Dessa forma, esse método coleta o tempo atual e atribui no atributo *begin_time*. Já o método *end_time step* é responsável por coletar o tempo atual e subtrair desse tempo o *begin_time*, ou seja, deve ser executado no final da *paramount iteration*. Além disso, ele envia para a saída *std::cout* o tempo calculado. Essa classe também possui o método privado *get_time* que é responsável por coletar o tempo atual da execução da aplicação.

### Scripts

Para execumentar o experimento basta executar os *scripts* na seguinte ordem:

1. **script-build.sh**: Compila o *gromacs* no modo *release*;
2. **script-config**: Após a compilação, configura o ambiente para executar o experimento. Configuração é realizada na pasta *experiment*;
3. **script-exec**: Executa o experimento gerando o arquivo de resultados output.csv na pasta *experiment*;

### Resultados

![]()

Tempo gasto da inicialização até o primeiro *loop*: Xs.
