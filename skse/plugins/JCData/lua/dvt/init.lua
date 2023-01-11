--- dvt: a Lua data manager for Devourment
--[[--
@author Mark Fairchild
@copyright 2020-02-25
@license
Copyright 2020 Mark Fairchild

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--]]--


local dvt = {}
local logging = jrequire 'logging'
local jc = jrequire 'jc'


dvt.required = {"predators", "blocks", "playerRef", "fakePlayer"}


--[[--
Modifies health and timers for a pred, and stores the changes in preyData.
--]]--
function dvt.Tick(predData, dt, rapid1, rapid2)
	local DB = dvt.getDB()
	
	if predData.fake then
		local increment = dt * rapid2 / predData.fake.timerMax
		predData.fake.size = predData.fake.size * (1.0 - increment)
		if predData.fake.timer <= 0.0 or predData.fake.size <= 0.01 then
			predData.fake = nil
		end
	end
	
	for prey,preyData in pairs(predData.stomach or {}) do
		if not DB.blocks[prey] and not preyData.vomit then
			if preyData.alive then
				if preyData.timerMax > 0.0 then
					preyData.timer = math.max(0.0, preyData.timer - dt)
				end

				if preyData.vore then
					preyData.fluxdamage = dt * preyData.dps * rapid1
					if preyData.prey ~= DB.playerRef then
						preyData.fluxtimes = dvt.poisson(dt * 0.333)
					end
				end
			elseif preyData.reforming then
				if preyData.timer + dt >= preyData.timerMax then
					preyData.fluxtimes = math.max(0.0, preyData.timerMax - preyData.timer)
					preyData.timer = preyData.timerMax
				else
					preyData.fluxtimes = dt
					preyData.timer = preyData.timer + dt
				end
			elseif preyData.digesting then
				if dt * rapid2 >= preyData.timer then
					preyData.fluxtimes = preyData.timer
					preyData.timer = 0.0
				else
					preyData.fluxtimes = dt
					preyData.timer = math.max(0.0, preyData.timer - dt * rapid2)
				end
			end
		end
	end
	
	return dvt.PredatorTimeout(predData)
end


--[[--
Performs a brief verification check on the devourment data structure.
It throws an exception
@param DB The JMap structure containing the devourment data.
--]]--
function dvt.verifyDB(DB)
	assert(DB, "DB is missing.")
	for _,req in pairs(dvt.required) do
		assert(DB[req], "DB."..req.." is missing.")
	end
end


--[[--
Retrieves the entire devourment data structure.
@return A JMap object containing the devourment data.
--]]--

function dvt.getDB()
	--dvt.verifyDB(JDB.dvt)
	return JDB.dvt
end


--[[--
Retrieves the predators table.
@return A JFormMap mapping papyrus Actors to JMaps.
--]]--
function dvt.getPredators()
	return dvt.getDB().predators
end


--[[--
Retrieves the predators table.
@return A JFormMap mapping papyrus Actors to JMaps.
--]]--
function dvt.getBlocks()
	return dvt.getDB().blocks
end


--[[--
Retrieves the PredData table for the specified Actor.
Returns an empty Lua table if there is no such entry in the Predators table.

@param pred The target for which to find the matching predData.
@return A predData.
--]]--
function dvt.GetPredData(pred)
	assert(pred, "pred must be specified.")
	return dvt.getPredators()[pred]
end


--[[--
Retrieves the stomach table for the specified Actor.
Returns an empty Lua table if there is no such entry in the Predators table.

@return A JFormMap mapping papyrus Actors to JFormMaps.
--]]--
function dvt.GetStomach(pred)
	assert(pred, "pred must be specified.")
	local predData = dvt.GetPredData(pred)
	if not dvt.isPred(pred) then
		return {}
	else
		return dvt.GetPredData(pred).stomach or {}
	end
end


--[[--
@return A flag indicating if prey is in the stomach of pred.
--]]--
function dvt.has(pred, prey)
	assert(pred, "pred must be specified.")
	assert(prey, "prey must be specified.")

	local stomach = dvt.GetStomach(pred)
	if stomach[prey] ~= nil then
		assert(stomach[prey].pred == pred, "Predator mismatch!")
		return true
	end
end


--[[--
--]]--
function dvt.isPrey(prey)
	assert(prey, "prey must be specified.")
	return dvt.GetPreyData(prey) ~= nil
end


--[[--
--]]--
function dvt.isPred(pred)
	assert(pred, "pred must be specified.")
	return dvt.getPredators()[pred]
