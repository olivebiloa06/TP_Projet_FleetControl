/*==============================================================*/
/* Nom de SGBD :  MySQL 5.0                                     */
/* Date de création :  07/11/2025 16:35:00                      */
/* Version : 2.0 - Évolution majeure avec traçabilité complète */
/*==============================================================*/

-- Suppression des tables dans l'ordre inverse des dépendances
drop table if exists HISTORIQUE_STATUT_ANOMALIE;
drop table if exists ACTION_CORRECTIVE_APPLIQUEE;
drop table if exists PIECE_UTILISEE_ANOMALIE;
drop table if exists IMPACT_FINANCIER_ANOMALIE;
drop table if exists ETRE_UTISEE;
drop table if exists FAIRE;
drop table if exists INTERROMPRE;
drop table if exists PANNE;
drop table if exists ACTION_CORRECTIVE;
drop table if exists TYPE_IMPACT_FINANCIER;
drop table if exists SEVERITE_ANOMALIE;
drop table if exists CAUSE_ANOMALIE;
drop table if exists CATEGORIE;
drop table if exists CONDUCTEUR;
drop table if exists CONTRAT;
drop table if exists ENTRETIEN;
drop table if exists FOURNISSEUR;
drop table if exists PIECE;
drop table if exists SITE;
drop table if exists TECHNICIEN;
drop table if exists TRAJET;
drop table if exists VEHICULE;

/*==============================================================*/
/* Tables de référence pour la traçabilité                     */
/*==============================================================*/

/*==============================================================*/
/* Table : CAUSE_ANOMALIE                                       */
/*==============================================================*/
create table CAUSE_ANOMALIE
(
   ID_CAUSE             int AUTO_INCREMENT not null,
   CODE                 varchar(30) not null,
   LIBELLE              varchar(100) not null,
   DESCRIPTION          text,
   NIVEAU_GRAVITE       enum('FAIBLE','MOYEN','ELEVE','CRITIQUE') default 'MOYEN',
   PREVENTABLE          boolean default true,
   DATE_CREATION        timestamp default CURRENT_TIMESTAMP,
   ACTIF                boolean default true,
   primary key (ID_CAUSE),
   unique key UK_CAUSE_CODE (CODE)
) ENGINE=InnoDB COMMENT='Référentiel des causes d''anomalies';

/*==============================================================*/
/* Table : SEVERITE_ANOMALIE                                    */
/*==============================================================*/
create table SEVERITE_ANOMALIE
(
   ID_SEVERITE          int AUTO_INCREMENT not null,
   CODE                 varchar(20) not null,
   LIBELLE              varchar(50) not null,
   DESCRIPTION          text,
   IMPACT_OPERATIONNEL  enum('AUCUN','FAIBLE','MOYEN','FORT','BLOQUANT') default 'FAIBLE',
   DUREE_MAX_RESOLUTION int comment 'Durée maximale de résolution en heures',
   PRIORITE             int default 3 comment 'Priorité de traitement (1=urgent, 5=faible)',
   DATE_CREATION        timestamp default CURRENT_TIMESTAMP,
   ACTIF                boolean default true,
   primary key (ID_SEVERITE),
   unique key UK_SEVERITE_CODE (CODE)
) ENGINE=InnoDB COMMENT='Référentiel des niveaux de sévérité';

/*==============================================================*/
/* Table : TYPE_IMPACT_FINANCIER                                */
/*==============================================================*/
create table TYPE_IMPACT_FINANCIER
(
   ID_TYPE_IMPACT       int AUTO_INCREMENT not null,
   CODE                 varchar(30) not null,
   LIBELLE              varchar(100) not null,
   DESCRIPTION          text,
   UNITE_MESURE         varchar(20) default 'EUR',
   CALCUL_AUTOMATIQUE   boolean default false,
   FORMULE_CALCUL       text comment 'Formule de calcul automatique si applicable',
   DATE_CREATION        timestamp default CURRENT_TIMESTAMP,
   ACTIF                boolean default true,
   primary key (ID_TYPE_IMPACT),
   unique key UK_TYPE_IMPACT_CODE (CODE)
) ENGINE=InnoDB COMMENT='Types d''impacts financiers';

