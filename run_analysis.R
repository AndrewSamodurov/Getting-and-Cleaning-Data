## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

## read labels and features
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[, 2]
features <- read.table("./UCI HAR Dataset/features.txt")[, 2]

## only features with mean and std
mean_stdev <- grepl("mean|std", features)

## read test data
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

## names for features fields
names(X_test) <- features

## subsetting exectly need data
X_test <- X_test[, mean_stdev]

## adding colomn for labels
y_test[, 2] <- activity_labels[y_test[,1]]

## names for Activity colomns and Subject
names(y_test) <- c("ID", "Activity_Label")
names(subject_test) <- c("Subject")

## binding in test dataframe
test <- cbind(subject_test, y_test, X_test)

## read train data
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

## names for features fields
names(X_train) <- features

## subsetting exectly need data
X_train <- X_train[, mean_stdev]

## adding colomn for labels
y_train[, 2] <- activity_labels[y_train[,1]]

## names for Activity colomns and Subject
names(y_train) <- c("ID", "Activity_Label")
names(subject_train) <- c("Subject")

## binding in test dataframe
train <- cbind(subject_train, y_train, X_train)

## binding data
data <- rbind(test, train)

## subsetting labels
data_labels <- setdiff(colnames(data), c("Subject", "ID", "Activity_Label"))

## melting dataset
melt_data <- melt(data, id = c("Subject", "ID", "Activity_Label"), measure.vars = data_labels)

## apply mean function of each variable for each activity and each subject
tidy_data <- dcast(melt_data, Subject + Activity_Label ~ variable, mean)

## write data into file
write.table(tidy_data, file = "./tidy_data.txt", row.names = F)