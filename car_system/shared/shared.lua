
function convertPlateIDtoLicensep(plateID)
	if (not plateID) then return "" end
	local licensep
	local test = string.sub(plateID, 1, 1)
	if (test == "a") then
		licensep = ""..strRep(string.sub(plateID, 3, 8))..""..string.sub(plateID, 9, 11)..""
	elseif (test == "q") then
		licensep = ""..strRep(string.sub(plateID, 3, 8))..""..string.sub(plateID, 9, 11)..""
	elseif (test == "b") then
		licensep = ""..strRep(string.sub(plateID, 3, 7))..""..string.sub(plateID, 8, 10)..""
	elseif (test == "c") then
		licensep = ""..string.sub(plateID, 3, 6)..""..strRep(string.sub(plateID, 7, 8))..""..string.sub(plateID, 9, 10)..""
	elseif (test == "d") then
		licensep = ""..string.sub(plateID, 3, 6)..""..strRep(string.sub(plateID, 7, 7)).." "..string.sub(plateID, 8, 9)..""
	elseif (test == "e") then
		licensep = ""..string.sub(plateID, 3, 8)..""..string.sub(plateID, 9, 10)..""
	elseif (test == "f") then
		licensep = ""..string.sub(plateID, 3, 4).." "..string.sub(plateID, 5, 8).." "..string.sub(plateID, 9, 10)..""
	elseif (test == "s") then
		licensep = ""..string.sub(plateID, 3, 5).." "..string.sub(plateID, 6, 9)..""
	elseif (test == "g") then
		licensep = ""..string.sub(plateID, 3, 6).." "..string.sub(plateID, 7, 8).."-"..string.sub(plateID, 9, 9)..""
	elseif (test == "h") then
		licensep = ""..string.sub(plateID, 3, string.len(plateID))..""
	elseif (test == "r") then
		licensep = ""..string.sub(plateID, 3, string.len(plateID))..""
	elseif (test == "n") then
		licensep = ""..string.sub(plateID, 3, string.len(plateID))..""
	elseif (test == "i") then
		licensep = ""..strRep(string.sub(plateID, 3, 7))..""..string.sub(plateID, 8, 9)..""	
	elseif (test == "o") then
		licensep = ""..strRep(string.sub(plateID, 3, 8))..""--..string.sub(plateID, 9, 11)..""
	elseif (test == "x") then
		licensep = ""..strRep(string.sub(plateID, 3, 8))..""--..string.sub(plateID, 9, 11)..""
	elseif (test == "m") then
		licensep = ""..strRep(string.sub(plateID, 3, 8))..""--..string.sub(plateID, 9, 11)..""
	elseif (test == "z") then
		licensep = ""..strRep(string.sub(plateID, 3, 8))..""..string.sub(plateID, 9, 11)..""		
	elseif (test == "l") then		
		licensep = ""..strRep(string.sub(plateID, 3, 9))..""..string.sub(plateID, 9, 11)..""	
	elseif (test == "j") then
		licensep = ""..strRep(string.sub(plateID, 3, 8))..""
	elseif (test == "v") then		
		licensep = ""..string.sub(plateID, 3, 4)..""..strRep(string.sub(plateID, 5, 10))..""
	elseif (test == "y") then		
		licensep = ""..string.sub(plateID, 3, 5).."-"..strRep(string.sub(plateID, 6, 10))..""
	else
		return ""
	end
	return licensep
end

function strRep(str)
	str = string.gsub(str, "b", "в")
	str = string.gsub(str, "k", "к")
	str = string.gsub(str, "m", "м")
	str = string.gsub(str, "h", "н")
	str = string.gsub(str, "t", "т")
	return str
end

function getAllSellingPrices(model)
	if isResourceRunning("bank") then
		local price, currency = getCarPrice(model)
		local realPrice = exports.bank:convertCurrency(price, currency)
		realPrice = math.floor(realPrice/1000)*1000		-- Округляем до тысяч
		
		local defaultPrice = math.floor(realPrice*0.55)
		local minSellPrice = math.floor(realPrice*0.2)
		local maxSellPrice = math.floor(realPrice*0.7)
		
		return realPrice, defaultPrice, minSellPrice, maxSellPrice
	else
		return false
	end
end


