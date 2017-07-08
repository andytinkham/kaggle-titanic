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

# Now look at age
# summary(train$Age)

# Simplify Age data into 0/1 Child field
# Most are adults so default to 0
train$Child <- 0
# Everyone under 18 is a child
train$Child[train$Age < 18] <- 1

# See the counts of who survived - sum Survived value
# aggregate(Survived ~ Child + Sex, data = train, FUN = sum)

# See the totals for each category - count Survived value
# aggregate(Survived ~ Child + Sex, data = train, FUN = length)

# See the proportions of who survived
# aggregate(Survived ~ Child + Sex, data = train, FUN = 
#   function(x) {sum(x)/length(x)})

submit <- data.frame(PassengerId = test$PassengerId, Survived = test$Survived)
write.csv(submit, file = "submissions/womenallsurvive.csv", row.names = FALSE)
