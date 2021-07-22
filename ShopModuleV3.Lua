local Shop = {}
Shop.__index = Shop

local TweenService = game:GetService("TweenService")
local Runservice = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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



function Shop:New(ShopFolder, GuiFrame, Player)
	

	local newShop = setmetatable({},Shop)
	newShop.__index = newShop
	Essentials.WeldModelsToRoot(ShopFolder.ShopItems:GetChildren())
	
	newShop.buyEvent = ReplicatedStorage:WaitForChild("BuyTool")
	newShop.clickSound = ShopFolder.Sounds.click2down
	newShop.purchaseSound = ShopFolder.Sounds.purchase
	
	newShop.frame = GuiFrame
	newShop.left = GuiFrame.Left
	newShop.right =  GuiFrame.Right
	newShop.close =  GuiFrame.Close
	newShop.buy =  GuiFrame.Buy
	
	newShop.buyFrame = newShop.frame.Parent.BuyFrame
	newShop.yes = newShop.buyFrame.SureFrame.Yes
	newShop.no = newShop.buyFrame.SureFrame.No
	
	newShop.player = Player
	newShop.showcasePart = ShopFolder.Parts.ShowCasePoint
	newShop.viewPart = ShopFolder.Parts.ViewPoint
	newShop.anchorPart = ShopFolder.Parts.AnchorPoint
	newShop.returnPart = ShopFolder.Parts.ReturnPoint
	newShop.openPart = ShopFolder.Parts.OpenPoint
	newShop.camera = workspace.CurrentCamera
	newShop.weldCon = ShopFolder.Parts.Weld
	newShop.currentItem = 1
	newShop.n = .1
	newShop.uiT = .2
	newShop.tweenTime = .35
	newShop.T,newShop.ItemTable = SortertableOranizer(ShopFolder.ShopItems:GetChildren(), GuiFrame.DetailsFrame.Items:GetChildren())
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	local function SetReturnPart()
		if newShop.T[newShop.currentItem]:IsA("Model") then
			newShop.returnPart.CFrame = newShop.T[newShop.currentItem]:GetPrimaryPartCFrame()
		else
			newShop.returnPart.Position = newShop.T[newShop.currentItem].Position
		end
	end
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	local function TweenBackPrevobj()
		newShop.ItemTable[newShop.T[newShop.currentItem]][1] = false
		newShop.ItemTable[newShop.T[newShop.currentItem]][2].Visible = false
		
		newShop.buy.TextLabel.Text = "..."
		
		if newShop.T[newShop.currentItem]:IsA("Model") then
			local t1 = TweenService:Create(newShop.T[newShop.currentItem].PrimaryPart,TweenInfo.new(newShop.tweenTime),{CFrame = newShop.returnPart.CFrame})
			t1:Play()
		else
			local t2 = TweenService:Create(newShop.T[newShop.currentItem],TweenInfo.new(newShop.tweenTime),{CFrame = newShop.returnPart.CFrame})
			t2:Play()
		end
	end
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	function Shop:Next()
		newShop.clickSound:Play()
		TweenBackPrevobj()

		if newShop.currentItem >= #newShop.T then
			newShop.currentItem = 1
		else
			-- moves right
			newShop.currentItem += 1
		end
		SetReturnPart()
	end
	
	
	function Shop:Prev()
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
	--newShop.Prev = function()
		
	--end
	function Shop:Show()
		if self.T[self.currentItem]:IsA("Model") then
			local t1 = TweenService:Create(self.T[self.currentItem].PrimaryPart,TweenInfo.new(self.tweenTime),{CFrame = self.showcasePart.CFrame})
			t1:Play()
		else
			local t2 = TweenService:Create(self.T[self.currentItem],TweenInfo.new(self.tweenTime),{CFrame = self.showcasePart.CFrame})
			t2:Play()
		end
		wait(self.n)
		self.ItemTable[self.T[self.currentItem]][1] = true
		self.ItemTable[self.T[self.currentItem]][2].Visible = true
		local c c = Runservice.Heartbeat:Connect(function()
			if self.ItemTable[self.T[newShop.currentItem]][1] == true then
				--show.Text = "Current Part: "..ObjectStateTable[T[CurrentItem]][2].N.Text
				self.frame.Buy.TextLabel.Text = "$"..self.ItemTable[self.T[self.currentItem]][2].Price.Value
				if self.T[self.currentItem]:IsA("Model") then
					self.T[self.currentItem]:SetPrimaryPartCFrame(self.T[self.currentItem]:GetPrimaryPartCFrame() * CFrame.Angles(0,.05,0.01))
				else
					self.T[self.currentItem].CFrame *= CFrame.Angles(0,.05,0.01)
				end
			else
				c:Disconnect()
			end
		end)
	end

	

	local function OpenAct(player, Camera, TweenTo)
		Essentials.anchorTo(newShop.weldCon, player.Character:WaitForChild("RightFoot"), newShop.anchorPart)
		Essentials.MoveToParent(newShop.openPart, game.Lighting)
		----------------------------------------------------------------------------------------
		Camera.CameraType = Enum.CameraType.Scriptable 
		local t = TweenService:Create(Camera,TweenInfo.new(1),{CFrame = TweenTo.CFrame})
		t:Play()
		t.Completed:Wait()
		----------------------------------------------------------------------------------------
	end

	
	newShop.openPart.ProximityPrompt.Triggered:Connect(function(player)
		newShop.clickSound:Play()
		newShop.buy.TextLabel.Text = "..."
		OpenAct(player,workspace.CurrentCamera, newShop.viewPart)
		Essentials.uiTween(newShop.frame.DetailsFrame, 1, newShop.uiT)
		newShop.frame.Visible = true
		newShop:Show()
	end)
	
	newShop.close.MouseButton1Down:Connect(function()
		newShop.clickSound:Play()
		TweenBackPrevobj()
		newShop.currentItem = 1
		SetReturnPart()
		newShop.weldCon.Part1 = nil
		newShop.camera.CameraType = Enum.CameraType.Custom
		newShop.frame.Visible = false
		Essentials.MoveToParent(newShop.openPart, game.Workspace)
	end)

	newShop.buy.MouseButton1Down:Connect(function()
		newShop.clickSound:Play()
		newShop.frame.Visible = false

		newShop.buyFrame.SureFrame.SureCheck.Text = "Are you sure you want to buy "..string.lower(newShop.ItemTable[newShop.T[newShop.currentItem]][2].N.Text).."?"
		newShop.buyFrame.Visible = true
		Essentials.uiTween(newShop.buyFrame.SureFrame, 1, newShop.uiT)
		newShop.buyFrame.SureFrame.Visible = true
	end)
	
	
	newShop.yes.MouseButton1Down:Connect(function(player)
		newShop.clickSound:Play()
		newShop.buyEvent:FireServer(newShop.ItemTable[newShop.T[newShop.currentItem]][2].Name)
		if newShop.player.leaderstats.Cash.Value >= newShop.ItemTable[newShop.T[newShop.currentItem]][2].Price.Value then
			newShop.purchaseSound:Play()
			Essentials.emiter(newShop.showcasePart.Attachment)
			newShop.buyFrame.Visible = false
			Essentials.uiTween(newShop.frame.DetailsFrame, 1, newShop.uiT)
			newShop.frame.Visible = true
		else
			newShop.buyFrame.SureFrame.Visible = false
			Essentials.uiTween(newShop.buyFrame.NotEnoughFrame, 1, newShop.uiT)
			newShop.buyFrame.NotEnoughFrame.Visible = true
			
		end
	end)
	
	
	newShop.no.MouseButton1Down:Connect(function()
		newShop.clickSound:Play()
		newShop.buyFrame.Visible = false
		Essentials.uiTween(newShop.frame.DetailsFrame, 1, newShop.uiT)
		newShop.frame.Visible = true
	end)
	
	return newShop
end


return Shop
