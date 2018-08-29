#Disclaimer - this is taken from Hadley Wickham's advanced R, which can be found
#here: http://adv-r.had.co.nz/Functional-programming.html?. This is intended
#onlt to store my own answers and notes.

#Quote - "complicated control flows confuse programmers. Messy code often hides
#bugs.

#Higher order functions: a function that takes a function as an input or returns
#a function as an output. A closure is an example of this. A functional instead
#takes a function as an input.

#Example:
randomise <- function(f) f(runif(1e3))
randomise(mean);randomise(mean);randomise(mean)
randomise(summary)
#Here you can see that the randomise function takes a function and gives it the
#argument runif(1e3). The apply family is a good example of functionals that we
#often use.

#AVOIDING LOOPS! Functionals are often used as a method for avoiding loops in R.
#For loops have a particularly bad reputation in R for being slow, though this 
#is only part of the story. Regardless, it's usually better to use a functional 
#than a for loop. They are also useful for common tasks such as
#split-apply-combine.

#Many functionals are written in C, making them faster. More importantly it
#helps to make clear what you are trying to do - speed can be dealt with later.

#The simplest functional is lapply. It applies a function to each component of a
#list, and then puts all the results in a list. It is written in C for
#performance purposes, but we can make our own version in R.

my_lapply <- function(x, f, ...){
    out <- vector("list", length(x))
    for (i in seq_along(x)){
        out[[i]] <- f(x[[i]], ...)
    }
    out
}
#From this we can see that lapply is a wrapper for a looping pattern. (We can
#use unlist() to take the output of lapply into a vector).

lapply(mtcars, class)
unlist(lapply(mtcars, class))
#-------------------------------------------------------------------------------

#Looping patterns. For speed it is best to create an object of the correct
#length to start with and then fill each component as required.

#Exercise: use both loops and lapply to fit these linear models of the mtcars
#data.
formulas <- c(
    mpg ~ disp,
    mpg ~ I(1 / disp),
    mpg ~ disp + wt,
    mpg ~ I(1 / disp) + wt
)
attach(mtcars)
output <- numeric(length(formulas))
for (i in seq_along(formulas)){
    output[i] <- lm(formula = formulas[[i]], data = mtcars)
}

output_comp <- lapply(formulas, lm, data =mtcars)


#For loop functionals. Here there's a discussion on various other forms.sapply
#and vapply have different outputs, usually a vector or matrix.

#Map() and mapply() - this allows for multiple inputs. 

mt_means <- lapply(mtcars, mean) #Notice that the function comes second!
mt_means <- Map('/', mtcars, mt_means) # notice that the function comes first!
#while this is equivelent to 
mt_means_comp <- lapply(mtcars, function(x) x/mean(x))
#The first form is easier to check and also more obvious what we are trying to
#do. Becomes much more useful when you are doing more complex computations. 

#mapply() apparently adds additional complications, so is not discussed. 
#-------------------------------------------------------------------------------
#Rolling computations. 

#When something doesn't exist in base R you can usually create your own wrapper 
#in R. 
#The example here is a rolling mean function for smoothing some data.
#Below is an example that allows different summaries to be used.

rollapply <- function(x, n, f, ...) {
    out <- rep(NA, length(x))
    
    offset <- trunc(n / 2)
    for (i in (offset + 1):(length(x) - n + offset + 1)) {
        out[i] <- f(x[(i - offset):(i + offset - 1)], ...)
    }
    out
}
plot(x)
lines(rollapply(x, 5, median), col = "red", lwd = 2)

#Where the for loop exists, we can replace it with vapply. According to the
#author, this is extremely simliar to the zoo::rollapply() function.
library(zoo)
?rollapply
#Note to self - this could be really handy. 
#At this point there is a discussion
#on parallelisation, which I'm not going to cover.

# Matrices and Dataframes. 

#We need to be able to deal with more complex data structures. 
#Matrix and array operations:

#apply() works with matrices and arrays. Here we need to specify the MARGIN, 1 =
#rows, 2 = columns. 
a <- matrix(1:20, nrow = 5)
apply(a, 1, mean)
apply(a, 2, mean)

#The difficulty in using this is that you often aren't sure what sort of output 
#you're going to get. This means it is not well suited to being used in new
#functions. It is also not idempotent(?).

#outer() is another interesting function, taking multiple vector inputs and
#creates a matrix or array where the function is run over every combination of
#inputs. Example below:

outer(1:5, 5:10, "*")

#Group apply

#tapply can be used where there is a differing number of columns between rows.It
#works by creating a ragged data structure of inputs and then applying the 
#function to each of these. This is actually what the split() function does.
#Therefore a new tapply() function can be created like so:

my_tapply <- function(x,group, f, ..., simplify = TRUE){
    pieces <- split(x, group)
    sapply(pieces, f, ..., simplify = simplify)
}

#PLYR! Issue with the base functionals is that they have developed over time and
#are not particularly consistent.

#In plyr the first two letters indicate the input and output structure
#respectively. For example dlply takes a dataframe, applies a function to each
#column and then returns a list.

# Manipulating lists. 

# Reduce()

#Reduces a vector to a single value by recursively calling a function,f, two
#functions at a time.It looks like this:
#Reduce(f, 1:3) => f(f(1,2),3)
#Reduce is known as a fold also. It can be rewritten like so:

my_reduce <- function(f,x){
    out <- x[[1]]
    for (i in seq(2, length(x))){
        out <- f(out, x[[i]])
    }
    out
}
#Reduce() is actually more complicated as it has more control functionality.

