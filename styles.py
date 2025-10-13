"""
Estilos futuristas para o Kings Path
"""

# Paleta de cores futurista
COLORS = {
    'primary': '#6C63FF',      # Roxo vibrante
    'secondary': '#4ECDC4',    # Azul ciano
    'accent': '#FF6B6B',       # Vermelho suave
    'success': '#4ECDC4',      # Verde ciano
    'warning': '#FFE66D',      # Amarelo
    'danger': '#FF6B6B',       # Vermelho
    'dark': '#1A1A2E',         # Azul escuro
    'darker': '#16213E',       # Azul mais escuro
    'light': 'rgba(255, 255, 255, 0.1)',  # Branco transparente
    'text': '#E0E0E0',         # Texto claro
    'text_secondary': '#B0B0B0' # Texto secundário
}

# Estilo principal da janela
MAIN_WINDOW_STYLE = f"""
QMainWindow {{
    background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
        stop:0 {COLORS['dark']}, stop:1 {COLORS['darker']});
    color: {COLORS['text']};
}}

QWidget {{
    background: transparent;
    color: {COLORS['text']};
    font-family: 'Segoe UI', Arial, sans-serif;
}}
"""

# Estilo para labels
LABEL_STYLES = {
    'title': f"""
        font-size: 28px;
        font-weight: bold;
        color: {COLORS['primary']};
        margin: 15px;
        background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
            stop:0 transparent, stop:0.5 {COLORS['light']}, stop:1 transparent);
        border-radius: 8px;
        padding: 10px;
    """,
    'subtitle': f"""
        font-size: 20px;
        font-weight: bold;
        color: {COLORS['secondary']};
        margin: 10px 0;
    """,
    'attribute': f"""
        font-size: 16px;
        font-weight: bold;
        color: {COLORS['text']};
        padding: 5px;
        background: {COLORS['light']};
        border-radius: 8px;
        border: 1px solid {COLORS['primary']};
    """,
    'mission': f"""
        font-size: 14px;
        color: {COLORS['text']};
        padding: 8px;
        background: {COLORS['light']};
        border-radius: 8px;
        border: 1px solid {COLORS['secondary']};
    """
}

# Estilo para botões
BUTTON_STYLES = {
    'primary': f"""
        QPushButton {{
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                stop:0 {COLORS['primary']}, stop:1 {COLORS['darker']});
            color: white;
            border: 2px solid {COLORS['primary']};
            border-radius: 12px;
            padding: 10px 20px;
            font-size: 14px;
            font-weight: bold;
            text-transform: uppercase;
        }}
        QPushButton:hover {{
            background: {COLORS['primary']};
            box-shadow: 0 0 20px {COLORS['primary']};
        }}
        QPushButton:pressed {{
            background: {COLORS['darker']};
        }}
    """,
    'success': f"""
        QPushButton {{
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                stop:0 {COLORS['success']}, stop:1 {COLORS['darker']});
            color: white;
            border: 2px solid {COLORS['success']};
            border-radius: 8px;
            padding: 8px 16px;
            font-weight: bold;
        }}
        QPushButton:hover {{
            background: {COLORS['success']};
            box-shadow: 0 0 15px {COLORS['success']};
        }}
    """,
    'danger': f"""
        QPushButton {{
            background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                stop:0 {COLORS['danger']}, stop:1 {COLORS['darker']});
            color: white;
            border: 2px solid {COLORS['danger']};
            border-radius: 8px;
            padding: 8px 16px;
            font-weight: bold;
        }}
        QPushButton:hover {{
            background: {COLORS['danger']};
            box-shadow: 0 0 15px {COLORS['danger']};
        }}
    """
}

# Estilo para barras de progresso
PROGRESS_BAR_STYLE = f"""
QProgressBar {{
    background: {COLORS['light']};
    border: 2px solid {COLORS['primary']};
    border-radius: 10px;
    text-align: center;
    font-weight: bold;
    color: {COLORS['text']};
    height: 25px;
}}

QProgressBar::chunk {{
    background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
        stop:0 {COLORS['primary']}, stop:1 {COLORS['secondary']});
    border-radius: 8px;
    margin: 2px;
}}
"""

# Estilo para inputs
INPUT_STYLES = {
    'line_edit': f"""
        QLineEdit {{
            background: {COLORS['light']};
            border: 2px solid {COLORS['primary']};
            border-radius: 8px;
            padding: 8px 12px;
            font-size: 14px;
            color: {COLORS['text']};
        }}
        QLineEdit:focus {{
            border-color: {COLORS['secondary']};
            box-shadow: 0 0 10px {COLORS['secondary']};
        }}
    """,
    'spin_box': f"""
        QSpinBox {{
            background: {COLORS['light']};
            border: 2px solid {COLORS['primary']};
            border-radius: 8px;
            padding: 8px;
            font-size: 14px;
            color: {COLORS['text']};
        }}
        QSpinBox:focus {{
            border-color: {COLORS['secondary']};
        }}
    """,
    'combo_box': f"""
        QComboBox {{
            background: {COLORS['light']};
            border: 2px solid {COLORS['primary']};
            border-radius: 8px;
            padding: 8px;
            font-size: 14px;
            color: {COLORS['text']};
        }}
        QComboBox:focus {{
            border-color: {COLORS['secondary']};
        }}
        QComboBox::drop-down {{
            border: none;
        }}
        QComboBox::down-arrow {{
            image: none;
            border-left: 5px solid transparent;
            border-right: 5px solid transparent;
            border-top: 5px solid {COLORS['text']};
        }}
    """
}

# Estilo para scroll area
SCROLL_AREA_STYLE = f"""
QScrollArea {{
    background: transparent;
    border: 2px solid {COLORS['primary']};
    border-radius: 12px;
}}

QScrollBar:vertical {{
    background: {COLORS['light']};
    width: 12px;
    border-radius: 6px;
}}

QScrollBar::handle:vertical {{
    background: {COLORS['primary']};
    border-radius: 6px;
    min-height: 20px;
}}

QScrollBar::handle:vertical:hover {{
    background: {COLORS['secondary']};
}}
"""

# Estilo para containers de missão
MISSION_CONTAINER_STYLE = f"""
QWidget {{
    background: {COLORS['light']};
    border: 2px solid {COLORS['secondary']};
    border-radius: 12px;
    margin: 5px;
    padding: 10px;
}}
"""

# Estilo para separadores
SEPARATOR_STYLE = f"""
QFrame {{
    background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
        stop:0 transparent, stop:0.5 {COLORS['primary']}, stop:1 transparent);
    height: 2px;
    margin: 20px 0;
}}
"""