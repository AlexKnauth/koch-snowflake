#lang racket/base

(provide (all-defined-out))

(require racket/match
         racket/math
         )

(struct posn (x y) #:transparent #:extra-constructor-name make-posn)

(define (p+ p1 p2)
  (match-define (posn p1.x p1.y) p1)
  (match-define (posn p2.x p2.y) p2)
  (posn (+ p1.x p2.x)
        (+ p1.y p2.y)))

(define (p- p1 p2)
  (match-define (posn p1.x p1.y) p1)
  (match-define (posn p2.x p2.y) p2)
  (posn (- p1.x p2.x)
        (- p1.y p2.y)))

(define (p* arg . rst)
  (match (cons arg rst)
    [(list-no-order (posn x y) (? real? ns) ...)
     (define n (apply * ns))
     (posn (* x n) (* y n))]))

;; distance : Posn Posn -> Number
;; produce the distance between two points
(define (distance p1 p2)
  (sqrt (+ (sqr (dx p1 p2))
           (sqr (dy p1 p2)))))

;; dx and dy are helper functions for distance
;; dx : Posn Posn -> Real
(define (dx p1 p2)
  (- (posn-x p2) (posn-x p1)))
;; dy : Posn Posn -> Real
(define (dy p1 p2)
  (- (posn-y p2) (posn-y p1)))
;; d : Posn Posn -> Posn
(define (d p1 p2)
  (p- p2 p1))

