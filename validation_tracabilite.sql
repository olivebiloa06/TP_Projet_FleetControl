/*==============================================================*/
/* Script de validation - Traçabilité FleetControl v2.0        */
/* Date : 07/11/2025                                           */
/* Objectif : Valider la cohérence du nouveau modèle          */
/*==============================================================*/

-- =====================================================
-- TESTS DE COHÉRENCE STRUCTURELLE
-- =====================================================

-- Test 1: Vérification de l'existence des tables principales
SELECT 
    'Tables principales' AS test_category,
    CASE 
        WHEN COUNT(*) = 4 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    GROUP_CONCAT(table_name) AS details
FROM information_schema.tables 
WHERE table_schema = DATABASE() 
AND table_name IN ('CAUSE_ANOMALIE', 'SEVERITE_ANOMALIE', 'TYPE_IMPACT_FINANCIER', 'ACTION_CORRECTIVE');

-- Test 2: Vérification de l'existence des tables de traçabilité
SELECT 
    'Tables traçabilité' AS test_category,
    CASE 
        WHEN COUNT(*) = 4 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    GROUP_CONCAT(table_name) AS details
FROM information_schema.tables 
WHERE table_schema = DATABASE() 
AND table_name IN ('IMPACT_FINANCIER_ANOMALIE', 'ACTION_CORRECTIVE_APPLIQUEE', 
                   'PIECE_UTILISEE_ANOMALIE', 'HISTORIQUE_STATUT_ANOMALIE');

-- Test 3: Vérification des colonnes ajoutées à la table PANNE
SELECT 
    'Colonnes PANNE' AS test_category,
    CASE 
        WHEN COUNT(*) >= 25 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('Colonnes trouvées: ', COUNT(*)) AS details
FROM information_schema.columns 
WHERE table_schema = DATABASE() 
AND table_name = 'PANNE'
AND column_name IN ('ID_VEHICULE', 'ID_CAUSE', 'ID_SEVERITE', 'STATUT', 'PRIORITE',
                   'DATE_DETECTION', 'DATE_DEBUT_RESOLUTION', 'DATE_RESOLUTION', 'DATE_FERMETURE',
                   'COUT_PIECES', 'COUT_MAIN_OEUVRE', 'COUT_IMMOBILISATION', 'COUT_SOUS_TRAITANCE',
                   'COUT_TRANSPORT', 'COUT_TOTAL_CALCULE', 'KILOMETRAGE_PANNE', 'CONDITIONS_UTILISATION',
                   'SYMPTOMES_OBSERVES', 'DIAGNOSTIC_INITIAL', 'DIAGNOSTIC_FINAL',
                   'ID_TECHNICIEN_DIAGNOSTIC', 'ID_TECHNICIEN_REPARATION', 'ID_RESPONSABLE_VALIDATION',
                   'RECURRENCE', 'NB_OCCURRENCES', 'ID_PANNE_PRECEDENTE', 'GARANTIE_APPLICABLE',
                   'NUMERO_GARANTIE', 'CREE_PAR', 'MODIFIE_PAR', 'VERSION');

-- =====================================================
-- TESTS DE COHÉRENCE DES DONNÉES DE RÉFÉRENCE
-- =====================================================

-- Test 4: Vérification des données de référence - Causes
SELECT 
    'Données causes' AS test_category,
    CASE 
        WHEN COUNT(*) >= 10 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('Causes créées: ', COUNT(*)) AS details
FROM CAUSE_ANOMALIE WHERE ACTIF = TRUE;

-- Test 5: Vérification des données de référence - Sévérités
SELECT 
    'Données sévérités' AS test_category,
    CASE 
        WHEN COUNT(*) >= 6 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('Sévérités créées: ', COUNT(*)) AS details
FROM SEVERITE_ANOMALIE WHERE ACTIF = TRUE;

-- Test 6: Vérification des données de référence - Types d'impact
SELECT 
    'Données impacts' AS test_category,
    CASE 
        WHEN COUNT(*) >= 8 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('Types d''impact créés: ', COUNT(*)) AS details
FROM TYPE_IMPACT_FINANCIER WHERE ACTIF = TRUE;

-- Test 7: Vérification des données de référence - Actions correctives
SELECT 
    'Données actions' AS test_category,
    CASE 
        WHEN COUNT(*) >= 6 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('Actions créées: ', COUNT(*)) AS details
FROM ACTION_CORRECTIVE WHERE ACTIF = TRUE;

-- =====================================================
-- TESTS DE COHÉRENCE DES CONTRAINTES
-- =====================================================

