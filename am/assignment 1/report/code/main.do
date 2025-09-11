**** This do-file contains all the commands with explanations used in all the videos 
**** related to the Stata application for the first topic and other resources
**** that maybe useful for completition of the first assignment or one of the future ones.  

** In this Stata application we will focus on:

* 1) Estimate log-log models, log-level models, level-log and level-level models
* 2) Put emphasis on interpretation of the coefficient (sign, magnitude and significance)
* 3) How to obtain predictions
* 4) Model with dummy variables (constant and interactions)
* 5) Model with qualitative variables with more than one category   
* 6) Model selection and Reset test

* All the lines that start with an asterisc are explanations that Stata identifies
* that they are not commands

* Remember to create a log file to store your commands and results which you 
* can later use for your Word answer file. Graphs have to be 
* copied and pasted into the Word file (select the graph window 
* (click blue bar on top).
* You may need to change the directory


log using "C:\example assignment.log", replace


* We start closing any previous dataset
clear

* We open the dataset:
* you may need to change the directory

use "C:\data1.dta"


* Begin by describing the dataset:

des
sum houseprice perc_private density inc_per_cap P_00_14_jr P_15_24_jr P_25_44_jr P_45_64_jr P_65_eo_jr Rotterdam
tab perc_privat_cat
tab Rotterdam

*gen new2=2


* Change the name of the variable inc_per_cap

rename inc_per_cap income


*******************************************************
* Nonlinearities: compare the interpretation of the different models 
*******************************************************

* Note: we use heteroskedasticy-robust standard erros (option robust) 

* Model in levels

reg houseprice income, robust

* Interpretation: one additional unit of x increases y by b1 units, ceteris paribus. 

* Test the null hypothesis that the coefficient of income is equal to 13.5

test income=13.5


* Model log-log

gen lnhouseprice=ln(houseprice)
gen lnincome=ln(income)

reg lnhouseprice lnincome, robust

* Interpretation: a 1% increase in x (not log of x) increases y (not log of y) by b1%, ceteris paribus [elasticity]

* Model log-level

reg lnhouseprice income, robust

* Interpretation: one additional unit of x increases y by [100*(exp(b1)-1)]%, ceteris paribus [semi-elasticity]
* See section 6.2 in Wooldridge

display 100*(exp(_b[income])-1)

*Note: if we are interested in other changes in x, the exact formula would be:
* if x changes by D units, y changes by [100*(exp(b1*D)-1)]%, ceteris paribus 


* Model level-log

reg houseprice lnincome, robust

display _b[lnincome]*ln(1.01)

* Interpretation: a 1% increase in x (not in log of x) increases y by (b1*ln(1.01)) units, ceteris paribus
* Note: You may see (and use) an approximation as a 1% increase in x increases y by b1/100 units, ceteris paribus. 
* b1/100  is an approximation based on the Taylor expansion of ln(1.01)=0.01 [ln(1.01=00995033)]
* which leads you to _b[income]*0.01. The approximation is only "good" if you interpret a 1% increase in your independent variable, 
* However if you go to larger values, e.g. a 10% increase in x, the approximation works less well.  

* In general, as x changes from X1 to X2, y changes by b1*[ln(X2)-ln(X1)] units. A p% increase in x, changes y by (b1*ln(1+p/100)) 


* Models with quadratics

gen income2=income^2

reg houseprice income income2, robust

* Let's look at the prediction 

predict houseprice_predicted

scatter houseprice_predicted income


* The slope of the relationship between x and y depends on the value of x
* The estimated slope is b_income+2*b_income2*income 

* What is the estimated effect at the average income per capita?

sum income 

display [_b[income]+2*_b[income2]*r(mean)]



***************************************************************
*** DUMMY VARIABLES: BINARY AND CATEGORICAL VARIABLES *********
***************************************************************

* Are house prices in Rotterdam different than in the rest of the country?

reg houseprice income Rotterdam, robust

* Obtain the predicted values of this last model 
* Notice that every time that you use the command predict, Stata uses the results from the last model that you run
* So you need to make sure that the last estimated model is the one you are interested in

predict housepricep2

* Create a scatter plot with predicted houseprices on the y-axis and per capita income on the x-axis 

scatter housepricep2 income

* Is the effect of income the same in Rotterdam and in other regions?

* Include an interaction

* First, we create the interaction

gen income_Rotterdam=income*Rotterdam

*** How does this new variable look like? Have a look at the data browser. 

reg houseprice income Rotterdam income_Rotterdam, robust

predict housepricep3

scatter housepricep3 income


* When can we include the two categories of a binary variable? 

**** Create a variable that takes value 1 if other and 0 if Rotterdam

gen other=Rotterdam==0 if Rotterdam!=.

reg houseprice income Rotterdam, robust
reg houseprice income other, robust
reg houseprice income Rotterdam other, robust
reg houseprice income Rotterdam other, robust nocons

* Compare the values of the estimates for Rotterdam, other and the constant in the previous models



* Now include the categorical variable percentage of privately owned dwellings (perc_privat_cat) in the model without interaction
* and without Rotterdam dummy

tab perc_privat_cat

tab perc_privat_cat, gen(dperc_privat)

reg houseprice income dperc_privat1 dperc_privat2 dperc_privat3, robust


* How does the predicted variable and its correlation with income looks like? 

predict housepricep4

scatter housepricep4 income


*  Are these dummies jointly significant?

test dperc_privat1 dperc_privat2 dperc_privat3


* Are there differences in the house prices between neighbourhoods with less than 25% and those with 25-50% with private owners?

test dperc_privat1=dperc_privat2


*****************************
*** MODEL SELECTION *********
*****************************

* Which model fits the data better: a model with or without the dummies capturing the percentage of privately owned dwellings? 

reg houseprice income dperc_privat1 dperc_privat2 dperc_privat3, robust
reg houseprice income, robust

* Compare R2, Adjusted-R2 and F-test


**** Is the functional form correctly specified? Reset test

reg houseprice income dperc_privat1 dperc_privat2 dperc_privat3 Rotterdam, robust
ovtest

reg houseprice income income2 dperc_privat1 dperc_privat2 dperc_privat3 Rotterdam, robust
ovtest

gen income3=income^3
reg houseprice income income2 income3 dperc_privat1 dperc_privat2 dperc_privat3 Rotterdam, robust
ovtest


************************************************************
* Other useful commands
****************************************************************

* Average income for individuals living in Rotterdam and in other areas

sum income if Rotterdam==1
sum income if Rotterdam==0


* What is the correlation between house price and per capita income?

pwcorr houseprice income

* If you want to learn more about the different options of one command, you can look into help

help pwcorr

* Make a plot of the distribution of the dependent variable (histogram)

* Show frequencies

hist houseprice, frequency

* Show fractions

hist houseprice, fraction


* And if you want to change how the graph looks like:

scatter houseprice income, xlabel(0(10)80) ylabel(0(500)2000) ytitle("House price, in 1000 Euro") xtitle("Income per capita, in 1000 Euro")


* We define the dependent variable in 100,000 (it is currently in 1000)

gen houseprice_100=houseprice/100

*Obtain adjusted R-squared with robust standard errors

reg houseprice income, robust
di e(r2_a)

* Do not forget to close your log-file before leaving

log close



© 2025 Erasmus University Rotterdam, All rights reserved. No text and datamining




