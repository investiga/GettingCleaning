# Cargar librerías necesarias al proyecto
library(tidyverse)

# 0. Descargar el archivo para la realización del análisis. 

if(!file.exists("./data")){dir.create("./data")}
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              destfile="./data/Dataset.zip")
unzip(zipfile="./data/Dataset.zip",exdir="./data")

# 1. Combinar los datos de "training" y "test" y unirlos en una sola tabla.
car <- read.table("./data/UCI HAR Dataset/features.txt", 
                  col.names = c("n", "funciones"))
act <- read.table("./data/UCI HAR Dataset/activity_labels.txt",
                  col.names = c("codigo", "actividad"))


# 1.1. Sección datos "test"
te1 <- read.table("./data/UCI HAR Dataset/test/y_test.txt", 
                   col.names = "codigo")
te2 <- read.table("./data/UCI HAR Dataset/test/X_test.txt", 
                  col.names = car$funciones)
te3 <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", 
                  col.names = "sujeto")

# 1.2. Sección datos "training"
tr1 <- read.table("./data/UCI HAR Dataset/train/y_train.txt", 
                  col.names = "codigo")
tr2 <- read.table("./data/UCI HAR Dataset/train/X_train.txt", 
                  col.names = car$funciones)
tr3 <- read.table("./data/UCI HAR Dataset/train/subject_train.txt",
                  col.names = "sujeto")

# 1.3. Unión de las tablas en "all"
X <- rbind(tr2, te2)
Y <- rbind(te1, tr1)
sujeto <- rbind(tr3, te3)
all <- cbind(sujeto, Y, X)


# 2. Extracción de promedio y desviación estándar en todas las mediciones.
mean_std <- all %>%
        select(sujeto, codigo, contains("mean"), contains("std"))

# 3. Colocar nombres descriptivos para las actividades de los datos 
# seleccionados
mean_std$codigo <- act[mean_std$codigo, 2]

# 4. Colocar los nombres apropiados a las variables para su mejor 
# reconocimiento.
names(mean_std)[2] = "actividad"
names(mean_std) <- gsub("Acc", "Accelerometer", names(mean_std))
names(mean_std) <- gsub("Gyro", "Gyroscope", names(mean_std))
names(mean_std) <- gsub("BodyBody", "Body", names(mean_std))
names(mean_std) <- gsub("Mag", "Magnitude", names(mean_std))
names(mean_std) <- gsub("^t", "Time", names(mean_std))
names(mean_std) <- gsub("^f", "Frequency", names(mean_std))
names(mean_std) <- gsub("tBody", "TimeBody", names(mean_std))
names(mean_std) <-
        gsub("-mean()", "Mean", names(mean_std), ignore.case = TRUE)
names(mean_std) <-
        gsub("-std()", "STD", names(mean_std), ignore.case = TRUE)
names(mean_std) <-
        gsub("-freq()", "Frequency", names(mean_std), ignore.case = TRUE)
names(mean_std) <- gsub("angle", "Angle", names(mean_std))
names(mean_std) <- gsub("gravity", "Gravity", names(mean_std))

# 5. A continuación se crea una tabla nueva con las transformaciones
# hechas en el paso anterios.Se recuperan los valores promedio de cada 
# variable por actividad y sujeto.
avg_act_sub <- mean_std %>%
        group_by(sujeto, actividad) %>%
        summarise_all(funs(mean))

write.table(avg_act_sub, "avg_act_sub.txt", row.name = FALSE)
avg_act_sub
