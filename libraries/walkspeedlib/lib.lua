local Lib = {}

function Lib:init()
	Utils.hook(ActorSprite, "update", function(orig, self)

		if not self.playing and self.actor.walk_anim_speed then
			local speed = self.actor.walk_anim_speed

			local floored_frame = math.floor(self.walk_frame)
			if floored_frame ~= self.walk_frame or ((self.directional or self.walk_override) and self.walking) then
				self.walk_frame = Utils.approach(self.walk_frame, floored_frame + 1, DT * (self.walk_speed > 0 and self.walk_speed*speed or 1*speed))
				local last_frame = self.frame
				self:setFrame(floored_frame)
				if self.frame ~= last_frame and self.on_footstep and self.frame % 2 == 0 then
					self.on_footstep(self, math.floor(self.frame/2))
				end
			elseif (self.directional or self.walk_override) and self.frames and not self.walking then
				self:setFrame(1)
			end
	
			self:updateDirection()
			return
		end

		orig(self)

		--self.sprite:setSprite("path/sprite")
	end)
end

return Lib
