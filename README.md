![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# Revision des valeurs locatives des locaux professionnels (RVLLP)


Ensemble des éléments constituant la mise en oeuvre de la base de données relative à la RVLLP :

- Script d'initialisation de la base de données
  * [Script d'initialisation de la base de données métier postgis](bdd/init_bd_fisc_rvllp.sql)
- [Documentation d'administration de la base de données](bdd/doc_admin_bd_fisc_rvllp.md)

## Contexte

Dans le cadre de la révision des valeurs locatives (VL) des locaux professionnels (LP) qui déterminent les bases fiscales de la taxe foncière, la collectivité avait pour besoin de :
- faire état de la situation avant la réforme des VL
- la proposition de l'Etat
- simuler les possibilités offertes à la collectivité pour la guider dans ces choix.

3 paramètres rentrent en jeu dans le calcul de la valeur locative révisée brute :
- la surface pondérée du LP
- le bareme tarifaire (en fonction de la catégorie du LP et du niveau de secteur)
- le coefficient de localisation

NB : la valeur locative révisée nette est obtenue par diverses mesures de lissage transitoires et temporaires définies par l'Etat (neutralisation, planchonnement ...)

La collectivité peut agir directement sur 2 leviers :
- la sectorisation : le choix du niveau de secteur (de 1 à 4) pouvant s'appliquer à la totalité de la commune ou à la section cadastrale communale dans certains cas (ex : Compiègne et Margny)
- le coefficient de localisation : mesures locales de minoration ou majoration prisent à l'échelle parcellaire pour des considérations territoriales (ex : proximtié axe de circulation majeur, centralité ...)

Par ailleurs, la collectivité pouvait de façon indirecte, recommander d'autre VL par catégorie. Cette approche a été étayée à l'appui d'un recueil de loyers pratiqués (propriétaires/locataires/marchant immo de LP).