/*==============================================================*/
/* Table : ACTION_CORRECTIVE                                    */
/*==============================================================*/
create table ACTION_CORRECTIVE
(
   ID_ACTION            int AUTO_INCREMENT not null,
   CODE                 varchar(30) not null,
   LIBELLE              varchar(100) not null,
   DESCRIPTION          text,
   TYPE_ACTION          enum('PREVENTIVE','CORRECTIVE','PALLIATIVE') not null,
   DUREE_ESTIMEE        int comment 'Durée estimée en heures',
   COUT_MOYEN           decimal(10,2) default 0,
   COMPETENCE_REQUISE   varchar(100),
   DATE_CREATION        timestamp default CURRENT_TIMESTAMP,
   ACTIF                boolean default true,
   primary key (ID_ACTION),
   unique key UK_ACTION_CODE (CODE)
) ENGINE=InnoDB COMMENT='Référentiel des actions correctives';

/*==============================================================*/
/* Tables principales existantes (structure conservée)          */
/*==============================================================*/

/*==============================================================*/
/* Table : SITE                                                 */
/*==============================================================*/
create table SITE
(
   ID_SITE              int AUTO_INCREMENT not null,
   NOM                  varchar(255),
   ADRESSE              varchar(255) not null,
   primary key (ID_SITE, ADRESSE),
   key AK_ID_SITE (ID_SITE)
);

/*==============================================================*/
/* Table : CATEGORIE                                            */
/*==============================================================*/
create table CATEGORIE
(
   ID_CAT               int AUTO_INCREMENT not null,
   LIBELLE              varchar(255),
   primary key (ID_CAT),
   key AK_ID_CAT (ID_CAT)
);

/*==============================================================*/
/* Table : CONDUCTEUR                                           */
/*==============================================================*/
create table CONDUCTEUR
(
   ID_COND              int AUTO_INCREMENT not null,
   NOM                  varchar(255),
   PRENOM               varchar(255),
   PERMIS               varchar(30),
   TELEPHONE            varchar(10),
   primary key (ID_COND),
   key AK_ID_COND (ID_COND)
);

/*==============================================================*/
/* Table : VEHICULE                                             */
/*==============================================================*/
create table VEHICULE
(
   ID_VEHICULE          int AUTO_INCREMENT not null,
   ID_CAT               int,
   ID_COND              int,
   ID_SITE              int,
   ADRESSE              varchar(255),
   IMMATRICULATION      varchar(255),
   DATE_ACHAT           date,
   KM                   double,
   STATUT               varchar(255),
   primary key (ID_VEHICULE),
   key AK_ID_VEHICULE (ID_VEHICULE)
);

/*==============================================================*/
/* Table : TRAJET                                               */
/*==============================================================*/
create table TRAJET
(
   ID_TRAJET            int AUTO_INCREMENT not null,
   ID_COND              int,
   ID_VEHICULE          int,
   DATE_DEBUT           date,
   DATE_FIN             date,
   DESTINATION          varchar(255),
   COUT                 double,
   primary key (ID_TRAJET),
   key AK_ID_TRAJET (ID_TRAJET)
);

/*==============================================================*/
/* Table : FOURNISSEUR                                          */
/*==============================================================*/
create table FOURNISSEUR
(
   ID_FOURNISSEUR       int AUTO_INCREMENT not null,
   NOM                  varchar(255),
   TELEPHONE_           varchar(10),
   primary key (ID_FOURNISSEUR),
   key AK_ID_FOURNISSEUR (ID_FOURNISSEUR)
);

/*==============================================================*/
/* Table : ENTRETIEN                                            */
/*==============================================================*/
create table ENTRETIEN
(
   ID_ENTRETIEN         int AUTO_INCREMENT not null,
   ID_FOURNISSEUR       int,
   TYPE                 varchar(255),
   DATE                 date,
   KM                   double,
   primary key (ID_ENTRETIEN),
   key AK_ID_ENTRETIEN (ID_ENTRETIEN)
);

