import nimraylib_now as raylib
import strformat
import random

type
  Player = ref object of RootObj
    x:int
    y:int
    w:int
    h:int
    speed:int

  HANDLE = int
  HWND = HANDLE
  LPCSTR = cstring
  UINT = uint

  Line = ref object of Player
  Rock = ref object of Player
    size:int

  Money = ref object of Player
  Heart = ref object of Player

let
  ScreenWidth:int = 500
  ScreenHeight:int = 800

var
  player:Player = Player(x:60,y:744,w:50,h:50,speed:1)

  money1:Money = Money(x:250,y:80,w:25,h:25,speed:1)
  money2:Money = Money(x:400,y:80,w:25,h:25,speed:2)
  money3:Money = Money(x:50,y:80,w:25,h:25,speed:3)

  rock1:Rock = Rock(x:150,y:80,w:75,h:75,speed:1,size:3)
  rock2:Rock = Rock(x:325,y:80,w:50,h:50,speed:2,size:2)
  rock3:Rock = Rock(x:25,y:80,w:25,h:25,speed:3,size:1)

  heart:Heart = Heart(x:175,y:80,w:30,h:30,speed:2)

  fps:int = 60
  score:int = 0
  hp:int = 5

  line1:Line = Line(x:0,y:70,w:500,h:10)

# =============================================== Function
proc MessageBoxA(hwnd:HWND, lpText:LPCSTR, lpCap:LPCSTR, uType:UINT):UINT {. discardable, fastcall, dynlib:"user32", importc:"MessageBoxA".}

proc playerMove() =
  if raylib.isKeyDown(D) and player.x < ScreenWidth - player.w:
    player.x += int((fps * player.speed)/8)

  if raylib.isKeyDown(A) and player.x > 0:
    player.x -= int((fps * player.speed)/8)

proc MoneyMove(this:Money) =
  if this.y > -1:
    this.y += int((fps * this.speed)/15)
  if this.y > ScreenHeight - this.w:
    this.y = 80
    this.x = rand(0..400)
  if this.x <= player.x+player.w and player.x <= this.x+this.w and this.y <= player.y+player.h and player.y <= this.y+this.h:
    inc(score)
    this.y = 80
    this.x = rand(0..400)

proc RockMove(this:Rock) =
  if this.y > -1:
    this.y += int((fps * this.speed)/15)
  if this.y > ScreenHeight - this.w:
    this.y = 80
    this.x = rand(0..400)
  if this.x <= player.x+player.w and player.x <= this.x+this.w and this.y <= player.y+player.h and player.y <= this.y+this.h:
    this.y = 80
    this.x = rand(0..400)
    case this.size
    of 1:
      hp -= 1
    of 2:
      hp -= 2
    else:
      hp -= 3

proc HeartMove(this:Heart) =
  if this.y > -1:
    this.y += int((fps * this.speed)/15)
  if this.y > ScreenHeight - this.w:
    this.y = 80
    this.x = rand(0..400)
  if this.x <= player.x+player.w and player.x <= this.x+this.w and this.y <= player.y+player.h and player.y <= this.y+this.h:
    inc(hp)
    this.y = 80
    this.x = rand(0..400)

setTargetFPS(fps)

when isMainModule:
  initWindow(ScreenWidth, ScreenHeight, "Catch Coins")

  MessageBoxA(0,"This is a small game of collecting gold coins. Please control A and D to control the left and right directions to eat gold coins and avoid meteorites. When your life reaches zero, you will lose. If you eat more than 50 gold coins, you will win!!!","Attention",0)

  while not windowShouldClose():
    beginDrawing()
    clearBackground(Black)

    drawText(&"FPS:{fps}",20,20,30,White)
    drawText(&"Score:{score}",150,20,30,Yellow)
    drawText(&"HP:{hp}",300,20,30,Green)

    # 玩家
    drawRectangle(player.x,player.y,player.w,player.h,Green)
    # 錢錢 ========================================================***
    drawRectangle(money1.x,money1.y,money1.w,money1.h,Yellow)
    drawRectangle(money2.x,money2.y,money2.w,money2.h,Yellow)
    drawRectangle(money3.x,money3.y,money3.w,money3.h,Yellow)
    # 隕石 ========================================================***
    drawRectangle(rock1.x,rock1.y,rock1.w,rock1.h,Gray)
    drawRectangle(rock2.x,rock2.y,rock2.w,rock2.h,Gray)
    drawRectangle(rock3.x,rock3.y,rock3.w,rock3.h,Gray)
    # 愛心 ========================================================***
    drawRectangle(heart.x,heart.y,heart.w,heart.h,Pink)

    drawRectangle(line1.x,line1.y,line1.w,line1.h,Purple)

    endDrawing()

    playerMove()
    MoneyMove(money1)
    MoneyMove(money2)
    MoneyMove(money3)
    
    RockMove(rock1)
    RockMove(rock2)
    RockMove(rock3)

    HeartMove(heart)

    if hp <= 0:
      fps = 0
      drawText(&"Game Over",int(ScreenWidth/2-120),int(ScreenHeight/2),50,White)
    if score >= 50:
      fps = 0
      drawText(&"You Win",int(ScreenWidth/2)-100,int(ScreenHeight/2),50,White)
