void drawTimeDomain(int width, int selectionBarHeight) {
  int columns = 2; // Número de colunas
  int rows = 3;    // Número de linhas (número de canais por coluna)
    
  // Ajustando a altura total ocupada pelos canais considerando a altura da barra
  int totalHeight = height - selectionBarHeight; // Altura total da tela menos a altura da barra de seleção
  int availableHeight = totalHeight / rows; // Altura disponível para cada canal (sem a barra de seleção)

  // Calculando as larguras e alturas das colunas
  int columnWidth = width / columns; // Largura de cada coluna
  // Desenhar a linha divisória entre os canais

    
  for (int ch = 0; ch < numChannels; ch++) {
    float peakValue = 0;
    float rmsSum = 0;

    // Determinar a coluna e linha do canal atual
    int column = ch / rows; // 0 para a primeira coluna, 1 para a segunda
    int row = ch % rows;    // 0, 1 ou 2 para as linhas

    // Calcular a posição da linha e da coluna para desenhar o gráfico
    int xOffset = column * columnWidth;
    int yOffset = selectionBarHeight + (row * availableHeight); // Ajustar a posição y com base na altura da barra de seleção

    // Desenhar a linha divisória entre os canais
    strokeWeight(5); // Define a espessura da linha como 5 pixels
    stroke(255);
    line(xOffset, yOffset, xOffset + columnWidth, yOffset);

    // Desenhar a linha central (horizontal) no gráfico
    stroke(255);
    strokeWeight(1); // Define a espessura da linha central
    float centralLineY = map(0, 0, maxRawValue, yOffset + availableHeight / 2 + 20, yOffset - availableHeight / 2 + 100); // Linha central
    line(xOffset, centralLineY, xOffset + columnWidth, centralLineY); // Linha horizontal

    // Desenhar o gráfico de cada canal
    strokeWeight(2); // Define a espessura da linha do gráfico como 2 pixels
    switch (ch) {
      case 0:
        stroke(255, 0, 0);
        break;
      case 1:
        stroke(0, 255, 0);
        break;
      case 2:
        stroke(0, 0, 255);
        break;
      case 3:
        stroke(255, 150, 100);
        break;
      case 4:
        stroke(100, 255, 150);
        break;
      case 5:
        stroke(150, 100, 255);
        break;
      }
      //stroke(255 - (ch + 1), 0, 255 - (ch + 1));
      noFill();
      beginShape();
        
      float[][] scaledData = applyScale(plotChannelData);
        
      for (int i = 0; i < displaySamples && i < plotChannelData[ch].length; i++) {
        float normalizedValue = scaledData[ch][i];
        peakValue = max(peakValue, abs(normalizedValue));
        rmsSum += sq(normalizedValue);

        float y = map(normalizedValue, 0, maxRawValue, yOffset + availableHeight / 2 + 20, yOffset - availableHeight / 2 + 100); 
        float x = map(i, 0, displaySamples - 1, xOffset, xOffset + columnWidth);
        vertex(x, y);
      }
      endShape();

      // Cálculos de RMS e THD
      float rmsValue = sqrt(rmsSum / displaySamples);
      float rmsPercentage = (2 * rmsValue / maxRawValue) * 100;
      float[][] harmonicsValues = calculateDFT(plotChannelData[ch], harmonics);

      float sumAmplitudes = 0;
      for (int i = 0; i < harmonicsValues.length; i++) {
        sumAmplitudes += harmonicsValues[i][0];
      }

      float harmonicSum = 0;
      for (int i = 2; i < harmonicsValues.length; i++) {
        harmonicSum += sq(harmonicsValues[i][0]);
      }

      float fundamental = harmonicsValues[1][0];
      float THD = (fundamental > 0) ? sqrt(harmonicSum) / fundamental * 100 : 0;
      float peakPercentage = (peakValue*2 / maxRawValue) * 100;

      float realFrequency = estimateFrequency(channelData[ch], UDPRateAverage*samplePerChannel, cyclesToDisplay);
      
      // Exibir os dados do canal
      fill(255);
      textAlign(LEFT, TOP);
      text("Channel " + (ch + 1) + " - Peak: " + nf(peakPercentage, 1, 1) + 
           "% - RMS: " + nf(rmsPercentage, 1, 1) + "% - THD: " + nf(THD, 1, 1) + "% - Real Freq: " + nf(realFrequency, 1, 1) + "Hz", 
           xOffset + 25, yOffset + 15);
  }
  strokeWeight(5); // Define a espessura da linha como 5 pixels
  stroke(255);
  line(width/2, selectionBarHeight, width/2, height);
  strokeWeight(3); // Define a espessura da linha como 5 pixels
  stroke(255);
}



