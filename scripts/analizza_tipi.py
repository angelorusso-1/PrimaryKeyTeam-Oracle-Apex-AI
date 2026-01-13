import pandas as pd
import os

print(f"Cerco il file qui: {percorso_completo}")

if os.path.exists(percorso_completo):
    print("✅ FILE TROVATO! Analisi in corso...")
    df = pd.read_csv(percorso_completo)
    print(df.info())
    print("\nEsempio dati:")
    print(df.head(2))
else:
    print("❌ FILE NON TROVATO.")
    print("Controlla di aver scritto giusto il nome del file e che il percorso sia esatto.")
    
    # Questo ti aiuta a capire dove Python sta guardando ora
    print("\n--- DEBUG ---")
    print(f"Python sta lavorando in questa cartella: {os.getcwd()}")
    print("File presenti qui:", os.listdir())