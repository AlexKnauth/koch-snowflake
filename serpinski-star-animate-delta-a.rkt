#lang postfix-dot-notation sweet-exp racket

require 2htdp/image
        2htdp/universe
        my-cond/iffy
        koch-snowflake/utils
        koch-snowflake/posn
        math/base
module+ test
  require racket/runtime-path
          mrlib/gif
          mrlib/image-core
          only-in racket/draw make-bitmap

define cutoff 11

define serpinski-star(r color ∆a)
  define w {{r * 2} + 10}
  define h w
  define MTS rectangle(w h "solid" "transparent")
  define t(p)
    posn({p.y + {w / 2}} {(- p.x) + {h / 2}})
  add-serpinski-star*(MTS r color t ∆a)

define add-serpinski-star*(img r color t ∆a)
  define img2
    for/fold ([img img]) ([i (in-range 5)])
      define a1 {2 * pi * {{i - 1} / 5}}
      define a2 {2 * pi * {{i + 1} / 5}}
      define p1 t{r * posn(cos(a1) sin(a1))}
      define p2 t{r * posn(cos(a2) sin(a2))}
      add-simple-lines/color img color
        p1 p2
  my-cond
    if {r <= cutoff}
      img2
    else
      define r* {r * {1 - {1 / |phi.0|}}}
      for/fold ([img img]) ([i (in-range 5)])
        define a {{2 * pi * {i / 5}} + ∆a}
        define ∆p
          {{r - r*} * posn(cos(a) sin(a))}
        define (t2 p)
          t{p + ∆p}
        add-serpinski-star*(img r* color t2 (- ∆a))

module+ test
  define 2pi/360 {{2 * pi} / 360}
  define hsh
    for/hash ([t (in-range 0 360 2)])
      values
        t
        freeze serpinski-star(200 "purple" {t * 2pi/360})
  hash-ref hsh 90 ; ∆a = 90
  define bms
    for/list ([t (in-range 0 360 2)])
      define img
        hash-ref hsh t
      define bm make-bitmap(img.image-height img.image-width #f)
      define dc (send bm make-dc)
      render-image(img dc 0 0)
      bm
  define-runtime-path images/serpinski-star-anim-delta-a-gif
    "images/serpinski-star-anim-delta-a.gif"
  when file-exists?(images/serpinski-star-anim-delta-a-gif)
    delete-file(images/serpinski-star-anim-delta-a-gif)
  write-animated-gif
    bms
    3
    images/serpinski-star-anim-delta-a-gif
    #:loop? #t
    #:last-frame-delay 3
  animate
    λ (t)
      hash-ref hsh
        modulo {2 * exact-round(t)} 360
