#lang postfix-dot-notation sweet-exp racket/base

provide all-defined-out()

require 2htdp/image
        racket/match
        syntax/parse/define
        my-cond/iffy
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
  my-cond
    #:let ([x1 p1.x] [y1 p1.y] [x2 p2.x] [y2 p2.y] [w img.image-width] [h img.image-height])
    if (and {0 <= x1 <= w}
            {0 <= x2 <= w}
            {0 <= y1 <= h}
            {0 <= y2 <= h})
      add-line img x1 y1 x2 y2 color
    else
      eprintf "warning: add-simple-line/color: line outside bounding box\n"
      img

