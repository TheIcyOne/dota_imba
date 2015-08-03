--[[	Author: d2imba
		Date:	16.05.2015	]]

function RapierPickUp( keys )
	local caster = keys.caster
	local ability = keys.ability

	local rapier_level = 0
	if not caster.rapier_picked_up then
		rapier_level = keys.rapier_level
	end
	print("picked-up rapier_level: "..rapier_level)

	-- Double pick-up safety variable
	caster.rapier_picked_up = true
	Timers:CreateTimer(0.01, function()
		caster.rapier_picked_up = nil
	end)
	
	-- Calculate total rapier level carried by the owner
	for i = 0, 5 do
		local item = caster:GetItemInSlot(i)

		for j = 1, 10 do
			if item and item:GetAbilityName() == ( "item_imba_rapier_"..j ) then
				caster:RemoveItem(item)
				item = nil
				rapier_level = rapier_level + j
				print("found level "..j.." rapier")
			end
		end
	end

	-- Cap rapier level at 10
	rapier_level = math.min(rapier_level, 10)
	print("final rapier_level: "..rapier_level)

	-- Remove this item
	caster:RemoveItem(ability)

	-- Create appropriate level rapier
	caster:AddItem(CreateItem("item_imba_rapier_"..rapier_level, caster, caster))

end

function RapierDamage( keys )
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local damage = keys.damage

	-- Parameters
	local damage_amplify = ability:GetLevelSpecialValueFor("damage_amplify", ability:GetLevel() - 1) / 100

	-- Deal extra damage
	caster:RemoveModifierByName("modifier_item_imba_rapier_damage")
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage * damage_amplify, damage_type = DAMAGE_TYPE_PURE})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_imba_rapier_damage", {})
end

function AegisCheck( keys )
	local caster = keys.caster

	if not caster.has_aegis then
		caster.has_aegis = false
	end

	if HasAegis(caster) then
		caster.has_aegis = true
	else
		caster.has_aegis = false
	end
end

function RapierDrop( keys )
	local caster = keys.caster
	local ability = keys.ability
	local rapier_name = keys.rapier_name
	local caster_pos = caster:GetAbsOrigin()

	-- If the caster has aegis, do nothing
	if caster.has_aegis then
		return nil
	end

	-- Remove the rapiers from the player's inventory
	for i = 0, 5 do
		local item = caster:GetItemInSlot(i)

		for j = 1, 10 do
			if item and item:GetAbilityName() == ( "item_imba_rapier_"..j ) then
				caster:RemoveItem(item)
				item = nil
				local drop = CreateItem("item_imba_rapier_"..j.."_dummy", nil, nil)
				CreateItemOnPositionSync(caster:GetAbsOrigin(), drop)
				drop:LaunchLoot(false, 250, 0.5, caster:GetAbsOrigin())
			end
		end
	end
end