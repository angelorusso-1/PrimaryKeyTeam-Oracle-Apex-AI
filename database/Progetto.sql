-- *** SCRIPT DEFINITIVO *** --

-- 1. SETUP INIZIALE (Eseguire come SYSTEM/SYS)
ALTER SESSION SET CONTAINER = xepdb1;

-- Creazione Utente Proprietario dello Schema
CREATE USER prog1 IDENTIFIED BY password123; 
GRANT CONNECT, RESOURCE, UNLIMITED TABLESPACE TO prog1;
GRANT CREATE VIEW TO prog1;
GRANT CREATE MATERIALIZED VIEW TO prog1;

-- Impostiamo il focus su PROG1 per creare le tabelle al suo interno
ALTER SESSION SET CURRENT_SCHEMA = prog1;

GRANT CREATE ROLE TO prog1;
GRANT CREATE USER TO prog1;
GRANT DROP USER TO prog1;
GRANT ALTER USER TO prog1;

-- Diamo a prog1 il potere di passare i permessi di login e spazio ad altri
GRANT CREATE SESSION TO prog1 WITH ADMIN OPTION;
GRANT UNLIMITED TABLESPACE TO prog1 WITH ADMIN OPTION;


-- 2. CREAZIONE TABELLE

-- Tabella: UTENTI
CREATE TABLE UTENTI (
    Codice_Utente VARCHAR2(50),
    Nome VARCHAR2(100),
    Data_Iscrizione DATE DEFAULT SYSDATE,
    Valutazione_Media_Recensioni NUMBER (3,2),
    Num_Recensioni INTEGER DEFAULT 0,
    Num_Complimenti INTEGER DEFAULT 0,

    CONSTRAINT PK_UTENTI PRIMARY KEY(Codice_Utente),
    CONSTRAINT Check_Valutazione CHECK (Valutazione_Media_Recensioni >= 0 AND Valutazione_Media_Recensioni <= 5)
);

-- Tabella: ATTIVITA
CREATE TABLE ATTIVITA (
    ID_Attivita VARCHAR2(50),
    Nome VARCHAR2(150) NOT NULL,
    Valutazione_Media NUMBER (3,2),
    Numero_Recensioni INTEGER DEFAULT 0,
    Via VARCHAR2(200),
    Stato VARCHAR2(50),
    Citta VARCHAR2(100) NOT NULL,
    CAP VARCHAR2(20),
    Latitudine NUMBER(9,6),
    Longitudine NUMBER(9,6),
    Stato_Aperto VARCHAR2(10) DEFAULT '1',
    
    CONSTRAINT PK_ATTIVITA PRIMARY KEY(ID_Attivita),
    CONSTRAINT Check_Stato CHECK (Stato_Aperto IN ('Aperto', 'Chiuso', '0', '1')),
    CONSTRAINT Check_Valutazione2 CHECK (Valutazione_Media >= 0 AND Valutazione_Media <= 5)
);

-- Tabella: RECENSIONI
CREATE TABLE RECENSIONI(
    Codice_Recensione VARCHAR2(50),
    Utente VARCHAR2(50) NOT NULL,
    Attivita VARCHAR2(50) NOT NULL,
    Valutazione INTEGER NOT NULL,
    Data DATE DEFAULT SYSDATE NOT NULL,
    Testo CLOB,

    Voti_Utili INTEGER DEFAULT 0,
    Voti_Divertenti INTEGER DEFAULT 0,
    Voti_Interessanti INTEGER DEFAULT 0,

    CONSTRAINT PK_RECENSIONI PRIMARY KEY(Codice_Recensione),
    CONSTRAINT Check_Valutazione3 CHECK (Valutazione >= 0 AND Valutazione <= 5)
);

-- Tabella: FOTOGRAFIE
CREATE TABLE FOTOGRAFIE(
    Codice_Fotografia VARCHAR2(50),
    Attivita VARCHAR2(50) NOT NULL,
    Etichetta VARCHAR2(50),
    Didascalia CLOB,
    Foto_Blob BLOB,
    Mimetype VARCHAR2(255 BYTE),
    Filename VARCHAR2(255 BYTE),

    CONSTRAINT PK_FOTOGRAFIE PRIMARY KEY(Codice_Fotografia)
);

-- Tabella: CHECK_IN
CREATE TABLE CHECK_IN(
    Data TIMESTAMP,
    Attivita VARCHAR2(50),
    
    CONSTRAINT PK_CHECK_IN PRIMARY KEY(Data, Attivita)
);

