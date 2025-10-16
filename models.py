class Attribute:
    """
    Representa um unico atributo e controla funções de xp e ganho de xp do atributo específico
    """
    def __init__(self, name, level=1, current_xp=0):
        self.name = name
        self.level = level
        self.current_xp = current_xp
        self.xp_to_next_level = self.calculate_xp_to_next_level()

    def calculate_xp_to_next_level(self):
        return 50 * self.level + 20 * self.level**2
    
    def add_xp(self, amount):
        self.current_xp += amount
        print(f"Ganhou {amount} XP em {self.name}! Total Agora: {self.current_xp}/ {self.xp_to_next_level}")

        while self.current_xp >= self.xp_to_next_level:
            self.level_up()
    
    def level_up(self):
        xp_excess = self.current_xp - self.xp_to_next_level
        self.level += 1
        self.current_xp = xp_excess
        self.xp_to_next_level = self.calculate_xp_to_next_level()
        print(f"LEVEL UP! {self.name} level {self.level}")
    
class Player:
    """
    Classe principal que representa o usuário, ela contem os atributos e missões
    """
    def __init__(self, name):
        self.name = name
        self.load_attributes()
    
    def load_attributes(self):
        """Carrega atributos do banco de dados"""
        import database
        saved_attrs = database.load_player_attributes()
        
        self.attributes = {}
        default_attrs = ["Força", "Inteligência", "Carisma", "Sabedoria", "Riqueza", "Relacionamento"]
        
        for attr_name in default_attrs:
            if attr_name in saved_attrs:
                data = saved_attrs[attr_name]
                self.attributes[attr_name] = Attribute(attr_name, data['level'], data['current_xp'])
            else:
                self.attributes[attr_name] = Attribute(attr_name)
    
    def save_attributes(self):
        """Salva atributos no banco de dados"""
        import database
        database.save_player_attributes(self.attributes)


    def complete_mission_action(self, reward_xp, attribute_name):
        """
        Essa função é chamada pela interface para aplicar a recompensa da missão
        """
        target_attribute  = self.attributes.get(attribute_name)
        if target_attribute:
            target_attribute.add_xp(reward_xp)
            self.save_attributes()  # Salvar progresso
            print(f"Recompensa de {reward_xp} XP aplicada em {attribute_name}!")
        else:
            print(f"Erro: Atributo '{attribute_name}' não encontrado!")
    def get_overall_level(self):
        """Calcula o nível geral baseado na média dos atributos"""
        total_levels = sum(attr.level for attr in self.attributes.values())
        return total_levels // len(self.attributes)
    
    def get_attributes_data(self):
        """Retorna dados dos atributos para o gráfico radar"""
        return {
            name: {
                'level': attr.level,
                'progress': attr.current_xp / attr.xp_to_next_level * 100
            }
            for name, attr in self.attributes.items()
        }
        
    def get_status(self):
        print("\n --- Status do Player ---")
        print(f"Nome: {self.name}")
        for attr_name, attribute in self.attributes.items():
            print(f"- {attr_name}: Nivel {attribute.level} ({attribute.current_xp}/{attribute.xp_to_next_level} XP)")
        print("---------------------\n")
        
