#!/usr/bin/env python3
"""
Script para verificar configurações de startup
"""

import os
import winreg

def check_registry():
    """Verifica registro do Windows"""
    try:
        key = winreg.OpenKey(
            winreg.HKEY_CURRENT_USER,
            r"Software\Microsoft\Windows\CurrentVersion\Run",
            0,
            winreg.KEY_READ
        )
        
        value, _ = winreg.QueryValueEx(key, "KingsPath")
        winreg.CloseKey(key)
        
        print(f"[REGISTRO] Configurado: {value}")
        return os.path.exists(value)
        
    except Exception as e:
        print(f"[REGISTRO] Não configurado: {e}")
        return False

def check_startup_folder():
    """Verifica pasta Startup"""
    startup_folder = os.path.join(
        os.environ["APPDATA"],
        "Microsoft\\Windows\\Start Menu\\Programs\\Startup"
    )
    
    startup_path = os.path.join(startup_folder, "KingsPath.pyw")
    
    if os.path.exists(startup_path):
        print(f"[STARTUP FOLDER] Configurado: {startup_path}")
        return True
    else:
        print("[STARTUP FOLDER] Não configurado")
        return False

def main():
    """Verifica todas as configurações"""
    print("=== VERIFICAÇÃO DE STARTUP ===")
    
    registry_ok = check_registry()
    folder_ok = check_startup_folder()
    
    print(f"\n=== RESULTADO ===")
    print(f"Registro: {'✓' if registry_ok else '✗'}")
    print(f"Pasta Startup: {'✓' if folder_ok else '✗'}")
    
    if registry_ok or folder_ok:
        print("\n✅ Pelo menos um método está configurado!")
        print("O Kings Path deve iniciar com o Windows.")
    else:
        print("\n❌ Nenhum método configurado!")
        print("Execute 'python setup_startup.py' ou 'python startup_folder.py'")

if __name__ == "__main__":
    main()