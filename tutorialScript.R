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
# test$Survived <- 0

# Titanic famous for saving women and children first - refine to say all women
# survived (Correctness = 0.76555)
# test$Survived[test$Sex == "female"] <- 1

# Now look at age
# summary(train$Age)

# Simplify Age data into 0/1 Child field
# Most are adults so default to 0
# train$Child <- 0
# Everyone under 18 is a child
# train$Child[train$Age < 18] <- 1

# See the counts of who survived - sum Survived value
# aggregate(Survived ~ Child + Sex, data = train, FUN = sum)

# See the totals for each category - count Survived value
# aggregate(Survived ~ Child + Sex, data = train, FUN = length)

# See the proportions of who survived
# aggregate(Survived ~ Child + Sex, data = train, FUN = 
#   function(x) {sum(x)/length(x)})

# What about fare and ticket class? Maybe they'll show something interesting
# Group the fares into bins
# train$Fare2 <- '30+'
# train$Fare2[train$Fare < 30 & train$Fare >= 20] <- '20-30'
# train$Fare2[train$Fare < 20 & train$Fare >= 10] <- '10-20'
# train$Fare2[train$Fare < 10] <- "<10"

# Look at proportions by sex, class, and fare grouping
# aggregate(Survived ~ Fare2 + Pclass + Sex, data = train, FUN = 
#             function(x) {sum(x)/length(x)})

# Women in 3rd class with expensive tickets were much less likely to survive.
# Assume they didn't (Correctness = 0.77990)
# test$Survived[test$Sex == "female" & test$Pclass == 3 & test$Fare >= 20] <- 0

# Too much work to do it all by hand - use decision trees! (rpart library)
# (Correcness = 0.78469)
# fit <- rpart(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked,
#              data = train,
#              method = "class")

# Override the control to get more complex trees - beware overfitting! (this
# will do worse than just the all ladies survive model if submitted)
#              control = rpart.control(minsplit = 2, cp = 0))

# Standard rpart commands
# plot(fit)
# text(fit)

# Fancy rpart commands (requires rattle and other packages installed above)
# fancyRpartPlot(fit)

# Feature Engineering (Tutorial Part 4)
test$Survived <- NA
train$Child <- NULL
train$Fare2 <- NULL

# Make changes to both sets at once
combi <- rbind(train, test)

# Convert back from factors to strings
combi$Name <- as.character(combi$Name)

# Grab just the title from each record
combi$Title <- sapply(combi$Name, FUN = function(x) {strsplit(x, 
                                                      split = '[,.]')[[1]][2]})
# Remove the first space from each title
combi$Title <- sub(' ', '', combi$Title)

# Combine elements with small occurences
# combi$Title[combi$Title %in% c("Don", "Sir", "Rev")] <- 'Sir'
# combi$Title[combi$TItle %in% c("Capt", "Major", "Col")] <- 'Military'
# combi$Title[combi$Title %in% c("Lady", "the Countess")] <- 'Lady'
# combi$Title[combi$Title %in% c("Jonkheer", "Master")] <- "Master"
# combi$Title[combi$Title %in% c("Miss", "Mlle", "Ms")] <- "Miss"
# combi$Title[combi$Title %in% c("Mme", "Mrs", "Dona")] <- "Mrs"

# Trevor's title combinations (Correctness = 0.79426)
combi$Title[combi$Title %in% c('Mme', 'Mlle')] <- 'Mlle'
combi$Title[combi$Title %in% c('Capt', 'Don', 'Major', 'Sir')] <- 'Sir'
combi$Title[combi$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] <- 'Lady'

# Return it back to a factor
combi$Title <- factor(combi$Title)

# Combine siblings/parent children to get total family size on board for each 
# passenger (counting themselves, hence the +1)
combi$FamilySize <- combi$SibSp + combi$Parch + 1

# Let's try getting surnames and combining with family size to try to get 
# family groups
combi$Surname <- sapply(combi$Name, FUN = function(x) {strsplit(x, 
                                                    split = '[,.]')[[1]][1]})
# Generate a family id by putting the family size before the surname
combi$FamilyID <- paste(as.character(combi$FamilySize), combi$Surname, sep = "")

# All single Johnsons have same id right now. Call any family of 2 or less "Small"
combi$FamilyID[combi$FamilySize <= 2] <- "Small"

# This still leaves many family ids with a single occurrence (probably due to 
# married names, nannies, adult siblings, ??). Set those to Small as well
# convert to data frame and filter out anyone with 2 or fewer occurences to act on
famIds <- data.frame(table(combi$FamilyID))
famIds <- famIds[famIds$Freq <= 2,]

# Set the small families to 'Small'
combi$FamilyID[combi$FamilyID %in% famIds$Var1] <- 'Small'

# Put family id to factor
combi$FamilyID <- factor(combi$FamilyID)

# Split the train and test data sets back apart, retaining the same factor levels
train <- combi[1:891,]
test <- combi[892:1309,]

# Check the fit based on our new variables and factors (Correctness = 0.74163 
# as grouped)
fit <- rpart(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title 
             + FamilySize + FamilyID, data = train, method = "class")

fancyRpartPlot(fit)
Prediction <- predict(fit, test, type = "class")

submit <- data.frame(PassengerId = test$PassengerId, Survived = Prediction)
write.csv(submit, file = "submissions/featureengineereddecisiontreemodeltrevor1.csv", row.names = FALSE)
