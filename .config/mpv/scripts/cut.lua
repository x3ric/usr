utils = require 'mp.utils'
cut_begin = 0.0
cut_end   = mp.get_property_native("length")
if cut_end == nil or cut_end == "none" then
 cut_end = 0.0
end
mp.set_property("hr-seek-framedrop","no")
mp.set_property("options/keep-open","always")
function cut_on_eof()
	mp.msg.log("info", "playback reached end of file")
	mp.set_property("pause","yes")
	mp.commandv("seek", 100, "absolute-percent", "exact")
end
mp.register_event("eof-reached", cut_on_eof)
function cut_mark_begin_handler() 
	pt = mp.get_property_native("playback-time")
	if pt == nil or pt == "none" then
		pt = 0.0
	end
    local all_chapters = mp.get_property_native("chapter-list")
	table.remove(all_chapters,2)
	all_chapters[1] = {
		title = "in",
		time = pt
	}
	mp.set_property_native("chapter-list", all_chapters)
	cut_begin = pt
	if cut_begin > cut_end then
		cut_end = cut_begin
	end
	local message = "StartCut point set."
	mp.msg.log("info", message)
	mp.osd_message(message, 5)
	mp.set_property("options/script-opts","osc-layout=bottombar,osc-hidetimeout=120000")

 end
function cut_mark_end_handler() 
	pt = mp.get_property_native("playback-time")
	if pt == nil or pt == "none" then
		pt = 0.0
	end
    local all_chapters = mp.get_property_native("chapter-list")
	all_chapters[2] = {
		title = "out",
		time = pt
	}
	mp.set_property_native("chapter-list", all_chapters)
	cut_end = pt
	if cut_end < cut_begin then
		cut_begin = cut_end
	end
	local message = "EndCut point set."
	mp.msg.log("info", message)
	mp.osd_message(message, 5)
end
srcname = ""
srcpath = ""
srcext = ""
installed_gpus = ""
encoding = true
ffmpeg_profiles = {}
export_profile_idx = 1
function get_destination_filename()	
	srcname   = mp.get_property_native("filename")
	local srcnamene = mp.get_property_native("filename/no-ext")	
	local ext_length = string.len(srcname) - string.len(srcnamene)
	srcext = string.sub(srcname, -ext_length)
	local name_length = string.len(tostring(srcname))
	srcpath = tostring(mp.get_property_native("path")) -- string.sub(tostring(mp.get_property_native("path")), name_length)
	return tostring(srcpath .. ".cut_" .. cut_begin .. "-" .. cut_end)
end
function cut_encoding_toggle_handler() 
	export_profile_idx = (export_profile_idx % #ffmpeg_profiles) + 1
	mp.osd_message("Export profile: " .. ffmpeg_profiles[export_profile_idx][1], 3)
end
function cut_write_handler() 
	if cut_begin == cut_end then
		message = "cut_write: not writing because begin == end == " .. cut_begin
		mp.osd_message(message, 3)
		return
	end
	dstname = get_destination_filename()
	duration = cut_end - cut_begin
	if (dstname == "") then
		return
	end
	local message = ""
	message = message .. "writing to destination file '" .. dstname .. "'" .. "\nPlease wait..." 
	mp.msg.log("info", message)
	mp.osd_message(message, 60)
	local cmd = {}
	cmd["cancellable"] = false
	cmd["args"] = {}
	table.insert(cmd["args"], "ffmpeg")
	if string.find(installed_gpus, "nvidia")  then
		table.insert(cmd["args"], "-hwaccel") 
		table.insert(cmd["args"], "cuda")
		table.insert(cmd["args"], "-hwaccel_output_format")
		table.insert(cmd["args"], "cuda")
	elseif string.find(installed_gpus, "intel") then
		table.insert(cmd["args"], "-hwaccel") 
		table.insert(cmd["args"], "vaapi")
		table.insert(cmd["args"], "-hwaccel_output_format") 
		table.insert(cmd["args"], "vaapi")
		table.insert(cmd["args"], "-vaapi_device") 
		table.insert(cmd["args"], "/dev/dri/renderD128") 
	end
	table.insert(cmd["args"], "-i")
	table.insert(cmd["args"], tostring(srcpath))
	table.insert(cmd["args"], "-ss")
	table.insert(cmd["args"], tostring(cut_begin))
	table.insert(cmd["args"], "-t")
	table.insert(cmd["args"], tostring(duration))
	for k, v in ipairs(ffmpeg_profiles[export_profile_idx]) do
		if k == 1 then
			-- mp.osd_message("Exporting with profile: " .. v, 1)
		else
			table.insert(cmd["args"], v)
		end
	end
	local dstext_idx = #ffmpeg_profiles[export_profile_idx]
	local dstext = ffmpeg_profiles[export_profile_idx][dstext_idx]
	if dstext == "." then
		cmd["args"][#cmd["args"]] = dstname .. srcext
	else
		cmd["args"][#cmd["args"]] = dstname .. dstext
	end 
	local res = utils.subprocess(cmd)
	if (res["status"] ~= 0) then
		message = message .. "failed!\nfailed to run cut - status = " .. res["status"]
		if (res["error"] ~= nil) then
			message = message .. ", error message: " .. res["error"]
		end
		mp.msg.log("error", message)
		mp.osd_message(message, 10)
	else
		mp.msg.log("info", "cut '" .. dstname .. "' written.")
		message = message .. "\n DONE!"
		mp.osd_message(message, 10)
	end
 
end
function os.capture(cmd, raw)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then return s end
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end
function cut_on_loaded()
	--mp.osd_message("cut: use i and o to set IN and OUT points.", 3)
	local operating_system = string.lower(os.capture("uname"))
	installed_gpus = string.lower(os.capture("lspci -k | grep -E 'VGA|3D|Display'"))
	if operating_system == "darwin" then
		table.insert(ffmpeg_profiles, {"ACCURATE (MacOS GPU)", "-c:v", "h264_videotoolbox", "-b:v", "10000k", "-c:a", "aac", ".mp4"})
	else 
		if string.find(installed_gpus, "nvidia")  then
			table.insert(ffmpeg_profiles, {"ACCURATE (NVIDIA GPU)", "-c:v", "h264_nvenc", "-preset", "medium", "-c:a", "aac", ".mp4"})
		elseif string.find(installed_gpus, "intel")  then
			table.insert(ffmpeg_profiles, {"ACCURATE (INTEL GPU)", "-vf", "'format=nv12,hwupload'", "-c:v", "h264_vaapi", "-qp", "25", "-c:a", "aac", ".mp4"})
		end
	end 
	table.insert(ffmpeg_profiles, {"ACCURATE (CPU)", "-c:v", "libx264", "-crf", "23", "-c:a", "aac", ".mp4"})
	table.insert(ffmpeg_profiles, {"FAST", "-c:v", "copy", "-c:a", "copy", "."})
end
mp.register_event("file-loaded", cut_on_loaded)
-- key bindings
mp.add_key_binding("shift+s", "cut_mark_begin", cut_mark_begin_handler)
mp.add_key_binding("shift+e", "cut_mark_end", cut_mark_end_handler)
mp.add_key_binding("shift+C", "cut_encoding_toggle", cut_encoding_toggle_handler)
mp.add_key_binding("c", "cut_write", cut_write_handler)
