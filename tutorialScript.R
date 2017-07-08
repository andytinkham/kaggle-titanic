# Built following tutorial at 
# http://trevorstephens.com/kaggle-titanic-tutorial/getting-started-with-r/

setwd("~/Rprojects/kaggle-titanic/")

library(readr)

# Pull in the datasets
train <- read.csv("data/train.csv")
test <- read.csv("data/test.csv")

# Most people died on the Titanic. Start with an assumption that all the test 
# data people did as well.
test$Survived <- rep(0, 418)

submit <- data.frame(PassengerId = test$PassengerId, Survived = test$Survived)
write.csv(submit, file = "submissions/theyallperish.csv", row.names = FALSE)
