local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPadngc = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
Tunnel.bindInterface("vrp_addon_gcphone",vRPadngc)

local PhoneNumbers        = {}

-- PhoneNumbers = {
--   police = {
--     type  = "police",
--     sources = {
--        ['3'] = true
--     }
--   }
-- }

--[[
function notifyAlertSMS (number, alert, listSrc)
  if PhoneNumbers[number] ~= nil then
    for k, _ in pairs(listSrc) do
      getPhoneNumber(tonumber(k), function (n)
        if n ~= nil then
          TriggerEvent('gcPhone:_internalAddMessage', number, n, 'De #' .. alert.numero  .. ' : ' .. alert.message, 0, function (smsMess)
            TriggerClientEvent("gcPhone:receiveMessage", tonumber(k), smsMess)
          end)
          if alert.coords ~= nil then
            TriggerEvent('gcPhone:_internalAddMessage', number, n, 'GPS: ' .. alert.coords.x .. ', ' .. alert.coords.y, 0, function (smsMess)
              TriggerClientEvent("gcPhone:receiveMessage", tonumber(k), smsMess)
            end)
          end
        end
      end)
    end
  end
end



AddEventHandler('esx_phone:registerNumber', function(number, type, sharePos, hasDispatch, hideNumber, hidePosIfAnon)
  print('==== Enregistrement du telephone ' .. number .. ' => ' .. type)
	local hideNumber    = hideNumber    or false
	local hidePosIfAnon = hidePosIfAnon or false

	PhoneNumbers[number] = {
		type          = type,
    sources       = {},
    alerts        = {}
	}
end)


AddEventHandler('esx:setJob', function(source, job, lastJob)
  if PhoneNumbers[lastJob.name] ~= nil then
    TriggerEvent('esx_addons_gcphone:removeSource', lastJob.name, source)
  end

  if PhoneNumbers[job.name] ~= nil then
    TriggerEvent('esx_addons_gcphone:addSource', job.name, source)
  end
end)
]]
--[[
AddEventHandler('vrp_addons_gcphone:addSource', function(number, source)
	PhoneNumbers[number].sources[tostring(source)] = true
end)

AddEventHandler('vrp_addons_gcphone:removeSource', function(number, source)
	PhoneNumbers[number].sources[tostring(source)] = nil
end)
]]

RegisterServerEvent('vrp_addons_gcphone:startCall')
AddEventHandler('vrp_addons_gcphone:startCall', function (number, message, coords)
  local source = source
  local user_id = vRP.getUserId(source)
  local player = vRP.getUserSource(user_id)

  vRPclient.notify(player,"Seu chamado foi solicitado a um "..number)
  vRP.sendServiceAlert(source, number,coords.x,coords.y,coords.z,message)

--[[
  local source = source
  if PhoneNumbers[number] ~= nil then
    getPhoneNumber(source, function (phone) 
      notifyAlertSMS(number, {
        message = message,
        coords = coords,
        numero = phone,
      }, PhoneNumbers[number].sources)
    end)
  else
    print('Appels sur un service non enregistre => numero : ' .. number)
  end]]
end)

--[[
AddEventHandler('vRP:playerSpawn', function(user_id, source, first_spawn)
  local xPlayer = user_id
  print('logou telefone')
  print(vRP.getUserGroupByType(xPlayer,"job"))
  MySQL.Async.fetchAll('SELECT * FROM vrp_user_identities WHERE user_id = @identifier',{
    ['@identifier'] = xPlayer
  }, function(result)
    local phoneNumber = result[1].phone
    print(phoneNumber)
--    xPlayer.set('phoneNumber', phoneNumber)
    if PhoneNumbers[vRP.getUserGroupByType(xPlayer,"job")] ~= nil then
      TriggerEvent('vrp_addons_gcphone:addSource', vRP.getUserGroupByType(xPlayer,"job"), source)
    end
  end)

end)


AddEventHandler('vRP:playerLeave', function(user_id, source)
  local source = source
  local xPlayer = user_id 
  print('saindo')
  print(user_id)
  print(vRP.getUserGroupByType(xPlayer,"job"))
  if PhoneNumbers[vRP.getUserGroupByType(xPlayer,"job")] ~= nil then
    TriggerEvent('vrp_addons_gcphone:removeSource', vRP.getUserGroupByType(xPlayer,"job"), source)
  end
end)


function getPhoneNumber (source, callback) 
  local user_id = vRP.getUserId(source)
  if user_id == nil then
    callback(nil)
  end
  MySQL.Async.fetchAll('SELECT * FROM vrp_user_identities WHERE user_id  = @identifier',{
    ['@identifier'] = user_id
  }, function(result)
    callback(result[1].phone)
  end)
end
]]