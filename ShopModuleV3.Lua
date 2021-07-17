local Shop = {}
Shop.__index = Shop

local TweenService = game:GetService("TweenService")
local Runservice = game:GetService("RunService")
local Essentials = require(game:GetService("ReplicatedStorage"):WaitForChild("EssentialFunctions"))

local function SortertableOranizer(tab, FrameTab)
	local t = {}
	local T = tab
	table.sort(T, function(a,b) return a.Name < b.Name end)
	
	for i, v in ipairs(T) do
		for i, letter in ipairs(FrameTab) do
			if v.Name == letter.Name then
				t[v] = {false, letter}
			end
		end
	end
	return T, t
end



function Shop:New(ShopFolder, GuiFrame)
	

	local t = setmetatable({},self)
	t.__index = t
	Essentials.WeldModelsToRoot(ShopFolder.ShopItems:GetChildren())
	
	self.clickSound = ShopFolder.Sounds.click2down
	self.purchaseSound = ShopFolder.Sounds.purchase
	self.frame = GuiFrame
	self.left = GuiFrame.Left
	self.right =  GuiFrame.Right
	self.close =  GuiFrame.Close
	self.buy =  GuiFrame.Buy
	self.showcasePart = ShopFolder.Parts.ShowCasePoint
	self.viewPart = ShopFolder.Parts.ViewPoint
	self.anchorPart = ShopFolder.Parts.AnchorPoint
	self.returnPart = ShopFolder.Parts.ReturnPoint
	self.openPart = ShopFolder.Parts.OpenPoint
	self.camera = workspace.CurrentCamera
	self.weldCon = ShopFolder.Parts.Weld
	self.currentItem = 1
	self.uiT = .2
	self.tweenTime = .35
	self.T,self.ItemTable = SortertableOranizer(ShopFolder.ShopItems:GetChildren(), GuiFrame.DetailsFrame.Items:GetChildren())
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	local function SetReturnPart()
		if self.T[self.currentItem]:IsA("Model") then
			self.returnPart.CFrame = self.T[self.currentItem]:GetPrimaryPartCFrame()
		else
			self.returnPart.Position = self.T[self.currentItem].Position
		end
	end
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	local function TweenBackPrevobj()
		self.ItemTable[self.T[self.currentItem]][1] = false
		self.ItemTable[self.T[self.currentItem]][2].Visible = false
		
		self.buy.TextLabel.Text = "..."
		
		if self.T[self.currentItem]:IsA("Model") then
			local t1 = TweenService:Create(self.T[self.currentItem].PrimaryPart,TweenInfo.new(self.tweenTime),{CFrame = self.returnPart.CFrame})
			t1:Play()
			--t1.Completed:Wait() --optional wait()
		else
			local t2 = TweenService:Create(self.T[self.currentItem],TweenInfo.new(self.tweenTime),{CFrame = self.returnPart.CFrame})
			t2:Play()
			--t2.Completed:Wait() --optional wait()
		end
	end
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	
	self.Next = function()
		self.clickSound:Play()
		TweenBackPrevobj()

		if self.currentItem >= #self.T then
			self.currentItem = 1
		else
			-- moves right
			self.currentItem += 1
		end
		SetReturnPart()
	end
	
	
	self.Prev = function()
		self.clickSound:Play()
		TweenBackPrevobj()
		
		if  self.currentItem <= 1 then
			self.currentItem = #self.T
		else
			-- moves left
			self.currentItem -= 1
		end
		SetReturnPart()
	end
	
	self.Show = function(T,ObjectStateTable)
		if T[self.currentItem]:IsA("Model") then
			local t1 = TweenService:Create(T[self.currentItem].PrimaryPart,TweenInfo.new(self.tweenTime),{CFrame = self.showcasePart.CFrame})
			t1:Play()
			t1.Completed:Wait()
		else
			local t2 = TweenService:Create(T[self.currentItem],TweenInfo.new(self.tweenTime),{CFrame = self.showcasePart.CFrame})
			t2:Play()
			t2.Completed:Wait()
		end
		
		ObjectStateTable[T[self.currentItem]][1] = true
		ObjectStateTable[T[self.currentItem]][2].Visible = true
		local c c = Runservice.Heartbeat:Connect(function()
			if ObjectStateTable[T[self.currentItem]][1] == true then
				--show.Text = "Current Part: "..ObjectStateTable[T[CurrentItem]][2].N.Text
				self.frame.Buy.TextLabel.Text = "$"..ObjectStateTable[T[self.currentItem]][2].Price.Value
				if T[self.currentItem]:IsA("Model") then
					T[self.currentItem]:SetPrimaryPartCFrame(T[self.currentItem]:GetPrimaryPartCFrame() * CFrame.Angles(0,.05,0.01))
				else
					T[self.currentItem].CFrame *= CFrame.Angles(0,.05,0.01)
				end
			else
				c:Disconnect()
			end
		end)
	end
	

	local function OpenAct(player, Camera, TweenTo)
		Essentials.anchorTo(self.weldCon, player.Character:WaitForChild("RightFoot"), self.anchorPart)
		Essentials.MoveToParent(self.openPart, game.Lighting)
		----------------------------------------------------------------------------------------
		Camera.CameraType = Enum.CameraType.Scriptable 
		local t = TweenService:Create(Camera,TweenInfo.new(1),{CFrame = TweenTo.CFrame})
		t:Play()
		t.Completed:Wait()
		----------------------------------------------------------------------------------------
	end

	
	self.openPart.ProximityPrompt.Triggered:Connect(function(player)
		self.clickSound:Play()
		OpenAct(player,workspace.CurrentCamera, self.viewPart)
		Essentials.uiTween(self.frame.DetailsFrame, 1, self.uiT)
		self.frame.Visible = true
		self.Show(self.T, self.ItemTable)
	end)
	
	self.close.MouseButton1Down:Connect(function()
		self.clickSound:Play()
		TweenBackPrevobj()
		self.currentItem = 1
		SetReturnPart()
		self.weldCon.Part1 = nil
		self.camera.CameraType = Enum.CameraType.Custom
		self.frame.Visible = false
		Essentials.MoveToParent(self.openPart, game.Workspace)
	end)
	
	
	
	
		return t
end







return Shop
