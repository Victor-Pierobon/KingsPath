#!/usr/bin/env python3
"""
Script para criar executável do Kings Path
"""

import os
import subprocess
import sys

def build_executable():
    """Cria o executável do Kings Path"""
    print("[BUILD] Criando executável do Kings Path...")
    
    # Comando PyInstaller
    cmd = [
        "pyinstaller",
        "--onefile",
        "--windowed",
        "--name=KingsPath",
        "--icon=icon.ico",
        "--add-data=kings_path.db;.",
        "main.py"
    ]
    
    try:
        # Executar PyInstaller
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("[BUILD] Executável criado com sucesso!")
            print("[BUILD] Localização: dist/KingsPath.exe")
            return True
        else:
            print(f"[ERRO] Falha ao criar executável: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"[ERRO] Erro durante build: {e}")
        return False

def create_startup_script():
    """Cria script para inicialização automática"""
    startup_script = """
@echo off
cd /d "%~dp0"
start "" "KingsPath.exe"
"""
    
    with open("startup.bat", "w") as f:
        f.write(startup_script)
    
    print("[BUILD] Script de inicialização criado: startup.bat")

if __name__ == "__main__":
    success = build_executable()
    if success:
        create_startup_script()
        print("\n[SUCESSO] Build completo!")
        print("Execute 'setup_autostart.py' para configurar inicialização automática")
    else:
        print("\n[ERRO] Build falhou!")