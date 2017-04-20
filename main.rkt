#lang racket
(require 2htdp/image)
(require 2htdp/universe)
(require racket/trace) ; was trying to use this to debug, nothing seems to write until after the window created by big-bang closes though.
(require rsound)
(require "objects.rkt")

(define lost? #f)

(define lives 3)

(define level 5)

(define (draw-lives n)
  (if (> n 0)
      (beside (circle 8 "solid" "black") (draw-lives (- n 1))) empty-image))

(define (draw-HUD)
   (underlay/xy
    (underlay/xy (rectangle 1100 30 "solid" "red")
                0
                5
                (draw-lives lives))
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
       
        (bubble2 'x)
        (bubble2 'y)
        (bubble2 'draw))
      
       (bubble3 'x)
       (bubble3 'y)
       (bubble3 'draw))
      (+ 7 (my-hook 'x))
      (+ (my-hook 'y) 5)
      (draw-chain-2))
     (my-hook 'x)
     (my-hook 'y)
     (hook-sprite))
    0
    670
    (draw-HUD))
   10
   10
   (debug-prints))
  )


(define (draw-chain-2)
  (if (my-hook 'is-shooting?)
  (overlay (rectangle 2 (- 600 (my-hook 'y) 8) "solid" "brown") (rectangle 3 (- 600 (my-hook 'y) 7) "solid" "gray"))
  empty-image))

(define (update-screen x)
  (if (equal? lives 0)
      (text "YOU DEAD!" 90 "black")
  (world-obj)))

(define (update-bubbles)
  (begin
    (bubble1
                              (cond
                                [(> (bubble1 'x) 1058) 'go-left]
                                [(< (bubble1 'x) 2) 'go-right]
                                [else
                                 (if (eq? (bubble2 'x-dir) 0)
                                     'go-left
                                     'go-right)]
                                ))
                             
                             (bubble1 'update-y) 
                             (bubble2 'update-y)
                             (bubble2
                              (cond
                                [(> (bubble2 'x) 1048) 'go-left]
                                [(< (bubble2 'x) 5) 'go-right]
                                [else
                                 (if (eq? (bubble2 'x-dir) 0)
                                     'go-left
                                     'go-right)]
                                ))
                             (bubble3 'update-y)
                             (bubble3
                              (cond
                                [(> (bubble3 'x) 1038) 'go-left]
                                [(< (bubble3 'x) 0) 'go-right]
                                [else
                                 (if (eq? (bubble3 'x-dir) 0)
                                     'go-left
                                     'go-right)]
                                ))
                             ))


(define (debug-prints)
  (above
                (text (string-join `("p1 TL-x:" ,(number->string (p1 'top-left-x)))) 15 "black")
                (text (string-join `("p1 TL-y:" ,(number->string (p1 'bottom-right-x)))) 15 "black")
                (text (string-join `("p1 BR-x:" ,(number->string (p1 'top-left-y)))) 15 "black")
                (text (string-join `("p1 BR-y:" ,(number->string (p1 'bottom-right-y)))) 15 "black")

                (text (string-join `("b3 TL-x:" ,(number->string (bubble3 'top-left-x)))) 15 "black")
                (text (string-join `("b3 TL-y:" ,(number->string (bubble3 'bottom-right-x)))) 15 "black")
                (text (string-join `("b3 BR-x:" ,(number->string (bubble3 'top-left-y)))) 15 "black")
                (text (string-join `("b3 BR-y:" ,(number->string (bubble3 'bottom-right-y)))) 15 "black")
                ))

(define (check-collisions)
  (if (and
       (> (bubble3 'bottom-right-x) (p1 'top-left-x)) ; if the bottom right corner of the bubble is bigger than top left of player
       (< (bubble3 'top-left-x) (p1 'bottom-right-x)) ; and top left of bubble is less than bottom right of player
       (> (bubble3 'bottom-right-y) (p1 'top-left-y)) ; and same for y (but reversed because y axis goes top to bottom)
       (< (bubble3 'top-left-y) (p1 'bottom-right-y))
       )
      (begin (bubble3 'col-sprite) (set! lives (- lives 1)))
      void)
  )

(define (update-sprites x) (begin
                             (if (and (my-hook 'is-shooting?) (> (my-hook 'y) 10)) ; if the hook is shooting and it hasn't reached the top of the screen yet
                                 (my-hook 'update) ; keep moving it up 10 pixels
                                 (my-hook 'reset))
                             (update-bubbles)
                             (check-collisions)
                             ))
                                        ; reset to original place

;; go left until 1100, then go right until 0, then go left until 1100, etc

(big-bang 'world0
          (on-tick update-sprites); don't fully understand what this does but it's in the example
          (on-key change) ; check for key events (left, right or space)
          (to-draw update-screen)) ; update sprite (sprites eventually, hopefully