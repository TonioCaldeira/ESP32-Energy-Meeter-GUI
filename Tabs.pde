// Desenhar as abas
void drawTabs() {
    String[] tabNames = { "Settings", "PQ Meter", "Time Domain", "Phasor Diagram", "Phase A", "Phase B", "Phase C" };
    int tabWidth = width / tabNames.length;
    textSize(22);
    stroke(255);
    strokeWeight(5);
    for (int i = 0; i < tabNames.length; i++) {
        if (i == activeTab) {
            fill(100, 255, 150); // Cor da aba ativa
        } else if (i == hoverTab) {
            fill(150, 150, 150); // Cor da aba em hover
        } else {
            fill(200); // Cor das abas inativas
        }
        rect(i * tabWidth, 0, tabWidth, 40); // Desenhar aba
        fill(0);
        textAlign(CENTER, CENTER);
        text(tabNames[i], i * tabWidth + tabWidth / 2, 20);
    }
}