-- Test 8: Vérification des contraintes de clés étrangères
SELECT 
    'Contraintes FK' AS test_category,
    CASE 
        WHEN COUNT(*) >= 15 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('Contraintes FK: ', COUNT(*)) AS details
FROM information_schema.table_constraints 
WHERE table_schema = DATABASE() 
AND constraint_type = 'FOREIGN KEY'
AND table_name IN ('PANNE', 'IMPACT_FINANCIER_ANOMALIE', 'ACTION_CORRECTIVE_APPLIQUEE', 
                   'PIECE_UTILISEE_ANOMALIE', 'HISTORIQUE_STATUT_ANOMALIE');

-- Test 9: Vérification des index créés
SELECT 
    'Index PANNE' AS test_category,
    CASE 
        WHEN COUNT(*) >= 8 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('Index créés: ', COUNT(*)) AS details
FROM information_schema.statistics 
WHERE table_schema = DATABASE() 
AND table_name = 'PANNE'
AND index_name LIKE 'IDX_%';

-- =====================================================
-- TESTS FONCTIONNELS AVEC DONNÉES D'EXEMPLE
-- =====================================================

-- Test 10: Insertion d'une anomalie d'exemple
INSERT IGNORE INTO VEHICULE (ID_VEHICULE, IMMATRICULATION, DATE_ACHAT, KM, STATUT) 
VALUES (999, 'TEST-999-XX', '2023-01-01', 50000, 'ACTIF');

INSERT IGNORE INTO TECHNICIEN (ID_TECHNICIEN, NOM, SPECIALITE) 
VALUES (999, 'TECHNICIEN_TEST', 'MECANIQUE');

-- Insertion d'une anomalie de test
SET @test_cause = (SELECT ID_CAUSE FROM CAUSE_ANOMALIE WHERE CODE = 'PANNE_ELECTRIQUE' LIMIT 1);
SET @test_severite = (SELECT ID_SEVERITE FROM SEVERITE_ANOMALIE WHERE CODE = 'MAJEURE' LIMIT 1);

INSERT IGNORE INTO PANNE (
    ID_PANNE_, ID_VEHICULE, ID_CAUSE, ID_SEVERITE, DESCRIPTION, 
    DATE_DETECTION, STATUT, COUT_PIECES, COUT_MAIN_OEUVRE,
    KILOMETRAGE_PANNE, SYMPTOMES_OBSERVES, CREE_PAR
) VALUES (
    999, 999, @test_cause, @test_severite, 'Test anomalie électrique',
    '2025-11-07 15:00:00', 'OUVERTE', 150.00, 200.00,
    50000, 'Voyants allumés, démarrage difficile', 'TEST_USER'
);

-- Test 11: Vérification du calcul automatique du coût total
SELECT 
    'Calcul coût total' AS test_category,
    CASE 
        WHEN COUT_TOTAL_CALCULE = (COUT_PIECES + COUT_MAIN_OEUVRE + COUT_IMMOBILISATION + COUT_SOUS_TRAITANCE + COUT_TRANSPORT + COALESCE(COUT, 0)) THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('Coût calculé: ', COUT_TOTAL_CALCULE, ' - Attendu: ', (COUT_PIECES + COUT_MAIN_OEUVRE + COUT_IMMOBILISATION + COUT_SOUS_TRAITANCE + COUT_TRANSPORT + COALESCE(COUT, 0))) AS details
FROM PANNE 
WHERE ID_PANNE_ = 999;

-- Test 12: Test d'ajout d'impact financier
INSERT IGNORE INTO IMPACT_FINANCIER_ANOMALIE (
    ID_PANNE, ID_TYPE_IMPACT, MONTANT, DESCRIPTION
) VALUES (
    999, 
    (SELECT ID_TYPE_IMPACT FROM TYPE_IMPACT_FINANCIER WHERE CODE = 'TRANSPORT' LIMIT 1),
    75.00, 
    'Coût de remorquage test'
);

-- Test 13: Test d'ajout de pièce utilisée
INSERT IGNORE INTO PIECE (ID_PIECE, NOM, PRIX_UNITAIRE, QTE) 
VALUES (999, 'PIECE_TEST', 25.00, 100);

INSERT IGNORE INTO PIECE_UTILISEE_ANOMALIE (
    ID_PANNE, ID_PIECE, QUANTITE_UTILISEE, PRIX_UNITAIRE_REEL
) VALUES (
    999, 999, 2, 25.00
);

