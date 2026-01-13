import csv
import ast  # Libreria per convertire le stringhe in dizionari in modo sicuro

# CONFIGURAZIONE
INPUT_FILE = 'business.csv'
OUTPUT_SQL = 'insert_servizi.sql'

# Set per salvare i servizi univoci ed evitare duplicati
servizi_univoci = set()

print("Inizio lettura del file...")

try:
    with open(INPUT_FILE, mode='r', encoding='utf-8') as csvfile:
        # Usa DictReader per accedere alle colonne per nome
        reader = csv.DictReader(csvfile)
        
        for row in reader:
            # Prendi la colonna 'attributes'
            attr_str = row.get('attributes')
            
            # Se la cella è vuota o None, saltala
            if not attr_str or attr_str.lower() == 'none' or attr_str == '{}':
                continue
            
            try:
                # La colonna 'attributes' nel dataset Yelp spesso non è un JSON standard,
                # ma una stringa rappresentante un dizionario Python.
                # ast.literal_eval è il modo sicuro per convertirla.
                attributes_dict = ast.literal_eval(attr_str)
                
                # Se la conversione ha successo, prendiamo le chiavi
                if isinstance(attributes_dict, dict):
                    for key in attributes_dict.keys():
                        # Aggiungiamo la chiave al set (es. 'WiFi', 'Parking')
                        # .strip() rimuove spazi extra
                        servizi_univoci.add(key.strip())
                        
            except (ValueError, SyntaxError):
                # Se c'è un errore nel formato di quella riga, la saltiamo
                continue

    print(f"Trovati {len(servizi_univoci)} servizi univoci.")

    # Scrittura del file SQL
    with open(OUTPUT_SQL, 'w', encoding='utf-8') as sqlfile:
        sqlfile.write("-- Script generato automaticamente per popolare la tabella SERVIZI\n")
        sqlfile.write("SET DEFINE OFF;\n\n") # Evita problemi con caratteri speciali in Oracle
        
        for servizio in sorted(servizi_univoci):
            # Tronca a 100 caratteri per sicurezza (come da tua definizione DDL)
            servizio_clean = servizio[:100].replace("'", "''") # Gestione apostrofi per SQL
            
            # Genera la INSERT. 
            # Nota: Usiamo INSERT IGNORE logica (o MERGE) per evitare errori se lanci lo script due volte.
            # Ma per semplicità qui facciamo INSERT standard.
            sql_statement = f"INSERT INTO SERVIZI (ID_Servizio) SELECT '{servizio_clean}' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM SERVIZI WHERE ID_Servizio = '{servizio_clean}');\n"
            sqlfile.write(sql_statement)
            
        sqlfile.write("\nCOMMIT;\n")

    print(f"Fatto! File '{OUTPUT_SQL}' creato con successo.")

except FileNotFoundError:
    print(f"Errore: Il file '{INPUT_FILE}' non è stato trovato nella cartella.")
except Exception as e:
    print(f"Si è verificato un errore imprevisto: {e}")