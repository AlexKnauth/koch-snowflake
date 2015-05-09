#lang postfix-dot-notation sweet-exp racket/base

provide snowflake/inner-fractal
        snowflake/inner-fractal/multi-color
        add-k-lines/inner-fractal/layer
        add-half-k-lines/inner-fractal/layer
        add-k-line/inner-fractal/layer
        add-half-k-line/inner-fractal/layer

require 2htdp/image
        racket/local
        racket/match
        racket/list
        syntax/parse/define
        my-cond/iffy
        "posn.rkt"
        "utils.rkt"

;; snowflake/inner-fractal : Positive-Real -> Image
define (snowflake/inner-fractal n #:cutoff [line-cutoff default-line-cutoff])
  (snowflake/inner-fractal/multi-color n '("black") #:cutoff line-cutoff)

;; snowflake/inner-fractal/multi-color : Positive-Real (Listof Color) -> Image
;; example: (snowflake/inner-fractal/multi-color 500 '("red" "green"))
define (snowflake/inner-fractal/multi-color w colors #:cutoff [line-cutoff default-line-cutoff])
  define h {w * 4/3 * √3/2}
  ;; r1 = h/2
  ;; r2 = r1*h/a = r1*2/√3 = r1/[cos(30º)]
  ;; r3 = r2*h/a = 
  define m {10 + {1/2 * {w / 2}}}
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
  define top-left
    posn m
         {m + {1/4 * h}}
  define top-right
    posn {m + w}
         {m + {1/4 * h}}
  define bottom
    posn {m + {1/2 * w}}
         {m + h}
  for/fold ([img MTS]) ([color (in-list reverse(colors))]
                        [layer (in-list reverse(range(length(colors))))])
    my-cond
      if (equal? "transparent" color)
        img
      define img+k-lines
        add-k-lines/inner-fractal/layer img layer color #:cutoff line-cutoff
          bottom-left top
          top bottom-right
          bottom-right bottom-left
      else-if {layer = 0}
        add-simple-lines/color img+k-lines color
          top-left top-right
          top-right bottom
          bottom top-left
      else img+k-lines

;; add-k-lines/inner-fractal/layer :
;; Image Natural Color #:cutoff PosReal [Posn Posn] ...  -> Image
define-simple-macro
  add-k-lines/inner-fractal/layer img-expr layer-expr color-expr #:cutoff line-cutoff-expr
    start-expr stop-expr
    ...
  let ([layer layer-expr] [color color-expr] [line-cutoff line-cutoff-expr])
    for/fold ([img img-expr]) ([start in-list(list(start-expr ...))]
                               [stop  in-list(list(stop-expr  ...))])
      add-k-line/inner-fractal/layer img start stop layer color #:cutoff line-cutoff

;; add-half-k-lines/inner-fractal/layer :
;; Image Natural Color #:cutoff PosReal [Posn Posn] ...  -> Image
define-simple-macro
  add-half-k-lines/inner-fractal/layer img-expr layer-expr color-expr #:cutoff line-cutoff-expr
    start-expr stop-expr
    ...
  let ([layer layer-expr] [color color-expr] [line-cutoff line-cutoff-expr])
    for/fold ([img img-expr]) ([start in-list(list(start-expr ...))]
                               [stop  in-list(list(stop-expr  ...))])
      add-half-k-line/inner-fractal/layer img start stop layer color #:cutoff line-cutoff


;; add-k-line/inner-fractal/layer : Image Posn Posn Natural Color #:cutoff PosReal -> Image
define (add-k-line/inner-fractal/layer img p1 p2 layer color #:cutoff line-cutoff)
  add-half-k-lines/inner-fractal/layer img layer color #:cutoff line-cutoff
    p1 p2
    p2 p1


;; add-half-k-line/inner-fractal/layer :
;; Image Posn Posn Natural Color #:cutoff PosReal -> Image
define (add-half-k-line/inner-fractal/layer img p1 p2 layer color #:cutoff line-cutoff)
  define ∆p (∆ p1 p2)
  define mid-point
    {p1 + {1/2 * ∆p}}
  define top
    {mid-point + {√3/6 * (posn ∆p.y (- ∆p.x))}}
  define mid-left
    {p1 + {1/3 * ∆p}}
  define mid-right
    {mid-left + {1/3 * ∆p}}
  define img2
    my-cond
      if {layer = 0}
        add-simple-lines/color img color
          p1 p2
      else
        add-half-k-lines/inner-fractal/layer img {layer - 1} color #:cutoff line-cutoff
          p1 top
          top p2
  my-cond
    if {distance(p1 p2) <= line-cutoff}
      img2
    else
      add-k-lines/inner-fractal/layer img2 layer color #:cutoff line-cutoff
        p1 mid-left
        mid-left top
        top mid-right
        mid-right p2

