import nimraylib_now as rb
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
  Bullet = ref object of Player

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
  bullet:Bullet = Bullet(x:player.x,y:player.y,w:15,h:15,speed:1)

  bFlag:bool = false
  flag:bool = false

  fps:int = 60
  score:int = 0
  hp:int = 5

  line1:Line = Line(x:0,y:70,w:500,h:10)

# =============================================== Function
proc MessageBoxA(hwnd:HWND, lpText:LPCSTR, lpCap:LPCSTR, uType:UINT):UINT {. discardable, fastcall, dynlib:"user32", importc:"MessageBoxA".}

proc playerMove() =
  if rb.isKeyDown(D) and player.x < ScreenWidth - player.w:
    player.x += int((fps * player.speed)/8)

  if rb.isKeyDown(A) and player.x > 0:
    player.x -= int((fps * player.speed)/8)

  if rb.isKeyDown(W) and player.y > ScreenHeight div 2:
    player.y -= int((fps * player.speed)/8)

  if rb.isKeyDown(S) and player.y < ScreenHeight - player.h:
    player.y += int((fps * player.speed)/8)

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

  if this.x <= bullet.x+bullet.w and bullet.x <= this.x+this.w and this.y <= bullet.y+bullet.h and bullet.y <= this.y+this.h:
    this.y = 80
    this.x = rand(0..400)
    bFlag = false
    flag = false


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

proc main() =
  initWindow(ScreenWidth, ScreenHeight, "Catch Coins")

  MessageBoxA(0,"This is a small game of collecting gold coins. Please control A and D to control the left and right directions to eat gold coins and avoid meteorites. When your life reaches zero, you will lose. If you eat more than 50 gold coins, you will win!!!","Attention",0)

  var
# =============================================== 背景圖
    bgImage:Image = loadImage("sky.png")
    bgTexture:Texture2D = loadTextureFromImage(bgImage)

# =============================================== 火箭圖 
    rImage:Image = loadImage("rocket.png")
    rTexture:Texture2D = loadTextureFromImage(rImage)

# =============================================== 勝利圖 
    winImage:Image = loadImage("win.png")
    winTexture:Texture2D = loadTextureFromImage(winImage)

# =============================================== 失敗圖 
    loseImage:Image = loadImage("gameover.png")
    loseTexture:Texture2D = loadTextureFromImage(loseImage)

# =============================================== rock1圖 
    r1Image:Image = loadImage("rock1.png")
    r1Texture:Texture2D = loadTextureFromImage(r1Image)

# =============================================== rock2圖 
    r2Image:Image = loadImage("rock2.png")
    r2Texture:Texture2D = loadTextureFromImage(r2Image)

# =============================================== rock3圖
    r3Image:Image = loadImage("rock3.png")
    r3Texture:Texture2D = loadTextureFromImage(r3Image)

# =============================================== 金錢圖
    mImage:Image = loadImage("money.png")
    mTexture:Texture2D = loadTextureFromImage(mImage)

# =============================================== 愛心圖
    hImage:Image = loadImage("heart.png")
    hTexture:Texture2D = loadTextureFromImage(hImage)

# =============================================== 子彈圖 
    bImage:Image = loadImage("bullet.png")
    bTexture:Texture2D = loadTextureFromImage(bImage)

  unloadImage(bgImage)
  unloadImage(rImage)
  unloadImage(winImage)
  unloadImage(loseImage)
  unloadImage(r1Image)
  unloadImage(r2Image)
  unloadImage(r3Image)
  unloadImage(mImage)
  unloadImage(bImage)
  unloadImage(hImage)

  while not windowShouldClose():  

    # 背景
    drawTexture(bgTexture, 0, 0, White)

    beginDrawing:
      clearBackground(Raywhite)

      drawText(&"FPS:{fps}",20,20,30,Black)
      drawText(&"Score:{score}",150,20,30,Green)
      drawText(&"HP:{hp}",300,20,30,Red)

      # 玩家
      drawTexture(rTexture, player.x,player.y,White)

      # 錢錢 ========================================================***
      drawTexture(mTexture,money1.x,money1.y,White)
      drawTexture(mTexture,money2.x,money2.y,White)
      drawTexture(mTexture,money3.x,money3.y,White)
      # 隕石 ========================================================***
      drawTexture(r1Texture,rock1.x,rock1.y,White)
      drawTexture(r2Texture,rock2.x,rock2.y,White)
      drawTexture(r3Texture,rock3.x,rock3.y,White)
      # 愛心 ========================================================***
      drawTexture(hTexture,heart.x,heart.y,White)

      # 框架 ========================================================***
      drawRectangle(line1.x,line1.y,line1.w,line1.h,Purple)

      if hp <= 0:
        fps = 0
        drawTexture(loseTexture, ScreenWidth div 2 - loseTexture.width div 2, ScreenHeight div 2 - loseTexture.height div 2, White)

      if score >= 50:
        drawTexture(winTexture, ScreenWidth div 2 - winTexture.width div 2, ScreenHeight div 2 - winTexture.height div 2, White)
        fps = 0

      if isKeyDown(Space) and not flag:
        bullet.y = player.y
        bullet.x = player.x
        bFlag = true

      if bFlag:
        flag = true
        drawTexture(bTexture, bullet.x, bullet.y, White)
        bullet.y -= int((fps * bullet.speed)/8) 
        if bullet.y < 0:
          bullet.y = player.y
          bullet.x = player.x
          bFlag = false
          flag = false


    playerMove()
    MoneyMove(money1)
    MoneyMove(money2)
    MoneyMove(money3)
    
    RockMove(rock1)
    RockMove(rock2)
    RockMove(rock3)

    HeartMove(heart)

  unloadTexture(bgTexture)
  unloadTexture(rTexture)
  unloadTexture(winTexture)
  unloadTexture(loseTexture)
  unloadTexture(r1Texture)
  unloadTexture(r2Texture)
  unloadTexture(r3Texture)
  unloadTexture(mTexture)
  unloadTexture(hTexture)
  unloadTexture(bTexture)

  closeWindow()

main()
