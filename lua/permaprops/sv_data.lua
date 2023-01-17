// THIS UTIL IS VERY USEFUL ! 
// MORE EASY TO TRANSFER SQL DATA INTO ANOTHER SERVER

// EXAMPLE USAGE : 
// You have an gamemode with a very difficult to use this (example : Murder)
// You need an Sandbox server with the map you want to add props
// Now just use command in superadmin : "permaprops_export mapname"
// In data you have an folder : permaprops (and inside the mapname.txt)
// Copy this, and paste into server data folder (create permaprops if don't exist)
// Restart server
// And in murder gamemode just use command in superadmin : "permaprops_import filename erase" (erase = bool > 1 = remove previous sql data | 0 = add after [not recommanded])
// And is done !

// WARNING ! THIS CODE IS EXPERIMENTAL ! I USE THIS FOR MY SERVER ! DON'T USE THIS IF YOU DON'T KNOW HOW TO USE THIS !

concommand.Add("permaprops_export", function(ply,cmd,args)
    if ply:IsSuperAdmin() == false then
        ply:PrintMessage(HUD_PRINTCONSOLE,"You don't have permissions to use 'permaprops_export' command !")
        return
    end
    local mapname = args[1]
    if isstring(mapname) == false then
        ply:PrintMessage(HUD_PRINTCONSOLE,"'permaprops_export' need map arg !")
        return
    end
    local Data_PropsList = sql.Query( "SELECT * FROM permaprops WHERE map = " .. sql.SQLStr(mapname) .. ";" )

    if file.Exists("permaprops","DATA") == false then
        file.CreateDir("permaprops")
    end

    local fileName = "permaprops/" .. mapname .. os.time() .. ".txt"

    Data_PropsList = util.TableToJSON(Data_PropsList)
    Data_PropsList = util.Compress(Data_PropsList)

    file.Write(fileName, Data_PropsList)
    ply:PrintMessage(HUD_PRINTCONSOLE, mapname .. " PermaProps saved into " .. fileName .. " !" )
end)


concommand.Add("permaprops_import", function(ply,cmd,args)
    if ply:IsSuperAdmin() == false then
        ply:PrintMessage(HUD_PRINTCONSOLE,"You don't have permissions to use 'permaprops_export' command !")
        return
    end
    local filename = args[1]
    local erase = args[2]

    if isstring(filename) == false then
        ply:PrintMessage(HUD_PRINTCONSOLE,"'permaprops_export' need filename arg !")
        return
    end

    if erase == nil then
        ply:PrintMessage(HUD_PRINTCONSOLE,"'permaprops_export' need erase arg !")
        return
    end

    erase = tonumber(erase) == 1 and true or false

    fileName = "permaprops/" .. filename .. ".txt"

    if file.Exists(fileName,"DATA") == false then
        ply:PrintMessage(HUD_PRINTCONSOLE,fileName .. " Not exists ...")
        return
    end

    local data = file.Read(fileName,"DATA")

    data = util.Decompress(data)

    data = util.JSONToTable(data)

    for _,v in pairs(data) do
        if v.id and v.map and v.content then
            v.id = erase == true and v.id or 'NULL'
            PermaProps.SQL.Query("INSERT INTO permaprops (id, map, content) VALUES(" .. sql.SQLStr(v.id) .. ", ".. sql.SQLStr(v.map) ..", ".. sql.SQLStr(v.content) ..");")
        end
    end



end)