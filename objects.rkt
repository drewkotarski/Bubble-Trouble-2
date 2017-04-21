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
(provide bubble-list)


(define arrowSound (rs-read "arrow.wav"));read in the arrow sound to be played upon shooting

(define (bubble x y size color x-dir y-dir)
  
  (define (size-picker)
    (cond
      [(equal? size 1) 8]
      [(equal? size 2) 16]
      [(equal? size 3) 32]
      [(equal? size 4) 64]
      [(equal? size 5) 60]
      [else size]))

  (define (center-x)
    (+ x (/ (size-picker) 2)))
  (define (center-y)
    (+ y (/ (size-picker) 2)))

  (define (top-left-x)
    x)
  (define (top-left-y)
    y)
  (define (bottom-right-x)
    (+ x (* 2 (size-picker))))
  (define (bottom-right-y)
    (+ y (* 2 (size-picker))))
  
  (define (collision-user)
    (set! color "black"))

 
  (define (collision-bubble)
    (set! color "white"))
  
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
    (unless (<= y (- GROUND (* 2 (size-picker))))
      (set! y-vel (* -6 size)))
      
    (set! y-vel (+ (/ size 6) y-vel))
    (set! y (+ y y-vel))
    )

  (define GROUND 650)
  (define y-vel (* 2 size))
  (define (dispatch comm) ; couldn't figure out how to do an optional arg (val only needed in update case)
    (cond [(equal? comm 'x) x]
          [(equal? comm 'y) y]
          [(equal? comm 'GROUND) GROUND]
          
          [(equal? comm 'go-left)(change-x -5)]
          [(equal? comm 'go-right)(change-x 5)]
          
          [(equal? comm 'go-up) (change-y -4)]
          [(equal? comm 'go-down)(change-y 4)]
          [(equal? comm 'update-y) (update-y)]

          [(equal? comm 'col-sprite)(collision-user)]
          [(equal? comm 'col-arrow)(collision-bubble)]
          
          [(equal? comm 'size) size]
          [(equal? comm 'size-picker) (size-picker)]
          [(equal? comm 'color) color]
          [(equal? comm 'x-dir) x-dir]
          [(equal? comm 'y-dir) y-dir]

          [(equal? comm 'center-x) (center-x)]
          [(equal? comm 'center-y) (center-y)]
          [(equal? comm 'top-left-x) (top-left-x)]
          [(equal? comm 'top-left-y) (top-left-y)]
          [(equal? comm 'bottom-right-x) (bottom-right-x)]
          [(equal? comm 'bottom-right-y) (bottom-right-y)]
          
          [(equal? comm 'draw) (overlay
                                (circle (- (size-picker) 2) "solid" color)
                                (circle (size-picker) "solid" "white"))]
          
          [else (error "bubble: unknown command --" comm)]))
    dispatch)





(define (player x y)
  (define direction 'up)
  (define width 30)
  (define height 50)

  (define (center-x)
    (+ x (/ width 2)))
  (define (center-y)
    (+ y (/ height 2)))

  (define (top-left-x)
    x)
  (define (top-left-y)
    y)
  (define (bottom-right-x)
    (+ x width))
  (define (bottom-right-y)
    (+ y height))

  
  (define (dispatch comm)
    (cond [(equal? comm 'move-left) (if (< x 1) x (begin (set! x (- x 5)) (set! direction 'left)))]
          [(equal? comm 'move-right) (if (> x 1068) x (begin (set! x (+ x 5)) (set! direction 'right)))]
          [(equal? comm 'position) x]
          [(equal? comm 'dir) direction]
          [(equal? comm 'top-left-x) (top-left-x)]
          [(equal? comm 'top-left-y) (top-left-y)]
          [(equal? comm 'bottom-right-x) (bottom-right-x)]
          [(equal? comm 'bottom-right-y) (bottom-right-y)]
          [(equal? comm 'center-x) (center-x)]
          [(equal? comm 'center-y) (center-y)]
          [(equal? comm 'face-up) (set! direction 'up)]
          [(equal? comm 'shoot) (if (my-hook 'is-shooting?) ;if it's not shot yet, let start shot. otherwise ignore.
                                    (my-hook 'start-shooting)
                                    "currently shooting")] ; will eventually shoot a grappling hook to top of screen. for now it shoots the sprite since I can't figure out how to draw multiple sprites yet.
          [else (error "player: unknown command --" comm)]))
  dispatch)

(define (hook x y shooting)

  (define (top-left-x)
    x)
  (define (top-left-y)
    y)
  (define (bottom-right-x)
    (+ x 15))


  ; will eventually be second object that needs an x and y since it will be shot to pop bubbles
  (define orig-y y) ;save what to reset y value to when it reaches the top of the screen
  (define (dispatch comm)
    (cond [(equal? comm 'x) x]
          [(equal? comm 'y) y]
          [(equal? comm 'is-shooting?) (if (equal? shooting 'no) #f #t)]
          [(equal? comm 'start-shooting) (if (equal? shooting 'no) (begin (play arrowSound) (set! shooting 'yes) (set! x (p1 'position))) "shooting")] ; need to debug this, if statement doesn't seem to read properly
          [(equal? comm 'stop-shooting) (set! shooting 'no)]
          [(equal? comm 'update) (set! y (- y 10))]
          [(equal? comm 'reset) (begin (set! y orig-y) (set! shooting 'no))]
          [(equal? comm 'top-left-x)(top-left-x)]
          [(equal? comm 'top-left-y)(top-left-y)]
          [(equal? comm 'bottom-right-x)(bottom-right-x)]
          [else (error "hook: unknown command --" comm)]))
  dispatch)

(define p1 (player 0 550))
(define my-hook (hook 0 550 'no))
;(define        (bubble x y size color x-dir y-dir)
(define bubble1 (bubble 0 550 1 "blue" 1 1))
(define bubble2 (bubble 0 400 2 "red" 1 1))
(define bubble3 (bubble 0 200 3 "yellow" 1 1))

(define bubble-list (list (bubble 0 550 1 "blue" 1 1) (bubble 0 400 2 "red" 1 1) (bubble 0 200 3 "yellow" 1 1)))

(define orig-bubble1 bubble1)