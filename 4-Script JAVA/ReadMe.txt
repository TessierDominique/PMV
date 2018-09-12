Fonction JAVA pour calculer la distance entre 2 points.
Le JAR généré sera utilisé avec Hive (Fonction UDF)

-- copier le jar dans HDFS 
hdfs dfs -copyFromLocal PMV.jar /user/hduser/PMV/PMV.jar'

-- Ajouter la fonction Java dans Hive
hive> create function Distance2 as 'com.bdeb.UDF.Distance2' using jar 'hdfs:/user/hduser/PMV/PMV.jar';

-- Ajouter dans cloudera
create function Distance2 as 'com.bdeb.UDF.Distance2' using jar 'hdfs:///user/cloudera/projetPMV/PMV.jar'; 

