#lang sweet-exp racket/base

(provide (all-defined-out))

(require racket/match
         racket/math
         math/base
         postfix-dot-notation
         (prefix-in rkt: racket/base)
         )

(struct posn (x y) #:transparent #:extra-constructor-name make-posn)

(define p posn)
(define x posn-x)
(define y posn-y)

(define (+ . args)
  (match args
    [(list) 0]
    [(list (? number? args) ...) (sum args)]
    [(list (posn xs ys) ...) (posn (sum xs) (sum ys))]))

(define -
  (case-lambda
    [(a) {-1 * a}]
    [(a . rst) {a + (- (apply + rst))}]))

(define (* . args)
  (match args
    [(list) 1]
    [(list (? number? args) ...) (apply rkt:* args)]
    [(list-no-order (posn x y) (? real? ns) ...)
     (define n (apply rkt:* ns))
     (posn {n * x} {n * y})]))

;; distance : Posn Posn -> Number
;; produce the distance between two points
;; note that here d means delta, not differential
(define (distance p1 p2)
  (let ([dx (dx p1 p2)] [dy (dy p1 p2)])
    √{{dx ^ 2} + {dy ^ 2}}))

;; dx and dy are helper functions for distance
;; note that here d means delta, not differential
;; dx : Posn Posn -> Real
(define (dx p1 p2)
  {p2.x - p1.x})
;; dy : Posn Posn -> Real
(define (dy p1 p2)
  {p2.y - p1.y})
;; d : Posn Posn -> Posn
(define (d p1 p2)
  {p2 - p1})

(define √ sqrt)
(define ^ expt)



