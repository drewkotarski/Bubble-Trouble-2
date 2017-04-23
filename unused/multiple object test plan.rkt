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
(define arrowSound (rs-read "arrow.wav"));read in the arrow sound to be played upon shooting

(define (bubble x y size speed color)
  (define (dispatch comm val) ; couldn't figure out how to do an optional arg (val only needed in update case)
    (cond [(equal? comm 'x) x]
          [(equal? comm 'y) y]
          [(equal? comm 'update-x) (set! x val)]
          [(equal? comm 'update-y) (set! y val)]
          [(equal? comm 'size) size]
          [(equal? comm 'speed) speed]
          [(equal? comm 'color) color]
          [(equal? comm 'draw) (circle size "solid" color)]
          [else (error "bubble: unknown command --" comm)]))
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
          [(equal? comm 'start-shooting) (if (equal? shooting 'no) (begin (play arrowSound) (set! shooting 'yes)) "shooting")] ; need to debug this, if statement doesn't seem to read properly
          [(equal? comm 'stop-shooting) (set! shooting 'no)]
          [(equal? comm 'update) (begin (set! x (p1 'position)) (set! y (- y 10)))]
          [(equal? comm 'reset) (begin (set! y orig-y) (set! shooting 'no))]
          [else (error "hook: unknown command --" comm)]))
  dispatch)

(define p1 (player 0 550))
(define my-hook (hook 50 550 'no))
(define bubble1 (bubble 0 500 30 3 "blue"))


;; how to approach the multiple objects problem?
;; each object needs a class and needs to be instantiaited
;; each object is already defined with 1) a name
;; 2) an action 3) an origin 4) a direction...
;; using these fields, I think that bby encapuslating them in
;; classes we can control multiple objects at once.
;; We can use the following methods to make classes for
;; multi-object control

;;World% -- a class that satisfies the World<%> interface (shown below).
;;Rectangle% -- a class that satisfies the Rectangle<%> interface
;;(shown below).

;;make-world : PosInt -> World%
;;Creates a world with no rectangles, but in which any rectangles
;;created in the future will travel at the given speed.

;;run : PosNum PosInt -> World%
;;Given a frame rate (in seconds/tick) and a rectangle-speed (in pixels/tick),
;;creates and runs a world.  Returns the final state of the world

;;Interfaces:

(define World<%>
  (interface ()

    ;; -> World<%>
    ;; Returns the World<%> that should follow this one after a tick
    on-tick                             

    ;; Integer Integer MouseEvent -> World<%>
    ;; Returns the World<%> that should follow this one after the
    ;; given MouseEvent
    on-mouse

    ;; KeyEvent -> World<%>
    ;; Returns the World<%> that should follow this one after the
    ;; given KeyEvent
    on-key

    ;; Scene -> Scene
    ;; Returns a Scene like the given one, but with this object drawn
    ;; on it.
    add-to-scene  
    
    ;; -> Integer
    ;; Returns the x and y coordinates of the target
    get-x
    get-y

    ;; -> Boolean
    ;; Is the target selected?
    get-selected?


    ;; -> ListOf<Rectangle<%>>
    get-rectangles

))
    
(define Rectangle<%>
  (interface ()

    ;; -> Rectangle<%>
    ;; Returns the Rectangle<%> that should follow this one after a tick
    on-tick                             

    ;; Integer Integer MouseEvent -> Rectangle<%>
    ;; Returns the Rectangle<%> that should follow this one after the
    ;; given MouseEvent
    on-mouse

    ;; KeyEvent -> Rectangle<%>
    ;; Returns the Rectangle<%> that should follow this one after the
    ;; given KeyEvent
    on-key

    ;; Scene -> Scene
    ;; Returns a Scene like the given one, but with this object drawn
    ;; on it.
    add-to-scene

    ;; -> Integer
    ;; Return the x and y coordinates of the center of the rectangle.
    get-x
    get-y

    ;; -> Boolean
    ;; Is the rectangle currently selected?
    is-selected?

))
;; http://www.ccs.neu.edu/course/cs5010f13/problem-sets/ps09.html
;;http://www.ccs.neu.edu/course/cs5010f16/Problem%20Sets/ps09.html

;;make-metatoy : ListOfToys -> Metatoy
;;RETURNS: a Metatoy with the given list of toys.
;;NOTE: The Metatoy<%> interface extends the World<%> interface, so the
;;result of make-metatoy is something that big-bang can use as a world.

;;run : PosNum -> Metatoy
;;GIVEN: a frame rate (in seconds/tick)
;;EFFECT: creates a MetaToy with no toys in it, and runs it using big-bang
;;at the given frame rate.  Returns the final state of the Metatoy.

;;make-throbber: PosInt PosInt -> Toy
;;GIVEN: an x and a y position
;;RETURNS: an object representing a throbber at the given position.

;;make-clock : PosInt PosInt -> Toy
;;GIVEN: an x and a y position
;;RETURNS: an object representing a clock at the given position.

;;make-politician : PosInt PosInt -> Toy
;;GIVEN: an x and a y position
;;RETURNS: an object representing a politician at the given position.

;;Interfaces:

;; A Metatoy is an object of any class that implements Metatoy<%>.
;; (You will only need one such class)

(define Metatoy<%>
  (interface 
  
   ;; the (World<%>) says that Metatoy<%> inherits from World<%>
   ;; This means that any class that implements Metatoy<%> must
   ;; implement all the methods from World<%> plus all the methods
   ;; defined here. In this case, there is just one additional method,
   ;; called get-toys.
   (World<%>)

    ;; -> ListOfToy
    get-toys

))

;; A Toy is an object of any class that implements Toy<%>
;; You will probably have three such classes, one for each kind of toy. 

(define Toy<%> 
  (interface
  
   ;; The interface Toy<%> inherits from the interface Widget<%>.
   ;; This means that any class that implements Toy<%> must implement
   ;; all the methods from Widget<%> plus all the methods defined here.
   (Widget<%>)


    ;; Note: the Widgets of the space-invader-examples don't respond
    ;; to mouse "move" events, but some of our toys do.  So we add an
    ;; after-move method to the interface.

    ;;  Int Int -> Toy
    ;;  RETURNS: the state of this toy that should follow a mouse-move
    ;;  at the given coordinates
    after-move

 
    ;; -> Int
    ;; RETURNS: the x or y position of the center of the toy
    toy-x
    toy-y

    ;; -> Int
    ;; RETURNS: some data related to the toy.  The interpretation of
    ;; this data depends on the class of the toy.
    ;; for a throbber, it is the current radius of the throbber
    ;; for the clock, it is the current value of the clock
    ;; for a politician, it is the current distance to the mouse
    toy-data


    ))
;; THE STRUCTURE OF WHAT WE WANT TO DO SHOULD RESEMBE THE STRUCUTURE OF THE ABOVE 2 EXAMPLES
;; ALL YOU REALLY NEED TO DO IS PLUG AND CHUG