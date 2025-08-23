import sys
import database
from functools import partial
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
        self.attribute_widgets = {}
        self.missions_layout = None
        self.setWindowTitle("Kings Path")
        self.setGeometry(100, 100, 800, 700) # posição x, posição y, largura, Altura
        self.setup_ui()

    def setup_ui(self):
        """
        Cria e organiza todos o widget's da interface
        """
        central_widget = QWidget()
        self.setCentralWidget(central_widget)

        self.main_layout = QVBoxLayout()
        central_widget.setLayout(self.main_layout)
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

        missions_container = QWidget()
        self.missions_layout = QVBoxLayout(missions_container)
        self.missions_layout.setContentsMargins(0, 0, 0, 0)
        self.main_layout.addWidget(missions_container)


    
    def refresh_ui(self):
        """Atualiza toda a interface com os dados mais recentes"""
        self.refresh_attributes_ui()
        self.refresh_missions_list()

    def refresh_attributes_ui(self):
        """Atualiza os widgets dos atributos (nível e barra de XP)."""
        for attr_name, attribute in self.player.attributes.items():
            widgets = self.attribute_widgets[attr_name]
            widgets['label'].setText(f"{attr_name}: Nível {attribute.level}")
            widgets['bar'].setRange(0, attribute.xp_to_next_level)
            widgets['bar'].setValue(attribute.current_xp)
            widgets['bar'].setFormat(f"{attribute.current_xp}/{attribute.xp_to_next_level} XP")

    def refresh_missions_list(self):
        """Limpa e recria a lista de missões com base nos dados do banco."""
        # Limpa widgets antigos da lista de missões
        while self.missions_layout.count():
            item = self.missions_layout.takeAt(0)
            widget = item.widget()
            if widget is not None:
                widget.deleteLater()
            else:
                layout_to_clear = item.layout()
                if layout_to_clear is not None:
                    while layout_to_clear.count():
                        sub_item = layout_to_clear.takeAt(0)
                        sub_widget = sub_item.widget()
                        if sub_widget is not None:
                            sub_widget.deleteLater()
        
        missions = database.get_active_missions()
        for mission in missions:
            mission_label = QLabel(f"{mission['description']} (+{mission['reward_xp']} XP em {mission['attribute_name']})")

            complete_button = QPushButton("Concluir")
            complete_button.clicked.connect(partial(self.handle_complete_mission, mission['id'],mission['reward_xp'], mission['attribute_name']))
            
            delete_button = QPushButton("deletar")
            delete_button.clicked.connect(partial(self.handle_delete_mission, mission['id']))

            mission_layout = QHBoxLayout()
            mission_layout.addWidget(mission_label)
            mission_layout.addStretch()
            mission_layout.addWidget(complete_button)
            mission_layout.addWidget(delete_button)


            self.missions_layout.addLayout(mission_layout)

    def handle_add_mission(self):
        """Pega os dados do formulário, adiciona ao DB e atualiza a UI."""
        description = self.desc_input.text()
        reward_xp = self.xp_input.value()
        attribute_name = self.attr_dropdown.currentText()

        if description:
            database.add_mission(description, reward_xp, attribute_name)
            self.desc_input.clear()
            self.refresh_missions_list()

    def handle_complete_mission(self, mission_id, reward_xp, attribute_name):
        """Completa a missão no DB, aplica o XP e atualiza a UI."""
        database.complete_mission(mission_id)
        self.player.complete_mission_action(reward_xp, attribute_name)
        self.refresh_ui()

    def handle_delete_mission(self, mission_id):
        """Deleta a missão do DB e atualiza a UI."""
        database.delete_mission(mission_id)
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

