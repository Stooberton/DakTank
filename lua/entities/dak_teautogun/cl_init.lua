include("shared.lua")

function ENT:Draw()

	self:DrawModel()

end

function ENT:Think()
	if not(self:GetPhysicsObject():IsValid()) then
		self:PhysicsDestroy()
		self:PhysicsInit(SOLID_VPHYSICS)
	end
	if self.Scaled == nil then self.Scaled = 0 end
	if self.CycleVal == nil then self.CycleVal = 0.05 end
	if self.LastFire2 == nil then self.LastFire2 = false end
	local Caliber = self:GetNWFloat("Caliber")

	--NOTE: this stuff might need to be set per model
	if Caliber > 0 and self.Scaled == 0 then
		--get bounds of both bones since its got recoil so we can add length of gun barrel on
		if self:GetModel() == "models/daktanks/mortar100mm2.mdl" then
			local mins1, maxs1 = self:GetHitBoxBounds( 0, 0 )
			local mins2, maxs2 = self:GetHitBoxBounds( 1, 0 )
			self:SetCollisionBounds( mins1, Vector(-mins2.x,maxs1.y,maxs1.z) )
			self:PhysicsInitBox( mins1, Vector(-mins2.x,maxs1.y,maxs1.z) )
		end
		self.Scaled = 1
	end
	if self:GetModel() == "models/daktanks/mortar100mm2.mdl" then
		if self:GetNWBool("Firing") == true and self:GetNWBool("Firing")~=self.LastFire2 then
			self:SetSequence( self:LookupSequence( "recoil" ) )
			self.CycleVal = 0.05
			self:SetCycle( self.CycleVal )
			timer.Create( "RecoilTimer"..self:EntIndex()..CurTime(), 0.005, 200, function()
				self.CycleVal = self.CycleVal + 0.005
				self:SetCycle( self.CycleVal )
			end)
		end
		self.LastFire2 = self:GetNWBool("Firing")
	end

	--NOTE: stuff past this is universal
	if self.Scaled == 1 then
		self:GetPhysicsObject():SetPos(self:GetPos())
		self:GetPhysicsObject():SetAngles(self:GetAngles())
		self:GetPhysicsObject():EnableMotion( false )
	end

	if Caliber >= 40 then
		if (self:GetNWBool("Firing")) == true and self:GetNWBool("Firing")~=self.LastFire then
			local pitch = math.Rand(0.95, 1.05)
			local Dir = LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000)
			local Vol = math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/5000 ),0,1)
			--13503.9 speed of sound in inches
			timer.Simple(LocalPlayer():GetPos():Distance(self:GetPos())/13503.9, function()
				if self:IsValid() then
					sound.Play( self:GetNWString("FireSound"), Dir, 100, 100*pitch, Vol )
					if Caliber >= 75 then
						sound.Play( self:GetNWString("FireSound"), Dir, 100, 100*pitch, Vol )
					end
					if Caliber >= 100 then
						sound.Play( self:GetNWString("FireSound"), Dir, 100, 100*pitch, Vol )
					end
					if Caliber >= 150 then
						sound.Play( self:GetNWString("FireSound"), Dir, 100, 100*pitch, Vol )
					end
					if Caliber >= 250 then
						sound.Play( self:GetNWString("FireSound"), Dir, 100, 100*pitch, Vol )
					end
				end
				util.ScreenShake( self:GetPos(), math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/(500*Caliber) ),0,1) * 2.5, 2.5, 1.0, 5000000 )
			end)
		end
		self.LastFire = self:GetNWBool("Firing")
	end
	--if Caliber >= 75 then
	--	if (self:GetNWBool("Exploding")) == true and self:GetNWBool("Exploding")~=self.LastExp then
	--		sound.Play( "daktanks/distexp1.mp3", LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000), 100, 100, math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/(500*self:GetNWFloat("ExpDamage")) ),0,1) )
	--	end
	--	self.LastExp = self:GetNWBool("Exploding")
	--end
end