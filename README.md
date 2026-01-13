# 🗝️ PrimaryKeyApp - Piattaforma Gestione Recensioni Attività

> **Progetto Universitario - Corso di Basi di Dati**
>
> 🏆 **Valutazione Finale:** 30 e Lode

## 📝 Descrizione del Progetto
Applicazione web completa per la gestione e la consultazione di recensioni per diverse attività. Il sistema permette agli utenti di esplorare i locali tramite un'interfaccia a schede (Cards) e agli amministratori di gestire i contenuti tramite dashboard avanzate.

Il progetto si distingue per l'integrazione di un modulo di **Intelligenza Artificiale (Text-to-SQL)** che permette di interrogare il database utilizzando il linguaggio naturale.

## 📄 Documentazione
Tutti i dettagli tecnici, lo schema Entità-Relazione (E-R), la progettazione logica e le scelte implementative sono disponibili nel documento ufficiale:
👉 **[Scarica/Leggi la Relazione Tecnica (PDF)](docs/Documentazione_PrimaryKeyTeam.pdf)**

## 🛠️ Tecnologie Utilizzate
* **Database:** Oracle Database 21c (Relazionale, PL/SQL, BLOB management)
* **Frontend/Framework:** Oracle APEX (Interactive Grids, Cards, Modal Dialogs)
* **AI & Backend Scripting:** Python, Cohere AI (LLM), API REST
* **Tools:** SQL Developer, Git

## ✨ Funzionalità Principali

### 👥 Lato Utente (Frontend)
* **Visualizzazione a Card:** Esplorazione intuitiva delle attività con foto e valutazioni.
* **Sistema di Recensioni:** Gli utenti visualizzano feedback dettagliati e voti, possono inserire foto per un'attività con specifica etichetta.
* **Gestione Foto:** Upload e visualizzazione di immagini salvate come BLOB nel database.

### 🛡️ Lato Admin & Moderatore (Backend APEX)
* **Role-Based Access Control (RBAC):** Gestione granulare dei permessi (Admin, Moderatore, Utente).
* **Dashboard di Moderazione:** Utilizzo di *Interactive Grid* per approvare o rimuovere recensioni offensive e utenti.
* **Gestione Utenti:** Pannello di controllo per la gestione delle anagrafiche e dei permessi.

### 🤖 Modulo AI (Innovazione)
Implementazione di uno script **Python** (`main.py`) che interfaccia il Database locale con **Cohere AI**.
* **Funzione:** Converte domande in linguaggio naturale (es. *"Quali sono i ristoranti con voto medio superiore a 4 a Los Angeles?"*) in query SQL eseguibili.
* **Obiettivo:** Rendere l'analisi dei dati accessibile anche a utenti non tecnici senza conoscere SQL.

## 🗄️ Struttura del Database
Il progetto segue i principi di normalizzazione e integrità referenziale, includendo:
* Gestione Chiavi Primarie ed Esterne.
* Vincoli di integrità (Constraints) e Trigger.
* Ottimizzazione tramite Indici per query frequenti.

## 🚀 Come installare il progetto

### 1. Database & APEX
1.  Importare gli script SQL presenti nella cartella `/database` per creare le tabelle.
2.  Importare il file dell'applicazione (`PrimaryKeyApp.sql`) tramite l'App Builder di Oracle APEX.
3.  Configurare gli *Authorization Schemes* se necessario.

### 2. Modulo Python
Per utilizzare la funzionalità Text-to-SQL:
1.  Installare le dipendenze: `pip install cx_Oracle cohere`
2.  Inserire la propria API Key di Cohere nel file `main.py`.
3.  Eseguire lo script: `python main.py`

## 👥 Il Team
Progetto realizzato da:
* **Angelo Russo** (Frontend (APEX) / Linguaggio Naturale / Backend (Creazione Database / Importazione Dataset)
* **Giovanni Cozzolino** (Query / Trigger/ Procedure / Gestione Concorrenze / Gestione affidabilità)
* **Anna Paola Granato** (Frontend (APEX) / Backend (Comandi DDL) / Schematizzazione Modello E-R)
* **Giada Savi** (Progettazione Concettuale / Traduzione / Progettazione Logica)

---
*Developed by PrimaryKey Team*
