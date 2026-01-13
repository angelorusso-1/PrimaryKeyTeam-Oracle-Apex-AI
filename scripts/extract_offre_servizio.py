import csv
import ast

# CONFIGURAZIONE
INPUT_FILE = 'business.csv'
OUTPUT_SQL = 'insert_offre_servizio.sql'

# Set per evitare duplicati esatti (stessa attività, stesso servizio)
relazioni_inserite = set()

print("Inizio generazione relazioni Attività-Servizi...")

try:
    with open(INPUT_FILE, mode='r', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        
        with open(OUTPUT_SQL, 'w', encoding='utf-8') as sqlfile:
            sqlfile.write("-- Script per popolare OFFRE_SERVIZIO\n")
            sqlfile.write("SET DEFINE OFF;\n\n") 
            
            count = 0
            
            for row in reader:
                business_id = row.get('business_id')
                attr_str = row.get('attributes')
                
                # Se manca l'ID o gli attributi, salta
                if not business_id or not attr_str or attr_str == '{}' or attr_str.lower() == 'none':
                    continue

                try:
                    # Convertiamo la stringa in dizionario reale
                    attributes_dict = ast.literal_eval(attr_str)
                    
                    if isinstance(attributes_dict, dict):
                        for servizio, valore in attributes_dict.items():
                            
                            # 1. PULIZIA DEL SERVIZIO (ID)
                            # Deve essere identico a quello inserito nella tabella SERVIZI
                            servizio_clean = servizio.strip()[:100] 
                            
                            # 2. LOGICA "OFFRE DAVVERO?"
                            # Se il valore è "False", "None" o "u'no'", l'attività NON offre il servizio.
                            val_str = str(valore).lower()
                            if val_str in ['false', 'none', 'no', "u'no'", "u'none'"]:
                                continue

                            # 3. CONTROLLO DUPLICATI
                            chiave_relazione = (business_id, servizio_clean)
                            if chiave_relazione in relazioni_inserite:
                                continue
                            
                            relazioni_inserite.add(chiave_relazione)

                            # 4. SCRITTURA INSERT
                            # Escape degli apostrofi per Oracle (' diventa '')
                            servizio_sql = servizio_clean.replace("'", "''")
                            
                            # Usiamo INSERT IGNORE logico (Dettagli sotto)
                            sql = f"INSERT INTO OFFRE_SERVIZIO (ID_Attivita, ID_Servizio) VALUES ('{business_id}', '{servizio_sql}');\n"
                            sqlfile.write(sql)
                            
                            count += 1

                except (ValueError, SyntaxError):
                    continue

    print(f"Finito! Generate {count} relazioni nel file '{OUTPUT_SQL}'.")

except FileNotFoundError:
    print(f"Errore: File '{INPUT_FILE}' non trovato.")