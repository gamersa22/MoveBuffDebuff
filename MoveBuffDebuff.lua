MoveBuffDebuff = {}

MoveBuffDebuff.name = "MoveBuffDebuff"
MoveBuffDebuff.version = 1
MoveBuffDebuff.defaultCharacter = 
{	
	["offsetY"] = 325,
	["offsetX"] = 0,
	["alignment"]={
		["name"] = "Center",
		["data"] = CENTER,
	},
	["useCharacterSettings"] = false,
}
MoveBuffDebuff.default = {
	["accountWideProfile"] = MoveBuffDebuff.defaultCharacter,
}

function MoveBuffDebuff.GetSettings()--
	if MoveBuffDebuff.charSavedVars.useCharacterSettings then
		return MoveBuffDebuff.charSavedVars
	else
		return MoveBuffDebuff.savedvars.accountWideProfile
	end
end

--local offsetX
function MoveBuffDebuff.ApplyAnchor()
	ZO_BuffDebuffTopLevelSelfContainer:ClearAnchors()	
	ZO_BuffDebuffTopLevelSelfContainer:SetAnchor(MoveBuffDebuff.GetSettings().alignment.data, GuiRoot, 0, MoveBuffDebuff.GetSettings().offsetX, MoveBuffDebuff.GetSettings().offsetY)	
end	

local BuffDebuffBarInMenu = false

function MoveBuffDebuff.Initialize()
	--Load up, those Saved Vars
	local serverName = GetWorldName()
	MoveBuffDebuff.savedvars = ZO_SavedVars:NewAccountWide("MoveBuffDebuffSavedVariables", MoveBuffDebuff.version, serverName, MoveBuffDebuff.default)
	MoveBuffDebuff.charSavedVars = ZO_SavedVars:NewCharacterIdSettings("MoveBuffDebuffSavedVariables",MoveBuffDebuff.version, serverName, MoveBuffDebuff.savedvars.accountWideProfile) 	
	MoveBuffDebuff.ApplyAnchor() --move to saved position
	ZO_BuffDebuffTopLevelSelfContainer:SetHandler("OnShow",function() MoveBuffDebuff.ApplyAnchor() end)
    local LHAS = LibHarvensAddonSettings
    
    local options = {
        allowDefaults = true,
		allowRefresh = false,
		defaultsFunction = function()      
		d("MoveBuffDebuff Reset")
        end,
    }
    
    local settings = LHAS:AddAddon("Move Buff Debuff", options)
    if not settings then
        return
    end
	--On/Off for Character Settings
    local checkbox = {
        type = LHAS.ST_CHECKBOX,
        label = "Use character settings", 
		--default = false, 
        setFunction = function(value)
           MoveBuffDebuff.charSavedVars.useCharacterSettings = value
        end,
        getFunction = function()
            return MoveBuffDebuff.charSavedVars.useCharacterSettings
        end,
    }
    settings:AddSetting(checkbox)
	local scene
	local function addBuffDebuffBar()
		if BuffDebuffBarInMenu then
			return
		end
		scene = SCENE_MANAGER:GetCurrentScene()					
		scene:AddFragment(BUFF_DEBUFF_FRAGMENT)
		BUFF_DEBUFF_FRAGMENT:Refresh()
		ZO_BuffDebuffTopLevelSelfContainer:SetHidden(false)	
		BuffDebuffBarInMenu = true	
	end
	
	local function addonSelected(_, addonSettings)
		local addBuffDebuffBar = addonSettings == settings
		if not addBuffDebuffBar and BuffDebuffBarInMenu then	
			scene:RemoveFragment(BUFF_DEBUFF_FRAGMENT)
			BUFF_DEBUFF_FRAGMENT:Refresh()
			BuffDebuffBarInMenu = false
		end
	end
		
	CALLBACK_MANAGER:RegisterCallback("LibHarvensAddonSettings_AddonSelected", addonSelected)

	local button = {
        type = LHAS.ST_BUTTON,
        label = "Show Buff Debuff Bar NOW",		
        buttonText = "Show",
        clickHandler = function(control, button)
			if not BuffDebuffBarInMenu then
				addBuffDebuffBar()
			else
				addonSelected()
			end
        end,
    }
	settings:AddSetting(button)
	 local selectedText = "Center"
	 local Alainment={
			type = LHAS.ST_DROPDOWN,
			label = "Align Bar",
			items = {{
				name = "Center",
				data = CENTER
			},{
				name = "Right",
				data = RIGHT
			},{
                name = "Left",
                data = LEFT
            },},
			default = "Center",
			getFunction = function()
				return MoveBuffDebuff.GetSettings().alignment.name
			end,
			setFunction = function(combobox, name, item)
				MoveBuffDebuff.GetSettings().alignment = item
				MoveBuffDebuff.ApplyAnchor()
			end
		}
	settings:AddSetting(Alainment)
	
	--Slider to Adjust BuffDebuff Bar's Y Position
    local slider = {
        type = LHAS.ST_SLIDER,
        label = "Up <- -> Down",
		tooltip = "Default: 325",
        setFunction = function(value)
            MoveBuffDebuff.GetSettings().offsetY = value
			MoveBuffDebuff.ApplyAnchor()
        end,
        getFunction = function()
            return MoveBuffDebuff.GetSettings().offsetY
        end,
        default = 325,
        min = -1000,
        max = 1000,
        step = 5
    }
    settings:AddSetting(slider)
	--X value
	 local slider = {
        type = LHAS.ST_SLIDER,
        label = "Left <- -> Right",
		tooltip = "Default is 0",
        setFunction = function(value)
            MoveBuffDebuff.GetSettings().offsetX = value
			MoveBuffDebuff.ApplyAnchor()
        end,
        getFunction = function()
            return MoveBuffDebuff.GetSettings().offsetX
        end,
        default = 0,
        min = -1550,
        max = 1550,
        step = 5
    }
    settings:AddSetting(slider)
end
function MoveBuffDebuff.OnAddOnLoaded(event, addonName)
	if addonName == MoveBuffDebuff.name then
		MoveBuffDebuff.Initialize()		
		EVENT_MANAGER:UnregisterForEvent(MoveBuffDebuff.name, EVENT_ADD_ON_LOADED)
	end
end
 
EVENT_MANAGER:RegisterForEvent(MoveBuffDebuff.name, EVENT_ADD_ON_LOADED, MoveBuffDebuff.OnAddOnLoaded)

--HUGE thanks to Dolgubon for helping me working out on how to do this