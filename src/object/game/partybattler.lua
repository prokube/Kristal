local PartyBattler, super = Class(Object)

function PartyBattler:init(chara, x, y)
    self.chara = chara
    self.actor = Registry.getActor(chara.actor)

    super:init(self, x, y, self.actor.width, self.actor.height)

    self.layer = -10

    self.sprite = ActorSprite(self.actor)
    self.sprite.facing = "right"

    self:addChild(self.sprite)

    self:setOrigin(0.5, 1)
    self:setScale(2)

    -- default to the idle animation, handle the battle intro elsewhere
    self:setAnimation("battle/idle")
end

function PartyBattler:hurt(amount)
    self.chara.health = self.chara.health - amount
    self:statusMessage("max", amount)
    self:setAnimation("battle/hurt")
end

function PartyBattler:heal(amount)
    love.audio.newSource("assets/sounds/snd_power.wav", "static"):play()
    self.chara.health = self.chara.health + amount
    if self.chara.health > self.chara.stats.health then
        self.chara.health = self.chara.stats.health
        self:statusMessage("msg", "max")
    else
        self:statusMessage("heal", amount, {0, 1, 0})
    end
end

function PartyBattler:statusMessage(type, arg, color)

    local x, y = self:getRelativePos(self.parent, -self.width, self.height/2)

    local percent = DamageNumber(type, arg, x - 4, y + 16, color)
    percent.kill_others = true
    self.parent:addChild(percent)

end

function PartyBattler:setActSprite(sprite, ox, oy, speed, loop, after)

    self:setCustomSprite(sprite, ox, oy, speed, loop, after)

    local x = self.x - (self.actor.width/2 + ox) * 2
    local y = self.y - (self.actor.height + oy) * 2
    local flash = FlashFade(sprite, x, y)
    flash:setOrigin(0, 0)
    flash:setScale(self:getScale())
    self.parent:addChild(flash)

    local afterimage1 = AfterImage(self, 0.5)
    local afterimage2 = AfterImage(self, 0.6)
    afterimage1.speed_x = 2.5
    afterimage2.speed_x = 5

    afterimage2.layer = afterimage1.layer - 1

    self:addChild(afterimage1)
    self:addChild(afterimage2)
end

-- Shorthand for convenience
function PartyBattler:setAnimation(animation, callback)
    return self.sprite:setAnimation(animation, callback)
end

function PartyBattler:setSprite(sprite, speed, loop, after)
    self.sprite:setSprite(sprite)
    if not self.sprite.directional and speed then
        self.sprite:play(speed, loop, after)
    end
end

function PartyBattler:setCustomSprite(sprite, ox, oy, speed, loop, after)
    self.sprite:setCustomSprite(sprite, ox, oy)
    if not self.sprite.directional and speed then
        self.sprite:play(speed, loop, after)
    end
end

return PartyBattler