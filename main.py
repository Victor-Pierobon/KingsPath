import sys
import database
from PyQt6.QtWidgets import QApplication, QMainWindow, QWidget, QLabel, QProgressBar, QVBoxLayout, QHBoxLayout, QPushButton, QLineEdit, QSpinBox, QComboBox, QFrame
from PyQt6.QtCore import Qt
from models import Player


class MainWindow(QMainWindow):
    """
    Janela principal do app
    """
    def __init__(self):
        super().__init__() # Chama o construtor da classe pai
        database.init_db()
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

        self.main_layout = QVBoxLayout()
        self.setup_player_section()
        self.setup_mission_section()
        self.main_layout.addStretch()
        self.refresh_ui()

    def setup_player_section(self):
        """Cria a seção de status do jogador e atributos"""
        player_name_label = QLabel(f"Jogador: {self.player.name}")
        player_name_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        player_name_label.setStyleSheet("font-size: 24px; font-weight: bold; margin-bottom: 10px;")
        self.main_layout.addWidget(player_name_label)

        for attr_name, attribute in self.player.attributes.items():
            attr_label = QLabel()
            xp_bar = QProgressBar()

            self.attribute_widgets[attr_name] = {'label': attr_label, 'bar': xp_bar}

            attr_layout = QHBoxLayout()
            attr_layout.addWidget(attr_label)
            attr_layout.addWidget(xp_bar)
            self.main_layout.addLayout(attr_layout)

    def setup_mission_section(self):
        """Cria a seção de gerenciamento de missões"""
        line = QFrame()
        line.setFrameShape(QFrame.Shape.HLine)
        line.setFrameShadow(QFrame.Shadow.Sunken)
        self.main_layout.addWidget(line)

        add_mission_label = QLabel("Adicionar Nova Missão")
        add_mission_label.setStyleSheet("font-size: 20px; font-weight: bold; margin-top: 20px;")
        self.main_layout.addWidget(add_mission_label)

        self.desc_input = QLineEdit()
        self.desc_input.setPlaceholderText("Descrição da Missão")

        self.xp_input = QSpinBox()
        self.xp_input.setRange(1, 1000)
        self.xp_input.setValue(10)

        self.attr_dropdown = QComboBox()
        self.attr_dropdown.addItems(self.player.attributes.keys())

        add_button = QPushButton("Adicionar")
        add_button.clicked.connect(self.handle_add_mission)

        form_layout = QHBoxLayout()
        form_layout.addWidget(self.desc_input)
        form_layout.addWidget(QLabel("XP:"))
        form_layout.addWidget(self.xp_input)
        form_layout.addWidget(QLabel("Atributo:"))
        form_layout.addWidget(self.attr_dropdown)
        form_layout.addWidget(add_button)
        self.main_layout.addLayout(form_layout)

        missions_list_label = QLabel("Missões Ativas")
        missions_list_label.setStyleSheet("font-size: 20px; font-weight: bold; margin-top: 20px;")
        self.main_layout.addWidget(missions_list_label)

    
    def refresh_ui(self):
        """Atualiza toda a interface com os dados mais recentes"""
        self.refresh_attributes_ui()
        self.refresh_missions_list()


        

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

