#lang sweet-exp racket/base

require 2htdp/image
        "../koch-snowflake-inner-fractal.rkt"
        "try-draw.rkt"

display    "(time (snowflake/inner-fractal 728))      : "
define img1 (time (snowflake/inner-fractal 728))
display    "(time (freeze img1))                      : "
define img2 (time (freeze img1))

display    "(time (snowflake/inner-fractal/draw 728)) : "
define img3 (time (snowflake/inner-fractal/draw 728))

