setwd("~/Desktop/CU Denver/2020 Spring/BANA 6610 Statistics for Business Analytics/Homework/covid19-us-countylevel-summaries")

library(tidyverse)
library(readxl)
library(ggplot2)
library(lubridate)
library(forecast)
library(tseries)
library(lmtest)
library(FitAR)


denver_data <- read_excel("Covid19_Denver.xlsx", sheet=1)
glimpse(denver_data)

denver_data$Time <- as.Date(denver_data$Time, "%m/%d/%Y")


#Grocery shopping footage

denver_grocery_ts<-ts(data=denver_data$`Grocery Stores`,frequency =7)
denver_grocery_ts
denver_grocery_fc<-HoltWinters(denver_grocery_ts, beta = FALSE, gamma=TRUE, seasonal = 'additive')
denver_grocery_fc
denver_grocery_ts2 <- forecast(denver_grocery_fc, h=8)
denver_grocery_ts2 


#Seasonal Decomposition

denver_grocery_ts_decomp<- decompose(denver_grocery_ts)

#Stationary test

adf.test(denver_grocery_ts, alternative = "stationary", k=0)

summary(denver_grocery_ts2)

#Auto-correlation

Acf(denver_grocery_ts, lag.max = 30, main='ACF for Denver Grocery')
Pacf(denver_grocery_ts, lag.max = 30, main= 'PACF for Denver Grocery')
Box.test(denver_grocery_ts2$residuals,lag = 1, type = "Ljung-Box")


denver_grocery_ts2$residuals
denver_grocery_df <- data.frame(denver_data$Time,denver_grocery_ts2$residuals)
denver_grocery_df 

#ARIMA models for grocery ("ML" maximum likehood)

denver_grocery_model1 <- arima(denver_grocery_ts, order = c(1,0,0),
                              seasonal = list(order = c(0,3,1), period = 7), method="ML") 
denver_grocery_model1
coeftest(denver_grocery_model1)

denver_grocery_model2 <- arima(denver_grocery_ts, order = c(1,0,0), 
                              seasonal = list(order = c(1,3,0), period = 7), method="ML") 
denver_grocery_model2
coeftest(denver_grocery_model2)

denver_grocery_model3 <- arima(denver_grocery_ts, order = c(1,0,0),
                               seasonal = list(order = c(1,3,1),period = 7), method="ML") 
denver_grocery_model3
coeftest(denver_grocery_model3)

denver_grocery_model4 <- arima(denver_grocery_ts, order = c(0,0,1),
                               seasonal = list(order = c(1,3,0),period = 7), method="ML") 
denver_grocery_model4
coeftest(denver_grocery_model4)

denver_grocery_model5 <- auto.arima(denver_grocery_ts, seasonal = TRUE) 
denver_grocery_model5 
coeftest(denver_grocery_model5)

summary(denver_grocery_model5)
accuracy(denver_grocery_ts2)

#model3 forecast plot with 80%~95%CI

future_g_model3 <- forecast(denver_grocery_model3 ,h=10, level=c(80,95))
autoplot(future_g_model3)



ggplot(data = denver_data, aes(Time,`Grocery Stores`))+geom_line(color='blue', size=1)+
  ggtitle('Grocery shopping in Denver') +theme(plot.title = element_text(hjust = 0.5))+
  geom_smooth(mapping = aes(x=Time,y=`Grocery Stores`),span=0.3 ,color='pink')

ggplot(data=denver_grocery_df,aes(denver_data.Time,denver_grocery_ts2.residuals))+geom_point(color='black', size=1)+
  ggtitle('Residual Plot in Denver Grocery Shopping') +theme(plot.title = element_text(hjust = 0.5))+
  geom_smooth(mapping = aes(x=denver_data.Time,y=denver_grocery_ts2.residuals),method = 'lm' ,color='red')



#Health and Personal Care shopping footage

denver_health_pc_ts<-ts(data=denver_data$`Health and Personal Care Stores`,frequency = 7)
denver_health_pc_fc<-HoltWinters(denver_health_pc_ts, beta = FALSE, gamma=TRUE, seasonal = 'additive')
denver_health_pc_fc

#Forecast
denver_health_pc_ts2 <-forecast(denver_health_pc_fc,h=8)
denver_health_pc_ts2

#Auto-correlation for health and personal care shopping
Acf(denver_health_pc_ts,lag.max = 30, main='ACF for Denver Health and Personal Care')
Pacf(denver_health_pc_ts,lag.max = 30, main='PACF for Denver Health and Personal Care')


ggplot(data = denver_data, aes(Time,`Health and Personal Care Stores`))+geom_line(color='blue', size=1)+
  ggtitle('Health and Personal Care shopping in Denver') +theme(plot.title = element_text(hjust = 0.5))+
  geom_smooth(mapping = aes(x=Time,y=`Health and Personal Care Stores`),span=0.3 ,color='pink')




