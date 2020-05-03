## Atividade 5 - Experimento 1

Esta atividade visa realizar a execução do gromacs com MPI na nuvem. Para isso, é necessário a realização das seguintes etapas:

 1. Configurando uma máquina;
 2. Configurando a chave RSA;
 3. Configurando o GROMACS;
 4. Criando a imagem base;
 5. Configurando a rede de interconexão; e
 6. Selecionando e configurando múltiplas instâncias.

 cada uma das etapas são detalhados a seguir.

### Configurando uma máquina

A primeira coisa a se fazer é realizar a configuração de uma máquina. Para isso basta acessar o EC2 dashboard da AWS e clique na opção **launch instance**. Em cada passo da configuração, siga as seguintes recomendações:

 1. Selecionar a Amazon Machine Image (AMI) **Ubuntu Server 18.04 LTS (HVM), SSD Volume Type**;
 2. Selecionar o tipo da instância **t2.micro** e clicar em **Next: Configure Instance Details**;
 3. No campo *Advanced Details*, seleciona *as Text* e dentro de *user data* coloque *script* apresentado a seguir. Após isso, selecionar **Next: Add Storage**;

```
#!/bin/bash
sudo apt-get update
sudo apt-get install -y wget make gcc libgfortran3 \
sysstat libibnetdisc-dev openmpi-bin libopenmpi-dev \
libhdf5-openmpi-dev gfortran build-essential git cmake
```

 4. Clicar em **Next: Add Tags**;
 5. Clicar em **Next: Configure Security Group**;
 6. Clicar em **Review and Launch**;
 7. Clicar em **Launch**, então criar uma nova *key group* e realizar o *download* dela. Após isso, clicar em **Launch Instances**.

#### Configurando a chave RSA
Antes de gerar a imagem é necessário configurar a chave RSA para permitir o acesso  por SSH livre entre as máquinas. Primeiramente, é necessário entrar na máquina virtual. Para isso execute o seguinte comando

```
ssh -i "<key-part-path>" ubuntu@<public-dns>
```

Após isso, basta executar

```
ssh-keygen
```

Não precisa alterar nenhuma configuração, basta executar *enter* em todas as etapas desse comando. Após isso, é necessário executar o seguinte comando

```
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

#### Configurando o GROMACS

Para configurar o GROMACS basta, dentro da VM, executar os seguintes comandos

```
git clone https://github.com/thaisacs/gromacs-mo833a.git
cd gromacs-mo833a
git checkout ativ-5-exp-1
cd experiments/ativ-5-exp-1
./script-build.sh
./script-config.sh
```

#### Criando a imagem base

Depois de tudo configurado, é necessário ir até o *dashboard* da AWS, selecionar a instância gerada e então ir até *Actions* > *Image*  > *Create image*. Na janela de criação, preencha o campo *Image name* com o nome da imagem desejado e o campo *Image Description* com uma pequena descrição de AMI.

#### Configurando a rede de interconexão

No *dashboard* EC2, encontre a opção de *Security Groups* e selecione *Create Security Group*. Preencher o campo *Security group name*  e o campo *Description*. Após isso, clique no botão *Create security group*. Na tela que apareceu, clique em *Edit inbound rules*. Adicione novas duas regras, como na figura a seguir e clique em *Save rules*.

![](https://raw.githubusercontent.com/thaisacs/gromacs-mo833a/ativ-5-exp-1/experiments/ativ-5-exp-1/imgs/network.png)

#### Selecionando e configurando múltiplas instâncias

Utilizando a imagem base é necessário criar duas VMs para de fato executar o GROMACS. Para isso basta acessar o EC2 dashboard da AWS e clique na opção **launch instance**. Em cada passo da configuração, siga as seguintes recomendações:

 1. Clique em *My AMI* e selecione a imagem criada anteriormente;
 2. Selecionar o tipo da instância **t2.micro** e clicar em **Next: Configure Instance Details**;
 3. Altere o campo *Number of instances* para 2. No campo *Add instance to placement group*, seleciona *Add to a new placement group* e dê um nome para o novo *placement group*. Após isso, selecione **Next: Add Storage**;
 4. Clique em **Next: Add Tags**;
 5. Clique em **Next: Configure Security Group**;
 6. No campo *Assign a security group*, altere para *Select an **existing** security group* e selecione o *security group* criado anteriormente. Clique em **Review and Launch**;
 7. Clique em **Launch**, selecione a *key group* criada anteriormente e clique em **Launch Instances**.

#### Executando o GROMACS

Após as duas VMs configuradas e executando, acesse uma das VMs e entre no diretório *experiments* > *exp-5-ativ-1*.  Dentro do diretório *experiments* > *exp-5-ativ-1* configure o arquivo *hostfile* executando os seguintes comandos

```
echo "<IP1> slots=2" > hostfile
echo "<IP2> slots=2" >> hostfile
```

substituindo **IP1** e **IP2** pelos IPs das duas VMs criadas. Após isso execute o comando

```
./script-exec.sh
```

Depois que terminar o experimento, é só parar e terminar as três VMs.

A seguir é apresentado o *wall time clock* encontrado para cada execução.

## Resultados
| Nodes | Tempo(s) |
|-------|----------|
|  1    |  368.81  |
|  2    | 1479.92s |
|  4    | 896.13s  |


