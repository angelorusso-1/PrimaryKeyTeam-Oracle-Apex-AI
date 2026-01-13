import os
import csv
import json

# Configurazione cartelle
input_folder = "JSON"
output_folder = "CSV"

# Crea la cartella CSV se non esiste
os.makedirs(output_folder, exist_ok=True)

print("--- INIZIO CONVERSIONE ---")

for filename in os.listdir(input_folder):
    if filename.endswith(".json"):
        input_path = os.path.join(input_folder, filename)
        output_path = os.path.join(output_folder, filename.replace(".json", ".csv"))
        
        print(f"Elaborazione: {filename}...")
        data = []

        with open(input_path, "r", encoding="utf-8") as f:
            try:
                # TENTATIVO 1: Carica tutto il file come un unico oggetto JSON
                content = json.load(f)
                if isinstance(content, dict):
                    data = [content]
                elif isinstance(content, list):
                    data = content
            
            except json.JSONDecodeError:
                # TENTATIVO 2: Se fallisce, prova a leggere riga per riga (JSON Lines)
                f.seek(0)
                # Usa enumerate per avere il numero di riga (i)
                for i, line in enumerate(f, 1):
                    line = line.strip()
                    if line:
                        try:
                            data.append(json.loads(line))
                        except json.JSONDecodeError as e:
                            # Se una riga è rotta, stampa l'errore ma NON bloccare lo script
                            print(f" -> ERRORE IGNORATO in {filename} alla riga {i}: {e}")
                            continue

        # Se dopo tutto questo non abbiamo dati (file vuoto o tutto rotto), passiamo al prossimo
        if not data:
            print(f" -> ATTENZIONE: Nessun dato valido trovato in {filename}")
            continue

        # Estrazione delle colonne (Header)
        # Nota: Prende le chiavi solo dal primo elemento. 
        # Se altri elementi hanno chiavi diverse, potrebbero essere ignorate.
        keys = data[0].keys()

        # Scrittura del file CSV
        try:
            with open(output_path, "w", newline="", encoding="utf-8") as f_out:
                writer = csv.DictWriter(f_out, fieldnames=keys, extrasaction='ignore')
                writer.writeheader()
                writer.writerows(data)
            print(f" -> FATTO: {output_path}")
            
        except Exception as e:
            print(f" -> Errore durante la scrittura CSV di {filename}: {e}")

print("--- FINE OPERAZIONE ---")