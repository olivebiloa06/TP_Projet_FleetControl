/* =======================================================
   PHASE 2 – VUE ANALYTIQUE : Synthèse des pannes véhicules
   Projet : FleetControl
   ======================================================= */

CREATE OR REPLACE VIEW V_PANNE_ANALYTIQUE AS
SELECT
    p.ID_PANNE_ AS id_panne,
    v.ID_VEHICULE AS id_vehicule,
    v.IMMATRICULATION AS immatriculation,
    p.DESCRIPTION AS description_panne,
    p.DATE AS date_panne,
    p.STATUT AS statut_panne,
    c.LIBELLE AS cause_anomalie,
    s.LIBELLE AS niveau_severite,

    -- Calcul du coût total : toutes les composantes additionnées
    COALESCE(p.COUT, 0)
      + COALESCE(p.COUT_PIECES, 0)
      + COALESCE(p.COUT_MAIN_OEUVRE, 0)
      + COALESCE(p.COUT_IMMOBILISATION, 0) AS cout_total,

    -- Indicateur de délai de résolution (en jours)
    CASE 
        WHEN p.DATE_RESOLUTION IS NOT NULL 
        THEN DATEDIFF(p.DATE_RESOLUTION, p.DATE)
        ELSE NULL
    END AS delai_resolution_jours

FROM PANNE p
    LEFT JOIN VEHICULE v ON v.ID_VEHICULE = p.ID_VEHICULE
    LEFT JOIN CAUSE_ANOMALIE c ON c.ID_CAUSE = p.ID_CAUSE
    LEFT JOIN SEVERITE_ANOMALIE s ON s.ID_SEVERITE = p.ID_SEVERITE;

CREATE OR REPLACE VIEW V_PANNE_ANALYTIQUE AS
SELECT
  p.ID_PANNE_         AS id_panne,
  p.ID_VEHICULE       AS id_vehicule,
  v.IMMATRICULATION   AS immatriculation,
  p.DESCRIPTION,
  p.DATE              AS date_evt,
  p.STATUT,
  c.LIBELLE           AS cause,
  s.LIBELLE           AS severite,
  COALESCE(p.COUT,0)
  + COALESCE(p.COUT_PIECES,0)
  + COALESCE(p.COUT_MAIN_OEUVRE,0)
  + COALESCE(p.COUT_IMMOBILISATION,0) AS cout_total
FROM PANNE p
LEFT JOIN VEHICULE v          ON v.ID_VEHICULE  = p.ID_VEHICULE
LEFT JOIN CAUSE_ANOMALIE c    ON c.ID_CAUSE     = p.ID_CAUSE
LEFT JOIN SEVERITE_ANOMALIE s ON s.ID_SEVERITE  = p.ID_SEVERITE;
