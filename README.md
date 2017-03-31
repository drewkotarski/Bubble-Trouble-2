# Bubble Trouble 2 Emulator

### Statement
Our project is a racket remake of the flash game "Bubble Trouble". It's interesting because we learn how to use racket libraries and implement and manipulate different objects with a functional language. It's interesting to us because we both played it in elementary/middle school so it's nostalgic. We hope to learn how to apply some of the concepts we learned in class to a project that has a clear result of what we want to see in the end.

### Analysis
We will be using object orientation to hold our "player" object, "hook" or object that will be shot from the player to pop bubbles. To manipulate these objects, we will use data abstraction to update the x/y variables, as well as delete objects from the universe. To check whether collisions occurred (either hook hits bubble, or bubble hits player) we will filter over the objects x/y positions. state modification will be used within each object to update the location, for example. if the left arrow key is held, the player will move 10 units to the left (set! x (- x 10)). 

### External Technologies
Our project will generate or produce sound, because the original flash game produces sounds as well. When the hook is deployed, 
a bubble is popped, or the player is hit by a bubble a specific sound that is associated with each action is prodcued. The sounds do 
not differ when the same action is performed. 

### Data Sets or other Source Materials
We are not going to be using data sets or other source materials. We are attempting to emulate the classic flash game 'Bubble trouble 2'
from scratch in order to understand and reinforce the concepts learned in this class in an applicative way. 

### Deliverable and Demonstration

What we will have at the end of this semester is are playable levels that resemble those of the original game. At the live demo, we 
we will be able to run our racket code and have observers play the levels that we have successfully emulated. The player will be able 
to deploy the hook with the space bar, move the characcter with the arrow keys, and interact with objects successfully in the game 
itself. 

What will be produced at the end of the project is and interactive deliverable that anyone can play on- which will produce the same 
results no matter who is playing it. This means that the project will work to the means that we have specified in our code as well 
as our proposal, where no matter how the user interacts with our project it will not break. 

### Evaluation of Results
We will know that we are successful if we can reproduce one level from the game with some margin of similarity, with the most
simple level (level 1) successfully emulated. We will be successful if we can produce level 1 from 'Bubble trouble 2' that uses the 
same user inputs as the game, produces the same results when the imputs are used, and dose not break when other imputs are selected. 

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
Drawing objects to the sceen for milestone 1, collision detection for milestone 2, and any bug fixing before the final presentation. 

### Michael Danino @mdanino94
will work on... 
- Polishing the player controls I already implemented in my exploration, possibly adding multiple sprites for when walking left/right
- Creating a HUD that will show a menu for enabling/disabling sound, a timer, and level indicator, as well as basic bubble physics
- Any necessary bug fixing related to this, as well as helping with collision detection/drawing multiple objects when necessary.
