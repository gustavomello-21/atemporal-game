require("camera")
log = require "libs/log"
game = {
  width = 375,
  height = 812,
  scale = 1,
  score = 0,
  collision = false,
  background1 = "text.png",
  background2 = "text2.png",
  music_menu = love.audio.newSource( 'sounds/menu_music.mp3', 'static' ),
  music_medieval = love.audio.newSource( 'sounds/medieval_music.mp3', 'static' ),
  music_realidade = love.audio.newSource( 'sounds/realidade_music.mp3', 'static' ),
  music_futuro = love.audio.newSource( 'sounds/futuro_music.mp3', 'static' ),
  jump_sound = love.audio.newSource( 'sounds/jump.mp3', 'static' ),
  game_over_sound = love.audio.newSource( 'sounds/game_over_sound.mp3', 'static' ),
  state = "menu"
}

player = {
  x = 187-22,
  y = 812-34,
  velx = 3,
  width = 44,
  height = 68,
  direction = "right",
  jump_height = -300,
  gravity = -500,
  current_image_left = "",
  current_image_right = "",
  current_time = "passado"
}

platform = {}
platforms = {
  count = 2000,
  distance_y = 90
}
platform_count = 0

function menu_keypressed(key)
  if key == "space" then
    game.state = "play"
    game.music_menu:stop()
    game.music_medieval:play()
  elseif key == "escape" then
    love.event.quit()
  end
end

function gameover_keypressed(key)
  love.event.quit('restart')
  -- game.state = "play"
  -- love.load()
end

function checkCollision(a, b)
  -- não-colisão no eixo x
  if player.y_velocity < 0 then
    return false
  end
  if
    b.x > a.x + a.width or
    a.x > b.x + b.width then

    return false
  end

  -- não-colisão no eixo y
  if
    b.y > a.y + a.height or
    a.y > b.y + b.height then

    return false
  end

  return true
end

function drawBackground()
  love.graphics.draw(background1, 0)
  game.background_offset = game.background_offset - camera._y - game.height
end

function checkAllCollision()
  for i = 1, #platforms do
    if checkCollision(player, platforms[i]) then

      if(platforms[i].is_visited == false) then
        game.score = game.score + 1
        platforms[i].is_visited = true
      end

      aux = player.current_time
      player.current_time = platforms[i].age

      if(aux ~= player.current_time) then
        if player.current_time == "presente" then
          game.music_medieval:stop()
          game.music_realidade:play()
        elseif player.current_time == "futuro" then
          game.music_realidade:stop()
          game.music_futuro:play()
        end
      end

      game.jump_sound:play()
      return true
    end
  end

  return false
end

function love.keypressed(key, scan_code, is_repeat)
  if game.state == "menu" then
    menu_keypressed(key)
  elseif game.state == "gameover" then
    gameover_keypressed(key)
  end
end

function draw_score()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(game.score, camera._x + 25, camera._y + 25)
end

function love.load()
  menu_image = love.graphics.newImage("game/background_start.png")
  gameover_image = love.graphics.newImage("game/game_over.png")

  camera:setBounds(0, 0, game.width, 9999)
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.math.setRandomSeed(os.time())

  love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
  love.window.setMode(
    game.width * game.scale,
    game.height * game.scale
  )

  love.graphics.setFont(love.graphics.newFont(50))

  platform.image_medieval = love.graphics.newImage("platforms/medieval_platform.png")
  platform.image_realidade = love.graphics.newImage("platforms/reality_platform.png")
  platform.image_futuro = love.graphics.newImage("platforms/future_platform.png")

  player.image = love.graphics.newImage("characters/passado_direita.png")
  player.ground = player.y     -- This makes the character land on the plaform.
  player.y_velocity = 0        -- Whenever the character hasn't jumped yet, the Y-Axis velocity is always at 0.

	player.jump_height = -300    -- Whenever the character jumps, he can reach this height.
	player.gravity = -500        -- Whenever the character falls, he will descend at this rate.

  --platform
  platform.width = 75    -- This makes the platform as wide as the whole game window.
	platform.height = 10  -- This makes the platform as tall as the whole game window.

        -- This is the coordinates where the platform will be rendered.
	platform.x = 0                               -- This starts drawing the platform at the left edge of the game window.
	platform.y = game.height - 70             -- This starts drawing the platform at the very middle of the game window

  --platform
  platform.width = 75    -- This makes the platform as wide as the whole game window.
	platform.height = 10  -- This makes the platform as tall as the whole game window.

  for i = 1, platforms.count do
    platformObj = {}

    if (i >= 1 and i <= 25) then
      image_platform = platform.image_medieval
      current_age = "passado"
      current_valx = love.math.random(0, 5)
    elseif (i > 25 and i <= 42) then
      image_platform = platform.image_realidade
      current_age = "presente"
      current_valx = love.math.random(3, 8)
    else
      image_platform = platform.image_futuro
      current_age = "futuro"
      current_valx = love.math.random(5, 10)
    end

    if (i % 2 == 0) then
      isEven = true
    else
      isEven = false
    end

    if (isEven) then
      platformObj = {
        width = platform.width,
        height = platform.height,
        x = love.math.random(20, (game.width / 2 - 75)),
        y = game.height - (platforms.distance_y * i),
        velx = current_valx,
        isRight = true,
        index = i,
        image_source = image_platform,
        age = current_age,
        is_visited = false
      }
      platforms[i] = platformObj
    else
      platformObj = {
        width = platform.width,
        height = platform.height,
        x = love.math.random(game.width / 2, (game.width - 95)),
        y = game.height - (platforms.distance_y * i),
        velx = current_valx,
        isRight = true,
        index = i,
        image_source = image_platform,
        age = current_age,
        is_visited = false
      }

      platforms[i] = platformObj
    end
  end
