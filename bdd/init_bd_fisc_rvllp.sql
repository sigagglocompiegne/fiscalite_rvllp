/*
Base de données sur la révision des valeurs locatives des locaux professionnels (RVLLP)
Creation du squelette de la structure (table, séquence, ...)
init_bd_fisc_rvllp.sql

GeoCompiegnois - http://geo.compiegnois.fr/
Auteur : Florent Vanhoutte
*/

-- 2022/09/07 : FV / initialisation du code (classe, test jointure pour vues, droits)
-- 2022/09/08 : FV / vues et champs calculés, ajout class coefloc
-- 2022/09/09 : FV / ajout attribut superficie pour les locaux
-- 2022/09/12 : FV / ajustement vue secteur_vl pour simuler les résultats de chaque niveau de secteur
-- 2022/09/20 : FV / ajout classe des locaux pro fiscalisé
-- 2022/09/20 : FV / ajout des index spatiaux + id
-- 2022/09/20 : FV / suppression vue des secteurs avec les VL de certains cat2 (ex : mag1)
-- 2022/09/20 : FV / adaptation des vues pour coefloc x1 hors des coefloc minoration et majoration et prise en compte dans les calculs
-- 2022/09/26 : FV / ajustement vue des locaux mixés avec secteur et zones de coef de localisation avec ajout d'un gid pour tenir compte des superpositions multiples et donc d'id local non unique
-- 2022/09/30 : FV / ajout d'une vue des parcelles impactées par une zone de coefficient de localisation
-- 2022/09/30 : FV / ajout d'un attribut geom1 (buffer négatif) sur la table de coefficient de localisation et l'index spatial
-- 2022/09/30 : FV / ajout d'un trigger de maj geom1 en cas insert ou update de la table coefficient de localisation
-- 2022/09/30 : FV / correction calcul de la valeur locative pondérée (collectivité finale)
-- 2022/10/06 : FV / correction commentaires erronés des tables an_fisc_vl21 et an_fisc_vl22
-- 2022/10/06 : FV / ajout classe sur la nouvelle grille de VL (an_fisc_vl23) et éléments liés (index, sequence, droits)
-- 2022/10/07 : FV / ajout d'un attribut geom1 (buffer négatif) sur la table des locaux d'activités fiscalisés (geo_fisc_locact), index spatial et trigger pour éviter les problèmes de bordures lors des jointures spatiales avec les secteurs
-- 2022/10/07 : FV / correction des vues pour la jointure local-secteur avec utilisation de la geom1 des locaux + conditions pour s'assurer d'être dans la meme commune (insee)
-- 2022/10/07 : FV / ajout calculs des bases locatives en fonction des différentes simulation de VL (sup_pond * VLxxx)
-- 2022/10/10 : FV / ajout d'un attribut geom1 (buffer négatif) sur la table des secteurs + index spatial + trigger
-- 2022/10/10 : FV / revision des jointures spatiales pour la vue des locaux d'actvités avec utilisation de la geom1 pour les secteurs et la geom pour les locaux
-- 2022/10/10 : FV / suppression atttibut geom1 et dépendances (index, trigger) pour les locaux d'activités


/*
ToDo :
- optimisation index
- définir si le changement de grille tarifaire vl22 et vl23 nécessite la création de nouvelles vues, le remplacement de la src actuelle des vues ou la restructuration des vues pour disposer des 2 infos
*/


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                      SUPPRESSION                                                             ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- vue
DROP VIEW IF EXISTS m_fiscalite.geo_v_fisc_refloyer_vl;
DROP VIEW IF EXISTS m_fiscalite.geo_v_fisc_localact_vl;
DROP VIEW IF EXISTS m_fiscalite.geo_v_fisc_secteur_vl;
DROP VIEW IF EXISTS m_fiscalite.geo_v_parcelle_coefloc;


-- classe
DROP TABLE IF EXISTS m_fiscalite.geo_fisc_refloyer;
DROP TABLE IF EXISTS m_fiscalite.geo_fisc_locact;
DROP TABLE IF EXISTS m_fiscalite.geo_fisc_coefloc;
DROP TABLE IF EXISTS m_fiscalite.geo_fisc_secteur;
DROP TABLE IF EXISTS m_fiscalite.an_fisc_vl21;
DROP TABLE IF EXISTS m_fiscalite.an_fisc_vl22;
DROP TABLE IF EXISTS m_fiscalite.an_fisc_vl23;

-- sequence
DROP SEQUENCE IF EXISTS m_fiscalite.idcoefloc_seq;
DROP SEQUENCE IF EXISTS m_fiscalite.idrefloyer_seq;
DROP SEQUENCE IF EXISTS m_fiscalite.idsecteur_seq;
DROP SEQUENCE IF EXISTS m_fiscalite.idvl21_seq;
DROP SEQUENCE IF EXISTS m_fiscalite.idvl22_seq;
DROP SEQUENCE IF EXISTS m_fiscalite.idvl23_seq;

-- #################################################################### SCHEMA  ####################################################################


-- Schema: m_fiscalite


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                     SEQUENCE                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- Sequence: m_fiscalite.idrefloyer_seq

-- DROP SEQUENCE m_fiscalite.idrefloyer_seq;

CREATE SEQUENCE m_fiscalite.idrefloyer_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
  
-- Sequence: m_fiscalite.idlocact_seq

-- DROP SEQUENCE m_fiscalite.idlocact_seq;

CREATE SEQUENCE m_fiscalite.idlocact_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
  
  
-- Sequence: m_fiscalite.idsecteur_seq

-- DROP SEQUENCE m_fiscalite.idsecteur_seq;

CREATE SEQUENCE m_fiscalite.idsecteur_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
  
-- Sequence: m_fiscalite.idcoefloc_seq

-- DROP SEQUENCE m_fiscalite.idcoefloc_seq;

CREATE SEQUENCE m_fiscalite.idcoefloc_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;    

-- Sequence: m_fiscalite.idvl21_seq

-- DROP SEQUENCE m_fiscalite.idvl21_seq;

CREATE SEQUENCE m_fiscalite.idvl21_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
  
-- Sequence: m_fiscalite.idvl22_seq

-- DROP SEQUENCE m_fiscalite.idvl22_seq;

