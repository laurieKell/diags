utils::globalVariables(c("y","resStd","hatLn","res","FLPar","YearC","viewport"))
utils::globalVariables(c("rstandard"))
utils::globalVariables(c("grid.newpage"))
utils::globalVariables(c("pushViewport"))
utils::globalVariables(c("grid.layout"))
utils::globalVariables(c("qqnorm"))
utils::globalVariables(c("ggplot"))
utils::globalVariables(c("geom_point"))
utils::globalVariables(c("aes"))
utils::globalVariables(c("opts"))
utils::globalVariables(c("scale_x_continuous"))
utils::globalVariables(c("scale_y_continuous"))
utils::globalVariables(c("geom_abline"))
utils::globalVariables(c("hat"))
utils::globalVariables(c("stat_smooth"))

#### Diagnostics for a glm
.diagGlm<-function(object){
   vplayout <-function(x, y) viewport(layout.pos.row=x, layout.pos.col=y)

   smry<-data.frame(resStd    =rstandard(object),
                    res       =object$residuals,
                    hatLn     =object$linear.predictors,
                    hat       =object$fitted.values,
                    y         =object$y)

  grid.newpage()
  pushViewport(viewport(layout=grid.layout(2,2)))

  rsdl<-qqnorm(rstandard(object),plot.it=FALSE)
  rsdl<-data.frame(x=rsdl$x,y=rsdl$y)

  p<-ggplot(rsdl) + geom_point(aes(x,y),size=0.5)   +
                    opts(title = "Normal Q-Q Plot") + scale_x_continuous(name="Theoretical Quantiles") +
                                                      scale_y_continuous(name="Sample Quantiles")  +
                    geom_abline(intercept=0, slope=1)
  print(p, vp=vplayout(1,1))

  p<-ggplot(smry) +
                geom_point(aes(hat,resStd),size=0.5) + stat_smooth(aes(hat,resStd),method="gam") +
                opts(title="Error Distributions")    + scale_x_continuous(name="Predicted") +
                                                       scale_y_continuous(name="Standardised Residuals")
  print(p, vp=vplayout(1,2))

  p<-ggplot(smry) +
                geom_point(aes(hatLn,res), size=0.5) + stat_smooth(aes(hatLn,res),method="gam") +
                opts(title="Assumed Variance") + scale_x_continuous(name="Predicted on Link") +
                                                 scale_y_continuous(name="Absolute Residuals")
  print(p, vp=vplayout(2,2))

  p<-ggplot(smry) +
                geom_point(aes(hatLn,y), size=0.5) + stat_smooth(aes(hatLn,y),method="gam") +
                opts(title="Link Function") + scale_x_continuous(name="Predicted on Link") +
                                              scale_y_continuous(name="Observed")
  print(p, vp=vplayout(2,1))}
################################################################################


setMethod('diags',  signature(object='glm',method="missing"), function(object,method,...) .diagGlm(object,...))



