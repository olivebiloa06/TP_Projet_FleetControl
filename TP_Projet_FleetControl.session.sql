/* 0) Vérif rapide avant (juste pour voir) */
SELECT
  SUM(ID_VEHICULE IS NULL) AS vehicule_nulls,
  SUM(ID_CAUSE IS NULL) AS cause_nulls,
  SUM(ID_SEVERITE IS NULL) AS severite_nulls,
  SUM(COUT IS NULL) AS cout_nulls,
  SUM(COUT_PIECES IS NULL) AS cout_pieces_nulls,
  SUM(COUT_MAIN_OEUVRE IS NULL) AS cout_mo_nulls,
  SUM(COUT_IMMOBILISATION IS NULL) AS cout_immob_nulls,
  SUM(STATUT IS NULL) AS statut_nulls,
  SUM(DATE_RESOLUTION IS NULL) AS date_reso_nulls
FROM PANNE;

/* 1) Référentiels cause/sévérité */
CREATE TABLE IF NOT EXISTS CAUSE_ANOMALIE (
  ID_CAUSE INT AUTO_INCREMENT PRIMARY KEY,
  CODE     VARCHAR(30) NOT NULL UNIQUE,
  LIBELLE  VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS SEVERITE_ANOMALIE (
  ID_SEVERITE INT AUTO_INCREMENT PRIMARY KEY,
  CODE        VARCHAR(20) NOT NULL UNIQUE,
  LIBELLE     VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

INSERT IGNORE INTO CAUSE_ANOMALIE (CODE, LIBELLE) VALUES
('USURE','Usure normale'),('CHOC','Choc/Accident'),
('FAB','Défaut fabrication'),('ELECT','Panne électrique'),
('MOTEUR','Problème moteur');

INSERT IGNORE INTO SEVERITE_ANOMALIE (CODE, LIBELLE) VALUES
('MINEURE','Impact faible'),('MAJEURE','Impact notable'),('CRITIQUE','Arrêt immédiat');

/* 2) Renseigner ID_VEHICULE pour l'historique via INTERROMPRE -> TRAJET */
UPDATE PANNE p
JOIN INTERROMPRE i ON i.ID_PANNE_ = p.ID_PANNE_
JOIN TRAJET t      ON t.ID_TRAJET = i.ID_TRAJET
SET p.ID_VEHICULE = t.ID_VEHICULE
WHERE p.ID_VEHICULE IS NULL;

/* Si certaines pannes restent sans véhicule, mets-les (temporairement) sur un véhicule connu (ex: 1)
   => décommente cette ligne seulement si nécessaire :
-- UPDATE PANNE SET ID_VEHICULE = 1 WHERE ID_VEHICULE IS NULL;
*/

/* 3) Remplir TOUTES les colonnes NULL par des valeurs par défaut cohérentes */
SET @ID_CAUSE_DEF    = (SELECT ID_CAUSE    FROM CAUSE_ANOMALIE    WHERE CODE='USURE'   LIMIT 1);
SET @ID_SEVERITE_DEF = (SELECT ID_SEVERITE FROM SEVERITE_ANOMALIE WHERE CODE='MINEURE' LIMIT 1);

UPDATE PANNE
SET
  ID_CAUSE            = COALESCE(ID_CAUSE,    @ID_CAUSE_DEF),
  ID_SEVERITE         = COALESCE(ID_SEVERITE, @ID_SEVERITE_DEF),
  COUT                = COALESCE(COUT, 0),
  COUT_PIECES         = COALESCE(COUT_PIECES, 0),
  COUT_MAIN_OEUVRE    = COALESCE(COUT_MAIN_OEUVRE, 0),
  COUT_IMMOBILISATION = COALESCE(COUT_IMMOBILISATION, 0),

/* Option : si tu veux ZÉRO NULL même pour DATE_RESOLUTION,
   tu peux mettre la même date que l’événement (sinon garde NULL pour "non résolue")
-- UPDATE PANNE SET DATE_RESOLUTION = COALESCE(DATE_RESOLUTION, DATE);
*/

/* 4) Contraintes pour empêcher les futurs NULL */
-- (FKs ; si elles existent déjà, MySQL refusera gentiment)
ALTER TABLE PANNE
  ADD CONSTRAINT fk_panne_vehicule  FOREIGN KEY (ID_VEHICULE)  REFERENCES VEHICULE(ID_VEHICULE);

ALTER TABLE PANNE
  ADD CONSTRAINT fk_panne_cause     FOREIGN KEY (ID_CAUSE)     REFERENCES CAUSE_ANOMALIE(ID_CAUSE);

ALTER TABLE PANNE
  ADD CONSTRAINT fk_panne_severite  FOREIGN KEY (ID_SEVERITE)  REFERENCES SEVERITE_ANOMALIE(ID_SEVERITE);

-- Rendre NOT NULL et définir des defaults (après avoir rempli)
ALTER TABLE PANNE
  MODIFY ID_VEHICULE INT NOT NULL,
  MODIFY ID_CAUSE INT NOT NULL,
  MODIFY ID_SEVERITE INT NOT NULL,
  MODIFY STATUT ENUM('ouverte','en_cours','resolue') NOT NULL DEFAULT 'ouverte',
  MODIFY COUT DECIMAL(10,2) NOT NULL DEFAULT 0,
  MODIFY COUT_PIECES DECIMAL(10,2) NOT NULL DEFAULT 0,
  MODIFY COUT_MAIN_OEUVRE DECIMAL(10,2) NOT NULL DEFAULT 0,
  MODIFY COUT_IMMOBILISATION DECIMAL(10,2) NOT NULL DEFAULT 0;

-- garde DATE_RESOLUTION NULL pour refléter "en cours". Si tu veux l'interdire, modifie aussi cette colonne :
-- ALTER TABLE PANNE MODIFY DATE_RESOLUTION DATE NOT NULL;

/* 5) Vérif finale : tout doit être à 0 (sauf date_reso si tu l’as laissée nullable) */
SELECT
  SUM(ID_VEHICULE IS NULL) AS vehicule_nulls,
  SUM(ID_CAUSE IS NULL) AS cause_nulls,
  SUM(ID_SEVERITE IS NULL) AS severite_nulls,
  SUM(COUT IS NULL) AS cout_nulls,
  SUM(COUT_PIECES IS NULL) AS cout_pieces_nulls,
  SUM(COUT_MAIN_OEUVRE IS NULL) AS cout_mo_nulls,
  SUM(COUT_IMMOBILISATION IS NULL) AS cout_immob_nulls,
  SUM(STATUT IS NULL) AS statut_nulls,
  SUM(DATE_RESOLUTION IS NULL) AS date_reso_nulls
FROM PANNE;
