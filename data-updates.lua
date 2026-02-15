local api = require("__juh-tweaks__/api")

if mods["um-standalone-foundry"] or mods["space-age"] then
	local replacements = {
		["el_arc_pure_iron"] = { name = "molten-iron", amountMult = 0.1 },
		["el_arc_pure_copper"] = { name = "molten-copper", amountMult = 0.1 },
		["el_arc_pure_aluminum"] = { amountMult = 0.1 },
		["fi_arc_glass"] = { amountMult = 0.1 },
		["fi_arc_gold"] = { amountMult = 0.1 },
		["fi_arc_neodym"] = { amountMult = 0.1 },
		["fi_arc_titan"] = { amountMult = 0.1 },
		["fu_arc_pure_lead"] = { amountMult = 0.1 },
	}
	for _, recipeData in pairs(data.raw["recipe"]) do
		api.patchRecipe(recipeData, replacements)
	end

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

	local assemblerCategories = data.raw["assembling-machine"]["assembling-machine-3"].crafting_categories

	for _, machineId in pairs({ "fi_crafter_entity", "gr_crafter_entity", "fi_crafter", "gr_crafter" }) do
		local machine = data.raw["assembling-machine"][machineId]
		if machine ~= nil then
			machine.crafting_categories = api.merge_categories(assemblerCategories, machine.crafting_categories, {
				["crafting-with-fluid"] = false,
				["crafting-with-fluid-or-metallurgy"] = false,
				["electronics-with-fluid"] = false,
			})
		end
	end

	local foundryCats = data.raw["assembling-machine"]["foundry"].crafting_categories
	table.insert(foundryCats, "el_caster_category")
	table.insert(foundryCats, "el_arc_furnace_category")

	data.raw["recipe"]["casting-iron"].hidden = true
	data.raw["recipe"]["casting-steel"].hidden = true
	data.raw["recipe"]["casting-copper"].hidden = true

	data.raw["recipe"]["el_arc_pure_iron"].subgroup = "el_item_subgroup_e"
	data.raw["recipe"]["el_arc_pure_copper"].subgroup = "el_item_subgroup_e"

	local ingot_factory = data.raw["assembling-machine"]["fu_ingot"]
	api.modify_effects_receiver_base(ingot_factory, function(base)
		base.productivity = 0.5
	end)
	ingot_factory.crafting_speed = ingot_factory.crafting_speed / 1.5

	-- EM plant recipe and tech
	table.insert(data.raw["technology"]["electromagnetic-plant"].prerequisites, "fu_magnet_tech")
	data.raw["recipe"]["electromagnetic-plant"].ingredients = {
		{ type = "item", name = "fi_energy_crystal", amount = 30 },
		{ type = "item", name = "fu_magnet", amount = 10 },
		{ type = "item", name = "processing-unit", amount = 50 },
		{ type = "item", name = "holmium-plate", amount = 150 },
		{ type = "item", name = "refined-concrete", amount = 50 },
	}

	-- Foundry recipe and tech
	data.raw["recipe"]["foundry"].ingredients = {
		{ type = "item", name = "fu_ingot", amount = 1 },
		{ type = "item", name = "tungsten-carbide", amount = 50 },
		{ type = "item", name = "refined-concrete", amount = 20 },
		{ type = "fluid", name = "lubricant", amount = 20 },
	}
	table.insert(data.raw["technology"]["foundry"].prerequisites, "fu_ingot_tech")

	-- BMD recipe
	data.raw["recipe"]["big-mining-drill"].ingredients = {
		{ type = "item", name = "tungsten-carbide", amount = 20 },
		{ type = "item", name = "fu_TIM", amount = 20 },
		{ type = "item", name = "processing-unit", amount = 10 },
		{ type = "item", name = "kr-electric-mining-drill-mk2", amount = 1 },
		{ type = "fluid", name = "fi_arc_titan", amount = 100 },
	}

	-- Make cryo plant depend on EM plant
	table.insert(data.raw["technology"]["cryogenic-plant"].prerequisites, "electromagnetic-plant")

	-- Circuits dependency on quantum processor
	data.raw["recipe"]["gr_circuit"].ingredients = {
		{ type = "item", name = "gr_pcb", amount = 1 },
		{ type = "item", name = "gr_gold_wire", amount = 10 },
		{ type = "item", name = "quantum-processor", amount = 1 },
		{ type = "fluid", name = "fi_strong_acid", amount = 50 },
	}
	table.insert(data.raw["technology"]["gr_circuit_tech"].prerequisites, "quantum-processor")

	if mods["Krastorio2-spaced-out"] then
		local cast_steel = data.raw["recipe"]["el_cast_pure_steel"]
		cast_steel.ingredients = {
			{ type = "fluid", name = "molten-iron", amount = 100 },
			{ type = "item", name = "kr-coke", amount = 2 },
		}
		cast_steel.results = { { type = "item", name = "steel-plate", amount = 5 } }

		local purify_copper = table.deepcopy(data.raw["recipe"]["el_purify_copper"])
		purify_copper.name = "el_purify_enriched_copper"
		purify_copper.localised_name = { "item-name.kr-enriched-copper" }
		api.patchRecipe(purify_copper, { ["copper-ore"] = { name = "kr-enriched-copper" } })
		purify_copper.icons = api.build_icons_subscripts({
			base = "__248k-Redux-graphics__/ressources/fluids/el_dirty_water.png",
			top_left = "__Krastorio2Assets__/icons/items/enriched-copper.png",
		})

		---@type data.RecipePrototype
		local purify_iron = table.deepcopy(data.raw["recipe"]["el_purify_iron"])
		purify_iron.name = "el_purify_enriched_iron"
		purify_iron.localised_name = { "item-name.kr-enriched-iron" }
		api.patchRecipe(purify_iron, { ["iron-ore"] = { name = "kr-enriched-iron" } })
		purify_iron.icons = api.build_icons_subscripts({
			base = "__248k-Redux-graphics__/ressources/fluids/el_dirty_water.png",
			top_left = "__Krastorio2Assets__/icons/items/enriched-iron.png",
		})

		data.raw["recipe"]["casting-steel"].hidden = false
		data.raw["recipe"]["el_cast_pure_steel"].icons = api.build_icons_subscripts({
			base = "__Krastorio2Assets__/icons/items/steel-plate.png",
			top_left = "__Krastorio2Assets__/icons/items/coke.png",
		})

		local enrich_tech = data.raw["technology"]["kr-enriched-ores"]
		table.insert(enrich_tech.effects, { type = "unlock-recipe", recipe = purify_copper.name })
		table.insert(enrich_tech.effects, { type = "unlock-recipe", recipe = purify_iron.name })

		table.insert(data.raw["technology"]["fi_purifier_2_tech"].prerequisites, "kr-enriched-ores")

		data:extend({ purify_copper, purify_iron })

		api.patchRecipes({
			"el_purify_iron",
			"el_purify_copper",
		}, {
			["copper-ore"] = { amountMult = 2 },
			["iron-ore"] = { amountMult = 2 },
		})
		api.patchRecipes({
			"fi_purify_iron",
			"fi_purify_copper",
		}, {
			["copper-ore"] = { name = "kr-enriched-copper" },
			["iron-ore"] = { name = "kr-enriched-iron" },
		})

		local adv_furnace = data.raw["assembling-machine"]["kr-advanced-furnace"]
		adv_furnace.crafting_categories = api.merge_categories(adv_furnace.crafting_categories, foundryCats)
	end
end
