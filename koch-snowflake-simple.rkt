#lang postfix-dot-notation sweet-exp racket/base

provide snowflake
        add-k-lines
        add-k-line

require 2htdp/image
        racket/local
        racket/match
        racket/list
        syntax/parse/define
        my-cond/iffy
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
  add-k-lines MTS #:cutoff line-cutoff
    bottom-left top
    top bottom-right
    bottom-right bottom-left

;; add-k-lines : Image #:cutoff PosReal [Posn Posn] ...  -> Image
define-simple-macro
  add-k-lines img-expr #:cutoff line-cutoff-expr
    start-expr stop-expr
    ...
  let ([line-cutoff line-cutoff-expr])
    for/fold ([img img-expr]) ([start in-list(list(start-expr ...))]
                               [stop  in-list(list(stop-expr  ...))])
      add-k-line img start stop #:cutoff line-cutoff

define (add-k-line img p1 p2 #:cutoff line-cutoff)
  my-cond
    if {distance(p1 p2) <= line-cutoff}
      add-simple-lines/color img "black"
        p1 p2
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
      add-k-lines img #:cutoff line-cutoff
        p1 mid-left
        mid-left top
        top mid-right
        mid-right p2

