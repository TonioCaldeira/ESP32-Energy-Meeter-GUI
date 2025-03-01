// Função chamada ao receber um pacote de dados
void receive(byte[] data, String senderIP, int senderPort) {
    // Atualiza o tempo do último pacote recebido
    lastAnyPacketMillis = millis();

    if (data.length == 1000) {
        // Pacote de dados
        ipData = senderIP;
        lastDataPacketMillis = millis();
        processDataPacket(data);
    } else if (data.length >= 50) {
        // Pacote presumido conter o IP
        String espIP = new String(data).trim();
        if (!espDevices.contains(espIP)) {
            espDevices.add(espIP);
            println("ESP encontrado: " + espIP);
        }
    } else {
        println("Pacote inesperado recebido. Tamanho: " + data.length);
    }
}

// Processa pacotes de dados com tamanho 1000
void processDataPacket(byte[] data) {
    ByteBuffer buffer = ByteBuffer.wrap(data, 0, data.length - 2);
    buffer.order(ByteOrder.LITTLE_ENDIAN);

    packetCount = buffer.getInt();               // Contador de pacotes
    errorFlag = buffer.getShort();               // Flag de erro
    activeChannels = buffer.getShort();          // Número de canais ativos
    int sampleRate_x = buffer.getInt();          // Taxa de amostragem
    UDPRateReal = buffer.getFloat();             // Taxa UDP real
    calibCoeffAtten = buffer.getShort();         // Coeficiente de calibração de atenuação
    calibCoeffDCOffset = buffer.getShort();      // Coeficiente de calibração de offset DC
    samplesPerPacketChannel = buffer.getShort(); // Amostras por pacote por canal
    calibCoeffADC_A = buffer.getShort();         // Coeficiente de calibração ADC A
    calibCoeffADC_B = buffer.getShort();         // Coeficiente de calibração ADC B
    
    float alpha = 0.03;
    UDPRateAverage = UDPRateAverage * (1 - alpha) + UDPRateReal * alpha;    

    // Verifica se a taxa UDP real mudou significativamente
    if (Math.abs(aux - UDPRateAverage) / UDPRateAverage > 0.25) {
      aux = UDPRateAverage;  
      updateDisplaySamples();   
    }

    // Atualiza os coeficientes de calibração para cada canal
    for (int j = 0; j < numChannels; j++) {
      calibChannel[j] = buffer.getShort();
    }

    // Ajusta o número de canais ativos e o tamanho do array de dados do canal
    if (activeChannels > numChannels) {
      numChannels = activeChannels;
      channelData = new short[numChannels][displaySamples];
    } else if (channelData[0].length != displaySamples) {
      channelData = new short[numChannels][displaySamples];
    }
    
    // Copia os dados do buffer para o array de dados do canal
    for (int ch = 0; ch < activeChannels; ch++) {
      int numToCopy = displaySamples - samplesPerPacketChannel;
      if (numToCopy > 0) {
          System.arraycopy(channelData[ch], samplesPerPacketChannel, channelData[ch], 0, numToCopy);
      }
  
      for (int i = numToCopy; i < displaySamples; i++) {
          if (buffer.hasRemaining()) {
              channelData[ch][i] = (short)(buffer.getShort() - calibCoeffDCOffset + calibChannel[ch]);
          } else {
              channelData[ch][i] = (i > 0 ? channelData[ch][i - 1] : 0);
          }
      }
   }
   shotSampleCounter += samplesPerPacketChannel;
   newDataAvailable = true;
   if (first_setup){
     numChannels = activeChannels;
     samplePerChannel = samplesPerPacketChannel;
     first_setup = false;
   }
}