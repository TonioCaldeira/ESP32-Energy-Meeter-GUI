// Declaração dos componentes da interface
DropDown espDropDown;

Button selectButton;
Button updateButton;
Button triggerShotButton;
Button exportCSVButton;
Button playButton;
Button pauseButton;
Button helpButton;

// Campos de entrada
TextBox[] configInputs;

Checkbox checkboxMachine;
Checkbox checkboxUser;
Checkbox checkboxContinuousMode;
Checkbox checkboxShotMode;
Checkbox checkboxExportCSV;
Checkbox checkboxNoScale;
Checkbox checkboxAutoScale;
Checkbox checkboxManualScale;

PApplet helpWindow;

// Classe Botão
class Button {
    int x, y, w, h;
    String label;
    boolean clicked = false;

    Button(int x, int y, int w, int h, String label) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.label = label;
    }

    void display() {
        textSize(23);
        fill(clicked ? 200 : 255); // Muda a cor se estiver clicado
        stroke(0);
        rect(x, y, w, h, 5);
        fill(0);
        textAlign(CENTER, CENTER);
        text(label, x + w / 2, y + h / 2);
    }

    boolean isClicked(int mx, int my) {
        return mx >= x && mx <= x + w && my >= y && my <= y + h;
    }
}

// Classe lista Drop Down
class DropDown {
    int x, y, w, h;
    ArrayList<String> items;
    boolean expanded = false;
    int selectedIndex = -1;

    DropDown(int x, int y, int w, int h, ArrayList<String> items) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.items = items;
    }

    void display() {
        textSize(22);
        fill(255);
        stroke(200);
        rect(x, y, w, h); // Caixa principal
        fill(0);
        textAlign(LEFT, CENTER);
        String label = (selectedIndex >= 0) ? items.get(selectedIndex) : "Select an available Device...";
        text(label, x + 5, y + h / 2);

        // Setinha indicando a expansão
        fill(100);
        triangle(x + w - 15, y + h / 3, x + w - 5, y + h / 3, x + w - 10, y + 2 * h / 3);

        if (expanded) {
            for (int i = 0; i < items.size(); i++) {
                fill(i == selectedIndex ? 200 : 255);
                rect(x, y + h * (i + 1), w, h); // Opções
                fill(0);
                text(items.get(i), x + 5, y + h * (i + 1) + h / 2);
            }
        }
    }

    void handleClick(int mx, int my) {
        if (mx >= x && mx <= x + w && my >= y && my <= y + h) {
            expanded = !expanded; // Expande/contrai ao clicar na caixa principal
        } else if (expanded) {
            for (int i = 0; i < items.size(); i++) {
                if (mx >= x && mx <= x + w && my >= y + h * (i + 1) && my <= y + h * (i + 2)) {
                    selectedIndex = i;
                    expanded = false; // Fecha após selecionar
                    break;
                }
            }
        } else {
            expanded = false; // Fecha caso clique fora
        }
    }

    String getSelectedItem() {
        return (selectedIndex >= 0) ? items.get(selectedIndex) : null;
    }
}

// Classe para as caixas de texto
class TextBox {
    int x, y, w, h;
    String label;
    String text = "";
    boolean focused = false;

    TextBox(int x, int y, String label, float defaultValue) {
        this(x, y, label, str(defaultValue));
    }

    TextBox(int x, int y, String label, String defaultValue) {
        this.x = x+150;
        this.y = y;
        this.w = 180;
        this.h = 40;
        this.label = label;
        this.text = defaultValue.replace(',', '.');
    }

    void display() {
        fill(255);
        textAlign(LEFT, CENTER);
        text(label, x - 200, y + h / 2);

        stroke(focused ? color(100, 150, 255) : 200);
        fill(50);
        rect(x, y, w, h);

        fill(255);
        textAlign(LEFT, CENTER);
        text(text, x + 5, y + h / 2);
    }

    void handleClick(int mx, int my) {
        focused = (mx >= x && mx <= x + w && my >= y && my <= y + h);
    }

    void handleKeyPress(char key) {
        if (focused) {
            if (key == BACKSPACE && text.length() > 0) {
                text = text.substring(0, text.length() - 1);
            } else if (key == ENTER) {
                focused = false;
            } else if (key >= '0' && key <= '9' || key == '.' || key == '-') {
                text += key;
            }
        }
    }
}

// Classe Checkbox
class Checkbox {
    int x, y, size;
    String label;
    boolean selected = false;
    
    Checkbox(int x, int y, int size, String label) {
        this.x = x;
        this.y = y;
        this.size = size;
        this.label = label;
    }
    
    void display() {
        // Desenha a caixa da checkbox
        stroke(255);
        fill(selected ? color(0, 255, 100) : 200);
        rect(x, y, size, size);
        
        // Desenha o rótulo ao lado
        fill(255);
        textAlign(LEFT, CENTER);
        text(label, x + size + 10, y + size/2);
        
        // Opcional: desenha um "check" se estiver selecionada
        if (selected) {
            stroke(255);
            line(x + 3, y + size/2, x + size/2, y + size - 3);
            line(x + size/2, y + size - 3, x + size - 3, y + 3);
        }
    }
    
    // Verifica se o mouse está sobre a checkbox
    boolean isMouseOver(int mx, int my) {
        return (mx >= x && mx <= x + size && my >= y && my <= y + size);
    }
    
    void setSelected(boolean s) {
        selected = s;
    }
}

// Classe que implementa a janela de ajuda
public class HelpWindow extends PApplet {
  public void settings() {
    size(1000, 500);
  }
  
  public void setup() {
    background(255);
    textAlign(LEFT, CENTER);
    fill(0);
  }
  
  public void draw() {
    background(255);
    textSize(20);
    text("Instruções de Uso:\n\n" +
         "1° - Configure os parâmetros na aba 'Settings' e confirme com 'Update Parameters'.\n" +
         "2° - Escolha entre 'Local IP' e 'Custom IP' selecionando uma das caixas.\n" +
         "3° - Selecione um dispositivo disponivel e confirme com 'Confirm'.\n" +
         "4° - Use as caixas para alternar entre o modo Contínuo (Continuous Mode) e o modo de Disparo (Shot Mode).\n" +
         "5° - Use a aba superiora para navegar entre janelas.\n\n" +
         
         "Dentro do modo Contínuo:\n" + 
         "    Use a barra de espaço (SPACEBAR) para Pausar.\n" +
         "    Use as caixas para alternar entre escala Desativada, Automática e Manual.\n" +
         "    Use as setas direcionais (UP, DOWN, LEFT, RIGHT) para ajustar a escala manualmente em (Manual Scale).\n\n" +
         
         "Dentro do modo de Disparo:\n" + 
         "    Para aquisitar dados pressione 'Trigger Shot'.\n" + 
         "    Para exportar dados pressione 'Export CSV'.\n\n" +
         
         "Pressione ESC para fechar esta janela.", 50, height/2);
  }
  public void keyPressed() {
    if (key == ESC) {
      // Em vez de chamar exit(), que fecha o sketch inteiro, apenas feche o popup:
      surface.setVisible(false);
      key = 0;
    }
  }
}