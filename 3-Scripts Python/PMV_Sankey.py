# Le but du code est d'afficher un graphique du type "Sankey"
# Pour fonctionner le programme a besoin d'une liste (cpStart, coEnd) nombre de déplacements
# Cette liste est générée par le programme PMV_BIXI-StartEndKey.py

import plotly as py
import plotly.graph_objs as go

def loadDataFile(filename):
    # initialisation
    resultCPStart = []
    resultCPEnd = []
    resultCount = []

    #charger fichier
    fichier = open(filename)

    # lire le contenu du fichier (toutes les lignes
    lignes = fichier.readlines()

    # fermer le fichier
    fichier.close()

    ligneIter = iter(lignes)

    # Traiter chaque enregistrement du fichier
    for ligne in ligneIter:

        # Extraire la clé de la valeur
        rec = ligne.strip().split("\t")
        key = rec[0]
        val = int(rec[1])

        # Extraire le code postal de depart du code postal d'arrivée (dans la clé)
        keySplit = key.replace("[", "").replace("]","").replace('"','').split(",")
        cpStart = keySplit[0].strip()
        cpEnd = keySplit[1].strip()

        # Faire les ajouts
        if (cpStart != cpEnd):
            resultCount.append(val)
            resultCPStart.append(cpStart)
            resultCPEnd.append(cpEnd)


    return resultCPStart, resultCPEnd, resultCount



def test2(cpStartList, cpEndList, valList):

    src = []
    tgt = []

    # Constuire une liste de noeuds distincts pour le depart et l'arrivée
    startSet = set(cpStartList)
    startList = list(startSet)
    endSet = set(cpEndList)
    endList = list(endSet)

    # Construire la liste des noeuds (Depart + arrivée)
    myNewList =  startList + endList

    # taille de set de depart (Point de depart pour les noeuds à l'arrivée)
    lgStart = 0
    for item in startList:     # Trouver la fonction qui fait le compte
        lgStart += 1

    # Constreuire la source (index des noeuds)
    for itemStart in cpStartList:
        src.append(startList.index(itemStart))

    # Constreuire la destination (index des noeuds)
    for itemEnd in cpEndList:
        tgt.append(endList.index(itemEnd) + lgStart )

    print (myNewList)
    print ("SRC",src)
    print("TGT",tgt)

    data = dict(
        type='sankey',


        ############  NODE
        node = dict(
          pad = 15,
          thickness = 20,
          line = dict(
         # color = "black",
          width = 0.5
          )
          ,label = myNewList
        ),

        #############  Liens entre les noeuds
        link = dict(
          source =  src,
          target =  tgt,
          value = valList
      ))

    layout =  dict(
        title = "PMV",
        font = dict(
          size = 10
        )
    )

    fig = dict(data=[data], layout=layout)
    py.offline.plot(fig, validate=False)

# Il faudrait passer un répertoire et traiter tous les fichiers du répertoire
lst1A, lst2A, lst3A =loadDataFile("c:/temp/part-00000")
lst1B, lst2B, lst3B =loadDataFile("c:/temp/part-00001")
lst1C, lst2C, lst3C =loadDataFile("c:/temp/part-00002")
lst1D, lst2D, lst3D =loadDataFile("c:/temp/part-00003")

lst1 = lst1A + lst1B + lst1C + lst1D
lst2 = lst2A + lst2B + lst2C + lst2D
lst3 = lst3A + lst3B + lst3C + lst3D

test2(lst1, lst2, lst3)