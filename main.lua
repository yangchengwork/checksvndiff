require("svn");

srcpath = "svn://xcyserver/rock3188/trunk/git4.2.2_r1";
trgpath = "svn://xcyserver/rock3188/trunk/4.2.2_r1";	-- target
startver = 688
endver = 1200
filename = "/media/ramdisk/a.txt"
fixedpath = "/trunk/git4.2.2_r1/"
filetable = {}

ignore = ".git"

trgworkpath = "/media/ramdisk/4.2.2_r1"

--[[
t = svn.list(srcpath, startver, endver);
for name, prop in pairs (t) do
	print (name)
	for k, v in pairs(prop) do
		print (k, v)
	end
end
]]

function splitline(line)
	local i, j = string.find(line, "^%s+%u");
	local mode = string.char(string.byte(line, j));
	i, j = string.find(line, fixedpath, j);
	name = string.sub(line, j+1);
	i, j = string.find(name, ignore);
	if i ~= 1 then
		table.insert(filetable, name);
	end
	--[[
	for w in string.gmatch(name, "[^/]+") do
		print(w)
	end
	]]
	-- print(line)
end

function readfile()
	local line
	file = io.open(filename, "r");
	while true do
		line = file:read()
		if line == nil then break end
		i = string.find(line, "^   ");
		if i == 1 then
			splitline(line);
			-- break;
		end
	end
	file:close();
	--[[
	for i, w in ipairs(filetable) do
		print(w)
	end
	print(table.getn(filetable));
	]]
end

function updatesvnfile(name)
	-- print(name);
	local path = trgworkpath;
	local cmd = "svn up --depth empty ";
	for w in string.gmatch(name, "[^/]+") do
		path = string.format("%s/%s", path, w);
		cmd = string.format("%s \"%s\"", cmd, path);
		-- print(cmd);
	end
	-- print(cmd)
	os.execute(cmd);
	-- name = string.format("svn ls %s/%s", trgworkpath, w);
	-- os.execute(name);
end
function updatefile()
	local i, w;

	for i, w in ipairs(filetable) do
		updatesvnfile(w);
	end
end

function init()
	local cmd = string.format("svn co --depth empty %s %s", trgpath, trgworkpath);
	os.execute(cmd);
	cmd = string.format("svn log -v -r %d:%d %s > %s", startver, endver, srcpath, filename);
	os.execute(cmd);
end

init();
readfile();
updatefile();
