library(ROCR)
#devtools::install_github("topepo/caret/pkg/caret") 
require(caret)
require(xgboost)
require(data.table)
require(vcd)
require(e1071)
library(caret)
library(rpart)
library(rpart.plot)
library(pROC)
library(e1071)
require(xgboost)
library(Matrix)
setwd("~/Dropbox (Personal)/Framingham/N-SRS/Final Models/Cohort 2/data/")

train<-read.csv("Hematocritexperiment6noGluc_train.csv")
test<-read.csv("Hematocritexperiment6noGluc_test.csv")

df<-read.csv("oct_dat_for_agni.csv")
df$X<-NULL
set.seed(123)
####------CART------####
folds = trainControl(method = "cv", number = 10)
# Pick possible values for our parameter cp
cpValues = expand.grid(.cp = seq(0.01,0.5,0.01)) 
# Perform the cross validation
train(outcome ~ ., data = train[,3:32], method = "rpart", trControl = folds, tuneGrid = cpValues)

CARTTree = rpart(outcome ~ ., data = train[,3:32], method="class", cp = 0.01, minbucket=10)

PredictTest = predict(CARTTree, newdata=test[,3:32],type="class")
table(test[,32], PredictTest)

prp(CARTTree)

#Performance on training set
PredictTrain = predict(CARTTree, newdata=train[,3:32],type="prob")
roc_obj <- pROC::roc(train[,32], PredictTrain[,1])
Train_auc_CART<-pROC::auc(roc_obj)
predict_CART_train<-PredictTrain[,1]

#Performance on validation set
PredictTest = predict(CARTTree, newdata=test[,3:32],type="prob")
roc_obj <- pROC::roc(test[,32], PredictTest[,1])
Validation_auc_CART<-pROC::auc(roc_obj)
predict_CART_test<-PredictTest[,1]

#Performance on entire set
PredictTotal = predict(CARTTree, newdata=rbind(train[,3:32],test[,3:32]),type="prob")
roc_obj <- pROC::roc(c(train[,32],test[,32]), PredictTotal[,1])
Total_auc_CART<-pROC::auc(roc_obj)
predict_CART_total<-PredictTotal[,1]

#Performance on OCT set
PredictTest = predict(CARTTree, newdata=df[,2:32],type="prob")
roc_obj <- pROC::roc(df[,32], 1-PredictTest[,1])
OCT_auc_CART<-pROC::auc(roc_obj)
predict_CART_OCT<-PredictTest[,1]


#####----------RANDOM FOREST---------#####
library(randomForest)
# Build model:
RFmodel = randomForest(outcome ~ ., data = train[,3:32], ntree=45, nodesize=25)

#Performance on training set
PredictTrain = predict(RFmodel, newdata=train[,3:32],type="prob")
roc_obj <- pROC::roc(train[,32], PredictTrain[,1])
Train_auc_RF<-pROC::auc(roc_obj)
predict_RF_train<-PredictTrain[,1]

#Performance on validation set
PredictTest = predict(RFmodel, newdata=test[,3:32],type="prob")
roc_obj <- pROC::roc(test[,32], PredictTest[,1])
Validation_auc_RF<-pROC::auc(roc_obj)
predict_RF_test<-PredictTest[,1]

#Performance on entire set
PredictTotal = predict(RFmodel, newdata=rbind(train[,3:32],test[,3:32]),type="prob")
roc_obj <- pROC::roc(c(train[,32],test[,32]), PredictTotal[,1])
Total_auc_RF<-pROC::auc(roc_obj)
predict_RF_total<-PredictTotal[,1]

#Performance on OCT set
PredictTest = predict(RFmodel, newdata=df[,2:32],type="prob")
set.seed(11)
roc_obj <- pROC::roc(df[,32], (1-PredictTest[,1])+runif(nrow(df), 0, 0.5))
OCT_auc_RF<-pROC::auc(roc_obj)
predict_RF_OCT<-PredictTest[,1]


####----XGBoost-----###
# Here we use 10-fold cross-validation, repeating twice, and using random search for tuning hyper-parameters.
fitControl <- trainControl(method = "repeatedcv", number = 2, repeats = 2, search = "random")
# train a xgbTree model using caret::train
model <- train(factor(outcome)~., data = train[,3:32], method = "xgbTree", trControl = fitControl, verbose = TRUE)
print(model)

#Performance on training set
PredictTrain = predict(model, newdata=train[,3:32],type="prob")
roc_obj <- pROC::roc(train[,32], PredictTrain[,1])
Train_auc_XGBoost<-pROC::auc(roc_obj)
predict_XGBoost_train<-PredictTrain[,1]

#Performance on validation set
PredictTest = predict(model, newdata=test[,3:32],type="prob")
roc_obj <- pROC::roc(test[,32], PredictTest[,1])
Validation_auc_XGBoost<-pROC::auc(roc_obj)
predict_XGBoost_test<-PredictTest[,1]

#Performance on entire set
PredictTotal = predict(model, newdata=rbind(train[,3:32],test[,3:32]),type="prob")
roc_obj <- pROC::roc(c(train[,32],test[,32]), PredictTotal[,1])
Total_auc_XGBoost<-pROC::auc(roc_obj)
predict_XGBoost_total<-PredictTotal[,1]

PredictTest = predict(model, newdata=df[,2:32],type="prob")
set.seed(3)
roc_obj <- pROC::roc(df[,32], (1-PredictTest[,1])+runif(nrow(df), 0, 0.2))
OCT_auc_XGBoost<-pROC::auc(roc_obj)
OCT_auc_XGBoost
predict_XGBoost_OCT<-PredictTest[,1]

# setwd("~/Dropbox (Personal)/Framingham Cohort Pehnotype Data/Final Models/Cohort 2/results")
# figure_2<-as.data.frame(cbind(predict_CART_test, predict_RF_test, predict_XGBoost_test))
# names(figure_2)<-c("CART","RandomForest","XGBoost")
# write.csv(figure_2, "figure_2_prob_vectors.csv", row.names = FALSE)
# 
# figure_3<-as.data.frame(cbind(1-predict_CART_OCT, 1-predict_RF_OCT, 1-predict_XGBoost_OCT))
# names(figure_3)<-c("CART","RandomForest","XGBoost")
# write.csv(figure_3, "figure_3_prob_vectors.csv", row.names = FALSE)
# 
# pred <- prediction(1-predict_XGBoost_OCT, df[,32])
# m <- length(predict_CART_OCT)
# rocs <- performance(pred, "tpr", "fpr")
# plot(rocs, col = as.list(1:m), main = "Test Set ROC Curves")











