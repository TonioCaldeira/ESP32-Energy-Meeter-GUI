// Inicializar caixas de texto para a aba de configurações
void initializeConfigInputs() {
    configInputs = new TextBox[6];
    int startX = 100, startY = 100, spacing = 60;
    configInputs[0] = new TextBox(startX, startY, "Voltage Factor", nf(voltageConv, 1, 3));
    configInputs[1] = new TextBox(startX, startY + spacing, "Current Factor", nf(currentConv, 1, 3));
    configInputs[2] = new TextBox(startX, startY + 2 * spacing, "Sample Rate", nf(sampleRate, 1, 0));
    configInputs[3] = new TextBox(startX, startY + 3 * spacing, "Max RAW Value", nf(maxRawValue, 1, 0));
    configInputs[4] = new TextBox(startX, startY + 4 * spacing, "Cycles to Display", nf(cyclesToDisplay, 1, 0));
    configInputs[5] = new TextBox(startX, startY + 5 * spacing, "Custom IP", customIPAddres);
}

// Função para desenhar a aba de configurações
void drawConfigTab() {
    // Desenha as geometrias da aba de configurações
    strokeWeight(4);
    fill(0);
    rect(20, 60, 1090, 500, 15, 15, 15, 15);
    line(465, 100, 465, 520);
    rect(1130, 60, 650, height - 80, 15, 15, 15, 15);   
    rect(20, 580, 410, 300, 15, 15, 15, 15);
    line(50, 680, 400, 680);
    rect(450, 580, 660, 300, 15, 15, 15, 15);
    line(480, 680, 1080, 680);
    
    strokeWeight(3);
    
    // Indica o estado de pausa da plotagem
    if (pausePlot) {
        fill(255, 220, 0);  // amarelo
        rect(930, 613, 15, 35, 4, 4, 4, 4);
    } else {
        fill(0, 255, 100);  // verde
        rect(930, 613, 15, 35, 4, 4, 4, 4);
    }
    
    textSize(25);
    textAlign(LEFT, CENTER);
    
    // Indica o status do CSV
    if (indicatorCSV == 1) {
        fill(255, 220, 0);  // amarelo
        rect(55, 805, 15, 35, 4, 4, 4, 4);
        fill(255);
        if (shotTrigger) {
            text("Status: Acquiring Samples", 55, 720);
            text("Progress: " + ((100 * shotSampleCounter) / (samplePerChannel * cyclesToDisplay)) + "%", 55, 760);
        } else {
            text("Status: Waiting Trigger", 55, 720);
            text("Progress: 0%", 55, 760);
        }
    } else if (indicatorCSV == 2) {
        fill(0, 255, 100);  // verde
        rect(55, 805, 15, 35, 4, 4, 4, 4);
        fill(255);
        text("Status: Ready to Export", 55, 720);
        text("Progress: 100%", 55, 760);
    } else {
        fill(255, 0, 50);  // vermelho
        rect(55, 805, 15, 35, 4, 4, 4, 4);
        fill(255);
        text("Status: Deactivated", 55, 720);
        text("Progress: ---", 55, 760);
    }
    
    // Exibe os campos Manual Scale
    textSize(24);
    text("DC Offset: " + manualDCOffset + "  |  Scale Factor: " + (100 * 2048 / manualScaleFactor) + "%", 710, 833);

    // Exibe os campos de entrada
    fill(255);
    textSize(25);
    for (TextBox input : configInputs) {
        input.display();
    }
    textSize(23);
    textAlign(CENTER, CENTER);
    textAlign(LEFT, CENTER);
    fill(255);
    textSize(24);
    
    // Exibe as informações de status e calibração
    int infoX = 500;         // Coordenada X para exibição das informações
    int infoY = 170;         // Posição inicial Y
    int lineSpacing = 48;    // Espaçamento entre linhas
    textSize(30);
    text("Active Channels: " + activeChannels, infoX, infoY);
    text("Samples per Channel: " + samplePerChannel, infoX, infoY + 1 * lineSpacing);
    text("DC Offset: " + calibCoeffDCOffset, infoX, infoY + 2 * lineSpacing);
    text("Error Flag: " + errorFlag, infoX, infoY + 3 * lineSpacing);
    text("UDP Rate [Hz]: " + nf(UDPRateReal, 2, 1) + "    Average: " + nf(UDPRateAverage, 2, 2), infoX, infoY + 4 * lineSpacing);
    text("Packet Count: " + nf(packetCount, 7, 0), infoX, infoY + 5 * lineSpacing);
    text("IP Connected: " + ipData, infoX, infoY + 6 * lineSpacing);
    text("Local IP Address: " + localIPAddress, infoX, infoY + 7 * lineSpacing);

    // Exibe a DropDown de ESPs
    espDropDown.display();
    
    // Exibe os botões
    selectButton.display();
    updateButton.display();
    triggerShotButton.display();
    exportCSVButton.display();
    playButton.display();
    pauseButton.display();
    helpButton.display();
    
    // Exibe os checkboxes de IP
    checkboxMachine.display();
    checkboxUser.display();
    
    // Exibe os checkboxes dos modos
    checkboxContinuousMode.display();
    checkboxShotMode.display();
    
    // Exibe os checkboxes de escala
    checkboxNoScale.display();
    checkboxAutoScale.display();
    checkboxManualScale.display();
        
    strokeWeight(3); // Define a espessura da linha como 3 pixels
    stroke(255);
}

