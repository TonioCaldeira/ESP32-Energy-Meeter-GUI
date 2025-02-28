/**
 * Estima a frequência de um sinal usando o método de cruzamento por zero
 * com interpolação linear, combinada com o período esperado (calculado a partir de cyclesToDisplay).
 *
 * @param data O array de amostras do sinal.
 * @param sampleRate A taxa de amostragem em Hz.
 * @param cyclesToDisplay Número de ciclos contidos no vetor 'data'.
 * @return A frequência estimada em Hz.
 */
float estimateFrequency(short[] data, float sampleRate, int cyclesToDisplay) {
  int N = data.length;
  float lastCrossing = -1;
  float sumPeriods = 0;
  int count = 0;
  
  // Percorre o vetor para detectar zero crossings e calcular períodos (em número de amostras)
  for (int i = 1; i < N; i++) {
    if ((data[i-1] < 0 && data[i] >= 0) || (data[i-1] > 0 && data[i] <= 0)) {
      float delta = data[i] - data[i-1];
      // Interpolação linear para refinar a posição do cruzamento
      float fraction = (delta != 0) ? abs(data[i-1]) / abs(delta) : 0;
      float crossingPos = (i - 1) + fraction;
      
      if (lastCrossing >= 0) {
        float period = crossingPos - lastCrossing;
        sumPeriods += period;
        count++;
      }
      lastCrossing = crossingPos;
    }
  }
  
  // Se não houver zero crossings suficientes, retorna 0
  if (count < 1) return 0;
  
  // Período médio medido (entre zero-crossings)
  float avgPeriodMeasured = sumPeriods / count;
  // Como uma senóide cruza zero duas vezes por ciclo, o período do ciclo em amostras é:
  float measuredCycle = avgPeriodMeasured * 2;
  
  // Calcula o período esperado a partir do número de ciclos exibidos
  float expectedCycle = (float) N / cyclesToDisplay;
  
  // Faz a média dos dois períodos para compensar erros de quantização
  float finalCycle = (measuredCycle + expectedCycle) / 2.0;
  
  // Calcula a frequência: f = sampleRate / período (em amostras)
  float frequency = sampleRate / finalCycle;
  
  return frequency;
}
