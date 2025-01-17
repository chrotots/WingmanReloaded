﻿; Crafting Section - main routine and all subroutines and popup
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Crafting(selection:="Maps"){
	; Thread, NoTimers, True
	MouseGetPos xx, yy
	CheckRunning()
	If GameActive
	{
		CheckRunning("On")
		GuiStatus()
		If (!OnChar) 
		{
			Notify("You do not appear to be in game.","Likely need to calibrate Character Active",1)
			CheckRunning("Off")
			Return
		}
		; Begin Crafting Script
		Else
		{
			If (!OnStash && YesEnableAutomation)
			{
				; If don't find stash, return
				If !SearchStash()
				{
					CheckRunning("Off")
					Return
				}
				Else
					RandomSleep(90,90)
			}
			; Open Inventory if is closed
			If (!OnInventory && OnStash)
			{
				SendHotkey(hotkeyInventory)
				RandomSleep(45,45)
				GuiStatus()
				RandomSleep(45,45)
			}
			If (OnInventory && OnStash)
			{
				RandomSleep(45,45)
				CurrentTab := 0
				MoveStash(StashTabCurrency)
				If indexOf(selection,["Maps","Socket","Color","Link","Chance"])
					Crafting%selection%()
				Else
					Notify("Unknown Result is:",selection,2)
			}
			Else
			{
				; Exit Routine
				CheckRunning("Off")
				Return
			}
		}
	}
	MouseMove %xx%, %yy%
	CheckRunning("Off")
	Return
}
; CraftingChance - Use the settings to apply chance to item(s) until unique
CraftingChance(){
	Global
	local f
	; Notify("Chance Logic Coming Soon","",2)
	f := New Craft("Chance",BasicCraftChanceMethod,{Scour:BasicCraftChanceScour})
}
; CraftingColor - Use the settings to apply Chromatic Orb to item(s) until proper colors
CraftingColor(){
	Global
	local f
	f := New Craft("Color",BasicCraftColorMethod,{R:BasicCraftR,G:BasicCraftG,B:BasicCraftB})
}
; CraftingLink - Use the settings to apply Fusing to item(s) until minimum links
CraftingLink(){
	Global
	local f
	f := New Craft("Link",BasicCraftLinkMethod,{Links:BasicCraftDesiredLinks,Auto:BasicCraftLinkAuto})
}
; CraftingSocket - Use the settings to apply Jewelers to item(s) until minimum sockets
CraftingSocket(){
	Global
	local f
	f := New Craft("Socket",BasicCraftSocketMethod,{Sockets:BasicCraftDesiredSockets,Auto:BasicCraftSocketAuto})
}
; CraftingMaps - Scan the Inventory for Maps and apply currency based on method select in Crafting Settings
CraftingMaps(){
	Global RunningToggle
	; Move mouse away for Screenshot
	ShooMouse(), GuiStatus(), ClearNotifications()
	; Ignore Slot
	BlackList := Array_DeepClone(IgnoredSlot)
	WR.data.Counts := CountCurrency(["Alchemy","Binding","Transmutation","Scouring","Vaal","Chisel"])
	; MsgBoxVals(WR.data.Counts)
	; Start Scan on Inventory
	For C, GridX in InventoryGridX
	{
		If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
			Break
		For R, GridY in InventoryGridY
		{
			If not RunningToggle  ; The user signaled the loop to stop by pressing Hotkey again.
				Break
			If BlackList[C][R]
				Continue
			Grid := RandClick(GridX, GridY)
			If (((Grid.X<(WisdomScrollX+24)&&(Grid.X>WisdomScrollX-24))&&(Grid.Y<(WisdomScrollY+24)&&(Grid.Y>WisdomScrollY-24)))||((Grid.X<(PortalScrollX+24)&&(Grid.X>PortalScrollX-24))&&(Grid.Y<(PortalScrollY+24)&&(Grid.Y>PortalScrollY-24))))
			{   
				Ding(500,11,"Hit Scroll")
				Continue ;Dont want it touching our scrolls, location must be set to very center of 52 pixel square
			} 
			PointColor := FindText.GetColor(GridX,GridY)
			If indexOf(PointColor, varEmptyInvSlotColor) 
			{
				;Seems to be an empty slot, no need to clip item info
				Continue
			}
			; Identify Items routines
			ClipItem(Grid.X,Grid.Y)
			addToBlacklist(C, R)
			If (Item.Affix["Unidentified"]&&YesIdentify)
			{
				If ( Item.Prop.IsMap
				&& (!YesMapUnid || ( Item.Prop.RarityMagic && ( getMapCraftingMethod() ~= "Alchemy" )))
				&&!Item.Prop.Corrupted)
				{
					WisdomScroll(Grid.X,Grid.Y)
					ClipItem(Grid.X,Grid.Y)
				}
				Else If CheckToIdentify()
				{
					WisdomScroll(Grid.X,Grid.Y)
					ClipItem(Grid.X,Grid.Y)
				}
			}
			;Crafting Map Script
			If (Item.Prop.IsMap && !Item.Prop.IsBlightedMap && !Item.Prop.Corrupted && !Item.Prop.RarityUnique) 
			{
				;Check all 3 ranges tier with same logic
				i = 0
				Loop, 3
				{
					i++
					If (EndMapTier%i% >= StartMapTier%i% && CraftingMapMethod%i% != "Disable" && Item.Prop.Map_Tier >= StartMapTier%i% && Item.Prop.Map_Tier <= EndMapTier%i%)
					{
						If (!Item.Prop.RarityNormal)
						{
							If ( (Item.Prop.RarityMagic && CraftingMapMethod%i% == "Transmutation+Augmentation") 
							|| (Item.Prop.RarityRare && (CraftingMapMethod%i% == "Transmutation+Augmentation" || CraftingMapMethod%i% ~= "(^Alchemy$|^Binding$|^Hybrid$)")) 
							|| (Item.Prop.RarityRare && Item.Prop.Quality >= 16 && CraftingMapMethod%i% ~= "(Alchemy|Binding|Hybrid)") )
							{
								MapRoll(CraftingMapMethod%i%, Grid.X,Grid.Y)
								Continue
							}
							Else
							{
								If !ApplyCurrency("Scouring",Grid.X,Grid.Y)
									Return False
							}
						}
						If (Item.Prop.RarityNormal)
						{
							If (Item.Prop.Map_Quality <= 20)
							{
								numberChisel := (20 - Item.Prop.Map_Quality)//5
							}  
							Else
							{
								numberChisel := 0
							}
							If (CraftingMapMethod%i% == "Transmutation+Augmentation")
							{
								MapRoll(CraftingMapMethod%i%, Grid.X,Grid.Y)
								Continue
							}
							Else if (CraftingMapMethod%i% ~= "(^Alchemy$|^Binding$|^Hybrid$)")
							{
								MapRoll(CraftingMapMethod%i%, Grid.X,Grid.Y)
								Continue
							}
							Else if (CraftingMapMethod%i% ~= "^Chisel\+(Alchemy$|Binding$|Hybrid$)")
							{
								Loop, %numberChisel%
								{
									If !ApplyCurrency("Chisel",Grid.X,Grid.Y)
										Return False
								}
								MapRoll(CraftingMapMethod%i%, Grid.X,Grid.Y)
								Continue
							}
							Else if (CraftingMapMethod%i% ~= "Chisel\+(Alchemy|Binding|Hybrid)\+Vaal")
							{
								Loop, %numberChisel%
								{
									If !ApplyCurrency("Chisel",Grid.X,Grid.Y)
										Return False
								}
								MapRoll(CraftingMapMethod%i%,Grid.X,Grid.Y)
								ApplyCurrency("Vaal",Grid.X,Grid.Y)
								Continue
							}
						}
					}
				}
			} Else If (indexOf(Item.Prop.ItemClass,["Blueprint","Contract"]) && Item.Prop.RarityNormal && HeistAlcNGo) {
				ApplyCurrency("Alchemy",Grid.X,Grid.Y)
			}
		}
	}
	Return
}
getMapCraftingMethod(){
	Loop, 3
	{
		If ( EndMapTier%A_Index% >= StartMapTier%A_Index% 
		&& CraftingMapMethod%A_Index% != "Disable" 
		&& Item.Prop.Map_Tier >= StartMapTier%A_Index% 
		&& Item.Prop.Map_Tier <= EndMapTier%A_Index% )
			Return CraftingMapMethod%A_Index%
	}
	Return False
}
; Find the stack sizes of all relevant currency, returns count object
CountCurrency(NameList:=""){
	retCount := {}
	If (NameList = "")
		Return False
	If !IsObject(NameList)
		NameList := StrSplit(NameList,",")
	For key, currency in NameList {
		If !WR.loc.pixel.HasKey(currency) 
			Return False
		If (WR.loc.pixel[currency].X = 0 && WR.loc.pixel[currency].Y = 0) {
			Notify("Position Error","Aspect ratio is missing adjustment for " currency " slot`nPlease submit the correct position on github for your aspect ratio",5)
			retCount[currency] := 0
		} Else {
			ClipItem(WR.loc.pixel[currency].X,WR.loc.pixel[currency].Y)
			retCount[currency] := Item.Prop.Stack_Size ? Item.Prop.Stack_Size : 0
		}
	}
	Return retCount.Count() ? retCount : False
}
; ApplyCurrency - Using cname = currency name string and x, y as apply position
ApplyCurrency(cname, x, y){
	If WR.data.Counts.HasKey(cname) {
		If (WR.data.Counts[cname] <= 0) {
			Notify("Error","Not enough " cname " to continue crafting",5)
			Return False
		}
		WR.data.Counts[cname]--
	}
	RightClick(WR.loc.pixel[cname].X, WR.loc.pixel[cname].Y)
	Sleep, 45*Latency
	LeftClick(x,y)
	Sleep, 90*Latency
	ClipItem(x,y)
	Sleep, 45*Latency
	return True
}
; MapRoll - Apply currency/reroll on maps based on select undesireable mods
MapRoll(Method, x, y){
	MMQIgnore := False
	If (Method == "Transmutation+Augmentation")
	{
		cname := "Transmutation"
		crname := "Alteration"
		If (!EnableMQQForMagicMap)
		{
			MMQIgnore := True
		}
	}
	Else If (Method ~= "Alchemy")
	{
		cname := "Alchemy"
		crname := "Scouring"
	}
	Else If (Method ~= "Binding")
	{
		cname := "Binding"
		crname := "Scouring"
	}
	Else If (Method ~= "Hybrid")
	{
		If (WR.data.Counts.Binding >= WR.data.Counts.Alchemy)
			cname := "Binding"
		Else
			cname := "Alchemy"
		crname := "Scouring"
	}
	Else
	{
		return
	}
	If (Item.Affix["Unidentified"])
	{
		If (Item.Prop.Rarity_Digit > 1 && cname = "Transmutation" && YesMapUnid )
		{
			Return
		}
		Else If (Item.Prop.Rarity_Digit > 2 && cname = "Alchemy" && YesMapUnid )
		{
			Return
		}
		Else If (Item.Prop.Rarity_Digit > 2 && cname = "Binding" && YesMapUnid )
		{
			Return
		}
		Else
		{
			WisdomScroll(x,y)
			ClipItem(x,y)
			Sleep, 45*Latency
		}
	}
	; Apply Currency if Normal
	If (Item.Prop.RarityNormal)
	{
		If !ApplyCurrency(cname, x, y)
			Return False
	}
	If (Item.Prop.AffixCount < 2 && Item.Prop.RarityMagic && cname = "Transmutation")
	{
		If !ApplyCurrency("Augmentation",x,y)
			Return False
	}
	antr := Item.Prop.Map_Rarity
	antp := Item.Prop.Map_PackSize
	antq := Item.Prop.Map_Quantity
	;MFAProjectiles,MDExtraPhysicalDamage,MICSC,MSCAT
	While ( Item.Prop.IsBrickedMap
	|| (Item.Prop.RarityNormal) 
	|| (!MMQIgnore && (Item.Prop.Map_Rarity < MMapItemRarity 
	|| Item.Prop.Map_PackSize < MMapMonsterPackSize 
	|| Item.Prop.Map_Quantity < MMapItemQuantity)) )
	&& !Item.Affix["Unidentified"]
	{
		Notify("Inside roll while","These maps should not see this",1)
		If (!RunningToggle)
		{
			break
		}
		; Scouring or Alteration
		If !ApplyCurrency(crname, x, y)
			Return False
		If (Item.Prop.RarityNormal)
		{
			If !ApplyCurrency(cname, x, y)
				Return False
		}
		; Augmentation if not 2 mods on magic maps
		Else If (Item.Prop.AffixCount < 2 && Item.Prop.RarityMagic)
		{
			If !ApplyCurrency("Augmentation",x,y)
				Return False
		}
		; take fresh values to analyze in the following loop
		antr := Item.Prop.Map_Rarity
		antp := Item.Prop.Map_PackSize
		antq := Item.Prop.Map_Quantity
		If (DebugMessages)
			Notify("MapCrafting: " Item.Prop.ItemBase "","Before Rolling`nItem Rarity: " antr "`nMonsterPackSize: " antp "`nItem Quantity: " antq "`nAfter Rolling`nItem Rarity: " Item.Prop.Map_Rarity "`nMonsterPackSize: " Item.Prop.Map_PackSize "`nItem Quantity: " Item.Prop.Map_Quantity "`nEnd",4)
	}
	return 1
}
