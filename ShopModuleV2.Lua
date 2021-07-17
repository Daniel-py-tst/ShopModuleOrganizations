--Models must have a primarypart acting as a root
--Only the root must be anchored



--Sorting Tables
local frame = script.Parent.ShopUiFrame
local function PredicatorForInstance(a,b)
	return a.Name < b.Name
end

local T = game.Workspace.Shop.ShopItems:GetChildren()
table.sort(T, PredicatorForInstance)

local function SortertableOranizer(tab)
	local t = {}
	for i, v in ipairs(tab) do
		for i, letter in ipairs(frame.DetailsFrame.Items:GetChildren()) do
			if v.Name == letter.Name then
				t[v] = {false, letter}
			end
		end
	end
	return t
end

local ItemTable = SortertableOranizer(T)
print(ItemTable)

local function WeldModelsToRoot(Table)
	for i, Item in ipairs(Table) do
		if Item:IsA("Model") then
			for i, Part in ipairs(Item:GetChildren()) do
				if Part:IsA("BasePart") then
					local weld = Instance.new("WeldConstraint", Part)
					weld.Part0 = Part
					weld.Part1 = Item.PrimaryPart
				end
			end
		end
	end
end

WeldModelsToRoot(T)

local c c = game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Wait()
	print("Done")
	c:Disconnect()
end)

--Controllers and Variables

CurrentItem = 1
local tweenTime = .5
local bd = true
local db = true
local lighting = game.Lighting
local left = frame.Left
local right = frame.Right
local close = frame.Close
local ReturnPart = game.Workspace.Shop.ReturnPoint
local ShowcasePoint = game.Workspace.Shop.ShowCasePoint
local player = game.Players.localPlayer
local character = player.Character
local AnchorPart = character:WaitForChild("RightFoot")
local Camera = workspace.CurrentCamera
local open = game.Workspace.Shop.Open
local openPrompt = open.ProximityPrompt
local anchorSurf = game.Workspace.Shop.AnchorPoint
local weldyboi = Instance.new("WeldConstraint")
weldyboi.Parent = game.Workspace

--Services
local TweenService = game:GetService("TweenService")
local Runservice = game:GetService("RunService")

--misc Functions
local function MoveToParent(obj, space)
	obj.Parent = space
end

local function anchorTo(FPart, SPart)
	weldyboi.Part0 = FPart
	weldyboi.Part1 = SPart
end

--Tweens
local tweenToView = TweenService:Create(
	Camera,
	TweenInfo.new(1),
	{CFrame = game.Workspace.Shop.LookPoint.CFrame}
)

--Functions
--------------------------------------------------------------------------------------------------------------
-- Cometic functions

local function ShowObj(SortedTable, ObjectStateTable)
	--Tweening to Showcase
	ObjectStateTable[T[CurrentItem]][2].Visible = true
	if SortedTable[CurrentItem]:IsA("Model") then
		local t1 = TweenService:Create(SortedTable[CurrentItem].PrimaryPart,TweenInfo.new(tweenTime),{CFrame = ShowcasePoint.CFrame})
		t1:Play()
		t1.Completed:Wait()
	else
		local t2 = TweenService:Create(SortedTable[CurrentItem],TweenInfo.new(tweenTime),{CFrame = ShowcasePoint.CFrame})
		t2:Play()
		t2.Completed:Wait()
	end
	
	--Ensure current item spins
	ObjectStateTable[T[CurrentItem]][1] = true
	
	--spin event
	local c c = Runservice.Heartbeat:Connect(function()
		if ObjectStateTable[T[CurrentItem]][1] == true then
			if T[CurrentItem]:IsA("Model") then
				T[CurrentItem]:SetPrimaryPartCFrame(T[CurrentItem]:GetPrimaryPartCFrame() * CFrame.Angles(0,.05,0.01))
			else
				T[CurrentItem].CFrame *= CFrame.Angles(0,.05,0.01)
			end
		else
			print("disconnected")
			c:Disconnect()
		end 
	end)
end


local function TweenBackCurrobj(obj, returnp, SortedTable)
	if SortedTable[CurrentItem]:IsA("Model") then
		local t1 = TweenService:Create(obj.PrimaryPart,TweenInfo.new(tweenTime),{CFrame = returnp.CFrame})
		t1:Play()
		t1.Completed:Wait()
	else
		local t2 = TweenService:Create(obj,TweenInfo.new(tweenTime),{CFrame = returnp.CFrame})
		t2:Play()
		t2.Completed:Wait()
	end
end



--LogicFunctions
--------------------------------------------------------------------------------------------------------------
--Moves the return part to the current obj
local function SetReturnPart(Tab)
	if Tab[CurrentItem]:IsA("Model") then
		ReturnPart.CFrame = Tab[CurrentItem]:GetPrimaryPartCFrame()
	else
		ReturnPart.Position = T[CurrentItem].Position
	end
end


local function Open()
	MoveToParent(open, lighting)
	anchorTo(AnchorPart, anchorSurf)
	Camera.CameraType = Enum.CameraType.Scriptable 
	tweenToView:Play()
	tweenToView.Completed:Wait()
	frame.Visible = true
	ShowObj(T, ItemTable)
end

--RightButton
local function Next()
	if db == true then
		db = false
		--causes the current spining item to stop
		ItemTable[T[CurrentItem]][1] = false
		ItemTable[T[CurrentItem]][2].Visible = false
		TweenBackCurrobj(T[CurrentItem], ReturnPart, T)
		--value changer of item
		if CurrentItem >= #T then
			CurrentItem = 1
		else
			-- moves right
			CurrentItem += 1
		end
		SetReturnPart(T)
		--runs the function which causes the new current item to spin, if next is clicked again, it'll change its state to false.
		ShowObj(T, ItemTable)
		db = true
	end
end


--LeftButton
local function Prev()
	if bd == true then
		bd = false
		--Checks table end
		ItemTable[T[CurrentItem]][1] = false
		ItemTable[T[CurrentItem]][2].Visible = false
		TweenBackCurrobj(T[CurrentItem], ReturnPart, T)
		if CurrentItem <= 1 then
			CurrentItem = #T
		else
			-- moves left
			CurrentItem -= 1
		end
		SetReturnPart(T)

		ShowObj(T, ItemTable)
		bd = true
	end

end

local function Close()
	TweenBackCurrobj(T[CurrentItem], ReturnPart, T)
	ItemTable[T[CurrentItem]][1] = false
	ItemTable[T[CurrentItem]][2].Visible = false
	CurrentItem = 1
	SetReturnPart(T)
	weldyboi.Part1 = nil
	Camera.CameraType = Enum.CameraType.Custom
	frame.Visible = false
	MoveToParent(open, game.Workspace)
end


close.MouseButton1Down:Connect(Close)
openPrompt.Triggered:Connect(Open)
right.MouseButton1Down:Connect(Next)
left.MouseButton1Down:Connect(Prev)

