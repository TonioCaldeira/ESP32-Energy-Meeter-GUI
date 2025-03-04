import hypermedia.net.UDP;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.net.*;
import java.util.*;
import java.nio.BufferUnderflowException;

//Config Var
int port = 5000;            // Porta de escuta
int port_selected = 6000;   // Porta para envio de dados
String customIPAddres = "255.255.255.255";

int numChannels = 6;        // Número de canais
int sampleRate = 4800;      // Taxa de amostragem
int samplePerChannel = 80;  // Amostras por canal
float maxRawValue = 4096;   // Valor máximo em RAW
float voltageConv = 0.175;  // Fator de conversão de tensão
float currentConv = 0.05;   // Fator de conversão de corrente
int cyclesToDisplay = 10;   // Ciclos a serem exibidos
//Config Var

//AUX VAR
UDP udp;
short[][] channelData;        // Dados do canal
short[][] plotChannelData;    // Dados do canal para plotagem
short[][] shotChannelData;    // Dados do canal para captura de disparo
short[][] pauseChannelData;   // Dados do canal para pausa
float[][] filteredSignals = new float[numChannels][];
float[][] harmonicAmplitudes; // Amplitudes das harmônicas
int maxWindowSamples;         // Número máximo de amostras na janela
int displaySamples = cyclesToDisplay * samplePerChannel;
int packetCount;                // Contador de pacotes
short errorFlag;                // Flag de erro
short activeChannels;           // Número de canais ativos
short calibCoeffAtten;          // Coeficiente de calibração de atenuação
short calibCoeffDCOffset;       // Coeficiente de calibração de offset DC
short samplesPerPacketChannel;  // Amostras por pacote por canal
short calibCoeffADC_A;          // Coeficiente de calibração ADC A
short calibCoeffADC_B;          // Coeficiente de calibração ADC B
short[] calibChannel = new short[numChannels]; // Coeficientes de calibração para cada canal
float aux = displaySamples; 
float UDPRateReal = 60; // Taxa UDP inicial (Atualiza automaticamente)
float UDPRateAverage = 60; // Taxa UDP inicial (Atualiza automaticamente)
int[] harmonics = {0, 60, 120, 180, 240, 300}; // DC, 1ª, 2ª, 3ª, 4ª e 5ª harmônicas

int blinkDuration = 100;          // Duração do "piscar" (em milissegundos)
int lastAnyPacketMillis = 0;      // Tempo do último pacote recebido
int lastDataPacketMillis = 0;     // Tempo do último pacote de dados (tamanho 1000)
int shotSampleCounter = 0;        // Contador de amostras para o modo de captura
//AUX VAR

volatile boolean first_setup = true;
volatile boolean newDataAvailable = false;

// Variáveis para os modos de operação
boolean shotTrigger = false;      // Indica se o disparo foi acionado
boolean shotModeActive = false;   // Indica se estamos no modo de captura
boolean shotCaptured = false;     // Indica se os dados já foram congelados
boolean shotCSV = false;          // Indica se os dados devem ser exportados para CSV
boolean pausePlot = false;        // Indica se os dados devem ser pausados
boolean pauseData = false;        // Indica se os dados foram pausados
int scaleMode = 0;                // Modo de escala (0: No Scale, 1: Auto Scale, 2: Manual Scale)
int indicatorCSV = 0;             // Indicador para exportação de CSV
int manualScaleFactor = 2048;     // Fator de escala manual
int manualDCOffset = 0;           // Deslocamento DC manual

// Variável global para armazenar o IP do remetente
String localIPAddress = "";
String ipToSend;
String ipData;

// Lista de ESPs encontrados
ArrayList<String> espDevices = new ArrayList<String>();

// Aba ativa e hover
int activeTab = 0;  // Aba ativa (0: Configurações, 1: PQ Meter, 2: Tempo, 3: Frequência, 4: Fase A, 5: Fase B, 6: Fase C)
int hoverTab = -1;  // Aba em que o mouse está passando

void setup() {
    size(1800, 900);  // Ajuste da janela
    frameRate(80);    // Ajuste da taxa de atualização
    initializeConfigInputs();   
    plotChannelData = new short[numChannels][displaySamples];

    // Configura o objeto UDP
    udp = new UDP(this, port);
    udp.listen(true); // Inicia a escuta de pacotes UDP

    println("Listening on port: " + port);

    // Obter o IP local da máquina
    localIPAddress = getLocalIPAddress();

    // Configuração adicional para descoberta de ESPs
    udp.log(false); // Desativa o log de pacotes recebidos (pode ativar se precisar de debug)
       
    espDropDown = new DropDown(width / 2 + 270, 160, 570, 40, espDevices); // Inicializa a DropDown para os ESPs
    
    selectButton = new Button(width / 2 + 270, 95, 130, 45, "Confirm"); // Inicializa o botão ao lado da DropDown
    
    triggerShotButton = new Button(250, 608, 150, 45, "Trigger Shot");
    exportCSVButton = new Button(87, 800, 150, 45, "Export CSV");
    
    updateButton = new Button(115, 480, 250, 45, "Update Parameters");
    
    playButton = new Button(793, 608, 120, 45, "Play");
    pauseButton = new Button(962, 608, 120, 45, "Pause");
    
    helpButton = new Button(width - 100, height - 70, 65, 35, "Help");
    
    channelData = new short[numChannels][displaySamples];
    harmonicAmplitudes = new float[numChannels][harmonics.length];
    
    // Inicializa as checkboxes (posicione-as conforme sua interface)
    checkboxMachine = new Checkbox(width / 2 + 450, 105, 25, "Local IP");
    checkboxUser = new Checkbox(width / 2 + 650, 105, 25, "Custom IP");
    checkboxMachine.setSelected(true);
    checkboxUser.setSelected(false);
    
    checkboxContinuousMode = new Checkbox(485, 620, 25, "Continuous Mode");
    checkboxShotMode = new Checkbox(55, 620, 25, "Shot Mode");
    checkboxContinuousMode.setSelected(true);
    checkboxShotMode.setSelected(false);
    
    checkboxNoScale = new Checkbox(485, 720, 25, "No Scale");
    checkboxAutoScale = new Checkbox(485, 770, 25, "Auto Scale");
    checkboxManualScale = new Checkbox(485, 820, 25, "Manual Scale");
    checkboxNoScale.setSelected(true);
    checkboxAutoScale.setSelected(false);
    checkboxManualScale.setSelected(false);
    
    helpWindow = new HelpWindow();
}