/*==============================================================*/
/* Table : TECHNICIEN                                           */
/*==============================================================*/
create table TECHNICIEN
(
   ID_TECHNICIEN        int AUTO_INCREMENT not null,
   NOM                  varchar(255),
   SPECIALITE           varchar(255),
   primary key (ID_TECHNICIEN),
   key AK_ID_TECHNICIEN (ID_TECHNICIEN)
);

/*==============================================================*/
/* Table : PIECE                                                */
/*==============================================================*/
create table PIECE
(
   ID_PIECE             int AUTO_INCREMENT not null,
   NOM                  varchar(255),
   PRIX_UNITAIRE        decimal(10,2),
   QTE                  bigint,
   primary key (ID_PIECE),
   key AK_ID_PIECE (ID_PIECE)
);

/*==============================================================*/
/* Table : CONTRAT                                              */
/*==============================================================*/
create table CONTRAT
(
   ID_CONTRAT           int AUTO_INCREMENT not null,
   ID_VEHICULE          int,
   TYPE                 varchar(255),
   DATE_DEBUT           date,
   DATE_FIN             date,
   primary key (ID_CONTRAT),
   key AK_ID_CONTRAT (ID_CONTRAT)
);

/*==============================================================*/
/* Table : PANNE (Version 2.0 avec traçabilité complète)       */
/*==============================================================*/
create table PANNE
(
   ID_PANNE_            int AUTO_INCREMENT not null,
   ID_VEHICULE          int not null comment 'Référence vers le véhicule concerné',
   ID_CAUSE             int not null comment 'Cause de l''anomalie',
   ID_SEVERITE          int not null comment 'Niveau de sévérité',
   
   -- Informations de base (conservées)
   DESCRIPTION          varchar(255),
   DATE                 date comment 'Date de l''événement (conservé pour compatibilité)',
   COUT                 decimal(10,2) default 0 comment 'Coût initial (conservé pour compatibilité)',
   
   -- Traçabilité du statut et priorité
   STATUT               enum('OUVERTE','EN_COURS','RESOLUE','FERMEE','ANNULEE') not null default 'OUVERTE',
   PRIORITE             int default 3 comment 'Priorité de traitement (1=urgent, 5=faible)',
   
   -- Traçabilité temporelle
   DATE_DETECTION       datetime not null comment 'Date de détection de l''anomalie',
   DATE_DEBUT_RESOLUTION datetime comment 'Date de début de résolution',
   DATE_RESOLUTION      datetime comment 'Date de résolution effective',
   DATE_FERMETURE       datetime comment 'Date de fermeture du dossier',
   
   -- Impacts financiers détaillés
   COUT_PIECES          decimal(10,2) not null default 0 comment 'Coût des pièces de rechange',
   COUT_MAIN_OEUVRE     decimal(10,2) not null default 0 comment 'Coût de la main d''œuvre',
   COUT_IMMOBILISATION  decimal(10,2) not null default 0 comment 'Coût d''immobilisation du véhicule',
   COUT_SOUS_TRAITANCE  decimal(10,2) not null default 0 comment 'Coût de sous-traitance',
   COUT_TRANSPORT       decimal(10,2) not null default 0 comment 'Coût de transport/remorquage',
   COUT_TOTAL_CALCULE   decimal(10,2) GENERATED ALWAYS AS (
       COALESCE(COUT, 0) + COALESCE(COUT_PIECES, 0) + COALESCE(COUT_MAIN_OEUVRE, 0) + 
       COALESCE(COUT_IMMOBILISATION, 0) + COALESCE(COUT_SOUS_TRAITANCE, 0) + COALESCE(COUT_TRANSPORT, 0)
   ) STORED comment 'Coût total calculé automatiquement',
   
   -- Informations techniques
   KILOMETRAGE_PANNE    double comment 'Kilométrage au moment de la panne',
   CONDITIONS_UTILISATION text comment 'Conditions d''utilisation lors de la panne',
   SYMPTOMES_OBSERVES   text comment 'Symptômes observés',
   DIAGNOSTIC_INITIAL   text comment 'Diagnostic initial',
   DIAGNOSTIC_FINAL     text comment 'Diagnostic final après analyse',
   
   -- Traçabilité des intervenants
   ID_TECHNICIEN_DIAGNOSTIC int comment 'Technicien ayant effectué le diagnostic',
   ID_TECHNICIEN_REPARATION int comment 'Technicien ayant effectué la réparation',
   ID_RESPONSABLE_VALIDATION int comment 'Responsable ayant validé la réparation',
   
   -- Informations de suivi
   RECURRENCE           boolean default false comment 'Anomalie récurrente',
   NB_OCCURRENCES       int default 1 comment 'Nombre d''occurrences de cette anomalie',
   ID_PANNE_PRECEDENTE  int comment 'Référence vers la panne précédente si récurrente',
   GARANTIE_APPLICABLE  boolean default false comment 'Prise en charge sous garantie',
   NUMERO_GARANTIE      varchar(50) comment 'Numéro de dossier garantie',
   
   -- Métadonnées
   CREE_PAR             varchar(50) comment 'Utilisateur ayant créé l''enregistrement',
   DATE_CREATION        timestamp default CURRENT_TIMESTAMP,
   MODIFIE_PAR          varchar(50) comment 'Dernier utilisateur ayant modifié',
   DATE_MODIFICATION    timestamp default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
   VERSION              int default 1 comment 'Version de l''enregistrement',
   
   primary key (ID_PANNE_),
   key AK_ID_PANNE (ID_PANNE_),
   key IDX_PANNE_VEHICULE (ID_VEHICULE),
   key IDX_PANNE_STATUT (STATUT),
   key IDX_PANNE_DATE_DETECTION (DATE_DETECTION),
   key IDX_PANNE_CAUSE (ID_CAUSE),
   key IDX_PANNE_SEVERITE (ID_SEVERITE),
   key IDX_PANNE_COUT_TOTAL (COUT_TOTAL_CALCULE),
   key IDX_PANNE_VEHICULE_STATUT (ID_VEHICULE, STATUT),
   key IDX_PANNE_DATE_STATUT (DATE_DETECTION, STATUT)
) ENGINE=InnoDB COMMENT='Table des pannes avec traçabilité complète';

