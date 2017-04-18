#lang racket
(require 2htdp/image)
(require 2htdp/universe)
(require racket/trace) ; was trying to use this to debug, nothing seems to write until after the window created by big-bang closes though.
(require rsound)
(require "objects.rkt")


(define num-lives 3)

(define level 5)

(define (draw-lives n)
  (if (> n 0)
      (beside (circle 8 "solid" "black") (draw-lives (- n 1))) empty-image))

(define (draw-HUD)
   (underlay/xy
    (underlay/xy (rectangle 1100 30 "solid" "red")
                0
                5
                (draw-lives num-lives))
    500
    5
    (text (string-join `("LEVEL:" ,(number->string level))) 20 "black")))
    
;(text (string #\L #\I #\V #\E #\S #\: #\ (integer->char num-lives)) 5 "black")))
(define arrowSound (rs-read "arrow.wav"));read in the arrow sound to be played upon shooting
;(play arrowSound)
; initialize the main player and the "hook" used (eventually) to pop bubbles
(define (p1-sprite)
  (define p1-up (bitmap "up.png"))
  (define p1-left (bitmap "left.png"))
  (define p1-right (bitmap "right.png"))
  (define retval
    (cond [(equal? (p1 'dir) 'left) p1-left]
          [(equal? (p1 'dir) 'right) p1-right]
          [else p1-up]))
  retval)
          
(define my-hook-sprite (bitmap "arrow.png"))

(define background (bitmap "background.jpg"))

(define (hook-sprite)
  (if (my-hook 'is-shooting?) my-hook-sprite empty-image))

;handle key events
(define (change w a-key)
  (cond [(key=? a-key "left") (p1 'move-left)]
        [(key=? a-key "right") (p1 'move-right)]
        [(key=? a-key " ") (my-hook 'start-shooting)]
        [else (p1 'face-up)]))

(define (world-obj)
  (underlay/xy 
   (underlay/xy
    (underlay/xy
     (underlay/xy
      (underlay/xy background
                   (p1 'position) ; x val of p1
                   600 ; y val of p1
                   (p1-sprite))
      (bubble1 'x)
      (bubble1 'y)
      (bubble1 'draw))
     (+ 10 (my-hook 'x))
     (+ (my-hook 'y) 7)
     (draw-chain-2))
    (my-hook 'x)
    (my-hook 'y)
    (hook-sprite))
   0
   670
   (draw-HUD))
  )

(define (draw-chain-2)
  (if (my-hook 'is-shooting?)
  (overlay (rectangle 4 (- 600 (my-hook 'y) 8) "solid" "brown") (rectangle 5 (- 600 (my-hook 'y) 7) "solid" "gray"))
  empty-image))

(define (draw-chain y)
  (if (and (< y 600) (my-hook 'is-shooting?))
      (underlay/xy (ellipse 5 10 "outline" "gray")
                   (my-hook 'x)
                   y
                   (draw-chain (+ y 7)))
      empty-image))

(define (update-screen x)
  (world-obj))

(define (update-sprites x) (if (and (my-hook 'is-shooting?) (> (my-hook 'y) 10)) ; if the hook is shooting and it hasn't reached the top of the screen yet
                               (my-hook 'update) ; keep moving it up 10 pixels
                               (my-hook 'reset))) ; reset to original place

(big-bang 'world0
          (on-tick update-sprites); don't fully understand what this does but it's in the example
          (on-key change) ; check for key events (left, right or space)
          (to-draw update-screen)) ; update sprite (sprites eventually, hopefully
