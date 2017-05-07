setwd("~/Desktop/SummerWork")
library(foreign)
library(gmm)
library(ggplot2)
library(sandwich)
library(lmtest)
library(rqpd)
library(boot)
library(quantreg)

VPP_data=read.dta('VPP_for_R.dta')

Quantile90 = c()

for (VPPindex in 1:5) {
  for (hourIndex in 0:23) {
    VPP_regress_set <- subset(VPP_data, VPP_data$VPPDay == VPPindex & VPP_data$hour == hourIndex)
    reg_Design <- as.matrix(VPP_regress_set[,c(3:10, 15:17)])
    
    logkwh_vector <- VPP_regress_set$logkwh

    length(VPP_regress_set$identity)
    VPP_fit <- boot.rq(reg_Design, logkwh_vector, tau = 0.9, R=500, cluster = VPP_regress_set$identity)
    # where we'll take the bootstrap samples
    treat6_coeff <- mean(VPP_fit$B[,9])
    treat6_std <- sqrt(var(VPP_fit$B[,9]))
    treat7_coeff <- mean(VPP_fit$B[,10])
    treat7_std <- sqrt(var(VPP_fit$B[,10]))
    treat8_coeff <- mean(VPP_fit$B[,11])
    treat8_std <- sqrt(var(VPP_fit$B[,11]))
    nextHour <- cbind(VPPindex, hourIndex, treat6_coeff, treat6_std, treat7_coeff, treat7_std, treat8_coeff, treat8_std)
    
    Quantile90 <- rbind(Quantile90, nextHour)
    
  }
}

Quantile90
Quantile90_dataFrame <- as.data.frame(Quantile90)
write.dta(Quantile90_dataFrame, "Quantile90_BootstrapResults.dta")

