#lang racket/base

(require 2htdp/image
         racket/local
         racket/match
         racket/list
         "posn.rkt"
         )

;; =================
;; Constants:

(define LINE-CUTOFF 3)

;; =================
;; Functions:

;; snowflake : Positive-Real -> Image
;; a function to combine lines into snowflake
(define (snowflake n)
  (local [(define MTS 
            (rectangle (+ n 20) (+ (/ (* 2 n (sqrt 3)) 3) 20) 0 "white"))
          (define bottom-left
            (posn 10
                  (+ (* n (/ (sqrt 3) 2)) 10)))
          (define bottom-right
            (posn (+ n 10)
                  (+ (* n (/ (sqrt 3) 2)) 10)))
          (define top
            (posn (+ 10 (/ n 2))
                  10))]
    (add-k-lines
     MTS
     bottom-left top
     top bottom-right
     bottom-right bottom-left)))

;; snowflake/inner-fractal : Positive-Real -> Image
(define (snowflake/inner-fractal n)
  (snowflake/inner-fractal/multi-color n '("black")))

;; snowflake/inner-fractal/multi-color : Positive-Real (Listof Color) -> Image
(define (snowflake/inner-fractal/multi-color n colors)
  (local [(define width (+ n 20))
          (define height (+ (/ (* 2 n (sqrt 3)) 3) 20))
          (define MTS 
            (rectangle width height 0 "white"))
          (define bottom-left
            (posn 10
                  (+ (* n (/ (sqrt 3) 2)) 10)))
          (define bottom-right
            (posn (+ n 10)
                  (+ (* n (/ (sqrt 3) 2)) 10)))
          (define top
            (posn (+ 10 (/ n 2))
                  10))
          (define top-left
            (posn 10
                  (- height (+ (* n (/ (sqrt 3) 2)) 10))))
          (define top-right
            (posn (+ n 10)
                  (- height (+ (* n (/ (sqrt 3) 2)) 10))))
          (define bottom
            (posn (+ 10 (/ n 2))
                  (- height 10)))]
    (add-simple-lines/color
     (add-k-lines/inner-fractal/multi-color
      MTS
      colors
      bottom-left top
      top bottom-right
      bottom-right bottom-left)
     (first colors)
     top-left top-right
     top-right bottom
     bottom top-left)))

;; add-simple-lines : Image Posn Posn ... ... -> Image
(define (add-simple-lines scene . rst-args)
  (apply add-simple-lines/color scene "black" rst-args))

;; add-simple-lines/color : Image Color Posn Posn ... ... -> Image
(define (add-simple-lines/color scene color . rst-args)
  (match rst-args
    [(list) scene]
    [(list-rest start stop rst)
     (apply add-simple-lines/color (add-simple-line/color scene start stop color) color rst)]))

;; add-k-lines : Image Posn Posn ... ... -> Image
(define (add-k-lines scene . rst-args)
  (match rst-args
    [(list) scene]
    [(list-rest start stop rst)
     (apply add-k-lines (add-k-line scene start stop) rst)]))

;; add-k-lines/inner-fractal/multi-color : Image (Listof Color) Posn Posn ... ... -> Image
(define (add-k-lines/inner-fractal/multi-color scene colors . rst-args)
  (match rst-args
    [(list) scene]
    [_ #:when (empty? colors) scene]
    [(list-rest start stop rst)
     (apply add-k-lines/inner-fractal/multi-color
            (add-k-line/inner-fractal/multi-color scene start stop colors)
            colors rst)]))


(define (add-k-line img p1 p2)
  (if (<= (distance p1 p2) LINE-CUTOFF)
      (add-simple-line img p1 p2)
      (local [(define dp (d p1 p2))
              (define mid-point
                (p+ p1 (p* dp 1/2)))
              (define top
                (p+ mid-point (p* (posn (dy p1 p2)
                                        (- (dx p1 p2)))
                                  (/ (sqrt 3) 6))))
              (define mid-left
                (p+ p1 (p* dp 1/3)))
              (define mid-right
                (p+ mid-left (p* dp 1/3)))]
        (add-k-lines
         img
         p1 mid-left
         mid-left top
         top mid-right
         mid-right p2))))

;; add-k-line/inner-fractal/multi-color : Image Posn Posn (Listof Color) -> Image
(define (add-k-line/inner-fractal/multi-color img p1 p2 colors)
  (add-half-k-line/inner-fractal/multi-color
   (add-half-k-line/inner-fractal/multi-color
    img p1 p2 colors) p2 p1 colors))


;; add-half-k-line/inner-fractal/multi-color : Image Posn Posn (Listof Color) -> Image
(define (add-half-k-line/inner-fractal/multi-color img p1 p2 colors)
  (cond
    [(empty? colors) img]
    [(<= (distance p1 p2) LINE-CUTOFF)
     (add-simple-line/color img p1 p2 (first colors))]
    [else
     (local [(define dp (d p1 p2))
             (define mid-point
               (p+ p1 (p* dp 1/2)))
             (define top
               (p+ mid-point (p* (posn (dy p1 p2)
                                       (- (dx p1 p2)))
                                 (/ (sqrt 3) 6))))
             (define mid-left
               (p+ p1 (p* dp 1/3)))
             (define mid-right
               (p+ mid-left (p* dp 1/3)))]
       (add-simple-line/color 
        (add-k-lines/inner-fractal/multi-color
         (add-k-lines/inner-fractal/multi-color
          img
          (rest colors)
          p1 top
          top p2)
         colors
         p1 mid-left
         mid-left top
         top mid-right
         mid-right p2)
        p1 p2
        (first colors)))]))



;; add-simple-line : Image Posn Posn -> Image
;; add a black line from p1 to p2 on img
(define (add-simple-line img p1 p2)
  (add-simple-line/color img p1 p2 "black"))

;; add-simple-line/color : Image Posn Posn Color -> Image
(define (add-simple-line/color img p1 p2 color)
  (match-define (posn p1.x p1.y) p1)
  (match-define (posn p2.x p2.y) p2)
  (add-line img p1.x p1.y p2.x p2.y color))


(module+ test
  (snowflake 728)
  (snowflake/inner-fractal 728)
  (add-k-line (empty-scene 1020 520)
              (make-posn 10 510)
              (make-posn 1010 510))
  )