end


--[[--
--]]--
function dvt.isExcretable(preyData)
	assert(preyData, "preyData must be specified.")
	assert(preyData.prey or preyData.bolus, "Either prey or bolus MUST be set!")
	
	if preyData.alive then
		return true
	elseif preyData.digested then
		return true
	elseif preyData.bolus then
		return true
	else
		return false
	end
end


function dvt.BumpSliders(data, playerStruggle)
	assert(data, "data must not be nil.")
	assert(data.target, "data.target must not be nil.")
	local DB = dvt.getDB()
	
	-- DO BODY SCALING --
	local smoothness = data.MorphSpeed or 0.007
	local threshold = 0.001

	-- Overall scale, for when locuses are not in use.
	data.targetScale = dvt.GetBurden(data.target) * (data.CreatureScaling or 1.0)

	local diff = data.targetScale - data.currentScale
	if diff * diff < threshold then
		data.output_scale = -1.0
	else
		data.currentScale = (1.0 - smoothness) * data.currentScale + smoothness * data.targetScale
		data.output_scale = math.min(data.currentScale * DB.Locus_Scales[1], DB.Locus_Maxes[1])
	end

	-- Partitioned scaling, for when locuses ARE in use.

	-- if data.UseLocationalMorphs then
		dvt.PartitionBurden(data.target, data.UseEliminationLocus, data.targetScales)

		for locus=1,6 do
			-- ignore tiny changes.
			local diff = data.currentScales[locus] - data.targetScales[locus]
			if diff * diff < threshold then
				-- Flip the value to negative so that DevourmentBellyScaling.psc knows to ignore it.
				if data.output_body[locus] > 0.0 then
					data.output_body[locus] = -data.output_body[locus]
				end

			else
				data.currentScales[locus] = (1.0 - smoothness) * data.currentScales[locus] + smoothness * data.targetScales[locus]
				local outputScale = math.min(data.currentScales[locus] * DB.Locus_Scales[locus], DB.Locus_Maxes[locus])

				-- If the output value is unchanged, flip it negative so that DevourmentBellyScaling.psc knows to ignore it.
				if data.output_body[locus] == outputScale or data.output_body[locus] == -outputScale then
					data.output_body[locus] = -outputScale
				else
					data.output_body[locus] = outputScale
				end
			end
		end
	-- end

	-- DO BUMP SCALING --

	if data.UseStruggleSliders then
		local bumpLoci = {1,1,1,4,4,4,5,5,5,6,6,6}
		local locusHealth = dvt.GetLocusHealth(data.target, playerStruggle, data.UseEliminationLocus)

		for i,bump in ipairs(data.bumps) do
			if not bump.A then
				bump.A = JMap.object()
				bump.B = JMap.object()
				bump.C = JMap.object()
			end
	
			local locus = bumpLoci[i]
			local amplitude = (locusHealth[locus] or 0.0) * data.StruggleAmplitude
			if data.squench then
				amplitude = 0.0
			end

			if math.random() > data.oddity then
				if not bump.A.active then
					dvt.StartThread(bump.A, amplitude, data.minDuration, data.maxDuration)
				elseif not bump.B.active then
					dvt.StartThread(bump.B, amplitude, data.minDuration, data.maxDuration)
				elseif not bump.C.active then
					dvt.StartThread(bump.C, amplitude, data.minDuration, data.maxDuration)
				end
			end
	
			dvt.UpdateThread(bump.A)
			dvt.UpdateThread(bump.B)
			dvt.UpdateThread(bump.C)
			bump.total = bump.A.output + bump.B.output + bump.C.output

			local newScale = (bump.total or 0.0) * DB.Locus_Scales[locus], DB.Locus_Maxes[locus]
			-- if data.UseLocationalMorphs then
				-- newScale = (bump.total or 0.0) * DB.Locus_Scales[locus], DB.Locus_Maxes[locus]
			-- else
				-- newScale = (bump.total or 0.0) * math.min(data.currentScale * DB.Locus_Scales[1], DB.Locus_Maxes[1])
			-- end

			if data.output_bumps[i] == newScale or data.output_bumps[i] == -newScale then
				data.output_bumps[i] = -newScale
			else	
				data.output_bumps[i] = newScale
			end
		end
	end

	return data.output_scale
end