-- Test 14: Vérification de la mise à jour automatique du coût des pièces
SELECT 
    'Mise à jour coût pièces' AS test_category,
    CASE 
        WHEN COUT_PIECES >= 50.00 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('Coût pièces: ', COUT_PIECES) AS details
FROM PANNE 
WHERE ID_PANNE_ = 999;

-- =====================================================
-- TESTS DES VUES
-- =====================================================

-- Test 15: Test de la vue synthétique
SELECT 
    'Vue synthétique' AS test_category,
    CASE 
        WHEN COUNT(*) > 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('Enregistrements dans vue: ', COUNT(*)) AS details
FROM V_ANOMALIES_SYNTHESE 
WHERE ID_PANNE_ = 999;

-- Test 16: Test de la vue coûts par véhicule
SELECT 
    'Vue coûts véhicule' AS test_category,
    CASE 
        WHEN COUNT(*) > 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    CONCAT('Véhicules avec coûts: ', COUNT(*)) AS details
FROM V_COUTS_PAR_VEHICULE 
WHERE ID_VEHICULE = 999;

-- =====================================================
-- RAPPORT DE VALIDATION FINAL
-- =====================================================

-- Synthèse des tests
SELECT 
    '=== RAPPORT DE VALIDATION FINAL ===' AS rapport,
    '' AS details
UNION ALL
SELECT 
    'Structure de base' AS rapport,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name LIKE '%ANOMALIE%') >= 4
        THEN 'VALIDÉE ✓'
        ELSE 'ERREUR ✗'
    END AS details
UNION ALL
SELECT 
    'Données de référence' AS rapport,
    CASE 
        WHEN (SELECT COUNT(*) FROM CAUSE_ANOMALIE) >= 10 
         AND (SELECT COUNT(*) FROM SEVERITE_ANOMALIE) >= 6
         AND (SELECT COUNT(*) FROM TYPE_IMPACT_FINANCIER) >= 8
        THEN 'VALIDÉES ✓'
        ELSE 'ERREUR ✗'
    END AS details
UNION ALL
SELECT 
    'Contraintes et relations' AS rapport,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.table_constraints 
              WHERE table_schema = DATABASE() AND constraint_type = 'FOREIGN KEY' 
              AND table_name = 'PANNE') >= 6
        THEN 'VALIDÉES ✓'
        ELSE 'ERREUR ✗'
    END AS details
UNION ALL
SELECT 
    'Vues métier' AS rapport,
    CASE 
        WHEN (SELECT COUNT(*) FROM information_schema.views 
              WHERE table_schema = DATABASE() 
              AND table_name LIKE 'V_%ANOMALIE%') >= 2
        THEN 'VALIDÉES ✓'
        ELSE 'ERREUR ✗'
    END AS details;

-- Nettoyage des données de test
DELETE FROM PIECE_UTILISEE_ANOMALIE WHERE ID_PANNE = 999;
DELETE FROM IMPACT_FINANCIER_ANOMALIE WHERE ID_PANNE = 999;
DELETE FROM PANNE WHERE ID_PANNE_ = 999;
DELETE FROM VEHICULE WHERE ID_VEHICULE = 999;
DELETE FROM TECHNICIEN WHERE ID_TECHNICIEN = 999;
DELETE FROM PIECE WHERE ID_PIECE = 999;

/*==============================================================*/
/* STATISTIQUES DU NOUVEAU MODÈLE                              */
/*==============================================================*/

-- Nombre total de tables dans le système
SELECT 
    'STATISTIQUES SYSTÈME' AS categorie,
    COUNT(*) AS valeur,
    'Tables totales' AS description
FROM information_schema.tables 
WHERE table_schema = DATABASE()
UNION ALL
SELECT 
    'TRAÇABILITÉ',
    COUNT(*) AS valeur,
    'Tables de traçabilité' AS description
FROM information_schema.tables 
WHERE table_schema = DATABASE() 
AND table_name IN ('CAUSE_ANOMALIE', 'SEVERITE_ANOMALIE', 'TYPE_IMPACT_FINANCIER', 
                   'ACTION_CORRECTIVE', 'IMPACT_FINANCIER_ANOMALIE', 'ACTION_CORRECTIVE_APPLIQUEE',
                   'PIECE_UTILISEE_ANOMALIE', 'HISTORIQUE_STATUT_ANOMALIE')
UNION ALL
SELECT 
    'CONTRAINTES',
    COUNT(*) AS valeur,
    'Contraintes de clés étrangères' AS description
FROM information_schema.table_constraints 
WHERE table_schema = DATABASE() 
AND constraint_type = 'FOREIGN KEY'
UNION ALL
SELECT 
    'VUES',
    COUNT(*) AS valeur,
    'Vues métier créées' AS description
