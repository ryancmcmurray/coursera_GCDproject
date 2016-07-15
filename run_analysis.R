# You should create one R script called run_analysis.R that does the following:

# 1 Merges the training and the test sets to create one data set.
# 2 Extracts only the measurements on the mean and standard deviation for each measurement.
# 3 Uses descriptive activity names to name the activities in the data set
# 4 Appropriately labels the data set with descriptive variable names.
# 5 From the data set in step 4, creates a second, independent tidy data set with the average 
#   of each variable for each activity and each subject.

# Load necessary packages

library(reshape2)

# Download and unzip the file

if(!file.exists("GCD4data")) {dir.create("GCD4data")} else {
  print("Updating data files")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile="GCD4data\\GCD4data.zip")
unzip(zipfile="GCD4data\\GCD4data.zip", exdir="GCD4data")


# set wd to folder containing data

setwd("GCD4data\\UCI HAR Dataset")

# Read the data from the files

features          <- read.table("features.txt")
activity_labels   <- read.table("activity_labels.txt")
training_data     <- read.table("train/X_train.txt")
training_labels   <- read.table("train/y_train.txt")
training_subject  <- read.table("train/subject_train.txt")
test_data         <- read.table("test/X_test.txt")
test_labels       <- read.table("test/y_test.txt")
test_subject      <- read.table("test/subject_test.txt")

# Set WD back to original WD

setwd("..")
setwd("..")

# Combine each test/training pair

data           <- rbind(training_data, test_data)
activities     <- rbind(training_labels, test_labels)
subjects       <- rbind(training_subject, test_subject)

# Set column names

names(data)         <- features$V2
names(activities)   <- c("activity")
names(subjects)     <- c("subject")

# Take only the mean and std data of "data"

data <- data[,grep("mean\\(\\)|std\\(\\)", features$V2, value = TRUE)]

# Rename the variables so that they make a little sense

names(data)<-gsub("^t", "time", names(data))
names(data)<-gsub("^f", "frequency", names(data))
names(data)<-gsub("Acc", "Accelerometer", names(data))
names(data)<-gsub("Gyro", "Gyroscope", names(data))
names(data)<-gsub("Mag", "Magnitude", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))
names(data)<-gsub("\\.", "", names(data))

# Replace activity codes with corresponding character strings

activities[,1] <- activity_labels[activities[,1], 2]

# Combine the sets

merged_data <- cbind(subjects, activities, data)

# Melt the data to make a tall, skinny set, with only 1 observation per subject/activity combo

melted_data <- melt(merged_data, id=c("subject", "activity"))

# Create a tidy set containing one observation (the mean) for each subject/activity/variable combo. 

mean_data <- dcast(melted_data, subject + activity ~ variable, mean)

# Write out a file for the new set

write.table(mean_data, file="tidy_data.txt")


