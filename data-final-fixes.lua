if mods["larger-machines"] then
	local size_api = require("__larger-machines__/api") --[[@as LargerMachines.API]]

	local gr_crafter = data.raw["assembling-machine"]["gr_crafter"]
	local fi_crafter = data.raw["assembling-machine"]["fi_crafter"]

	gr_crafter.next_upgrade = nil
	fi_crafter.next_upgrade = nil

	for _, machine in pairs(data.raw["assembling-machine"]) do
		if machine.next_upgrade == gr_crafter.name or machine.next_upgrade == fi_crafter.name then
			machine.next_upgrade = nil
		end
	end

	size_api.apply_to_machine({
		machine = "gr_crafter",
		old_size = 3,
		size = 6,
	})

	size_api.apply_to_machine({
		machine = "fi_crafter",
		old_size = 3,
		size = 4,
	})
end

if mods["space-age"] then
	local recipe_category_conversions = {
		["electronics"] = {
			"fi_modules_productivity_1",
			"fi_modules_productivity_2",
			"fi_modules_productivity_3",
			"fi_modules_productivity_4",
			"fi_modules_productivity_5",
			"fi_modules_productivity_6",
			"fi_modules_core",
			"gr_gold_wire",
		},
		["electronics-with-fluid"] = {
			"gr_circuit",
		},
		["crafting-with-fluid-or-metallurgy"] = {
			"el_ceramic",
			"fi_ceramic",
		},
	}

	for catName, recipes in pairs(recipe_category_conversions) do
		for _, recipeName in pairs(recipes) do
			data.raw["recipe"][recipeName].category = catName
		end
	end

	if mods["Krastorio2-spaced-out"] then
		data.raw["lab"]["fu_lab"].science_pack_drain_rate_percent = 75
		data.raw["lab"]["fu_lab"].inputs = data.raw["lab"]["kr-advanced-lab"].inputs

		if mods["space-is-fake"] then
			local sing_tech_recipe = data.raw["recipe"]["kr-singularity-tech-card"]
			table.insert(sing_tech_recipe.ingredients, { type = "item", name = "gr_magnet", amount = 1 })
			local sing_tech_recipe_cooled = data.raw["recipe"]["kr-singularity-tech-card-cooling"]
			table.insert(sing_tech_recipe_cooled.ingredients, { type = "item", name = "gr_magnet", amount = 1 })
		end
	end
end
