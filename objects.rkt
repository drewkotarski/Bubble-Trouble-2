#lang racket
(require 2htdp/image)
(require 2htdp/universe)
(require racket/trace) ; was trying to use this to debug, nothing seems to write until after the window created by big-bang closes though.
(require rsound)
;sprites from http://vignette2.wikia.nocookie.net/finalfantasy/images/2/2f/FF6_iOS_Ghost_Sprites.png/revision/latest?cb=20140908174159

;(provide bubble)
;(provide player)
;(provide hook)
(provide my-hook)
(provide p1)
(provide bubble1)
(provide bubble2)
(provide bubble3)



(define arrowSound (rs-read "arrow.wav"));read in the arrow sound to be played upon shooting

(define (bubble x y size color x-dir y-dir)
  (define (dispatch comm) ; couldn't figure out how to do an optional arg (val only needed in update case)
    (cond [(equal? comm 'x) x]
          [(equal? comm 'y) y]
          
          [(equal? comm 'go-left)(change-x -4)]
          [(equal? comm 'go-right)(change-x 4)]
          
          [(equal? comm 'go-up) (change-y -4)]
          [(equal? comm 'go-down)(change-y 4)]
          [(equal? comm 'update-y) (update-y)]
          
          [(equal? comm 'size) size]
          [(equal? comm 'color) color]
          [(equal? comm 'x-dir) x-dir]
          [(equal? comm 'y-dir) y-dir]
          [(equal? comm 'draw) (overlay
                                (circle (size-picker) "solid" color)
                                (circle (+ 2 (size-picker)) "solid" "white"))]
          
          [else (error "bubble: unknown command --" comm)]))
  (define (size-picker)
    (cond
      [(equal? size 1) 10]
      [(equal? size 2) 15]
      [(equal? size 3) 25]
      [(equal? size 4) 40]
      [(equal? size 5) 70]
      [else size]))
  
  (define (change-y dist)
    (begin(set! y (+ y dist))
          (if (< dist 0)
              (set! y-dir 0)
              (set! y-dir 1))))

  (define (change-x dist)
    (begin(set! x (+ x dist))
          (if (< dist 0)
              (set! x-dir 0)
              (set! x-dir 1))))
  (define (update-y)
    (unless (< y (- GROUND (* 2 (size-picker))))
      (set! y-vel (* -10 size)))
      
    (set! y-vel (+ (/ size 2) y-vel))
    (set! y (+ y y-vel))
    )

  (define GROUND 580)
  (define y-vel (* 2 size))
    dispatch)
          
(define (player x y)
  (define direction 'up)
  (define (dispatch comm)
    (cond [(equal? comm 'move-left) (if (< x 1) x (begin (set! x (- x 5)) (set! direction 'left)))]
          [(equal? comm 'move-right) (if (> x 1068) x (begin (set! x (+ x 5)) (set! direction 'right)))]
          [(equal? comm 'position) x]
          [(equal? comm 'dir) direction]
          [(equal? comm 'face-up) (set! direction 'up)]
          [(equal? comm 'shoot) (if (my-hook 'is-shooting?) ;if it's not shot yet, let start shot. otherwise ignore.
                                    (my-hook 'start-shooting)
                                    "currently shooting")] ; will eventually shoot a grappling hook to top of screen. for now it shoots the sprite since I can't figure out how to draw multiple sprites yet.
          [else (error "player: unknown command --" comm)]))
  dispatch)

(define (hook x y shooting) ; will eventually be second object that needs an x and y since it will be shot to pop bubbles
  (define orig-y y) ;save what to reset y value to when it reaches the top of the screen
  (define (dispatch comm)
    (cond [(equal? comm 'x) x]
          [(equal? comm 'y) y]
          [(equal? comm 'is-shooting?) (if (equal? shooting 'no) #f #t)]
          [(equal? comm 'start-shooting) (if (equal? shooting 'no) (begin (play arrowSound) (set! shooting 'yes) (set! x (p1 'position))) "shooting")] ; need to debug this, if statement doesn't seem to read properly
          [(equal? comm 'stop-shooting) (set! shooting 'no)]
          [(equal? comm 'update) (set! y (- y 10))]
          [(equal? comm 'reset) (begin (set! y orig-y) (set! shooting 'no))]
          [else (error "hook: unknown command --" comm)]))
  dispatch)

(define p1 (player 0 550))
(define my-hook (hook 0 550 'no))
;(define        (bubble x y size color x-dir y-dir)
(define bubble1 (bubble 0 550 1 "blue" 1 1))
(define bubble2 (bubble 20 400 2 "red" 1 1))
(define bubble3 (bubble 40 200 3 "yellow" 1 1))
