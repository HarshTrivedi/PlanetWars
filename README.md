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

So as mentioned earlier, its built with ruby and shoes. So you need to have both of them. I will assume that you know how and from where to install ruby. For shoes, you need to install `shoes 3.3.1` from [here](http://shoesrb.com/downloads/). You can choose from the os distro that you have. PS: It's tested on Linux/Ununtu only. However, it will run appropriately on any Linux and Mac atleast. Can't be sure about Windows. 


### Usage:

You can either run `FinalPlanetMainClient.shy` from `open my shy script` option or you can choose `open an app` and select the `FinalPlanetWarsProject/Game.rb`.

##### Single Player:

Once the the interface opens, I guess rest of the things are intutive. You can check the controls in `controls` option: 

* To attack: Keep Pressed `s`, click the source planet, then click the target planet, and then release `s`. When source planet is selected 
* To exit: `Cntrl + C`
* To clear selection: `Esc`

One you choose `Single Player`: you will get option to choose from one of the two maps and choose one of the opponent bot. Each of these bots work on a simple strategy to defeat you.


##### Multi Player:

To run on multi-player, you need to run the server script `main_server_script.tb`. Make sure that your port `4000` is free.

If something like this appears: `Server started at -> 192.168.2.6:4000`. The server has started. 

Next up, open the shoes game and go to `multiplayer` option. Enter the server address as `ip:port` like `192.168.2.6:4000`. If you are playing for the first time, it will ask you to enter a name. Your status is online now! Later, in there you will be able to see the available players online. You can choose one of them and request to play. If the opponent accepts it, the game starts.


---

You can contact me at harshjtrivedi94@gmail.com in case of any problem.

