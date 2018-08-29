#Function Operators - They take functions in and push functions out. In some
#ways they're quite similar to functionals - there's nothing you can't do
#without then but they make the code more readable and expressive(?).

chatty <- function(f){
    function(x,...){
        res <- f(x,...)
        cat("Processing", x, "\n", sep = " ")
        res
    }
}
f <- function(x)x^2
s <- c(3,2,1)
chatty(f)(10)
vapply(s, chatty(f), numeric(1))

#We've seen that built in functionals have very few arguments so we needed to be
#clever in the way we used them. For example we used anonymous functions:

Map(function(x,y)f(x,y,zs),xs,ys)

#Later we'll learn about partial application; this encapsulationthe use of an
#anonymous function to supply default arguments, and allows us to write succinct
#code:

Map(partial(f, zs = zs), xs, ys)

#This is an important use of FOs. This will show a selection of FO techniques -
#we'll need a few packages for this:
install.packages("memoise")
install.packages("plyr")
install.packages("pryr")

#Behavioural FOs leave inputs and outputs unchanged but add some functionality. 
#Add a delay to avoid swamping server with requests
#Print to console every n invocations to check running process
#Cache previous computations to improve performance

#Imagine we want to download a long vector of URLs - pretty simple with lapply. 
download_file <- function(url, ...){
    download.file(url, basename(url), ...)
}
lapply(urls, download_file)

#There are some useful behaviours we might want to add here. With a long list, 
#we might want to print something after every 10 URLs to check everything's 
#still working properly. We might want to put a small delay between requests to 
#avoid hammering the server. This makes things a little difficult using a for
#loop and we can't use lapply. because an external counter is required.