void draw() {
    // Se houver novos dados, copie para o buffer usado no desenho
    if (newDataAvailable) {
        if (shotTrigger) {
            triggerCaptureShot();
        }
        if (shotModeActive && shotCaptured) {
            plotChannelData = shotChannelData;
        } else if (!shotModeActive) {
            if (pausePlot) {
                capturePauseData();
                plotChannelData = pauseChannelData;
            } else {
                pauseData = false;
                plotChannelData = channelData;
            }
        } else {
            plotChannelData = channelData;
        }
        newDataAvailable = false;
    }
    background(0);
    // Desenhar os botões das abas
    drawTabs();

    // Determinar qual aba está ativa
    switch (activeTab) {
        case 0:
            stroke(255);
            drawConfigTab(); // Chama a função para desenhar a aba de configurações
            drawIndicators(510, 120); // Ajuste as coordenadas conforme seu layout
            break;
        case 1:
            int PosX = width * 3 / 4;
            int PosY = 2 * height / 4 + 25;
            int Diameter = 700;
            strokeWeight(4);
            fill(100, 80, 80);
            arc(PosX, PosY, Diameter, Diameter, -PI / 3, PI / 3);            
            fill(80, 80, 100);
            arc(PosX, PosY, Diameter, Diameter, -PI, -PI / 3);
            fill(80, 100, 80);
            arc(PosX, PosY, Diameter, Diameter, PI / 3, PI);
            
            drawPhasorGraph(PosX, PosY, Diameter, 5);
            drawPhasorDiagram(PosX - 27, PosY - 27, 55, 55, 1);
            pqMeter(40);
            break;
        case 2:
            stroke(255);
            drawTimeDomain(width, 40);
            break;
        case 3:
            int PosX1 = width * 5 / 18;
            drawFrequencyDomain(1, PosX1, (height - 100) / numChannels);
            stroke(255);
            line(PosX1, 40, PosX1, height);
            textSize(24);
            text("DC", PosX1 / 12, height - 20);
            text("1°", PosX1 * 3 / 12, height - 20);
            text("2°", PosX1 * 5 / 12, height - 20);
            text("3°", PosX1 * 7 / 12, height - 20);
            text("4°", PosX1 * 9 / 12, height - 20);
            text("5°", PosX1 * 11 / 12, height - 20);
            fill(0);
            ellipse(width * 13 / 25 + 27, 2 * height / 4 + 27, 700, 700);
            ellipse(width * 21 / 25 + 15, 1 * height / 4 + 15, 300, 300);
            ellipse(width * 21 / 25 + 15, 3 * height / 4 + 15, 300, 300);
            fill(255);
            textSize(27);
            text("1° Harmonic", width * 13 / 25 + 27, 110);
            textSize(25);
            text("3° Harmonic", width * 21 / 25 + 15, 430);
            text("5° Harmonic", width * 21 / 25 + 15, 525);
            
            textSize(22);
            drawPhasorGraph(width * 13 / 25 + 27, 2 * height / 4 + 27, 700, 5);
            drawPhasorDiagram(width * 13 / 25, 2 * height / 4, 55, 55, 1);
            
            drawPhasorGraph(width * 21 / 25 + 15, 1 * height / 4 + 15, 300, 5);
            drawPhasorDiagram(width * 21 / 25, 1 * height / 4, 30, 30, 3);
            
            drawPhasorGraph(width * 21 / 25 + 15, 3 * height / 4 + 15, 300, 5);
            drawPhasorDiagram(width * 21 / 25, 3 * height / 4, 30, 30, 5);
            break;
        case 4:
            fill(255);
            text("Channel 1 + Channel 4", 110, 130);
            text("Channel 1 x Channel 4", 110, 480);
            drawCombinedTimeDomain(0, 150, width - 2, 300, 0, 3);
            drawMultiplicationPlot(0, 498, width - 2, 400, 0, 3, 255, 255, 0);
            drawElectricalParameters(20, 70, 0, 3);
            break;
        case 5:
            fill(255);
            text("Channel 2 + Channel 5", 110, 130);
            text("Channel 2 x Channel 5", 110, 480);
            drawCombinedTimeDomain(0, 150, width - 2, 300, 1, 4);
            drawMultiplicationPlot(0, 498, width - 2, 400, 1, 4, 255, 255, 0);
            drawElectricalParameters(20, 70, 1, 4);
            break;
        case 6:
            fill(255);
            text("Channel 3 + Channel 6", 110, 130);
            text("Channel 3 x Channel 6", 110, 480);
            drawCombinedTimeDomain(0, 150, width - 2, 300, 2, 5);
            drawMultiplicationPlot(0, 498, width - 2, 400, 2, 5, 255, 255, 0);
            drawElectricalParameters(20, 70, 2, 5);
            break;
    }
}