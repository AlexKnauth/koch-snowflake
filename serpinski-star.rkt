#lang postfix-dot-notation sweet-exp racket

require 2htdp/image
        my-cond/iffy
        koch-snowflake/utils
        koch-snowflake/posn
        math/base

define cutoff 11

define serpinski-star(r color)
  define w {{r * 2} + 10}
  define h w
  define MTS rectangle(w h "solid" "transparent")
  define t(p)
    posn({p.y + {w / 2}} {(- p.x) + {h / 2}})
  add-serpinski-star*(MTS r color t)

define add-serpinski-star*(img r color t)
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
      for/fold ([img img2]) ([i (in-range 5)])
        define a {2 * pi * {i / 5}}
        define ∆p
          {{r - r*} * posn(cos(a) sin(a))}
        define (t2 p)
          t{p + ∆p}
        add-serpinski-star*(img r* color t2)

module+ test
  serpinski-star(200 "purple")
