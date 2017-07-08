# Built following tutorial at 
# http://trevorstephens.com/kaggle-titanic-tutorial/getting-started-with-r/

setwd("~/Rprojects/kaggle-titanic/")

library(readr)

# Pull in the datasets
train <- read.csv("data/train.csv")
test <- read.csv("data/test.csv")

# Look at proportions of men and women who survived
# prop.table(table(train$Sex, train$Survived),1)

# Start with assumption everyone dies (Correctness = 0.62679)
test$Survived <- 0

# Titanic famous for saving women and children first - refine to say all women
# survived (Correctness = 0.76555)
test$Survived[test$Sex == "female"] <- 1

submit <- data.frame(PassengerId = test$PassengerId, Survived = test$Survived)
write.csv(submit, file = "submissions/womenallsurvive.csv", row.names = FALSE)
