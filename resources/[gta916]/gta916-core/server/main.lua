local RESOURCE_NAME = GetCurrentResourceName()

CreateThread(function()
    print(("[%-12s] server initialized"):format(RESOURCE_NAME))
end)

RegisterCommand("gta916ping", function(source)
    local msg = ("[%s] pong"):format(RESOURCE_NAME)

    if source == 0 then
        print(msg)
        return
    end

    TriggerClientEvent("chat:addMessage", source, {
        color = { 0, 200, 120 },
        multiline = false,
        args = { "GTA916", msg }
    })
end, false)

-- Human-readable status page served on the game port:
--   http://<host>:30120/gta916-core/         (HTML dashboard)
--   http://<host>:30120/gta916-core/health   (JSON for scripts/monitoring)
-- The bare root of :30120 only redirects to the public cfx.re page, which is
-- useless for a private unlisted server - this page is the readable view.

local function buildStatusData()
    local players = GetPlayers()
    local names = {}
    for _, id in ipairs(players) do
        names[#names + 1] = GetPlayerName(id) or ("player " .. id)
    end
    return {
        server = GetConvar("sv_hostname", "unknown"),
        project = GetConvar("sv_projectName", "GTA916"),
        coreVersion = GetResourceMetadata(RESOURCE_NAME, "version", 0) or "?",
        uptimeMinutes = math.floor(GetGameTimer() / 60000),
        resourceCount = GetNumResources(),
        playerCount = #players,
        players = names,
    }
end

local function renderStatusHtml(data)
    local playerList = "<li class=\"muted\">No players online</li>"
    if #data.players > 0 then
        local items = {}
        for _, name in ipairs(data.players) do
            items[#items + 1] = ("<li>%s</li>"):format(name)
        end
        playerList = table.concat(items)
    end

    return ([[
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>GTA916 Server Status</title>
<style>
  body { background: #131318; color: #e8e8ee; font-family: system-ui, sans-serif;
         max-width: 640px; margin: 40px auto; padding: 0 20px; }
  h1 { color: #35d07f; font-size: 1.6rem; }
  .card { background: #1c1c24; border: 1px solid #2a2a35; border-radius: 10px;
          padding: 16px 20px; margin: 14px 0; }
  .label { color: #8b8b9a; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.08em; }
  .value { font-size: 1.2rem; margin-top: 2px; }
  .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
  ul { margin: 8px 0 0; padding-left: 20px; }
  .muted { color: #8b8b9a; list-style: none; margin-left: -20px; }
  footer { color: #55556a; font-size: 0.8rem; margin-top: 24px; }
</style>
</head>
<body>
<h1>GTA916 &mdash; Private Foundation</h1>
<div class="card"><div class="label">Server</div><div class="value">%s</div></div>
<div class="grid">
  <div class="card"><div class="label">Players online</div><div class="value">%d</div></div>
  <div class="card"><div class="label">Uptime</div><div class="value">%d min</div></div>
  <div class="card"><div class="label">Resources loaded</div><div class="value">%d</div></div>
  <div class="card"><div class="label">Core version</div><div class="value">%s</div></div>
</div>
<div class="card"><div class="label">Player list</div><ul>%s</ul></div>
<footer>Served by gta916-core &middot; JSON: /gta916-core/health</footer>
</body>
</html>
]]):format(data.server, data.playerCount, data.uptimeMinutes,
           data.resourceCount, data.coreVersion, playerList)
end

SetHttpHandler(function(req, res)
    local path = req.path or "/"
    if path == "/" or path == "" then
        res.writeHead(200, { ["Content-Type"] = "text/html; charset=utf-8" })
        res.send(renderStatusHtml(buildStatusData()))
    elseif path == "/health" then
        res.writeHead(200, { ["Content-Type"] = "application/json" })
        res.send(json.encode(buildStatusData()))
    else
        res.writeHead(404, { ["Content-Type"] = "text/plain" })
        res.send("not found - try /gta916-core/ or /gta916-core/health")
    end
end)
