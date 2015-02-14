#lang sweet-exp racket/base

(provide (all-defined-out))

(require 2htdp/image
         racket/match
         postfix-dot-notation
         "posn.rkt")

(define √3 (√ 3))
(define √3/2 {√3 / 2})
(define √3/6 {√3 / 6})

;; add-simple-lines/color : Image Color Posn Posn ... ... -> Image
(define (add-simple-lines/color scene color . rst-args)
  (match rst-args
    [(list) scene]
    [(list-rest start stop rst)
     (apply add-simple-lines/color (add-simple-line/color scene start stop color) color rst)]))

;; add-simple-line/color : Image Posn Posn Color -> Image
(define (add-simple-line/color img p1 p2 color)
  (scene+line img p1.x p1.y p2.x p2.y color))


