#lang racket/base

(require 2htdp/image
         racket/local
         racket/match
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
    (add-simple-lines
     (add-k-lines/inner-fractal
      MTS
      bottom-left top
      top bottom-right
      bottom-right bottom-left)
     top-left top-right
     top-right bottom
     bottom top-left)))

;; add-simple-lines : Image Posn Posn ... ... -> Image
(define (add-simple-lines scene . rst-args)
  (match rst-args
    [(list) scene]
    [(list-rest start stop rst)
     (apply add-simple-lines (add-simple-line scene start stop) rst)]))

;; add-k-lines : Image Posn Posn ... ... -> Image
(define (add-k-lines scene . rst-args)
  (match rst-args
    [(list) scene]
    [(list-rest start stop rst)
     (apply add-k-lines (add-k-line scene start stop) rst)]))

;; add-k-lines/inner-fractal : Image Posn Posn ... ... -> Image
(define (add-k-lines/inner-fractal scene . rst-args)
  (match rst-args
    [(list) scene]
    [(list-rest start stop rst)
     (apply add-k-lines/inner-fractal (add-k-line/inner-fractal scene start stop) rst)]))


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

;; add-k-line/inner-fractal : Image Posn Posn -> Image
(define (add-k-line/inner-fractal img p1 p2)
  (add-half-k-line/inner-fractal 
   (add-half-k-line/inner-fractal
    img p1 p2) p2 p1))


;; add-half-k-line/inner-fractal : Image Posn Posn -> Image
(define (add-half-k-line/inner-fractal img p1 p2)
  (if (<= (distance p1 p2) LINE-CUTOFF)
      (add-simple-line img p1 p2)
      (add-simple-line 
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
         (add-k-lines/inner-fractal
          img
          p1 mid-left
          mid-left top
          top mid-right
          mid-right p2))
       p1 p2)))



;; add-simple-line : Image Posn Posn -> Image
;; add a black line from p1 to p2 on img
(define (add-simple-line img p1 p2)
  (match-define (posn p1.x p1.y) p1)
  (match-define (posn p2.x p2.y) p2)
  (add-line img p1.x p1.y p2.x p2.y "black"))


(module+ test
  (snowflake 728)
  (snowflake/inner-fractal 728)
  (add-k-line (empty-scene 1020 520)
              (make-posn 10 510)
              (make-posn 1010 510))
  )
