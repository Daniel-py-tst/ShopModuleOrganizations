local Shop = require(script.Parent)
db = true


local PotionShop = Shop:New(game.Workspace.ShopFolder, player.PlayerGui:WaitForChild("ShopUi"):WaitForChild("ShopUiFrame"), game.Players.LocalPlayer)


for i,v in pairs({PotionShop.right, PotionShop.left}) do
	v.MouseButton1Down:Connect(function()
		if db == true then
			db = false
			if v == PotionShop.left then
				PotionShop:Prev()
			else
				PotionShop:Next()
			end
			PotionShop:Show()
			db = true
		end		
	end)
end
