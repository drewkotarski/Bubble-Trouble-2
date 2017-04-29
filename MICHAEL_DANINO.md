# Bubble Trouble 2 in Racket

## Michael Danino
### April 29, 2017

#Overview
This was a recreation of a classic flash game called Bubble Trouble. The goal of the game is to pop all the bubbles on the screen without getting hit, with larger bubbles splitting into 2 smaller ones each time they get hit until they are hit at the smallest size and are popped for good.
The game can be played with the left and right arrow keys and a hook with a rope can be shot with the space bar, limiting to 1 "shot" on the screen at any given time.

**Authorship note:** All code described was written by Molly McGuire and Me.

# Libraries used
The code uses 4 libraries

```racket
(require lang/posn)
(require 2htdp/image)
(require 2htdp/universe)
(require rsound)
```
**Note:** I tried using the "trace" library for debugging purposes, but couldn't get it to work and fixed my issue so I didn't end up using it.

* The ```lang/posn``` library is used by the ```(place-images)``` function to create a make-posn coordinate object
* The ```2htdp/image``` library is used for drawing game objects to the screen
* The ```2htdp/universe``` library is used for object manipulation within the "game world" as well as handling key inputs (left/right arrow keys and spacebar)
* The ```rsound``` library is used to play an arrow shot sound as the spacebar is pressed.

#Key Code Excerpts

Below are the parts of the code that embody the ideas from the Organization of Programming Language's course.

## 1. "Object orientation" with message passing to manipulate objects

**Note:** Some parts of the object orientation were written by me, some by Molly, and some both of us together.
There were 3 main objects in our code, the Bubble object, the player object, and the hook object. The code for each is below

```racket

(define (bubble x y size color x-dir y-dir y-vel)

  (define popped? #f)
  
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
  
  (define (collision-user)
    (set! color "black"))

 
  (define (collision-bubble)
    (begin
      (set! popped? #t)
      (if (> size 1)
          (bubble-split)
          void)))

  (define (bubble-split)
    (begin
      (set! bubble-list (cons
                         (bubble x y (- size 1) color 0 y-dir (- y-vel 10))
                         (cons (bubble x y (- size 1) color 1 y-dir (- y-vel 10))
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

          [(equal? comm 'col-sprite)(collision-user)]
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
  ```
  
  Each function has helper functions that can be accessed in main.rkt by message passing, for example, if someone wants to find the x position of a "bubble" object called "bubble-1" they could call 
  ```racket (bubble-1 'x)
  ```
this goes into the bubble object's dispatch function and comes to the following cond statement, returning the x val.
```
[(equal? comm 'x) x]
```

## 2. Map, Fold, and Filter


### Map

**Note** The original functions that are being mapped over were written some by me and some by Molly, I changed the code from using hard-coded objects lists of objects that can be mapped over (along with the actual map calls).

Because each level has a different number of bubbles that need to be modified, we created lists of bubbles for each level. To manipulate these lists of bubbles, we mapped over them to update the x/y position, as seen below.
```racket 
(define (update-bubbles)
  (map update-bubble bubble-list)
  )
  
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

```
bubble-list is the current list of bubbles for the current level, so it maps over each bubble object in the list and applies the update procedure seen right below it called "update-bubble".

Similarly, to check for player-bubble collisions, and hook-bubble collisions, we also mapped over the list and compared the x/y values with the hook and the player objects.

```racket
(define (update-player-collision)
  (map check-collisions bubble-list))

(define (check-collisions my-bubble)
  (if (and
       (> (my-bubble 'bottom-right-x) (p1 'top-left-x)) ; if the bottom right corner of the bubble is bigger than top left of player
       (< (my-bubble 'top-left-x) (p1 'bottom-right-x)) ; and top left of bubble is less than bottom right of player
       (> (my-bubble 'bottom-right-y) (p1 'top-left-y)) ; and same for y (but reversed because y axis goes top to bottom)
       (< (my-bubble 'top-left-y) (p1 'bottom-right-y))
       )
      (begin (my-bubble 'col-sprite) (set! lives (- lives 1)) (if (<= 0 lives) (set! lost? #t) void))
      void)
  )

(define (update-hook-collision)
  (map check-collisions-hook bubble-list))

(define (check-collisions-hook my-bubble)
  (if (and
       (> (my-bubble 'bottom-right-x) (my-hook 'top-left-x)) ; if the bottom right corner of the bubble is bigger than top left of player
       (< (my-bubble 'top-left-x) (my-hook 'bottom-right-x)) ; and top left of bubble is less than bottom right of player
       (> (my-bubble 'bottom-right-y) (my-hook 'top-left-y)) ; and same for y (but reversed because y axis goes top to bottom)
       (my-hook 'is-shooting?)
       )
      (begin (my-bubble 'col-arrow) (my-hook 'reset))
      void)
)
```
Both functions map over each bubble object and  check if any of the bubbles are overlapping with either the hook or the player, calling the correct collision function using aforementioned message passing 'col-sprite for player-bubble collision, and 'col-hook for hook-bubble collision.

### Fold

**Note** The folds were written by me

Fold was used to build the list of images, and the list of positions that place-images uses to draw to the screen.

```racket
(define (world-obj)
  (cond
    [lost? (lost-screen)]
    [win? (win-screen)]
    [else
     (place-images
      (obj-list)
      (posn-list)
      background)]
    )) 
```

The obj-list and posn-list are both created with folds over the posn-bubble-list + the other positions in order to create a single list of positions, and the draw-bubble-list + the other images to be drawn to the screen. The posn-bubble-list, and draw-bubble-list are folds over the bubble-list to create a list of positions and bubble images respectively.

```racket
(define (obj-list)
  (foldl cons (draw-bubble-list bubble-list)
         (list (p1-sprite) (draw-chain) (hook-sprite) (draw-HUD) (num-list))))
     
(define (posn-list)
  (foldl cons (posn-bubble-list bubble-list)
         (list (p1 'my-posn) (chain-posn) (my-hook 'my-posn) (HUD-posn) (make-posn 100 100))))

(define (draw-bubble-list my-bubbles)
  (foldl (lambda (bubble rest-list) (cons (bubble 'draw) rest-list)) '() my-bubbles))

(define (posn-bubble-list my-bubbles)
  (foldl (lambda (bubble rest-list) (cons (bubble 'my-posn) rest-list)) '() my-bubbles))

```

In ```draw-bubble-list``` and ```posn-bubble-list```, the list of bubble objects is folded to create a new list of either the image of the respective bubble, or the posn of the respective bubble.

### Filter

**Note** The filter was written by me

Filter was used to remove "popped" bubbles from the list, based on a flag that was set in the col-hook function as seen below.

```racket
(define (delete-popped-bubbles)
  (set! bubble-list (filter (lambda (x) (not (x 'popped?))) bubble-list)))
```


