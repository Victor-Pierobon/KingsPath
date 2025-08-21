import sys
from PyQt6.QtWidgets import QApplication, QMainWindow, QWidget, QLabel, QProgressBar, QVBoxLayout, QHBoxLayout
from PyQt6.QtCore import Qt
from models import Player


class MainWindow(QMainWindow):
    """
    Janela principal do app
    """
    def __init__(self):
        super().__init__() # Chama o construtor da classe pai
        self.player = Player("NullByte")
        self.setWindowTitle("Kings Path")
        self.setGeometry(100, 100, 600, 400) # posição x, posição y, largura, Altura
        self.setup_ui()

    def setup_ui(self):
        """
        Cria e organiza todos o widget's da interface
        """
        central_widget = QWidget()
        self.setCentralWidget(central_widget)

        main_layout = QVBoxLayout()
        central_widget.setLayout(main_layout)

        player_name_label = QLabel(f"jogador: {self.player.name}")
        player_name_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        player_name_label.setStyleSheet("font-size: 24px; font-weight: bold; margin-bottom: 20px;")
        main_layout.addWidget(player_name_label)

        # Usamos um loop para criar uma linha para cada atributo do jogador
        for attr_name, attribute in self.player.attributes.items():
            attr_label = QLabel(f"{attr_name}: Nível: {attribute.level}")
            attr_label.setStyleSheet("font-size: 16px;")

            xp_bar = QProgressBar()
            xp_bar.setRange(0, attribute.xp_to_next_level)
            xp_bar.setValue(attribute.current_xp)
            xp_bar.setTextVisible(True)
            xp_bar.setFormat(f"{attribute.current_xp} / {attribute.xp_to_next_level} XP")

            # Layout horizontal para a linha do atributo (nome ao lado da barra)
            attr_layout = QHBoxLayout()
            attr_layout.addWidget(attr_label)
            attr_layout.addWidget(xp_bar)

            main_layout.addLayout(attr_layout)

        # Adiciona um "espaçador" para empurrar tudo para cima
        main_layout.addStretch()

# Este código só é executado quando você roda o arquivo 'main.py' diretamente.
if __name__ == "__main__":
    # 1. Cria a aplicação
    # Toda aplicação PyQt precisa de uma (e apenas uma) instância de QApplication.
    # sys.argv permite passar argumentos da linha de comando para a aplicação.
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()

    # 3. Inicia o loop de eventos da aplicação
    # sys.exit(app.exec()) garante que o programa feche de forma limpa.
    # app.exec() inicia o loop que processa eventos (cliques, teclado, etc.)
    # e mantém a aplicação aberta.
    sys.exit(app.exec())