# Predicate functionals. 

#A function that returns a single TRUE or FALSE. There a three useful predicates
#in base R. 
#Filter() selects only elements that match the predicate.
#Find() selects the first element that matches the predicate.
#Position() returns the position of the first element that matches the predicate. 
#Another useful one is where.

where <- function(f, x){
    vapply(x, f, FUN.VALUE = logical(1))
}
df <- data.frame(x = 1:3, y = c("a", "b", "c"))
where(is.factor, df)

#Implement Any()

Any <- function(f, x){
    any(where(f,x))
}
#Implement All()

All <- function(f,x){
    all(where(f,x))   
}


#Mathematical functions:

#Functionals are very common in mathematics. Here we'll look at 3, though it's
#not obvious how these help to avoid loops.

#integrate() finds the area under a curve defined by f()
#uniroot finds where f() hits zero
#optimise() finds the location of the lowest of highest value of f()

#In stats optimisation is often used for maximum liklihood estimation (MLE). In 
#MLE we have two parameters - the data and the parameters which vary as we try 
#to find the maxuimum. The data are fixed. Closures lend themselves to being
#helpful for this problem.

#The following example shows how we might find the MLE. We need a function 
#factory that returns a functions that comptes the negative log liklihood (NLL) 
#for parameter llambda. (We're using a poisson distribution).We often use NLL as
#optimise defaults to finding minimum in R.

poisson_nll <- function(x){
    n <- length(x)
    sum_x <- sum(x)
    function(lambda){
        n * lambda - sum_x * log(lambda)
    }
}

#Note what is happening here - when we create a new function with the
#poission_nll function, the data is fixed in the execution environment, which is
#saved by the created function's enclosing environment.

#We can then use the optimise() function to find the best values given a range
#of inputs for lambda.

#optim() is another useful function, that works in more than one dimension. For 
#interest, there is a version of optim writen in pure R in the Rvmin
#package.Interestingly, this runs no slower, even though base optim() is written
#in C.

#Exercises:

#implement arg_max()

arg_max <- function(x, f){
    x[f(x)==max(f(x))]
}


#-------------------------------------------------------------------------------
#Loops that can and should be left:
#modiying in place,
#recursive functions, 
#while loops

#Modifyingin place: if you are transforming a data frame and each variable is
#undergoing a different functional transformation, a for loop still may be best,
#with the differnt functions given different names in a list.

#Recurrent relationships can make it hard to express a loop as a functional. For
#example, taking a weighted average. You can solve the recurrence relation, but
#this requires a new set of tools which will be tackled later.

#While loops

#While loops are more general the for loops - all for loops can be written as
#while loop, but this relationship is not true in reverse. 
for (i in 1:10) print(i)

i <- 1
while (i <= 10){
    print(i)
    i <- i+1
}
# The difficulty is many while loops do not know how many while loops don't know
# how many times they'll be run.

i <- 0
while(TRUE){
    if(runif(1) > 0.9) break
    i <- i+1
}

#This problem is common in simulations. In some cases, loops can be removed by 
#recognising special features in problems. In the example above we're counting 
#the number of successes before bernouli trial with p=0.1 fails. This is a 
#geometric random variable so can be replaced. This can often be difficult to
#do, but there are often substantial benefits to doing this.

# A family of functions:

add <- function(x,y){
    stopifnot(length(x) == 1, length(y) ==1, is.numeric(x), is.numeric(y))
    x+y
}
rm_na <- function(x,y,identity){
    if(is.na(x) && is.na(y)){
        identity
    }else if(is.na(x)){
        y
    }else{
        x
    }
}
add <- function(x,y,na.rm = FALSE){
    if(na.rm && (is.na(x) || is.na(y)))rm_na(x,y,0) else x+y
}
add(9,NA, na.rm = TRUE)
add(10,10)

#at this point we have a basic function that can add two numbers together and 
#deal with NA values. How can we expand this to deal with more than two numbers.

r_add <- function(xs, na.rm = TRUE){
    Reduce(function(x,y)add(x,y,na.rm = na.rm), xs)
}
r_add(c(1,4,10))

#Good. Does it still work with special cases?
r_add(NA, na.rm = TRUE)
#While not a major problem, it's incorrect. If we give Reduce() a vector of 
#length 1, it can't reduce it so returns it's input. We can over come this with
#the init argument.

r_add <- function(xs, na.rm = TRUE){
    Reduce(function(x,y)add(x,y,na.rm = na.rm), xs, init = 0)
}
r_add(c(1,4,10))
r_add(NA, na.rm = T)

#It would also be nice to vectorise this, meaning that we can give multiple
#vectors as the objects to be added together.Let's have a look at some options. 

v_add1 <- function(x,y,na.rm = FALSE){
    stopifnot(length(x) == length(y), is.numeric(x), is.numeric(y))
    if (length(x) == 0) return(numeric())
    simplify2array(
        Map(function(x,y)add(x,y,na.rm = na.rm), x, y)
    )
}
v_add2 <- function(x, y, na.rm = FALSE){
    stopifnot(length(x) == length(y), is.numeric(x), is.numeric(y))
    vapply(seq_along(x), function(i) add(x[i], y[i], na.rm = na.rm),
    numeric(1))
}
v_add1(1:10, 1:10)
v_add2(1:10, 1:10)

#Exercises: 
#Implement smaller and larger functions that given two inputs return
#either the smaller or larger.

smaller <- function(x,y,na.rm = T){}

larger <- function(x,y,na.rm = T){}