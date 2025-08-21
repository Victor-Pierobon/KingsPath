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
        return 100 * self.level
    
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
    
class Mission:
    """
    Representa o inicio de uma quest
    """
    def __init__(self, description, reward_xp, attribute_name, mission_type="daily"):
        self.description = description
        self.reward_xp = reward_xp
        self.attribute_name = attribute_name
        self.mission_type = mission_type
        self.completed = False

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
        self.missions = []

    def add_mission(self, mission):
        self.mission.append(mission)
        print(f"Nova missão adicionada '{mission.description}'")

    def complete_mission(self, mission_description):
        mission_to_complete = None
        for mission in self.missions:
            if mission_description == mission_description and not mission.completed:
                mission_to_complete = mission
                break

        if mission_to_complete:
            mission_to_complete.completed = True
            target_attribute = self.attributes.get(mission_to_complete.attribute_name)
            if target_attribute:
                target_attribute.add_xp(mission_to_complete.reward_xp)
                print(f"Missão {mission_to_complete} Concluida")
            else:
                print(f"Erro: atributo '{mission_to_complete.attribute_name}' não encontrado")
        else:
            print(f"Missão '{mission_description}' não encontrada ou já completa.")
        
    def get_status(self):
        print("\n --- Status do Player ---")
        print(f"Nome: {self.name}")
        for attr_name, attribute in self.attributes.item():
            print(f"- {attr_name}: Nivel {attribute.level} ({attribute.current_xp}/{attribute.xp_to_next_level} XP)")
        print("---------------------\n")
        
