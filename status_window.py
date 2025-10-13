import matplotlib.pyplot as plt
import numpy as np
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
from PyQt6.QtWidgets import QDialog, QVBoxLayout, QHBoxLayout, QLabel, QWidget
from PyQt6.QtCore import Qt
from styles import *

class StatusWindow(QDialog):
    """Janela para mostrar status geral do jogador com gráfico radar"""
    
    def __init__(self, player, parent=None):
        super().__init__(parent)
        self.player = player
        self.setWindowTitle("📊 Kings Path - Status Geral")
        self.setGeometry(200, 200, 900, 700)
        
        # Aplicar estilo futurista
        self.setStyleSheet(MAIN_WINDOW_STYLE)
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground, True)
        
        self.setup_ui()
        
    def setup_ui(self):
        """Configura a interface da janela de status"""
        layout = QVBoxLayout()
        
        # Seção de informações gerais
        info_layout = QHBoxLayout()
        
        # Informações do jogador
        player_info = QWidget()
        player_layout = QVBoxLayout(player_info)
        
        name_label = QLabel(f"🎮 {self.player.name}")
        name_label.setStyleSheet(LABEL_STYLES['title'])
        name_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        
        overall_level = self.player.get_overall_level()
        level_label = QLabel(f"⭐ Nível Geral: {overall_level}")
        level_label.setStyleSheet(f"font-size: 22px; color: {COLORS['secondary']}; font-weight: bold; background: {COLORS['light']}; border-radius: 8px; padding: 8px;")
        level_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        
        player_layout.addWidget(name_label)
        player_layout.addWidget(level_label)
        
        # Lista detalhada dos atributos
        attrs_widget = QWidget()
        attrs_layout = QVBoxLayout(attrs_widget)
        
        attrs_title = QLabel("📊 Detalhes dos Atributos:")
        attrs_title.setStyleSheet(f"font-size: 18px; font-weight: bold; color: {COLORS['primary']}; margin-bottom: 10px;")
        attrs_layout.addWidget(attrs_title)
        
        for attr_name, attr in self.player.attributes.items():
            progress_percent = (attr.current_xp / attr.xp_to_next_level) * 100
            attr_label = QLabel(f"🔥 {attr_name}: Nível {attr.level} ({progress_percent:.1f}%)")
            attr_label.setStyleSheet(f"font-size: 14px; margin: 3px; color: {COLORS['text']}; padding: 5px; background: {COLORS['light']}; border-radius: 5px;")
            attrs_layout.addWidget(attr_label)
        
        info_layout.addWidget(player_info)
        info_layout.addWidget(attrs_widget)
        
        # Gráfico radar
        self.create_radar_chart()
        
        layout.addLayout(info_layout)
        layout.addWidget(self.canvas)
        
        self.setLayout(layout)
    
    def create_radar_chart(self):
        """Cria o gráfico radar dos atributos"""
        self.figure = Figure(figsize=(8, 6), facecolor=COLORS['dark'])
        self.canvas = FigureCanvas(self.figure)
        
        ax = self.figure.add_subplot(111, projection='polar')
        
        # Dados dos atributos
        attrs_data = self.player.get_attributes_data()
        attributes = list(attrs_data.keys())
        levels = [attrs_data[attr]['level'] for attr in attributes]
        
        # Ângulos para cada atributo
        angles = np.linspace(0, 2 * np.pi, len(attributes), endpoint=False).tolist()
        
        # Fechar o polígono
        levels += levels[:1]
        angles += angles[:1]
        
        # Criar o gráfico
        ax.plot(angles, levels, 'o-', linewidth=2, label='Níveis', color='#4CAF50')
        ax.fill(angles, levels, alpha=0.25, color='#4CAF50')
        
        # Configurar os rótulos
        ax.set_xticks(angles[:-1])
        ax.set_xticklabels(attributes)
        
        # Configurar escala radial
        max_level = max(levels) if levels else 1
        ax.set_ylim(0, max(max_level + 2, 5))
        ax.set_yticks(range(0, max(max_level + 3, 6)))
        
        # Título
        ax.set_title('⚔️ Radar dos Atributos', size=18, pad=20, color=COLORS['primary'], weight='bold')
        
        # Estilo
        ax.grid(True, alpha=0.3, color=COLORS['secondary'])
        ax.set_facecolor(COLORS['darker'])
        
        # Cores dos labels
        ax.tick_params(colors=COLORS['text'])
        for label in ax.get_xticklabels():
            label.set_color(COLORS['text'])
            label.set_fontweight('bold')
        
        self.figure.tight_layout()