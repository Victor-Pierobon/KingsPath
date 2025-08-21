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
            self.level_ip()
    
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
        self.attributes = {
            "Força": Attribute("Força"),
            "Inteligência": Attribute("Inteligência"),
            "Carisma": Attribute("Carisma"),
            "Sabedoria": Attribute("Sabedoria"),
            "Riqueza": Attribute("Riqueza")
        }


    def complete_mission_action(self, reward_xp, attribute_name):
        """
        Essa função é chamada pela interface para aplicar a recompensa da missão
        """
        target_attribute  = self.attributes.get(attribute_name)
        if target_attribute:
            target_attribute.add_xp(reward_xp)
            print(f"Recompensa de {reward_xp} XP aplicada em {attribute_name}!")
        else:
            print(f"Erro: Atributo '{attribute_name}' não encontrado!")
        
    def get_status(self):
        print("\n --- Status do Player ---")
        print(f"Nome: {self.name}")
        for attr_name, attribute in self.attributes.item():
            print(f"- {attr_name}: Nivel {attribute.level} ({attribute.current_xp}/{attribute.xp_to_next_level} XP)")
        print("---------------------\n")
        
