Hello,

I've implemented my battle simulator game, Khan, using Lua with LÖVE. There are two ways in which my game can be run. Either way, downloading Love from this link (https://love2d.org/#download) and making sure the file is unzipped is necessary. After doing so, you can drag the project file (the file called "Khan") onto Love's icon. Placing Love on the taskbar might be necessary in order to be able to do this. Another way of running the project after downloading Love is enabling the Love2D support extension if you are using VS Code, dragging the project folder onto a new window, and then pressing CMD + L while the window is open. This will automatically run the game as long as the folder is open in the current window and the open editor is a .lua file from within the project.

The code itself is fully documented, and I believe I have written comments above anything that might need clarification. I've also included a file called SOURCES.txt file where I cite links to the sources from which I gathered media resources. The game itself provides simple instructions that the user can follow to progress through the game. The "enter" key is used as a state changer throughout the game, so the user will move through the storyline by clicking enter. Inside battle scenes, the user will be able to see information about the army that they control and the army that they are facing, and they will be prompted at different times during the battle for a choice. When they are, pressing the corresponding number (1, 2, or 3) will allow the user to make the choice that is offered to them. The main concern in each battle is morale, as when an army's morale reaches zero, it loses the battle. There are three battles the user can play, and the user has unlimited attempts with each battle before achieving victory. After the user is victorious in each battle, they move onto the next, and if they win the final battle, they are greeted with an end message and an instruction to restart the game, if they wish to do so.