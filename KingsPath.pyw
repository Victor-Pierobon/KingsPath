#!/usr/bin/env python3
"""
Launcher do Kings Path sem terminal
"""

import sys
import os

# Mudar para o diretório do script
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
sys.path.insert(0, script_dir)

try:
    # Importar e executar o app
    import database
    from functools import partial
    from PyQt6.QtWidgets import QApplication, QMainWindow, QWidget, QLabel, QProgressBar, QVBoxLayout, QHBoxLayout, QPushButton, QLineEdit, QSpinBox, QComboBox, QFrame, QScrollArea
    from PyQt6.QtCore import Qt
    from models import Player
    from status_window import StatusWindow
    from styles import *
    
    class MainWindow(QMainWindow):
        def __init__(self):
            super().__init__()
            database.init_db()
            self.player = Player("NullByte")
            self.attribute_widgets = {}
            self.missions_layout = None
            self.setWindowTitle("⚔️ Kings Path - Solo Leveling")
            self.setGeometry(100, 100, 900, 750)
            self.setStyleSheet(MAIN_WINDOW_STYLE)
            self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground, True)
            self.setWindowOpacity(0.95)
            self.setup_ui()
        
        def setup_ui(self):
            central_widget = QWidget()
            self.setCentralWidget(central_widget)
            self.main_layout = QVBoxLayout()
            central_widget.setLayout(self.main_layout)
            self.setup_player_section()
            self.setup_mission_section()
            self.main_layout.addStretch()
            self.refresh_ui()
        
        def setup_player_section(self):
            header_layout = QHBoxLayout()
            player_name_label = QLabel(f"🎮 {self.player.name}")
            player_name_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
            player_name_label.setStyleSheet(LABEL_STYLES['title'])
            status_button = QPushButton("📊 Status Geral")
            status_button.setStyleSheet(BUTTON_STYLES['primary'])
            status_button.clicked.connect(self.open_status_window)
            header_layout.addStretch()
            header_layout.addWidget(player_name_label)
            header_layout.addStretch()
            header_layout.addWidget(status_button)
            self.main_layout.addLayout(header_layout)
            
            for attr_name, attribute in self.player.attributes.items():
                attr_label = QLabel()
                attr_label.setStyleSheet(LABEL_STYLES['attribute'])
                xp_bar = QProgressBar()
                xp_bar.setStyleSheet(PROGRESS_BAR_STYLE)
                self.attribute_widgets[attr_name] = {'label': attr_label, 'bar': xp_bar}
                attr_layout = QHBoxLayout()
                attr_layout.addWidget(attr_label)
                attr_layout.addWidget(xp_bar)
                self.main_layout.addLayout(attr_layout)
        
        def setup_mission_section(self):
            line = QFrame()
            line.setFrameShape(QFrame.Shape.HLine)
            line.setStyleSheet(SEPARATOR_STYLE)
            self.main_layout.addWidget(line)
            
            add_mission_label = QLabel("⚡ Nova Missão")
            add_mission_label.setStyleSheet(LABEL_STYLES['subtitle'])
            self.main_layout.addWidget(add_mission_label)
            
            self.desc_input = QLineEdit()
            self.desc_input.setPlaceholderText("📝 Descrição da Missão")
            self.desc_input.setStyleSheet(INPUT_STYLES['line_edit'])
            
            self.xp_input = QSpinBox()
            self.xp_input.setRange(1, 1000)
            self.xp_input.setValue(10)
            self.xp_input.setStyleSheet(INPUT_STYLES['spin_box'])
            
            self.attr_dropdown = QComboBox()
            self.attr_dropdown.addItems(self.player.attributes.keys())
            self.attr_dropdown.setStyleSheet(INPUT_STYLES['combo_box'])
            
            add_button = QPushButton("➕ Adicionar")
            add_button.setStyleSheet(BUTTON_STYLES['primary'])
            add_button.clicked.connect(self.handle_add_mission)
            
            form_layout = QHBoxLayout()
            form_layout.addWidget(self.desc_input)
            xp_label = QLabel("💎 XP:")
            xp_label.setStyleSheet(f"color: {COLORS['text']}; font-weight: bold;")
            attr_label = QLabel("🎯 Atributo:")
            attr_label.setStyleSheet(f"color: {COLORS['text']}; font-weight: bold;")
            form_layout.addWidget(xp_label)
            form_layout.addWidget(self.xp_input)
            form_layout.addWidget(attr_label)
            form_layout.addWidget(self.attr_dropdown)
            form_layout.addWidget(add_button)
            self.main_layout.addLayout(form_layout)
            
            missions_list_label = QLabel("🎯 Missões Ativas")
            missions_list_label.setStyleSheet(LABEL_STYLES['subtitle'])
            self.main_layout.addWidget(missions_list_label)
            
            scroll_area = QScrollArea()
            scroll_area.setWidgetResizable(True)
            scroll_area.setMaximumHeight(300)
            scroll_area.setStyleSheet(SCROLL_AREA_STYLE)
            missions_container = QWidget()
            self.missions_layout = QVBoxLayout(missions_container)
            self.missions_layout.setContentsMargins(0, 0, 0, 0)
            scroll_area.setWidget(missions_container)
            self.main_layout.addWidget(scroll_area)
        
        def refresh_ui(self):
            self.refresh_attributes_ui()
            self.refresh_missions_list()
        
        def refresh_attributes_ui(self):
            attr_icons = {'Força': '💪', 'Inteligência': '🧠', 'Carisma': '😎', 'Sabedoria': '🧙', 'Riqueza': '💰', 'Relacionamento': '❤️'}
            for attr_name, attribute in self.player.attributes.items():
                widgets = self.attribute_widgets[attr_name]
                icon = attr_icons.get(attr_name, '✨')
                widgets['label'].setText(f"{icon} {attr_name}: Nível {attribute.level}")
                widgets['bar'].setRange(0, attribute.xp_to_next_level)
                widgets['bar'].setValue(attribute.current_xp)
                widgets['bar'].setFormat(f"{attribute.current_xp}/{attribute.xp_to_next_level} XP")
        
        def refresh_missions_list(self):
            while self.missions_layout.count():
                item = self.missions_layout.takeAt(0)
                widget = item.widget()
                if widget is not None:
                    widget.deleteLater()
            
            missions = database.get_active_missions()
            if not missions:
                no_missions_label = QLabel("🔍 Nenhuma missão ativa encontrada")
                no_missions_label.setStyleSheet(f"color: {COLORS['text_secondary']}; font-style: italic; padding: 15px; text-align: center;")
                self.missions_layout.addWidget(no_missions_label)
            
            for mission in missions:
                mission_label = QLabel(f"⚔️ {mission['description']} (+{mission['reward_xp']} XP em {mission['attribute_name']})")
                mission_label.setStyleSheet(LABEL_STYLES['mission'])
                complete_button = QPushButton("✅ Concluir")
                complete_button.setStyleSheet(BUTTON_STYLES['success'])
                complete_button.clicked.connect(partial(self.handle_complete_mission, mission['id'], mission['reward_xp'], mission['attribute_name']))
                delete_button = QPushButton("🗑️ Deletar")
                delete_button.setStyleSheet(BUTTON_STYLES['danger'])
                delete_button.clicked.connect(partial(self.handle_delete_mission, mission['id']))
                
                mission_layout = QHBoxLayout()
                mission_layout.addWidget(mission_label)
                mission_layout.addStretch()
                mission_layout.addWidget(complete_button)
                mission_layout.addWidget(delete_button)
                
                mission_widget = QWidget()
                mission_widget.setLayout(mission_layout)
                mission_widget.setStyleSheet(MISSION_CONTAINER_STYLE)
                self.missions_layout.addWidget(mission_widget)
        
        def handle_add_mission(self):
            description = self.desc_input.text()
            reward_xp = self.xp_input.value()
            attribute_name = self.attr_dropdown.currentText()
            if description:
                database.add_mission(description, reward_xp, attribute_name)
                self.desc_input.clear()
                self.refresh_missions_list()
        
        def handle_complete_mission(self, mission_id, reward_xp, attribute_name):
            database.complete_mission(mission_id)
            self.player.complete_mission_action(reward_xp, attribute_name)
            self.refresh_ui()
        
        def handle_delete_mission(self, mission_id):
            database.delete_mission(mission_id)
            self.refresh_missions_list()
        
        def open_status_window(self):
            status_window = StatusWindow(self.player, self)
            status_window.exec()
    
    if __name__ == "__main__":
        app = QApplication(sys.argv)
        window = MainWindow()
        window.show()
        sys.exit(app.exec())
        
except Exception as e:
    with open(os.path.join(script_dir, "error.log"), "w") as f:
        f.write(f"Erro ao iniciar Kings Path: {e}\n")
        f.write(f"Diretório: {script_dir}\n")
        f.write(f"Python: {sys.executable}\n")