void drawFrequencyDomain(int startX, int width, int channelHeight) {
  int selectionBarHeight = 40; // Altura da barra de seleção
  int verticalOffset = selectionBarHeight; // Deslocamento vertical para compensar a barra de seleção

  for (int ch = 0; ch < numChannels; ch++) {
    float[][] harmonicsValues = calculateDFT(plotChannelData[ch], harmonics);

    float sumAmplitudes = 0;
    for (int i = 0; i < harmonicsValues.length; i++) {
      sumAmplitudes += harmonicsValues[i][0];
    }

    for (int i = 0; i < harmonicsValues.length; i++) {
      harmonicAmplitudes[ch][i] = (sumAmplitudes > 0) ? (harmonicsValues[i][0] / sumAmplitudes) * 100 : 0;
    }

    for (int i = 0; i < harmonics.length; i++) {
      float amplitude = harmonicAmplitudes[ch][i];
      float normalizedAmplitude = map(amplitude, 0, 100, 0, channelHeight * 0.8);
      float barWidth = width / harmonics.length;
      float freqX = startX + i * barWidth;
      float barY = (channelHeight * (ch + 1)) - normalizedAmplitude + verticalOffset;
            
      switch (ch) {
        case 0:
          stroke(255, 0, 0);
          fill(255, 0, 0);
          break;
        case 1:
          stroke(0, 255, 0);
          fill(0, 255, 0);
          break;
        case 2:
          stroke(0, 0, 255);
          fill(0, 0, 255);
          break;
        case 3:
          stroke(255, 150, 100);
          fill(255, 150, 100);
          break;
        case 4:
          stroke(100, 255, 150);
          fill(100, 255, 150);
          break;
        case 5:
          stroke(150, 100, 255);
          fill(150, 100, 255);
          break;
      }            
      rect(freqX, barY, barWidth - 2, normalizedAmplitude);
      fill(255);
      textAlign(CENTER, BOTTOM);
      text(nf(amplitude, 1, 1) + "%", freqX + (barWidth - 2) / 2, barY - 5);
    }
  }
  strokeWeight(3); // Define a espessura da linha como 3 pixels
  stroke(255);
}


float[][] calculateDFT(short[] data, int[] freqs) {
  int N = max(displaySamples, samplePerChannel);
  float[][] results = new float[freqs.length][2];
  float scaleFactor = sqrt(2); // Fator para converter A/2 em A/sqrt(2) (RMS)

  for (int f = 0; f < freqs.length; f++) {
    float real = 0, imag = 0;
    for (int n = 0; n < N; n++) {
      float angle = TWO_PI * freqs[f] * n / sampleRate;
      real += data[n] * cos(angle);
      imag -= data[n] * sin(angle);
    }
    float mag = sqrt(real * real + imag * imag) / N; // Isso retorna A/2 para uma senóide pura
    results[f][0] = mag * scaleFactor;              // Magnitude - Agora resulta em A/sqrt(2) (valor RMS)
    results[f][1] = atan2(imag, real);               // Fase
  }
  return results;
}

