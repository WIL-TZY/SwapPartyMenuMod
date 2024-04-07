local Lib = {}

function Lib:init()
	Utils.hook(ActionBoxDisplay, 'draw', function(orig, self)
		if #Game.party <= 3 then orig(self) return end
		
		local parent = self.parent
		
		if Game.battle.current_selecting == self.actbox.index then
			love.graphics.setColor(self.actbox.battler.chara:getColor())
		else
			love.graphics.setColor(PALETTE["action_strip"], 1)
		end

		love.graphics.setLineWidth(2)
		love.graphics.line(0, Game:getConfig("oldUIPositions") and 2 or 1, parent.realWidth, Game:getConfig("oldUIPositions") and 2 or 1)

		love.graphics.setLineWidth(2)
		
		if Game.battle.current_selecting == self.actbox.index then
			love.graphics.line(1  , 2, 1,   36)
		end

		love.graphics.setColor(PALETTE["action_fill"])
		love.graphics.rectangle("fill", 2, Game:getConfig("oldUIPositions") and 3 or 2, parent.realWidth, Game:getConfig("oldUIPositions") and 34 or 35)

		do
			if Game.battle.current_selecting == self.actbox.index then
				love.graphics.setColor(self.actbox.battler.chara:getColor())
			else
				love.graphics.setColor(PALETTE["action_strip"], 1)
			end
			
			local x = parent.realWidth - 1
			love.graphics.line(x, 2, x, 36)
		end
		
		-- love.graphics.setColor(PALETTE["action_health_bg"])
		-- love.graphics.rectangle("fill", 128, 22 - self.actbox.data_offset, 76, 9)

		local health = (self.actbox.battler.chara.health / self.actbox.battler.chara:getStat("health")) * 76

		if health > 0 then
			love.graphics.setColor(self.actbox.battler.chara:getColor())
			-- love.graphics.rectangle("fill", 128, 22 - self.actbox.data_offset, health, 9)
		end

		if health <= 0 then
			love.graphics.setColor(PALETTE["action_health_text_down"])
		elseif (self.actbox.battler.chara.health <= (self.actbox.battler.chara:getStat("health") / 4)) then
			love.graphics.setColor(PALETTE["action_health_text_low"])
		else
			love.graphics.setColor(PALETTE["action_health_text"])
		end

		local health_offset = 0
		health_offset = (#tostring(self.actbox.battler.chara.health) - 1) * 8

		love.graphics.setFont(self.font)
		
		local x = parent.hp_sprite.x
		local string_width = self.font:getWidth(tostring(self.actbox.battler.chara:getStat("health")))
		
		if x + string_width > parent.realWidth then
			local dif = parent.realWidth - (x + string_width)
			x = (x + dif) - 2
		end
		
		local name_sprite = parent.name_sprite
		if name_sprite and name_sprite.x + name_sprite.width >= x then
			name_sprite.alpha = 0.5
		end
		
		love.graphics.print(self.actbox.battler.chara.health, x, 9 - self.actbox.data_offset)
		-- love.graphics.print("/", 161, 9 - self.actbox.data_offset)
		-- love.graphics.print(self.actbox.battler.chara:getStat("health"), 205 - string_width, 9 - self.actbox.data_offset)

		Object.draw(self)
	end)
	
	Utils.hook(ActionBox, "drawActionBox", function(orig, self)
		if #Game.party <= 3 then orig(self) return end
		
		if Game.battle.current_selecting == self.index then
			love.graphics.setColor(self.battler.chara:getColor())
			love.graphics.setLineWidth(2)
			love.graphics.line(1  , 2, 1,   37)
			love.graphics.line(self.realWidth, 2, self.realWidth, 37)
			love.graphics.line(0  , 6, self.realWidth, 6 )
		end
		
		love.graphics.setColor(1, 1, 1, 1)
	end)
	
	Utils.hook(ActionBox, "drawSelectionMatrix", function(orig, self)
		if #Game.party <= 3 then orig(self) return end
		
		-- Draw the background of the selection matrix
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 2, 2, self.realWidth, 35)

		if Game.battle.current_selecting == self.index then
			local r,g,b,a = self.battler.chara:getColor()

			for i = 0, 11 do
				local siner = self.selection_siner + (i * (10 * math.pi))

				love.graphics.setLineWidth(2)
				love.graphics.setColor(r, g, b, a * math.sin(siner / 60))
				if math.cos(siner / 60) < 0 then
					love.graphics.line(
						1 - (math.sin(siner / 60) * 30) + 30, 
						0,
						1 - (math.sin(siner / 60) * 30) + 30, 
						37
					)
						
					love.graphics.line(
						self.realWidth + (math.sin(siner / 60) * 30) - 30, 
						0, 
						self.realWidth + (math.sin(siner / 60) * 30) - 30, 
						37
					)
				end
			end

			love.graphics.setColor(1, 1, 1, 1)
		end
	end)
	
	Utils.hook(ActionBox, "update", function(orig, self)
		orig(self)
		
		if #Game.battle.party <= 3 then return end
		
		local hp_sprite = self.hp_sprite
		
		if hp_sprite.x + 16 >= self.realWidth then
			hp_sprite.visible = false
		end
		
		local name_sprite = self.name_sprite
		
		if name_sprite and name_sprite.x + name_sprite.width >= self.realWidth then
			name_sprite.visible = false
		end
		-- local btn_types = {"fight", "act", "magic", "item", "spare", "defend"}
			
		-- if not self.battler.chara:hasAct() then Utils.removeFromTable(btn_types, "act") end
		-- if not self.battler.chara:hasSpells() then Utils.removeFromTable(btn_types, "magic") end

		-- for lib_id,_ in pairs(Mod.libs) do
			-- btn_types = Kristal.libCall(lib_id, "getActionButtons", self.battler, btn_types) or btn_types
		-- end
		-- btn_types = Kristal.modCall("getActionButtons", self.battler, btn_types) or btn_types

		-- local x = 20
		
		-- for i,v in ipairs(self.buttons) do
			-- v.visible = (Game.battle.current_selecting == self.index)
			-- v.x = x
			
			-- if v.x + 32 > self.realWidth then
				-- v.visible = false
			-- end
			
			-- x = x + 32
		-- end
	end)
	
	Utils.hook(ActionBox, "init", function(orig, self, ...)
		orig(self, ...)

		if #Game.battle.party <= 3 then return end
		
		for i,v in ipairs(self.buttons) do
			v.visible = false
		end
	end)
	
	
	Utils.hook(ActionBox, "draw", function(orig, self, ...)
		orig(self, ...)
				
		if #Game.battle.party <= 3 then return end
			
		local buttons = self.buttons
		
		for i = 1, #buttons do
			local v = buttons[i]
			
			if v.hovered then
				love.graphics.push('all')
				love.graphics.translate(math.floor(self.realWidth * .5) - 16, v.y * .5)
				v:draw()
				
				local y = 26 * .5
				local prev = buttons[i - 1]
				
				-- if prev == nil then
					-- prev = buttons[#buttons]
				-- end
				
				if prev then
					love.graphics.push('all')
					love.graphics.scale(0.5, 0.5)
					love.graphics.translate(-34, y)
					prev:draw()
					love.graphics.pop()
				end
			
				local nex = buttons[i + 1]
				
				-- if nex == nil then
					-- nex = buttons[1]
				-- end
				
				if nex then
					love.graphics.push('all')
					love.graphics.scale(0.5, 0.5)
					love.graphics.translate(34 + (34 * .5) + (34 * .5), y)
					nex:draw()
					love.graphics.pop()
				end
				
				love.graphics.pop()
			end
		end
	end)
	
	Utils.hook(AttackBox, 'update', function(orig, self, ...)
		if #Game.battle.party <= 3 then return orig(self, ...) end
		
		if Game.battle.cancel_attack then
			self.fade_rect.alpha = Utils.approach(self.fade_rect.alpha, 1, DTMULT/20)
		end

		if not self.attacked then
			self.bolt:move(-AttackBox.BOLTSPEED * DTMULT, 0)

			self.afterimage_timer = self.afterimage_timer + DTMULT/2
			while math.floor(self.afterimage_timer) > self.afterimage_count do
				self.afterimage_count = self.afterimage_count + 1
				local afterimg = AttackBar(self.bolt_start_x - (self.afterimage_count * AttackBox.BOLTSPEED * 2), 0, 6, self.realHeight)
				afterimg.layer = 3
				afterimg.alpha = 0.4
				afterimg:fadeOutAndRemove()
				self:addChild(afterimg)
			end
		end

		if not Game.battle.cancel_attack and Input.pressed("confirm") then
			self.flash = 1
		else
			self.flash = Utils.approach(self.flash, 0, DTMULT/5)
		end

		Object.update(self)
	end)
	
	Utils.hook(AttackBox, 'draw', function(orig, self, ...)
		if #Game.party <= 3 then orig(self, ...) return end
		
		local target_color = {self.battler.chara:getAttackBarColor()}
		local box_color = {self.battler.chara:getAttackBoxColor()}

		if self.flash > 0 then
			box_color = Utils.lerp(box_color, {1, 1, 1}, self.flash)
		end

		love.graphics.setLineWidth(2)
		love.graphics.setLineStyle("rough")

		local h = (self.realHeight or 38) - 2
		
		love.graphics.setColor(box_color)
		love.graphics.rectangle("line", 80, 1, (15 * AttackBox.BOLTSPEED) + 3, h)
		love.graphics.setColor(target_color)
		love.graphics.rectangle("line", 83, 1, 8, h)

		love.graphics.setLineWidth(1)

		Object.draw(self)
	end)
	
	Utils.hook(BattleUI, "drawState", function(orig, self, ...)
		if #Game.party <= 3 then return orig(self, ...) end
		
		if not (Game.battle.state == "ATTACKING" or self.attacking) then
			return orig(self, ...)
		end
		
		local y = 40
		local h = (115 / #Game.battle.party)
		
		for _ = 1, #Game.battle.party do
			love.graphics.setColor(PALETTE["battle_attack_lines"])
			love.graphics.rectangle("fill", 79, y, 224, 2)
			y = y + h
		end
	end)
	
	Utils.hook(BattleUI, "beginAttack", function(orig, self, ...)
		orig(self, ...)
		
		if #Game.party <= 3 then return end
		
		local h = (115 / #Game.battle.party)
		
		for k,v in ipairs(self.attack_boxes) do
			v.head_sprite:remove()
			v.bolt.height = h
			v.fade_rect.height = v.bolt.height
			v.realHeight = v.bolt.height
			-- v:setScale(scale)
			v.y = 40 + (h * (k - 1)) 
		end
	end)
	
	Utils.hook(BattleUI, "init", function(orig, self, ...)
		orig(self, ...)
		
		if #Game.party <= 3 then return end
		
		local x = 0
		-- local w = ((108 * .5) + 212) * 2
		local realW = (SCREEN_WIDTH / #Game.party)
		
		for k,v in ipairs(self.action_boxes) do
			v.x = x
			v.realWidth = realW
			x = x + realW
		end
	end)
	
	Utils.hook(Encounter, "getPartyPosition", function(orig, self, index)
		if #Game.battle.party <= 3 then
			return orig(self, index)
		end
		
		local x, y = 0, 0
		x = 80
		y = (140 / #Game.battle.party) + (((SCREEN_HEIGHT * .5) / #Game.battle.party) * (index - 1))

		local battler = Game.battle.party[index]
		local ox, oy = battler.chara:getBattleOffset()
		x = x + (battler.actor:getWidth()/2 + ox) * 2
		y = y + (battler.actor:getHeight()  + oy) * 2
		return x, y
	end)
	
	Utils.hook(Battle, "init", function(orig, self, ...)
		orig(self, ...)

		if #Game.party <= 3 then return end
		
		for i = 4, #Game.party do
			local party_member = Game.party[i]

			local found = false
			
			for _,follower in ipairs(Game.world.followers) do
				if follower.visible and follower.actor.id == party_member:getActor().id then
					local chara_x, chara_y = follower:getScreenPos()
					local chara_battler = PartyBattler(party_member, chara_x, chara_y)
					chara_battler:setAnimation("battle/transition")
					self:addChild(chara_battler)
					table.insert(self.party, chara_battler)
					table.insert(self.party_beginning_positions, {chara_x, chara_y})
					self.party_world_characters[party_member.id] = follower

					follower.visible = false

					found = true
					break
				end
			end
			
			if not found then
				local chara_battler = PartyBattler(party_member, SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
				chara_battler:setAnimation("transition")
				self:addChild(chara_battler)
				table.insert(self.party, chara_battler)
				table.insert(self.party_beginning_positions, {chara_battler.x, chara_battler.y})
			end
		end
	end)
	
	print("Loaded MoreBattle")
end

return Lib