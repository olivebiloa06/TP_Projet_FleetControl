/*==============================================================*/
/* Nom de SGBD :  MySQL 5.0                                     */
/* Date de création :  07/11/2025 13:55:41                      */
/*==============================================================*/


drop table if exists CATEGORIE;

drop table if exists CONDUCTEUR;

drop table if exists CONTRAT;

drop table if exists ENTRETIEN;

drop table if exists ETRE_UTISEE;

drop table if exists FAIRE;

drop table if exists FOURNISSEUR;

drop table if exists INTERROMPRE;

drop table if exists PANNE;

drop table if exists PIECE;

drop table if exists SITE;

drop table if exists TECHNICIEN;

drop table if exists TRAJET;

drop table if exists VEHICULE;

/*==============================================================*/
/* Table : CATEGORIE                                            */
/*==============================================================*/
create table CATEGORIE
(
   ID_CAT               int AUTO_INCREMENT not null,
   ID_VEHICULE          int,
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
   ID_VEHICULE          int,
   NOM                  varchar(255),
   PRENOM               varchar(255),
   PERMIS               varchar(30),
   TELEPHONE            varchar(10),
   primary key (ID_COND),
   key AK_ID_COND (ID_COND)
);

/*==============================================================*/
/* Table : CONTRAT                                              */
/*==============================================================*/
create table CONTRAT
(
   ID_CONTRAT           int AUTO_INCREMENT  not null,
   ID_VEHICULE          int,
   TYPE                 varchar(255),
   DATE_DEBUT           date,
   DATE_FIN             date,
   primary key (ID_CONTRAT),
   key AK_ID_CONTRAT (ID_CONTRAT)
);

