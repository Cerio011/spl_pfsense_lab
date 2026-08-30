## Atividade Avaliativa – Documentação do Ambiente de Laboratório de Resposta a Incidentes

Claudio Henrique Silva

[1. Introdução ............................................................................................ 1](#page-0)

[1.1 Propósito do Laboratório ................................................................... 1](#page-0)

[1.2 Descrição dos Ativos e Funções no Ambiente ..................................... 1](#page-0)

[2. Escopo da Infraestrutura ........................................................................ 2](#page-0)

[2.1 Arquitetura da Rede do Laboratório .................................................... 3](#page-0)

[3. Instalação e Configuração dos Ativos ...................................................... 4](#page-0)

[3.1 Ativos on-premise ............................................................................. 4](#page-0)

[3.1.1 Pfsense/Snort ............................................................................. 4](#page-0)

[3.1.2 Kali ............................................................................................ 7](#page-0)

[3.2 Ativos em nuvem .............................................................................. 8](#page-0)

[3.2.1 Host orquestrador Terraform/Ansible ............................................ 9](#page-0)

[3.2.2 Host orquestrado Terraform/Ansible ........................................... 12](#page-0)

[3.2.3 Windows server ........................................................................ 12](#page-0)

[3.2.4 SIEM Splunk ............................................................................. 13](#page-0)

[4. Conclusão .......................................................................................... 14](#page-0)

[4.1 Limitações técnicas ........................................................................ 14](#page-0)

[4.2 Sugestões de melhorias para o ambiente de laboratório. ................... 14](#page-0)


## 1. Introdução

## 1.1 Propósito do Laboratório

O presente laboratório foi construído com o objetivo de simular, em ambiente controlado, uma infraestrutura de rede corporativa minimamente realista, permitindo a prática de conceitos de Resposta a Incidentes e monitoramento de segurança. A proposta deste trabalho contempla a implementação de um ambiente híbrido, combinando virtualização on-premise (Oracle VM VirtualBox) e infraestrutura em nuvem (AWS), reproduzindo um cenário comum em ambientes corporativos atuais, nos quais parte dos ativos permanece local e parte é hospedada em provedores de nuvem pública.

Como ferramenta de SIEM, optou-se pela utilização do Splunk Enterprise, em substituição ao QRadar CE originalmente sugerido no escopo da atividade, dada a maior familiaridade prévia do autor com a ferramenta e sua ampla adoção no mercado de Segurança da Informação, especialmente em operações de SOC (Security Operations Center). Essa adaptação não compromete os objetivos pedagógicos da disciplina, uma vez que os conceitos de coleta, correlação e monitoramento de logs permanecem os mesmos, independentemente da plataforma de SIEM utilizada.

O ambiente foi projetado para permitir, futuramente, a simulação de incidentes de segurança possibilitando a análise do ciclo completo de detecção, investigação e resposta.

## 1.2 Descrição dos Ativos e Funções no Ambiente

| Ativo | Ambiente | Função no Laboratório |
| --- | --- | --- |
| PfSense + Snort | VirtualBox (on-premise) | Firewall perimetral, responsável pelo controle de tráfego, NAT e geração de logs de segurança (syslog), com o pacote PfBlocker- NG instalado, enviados ao SIEM, agregado ao IDS Snort como serviço. |
| Windows Server | AWS (EC2) | Ativo de infraestrutura corporativa simulado, gerando eventos de segurança (Event Logs) coletados pelo SIEM via Universal Forwarder. |
| Ubuntu Orquestrador Terraform | AWS | Ativo servindo como gerenciador de instâncias em nuvem simulando parte de uma operação DevOps para ativos em cloud, não conectado ao SIEM. |
| Ubuntu Orquestrado Terraform | AWS | Ativo servindo como fonte adicional de logs de sistema, permitindo a prática de coleta via Forwarder em ambiente Unix-like. |
| Kali Linux | VirtualBox (on-premise) | Ativo dedicado à simulação de ataques e testes de segurança controlados. |
| Splunk Enterprise (SIEM) | AWS (EC2) | Plataforma central de coleta, indexação e correlação de logs, recebendo dados de todos os demais ativos do ambiente para fins de monitoramento e análise de incidentes. |

## 2. Escopo da Infraestrutura

O laboratório consiste numa infraestrutura híbrida on-premise/cloud pública. O provedor IaaS utilizado foi o AWS Cloud. O serviço de Firewall Pfsense, com o módulo de IDS/IPS Snort implementado e o host virtualizado Kali, foram montados localmente via VirtualBox e operam localmente sobre o fluxo do host físico, um Windows 11. Todo o restante da infraestrutura foi montado no AWS Cloud.

Foi utilizado o Splunk como solução de SIEM numa instancia em nuvem AWS, diferindo ligeiramente no escopo da atividade, porém agregando dificuldade em face da significativa parcela de mercado que os produtos possuem12. [URL 🔗](#page-0)

Agregado a infraestrutura está também uma instância orquestradora do IaC (Infraestrutura como Código) Terraform, munida da solução de automação de TI Ansible. Com este conjunto de soluções DevOps, eu criei um (1) host Ubuntu, hardenizados e conexão com o Splunk configurada via host orquestrador.

Também compõe a infraestrutura um (1) host Windows Server criado individualmente e com seu Splunk Universal Forwarder configurado manualmente, também hospedado na AWS Cloud. O Pfsense está munido apenas de regras padrões e monitora o fluxo de rede local. O Snort dispõe apenas com uma regra que notifica sobre o uso do protocolo ICMP.


## 2.1 Arquitetura da Rede do Laboratório

*Diagrama de rede da infraestrutura híbrida escopo da atividade*

No ambiente local todos as interfaces de rede dos ativos locais foram configuradas com o modo Bridged na rede local com o adendo de uma segunda placa de rede no modo Host Only para host do Pfsense, necessário para seu pleno funcionamento.

No AWS Cloud, foi criado uma VPC (Rede Privada Virtual) com o range 172.31.0.0/16, segmentada em duas sub-redes (172.31.32.0/20, 172.31.0.0/20).


*Aba ‘sub-redes’ das configurações da VPC utilizada na infraestrutura escopo da atividade.*

Todas as VNICs (Interfaces de Rede Virtual) tiveram atribuídas a si um IP do range 172.31.32.0/20, com exceção do host admin Terraform, que compõe a rede 172.31.0.0. Foram atribuídas as VNIC também um IP e DNS público cuja gestão pertencem ao provedor de serviço em nuvem, porém a conexão entre os ativos se dá via rede privada.

## 3. Instalação e Configuração dos Ativos

## 3.1 Ativos on-premise

## 3.1.1 Pfsense/Snort

A instalação do Pfsense se deu através de uma imagem ISO, baseado no sistema operacional FreeBSD. Foram configuradas duas interfaces de rede ativa uma no modo Host Only (LAN) e outra no modo Bridged (WAN), conforme mencionado, no intuito de atender aos requisitos da tecnologia. Abaixo segue a evidência da referida máquina virtual criada e suas especificações.

*Tela da interface do VirtualBox com as especificações da máquina virtual do Pfsense nomeada como*

*‘PfSensy’*


*Tela da interface do host local Pfsense.*

Foi instalado o pacote PfBlocker-NG que “apresenta um recurso aprimorado de tabela de alias para o software pfSense”3, trazendo relações de IPs maliciosos e outros tipos de regras e recursos pré-definidos, ideal para a ocasião. [URL 🔗](#page-0)

Ambos os utilitários, Snort e PfBlocker-NG, foram instalados via o menu System > Package Management.

*Menu Firewall > PfBlocker-NG evidenciando o pacote instalado.*


Tanto o PfSense (com os recursos do PfBlocker-NG) como o Snort no modo IDS, operam somente sobre a rede LAN.

Menu Firewall > Rules e Services > Snort evidenciando quais interfaces estão sendo monitoradas pelas soluções.

Duas regras de IDS para alertar o uso do protocolo ICMP, uma para cada interface, foram configuradas no intuito de gerar volumetria para testes e coleta de evidência.

*Menu Services > Snort > LAN Rules evidenciando a regra de IDS aplicada sobre as interfaces cobertas pelo*

*Snort.*


## 3.1.2 Kali

Abaixo está a evidência da máquina virtual criada com o Kali, para fim de realização dos requisitos da atividade e conveniência para testes e estudos contínuos. Não se pretende incluir a máquina Kali na gerência do SIEM.


## 3.2 Ativos em nuvem

Abaixo vemos a relação de todas as instâncias EC2 na AWS Cloud criadas para o fim da realização da atividade.

Todos as instâncias em nuvem tiveram o mesmo par de chaves RSA “kelly_pair_key" atribuído a si portanto a mesma chave privada é utilizada para conexão remota a todos os ativos mencionados.

## 3.2.1 Host orquestrador Terraform/Ansible

Abaixo segue a evidência de um host Ubuntu, com a solução de IaC Terraform e a de automação de TI Ansible. O host está nomeado como terraf_admin na primeira imagem desta seção.


A imagem mostra uma conexão SSH com o terminal do host orquestrador Terraform evidenciando a versão do

próprio SO, do Ansible e do Terraform instalados.

A seguir está a evidência extraída via VS Code o editor de código fonte desenvolvido pela Microsoft, de que o host apontado como gerenciado está na relação de objetos orquestrados pelo Terraform, nomeado como lab_ec2, instância presente na primeira imagem da seção.


O comando “terraform state show nome_da_instancia” exibe o status do host gerenciado e comprova a operação.


Abaixo está a evidência do playbook Ansible que garante a conexão do host orquestrado como o Splunk consultado via VS Code.

## 3.2.2 Host orquestrado Terraform/Ansible

Acima vemos a evidência do host gerenciado Ubuntu, acessado via conexão SSH no Putty com o Splunk Universal Forwarder instalado e ativo, consultado sua versão (splunk version) e status (splunk status).


## 3.2.3 Windows server

As evidências do servidor Windows, nomeado WIN-AD01, com o Splunk Universal Forward instalado e funcional estão abaixo.


## 3.2.4 SIEM Splunk

Estas são as evidências da instância AWS com o Splunk instalado e as informações acerca do software.


Esta seção cobre as evidências acerca do SIEM Splunk e a devida conexão com os ativos cobertos: WinServer, Pfsense e o host gerenciado via Terraform Ubuntu.

Abaixo está a evidência que cremos ser central, a respeito da receptação dos logs relacionados ao Pfsense/Snort.

O Add-on do Pfsense foi instalado com a finalidade de refinar o parsing da solução sobre os eventos do Pfsense e seus módulos internos em sourcetypes derivados (ex. pfsense:snort). Muito troubleshooting foi aplicado, porém sem resultado. Dessa forma o efeito está sendo reportado como uma limitação técnica encontrada.

Seguem também as evidências relacionadas ao Windows Server e o host ubuntu gerenciado via Terraform/Ansible conforme mencionado.


## 4. Conclusão

## 4.1 Limitações técnicas

Um add-on (https://github.com/barakat-abweh/TA-pfsense) foi instalado no intuito de normalização dos eventos, porém o efeito desejado não foi observado. Muito trobleshooting foi aplicado para resolução da questão, porém sem efeito. Abaixo está a evidência do add-on instalado no Splunk. [URL 🔗](https://github.com/barakat-abweh/TA-pfsense)


## 4.2 Sugestões de melhorias para o ambiente de laboratório.

Gostaria de implementar uma solução de SOAR no intuito de criar e aplicar scripts de automação e aprofundar meu conhecimento técnico em atividades relacionadas a sustenção de infraestruturas de segurança da informação.

Pode se observar também uma ausência de descontinuidade temporal/cronológica entre as evidências que tem timestamps impressos. O laboratório foi desenvolvido com muita calma e alguma energia e tempo foi necessária para aplicar certos troubleshootings para a integração da infraestrutura.
