void mouseReleased() {
    selectButton.clicked = false;
    updateButton.clicked = false;
    triggerShotButton.clicked = false;
    exportCSVButton.clicked = false;
    play.clicked = false;
    pause.clicked = false;
    help.clicked = false;
}

// Passar evento de teclado para caixas de texto
void keyPressed() {
    if (activeTab == 0) {
      for (TextBox input : configInputs) {
        input.handleKeyPress(key);
      }
    } else if (activeTab > 0) {
      if (key == ' ') {
        if (shotModeActive) {
          triggerCaptureShot();
        } else {
          pausePlot = !pausePlot;
        }
      }
    }
    
    // Se estiver no modo manual, ajuste o manualScaleFactor com as teclas '+' e '-'
    if (scaleMode == 2) {
      if (keyCode == LEFT) {  // Aumenta o fator de escala (amplia o intervalo, o que reduz o zoom)\n
        manualScaleFactor += 20;
        println("manualScaleFactor: " + manualScaleFactor);
      } else if (keyCode == RIGHT) {  // Diminui o fator de escala (reduz o intervalo, aumentando o zoom)\n
        manualScaleFactor -= 20;
        if (manualScaleFactor < 100) manualScaleFactor = 100;  // Evitar valores muito baixos
        println("manualScaleFactor: " + manualScaleFactor);
      } else if (keyCode == UP) {
        manualDCOffset += 4;
        if (manualDCOffset > 2048) manualDCOffset = 2048;  // Evitar valores muito baixos
        println("manualDCOffset: " + manualDCOffset);
      } else if (keyCode == DOWN) {
        manualDCOffset -= 4;
        if (manualDCOffset < -2048) manualDCOffset = -2048;  // Evitar valores muito baixos
        println("manualDCOffset: " + manualDCOffset);
      }
    }
  
}

// Detectar hover nas abas
void mouseMoved() {
    int tabWidth = width / 7;
    if (mouseY < 40) {
        hoverTab = mouseX / tabWidth;
    } else {
        hoverTab = -1;
    }
}

// Alternar aba ao clicar
void mousePressed() {
    int tabWidth = width / 7;
    if (mouseY < 40) {
        activeTab = mouseX / tabWidth;
    }

    // Passar evento de clique para caixas de texto
    if (activeTab == 0) {
      
        // Verifica se o clique ocorreu nos checkboxes de modo
        if (checkboxContinuousMode.isMouseOver(mouseX, mouseY)) {
          checkboxContinuousMode.setSelected(true);
          checkboxShotMode.setSelected(false);
          shotModeActive = false;
          shotCaptured = false;  // Ao voltar para continuous, descarta os dados congelados
          indicatorCSV = 0;
        } else if (checkboxShotMode.isMouseOver(mouseX, mouseY)) {
          checkboxShotMode.setSelected(true);
          checkboxContinuousMode.setSelected(false);
          shotModeActive = true;
          indicatorCSV = 1;
        }
        
        // Verifica se o botão de trigger foi clicado
        if (triggerShotButton.isClicked(mouseX, mouseY) && shotModeActive) {
          // Se o botão for acionado, ativa o shot_mode e captura os dados
          triggerShotButton.clicked = true;
          shotSampleCounter = 0;
          indicatorCSV = 1;
          shotTrigger = true;
          println("Shot mode: dados congelados!");
        } else if (exportCSVButton.isClicked(mouseX, mouseY) && shotModeActive && shotCSV) {
          exportShotDataToCSV();
          exportCSVButton.clicked = true;
          println("CSV Exportado");
        }
        
        if (checkboxMachine.isMouseOver(mouseX, mouseY)) {
          checkboxMachine.setSelected(true);
          checkboxUser.setSelected(false);
        } else if (checkboxUser.isMouseOver(mouseX, mouseY)) {
          checkboxMachine.setSelected(false);
          checkboxUser.setSelected(true);
        }
        
        if (checkboxNoScale.isMouseOver(mouseX, mouseY)) {
          checkboxNoScale.setSelected(true);
          checkboxAutoScale.setSelected(false);
          checkboxManualScale.setSelected(false);
          scaleMode = 0;
        } else if (checkboxAutoScale.isMouseOver(mouseX, mouseY)) {
          checkboxNoScale.setSelected(false);
          checkboxAutoScale.setSelected(true);
          checkboxManualScale.setSelected(false);
          scaleMode = 1;
        } else if (checkboxManualScale.isMouseOver(mouseX, mouseY)) {
          checkboxNoScale.setSelected(false);
          checkboxAutoScale.setSelected(false);
          checkboxManualScale.setSelected(true);
          scaleMode = 2;
        }
              
        if (play.isClicked(mouseX, mouseY)) {
          play.clicked = true;
          pausePlot = false;
        } else if (pause.isClicked(mouseX, mouseY)) {
          pause.clicked = true;
          pausePlot = true;  
        }
        
        if (help.isClicked(mouseX, mouseY)) {
          help.clicked = true;
          String[] args = {"Ajuda"};
          PApplet.runSketch(args, helpWindow);
          helpWindow = new HelpWindow();
        }
        
        // Passa o evento de clique para as caixas de texto
        for (TextBox input : configInputs) {
            input.handleClick(mouseX, mouseY);
        }
        espDropDown.handleClick(mouseX, mouseY);
        
        // Verifica clique no botão de seleção
        if (selectButton.isClicked(mouseX, mouseY)) {
            selectButton.clicked = true;
            String selectedESP = espDropDown.getSelectedItem();
            if (selectedESP != null) {
                String espIP = extractIP(selectedESP);
                if (espIP != null) {
                    // Define qual IP enviar com base na checkbox selecionada
                    ipToSend = (checkboxMachine.selected) ? localIPAddress : customIPAddres;
                    String message = "SELECTED " + ipToSend;
                    udp.send(message, espIP, port_selected);
                    println("Comando enviado ao ESP: " + espIP + " com IP: " + ipToSend);
                } else {
                    println("IP não encontrado na seleção!");
                }
            } else {
                println("Nenhum ESP selecionado!");
            }
        }
        
        // Verifica clique no botão de atualização dos parâmetros
        if (updateButton.isClicked(mouseX, mouseY)) {
            updateButton.clicked = true;
            handleUpdateParameters();
        }
    }
}
