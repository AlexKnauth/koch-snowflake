#lang sweet-exp racket/base

provide all-defined-out()

require 2htdp/image
        racket/match
        syntax/parse/define
        postfix-dot-notation
        "posn.rkt"

define default-line-cutoff 4

define √3 (√ 3)
define √3/2 {√3 / 2}
define √3/6 {√3 / 6}

;; add-simple-lines/color : Image Color [Posn Posn] ... -> Image
define-simple-macro
  add-simple-lines/color img-expr:expr color-expr:expr
    start-expr:expr stop-expr:expr
    ...
  let ([color color-expr])
    for/fold ([img img-expr]) ([start in-list(list(start-expr ...))]
                               [stop  in-list(list(stop-expr  ...))])
      add-simple-line/color img start stop color

;; add-simple-line/color : Image Posn Posn Color -> Image
define
  add-simple-line/color img p1 p2 color
  scene+line img p1.x p1.y p2.x p2.y color


