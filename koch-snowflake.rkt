#lang racket/base

(require 2htdp/image
         racket/local
         racket/match
         racket/list
         "posn.rkt"
         )

;; =================
;; Constants:

(define default-line-cutoff 4)

;; =================
;; Functions:

;; snowflake : Positive-Real -> Image
;; a function to combine lines into snowflake
(define (snowflake w #:cutoff [line-cutoff default-line-cutoff])
  (local [(define h (* w 4/3 (/ (sqrt 3) 2)))
          (define m 10)
          (define MTS 
            (rectangle (+ m w m) (+ m h m) 0 "transparent"))
          (define bottom-left
            (posn (+ m)
                  (+ m (* 3/4 h))))
          (define bottom-right
            (posn (+ m w)
                  (+ m (* 3/4 h))))
          (define top
            (posn (+ m (* 1/2 w))
                  (+ m)))]
    (add-k-lines
     MTS
     bottom-left top
     top bottom-right
     bottom-right bottom-left
     #:cutoff line-cutoff)))

;; snowflake/inner-fractal : Positive-Real -> Image
(define (snowflake/inner-fractal n #:cutoff [line-cutoff default-line-cutoff])
  (snowflake/inner-fractal/multi-color n '("black") #:cutoff line-cutoff))

;; snowflake/inner-fractal/multi-color : Positive-Real (Listof Color) -> Image
(define (snowflake/inner-fractal/multi-color w colors #:cutoff [line-cutoff default-line-cutoff])
  (local [(define h (* w 4/3 (/ (sqrt 3) 2)))
          (define m 50)
          (define MTS 
            (rectangle (+ m w m) (+ m h m) 0 "transparent"))
          (define bottom-left
            (posn (+ m)
                  (+ m (* 3/4 h))))
          (define bottom-right
            (posn (+ m w)
                  (+ m (* 3/4 h))))
          (define top
            (posn (+ m (* 1/2 w))
                  (+ m)))
          (define top-left
            (posn (+ m)
                  (+ m (* 1/4 h))))
          (define top-right
            (posn (+ m w)
                  (+ m (* 1/4 h))))
          (define bottom
            (posn (+ m (* 1/2 w))
                  (+ m h)))]
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
             (cond [(= 0 layer)
                    (add-simple-lines/color
                     img+k-lines
                     color
                     top-left top-right
                     top-right bottom
                     bottom top-left)]
                   [else img+k-lines])]))))

;; add-simple-lines : Image Posn Posn ... ... -> Image
(define (add-simple-lines scene . rst-args)
  (apply add-simple-lines/color scene "black" rst-args))

;; add-simple-lines/color : Image Color Posn Posn ... ... -> Image
(define (add-simple-lines/color scene color . rst-args)
  (match rst-args
    [(list) scene]
    [(list-rest start stop rst)
     (apply add-simple-lines/color (add-simple-line/color scene start stop color) color rst)]))

;; add-k-lines : Image Posn Posn ... ... #:cutoff PosReal -> Image
(define (add-k-lines scene #:cutoff line-cutoff . rst-args)
  (match rst-args
    [(list) scene]
    [(list-rest start stop rst)
     (apply add-k-lines (add-k-line scene start stop #:cutoff line-cutoff) rst #:cutoff line-cutoff)]
    ))

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


(define (add-k-line img p1 p2 #:cutoff line-cutoff)
  (if (<= (distance p1 p2) line-cutoff)
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
         #:cutoff line-cutoff
         img
         p1 mid-left
         mid-left top
         top mid-right
         mid-right p2))))

;; add-k-line/inner-fractal/layer : Image Posn Posn Natural Color #:cutoff PosReal -> Image
(define (add-k-line/inner-fractal/layer img p1 p2 layer color #:cutoff line-cutoff)
  (add-half-k-lines/inner-fractal/layer img layer color p1 p2 p2 p1 #:cutoff line-cutoff))


;; add-half-k-line/inner-fractal/layer :
;; Image Posn Posn Natural Color #:cutoff PosReal -> Image
(define (add-half-k-line/inner-fractal/layer img p1 p2 layer color #:cutoff line-cutoff)
  (cond
    [(<= (distance p1 p2) line-cutoff)
     (cond [(= 0 layer) (add-simple-line/color img p1 p2 color)]
           [else img])]
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
       (define img2
         (cond [(= 0 layer)
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



;; add-simple-line : Image Posn Posn -> Image
;; add a black line from p1 to p2 on img
(define (add-simple-line img p1 p2)
  (add-simple-line/color img p1 p2 "black"))

;; add-simple-line/color : Image Posn Posn Color -> Image
(define (add-simple-line/color img p1 p2 color)
  (match-define (posn p1.x p1.y) p1)
  (match-define (posn p2.x p2.y) p2)
  (scene+line img p1.x p1.y p2.x p2.y color))


(module+ test
  (snowflake 728)
  (snowflake/inner-fractal 728)
  (snowflake/inner-fractal/multi-color 150 '("transparent" "black")) ; inside-out-ish
  (snowflake/inner-fractal/multi-color 500 '("red" "green") #:cutoff 12) ; 2-color
  (snowflake/inner-fractal/multi-color 500 '("red" "blue" "green") #:cutoff 12) ; 3-color
  (snowflake/inner-fractal/multi-color 100 '("red" "blue" "green" "orange") #:cutoff 12) ; 4-color
  (snowflake/inner-fractal/multi-color 500 '("red" "orange" "yellow" "green" "blue" "purple")
                                       #:cutoff 10) ; 6-color
  (add-k-line (empty-scene 1020 520) #:cutoff default-line-cutoff
              (make-posn 10 510)
              (make-posn 1010 510))
  )