function dvt.GutSliders(data)
	if not data then
		return 0.0
	end

	for i,bump in ipairs(data.bumps) do
		if not bump.A then
			bump.A = JMap.object()
			bump.B = JMap.object()
			bump.C = JMap.object()
		end

		if math.random() > data.oddity then
			if not bump.A.active then
				dvt.StartThread(bump.A, 1.0, data.minDuration, data.maxDuration)
			elseif not bump.B.active then
				dvt.StartThread(bump.B, 1.0, data.minDuration, data.maxDuration)
			elseif not bump.C.active then
				dvt.StartThread(bump.C, 1.0, data.minDuration, data.maxDuration)
			end
		end

		dvt.UpdateThread(bump.A)
		dvt.UpdateThread(bump.B)
		dvt.UpdateThread(bump.C)
		bump.total = bump.A.output + bump.B.output + bump.C.output

		if data.output_bumps[i] == bump.total or data.output_bumps[i] == -bump.total then
			data.output_bumps[i] = -bump.total
		else	
			data.output_bumps[i] = bump.total
		end
	end
end


--[[--
--]]--
function dvt.StartThread(thread, amplitude, minDuration, maxDuration)
	thread.active = true
	thread.tick = 1
	thread.output = 0.0
	thread.ramp = amplitude * math.random()
	thread.duration = minDuration + (maxDuration - minDuration) * math.random()
end


--[[--
--]]--
function dvt.UpdateThread(thread)
	if thread.active then
		thread.output = thread.ramp * math.sin(math.pi * thread.tick / thread.duration)
		thread.tick = thread.tick + 1
		thread.active = thread.tick <= thread.duration
	else
		thread.output = 0.0
	end
end


--[[--
@return An unowned bolus that is less than 10% digested.
--]]--
function dvt.GetRecentBolus(pred)
	assert(pred, "pred must be specified.")
	local stomach = dvt.GetStomach(pred)
	local bestBolus = nil
	local bestAge = 0.0

	for prey,preyData in pairs(stomach) do
		if preyData.bolus and preyData.owner == pred then
			local age = dvt.GetRemainingTime(preyData)
			if age > 0.9 and age > bestAge then
				bestBolus = prey
			end
		end
	end

	return bestBolus
end


