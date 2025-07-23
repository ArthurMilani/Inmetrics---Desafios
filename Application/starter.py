import subprocess
import os
import signal
import time
from dotenv import load_dotenv

paths = [
    "Authentication_context/main.py",
    "Clientes/main.py",
    "Inventário/main.py",
    "Produtos/main.py"
]

processes = []

def start_apis():
    for path in paths:
        if os.path.exists(path):
            process = subprocess.Popen(["python3", path])
            processes.append((path, process))
            print(f"Iniciado: {path} (PID: {process.pid})")
        else:
            print(f"main.py não encontrado")


def end_apis():
    
    for path, process in processes:
        process.send_signal(signal.SIGINT)  # ou processo.terminate() se preferir
        print(f"Encerrado: {path} (PID: {process.pid})")


if __name__ == "__main__":
    load_dotenv()
    start_apis()
    
    try:
        while True:
            time.sleep(60)
    except KeyboardInterrupt:
            print("Recebido Ctrl+C, encerrando APIs...")
            end_apis()