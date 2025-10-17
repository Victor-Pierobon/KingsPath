import re
import json
import os

class MissionXPCalculator:
    def __init__(self):
        self.attributes = ['Força', 'Inteligência', 'Carisma', 'Sabedoria', 'Riqueza', 'Relacionamento']
        
        # Carregar variáveis do arquivo .env se existir
        self._load_env()
        
        # Chave da API do Gemini
        self.api_key = os.getenv('GEMINI_API_KEY', '')
    
    def _load_env(self):
        """Carrega variáveis do arquivo .env"""
        try:
            if os.path.exists('.env'):
                with open('.env', 'r') as f:
                    for line in f:
                        if '=' in line and not line.startswith('#'):
                            key, value = line.strip().split('=', 1)
                            os.environ[key] = value
        except:
            pass

    def calculate_xp_and_attribute(self, mission_description: str) -> dict:
        """Analisa contexto da missão usando Gemini API"""
        if self.api_key:
            try:
                result = self._analyze_with_gemini_api(mission_description)
                if result:
                    return result
            except Exception as e:
                print(f"Erro na API Gemini: {e}")
        
        # Fallback simples se API falhar
        return self._simple_fallback(mission_description)
    

    
    def _analyze_with_gemini_api(self, description: str) -> dict:
        """Usa API do Gemini para análise contextual"""
        import requests
        
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key={self.api_key}"
        
        prompt = f"""
Analise esta missão e determine:
1. Qual atributo se encaixa melhor: {', '.join(self.attributes)}
2. Quantidade de XP (5-200) baseada na complexidade

Atributos:
- Força: Atividades físicas, exercícios, esportes
- Inteligência: Estudos, aprendizado, xadrez, puzzles, programação, matemática
- Carisma: Comunicação, apresentações, liderança, networking
- Sabedoria: Meditação, reflexão, autoconhecimento, filosofia
- Riqueza: Investimentos, finanças, negócios, economia
- Relacionamento: Família, amigos, vida social, ajudar pessoas

Missão: "{description}"

Responda APENAS com JSON válido:
{{"reward_xp": numero, "attribute_name": "nome_exato_do_atributo"}}
"""
        
        payload = {
            "contents": [{
                "parts": [{"text": prompt}]
            }]
        }
        
        response = requests.post(url, json=payload, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            text = data['candidates'][0]['content']['parts'][0]['text']
            
            # Extrair JSON da resposta
            start = text.find('{')
            end = text.rfind('}') + 1
            if start >= 0 and end > start:
                result = json.loads(text[start:end])
                if result['attribute_name'] in self.attributes:
                    return result
        
        return None
    
    def _simple_fallback(self, description: str) -> dict:
        """Fallback simples quando API não funciona"""
        # Determinar atributo por palavra-chave simples
        desc_lower = description.lower()
        
        if any(word in desc_lower for word in ['exercício', 'correr', 'treino']):
            attr = 'Força'
        elif any(word in desc_lower for word in ['ler', 'estudar', 'xadrez', 'puzzle']):
            attr = 'Inteligência'
        elif any(word in desc_lower for word in ['apresentação', 'falar']):
            attr = 'Carisma'
        elif any(word in desc_lower for word in ['meditar', 'refletir']):
            attr = 'Sabedoria'
        elif any(word in desc_lower for word in ['investir', 'dinheiro']):
            attr = 'Riqueza'
        elif any(word in desc_lower for word in ['família', 'amigo']):
            attr = 'Relacionamento'
        else:
            attr = 'Inteligência'
        
        xp = self._calculate_xp_by_complexity(desc_lower)
        return {"reward_xp": xp, "attribute_name": attr}
    
    def _calculate_xp_by_complexity(self, description: str) -> int:
        """Calcula XP baseado na complexidade da missão"""
        base_xp = 15
        
        # Palavras que indicam maior complexidade/esforço
        complexity_words = {
            'curso': 50, 'aprender': 30, 'estudar': 25, 'treinar': 25,
            'completar': 20, 'terminar': 20, 'concluir': 20,
            'horas': 15, 'dias': 25, 'semanas': 40, 'meses': 60,
            'difícil': 20, 'complexo': 25, 'avançado': 30,
            'novo': 15, 'primeira vez': 25, 'desafio': 20
        }
        
        # Números na descrição (indicam quantidade/duração)
        numbers = re.findall(r'\d+', description)
        if numbers:
            max_number = max(int(n) for n in numbers)
            base_xp += min(max_number * 2, 50)  # Máximo 50 XP por números
        
        # Adicionar XP por palavras de complexidade
        for word, xp_bonus in complexity_words.items():
            if word in description:
                base_xp += xp_bonus
        
        # Adicionar XP baseado no tamanho da descrição
        word_count = len(description.split())
        if word_count > 5:
            base_xp += min((word_count - 5) * 3, 30)
        
        # Garantir que XP está no range válido
        return max(5, min(base_xp, 200))


# Exemplo de uso (para demonstração)
if __name__ == "__main__":
    # Certifique-se de que OPENAI_API_KEY esteja configurada no seu ambiente
    # os.environ["OPENAI_API_KEY"] = "sua_chave_aqui"
    
    calculator = MissionXPCalculator()
    
    mission1 = "Aprender a tocar um novo instrumento musical."
    xp_attr1 = calculator.calculate_xp_and_attribute(mission1)
    print(f"Missão: '{mission1}' -> XP: {xp_attr1['reward_xp']}, Atributo: {xp_attr1['attribute_name']}")

    mission2 = "Derrotar um chefe de masmorra." # Exemplo de missão de combate
    xp_attr2 = calculator.calculate_xp_and_attribute(mission2)
    print(f"Missão: '{mission2}' -> XP: {xp_attr2['reward_xp']}, Atributo: {xp_attr2['attribute_name']}")

    mission3 = "Concluir um curso online de programação avançada."
    xp_attr3 = calculator.calculate_xp_and_attribute(mission3)
    print(f"Missão: '{mission3}' -> XP: {xp_attr3['reward_xp']}, Atributo: {xp_attr3['attribute_name']}")
