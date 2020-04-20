library(data.table)
library(dplyr)



# Load activity labels + features
activityLabels <- read.table("./R/UCI HAR Dataset/activity_labels.txt")

features <- read.table("./R/UCI HAR Dataset/features.txt")


# Extracts only the measurements on the mean and standard deviation for each measurement. 
indexFeaturesWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[indexFeaturesWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[()-]', '', featuresWanted.names)


# Load the datasets
train <- read.table("./R/UCI HAR Dataset/train/X_train.txt")[indexFeaturesWanted]
trainActivities <- read.table("./R/UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("./R/UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("./R/UCI HAR Dataset/test/X_test.txt")[indexFeaturesWanted]
testActivities <- read.table("./R/UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("./R/UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Merges the training and the test sets to create one data set.
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWanted.names)

# Uses descriptive activity names to name the activities in the data set
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)
# Appropriately labels the data set with descriptive variable names. 
allData.melted <- melt(allData, id = c("subject", "activity"))
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "./R/UCI HAR Dataset/tidy.txt", row.names = FALSE, quote = FALSE)