/*==============================================================*/
/* Table : ENTRETIEN                                            */
/*==============================================================*/
create table ENTRETIEN
(
   ID_ENTRETIEN         int AUTO_INCREMENT  not null,
   ID_FOURNISSEUR       char(10),
   TYPE                 varchar(255),
   DATE                 date,
   KM                   double,
   primary key (ID_ENTRETIEN),
   key AK_ID_ENTRETIEN (ID_ENTRETIEN)
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
/* Table : FOURNISSEUR                                          */
/*==============================================================*/
create table FOURNISSEUR
(
   ID_FOURNISSEUR       int AUTO_INCREMENT  not null,
   NOM                  varchar(255),
   TELEPHONE_           varchar(10),
   primary key (ID_FOURNISSEUR),
   key AK_ID_FOURNISSEUR (ID_FOURNISSEUR)
);

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
/* Table : PANNE                                                */
/*==============================================================*/
create table PANNE
(
   ID_PANNE_            int AUTO_INCREMENT  not null,
   DESCRIPTION          varchar(255),
   DATE                 date,
   COUT                 double,
   primary key (ID_PANNE_),
   key AK_ID_PANNE (ID_PANNE_)
);

/*==============================================================*/
/* Table : PIECE                                                */
/*==============================================================*/
create table PIECE
(
   ID_PIECE             int AUTO_INCREMENT  not null,
   NOM                  varchar(255),
   PRIX_UNITAIRE        int,
   QTE                  bigint,
   primary key (ID_PIECE),
   key AK_ID_PIECE (ID_PIECE)
);

/*==============================================================*/
/* Table : SITE                                                 */
/*==============================================================*/
create table SITE
(
   ID_SITE              int AUTO_INCREMENT  not null,
   NOM                  varchar(255),
   ADRESSE              varchar(255) not null,
   primary key (ID_SITE, ADRESSE),
   key AK_ID_SITE (ID_SITE)
);

/*==============================================================*/
/* Table : TECHNICIEN                                           */
/*==============================================================*/
create table TECHNICIEN
(
   ID_TECHNICIEN        int AUTO_INCREMENT  not null,
   NOM                  varchar(255),
   SPECIALITE           varchar(255),
   primary key (ID_TECHNICIEN),
   key AK_ID_TECHNICIEN (ID_TECHNICIEN)
);

/*==============================================================*/
/* Table : TRAJET                                               */
/*==============================================================*/
create table TRAJET
(
   ID_COND              int,
   ID_TRAJET            int AUTO_INCREMENT  not null,
   ID_VEHICULE          int,
   DATE_DEBUT           date,
   DATE_FIN             date,
   DESTINATION          varchar(255),
   COUT                 double,
   primary key (ID_TRAJET),
   key AK_ID_TRAJET (ID_TRAJET)
);

/*==============================================================*/
/* Table : VEHICULE                                             */
/*==============================================================*/
create table VEHICULE
(
   ID_CAT               varchar(10),
   ID_COND              int,
   ID_SITE              int,
   ADRESSE              char(10),
   ID_VEHICULE          int AUTO_INCREMENT not null,
   IMMATRICULATION      varchar(255),
   DATE_ACHAT           date,
   KM                   double,
   STATUT               varchar(255),
   primary key (ID_VEHICULE),
   key AK_ID_VEHICULE (ID_VEHICULE)
);

alter table CATEGORIE add constraint FK_APPARTENIR foreign key (ID_VEHICULE)
      references VEHICULE (ID_VEHICULE) on delete restrict on update restrict;

alter table CONDUCTEUR add constraint FK_ATTRIBUER foreign key (ID_VEHICULE)
      references VEHICULE (ID_VEHICULE) on delete restrict on update restrict;

alter table CONTRAT add constraint FK_CONCERNER foreign key (ID_VEHICULE)
      references VEHICULE (ID_VEHICULE) on delete restrict on update restrict;

alter table ENTRETIEN add constraint FK_INTERVENIR foreign key (ID_FOURNISSEUR)
      references FOURNISSEUR (ID_FOURNISSEUR) on delete restrict on update restrict;

alter table ETRE_UTISEE add constraint FK_ETRE_UTISEE foreign key (ID_ENTRETIEN)
      references ENTRETIEN (ID_ENTRETIEN) on delete restrict on update restrict;

alter table ETRE_UTISEE add constraint FK_ETRE_UTISEE2 foreign key (ID_PIECE)
      references PIECE (ID_PIECE) on delete restrict on update restrict;

alter table FAIRE add constraint FK_FAIRE foreign key (ID_TECHNICIEN)
      references TECHNICIEN (ID_TECHNICIEN) on delete restrict on update restrict;

alter table FAIRE add constraint FK_FAIRE2 foreign key (ID_ENTRETIEN)
      references ENTRETIEN (ID_ENTRETIEN) on delete restrict on update restrict;

alter table INTERROMPRE add constraint FK_INTERROMPRE foreign key (ID_TRAJET)
      references TRAJET (ID_TRAJET) on delete restrict on update restrict;

alter table INTERROMPRE add constraint FK_INTERROMPRE2 foreign key (ID_PANNE_)
      references PANNE (ID_PANNE_) on delete restrict on update restrict;

alter table TRAJET add constraint FK_DEPLACER foreign key (ID_VEHICULE)
      references VEHICULE (ID_VEHICULE) on delete restrict on update restrict;

alter table TRAJET add constraint FK_EFFECTUER foreign key (ID_COND)
      references CONDUCTEUR (ID_COND) on delete restrict on update restrict;

alter table VEHICULE add constraint FK_APPARTENIR2 foreign key (ID_CAT)
      references CATEGORIE (ID_CAT) on delete restrict on update restrict;

alter table VEHICULE add constraint FK_ATTRIBUER2 foreign key (ID_COND)
      references CONDUCTEUR (ID_COND) on delete restrict on update restrict;

alter table VEHICULE add constraint FK_REPARTIR foreign key (ID_SITE, ADRESSE)
      references SITE (ID_SITE, ADRESSE) on delete restrict on update restrict;

