#lang postfix-dot-notation sweet-exp racket/base

provide (all-defined-out)

require racket/class
        racket/draw
        racket/list
        racket/math
        syntax/parse/define
        my-cond/iffy
        "../koch-snowflake-inner-fractal.rkt"
        "../posn.rkt"
        "../utils.rkt"

;; add-simple-lines/color/draw! : DC Color [Posn Posn] ... -> Void
define-simple-macro
  add-simple-lines/color/draw! dc-expr:expr color-expr:expr
    start-expr:expr stop-expr:expr
    ...
  let ([dc dc-expr] [color color-expr])
    for ([start in-list(list(start-expr ...))]
         [stop  in-list(list(stop-expr  ...))])
      add-simple-line/color/draw! dc start stop color

;; add-simple-line/color/draw! : DC Posn Posn Color -> Void
define
  add-simple-line/color/draw! dc p1 p2 color
  send dc set-brush color 'solid
  send dc draw-line p1.x p1.y p2.x p2.y

;; snowflake/inner-fractal/draw : Positive-Real -> Bitmap
define (snowflake/inner-fractal/draw n #:cutoff [line-cutoff default-line-cutoff])
  (snowflake/inner-fractal/multi-color/draw n '("black") #:cutoff line-cutoff)

;; snowflake/inner-fractal/multi-color/draw : Positive-Real (Listof Color) -> Bitmap
;; example: (snowflake/inner-fractal/multi-color/draw 500 '("red" "green"))
define (snowflake/inner-fractal/multi-color/draw w colors #:cutoff [line-cutoff default-line-cutoff])
  define h {w * 4/3 * √3/2}
  ;; r1 = h/2
  ;; r2 = r1*h/a = r1*2/√3 = r1/[cos(30o)]
  ;; r3 = r2*h/a = 
  define m {10 + {1/2 * {w / 2}}}
  define bm 
    make-bitmap(exact-ceiling{m + w + m} exact-ceiling{m + h + m})
  define dc
    send bm make-dc
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
  for ([color (in-list reverse(colors))]
       [layer (in-list reverse(range(length(colors))))])
    my-cond
      if (equal? "transparent" color)
        void()
      else
        add-k-lines/inner-fractal/layer/draw! dc layer color #:cutoff line-cutoff
          bottom-left top
          top bottom-right
          bottom-right bottom-left
        when {layer = 0}
          add-simple-lines/color/draw! dc color
            top-left top-right
            top-right bottom
            bottom top-left
  bm

;; add-k-lines/inner-fractal/layer/draw! :
;; DC Natural Color #:cutoff PosReal [Posn Posn] ...  -> Void
define-simple-macro
  add-k-lines/inner-fractal/layer/draw! dc-expr layer-expr color-expr #:cutoff line-cutoff-expr
    start-expr stop-expr
    ...
  let ([dc dc-expr] [layer layer-expr] [color color-expr] [line-cutoff line-cutoff-expr])
    for ([start in-list(list(start-expr ...))]
         [stop  in-list(list(stop-expr  ...))])
      add-k-line/inner-fractal/layer/draw! dc start stop layer color #:cutoff line-cutoff

;; add-half-k-lines/inner-fractal/layer/draw! :
;; DC Natural Color #:cutoff PosReal [Posn Posn] ...  -> Void
define-simple-macro
  add-half-k-lines/inner-fractal/layer/draw! dc-expr layer-expr color-expr #:cutoff line-cutoff-expr
    start-expr stop-expr
    ...
  let ([dc dc-expr] [layer layer-expr] [color color-expr] [line-cutoff line-cutoff-expr])
    for ([start in-list(list(start-expr ...))]
         [stop  in-list(list(stop-expr  ...))])
      add-half-k-line/inner-fractal/layer/draw! dc start stop layer color #:cutoff line-cutoff

;; add-k-line/inner-fractal/layer/draw! : DC Posn Posn Natural Color #:cutoff PosReal -> Void
define (add-k-line/inner-fractal/layer/draw! dc p1 p2 layer color #:cutoff line-cutoff)
  add-half-k-lines/inner-fractal/layer/draw! dc layer color #:cutoff line-cutoff
    p1 p2
    p2 p1

;; add-half-k-line/inner-fractal/layer/draw! :
;; DC Posn Posn Natural Color #:cutoff PosReal -> Void
define (add-half-k-line/inner-fractal/layer/draw! dc p1 p2 layer color #:cutoff line-cutoff)
  define ∆p (∆ p1 p2)
  define mid-point
    {p1 + {1/2 * ∆p}}
  define top
    {mid-point + {√3/6 * (posn ∆p.y (- ∆p.x))}}
  define mid-left
    {p1 + {1/3 * ∆p}}
  define mid-right
    {mid-left + {1/3 * ∆p}}
  my-cond
    if {layer = 0}
      add-simple-lines/color/draw! dc color
        p1 p2
    else
      add-half-k-lines/inner-fractal/layer/draw! dc {layer - 1} color #:cutoff line-cutoff
        p1 top
        top p2
  my-cond
    if {distance(p1 p2) <= line-cutoff}
      void()
    else
      add-k-lines/inner-fractal/layer/draw! dc layer color #:cutoff line-cutoff
        p1 mid-left
        mid-left top
        top mid-right
        mid-right p2