-- Tabella: CATEGORIE
CREATE TABLE CATEGORIE(
    ID_Categoria VARCHAR2(100),
    Nome VARCHAR2(100) NOT NULL,

    CONSTRAINT PK_CATEGORIE PRIMARY KEY(ID_Categoria)
);

-- Tabella: SERVIZI
CREATE TABLE SERVIZI(
    ID_Servizio VARCHAR2(200),

    CONSTRAINT PK_SERVIZI PRIMARY KEY(ID_Servizio)
);

-- Tabella: SUGGERIMENTI
CREATE TABLE SUGGERIMENTI (
    Data_Pubblicazione TIMESTAMP DEFAULT SYSDATE NOT NULL,
    Num_Complimenti_Ricevuti INTEGER DEFAULT 0,
    Testo CLOB,
    Utente VARCHAR2(50) NOT NULL,
    Attivita VARCHAR2(50) NOT NULL,

    CONSTRAINT PK_SUGGERIMENTI PRIMARY KEY(Utente, Attivita, Data_Pubblicazione)
);

-- Tabella: ORARI
CREATE TABLE ORARI (
    Attivita VARCHAR2(50),
    Giorno VARCHAR2(15),
    Ora_Apertura VARCHAR2(10),
    Ora_Chiusura VARCHAR2(10),
    
    CONSTRAINT PK_ORARI PRIMARY KEY(Attivita, Giorno),
    CONSTRAINT Check_Giorni CHECK (Giorno IN ('Monday', 'Tuesday', 'Wednesday', 
    'Thursday', 'Friday', 'Saturday', 'Sunday'))
);

-- Tabella Associazione: COMPLIMENTI
CREATE TABLE COMPLIMENTI (
    Utente1 VARCHAR2(50),
    Utente2 VARCHAR2(50),
    Contenuto VARCHAR2 (50),

    CONSTRAINT PK_COMPLIMENTI PRIMARY KEY (Utente1, Utente2, Contenuto)
);

-- Tabelle Associazione: APPARTIENE_A_CATEGORIA
CREATE TABLE APPARTIENE_A_CATEGORIA (
    ID_Attivita VARCHAR2(50),
    ID_Categoria VARCHAR2(100),

    CONSTRAINT PK_APPARTENENZA PRIMARY KEY(ID_Attivita, ID_Categoria)
);

-- Tabelle Associazione: OFFRE_SERVIZIO
CREATE TABLE OFFRE_SERVIZIO (
    ID_Attivita VARCHAR2(50),
    ID_Servizio VARCHAR2(200),

    CONSTRAINT PK_SERVIZIO PRIMARY KEY(ID_Attivita, ID_Servizio)
);

-- Tabella Associazione: RELAZIONE_AMICIZIA
CREATE TABLE RELAZIONE_AMICIZIA (
    Codice_Utente1 VARCHAR2(50),
    Codice_Utente2 VARCHAR2(50),

    CONSTRAINT PK_AMICIZIA PRIMARY KEY (Codice_Utente1, Codice_Utente2)
);



-- 3. VINCOLI INTEGRITA (Foreign Keys)

-- RECENSIONI
ALTER TABLE RECENSIONI ADD CONSTRAINT FK_REC_ATTIVITA FOREIGN KEY (Attivita) 
REFERENCES ATTIVITA(ID_Attivita) ON DELETE CASCADE;
ALTER TABLE RECENSIONI ADD CONSTRAINT FK_REC_UTENTE FOREIGN KEY (Utente) 
REFERENCES UTENTI(Codice_Utente) ON DELETE CASCADE;

-- FOTOGRAFIE
ALTER TABLE FOTOGRAFIE ADD CONSTRAINT FK_FOTO_ATTIVITA FOREIGN KEY (Attivita) 
REFERENCES ATTIVITA(ID_Attivita) ON DELETE CASCADE;

-- CHECK_IN
ALTER TABLE CHECK_IN ADD CONSTRAINT FK_CHECK_ATTIVITA FOREIGN KEY (Attivita)
REFERENCES ATTIVITA(ID_Attivita) ON DELETE CASCADE;

-- SUGGERIMENTI
ALTER TABLE SUGGERIMENTI ADD CONSTRAINT FK_SUGG_ATTIVITA FOREIGN KEY (Attivita) 
REFERENCES ATTIVITA(ID_Attivita) ON DELETE CASCADE;
ALTER TABLE SUGGERIMENTI ADD CONSTRAINT FK_SUGG_UTENTE FOREIGN KEY (Utente) 
REFERENCES UTENTI(Codice_Utente) ON DELETE CASCADE;

