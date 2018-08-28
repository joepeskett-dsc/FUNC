#======DISCLAIMER====== 

#This walk through is taken from Hadley Wickhams advanced R, which can be found
#here: http://adv-r.had.co.nz/Functional-programming.html. Answers here are for
#my personal reference.

#===============================================================================
#Motivating example: 
my_summary <- function(x){
    funs <- c(mean, median, sd, mad, IQR)
    lapply(funs, function(f) f(x, na.rm = TRUE))
}
my_summary(1:10)

#This is much easier than writing out idividual calls to each of the functions
#(mean, median etc.)

#Here we'll look at some of the required tools to be able program functionally. 

#Anonymous functions: these are functions that aren't given a name, they still 
#have formals, a body and a parent environment. One of the most common uses of
#anonymous functions is to create closures, that is functions made by other
#functions.

(function(x)x+3)(10)
#Here we are defining an anomymous function with a single argument x. The body 
#of the function is x+3. We then pass it 10 in parentheses, so the result 13 is
#given. Below, we show the body and formals of the function.

body(function(x)x+3) #body is x+3
formals(function(x)x+3) #formal is x

#Exercise/example

#create a function that will take the coefficient of variation for each column
#of mtcars
lapply(mtcars, function(x)(sd(x)/mean(x))) 


#Use anonymous functions to integrate some functions. 
integrate(function(x) (x^2)-x, 0, 10)
integrate(function(x) sin(x)+cos(x), -pi, pi)
integrate(function(x) exp(x), 10, 20)

#No {} used, which is good :)

#Closures: An object is data with functions; a closure is a function with data. 
#Closures can be functions that are written by functions; see the example below.

power <- function(exponent){
    function(x){
        x^exponent
    }
}

#Closures enclose the environment of it's parents and can access it's variables.
#This is useful as it allows different levels of parameters, parent level to
#control operation and child that does that actual work.

sqare <- power(2)
sqare

#When we print this function out then we just see that x ^ exponent. This
#changes when we se the following code:

as.list(environment(sqare))

#Here we can see that in the function's environment, exponent = 2. This is the
#function's enclosing environment.

#pryr::unenclose() can also be used here:
library(pryr)
unenclose(sqare)

#The parent environment of a closure is the execution environment of the 
#function it was created by. Execution environments are usually deleted after a 
#function completes. Functions capture their enclosing environments however.
#This means that when power creates sqare, sqare stores the execution
#environment.(Need to be careful to consider memory usage here!)

#Most functions in R are closures, all remember the environment that they were 
#created in, typically the global environment if you created them. Primitive 
#functions (written in C) are the exception to this rule. Function factories can
#be created with closures.

#Function factories:

#Mutable states: having variables at multiple levels allows maintenance of state
#across function invovations(?!). Basically this means a function can recall
#what a variable is stored as and maintain that value due to refreshing
#exectuion environments and keeping the enclosing environment constant.

#<<- is made use of here, which will keep looking up in further parents
#environments rather than <- that looks only in the current environment.

#Example below:

new_counter <- function(){
    i <- 0
    function(){
        i <<- i+1
        i
    }
}
count_one <- new_counter()
count_two <- new_counter()
count_one()
count_two()
count_one();count_one();count_one();count_one()
count_two()

#new_counter creates a new closure, and it's enclosing environment is run. This 
#closure maintains access to this enclosing environment. Because these will be
#different each time new_counter is run, different counters will have different
#enclosing environments.

#Counters avoid the fresh start problem by altering a variable in the enclosing 
#environment rather than it's local environment.Therefore the changes are
#preserved accross calls.

#This is a good way to create mutable states in R. When your code is complex,
#try reference classes.

#Example: create a function called pick that takes a number i and will subset an
#object x by i.

pick <- function(i){
    function(x){
        x[[i]]
    }
}
lapply(mtcars, function(x) x[[5]])
lapply(mtcars, pick(3))

#Lists of functions

#Functions can be stored as lists. This makes interacting with related functions
#easier, in the same way that dataframes makes interacting with similar vectors
#easier.

#Work through this example:
x <- 1:10
funs <- list(
    sum =sum,
    mean = mean,
    median = median 
)
lapply(funs, function(f) f(x))

# Here, lapply is applying a function to the list f. The anonymous function 
# within lapply takes a function from funs and applies it to x. This is
# exemplified further when we add the na.rm argument to the function call.

lapply(funs, function(f) f(x, na.rm = TRUE))

#Occasionally, we'll want to move a list of function to the global environment.
#There are a number of ways to do this, using with(), attach and list2env for
#starters.

#Exercises :

#Make a version of summary and then change it into a function factory:

my_summary <- function(x){
    funs <- list(mean = mean, median = median, sd = sd, mad = mad, IQR = IQR)
    lapply(funs, function(f) f(x, na.rm = TRUE))
}
my_summary(1:10)







