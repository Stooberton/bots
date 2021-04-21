MsgN("\n===========[ Loading Bots ]============\n|")

Bots = Bots or {
	Bots     = {},
	Teams    = {}
}

if SERVER then
	local Realms = {client = "client", server = "server", shared = "shared"}
	local ServerCount, SharedCount, ClientCount = 0, 0, 0

	local function Load(Path, Realm)
		local Files, Directories = file.Find(Path .. "/*", "LUA")

		if Realm then -- If a directory specifies which realm then load in that realm and persist through sub-directories
			for _, File in ipairs(Files) do
				File = Path .. "/" .. File

				if Realm == "client" then
					AddCSLuaFile(File)

					ClientCount = ClientCount + 1
				elseif Realm == "server" then
					include(File)

					ServerCount = ServerCount + 1
				else -- Shared
					include(File)
					AddCSLuaFile(File)

					SharedCount = SharedCount + 1
				end
			end
		else
			for _, File in ipairs(Files) do
				local Sub = string.sub(File, 1, 3)

				File = Path .. "/" .. File

				if Sub == "cl_" then
					AddCSLuaFile(File)

					ClientCount = ClientCount + 1
				elseif Sub == "sv_" then
					include(File)

					ServerCount = ServerCount + 1
				else -- Shared
					include(File)
					AddCSLuaFile(File)

					SharedCount = SharedCount + 1
				end
			end
		end

		for _, Directory in ipairs(Directories) do
			local Sub = string.sub(Directory, 1, 6)

			Realm = Realms[Sub] or Realm or nil

			Load(Path .. "/" .. Directory, Realm)
		end
	end

	Load("bots")

	if ServerCount > 0 then MsgN("| > Loaded " .. ServerCount .. " serverside file(s).") end
	if SharedCount > 0 then MsgN("| > Loaded " .. SharedCount .. " shared file(s).") end
	if ClientCount > 0 then MsgN("| > Loaded " .. ClientCount .. " clientside file(s).") end

elseif CLIENT then
	local FileCount, SkipCount = 0, 0

	local function Load(Path)
		local Files, Directories = file.Find(Path .. "/*", "LUA")

		for _, File in ipairs(Files) do
			local Sub = string.sub(File, 1, 3)

			if Sub == "sk_" then
				SkipCount = SkipCount + 1
			else
				File = Path .. "/" .. File

				include(File)

				FileCount = FileCount + 1
			end
		end

		for _, Directory in ipairs(Directories) do
			Load(Path .. "/" .. Directory)
		end
	end

	Load("bots")

	if FileCount > 0 then MsgN("| > Loaded " .. FileCount .. " clientside file(s).") end
	if SkipCount > 0 then MsgN("| > Skipped loading " .. SkipCount .. " clientside file(s).") end
	if FileCount + SkipCount == 0 then MsgN("| > No files loaded.") end
end

MsgN("|\n=======[ Finished Loading Bots ]=======\n")