-- ORARI
ALTER TABLE ORARI ADD CONSTRAINT FK_ORARI_ATTIVITA FOREIGN KEY (Attivita) 
REFERENCES ATTIVITA(ID_Attivita) ON DELETE CASCADE;

-- APPARTIENE_A_CATEGORIA
ALTER TABLE APPARTIENE_A_CATEGORIA ADD CONSTRAINT FK_APP_ATTIVITA FOREIGN KEY (ID_Attivita) 
REFERENCES ATTIVITA(ID_Attivita) ON DELETE CASCADE;
ALTER TABLE APPARTIENE_A_CATEGORIA ADD CONSTRAINT FK_APP_CATEGORIA FOREIGN KEY (ID_Categoria) 
REFERENCES CATEGORIE(ID_Categoria) ON DELETE CASCADE;

-- OFFRE_SERVIZIO
ALTER TABLE OFFRE_SERVIZIO ADD CONSTRAINT FK_OFFERTA_ATTIVITA FOREIGN KEY (ID_Attivita) 
REFERENCES ATTIVITA(ID_Attivita) ON DELETE CASCADE;
ALTER TABLE OFFRE_SERVIZIO ADD CONSTRAINT FK_OFFERTA_SERVIZIO FOREIGN KEY (ID_Servizio) 
REFERENCES SERVIZI(ID_Servizio) ON DELETE CASCADE;

-- RELAZIONE_AMICIZIA
ALTER TABLE RELAZIONE_AMICIZIA ADD CONSTRAINT FK_AMICO_UTENTE1 FOREIGN KEY (Codice_Utente1) 
REFERENCES UTENTI(Codice_Utente) ON DELETE CASCADE;
ALTER TABLE RELAZIONE_AMICIZIA ADD CONSTRAINT FK_AMICO_UTENTE2 FOREIGN KEY (Codice_Utente2) 
REFERENCES UTENTI(Codice_Utente) ON DELETE CASCADE;

-- COMPLIMENTI
ALTER TABLE COMPLIMENTI ADD CONSTRAINT FK_COMPLIMENTI_UTENTE1 FOREIGN KEY (Utente1) 
REFERENCES UTENTI(Codice_Utente) ON DELETE CASCADE;
ALTER TABLE COMPLIMENTI ADD CONSTRAINT FK_COMPLIMENTI_UTENTE2 FOREIGN KEY (Utente2) 
REFERENCES UTENTI(Codice_Utente) ON DELETE CASCADE;


-- 4. CREAZIONE RUOLI E UTENTI FISICI

-- A. ADMIN
CREATE ROLE ROLE_ADMIN;

GRANT ALL PRIVILEGES ON UTENTI TO ROLE_ADMIN;
GRANT ALL PRIVILEGES ON ATTIVITA TO ROLE_ADMIN;
GRANT ALL PRIVILEGES ON CATEGORIE TO ROLE_ADMIN;
GRANT ALL PRIVILEGES ON SERVIZI TO ROLE_ADMIN;
GRANT ALL PRIVILEGES ON RECENSIONI TO ROLE_ADMIN;
GRANT ALL PRIVILEGES ON FOTOGRAFIE TO ROLE_ADMIN;
GRANT ALL PRIVILEGES ON CHECK_IN TO ROLE_ADMIN;
GRANT ALL PRIVILEGES ON SUGGERIMENTI TO ROLE_ADMIN;
GRANT ALL PRIVILEGES ON ORARI TO ROLE_ADMIN;
GRANT ALL PRIVILEGES ON COMPLIMENTI TO ROLE_ADMIN;
GRANT ALL PRIVILEGES ON RELAZIONE_AMICIZIA TO ROLE_ADMIN;
GRANT ALL PRIVILEGES ON OFFRE_SERVIZIO TO ROLE_ADMIN;
GRANT ALL PRIVILEGES ON APPARTIENE_A_CATEGORIA TO ROLE_ADMIN;

CREATE USER Admin_Progetto IDENTIFIED BY sono_admin_del_progetto;
GRANT CREATE SESSION TO Admin_Progetto;
GRANT UNLIMITED TABLESPACE TO Admin_Progetto; 
GRANT ROLE_ADMIN TO Admin_Progetto;

-- B. MODERATORE
CREATE ROLE ROLE_MODERATOR;