CREATE SEQUENCE m_fiscalite.idvl22_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
  
-- Sequence: m_fiscalite.idvl23_seq

-- DROP SEQUENCE m_fiscalite.idvl23_seq;

CREATE SEQUENCE m_fiscalite.idvl23_seq
  INCREMENT 1
  MINVALUE 0
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;        


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                  CLASSE OBJET                                                                ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- ################################################################ CLASSE VL21 CAT2 ##############################################

-- Table: m_fiscalite.an_fisc_vl21

-- DROP TABLE m_fiscalite.an_fisc_vl21;

CREATE TABLE m_fiscalite.an_fisc_vl21
(
  idvl21 bigint NOT NULL,
  cat1 character varying(3),
  cat2 character varying(4),
  s21e character varying(1),
  vl21e numeric (6,2), 
 
  CONSTRAINT an_fisc_vl21_pkey PRIMARY KEY (idvl21)  
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_fiscalite.an_fisc_vl21
  IS 'Grille tarifaire des valeurs locatives 2021';
COMMENT ON COLUMN m_fiscalite.an_fisc_vl21.idvl21 IS 'Identifiant';
COMMENT ON COLUMN m_fiscalite.an_fisc_vl21.cat1 IS 'Catégorie niveau 1 du local d''activité';  
COMMENT ON COLUMN m_fiscalite.an_fisc_vl21.cat2 IS 'Catégorie niveau 2 du local d''activité';
COMMENT ON COLUMN m_fiscalite.an_fisc_vl21.s21e IS 'Niveau de secteur 21';
COMMENT ON COLUMN m_fiscalite.an_fisc_vl21.vl21e IS 'Valeur locative 21 € TTC / m2 / an';

ALTER TABLE m_fiscalite.an_fisc_vl21 ALTER COLUMN idvl21 SET DEFAULT nextval('m_fiscalite.idvl21_seq'::regclass);


-- ################################################################ CLASSE VL22 CAT2 ##############################################

-- Table: m_fiscalite.an_fisc_vl22

-- DROP TABLE m_fiscalite.an_fisc_vl22;

CREATE TABLE m_fiscalite.an_fisc_vl22
(
  idvl22 bigint NOT NULL,
  cat1 character varying(3),
  cat2 character varying(4),
  s22e character varying(1),
  vl22e numeric (6,2), 
 
  CONSTRAINT an_fisc_vl22_pkey PRIMARY KEY (idvl22)  
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_fiscalite.an_fisc_vl22
  IS 'Grille tarifaire des valeurs locatives 2022 (grille été 2022)';
COMMENT ON COLUMN m_fiscalite.an_fisc_vl22.idvl22 IS 'Identifiant';
COMMENT ON COLUMN m_fiscalite.an_fisc_vl22.cat1 IS 'Catégorie niveau 1 du local d''activité';  
COMMENT ON COLUMN m_fiscalite.an_fisc_vl22.cat2 IS 'Catégorie niveau 2 du local d''activité';
COMMENT ON COLUMN m_fiscalite.an_fisc_vl22.s22e IS 'Niveau de secteur 22 Etat';
COMMENT ON COLUMN m_fiscalite.an_fisc_vl22.vl22e IS 'Valeur locative 22 Etat € TTC / m2 / an';

ALTER TABLE m_fiscalite.an_fisc_vl22 ALTER COLUMN idvl22 SET DEFAULT nextval('m_fiscalite.idvl22_seq'::regclass);


-- ################################################################ CLASSE VL23 CAT2 ##############################################

-- Table: m_fiscalite.an_fisc_vl23

-- DROP TABLE m_fiscalite.an_fisc_vl23;

CREATE TABLE m_fiscalite.an_fisc_vl23
(
  idvl23 bigint NOT NULL,
  cat1 character varying(3),
  cat2 character varying(4),
  s23e character varying(1),
  vl23e numeric (6,2), 
 
  CONSTRAINT an_fisc_vl23_pkey PRIMARY KEY (idvl23)  
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_fiscalite.an_fisc_vl23
  IS 'Grille tarifaire des valeurs locatives 2023 (grille octobre 2022)';
COMMENT ON COLUMN m_fiscalite.an_fisc_vl23.idvl23 IS 'Identifiant';
COMMENT ON COLUMN m_fiscalite.an_fisc_vl23.cat1 IS 'Catégorie niveau 1 du local d''activité';  
COMMENT ON COLUMN m_fiscalite.an_fisc_vl23.cat2 IS 'Catégorie niveau 2 du local d''activité';
COMMENT ON COLUMN m_fiscalite.an_fisc_vl23.s23e IS 'Niveau de secteur 23 Etat';
COMMENT ON COLUMN m_fiscalite.an_fisc_vl23.vl23e IS 'Valeur locative 23 Etat € TTC / m2 / an';

ALTER TABLE m_fiscalite.an_fisc_vl23 ALTER COLUMN idvl23 SET DEFAULT nextval('m_fiscalite.idvl23_seq'::regclass);



-- ################################################################ CLASSE DE REFERENCE DE LOYERS DE LOCAUX D'ACTIVITES ##############################################

-- Table: m_fiscalite.geo_fisc_refloyer

-- DROP TABLE m_fiscalite.geo_fisc_refloyer;

CREATE TABLE m_fiscalite.geo_fisc_refloyer
(
  idrefloyer bigint NOT NULL,
  nom character varying(150),
  adresse character varying(80),
  bal character varying(150),
  complement character varying(150), 
  insee character varying(5) NOT NULL,
  commune character varying(30) NOT NULL,
  cat1 character varying(3) NOT NULL,
  cat2 character varying(4) NOT NULL,
  sup_m2 integer,
  loyer_m2 numeric (6,2), 
  observ character varying(254),
  source character varying(100),
  dbinsert timestamp without time zone NOT NULL DEFAULT now(),  
  dbupdate timestamp without time zone,
  geom geometry(Point,2154), 
 
  CONSTRAINT geo_fisc_refloyer_pkey PRIMARY KEY (idrefloyer)  
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_fiscalite.geo_fisc_refloyer
  IS 'Références de loyers de locaux d''activités géolocalisées à l''adresse';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.idrefloyer IS 'Identifiant de la référence de loyer';  
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.nom IS 'Nom du propriétaire, locataire ou du bâtiment selon la source';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.adresse IS 'Adresse source';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.bal IS 'Adresse BAL';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.complement IS 'Complément d''adressage';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.insee IS 'Code INSEE';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.commune IS 'Nom de la commune';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.cat1 IS 'Catégorie niveau 1 du local d''activité';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.cat2 IS 'Catégorie niveau 2 du local d''activité';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.sup_m2 IS 'Superficie du local d''activité m2';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.loyer_m2 IS 'Loyer € TTC / m2 / an';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.observ IS 'Observations';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.source IS 'Source de l''information';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_fiscalite.geo_fisc_refloyer.geom IS 'Géométrie ponctuelle de l''adresse du local d''activité';

ALTER TABLE m_fiscalite.geo_fisc_refloyer ALTER COLUMN idrefloyer SET DEFAULT nextval('m_fiscalite.idrefloyer_seq'::regclass);


-- ################################################################ CLASSE DE LOCAL D'ACTIVITE ##############################################

-- Table: m_fiscalite.geo_fisc_localact

-- DROP TABLE m_fiscalite.geo_fisc_localact;

CREATE TABLE m_fiscalite.geo_fisc_localact
(
  idlocact bigint NOT NULL,
  pro_nom character varying(150),
  pro_adress character varying(150),
  cadparcel character varying(14),
  loc_adress character varying(80), 
  insee character varying(5) NOT NULL,
  commune character varying(30) NOT NULL,
  cat1 character varying(3) NOT NULL,
  cat2 character varying(4) NOT NULL,
  sup_reel integer,
  sup_pond integer, 
  observ character varying(254),
  source character varying(100),
  dbinsert timestamp without time zone NOT NULL DEFAULT now(),  
  dbupdate timestamp without time zone,
  geom geometry(MultiPolygon,2154),
  geom1 geometry(MultiPolygon,2154),    
 
  CONSTRAINT geo_fisc_localact_pkey PRIMARY KEY (idlocact)  
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_fiscalite.geo_fisc_localact
  IS 'Locaux d''activités géolocalisés à la parcelle';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.idlocact IS 'Identifiant du local d''activité';  
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.pro_nom IS 'Nom du propriétaire du local';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.pro_adress IS 'Adresse du propriétaire du local';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.cadparcel IS 'Référence parcellaire du local';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.loc_adress IS 'Adresse déclarée du local';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.insee IS 'Code INSEE';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.commune IS 'Nom de la commune';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.cat1 IS 'Catégorie niveau 1 du local d''activité';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.cat2 IS 'Catégorie niveau 2 du local d''activité';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.sup_reel IS 'Superficie réelle du local d''activité m2';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.sup_pond IS 'Superficie pondérée du local d''activité m2';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.observ IS 'Observations';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.source IS 'Source de l''information';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.geom IS 'Géométrie surfacique de la parcelle du local d''activité';
COMMENT ON COLUMN m_fiscalite.geo_fisc_localact.geom1 IS 'Géométrie réduite pour jointure spatiale avec la table des secteurs de fiscalité';

ALTER TABLE m_fiscalite.geo_fisc_localact ALTER COLUMN idlocact SET DEFAULT nextval('m_fiscalite.idlocact_seq'::regclass);



-- ################################################################ CLASSE SECTEUR ##############################################

-- Table: m_fiscalite.geo_fisc_secteur

-- DROP TABLE m_fiscalite.geo_fisc_secteur;

CREATE TABLE m_fiscalite.geo_fisc_secteur
(
  idsecteur bigint NOT NULL,
  insee character varying(5) NOT NULL,
  commune character varying(30) NOT NULL,
  section character varying(2),
  cleinterop character varying(7),
  s21e character varying(1),
  s22e character varying(1),
  s22_1 character varying(1),
  s22_2 character varying(1),
  s22_3 character varying(1),
  s22_4 character varying(1),
  s22c character varying(1),
  s22cf character varying(1),
  observ character varying(254),
  dbinsert timestamp without time zone NOT NULL DEFAULT now(),  
  dbupdate timestamp without time zone,
  geom geometry(Polygon,2154), 
  geom1 geometry(Polygon,2154),
   
  CONSTRAINT geo_fisc_secteur_pkey PRIMARY KEY (idsecteur)  
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_fiscalite.geo_fisc_secteur
  IS 'Secteur de fiscalité des locaux d''activités';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.idsecteur IS 'Identifiant du secteur';  
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.insee IS 'Code INSEE';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.commune IS 'Nom de la commune';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.section IS 'Section cadastrale';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.cleinterop IS 'Clé d''identification de chaque zone INSEESECTION';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.s21e IS 'Niveau de secteur 2021 de l''Etat';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.s22e IS 'Niveau de secteur 2022 proposé par l''Etat';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.s22_1 IS 'Niveau 1 de secteur 2022';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.s22_1 IS 'Niveau 2 de secteur 2022';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.s22_1 IS 'Niveau 3 de secteur 2022';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.s22_1 IS 'Niveau 4 de secteur 2022';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.s22c IS 'Niveau de secteur 2022 initial proposé par la collectivité';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.s22cf IS 'Niveau de secteur 2022 final proposé par la collectivité';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.observ IS 'Observations';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.geom IS 'Géométrie du secteur de fiscalité des locaux d''activité';
COMMENT ON COLUMN m_fiscalite.geo_fisc_secteur.geom1 IS 'Géométrie réduite pour jointure spatiale avec d''autres classes geo';

ALTER TABLE m_fiscalite.geo_fisc_secteur ALTER COLUMN idsecteur SET DEFAULT nextval('m_fiscalite.idsecteur_seq'::regclass);


-- ################################################################ CLASSE COEFLOC ##############################################

-- Table: m_fiscalite.geo_fisc_coefloc

-- DROP TABLE m_fiscalite.geo_fisc_coefloc;

CREATE TABLE m_fiscalite.geo_fisc_coefloc
(
  idcoefloc bigint NOT NULL,
  valcoef numeric (3,2),
  observ character varying(254),
  dbinsert timestamp without time zone NOT NULL DEFAULT now(),  
  dbupdate timestamp without time zone,
  geom geometry(Polygon,2154),
  geom1 geometry(Polygon,2154),    
 
  CONSTRAINT geo_fisc_coefloc_pkey PRIMARY KEY (idcoefloc)  
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE m_fiscalite.geo_fisc_coefloc
  IS 'Secteur de fiscalité des locaux d''activités';
COMMENT ON COLUMN m_fiscalite.geo_fisc_coefloc.idcoefloc IS 'Identifiant du local d''activité';  
COMMENT ON COLUMN m_fiscalite.geo_fisc_coefloc.valcoef IS 'Valeur du coefficient de localisation';
COMMENT ON COLUMN m_fiscalite.geo_fisc_coefloc.observ IS 'Observations';
COMMENT ON COLUMN m_fiscalite.geo_fisc_coefloc.dbinsert IS 'Horodatage de l''intégration en base de l''objet';
COMMENT ON COLUMN m_fiscalite.geo_fisc_coefloc.dbupdate IS 'Horodatage de la mise à jour en base de l''objet';
COMMENT ON COLUMN m_fiscalite.geo_fisc_coefloc.geom IS 'Géométrie du coefficient de localisation de la fiscalité des locaux d''activité';
COMMENT ON COLUMN m_fiscalite.geo_fisc_coefloc.geom IS 'Géométrie réduite pour jointure spatiale avec la table des parcelles du cadastre';

ALTER TABLE m_fiscalite.geo_fisc_coefloc ALTER COLUMN idcoefloc SET DEFAULT nextval('m_fiscalite.idcoefloc_seq'::regclass);


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                       INDEX                                                                  ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- ################################################################ CLASSE VL21 CAT2 ##############################################

-- Index: an_fisc_vl21_idvl21_idx

-- DROP INDEX m_fiscalite.an_fisc_vl21_idcoefloc_idx;

CREATE INDEX an_fisc_vl21_idvl21_idx
    ON m_fiscalite.an_fisc_vl21 USING btree (idvl21);
    
-- Index: an_fisc_vl21_cat2_idx

-- DROP INDEX m_fiscalite.an_fisc_vl21_cat2_idx;

CREATE INDEX an_fisc_vl21_cat2_idx
    ON m_fiscalite.an_fisc_vl21 USING btree (cat2);


-- ################################################################ CLASSE VL22 CAT2 ##############################################

-- Index: an_fisc_vl22_idvl22_idx

-- DROP INDEX m_fiscalite.an_fisc_vl22_idcoefloc_idx;

CREATE INDEX an_fisc_vl22_idvl22_idx
    ON m_fiscalite.an_fisc_vl22 USING btree (idvl22);
    
-- Index: an_fisc_vl22_cat2_idx

-- DROP INDEX m_fiscalite.an_fisc_vl22_cat2_idx;

CREATE INDEX an_fisc_vl22_cat2_idx
    ON m_fiscalite.an_fisc_vl22 USING btree (cat2);


-- ################################################################ CLASSE VL23 CAT2 ##############################################
    
-- Index: an_fisc_vl23_idvl23_idx

-- DROP INDEX m_fiscalite.an_fisc_vl23_idcoefloc_idx;

CREATE INDEX an_fisc_vl23_idvl23_idx
    ON m_fiscalite.an_fisc_vl23 USING btree (idvl23);
    
-- Index: an_fisc_vl23_cat2_idx

-- DROP INDEX m_fiscalite.an_fisc_vl23_cat2_idx;

CREATE INDEX an_fisc_vl23_cat2_idx
    ON m_fiscalite.an_fisc_vl23 USING btree (cat2);



-- ################################################################ CLASSE SECTEUR ##############################################

-- Index: geo_fisc_secteur_geom_idx

-- DROP INDEX m_fiscalite.geo_fisc_secteur_geom_idx;

CREATE INDEX geo_fisc_secteur_geom_idx
    ON m_fiscalite.geo_fisc_secteur USING gist (geom);
    
-- Index: geo_fisc_secteur_geom1_idx

-- DROP INDEX m_fiscalite.geo_fisc_secteur_geom1_idx;

CREATE INDEX geo_fisc_secteur_geom1_idx
    ON m_fiscalite.geo_fisc_secteur USING gist (geom1);    

-- Index: geo_fisc_secteur_idsecteur_idx

-- DROP INDEX m_fiscalite.geo_fisc_secteur_idsecteur_idx;

CREATE INDEX geo_fisc_secteur_idsecteur_idx
    ON m_fiscalite.geo_fisc_secteur USING btree (idsecteur);
    
-- Index: geo_fisc_secteur_insee_idx

-- DROP INDEX m_fiscalite.geo_fisc_secteur_insee_idx;

CREATE INDEX geo_fisc_secteur_insee_idx
    ON m_fiscalite.geo_fisc_secteur USING btree (insee);    


-- ################################################################ CLASSE DE LOCAL D'ACTIVITE ##############################################

-- Index: geo_fisc_localact_geom_idx

-- DROP INDEX m_fiscalite.geo_fisc_localact_geom_idx;

CREATE INDEX geo_fisc_localact_geom_idx
    ON m_fiscalite.geo_fisc_localact USING gist (geom);
    

-- Index: geo_fisc_localact_idlocact_idx

-- DROP INDEX m_fiscalite.geo_fisc_localact_idlocact_idx;

CREATE INDEX geo_fisc_localact_idlocact_idx
    ON m_fiscalite.geo_fisc_localact USING btree (idlocact);
    

-- Index: geo_fisc_localact_insee_idx

-- DROP INDEX m_fiscalite.geo_fisc_localact_insee_idx;

CREATE INDEX geo_fisc_localact_insee_idx
    ON m_fiscalite.geo_fisc_localact USING btree (insee);     



-- ################################################################ CLASSE DE REFERENCE DE LOYERS DE LOCAUX D'ACTIVITES ##############################################

-- Index: geo_fisc_refloyer_geom_idx

-- DROP INDEX m_fiscalite.geo_fisc_refloyer_geom_idx;

CREATE INDEX geo_fisc_refloyer_geom_idx
    ON m_fiscalite.geo_fisc_refloyer USING gist (geom);
    

-- Index: geo_fisc_refloyer_idrefloyer_idx

-- DROP INDEX m_fiscalite.geo_fisc_refloyer_idrefloyer_idx;

CREATE INDEX geo_fisc_refloyer_idrefloyer_idx
    ON m_fiscalite.geo_fisc_refloyer USING btree (idrefloyer);


-- ################################################################ CLASSE COEFLOC ##############################################

-- Index: geo_fisc_coefloc_geom_idx

-- DROP INDEX m_fiscalite.geo_fisc_coefloc_geom_idx;

CREATE INDEX geo_fisc_coefloc_geom_idx
    ON m_fiscalite.geo_fisc_coefloc USING gist (geom);
    
-- Index: geo_fisc_coefloc_geom1_idx

-- DROP INDEX m_fiscalite.geo_fisc_coefloc_geom1_idx;

CREATE INDEX geo_fisc_coefloc_geom1_idx
    ON m_fiscalite.geo_fisc_coefloc USING gist (geom1);

-- Index: geo_fisc_coefloc_idcoefloc_idx

-- DROP INDEX m_fiscalite.geo_fisc_coefloc_idcoefloc_idx;

CREATE INDEX geo_fisc_coefloc_idcoefloc_idx
    ON m_fiscalite.geo_fisc_coefloc USING btree (idcoefloc);



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        VUES                                                                  ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################



-- #################################################################### VUE SECTEUR VL ###############################################
        
-- View: m_fiscalite.geo_v_fisc_secteur_vl

-- DROP VIEW m_fiscalite.geo_v_fisc_secteur_vl;

CREATE VIEW m_fiscalite.geo_v_fisc_secteur_vl AS 
 SELECT 
  concat(s.idsecteur::text, v.cat2) AS idcat2sect,
  s.idsecteur,
  s.insee,
  s.commune,
  s.section,
  s.cleinterop,
  v.cat2,
  s.s21e,
  v.vl21e,
  s.s22e,
  w.vl22e,
  round(((w.vl22e-v.vl21e)/v.vl21e * 100),2) AS evl22e21e,
  s.s22_1,
  a.vl22e AS vl22_1,
  s.s22_2,
  b.vl22e AS vl22_2,  
  s.s22_3,
  c.vl22e AS vl22_3,  
  s.s22_4,
  d.vl22e AS vl22_4,        
  s.s22c,
  z.vl22e AS vl22c, 
  round(((z.vl22e-v.vl21e)/v.vl21e * 100),2) AS evl22c21e,
  s.s22cf,
  zf.vl22e as vl22cf,
  round(((y.vl22e-v.vl21e)/v.vl21e * 100),2) AS evl22cf21e,      
  s.observ,
  s.geom,
  s.geom1
  
FROM m_fiscalite.geo_fisc_secteur s
LEFT JOIN m_fiscalite.an_fisc_vl21 v ON v.s21e = s.s21e
LEFT JOIN m_fiscalite.an_fisc_vl22 w ON w.s22e = s.s22e AND w.cat2 = v.cat2
LEFT JOIN m_fiscalite.an_fisc_vl22 a ON a.s22e = s.s22_1 AND a.cat2 = v.cat2
LEFT JOIN m_fiscalite.an_fisc_vl22 b ON b.s22e = s.s22_2 AND b.cat2 = v.cat2
LEFT JOIN m_fiscalite.an_fisc_vl22 c ON c.s22e = s.s22_3 AND c.cat2 = v.cat2
LEFT JOIN m_fiscalite.an_fisc_vl22 d ON d.s22e = s.s22_4 AND d.cat2 = v.cat2
LEFT JOIN m_fiscalite.an_fisc_vl22 z ON z.s22e = s.s22c AND z.cat2 = v.cat2
LEFT JOIN m_fiscalite.an_fisc_vl22 y ON y.s22e = s.s22cf AND y.cat2 = v.cat2
LEFT JOIN m_fiscalite.an_fisc_vl22 zf ON zf.s22e = s.s22cf AND zf.cat2 = v.cat2;


COMMENT ON VIEW m_fiscalite.geo_v_fisc_secteur_vl
  IS 'Croisement des VL par catégorie au secteur de fiscalité des locaux d''activités';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.idsecteur IS 'Identifiant de secteur';  
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.insee IS 'Code INSEE';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.commune IS 'Nom de la commune';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.section IS 'Section cadastrale';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.cleinterop IS 'Clé d''identification de chaque zone INSEESECTION';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.cat2 IS 'Catégorie niveau 2 du local d''activité';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.s21e IS 'Niveau de secteur 2021 de l''Etat';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.vl21e IS 'Valeur locative 2021 de l''Etat';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.s22e IS 'Niveau de secteur 2022 proposé par l''Etat';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.vl22e IS 'Valeur locative 2022 (Etat)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.evl22e21e IS 'Evolution de la valeur locative 2021-2022 (Etat)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.s22_1 IS 'Niveau 1 de secteur 2022';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.vl22_1 IS 'Valeur locative 2022 de niveau 1 (Etat)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.s22_2 IS 'Niveau 2 de secteur 2022';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.vl22_2 IS 'Valeur locative 2022 de niveau 2 (Etat)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.s22_3 IS 'Niveau 3 de secteur 2022';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.vl22_3 IS 'Valeur locative 2022 de niveau 3 (Etat)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.s22_4 IS 'Niveau 4 de secteur 2022';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.vl22_4 IS 'Valeur locative 2022 de niveau 4 (Etat)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.s22c IS 'Niveau de secteur 2022 initial proposé par la collectivité';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.vl22c IS 'Valeur locative 2022 (Collectivité - initial)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.evl22c21e IS 'Evolution de la valeur locative 2021-2022 (Collectivité - initial)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.s22cf IS 'Niveau de secteur 2022 final proposé par la collectivité';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.vl22cf IS 'Valeur locative 2022 (Collectivité - final)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.evl22cf21e IS 'Evolution de la valeur locative 2021-2022 (Collectivité - final)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.observ IS 'Observations';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.geom IS 'Géométrie du secteur de fiscalité des locaux d''activité';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_secteur_vl.geom1 IS 'Géométrie réduite pour jointure spatiale avec d''autres classes geo';



-- #################################################################### VUE REF LOYER VL ###############################################
        
-- View: m_fiscalite.geo_v_fisc_refloyer_vl

-- DROP VIEW m_fiscalite.geo_v_fisc_refloyer_vl;

CREATE VIEW m_fiscalite.geo_v_fisc_refloyer_vl AS 
 SELECT 
  l.idrefloyer,
  l.nom,
  l.adresse,
  l.bal,
  l.complement,
  l.insee,
  l.commune,
  s.section,
  l.cat1,
  l.cat2,
  l.sup_m2,
  s.s21e,
  s.s22e,
  s.s22c,
  s.s22cf,
  s.vl21e,
  s.vl22e,
  s.vl22c,
  s.vl22cf,
  CASE WHEN p.valcoef IS NULL THEN 1::numeric ELSE p.valcoef END AS valcoef,
  round((s.vl22c * (CASE WHEN p.valcoef IS NULL THEN 1::numeric ELSE p.valcoef END)),2) AS vl22cp,
  l.loyer_m2,
  s.evl22e21e,
  s.evl22c21e,
  s.evl22cf21e,  
  round((((s.vl22cf * (CASE WHEN p.valcoef IS NULL THEN 1::numeric ELSE p.valcoef END))-s.vl21e)/s.vl21e * 100),2) AS evl22cfp21e,
  l.observ,
  l.source,
  l.geom
  
FROM m_fiscalite.geo_fisc_refloyer l
LEFT JOIN m_fiscalite.geo_v_fisc_secteur_vl s ON s.cat2 = l.cat2 AND st_intersects(l.geom, s.geom) IS TRUE AND l.insee = s.insee
LEFT JOIN m_fiscalite.geo_fisc_coefloc p ON st_intersects(l.geom, p.geom) IS TRUE;


COMMENT ON VIEW m_fiscalite.geo_v_fisc_refloyer_vl
  IS 'Comparaison entre les VL projetées par rapport à des références de loyers de locaux d''activités géolocalisées à l''adresse';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.idrefloyer IS 'Identifiant de la référence de loyer';  
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.nom IS 'Nom du propriétaire, locataire ou du bâtiment selon la source';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.adresse IS 'Adresse source';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.bal IS 'Adresse BAL';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.complement IS 'Complément d''adressage';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.insee IS 'Code INSEE';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.commune IS 'Nom de la commune';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.section IS 'Section cadastrale';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.cat1 IS 'Catégorie niveau 1 du local d''activité';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.cat2 IS 'Catégorie niveau 2 du local d''activité';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.sup_m2 IS 'Superficie du local d''activité m2';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.s21e IS 'Niveau de secteur 2021 de l''Etat';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.s22e IS 'Niveau de secteur 2022 proposé par l''Etat';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.s22c IS 'Niveau de secteur 2022 initial proposé par la collectivité';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.s22cf IS 'Niveau de secteur 2022 final proposé par la collectivité';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.vl21e IS 'Valeur locative 2021 de l''Etat';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.vl22e IS 'Valeur locative 2022 (Etat)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.vl22c IS 'Valeur locative 2022 (Collectivité - initial)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.vl22cf IS 'Valeur locative 2022 (Collectivité - final)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.valcoef IS 'Valeur du coefficient de localisation (Collectivité)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.vl22cp IS 'Valeur locative 2022 pondérée (Collectivité - final)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.loyer_m2 IS 'Loyer € TTC / m2 / an';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.evl22e21e IS 'Evolution de la valeur locative 2021-2022 (Etat)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.evl22c21e IS 'Evolution de la valeur locative 2021-2022 (Collectivité - initial)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.evl22cf21e IS 'Evolution de la valeur locative 2021-2022 (Collectivité - final)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.evl22cfp21e IS 'Evolution de la valeur locative pondérée 2021-2022 (Collectivité - final)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.observ IS 'Observations';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.source IS 'Source de l''information';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_refloyer_vl.geom IS 'Géométrie ponctuelle de l''adresse du local d''activité';



-- #################################################################### VUE LOCAL ACT VL ###############################################
        
-- View: m_fiscalite.geo_v_fisc_localact_vl

-- DROP VIEW m_fiscalite.geo_v_fisc_localact_vl;

CREATE VIEW m_fiscalite.geo_v_fisc_localact_vl AS 
 SELECT 
  row_number() OVER () AS gid,
  l.idlocact,
  l.pro_nom,
  l.pro_adress,
  l.cadparcel,
  l.loc_adress,
  l.insee,
  l.commune,
  s.section,
  l.cat1,
  l.cat2,
  l.sup_reel,
  l.sup_pond,
  s.s21e,
  s.s22e,
  s.s22c,
  s.s22cf,
  s.vl21e,
  s.vl22e,
  s.vl22c,
  s.vl22cf,
  CASE WHEN p.valcoef IS NULL THEN 1::numeric ELSE p.valcoef END AS valcoef,
  round((s.vl22cf * (CASE WHEN p.valcoef IS NULL THEN 1::numeric ELSE p.valcoef END)),2) AS vl22cfp,
  l.sup_pond * s.vl21e as base21e,
  l.sup_pond * s.vl22e as base22e,
  l.sup_pond * s.vl22cf as base22cf,
  l.sup_pond * (round((s.vl22cf * (CASE WHEN p.valcoef IS NULL THEN 1::numeric ELSE p.valcoef END)),2)) as base22cfp,
  s.evl22e21e,
  s.evl22c21e,
  s.evl22cf21e,  
  round((((s.vl22cf * (CASE WHEN p.valcoef IS NULL THEN 1::numeric ELSE p.valcoef END))-s.vl21e)/s.vl21e * 100),2) AS evl22cfp21e,
  l.observ,
  l.source,
  l.geom
  
FROM m_fiscalite.geo_fisc_localact l
LEFT JOIN m_fiscalite.geo_v_fisc_secteur_vl s ON s.cat2 = l.cat2 AND st_intersects(l.geom, s.geom1) IS TRUE AND l.insee = s.insee
LEFT JOIN m_fiscalite.geo_fisc_coefloc p ON st_intersects(l.geom, p.geom1) IS TRUE ;


COMMENT ON VIEW m_fiscalite.geo_v_fisc_localact_vl
  IS 'Simulation de l''impact de la sectorisation et des coefficients de localisation sur la fiscalité des locaux d''activités géolocalisés à la parcelle';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.gid IS 'Identifiant unique de la vue';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.idlocact IS 'Identifiant du local d''activité';  
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.pro_nom IS 'Nom du propriétaire du local';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.pro_adress IS 'Adresse du propriétaire du local';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.cadparcel IS 'Référence parcellaire du local';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.loc_adress IS 'Adresse déclarée du local';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.insee IS 'Code INSEE';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.commune IS 'Nom de la commune';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.section IS 'Section cadastrale';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.cat1 IS 'Catégorie niveau 1 du local d''activité';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.cat2 IS 'Catégorie niveau 2 du local d''activité';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.sup_reel IS 'Superficie réelle du local d''activité m2';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.sup_pond IS 'Superficie pondérée du local d''activité m2';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.s21e IS 'Niveau de secteur 2021 de l''Etat';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.s22e IS 'Niveau de secteur 2022 proposé par l''Etat';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.s22c IS 'Niveau de secteur 2022 initial proposé par la collectivité';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.s22cf IS 'Niveau de secteur 2022 final proposé par la collectivité';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.vl21e IS 'Valeur locative 2021 de l''Etat';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.vl22e IS 'Valeur locative 2022 (Etat)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.vl22c IS 'Valeur locative 2022 (Collectivité - initial)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.vl22cf IS 'Valeur locative 2022 (Collectivité - final)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.valcoef IS 'Valeur du coefficient de localisation (Collectivité)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.vl22cfp IS 'Valeur locative 2022 pondérée (Collectivité - final)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.base21e IS 'Base locative 2021 de l''Etat';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.base22e IS 'Base locative 2022 (Etat)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.base22cf IS 'Base locative 2022 (Collectivité - final)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.base22cfp IS 'Base locative 2022 pondérée (Collectivité - final)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.evl22e21e IS 'Evolution de la valeur locative 2021-2022 (Etat)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.evl22c21e IS 'Evolution de la valeur locative 2021-2022 (Collectivité - initial)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.evl22cf21e IS 'Evolution de la valeur locative 2021-2022 (Collectivité - final)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.evl22cfp21e IS 'Evolution de la valeur locative pondérée 2021-2022 (Collectivité - final)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.observ IS 'Observations';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.source IS 'Source de l''information';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_localact_vl.geom IS 'Géométrie surfacique de la parcelle du local d''activité';


-- #################################################################### VUE PARCELLE COEF LOC ###############################################
        
-- View: m_fiscalite.geo_v_fisc_parcelle_coefloc

-- DROP VIEW m_fiscalite.geo_v_fisc_parcelle_coefloc;

CREATE VIEW m_fiscalite.geo_v_fisc_parcelle_coefloc AS 
 SELECT 
  row_number() OVER () AS gid,
  p.geo_parcelle as refcad,
  p.insee,
  p.commune,
  right(p.geo_section,2) as section,
  right(p.geo_parcelle,4) as parcelle,
  c.valcoef,
  c.observ,
  p.geom
  
FROM m_fiscalite.geo_fisc_coefloc c
LEFT JOIN r_cadastre.geo_parcelle p ON st_intersects(c.geom1, p.geom) IS TRUE WHERE p.lot = 'arc';


COMMENT ON VIEW m_fiscalite.geo_v_fisc_parcelle_coefloc
  IS 'Parcelles concernées par les zones de coefficient de localisation de la RVLLP';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_parcelle_coefloc.gid IS 'Identifiant unique de la vue';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_parcelle_coefloc.refcad IS 'Référence cadastrale';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_parcelle_coefloc.insee IS 'Code INSEE';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_parcelle_coefloc.commune IS 'Nom de la commune';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_parcelle_coefloc.section IS 'Section';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_parcelle_coefloc.parcelle IS 'Parcelle';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_parcelle_coefloc.valcoef IS 'Valeur du coefficient de localisation (Collectivité)';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_parcelle_coefloc.observ IS 'Observations';
COMMENT ON COLUMN m_fiscalite.geo_v_fisc_parcelle_coefloc.geom IS 'Géométrie surfacique de la parcelle affectée par un coefficient de localisation';


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                      TRIGGER                                                                 ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- #################################################################### FONCTION TRIGGER - GEO_FISC_LOCALACT #############################################

-- Function: m_fiscalite.ft_geo_fisc_secteur()

-- DROP FUNCTION m_fiscalite.ft_geo_fisc_secteur();

CREATE OR REPLACE FUNCTION m_fiscalite.ft_geo_fisc_secteur()
  RETURNS trigger AS
$BODY$

BEGIN

-- INSERT
IF (TG_OP = 'INSERT') THEN

NEW.geom1 = st_buffer (NEW.geom,-1);

RETURN NEW;

-- UPDATE
ELSIF (TG_OP = 'UPDATE') THEN

NEW.geom1 = st_buffer (NEW.geom,-1);
 
RETURN NEW;

END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

COMMENT ON FUNCTION m_fiscalite.ft_geo_fisc_secteur() IS 'Fonction trigger pour insert ou update du buffer négatif des polygones de secteurs de VLLP';


-- Trigger: t_geo_fisc_secteur ON m_fiscalite.geo_fisc_secteur

-- DROP TRIGGER t_geo_fisc_secteur ON m_fiscalite.geo_fisc_secteur;

CREATE TRIGGER t_geo_fisc_secteur
  BEFORE INSERT OR UPDATE
  ON m_fiscalite.geo_fisc_secteur
  FOR EACH ROW
  EXECUTE PROCEDURE m_fiscalite.ft_geo_fisc_secteur();


-- #################################################################### FONCTION TRIGGER - GEO_FISC_COEFLOC #############################################

-- Function: m_fiscalite.ft_geo_fisc_coefloc()

-- DROP FUNCTION m_fiscalite.ft_geo_fisc_coefloc();

CREATE OR REPLACE FUNCTION m_fiscalite.ft_geo_fisc_coefloc()
  RETURNS trigger AS
$BODY$

BEGIN

-- INSERT
IF (TG_OP = 'INSERT') THEN

NEW.geom1 = st_multi(st_buffer (NEW.geom,-1));

RETURN NEW;

-- UPDATE
ELSIF (TG_OP = 'UPDATE') THEN

NEW.geom1 = st_multi(st_buffer (NEW.geom,-1));
 
RETURN NEW;

END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

COMMENT ON FUNCTION m_fiscalite.ft_geo_fisc_coefloc() IS 'Fonction trigger pour insert ou update du buffer négatif des polygones de coefficient de localisation';


-- Trigger: t_geo_fisc_coefloc ON m_fiscalite.geo_fisc_coefloc

-- DROP TRIGGER t_geo_fisc_coefloc ON m_fiscalite.geo_fisc_coefloc;

CREATE TRIGGER t_geo_fisc_coefloc
  BEFORE INSERT OR UPDATE
  ON m_fiscalite.geo_fisc_coefloc
  FOR EACH ROW
  EXECUTE PROCEDURE m_fiscalite.ft_geo_fisc_coefloc();


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                        DROITS                                                                ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


ALTER TABLE m_fiscalite.geo_fisc_refloyer
  OWNER TO sig_create;
GRANT ALL ON TABLE m_fiscalite.geo_fisc_refloyer TO sig_create;
GRANT SELECT ON TABLE m_fiscalite.geo_fisc_refloyer TO sig_read;
GRANT ALL ON TABLE m_fiscalite.geo_fisc_refloyer TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_fiscalite.geo_fisc_refloyer TO sig_edit;

ALTER TABLE m_fiscalite.geo_fisc_localact
  OWNER TO sig_create;
GRANT ALL ON TABLE m_fiscalite.geo_fisc_localact TO sig_create;
GRANT SELECT ON TABLE m_fiscalite.geo_fisc_localact TO sig_read;
GRANT ALL ON TABLE m_fiscalite.geo_fisc_localact TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_fiscalite.geo_fisc_localact TO sig_edit;

ALTER TABLE m_fiscalite.geo_fisc_secteur
  OWNER TO sig_create;
GRANT ALL ON TABLE m_fiscalite.geo_fisc_secteur TO sig_create;
GRANT SELECT ON TABLE m_fiscalite.geo_fisc_secteur TO sig_read;
GRANT ALL ON TABLE m_fiscalite.geo_fisc_secteur TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_fiscalite.geo_fisc_secteur TO sig_edit;

ALTER TABLE m_fiscalite.geo_fisc_coefloc
  OWNER TO sig_create;
GRANT ALL ON TABLE m_fiscalite.geo_fisc_coefloc TO sig_create;
GRANT SELECT ON TABLE m_fiscalite.geo_fisc_coefloc TO sig_read;
GRANT ALL ON TABLE m_fiscalite.geo_fisc_coefloc TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_fiscalite.geo_fisc_coefloc TO sig_edit;

ALTER TABLE m_fiscalite.an_fisc_vl21
  OWNER TO sig_create;
GRANT ALL ON TABLE m_fiscalite.an_fisc_vl21 TO sig_create;
GRANT SELECT ON TABLE m_fiscalite.an_fisc_vl21 TO sig_read;
GRANT ALL ON TABLE m_fiscalite.an_fisc_vl21 TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_fiscalite.an_fisc_vl21 TO sig_edit;

ALTER TABLE m_fiscalite.an_fisc_vl22
  OWNER TO sig_create;
GRANT ALL ON TABLE m_fiscalite.an_fisc_vl22 TO sig_create;
GRANT SELECT ON TABLE m_fiscalite.an_fisc_vl22 TO sig_read;
GRANT ALL ON TABLE m_fiscalite.an_fisc_vl22 TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_fiscalite.an_fisc_vl22 TO sig_edit;

ALTER TABLE m_fiscalite.an_fisc_vl23
  OWNER TO sig_create;
GRANT ALL ON TABLE m_fiscalite.an_fisc_vl23 TO sig_create;
GRANT SELECT ON TABLE m_fiscalite.an_fisc_vl23 TO sig_read;
GRANT ALL ON TABLE m_fiscalite.an_fisc_vl23 TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_fiscalite.an_fisc_vl23 TO sig_edit;

ALTER VIEW m_fiscalite.geo_v_fisc_secteur_vl
  OWNER TO sig_create;
GRANT ALL ON TABLE m_fiscalite.geo_v_fisc_secteur_vl TO sig_create;
GRANT SELECT ON TABLE m_fiscalite.geo_v_fisc_secteur_vl TO sig_read;
GRANT ALL ON TABLE m_fiscalite.geo_v_fisc_secteur_vl TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_fiscalite.geo_v_fisc_secteur_vl TO sig_edit;

ALTER VIEW m_fiscalite.geo_v_fisc_refloyer_vl
  OWNER TO sig_create;
GRANT ALL ON TABLE m_fiscalite.geo_v_fisc_refloyer_vl TO sig_create;
GRANT SELECT ON TABLE m_fiscalite.geo_v_fisc_refloyer_vl TO sig_read;
GRANT ALL ON TABLE m_fiscalite.geo_v_fisc_refloyer_vl TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_fiscalite.geo_v_fisc_refloyer_vl TO sig_edit;

ALTER VIEW m_fiscalite.geo_v_fisc_localact_vl
  OWNER TO sig_create;
GRANT ALL ON TABLE m_fiscalite.geo_v_fisc_localact_vl TO sig_create;
GRANT SELECT ON TABLE m_fiscalite.geo_v_fisc_localact_vl TO sig_read;
GRANT ALL ON TABLE m_fiscalite.geo_v_fisc_localact_vl TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_fiscalite.geo_v_fisc_localact_vl TO sig_edit;

ALTER VIEW m_fiscalite.geo_v_fisc_parcelle_coefloc
  OWNER TO sig_create;
GRANT ALL ON TABLE m_fiscalite.geo_v_fisc_parcelle_coefloc TO sig_create;
GRANT SELECT ON TABLE m_fiscalite.geo_v_fisc_parcelle_coefloc TO sig_read;
GRANT ALL ON TABLE m_fiscalite.geo_v_fisc_parcelle_coefloc TO create_sig;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE m_fiscalite.geo_v_fisc_parcelle_coefloc TO sig_edit;
