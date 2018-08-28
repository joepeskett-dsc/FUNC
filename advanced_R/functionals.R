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