GRANT SELECT ON UTENTI TO ROLE_MODERATOR;
GRANT SELECT ON ATTIVITA TO ROLE_MODERATOR;
GRANT SELECT ON CATEGORIE TO ROLE_MODERATOR;
GRANT SELECT ON SERVIZI TO ROLE_MODERATOR;
GRANT SELECT ON CHECK_IN TO ROLE_MODERATOR;
GRANT SELECT ON ORARI TO ROLE_MODERATOR;
GRANT SELECT ON COMPLIMENTI TO ROLE_MODERATOR;
GRANT SELECT ON RELAZIONE_AMICIZIA TO ROLE_MODERATOR;
GRANT SELECT ON OFFRE_SERVIZIO TO ROLE_MODERATOR;
GRANT SELECT ON APPARTIENE_A_CATEGORIA TO ROLE_MODERATOR;

GRANT SELECT, UPDATE, DELETE ON RECENSIONI TO ROLE_MODERATOR;
GRANT SELECT, UPDATE, DELETE ON SUGGERIMENTI TO ROLE_MODERATOR;
GRANT SELECT, UPDATE, DELETE ON FOTOGRAFIE TO ROLE_MODERATOR;

CREATE USER Moderator_Progetto IDENTIFIED BY sono_moderatore_del_progetto;
GRANT CREATE SESSION TO Moderator_Progetto;
GRANT UNLIMITED TABLESPACE TO Moderator_Progetto; 
GRANT ROLE_MODERATOR TO Moderator_Progetto;

-- C. USER
CREATE ROLE ROLE_USER;

GRANT INSERT, UPDATE, DELETE ON RECENSIONI TO ROLE_USER;
GRANT INSERT, UPDATE, DELETE ON SUGGERIMENTI TO ROLE_USER;
GRANT INSERT, UPDATE, DELETE ON FOTOGRAFIE TO ROLE_USER;
GRANT INSERT, UPDATE, DELETE ON RELAZIONE_AMICIZIA TO ROLE_USER;
GRANT INSERT, UPDATE, DELETE ON COMPLIMENTI TO ROLE_USER;

GRANT SELECT ON UTENTI TO ROLE_USER;
GRANT SELECT ON ATTIVITA TO ROLE_USER;
GRANT SELECT ON CATEGORIE TO ROLE_USER;
GRANT SELECT ON SERVIZI TO ROLE_USER;
GRANT SELECT ON ORARI TO ROLE_USER;
GRANT SELECT ON OFFRE_SERVIZIO TO ROLE_USER;
GRANT SELECT ON APPARTIENE_A_CATEGORIA TO ROLE_USER;
GRANT SELECT ON RECENSIONI TO ROLE_USER;
GRANT SELECT ON SUGGERIMENTI TO ROLE_USER;
GRANT SELECT ON FOTOGRAFIE TO ROLE_USER;
GRANT SELECT ON CHECK_IN TO ROLE_USER;
GRANT SELECT ON RELAZIONE_AMICIZIA TO ROLE_USER;
GRANT SELECT ON COMPLIMENTI TO ROLE_USER;

CREATE USER User_Progetto IDENTIFIED BY sono_user_del_progetto;
GRANT CREATE SESSION TO User_Progetto;
GRANT UNLIMITED TABLESPACE TO User_Progetto;
GRANT ROLE_USER TO User_Progetto;

-- 5. INDICI

-- Indici per velocizzare la ricerca sui Check-in per Attività e Data
CREATE INDEX IDX_CHECKIN_ATTIVITA ON CHECK_IN (ATTIVITA);
CREATE INDEX IDX_CHECKIN_DATA ON CHECK_IN (DATA);

-- Indici per velocizzare la ricerca sulle Recensioni su utente e attività (per join)
CREATE INDEX IDX_RECENSIONI_UTENTE ON RECENSIONI (UTENTE);     
CREATE INDEX IDX_RECENSIONI_ATTIVITA ON RECENSIONI (ATTIVITA);  

-- Indice per velocizzare la ricerca sulle foto delle Attività
CREATE INDEX IDX_FOTO_ATTIVITA ON FOTOGRAFIE(ATTIVITA);

-- Indice per velocizzare la ricerca sui nomi delle Attività
CREATE INDEX IDX_ATTIVITA_NOME ON ATTIVITA(NOME);

-- Indice per velocizzare la ricerca sui Servizi associati alle Attività
CREATE INDEX IDX_OFFRE_SERVIZIO_SERVIZI ON OFFRE_SERVIZIO(ID_SERVIZIO);


