## Atividade 5 - Experimento 1

Esta atividade visa realizar a execução do gromacs com MPI na nuvem. Para isso, é necessário a realização das seguintes etapas:

 1. Configurando uma máquina para geração de imagem;
 2. Criando a imagem base; e
 3. Selecionando e configurando múltiplas instâncias.

 cada uma das etapas são detalhados a seguir.

### Configurando uma máquina para geração de imagem

A primeira coisa a se fazer é realizar a configuração de uma máquina. Para isso basta acessar o EC2 dashboard da AWS e clique na opção **launch instance**. Em cada passo da configuração, siga as seguintes recomendações:

 1. Selecionar a Amazon Machine Image (AMI) **Ubuntu Server 18.04 LTS (HVM), SSD Volume Type**;
 2. Selecionar o tipo da instância **t2.micro** e clicar em **Next: Configure Instance Details**;
 3. No campo *Advanced Details*, seleciona *as Text* e dentro de *user data* configure o seguinte *script*.
``
#!/bin/bash
``
``
sudo apt-get update
sudo apt-get install -y wget make gcc libgfortran3 \
sysstat libibnetdisc-dev openmpi-bin libopenmpi-dev \
libhdf5-openmpi-dev gfortran build-essential git cmake
``

#### Criando a imagem base


#### Selecionando e configurando múltiplas instâncias
