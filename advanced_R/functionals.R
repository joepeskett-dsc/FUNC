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