/*==============================================================*/
/* Tables de liaison et détails pour la traçabilité            */
/*==============================================================*/

/*==============================================================*/
/* Table : IMPACT_FINANCIER_ANOMALIE                            */
/*==============================================================*/
create table IMPACT_FINANCIER_ANOMALIE
(
   ID_IMPACT            int AUTO_INCREMENT not null,
   ID_PANNE             int not null,
   ID_TYPE_IMPACT       int not null,
   MONTANT              decimal(10,2) not null default 0,
   QUANTITE             decimal(8,2) default 1,
   PRIX_UNITAIRE        decimal(10,2) default 0,
   DESCRIPTION          text,
   JUSTIFICATION        text,
   FACTURE_NUMERO       varchar(50),
   DATE_IMPACT          date,
   VALIDE               boolean default false,
   VALIDE_PAR           varchar(50),
   DATE_VALIDATION      datetime,
   DATE_CREATION        timestamp default CURRENT_TIMESTAMP,
   primary key (ID_IMPACT)
) ENGINE=InnoDB COMMENT='Détail des impacts financiers par anomalie';

/*==============================================================*/
/* Table : ACTION_CORRECTIVE_APPLIQUEE                          */
/*==============================================================*/
create table ACTION_CORRECTIVE_APPLIQUEE
(
   ID_APPLICATION       int AUTO_INCREMENT not null,
   ID_PANNE             int not null,
   ID_ACTION            int not null,
   ID_TECHNICIEN        int,
   DATE_DEBUT           datetime,
   DATE_FIN             datetime,
   DUREE_REELLE         int comment 'Durée réelle en minutes',
   STATUT               enum('PLANIFIEE','EN_COURS','TERMINEE','ANNULEE') default 'PLANIFIEE',
   RESULTAT             enum('SUCCES','ECHEC','PARTIEL') default 'SUCCES',
   COMMENTAIRES         text,
   COUT_REEL            decimal(10,2) default 0,
   EFFICACITE           enum('TRES_FAIBLE','FAIBLE','MOYENNE','BONNE','EXCELLENTE'),
   DATE_CREATION        timestamp default CURRENT_TIMESTAMP,
   primary key (ID_APPLICATION)
) ENGINE=InnoDB COMMENT='Actions correctives appliquées par anomalie';

