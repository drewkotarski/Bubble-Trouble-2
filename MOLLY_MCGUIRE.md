# Bubble Trouble 2 Emulator in Racket

## Molly McGuire
### April 30, 2017

# Overview

The code below, as well as the code in this repository, create an desktop game that emulates Bubble Trouble 2, which can be found at
http://bubbletrouble2.net/ . The features of this game include responses to key event input, recursive state updates, and sounds.

We were able to make our player sprite respond to keyboard inputs in the same manner the original game does. Left, right, and space to 
shoot were all incorporated successfully. 

We could also play a sound in a .wav file whenever a specific action happens in the game- that being whenever the hook is deployed.


**Authorship note:** All of the code described here was written by Michael Danino and me.

# Libraries Used
The code uses four libraries:

```racket
(require lang/posn)
(require 2htdp/image)
(require 2htdp/universe)
(require rsound)
```

* The lang/posn library was used to display image objects using coordinate pairs 
* The 2htdp/image library was used to display objects to the output screen
* The 2htdp/universe library was used to create our world, as well  as handle keyboard events
* The rsound library was used to play a certain sound when an event happens

# Key Code Excerpts

The below excerpts embody ideas from UMass Lowell's COMP.3010 Organization of Programming languages course, as well as 
make up the body of our project. 

Three excerpts are shown and they are individually numbered. 

## 1. Message Passing
**Note:** Both Mike and I wrote portions of the below code.

Through using message passing, objects that were previously defined could be mainuplated. These manipulations included changing
x position, y position, event handling, and collision detection.

```
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
Each object defined (the bubbles, the player, and the hook) has their own set of tokens which can be called from the main body of the
program- which allow certain acitons to be performed. For example, 
```
(if (equal? (my-hook 'is-shooting?) #t)
  (check-collision)
  void)
```
would check to see if the hook object was deployed. If it were true, a collision between the hook and the bubbles would be checked.

## 2. Map
**Note:** Both Mike and I wrote portions of the below code, Mike moreso with map while I worked with collision detection.

Map was applied in order to edit the position for each bubble displayed at a given point. The bubbles that were displayed to the output
all belong to the same list. Map was then applied to each bubble object in the list, in order to update it's location. Map was effective
when collisions between bubbles and the hook were detected because bubbles needed to be added to and removed from the bubble list.
Hardcoding the path of each bubble would be very difficult because there would be no way to check the size of the list - so map was the
preferred choice. 

```
(define (update-bubbles)
  (map update-bubble bubble-list))

(define (update-player-collision)
  (map check-collisions bubble-list))

(define (update-hook-collision)
  (map check-collisions-hook bubble-list))
  ```
  The map function also checked for collisions between each ball and the hook object, and each ball and the player sprite object. 
  
  ```
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

(define (check-collisions my-bubble)
  (if (and
       (> (my-bubble 'bottom-right-x) (p1 'top-left-x)) ; if the bottom right corner of the bubble is bigger than top left of player
       (< (my-bubble 'top-left-x) (p1 'bottom-right-x)) ; and top left of bubble is less than bottom right of player
       (> (my-bubble 'bottom-right-y) (p1 'top-left-y)) ; and same for y (but reversed because y axis goes top to bottom)
       (< (my-bubble 'top-left-y) (p1 'bottom-right-y))
       )
      (begin (set! lives (- lives 1)) (if (<= 0 lives) (set! lost? #t) void))
      void)
  )

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

## 3. Recursion
**Note:** Both Mike and I wrote portions of the below code.

Although no function here is explicit it's recursion, the main functionality of big-bang is that it is recursively called multiple times
in one second in order to update the changes that are made to each object, when key event buttons are pressed, and the mouse is clicked.
```big-bang``` is provided by the 2htdp/universe library, and it is the function that enables the user to make real time decisions 
that are represented in the game. 

```
(define (lost-screen)
  (place-images
   (list (text "YOU DEAD!" 90 "black")
         (overlay (text "replay?" 40 "black")
                  (rectangle 190 70 "solid" "red")
                  (rectangle 200 80 "solid" "black")
                  ))
   (list (make-posn 470 200)
         (make-posn 470 380))
   lost-img))

(define (win-screen)
  (place-images
   (list(text "YOU WIN!" 90 "red")
        (overlay (text "next level" 40 "black")
                 (rectangle 190 70 "solid" "red")
                 (rectangle 200 80 "solid" "black")
                 ))
  (list (make-posn 470 200)
        (make-posn 470 380))
   win-img))

(define (end-game)
  (place-images
   (list(text "YOU WIN!" 90 "red"))
   (list (make-posn 470 200))
   win-img))
   
(define (update-screen x)
  (world-obj))
  
(define (world-obj)
  (cond
    [lost? (lost-screen)]
    [(and win? (> 5 current-level)) (win-screen)]
    [(and win? (equal? current-level 5))(end-game)]
    [else
     (place-images
      (obj-list)
      (posn-list)
      background)]
    ))
    
(big-bang 'world0
          (on-tick update-sprites); don't fully understand what this does but it's in the example
          (on-key keypress)
          (on-mouse mouseclick)
          (to-draw update-screen)) ; check for key events (left, right or space)
```