void drawPhasorDiagram(int startX, int startY, int sectionWidth, int sectionHeight, int harmonicIndex) {
  int centerX = startX + sectionWidth / 2;
  int centerY = startY + sectionHeight / 2;
  float scaleFactor = sectionHeight / 5;
  float ref = 0;
  float absoluteThreshold = 5; // Valor absoluto para ignorar magnitudes < 0,5%
    
  fill(0);
  fill(255);

  // Inicializar array para armazenar os valores calculados
  float[][][] harmonicsValuesAllChannels = new float[numChannels][][];

  float maxMagnitude = 0;
  for (int ch = 0; ch < numChannels; ch++) {
    harmonicsValuesAllChannels[ch] = calculateDFT(plotChannelData[ch], harmonics);
    float magnitude = harmonicsValuesAllChannels[ch][harmonicIndex][0];
    maxMagnitude = max(maxMagnitude, magnitude);
    if (ch == 0) ref = harmonicsValuesAllChannels[ch][harmonicIndex][1]; // Referência do canal 0
  }

  for (int ch = 0; ch < numChannels; ch++) {
    float magnitude = harmonicsValuesAllChannels[ch][harmonicIndex][0];
    float phase = harmonicsValuesAllChannels[ch][harmonicIndex][1] - ref;

    // Ignorar magnitudes abaixo do limiar absoluto
    if (magnitude < absoluteThreshold) {
      continue;
    }

    float normalizedMagnitude = map(magnitude, 0, maxMagnitude, 0, sectionHeight / 2);
    float xEnd = centerX + cos(phase) * normalizedMagnitude * scaleFactor;
    float yEnd = centerY - sin(phase) * normalizedMagnitude * scaleFactor;

    // Desenhar o vetor
    strokeWeight(4);
    switch (ch) {
      case 0:
        stroke(255, 0, 0);
        break;
      case 1:
        stroke(0, 255, 0);
        break;
      case 2:
        stroke(0, 0, 255);
        break;
      case 3:
        stroke(255, 150, 100);
        break;
      case 4:
        stroke(100, 255, 150);
        break;
      case 5:
        stroke(150, 100, 255);
        break;
      }
  line(centerX, centerY, xEnd, yEnd);
  stroke(255);
  fill(255);
  // Desenhar o ponto final do vetor
  ellipse(xEnd, yEnd, 5, 5);

  // Adicionar rótulo do canal
  textAlign(CENTER);
  text("Canal " + (ch + 1), xEnd, yEnd - 10);
  }
}


void updateDisplaySamples() {
  displaySamples = (int)(cyclesToDisplay * UDPRateReal * samplePerChannel / 60);
  sampleRate = (int)(UDPRateReal * samplePerChannel);
}


// Função para desenhar os canais combinados (canal A e canal B) no domínio do tempo
void drawCombinedTimeDomain(int startX, int startY, int plotWidth, int plotHeight, int channelA, int channelB) {
    
  // Definir quais canais serão combinados:
  // Canal A e Canal B
  int[] channels = {channelA, channelB};
  stroke(255);
  strokeWeight(2);
  line(startX, plotHeight/2 + startY, plotWidth + startX, plotHeight/2 + startY);
    
  // Para cada canal, desenha o sinal
  for (int idx = 0; idx < channels.length; idx++) {
    int ch = channels[idx];
    // Verifica se o canal existe (caso numChannels seja menor)
    if(ch >= numChannels) continue;        
      switch (ch) {
        case 0:
          stroke(255, 0, 0);
          break;
        case 1:
          stroke(0, 255, 0);
          break;
        case 2:
          stroke(0, 0, 255);
          break;
        case 3:
          stroke(255, 150, 100);
          break;
        case 4:
          stroke(100, 255, 150);
          break;
        case 5:
          stroke(150, 100, 255);
          break;
      }
    strokeWeight(2);
    noFill();
    beginShape();
    float[][] scaledData = applyScale(plotChannelData);        
    for (int i = 0; i < displaySamples && i < plotChannelData[ch].length; i++) {
      // Obter o valor do sinal e mapeá-lo para a altura do gráfico
      float value = scaledData[ch][i];
      // Mapear o valor de 0 a maxRawValue para a área do gráfico, centralizando corretamente
      float y = map(value, -maxRawValue / 2, maxRawValue / 2, startY + plotHeight, startY);
      // Mapear a posição do sample ao longo do eixo x
      float x = map(i, 0, displaySamples - 1, startX, startX + plotWidth);
      vertex(x, y);
    }
      endShape();
  }
  // Desenha um contorno para a área do gráfico (opcional)
  stroke(255);
  noFill();
  strokeWeight(5);
  rect(startX, startY, plotWidth, plotHeight);
}