/*==============================================================*/
/* Table : PIECE_UTILISEE_ANOMALIE                              */
/*==============================================================*/
create table PIECE_UTILISEE_ANOMALIE
(
   ID_UTILISATION       int AUTO_INCREMENT not null,
   ID_PANNE             int not null,
   ID_PIECE             int not null,
   QUANTITE_UTILISEE    decimal(8,2) not null,
   PRIX_UNITAIRE_REEL   decimal(10,2),
   COUT_TOTAL           decimal(10,2) GENERATED ALWAYS AS (QUANTITE_UTILISEE * COALESCE(PRIX_UNITAIRE_REEL, 0)) STORED,
   NUMERO_LOT           varchar(50),
   DATE_UTILISATION     datetime default CURRENT_TIMESTAMP,
   FOURNISSEUR_REEL     varchar(100),
   GARANTIE_PIECE       boolean default false,
   DUREE_GARANTIE_MOIS  int,
   COMMENTAIRES         text,
   primary key (ID_UTILISATION)
) ENGINE=InnoDB COMMENT='Détail des pièces utilisées pour chaque anomalie';

/*==============================================================*/
/* Table : HISTORIQUE_STATUT_ANOMALIE                           */
/*==============================================================*/
create table HISTORIQUE_STATUT_ANOMALIE
(
   ID_HISTORIQUE        int AUTO_INCREMENT not null,
   ID_PANNE             int not null,
   ANCIEN_STATUT        varchar(20),
   NOUVEAU_STATUT       varchar(20) not null,
   DATE_CHANGEMENT      timestamp default CURRENT_TIMESTAMP,
   UTILISATEUR          varchar(50),
   COMMENTAIRE          text,
   DUREE_STATUT_PRECEDENT int comment 'Durée en minutes dans le statut précédent',
   primary key (ID_HISTORIQUE)
) ENGINE=InnoDB COMMENT='Historique des changements de statut';

/*==============================================================*/
/* Tables de liaison existantes (conservées pour compatibilité) */
/*==============================================================*/

/*==============================================================*/
/* Table : INTERROMPRE                                          */
/*==============================================================*/
create table INTERROMPRE
(
   ID_PANNE_            int,
   ID_TRAJET            int,
   NBRE_PANNE           varchar(255)
);

/*==============================================================*/
/* Table : ETRE_UTISEE                                          */
/*==============================================================*/
create table ETRE_UTISEE
(
   ID_ENTRETIEN         int,
   ID_PIECE             int,
   NBRE_PIECE           varchar(255)
);

/*==============================================================*/
/* Table : FAIRE                                                */
/*==============================================================*/
create table FAIRE
(
   ID_ENTRETIEN         int,
   ID_TECHNICIEN        int,
   NBRE_TECHNICIEN_     varchar(255)
);

/*==============================================================*/
/* Contraintes de clés étrangères                               */
/*==============================================================*/

-- Contraintes pour les tables principales
alter table VEHICULE add constraint FK_APPARTENIR foreign key (ID_CAT)
      references CATEGORIE (ID_CAT) on delete restrict on update restrict;

alter table VEHICULE add constraint FK_ATTRIBUER2 foreign key (ID_COND)
      references CONDUCTEUR (ID_COND) on delete restrict on update restrict;

alter table VEHICULE add constraint FK_REPARTIR foreign key (ID_SITE, ADRESSE)
      references SITE (ID_SITE, ADRESSE) on delete restrict on update restrict;

alter table TRAJET add constraint FK_DEPLACER foreign key (ID_VEHICULE)
      references VEHICULE (ID_VEHICULE) on delete restrict on update restrict;

alter table TRAJET add constraint FK_EFFECTUER foreign key (ID_COND)
      references CONDUCTEUR (ID_COND) on delete restrict on update restrict;

alter table CONTRAT add constraint FK_CONCERNER foreign key (ID_VEHICULE)
      references VEHICULE (ID_VEHICULE) on delete restrict on update restrict;

alter table ENTRETIEN add constraint FK_INTERVENIR foreign key (ID_FOURNISSEUR)
      references FOURNISSEUR (ID_FOURNISSEUR) on delete restrict on update restrict;