#residuals for health and personal care shopping
denver_health_pc_ts2$residuals
denver_health_pc_df <- data.frame(denver_data$Time,denver_health_pc_ts2$residuals) 
denver_health_pc_df

ggplot(data=denver_health_pc_df,aes(denver_data.Time,denver_health_pc_ts2.residuals))+geom_point(color='black', size=1)+
  ggtitle('Residual Plot for Health and Personal Care shopping in Denver') +theme(plot.title = element_text(hjust = 0.5))+
  geom_smooth(mapping = aes(x=denver_data.Time,y=denver_health_pc_ts2.residuals),method = 'lm' ,color='red')

#ARIMA models for health and personal care shopping

denver_health_pc_model1 <- arima(denver_health_pc_ts, order = c(1,0,0),
                               seasonal = list(order = c(0,3,1), period = 7), method="ML") 

denver_health_pc_model1
coeftest(denver_health_pc_model1)


denver_health_pc_model2 <- arima(denver_health_pc_ts, order = c(0,0,1),
                                 seasonal = list(order = c(1,3,0), period = 7), method="ML")

denver_health_pc_model2
coeftest(denver_health_pc_model2)


denver_health_pc_model3 <- arima(denver_health_pc_ts, order = c(2,0,1),
                                 seasonal = list(order = c(0,3,0), period = 7), method="ML")

denver_health_pc_model3
coeftest(denver_health_pc_model3)

denver_health_pc_model4 <- arima(denver_health_pc_ts, order = c(2,0,1),
                                 seasonal = list(order = c(1,3,0), period = 7), method="ML")

denver_health_pc_model4
coeftest(denver_health_pc_model4)

#model4 forecast plot with 80%~95%CI

future_health_pc_model4 <- forecast(denver_health_pc_model4,h=10, level=c(80,95))
autoplot(future_health_pc_model4)


#Traveler Accommodation

ggplot(data = denver_data, aes(Time,`Traveler Accommodation`))+geom_line(color='blue', size=1)+
  ggtitle('Traveler Accommodation footage in Denver') +theme(plot.title = element_text(hjust = 0.5))+
  geom_smooth(mapping = aes(x=Time,y=`Traveler Accommodation`),span=0.3 ,color='pink')

#Auto-correlation

Acf(denver_travel_ts, lag.max = 30, main='ACF for travel accommodation in Denver')
Pacf(denver_travel_ts, lag.max = 30, main= 'PACF for travel accommodation in Denver')



#residuals for travel

denver_travel_ts <- ts(data = denver_data$`Traveler Accommodation`,frequency =365)
                      
denver_travel_ts
denver_travel_fc<-HoltWinters(denver_travel_ts, beta = FALSE, gamma=FALSE)
denver_travel_fc

summary(denver_travel_fc)

denver_travel_ts2 <- forecast(denver_travel_fc, h=8)
denver_travel_ts2

denver_travel_ts2$residuals

denver_travel_df <- data.frame(denver_data$Time,denver_travel_ts2$residuals)

ggplot(data=denver_travel_df,aes(denver_data.Time,denver_travel_ts2.residuals))+geom_point(color='black', size=1)+
  ggtitle('Residual Plot for Travel Accommodation in Denver') +theme(plot.title = element_text(hjust = 0.5))+
  geom_smooth(mapping = aes(x=denver_data.Time,y=denver_travel_ts2.residuals),method = 'lm' ,color='red')

#ARIMA models for travel accommodation
denver_travel_model1 <-arima(denver_travel_ts, order = c(1,1,0), method="ML")
denver_travel_model1 
coeftest(denver_travel_model1)

denver_travel_model2 <-arima(denver_travel_ts, order = c(1,3,0), method="ML")
denver_travel_model2 
coeftest(denver_travel_model2)

denver_travel_model3 <-arima(denver_travel_ts, order = c(0,3,1), method="ML")
denver_travel_model3 
coeftest(denver_travel_model3)

denver_travel_model4 <-arima(denver_travel_ts, order = c(2,1,0), method="ML")
denver_travel_model4 
coeftest(denver_travel_model4)

denver_travel_model5 <- auto.arima(denver_travel_ts, seasonal = FALSE)
denver_travel_model5 
coeftest(denver_travel_model5)

#model5 forecast plot with 80%~95%CI
future_travel_model5 <- forecast(denver_travel_model5,h=10, level=c(80,95))
autoplot(future_travel_model5)


#Physicians Footage

ggplot(data = denver_data, aes(Time,`Offices of Physicians`))+geom_line(color='blue', size=1)+
  ggtitle('Physician footage in Denver') +theme(plot.title = element_text(hjust = 0.5))+
  geom_smooth(mapping = aes(x=Time,y=`Offices of Physicians`),span=0.3 ,color='pink')

