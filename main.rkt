#lang racket
(require lang/posn)
(require 2htdp/image)
(require 2htdp/universe)
(require racket/trace) ; was trying to use this to debug, nothing seems to write until after the window created by big-bang closes though.
(require rsound)
(require "objects.rkt")

(define lost? #f)
(define sound? #f)

(define lives 3)

(define level 5)

(define (draw-lives n)
  (if (> n 0)
      (beside (circle 8 "solid" "black") (draw-lives (- n 1))) empty-image))

(define (draw-HUD)
   (underlay/xy
    (underlay/xy (rectangle 1100 30 "solid" "red")
                5
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


(define (draw-bubble-list my-bubbles)
  (foldl (lambda (bubble rest-list) (cons (bubble 'draw) rest-list)) '() my-bubbles))


(define (posn-bubble-list my-bubbles)
  (foldl (lambda (bubble rest-list) (cons (bubble 'my-posn) rest-list)) '() my-bubbles))

(define (obj-list)
  (foldl cons (draw-bubble-list bubble-list)
         (list (p1-sprite) (draw-chain) (hook-sprite) (draw-HUD))))


(define (posn-list)
  (foldl cons (posn-bubble-list bubble-list)
         (list (p1 'my-posn) (chain-posn) (my-hook 'my-posn) (HUD-posn))))

(define (HUD-posn)
  (make-posn 550 672))

(define (world-obj)
  (place-images
   (obj-list)
   (posn-list)
   background))

(define (chain-posn)
  (make-posn (my-hook 'x)
             (+ (my-hook 'y) 450)))

(define (draw-chain)
  (if (my-hook 'is-shooting?)
  (overlay (rectangle 2 900 "solid" "brown")
           (rectangle 3 900  "solid" "gray"))
  empty-image))

(define (update-screen x)
  (if (equal? lives 0)
      (text "YOU DEAD!" 90 "black")
  (world-obj)))

(define (update-bubbles)
  (map update-bubble bubble-list)
  )

(define (update-player-collision)
  (begin
    (check-collisions bubble1)
    (check-collisions bubble2)
    (check-collisions bubble3)))

(define (update-hook-collision)
  (begin
    (check-collisions-hook bubble1)
    (check-collisions-hook bubble2) 
    (check-collisions-hook bubble3)))

(define (update-bubble my-bubble)
  (my-bubble
                              (cond
                                [(> (my-bubble 'bottom-right-x) 1099) 'go-left]
                                [(< (my-bubble 'top-left-x) 1) 'go-right]
                                [else
                                 (if (eq? (my-bubble 'x-dir) 0)
                                     'go-left
                                     'go-right)]
                                ))
                             
                             (my-bubble 'update-y) 
)
#;(define (debug-prints)
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


(define (check-collisions my-bubble)
  (if (and
       (> (my-bubble 'bottom-right-x) (p1 'top-left-x)) ; if the bottom right corner of the bubble is bigger than top left of player
       (< (my-bubble 'top-left-x) (p1 'bottom-right-x)) ; and top left of bubble is less than bottom right of player
       (> (my-bubble 'bottom-right-y) (p1 'top-left-y)) ; and same for y (but reversed because y axis goes top to bottom)
       (< (my-bubble 'top-left-y) (p1 'bottom-right-y))
       )
      (begin (my-bubble 'col-sprite) (set! lives (- lives 1)))
      void)
  )

(define (check-collisions-hook my-bubble)
  (if (and
       (> (my-bubble 'bottom-right-x) (my-hook 'top-left-x)) ; if the bottom right corner of the bubble is bigger than top left of player
       (< (my-bubble 'top-left-x) (my-hook 'bottom-right-x)) ; and top left of bubble is less than bottom right of player
       (> (my-bubble 'bottom-right-y) (my-hook 'top-left-y)) ; and same for y (but reversed because y axis goes top to bottom)
       (my-hook 'is-shooting?)
       )
      (begin (my-bubble 'col-arrow))
      void)
  )



(define (update-hook)
  (if (and (my-hook 'is-shooting?) (> (my-hook 'y) 10)) ; if the hook is shooting and it hasn't reached the top of the screen yet
                                 (my-hook 'update) ; keep moving it up 10 pixels
                                 (my-hook 'reset)))

(define (update-sprites x) (if (> 0 lives) void (begin
                             (update-hook)
                             (update-bubbles)
                             (update-player-collision)
                             (update-hook-collision)
                             )))
                                        ; reset to original place

;; go left until 1100, then go right until 0, then go left until 1100, etc

(big-bang 'world0
          (on-tick update-sprites); don't fully understand what this does but it's in the example
          (on-key change) ; check for key events (left, right or space)
          (to-draw update-screen)) ; update sprite (sprites eventually, hopefully