# censurador-de-arq-bmp

## Primeiramente implementar um programa que recebe as entradas solicitadas, abra o arquivo indicado e realize a seguinte sequência de operações:

### - Ler 18 bytes (14 + 4) do arquivo recém-aberto e escrever esses bytes no arquivo de saída;

### - Ler 4 bytes referentes ao tamanho da largura da imagem de entrada, salvar o valor em uma variável inteira e escrever esses bytes no arquivo de saída;

### - Ler os 32 bytes restantes do cabeçalho da imagem (o cabeçalho tem um total de 54 bytes) e escrever esses bytes no arquivo de saída;

### - Por fim, implemente um loop que leia a quantidade de bytes equivalente ao tamanho da largura da imagem multiplicada por 3 (considerando que para cada pixel de largura existem 3 bytes referentes aos componentes RGB), e simplesmente escreva os bytes lidos no arquivo de destino, sem nenhuma alteração. Para essa leitura, recomenda-se que os bytes de uma linha da imagem sejam salvos em um array de 6480 bytes (3 bytes/pixel multiplicados por 2160 pixels, que é a largura de uma imagem com resolução 4K – o maior tamanho de imagem possível no contexto deste projeto);

### - Ao final desse processo você terá um programa que salva em uma variável a largura de uma imagem e simplesmente faz uma cópia inalterada da imagem informada na entrada. 

## Uma vez que o tópico anterior tenha sido solucionado, altere o programa para desenhar o retângulo preto na área indicada. Recomenda-se o uso da seguinte estratégia:

### - Crie uma função que receba 3 parâmetros, na seguinte ordem:

#### 1. O endereço do array que contém os bytes da linha da imagem;

#### 2. A coordenada X inicial; 3. A largura da censura a ser aplicada. Essa função deve preencher os pixels a partir da posição X com três bytes 0, referentes à cor preta no padrão RGB. Esse preenchimento deve acontecer até a posição “X inicial” + largura. A inclusão dessa função conforme especificado é considerada obrigatória nesta parte do projeto;

### - Uma vez que essa função esteja pronta, altere o loop de leitura do arquivo, para que essa função altere apenas as linhas que estejam no conjunto que vai desde linha da coordenada Y inicial até a linha “Y inicial” + altura. As linhas que não estiverem contidas neste conjunto devem ser apenas copiadas de forma inalterada para o arquivo de destino.

## Algumas observações importantes:

### - A imagem original e a nova imagem devem estar no mesmo diretório do arquivo executável, de modo que o usuário só precise informar o nome do arquivo sem se preocupar com o caminho do arquivo;

### - O(a) aluno(a) não precisa se preocupar com tratamento de erros de entrada. Assuma que todas as entradas serão fornecidas corretamente, dentro das faixas de valores esperadas;

### - Tanto no Windows quanto no Linux deverão ser utilizadas as chamadas oficiais do sistema operacional para abrir, ler, escrever e fechar arquivos, não sendo permitido o uso de outras bibliotecas para esse fim;

### - A entrada e saída de console no Windows deve utilizar as funções ReadConsole e WriteConsole da biblioteca kernel32. No Linux podem ser utilizadas as funções printf e scanf da biblioteca padrão da linguagem C, utilizando o gcc para “linkagem” do programa.
