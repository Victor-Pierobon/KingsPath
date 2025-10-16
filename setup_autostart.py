#!/usr/bin/env python3
"""
Script para configurar inicialização automática do Kings Path
"""

import os
import shutil
import winreg

def setup_autostart():
    """Configura o Kings Path para iniciar automaticamente"""
    print("[AUTOSTART] Configurando inicialização automática...")
    
    # Caminho do executável
    exe_path = os.path.abspath("dist/KingsPath.exe")
    
    if not os.path.exists(exe_path):
        print("[ERRO] Executável não encontrado. Execute build_exe.py primeiro.")
        return False
    
    try:
        # Adicionar ao registro do Windows (Startup)
        key = winreg.OpenKey(
            winreg.HKEY_CURRENT_USER,
            r"Software\Microsoft\Windows\CurrentVersion\Run",
            0,
            winreg.KEY_SET_VALUE
        )
        
        winreg.SetValueEx(key, "KingsPath", 0, winreg.REG_SZ, exe_path)
        winreg.CloseKey(key)
        
        print(f"[AUTOSTART] Adicionado ao registro: {exe_path}")
        
        # Criar atalho na pasta Startup (método alternativo)
        startup_folder = os.path.join(
            os.environ["APPDATA"],
            "Microsoft\\Windows\\Start Menu\\Programs\\Startup"
        )
        
        if os.path.exists(startup_folder):
            shortcut_path = os.path.join(startup_folder, "KingsPath.lnk")
            create_shortcut(exe_path, shortcut_path)
            print(f"[AUTOSTART] Atalho criado: {shortcut_path}")
        
        return True
        
    except Exception as e:
        print(f"[ERRO] Falha ao configurar autostart: {e}")
        return False

def create_shortcut(target, shortcut_path):
    """Cria atalho do Windows"""
    try:
        import win32com.client
        shell = win32com.client.Dispatch("WScript.Shell")
        shortcut = shell.CreateShortCut(shortcut_path)
        shortcut.Targetpath = target
        shortcut.WorkingDirectory = os.path.dirname(target)
        shortcut.save()
    except ImportError:
        print("[AVISO] win32com não disponível. Apenas registro foi usado.")

def remove_autostart():
    """Remove inicialização automática"""
    print("[AUTOSTART] Removendo inicialização automática...")
    
    try:
        # Remover do registro
        key = winreg.OpenKey(
            winreg.HKEY_CURRENT_USER,
            r"Software\Microsoft\Windows\CurrentVersion\Run",
            0,
            winreg.KEY_SET_VALUE
        )
        
        winreg.DeleteValue(key, "KingsPath")
        winreg.CloseKey(key)
        print("[AUTOSTART] Removido do registro")
        
        # Remover atalho
        startup_folder = os.path.join(
            os.environ["APPDATA"],
            "Microsoft\\Windows\\Start Menu\\Programs\\Startup"
        )
        shortcut_path = os.path.join(startup_folder, "KingsPath.lnk")
        
        if os.path.exists(shortcut_path):
            os.remove(shortcut_path)
            print("[AUTOSTART] Atalho removido")
        
        return True
        
    except Exception as e:
        print(f"[ERRO] Falha ao remover autostart: {e}")
        return False

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "remove":
        success = remove_autostart()
    else:
        success = setup_autostart()
    
    if success:
        print("\n[SUCESSO] Configuração concluída!")
    else:
        print("\n[ERRO] Configuração falhou!")