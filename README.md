# Planet-Wars Game

> So this is basically a desktop game that I had developed 2 years back for my Computer Networks course project. The idea of game is taken from a game called [Galcon Fusion](https://www.galcon.com/fusion/). The game is playable on LAN network against a real opponent or just in single player mode against a bot. It is implemented in Ruby : ) - used a tiny GUI framework called [Shoes](http://shoesrb.com/) for it.

Few snapshots from the game: 

Home Window                |  Game Play Window
:-------------------------:|:-------------------------:
![Home Image](README-Images/home_image.png?raw=true)  |  ![Game Play Image](README-Images/game_play.png?raw=true)





### Game Playing:

There is a galaxy with lots of planets. Initially one of them belongs to you and one belongs to the opponent - identified by red/blue. Gray ones are the unconquered ones. Your target (to win ) is to conquer all planets in the galaxy board. 

But, how to win? Some notes:

* Each planet has some fighting fleets on it - identified by the number on the planet. 
* You can use these fleets as weapons and send your fleets to attack the opponent planet / neutral planet. 
* With the attack order you will be able to see the fleets flying through galaxy - identified by a number. 
* When these fleets reach the other planet, if the sent number of fleets are more than the fleets located on that planet then you have conquered that planet. 
* On each attack, from source planet half the number of fleets present will be used for attacking the targeted planet. 
* Also, the planets that are owned by any one player are not static - their number of fleets grow at the rate proportional to their visible size. 
* So, this way, you have to win all the planets to win the galaxy. :+1:

### Installation:



### Usage:

