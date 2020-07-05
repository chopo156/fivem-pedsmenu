--[ peds menu powered by: https://szymczakovv.pl ]--
-- Nazwa: peds menu
-- Autor: Szymczakovv#0001
-- Data: 05/06/2020
-- Wersja: 0.01

AddOnPedsTable = {}

Citizen.CreateThread(function()
	local AddOnPedsTXT = LoadResourceFile(GetCurrentResourceName(), 'peds.cs'):gsub('\r', '\n')
	if AddOnPedsTXT ~= nil and AddOnPedsTXT ~= '' then
		if not (AddOnPedsTXT:find('SpawnName') or AddOnPedsTXT:find('DisplayName')) then
			AddOnPedsTable = GetAddOns(AddOnPedsTXT)
		elseif AddOnPedsTXT:find('SpawnName') or AddOnPedsTXT:find('DisplayName') then
			print('peds.cs jest nie poprawnym plikiem')
			AddOnPedsTXT = AddOnPedsTXT:gsub('\nDisplayName: \n', ''):gsub('\nSpawnName: ', ''):gsub('SpawnName: ', ''):gsub('\nDisplayName: ', ':')
			SaveResourceFile(GetCurrentResourceName(), 'peds.cs', AddOnPedsTXT, -1)
			
			AddOnPedsTable = GetAddOns(AddOnPedsTXT)
		else
			print('peds.cs format jest nieznany')
		end
	else
		print('peds.cs jest puste')
	end
end)

RegisterServerEvent('szymczak:GetPeds') 
AddEventHandler('szymczak:GetPeds', function()
	TriggerClientEvent('szymczak:GotPeds', source, AddOnPedsTable)
end)

--Admin Check

RegisterServerEvent('szymczak:CheckAdminStatus') 
AddEventHandler('szymczak:CheckAdminStatus', function()
	local IDs = GetPlayerIdentifiers(source)
	local Admins = LoadResourceFile(GetCurrentResourceName(), 'admlist.cs')
	local AdminsSplitted = stringsplit(Admins, '\n')
	for k, AdminID in pairs(AdminsSplitted) do
		local AdminID = AdminID:gsub(' ', '')
		local SingleAdminsSplitted = stringsplit(AdminID, ',')
		for _, ID in pairs(IDs) do
			if ID:lower() == SingleAdminsSplitted[1]:lower() or ID:lower() == SingleAdminsSplitted[2]:lower() or ID:lower() == SingleAdminsSplitted[3]:lower() then
				TriggerClientEvent('szymczak:AdminStatusChecked', source, true); return
			end
		end
	end
end)

AddEventHandler('es:playerLoaded', function(Source, user)
	if user.getGroup() == 'admin' or user.getGroup() == 'superadmin' then
		TriggerClientEvent('szymczak:AdminStatusChecked', Source, true)
	end
end)

function stringsplit(input, seperator)
	if seperator == nil then
		seperator = '%s'
	end
	
	local t={} ; i=1
	
	for str in string.gmatch(input, '([^'..seperator..']+)') do
		t[i] = str
		i = i + 1
	end
	
	return t
end

function GetAddOns(AddOnPedsTXT)
	local AddOnPedsTXTSplitted = stringsplit(AddOnPedsTXT, '\n')
	local ReturnTable = {}
	
	for Key, Value in ipairs(AddOnPedsTXTSplitted) do
		if Value:find(':') then
			local PedInformations = stringsplit(Value, ':')
			if #PedInformations == 2 then
				local SpawnName = PedInformations[1]
				local DisplayName = PedInformations[2]
				if SpawnName and SpawnName ~= '' and DisplayName and DisplayName ~= '' then
					table.insert(ReturnTable, {['SpawnName'] = SpawnName, ['DisplayName'] = DisplayName})
				end
			end
		end
	end
	return ReturnTable
end