-- Contraintes pour la table PANNE (traçabilité)
alter table PANNE add constraint FK_PANNE_VEHICULE foreign key (ID_VEHICULE)
      references VEHICULE (ID_VEHICULE) on delete restrict on update restrict;

alter table PANNE add constraint FK_PANNE_CAUSE foreign key (ID_CAUSE)
      references CAUSE_ANOMALIE (ID_CAUSE) on delete restrict on update restrict;

alter table PANNE add constraint FK_PANNE_SEVERITE foreign key (ID_SEVERITE)
      references SEVERITE_ANOMALIE (ID_SEVERITE) on delete restrict on update restrict;

alter table PANNE add constraint FK_PANNE_TECHNICIEN_DIAG foreign key (ID_TECHNICIEN_DIAGNOSTIC)
      references TECHNICIEN (ID_TECHNICIEN) on delete set null on update restrict;

alter table PANNE add constraint FK_PANNE_TECHNICIEN_REPARATION foreign key (ID_TECHNICIEN_REPARATION)
      references TECHNICIEN (ID_TECHNICIEN) on delete set null on update restrict;

alter table PANNE add constraint FK_PANNE_PRECEDENTE foreign key (ID_PANNE_PRECEDENTE)
      references PANNE (ID_PANNE_) on delete set null on update restrict;

-- Contraintes pour les tables de traçabilité
alter table IMPACT_FINANCIER_ANOMALIE add constraint FK_IMPACT_PANNE foreign key (ID_PANNE)
      references PANNE (ID_PANNE_) on delete cascade on update restrict;

alter table IMPACT_FINANCIER_ANOMALIE add constraint FK_IMPACT_TYPE foreign key (ID_TYPE_IMPACT)
      references TYPE_IMPACT_FINANCIER (ID_TYPE_IMPACT) on delete restrict on update restrict;

alter table ACTION_CORRECTIVE_APPLIQUEE add constraint FK_ACTION_APPLIQUEE_PANNE foreign key (ID_PANNE)
      references PANNE (ID_PANNE_) on delete cascade on update restrict;

alter table ACTION_CORRECTIVE_APPLIQUEE add constraint FK_ACTION_APPLIQUEE_ACTION foreign key (ID_ACTION)
      references ACTION_CORRECTIVE (ID_ACTION) on delete restrict on update restrict;

alter table ACTION_CORRECTIVE_APPLIQUEE add constraint FK_ACTION_APPLIQUEE_TECHNICIEN foreign key (ID_TECHNICIEN)
      references TECHNICIEN (ID_TECHNICIEN) on delete set null on update restrict;

alter table PIECE_UTILISEE_ANOMALIE add constraint FK_PIECE_UTILISEE_PANNE foreign key (ID_PANNE)
      references PANNE (ID_PANNE_) on delete cascade on update restrict;

alter table PIECE_UTILISEE_ANOMALIE add constraint FK_PIECE_UTILISEE_PIECE foreign key (ID_PIECE)
      references PIECE (ID_PIECE) on delete restrict on update restrict;

alter table HISTORIQUE_STATUT_ANOMALIE add constraint FK_HISTORIQUE_PANNE foreign key (ID_PANNE)
      references PANNE (ID_PANNE_) on delete cascade on update restrict;

-- Contraintes pour les tables de liaison existantes (conservées)
alter table INTERROMPRE add constraint FK_INTERROMPRE foreign key (ID_TRAJET)
      references TRAJET (ID_TRAJET) on delete restrict on update restrict;

alter table INTERROMPRE add constraint FK_INTERROMPRE2 foreign key (ID_PANNE_)
      references PANNE (ID_PANNE_) on delete restrict on update restrict;

alter table ETRE_UTISEE add constraint FK_ETRE_UTISEE foreign key (ID_ENTRETIEN)
      references ENTRETIEN (ID_ENTRETIEN) on delete restrict on update restrict;

alter table ETRE_UTISEE add constraint FK_ETRE_UTISEE2 foreign key (ID_PIECE)
      references PIECE (ID_PIECE) on delete restrict on update restrict;

alter table FAIRE add constraint FK_FAIRE foreign key (ID_TECHNICIEN)
      references TECHNICIEN (ID_TECHNICIEN) on delete restrict on update restrict;

