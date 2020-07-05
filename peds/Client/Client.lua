--[ peds menu powered by: https://szymczakovv.pl ]--
-- Nazwa: peds menu
-- Autor: Szymczakovv#0001
-- Data: 05/06/2020
-- Wersja: 0.01

local Pool = MenuPool.New()
local MainMenu = UIMenu.New('Wybierz Postać', '~b~www.szymczak.pl')
local Items = {}
Pool:Add(MainMenu)


local IsAdmin

RegisterNetEvent('szymczak:AdminStatusChecked')
AddEventHandler('szymczak:AdminStatusChecked', function(State) 
	IsAdmin = State
end)


Citizen.CreateThread(function()
	szymczak.CheckStuff()

	while true do
		Citizen.Wait(0)

        Pool:ProcessMenus()

		if ((GetIsControlJustPressed(szymczak.KBKey) and GetLastInputMethod(2)) or ((GetIsControlPressed(szymczak.GPKey1) and GetIsControlJustPressed(szymczak.GPKey2)) and not GetLastInputMethod(2))) then
			MainMenu:Visible(not MainMenu:Visible())
		end
	end
end)

RegisterNetEvent('szymczak:GotPeds')
AddEventHandler('szymczak:GotPeds', function(AddOnPeds)
	for Key, Value in pairs(AddOnPeds) do
		local Ped = UIMenuItem.New(Value.DisplayName, 'Model Postaci: ' .. Value.SpawnName)
		MainMenu:AddItem(Ped)
		table.insert(Items, {Ped, Value.SpawnName})
	end

	MainMenu.OnItemSelect = function(Sender, Item, Index)
		for Key, Value in pairs(Items) do
			if Item == Value[1] then
				szymczak.SpawnPed(Value[2])
			end
		end
	end

	Pool:RefreshIndex()
end)


function szymczak.SpawnPed(Model)
	Model = GetHashKey(Model)
	if IsModelValid(Model) then
		if not HasModelLoaded(Model) then
			RequestModel(Model)
			while not HasModelLoaded(Model) do
				Citizen.Wait(0)
			end
		end
		
		SetPlayerModel(PlayerId(), Model)
		SetPedDefaultComponentVariation(PlayerPedId())
		
		SetModelAsNoLongerNeeded(Model)
	else
		SetNotificationTextEntry('STRING')
		AddTextComponentString('~r~Zły Model')
		DrawNotification(false, false)
	end
end

function szymczak.CheckStuff()
	IsAdmin = nil
	if szymczak.Tylkodlaadminow then
		TriggerServerEvent('szymczak:CheckAdminStatus')
		while (IsAdmin == nil) do
			Citizen.Wait(0)
		end
		if IsAdmin then
			TriggerServerEvent('szymczak:GetPeds')
		end
	else
		TriggerServerEvent('szymczak:GetPeds')
	end
end

function GetIsControlPressed(Control)
	if IsControlPressed(1, Control) or IsDisabledControlPressed(1, Control) then
		return true
	end
	return false
end

function GetIsControlJustPressed(Control)
	if IsControlJustPressed(1, Control) or IsDisabledControlJustPressed(1, Control) then
		return true
	end
	return false
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght, NoSpaces)
	AddTextEntry(GetCurrentResourceName() .. '_KeyboardHead', TextEntry)
	DisplayOnscreenKeyboard(1, GetCurrentResourceName() .. '_KeyboardHead', '', ExampleText, '', '', '', MaxStringLenght)

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		if NoSpaces == true then
			drawNotification('~y~SRC ERR')
		end
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		return result
	else
		Citizen.Wait(500)
		return nil
	end
end


