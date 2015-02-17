#lang sweet-exp racket/base

provide snowflake
        add-k-lines
        add-k-line

require 2htdp/image
        racket/local
        racket/match
        racket/list
        postfix-dot-notation
        "posn.rkt"
        "utils.rkt"

;; snowflake : Positive-Real -> Image
;; a function to combine lines into snowflake
define (snowflake w #:cutoff [line-cutoff default-line-cutoff])
  define h {w * 4/3 * √3/2}
  define m 10
  define MTS 
    rectangle({m + w + m} {m + h + m} 0 "transparent")
  define bottom-left
    posn m
         {m + {3/4 * h}}
  define bottom-right
    posn {m + w}
         {m + {3/4 * h}}
  define top
    posn {m + {1/2 * w}}
         m
  (add-k-lines
   MTS
   bottom-left top
   top bottom-right
   bottom-right bottom-left
   #:cutoff line-cutoff)

;; add-k-lines : Image Posn Posn ... ... #:cutoff PosReal -> Image
define (add-k-lines scene #:cutoff line-cutoff . rst-args)
  match rst-args
    [(list) scene]
    [(list-rest start stop rst)
     (apply add-k-lines (add-k-line scene start stop #:cutoff line-cutoff) rst #:cutoff line-cutoff)]

define (add-k-line img p1 p2 #:cutoff line-cutoff)
  cond
    {distance(p1 p2) <= line-cutoff}
      (add-simple-line/color img p1 p2 "black")
    else
      define ∆p (∆ p1 p2)
      define mid-point
        {p1 + {1/2 * ∆p}}
      define top
        {mid-point + {√3/6 * (posn ∆p.y (- ∆p.x))}}
      define mid-left
        {p1 + {1/3 * ∆p}}
      define mid-right
        {mid-left + {1/3 * ∆p}}
      (add-k-lines
       #:cutoff line-cutoff
       img
       p1 mid-left
       mid-left top
       top mid-right
       mid-right p2)

