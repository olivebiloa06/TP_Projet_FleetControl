/*==============================================================*/
/* Script de mise à jour FleetControl - Traçabilité Complète des Anomalies */
/* Date de création : 07/11/2025                                */
/* Version : 2.0 - Évolution majeure                           */
/*==============================================================*/

-- =====================================================
-- ÉTAPE 1: CRÉATION DES TABLES DE RÉFÉRENCE
-- =====================================================

-- Table des causes d'anomalies (référentiel étendu)
CREATE TABLE IF NOT EXISTS CAUSE_ANOMALIE (
    ID_CAUSE INT AUTO_INCREMENT PRIMARY KEY,
    CODE VARCHAR(30) NOT NULL UNIQUE,
    LIBELLE VARCHAR(100) NOT NULL,
    DESCRIPTION TEXT,
    NIVEAU_GRAVITE ENUM('FAIBLE', 'MOYEN', 'ELEVE', 'CRITIQUE') DEFAULT 'MOYEN',
    PREVENTABLE BOOLEAN DEFAULT TRUE,
    DATE_CREATION TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ACTIF BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB COMMENT='Référentiel des causes d''anomalies';

-- Table des niveaux de sévérité (référentiel étendu)
CREATE TABLE IF NOT EXISTS SEVERITE_ANOMALIE (
    ID_SEVERITE INT AUTO_INCREMENT PRIMARY KEY,
    CODE VARCHAR(20) NOT NULL UNIQUE,
    LIBELLE VARCHAR(50) NOT NULL,
    DESCRIPTION TEXT,
    IMPACT_OPERATIONNEL ENUM('AUCUN', 'FAIBLE', 'MOYEN', 'FORT', 'BLOQUANT') DEFAULT 'FAIBLE',
    DUREE_MAX_RESOLUTION INT COMMENT 'Durée maximale de résolution en heures',
    PRIORITE INT DEFAULT 3 COMMENT 'Priorité de traitement (1=urgent, 5=faible)',
    DATE_CREATION TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ACTIF BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB COMMENT='Référentiel des niveaux de sévérité';

-- Table des types d'impacts financiers
CREATE TABLE IF NOT EXISTS TYPE_IMPACT_FINANCIER (
    ID_TYPE_IMPACT INT AUTO_INCREMENT PRIMARY KEY,
    CODE VARCHAR(30) NOT NULL UNIQUE,
    LIBELLE VARCHAR(100) NOT NULL,
    DESCRIPTION TEXT,
    UNITE_MESURE VARCHAR(20) DEFAULT 'EUR',
    CALCUL_AUTOMATIQUE BOOLEAN DEFAULT FALSE,
    FORMULE_CALCUL TEXT COMMENT 'Formule de calcul automatique si applicable',
    DATE_CREATION TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ACTIF BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB COMMENT='Types d''impacts financiers';

-- Table des actions correctives
CREATE TABLE IF NOT EXISTS ACTION_CORRECTIVE (
    ID_ACTION INT AUTO_INCREMENT PRIMARY KEY,
    CODE VARCHAR(30) NOT NULL UNIQUE,
    LIBELLE VARCHAR(100) NOT NULL,
    DESCRIPTION TEXT,
    TYPE_ACTION ENUM('PREVENTIVE', 'CORRECTIVE', 'PALLIATIVE') NOT NULL,
    DUREE_ESTIMEE INT COMMENT 'Durée estimée en heures',
    COUT_MOYEN DECIMAL(10,2) DEFAULT 0,
    COMPETENCE_REQUISE VARCHAR(100),
    DATE_CREATION TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ACTIF BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB COMMENT='Référentiel des actions correctives';

-- =====================================================
-- ÉTAPE 2: MODIFICATION DE LA TABLE PANNE EXISTANTE
-- =====================================================

-- Sauvegarde de la structure actuelle
CREATE TABLE IF NOT EXISTS PANNE_BACKUP AS SELECT * FROM PANNE;

-- Ajout des nouvelles colonnes pour la traçabilité complète
ALTER TABLE PANNE 
ADD COLUMN IF NOT EXISTS ID_VEHICULE INT COMMENT 'Référence vers le véhicule concerné',
ADD COLUMN IF NOT EXISTS ID_CAUSE INT COMMENT 'Cause de l''anomalie',
ADD COLUMN IF NOT EXISTS ID_SEVERITE INT COMMENT 'Niveau de sévérité',
ADD COLUMN IF NOT EXISTS STATUT ENUM('OUVERTE', 'EN_COURS', 'RESOLUE', 'FERMEE', 'ANNULEE') DEFAULT 'OUVERTE',
ADD COLUMN IF NOT EXISTS PRIORITE INT DEFAULT 3 COMMENT 'Priorité de traitement (1=urgent, 5=faible)',

-- Traçabilité temporelle
ADD COLUMN IF NOT EXISTS DATE_DETECTION DATETIME COMMENT 'Date de détection de l''anomalie',
ADD COLUMN IF NOT EXISTS DATE_DEBUT_RESOLUTION DATETIME COMMENT 'Date de début de résolution',
ADD COLUMN IF NOT EXISTS DATE_RESOLUTION DATETIME COMMENT 'Date de résolution effective',
ADD COLUMN IF NOT EXISTS DATE_FERMETURE DATETIME COMMENT 'Date de fermeture du dossier',

-- Impacts financiers détaillés
ADD COLUMN IF NOT EXISTS COUT_PIECES DECIMAL(10,2) DEFAULT 0 COMMENT 'Coût des pièces de rechange',
ADD COLUMN IF NOT EXISTS COUT_MAIN_OEUVRE DECIMAL(10,2) DEFAULT 0 COMMENT 'Coût de la main d''œuvre',
ADD COLUMN IF NOT EXISTS COUT_IMMOBILISATION DECIMAL(10,2) DEFAULT 0 COMMENT 'Coût d''immobilisation du véhicule',
ADD COLUMN IF NOT EXISTS COUT_SOUS_TRAITANCE DECIMAL(10,2) DEFAULT 0 COMMENT 'Coût de sous-traitance',
ADD COLUMN IF NOT EXISTS COUT_TRANSPORT DECIMAL(10,2) DEFAULT 0 COMMENT 'Coût de transport/remorquage',
ADD COLUMN IF NOT EXISTS COUT_TOTAL_CALCULE DECIMAL(10,2) GENERATED ALWAYS AS (
    COALESCE(COUT, 0) + COALESCE(COUT_PIECES, 0) + COALESCE(COUT_MAIN_OEUVRE, 0) + 
    COALESCE(COUT_IMMOBILISATION, 0) + COALESCE(COUT_SOUS_TRAITANCE, 0) + COALESCE(COUT_TRANSPORT, 0)
) STORED COMMENT 'Coût total calculé automatiquement',

-- Informations techniques
ADD COLUMN IF NOT EXISTS KILOMETRAGE_PANNE DOUBLE COMMENT 'Kilométrage au moment de la panne',
ADD COLUMN IF NOT EXISTS CONDITIONS_UTILISATION TEXT COMMENT 'Conditions d''utilisation lors de la panne',
ADD COLUMN IF NOT EXISTS SYMPTOMES_OBSERVES TEXT COMMENT 'Symptômes observés',
ADD COLUMN IF NOT EXISTS DIAGNOSTIC_INITIAL TEXT COMMENT 'Diagnostic initial',
ADD COLUMN IF NOT EXISTS DIAGNOSTIC_FINAL TEXT COMMENT 'Diagnostic final après analyse',

-- Traçabilité des intervenants
ADD COLUMN IF NOT EXISTS ID_TECHNICIEN_DIAGNOSTIC INT COMMENT 'Technicien ayant effectué le diagnostic',
ADD COLUMN IF NOT EXISTS ID_TECHNICIEN_REPARATION INT COMMENT 'Technicien ayant effectué la réparation',
ADD COLUMN IF NOT EXISTS ID_RESPONSABLE_VALIDATION INT COMMENT 'Responsable ayant validé la réparation',

-- Informations de suivi
ADD COLUMN IF NOT EXISTS RECURRENCE BOOLEAN DEFAULT FALSE COMMENT 'Anomalie récurrente',
ADD COLUMN IF NOT EXISTS NB_OCCURRENCES INT DEFAULT 1 COMMENT 'Nombre d''occurrences de cette anomalie',
ADD COLUMN IF NOT EXISTS ID_PANNE_PRECEDENTE INT COMMENT 'Référence vers la panne précédente si récurrente',
ADD COLUMN IF NOT EXISTS GARANTIE_APPLICABLE BOOLEAN DEFAULT FALSE COMMENT 'Prise en charge sous garantie',
ADD COLUMN IF NOT EXISTS NUMERO_GARANTIE VARCHAR(50) COMMENT 'Numéro de dossier garantie',

-- Métadonnées
ADD COLUMN IF NOT EXISTS CREE_PAR VARCHAR(50) COMMENT 'Utilisateur ayant créé l''enregistrement',
ADD COLUMN IF NOT EXISTS DATE_CREATION TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS MODIFIE_PAR VARCHAR(50) COMMENT 'Dernier utilisateur ayant modifié',
ADD COLUMN IF NOT EXISTS DATE_MODIFICATION TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS VERSION INT DEFAULT 1 COMMENT 'Version de l''enregistrement';

-- =====================================================
-- ÉTAPE 3: TABLES DE LIAISON ET DÉTAILS
-- =====================================================

-- Table des impacts financiers détaillés par anomalie
CREATE TABLE IF NOT EXISTS IMPACT_FINANCIER_ANOMALIE (
    ID_IMPACT INT AUTO_INCREMENT PRIMARY KEY,
    ID_PANNE INT NOT NULL,
    ID_TYPE_IMPACT INT NOT NULL,
    MONTANT DECIMAL(10,2) NOT NULL DEFAULT 0,
    QUANTITE DECIMAL(8,2) DEFAULT 1,
    PRIX_UNITAIRE DECIMAL(10,2) DEFAULT 0,
    DESCRIPTION TEXT,
    JUSTIFICATION TEXT,
    FACTURE_NUMERO VARCHAR(50),
    DATE_IMPACT DATE,
    VALIDE BOOLEAN DEFAULT FALSE,
    VALIDE_PAR VARCHAR(50),
    DATE_VALIDATION DATETIME,
    DATE_CREATION TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_PANNE) REFERENCES PANNE(ID_PANNE_) ON DELETE CASCADE,
    FOREIGN KEY (ID_TYPE_IMPACT) REFERENCES TYPE_IMPACT_FINANCIER(ID_TYPE_IMPACT)
) ENGINE=InnoDB COMMENT='Détail des impacts financiers par anomalie';

-- Table des actions correctives appliquées
CREATE TABLE IF NOT EXISTS ACTION_CORRECTIVE_APPLIQUEE (
    ID_APPLICATION INT AUTO_INCREMENT PRIMARY KEY,
    ID_PANNE INT NOT NULL,
    ID_ACTION INT NOT NULL,
    ID_TECHNICIEN INT,
    DATE_DEBUT DATETIME,
    DATE_FIN DATETIME,
    DUREE_REELLE INT COMMENT 'Durée réelle en minutes',
    STATUT ENUM('PLANIFIEE', 'EN_COURS', 'TERMINEE', 'ANNULEE') DEFAULT 'PLANIFIEE',
    RESULTAT ENUM('SUCCES', 'ECHEC', 'PARTIEL') DEFAULT 'SUCCES',
    COMMENTAIRES TEXT,
    COUT_REEL DECIMAL(10,2) DEFAULT 0,
    EFFICACITE ENUM('TRES_FAIBLE', 'FAIBLE', 'MOYENNE', 'BONNE', 'EXCELLENTE'),
    DATE_CREATION TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_PANNE) REFERENCES PANNE(ID_PANNE_) ON DELETE CASCADE,
    FOREIGN KEY (ID_ACTION) REFERENCES ACTION_CORRECTIVE(ID_ACTION),
    FOREIGN KEY (ID_TECHNICIEN) REFERENCES TECHNICIEN(ID_TECHNICIEN)
) ENGINE=InnoDB COMMENT='Actions correctives appliquées par anomalie';

-- Table de suivi des pièces utilisées (amélioration de ETRE_UTISEE)
CREATE TABLE IF NOT EXISTS PIECE_UTILISEE_ANOMALIE (
    ID_UTILISATION INT AUTO_INCREMENT PRIMARY KEY,
    ID_PANNE INT NOT NULL,
    ID_PIECE INT NOT NULL,
    QUANTITE_UTILISEE DECIMAL(8,2) NOT NULL,
    PRIX_UNITAIRE_REEL DECIMAL(10,2),
    COUT_TOTAL DECIMAL(10,2) GENERATED ALWAYS AS (QUANTITE_UTILISEE * COALESCE(PRIX_UNITAIRE_REEL, 0)) STORED,
    NUMERO_LOT VARCHAR(50),
    DATE_UTILISATION DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOURNISSEUR_REEL VARCHAR(100),
    GARANTIE_PIECE BOOLEAN DEFAULT FALSE,
    DUREE_GARANTIE_MOIS INT,
    COMMENTAIRES TEXT,
    FOREIGN KEY (ID_PANNE) REFERENCES PANNE(ID_PANNE_) ON DELETE CASCADE,
    FOREIGN KEY (ID_PIECE) REFERENCES PIECE(ID_PIECE)
) ENGINE=InnoDB COMMENT='Détail des pièces utilisées pour chaque anomalie';

-- Table d'historique des changements de statut
CREATE TABLE IF NOT EXISTS HISTORIQUE_STATUT_ANOMALIE (
    ID_HISTORIQUE INT AUTO_INCREMENT PRIMARY KEY,
    ID_PANNE INT NOT NULL,
    ANCIEN_STATUT VARCHAR(20),
    NOUVEAU_STATUT VARCHAR(20) NOT NULL,
    DATE_CHANGEMENT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UTILISATEUR VARCHAR(50),
    COMMENTAIRE TEXT,
    DUREE_STATUT_PRECEDENT INT COMMENT 'Durée en minutes dans le statut précédent',
    FOREIGN KEY (ID_PANNE) REFERENCES PANNE(ID_PANNE_) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Historique des changements de statut';

-- =====================================================
-- ÉTAPE 4: DONNÉES DE RÉFÉRENCE
-- =====================================================

-- Insertion des causes d'anomalies
INSERT IGNORE INTO CAUSE_ANOMALIE (CODE, LIBELLE, DESCRIPTION, NIVEAU_GRAVITE, PREVENTABLE) VALUES
('USURE_NORMALE', 'Usure normale', 'Usure liée à l''utilisation normale du véhicule', 'FAIBLE', TRUE),
('USURE_PREMATUREE', 'Usure prématurée', 'Usure anormalement rapide d''un composant', 'MOYEN', TRUE),
('CHOC_ACCIDENT', 'Choc/Accident', 'Dommage suite à un choc ou accident', 'ELEVE', FALSE),
('DEFAUT_FABRICATION', 'Défaut de fabrication', 'Défaut de conception ou fabrication', 'ELEVE', FALSE),
('PANNE_ELECTRIQUE', 'Panne électrique', 'Dysfonctionnement du système électrique', 'MOYEN', TRUE),
('PROBLEME_MOTEUR', 'Problème moteur', 'Dysfonctionnement du groupe motopropulseur', 'ELEVE', TRUE),
('MAINTENANCE_INSUFFISANTE', 'Maintenance insuffisante', 'Manque ou retard de maintenance préventive', 'MOYEN', TRUE),
('MAUVAISE_UTILISATION', 'Mauvaise utilisation', 'Utilisation non conforme aux préconisations', 'MOYEN', TRUE),
('CONDITIONS_EXTREMES', 'Conditions extrêmes', 'Utilisation dans des conditions difficiles', 'MOYEN', FALSE),
('VANDALISME', 'Vandalisme', 'Dégradation volontaire', 'ELEVE', FALSE);

-- Insertion des niveaux de sévérité
INSERT IGNORE INTO SEVERITE_ANOMALIE (CODE, LIBELLE, DESCRIPTION, IMPACT_OPERATIONNEL, DUREE_MAX_RESOLUTION, PRIORITE) VALUES
('MINEURE', 'Impact mineur', 'Anomalie sans impact sur l''utilisation', 'AUCUN', 168, 4),
('FAIBLE', 'Impact faible', 'Gêne mineure, véhicule utilisable', 'FAIBLE', 72, 3),
('MOYENNE', 'Impact moyen', 'Limitation d''usage, intervention nécessaire', 'MOYEN', 48, 3),
('MAJEURE', 'Impact majeur', 'Usage fortement limité, intervention urgente', 'FORT', 24, 2),
('CRITIQUE', 'Impact critique', 'Véhicule inutilisable, arrêt immédiat', 'BLOQUANT', 8, 1),
('SECURITE', 'Problème de sécurité', 'Risque pour la sécurité des personnes', 'BLOQUANT', 4, 1);

-- Insertion des types d'impacts financiers
INSERT IGNORE INTO TYPE_IMPACT_FINANCIER (CODE, LIBELLE, DESCRIPTION, CALCUL_AUTOMATIQUE) VALUES
('PIECES', 'Coût des pièces', 'Coût des pièces de rechange utilisées', TRUE),
('MAIN_OEUVRE', 'Main d''œuvre', 'Coût de la main d''œuvre de réparation', FALSE),
('IMMOBILISATION', 'Immobilisation', 'Coût d''immobilisation du véhicule', FALSE),
('SOUS_TRAITANCE', 'Sous-traitance', 'Coût de sous-traitance externe', FALSE),
('TRANSPORT', 'Transport', 'Coût de transport/remorquage', FALSE),
('VEHICULE_REMPLACEMENT', 'Véhicule de remplacement', 'Coût de location d''un véhicule de remplacement', FALSE),
('PERTE_EXPLOITATION', 'Perte d''exploitation', 'Manque à gagner lié à l''indisponibilité', FALSE),
('FRANCHISE_ASSURANCE', 'Franchise assurance', 'Franchise à la charge de l''entreprise', FALSE);

-- Insertion des actions correctives de base
INSERT IGNORE INTO ACTION_CORRECTIVE (CODE, LIBELLE, DESCRIPTION, TYPE_ACTION, DUREE_ESTIMEE, COUT_MOYEN) VALUES
('REMPLACEMENT_PIECE', 'Remplacement de pièce', 'Remplacement d''une pièce défectueuse', 'CORRECTIVE', 2, 150.00),
('REPARATION', 'Réparation', 'Réparation d''un composant', 'CORRECTIVE', 4, 200.00),
('MAINTENANCE_PREVENTIVE', 'Maintenance préventive', 'Maintenance préventive renforcée', 'PREVENTIVE', 3, 100.00),
('DIAGNOSTIC_APPROFONDI', 'Diagnostic approfondi', 'Diagnostic technique détaillé', 'CORRECTIVE', 2, 80.00),
('FORMATION_CONDUCTEUR', 'Formation conducteur', 'Formation à l''utilisation correcte', 'PREVENTIVE', 4, 50.00),
('MODIFICATION_TECHNIQUE', 'Modification technique', 'Modification ou amélioration technique', 'PREVENTIVE', 8, 500.00);

-- =====================================================
-- ÉTAPE 5: CONTRAINTES ET INDEX
-- =====================================================

-- Contraintes de clés étrangères pour la table PANNE
ALTER TABLE PANNE 
ADD CONSTRAINT IF NOT EXISTS fk_panne_vehicule 
    FOREIGN KEY (ID_VEHICULE) REFERENCES VEHICULE(ID_VEHICULE) ON DELETE RESTRICT,
ADD CONSTRAINT IF NOT EXISTS fk_panne_cause 
    FOREIGN KEY (ID_CAUSE) REFERENCES CAUSE_ANOMALIE(ID_CAUSE) ON DELETE RESTRICT,
ADD CONSTRAINT IF NOT EXISTS fk_panne_severite 
    FOREIGN KEY (ID_SEVERITE) REFERENCES SEVERITE_ANOMALIE(ID_SEVERITE) ON DELETE RESTRICT,
ADD CONSTRAINT IF NOT EXISTS fk_panne_technicien_diag 
    FOREIGN KEY (ID_TECHNICIEN_DIAGNOSTIC) REFERENCES TECHNICIEN(ID_TECHNICIEN) ON DELETE SET NULL,
ADD CONSTRAINT IF NOT EXISTS fk_panne_technicien_reparation 
    FOREIGN KEY (ID_TECHNICIEN_REPARATION) REFERENCES TECHNICIEN(ID_TECHNICIEN) ON DELETE SET NULL,
ADD CONSTRAINT IF NOT EXISTS fk_panne_precedente 
    FOREIGN KEY (ID_PANNE_PRECEDENTE) REFERENCES PANNE(ID_PANNE_) ON DELETE SET NULL;

-- Index pour optimiser les performances
CREATE INDEX IF NOT EXISTS idx_panne_vehicule ON PANNE(ID_VEHICULE);
CREATE INDEX IF NOT EXISTS idx_panne_statut ON PANNE(STATUT);
CREATE INDEX IF NOT EXISTS idx_panne_date_detection ON PANNE(DATE_DETECTION);
CREATE INDEX IF NOT EXISTS idx_panne_cause ON PANNE(ID_CAUSE);
CREATE INDEX IF NOT EXISTS idx_panne_severite ON PANNE(ID_SEVERITE);
CREATE INDEX IF NOT EXISTS idx_panne_cout_total ON PANNE(COUT_TOTAL_CALCULE);

-- Index composites pour les requêtes fréquentes
CREATE INDEX IF NOT EXISTS idx_panne_vehicule_statut ON PANNE(ID_VEHICULE, STATUT);
CREATE INDEX IF NOT EXISTS idx_panne_date_statut ON PANNE(DATE_DETECTION, STATUT);

-- =====================================================
-- ÉTAPE 6: TRIGGERS POUR L'AUTOMATISATION
-- =====================================================

-- Trigger pour mettre à jour automatiquement la date de modification
DELIMITER //
CREATE TRIGGER IF NOT EXISTS tr_panne_update_modification 
BEFORE UPDATE ON PANNE
FOR EACH ROW
BEGIN
    SET NEW.DATE_MODIFICATION = CURRENT_TIMESTAMP;
    SET NEW.VERSION = OLD.VERSION + 1;
END//

-- Trigger pour l'historique des changements de statut
CREATE TRIGGER IF NOT EXISTS tr_panne_historique_statut 
AFTER UPDATE ON PANNE
FOR EACH ROW
BEGIN
    IF OLD.STATUT != NEW.STATUT THEN
        INSERT INTO HISTORIQUE_STATUT_ANOMALIE 
        (ID_PANNE, ANCIEN_STATUT, NOUVEAU_STATUT, UTILISATEUR, DUREE_STATUT_PRECEDENT)
        VALUES 
        (NEW.ID_PANNE_, OLD.STATUT, NEW.STATUT, NEW.MODIFIE_PAR, 
         TIMESTAMPDIFF(MINUTE, OLD.DATE_MODIFICATION, NEW.DATE_MODIFICATION));
    END IF;
END//

-- Trigger pour calculer automatiquement les coûts de pièces
CREATE TRIGGER IF NOT EXISTS tr_piece_utilisee_update_cout 
AFTER INSERT ON PIECE_UTILISEE_ANOMALIE
FOR EACH ROW
BEGIN
    UPDATE PANNE 
    SET COUT_PIECES = (
        SELECT COALESCE(SUM(COUT_TOTAL), 0) 
        FROM PIECE_UTILISEE_ANOMALIE 
        WHERE ID_PANNE = NEW.ID_PANNE
    )
    WHERE ID_PANNE_ = NEW.ID_PANNE;
END//

DELIMITER ;

-- =====================================================
-- ÉTAPE 7: VUES POUR FACILITER L'EXPLOITATION
-- =====================================================

-- Vue synthétique des anomalies avec toutes les informations
CREATE OR REPLACE VIEW V_ANOMALIES_SYNTHESE AS
SELECT 
    p.ID_PANNE_,
    p.DESCRIPTION,
    v.IMMATRICULATION,
    v.ID_VEHICULE,
    ca.LIBELLE AS CAUSE,
    sa.LIBELLE AS SEVERITE,
    p.STATUT,
    p.DATE_DETECTION,
    p.DATE_RESOLUTION,
    DATEDIFF(COALESCE(p.DATE_RESOLUTION, CURRENT_DATE), p.DATE_DETECTION) AS DUREE_RESOLUTION_JOURS,
    p.COUT_TOTAL_CALCULE,
    p.COUT_PIECES,
    p.COUT_MAIN_OEUVRE,
    p.COUT_IMMOBILISATION,
    p.RECURRENCE,
    p.NB_OCCURRENCES,
    t1.NOM AS TECHNICIEN_DIAGNOSTIC,
    t2.NOM AS TECHNICIEN_REPARATION
FROM PANNE p
LEFT JOIN VEHICULE v ON p.ID_VEHICULE = v.ID_VEHICULE
LEFT JOIN CAUSE_ANOMALIE ca ON p.ID_CAUSE = ca.ID_CAUSE
LEFT JOIN SEVERITE_ANOMALIE sa ON p.ID_SEVERITE = sa.ID_SEVERITE
LEFT JOIN TECHNICIEN t1 ON p.ID_TECHNICIEN_DIAGNOSTIC = t1.ID_TECHNICIEN
LEFT JOIN TECHNICIEN t2 ON p.ID_TECHNICIEN_REPARATION = t2.ID_TECHNICIEN;

-- Vue des coûts par véhicule
CREATE OR REPLACE VIEW V_COUTS_PAR_VEHICULE AS
SELECT 
    v.ID_VEHICULE,
    v.IMMATRICULATION,
    COUNT(p.ID_PANNE_) AS NB_ANOMALIES,
    SUM(p.COUT_TOTAL_CALCULE) AS COUT_TOTAL,
    AVG(p.COUT_TOTAL_CALCULE) AS COUT_MOYEN,
    SUM(p.COUT_PIECES) AS COUT_TOTAL_PIECES,
    SUM(p.COUT_MAIN_OEUVRE) AS COUT_TOTAL_MAIN_OEUVRE,
    SUM(p.COUT_IMMOBILISATION) AS COUT_TOTAL_IMMOBILISATION
FROM VEHICULE v
LEFT JOIN PANNE p ON v.ID_VEHICULE = p.ID_VEHICULE
GROUP BY v.ID_VEHICULE, v.IMMATRICULATION;

-- Vue des anomalies récurrentes
CREATE OR REPLACE VIEW V_ANOMALIES_RECURRENTES AS
SELECT 
    ca.LIBELLE AS CAUSE,
    COUNT(*) AS NB_OCCURRENCES,
    AVG(p.COUT_TOTAL_CALCULE) AS COUT_MOYEN,
    SUM(p.COUT_TOTAL_CALCULE) AS COUT_TOTAL,
    AVG(DATEDIFF(COALESCE(p.DATE_RESOLUTION, CURRENT_DATE), p.DATE_DETECTION)) AS DUREE_MOYENNE_RESOLUTION
FROM PANNE p
JOIN CAUSE_ANOMALIE ca ON p.ID_CAUSE = ca.ID_CAUSE
WHERE p.RECURRENCE = TRUE OR p.NB_OCCURRENCES > 1
GROUP BY ca.ID_CAUSE, ca.LIBELLE
ORDER BY NB_OCCURRENCES DESC;

-- =====================================================
-- ÉTAPE 8: PROCÉDURES STOCKÉES UTILES
-- =====================================================

DELIMITER //

-- Procédure pour créer une nouvelle anomalie
CREATE PROCEDURE IF NOT EXISTS SP_CREER_ANOMALIE(
    IN p_id_vehicule INT,
    IN p_description TEXT,
    IN p_id_cause INT,
    IN p_id_severite INT,
    IN p_kilometrage DOUBLE,
    IN p_symptomes TEXT,
    IN p_utilisateur VARCHAR(50)
)
BEGIN
    DECLARE v_priorite INT DEFAULT 3;
    
    -- Récupération de la priorité basée sur la sévérité
    SELECT PRIORITE INTO v_priorite 
    FROM SEVERITE_ANOMALIE 
    WHERE ID_SEVERITE = p_id_severite;
    
    INSERT INTO PANNE (
        ID_VEHICULE, DESCRIPTION, ID_CAUSE, ID_SEVERITE, 
        STATUT, PRIORITE, DATE_DETECTION, KILOMETRAGE_PANNE, 
        SYMPTOMES_OBSERVES, CREE_PAR, DATE_CREATION
    ) VALUES (
        p_id_vehicule, p_description, p_id_cause, p_id_severite,
        'OUVERTE', v_priorite, CURRENT_TIMESTAMP, p_kilometrage,
        p_symptomes, p_utilisateur, CURRENT_TIMESTAMP
    );
    
    SELECT LAST_INSERT_ID() AS ID_PANNE_CREEE;
END//

-- Procédure pour clôturer une anomalie
CREATE PROCEDURE IF NOT EXISTS SP_CLOTURER_ANOMALIE(
    IN p_id_panne INT,
    IN p_diagnostic_final TEXT,
    IN p_utilisateur VARCHAR(50)
)
BEGIN
    UPDATE PANNE 
    SET 
        STATUT = 'RESOLUE',
        DATE_RESOLUTION = CURRENT_TIMESTAMP,
        DIAGNOSTIC_FINAL = p_diagnostic_final,
        MODIFIE_PAR = p_utilisateur
    WHERE ID_PANNE_ = p_id_panne;
END//

DELIMITER ;

-- =====================================================
-- ÉTAPE 9: MIGRATION DES DONNÉES EXISTANTES
-- =====================================================

-- Mise à jour des données existantes avec des valeurs par défaut cohérentes
UPDATE PANNE 
SET 
    DATE_DETECTION = COALESCE(DATE_DETECTION, DATE, CURRENT_TIMESTAMP),
    ID_CAUSE = COALESCE(ID_CAUSE, (SELECT ID_CAUSE FROM CAUSE_ANOMALIE WHERE CODE = 'USURE_NORMALE' LIMIT 1)),
    ID_SEVERITE = COALESCE(ID_SEVERITE, (SELECT ID_SEVERITE FROM SEVERITE_ANOMALIE WHERE CODE = 'FAIBLE' LIMIT 1)),
    STATUT = CASE 
        WHEN DATE_RESOLUTION IS NOT NULL THEN 'RESOLUE'
        WHEN STATUT IS NULL THEN 'OUVERTE'
        ELSE STATUT
    END,
    COUT_PIECES = COALESCE(COUT_PIECES, 0),
    COUT_MAIN_OEUVRE = COALESCE(COUT_MAIN_OEUVRE, 0),
    COUT_IMMOBILISATION = COALESCE(COUT_IMMOBILISATION, 0),
    COUT_SOUS_TRAITANCE = COALESCE(COUT_SOUS_TRAITANCE, 0),
    COUT_TRANSPORT = COALESCE(COUT_TRANSPORT, 0),
    CREE_PAR = COALESCE(CREE_PAR, 'MIGRATION'),
    DATE_CREATION = COALESCE(DATE_CREATION, DATE, CURRENT_TIMESTAMP)
WHERE ID_PANNE_ IS NOT NULL;

-- Mise à jour des références véhicules manquantes via la table INTERROMPRE
UPDATE PANNE p
JOIN INTERROMPRE i ON i.ID_PANNE_ = p.ID_PANNE_
JOIN TRAJET t ON t.ID_TRAJET = i.ID_TRAJET
SET p.ID_VEHICULE = t.ID_VEHICULE
WHERE p.ID_VEHICULE IS NULL;

-- =====================================================
-- ÉTAPE 10: CONTRAINTES FINALES ET VALIDATION
-- =====================================================

-- Rendre obligatoires les champs essentiels après migration
ALTER TABLE PANNE 
MODIFY ID_VEHICULE INT NOT NULL,
MODIFY ID_CAUSE INT NOT NULL,
MODIFY ID_SEVERITE INT NOT NULL,
MODIFY STATUT ENUM('OUVERTE', 'EN_COURS', 'RESOLUE', 'FERMEE', 'ANNULEE') NOT NULL DEFAULT 'OUVERTE',
MODIFY DATE_DETECTION DATETIME NOT NULL,
MODIFY COUT_PIECES DECIMAL(10,2) NOT NULL DEFAULT 0,
MODIFY COUT_MAIN_OEUVRE DECIMAL(10,2) NOT NULL DEFAULT 0,
MODIFY COUT_IMMOBILISATION DECIMAL(10,2) NOT NULL DEFAULT 0,
MODIFY COUT_SOUS_TRAITANCE DECIMAL(10,2) NOT NULL DEFAULT 0,
MODIFY COUT_TRANSPORT DECIMAL(10,2) NOT NULL DEFAULT 0;

-- =====================================================
-- ÉTAPE 11: SCRIPT DE VALIDATION
-- =====================================================

-- Vérification de la cohérence des données
SELECT 
    'Anomalies sans véhicule' AS verification,
    COUNT(*) AS nombre
FROM PANNE WHERE ID_VEHICULE IS NULL
UNION ALL
SELECT 
    'Anomalies sans cause' AS verification,
    COUNT(*) AS nombre
FROM PANNE WHERE ID_CAUSE IS NULL
UNION ALL
SELECT 
    'Anomalies sans sévérité' AS verification,
    COUNT(*) AS nombre
FROM PANNE WHERE ID_SEVERITE IS NULL
UNION ALL
SELECT 
    'Anomalies avec coûts négatifs' AS verification,
    COUNT(*) AS nombre
FROM PANNE WHERE COUT_TOTAL_CALCULE < 0;

-- Statistiques finales
SELECT 
    COUNT(*) AS total_anomalies,
    COUNT(CASE WHEN STATUT = 'OUVERTE' THEN 1 END) AS ouvertes,
    COUNT(CASE WHEN STATUT = 'EN_COURS' THEN 1 END) AS en_cours,
    COUNT(CASE WHEN STATUT = 'RESOLUE' THEN 1 END) AS resolues,
    SUM(COUT_TOTAL_CALCULE) AS cout_total_global,
    AVG(COUT_TOTAL_CALCULE) AS cout_moyen
FROM PANNE;

/*==============================================================*/
/* FIN DU SCRIPT - TRAÇABILITÉ COMPLÈTE IMPLÉMENTÉE           */
/*==============================================================*/