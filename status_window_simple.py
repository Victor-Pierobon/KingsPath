from PyQt6.QtWidgets import QDialog, QVBoxLayout, QHBoxLayout, QLabel, QWidget, QProgressBar
from PyQt6.QtCore import Qt

class StatusWindow(QDialog):
    """Janela para mostrar status geral do jogador (versão simplificada)"""
    
    def __init__(self, player, parent=None):
        super().__init__(parent)
        self.player = player
        self.setWindowTitle("Status Geral")
        self.setGeometry(200, 200, 600, 500)
        self.setup_ui()
        
    def setup_ui(self):
        """Configura a interface da janela de status"""
        layout = QVBoxLayout()
        
        # Título
        title_label = QLabel("📊 STATUS GERAL")
        title_label.setStyleSheet("font-size: 28px; font-weight: bold; color: #2E7D32; margin: 20px; text-align: center;")
        title_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(title_label)
        
        # Informações do jogador
        player_info_widget = QWidget()
        player_info_layout = QVBoxLayout(player_info_widget)
        
        name_label = QLabel(f"🎮 Jogador: {self.player.name}")
        name_label.setStyleSheet("font-size: 20px; font-weight: bold; margin: 10px;")
        name_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        
        overall_level = self.player.get_overall_level()
        level_label = QLabel(f"⭐ Nível Geral: {overall_level}")
        level_label.setStyleSheet("font-size: 18px; color: #4CAF50; margin: 10px;")
        level_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        
        player_info_layout.addWidget(name_label)
        player_info_layout.addWidget(level_label)
        
        # Seção de atributos detalhada
        attrs_title = QLabel("📈 ATRIBUTOS DETALHADOS")
        attrs_title.setStyleSheet("font-size: 18px; font-weight: bold; margin: 20px 10px 10px 10px; color: #1976D2;")
        
        layout.addWidget(player_info_widget)
        layout.addWidget(attrs_title)
        
        # Lista de atributos com barras de progresso
        attrs_data = self.player.get_attributes_data()
        
        for attr_name, data in attrs_data.items():
            attr_widget = self.create_attribute_widget(attr_name, data)
            layout.addWidget(attr_widget)
        
        # Estatísticas gerais
        stats_widget = self.create_stats_widget()
        layout.addWidget(stats_widget)
        
        layout.addStretch()
        self.setLayout(layout)
    
    def create_attribute_widget(self, attr_name, data):
        """Cria widget para um atributo específico"""
        widget = QWidget()
        widget.setStyleSheet("background-color: #f5f5f5; border-radius: 8px; margin: 5px; padding: 10px;")
        
        layout = QVBoxLayout(widget)
        
        # Nome e nível do atributo
        header_layout = QHBoxLayout()
        
        name_label = QLabel(f"🔥 {attr_name}")
        name_label.setStyleSheet("font-size: 16px; font-weight: bold;")
        
        level_label = QLabel(f"Nível {data['level']}")
        level_label.setStyleSheet("font-size: 14px; color: #666; font-weight: bold;")
        
        header_layout.addWidget(name_label)
        header_layout.addStretch()
        header_layout.addWidget(level_label)
        
        # Barra de progresso
        progress_bar = QProgressBar()
        progress_bar.setRange(0, 100)
        progress_bar.setValue(int(data['progress']))
        progress_bar.setFormat(f"{data['progress']:.1f}% para próximo nível")
        progress_bar.setStyleSheet("""
            QProgressBar {
                border: 2px solid #ccc;
                border-radius: 5px;
                text-align: center;
                font-weight: bold;
            }
            QProgressBar::chunk {
                background-color: #4CAF50;
                border-radius: 3px;
            }
        """)
        
        layout.addLayout(header_layout)
        layout.addWidget(progress_bar)
        
        return widget
    
    def create_stats_widget(self):
        """Cria widget com estatísticas gerais"""
        widget = QWidget()
        widget.setStyleSheet("background-color: #e3f2fd; border-radius: 8px; margin: 10px; padding: 15px;")
        
        layout = QVBoxLayout(widget)
        
        title = QLabel("📊 ESTATÍSTICAS GERAIS")
        title.setStyleSheet("font-size: 16px; font-weight: bold; color: #1976D2; margin-bottom: 10px;")
        
        # Calcular estatísticas
        attrs_data = self.player.get_attributes_data()
        total_levels = sum(data['level'] for data in attrs_data.values())
        avg_progress = sum(data['progress'] for data in attrs_data.values()) / len(attrs_data)
        highest_attr = max(attrs_data.items(), key=lambda x: x[1]['level'])
        lowest_attr = min(attrs_data.items(), key=lambda x: x[1]['level'])
        
        stats_layout = QVBoxLayout()
        
        stats = [
            f"🎯 Total de Níveis: {total_levels}",
            f"📈 Progresso Médio: {avg_progress:.1f}%",
            f"🏆 Atributo Mais Alto: {highest_attr[0]} (Nível {highest_attr[1]['level']})",
            f"📚 Atributo para Focar: {lowest_attr[0]} (Nível {lowest_attr[1]['level']})"
        ]
        
        for stat in stats:
            stat_label = QLabel(stat)
            stat_label.setStyleSheet("font-size: 14px; margin: 3px; color: #333;")
            stats_layout.addWidget(stat_label)
        
        layout.addWidget(title)
        layout.addLayout(stats_layout)
        
        return widget