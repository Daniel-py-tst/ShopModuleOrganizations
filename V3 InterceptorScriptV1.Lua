local player = game.Players.LocalPlayer
local Shop = require(game:GetService("ReplicatedStorage"):WaitForChild("oop"))
db = true

local PotionShop = Shop:New(game.Workspace.ShopFolder, player.PlayerGui:WaitForChild("ShopUi"):WaitForChild("ShopUiFrame"))


PotionShop.right.MouseButton1Down:Connect(function()
	if db == true then
		db = false
		PotionShop.Next()
		PotionShop.Show(PotionShop.T,PotionShop.ItemTable)
		db = true
	end
end)

PotionShop.left.MouseButton1Down:Connect(function()
	if db == true then
		db = false
		PotionShop.Prev()
		PotionShop.Show(PotionShop.T,PotionShop.ItemTable)
		db = true
	end
end)
