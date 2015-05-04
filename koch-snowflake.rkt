#lang sweet-exp racket/base

provide
      all-from-out 
        "koch-snowflake-simple.rkt"
        "koch-snowflake-inner-fractal.rkt"

require 2htdp/image
        racket/list
        "koch-snowflake-simple.rkt"
        "koch-snowflake-inner-fractal.rkt"
        "posn.rkt"
        "utils.rkt"

module+ test
  require syntax/parse/define
  define-simple-macro
    images img-expr:expr ...
    begin 
      let ()
        printf("time(img-expr)    : ")
        define img time(img-expr)
        printf("time(freeze(img)) : ")
        time(freeze(img))
      ...
  images
    add-k-line empty-scene(1020 520) #:cutoff default-line-cutoff
               posn(10 510)
               posn(1010 510)
    snowflake/inner-fractal/multi-color 100 '("transparent" "transparent" "purple") #:cutoff 58
    snowflake/inner-fractal/multi-color 100 '("transparent" "purple") #:cutoff 30
    snowflake/inner-fractal/multi-color 100 '("transparent" "purple") #:cutoff 12
    snowflake/inner-fractal/multi-color 100 '("transparent" "transparent" "purple") #:cutoff 12
    snowflake/inner-fractal/multi-color 100 '("transparent" "transparent" "purple") #:cutoff 11
    snowflake/inner-fractal/multi-color 100 append[make-list(3 "transparent") '("purple")] #:cutoff 12
    snowflake/inner-fractal/multi-color 100 append[make-list(4 "transparent") '("purple")] #:cutoff 12
    snowflake/inner-fractal/multi-color 100 append[make-list(5 "transparent") '("purple")] #:cutoff 12
    snowflake/inner-fractal/multi-color 100 '("red" "orange" "yellow" "green" "blue" "purple" "black")
                                        #:cutoff +inf.0
    snowflake 728
    snowflake/inner-fractal 728
    snowflake/inner-fractal/multi-color 150 '("transparent" "black") ; inside-out-ish
    snowflake/inner-fractal/multi-color 500 '("red" "green") #:cutoff 12 ; 2-color
    snowflake/inner-fractal/multi-color 500 '("red" "blue" "green") #:cutoff 12 ; 3-color
    snowflake/inner-fractal/multi-color 100 '("red" "blue" "green" "orange") #:cutoff 12 ; 4-color
    snowflake/inner-fractal/multi-color 500 '("red" "orange" "yellow" "green" "blue" "purple")
                                        #:cutoff 10 ; 6-color
    snowflake/inner-fractal/multi-color 500 '("red" "transparent" "yellow" "green" "blue" "purple")
                                        #:cutoff 10 ; 6-color-minus-orange
    snowflake/inner-fractal/multi-color 500 '("red" "transparent" "yellow" "transparent" "green"
                                                    "transparent" "blue" "transparent" "purple")
                                        #:cutoff 10 ; 5-color-odd-layers
    

