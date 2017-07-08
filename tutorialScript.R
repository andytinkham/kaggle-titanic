# Built following tutorial at http://trevorstephens.com/kaggle-titanic-tutorial/getting-started-with-r/

setwd("~/Rprojects/kaggle-titanic/")

library(readr)

# Pull in the datasets
train <- read_csv("data/train.csv")
test <- read_csv("data/test.csv")
