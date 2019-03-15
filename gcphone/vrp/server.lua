local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

RegisterServerEvent('vrp_addons_gcphone:startCall')
AddEventHandler('vrp_addons_gcphone:startCall', function (number, message, coords)
  local source = source
  local user_id = vRP.getUserId({source})

  vRPclient.notify(source,{"Seu chamado foi solicitado a um "..number})
  vRP.sendServiceAlert{(source,number,coords.x,coords.y,coords.z,message})
end)