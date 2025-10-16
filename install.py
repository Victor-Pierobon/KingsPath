#!/usr/bin/env python3
"""
Script de instalação completa do Kings Path
"""

import os
import subprocess
import sys

def install_dependencies():
    """Instala dependências necessárias"""
    print("[INSTALL] Instalando dependências...")
    
    try:
        subprocess.run([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"], check=True)
        print("[INSTALL] Dependências instaladas com sucesso!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"[ERRO] Falha ao instalar dependências: {e}")
        return False

def setup_database():
    """Configura banco de dados inicial"""
    print("[INSTALL] Configurando banco de dados...")
    
    try:
        import database
        database.init_db()
        print("[INSTALL] Banco de dados configurado!")
        return True
    except Exception as e:
        print(f"[ERRO] Falha ao configurar banco: {e}")
        return False

def setup_demo_data():
    """Configura dados de demonstração"""
    print("[INSTALL] Configurando dados de demonstração...")
    
    try:
        subprocess.run([sys.executable, "setup_demo.py"], check=True)
        print("[INSTALL] Dados de demonstração configurados!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"[ERRO] Falha ao configurar dados demo: {e}")
        return False

def setup_autostart():
    """Configura inicialização automática"""
    print("[INSTALL] Configurando inicialização automática...")
    
    try:
        subprocess.run([sys.executable, "setup_startup.py"], check=True)
        print("[INSTALL] Inicialização automática configurada!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"[ERRO] Falha ao configurar autostart: {e}")
        return False

def main():
    """Instalação completa"""
    print("=" * 50)
    print("    KINGS PATH - INSTALAÇÃO COMPLETA")
    print("=" * 50)
    
    steps = [
        ("Instalando dependências", install_dependencies),
        ("Configurando banco de dados", setup_database),
        ("Configurando dados demo", setup_demo_data),
        ("Configurando autostart", setup_autostart)
    ]
    
    success_count = 0
    
    for step_name, step_func in steps:
        print(f"\n[{success_count + 1}/4] {step_name}...")
        if step_func():
            success_count += 1
        else:
            print(f"[AVISO] Falha em: {step_name}")
    
    print("\n" + "=" * 50)
    if success_count == len(steps):
        print("✅ INSTALAÇÃO COMPLETA COM SUCESSO!")
        print("\n🎮 O Kings Path está pronto para usar!")
        print("📱 Execute 'python main.py' ou 'KingsPath.bat'")
        print("🚀 O app iniciará automaticamente com o Windows")
    else:
        print(f"⚠️  INSTALAÇÃO PARCIAL ({success_count}/{len(steps)} etapas)")
        print("Verifique os erros acima e tente novamente")
    
    print("=" * 50)

if __name__ == "__main__":
    main()