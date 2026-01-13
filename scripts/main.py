import os
import getpass
from langchain_community.utilities import SQLDatabase
from langchain_cohere import ChatCohere
from langchain_experimental.sql import SQLDatabaseChain

# ---------------- CONFIGURAZIONE ----------------

COHERE_API_KEY = "Inserisci_chiave" # (Ricorda di rigenerarla se la cambi) prendere una chiave

# Configurazione Database
db_user = "prog1"           
db_password = "Inserisci_password" #inserire una password corretta 
db_host = "localhost"
db_port = "1521"
db_service = "xepdb1"       

# ---------------- FINE CONFIGURAZIONE ----------------

os.environ["COHERE_API_KEY"] = COHERE_API_KEY

def main():
    print("--- 🔌 Connessione al Database in corso... ---")
    
    uri = f"oracle+oracledb://{db_user}:{db_password}@{db_host}:{db_port}/?service_name={db_service}"

    try:
        # Connessione al DB
        db = SQLDatabase.from_uri(uri)
        
        # Impostiamo il modello AI
        llm = ChatCohere(model="command-a-vision-07-2025", temperature=0)

        # Creiamo la catena
        db_chain = SQLDatabaseChain.from_llm(llm, db, verbose=True)

        print("\n✅ CONNESSIONE RIUSCITA!")
        print(f"Collegato come utente: {db_user.upper()}")
        print("Il sistema è pronto. Scrivi la tua domanda (o 'esci' per chiudere).")
        print("-" * 50)

        while True:
            user_input_raw = input("\n🗣️  Domanda: ")
            if user_input_raw.lower() in ['esci', 'exit', 'quit']:
                break
            
            # Aggiungiamo istruzioni tecniche di nascosto alla domanda
            user_input = user_input_raw + ". Rispondi solo con la query SQL. NON mettere il punto e virgola finale (;). NON aggiungere caratteri dopo la query."
            
            try:
                response = db_chain.run(user_input)
                print(f"\n🤖 Risposta: {response}")
                print("-" * 50)
            except Exception as e:
                print(f"❌ Errore nell'elaborazione: {e}")

    except Exception as e:
        print(f"\n❌ ERRORE DI CONNESSIONE: {e}")
        print("Verifica che il database sia acceso e che la password sia corretta.")

if __name__ == "__main__":
    main()