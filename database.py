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
            completed INTEGER 
        )
    """)
    conn.commit()
    conn.close()

def add_mission(description, reward_xp, attribute_name):
    """Adiciona uma nova missão no banco de dados"""
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO missions(description, reward_xp, attribute_name) VALUES (?, ?, ?)",
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
    cursor = conn.curosr()
    cursor.execute("DELETE FROM missions WHERE id = ?", (mission_id,))
    conn.commit()
    conn.close()

def complete_mission(mission_id):
    """Altera o valor do Boolean dizendo que a missão foi concluida"""
    conn = sqlite3.connect()
    cursor = conn.cursor()
    cursor.execute("UPDATE missions SET completed = 1 WHERE id =?", (mission_id))
    conn.commit()
    conn.close()
    