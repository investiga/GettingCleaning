El script run_analysis.R prepara los datos y mediante 5 pasos retorna una matriz ordenada con el promedio de cada variable para cada actividad y cada sujeto.

1. Descarga de archivos desde:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

En este caso el descargue se hizo a través de página web y el archivo se ubicó en la carpeta de trabajo del proyecto en R.

2. Se carga la libreria tidyverse necesaria para la ejecución del script.
library(tidyverse)

3. Se pasa a importar y combinar las tablas del proyecto y formar con ellas una sola tabla.

car <- read.table("UCI HAR Dataset/features.txt", col.names = c("n", "funciones"))
act <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("codigo", "actividad"))

3.1. Seccción de test 
te1 <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "codigo")
te2 <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = car$funciones) 
te3 <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "sujeto")

3.2. Sección de entrenamiento
tr1 <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "codigo")
tr2 <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = car$funciones) 
tr3 <- read.table("UCI HAR Dataset/train/subject_train.txt", 
               col.names = "sujeto")

3.2. Combinación de las tablas
X <- rbind(tr2, te2)
Y <- rbind(te1, tr1)
sujeto <- rbind(tr3, te3)
all <- cbind(sujeto, Y, X)


4. Luego se extraen la media y la desviación estándar para cada medida.
mean_std <- all %>% 
  select(sujeto, codigo, contains("mean"), contains("std"))

5. Se nombran las actividades por extenso usando sus nombres descriptivos.
mean_std$codigo <- act[mean_std$codigo, 2]

6. Se colocan los rótulos apropiados con las variables descriptivas.
names(mean_std)[2] = "actividad"
names(mean_std)<-gsub("Acc", "Accelerometer", names(mean_std))
names(mean_std)<-gsub("Gyro", "Gyroscope", names(mean_std))
names(mean_std)<-gsub("BodyBody", "Body", names(mean_std))
names(mean_std)<-gsub("Mag", "Magnitude", names(mean_std))
names(mean_std)<-gsub("^t", "Time", names(mean_std))
names(mean_std)<-gsub("^f", "Frequency", names(mean_std))
names(mean_std)<-gsub("tBody", "TimeBody", names(mean_std))
names(mean_std)<-gsub("-mean()", "Mean", names(mean_std), ignore.case = TRUE)
names(mean_std)<-gsub("-std()", "STD", names(mean_std), ignore.case = TRUE)
names(mean_std)<-gsub("-freq()", "Frequency", names(mean_std), ignore.case = TRUE)
names(mean_std)<-gsub("angle", "Angle", names(mean_std))
names(mean_std)<-gsub("gravity", "Gravity", names(mean_std))

7. A partir de la tabla creada en el paso anterior, se genera una segunda tabla independiente y ordenada con el promedio de cada variable por actividad y sujeto.
avg_act_sub <- mean_std %>%
  group_by(sujeto, actividad) %>%
  summarise_all(funs(mean))

7.1 Tabla exportar finalmente (avg_act_sub.txt):
write.table(avg_act_sub, "avg_act_sub.txt", row.name=FALSE)