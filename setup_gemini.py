#!/usr/bin/env python3
"""
Script para configurar chave da API do Gemini
"""

import os

def setup_gemini_api():
    """Configura a chave da API do Gemini"""
    print("=== Configuração da API do Gemini ===")
    print("1. Acesse: https://makersuite.google.com/app/apikey")
    print("2. Crie uma nova chave de API")
    print("3. Cole a chave abaixo:")
    
    api_key = input("Chave da API do Gemini: ").strip()
    
    if api_key:
        # Definir variável de ambiente
        os.environ['GEMINI_API_KEY'] = api_key
        
        # Criar arquivo .env para persistir
        with open('.env', 'w') as f:
            f.write(f'GEMINI_API_KEY={api_key}\n')
        
        print("✅ Chave configurada com sucesso!")
        print("A IA agora usará o Gemini para análise contextual.")
        
        # Testar a API
        print("\nTestando API...")
        try:
            from ai_xp_calculator import MissionXPCalculator
            calc = MissionXPCalculator()
            result = calc.calculate_xp_and_attribute("resolver puzzles de xadrez")
            print(f"Teste: {result}")
            print("✅ API funcionando!")
        except Exception as e:
            print(f"❌ Erro no teste: {e}")
    else:
        print("❌ Nenhuma chave fornecida.")

if __name__ == "__main__":
    setup_gemini_api()