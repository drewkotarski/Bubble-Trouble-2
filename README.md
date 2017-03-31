# Bubble Trouble 2 Emulator

### Statement
Describe your project. Why is it interesting? Why is it interesting to you personally? What do you hope to learn? 

### Analysis
Explain what approaches from class you will bring to bear on the project.

Be explicit about the techiques from the class that you will use. For example:

- Will you use data abstraction? How?
- Will you use recursion? How?
- Will you use map/filter/reduce? How? 
- Will you use object-orientation? How?
- Will you use functional approaches to processing your data? How?
- Will you use state-modification approaches? How? (If so, this should be encapsulated within objects. `set!` pretty much should only exist inside an object.)
- Will you build an expression evaluator, like we did in the symbolic differentatior and the metacircular evaluator?
- Will you use lazy evaluation approaches?

The idea here is to identify what ideas from the class you will use in carrying out your project. 

**Your project will be graded, in part, by the extent to which you adopt approaches from the course into your implementation, _and_ your discussion about this.**

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
We will have object collison detection and creating a head-up display (HUD) implementd.   

### Public Presentation (Mon Apr 24, Wed Apr 26, or Fri Apr 28 [your date to be determined later])
We will have bugs fixed, outlying errors fixed, and time permitting multiple levels implemented. 

## Group Responsibilities

### Molly McGuire @mollyelizabethmcguire11
- Drawing objects to the sceen for milestone 1, which includes multiple bubbles, the user, and the hook.
- Collision detection for milestone 2, which includes popping bubbles with the hook and bubbles hitting the user
- Bug fixing before the final presentation, as well as helping with the HUD and bubble physics 

### Leonard Lambda @lennylambda
will work on... 