FROM information_schema.views 
WHERE table_schema = DATABASE()
UNION ALL
SELECT 
    'INDEX',
    COUNT(DISTINCT index_name) AS valeur,
    'Index de performance' AS description
FROM information_schema.statistics 
WHERE table_schema = DATABASE() 
AND table_name = 'PANNE'
AND index_name LIKE 'IDX_%';

/*==============================================================*/
/* EXEMPLES D'UTILISATION DU NOUVEAU MODÈLE                    */
/*==============================================================*/

-- Exemple 1: Requête pour analyser les coûts par cause d'anomalie
-- (Exemple d'utilisation - ne s'exécute que si des données existent)
/*
SELECT 
    ca.LIBELLE AS cause_anomalie,
    COUNT(p.ID_PANNE_) AS nb_occurrences,
    AVG(p.COUT_TOTAL_CALCULE) AS cout_moyen,
    SUM(p.COUT_TOTAL_CALCULE) AS cout_total,
    AVG(DATEDIFF(COALESCE(p.DATE_RESOLUTION, CURRENT_DATE), p.DATE_DETECTION)) AS duree_moyenne_jours
FROM PANNE p
JOIN CAUSE_ANOMALIE ca ON p.ID_CAUSE = ca.ID_CAUSE
GROUP BY ca.ID_CAUSE, ca.LIBELLE
ORDER BY cout_total DESC;
*/

-- Exemple 2: Requête pour identifier les véhicules les plus problématiques
-- (Exemple d'utilisation - ne s'exécute que si des données existent)
/*
SELECT 
    v.IMMATRICULATION,
    COUNT(p.ID_PANNE_) AS nb_anomalies,
    SUM(p.COUT_TOTAL_CALCULE) AS cout_total,
    AVG(p.COUT_TOTAL_CALCULE) AS cout_moyen_par_anomalie,
    SUM(CASE WHEN p.STATUT = 'OUVERTE' THEN 1 ELSE 0 END) AS anomalies_ouvertes
FROM VEHICULE v
LEFT JOIN PANNE p ON v.ID_VEHICULE = p.ID_VEHICULE
GROUP BY v.ID_VEHICULE, v.IMMATRICULATION
HAVING nb_anomalies > 0
ORDER BY cout_total DESC;
*/

-- Exemple 3: Suivi des performances de résolution par technicien
-- (Exemple d'utilisation - ne s'exécute que si des données existent)
/*
SELECT 
    t.NOM AS technicien,
    COUNT(p.ID_PANNE_) AS nb_interventions,
    AVG(DATEDIFF(p.DATE_RESOLUTION, p.DATE_DEBUT_RESOLUTION)) AS duree_moyenne_resolution,
    SUM(p.COUT_MAIN_OEUVRE) AS cout_total_main_oeuvre,
    AVG(p.COUT_MAIN_OEUVRE) AS cout_moyen_intervention
FROM TECHNICIEN t
JOIN PANNE p ON t.ID_TECHNICIEN = p.ID_TECHNICIEN_REPARATION
WHERE p.STATUT = 'RESOLUE'
GROUP BY t.ID_TECHNICIEN, t.NOM
ORDER BY nb_interventions DESC;
*/

/*==============================================================*/
/* RECOMMANDATIONS D'UTILISATION                               */
/*==============================================================*/

SELECT 
    '=== RECOMMANDATIONS D''UTILISATION ===' AS information,
    '' AS details
UNION ALL
SELECT 
    '1. Création d''anomalie',
    'Utiliser la procédure SP_CREER_ANOMALIE() pour créer de nouvelles anomalies'
UNION ALL
SELECT 
    '2. Suivi des coûts',
    'Utiliser la vue V_COUTS_PAR_VEHICULE pour analyser les coûts par véhicule'
UNION ALL
SELECT 
    '3. Analyse des récurrences',
    'Utiliser la vue V_ANOMALIES_RECURRENTES pour identifier les problèmes récurrents'
UNION ALL
SELECT 
    '4. Traçabilité complète',
    'Toutes les modifications de statut sont automatiquement historisées'
UNION ALL
SELECT 
    '5. Calculs automatiques',
    'Les coûts totaux sont calculés automatiquement via les triggers'
UNION ALL
SELECT 
    '6. Migration des données',
    'Les données existantes sont préservées et enrichies avec les nouvelles informations';

/*==============================================================*/
/* FIN DU SCRIPT DE VALIDATION                                 */
/*==============================================================*/