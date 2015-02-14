#lang sweet-exp racket/base

(provide snowflake/inner-fractal
         snowflake/inner-fractal/multi-color
         add-k-lines/inner-fractal/layer
         add-half-k-lines/inner-fractal/layer
         add-k-line/inner-fractal/layer
         add-half-k-line/inner-fractal/layer
         )

(require 2htdp/image
         racket/local
         racket/match
         racket/list
         postfix-dot-notation
         "posn.rkt"
         "utils.rkt"
         )

;; snowflake/inner-fractal : Positive-Real -> Image
(define (snowflake/inner-fractal n #:cutoff [line-cutoff default-line-cutoff])
  (snowflake/inner-fractal/multi-color n '("black") #:cutoff line-cutoff))

;; snowflake/inner-fractal/multi-color : Positive-Real (Listof Color) -> Image
(define (snowflake/inner-fractal/multi-color w colors #:cutoff [line-cutoff default-line-cutoff])
  (local [(define h {w * 4/3 * √3/2})
          ;; r1 = h/2
          ;; r2 = r1*h/a = r1*2/√3 = r1/[cos(30º)]
          ;; r3 = r2*h/a = 
          (define m {10 + {1/2 * {w / 2}}})
          (define MTS 
            (rectangle {m + w + m} {m + h + m} 0 "transparent"))
          (define bottom-left
            (posn m
                  {m + {3/4 * h}}))
          (define bottom-right
            (posn {m + w}
                  {m + {3/4 * h}}))
          (define top
            (posn {m + {1/2 * w}}
                  m))
          (define top-left
            (posn m
                  {m + {1/4 * h}}))
          (define top-right
            (posn {m + w}
                  {m + {1/4 * h}}))
          (define bottom
            (posn {m + {1/2 * w}}
                  {m + h}))]
    (for/fold ([img MTS]) ([color (in-list (reverse colors))]
                           [layer (in-list (reverse (range (length colors))))])
      (cond [(equal? "transparent" color) img]
            [else
             (define img+k-lines
               (add-k-lines/inner-fractal/layer
                #:cutoff line-cutoff
                img
                layer color
                bottom-left top
                top bottom-right
                bottom-right bottom-left))
             (cond [{layer = 0}
                    (add-simple-lines/color
                     img+k-lines
                     color
                     top-left top-right
                     top-right bottom
                     bottom top-left)]
                   [else img+k-lines])]))))

;; add-k-lines/inner-fractal/layer :
;; Image Natural Color Posn Posn ... ... #:cutoff PosReal -> Image
(define (add-k-lines/inner-fractal/layer scene layer color #:cutoff line-cutoff . rst-args)
  (match rst-args
    [(list) scene]
    [(list-rest start stop rst)
     (apply add-k-lines/inner-fractal/layer #:cutoff line-cutoff
            (add-k-line/inner-fractal/layer scene start stop layer color #:cutoff line-cutoff)
            layer color rst)]))

;; add-half-k-lines/inner-fractal/layer :
;; Image Natural Color Posn ... ... #:cutoff PosReal -> Image
(define (add-half-k-lines/inner-fractal/layer scene layer color #:cutoff line-cutoff . rst-args)
  (match rst-args
    [(list) scene]
    [(list-rest start stop rst)
     (apply add-half-k-lines/inner-fractal/layer #:cutoff line-cutoff
            (add-half-k-line/inner-fractal/layer scene start stop layer color #:cutoff line-cutoff)
            layer color rst)]))


;; add-k-line/inner-fractal/layer : Image Posn Posn Natural Color #:cutoff PosReal -> Image
(define (add-k-line/inner-fractal/layer img p1 p2 layer color #:cutoff line-cutoff)
  (add-half-k-lines/inner-fractal/layer img layer color p1 p2 p2 p1 #:cutoff line-cutoff))


;; add-half-k-line/inner-fractal/layer :
;; Image Posn Posn Natural Color #:cutoff PosReal -> Image
(define (add-half-k-line/inner-fractal/layer img p1 p2 layer color #:cutoff line-cutoff)
  (cond
    [{distance(p1 p2) <= line-cutoff}
     (cond [{layer = 0} (add-simple-line/color img p1 p2 color)]
           [else img])]
    [else
     (local [(define dp (d p1 p2))
             (define mid-point
               {p1 + {1/2 * dp}})
             (define top
               {mid-point + {√3/6 * (posn dp.y (- dp.x))}})
             (define mid-left
               {p1 + {1/3 * dp}})
             (define mid-right
               {mid-left + {1/3 * dp}})]
       (define img2
         (cond [{layer = 0}
                (add-simple-line/color
                 img p1 p2 color)]
               [else
                (add-half-k-lines/inner-fractal/layer
                 #:cutoff line-cutoff
                 img (sub1 layer) color p1 top top p2)]))
       (add-k-lines/inner-fractal/layer
        #:cutoff line-cutoff
        img2
        layer color
        p1 mid-left
        mid-left top
        top mid-right
        mid-right p2))]))

