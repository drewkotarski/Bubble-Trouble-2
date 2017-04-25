#lang racket
(require lang/posn)
(require 2htdp/image)
(require 2htdp/universe)
(require racket/trace) ; was trying to use this to debug, nothing seems to write until after the window created by big-bang closes though.
(require rsound)
;sprites from http://vignette2.wikia.nocookie.net/finalfantasy/images/2/2f/FF6_iOS_Ghost_Sprites.png/revision/latest?cb=20140908174159

(provide my-hook)
(provide p1)
(provide initialize-level)
(provide bubble-list)
(provide delete-popped-bubbles)

(define (delete-popped-bubbles)
  (set! bubble-list (filter (lambda (x) (not (x 'popped?))) bubble-list)))

(define arrowSound (rs-read "arrow.wav"));read in the arrow sound to be played upon shooting

(define (bubble x y size color x-dir y-dir)

  (define popped? #f)
  (define y-vel (* -1 size))
  (define (size-picker)
    (cond
      [(equal? size 1) 8]
      [(equal? size 2) 16]
      [(equal? size 3) 32]
      [(equal? size 4) 64]
      [(equal? size 5) 60]
      [else size]))
  (define (my-posn)
    (make-posn x y))
  
  (define (top-left-x)
    (- x (size-picker)))
  (define (top-left-y)
    (- y (size-picker)))
  (define (bottom-right-x)
    (+ x (size-picker)))
  (define (bottom-right-y)
    (+ y (size-picker)))
 
  (define (collision-bubble)
    (begin
      (set! popped? #t)
      (if (> size 1)
          (bubble-split)
          void)))

  (define (bubble-split)
    (begin
      (set! bubble-list (cons
                         (bubble x y (- size 1) color 0 y-dir)
                         (cons (bubble x y (- size 1) color 1 y-dir)
                               bubble-list)))))
  
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
    (unless (<= y (- GROUND (size-picker)))
      (set! y-vel (* -6 size)))
    (if (<= y (+ 0 (* 2 (size-picker))))
        (set! y-vel 2)
        (set! y-vel (+ (/ size 6) y-vel)))
    (set! y (+ y y-vel))
    )

  (define GROUND 630)
  (define (dispatch comm) ; couldn't figure out how to do an optional arg (val only needed in update case)
    (cond [(equal? comm 'x) x]
          [(equal? comm 'y) y]
          [(equal? comm 'GROUND) GROUND]
          
          [(equal? comm 'go-left)(change-x -2)]
          [(equal? comm 'go-right)(change-x 2)]
          
          [(equal? comm 'go-up) (change-y -4)]
          [(equal? comm 'go-down)(change-y 4)]
          [(equal? comm 'update-y) (update-y)]

          [(equal? comm 'col-arrow)(collision-bubble)]
          
          [(equal? comm 'size) size]
          [(equal? comm 'size-picker) (size-picker)]
          [(equal? comm 'color) color]
          [(equal? comm 'x-dir) x-dir]
          [(equal? comm 'y-dir) y-dir]
          [(equal? comm 'my-posn) (my-posn)]
          [(equal? comm 'popped?) popped?]

         
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
  (define orig-x 15)
  
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
  (define (my-posn)
    (make-posn x y))
  
  (define (dispatch comm)
    (cond [(equal? comm 'move-left) (if (< (- x (/ width 2)) 1) x (begin (set! x (- x 5)) (set! direction 'left)))]
          [(equal? comm 'move-right) (if (> (+ x (/ width 2)) 1068) x (begin (set! x (+ x 5)) (set! direction 'right)))]
          [(equal? comm 'position) x]
          [(equal? comm 'dir) direction]
          [(equal? comm 'my-posn) (my-posn)]
          [(equal? comm 'reset-posn) (set! x orig-x)]
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
  (define height 20)
  (define width 14)
  (define (top-left-x)
    (- x (/ width 2)))
  (define (top-left-y)
    (- y (/ height 2)))
  (define (bottom-right-x)
    (+ x (/ width 2)))
  
  ; will eventually be second object that needs an x and y since it will be shot to pop bubbles
  (define orig-y y) ;save what to reset y value to when it reaches the top of the screen
  (define (my-posn)
    (make-posn x y))
  (define (dispatch comm)
    (cond [(equal? comm 'x) x]
          [(equal? comm 'y) y]
          [(equal? comm 'my-posn) (my-posn)]
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


(define p1 (player 15 630))
(define my-hook (hook 0 600 'no))

;(define bubble1 (bubble 0 550 1 "blue" 1 1))
;(define bubble2 (bubble 0 400 2 "red" 1 1))
;(define bubble3 (bubble 0 200 3 "yellow" 1 1))
;(define (bubble x y size color x-dir y-dir)

(define (level-1)
  (list (bubble 200 550 1 "blue" 1 1)
        (bubble 200 400 2 "red" 1 1)
        (bubble 200 200 3 "yellow" 1 1)))

(define (level-2)
  (list (bubble 200 550 1 "purple" 1 1)
        (bubble 200 500 1 "purple" 1 1)
        (bubble 200 400 2 "indigo" 1 1)
        (bubble 200 200 3 "blue" 1 1)))

(define bubble-list (level-2))

(define (initialize-level n)
  (begin (p1 'reset-posn)
         (my-hook 'reset)
         (cond [(= n 1) (set! bubble-list (level-1))]
               [else (error "hoijoiejrwoeirj")])))