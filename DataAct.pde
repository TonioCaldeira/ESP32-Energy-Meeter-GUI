void receive(byte[] data, String senderIP, int senderPort) {
    // Indica que foi recebido qualquer pacote:
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
    //calibChannel = new short[numChannels]; // Inicializa o array com o tamanho adequado
    //println("Packet received, length: " + data.length);
    ByteBuffer buffer = ByteBuffer.wrap(data, 0, data.length - 2);
    buffer.order(ByteOrder.LITTLE_ENDIAN);

    packetCount = buffer.getInt();               //
    errorFlag = buffer.getShort();               //
    activeChannels = buffer.getShort();          //
    int sampleRate_x = buffer.getInt();          //
    UDPRateReal = buffer.getFloat();             //
    calibCoeffAtten = buffer.getShort();         //
    calibCoeffDCOffset = buffer.getShort();      //
    samplesPerPacketChannel = buffer.getShort(); //
    calibCoeffADC_A = buffer.getShort();         //
    calibCoeffADC_B = buffer.getShort();
    
    float alpha = 0.03;
    UDPRateAverage = UDPRateAverage * (1 - alpha) + UDPRateReal * alpha;    

    //REVISAR
    if (Math.abs(aux - UDPRateReal) / UDPRateReal > 0.1) {
      aux = UDPRateReal;  
      //updateDisplaySamples();   
    }
    //REVISAR

    for (int j = 0; j < numChannels; j++) {
      calibChannel[j] = buffer.getShort();
    }

    if (activeChannels > numChannels) {
      numChannels = activeChannels;
      channelData = new short[numChannels][displaySamples];
    } else if (channelData[0].length != displaySamples) {
      channelData = new short[numChannels][displaySamples];
    }
    
    //println("Packet count: " + packetCount + ", Active channels: " + activeChannels + ", Samples per channel: " + samplesPerPacketChannel + ", UDP_rate [Hz]: " + UDPRateReal + ", DC_offset: " + calibCoeffDCOffset);
    //println(samplesPerPacketChannel + " " + calibCoeffADC_A + " " + calibCoeffADC_B);
    for (int ch = 0; ch < activeChannels; ch++) {
      int numToCopy = displaySamples - samplesPerPacketChannel;
      // Realiza o arraycopy somente se houver elementos para copiar
      if (numToCopy > 0) {
          System.arraycopy(channelData[ch], samplesPerPacketChannel, channelData[ch], 0, numToCopy);
      }
  
      // Preenche os índices restantes com novos dados do buffer
      for (int i = numToCopy; i < displaySamples; i++) {
          if (buffer.hasRemaining()) {
              channelData[ch][i] = (short)(buffer.getShort() - calibCoeffDCOffset + calibChannel[ch]);
          } else {
              // Se não houver dados no buffer, utiliza o valor anterior (cuidando para o caso i==0)
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
