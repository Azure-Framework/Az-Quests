local RESOURCE = GetCurrentResourceName()

local function dprint(...)
  
  
end

local function notify(msg)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(tostring(msg))
  DrawNotification(false, false)
end

local function vecDist(a, b)
  return #(a - b)
end




local state = {
  uiOpen = false,
  quests = {},           
  progress = {},         
  activeQuestId = nil,   
  blip = nil,
}




local function questById(id)
  for _, q in ipairs(state.quests) do
    if q.id == id then return q end
  end
  return nil
end

local function getCompletedCount(qid)
  return tonumber(state.progress[qid] or 0) or 0
end

local function isQuestCompleted(qid)
  local q = questById(qid)
  if not q then return false end
  return getCompletedCount(qid) >= #q.points
end

local function currentTarget(qid)
  local q = questById(qid)
  if not q then return nil end
  local done = getCompletedCount(qid)
  local idx = done + 1
  if idx > #q.points then return nil end
  return q.points[idx], idx, #q.points
end

local function clearBlip()
  if state.blip and DoesBlipExist(state.blip) then
    RemoveBlip(state.blip)
  end
  state.blip = nil
end

local function makeBlipForPoint(pt)
  clearBlip()
  if not Config.UseBlips then return end
  state.blip = AddBlipForCoord(pt.coords.x, pt.coords.y, pt.coords.z)
  SetBlipSprite(state.blip, 280) 
  SetBlipScale(state.blip, 0.9)
  SetBlipColour(state.blip, 27)  
  SetBlipAsShortRange(state.blip, false)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(("Quest: %s"):format(pt.label or "Target"))
  EndTextCommandSetBlipName(state.blip)
end

local function setWaypoint(pt)
  if not Config.UseWaypoint then return end
  SetNewWaypoint(pt.coords.x, pt.coords.y)
end

local function sendUi()
  SendNUIMessage({
    type = "sync",
    open = state.uiOpen,
    theme = Config.Theme,
    discord = Config.Discord,
    quests = state.quests,
    progress = state.progress,
    activeQuestId = state.activeQuestId
  })
end

local function setUiOpen(open)
  state.uiOpen = open and true or false
  SetNuiFocus(state.uiOpen, state.uiOpen)
  SetNuiFocusKeepInput(state.uiOpen)
  sendUi()
end

local function saveProgress()
  TriggerServerEvent("az_quests:server:saveProgress", state.progress)
end

local function markPointComplete(qid)
  local q = questById(qid)
  if not q then return end

  local done = getCompletedCount(qid)
  if done >= #q.points then return end

  done = done + 1
  state.progress[qid] = done
  saveProgress()

  local pt = q.points[done]
  notify(("✅ Quest update: %s (%d/%d)"):format(q.title, done, #q.points))

  
  local nextPt = currentTarget(qid)
  if nextPt then
    makeBlipForPoint(nextPt)
    setWaypoint(nextPt)
  else
    clearBlip()
    notify(("🏁 Quest complete: %s"):format(q.title))
  end

  sendUi()
end

local function trackQuest(qid)
  local q = questById(qid)
  if not q then
    notify("Quest not found.")
    return
  end
  if isQuestCompleted(qid) then
    notify("This quest is already completed.")
    state.activeQuestId = qid
    clearBlip()
    sendUi()
    return
  end

  state.activeQuestId = qid
  local pt = currentTarget(qid)
  if pt then
    makeBlipForPoint(pt)
    setWaypoint(pt)
    notify(("📍 Tracking quest: %s"):format(q.title))
  end
  sendUi()
end

local function untrackQuest()
  state.activeQuestId = nil
  clearBlip()
  sendUi()
end




RegisterNUICallback("close", function(_, cb)
  setUiOpen(false)
  cb({ ok = true })
end)

RegisterNUICallback("trackQuest", function(data, cb)
  trackQuest(tostring(data.id or ""))
  cb({ ok = true })
end)

RegisterNUICallback("untrack", function(_, cb)
  untrackQuest()
  cb({ ok = true })
end)

RegisterNUICallback("resetQuest", function(data, cb)
  local qid = tostring(data.id or "")
  if qid == "" then
    cb({ ok = false })
    return
  end
  state.progress[qid] = 0
  saveProgress()
  if state.activeQuestId == qid then
    trackQuest(qid)
  end
  sendUi()
  cb({ ok = true })
end)




RegisterCommand(Config.Command or "quest", function()
  setUiOpen(not state.uiOpen)
end, false)





CreateThread(function()
  state.quests = Config.Quests or {}
  Wait(500)
  TriggerServerEvent("az_quests:server:requestProgress")
end)

RegisterNetEvent("az_quests:client:setProgress", function(progress)
  if type(progress) ~= "table" then progress = {} end
  state.progress = progress
  sendUi()
end)




CreateThread(function()
  while true do
    Wait(Config.TickMs or 250)

    local qid = state.activeQuestId
    if not qid then goto continue end

    local pt, idx, total = currentTarget(qid)
    if not pt then goto continue end

    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then goto continue end

    local pcoords = GetEntityCoords(ped)
    local radius = tonumber(pt.radius or Config.DefaultRadius or 3.0) or 3.0
    local dist = vecDist(pcoords, pt.coords)

    if Config.DrawTargetMarker then
      DrawMarker(
        1,
        pt.coords.x, pt.coords.y, pt.coords.z - 1.0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        radius * 1.25, radius * 1.25, 1.4,
        228, 89, 164, 120,  
        false, false, 2, false, nil, nil, false
      )
    end

    if dist <= radius then
      markPointComplete(qid)
      Wait(900) 
    end

    ::continue::
  end
end)
