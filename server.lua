local RESOURCE = GetCurrentResourceName()

local function getPrimaryIdentifier(src)
  local ids = GetPlayerIdentifiers(src)
  if not ids then return nil end

  
  for _, v in ipairs(ids) do
    if v:sub(1, 8) == "license:" then return v end
  end
  
  for _, v in ipairs(ids) do
    if v:sub(1, 6) == "steam:" then return v end
  end
  for _, v in ipairs(ids) do
    if v:sub(1, 8) == "discord:" then return v end
  end
  return ids[1]
end

local function kvpKeyFor(src)
  local id = getPrimaryIdentifier(src)
  if not id then return nil end
  return ("az_quests:%s"):format(id)
end

RegisterNetEvent("az_quests:server:requestProgress", function()
  local src = source
  local key = kvpKeyFor(src)
  local progress = {}

  if key then
    local raw = GetResourceKvpString(key)
    if raw and raw ~= "" then
      local ok, decoded = pcall(json.decode, raw)
      if ok and type(decoded) == "table" then
        progress = decoded
      end
    end
  end

  TriggerClientEvent("az_quests:client:setProgress", src, progress)
end)

RegisterNetEvent("az_quests:server:saveProgress", function(progress)
  local src = source
  if type(progress) ~= "table" then return end
  local key = kvpKeyFor(src)
  if not key then return end

  
  local sanitized = {}
  for qid, v in pairs(progress) do
    if type(qid) == "string" then
      local n = tonumber(v or 0) or 0
      if n < 0 then n = 0 end
      if n > 999 then n = 999 end
      sanitized[qid] = n
    end
  end

  SetResourceKvp(key, json.encode(sanitized))
end)