-- music
  game.music_menu:setLooping( true )
  game.music_medieval:setLooping( true )
  game.music_realidade:setLooping( true )
  game.music_futuro:setLooping( true )

  game.music_menu:setVolume(0.5)
  game.music_medieval:setVolume(0.5)
  game.music_realidade:setVolume(0.5)
  game.music_futuro:setVolume(0.5)

  game.jump_sound:setLooping( false )

  game.music_menu:play()

  -- background
  background1 = love.graphics.newImage('times/medieval_start.png')
  background2 = love.graphics.newImage('times/medieval.png')
  background3 = love.graphics.newImage('times/medieval_end.png')
  background4 = love.graphics.newImage('times/reality.png')
  background5 = love.graphics.newImage('times/reality_end.png')
  background6 = love.graphics.newImage('times/future.png')
end

function love.update(dt)
  if game.state == "menu" then
    love.graphics.setBackgroundColor(0, 191/255, 255)
  elseif game.state == "play" then
    game.collision = false
    -- player movement

    if player.direction == "direita" then
      player.image = love.graphics.newImage("/characters/"..player.current_time.."_direita.png")
    else
      player.image = love.graphics.newImage("/characters/"..player.current_time.."_esquerda.png")
    end

    if love.keyboard.isDown("left") then
      player.direction = "left"

      player.x = player.x - player.velx
    end

    if love.keyboard.isDown("right") then
      player.direction = "right"
      player.x = player.x + player.velx
    end

    if player.x < 0 then
      player.x = 0
    end

    if player.x + player.width > game.width then
      player.x = game.width - player.width
    end

    --jumping

    if player.y_velocity == 0 then
      player.y_velocity = player.jump_height    -- The player's Y-Axis Velocity is set to it's Jump Height.
    end

    if player.y_velocity ~= 0 then                                      -- The game checks if player has "jumped" and left the ground.
      player.y = player.y + player.y_velocity * dt                -- This makes the character ascend/jump.
      player.y_velocity = player.y_velocity - player.gravity * dt -- This applies the gravity to the character.
    end

    if checkAllCollision() then    -- The game checks if the player has jumped.
      player.ground = player.y
      player.y_velocity = 0       -- The Y-Axis Velocity is set back to 0 meaning the character is on the ground again..
      platform_count = platform_count + 1
    end

    if player.y + player.height > camera._y + game.height then
      if platform_count > 0 then

        game.music_medieval:stop()
        game.music_realidade:stop()
        game.music_futuro:stop()

        game.state = "game/gameover"
        game.game_over_sound:play()
      else
        player.ground = player.y
        player.y_velocity = 0
      end
    end
    if platform_count == 1 then
      camera:setSpeed(-1.5)
    end

    --platform
    for i = 1, platforms.count do
      if platforms[i].x + platforms[i].width >= game.width then
        platforms[i].isRight = false
      end
      if platforms[i].x <= 0 then
        platforms[i].isRight = true
      end
      if platforms[i].isRight then
        platforms[i].x = platforms[i].x + platforms[i].velx
      else
        platforms[i].x = platforms[i].x - platforms[i].velx
      end
    end

    camera:move(0, camera.speed)
  end
end

function love.draw()
  if game.state == "menu" then
    love.graphics.draw(menu_image, 0, 0)
  elseif game.state == "play" then

    love.graphics.draw(background1, 0, - camera._y)

    love.graphics.draw(background2, 0, - camera._y - game.height)

    love.graphics.draw(background3, 0, - camera._y - (game.height * 2))

    love.graphics.draw(background4, 0, - camera._y - (game.height * 3))

    love.graphics.draw(background5, 0, - camera._y - (game.height * 4))

    for j = 5, 50 do
      love.graphics.draw(background6, 0, - camera._y - (game.height * j))
    end

    camera:set()

    for i = 1, platforms.count do
      love.graphics.draw(platforms[i].image_source,
        platforms[i].x,
        platforms[i].y
      )
    end

    love.graphics.setColor(1, 1, 1)        -- This sets the platform color to white.

          -- The platform will now be drawn as a white rectangle while taking in the variables we declared above.
    love.graphics.draw(player.image, player.x, player.y, 0, 2, 2)

    draw_score()

    camera:unset()
  elseif game.state == "game/gameover" then
    love.graphics.draw(gameover_image, 0, 0)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(game.score, game.width / 2 - 20, game.height / 2 + 30)
  end
end

function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end