// Função para desenhar o gráfico da multiplicação dos dois canais (canalA e canalB)
void drawMultiplicationPlot(int startX, int startY, int plotWidth, int plotHeight, int channelA, int channelB, int R, int G, int B) {
  // Calcula o intervalo esperado para o produto:
  // Se os sinais variam de -maxRawValue/2 a +maxRawValue/2,
  // então o produto varia de -maxRawValue²/4 a +maxRawValue²/4.
  float productRange = (maxRawValue * maxRawValue) / 5.5;
  stroke(255);
  strokeWeight(2);
  line(startX, plotHeight/2 + startY, plotWidth + startX, plotHeight/2 + startY);
    
  // Define a cor para o plot de multiplicação (por exemplo, verde)
  stroke(R, G, B);
  strokeWeight(3);
  noFill();
  beginShape();
  float[][] scaledData = applyScale(plotChannelData);
  for (int i = 0; i < displaySamples && i < plotChannelData[channelA].length && i < plotChannelData[channelB].length; i++) {
    // Calcula o produto dos valores nos canais escolhidos
    float productValue = scaledData[channelA][i] * scaledData[channelB][i];
    // Mapeia o produto para a área vertical do plot
    float y = map(productValue, -productRange, productRange, startY + plotHeight, startY);
    // Garante que y fique dentro dos limites da área do gráfico
    y = constrain(y, startY, startY + plotHeight);
    // Mapeia a posição do sample no eixo x
    float x = map(i, 0, displaySamples - 1, startX, startX + plotWidth);
    vertex(x, y);
  }
  endShape();
    
  // Desenha um contorno para a área do gráfico (opcional)
  stroke(255);
  noFill();
  strokeWeight(5);
  rect(startX, startY, plotWidth, plotHeight);
}


// Função para calcular e exibir os parâmetros elétricos:
void drawElectricalParameters(int startX, int startY, int channelA, int channelB) {
  // Usaremos o fundamental de 60 Hz para a análise (supondo sistema 60Hz)
  int[] fundamentalArray = {60};
  
  // Calcula a DFT para o canal de tensão e para o canal de corrente
  float[][] voltageDFT = calculateDFT(plotChannelData[channelA], fundamentalArray);
  float[][] currentDFT = calculateDFT(plotChannelData[channelB], fundamentalArray);
  
  // Extraímos as fases do fundamental (índice 0 do resultado)
  float voltagePhase = voltageDFT[0][1]; // em radianos
  float currentPhase = currentDFT[0][1]; // em radianos
  
  // Calcula a defasagem: diferença entre corrente e tensão
  float deltaPhase = currentPhase - voltagePhase;
  // Converte de radianos para graus
  float angleDiffDegrees = degrees(deltaPhase);
  
  // Calcula o fator de potência (usamos o valor do cosseno da defasagem)
  float powerFactor = cos(deltaPhase);  // Pode-se usar o valor absoluto se preferir
  
  // Determina quantas amostras utilizar (garantindo que não ultrapasse os arrays)
  int samples = min(displaySamples, min(plotChannelData[channelA].length, plotChannelData[channelB].length));
  
  // Cálculo dos valores RMS para tensão e corrente
  float sumVoltageSq = 0;
  float sumCurrentSq = 0;
  for (int i = 0; i < samples; i++) {
    float voltage = plotChannelData[channelA][i];
    float current = plotChannelData[channelB][i];
    
    sumVoltageSq += voltage * voltage;
    sumCurrentSq += current * current;
  }
  float Vrms = sqrt(sumVoltageSq / samples) * voltageConv;
  float Irms = sqrt(sumCurrentSq / samples) * currentConv;
  
  // Cálculo das potências
  float activePower   = Vrms * Irms * cos(deltaPhase); // em Watts (W)
  float apparentPower = Vrms * Irms;                     // em Volt-Amperes (VA)
  float reactivePower = Vrms * Irms * sin(deltaPhase);   // em Volt-Ampere Reativos (VAR)
  
  float realFrequencyA = estimateFrequency(channelData[channelA], UDPRateAverage*samplePerChannel, cyclesToDisplay);
  float realFrequencyB = estimateFrequency(channelData[channelB], UDPRateAverage*samplePerChannel, cyclesToDisplay);
  
  // Exibe os parâmetros na tela
  fill(255);
  textAlign(LEFT, TOP);
  textSize(24);
  
  String info = "Active Power:   " + nf(activePower, 3, 2) + " W" +
                "   |   Apparent Power:   " + nf(apparentPower, 3, 2) + " VA" +
                "   |   Reactive Power:   " + nf(reactivePower, 3, 2) + " VAr" +
                "   |   Angle:   " + nf(angleDiffDegrees, 3, 2) + "°" +
                "   |   Power Factor:   " + nf(powerFactor, 1, 3) +
                "   |   Freq_A:   " + nf(realFrequencyA, 2, 1) + "Hz" +
                "   |   Freq_B:   " + nf(realFrequencyB, 2, 1) + "Hz";
  
  text(info, startX, startY);
}