--[[--
--]]--
function dvt.FindATalker()
	local DB = dvt.getDB()
	local player = DB.playerRef
	local livePrey = {}

	for pred,predData in pairs(dvt.getPredators()) do
		for prey,preyData in pairs(predData.stomach) do
			if prey == player then
				return preyData.pred
			elseif pred == player and preyData.alive and preyData.NPC then
				table.insert(livePrey, preyData.prey)
			end
		end
	end

	if #livePrey then
		local index = (DB.lastTalker or 0) + 1
		if index > #livePrey then
			index = 1
		end
		
		assert(index > 0, "Invalid talker index.")
		assert(index <= #livePrey, "Invalid talker index.")
		DB.lastTalker = index
		return livePrey[index]
	else
		return nil
	end
end


--[[--
Adds fake bulk to a predator's stomach. 
--]]--
function dvt.AddFakeToStomach(pred, timer, size, randomness)
	assert(pred, "Pred must be specified.")
	assert(size >= 0.0, "size must be non-negative.")
	assert(randomness >= 0.0, "randomness must be non-negative.")

	local predData = dvt.GetPredData(pred)
	if not predData then
		return
	end
	
	local gauss = dvt.gaussian(size, size * randomness)
	if gauss <= 0.0 then
		return
	end

	if not predData.fake then
		predData.fake = JMap.object()
		predData.fake.size = gauss
		predData.fake.timer = timer
		predData.fake.timerMax = timer
	else
		predData.fake.size = gauss + predData.fake.size
		predData.fake.timer = timer
		predData.fake.timerMax = timer
	end
end


--[[--
Adds a preyData to a predator's stomach. The predator is identified from the pred field of the preyData.
--]]--
function dvt.AddToStomach(preyData)
	assert(preyData, "preyData must be specified.")
	
	local stomach = dvt.GetStomach(preyData.pred)
	assert(stomach, "Pred stomach is missing.")
	
	if preyData.bolus then
		stomach[preyData.bolus] = preyData
	else
		stomach[preyData.prey] = preyData
	end
end


--[[--
Removes a preyData from a predator's stomach. The predator is identified from the pred field of the preyData.
--]]--
function dvt.RemoveFromStomach(preyData)
	assert(preyData, "preyData must be specified.")
	
	local stomach = dvt.GetStomach(preyData.pred)
	assert(stomach, "Pred stomach is missing.")

	if preyData.bolus then
		stomach[preyData.bolus] = nil
	else
		stomach[preyData.prey] = nil
	end
end


--[[--
Removes a preyData from a predator's stomach. The predator is identified from the pred field of the preyData.
--]]--
function dvt.PredatorTimeout(predData)
	assert(predData, "predData must be specified.")
	
	local stomach = predData.stomach
	assert(stomach, "Pred stomach is missing.")

	if predData.fake or not dvt.empty(stomach) then
		predData.timeout = nil
	elseif not predData.timeout then
		predData.timeout = 1
	else
		predData.timeout = predData.timeout + 1
	end
	
	return predData.timeout
end


--[[--
Counts all of the follower prey for a given Actor. If the Actor is not registered at all, the function returns 0.
Follower prey includes any preyData with the "isfollower" key.

@param target The Actor for which to count prey.
@return The integer count of live prey.
--]]--
function dvt.countFollowers(target)
	assert(target, "target must be specified.")
	return jc.count(dvt.GetStomach(target), function(preyData)
		return preyData.isfollower
	end)
end


--[[--
Counts all of the live prey for a given Actor. If the Actor is not registered at all, the function returns 0.
Undigested prey includes any preyData with the "live" key.

@param target The Actor for which to count prey.
@return The integer count of live prey.
--]]--
function dvt.countLivePrey(target)
	assert(target, "target must be specified.")
	return jc.count(dvt.GetStomach(target), function(preyData)
		return preyData.alive
	end)
end


--[[--
Counts all of the prey for a given actor. If the actor is not registered at all, the function returns 0.

@param target The Actor for which to count prey.
@return The integer count of prey.
--]]--
function dvt.countPrey(target)
	assert(target, "target must be specified.")
	return jc.count(dvt.GetStomach(target), function(preyData) 
		return not preyData.bolus
	end)
end


--[[--
Counts all of the undigested prey for a given Actor. If the Actor is not registered at all, the function returns 0.
Undigested prey includes any preyData with the "live" key or the "bolus" key.

@param target The Actor for which to count prey.
@return The integer count of active prey.
--]]--
function dvt.countUndigested(target)
	assert(target, "target must be specified.")
	return jc.count(dvt.GetStomach(target), function(preyData)
		return preyData.alive or preyData.bolus
	end)
end


--[[--
Counts all of the digested prey for a given actor. If the actor is not registered at all, the function returns 0.
Digested prey includes any preyData with the "dead" or "bolus" key and a timer field of zero.

@param target The Actor for which to count prey.
@return The integer count of active prey.
--]]--
function dvt.countDigested(target)
	assert(target, "target must be specified.")
	return jc.count(dvt.GetStomach(target), function(preyData)
		return preyData.digested or (preyData.bolus and preyData.timer <= 0.0)
	end)
end


--[[--
--]]--
function dvt.countExcretable(target)
	assert(target, "target must be specified.")
	return jc.count(dvt.GetStomach(target), function(preyData)
		return dvt.isExcretable(preyData)
	end)
end


--[[--
Counts all of the prey and boluses for a given actor. If the actor is not registered at all, the function returns 0.

@param target The Actor for which to count stomach contents.
@return The integer count of prey.
--]]--
function dvt.countAll(target)
	assert(target, "target must be specified.")
	return jc.count(dvt.GetStomach(target), function(preyData) 
		return true
	end)
end


--[[--
Returns the pred for a given prey, or nil if there is no pred for them.
--]]--
function dvt.whoAte(prey)
	assert(prey, "Prey must be specified.")
	return GetPreyData(prey).pred
end


--[[--
Finds the preyData for a specified prey.
If the prey is not registered for any pred, returns nil.
--]]--
function dvt.GetPreyData(prey)
	assert(prey, "prey must be specified.")

	for pred,predData in pairs(dvt.getPredators()) do
		if predData.stomach[prey] then
			return predData.stomach[prey]
		end
	end

	return nil
end


--[[--
--]]--
function dvt.GetEliminatedWeight(preyData)
	if preyData.purge then
		return 0.0
	elseif preyData.digested then
		return preyData.weight
	elseif preyData.alive or preyData.bolus then
		return 0.0
	elseif preyData.digesting and preyData.locus == 0 then
		return preyData.weight * math.min(math.max((preyData.timerMax - preyData.timer) / preyData.timerMax, 0.0), 1.0)
	else
		return 0.0
	end
end


--[[--
--]]--
function dvt.GetRemainingWeight(preyData)
	if not preyData then
		return 0.0
	elseif preyData.purge then
		return 0.0
	elseif preyData.alive or preyData.bolus then
		return preyData.weight
	elseif preyData.digesting then
		return preyData.weight * math.min(math.max(preyData.timer / preyData.timerMax, 0.0), 1.0)
	elseif preyData.digested then
		return 0.0
	else
		return 0.0
	end
end


--[[--
--]]--
function dvt.GetRemainingTime(preyData)
	if not preyData then
		return 0.0
	elseif preyData.purge then
		return 0.0
	elseif preyData.endo then
		return 1.0
	elseif preyData.digesting or preyData.vore then
		return math.min(math.max(preyData.timer / preyData.timerMax, 0.0), 1.0)
	elseif preyData.digested then
		return 0.0
	else
		return 0.0
	end
end


--[[--
--]]--
function dvt.SetRemainingTime(preyData, percent)
	assert(preyData, "preyData must be specified.")
	if preyData.digesting or preyData.reforming or preyData.vore then
		preyData.timer = preyData.timerMax * math.min(math.max(percent, 0.0), 1.0)
	end
end


--[[--
Transfer a prey from its original pred to a new one.
Takes as parameters the database, preyData, newPred, and a dummy prey.
--]]--
function dvt.ReplacePrey(pred, oldPrey, newPrey)
	assert(pred, "pred must be specified.")
	assert(oldPrey, "oldPrey must be specified.")
	assert(newPrey, "newPrey must be specified.")
	
	local stomach = dvt.GetStomach(pred)
	local preyData = dvt.GetPreyData(oldPrey)
	assert(stomach, "stomach not found.")
	assert(preyData, "preyData not found.")
	assert(preyData.prey, "preyData doesn't have a prey field.")
	
	stomach[oldPrey] = nil
	stomach[newPrey] = preyData
	preyData.prey = newPrey
end


--[[--
Transfer a prey from its original pred to a new one.
Takes as parameters the preyData and the newPred.
Returns true if the player was the one transferred.
--]]--
function dvt.TransferPrey(preyData, newPred)
	assert(preyData, "preyData must be specified.")
	assert(newPred, "newPred must be specified.")
	assert(preyData.pred ~= newPred, "Current pred and new pred must not be the same.")
	assert(preyData.prey ~= newPred, "Prey cannot be transferred to themselves.")
	assert(dvt.isPred(newPred), "newPred must be a predator.")

	local player = dvt.getDB().playerRef
	local key = preyData.prey or preyData.bolus
	local oldPred = preyData.pred
	local oldStomach = dvt.GetStomach(oldPred)
	local newStomach = dvt.GetStomach(newPred)
	assert(oldStomach, "oldPred.stomach not found.")
	assert(newStomach, "newPred.stomach not found.")

	preyData.pred = newPred
	oldStomach[key] = nil
	newStomach[key] = preyData
	
	if preyData.isfollower and newPred == player then
		dvt.SetEndo(preyData)
	end

	return (preyData.key == player)
end


--[[--
Transfers all stomach contents from oldPred to newPred.
If newPred is registered as a prey of oldPred, an error will be raised.
Returns true if the player was transferred.
--]]--
function dvt.TransferStomach(oldPred, newPred)
	assert(oldPred, "oldPred must be specified.")
	assert(newPred, "newPred must be specified.")
	assert(oldPred ~= newPred, "oldPred and newPred must not be the same.")
	assert(dvt.isPred(newPred), "newPred must be a predator.")
	
	if not dvt.isPred(oldPred) then
		return
	end

	local player = dvt.getDB().playerRef

	local newPredData = dvt.GetPredData(newPred)
	local oldPredData = dvt.GetPredData(oldPred)

	local newStomach = newPredData.stomach
	local oldStomach = oldPredData.stomach
	oldPredData.stomach = JFormMap.object()

	assert(oldStomach, "oldPred must be a predator.")
	assert(newStomach, "newPred must be a predator.")
	assert(not oldStomach[newPred], "oldPred must not have newPred in their stomach.")

	local playerTransferred = false

	for prey,preyData in pairs(oldStomach) do
		assert(preyData.pred == oldPred)
		newStomach[prey] = preyData
		preyData.pred = newPred
		
		if preyData.isfollower and newPred == player then
			dvt.SetEndo(preyData)
		elseif prey == player then
			playerTransferred = true
		end
	end

	for prey,_ in pairs(newStomach) do
		oldStomach[prey] = nil
	end

	return playerTransferred
end


--[[--
For a given preyData, finds the apex predator.
If that predator is not the direct predator for the preyData,
the prey is transferred to them.
Returns the apex predator.
--]]--
function dvt.solveApex(preyData, dummy)
	assert(preyData, "preyData must be specified.")
	local apex = dvt.getApex(preyData.pred)

	if apex ~= preyData.pred then
		dvt.transferPrey(preyData, apex, dummy)
	end

	return apex
end


--[[--
For a given prey or pred, finds and returns the apex predator.
--]]--
function dvt.getApex(target)
	assert(target, "target must be specified.")

	local preyData = dvt.GetPreyData(target)
	if not preyData then
		return target
	else
		return dvt.getApex(preyData.pred)
	end
end


--[[--
Flags all of a predator's prey for vomiting.
--]]--
function dvt.registerVomitAll(pred, forced)
	assert(pred, "Pred must be specified.")

	local predData = dvt.GetPredData(pred)
	if not predData then
		return
	end
	
	predData.fake = nil

	--- Update the flags as appropriate.
	for _,preyData in pairs(predData.stomach) do
		if dvt.isExcretable(preyData) or forced then
			preyData.vomit = true
		end
	end
end


--[[--
Flags a preyData for vomiting by the prey's apex predator.
If the preyData is for an NPC, their equipment will be flagged too.
--]]--
function dvt.registerVomit(preyData)
	assert(preyData, "preyData must be specified.")
	local pred = preyData.pred
	local stomach = dvt.GetStomach(pred)
	
	preyData.vomit = true
	
	--- Vomit the prey's equipment too.
	if stomach and preyData.npc and preyData.prey then
		for _,bolusData in pairs(stomach) do
			if bolusData.bolus and bolusData.owner == preyData.prey then
				bolusData.vomit = true
			end
		end
	end
end


--[[--
Returns a subset of the predData consisting of bolus items.
If owner is specified, only boluses with a matching owner field
will be returned.
--]]--
function dvt.getBoluses(predData, owner)
	assert(predData, "predData must be specified.")

	local boluses = JFormMap.object()

	for prey,preyData in pairs(predData) do
		if preyData.bolus then
			if not owner or preyData.owner == owner then
				boluses[prey] = preyData
			end
		end
	end

	return boluses
end


--[[--
Returns a subset of the predData consisting of live prey.
--]]--
function dvt.getLive(predData)
	assert(predData, "predData must be specified.")

	local live = JFormMap.object()

	for prey,preyData in pairs(predData) do
		if preyData.alive then
			live[prey] = preyData
		end
	end

	return live
end


--[[--
Returns a subset of the predData consisting of fully digested prey.
--]]--
function dvt.getDigested(predData)
	assert(predData, "predData must be specified.")

	local digested = JFormMap.object()

	for prey,preyData in pairs(predData) do
		if preyData.dead and preyData.timer <= 0.0 then
			digested[prey] = preyData
		end
	end

	return digested
end


--[[--
--]]--
function dvt.setVomitFlags(preyData)
	preyData.vomit = 1
end


--[[--
--]]--
function dvt.GetBurdenLinear(pred)
	assert(pred, "Pred must be specified.")
	if not dvt.isPred(pred) then
		return 0.0
	end
	
	local predData = dvt.GetPredData(pred) or {}
	local burden = 0.0

	if predData.fake then
		burden = burden + predData.fake.size
	end
	
	for prey,preyData in pairs(predData.stomach or {}) do
		burden = burden + dvt.GetRemainingWeight(preyData) + dvt.GetBurdenLinear(prey) / 2.0
	end

	return burden
end


--[[--
--]]--
function dvt.GetBurden(pred)
	return math.pow(dvt.GetBurden2(pred), 0.4)
end


--[[--
--]]--
function dvt.GetBurden2(pred)
	assert(pred, "Pred must be specified.")
	if not dvt.isPred(pred) then
		return 0.0
	end
	
	local predData = dvt.GetPredData(pred) or {}
	local burden2 = 0.0

	if predData.fake then
		local weight = predData.fake.size
		burden2 = burden2 + weight*weight
	end
	
	for prey,preyData in pairs(predData.stomach or {}) do
		local preyBurden2 = dvt.GetBurden2(prey)
		local weight = dvt.GetRemainingWeight(preyData)
		burden2 = burden2 + weight*weight + preyBurden2 / 2.0
	end

	return burden2
end


--[[--
--]]--
function dvt.PartitionBurden(pred, useElimination, scales)
	assert(pred, "Pred must be specified.")
	
	local locusStomach = 1
	local locusButt = 2
	local locusUnbirth = 3
	local locusBreastL = 4
	local locusBreastR = 5
	local locusCock = 6

	local predData = dvt.GetPredData(pred) or {}
	
	for i,_ in ipairs(scales) do
		scales[i] = 0.0
	end

	if predData.fake then
		local weightStomach = predData.fake.size 
		scales[locusStomach] = (scales[locusStomach] or 0.0) + weightStomach * weightStomach

		if useElimination then
			local weightButt = predData.fake.size
			scales[locusButt] = (scales[locusButt] or 0.0) + weightButt * weightButt / 4.0
		end
	end
	
	for prey,preyData in pairs(predData.stomach or {}) do
		local preyBurden2 = dvt.GetBurden2(prey)
		local locus = preyData.locus + 1
		local weight = dvt.GetRemainingWeight(preyData)

		if locus == locusUnbirth or (locus == locusButt and useElimination) then
			scales[locusStomach] = (scales[locusStomach] or 0.0) + weight * weight + preyBurden2 / 2.0
		else
			scales[locus] = (scales[locus] or 0.0) + weight * weight + preyBurden2 / 2.0
		end

		if useElimination and not preyData.reforming then
			local weightElimation = dvt.GetEliminatedWeight(preyData)
			if locus == locusCock then
				scales[locusCock] = (scales[locusCock] or 0.0) + weightElimation * weightElimation / 4.0 + preyBurden2 / 8.0
			elseif locus == locusStomach then
				scales[locusButt] = (scales[locusButt] or 0.0) + weightElimation * weightElimation / 4.0 + preyBurden2 / 8.0
			end
		end
	end
	
	for locus,scale2 in pairs(scales) do
		scales[locus] = math.pow(scale2, 0.4)
	end
end


--[[--
--]]--
function dvt.GetHealth(pred, playerStruggle)
	assert(pred, "Pred must be specified.")
	if not dvt.isPred(pred) then
		return 0.0
	end
	
	local playerRef = dvt.getDB().playerRef
	local predData = dvt.GetPredData(pred) or {}
	local maxHealth = 0.0

	for prey,preyData in pairs(predData.stomach or {}) do
		if preyData.ForceStruggling then
			maxHealth = math.max(maxHealth or 0.0, 1.0)
		elseif prey == playerRef and playerStruggle >= 0.0 then
			maxHealth = math.max(maxHealth or 0.0, playerStruggle)
		else
			maxHealth = math.max(maxHealth or 0.0, preyData.health or 0.0)
		end
	end

	return maxHealth
end


--[[--
--]]--
function dvt.GetLocusHealth(pred, playerStruggle, useElimination)
	assert(pred, "Pred must be specified.")
	if not dvt.isPred(pred) then
		return {}
	end
	
	local locusStomach = 1
	local locusButt = 2
	local locusUnbirth = 3
	local locusBreastL = 4
	local locusBreastR = 5
	local locusCock = 6

	local playerRef = dvt.getDB().playerRef
	local predData = dvt.GetPredData(pred) or {}
	local locusHealth = {}

	for prey,preyData in pairs(predData.stomach or {}) do
		local locus = preyData.locus + 1
		local health

		if prey == playerRef and playerStruggle >= 0.0 then
			health = playerStruggle or 0.0
		elseif preyData.vore or (preyData.ForceStruggling and preyData.endo) then
			health = preyData.health or 0.0
		end

		if locus == locusUnbirth or (locus == locusButt and useElimination) then
			locusHealth[locusStomach] = math.max(locusHealth[locusStomach] or 0.0, health or 0.0)
		else
			locusHealth[locus] = math.max(locusHealth[locus] or 0.0, health or 0.0)
		end
	end

	return locusHealth
end


--[[--
--]]--
function dvt.GetFullness(pred)
	assert(pred, "pred must be specified.")

	local results = JMap.object()
	local stomach = dvt.GetStomach(pred)
	if not stomach then
		return results
	end

	for _,preyData in pairs(stomach) do
		if preyData.bolus or preyData.digested or preyData.vomit then
			-- nothing
			
		elseif preyData.alive and preyData.npc and preyData.vore then
			if preyData.sex > 0 then
				results.female = 1
			else
				results.male = 1
			end
			
		elseif preyData.alive or preyData.digesting then
			results.other = 1
		end
	end

	return results
end


--[[--
Checks if an actor is safe to sleep or wait.
--]]--
function dvt.CanEscape(preyData)
	assert(preyData, "preyData must be specified.")
	return not (preyData.consented or preyData.surrendered or preyData.noEscape)
end


--[[--
Checks if an actor is safe to sleep or wait.
--]]--
function dvt.RelativelySafe(target)
	assert(target, "target must be specified.")
	
	local targetPreyData = dvt.GetPreyData(target)
	if targetPreyData and targetPreyData.vore then
		return false
	end
	
	local stomach = dvt.GetStomach(target)
	if not stomach then
		return true
	end
	
	for prey,preyData in pairs(stomach) do
		if preyData.alive and preyData.vore then
			return false
		end
	end
	
	return true
end


--[[--
Obtain an prey's state with one call.
0 == alive, vore
1 == alive, endo
2 == dead, digesting
3 == dead, digested
4 == vomit
--]]--
function dvt.GetStateCode(preyData)
	if preyData.vomit then
		return 5
	elseif preyData.digested then
		return 4
	elseif preyData.reforming then
		return 3
	elseif preyData.digesting then
		return 2
	elseif preyData.alive then
		if preyData.endo then
			return 1
		else
			return 0
		end
	end
end


function dvt.SetEndo(preyData)
	assert(preyData, "preyData must be specified.")
	preyData.alive = 1
	preyData.corpse = nil
	preyData.endo = 1
	preyData.vore = nil
	preyData.digesting = nil
	preyData.digested = nil
	preyData.reforming = nil
	preyData.timer = 0.0
	preyData.timerMax = 0.0
end


function dvt.SetVore(preyData)
	assert(preyData, "preyData must be specified.")
	preyData.alive = 1
	preyData.vore = 1
	preyData.endo = nil
	preyData.digesting = nil
	preyData.digested = nil
	preyData.reforming = nil
	preyData.struggle = 0.0
	preyData.timer = preyData.timerMax or 10.0
end


function dvt.SetDigesting(preyData)
	assert(preyData, "preyData must be specified.")
	preyData.alive = nil
	preyData.endo = nil
	preyData.vore = nil
	preyData.health = nil
	preyData.digesting = 1
	preyData.digested = nil
end


function dvt.SetReforming(preyData)
	assert(preyData, "preyData must be specified.")
	preyData.health = nil
	preyData.timer = 0.0
	preyData.reforming = 1
	preyData.digested = nil
	preyData.digesting = 1
end


function dvt.SetDigested(preyData)
	assert(preyData, "preyData must be specified.")
	preyData.health = nil
	preyData.alive = nil
	preyData.endo = nil
	preyData.vore = nil
	preyData.digesting = nil
	preyData.reforming = nil
	preyData.digested = 1
end


function dvt.SetNPC(preyData)
	assert(preyData, "preyData must be specified.")
	preyData.npc = 1
end


function dvt.SetCorpse(preyData)
	assert(preyData, "preyData must be specified.")
	preyData.corpse = 1
end


--[[--
Generates a poisson-distributed pseudo-random integer.
--]]--
function dvt.poisson(t)
	local k = 0
	local p = 1
	local L = math.exp(-t)

	repeat
		k = k + 1
		p = p * math.random()
	until p <= L

	return k - 1
end


--[[--
Generates a gaussian-distributed pseudo-random float.
--]]--
function dvt.gaussian(mean, sigma)
	return math.sqrt(-2.0 * sigma * sigma * math.log(math.random())) * math.cos(2.0 * math.pi * math.random()) + mean
end


--[[--
Tests if a table is empty.
nil is always considered empty.
--]]--
function dvt.empty(tbl)
	if not tbl then
		return true
	end

	for _,_ in pairs(tbl) do
		return false
	end

	return true
end


--[[--
--]]--
function dvt.uuid()
   local randomPart = string.format("%08x", math.random(0x100000000))
   local timePart = string.format("%08x", (os.time() * 0x46838bd) % 0x100000000)
   return timePart.."-"..randomPart
end


function dvt.matcher(str_a)
	if str_a then
		return (function(str_b) return str_b and string.upper(str_a) == string.upper(str_b) end)
	else
		return (function(str_b) return not str_b end)
	end
end


return dvt
