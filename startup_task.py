#!/usr/bin/env python3
"""
Script para criar tarefa agendada no Windows
"""

import os
import subprocess
import sys

def create_scheduled_task():
    """Cria tarefa agendada para inicialização"""
    script_path = os.path.abspath("KingsPath.pyw")
    task_name = "KingsPath_Startup"
    
    # Comando para criar tarefa agendada
    cmd = f'''schtasks /create /tn "{task_name}" /tr "pythonw \\"{script_path}\\"" /sc onlogon /f'''
    
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"[TASK] Tarefa agendada criada: {task_name}")
            return True
        else:
            print(f"[ERRO] Falha ao criar tarefa: {result.stderr}")
            return False
    except Exception as e:
        print(f"[ERRO] Erro ao criar tarefa: {e}")
        return False

def remove_scheduled_task():
    """Remove tarefa agendada"""
    task_name = "KingsPath_Startup"
    
    cmd = f'schtasks /delete /tn "{task_name}" /f'
    
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"[TASK] Tarefa agendada removida: {task_name}")
            return True
        else:
            print(f"[ERRO] Falha ao remover tarefa: {result.stderr}")
            return False
    except Exception as e:
        print(f"[ERRO] Erro ao remover tarefa: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "remove":
        success = remove_scheduled_task()
    else:
        success = create_scheduled_task()
    
    if success:
        print("\n[SUCESSO] Configuração de tarefa concluída!")
    else:
        print("\n[ERRO] Configuração de tarefa falhou!")