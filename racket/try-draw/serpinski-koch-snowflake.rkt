#lang postfix-dot-notation sweet-exp racket/base

provide (all-defined-out)

require racket/class
        racket/draw
        racket/list
        racket/math
        syntax/parse/define
        my-cond/iffy
        "../posn.rkt"
        "../utils.rkt"

;; add-simple-lines! : DC Color [Posn Posn] ... -> Void
define-simple-macro
  add-simple-lines! dc-expr:expr color-expr:expr
    start-expr:expr stop-expr:expr
    ...
  let ([dc dc-expr] [color color-expr])
    for ([start in-list(list(start-expr ...))]
         [stop  in-list(list(stop-expr  ...))])
      add-simple-line! dc color start stop

;; add-simple-line! : DC Color Posn Posn -> Void
define
  add-simple-line! dc color p1 p2
  send dc set-brush color 'solid
  send dc draw-line p1.x p1.y p2.x p2.y

;; TODO: actually put the extra Koch spiky bits onto it

;; serpinski-koch-snowflake : Positive-Real -> Bitmap
define (serpinski-koch-snowflake w #:cutoff [line-cutoff default-line-cutoff])
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
  add-simple-lines! dc "black"
    bottom-left top
    top bottom-right
    bottom-right bottom-left
    top-left top-right
    top-right bottom
    bottom top-left
  define middle              {top + {1/2 * {top ∆ bottom}}}
  define top-middle-left     {top-left + {1/3 * {top-left ∆ top-right}}}
  define top-middle-right    {top-right + {1/3 * {top-right ∆ top-left}}}
  define middle-left         {bottom-left + {1/3 * {bottom-left ∆ top}}}
  define middle-right        {bottom-right + {1/3 * {bottom-right ∆ top}}}
  define bottom-middle-left  {bottom-left + {1/3 * {bottom-left ∆ bottom-right}}}
  define bottom-middle-right {bottom-right + {1/3 * {bottom-right ∆ bottom-left}}}
  add-serpinski-triangles! dc "black" #:cutoff line-cutoff
    top top-middle-left top-middle-right
    middle top-middle-left top-middle-right
    top-right top-middle-right middle-right
    middle top-middle-right middle-right
    bottom-right middle-right bottom-middle-right
    middle middle-right bottom-middle-right
    bottom bottom-middle-right bottom-middle-left
    middle bottom-middle-right bottom-middle-left
    bottom-left middle-left bottom-middle-left
    middle middle-left bottom-middle-left
    top-left middle-left top-middle-left
    middle middle-left top-middle-left
  bm

;; add-serpinski-triangles! :
;; DC Color #:cutoff Positive-Real [Posn Posn Posn] ... -> Void
define-simple-macro
  add-serpinski-triangles! dc-expr:expr color-expr:expr #:cutoff line-cutoff
    top-expr:expr left-expr:expr right-expr:expr
    ...
  let ([dc dc-expr] [color color-expr])
    for ([top   in-list(list(top-expr   ...))]
         [left  in-list(list(left-expr  ...))]
         [right in-list(list(right-expr ...))])
      add-serpinski-triangle! dc color top left right #:cutoff line-cutoff

;; add-serpinski-triangle! : DC Color Posn Posn Posn #:cutoff Positive-Real -> Void
define (add-serpinski-triangle! dc color top left right
                                #:cutoff [line-cutoff default-line-cutoff])
  my-cond
    if {{distance(top left) <= line-cutoff}
        or {distance(top right) <= line-cutoff}
        or {distance(left right) <= line-cutoff}}
      add-simple-lines! dc color
        top left
        top right
        left right
    else
      define bottom       {left + {1/2 * {left ∆ right}}}
      define middle-left  {left + {1/2 * {left ∆ top}}}
      define middle-right {right + {1/2 * {right ∆ top}}}
      add-serpinski-triangles! dc color #:cutoff line-cutoff
        top middle-left middle-right
        middle-left left bottom
        middle-right bottom right

#|
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
|#
