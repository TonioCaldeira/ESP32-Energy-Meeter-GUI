// Função que calcula a hipotenusa usando a Lei dos Cossenos
float calcHip(float cat1, float cat2, float angle) {
  float c = sqrt(cat1*cat1 + cat2*cat2 - 2*cat1*cat2*cos(angle));
  return c;
}

// Função que calcula e exibe os parâmetros de qualidade de energia
void pqMeter(int selectionBarHeight) {
  float[] peakPercentage = new float[numChannels];  // Porcentagem do valor de pico
  float[] THD = new float[numChannels];             // Distorção harmônica total
  float[] RMS = new float[numChannels];             // Valor eficaz
  float[] magnitude = new float[numChannels];       // Magnitude da componente fundamental
  float[] phase = new float[numChannels];           // Fase da componente fundamental
  float ref = 0;
    
  for (int ch = 0; ch < numChannels; ch++) {
    float peakValue = 0;
    float rmsSum = 0;
    float[][] scaledData = applyScale(plotChannelData); // Aplicar escala aos dados
        
    for (int i = 0; i < displaySamples && i < plotChannelData[ch].length; i++) {
      float normalizedValue = plotChannelData[ch][i];
      peakValue = max(peakValue, abs(normalizedValue));
      rmsSum += sq(normalizedValue);
    }

    // Cálculos de RMS e THD
    float rmsValue = sqrt(rmsSum / displaySamples);
    if(ch < 3) RMS[ch] = rmsValue * voltageConv;
    if(ch >= 3) RMS[ch] = rmsValue * currentConv;
    float[][] harmonicsValues = calculateDFT(plotChannelData[ch], harmonics);
    
    if (ch == 0) ref = harmonicsValues[1][1]; // Referência do canal 0
    magnitude[ch] = harmonicsValues[1][0];
    phase[ch] = harmonicsValues[1][1] - ref;
    
    float sumAmplitudes = 0;
    for (int i = 0; i < harmonicsValues.length; i++) {
      sumAmplitudes += harmonicsValues[i][0];
    }

    float harmonicSum = 0;
    for (int i = 2; i < harmonicsValues.length; i++) {
      harmonicSum += sq(harmonicsValues[i][0]);
    }
    
    float fundamental = harmonicsValues[1][0];
    THD[ch] = (fundamental > 0) ? sqrt(harmonicSum) / fundamental * 100 : 0;
    peakPercentage[ch] = (peakValue*2 / maxRawValue) * 100;
  }
  
  int AuxA = 20;
  int AuxB = 55;
  int AuxC = 900;
  int AuxD = 60;
  int AuxE = 55;
  int Pos0 = AuxA + 1*AuxC/36;
  int Pos1 = AuxA + 4*AuxC/12;
  int Pos2 = AuxA + 5*AuxC/12;
  int Pos3 = AuxA + 6*AuxC/12;
  int Pos4 = AuxA + 7*AuxC/12;
  int Pos5 = AuxA + 8*AuxC/12;
  int Pos6 = AuxA + 9*AuxC/12;
  int Pos7 = AuxA + 10*AuxC/12;
  int Pos8 = AuxA + 11*AuxC/12;
  
  // Desenho das caixas de fundo
  fill(100, 100, 100);
  rect(AuxA, AuxB+5, Pos1-AuxA, AuxD, 15, 0, 0, 0);
  fill(100, 80, 80);
  rect(Pos1, AuxB+5, Pos3-Pos1, AuxD, 0, 0, 0, 0);
  fill(80, 80, 100);
  rect(Pos3, AuxB+5, Pos5-Pos3, AuxD, 0, 0, 0, 0);
  fill(80, 100, 80);
  rect(Pos5, AuxB+5, Pos7-Pos5, AuxD, 0, 0, 0, 0);
  fill(100, 100, 80);
  rect(Pos7, AuxB+5, AuxC-Pos7+AuxA, AuxD, 0, 15, 0, 0);
  
  fill(50, 50, 50);
  rect(AuxA, AuxB+AuxD, Pos1-AuxA, height-(AuxA+AuxB+AuxD), 0, 0, 0, 15);
  fill(50, 40, 40);
  rect(Pos1, AuxB+AuxD, Pos3-Pos1, height-(AuxA+AuxB+AuxD), 0, 0, 0, 0);
  fill(40, 40, 50);
  rect(Pos3, AuxB+AuxD, Pos5-Pos3, height-(AuxA+AuxB+AuxD), 0, 0, 0, 0);
  fill(40, 50, 40);
  rect(Pos5, AuxB+AuxD, Pos7-Pos5, height-(AuxA+AuxB+AuxD), 0, 0, 0, 0);
  fill(50, 50, 40);
  rect(Pos7, AuxB+AuxD, AuxC-Pos7+AuxA, height-(AuxA+AuxB+AuxD), 0, 0, 15, 0);
  
  fill(100, 100, 100);
  rect(AuxA, AuxB+555, Pos1-AuxA, AuxD-5, 0, 0, 0, 0);
  fill(100, 80, 80);
  rect(Pos1, AuxB+555, Pos3-Pos1, AuxD-5, 0, 0, 0, 0);
  fill(80, 80, 100);
  rect(Pos3, AuxB+555, Pos5-Pos3, AuxD-5, 0, 0, 0, 0);
  fill(80, 100, 80);
  rect(Pos5, AuxB+555, Pos7-Pos5, AuxD-5, 0, 0, 0, 0);
  fill(100, 100, 80);
  rect(Pos7, AuxB+555, AuxC-Pos7+AuxA, AuxD-5, 0, 0, 0, 0);

  // Desenho dos textos de cabeçalho
  textSize(27);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Phase A", Pos2, AuxB+AuxD/2+3);
  text("Phase B", Pos4, AuxB+AuxD/2+3);
  text("Phase C", Pos6, AuxB+AuxD/2+3);
  text("Neutral", Pos8, AuxB+AuxD/2+3);
  
  // Cálculo das magnitudes e fases das tensões e correntes
  float vMagA = voltageConv * magnitude[0];
  float vMagB = voltageConv * magnitude[1];
  float vMagC = voltageConv * magnitude[2];
  float vMagAB = calcHip(vMagA, vMagB, (phase[0]-phase[1]));
  float vMagBC = calcHip(vMagB, vMagC, (phase[1]-phase[2]));
  float vMagCA = calcHip(vMagC, vMagA, (phase[2]-phase[0]));
  float[] vMagN = sumPhasors(vMagA, phase[0], vMagB, phase[1], vMagC, phase[2]); 

  float iMagA = currentConv * magnitude[3];
  float iMagB = currentConv * magnitude[4];
  float iMagC = currentConv * magnitude[5];
  float iMagAB = calcHip(iMagA, iMagB, (phase[3]-phase[4]));
  float iMagBC = calcHip(iMagB, iMagC, (phase[4]-phase[5]));
  float iMagCA = calcHip(iMagC, iMagA, (phase[5]-phase[3]));
  float[] iMagN = sumPhasors(iMagA, phase[3], iMagB, phase[4], iMagC, phase[5]);
  
  // Exibição dos valores calculados
  textSize(26);
  text(nf(vMagA, 3, 1) + "V", Pos2, 2*AuxB+AuxD/2);
  text(nf(vMagB, 3, 1) + "V", Pos4, 2*AuxB+AuxD/2);
  text(nf(vMagC, 3, 1) + "V", Pos6, 2*AuxB+AuxD/2);
  text(nf(vMagN[0], 1, 1) + "V", Pos8, 2*AuxB+AuxD/2);
  
  text(nf(degrees(phase[0]), 1, 1) + "°", Pos2, 3*AuxB+AuxD/2);
  text(nf(degrees(phase[1]), 1, 1) + "°", Pos4, 3*AuxB+AuxD/2);
  text(nf(degrees(phase[2]), 1, 1) + "°", Pos6, 3*AuxB+AuxD/2);
  text(nf(degrees(vMagN[1]), 1, 1) + "°", Pos8, 3*AuxB+AuxD/2);
  
  text(nf(vMagAB, 1, 1) + "Vab", Pos2, 4*AuxB+AuxD/2);
  text(nf(vMagBC, 1, 1) + "Vbc", Pos4, 4*AuxB+AuxD/2);
  text(nf(vMagCA, 1, 1) + "Vca", Pos6, 4*AuxB+AuxD/2);
  text("---", Pos8, 4*AuxB+AuxD/2);
  
  text(nf(RMS[0], 3, 1) + "V", Pos2, 5*AuxB+AuxD/2);
  text(nf(RMS[1], 3, 1) + "V", Pos4, 5*AuxB+AuxD/2);
  text(nf(RMS[2], 3, 1) + "V", Pos6, 5*AuxB+AuxD/2);
  text("---", Pos8, 5*AuxB+AuxD/2);
  
  text(nf(THD[0], 1, 2) + "%", Pos2, 6*AuxB+AuxD/2);
  text(nf(THD[1], 1, 2) + "%", Pos4, 6*AuxB+AuxD/2);
  text(nf(THD[2], 1, 2) + "%", Pos6, 6*AuxB+AuxD/2);
  text("---", Pos8, 6*AuxB+AuxD/2);
  
  text(nf(iMagA, 2, 2) + "A", Pos2, 7*AuxB+AuxD/2);
  text(nf(iMagB, 2, 2) + "A", Pos4, 7*AuxB+AuxD/2);
  text(nf(iMagC, 2, 2) + "A", Pos6, 7*AuxB+AuxD/2);
  text(nf(iMagN[0], 1, 1) + "A", Pos8, 7*AuxB+AuxD/2);
  
  text(nf(degrees(phase[3]), 1, 1) + "°", Pos2, 8*AuxB+AuxD/2);
  text(nf(degrees(phase[4]), 1, 1) + "°", Pos4, 8*AuxB+AuxD/2);
  text(nf(degrees(phase[5]), 1, 1) + "°", Pos6, 8*AuxB+AuxD/2);
  text(nf(degrees(iMagN[1]), 1, 1) + "°", Pos8, 8*AuxB+AuxD/2);
  
  text(nf(RMS[3], 2, 2) + "A", Pos2, 9*AuxB+AuxD/2);
  text(nf(RMS[4], 2, 2) + "A", Pos4, 9*AuxB+AuxD/2);
  text(nf(RMS[5], 2, 2) + "A", Pos6, 9*AuxB+AuxD/2);
  text("---", Pos8, 9*AuxB+AuxD/2);
  
  text(nf(THD[3], 1, 2) + "%", Pos2, 10*AuxB+AuxD/2);
  text(nf(THD[4], 1, 2) + "%", Pos4, 10*AuxB+AuxD/2);
  text(nf(THD[5], 1, 2) + "%", Pos6, 10*AuxB+AuxD/2);
  text("---", Pos8, 10*AuxB+AuxD/2);

  // Cálculo das potências
  float activePowerA   = vMagA * iMagA * cos(phase[0]-phase[3]);   // em Watts (W)
  float activePowerB   = vMagB * iMagB * cos(phase[1]-phase[4]);
  float activePowerC   = vMagC * iMagC * cos(phase[2]-phase[5]);
  float apparentPowerA = vMagA * iMagA;                            // em Volt-Amperes (VA)
  float apparentPowerB = vMagB * iMagB; 
  float apparentPowerC = vMagC * iMagC; 
  float reactivePowerA = vMagA * iMagA * sin(phase[0]-phase[3]);   // em Volt-Ampere Reativos (VAR)
  float reactivePowerB = vMagB * iMagB * sin(phase[1]-phase[4]);
  float reactivePowerC = vMagC * iMagC * sin(phase[2]-phase[5]);
  
  text(nf(activePowerA, 1, 1) + "W", Pos2, 12*AuxB+AuxD/2);
  text(nf(activePowerB, 1, 1) + "W", Pos4, 12*AuxB+AuxD/2);
  text(nf(activePowerC, 1, 1) + "W", Pos6, 12*AuxB+AuxD/2);
  text(nf(activePowerA+activePowerB+activePowerC, 1, 1) + "W", Pos8, 12*AuxB+AuxD/2);
  
  text(nf(apparentPowerA, 1, 1) + "VA", Pos2, 13*AuxB+AuxD/2);
  text(nf(apparentPowerB, 1, 1) + "VA", Pos4, 13*AuxB+AuxD/2);
  text(nf(apparentPowerC, 1, 1) + "VA", Pos6, 13*AuxB+AuxD/2);
  text(nf(apparentPowerA+apparentPowerB+apparentPowerC, 1, 1) + "VA", Pos8, 13*AuxB+AuxD/2);
  
  text(nf(reactivePowerA, 1, 1) + "VAr", Pos2, 14*AuxB+AuxD/2);
  text(nf(reactivePowerB, 1, 1) + "VAr", Pos4, 14*AuxB+AuxD/2);
  text(nf(reactivePowerC, 1, 1) + "VAr", Pos6, 14*AuxB+AuxD/2);
  text(nf(reactivePowerA+reactivePowerB+reactivePowerC, 1, 1) + "VAr", Pos8, 14*AuxB+AuxD/2);
  
  text(nf(cos(phase[0]-phase[3]), 1, 3) + "", Pos2, 15*AuxB+AuxD/2);
  text(nf(cos(phase[1]-phase[4]), 1, 3) + "", Pos4, 15*AuxB+AuxD/2);
  text(nf(cos(phase[2]-phase[5]), 1, 3) + "", Pos6, 15*AuxB+AuxD/2);
  text(nf((activePowerA+activePowerB+activePowerC)/(apparentPowerA+apparentPowerB+apparentPowerC), 1, 3), Pos8, 15*AuxB+AuxD/2);
  
  // Desenho dos textos de rodapé
  textSize(27);
  text("A-N", Pos2, 11*AuxB+AuxD/2+3);
  text("B-N", Pos4, 11*AuxB+AuxD/2+3);
  text("C-N", Pos6, 11*AuxB+AuxD/2+3);
  text("A-B-C", Pos8, 11*AuxB+AuxD/2+3);
  textAlign(LEFT, CENTER);
  text("POWER", Pos0, 11*AuxB+AuxD/2+3);
  text("OVERVIEW", Pos0, 1*AuxB+AuxD/2+3);
  
  textSize(26);
  text("Voltage P-N (60Hz)", Pos0, 2*AuxB+AuxD/2);
  text("Voltage Angle", Pos0, 3*AuxB+AuxD/2);
  text("Voltage P-P (60Hz)", Pos0, // Função que calcula a hipotenusa usando a Lei dos Cossenos
float calcHip(float cat1, float cat2, float angle) {
  float c = sqrt(cat1*cat1 + cat2*cat2 - 2*cat1*cat2*cos(angle));
  return c;
}

// Função que calcula e exibe os parâmetros de qualidade de energia
void pqMeter(int selectionBarHeight) {
  float[] peakPercentage = new float[numChannels];
  float[] THD = new float[numChannels];
  float[] RMS = new float[numChannels];
  float[] magnitude = new float[numChannels];
  float[] phase = new float[numChannels];
  float ref = 0;
    
  for (int ch = 0; ch < numChannels; ch++) {
    float peakValue = 0;
    float rmsSum = 0;
    float[][] scaledData = applyScale(plotChannelData); // Aplicar escala aos dados
        
    for (int i = 0; i < displaySamples && i < plotChannelData[ch].length; i++) {
      float normalizedValue = plotChannelData[ch][i];
      peakValue = max(peakValue, abs(normalizedValue));
      rmsSum += sq(normalizedValue);
    }

    // Cálculos de RMS e THD
    float rmsValue = sqrt(rmsSum / displaySamples);
    if(ch < 3) RMS[ch] = rmsValue * voltageConv;
    if(ch >= 3) RMS[ch] = rmsValue * currentConv;
    float[][] harmonicsValues = calculateDFT(plotChannelData[ch], harmonics);
    
    if (ch == 0) ref = harmonicsValues[1][1]; // Referência do canal 0
    magnitude[ch] = harmonicsValues[1][0];
    phase[ch] = harmonicsValues[1][1] - ref;
    
    float sumAmplitudes = 0;
    for (int i = 0; i < harmonicsValues.length; i++) {
      sumAmplitudes += harmonicsValues[i][0];
    }

    float harmonicSum = 0;
    for (int i = 2; i < harmonicsValues.length; i++) {
      harmonicSum += sq(harmonicsValues[i][0]);
    }
    
    float fundamental = harmonicsValues[1][0];
    THD[ch] = (fundamental > 0) ? sqrt(harmonicSum) / fundamental * 100 : 0;
    peakPercentage[ch] = (peakValue*2 / maxRawValue) * 100;
  }
  
  int AuxA = 20;
  int AuxB = 55;
  int AuxC = 900;
  int AuxD = 60;
  int AuxE = 55;
  int Pos0 = AuxA + 1*AuxC/36;
  int Pos1 = AuxA + 4*AuxC/12;
  int Pos2 = AuxA + 5*AuxC/12;
  int Pos3 = AuxA + 6*AuxC/12;
  int Pos4 = AuxA + 7*AuxC/12;
  int Pos5 = AuxA + 8*AuxC/12;
  int Pos6 = AuxA + 9*AuxC/12;
  int Pos7 = AuxA + 10*AuxC/12;
  int Pos8 = AuxA + 11*AuxC/12;
  
  // Desenho das caixas de fundo
  fill(100, 100, 100);
  rect(AuxA, AuxB+5, Pos1-AuxA, AuxD, 15, 0, 0, 0);
  fill(100, 80, 80);
  rect(Pos1, AuxB+5, Pos3-Pos1, AuxD, 0, 0, 0, 0);
  fill(80, 80, 100);
  rect(Pos3, AuxB+5, Pos5-Pos3, AuxD, 0, 0, 0, 0);
  fill(80, 100, 80);
  rect(Pos5, AuxB+5, Pos7-Pos5, AuxD, 0, 0, 0, 0);
  fill(100, 100, 80);
  rect(Pos7, AuxB+5, AuxC-Pos7+AuxA, AuxD, 0, 15, 0, 0);
  
  fill(50, 50, 50);
  rect(AuxA, AuxB+AuxD, Pos1-AuxA, height-(AuxA+AuxB+AuxD), 0, 0, 0, 15);
  fill(50, 40, 40);
  rect(Pos1, AuxB+AuxD, Pos3-Pos1, height-(AuxA+AuxB+AuxD), 0, 0, 0, 0);
  fill(40, 40, 50);
  rect(Pos3, AuxB+AuxD, Pos5-Pos3, height-(AuxA+AuxB+AuxD), 0, 0, 0, 0);
  fill(40, 50, 40);
  rect(Pos5, AuxB+AuxD, Pos7-Pos5, height-(AuxA+AuxB+AuxD), 0, 0, 0, 0);
  fill(50, 50, 40);
  rect(Pos7, AuxB+AuxD, AuxC-Pos7+AuxA, height-(AuxA+AuxB+AuxD), 0, 0, 15, 0);
  
  fill(100, 100, 100);
  rect(AuxA, AuxB+555, Pos1-AuxA, AuxD-5, 0, 0, 0, 0);
  fill(100, 80, 80);
  rect(Pos1, AuxB+555, Pos3-Pos1, AuxD-5, 0, 0, 0, 0);
  fill(80, 80, 100);
  rect(Pos3, AuxB+555, Pos5-Pos3, AuxD-5, 0, 0, 0, 0);
  fill(80, 100, 80);
  rect(Pos5, AuxB+555, Pos7-Pos5, AuxD-5, 0, 0, 0, 0);
  fill(100, 100, 80);
  rect(Pos7, AuxB+555, AuxC-Pos7+AuxA, AuxD-5, 0, 0, 0, 0);

  // Desenho dos textos de cabeçalho
  textSize(27);
  fill(255);
  textAlign(CENTER, CENTER);
  text("Phase A", Pos2, AuxB+AuxD/2+3);
  text("Phase B", Pos4, AuxB+AuxD/2+3);
  text("Phase C", Pos6, AuxB+AuxD/2+3);
  text("Neutral", Pos8, AuxB+AuxD/2+3);
  
  // Cálculo das magnitudes e fases das tensões e correntes
  float vMagA = voltageConv * magnitude[0];
  float vMagB = voltageConv * magnitude[1];
  float vMagC = voltageConv * magnitude[2];
  float vMagAB = calcHip(vMagA, vMagB, (phase[0]-phase[1]));
  float vMagBC = calcHip(vMagB, vMagC, (phase[1]-phase[2]));
  float vMagCA = calcHip(vMagC, vMagA, (phase[2]-phase[0]));
  float[] vMagN = sumPhasors(vMagA, phase[0], vMagB, phase[1], vMagC, phase[2]); 

  float iMagA = currentConv * magnitude[3];
  float iMagB = currentConv * magnitude[4];
  float iMagC = currentConv * magnitude[5];
  float iMagAB = calcHip(iMagA, iMagB, (phase[3]-phase[4]));
  float iMagBC = calcHip(iMagB, iMagC, (phase[4]-phase[5]));
  float iMagCA = calcHip(iMagC, iMagA, (phase[5]-phase[3]));
  float[] iMagN = sumPhasors(iMagA, phase[3], iMagB, phase[4], iMagC, phase[5]);
  
  // Exibição dos valores calculados
  textSize(26);
  text(nf(vMagA, 3, 1) + "V", Pos2, 2*AuxB+AuxD/2);
  text(nf(vMagB, 3, 1) + "V", Pos4, 2*AuxB+AuxD/2);
  text(nf(vMagC, 3, 1) + "V", Pos6, 2*AuxB+AuxD/2);
  text(nf(vMagN[0], 1, 1) + "V", Pos8, 2*AuxB+AuxD/2);
  
  text(nf(degrees(phase[0]), 1, 1) + "°", Pos2, 3*AuxB+AuxD/2);
  text(nf(degrees(phase[1]), 1, 1) + "°", Pos4, 3*AuxB+AuxD/2);
  text(nf(degrees(phase[2]), 1, 1) + "°", Pos6, 3*AuxB+AuxD/2);
  text(nf(degrees(vMagN[1]), 1, 1) + "°", Pos8, 3*AuxB+AuxD/2);
  
  text(nf(vMagAB, 1, 1) + "Vab", Pos2, 4*AuxB+AuxD/2);
  text(nf(vMagBC, 1, 1) + "Vbc", Pos4, 4*AuxB+AuxD/2);
  text(nf(vMagCA, 1, 1) + "Vca", Pos6, 4*AuxB+AuxD/2);
  text("---", Pos8, 4*AuxB+AuxD/2);
  
  text(nf(RMS[0], 3, 1) + "V", Pos2, 5*AuxB+AuxD/2);
  text(nf(RMS[1], 3, 1) + "V", Pos4, 5*AuxB+AuxD/2);
  text(nf(RMS[2], 3, 1) + "V", Pos6, 5*AuxB+AuxD/2);
  text("---", Pos8, 5*AuxB+AuxD/2);
  
  text(nf(THD[0], 1, 2) + "%", Pos2, 6*AuxB+AuxD/2);
  text(nf(THD[1], 1, 2) + "%", Pos4, 6*AuxB+AuxD/2);
  text(nf(THD[2], 1, 2) + "%", Pos6, 6*AuxB+AuxD/2);
  text("---", Pos8, 6*AuxB+AuxD/2);
  
  text(nf(iMagA, 2, 2) + "A", Pos2, 7*AuxB+AuxD/2);
  text(nf(iMagB, 2, 2) + "A", Pos4, 7*AuxB+AuxD/2);
  text(nf(iMagC, 2, 2) + "A", Pos6, 7*AuxB+AuxD/2);
  text(nf(iMagN[0], 1, 1) + "A", Pos8, 7*AuxB+AuxD/2);
  
  text(nf(degrees(phase[3]), 1, 1) + "°", Pos2, 8*AuxB+AuxD/2);
  text(nf(degrees(phase[4]), 1, 1) + "°", Pos4, 8*AuxB+AuxD/2);
  text(nf(degrees(phase[5]), 1, 1) + "°", Pos6, 8*AuxB+AuxD/2);
  text(nf(degrees(iMagN[1]), 1, 1) + "°", Pos8, 8*AuxB+AuxD/2);
  
  text(nf(RMS[3], 2, 2) + "A", Pos2, 9*AuxB+AuxD/2);
  text(nf(RMS[4], 2, 2) + "A", Pos4, 9*AuxB+AuxD/2);
  text(nf(RMS[5], 2, 2) + "A", Pos6, 9*AuxB+AuxD/2);
  text("---", Pos8, 9*AuxB+AuxD/2);
  
  text(nf(THD[3], 1, 2) + "%", Pos2, 10*AuxB+AuxD/2);
  text(nf(THD[4], 1, 2) + "%", Pos4, 10*AuxB+AuxD/2);
  text(nf(THD[5], 1, 2) + "%", Pos6, 10*AuxB+AuxD/2);
  text("---", Pos8, 10*AuxB+AuxD/2);

  // Cálculo das potências
  float activePowerA   = vMagA * iMagA * cos(phase[0]-phase[3]);   // em Watts (W)
  float activePowerB   = vMagB * iMagB * cos(phase[1]-phase[4]);
  float activePowerC   = vMagC * iMagC * cos(phase[2]-phase[5]);
  float apparentPowerA = vMagA * iMagA;                            // em Volt-Amperes (VA)
  float apparentPowerB = vMagB * iMagB; 
  float apparentPowerC = vMagC * iMagC; 
  float reactivePowerA = vMagA * iMagA * sin(phase[0]-phase[3]);   // em Volt-Ampere Reativos (VAR)
  float reactivePowerB = vMagB * iMagB * sin(phase[1]-phase[4]);
  float reactivePowerC = vMagC * iMagC * sin(phase[2]-phase[5]);
  
  text(nf(activePowerA, 1, 1) + "W", Pos2, 12*AuxB+AuxD/2);
  text(nf(activePowerB, 1, 1) + "W", Pos4, 12*AuxB+AuxD/2);
  text(nf(activePowerC, 1, 1) + "W", Pos6, 12*AuxB+AuxD/2);
  text(nf(activePowerA+activePowerB+activePowerC, 1, 1) + "W", Pos8, 12*AuxB+AuxD/2);
  
  text(nf(apparentPowerA, 1, 1) + "VA", Pos2, 13*AuxB+AuxD/2);
  text(nf(apparentPowerB, 1, 1) + "VA", Pos4, 13*AuxB+AuxD/2);
  text(nf(apparentPowerC, 1, 1) + "VA", Pos6, 13*AuxB+AuxD/2);
  text(nf(apparentPowerA+apparentPowerB+apparentPowerC, 1, 1) + "VA", Pos8, 13*AuxB+AuxD/2);
  
  text(nf(reactivePowerA, 1, 1) + "VAr", Pos2, 14*AuxB+AuxD/2);
  text(nf(reactivePowerB, 1, 1) + "VAr", Pos4, 14*AuxB+AuxD/2);
  text(nf(reactivePowerC, 1, 1) + "VAr", Pos6, 14*AuxB+AuxD/2);
  text(nf(reactivePowerA+reactivePowerB+reactivePowerC, 1, 1) + "VAr", Pos8, 14*AuxB+AuxD/2);
  
  text(nf(cos(phase[0]-phase[3]), 1, 3) + "", Pos2, 15*AuxB+AuxD/2);
  text(nf(cos(phase[1]-phase[4]), 1, 3) + "", Pos4, 15*AuxB+AuxD/2);
  text(nf(cos(phase[2]-phase[5]), 1, 3) + "", Pos6, 15*AuxB+AuxD/2);
  text(nf((activePowerA+activePowerB+activePowerC)/(apparentPowerA+apparentPowerB+apparentPowerC), 1, 3), Pos8, 15*AuxB+AuxD/2);
  
  // Desenho dos textos de rodapé
  textSize(27);
  text("A-N", Pos2, 11*AuxB+AuxD/2+3);
  text("B-N", Pos4, 11*AuxB+AuxD/2+3);
  text("C-N", Pos6, 11*AuxB+AuxD/2+3);
  text("A-B-C", Pos8, 11*AuxB+AuxD/2+3);
  textAlign(LEFT, CENTER);
  text("POWER", Pos0, 11*AuxB+AuxD/2+3);
  text("OVERVIEW", Pos0, 1*AuxB+AuxD/2+3);
  
  textSize(26);
  text("Voltage P-N (60Hz)", Pos0, 2*AuxB+AuxD/2);
  text("Voltage Angle", Pos0, 3*AuxB+AuxD/2);
  text("Voltage P-P (60Hz)", Pos0, 4*AuxB+AuxD/2);
  text("Voltage P-N (Total)", Pos0, 5*AuxB+AuxD/2);
  text("Voltage THD", Pos0, 6*AuxB+AuxD/2);
  text("Current P-N (60Hz)", Pos0, 7*AuxB+AuxD/2);
  text("Current Angle", Pos0, 8*AuxB+AuxD/2);
  text("Current P-N (Total)", Pos0, 9*AuxB+AuxD/2);
  text("Current THD", Pos0, 10*AuxB+AuxD/2);
  text("Active", Pos0, 12*AuxB+AuxD/2);
  text("Apparent", Pos0, 13*AuxB+AuxD/2);
  text("Reactive", Pos0, 14*AuxB+AuxD/2);
  text("Power Factor", Pos0, 15*AuxB+AuxD/2);
  
  line(AuxA, 169+AuxE*4, AuxC+AuxA, 169+AuxE*4);
  
  strokeWeight(1);
  for (int x = 0; x < 13; x++) line(AuxA, 169+AuxE*x, AuxC+AuxA, 169+AuxE*x);
} 
  

// Função que soma 3 fasores, recebendo 3 magnitudes e 3 fases (em radianos),
// e retorna um vetor de 2 floats: [magnitude_resultante, fase_resultante]
float[] sumPhasors(float m1, float phase1, float m2, float phase2, float m3, float phase3) {
  // Converte cada fasor para suas componentes reais e imaginárias:
  float re1 = m1 * cos(phase1);
  float im1 = m1 * sin(phase1);
  
  float re2 = m2 * cos(phase2);
  float im2 = m2 * sin(phase2);
  
  float re3 = m3 * cos(phase3);
  float im3 = m3 * sin(phase3);
  
  // Soma as componentes
  float sumRe = re1 + re2 + re3;
  float sumIm = im1 + im2 + im3;
  
  // Calcula a magnitude e a fase do fasor resultante
  float resultMag = sqrt(sumRe * sumRe + sumIm * sumIm);
  float resultPhase = atan2(sumIm, sumRe);
  
  return new float[] { resultMag, resultPhase };
}
