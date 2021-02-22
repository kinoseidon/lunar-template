--std.xml
local xero = setmetatable(xero, xero)
xero.__index = _G

local function noop() end

function xero:__call(f, name)
	
	if type(f) == 'string' then
		-- if xero is called with a string, we need to load the string as code
		local err
		-- try compiling the code
		f, err = loadstring( 'return function(self)' .. f .. '\nend', name)
		if err then SCREENMAN:SystemMessage(err) return noop end
		-- grab the function
		f, err = pcall(f)
		if err then SCREENMAN:SystemMessage(err) return noop end
	end
	
	setfenv(f or 2, self)
	return f
end

xero()

local function insertion_sort(t, l, h, c)
	for i = l + 1, h do
		local k = l
		local v = t[i]
		for j = i, l + 1, -1 do
			if c(v, t[j - 1]) then
				t[j] = t[j - 1]
			else
				k = j
				break
			end
		end
		t[k] = v
	end
end

local function merge(t, b, l, m, h, c)
	if c(t[m], t[m + 1]) then
		return
	end
	local i, j, k
	i = 1
	for j = l, m do
		b[i] = t[j]
		i = i + 1
	end
	i, j, k = 1, m + 1, l
	while k < j and j <= h do
		if c(t[j], b[i]) then
			t[k] = t[j]
			j = j + 1
		else
			t[k] = b[i]
			i = i + 1
		end
		k = k + 1
	end
	for k = k, j - 1 do
		t[k] = b[i]
		i = i + 1
	end
end

local magic_number = 12

local function merge_sort(t, b, l, h, c)
	if h - l < magic_number then
		insertion_sort(t, l, h, c)
	else
		local m = math.floor((l + h) / 2)
		merge_sort(t, b, l, m, c)
		merge_sort(t, b, m + 1, h, c)
		merge(t, b, l, m, h, c)
	end
end

local function default_comparator(a, b) return a < b end
local function flip_comparator(c) return function(a, b) return c(b, a) end end

function stable_sort(t, c)
	if not t[2] then return t end
	c = c or default_comparator
	local n = t.n
	local b = {}
	b[math.floor((n + 1) / 2)] = t[1]
	merge_sort(t, b, 1, n, c)
	return t
end

local function add(self, obj)
	local stage = self.stage
	self.n = self.n + 1
	stage.n = stage.n + 1
	stage[stage.n] = obj
end

local function remove(self)
	local swap = self.swap
	swap[swap.n] = nil
	swap.n = swap.n - 1
	self.n = self.n - 1
end

local function next(self)
	if self.n == 0 then return end
	
	local swap = self.swap
	local stage = self.stage
	local list = self.list
	
	if swap.n == 0 then
		stable_sort(stage, self.reverse_comparator)
	end
	if stage.n == 0 then
		if list.n == 0 then
			while swap.n ~= 0 do
				list.n = list.n + 1
				list[list.n] = swap[swap.n]
				swap[swap.n] = nil
				swap.n = swap.n - 1
			end
		else
			swap.n = swap.n + 1
			swap[swap.n] = list[list.n]
			list[list.n] = nil
			list.n = list.n - 1
		end
	else
		if list.n == 0 then
			swap.n = swap.n + 1
			swap[swap.n] = stage[stage.n]
			stage[stage.n] = nil
			stage.n = stage.n - 1
		else
			if self.comparator(list[list.n], stage[stage.n]) then
				swap.n = swap.n + 1
				swap[swap.n] = list[list.n]
				list[list.n] = nil
				list.n = list.n - 1
			else
				swap.n = swap.n + 1
				swap[swap.n] = stage[stage.n]
				stage[stage.n] = nil
				stage.n = stage.n - 1
			end
		end
	end
	return swap[swap.n]
end

function perframe_data_structure(comparator)
	return {
		add = add,
		remove = remove,
		next = next,
		comparator = comparator or default_comparator,
		reverse_comparator = flip_comparator(comparator or default_comparator),
		stage = {n = 0},
		list = {n = 0},
		swap = {n = 0},
		n = 0,
	}
end

local stringbuilder_mt =  {
	__index = {
		build = table.concat,
		sep = function(self, sep)
			if self[1] then
				self(sep)
			end
		end,
	},
	__tostring = table.concat,
	__call = function(self, a)
		table.insert(self, tostring(a))
		return self
	end,
}

function stringbuilder()
	return setmetatable({}, stringbuilder_mt)
end
return Def.Actor {}
