import os
import oracledb
import mimetypes

# --- 1. CONFIGURAZIONE ---
cartella_foto = r"C:\Users\angio\Desktop\Progetto Bd\FOTO_ATTIVITA\photos" #cambiare percorso in base alla cartella in cui si trovano le foto
db_user = "prog1" 
db_password = "password123"
db_dsn = "localhost:1521/xepdb1"

# --- 2. CONNESSIONE ---
print("Connessione a Oracle...")
try:
    connection = oracledb.connect(user=db_user, password=db_password, dsn=db_dsn)
    cursor = connection.cursor()
    print("Connesso!")
except Exception as e:
    print(f"Errore connessione: {e}")
    exit()

# --- 3. CICLO SUI FILE ---
files = os.listdir(cartella_foto)
count = 0

print(f"Inizio elaborazione di {len(files)} file...")

for nome_file in files:
    percorso_completo = os.path.join(cartella_foto, nome_file)
    
    if os.path.isfile(percorso_completo):
        if nome_file.startswith('.'): continue

        # --- PUNTO CRUCIALE MODIFICATO ---
        # Estraiamo il nome senza estensione (es. da "3_C9KZ.jpg" a "3_C9KZ")
        # E lo trattiamo come TESTO, non come numero.
        id_foto_str = os.path.splitext(nome_file)[0]

        mime_type, _ = mimetypes.guess_type(percorso_completo)
        
        try:
            with open(percorso_completo, 'rb') as f:
                blob_data = f.read()
        except Exception as e:
            print(f"Errore lettura {nome_file}: {e}")
            continue

        # --- 4. QUERY DI UPDATE ---
        # Cerchiamo la riga dove CODICE_FOTOGRAFIA è uguale alla stringa del nome file
        sql = """
            UPDATE FOTOGRAFIE 
            SET FOTO_BLOB = :blob, 
                MIMETYPE = :mime, 
                FILENAME = :fname
            WHERE CODICE_FOTOGRAFIA = :id_cercato
        """
        
        # Eseguiamo passando l'ID come stringa
        cursor.execute(sql, [blob_data, mime_type, nome_file, id_foto_str])
        
        if cursor.rowcount > 0:
            print(f"[OK] Aggiornato codice: {id_foto_str}")
            count += 1
        else:
            # Questo messaggio ti aiuta a capire se c'è un disallineamento
            print(f"[MISSING] Il codice '{id_foto_str}' non esiste nella colonna CODICE_FOTOGRAFIA.")

connection.commit()
cursor.close()
connection.close()
print("---")
print(f"Operazione conclusa. Aggiornate {count} foto.")