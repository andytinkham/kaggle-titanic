# Built following tutorial at 
# http://trevorstephens.com/kaggle-titanic-tutorial/getting-started-with-r/

setwd("~/Rprojects/kaggle-titanic/")

# Packages for better decision tree plots
# install.packages('rattle')
# install.packages('rpart.plot')
# install.packages('RColorBrewer')

library(readr)
library(rpart)
library(rattle)
library(rpart.plot)
library(RColorBrewer)

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

# What about fare and ticket class? Maybe they'll show something interesting
# Group the fares into bins
train$Fare2 <- '30+'
train$Fare2[train$Fare < 30 & train$Fare >= 20] <- '20-30'
train$Fare2[train$Fare < 20 & train$Fare >= 10] <- '10-20'
train$Fare2[train$Fare < 10] <- "<10"

# Look at proportions by sex, class, and fare grouping
# aggregate(Survived ~ Fare2 + Pclass + Sex, data = train, FUN = 
#             function(x) {sum(x)/length(x)})

# Women in 3rd class with expensive tickets were much less likely to survive.
# Assume they didn't (Correctness = 0.77990)
test$Survived[test$Sex == "female" & test$Pclass == 3 & test$Fare >= 20] <- 0

# Too much work to do it all by hand - use decision trees! (rpart library)
fit <- rpart(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked,
             data = train,
             method = "class")
plot(fit)
text(fit)

submit <- data.frame(PassengerId = test$PassengerId, Survived = test$Survived)
write.csv(submit, file = "submissions/womennotexpensive3rdclasssurvive.csv", row.names = FALSE)