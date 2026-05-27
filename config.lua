Config = Config or {}




Config.Theme = {
  bg        = "#0b0d12",
  panel     = "rgba(16,17,24,.86)",
  panel2    = "rgba(20,22,33,.92)",
  stroke    = "rgba(255,255,255,.08)",
  text      = "rgba(255,255,255,.92)",
  muted     = "rgba(255,255,255,.62)",

  
  accent    = "#e459a4", 
  accent2   = "#5ec9f0", 
}


Config.Discord = {
  enabled = true,
  label   = "DISCORD",
  invite  = "https://discord.gg/UCNE5H58Pt"
}


Config.Command = "quests"


Config.DefaultKeybind = ""


Config.UseBlips = true


Config.UseWaypoint = true


Config.DrawTargetMarker = true


Config.DefaultRadius = 3.0


Config.TickMs = 250






Config.Quests = Config.Quests or {
  
  
  {
    id = "dmv_license",
    title = "Get Your License",
    description = "Go to the DMV to get your driver's license.",
    points = {
      
      { label = "DMV (City Hall)", coords = vector3(237.37, -1383.17, 33.26), radius = 4.0 },
    }
  },
  {
    id = "first_steps",
    title = "First Steps",
    description = "Go visit the marked spots around the city to get familiar.",
    points = {
      { label = "Legion Square",    coords = vector3(215.76, -919.24, 30.69), radius = 3.5 },
      { label = "Alta St. Corner",  coords = vector3(254.18, -1017.05, 29.26), radius = 3.0 },
      { label = "Vinewood Blvd",    coords = vector3(318.39, 180.57, 103.59),  radius = 3.5 },
    }
  },

  {
    id = "beach_run",
    title = "Beach Run",
    description = "Head to the beach and check in at the pier.",
    points = {
      { label = "Vespucci Beach",   coords = vector3(-1235.76, -1445.26, 4.35), radius = 4.0 },
      { label = "Del Perro Pier",   coords = vector3(-1820.62, -1210.87, 13.02), radius = 4.0 },
    }
  },

  {
    id = "mountain_view",
    title = "Mountain View",
    description = "Drive up for a nice view. Don’t fall off.",
    points = {
      { label = "Vinewood Sign",    coords = vector3(716.14, 1197.38, 326.61), radius = 5.0 },
    }
  },

  
  {
    id = "car_shopping",
    title = "Car Shopping",
    description = "Visit the main dealership and then stop by Simeon's to browse vehicles.",
    points = {
      
      { label = "LS Dealership (LS Car Meet)", coords = vector3(781.92, -1867.02, 29.29), radius = 6.0 },
      
      { label = "Simeon's Dealership",         coords = vector3(-56.49, -1096.58, 26.42), radius = 4.0 },
    }
  },

}
