# Cargar librerías necesarias al proyecto
library(tidyverse)

# 1. Merges the training and the test sets to create one data set.
car <- read.table("UCI HAR Dataset/features.txt", 
                  col.names = c("n", "funciones"))
act <- read.table("UCI HAR Dataset/activity_labels.txt",
                  col.names = c("codigo", "actividad"))


# 1.1. Test section
te1 <- read.table("UCI HAR Dataset/test/y_test.txt", 
                   col.names = "codigo")
te2 <- read.table("UCI HAR Dataset/test/X_test.txt", 
                  col.names = car$funciones)
te3 <- read.table("UCI HAR Dataset/test/subject_test.txt", 
                  col.names = "sujeto")

# 1.2. Training section
tr1 <- read.table("UCI HAR Dataset/train/y_train.txt", 
                  col.names = "codigo")
tr2 <- read.table("UCI HAR Dataset/train/X_train.txt", 
                  col.names = car$funciones)
tr3 <- read.table("UCI HAR Dataset/train/subject_train.txt",
                  col.names = "sujeto")

X <- rbind(tr2, te2)
Y <- rbind(te1, tr1)
sujeto <- rbind(tr3, te3)
all <- cbind(sujeto, Y, X)


# 2. Extracts only the measurements on the mean and standard deviation
# for each measurement.
mean_std <- all %>%
        select(sujeto, codigo, contains("mean"), contains("std"))

# 3. Uses descriptive activity names to name the activities in the data set
mean_std$codigo <- act[mean_std$codigo, 2]

# 4. Appropriately labels the data set with descriptive variable names.
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

# 5. From the data set in step 4, creates a second, independent
# tidy data set with the average of each variable for each
# activity and each subject.
avg_act_sub <- mean_std %>%
        group_by(sujeto, actividad) %>%
        summarise_all(funs(mean))

write.table(avg_act_sub, "avg_act_sub.txt", row.name = FALSE)