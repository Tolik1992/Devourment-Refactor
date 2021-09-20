--------------------------------
---
--- Useful logging functions.
---
--------------------------------


local logging = {}


function logging.tableToList(tbl)
	if type(tbl) == 'nil' then
		return tostring(tbl)

	elseif type(tbl) == 'string' then
		return '"'..tbl..'"'

	elseif type(tbl) ~= 'cdata' then
		return tostring(tbl)

	elseif not logging.isTable(tbl) then
		return tostring(tbl)

	else
		if logging.isEmptyTable(tbl) then
			return '{}'
		else
			local t = {}

			for k,v in pairs(tbl) do
				local kstr = tostring(k)
				local vstr = tostring(v)
				v = '{['..kstr..'] = '..vstr..'}'
				table.insert(t, v)
			end

			return '{'..table.concat(t, ', ')..'}'
		end
	end
end


function logging.tableToString(tbl, lv)
	if type(tbl) == 'nil' then
		return tostring(tbl)

	elseif type(tbl) == 'string' then
		return '"'..tbl..'"'

	elseif type(tbl) ~= 'cdata' then
		return tostring(tbl)

	elseif not logging.isTable(tbl) then
		return tostring(tbl)

	else
		if logging.isEmptyTable(tbl) then
			return '{}'
		elseif logging.depth(tbl) == 1 then
			return logging.tableToList(tbl)
		else
			local level = lv or 0
			local t = {}

			for k,v in pairs(tbl) do
				local kstr = logging.tableToString(k, level + 1)
				local vstr = logging.tableToString(v, level + 1)
				local indent = string.rep('\t', level + 1)
				v = indent..'['..kstr..'] = '..vstr
				table.insert(t, v)
			end

			local indent = string.rep('\t', level)
			local concat = table.concat(t, ',\n')
			return '{\n'..concat..'\n'..indent..'}'
		end
	end
end


function logging.isTable(tbl)
	if not pcall(function() pairs(tbl) end)	then
		return false
	end

	return true
end


function logging.isEmptyTable(tbl)
	for _ in pairs(tbl) do
		return false
	end

	return true
end


function logging.depth(tbl)
	if not logging.isTable(tbl) then
		return 0
	end
	
	local valDepth = 0
	
	for k,v in pairs(tbl) do
		valDepth = math.max(valDepth, logging.depth(v))
	end
	
	return 1 + valDepth
end

return logging
