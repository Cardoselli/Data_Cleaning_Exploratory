# Tech Layoffs: Advanced Data Cleaning & Exploratory Data Analysis (EDA) in MySQL

Questo repository contiene un progetto completo di ingegneria e analisi dei dati focalizzato sul fenomeno dei licenziamenti nel settore tecnologico globale dal 2020 in poi. Il progetto è strutturato in due script SQL sequenziali: il primo dedicato alla trasformazione e pulizia profonda del dato grezzo, il secondo all'estrazione di metriche di business e trend storici.

## Stack Tecnologico
* **DB**: MySQL SQL
* **Funzioni e costrutti chiave**: CTE (Common Table Expressions), Window Functions (ROW_NUMBER, DENSE_RANK), Self-Join, Data Staging Workflow, Data Type Casting, String Manipulation.

---

## Fase 1: Data Cleaning Pipeline (data_cleaning.sql)

I dati grezzi (layoffs.csv) presentavano anomalie strutturali, duplicati e formati inconsistenti. Per preservare i dati originali, è stato implementato un flusso di staging strutturato in 4 step principali:

### 1. Rimozione dei Duplicati (Bypass del limite MySQL)
Poiché MySQL non permette l'esecuzione diretta di una DELETE su una CTE basata su Window Functions, il problema è stato aggirato con una strategia avanzata:
* È stata calcolata la combinazione univoca delle righe tramite ROW_NUMBER() OVER (PARTITION BY ...) su tutte le colonne del dataset.
* È stata creata una tabella di destinazione secondaria (layoffs_staging2) contenente la colonna fisica row_num.
* Sono stati isolati ed eliminati definitivamente tutti i record con row_num > 1.

### 2. Standardizzazione e Normalizzazione dei Dati
* **Anomalie testuali**: Applicato il TRIM() sulla colonna company per eliminare spazi vuoti parassiti.
* **Discrepanze categoriali**: Normalizzate le varianti della colonna industry (es. unificate le voci 'Crypto', 'Crypto Currency' e 'CryptoCurrency' sotto un unico standard 'Crypto').
* **Errori di battitura geografici**: Corretto l'errore di data-entry per gli Stati Uniti (trasformando 'United States.' in 'United States' tramite operatore LIKE).
* **Data Type Casting**: La colonna date originariamente in formato TEXT è stata convertita in un oggetto temporale reale tramite la funzione STR_TO_DATE(), modificando successivamente la struttura della tabella con un ALTER TABLE ... MODIFY COLUMN ... DATE.

### 3. Gestione dei Valori Mancanti (Null & Blanks)
* Identificati i record con valori vuoti ('') nella colonna industry.
* Convertiti i campi vuoti in NULL per standardizzare la gestione del dato mancante.
* Ricostruiti i dati mancanti tramite una Self-Join logica: incrociando le righe nulle con righe popolate della stessa azienda (es. recuperando il settore 'Travel' per i record mancanti di Airbnb).

### 4. Ottimizzazione Strutturale
* Eliminate le righe totalmente prive di valore analitico, ovvero quelle aventi contemporaneamente NULL sia in total_laid_off che in percentage_laid_off.
* Rimossa la colonna di servizio row_num tramite ALTER TABLE ... DROP COLUMN per lasciare il dataset finale pulito e ottimizzato.

---

## Fase 2: Exploratory Data Analysis (eda.sql)

Sul dataset bonificato è stata condotta un'analisi esplorativa per mappare l'andamento macroeconomico della crisi nel settore tech.

### Analisi dei Trend e dei Volumi
* **Analisi dei Picchi**: Individuazione dei record con tasso di licenziamento pari al 100% (percentage_laid_off = 1) ordinati per fondi raccolti, identificando le startup fallite più capitalizzate.
* **Aggregazioni Macro**: Calcolo dei volumi totali di licenziamenti aggregati per Azienda, Settore merceologico (industry), Nazione e Fase di finanziamento (stage).

### Query Avanzate e Analisi Progressiva
* **Analisi Temporale con Rolling Total**: Estrazione dell'andamento storico anno-mese tramite manipolazione di stringa (SUBSTRING(date,1,7)). È stata implementata una CTE per calcolare il totale progressivo cumulativo (Rolling Total) dei licenziamenti nel tempo tramite la funzione di aggregazione SUM() OVER (ORDER BY ...).
* **Classifiche Annuali Complesse (Top 5)**: Sviluppo di una struttura a matrioska con doppie CTE combinate. Sfruttando la Window Function DENSE_RANK() OVER (PARTITION BY YEAR(date) ORDER BY SUM(total_laid_off) DESC), il sistema isola e restituisce solo le 5 aziende che hanno licenziato più personale per ogni singolo anno, gestendo accuratamente gli eventuali pareggi (ties).

---