// Função para atualizar os parâmetros de configuração
void handleUpdateParameters() {
    // Lê os valores das caixas de texto e converte para os tipos apropriados
    voltageConv = float(configInputs[0].text);
    currentConv = float(configInputs[1].text);
    sampleRate = int(configInputs[2].text);
    maxRawValue = int(configInputs[3].text);
    cyclesToDisplay = int(configInputs[4].text);
    
    // Reseta os modos e indicadores
    checkboxContinuousMode.setSelected(true);
    checkboxShotMode.setSelected(false);
    shotModeActive = false;
    shotCaptured = false;
    pauseData = false;
    pausePlot = false;
    indicatorCSV = 0;
    updateDisplaySamples();
    redraw();  // Atualiza a tela chamando redraw()

    // Imprime os novos valores para verificação
    println("Updated Parameters:");
    println("Channels: " + numChannels);
    println("Sample Rate: " + sampleRate);
    println("Samples/Channel: " + samplePerChannel);
    println("Max RAW Value: " + maxRawValue);
    println("Cycles to Display: " + cyclesToDisplay);
}

// Função para desenhar os indicadores de status
void drawIndicators(int startX, int startY) {
    // Indicador 1: Qualquer pacote recebido (verde)
    if (millis() - lastAnyPacketMillis < blinkDuration) {
        fill(0, 255, 100);  // verde vibrante
    } else {
        fill(80);        // cor apagada
    }
    ellipse(startX, startY, 30, 30);
    
    // Indicador 2: Pacote de dados recebido (tamanho 1000) (amarelo)
    if (millis() - lastDataPacketMillis < blinkDuration / 8) {
        fill(255, 220, 0);  // amarelo
    } else {
        fill(80);
    }
    ellipse(startX + 250, startY, 30, 30);
    
    // Rótulos para identificar os indicadores
    fill(255);
    textSize(28);
    textAlign(LEFT, CENTER);
    text("Activity Status", startX + 30, startY);
    text("Receiving Data Packet", startX + 280, startY);
}

// Função para capturar dados em pausa
void capturePauseData() {
    if (!pauseData) {
        pauseChannelData = new short[numChannels][displaySamples];
        for (int ch = 0; ch < numChannels; ch++) {
            System.arraycopy(channelData[ch], 0, pauseChannelData[ch], 0, displaySamples);
        }
        pauseData = true;
    }
}

// Função para capturar dados em modo shot
void captureShotData() {
    // Inicializa shotChannelData com o mesmo número de canais e amostras
    shotChannelData = new short[numChannels][displaySamples];
    for (int ch = 0; ch < numChannels; ch++) {
        // Realiza cópia dos dados do canal
        System.arraycopy(channelData[ch], 0, shotChannelData[ch], 0, displaySamples);
    }
    indicatorCSV = 2;
    shotCaptured = true;
    shotCSV = true;
    println("Dados congelados (shot) capturados!");
}

// Função para acionar a captura de dados em modo shot
void triggerCaptureShot() {
    if (shotSampleCounter >= cyclesToDisplay * samplePerChannel) {
        shotTrigger = false;
        captureShotData(); 
    }
}

// Função para exportar dados capturados em modo shot para CSV
void exportShotDataToCSV() {
    if (shotChannelData == null) {
        println("Nenhum dado shot para exportar.");
        return;
    }
    
    // Cria um array de strings para armazenar cada linha do CSV (cabeçalho + linhas de dados)
    String[] lines = new String[displaySamples + 1];
    
    // Linha de cabeçalho
    String header = "Sample";
    for (int ch = 0; ch < numChannels; ch++) {
        header += ", Channel " + (ch + 1);
    }
    lines[0] = header;
    
    // Preenche as linhas com os dados de cada amostra
    for (int i = 0; i < displaySamples; i++) {
        String line = "" + i;
        for (int ch = 0; ch < numChannels; ch++) {
            line += ", " + shotChannelData[ch][i];
        }
        lines[i + 1] = line;
    }
    
    // Gera um nome de arquivo baseado na data/hora atual
    String fileName = "shot_data_" + year() + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".csv";
    saveStrings(fileName, lines);
    println("Dados shot exportados para " + fileName);
    shotCSV = false;
}