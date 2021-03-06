#' pe
#' 
#' @title Prediction Error 
#' 
#' @description 
#' 
#' If $Y_t$ is a variable of interest at time $t$ and \eqn{\hat{Y}_t} is it's predicted value then the prediction error is given by $e_t = Y_t - \hat{Y}_t$. For a series of $T$ observations and predictions The accuracy of the predictions can be compared to the actual value by calculating various measures, such as as the Mean Absolute Error (MAE), which is the mean of the absolute errors and tells us how big of an error we can expect from the forecast on average. \\
#' 
#' \eqn{MAE=\frac{\left|e_t\right|}{T}} \\
#' 
#' A problem with the MAE is that the relative size of the error is not always obvious. Sometimes it is hard to tell a big error from a small error. To deal with this problem, we can compute the MAPE instead, i.e. MAE as a percentage, this allows forecasts of different series in different scales to be compared.\\
#' 
#' \eqn{MAPE = \frac{1}{T} \sum_{t=1}^T 100\, \left|\frac{e_t}{Y_t}\right|}\\
#' 
#' Both MAE and MAPE are based on the mean error and so may understate the impact of big, but infrequent, errors. If we focus too much on the mean, we will be caught off guard by the infrequent big error. To adjust for large rare errors, we calculate the Root Mean Square Error (RMSE). By squaring the errors before we calculate their mean and then taking the square root of the mean, we arrive at a measure of the size of the error that gives more weight to the large but infrequent errors than the mean.\\
#' 
#' \eqn{RMSE = \sqrt{\frac{1}{T} \sum_{t=1}^T e_t^2}} \\
#' 
#' We can also compare RMSE and MAE to determine whether the forecast contains large but infrequent errors. The larger the difference between RMSE and MAE the more inconsistent the error size.
#' 
#' Another measure is the Mean Absolute Scaled Error (MASE) \\
#' 
#' \eqn{MASE={\frac {\sum _{t=1}^{T}\left|e_{t}\right|}{{\frac {T}{T-1}}\sum _{t=1}^{T}\left|Y_{t+1}-Y_{t}\right|}}} \\
#' 
#' Which has the desirable properties of scale invariance, predictable behaviour, symmetry, interpretability and asymptotic normality
#' 
#' The mean absolute scaled error is independent of the scale of the data, so can be used to compare forecasts across data sets with different scales. Behaviour is predictable as $y_{t}\rightarrow 0$] Percentage forecast accuracy measures such as the Mean absolute percentage error (MAPE) rely on division of $y_{t}$, skewing the distribution of the MAPE for values of $y_{t}$ near or equal to 0. This is especially problematic for data sets whose scales do not have a meaningful 0, such as temperature in Celsius or Fahrenheit, and for intermittent demand data sets, where $y_{t}=0$  occurs frequently.
#' Symmetry since The mean absolute scaled error penalises positive and negative forecast errors equally, and penalises errors in large forecasts and small forecasts equally. In contrast, the MAPE  fail both of these criteria. The mean absolute scaled error can be easily interpreted, as values greater than one indicate that in-sample one-step forecasts from the na??ve method perform better than the forecast values under consideration.The Diebold-Mariano test for one-step forecasts is used to test the statistical significance of the difference between two sets of forecasts. To perform hypothesis testing with the Diebold-Mariano test statistic, it is desirable for DM = N (0, 1) $DM\sim N(0,1)$ , where $DM$ is the value of the test statistic. The DM statistic for the MASE has been empirically shown to approximate this distribution, while the mean relative absolute error (MRAE), MAPE and sMAPE do not.
#' 
#' Another measure is Theil's $U$\\
#'   
#'  \eqn{U= \sqrt{\frac{1}{T}\\
#'         \sum_{t=1}^{T-1} \left(\frac{e_{t+1}}{Y_t}\right)^2
#'         \cdot \left[
#'        \frac{1}{T} \sum_{t=1}^{T-1} 
#'            \left(\frac{Y_{t+1} - Y_t}{Y_t}\right)^2 \right]^{-1}}}
#' 
#'   The more accurate the forecasts, the lower the value of Theil's $U$,   which has a minimum of 0. This measure can be interpreted as the ratio of the RMSE of the proposed forecasting model to the RMSE of   a na\"ive model which simply predicts $Y_{t+1} = Y_t$ for all $t$. The na\"ive model yields $U = 1$; values less than 1 indicate an  improvement relative to this benchmark and values greater than 1 a deterioration.
#' 
#'   Altough the methods have their limitations, they are simple tools for evaluating forecast accuracy that can be used without knowing anything about the forecast except the past values of a forecast.
#' 
#'  Just because a forecast has been accurate in the past, however, does not mean it will be accurate in the future. Over fitting may make the forecast less accurate and there is always the possibility of an event occurring that the model cannot anticipate, a black swan event. When this happens, you don???t know how big the error will be. Errors associated with these events are not typical errors, which is what the statistics above try to measure. So, while forecast accuracy can tell us a lot about the past, remember these limitations when using forecasts to predict the future.
#' 
#' @name pe
#' 
#' @param obs actual values an \code{FLQuant} or \code{numeric} 
#' @param hat predicted values an \code{FLQuant} or \code{numeric}
#' 
#' @aliases mae, mape, mase, rmse
#' 
#' @docType method
#' 
#' @rdname pErr
#' @seealso 
#' 
#' @examples
#' \dontrun{
#' 
#' 
#' }
# 
# setGeneric('pe',  function(obs,hat,...) standardGeneric('pe'))
# setMethod('pe', signature(obs='FLQuant',hat='FLQuant'), function(obs,hat) {
#         
#    mf =model.frame(FLQuants(obs=obs,hat=hat))
#    nms=names(mf)
#    names(mf)[1]="quant"
#   
#    if (dims(obs)$iter>dims(hat)$iter)
#      hat=propagate(hat,dims(obs)$iter)
#    if (dims(hat)$iter>dims(obs)$iter)
#      obs=propagate(obs,dims(hat)$iter)
#    
#    if (max(dims(obs)$iter,dims(hat)$iter)>1)
#       res=as(t(daply(mf,.(quant,season,unit,area,iter),with, pe(obs,hat))),"FLPar")
#    else
#       res=FLPar(daply(mf,.(quant,season,unit,area,iter),with, pe(obs,hat)),units="NA")
#          
#    res})
# 
# setMethod('pe', signature(obs='numeric',hat='numeric'),
#           function(obs,hat) {
#             c(mae   =mae( obs,hat),
#               mape  =mape(obs,hat),
#               mase  =mase(obs,hat),
#               theil =theil(obs,hat),
#               rmse  =rmse(obs,hat),
#               cor   =cor( obs,hat),
#               cov   =cov( obs,hat),
#               sd.obs=var( obs)^0.5,
#               sd.hat=var( hat)^0.5)
#           })
# 
# 
# mae<-function(obs,hat){
#   t=length(hat)
#   
#   sum(abs(obs-hat))/t}
# 
# mape<-function(obs,hat){
#   t=length(hat)
#   
#   sum(abs((obs-hat)/obs))/t}
# 
# mase<-function(obs,hat){
#   t=length(hat)
#   
#   sum(abs(obs-hat))/sum(abs(obs[-1]-obs[-length(obs)]))*(t-1)/t}
# 
# hmase<-function(obs,hat,h=1){
#   t=length(hat)
#   
#   sum(abs(obs-hat))/sum(abs(obs[-seq(h)]-rev(rev(obs)[-seq(h)])))*(t-h)/t}
# 
# rmse<-function(obs,hat){
#   t=length(hat)
#   
#   (sum(((obs-hat)^2)/t))^0.5}
# 
# theil<-function(obs,hat){
#   
#   res=(sum(((hat[-1]-obs[-1])/obs[-1])^2)/length(obs))/
#       (sum(((obs[-1]-obs[-length(obs)])/obs[-1])^2)/length(obs))
#   
#   res^0.5}

