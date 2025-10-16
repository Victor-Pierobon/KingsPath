import sqlite3

DB_NAME = "kings_path.db"

def init_db():
    """
    Cria o banco de dados e tabela de missões
    """
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS missions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT NOT NULL,
            reward_xp INTEGER NOT NULL,
            attribute_name TEXT NOT NULL,
            mission_type TEXT DEFAULT 'daily',
            completed INTEGER DEFAULT 0
        )
    """)
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS player_attributes(
            attribute_name TEXT PRIMARY KEY,
            level INTEGER DEFAULT 1,
            current_xp INTEGER DEFAULT 0
        )
    """)
    
    conn.commit()
    
    # Inicializar atributos padrão se não existirem
    cursor.execute("SELECT COUNT(*) FROM player_attributes")
    if cursor.fetchone()[0] == 0:
        default_attributes = ['Força', 'Inteligência', 'Carisma', 'Sabedoria', 'Riqueza', 'Relacionamento']
        for attr_name in default_attributes:
            cursor.execute("""
                INSERT INTO player_attributes (attribute_name, level, current_xp)
                VALUES (?, 1, 0)
            """, (attr_name,))
        conn.commit()
    
    conn.close()

def add_mission(description, reward_xp, attribute_name):
    """Adiciona uma nova missão no banco de dados"""
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO missions(description, reward_xp, attribute_name, completed) VALUES (?, ?, ?, 0)",
        (description, reward_xp, attribute_name)
    )
    conn.commit()
    conn.close()

def get_active_missions():
    """Retorna uma lista com todas as missões não concluidas"""
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM missions WHERE completed = 0")
    missions = cursor.fetchall()
    conn.close()
    return missions

def delete_mission(mission_id):
    """Deleta uma missão pelo id"""
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM missions WHERE id = ?", (mission_id,))
    conn.commit()
    conn.close()

def complete_mission(mission_id):
    """Altera o valor do Boolean dizendo que a missão foi concluida"""
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute("UPDATE missions SET completed = 1 WHERE id = ?", (mission_id,))
    conn.commit()
    conn.close()

def save_player_attributes(attributes):
    """Salva os atributos do player no banco"""
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    
    for attr_name, attribute in attributes.items():
        cursor.execute("""
            INSERT OR REPLACE INTO player_attributes (attribute_name, level, current_xp)
            VALUES (?, ?, ?)
        """, (attr_name, attribute.level, attribute.current_xp))
    
    conn.commit()
    conn.close()

def load_player_attributes():
    """Carrega os atributos do player do banco"""
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    cursor.execute("SELECT * FROM player_attributes")
    attributes = cursor.fetchall()
    conn.close()
    
    return {attr['attribute_name']: {'level': attr['level'], 'current_xp': attr['current_xp']} 
            for attr in attributes}
    