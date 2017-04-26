# Bubble Trouble 2 Emulator

### Statement
Our project is a racket remake of the flash game "Bubble Trouble". It's interesting because we learn how to use racket libraries and implement and manipulate different objects with a functional language. It's interesting to us because we both played it in elementary/middle school so it's nostalgic. We hope to learn how to apply some of the concepts we learned in class to a project that has a clear result of what we want to see in the end.

### Analysis
We used object orientation to hold our "bubble" objects, "player" object, "hook" object that will be shot from the player to pop bubbles. To manipulate these objects, we used data abstraction to update the x/y variables, and filter to delete objects from the universe. To check whether collisions occurred (either hook hits bubble, or bubble hits player) we mapped over the objects x/y positions. state modification will be used within each object to update the location, for example. if the left arrow key is held, the player will move 10 units to the left (set! x (- x 10)). 

### Filter
Filter was used to delete "popped" bubbles on the list by checking a flag that was set within each bubble object during hook-bubble collision detection.
```racket
(define (delete-popped-bubbles)
  (set! bubble-list (filter (lambda (x) (not (x 'popped?))) bubble-list)))
```

### Map
Map was used to update the location of each bubble in the list, as well as check for player-bubble and hook-bubble collisions.

```racket
(define (update-bubbles)
  (map update-bubble bubble-list)
  )

(define (update-player-collision)
  (map check-collisions bubble-list))

(define (update-hook-collision)
  (map check-collisions-hook bubble-list))

```

### Fold
Fold was used to build the list of images that place-images takes. Place-images takes a list of images, then a list of their corresponding x/y coordinates.

```racket
(define (posn-bubble-list my-bubbles)
  (foldl (lambda (bubble rest-list) (cons (bubble 'my-posn) rest-list)) '() my-bubbles))

(define (obj-list)
  (foldl cons (draw-bubble-list bubble-list)
         (list (p1-sprite) (draw-chain) (hook-sprite) (draw-HUD) (num-list))))

(define (draw-bubble-list my-bubbles)
  (foldl (lambda (bubble rest-list) (cons (bubble 'draw) rest-list)) '() my-bubbles))
     
(define (posn-list)
  (foldl cons (posn-bubble-list bubble-list)
         (list (p1 'my-posn) (chain-posn) (my-hook 'my-posn) (HUD-posn) (make-posn 100 100))))

```

### External Technologies
Our project will generate or produce sound, because the original flash game produces sounds as well. When the hook is deployed, 
a bubble is popped, or the player is hit by a bubble a specific sound that is associated with each action is prodcued. The sounds do 
not differ when the same action is performed. 

### Data Sets or other Source Materials
We are not going to be using data sets or other source materials. We are attempting to emulate the classic flash game 'Bubble trouble 2'
from scratch in order to understand and reinforce the concepts learned in this class in an applicative way. 

### Deliverable and Demonstration

We now have a playable demo of a few levels, though there's no way to automatically go to the next or previous level without restarting the game and changing in the code which level to load, though there is a replay button.

### Evaluation of Results

We know we are successful since we were able to recreate the first level in "Bubble Trouble".

## Architecture Diagram
Upload the architecture diagram you made for your slide presentation to your repository, and include it in-line here.

Create several paragraphs of narrative to explain the pieces and how they interoperate.

## Schedule
From this proposal, we will take the code that we have already written in our first and second explorations and commit them to one
repository (this repository). We will then combine the concepts that we have worked on in our explorations into one file that will 
be our deliverable file, which we will work on together at a high level so that we both know what needs to be done and what is going on. 

From our combined explorations, we will then work towards our first milestone - getting multiple objects drawn to the sceen as well as
player controls. 

From our first milestone, we will then work on object collison detection and creating a head-up display (HUD) until we have completed 
those tasks for our second milestone. 

From our second milestone, we will work on fixing bugs, outlying errors, and time permitting the creation of multiple levels to 
create our deliverable project. 

### First Milestone (Sun Apr 9)
We will have multiple objects drawn to the screen as well as player controls implemented.

### Second Milestone (Sun Apr 16)
We will have object collison detection, basic bubble physics (when a bubble pops, it splits into 2 and bounces at a lower/higher height, etc.) and creating a head-up display (HUD) implemented.   

### Public Presentation (Mon Apr 24, Wed Apr 26, or Fri Apr 28 [your date to be determined later])
We will have bugs fixed, outlying errors fixed, and time permitting multiple levels implemented. 

## Group Responsibilities

### Molly McGuire @mollyelizabethmcguire11
will work on... 
- Drawing objects to the sceen for milestone 1, which includes bubbles, the user, and the hook 
- Collision detection for milestone 2, which includes bubble and hook collision and bubble and player collisions
- Bug fixing before the final presentation, as well as helping with the HUD and bubble physics

### Michael Danino @mdanino94
- Polished the player controls I already implemented in my exploration, added multiple sprites for when walking left/right
- Created a HUD that shows a level indicator and the number of lives left. 
- Implemented basic bubble physics
- Helped with player-bubble collision detection.
- Changed original implementation with hard-coded bubble objects to a list of bubble objects that can be mapped/filtered/folded on.
- Random bug fixing

lost screen image from http://4vector.com/i/free-vector-laughing-and-pointing-emoticon_133428_Laughing_and_pointing_emoticon.jpg

win screen image from http://gclipart.com/wp-content/uploads/2017/02/Smiling-sun-with-sunglasses-clipart.jpeg