float[][] applyScale(short[][] rawData) {
  int numChannels = rawData.length;
  int numSamples = rawData[0].length;
  
  // Converte rawData de short[][] para float[][]
  float[][] rawDataFloat = new float[numChannels][numSamples];
  for (int ch = 0; ch < numChannels; ch++) {
    for (int i = 0; i < numSamples; i++) {
      rawDataFloat[ch][i] = (float) rawData[ch][i];
    }
  }
  
  float[][] scaledData = new float[numChannels][numSamples];
  
  if (scaleMode == 1) { // AutoScale: calcula os mínimos e máximos de cada canal
    for (int ch = 0; ch < numChannels; ch++) {
      float yMin = Float.MAX_VALUE;
      float yMax = Float.MIN_VALUE;
      for (int i = 0; i < numSamples; i++) {
        float value = rawDataFloat[ch][i];
        if (value < yMin) yMin = value;
        if (value > yMax) yMax = value;
      }
      // Evita divisão por zero
      float range = (yMax - yMin == 0) ? 1 : (yMax - yMin);
      for (int i = 0; i < numSamples; i++) {
        scaledData[ch][i] = map(rawDataFloat[ch][i], yMin, yMax, -2048, 2048);
      }
    }
    return scaledData;
  } else if (scaleMode == 2) { // Modo Manual: usa o manualScaleFactor para mapear os dados
    for (int ch = 0; ch < numChannels; ch++) {
      for (int i = 0; i < numSamples; i++) {
        scaledData[ch][i] = map(rawDataFloat[ch][i] + manualDCOffset, -manualScaleFactor, manualScaleFactor, -2048, 2048);
      }
    }
    return scaledData;
  } else if (scaleMode == 0) { // Off: sem escala, retorna os dados crus convertidos para float
    return rawDataFloat;
  }
  return rawDataFloat;  // Valor padrão
}

void drawPhasorGraph(int PosX, int PosY, int Diameter, int Spacing) {
  noFill();  
  strokeWeight(1);
  
  ellipse(PosX, PosY, Diameter/3, Diameter/3);
  ellipse(PosX, PosY, Diameter*2/3, Diameter*2/3);
  float r = (Diameter/2) - Spacing; // Comprimento da linha: até a borda interna
  float angleDeg;
  float x_end, y_end;
  
  int[] angles = {0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330};
  for (int i = 0; i < angles.length; i++) {
    angleDeg = angles[i];
    // Converte para radianos
    float angleRad = radians(angleDeg);
    x_end = PosX + r * cos(angleRad);
    y_end = PosY + r * sin(angleRad);
    line(PosX, PosY, x_end, y_end);
  }
}