alter table FAIRE add constraint FK_FAIRE2 foreign key (ID_ENTRETIEN)
      references ENTRETIEN (ID_ENTRETIEN) on delete restrict on update restrict;

/*==============================================================*/
/* Données de référence pour la traçabilité                    */
/*==============================================================*/

-- Insertion des causes d'anomalies
INSERT INTO CAUSE_ANOMALIE (CODE, LIBELLE, DESCRIPTION, NIVEAU_GRAVITE, PREVENTABLE) VALUES
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
INSERT INTO SEVERITE_ANOMALIE (CODE, LIBELLE, DESCRIPTION, IMPACT_OPERATIONNEL, DUREE_MAX_RESOLUTION, PRIORITE) VALUES
('MINEURE', 'Impact mineur', 'Anomalie sans impact sur l''utilisation', 'AUCUN', 168, 4),
('FAIBLE', 'Impact faible', 'Gêne mineure, véhicule utilisable', 'FAIBLE', 72, 3),
('MOYENNE', 'Impact moyen', 'Limitation d''usage, intervention nécessaire', 'MOYEN', 48, 3),
('MAJEURE', 'Impact majeur', 'Usage fortement limité, intervention urgente', 'FORT', 24, 2),
('CRITIQUE', 'Impact critique', 'Véhicule inutilisable, arrêt immédiat', 'BLOQUANT', 8, 1),
('SECURITE', 'Problème de sécurité', 'Risque pour la sécurité des personnes', 'BLOQUANT', 4, 1);

-- Insertion des types d'impacts financiers
INSERT INTO TYPE_IMPACT_FINANCIER (CODE, LIBELLE, DESCRIPTION, CALCUL_AUTOMATIQUE) VALUES
('PIECES', 'Coût des pièces', 'Coût des pièces de rechange utilisées', TRUE),
('MAIN_OEUVRE', 'Main d''œuvre', 'Coût de la main d''œuvre de réparation', FALSE),
('IMMOBILISATION', 'Immobilisation', 'Coût d''immobilisation du véhicule', FALSE),
('SOUS_TRAITANCE', 'Sous-traitance', 'Coût de sous-traitance externe', FALSE),
('TRANSPORT', 'Transport', 'Coût de transport/remorquage', FALSE),
('VEHICULE_REMPLACEMENT', 'Véhicule de remplacement', 'Coût de location d''un véhicule de remplacement', FALSE),
('PERTE_EXPLOITATION', 'Perte d''exploitation', 'Manque à gagner lié à l''indisponibilité', FALSE),
('FRANCHISE_ASSURANCE', 'Franchise assurance', 'Franchise à la charge de l''entreprise', FALSE);

-- Insertion des actions correctives de base
INSERT INTO ACTION_CORRECTIVE (CODE, LIBELLE, DESCRIPTION, TYPE_ACTION, DUREE_ESTIMEE, COUT_MOYEN) VALUES
('REMPLACEMENT_PIECE', 'Remplacement de pièce', 'Remplacement d''une pièce défectueuse', 'CORRECTIVE', 2, 150.00),
('REPARATION', 'Réparation', 'Réparation d''un composant', 'CORRECTIVE', 4, 200.00),
('MAINTENANCE_PREVENTIVE', 'Maintenance préventive', 'Maintenance préventive renforcée', 'PREVENTIVE', 3, 100.00),
('DIAGNOSTIC_APPROFONDI', 'Diagnostic approfondi', 'Diagnostic technique détaillé', 'CORRECTIVE', 2, 80.00),
('FORMATION_CONDUCTEUR', 'Formation conducteur', 'Formation à l''utilisation correcte', 'PREVENTIVE', 4, 50.00),
('MODIFICATION_TECHNIQUE', 'Modification technique', 'Modification ou amélioration technique', 'PREVENTIVE', 8, 500.00);

/*==============================================================*/
/* Vues pour faciliter l'exploitation                          */
/*==============================================================*/

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

/*==============================================================*/
/* FIN DU SCRIPT - VERSION 2.0 AVEC TRAÇABILITÉ COMPLÈTE      */
/*==============================================================*/