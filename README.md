![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# Revision des valeurs locatives des locaux professionnels (RVLLP)


Ensemble des éléments constituant la mise en oeuvre de la base de données relative à la RVLLP :

- Script d'initialisation de la base de données
  * [Script d'initialisation de la base de données métier postgis](bdd/init_bd_fisc_rvllp.sql)
- [Documentation d'administration de la base de données](bdd/doc_admin_bd_fisc_rvllp.md)

## Contexte

Dans le cadre de la révision des valeurs locatives (VL) des locaux professionnels (LP) qui déterminent les bases fiscales de la taxe foncière, la collectivité avait pour besoin, de faire état de la situation avant la réforme des VL, de la proposition de l'Etat et de simuler les possibilités offertes à la collectivité pour la guider dans ces choix.

3 paramètres rentrent en jeu dans le calcul de la valeur locative révisée brute :
- la surface pondérée du LP
- le bareme tarifaire selon la catégorie du LP et selon le niveau de secteur
- le coefficient de localisation

NB : la valeur locative révisée nette est obtenue par diverses mesures temporaires (délai?) de lissage de l'Etat (neutralisation, planchonnement ...) et sans aucune maitrise de la collectivité

La collectivité peut agir directement sur 2 leviers :
- la sectorisation : le choix du niveau de secteur (4) pouvant s'appliquer à la totalité de la commune ou à la section cadastrale communale dans certains cas (ex : Compiègne et Margny)
- le coefficient de localisation : mesures locales de minoration ou majoration prisent à l'échelle parcellaire pour des considérations territoriales (ex : proximtié axe de circulation majeur, centralité ...)

Par ailleurs, la collectivité pouvait de façon indirecte, recommandée d'autre VL par catégorie. Cette approche a été engagée en s'appuyant sur un recueil d'information auprès des propriétaires professionnels 