denver_physician_ts <- ts(data = denver_data$`Offices of Physicians`, frequency = 7)
denver_physician_fc<-HoltWinters(denver_physician_ts, beta = FALSE, gamma=TRUE,seasonal = 'additive')
denver_physician_ts2 <-forecast(denver_physician_fc, h=8)
denver_physician_ts2 

#Auto-correlation
Acf(denver_physician_ts, lag.max = 30, main='ACF for physician footage in Denver')
Pacf(denver_physician_ts, lag.max = 30, main= 'PACF for physician footage in Denver')


denver_physician_ts2$residuals
denver_physician_df <- data.frame(denver_data$Time,denver_physician_ts2$residuals)
denver_physician_df 

ggplot(data=denver_physician_df ,aes(denver_data.Time,denver_physician_ts2$residuals))+geom_point(color='black', size=1)+
  ggtitle('Residual Plot for Physician Footage in Denver') +theme(plot.title = element_text(hjust = 0.5))+
  geom_smooth(mapping = aes(x=denver_data.Time,y=denver_physician_ts2$residuals),method = 'lm' ,color='red')

#ARIMA models for Physician footage

denver_physician_model1 <- arima(denver_physician_ts, order = c(1,0,0),
                                 seasonal = list(order = c(0,3,1), period = 7), method="ML")
denver_physician_model1
coeftest(denver_physician_model1)

denver_physician_model2 <- arima(denver_physician_ts, order = c(1,0,0),
                                 seasonal = list(order = c(1,3,0), period = 7), method="ML")
denver_physician_model2
coeftest(denver_physician_model2)

denver_physician_model3 <- arima(denver_physician_ts, order = c(1,0,0),
                                 seasonal = list(order = c(2,3,0), period = 7), method="ML")
denver_physician_model3
coeftest(denver_physician_model3)

denver_physician_model4 <- arima(denver_physician_ts, order = c(1,0,0),
                                 seasonal = list(order = c(0,3,2), period = 7), method="ML")
denver_physician_model4
coeftest(denver_physician_model4)

denver_physician_model5 <- auto.arima(denver_physician_ts, seasonal = TRUE)
denver_physician_model5 
coeftest(denver_physician_model5)

#model4 forecast plot with 80%~95%CI
future_physician_model4 <- forecast(denver_physician_model4,h=10, level=c(80,95))
autoplot(future_physician_model4)


#Death Care Footage

ggplot(data = denver_data, aes(Time,`Death Care Services`))+geom_line(color='blue', size=1)+
  ggtitle('Death Care footage in Denver') +theme(plot.title = element_text(hjust = 0.5))+
  geom_smooth(mapping = aes(x=Time,y=`Death Care Services`),span=0.3 ,color='pink')

denver_deathcare_ts <- ts(data = denver_data$`Death Care Services`, frequency = 365)
denver_deathcare_ts

denver_deathcare_fc <-HoltWinters(denver_deathcare_ts, beta=FALSE, gamma=FALSE)
denver_deathcare_ts2 <- forecast(denver_deathcare_fc, h=8)
denver_deathcare_ts2

denver_deathcare_ts2$residuals
denver_deathcare_df <- data.frame(denver_data$Time,denver_deathcare_ts2$residuals)

ggplot(data=denver_physician_df ,aes(denver_data.Time,denver_deathcare_ts2$residuals))+geom_point(color='black', size=1)+
  ggtitle('Residual Plot for Death Care Footage in Denver') +theme(plot.title = element_text(hjust = 0.5))+
  geom_smooth(mapping = aes(x=denver_data.Time,y=denver_deathcare_ts2$residuals),method = 'lm' ,color='red')

#Auto-correlation
Acf(denver_deathcare_ts, lag.max = 30, main='ACF for Death Care footage in Denver')
Pacf(denver_deathcare_ts, lag.max = 30, main= 'PACF for Death Care footage in Denver')

#ARIMA models for Death Care

denver_deathcare_model1 <- arima(denver_deathcare_ts, order = c(1,0,0), method = "ML")
denver_deathcare_model1
coeftest(denver_deathcare_model1)

denver_deathcare_model2 <- arima(denver_deathcare_ts, order = c(1,0,1), method = "ML")
denver_deathcare_model2
coeftest(denver_deathcare_model2)

denver_deathcare_model3 <- arima(denver_deathcare_ts, order = c(1,2,1), method = "ML")
denver_deathcare_model3
coeftest(denver_deathcare_model3)

denver_deathcare_model4 <- arima(denver_deathcare_ts, order = c(1,3,1), method = "ML")
denver_deathcare_model4
coeftest(denver_deathcare_model4)

#model3 forecast plot with 80%~95%CI
future_deathcare_model3 <- forecast(denver_deathcare_model3,h=10, level=c(80,95))
autoplot(future_deathcare_model3)




  