-- 6. QUERY
-- Trovare per ogni attività, il giorno in cui c’è stato il maggior numero di check in nel 2021
-- Tramite Vista Materializzata (necessita di aggiornamento manuale in caso di nuovi check-in
CREATE MATERIALIZED VIEW GIORNI_CHECK_IN 
BUILD IMMEDIATE 
REFRESH COMPLETE ON DEMAND AS
SELECT 
    A.ID_Attivita,   
    A.Nome AS Nome_Attivita, 
    TRUNC(C.Data) AS Data_Check_In,
    COUNT(*) AS Num_Check_In
FROM 
    ATTIVITA A 
JOIN 
    CHECK_IN C ON A.ID_Attivita = C.Attivita 
WHERE 
    C.Data >= TO_DATE('2021-01-01', 'YYYY-MM-DD') 
    AND C.Data <= TO_DATE('2021-12-31', 'YYYY-MM-DD')
GROUP BY 
    A.ID_Attivita, 
    A.Nome,
    TRUNC(C.Data);
    

SELECT 
    G1.Nome_Attivita, 
    G1.Data_Check_In, 
    G1.Num_Check_In
FROM 
    GIORNI_CHECK_IN G1
WHERE 
    G1.Num_Check_In = (
        
        SELECT MAX(G2.Num_Check_In)
        FROM GIORNI_CHECK_IN G2
        WHERE G2.ID_Attivita = G1.ID_Attivita 
    )
ORDER BY 
    G1.Num_Check_In DESC; 
    
-- Trovare per ogni città, le 5 attività con la valutazione media più alta (decrescente) che abbiano almeno 50 recensioni

WITH Classifica_Citta AS (
    SELECT 
        ID_Attivita,  
        Nome,
        Citta,
        Valutazione_Media,
        Numero_Recensioni,
        RANK() OVER (
            PARTITION BY Citta 
            ORDER BY Valutazione_Media DESC
        ) as Posizione
    FROM 
        ATTIVITA
    WHERE 
        Numero_Recensioni >= 50 
)
SELECT 
    Nome,
    Citta,
    Valutazione_Media,
    Numero_Recensioni
FROM 
    Classifica_Citta
WHERE 
    Posizione <= 5
ORDER BY 
    Citta, Posizione;
    
-- Trovare per ogni utente, quelli che hanno scritto più di 100 recensioni
-- i cui complimenti ricevuti (numero di complimenti totali all’utente) superano 1000 (scopo identificare utenti elite)

SELECT 
    Nome, 
    Num_Recensioni, 
    Num_Complimenti 
FROM 
    UTENTI
WHERE 
    Num_Recensioni > 100
    AND Num_Complimenti > 1000
ORDER BY 
    Num_Complimenti DESC; 
    
-- Selezionare i ristoranti di Los Angeles (LA) con valutazione media > 4

SELECT 
    A.Nome, 
    A.Via, 
    A.Citta, 
    A.Valutazione_Media
FROM 
    ATTIVITA A
JOIN APPARTIENE_A_CATEGORIA K ON K.ID_Attivita = A.ID_Attivita 
JOIN CATEGORIE C ON K.ID_Categoria = C.ID_Categoria  
WHERE 
    A.Stato = 'LA'     
    AND C.Nome = 'Restaurants' 
    AND A.Valutazione_Media > 4
ORDER BY Valutazione_Media DESC;
    
-- Trovare tutte le attività aperte ora (controllo diretto sull'orario attuale)

SELECT 
    A.Nome, 
    O.Ora_Apertura, 
    O.Ora_Chiusura
FROM 
    ATTIVITA A
JOIN 
    ORARI O ON A.ID_Attivita = O.Attivita
WHERE 
    -- 1. Controlla il giorno (Forziamo la lingua INGLESE/AMERICAN)
    TRIM(UPPER(O.Giorno)) = TRIM(UPPER(TO_CHAR(SYSDATE, 'DAY', 'NLS_DATE_LANGUAGE=AMERICAN')))
    
    AND 
    
    -- 2. Controlla l'orario
    TO_CHAR(SYSDATE, 'HH24:MI') BETWEEN O.Ora_Apertura AND O.Ora_Chiusura;
    
-- Trovare tutte le foto di un'attività che hanno etichetta food

SELECT 
    A.Nome, 
    F.Codice_Fotografia
FROM 
    FOTOGRAFIE F 
JOIN 
    ATTIVITA A ON F.Attivita = A.ID_Attivita 
WHERE 
    F.Etichetta = 'food';
    
-- Estrarre la lista di tutti i contenuti di un utente specifico (codice -NycZLw5rPxqwrkKKI-83w)
-- (suggerimenti, recensioni, lista di amici)

SELECT 
    'Recensione' AS Tipo,                           
    TO_CHAR(SUBSTR(Testo, 1, 2000)) AS Contenuto,    
    TO_CHAR(Data, 'DD/MM/YYYY') AS Data       
FROM RECENSIONI 
WHERE Utente = '-NycZLw5rPxqwrkKKI-83w'

UNION ALL

SELECT 'Suggerimento', TO_CHAR(SUBSTR(Testo, 1, 2000)), TO_CHAR(Data_Pubblicazione, 'DD/MM/YYYY')
FROM SUGGERIMENTI 
WHERE Utente = '-NycZLw5rPxqwrkKKI-83w'

UNION ALL

SELECT 'Amico', CAST(U.Nome AS VARCHAR2(2000)), NULL
FROM RELAZIONE_AMICIZIA A
JOIN UTENTI U ON A.Codice_Utente2 = U.Codice_Utente 
WHERE A.Codice_Utente1 = '-NycZLw5rPxqwrkKKI-83w';


-- 7.  PROCEDURE

-- 1.	Inserimento "Sicuro" di una Recensione (User Experience
-- Questa procedura semplifica l'inserimento di una recensione. Invece di scrivere una INSERT manuale, l'applicazione chiama questa procedura.
-- Essa gestisce automaticamente la data e l'ID (usando SYS_GUID se non fornito o gestendolo internamente).

CREATE OR REPLACE PROCEDURE SP_AGGIUNGI_RECENSIONE (
    p_Codice_Utente IN VARCHAR2,
    p_ID_Attivita   IN VARCHAR2,
    p_Voto          IN INTEGER,
    p_Testo         IN CLOB
) AS
    v_Nuovo_ID VARCHAR2(50);
BEGIN
    -- Genera un ID univoco
    v_Nuovo_ID := SYS_GUID();

    -- Inserimento
    INSERT INTO RECENSIONI (Codice_Recensione, Utente, Attivita, Valutazione, Testo, Data)
    VALUES (v_Nuovo_ID, p_Codice_Utente, p_ID_Attivita, p_Voto, p_Testo, SYSDATE);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Recensione inserita con successo! ID: ' || v_Nuovo_ID);

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Errore: ID duplicato.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Errore durante l''inserimento: ' || SQLERRM);
        ROLLBACK;
END;
/

-- 2.	Moderazione: Rimozione Recensione e Penalizzazione (Admin/Moderator)
-- Quando un moderatore cancella una recensione offensiva, potrebbe voler anche abbassare il "trust score" dell'utente (o semplicemente loggare l'evento).
-- Questa procedura cancella la recensione (i trigger aggiorneranno le medie automaticamente) e stampa un alert.

CREATE OR REPLACE PROCEDURE SP_RIMUOVI_RECENSIONE_MOD (
    p_Codice_Recensione IN VARCHAR2,
    p_Motivo            IN VARCHAR2
) AS
    v_Utente VARCHAR2(50);
BEGIN
    -- Recupera l'utente prima di cancellare per notificarlo (simulato)
    SELECT Utente INTO v_Utente
    FROM RECENSIONI
    WHERE Codice_Recensione = p_Codice_Recensione;

    -- Cancellazione (I trigger aggiorneranno automaticamente le medie voti su UTENTI e ATTIVITA)
    DELETE FROM RECENSIONI
    WHERE Codice_Recensione = p_Codice_Recensione;

    IF SQL%ROWCOUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Recensione rimossa. Utente ' || v_Utente || ' segnalato per: ' || p_Motivo);
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Recensione non trovata.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Recensione inesistente.');
END;
/

-- 3.   Controllo sulle modifiche dei contenuti da parte degli Utenti

CREATE OR REPLACE PROCEDURE MODIFICA_MIA_RECENSIONE (
    p_id_recensione   IN VARCHAR2,
    p_nuovo_voto      IN NUMBER,
    p_nuovo_testo     IN CLOB,
    p_utente_loggato  IN VARCHAR2 -- L'ID dell'utente che sta provando a modificare
) IS
    v_owner VARCHAR2(50);
BEGIN
    -- 1. Trova chi è il proprietario della recensione
    -- Corretto ID_Recensione in Codice_Recensione
    SELECT Utente INTO v_owner
    FROM RECENSIONI
    WHERE Codice_Recensione = p_id_recensione; 

    -- 2. Se l'utente corrisponde, esegui l'update
    IF v_owner = p_utente_loggato THEN
        UPDATE RECENSIONI
        SET Valutazione = p_nuovo_voto,
            Testo = p_nuovo_testo,
            Data = SYSDATE -- Aggiorniamo la data alla modifica corrente
        WHERE Codice_Recensione = p_id_recensione; -- Corretto nome colonna
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Recensione modificata con successo.');
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Errore: Non puoi modificare recensioni non tue.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Recensione non trovata.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, 'Errore imprevisto: ' || SQLERRM);
END;
/

-- Assegna il permesso al ruolo ROLE_USER
GRANT EXECUTE ON MODIFICA_MIA_RECENSIONE TO ROLE_USER;


-- 8. TRIGGER

-- 1.     Trigger per Aggiornare le Statistiche dell'Attività (Media e Conteggio)

CREATE OR REPLACE TRIGGER TRG_UPDATE_STATS_ATTIVITA
AFTER INSERT OR UPDATE OR DELETE ON RECENSIONI
FOR EACH ROW
BEGIN
   -- Caso INSERIMENTO di una nuova recensione
   IF INSERTING THEN
       UPDATE ATTIVITA
       SET 
           -- Incrementiamo il contatore (usiamo NVL per sicurezza)
           Numero_Recensioni = NVL(Numero_Recensioni, 0) + 1,
           
           -- Ricalcoliamo la media ponderata
           Valutazione_Media = ( 
               (NVL(Valutazione_Media, 0) * NVL(Numero_Recensioni, 0)) + :NEW.Valutazione 
           ) / (NVL(Numero_Recensioni, 0) + 1)
       WHERE ID_Attivita = :NEW.Attivita;
    
   -- Caso CANCELLAZIONE di una recensione
   ELSIF DELETING THEN
       UPDATE ATTIVITA
       SET 
           Numero_Recensioni = GREATEST(NVL(Numero_Recensioni, 0) - 1, 0), -- Evitiamo numeri negativi
           
           Valutazione_Media = CASE 
               -- Se stiamo cancellando l'unica recensione rimasta, la media torna a 0
               WHEN (NVL(Numero_Recensioni, 0) - 1) <= 0 THEN 0 
               ELSE ( 
                   (NVL(Valutazione_Media, 0) * NVL(Numero_Recensioni, 0)) - :OLD.Valutazione 
               ) / (NVL(Numero_Recensioni, 0) - 1)
           END
       WHERE ID_Attivita = :OLD.Attivita;

   -- Caso AGGIORNAMENTO del voto
   -- Scatta solo se cambia la colonna Valutazione o cambia l'attività (spostamento recensione)
   ELSIF UPDATING('Valutazione') THEN
       UPDATE ATTIVITA
       SET Valutazione_Media = ( 
           (NVL(Valutazione_Media, 0) * NVL(Numero_Recensioni, 0)) - :OLD.Valutazione + :NEW.Valutazione 
       ) / NULLIF(Numero_Recensioni, 0) -- NULLIF evita divisioni per zero se i dati fossero corrotti
       WHERE ID_Attivita = :NEW.Attivita;
   END IF;
END;
/

-- 2.     Trigger per Aggiornare le Statistiche dell'Utente (Recensioni scritte)

CREATE OR REPLACE TRIGGER TRG_UPDATE_STATS_UTENTE
AFTER INSERT OR UPDATE OR DELETE ON RECENSIONI
FOR EACH ROW
BEGIN
   -- Caso INSERIMENTO
   IF INSERTING THEN
       UPDATE UTENTI
       SET 
           Num_Recensioni = NVL(Num_Recensioni, 0) + 1,
           
           -- Formula: (MediaVecchia * NumVecchio + NuovoVoto) / (NumVecchio + 1)
           Valutazione_Media_Recensioni = ( 
               (NVL(Valutazione_Media_Recensioni, 0) * NVL(Num_Recensioni, 0)) + :NEW.Valutazione 
           ) / (NVL(Num_Recensioni, 0) + 1)
       WHERE Codice_Utente = :NEW.Utente;
 
   -- Caso CANCELLAZIONE
   ELSIF DELETING THEN
       UPDATE UTENTI
       SET 
           -- Usiamo GREATEST per evitare che il contatore vada sotto zero per errore
           Num_Recensioni = GREATEST(NVL(Num_Recensioni, 0) - 1, 0),
           
           Valutazione_Media_Recensioni = CASE 
               -- Se il numero di recensioni sta per diventare 0 (o lo è già), la media torna a 0
               WHEN (NVL(Num_Recensioni, 0) - 1) <= 0 THEN 0
               ELSE ( 
                   (NVL(Valutazione_Media_Recensioni, 0) * NVL(Num_Recensioni, 0)) - :OLD.Valutazione 
               ) / (NVL(Num_Recensioni, 0) - 1)
           END
       WHERE Codice_Utente = :OLD.Utente;
       
   -- Caso AGGIORNAMENTO (Solo se cambia il voto)
   ELSIF UPDATING ('Valutazione') THEN
       UPDATE UTENTI
       SET 
           Valutazione_Media_Recensioni = ( 
               (NVL(Valutazione_Media_Recensioni, 0) * NVL(Num_Recensioni, 0)) - :OLD.Valutazione + :NEW.Valutazione 
           ) / NULLIF(NVL(Num_Recensioni, 0), 0) -- NULLIF protegge dalla divisione per zero
       WHERE Codice_Utente = :NEW.Utente;
   END IF;
END;
/


-- 3.     Trigger per Aggiornare i Complimenti Ricevuti

CREATE OR REPLACE TRIGGER TRG_UPDATE_COMPLIMENTI
AFTER INSERT OR DELETE ON COMPLIMENTI
FOR EACH ROW
BEGIN
    -- Se viene fatto un complimento (INSERT)
    IF INSERTING THEN
        UPDATE UTENTI
        SET Num_Complimenti = NVL(Num_Complimenti, 0) + 1
        WHERE Codice_Utente = :NEW.Utente2; -- Aggiorniamo il ricevente
    
    -- Se viene rimosso un complimento (DELETE)
    ELSIF DELETING THEN
        UPDATE UTENTI
        SET Num_Complimenti = GREATEST(NVL(Num_Complimenti, 0) - 1, 0) -- Evitiamo numeri negativi
        WHERE Codice_Utente = :OLD.Utente2;
    END IF;
END;
/

-- 4.     Trigger di Integrità: Prevenire Doppie Recensioni

CREATE OR REPLACE TRIGGER TRG_CHECK_DUPLICATE_REVIEW
BEFORE INSERT ON RECENSIONI
FOR EACH ROW
DECLARE
    v_count INTEGER;
BEGIN
    -- Controlla se esiste già una recensione per questa coppia Utente/Attività
    SELECT COUNT(*)
    INTO v_count
    FROM RECENSIONI
    WHERE Utente = :NEW.Utente 
      AND Attivita = :NEW.Attivita;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Errore: Questo utente ha già recensito questa attività.');
    END IF;
END;
/


-- 5.     Trigger per gestione automatica delle Categorie (verifica se esiste la categoria inserita per una nuova attività)

CREATE OR REPLACE TRIGGER TRG_AUTO_INSERT_CATEGORIA
BEFORE INSERT ON APPARTIENE_A_CATEGORIA
FOR EACH ROW
DECLARE
    v_esiste INTEGER;
BEGIN
    -- Controlla se la categoria esiste già nella tabella madre
    SELECT COUNT(*) INTO v_esiste
    FROM CATEGORIE
    WHERE ID_Categoria = :NEW.ID_Categoria;

    -- Se non esiste (count = 0), inseriRE prima di proseguire
    IF v_esiste = 0 THEN
        -- Dobbiamo inserire anche il campo 'Nome' perché è NOT NULL nel database.
        -- Usiamo lo stesso valore dell'ID come Nome di default.
        INSERT INTO CATEGORIE (ID_Categoria, Nome)
        VALUES (:NEW.ID_Categoria, :NEW.ID_Categoria);
        
        DBMS_OUTPUT.PUT_LINE('Nuova categoria creata automaticamente: ' || :NEW.ID_Categoria);
    END IF;
END;
/

-- 6.     Trigger di Coerenza Temporale (Check-in)

CREATE OR REPLACE TRIGGER TRG_CHECKIN_FUTURE
BEFORE INSERT OR UPDATE ON CHECK_IN
FOR EACH ROW
BEGIN
    -- Se la data del check-in è nel futuro rispetto all'orologio del server
    IF :NEW.Data > SYSTIMESTAMP THEN
        RAISE_APPLICATION_ERROR(-20003, 'Errore: Non è possibile effettuare un check-in nel futuro.');
    END IF;
END;
/

-- 7.     Trigger Sociale (Prevenzione auto-interazione)

CREATE OR REPLACE TRIGGER TRG_NO_SELF_INTERACTION
BEFORE INSERT OR UPDATE ON RELAZIONE_AMICIZIA
FOR EACH ROW
BEGIN
    -- Controllo se l'utente sta provando a stringere amicizia con se stesso
    IF :NEW.Codice_Utente1 = :NEW.Codice_Utente2 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Errore: Non puoi stringere amicizia con te stesso.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_NO_SELF_COMPLIMENT
BEFORE INSERT OR UPDATE ON COMPLIMENTI
FOR EACH ROW
BEGIN
    -- Controllo se l'utente sta provando a farsi un complimento da solo
    IF :NEW.Utente1 = :NEW.Utente2 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Errore: Non puoi farti i complimenti da solo.');
    END IF;
END;
/