setGeneric('pe',  function(obs,hat,...) standardGeneric('pe'))
setMethod('pe', signature(obs='FLQuant',hat='FLQuant'), function(obs,hat) {
        
   mf =model.frame(FLQuants(obs=obs,hat=hat))
   nms=names(mf)
   names(mf)[1]="quant"
  
   if (dims(obs)$iter>dims(hat)$iter)
     hat=propagate(hat,dims(obs)$iter)
   if (dims(hat)$iter>dims(obs)$iter)
     obs=propagate(obs,dims(hat)$iter)
   
   if (max(dims(obs)$iter,dims(hat)$iter)>1)
      res=as(t(daply(mf,.(quant,season,unit,area,iter),with, pe(obs,hat))),"FLPar")
   else
      res=FLPar(daply(mf,.(quant,season,unit,area,iter),with, pe(obs,hat)),units="NA")
         
   res})

setMethod('pe', signature(obs='numeric',hat='numeric'),
          function(obs,hat) {
            c(mae   =mae( obs,hat),
              mape  =mape(obs,hat),
              mase  =mase(obs,hat),
              theil =theil(obs,hat),
              rmse  =rmse(obs,hat),
              cor   =cor( obs,hat),
              cov   =cov( obs,hat),
              sd.obs=var( obs)^0.5,
              sd.hat=var( hat)^0.5)
          })


mae<-function(obs,hat){
  t=length(hat)
  
  sum(abs(obs-hat))/t}

mape<-function(obs,hat){
  t=length(hat)
  
  sum(abs((obs-hat)/obs))/t}

mase<-function(obs,hat){
  t=length(hat)
  
  sum(abs(obs-hat))/sum(abs(obs[-1]-obs[-length(obs)]))*(t-1)/t}

hmase<-function(obs,hat,h=1){
  t=length(hat)
  
  sum(abs(obs-hat))/sum(abs(obs[-seq(h)]-rev(rev(obs)[-seq(h)])))*(t-h)/t}

rmse<-function(obs,hat){
  t=length(hat)
  
  (sum(((obs-hat)^2)/t))^0.5}

theil<-function(obs,hat){
  
  res=(sum(((hat[-1]-obs[-1])/obs[-1])^2)/length(obs))/
      (sum(((obs[-1]-obs[-length(obs)])/obs[-1])^2)/length(obs))
  
  res^0.5}
