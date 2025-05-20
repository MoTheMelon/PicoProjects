pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- cryomancer
-- by suezou

--changelog
-- 4
-- Fixed some English spelling mistakes.
-- 3
-- Added level status to achievements screen.
-- 2
-- Fixed some minor issues.
-- 1
-- Fixed some English spelling mistakes.
-- 0
-- Published.

cartdata"spz_cryomancer"

game_mode, game_fcount, game_level, game_clrcount, game_totalsteps, game_quake, boss_wait, boss_timer
 = "title", 0,  1, 0, 0, 0, 0, 180

leveldata = {
	[1] = split("0, 0, 8, 8"),
	[2] = split("8, 0, 8, 8"),
	[3] = split("16, 0, 10, 8"),
	[4] = split("26, 0, 10, 8"),
	[5] = split("36, 0, 8, 8"),
	[6] = split("43, 0, 12, 9"),
	[7] = split("55, 0, 14, 9"),
	[8] = split("69, 0, 12, 8"),
	[9] = split("81, 0, 10, 10"),
	[11] = split("0, 9, 8, 8"),
	[12] = split("8, 9, 10, 10"),
	[10] = split("91, 0, 12, 11"),
	[13] = split("103, 0, 12, 10"),
	[14] = split("114, 0, 12, 11"),
	[15] = split("18, 9, 10, 9"),
	[16] = split("29, 9, 10, 12"),
	[17] = split("39, 9, 12, 12"),
	[18] = split("51, 9, 12, 12"),
	[19] = split("63, 9, 12, 12"),
	[20] = split("75, 10, 10, 14"),
	[21] = split("60, 21, 8, 9"),
	[22] = split("85, 11, 10, 9"),
	[23] = split("68, 21, 8, 8"),
	[24] = split("114, 11, 14, 13"),
	[25] = split("0, 19, 14, 13"),
	[26] = split("29, 22, 10, 8"),
	[27] = split("99, 12, 14, 13"),
	[28] = split("40, 21, 8, 11"),
	[29] = split("48, 21, 12, 10"),
	[30] = split("84, 20, 14, 12"),
	[31] = split("1, 49, 14, 14"),
}

set_clrcount = function()
	game_clrcount = 0
	game_totalsteps = 0
	for i=1, 31 do
		if dget(i) > 0 then
			game_clrcount += 1
			game_totalsteps += dget(i)
		end
	end
	if game_clrcount >= 31 and game_totalsteps <= 1600 then
		popup_set"36"
	end
end

function select_start()
	if boss_life ==0 then
		game_mode = "achievements"
		music"8"
		return
	end

	game_mode, game_level_max = "select", 1
	set_clrcount()

	snow_particles_init(game_clrcount)

	if dget"10"==0 then
		game_level_max = game_clrcount < 8 and 9 or 10
	elseif dget"20"==0 then
		game_level_max = game_clrcount < 16 and 19 or 20
	elseif dget"30"==0 then
		game_level_max = game_clrcount < 24 and 29 or 30
	elseif dget"30">=1 then
		game_level_max = 31
	end
	music"5"
end

function delete_save()
	game_pose = true
end

function retry()
	if game_mode == "playing" then level_start() end
end

function level_start(start_flag)
	if start_flag==1 then
		if game_level%10==0 and dget(game_level) == 0  then
			game_mode = "event"
			event_timer = 80
			music"-1"
			poke(0x5f2c,3)
			return
		end
	end
	-- level_repair ------------------------------------------
	if level_celw then
		for i=1, level_celw, 1 do
			for j=1, level_celh, 1 do
				mset(i-1+level_celx, j-1+level_cely, level_initial_mapdata[i][j])
			end
		end
	end
	-- player_init ------------------------------------------
	player_x, player_y, player_dx, player_dy, player_dlr, player_dud, player_f, player_drc_pre, player_wait, player_state, player_down
	= 64, 64, 0, 0, 1, 0, 0, 2, 0, "start", false
	player_int_x, player_int_y, player_dstx, player_dsty
	= player_x, player_y, player_x, player_y
	
	-- object_new -------------------------------------------
	object_x, object_y, object_int_x, object_int_y, object_src_x, object_src_y, object_dlr, object_dud, object_state, object_timer, object_is_ice
	= 0, 0, 0, 0, 0, 0, 1, 1, "hidden", 0, true

	level_actcount, popup_timer,  boss_offset= 0, 0, 3, 0

	-- level_new ----------------------------------------------
	local lvdata = leveldata[game_level]
	level_celx, level_cely, level_celw, level_celh = lvdata[1], lvdata[2],lvdata[3],lvdata[4]
	level_offsetx, level_offsety, level_undoable
	= 64-4*level_celw + level_celw%2*4, 64-4*level_celh + level_celh%2*4, not is_boss(game_level)

	-- level start -------------------------------------------
	level_initial_mapdata = {}
	for i=1, level_celw, 1 do
		level_initial_mapdata[i] = {}
		for j=1, level_celh, 1 do
			level_initial_mapdata[i][j] = mget(data2cel_x(i), data2cel_y(j))
		end
	end
	level_initial_mapdata.start_celx, level_initial_mapdata.start_cely = 0, 0

	-- retry ------------------------------------------------
	game_mode, new_best, level_complete = "playing", false, false
	snow_particles_init(game_level)
	local dc = 0
	for j=1, level_celh, 1 do
		for i=1, level_celw, 1 do
			local tmp_spr = level_initial_mapdata[i][j]
			if tmp_spr == 1 then
				-- start point
				player_x, player_y, level_initial_mapdata.start_celx, level_initial_mapdata.start_cely
				= (i-1-level_celx+level_celx)*8+level_offsetx, (j-1-level_cely+level_cely)*8+level_offsety, i, j
				-- player_position_reset
				player_dx, player_dx, player_dlr, player_dud, player_f, player_drc_pre
				= 0, 0, 1, 0, 0, 2
			   player_int_x, player_int_y, player_dstx, player_dsty
			   = player_x, player_y, player_x, player_y
				tmp_spr = 2
			elseif tmp_spr == 3 or tmp_spr == 14 or (tmp_spr >= 7 and tmp_spr <= 10) then
				dc += 1
				local d = tmp_spr == 3 and 0 or tmp_spr == 7 and 1 or tmp_spr == 8 and 2 or tmp_spr == 9 and 3 or tmp_spr == 10 and 4 or tmp_spr == 14 and 5
				local px_x, px_y = data2px_x(i), data2px_y(j)
				devil[dc] = {}
				local cdevil = devil[dc]
				cdevil.x, cdevil.y, cdevil.int_x, cdevil.int_y, cdevil.intf_x, cdevil.intf_y
				= px_x, px_y, px_x, px_y, px_x, px_y
				
				cdevil.dlr, cdevil.dud, cdevil.state, cdevil.type, cdevil.wait
				 = d==2 and 1 or d==4 and -1 or 0, d==1 and -1 or d==3 and 1 or 0, (d==0 or d==5) and "fixed" or "moving", d==0 and "bon" or (d==3 or d==4) and "bili" or d==5 and "boss" or "eye", 0

				if d == 5 then
					boss_x, boss_y, boss_life, boss_offset =  px_x, px_y, 3, 0.4
				end
				if tmp_spr >= 7 and tmp_spr <= 10 then
					tmp_spr = 2
				end
			end
			mset(i-1+level_celx, j-1+level_cely, tmp_spr)
		end
	end
	level_enemycount, game_enemycount, player_state, player_wait, player_down, undostack.index, boss_life, boss_timer
	= dc, dc, "start", 24, false, 0, 3, 180
	
	music((game_level == 10 or game_level == 20 or game_level == 30 or game_level == 31) and 2 or game_level >= 21 and 6 or game_level >= 11 and 12 or 0)
	sfx"6"
end

menuitem(1, "retry", retry)
menuitem(2, "select level", select_start)
menuitem(3, "delete save data", delete_save)


-- devil
devil = {}

devil_collition = function(x, y, dlr, dud, src_flag, dst_flag, bon_flag)
	-- mode=0:kirisute, mode=1:kiriage, mode=2:obj ni atariyasu  mode=3:spirit no mawari,
	-- src_flag is true: sx,y -> kirisute
	-- dst_flag is true: dx,y -> ushiro mo ataru
	-- bon_flag is true: only bon returns value
	if player_state == "miss" or player_state == "falling" or player_down == true then
		return 0
	end
	
	local sx, sy = 0, 0
	if src_flag then --default is kirisute
		sx, sy = px2intf(x, dlr), px2intf(y, dud) --kiriage
	else
		sx, sy = px2int(x, dlr), px2int(y, dud) --kirisute
	end
	for i=1, level_enemycount, 1 do
		local dv = devil[i]
		if dv.state != "dead" then
			if px2int(dv.x, dlr, true) == sx and px2int(dv.y, dud, true) == sy then
				if bon_flag then
					if dv.type == "bon" then return i end
				else
					return i
				end
			else
				if dst_flag then
					if px2intf(dv.x, dlr, true) == sx and px2intf(dv.y,dud, true) == sy then
						return i
					end
				end
			end
		end
	end
	return 0
end


-- player
ice_remove = function(target_cel_x, target_cel_y, reset_flag)
	local tmp_spr = level_initial_mapdata[target_cel_x+1][target_cel_y+1]
	if
		tmp_spr == 3 or tmp_spr ==1 or  tmp_spr ==7 or tmp_spr ==8 or tmp_spr ==9 or tmp_spr ==10 or tmp_spr == 32 or
		fget(tmp_spr, 6)
		or is_stoneblockf(tmp_spr)
	then
		tmp_spr = 2
	end
	mset(target_cel_x+level_celx, target_cel_y+level_cely, tmp_spr)
	sfx"1"
	if reset_flag then iceblock_reset() end
end

--function flag2ffint(f1, f2, f3, f4)	
--	local a = 0
--	if f1 then a+=1 end
--	if f2 then a+=2 end
--	if f3 then a+=4 end
--	if f4 then a+=8 end
--	return a
--end

function get_ffint(cel_x, cel_y)
	local a = 0
	if cel_y - level_cely >0 and fget(mget(cel_x, cel_y-1), 3) then
		a += 1
	end
	if cel_x - level_celx < level_celw and fget(mget(cel_x+1, cel_y), 4) then
		a += 2 
	end
	if cel_y - level_cely < level_celh and fget(mget(cel_x, cel_y+1), 1) then
		a += 4
	end
	if cel_x - level_celx >0 and fget(mget(cel_x-1, cel_y), 2) then
		a += 8
	end
	return a
end



--
-- util
--

function is_boss(n)
	if n%10 == 0 or n == 31 then
			return true
	end
	return false
end


function collition0(x,y,dlr,dud,flag,round_flag)
	return fget(mget(px2cel_x(px2int(x,dlr,round_flag)),px2cel_y(px2int(y,dud,round_flag))),flag)
end

function collition1(x,y,dlr,dud,flag)
	return fget(mget(px2cel_x(px2intf(x,dlr)),px2cel_y(px2intf(y,dud))),flag)
end

function collition0_spr(x,y,dlr,dud,spr,round_flag)
	return spr == mget(px2cel_x(px2int(x,dlr,round_flag)),px2cel_y(px2int(y,dud,round_flag)))
end

function collition1_spr(x,y,dlr,dud,spr)
	return spr == mget(px2cel_x(px2intf(x,dlr)),px2cel_y(px2intf(y,dud)))
end


function is_iceblock(cel_x, cel_y)
	return fget(mget(cel_x+level_celx, cel_y+level_cely),6)
end

function is_stoneblock(cel_x, cel_y)
	return mget(cel_x, cel_y) == 32
end

function is_stoneblockf(spr)
	return spr==32
end

function px2cel_x(px_x)
	return (px_x-level_offsetx)/8+level_celx
end

function px2cel_y(px_y)
	return (px_y-level_offsety)/8+level_cely
end


--function cel2px_x(cel_x)
--	return (cel_x+level_celx)*8+level_offsetx
--end

--function cel2px_y(cel_y)
--	return (cel_y+level_cely)*8+level_offsety
--end


function data2cel_x(data_x)
	return data_x-1+level_celx
end

function data2cel_y(data_y)
	return data_y-1+level_cely
end

function data2px_x(data_x)
	return (data_x-1)*8+level_offsetx
end

function data2px_y(data_y)
	return (data_y-1)*8+level_offsety
end

--function px2data_x(px_x)
--	return (px_x-level_offsetx)/8+1
--end

--function px2data_y(px_y)
--	return (px_y-level_offsety)/8+1
--end

function px2int(xy, d, flag)
	-- kirisute
	-- flag is shisyagonyu
	return sgn(d) * flr(sgn(d) * (xy+(flag and sgn(d) *4 or 0))/8)*8
end

function px2intf(xy, d, flag)
	-- kiriage
	-- "f" means "mae"
	return -1*sgn(d) * flr(-1*sgn(d) * (xy-(flag and sgn(d) *4 or 0))/8)*8
end

popup_set = function(n)
	if dget(n)==0 then
		dset(n, 1)
		sfx"56"
		popup_timer = 70
	end
end

popup_draw = function(n, s)
	if dget(n)==1 and popup_timer > 0 then
		printc(s, 126+max((popup_timer-50)*4, 0), 26, 7, 1, 2, 0, 13, 3)
	elseif dget(n)==1 and popup_timer <=0 then 
		dset(n, 2)
	end
end

rectb = function(x0, y0, x1, y1, col0, col1)
	rectfill(x0, y0, x1, y1, col0)
	rect(x0, y0, x1, y1, col1)
end


function iceblock_reset()
	iceblock_count = 0
	--1 ice gen de okasii kasho wo shusei
	for j=0, level_celh-1, 1 do
		for i=0, level_celw-1, 1 do
			local lx, ly = i+level_celx, j+level_cely
			if is_iceblock(i, j) then
				iceblock_count += 1
				local current_spr = mget(lx, ly)
				local f1, f2, f3, f4
				= fget(current_spr, 1), fget(current_spr, 2), fget(current_spr, 3), fget(current_spr, 4)
				if f1 then
					if fget(mget(lx, ly-1), 0) == false then f1 = false end
				end
				if f2 then
					if fget(mget(lx+1, ly), 0) == false then f2 = false end
				end
				if f3 then
					if fget(mget(lx, ly+1), 0) == false then f3 = false end
				end
				if f4 then
					if fget(mget(lx-1, ly), 0) == false then f4 = false end
				end
				mset(lx, ly, flag_to_iceblock(f1, f2, f3, f4))
			end
		end
	end
	if iceblock_count >= 30 then
		popup_set"32"
	end

	--2 iceblock no migi shita no kage wo shusei
	for j=0, level_celh-1, 1 do
		for i=0, level_celw-1, 1 do
			local lx, ly = i+level_celx, j+level_cely
			local current_spr = mget(lx, ly)
			if is_iceblock(i, j) then
				
				local next_spr = mget(i+1+level_celx, ly)
				if
					current_spr == 8 or current_spr ==25 or 
					current_spr == 39 or current_spr ==56 or
					current_spr == 50 or current_spr == 51 or 
					current_spr == 58 or current_spr == 59
				then	
					if
						next_spr == 10 or next_spr == 25 or
						next_spr == 42 or next_spr == 56 or
						next_spr == 56 or next_spr == 59 or
						next_spr == 57 or next_spr == 58
					then
						if current_spr == 8  then mset(lx, ly, 11) end
						if current_spr == 25 then mset(lx, ly, 12) end
						if current_spr == 39 then mset(lx, ly, 43) end
						if current_spr == 56 then mset(lx, ly, 59) end
						if
							current_spr == 50 or
							current_spr == 51 or
							current_spr == 58 or
							current_spr == 59 
						then
							mset(lx, ly, current_spr-16)
							
						end
					end
				end
			end
		end
	end
end

function flag_to_iceblock(f1, f2, f3, f4)
	local a = 48
	if f1 then a+=1  end
	if f2 then a+=2  end
	if f3 then a+=4  end
	if f4 then a+=8  end
	return a
end

function printc(s, x, y, c1, c2, align, wide_char_num, bgc, icon)
	-- align=1 : center
	-- align=2 : left
	-- icon-1 : level complete
	-- icon-2 : new best
	-- icon-3 : achievements
	if not wide_char_num then wide_char_num=0 end
	if align == 1 then
		x += 64 - (#tostring(s) + wide_char_num)*2
	elseif align == 2 then
		x -= (#tostring(s) + wide_char_num)*4
	end
	if bgc then
		rectb(x-14,y-3,#tostring(s)*4+x+4,y+7, bgc, 1)
		spr(icon==1 and 164 or icon==2 and 150 or icon==3 and 149, x-11, y-2)
		--spr(111, x-11, y-2)
	end
	if c2 then
		for y1=-1,1 do
			for x1=-1,1 do
				print(s,x+x1,y+y1,c2)
			end
		end
	end
	print(s,x,y,c1)
end

-- 
-- undo
--
undostack = {
	push = function(self)
		local is_same = true
		self.index += 1
		
		if undostack.index == 400 then
			popup_set"34"
		end	

		local index = self.index
		self[index] = {}
		self[index].player_drc, self[index].player_x, self[index].player_y, self[index].player_dlr, self[index].player_dud
		 = player_drc_pre, px2int(player_x, player_dlr), px2int(player_y, player_dud), player_dlr, player_dud

		if index>1 then
			if self[index].player_x != self[index-1].player_x or self[index].player_y != self[index-1].player_y then
				is_same = false
			end
		end

		self[index].mapdata = {}
		for i=1, level_celw, 1 do
			self[index].mapdata[i] = {}
			for j=1, level_celh, 1 do
				self[index].mapdata[i][j] = mget(i-1+level_celx, j-1+level_cely)
				if index > 1 then
					if tmp_spr != self[index-1].mapdata[i][j] then
						is_same = false
					end
				end
			end
		end

		if is_same and index >1 then
			self.index -= 1
			--if self.index <1 then self.index = 1 end
		end
		
	end,
	pop = function(self)
		local index = self.index
		if index <1 then return end
		for i=1, level_celw, 1 do
			for j=1, level_celh, 1 do
				mset(i-1+level_celx, j-1+level_cely, self[index].mapdata[i][j])
			end
		end
		player_x, player_y, player_drc_pre, player_dud, player_dlr, player_dx, player_dy, player_f
		 = self[index].player_x, self[index].player_y, self[index].player_drc, self[index].player_dud, self[index].player_dlr, 0, 0, 0
		player_dstx, player_dsty, player_int_x, player_int_y = player_x, player_y, player_x, player_y
		if index >0 then self.index -= 1 end
		sfx"7"
	end,
}

--
-- main 
--

function _init()
	--pal(8, 131, 1) --palet color change
	--pal(3, 140, 1) --palet color change
	--pal(14, 143, 1) --palet color change
	--memcpy(24576,0,8192)
	--repeat until forever
	if dget(0) != 1 then
		for i=1, 64, 1 do
			dset(i,0)
		end
	end
	dset(0, 1)
	set_clrcount()
	snow_particles_init(game_clrcount)
	pal(14, 131, 1) --palet color change
end

function _update()	
	-- game_update ----------------------------------------------

	if not game_pose then
		game_fcount += 1
		if game_fcount>32000 then 
			game_fcount = 0
		end
		game_quake -= 1
		if game_quake <0 then
			game_quake = 0
		end
	end

	if game_pose then
		if btn"5" then
			for i=1, 64, 1 do
				dset(i,0)
			end
			game_level = 1
			game_pose = false
			select_start()
		elseif btnp"4" then
			game_pose = false
		end	
	elseif game_mode == "title" then
		-- title_update -----------------------------------------
		if btnp"5" or btnp"4" then -- x, o
			select_start()
		end
	elseif game_mode == "select" then
		poke(0x5f2c,0)
		-- select_update -----------------------------------------
		if btnp"5" then -- x
			level_start(1)
		elseif btnp"4" then -- o
			game_mode = "achievements"
		elseif btnp"0"  then -- <
			if game_level != 31 then
				game_level -= 10
				if game_level <= 0 then
					game_level += 30
					while game_level > game_level_max do 
						game_level -= 10
					end
				end
			end
		elseif btnp"1" then -- >
			if game_level != 31 then
				game_level += 10
				if game_level > game_level_max then
					game_level -= 30
					while game_level <1 do
						game_level += 10
					end
				end
			end
		elseif btnp"2" then -- ^
			game_level += 1
			if game_level>game_level_max then
				game_level = 1
			end
		elseif btnp"3" then -- v
			game_level -= 1
			if game_level<=0 then
				game_level = game_level_max
			end
		end
	elseif game_mode == "playing" then
		popup_timer -= 1
		if popup_timer <= 0 then popup_timer = 0 end
		if undopopflag then
			undopopflag = false
			undostack:pop()
		end
		if object_state != "moving" then
			-- devil_update
			local move_ok = not(player_down or player_state == "falling" or player_state =="miss" or player_state =="clear" or boss_life == 0)
			for i=1, level_enemycount, 1 do
				local dv, ac = devil[i], 0.6
				if dv.type == "bili" then ac = 0.9 end
				if dv.state != "dead" then	
						
					if dv.state == "fixed" then
						if mget(px2cel_x(dv.x), px2cel_y(dv.y))==2 then dv.state="dead" end
					elseif dv.wait>0 then
						dv.wait -= 1 
					else
						-- move forward
						if move_ok then
							dv.x += ac * dv.dlr
							dv.y += ac * dv.dud
						end 
						if  dv.x < -8 or dv.x > 136 then
							popup_set"35"
						end
						dv.int_x, dv.int_y, dv.intf_x, dv.intf_y = px2int(dv.x, dv.dlr), px2int(dv.y, dv.dud), px2intf(dv.x, dv.dlr), px2intf(dv.y, dv.dud)
						
						if dv.type == "eye" then
							dv.state="moving"
							if collition1(dv.x, dv.y, dv.dlr, dv.dud, 0)then
								dv.x, dv.y, dv.state, dv.wait
								= dv.int_x, dv.int_y, "turn", 20
								dv.dlr *= -1
								dv.dud *= -1
							end
						end
		
						if dv.type == "bili" then
							-- migi-te gawa no kabe
							local kabe_lr, kabe_ud,  mae_lr, mae_ud
									= -1*dv.dud, dv.dlr, dv.dud, -1*dv.dlr
							if dv.state == "turn" and
								collition0(dv.x+8*kabe_lr-ac*dv.dlr, dv.y+8*kabe_ud-ac*dv.dud, dv.dlr, dv.dud, 0)
								or collition0_spr(dv.x+8*kabe_lr-ac*dv.dlr, dv.y+8*kabe_ud-ac*dv.dud, dv.dlr, dv.dud, 14)
							then
								dv.state = "moving"
		
							elseif
								-- migi ushironi kabe ga nakunattara "turn"
								dv.state == "moving" and
								not (
									collition0(dv.x+8*kabe_lr, dv.y+8*kabe_ud, dv.dlr, dv.dud, 0) -- flag 0: kabe
								or	collition0_spr(dv.x+8*kabe_lr, dv.y+8*kabe_ud, dv.dlr, dv.dud, 14) -- 14 is Boos no yuka
								)
							then
								-- soto-kado
								dv.state, dv.dlr, dv.dud, dv.x, dv.y
								= "turn", kabe_lr, kabe_ud, dv.int_x, dv.int_y
							elseif
								collition1(dv.x-0.9*dv.dlr, dv.y-0.9*dv.dud, dv.dlr, dv.dud, 0)
								or collition1_spr(dv.x-0.9*dv.dlr, dv.y-0.9*dv.dud, dv.dlr, dv.dud, 14)
							then
								--mae-kabe
								dv.state, dv.dlr, dv.dud, dv.x, dv.y
								= "turn", mae_lr, mae_ud, dv.int_x, dv.int_y
							end
						end
					end
				else
					if mget(px2cel_x(dv.x), px2cel_y(dv.y))==3 then
						dv.state="fixed"
					end
				end
			end
			if game_level ==31 and (move_ok or boss_timer<8) then
				if boss_timer > 0 then
					boss_timer -=1
				else
					boss_timer = 180
				end
				if boss_timer >= 70 then
					boss_atack_x = px2int(player_x, player_dlr)
					boss_atack_y = px2int(player_y, player_dud)
				end
				if boss_timer == 50 then
					sfx"53"
				end
				if boss_timer ==9 then
					game_quake =4
					steam_particles_init(boss_atack_x+1, boss_atack_y+2, 0, -1)
					local tx, ty = (boss_atack_x-level_offsetx)/8, (boss_atack_y-level_offsety)/8
					if is_iceblock(tx, ty) then
						ice_remove(tx, ty,true)
					end
					sfx"52"
				end
			end
		end
		-- player_update
		player_update()

		-- object_update
		if object_state != "moving" then
			object_src_x, object_src_y = object_x, object_y
		end
		object_timer-=1
		if object_timer<=0 then
			object_timer=0
		end			
		local obj_dlr, obj_dud = object_dlr, object_dud
		if object_state == "moving" then
			object_x += obj_dlr * 2
			object_y += obj_dud * 2
			local dvcol = devil_collition(object_x, object_y, obj_dlr, obj_dud, false, true)
			object_int_x, object_int_y = px2int(object_x, obj_dlr), px2int(object_y, obj_dud)
			if collition0_spr(object_x, object_y, obj_dlr, obj_dud, 14) then
				object_state = "steam"
				sfx"13"
				steam_particles_init(object_x, object_y, object_dlr, object_dud)
				player_wait, boss_wait = 0, 20
				boss_life -= 1
				if boss_life == 0 then
					player_wait += 30
				end
				return
			end
			if dvcol >0 then
				if devil[dvcol].type == "bili" then
					object_state = "steam"
					sfx"12"
					steam_particles_init(object_x, object_y, object_dlr, object_dud)
					player_wait = 0
				else 
					-- teki taosu
					object_state, object_x, object_y, player_wait, object_timer
					= "steam", object_int_x, object_int_y, 0, 12
					if abs(object_x - player_x)/8 >=10 or abs(object_y - player_y)/8 >=10 and  dget"33"==0 then
						popup_set(33, 1)
					end
					if object_is_ice then
						if devil[dvcol].state == "fixed" then
							mset(px2cel_x(object_int_x), px2cel_y(object_int_y), 2)
						end
					else
						--stone
						mset(px2cel_x(object_int_x), px2cel_y(object_int_y), 32)
					end
					devil[dvcol].state = "dead"
					sfx(3, 3)
					steam_particles_init(object_x, object_y, object_dlr, object_dud)
				end
				
			elseif collition0_spr(object_x, object_y, obj_dlr, obj_dud, 11) or collition0_spr(object_x, object_y, obj_dlr, obj_dud, 12) then
				-- ana ni ochiru
				object_state, object_x, object_y, player_wait, object_timer
				= "falling", object_int_x, object_int_y, 0, 12
				sfx"9"
				
			elseif object_x%8==0 and object_y%8==0 and mget(px2cel_x(object_x), px2cel_y(object_y))==5 then
				object_state, object_x, object_y, player_wait
				= "hidden", object_int_x, object_int_y, 0
				if object_is_ice then 
					mset(px2cel_x(object_int_x), px2cel_y(object_int_y), 48)
				else
					mset(px2cel_x(object_int_x), px2cel_y(object_int_y), 32)
				end
				
			elseif(collition1(object_x, object_y, obj_dlr, obj_dud, 0))
			or (object_is_ice == false
			and (
				(object_dlr*object_x-object_dlr*object_src_x)>=8
				or (object_dud*object_y-object_dud*object_src_y)>=8
			))
	
			then
				-- kabe ni butukaru
				object_state, player_wait = "hidden", 0
				mset(px2cel_x(object_int_x), px2cel_y(object_int_y), object_is_ice and 48 or 32)
			end
		end
		-- stage_update -----------------------------------------
		for j=1, level_celh, 1 do
			for i=1, level_celw, 1 do
				local mx, my = data2cel_x(i), data2cel_y(j)
				if mget(mx, my)==71 then
					if (i!=(px2int(player_x,player_dlr)-level_offsetx)/8+1 or j!=(px2int(player_y,player_dud)-level_offsety)/8+1) and player_state != "start" then
						sfx"10"
						local snum = mget(mx, my-1)==11 and 12 or 11
						mset(mx, my, snum)
					end
				end
				if mget(mx, my)==11 and (mget(mx, my-1)==12 or mget(mx, my-1)==11) then
					mset(mx, my, 12)
				end
			end
		end
	elseif game_mode == "event" then
		-- event_update
		event_timer -= 1
		if event_timer <= 0 then
			poke(0x5f2c,0)
			level_start()
		end
	elseif game_mode == "achievements" then
		-- result_update ---------------------------------
		if btnp"5" or btnp"4" then
			boss_life = 3
			select_start()
		end
	end
end

player_update = function()
	player_int_x, player_int_y = px2int(player_x, player_dlr), px2int(player_y, player_dud)
	-- wait check
	player_wait -= 1
	if player_wait <0 then player_wait = 0 end
	if player_wait == 0 then
		if boss_life ==0 then
			game_enemycount = 0
		end
		if player_state == "clear" then
			-- level_clear ---------------------------------
			if game_clrcount != 31 then
				game_level = 1
				for i=31, 1, -1 do
					if dget(i)==0 then
						game_level = i
					end
				end
			end
			select_start()
		elseif game_enemycount <= 0 then
			player_state, player_wait = "clear", 70
			music"-1"
			if dget(game_level) == 0 then 
				level_complete = true
				sfx"56"
			end
			local best_steps, new_steps = dget(game_level), undostack.index
			if best_steps > 1 and best_steps <= new_steps then
				new_steps = best_steps
			else
				sfx"56"
				new_best = true
			end
			dset(game_level, new_steps)
			set_clrcount()
		elseif player_state == "miss" or player_state == "falling" then
			player_state = "idle"
			if level_undoable then
				undopopflag = true
			else
				player_down = true
			end
			return
		else
			player_state = "idle"
		end
	else
		if player_state == "start" or player_state == "clear"  then
			return
		end
	end

	-- position map flag check
	if(	player_down )then

	elseif collition0_spr(player_x, player_y, player_dlr, player_dud, 6) then
		sfx"11"
		mset(px2cel_x(player_x), px2cel_y(player_y),71)
	elseif
		player_state != "miss" and
		(devil_collition(player_int_x, player_int_y, player_dlr, player_dud)>0
		or (boss_timer < 8 and player_int_x == boss_atack_x and player_int_y == boss_atack_y))
	then
		player_state, player_wait, player_magic_ready = "miss", 12, false
		sfx"5"
		return
	elseif 
		player_state != "falling" and player_state != "miss"
		and (collition0_spr(player_x, player_y, player_dlr, player_dud, 11) or collition0_spr(player_x, player_y, player_dlr, player_dud, 12))
	then
		-- ana ni ochiru
		player_state, player_wait = "falling", 12
		sfx"9"
		return
	end

	-- input check
	if player_state == "idle" then
		player_x, player_y, player_dstx, player_dsty, player_dx, player_dy
		= player_int_x, player_int_y, player_int_x, player_int_y, 0, 0
		
		-- 4:O 5:X
		if player_wait ==0 then
			if player_down then
				if btn"5" then -- x
					level_start()
				elseif btn"4" then -- O
					select_start()
				end
			else
				if btn"5"  and undostack.index<800 then --X
					player_magic_ready = true
					if btn"0" then -- <
						player_dlr, player_dud, player_drc_pre = -1, 0, 4
					elseif btn"1" then -- >
						player_dlr, player_dud, player_drc_pre = 1, 0, 2
					elseif btn"2" then -- ^
						player_dud, player_dlr, player_drc_pre = -1, 0, 1
					elseif btn"3" then -- v
						player_dud, player_dlr, player_drc_pre = 1, 0, 3
					end
				elseif btnp"4" and level_undoable then -- O
					-- undo
						player_press_undo, undopopflag, player_down = true, true, false
					return
				elseif player_down == false and undostack.index<800 then
					player_press_undo = false
					if player_magic_ready then
						player_magic_ready, player_state = false, "magic"
						if player_wait ==0 then player_wait +=12 end
					elseif btn"0" then -- <
						player_dx-=1.3
						player_dstx-=8
						player_dlr, player_dud, player_drc_pre=-1, 0, 4
					elseif btn"1" then -- >
						player_dx+=1.3
						player_dstx+=8
						player_dlr, player_dud, player_drc_pre=1, 0, 2
					elseif btn"2" then --^
						player_dy-=1.3
						player_dsty-=8					
						player_dud, player_dlr, player_drc_pre=-1, 0, 1
					elseif btn"3" then -- v
						player_dy+=1.3
						player_dsty+=8
						player_dud, player_dlr, player_drc_pre=1, 0, 3
					end
				end
			end
		end
	end

	-- move
	player_x += player_dx
	player_y += player_dy

	-- collition
	if collition1(player_x, player_y, player_dlr, player_dud, 0) then
		local xx = player_drc_pre == 2 and 8 or player_drc_pre == 4 and -8 or 0
		local yy = player_drc_pre == 1 and -8 or player_drc_pre == 3 and 8 or 0

		if player_state == "idle"
			and  (collition0_spr(player_int_x+xx, player_int_y+yy, player_dlr, player_dud, 48)
			or collition0_spr(player_int_x+xx, player_int_y+yy, player_dlr, player_dud, 32))
			and not(collition0(player_int_x+2*xx, player_int_y+2*yy, player_dlr, player_dud)
			or collition0(player_int_x+2*xx, player_int_y+2*yy, player_dlr, player_dud))
		then
			player_state = "kick"
			undostack:push()
			if player_wait ==0 then player_wait +=8 end
		end
		player_x, player_y, player_dx, player_dy
		= px2int(player_x, player_dlr), px2int(player_y, player_dud), 0, 0
		player_dstx, player_dsty = player_x, player_y
	end

	-- dst ni tsuitaka douka
	if
		player_dstx*player_dlr - player_x*player_dlr <=0 and
		player_dsty*player_dud - player_y*player_dud <=0
	then
		-- tsuitenai
		if player_dlr !=0 then player_x = player_dlr * flr(player_dlr * (player_x)/8)*8 end
		if player_dud !=0 then player_y = player_dud * flr(player_dud * (player_y)/8)*8 end
		player_dstx, player_dsty, player_dx, player_dy
		= player_x, player_y, 0, 0
		if player_wait ==0 and player_state != "continue" and player_state then
			player_state = "idle"
		end
	else
		-- tsuita
		if player_state == "idle" then
			undostack:push()
		end
		if player_state != "miss" then
			player_state, player_wait = "moving", 2
		end
	end

	-- for wark spr
	spd = sqrt(player_dx*player_dx+player_dy*player_dy)
	player_f = (player_f+spd*2)%2
	if spd<0.05 then player_f=0 end

	-- ice gen/remove
	local xx = player_drc_pre == 2 and 8 or player_drc_pre == 4 and -8 or 0
	local yy = player_drc_pre == 1 and -8 or player_drc_pre == 3 and 8 or 0
	
	if player_state == "magic" and player_wait == 2 then
		local target_cel_x, target_cel_y = (player_x+xx-level_offsetx)/8, (player_y+yy-level_offsety)/8
		-- ice gen dekiru ka?
		if	-- kabe no toki, spirit no toki.
			collition1(player_x+player_dlr*8, player_y+player_dud*8, player_dlr, player_dud, 7) or
			mget(px2cel_x(player_x)+player_dlr, px2cel_y(player_y)+player_dud) == 11 or
			mget(px2cel_x(player_x)+player_dlr, px2cel_y(player_y)+player_dud) == 12 or
			mget(px2cel_x(player_x)+player_dlr, px2cel_y(player_y)+player_dud) == 4 or
			mget(px2cel_x(player_x)+player_dlr, px2cel_y(player_y)+player_dud) == 5 or
			devil_collition(player_x+player_dlr*8, player_y+player_dud*8, player_dlr, player_dud) > 0 or
			is_stoneblock(px2cel_x(player_x)+player_dlr, px2cel_y(player_y)+player_dud)
		then
			-- ice gen shippai
			sfx"4"
		else
			-- ice gen/remove seikou
			if is_iceblock(target_cel_x, target_cel_y ) then
				-- ice remove
				undostack:push()
				ice_remove(target_cel_x, target_cel_y)
			elseif
				-- spirit no mawari ha dame
				devil_collition(player_x+player_dlr*8, player_y+player_dud*8-8, player_dlr, player_dud, true, false, true)>0 or
				devil_collition(player_x+player_dlr*8+8, player_y+player_dud*8, player_dlr, player_dud, true, false, true)>0 or
				devil_collition(player_x+player_dlr*8, player_y+player_dud*8+8, player_dlr, player_dud, true, false, true)>0 or
				devil_collition(player_x+player_dlr*8-8, player_y+player_dud*8, player_dlr, player_dud, true, false, true)>0
			then
				-- ice gen shippai
				sfx"4"
			else
				undostack:push()
				-- ice gen
				local next1, next2, next3, next4
				= mget(target_cel_x+level_celx, target_cel_y-1+level_cely),
				mget(target_cel_x+1+level_celx, target_cel_y+level_cely),
				mget(target_cel_x+level_celx, target_cel_y+1+level_cely),
				mget(target_cel_x-1+level_celx, target_cel_y+level_cely)
				mset(target_cel_x+level_celx, target_cel_y+level_cely, flag_to_iceblock(fget(next1, 0), fget(next2, 0), fget(next3, 0), fget(next4, 0)))
				if fget(next1,6) then
					mset(target_cel_x+level_celx, target_cel_y-1+level_cely, flag_to_iceblock(fget(next1, 1), fget(next1, 2), true, fget(next1, 4)))
				end
				if fget(next2,6) then
					mset(target_cel_x+1+level_celx, target_cel_y+level_cely, flag_to_iceblock(fget(next2, 1), fget(next2, 2), fget(next2, 3), true))
				end
				if fget(next3,6) then
					mset(target_cel_x+level_celx, target_cel_y+1+level_cely, flag_to_iceblock(true, fget(next3, 2), fget(next3, 3), fget(next3, 4)))
				end
				if fget(next4,6) then
					mset(target_cel_x-1+level_celx, target_cel_y+level_cely, flag_to_iceblock(fget(next4, 1), true, fget(next4, 3), fget(next4, 4)))
				end
				sfx"0"
			end
		end
	end

	-- kick ice
	if player_state == "kick" and player_wait == 2 then
		local target_cel_x, target_cel_y = (player_x+xx-level_offsetx)/8, (player_y+yy-level_offsety)/8
		local target_spr = mget(target_cel_x+level_celx, target_cel_y+level_cely)
		if
			target_spr == 48
		then
			local tmp_spr = level_initial_mapdata[target_cel_x+1][target_cel_y+1]
			if
				tmp_spr==3 or tmp_spr==1 or tmp_spr==7 or tmp_spr==8 or tmp_spr==32 or 
				fget(tmp_spr, 6)
				or is_stoneblockf(tmp_spr) 
			then
				tmp_spr = 2
			end
			mset(target_cel_x+level_celx, target_cel_y+level_cely, tmp_spr)
			sfx"2"
			object_x, object_y, object_dlr, object_dud
			= player_x+xx, player_y+yy, sgn(xx), sgn(yy)
			if xx==0 then object_dlr = 0 end
			if yy==0 then object_dud = 0 end
			player_wait, player_state, object_state, object_is_ice
			= 60, "idle", "moving", true
		elseif
			-- stone nara
			target_spr == 32 and get_ffint(data2cel_x(target_cel_x+1), data2cel_y(target_cel_y+1)) == 0
		then
			local tmp_spr = level_initial_mapdata[target_cel_x+1][target_cel_y+1]
			if
				tmp_spr==3 or tmp_spr==1 or tmp_spr==7 or tmp_spr==8 or tmp_spr==32 or
				fget(tmp_spr, 6)
				or is_stoneblockf(tmp_spr) 
			then
				tmp_spr = 2
			end
			mset(target_cel_x+level_celx, target_cel_y+level_cely, tmp_spr)
			sfx"2"
			object_x, object_y, object_src_x, object_src_y, object_dlr, object_dud
			= player_x+xx, player_y+yy, player_x+xx, player_y+yy, sgn(xx), sgn(yy)
			if xx==0 then object_dlr = 0 end
			if yy==0 then object_dud = 0 end
			player_wait, player_state, object_state, object_is_ice = 60, "idle", "moving", false
		end
	end

	-- iceblock reset
	iceblock_reset()
end

function event_draw(way, devil)
	for i=1, way, 1 do
		if devil == "eye" then
			spr(event_timer >40 and 12 or 96+(game_fcount%12)/3, 14-(40-event_timer)+i*4, 32-(40-event_timer)*i/3.5, 1, 1, -1)
		elseif devil == "bili" and event_timer < 40 then
			circfill(16-(40-event_timer)*1.5+i*4, 32-(40-event_timer)*i/3, 2+game_fcount%7/3, game_fcount%8 > 3 and 9 or 10)
		end
	end
end

function bestcount_draw()
	printc("\^:492a3e3e3e000000    ACTS", 87, 3, 6, 0)
	printc(dget(game_level)<=1 and "---" or dget(game_level), 39, 3, 6, 0, 1)
end

function acv_col(d)
	return dget(d)>=1 and 7 or 5, 1
end

function _draw()
	camera(0, (game_fcount %24 == 0 and 1 or -1) * game_quake)


	if  game_pose then
		rectfill(0, 47, 127, 80, 9)
		printc("are you sure?", 0, 53, 10, 2, 1)
		printc("❎ delete\n\|i🅾️ cancel", 42, 62, 7, 0)
	elseif game_mode != "playing" and game_mode!="event"  then
		cls"0"
		map(96, 48, 0, 0, 32, 32)
		map(48, 56, 0, 68, 16, 8 ) --mountain
		snow_particles_draw()
		map(16, 48, 112, 64, 1, 8 ) --tower 2		
	
		if game_mode != "select" then
			rectfill(12, 28, 116, 50, 14)
			rect(13, 29, 115, 49, 0)
			map(48, 48, 0, -8, 16, 8 ) --block
			sspr(59,75,66,10,31,34) --title

			if game_mode == "achievements" then
				-- result_draw -----------------------------------------------------
				rectb(2, 5, 125, 124, 14, 0)
				if boss_life == 0 then
					printc("thanks for playing!", 0, 3, 10, 1, 1)
				else
					printc("achievements", 0, 3, 12, 1, 1)
				end
				print("there are 30 ice blocks\n\|phit an enemy 10 tiles away\n\|p400 actions (limit: 800)\n\|plead a ball off screen\n\|pcompleted all levels,\ntotal acts less than 1600",
				15, 19, 6)
				printc("full of ice", 15, 12, acv_col"32", 1)
				printc("long shot", 15, 27, acv_col"33", 1)
				printc("half of action limit", 15, 42, acv_col"34", 1)
				printc("bye!", 15, 57, acv_col"35", 1)
				printc("the seeker", 15, 72, acv_col"36", 1)
				printc("total acts: "..game_totalsteps, 124, 117, dget"36" ==0  and 1 or 9, false, 2)
				for i=0, 4 do
					spr(dget(32+i)>=1 and 149 or 148, 5, 11+i*15)
				end
				for j=0, 3 do
					for i=0, 9 do
						local di, dj, lvf = i*12, j*8, dget(i+1+j*10)
						if j == 3 and i==0 then
							if game_level_max < 31 then 
								break
							end
						end
						rectfill(4+di, 92+dj, 14+di, 98+dj, lvf==0 and 5 or 4)
						printc(lvf,di-54, 93+dj, lvf==0 and 5 or 9, false, 1)
						if i==9 or j==3 and i==0 then
							rectfill(15+di, 92+dj, 15+di, 98+dj, lvf==0 and 2 or 8)
							break
						end
					end
				end
			else
				printc("press ❎/🅾️ to start", 0, 80, game_fcount %24 >12 and 3 or 11, 0, 1, 2)
				--printc("v3", 1, 122, 6, 1)
			end
		else
			-- select_draw
			rectfill(3, 0, 54, 11, 13)
			print("select level", 6, 3, 7)
			local btn_x, btn_y, baloon_x, baloon_y, req_num  =-3, 30, -100, -100, 0
			for i = 1, 31, 1 do
				if i<31 or game_level_max == 31 then
					-- position
					if i%10==1 and i!=31 then
						btn_x+=15
						btn_y+=87
					else
						btn_x+=2
						btn_y-=10
					end

					-- style
					local bg_col, tx_col, locked = 6, 1, i > game_level_max and true or false -- default
					if game_level == i then
						bg_col, tx_col = 12, 7
					elseif game_level_max == i and is_boss(i) and dget"31"==0 then
						bg_col, tx_col = 9
					elseif locked then 
						bg_col, tx_col = 13, 13
					end
		
					-- button
					rectfill(btn_x-4, btn_y, btn_x+20, btn_y+8, bg_col)
					rectfill(btn_x-5, btn_y+1, btn_x+21, btn_y+7, bg_col)
		
					-- label
					printc(i, btn_x-55, btn_y+2, tx_col, false, 1)

					-- icon
					spr(dget(i)>0 and 111 or 110, btn_x-4, btn_y)
		
					if is_boss(i) then
						spr(126, btn_x+13, btn_y)
					end
					if locked then
						spr(125, btn_x+4, btn_y)
					end					
				end
			end
			bestcount_draw()
			
			printc("\x8e achievements", 124, 122, 6, 0, 2)	
		
			if game_level_max <= 9 then
				baloon_x, baloon_y, req_num = 28, 17, 8
			elseif game_level_max <= 19 and dget"10">0 then
				baloon_x, baloon_y, req_num = 61, 14, 16
			elseif game_level_max <=29 and dget"20">0 then
				baloon_x, baloon_y, req_num = 94, 11, 24
			end
			if req_num > 0 then
				sspr(0, 72, 32, 11, baloon_x-5, baloon_y)
				printc(game_clrcount, baloon_x+12, baloon_y+2, 1, false, 2)
				print(req_num, baloon_x+16, baloon_y+2, 1)
			end
		
			-- player position
			circfill(114+game_level%3, 120-game_level*1.7, 1+game_fcount%4/3, game_fcount%8 > 3  and 7 or 12)
		
			-- boss position
			local bp, angle = game_level_max<=10 and 10 or game_level_max<=20 and 20 or game_level_max<=30 and 30 or 31, game_fcount%60/60
			 
			circfill(117+sin( angle )*5, 120- bp *1.7+cos( angle )*2, 1+game_fcount%4/3+bp%10, game_fcount%8 > 3 and 9 or 8)
		end
	elseif game_mode == "event" then
		-- event_draw
		map(20, 56, 0, 0, 8, 8)
		circfill(34, 34, (event_timer-70)*3, 9)
		circ(34, 34, (event_timer-50)*2, 8)
		spr(event_timer >50 and 112 or event_timer >42 and 117 or 116, 32, 30)
		local way3, way5 = "eye", false
		if game_level == 10 then
			way3, way5 = "eye", false
		elseif game_level ==20 then
			way3, way5 = false, "eye"
		elseif game_level ==30 then
			way3, way5 = "eye", "bili"
		end
		event_draw(3, way3)
		event_draw(5, way5)
		if event_timer == 80 then
		for i=1, 3, 1 do
			spr(dn, 16-(40-event_timer)+i*4, 32-(40-event_timer)*i/3, 1, 1, -1)
		end
			sfx"53"
		elseif event_timer == 40 then
			sfx"52"
		    steam_particles_init(22, 30, 0, -1)
		end
		steam_particles_draw()		
	elseif game_mode == "playing" then
	
		cls(game_level >=21 and 1 or game_level >= 11 and 13 or 12)
		--forest and mountain
		map(112, 56, 0, game_level <= 3 and 96 or game_level <= 7 and 104 or game_level <=14 and 112 or game_level <= 19 and 120 or 128, 16, 4 )

		snow_particles_draw()		

		--tower gaikan
		map(112+level_offsetx/8, 60, level_offsetx, level_offsety+8*level_celh, level_celw, 16)

		--floor no shitaji
		rectfill(level_offsetx+8, level_offsety, level_offsetx+level_celw*8-8, level_offsety+level_celh*8-1,0)
		map(level_celx,	level_cely, level_offsetx, level_offsety, level_celw, level_celh)

		--draw_ff
		for j=1, level_celh, 1 do
			for i=1, level_celw, 1 do
				local cx, cy = data2cel_x(i), data2cel_y(j)
				local current_ffint, current_spr = get_ffint(cx, cy), mget(cx, cy)
				if fget(current_spr, 5) then
					if fget(mget(data2cel_x(i+1),cy), 7) then
						spr(64, data2px_x(i), data2px_y(j))				
					end
				end
				if fget(current_spr, 7) then
					if j!=1 and fget(mget(cx, data2cel_y(j-1)), 7)then
						spr(92, data2px_x(i), data2px_y(j))
					end
					if i!=level_celw and fget(mget(data2cel_x(i+1),cy), 7) then
						spr(93, data2px_x(i), data2px_y(j))				
					end
					if i!=1 and fget(mget(data2cel_x(i-1), cy), 7) then	
						spr(95, data2px_x(i), data2px_y(j))			
					end
					if j!=level_celh and fget(mget(cx, data2cel_y(j+1)), 7) then
						spr(94, data2px_x(i), data2px_y(j))
					end
				end
				if (fget(current_spr,7)) or (current_spr ==32) then
					local udf = false
					if current_ffint >= 8 then
						spr(79, data2px_x(i), data2px_y(j))
						current_ffint -= 8
					end
					if current_ffint >= 4 then
						spr(78, data2px_x(i), data2px_y(j))
						current_ffint -= 4
					end
					if current_ffint >= 2 then
						udf = true
						current_ffint -= 2
					end
					if current_ffint >= 1 then
						spr(76, data2px_x(i), data2px_y(j))
					end
					if udf then
						spr(77, data2px_x(i), data2px_y(j))
					end
				end
			end
		end

		--devil_draw
		game_enemycount = 0	
		for i=1, level_enemycount, 1 do 
			local dv = devil[i]
			local dvx, dvy = dv.x, dv.y
			if dv.state != "dead" then
				if dv.type != "bili" then
					game_enemycount += 1
				end
				if dv.type == "boss" and boss_life != 0  and player_state != "clear" then
					rectfill(dvx+(game_fcount+15)%60/60*2, dvy+5, dvx+7-(game_fcount+15)%60/60*2, dvy+7, 1)
				elseif dv.type == "eye" and dv.state == "turn" then
					spr(dv.wait > 15 and 100 or dv.wait > 10 and 101 or dv.wait >5 and 102 or 103, dvx, dvy, 1, 1, (dv.dlr==-1)or(dv.dud==-1))
				elseif dv.type == "bili" then
					circfill(dvx+4, dvy+4, 2+game_fcount%7/3, game_fcount%8 > 3 and 9 or 10)
				elseif dv.type == "eye" then
					spr(96+(game_fcount%12)/3, dvx, dvy, 1, 1, (dv.dlr==-1)or(dv.dud==-1))
				elseif dv.type == "bon" then
					spr(104+(game_fcount%12)/3, dvx, dvy, 1, 1)
				end
			end
		end

		--player_draw()
		local pllr_eq_minus_one = (player_dlr == -1)
		
		-- motion by player_state
		if player_down then
			--spr(91, player_x, player_y, 1, 1, pllr_eq_minus_one)
		elseif player_state == "start" then
			circfill(player_x+4, player_y+4, player_wait/3, 7)
			circ(player_x+4, player_y+4, player_wait/2, 12)
			spr(player_wait >= 18 and 75 or player_wait >6 and 74 or 84, player_x, player_y, 1, 1)
		elseif player_magic_ready == true then
			spr(83, player_x, player_y, 1, 1, pllr_eq_minus_one)
		elseif player_state == "magic" then
			spr(player_wait > 6 and 83 or 84, player_x, player_y, 1, 1, pllr_eq_minus_one)
		elseif player_state == "falling" then
			spr(player_wait > 6 and 89 or 90, player_x, player_y, 1,1)
		elseif player_state == "miss" then
			if player_wait ==12 then
				--miss_particles_init
				for i=1, 2 do
					for dir=0, 7 do
						local angle = (dir/8)
						add(
							miss_particles,{
								x = player_x+4,
								y = player_y+4,
								l = 15,
								spd_x = sin(angle)*0.9*i,
								spd_y = cos(angle)*0.9*i,
							}
						)
					end
				end
			end
		elseif player_state == "kick" then
			spr(player_wait > 4 and 85 or 86, player_x, player_y, 1, 1, pllr_eq_minus_one)
		elseif player_state =="clear" then
			spr(87+(game_fcount%18)/9, player_x, player_y, 1, 1, pllr_eq_minus_one)
			if(game_fcount%18)/9 ==1 then sfx"8" end
		else
			spr(81+player_f, player_x,player_y, 1,1,pllr_eq_minus_one)
		end
	
		local xx = player_drc_pre == 2 and 8 or player_drc_pre == 4 and -8 or 0
		local yy = player_drc_pre == 1 and -8 or player_drc_pre == 3 and 8 or 0
	
		-- magic effects
		if player_state == "magic" and player_wait >6 then
			spr(72, player_x+xx, player_y+yy, 1, 1)
		elseif player_state == "magic" and player_wait <=6 then
			spr(73, player_x+xx, player_y+yy, 1, 1)
		end
	
		-- target masu
		if player_state != "miss" and not player_down  then
			if player_magic_ready == true then
				if player_drc_pre != 1 then 
					sspr(0, 40, 4, 4, player_x+3, player_y-4)
				end
				if player_drc_pre != 2 then 
					sspr(4, 40, 4, 4, player_x+9, player_y+2)
				end
				if player_drc_pre != 3 then 
					sspr(4, 44, 4, 4, player_x+3, player_y+9)
				end
				if player_drc_pre != 4 then 
					sspr(0, 44, 4, 4, player_x-4, player_y+2)
				end
				spr(game_fcount%4>1  and 108 or 109, player_x+xx, player_y+yy, 1, 1)
			elseif player_state != "magic" then 
				spr(108, player_x+xx, player_y+yy, 1, 1)
			end
		end

		--object_draw
		if object_state !="hidden" then
			if object_state == "steam" then
				if object_timer <= 6 then object_state = "hidden" end
			elseif object_state == "falling" then
				local dx, dy = object_dlr*(12-object_timer)/8, object_dud*(12-object_timer)/8
				if object_timer >6  then
					local s = object_is_ice and 67 or 69
					spr(s, object_x+dx, object_y+dy,1,1)
				elseif object_timer <=6  then
					local s = object_is_ice and 68 or 70
					spr(s, object_x+dx, object_y+dy,1,1)
					if object_timer <= 0 then object_state = "hidden" end
				end
			else
				local s = object_is_ice and 65 or 66
				spr(s, object_x, object_y,1,1)
			end
		end

		-- boss_draw
		if game_level == 31 then
			local angle = game_fcount%60/60
			local x, y, n = boss_x + sin(angle)*0.5, boss_y +cos(angle)*2 -3, boss_wait > 0 and 114 or 112
			spr(n+game_fcount%8/4, x, y, 1, 1)
			if boss_wait > 0 then boss_wait -=1 end
			local col = game_fcount%4 >1 and 10 or 9
			if boss_life == 3 then
				circ(x+4, y+3, 7, col)
			elseif boss_life == 2 then
				circ(x+4, y+3, 5, col)
			elseif boss_life == 0 then
				boss_offset += 0.01
				boss_x += 0.8
				boss_y += sin(boss_offset)
			end
		end
		if boss_timer <=70 and boss_timer > 10 then
			spr(176+(boss_timer-10)%60/4, boss_atack_x,boss_atack_y)
		elseif boss_timer <=8 then
			rectfill(boss_atack_x+4-boss_timer/2,0, boss_atack_x+5+boss_timer/2, boss_atack_y+7, boss_timer <2 and 9 or boss_timer < 5 and 10 or 7)
		end


		-- menu_draw ---------------------------------------------------------------
		rectfill(3, 0, 39, 10, game_level >= 21 and 8 or game_level >= 11 and 9 or 13)
		print("level "..game_level, 6, 3, 7)

		bestcount_draw()
			
		if not player_down  then
			if player_state != "clear" then

				if player_magic_ready and not player_down then
					printc("+\x8b\x94\x94\x83 turn\n\|irelease❎ ice", 4, 113, 6, 0)
					printc("hold❎  ", 1, 105, 9, 0 )
				else
					printc("hold❎ >", 1, 122, 6, 0)
				end

				if not is_boss(game_level) or dget(game_level)>0 then
					printc(dget(game_level)>0 and "🅾️ undo(".. undostack.index ..")" or "🅾️ undo", 128, 122, (undostack.index <=0 or not level_undoable) and 5 or btn"4"and not btn"5" and 9 or  6, 0, 2, 1)
				end
			end
		else
			rectfill(0, 48, 127, 80, 8)
			printc("❎ retry\n\|i🅾️ select level", 20, 58, 7, 0, 1)
		end

		if level_complete then
			printc("level complete", 126+max((player_wait-50)*4, 0), 14, 7, 1, 2, 0, 3, 1)
		elseif new_best then
			printc("new record", 126+max((player_wait-50)*4, 0), 14, 7, 1, 2, 0, 3, 2)
		end
		-- miss_particles_draw ---------------------------
		foreach(
			miss_particles,
			function(p)
				p.x += p.spd_x
				p.y += p.spd_y
				p.l -=1
				local life = p.l
				if life <= 0 then
					del(miss_particles,p)
				end
				circfill(p.x, p.y, life/2.5, 12+life%2)
			end
		)
		steam_particles_draw()
		popup_draw(32, "full of ice")
		popup_draw(33, "long shot")
		popup_draw(34, "half of action limit")
		popup_draw(35, "bye!")
		popup_draw(36, "the seeker")	
	end
end

miss_particles={}
steam_particles={}
steam_particles_init = function(input_x, input_y, input_dlr, input_dud)
	for dir=0,7 do
		add(
			steam_particles,{
				x=input_x+2+rnd"4",
				y=input_y+4+rnd"4",
				l=15,
				r=5,
				c=9,
				spd={
					x = 0.4*rnd"3"*input_dlr,
					y = 0.4*rnd"3"*input_dud,
				}
			}
		)
	end
	steam_particles.x, steam_particles.y = input_x, input_y
end

steam_particles_draw = function()
	foreach(
		steam_particles,
		function(p)
			p.x += p.spd.x
			p.y += p.spd.y -(3/p.l)
			p.r -=0.5
			p.l -=1
			if p.l <= 0 then del(steam_particles,p) end
			if p.r ==3 then p.c = 7 end
			circfill(p.x, p.y, p.r, p.c)
		end
	)
	if object_state== "steam" and object_timer > 8 then
		circ(steam_particles.x+4, steam_particles.y+4, 75/object_timer, 8)
	end
end

snow_particles_init = function(lvl)
	blizzard_scale = lvl!=0 and 0.4 + lvl/40 or 0.4
	clouds = {}
	for i=0,16 do
		add(
			clouds,{
				x = rnd"128",
				y = rnd"64",
				w = 32 + rnd"32",
				spd = 0.6 + rnd"1"*blizzard_scale,
			}
		)
	end

	snowflakes = {}
	for i=0,16 do
		add(
			snowflakes,{
				x = rnd"128",
				y = rnd"128",
				s = rnd"5" / 4,
				spd = 0.5 + rnd"4"*blizzard_scale,
			}
		)
	end
end

snow_particles_draw = function()
	local col = game_mode != "playing" and 1 or game_level<=20 and 6  or 13
	rectfill(0, 0, 128, 16, col)
	foreach(clouds,
		function(c)
			c.x += c.spd
			rectfill(c.x, c.y, c.x+c.w, c.y+4+(1-c.w/128)*12, col)
			if c.x > 128 then
				c.x = -c.w
				c.y = rnd"72"-8
			end
		end
	)
	if game_mode!="achievements" then 
		foreach(snowflakes,
			function(p)
				p.x += p.spd
				p.y += 0.5
				rectfill(p.x, p.y, p.x+p.s, p.y+p.s, 7)
				if p.x > 132 then 
					p.x = -4
					p.y = rnd"128"-16
				end
			end
		)
	end
end

__gfx__
00000000eeeeeeeee1eee1eee1eee1ee212221222222222210eeeee1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5555555500000000cccccccc2122212221222122
00000000eeeeeeee1e1e1e1e1e1e1e1e2212221221122112e10eeee1eeeaeeeeeeeeaeeeeeeceeeeeeeceeee1111111100000000cccccccc2212221222122212
00700700ee588eeeeee1eee1eee1eee12221222121211212eee0ee10eeaaaeeeeeeeaaeeeeeceeeeeecceeee0101010100000000cccccccc2221222122212221
00077000ee58888eee1e1e1eee1eee1e1222122222122122eee1010eeaaaaaeeeaaaaaaeeeeceeeeecccccce1010101000000000cccccccc1222122212221222
00077000ee58888ee1eee1eee1eaa1ee2122212222122122eee110eeeeeaeeeeeeeeaaeeeccccceeeecceeee0000000000000000cccccccc2122212221222122
00700700ee5ee88e1e1eee1e1e1aae1e2212221221211212eee1011eeeeaeeeeeeeeaeeeeeccceeeeeeceeee0000000000000000cccccccc2212221222122212
00000000ee5eeeeeeee1e1e1eee1eee12221222121122112e10eee0eeeeaeeeeeeeeeeeeeeeceeeeeeeeeeee0000000000000000cccccccc2221222122212221
00000000ee5eeeee1eee1eee1eee1eee12221222222222220eeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000cccccccc1222122212221222
de7ede7edddddddd00000006600000001111111d0000000000000000000000001ddddddd15555556000000000000000000000000111111111111111100000000
e777e777dddddddd00000066660000001111111d0000000000000000000000001155555d1555555600000000000000000000000011515d5511515d5d00000000
7777677766d6d66d000006dd6d6600001111111d0000000000000000000000001155555d1555555600000000000000000000000011515d5d11515d5600000000
7d76766676767d7600066dddd6dd660015555556000000000000000000000000111111111111111600000000000000000000000011515d5d11515d5600000000
d6d666d6d7d777d6066ddddddd6ddd6615555556000000000000000000000000155555511dddddd600000000000000000000000011515d5d11515d5600000000
6d6d6d6d7d7d677d6dddddddddd66dd615555556000000000000000000000000155115511dddddd600000000000000000000000011515d5d11515d5600000000
d3d3d3d6d6d676d6dddddddddddd66dd15555556000000000000000000000000155115511555555600000000000000000000000011515d5d11515d5600000000
eded3deeed6e6ededddddddddddddd6d11111115000000000000000000000000155115511111111500000000000000000000000011515d5d11515d5600000000
1666666115555555e77777777777777711111115111115561555555d15555556155115511555555d77777777777777771555555511515d5d11515d5600000000
6666666d56666667777777777777777711111115111155561555555d15555556155115511555555d77777777777777775666666711515d5d11515d5600000000
6666666d56666667777777777777777711111115111555561555555d15555556155115511555555d77777777777777775666666711515d5d11515d5600000000
666666651555555677777777777777771555555d155555561555555d15555556111111111111111177777777777777770555555611515d5111515d5500000000
6ddddd15155555567ccccccc7ccccccc1555555d155555561555555d155555561ddddddd1dddddddcccccccccccccccc055555561d11111d1d11111600000000
6dddd1d5155555567ccccccc7ccccccc1555555d155555561555555d155555561ddddddd1dddddddcccccccccccccccc055dd5561ddddddd1dddddd600000000
dddd1d15155555567ccccccc7ccccccc1555555d155555561555555d155555561555555d1555555dcccccccccccccccc055005561555555d1555555600000000
15555551111111151666666616666666111111111111111511111111111111151111111111111111666666666666666601111115111111111111111500000000
e777777e77777776e777777777777777e777777e77777776e7777777777777777777777e7777777677777777777777777777777e777777767777777777777777
77777776777777767777777777777777777777767777777677777777777777777777777677777776777777777777777777777776777777767777777777777777
77777776777777767777777777777777777777767777777677777777777777777777777677777776777777777777777777777776777777767777777777777777
77777776777777767777777777777777777777767777777677777777777777777777777677777776777777777777777777777776777777767777777777777777
7cccccc67cccccc67ccccccc7ccccccc77777776777777767777777777777777ccccccc6ccccccc6cccccccccccccccc77777776777777767777777777777777
7ccccc167ccccc167cccccc17cccccc177777776777777767777777777777777cccccc16cccccc16ccccccc1ccccccc177777776777777767777777777777777
7cccc1167cccc1167ccccc117ccccc1177777776777777767777777777777777ccccc116ccccc116cccccc11cccccc1177777776777777767777777777777777
16666661166666611666666616666666777777767777777677777777777777776666666166666661666666666666666677777776777777767777777777777777
00000011077777700666666000000000000000000000000000000000e0eee1e0000000000000000000ccccc000000000c7ccc7cc0000000c00000000cc000000
00000011777777766666666d00000000000000000000000000000000e10eee0e07700c07000000700cccccccc0ccccc0c0000c0c000000c70000000070000000
00000011777777766666666d006666000000000000dddd0000000000e1e010e107c0000000700700ccff2f2fcccccccc000000000000000c00000000c0000000
00000011777777766666666506666660000000000dddddd00000000011e1001e000000c00007c000ccdffffcccfccccc00000000000000c7000000007c000000
000000117cccccc66ddddd1506666660000000000d55555000000000e111001e00000000000cc000f222222f0cdffff0000000000000000cc0c000ccc0000000
000000117ccccc166dddd1d506ccc160000660000d555150000dd000ee10100e0c00007700c0070000222200f222222f00000000000000cccc7ccc7ccc000000
000000117cccc116dddd1d1506cc1160000cd0000d55155000055000e00ee10e070c007c07000000000f0f0000222200000000000000000c77777777c0000000
0000001116666661155555510066660000000000005555000000000001eee1e0000000000000000000000000000f0f0000000000000000067777777760000000
0900990000000000007cccc0000000000000000000000000007cccc0000000000f7ccccf000ccc00000000000000000056666667000000000000000050000000
99909990007cccc007cccccc007ccccf0000000007cccc0007cccccc007cccc002ccccc20fcccccc0000d0000000000000000000000000000000000050000000
9991991107cccccc0cff2f2f07ccccc2007cccc07cccccc00cff2f2f07cccccc02f2f2f202f2cccc0000dd000000c7c000000000000000000000000050000000
011101100cff2f2f0cdffff00cff2f2207cccccccff2f2f00cdffff00ff2f2ff02fffff202fff2cc0004dd00f0cccccc00000000000000005666666710000000
099099900cdffff00cd222200cdffff20cff2f2fcdffff000cd222200cfffffc0c22222cf22fffc000044d0022cccccc00000000000000005666666710000000
999199910cd222200c2222200cd222200cdffff0cd2222000c22222f0c22222c0c22222c022222f0001114002222cccc00000000000000005666666710000000
099109110c22222000f000f00c2222200cd22220c222220000f000000f22222f000f0f0000222200000100002222222f00000000000000005666666710000000
00110010000f0f0000000000000f0f000c22222f000f000000000000000f0f0000000000000f0000000000000000000000000000000000015555555610000000
00000000000000000000000000000000000000000000000000000000000000000000000000028220002822020200000099000099cc0000cc0000000000000000
00888800908888090088880000888800908888090088880000888800008888000002000000282200000228200000020090000009c000000c0000000000000000
9882228909822280088222800882228098222889988888890888888098888889028820200088882000028880000028000000000000000000000d000000020000
99861d8909861d8008861d8008861d8008d1689092222899098888809982222902888200028898800002898000028820000000000000000000d0d00000171000
088711800887118099871189988711890811788008d168809888888908861d800289888000289880002898200288888000000000000000000d000d0001ccd100
028777808287778002877780928777890877782008117820028222200287118002899820002898200088920008899880000000000000000000d0d000001d1000
88288800082888008828880008288800008882880088828008288800882888000028820000288820000282000028820090000009c000000c000d000000010000
00000000000000000000000080000000000000000000008008000000000000000000000000000000000000000000000099000099cc0000cc0000000000000000
0067769009677690099999000777770000000000006776901111111877777778dddddddd00dddd0000dddd00000d000000000000000000000000000000000000
09677d9944677d9499477640777777700067769079677d9911111881777777870dddddd00dddddd00dddddd0000d000000000000000000000000000000000000
4fd7d7f94fd7d7944f777df97777777709677d998fd7d7f911111811777778770dddddd000dddd0000dddd00000d000000000000000111000088880000000000
946776490467769494d6d649777777770fd7d7f9026776491111811177778777dddddddd00dddd0000dddd00000d000000101000000101000888888000000000
7828822478288920082666240777777704677649042882241118811177788777dddddddd00dddd0000dddd00000dd00000010000001111100881818000000000
04291272228422720279122207777777042882240429172218881111778777770dddddd00dddddd000dddd00000dd00000101000001111100088888000000000
0282182002218200005128700077777008291272028218208811111178777777dddddddd0dddddd00dddddd000ddd00000000000001111100008080000000000
0005050000050500000050000000700072882250000505008111111177777777dddddddd0dddddd000dddd0000dddd0000000000000000000000000000000000
0101010101010101111111110101010111111111d1d1d1d1cccccccceeeeeeee0000000000000000ddddd11100dd110000dd1100000d00000000000000000000
1000100010101010111111111110111011111111ddddddddcccccccceeeeeeee10001000010001000ddd11100dddd1100dddd110000d00000009000000000000
0101010101010101111111110101010111111111ddddddddcccccccceeeeeeee00000000000000000ddd111000dd110000dd1100000d00000097400000000000
0010001010101010111111111011101011111111ddddddddcccccccceeeeeeee0010001000000000ddddd11100dd110000dd1100000d0000997aa44000000000
0101010101010101111111110101010111111111ddddddddcccccccceeeeeeee0000000000000000ddddd11100dd110000dd1100000d100047aa994000000000
100010001010101011111111111011101d1d1d1dddddddddcccccccceeeeeeee10001000001000100ddd11100dddd11000dd1100000d100004a9940000000000
01010101010101011111111101010101d1d1d1d1ddddddddcccccccceeeeeeee0000000000000000ddddd1110dddd1100dddd11000dd10000494940000000000
001000101010101011111111101110111d1d1d1dddddddddcccccccceeeeeeee0010001000000000ddddd1110dddd11000dd110000dd11000440440000000000
09999999999999999999999999999990000000000999990000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999999999999999999999999999990001110000878780010010010000000000000000000000000000000000000000000000000000000000000000000000000
09999299999999999991999999999990011111000878780091191190000000000000000000000000000000000000000000000000000000000000000000000000
09991719999999999919999999999990011111000062600019191910000011111111111111111111111111111011111111111111111111111111111111100000
0991ccd19999999999199999999999900111110004aa940019a99410000017777717777117711771777771771117711777117711771777771777717777110000
09991d19999999999919999999999990001110000aa9990019a994100000177c77177c771771177177c7717771777177c771777177177c77177cc177c7710000
09999199999999999199999999999990000000000a99990019a9941000001771cc17717717711771771771777777717717717777771771cc1771117717710000
09999999999999999999999999999990000000000499940011111110000017711117777c1c7777c1771771777777717717717777771771111777717777c10000
099999999999999999999999999999900000000000000000000000000000177111177c7711c77c1177177177c7c77177777177c777177111177cc177c7710000
00000000000000999000000000000000000200001111111110000000000017717717717711177111771771771c177177c771771c771771771771117717710000
00000000000000090000000000000000002710001911911910000000000017777717717710177101777771771117717717717711771777771777717717710000
000000000000000000000000000000000277c100119191911000000000001ccccc1cc1cc101cc101ccccc1cc101cc1cc1cc1cc11cc1ccccc1cccc1cc1cc10000
000000000000000000000000000000001777cc100199999100000000000011111111111110111101111111111011111111111111111111111111111111110000
0000000000000000000000000000000001ccd1000199999100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000001c10000199999100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000100000111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
0888888008aa88800aaa88800aaa88800aaa88800aaa88800aaa88800aaa88800aaa88800aaa88800aaa88800aaa88800aaa88800aaa88a00aaaaaa000000000
800000088000000880000008a0000008a0000008a0000008a0000008a0000008a0000008a0000008a0000008a0000008a000000aa000000aa000000a00000000
80088008800aa00880088008a00aa008a0088008a0088008a00aa008a00aa008a00aa008a0088008a0088008a0088008a000000aa000000aa000000a00000000
80088008800aa00880088008800aa008a0088008a0088008a00aa008a00aa008a00aa008a0088008a0088008a008800aa000000aa000000aa000000a00000000
80000008800000088000000880000008a0000008a0000008a0000008a0000008a0000008a0000008a0000008a000000aa000000aa000000aa000000a00000000
80088008800aa00880088008800aa00880088008a0088008a00aa008a00aa008a00aa008a0088008a008800aa008800aa000000aa000000aa000000a00000000
8000000880000008800000088000000880000008a0000008a0000008a0000008a0000008a0000008a000000aa000000aa000000aa000000aa000000a00000000
0888888008888880088888800888888008888880088888800a8888800aaa88800aaaaa800aaaaaa00aaaaaa00aaaaaa00aaaaaa00aaaaaa00aaaaaa000000000
00000000000000000000000000000000d80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001212121212121212121212120000c80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00121212d192d1d1d1d192d112121200b80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001212d1d2b0d2d2d2d260d2d1121200c80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0012d1d26020202020608060d2d11200c80000000000000000000000000000000000000000000000000000000000000000120003000000000000000096001200
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d1d220606020202012902020d2e100a80000000000000000000000000000000000000000000000000000140000000000203500000000000000000000070000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d2b020602012129012121220b0e200a80000000000000000000000000000000000140000000000000000000014000000022020000000000000000003501200
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c020c020602020206020202030c020c0a80000000000000000000000000000000000000000000000000000000000000000002283000003000046000050e00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c010202060202020606012904040e0c0b70000002020202020202020000000000808080808080808081408080808080800000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000009898989898989898989898989898989821312131213121312131213121312131
c0202020202020202060202030b0a0c0a70000002020202020202020000000000808080808080808080808080808080800000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000008888888888888888888888888888888811111111111111111111111111111111
0012b020202012129012121220c01200a70000002020202020202020000000001818181818181818181818181418181800000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000808080808080808080808080808080801010101010101010101010101010101
001212b0202020202012902020121200970000002020202020202020000000001818181818181818181818181818181800000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001818181818181818181818181818181801010101010101010101010101010101
00121212602020206060806012121200a70000002020202020202020000000003838383838383838383838383838383800000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000003838383838383838383838383838383800d1d242d142d14242d142e141e2e100
00121212121212121212121212121200870000002020202020202020000000003838383838383838383838383838383821312131213121312131213121312131
00000000000000000000000000000000000000000000000000000000000000002828282828282828282828282828282800d2d162d281d28181d281e272e1e200
00421212121212121212121212125200870000002020202020202020000000002828282828282828282828282828282811111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000004848484848484848484848484848484800d1d292d182d28282d282e191e2e100
00000000000000000000000000000000870000002020202020202020000000002828282828282828282828282828282801010101010101010101010101010101
00000000000000000000000000000000000000000000000000000000000000005858585858585858585858585858585800d2d242d242d14242d142e241e2e200
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001111111111111111111111111111111111111111111111111111100001111111111111111111111111111111111111111111111111111111111110000000
00001111111111111111111111111111111111111111111111111111110011111111111111111111111111111111111111111111111111111111111111000000
00001177777777771777777771117777111177771777777777717771111111177711177777711177771111777717777777777177777777177777777111100000
00001177777777771777777777117777111177771777777777717777111111777711777777771177777111777717777777777177777777177777777711100000
0000117777cc777717777cc7777177771111777717777cc777717777711117777717777cc7777177777711777717777cc777717777cccc17777cc77771100000
0000117777cc777717777cc7777177771111777717777cc777717777771177777717777cc7777177777771777717777cc777717777cccc17777cc77771100000
000011777711cccc177771177771777711117777177771177771777777777777771777711777717777777777771777711cccc177771111177771177771100000
000011777711cccc177771177771777771177777177771177771777777777777771777711777717777777777771777711cccc177771111177771177771100000
0000117777111111177777777cc1c7777777777c1777711777717777777777777717777117777177777777777717777111111177777777177777777cc1100000
0000117777111111177777777cc1cc77777777cc1777711777717777777777777717777117777177777777777717777111111177777777177777777cc1100000
000011777711111117777cc777111cc777777cc11777711777717777c7777c77771777777777717777c77777771777711111117777cccc17777cc77711100000
000011777711111117777cc7777111cc7777cc111777711777717777cc77cc77771777777777717777cc7777771777711111117777cccc17777cc77771100000
0000117777117777177771177771111c7777c11117777117777177771cccc1777717777cc7777177771cc7777717777117777177771111177771177771100000
0000117777117777177771177771111177771111177771177771777711cc11777717777cc77771777711cc777717777117777177771111177771177771100000
0000117777777777177771177771111177771111177777777771777711111177771777711777717777111c777717777777777177777777177771177771100000
00001177777777771777711777711011777711011777777777717777111111777717777117777177771111777717777777777177777777177771177771100000
000011cccccccccc1cccc11cccc11011cccc11011cccccccccc1cccc110011cccc1cccc11cccc1cccc1111cccc1cccccccccc1cccccccc1cccc11cccc1100000
000011cccccccccc1cccc11cccc11011cccc11011cccccccccc1cccc110011cccc1cccc11cccc1cccc1111cccc1cccccccccc1cccccccc1cccc11cccc1100000
00001111111111111111111111111011111111011111111111111111110011111111111111111111111111111111111111111111111111111111111111100000
00001111111111111111111111111011111111011111111111111111110011111111111111111111111111111111111111111111111111111111111111100000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055000000cccccccc000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555500000c6ccccccccccc000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555550000cc7ccccccccccccc00000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555550000cc7ccccccccccccccc0000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000055555555555550000cc77cccccccccccccccc000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000ccs77ccccccccccccc7cc00000000000
00000000000000000000000000000000000000000000000000000000000000000000000555555555555555555500000ccsscc7sc7ccc7cccc77cc00000000000
00000000000000000000000000000000000000000000000000000000000000000005555555555555555555555000000csscccsdcc7cc76c7777cc00000000000
000000000000d000000000000000000000000000000000000000000000000005555555555555555555555555000000ccssccsd4ccsc77677c77ccc0000000000
000000000000d000000000000000000000000000000000000000000000055555555555555555555555555550000000csscccs4vccscccsccdc7ccc0000000000
000000000000c000000000000000000000000000000000000000000555555555555555555555555555555000000000cssscs4vfcscccscccdccccc0000000000
000000000000c00000000000000d00000000000000000000000555555555555555555555555555555556000000000ccsscss4fcscccscsccdsdccc0000000000
000000000000700000000000000000000000000000000005555555555555555555555555555575555550000000000ccs1s11ccscc1111ccsdsdcccc000000000
00000000000070000000000000000000000000000005555555555555555555555555555555575555550000000000cscs1s111fff411114cdssscccc000000000
000000000dc777cd0000000000000000000000055555d555555555555555555d555555555556555550000000007ccsc1d461cvfff61c11cdvfs7ccc000000000
0000000000007000000000000000000000055555555ddd55555555555555555d5555555555565555000000007cccssc1d47d17fff7d14fcsvfs7ccs000000000
00000000000070000000000000000005555555555555d555555555555555555c5555555555556d0000000777cccsscsdd44v4ffffvv4vfdvf17ccc0s00000000
000000000000c00000000000000555555555555555555555555555555555555c55555555555550dd66777cc7cccsc1sdd4vffvfffff7ff4sss7ccc0s00000000
000000000000c00000000005555555555555575555555555555555555555555755555555555500000777cc7cccssd1ddddvffffffffffssss7cccc0s00000000
000000000000d0000005555555555555555555555555555555555555555555575555555555500cc77cddd7ccssdd1ddddddvf4vv4fffscss7ccscc0s00000000
000000000000d005555555555555555555555555555555555555555555555557555555555500ccddd0007ccssd1dddddddd4vvffffsccss7ccsdcc0s00000000
00000000000555555555555555555555555555555555555555555555555dc77777cd5555500cddd0000cccssd1ddddddddd114vv47csss7ccsddcc0s00000000
000000055555555555555555555c55555555555555555555555555555555555755555550000dd0000cc7ssdd1ddddddddd1222227c11127csdddccs000000000
00055555555555555555555555c7c555555555555555555555655555555555575555550000d0000ccc7sddd1ddddddddd12112scc11227c22dd0ccs000000000
555555555555555555555555555c5555555555555555555555555555555555575555500000d000cccc7ddd1ddddddddd12222scs111227c22dd0cc0000000000
555555555555555555555555555555555555555555555555555555555555555c55550000000000ccc7ddd1dddd1ddddd11111cs1222122c22ddccc0000000000
555555555555555555555555555555555555555555555555555555555555555c5550000000000cccs7dd1dddd1ddddd12221ss11111212c22d0ccc0000000000
555555555555555555555555557777755555555557777555555555555555555d5500000000000cd007d1dddd1dddd4122211c1111ff2121c2d0cc00000000000
555555555555555555555555777777775555577777777777777555555555555d500000000000cd0007d1ddd1dddd4f111221111ffff12112c0scc00000000000
5555555556555555555555577777777777777777777777777777555555555550000000000000d000070dddd1dddd4ff1421111fffv1121222scc000000000000
555555555555555555555577777777777777777777777777777775555555550000000000000cd000007d0d1dddd14vfvf4111fffv411212sscc0000000000000
555555555555555556666667777777776777777777777777777667555555d00000000000000d0000000d001ddd4f14v4f411ffvv41121111c000000000000000
55555555555555766655666677777777766677777777777776666675555dcd0000000000000d0000000d001ddd4ffvvv44fffvv1111115110000000000000000
555555555555776555556666677777777666667777777777766666665550d00000000000000d00000000d00dddd4vvvvf4fvv411411155100000000000000000
55555555555775555555666666666776666666677777777766666677777777777777777777770000000000000dd14vvfvv411114441555100000000000000000
55555555557555555555666666777777776666666777766667777777777777777777777777777000000000000011d4v4411111144vv155100000700000000000
5555555557555755555576666777777776667777777777777777777777777777777777777767700000000000001ddd0111111551vvv151100000000000000000
5555555575555555557777667777777777777777777777777777777777777777777777776666700000000000ddddd00001111111vv4111100000000000000000
555555575555555577777777777777777777777777777777777777777777777777777cc776667000000d00ddddd00000011121vv414111000000000000000000
5555555755555557777777777777777777777777777777777777777777777777777cccc776c770000000ddddd000000022112121114122000000000000000000
55555575555555577667777777777777777777777777777777ccc7777777776ccccccc776cc7700000000000000000002221212211121250000ddd0000000000
555555755555555776ccc77777776ccccccccccccccccccc7cccc777777776ccccccc776ccc7700000000000000000021221222221522120000000ddd0000000
55555755555555576cccc7777776c11ccdccccccccccccc7cccc7777777776ccccccc76cccc77000000070000000000122212222221522250000000007700000
55555755555555577cc77777776c11cccdcccccccccccc7cccc7777777777ccccccc76ccccc77000000000000000000122212222222151210000000000077000
55557555555555577c77777776cc1cccccccccccccccc7cccc77777777777cccccc77cccccc77000000000000000001222212222222255150000000000000700
55557555555555577c7777776ccc1cccc7cccccccccc7cccc777777777777ccccc77ccccccc77000000000000000021222211222222215551000000000000700
555575555555555777777776cccc1cccc7ccccccccc7cccc777777777777ccccc776ccccccc77000000000000000212222221222222221551000000000000070
55575555555555577777776ccccc1cdc777cdcccc77cccc7777777777777cccc776cccccccc77000000000000000122221221222222222112000000000000070
5557555557555557777776ccccccdcccc7cccccc7cccc777777777777777ccc777ccccccccc770000000000000022222212212222222227c2000000000000070
555755555555555777776cccccccdcccc7ccccc7cccc77777777777777c7cc777cccccccccc77000000000000022222212221122222222cc2000000000000070
55575555555555577776ccccccccdcccc7cccc7cccc77777777777777cc7c777ccccccccccc77000000000002222221122111122222222222000000000000700
5577555555555557776cccccccccdcccccccc7cccc77777777777777ccc7777cccccccccccc77000000000022222112211111122221222222000d00000007000
557765555555555776cccccccccc1ccccdcc7cccc77777777777777ccc6777ccccccccccccc7700000000022222122111111111222122222200dcd0000007000
557765555555d5577ccccccccccc1cccccc7cccc77777777777777ccc67776ccccccccccccc77000000022222222111111111112221222222000d00000070000
55776555555555577ccccccccccc1ccccc7cccc77777777777777ccc67c77cccccccccccccc77000000221111111111114111111222122222000000000700000
577765555c5555577ccccccccccc1cccc7cccc7777777777777cccc67cc76cccccccccccccc7700000221111111111111v411111222122222000000007000000
57776555c7c555577ccccccccccc1ccc7cccc7777777777777cccc77ccc76cccccccccccccc7700002111111111111111vv41111222212222000000070000000
577765555c5555577ccccccccccc1cc7cccc7777777777777cccc7ccccc7ccccccccccccccc7700000000001111111111vvv4111122212222000000700000000
77676555555555577ccccccccccc1c7cccc7777777777777cccc7cccccc7cccccccccccccc67700000000000011111111vvvv411122221222200007000000000
77676655555555577cccccccccccc7cccc7777777777777cccc7ccccccc7cccccccccccccc67700000000000001111111vvvvv11111222122200770000000000
77676655555555577ccccccccccc7cccc7777777777777cccc7cccccccc7cccccccccccccc77700000000000000111111vvvvv11111112212207000000000000
76676655555556667ccddddccc67cccc7776777777777cccc7ccccccccc7ccccccccccccc7777d6666000000000011111vvvvv11111411122770000000000000
76667665555556666dddddddc67c1cc7776777777777cccc7cccccccc1c7cccccccddddd67777d6667770000000701111vvvv411111444177210000000000000
76667665555566666ddddddc67cc1c7776777777777ccc77cccccccc11c7cccccddddddd77777d6677777000000000000vvvv111111177711220000000000000
77766766555666666dddddc77dddc7776777777777ccc7ccccccccc11ccc7ccdddddddd777777d66677777000000000004vvv0001177vv444000000000000000
77776676655666666ddddc7ddddd7776777777777ccc7ccccccccc11cccc7cdddddddd6777777d66677777000000000000vfv0007700vvvv0000000000000000
777776676666666677ddc7dddd67776c77777777ccc7ccccccccc11ccccc7ddddddddd7777767d666777760000000000004ff77770000vvv0000000000000000
777777667666666667dc7dddd7777cc77777777ccc7ccccccccc11cccccc7dddddddd77777cc7666777766jjjjjjjjj11jj7777jjjjjjvv2jjjjjjjjjjjjjj11
77777666677666666dc76ddd7777dc7777777cccc7cccccccc111cccccc17ddddddd7777777776666776666jjjjjj11jj77772jjjjjjj2222jjjjjjjjjjjj11j
77776666667776666c76ddd7776dd7777777ccc77cccccccc11ccccccc1d7dddddd67777777666666666666jjjj11j7777j222jjjjjjjj222jjjjjjjjjjj1jjj
7777666777767766676ddd777ddd7777777ccc7ccccccccc11ccccccc1dd7dddddd7777777667766666666jjjj7777766jjjvvjjjjjjjj222jjjjjjjjj11jjjj
777776777777667667ddd777ddd7777777ccc7ccccccccc11ccccccc1ddd7ddddd77777766777777766666777777776jjjjjvvjjjjjjjjjvvjjjjjjjj1jjjjjj
777777777777666667dd777ddd7777777ccc7cccccdddc11dddccc11dddd7dddd77777776777777777666677777666jjjjjjvvvjjjjjjjjvvvjjjjj11jjjjjjj
777777777777766667d777dd67777777ddc7cccdddddd11dddddc1dddddd7ddd7766677777777777776777777666jjjjjjjjffvvjjjjjjjvvvjjjj1jjjjjjjjj
j77777777777777667777dd67777777ddc7ccddddddd11dddddd1ddddddd7dd766776677777777766677776666jjjjjjjjjj2224jjjjjj2222jj111jjjjdjjjj
j7777777777777776777dd67777777dd77ddddddddd11dddddd1ddddd7777776677777777776666677777666jjjjjjjjjjj2222111jjjj222211111111d11jjj
j777777777777776667dd77777777dd76ddd77777777dddddd1dd777777777777777777766777777666666jjjjjjjjjjjjfff21111111j222211jjjjj7jjj111
j177777777777777776677777777cd76ddddddddd11d77777777777777777777777777677776666677766jjjjjjjjjjjjvfvfv11111111ffffjjjjjj7jjjjjjj
j111677777777777777667777677776ddddddddd11dddddd6666666666666666666666666666667777766jjjjjjjjjjjjvvvv11111111vffff1jj777jjjjjjjj
jj1166777777777777776677666777777711111111177777777777776666777766666777777776777776666666777jjjjjj1111111111vff77777jjjjjjjjjjj
j1j166777777777777776676666661111111111117777777777777766677777776777777777777677666666667777777777777777777777711jjjjjjjjjjjjjj
jj11667777777777777767777777777711117777777777777777777677777777777777777777776777766667777777777777777666611111jjjjjjjjjjjjjjjj
11j1666777777777777767777777777777777777777777777777776677777777677777777777776777666666666666666666jjjj11jjjjjjjjjjjjjjjjjjjjjj
jj111667777777777776666777777777777777777777777777777766777777776777777777777767666666661jjjjjjjjjjjjj11jjjjjjjjjjjjjjjjjjjjjjjj
j1j111667777777777666667777777777777777777777777777776666777777767777777777777666666661111jjjjjjjjjjj11jjjjjjjjjjjjjjjjjjjjjjjjj
jj1j111667777777776666677777777777777677777777777777766666777776667777777677766666771111111jjjjjjjj111jjjjjjjjjjjjjjjjjjjjjjjjjj
jjj11111667777777666666767777777777776666677777777766666666666666667777766777666777111111111j1j1jj111jjjjjjjjjjjjjjjjjjjjjjjjjjj
jjjjj1111166666666666666667777777777776666666777776666666666666666666666677766767711111j1jjjjjjj1111111111j1j1j1j1jjjjjjjjjjjjjj
jjjjjj1j1111666666666666666777766677777766666666666666666666666666666666676666661111j1j1jjjjjj1111111111111111111111111111111111
jjjjjjj1j111111111111666666666666666666666666111666666666666666666666661111111111jjjjjjjjjjjj11jjjjjjjjjjjjjjjjjjjjjjjjjjjj11111
jjjjjjjjjj1j11111111111111666666666666666111111111166666666666666611111111j1jjjjjjjjjjjjjjj111jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
jjjjjjjjjjjjjj11111111111111111111111111111111111111111111111111111j1jjjjj1jjjjjjjjjjjjjjj11jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
jjjjjjjjjjjjjjjjjj1jjj111111111111111111111111j1j1j111jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj111jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
jjjjjjjjjjjjjjjjjjjj1111jjjjjjjjjjjjjjjjjjjjjjjjjj111jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj111jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
jjjjjjjjjjjjjjjjjj1111jjjjjjjjjjjjjjjjjjjjjjjjjj1111jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj111jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj

__gff__
00202020202020202020200000000000000000000100000001010000000101000181454701010101010155578181810041434547494b4d4f51535557595b5d5f00410100000000000000000083858991000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2121212c212c212121212c21212c2121212121212121212121212121212c2121212c212121212c21212c2121212c212c212c212c212c21212c212c212c21212c2121212c2121212c2121212121212c2121212c21212c21212c212121212c212c21212c212c2121212121212c21212c212121212121212c212c212c2121210000
2121020230020321210202212102022121020221212c212c212121210202022102020221210302032102022130020230020102022238212102023102020202020202020321210b0b0b0b0b0b0b0b030b2121030b210b210b0b0b21210b0b0b0b0b0b0b0b0b0b2121010230020505020202032121010202020202020203210000
212c020221212c212102020202020221210201210202020203212101020202020202022121022102020203212102210221022102210221210221212a3a213421213a210221210c01020230020202020c21210202020c21020c0c21210c0c210221022102210c2121212c21210202212c21212121022130210321302102210000
21010202300203212103020102020321210202210202212121212121020202212102212121222a38210202212130210221022102210221213a3d020202373f3d0203020221210c0b0b0b020b0b0b020c21210202020c0202030c21210c0c210703020202020c21210b0b0b2102300202020b2121020205020502050202210000
2121020221212c2121020202020202212102302121022121212121212c212c21210202212102020235022121020203222a380302030221210221022c213b212c0221210221210c210c2102210c21020c21210b032c2102022c21212102022102210221020b0c21210203022102020202050c2121022102213021022102210000
21210202300203212102022121020221210202020330212121212102030202373d0302212102212a2b3a2121212c022c212c213021022121020201310234020202323f3a21210c03020203020202020c212121020201020202032121010202020b0721020c0c2121040404212121212102212121020305020503050202210000
2121212121212121212121212121212121212121020221212121210202022121210202212101020202020221300202023002020202302121022121213221223a2121210221210c0b0b0b0b0b0b0b0b0c212121022c2121022c21212102022102210221020c0c2121040404212c212c2102022121022130213021302102210000
212c2c2c2c2c2c21212c2c2c2c2c2c21212c2c2c2c2c2c2c2c21212c2c2c2c2c2c2c2c21212c2c2c2c2c2c2121212121212121212121212103020202020202020235020221212c2c2c2c2c2c2c2c2c2c2121030202020202020321210b0b210202020307020c2121040504020202020205022121020205020502050202210000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000212c2c2c2c2c2c2c2c2c2c21212c2c2c2c2c2c2c2c2c2c2c2c21000000000000000000000000210b0b0b0b0b0b0b0b21210c0c210221022102210c21210202020b0b0b0b0b0b0b2121032102210221022103210000
2121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212c21212c21212c2121212121212121212121212121000000000000212c2c2c2c2c2c2c2c21210c0c0b0b0b0b0b0b0b0c21212c2c2c2c2c2c2c2c2c2c21210b0b0b0b0b0b0b0b0b210000
21020221040403212121040404040b210121210b0b0b0b0b0b0b0b2121210b0b0b0b0b0b0b0b21210b0b0b0b0b0b0b0b0b0b2121030404210b0b210b0b0b2121020202210b0b210202022121212c212c212c212c21000000000000212c2c2c2c2c2c2c2c2c2c212121212121212121000000212c2c2c2c2c2c2c2c2c2c210000
210202040404042121210403040421210421210c01022003030303020b210c0402020202020221210c02022002200202200c21210b04040404040404040421210201020202020202200221210b0b0b0b0b0b0b0b21212c212c21212c212c210000000000000000000000000000000000000021212c212c21212c21212c212c21
2101020404042121210b0404040403040421210c0b2121212121022121210c0403020220020321210c20020302200220020c21210c0404040404040404032121020202212121210203022121030202020202030c21210102020221040404210000000021212c2c21212c2c21212c2c21210021210b0b0b0b0b0b0b0b0b0b0b21
210202042104042121212104040404040421210c0c2121212121022121210c0421212134212121210c02212021022103020c2121210404210421040404212121212121210303212102212121022121212107212121210202020206040404210000000021300b0b210b22380b210b0b30210021210c0606030603060606060c21
2102022104040421210b2104040321042121210c03030303200202020b21210102023220032121210c02200202200320200c21210b04040401040404030b2121210b020202020221022121210201020221020202212121062121210404042100000000210b300221060203062103300b210021210c0621062106213021060c21
21020204042103212104040421210430042121000b0b0b0b0b0b0b2121210b0421212131212121210c20212021022120030c21210c04042104210404040c212121030204040404020221212104040404203a2002212104040406060404042100000000210c020102060202060202020c210021210c0606050605060506060c21
2121212121212121210421040304040404212121212121212121212121210c0402020203020221210c02200302022002200c212121040404040404040421212121210b0b0421210b0221212104212104212135022121040404212c212c06210000000021212102020602020602022121210021210c0621302130213021060c21
00000000000000002104030404040b210b2121212c2c2c2c2c2c2c2121210c0302020202020221210c02212021202120020c21210b04040404040403040b21210b0202040404040202022121080b0b0421042102212104040406050302052100000000210b060606060b0b060606060b210021210c0106050605060506030c21
0000000000000000212121212121212121210000000000000000000000210c0402212121212121210c01020202200202020c21210c04030404040404040421210c0202040404040203022121202121040404040821210404042102020203210000000021300203020b0c0c0b02020330210c21210c0621062106210621060c21
21212c2c21212c2c21212c2c2121210000000000000000000000000000210c0b0b0b0b0b0b0b21210c0b0b0b0b0b0b0b0b0c21210c0404210b0b2104040321210c0303210b0b210303022121310221212121022121212c2c2c2c2c2c2c2c210000000c210b060606060c0c060606060b210c21210c0606050605060506030c21
210505050b0b0b0b0b0b05050321210000000000000000000000000000212c2c2c2c2c2c2c2c21212121212121212121212121212c2c2c2c2c2c2c2c2c2c21212c2c2c2c2c2c2c2c2c2c21210202210b0b21022121212c2121212c2121212c2121210c21212102030602020602022121210c21210c0621302106210621060c21
210503040406030c0c0c040405212100000000000000000000000021212121212121210b0b212121212c212c212c212121212121212121212121212121212c21212c21212121212121212121020802020202070b210202022109020221090202212100210b020202060203060202020b210021210c0606060603060606060c21
210505040b0b050404040404052121000000000000000000000000212121212c212c210202212c21210b0b0b0b0b0321212c0b2c0b2c0b2c0b2c0b21210b0b0b0602032121020601060202210b0b0b0b0b0b0b0c210201023502030235020702212100210c300221060202062103300c210021210c0b0b0b0b0b0b0b0b0b0c21
210505040c2103210b0b0b040b2121000000000000000000000000210b020202060302030504020b210c0c0c0c0c0321210302020203020202030221210202020602212121202120212021212c2c2c2c2c2c2c2c21020202210202022102020221210021300b0b210b22380b210b0b302100212c2c2c2c2c2c2c2c2c2c2c2c21
2121060b0c0b060b0c0c0c0621212100000000000000000000000021212106022104042102062121210c212c212c022121062102210621212102212121020202060606212103060321032121000000000000000021212c2121212c2121213b212121002c2c2121212c2c2c2c21212c2c21000000000000000000000000000000
2103050203060106020302050b2121000000000000000000000000210b0202010604050b0302020b210c060606060221213806010632212c2102212121010230060203212106030306062121000000000000000021210b020202020202020a212121000000000000000000000000000000000000000000000000000000000000
2121050b0b21060b0b0b0b0621212100000000000000000000000021212106022104042102062121210102020202022121022106210202020202212121020202060202212103060303032121000000000000000021210c0221210202030202212121000000000000000000000000000000000000000000000000000000000000
210b050c0c0b020c0c0c0c04052121000000000000000000000000210b020202060302030504020b210b06060606022121022238020202022103212121020202060202212103210321032121000000000000000021210c02212c0902020202212121000000000000000000000000000000000000000000000000000000000000
210c05040c0c020c0c0c0c04052121000000000000000000000000212121212c2c2c2c2c2c212121210c212c212c02212102020202210606212c2121210b0b0b060302212121212121212121000000000000000021210c0802020221210902212121000000000000000000000000000000000000000000000000000000000000
210c05050506030604040403052121000000000000000000000000212121212c2c2c2c2c2c212121210c0b0b0b0b0321210203212121020202030221212c2c2c2c2c2c21212c2c2c2c2c2c21000000000000000021210c02020207212c0203212121000000000000000000000000000000000000000000000000000000000000
210c030b0b210b0b0505050505212100000000000000000000000000000000000000000000000000210c0c0c0c0c0321212c2c2c2c2c2c2c2c2c2c2100000000000000000000000000000000000000000000000021210c0b0b0b0b0b0b0b0b212121000000000000000000000000000000000000000000000000000000000000
2c2c2121212c2c2c2c21212c2c212c00000000000000000000000000000000000000000000000000212c2c2c2c2c2c21000000000000000000000000000000000000000000000000000000000000000000000000212c2c2c21212c2c21212c2c2c21000000000000000000000000000000000000000000000000000000000000
__sfx__
010200002a1502e150311503415037150391503c1503e1503f1503f1503f1403f1303f1203f1103f1003f1003f1003f1003f1003f1003f100202001f200045000050000500005000050001500015000250003500
00020000380503c0503e0502745024450204501b4501844015440124300f4300c420094200641002400004000f4000f4001960018600334003240000000000000000000000000000000000000000000000000000
0002000000000236502b65031650316502b650256501b650106500765001650326003360032100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000373502d3502535029450294502c6502e6503265036650396303b6203d6102b4502d4503045034450384503b4503e45038300393003b3003d3003d300336003260031600306002e6002d6002c6002c600
00010000000002845026450214501f4501c4501a4501745014440104300f420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000000023540285402b5402f5403354036540385403a5403c5403d5401c030210302403027020290202b0302d0202f02032020340203501036010380103a0103a0103c0103c0103d0103d0103d0103d010
01030000180401d0402104024040280402b0402e040310403304034040360403704038040390403a0403b0403b0403c0403d0403e0401c540265402c540315403354036540385403a5403b5403c5403d5403d540
00010000221202512027120291202a1202b1202c1202c1102c1102b1002b1002b1002a1002a100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000000030080300e030140301a0301f03024030290302d0303003032030350303703037030370303703037030000000000000000000000000000000000000000000000000000000000000000000000000000
000200003f7403e7403d7403c7403b7403a74038740377403674034740337403274031740307402e7402c7402b7402a730287302673024730227301f7301c7301a72016720137200f7200c720077100271001700
0001000031640306402f6402b6402964027640236301d63018630116300b63006630036202b62027640206401c64016630116300b630046301f6301d63018630136300b630026300c6200a620066100361007600
00010000156301863018630136300b6300460000600006001e6501a650176500d65005650026501b60014600116000e6000a60005600016000060000000000000000000000000000000000000000000000000000
0003000026650302501f6403823016630126300e6200b6200962006620046100261000610006100140016500044001750017500195000e1000e1000d100001000910007100051000410003100011000010021000
000200003d450224503a45026450364502d45031450324502b450354501c650186501565012640106400e6400c6400a6300963008630076300662005620046200462003620026100161000610006100031000410
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9520000024555245451f535245251804517035150251301524555245451f535245251804517035150251301523555235451f535235251704515035130251101523555235451f5352352517045150351302511015
9520000021555215451d535215251504513035110251001521555215451d535215251504513035110251001523555235451f53523525170451503513025110152655526545265351f52513045150351703513035
a12000002810524215246152421528105242152461524215281052421524615242152810524215246152421528105232152361523215281052321523615232152810523215236152321528105232152361523215
a02000002810021215216152121528100212152161521215281002121521615212152810021215216152121528100232152361523215281002321523615232152810023215236152321528100232152361523215
351200002d7353473530725347252d7353473530725347252d7353473530725347252d7353473530725347252b735327352f725327252b735327352f725327252b735327352f725327252b735327352f72532725
3512000029735307352d7253072529735307352d7253072529735307352d7253072529735307352d72530725287352f7352b7252f725287352f7352b7252f7252b735327352f725327252b735327352f72532725
31120000213352d30024603213352460024603246432460321335246032460321335246002460324643246031f33524603246031f335246002460324643246031f33524603246031f33524600246032464324603
7109002015350153401c3401c34015340153401734017340173401734018340183401734017340153401534013350133401a3401a3401734017340183401834018340183401a3401a34018340183401534015340
030900002d0462d0462d0462d0462d0362d0362d0362d0362d0262d0262d0262d0262d0162d0162d0162d0162b0462b0462b0462b0462b0362b0362b0362b0362b0262b0262b0262b0262b0162b0162b0162b016
09120000153201532015320153201c3201c3201c3201c3201a3201a32018320183201732017320153201532013320133201332013320153201532017320173201832018320173201732015320153201732017320
0912000011320113201132015320153201532018320183201a3201a3201832018320173201732015320153201c3201c3201c3201c320173201732018320183201f3201f3201f3201f3201a3201a3201a3201a320
01100000232351a435234351d4351a4351d4351a435234351d435234351d43523425234002340023400234001f200214001f400184001a4151c4151d4251f42523435214351d43521435184351a435214351a435
01100000186551a2051d6051d605186551860018655186551865523205236052360518655182051c6051c60518655212051d40518605186551c2051d4051f60518655212051865521605186551a2051865518655
01100000177201772017720177200e7200e7200e7200e720117201172011720117200e7200e7200e7200e720137201372013720137200e7200e7200e7200e720107201072010720107200c7200c7200c7200c720
01100000235001a500235001d5001a5001d5001a500235001d500235001d500235001a535185351d5351c5351f535215351f535185351a5001c5001d5001f50023500215001d50021500185001a500215001a500
01100000232351a435234351d4351a4351d4351a435234351d435234351d435234351a435184351d4351c4351f235214351f435184351a4351c4351d4351f43523435214351d43521435184351a435214351a435
011b0000117221572218722157221172215722187221572213722177221a7221772213722177221a7221772210722137221772213722107221372217722137221172215722187221572211722157221872215722
011b0000117221572218722157221172215722187221572213722177221a7221772213722177221a72217722107221372217722137221072213722177221372215722187221c7221872213722177221a72217722
011b00001155011540115301151018550185401853018520175501753015550155301355013540135301352010550105401053010520155501554017530175201155011540115401153011530115200e53010540
011b0000115501154011530115201855018540185301852017550175301555015530135501354015550175501c5501c5401c5301c52018550185301a5501a5301855018530155501553013550135300e55010550
011b00000552505515055250551505525055150552505615075250751507525075150752507515076250761504525045150452504515045250451504525046150552505515055250551505525055150562505615
011b00000552505515055250551505525055150552505615075250751507525075150752507515076250761504525045150452504515045250451504525046150952509515095250951507525075150562505615
01200000180451f0351d0451c0251a045180551a0451c0551f0201f025370051a0251a0201a0251a0051a005130451a0451804517045150451305515045170551c0201c025210051702517020170251300534005
01200000110401103515045180251704017055180451a0551f0201c0251a0551c02518020180251a0551c0551d0401d0351c0401c0251a0401a0551c0401c0551f0301f0201f0201f0101f015170051300534005
012000000c7250c7250c7250c7250c7250c7250c7250c615077250772507725077250772507725077250761509725097250972509725097250972509725096150472504725047250472504725047250472504615
012000000572505725057250572505725057250572505615007250072500725007250072500725007250061505725057250572505725057250572505725056150772507725077250772507725077250772507615
01200000377253471530725327153471530705307053070537735377253773537725377253771537715377152d72534715307252f7152d7153970539705397053473534725347353472534725347153471534715
0120000029725297152d7252d71530725307152d7252d715307353072530735307253072530715307153071529725297152d7252d71530725307152d7252d7153773537725377353772537725377153771537715
011a00000931509315093150931509315093150931509315053150531505315053150531505315053150531507315073150731507315073150731507315073150431504315043150431504315043150431504315
011a00000931509315093150931509315093150931509315053150531505315053150531505315053150531507315073150731507315073150731507315073150c3150c3150c3150c3150c3150c3150c3150c315
011a000021715217152171521715217152171521715217151d7151d7151d7151d7151d7151d7151d7151d7151f7151f7151f7151f7151f7151f7151f7151f7152471524715247152471524715247152471524715
011d0000021253e1050212502115021250c6350212502115021253e1050212502115021250c635021203e10507125001050712507115071250c635071250711507125041050712507115071250c635071203e105
011d000005125091050512505115051250c635051250511505125021050512505115051250c635051200b10007125001050712507115071250c635071250711507125041050712507115071250c635071200c635
011d00001a0301a0351a0351a0351a0301d035210301d0351f0301f0351d0301d0351c0301c0351d0301d0351f0301f0351f0351f0351f0302303526030260352403024035230302303521030210302103021035
011d00001d0301d0351d0351d0351d030210352403021035230302303521030210351f0301f0352103021035230412303023030230251c0401c0301c0301c0252404124030240302402523040230302103021025
011d00000e2121121515215112150e212112151521511215112121521518215152151121215215182151521513212172151a2151721513212172151a215172151121215215182151521511212152151821515215
011d0000112121521518215152151121215215182151521513212172151a2151721513212172151a2151721510212132151721513215102121321517215132151121215215182151521511212152151821515215
00020000243701d3701835115351103510e351003513f452043523e452083523d452123523c4521f3520035237452023523045206352294520b352214521d4521945215452124520f4520c452094520645203452
000500000a2100a2100f2100c2100f2200f2201222013220142301623017230192301b2401c2401e24020240222502925026250282502a25031250302503725034250372503b250362503d250392503b2503d250
010c00002424200202002022424224242172022024214202202420020220242002022224200202222421820222242002022424200202262420020228242002022924229242292422924229242292422924229242
010c00002924229242292422924229242292422924229242202020020220202002022220200202222021820222202002022420200202262020020228202002022920229202292022920229202292022920229202
000200002c7502f750317503275033750327502f7502c750297502675026750257502575026750277502b7502d750307503375036750387503a7503b7503d7503e7503e7503f7503f7503f7503f7503f7503f750
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000130501f0500d0501a0501f0501c0501f0501a050210501a0501f0501f0501f0501f0501a050210501a0502105022050210501f050210501a0501f0501a0501f050210501a0502105022050210501f050
__music__
01 0f115344
02 10124344
01 16174344
01 13151844
02 14151944
03 1a1b1c1d
01 1f212344
02 20222444
01 25272944
02 26282a44
01 2b6c4344
02 2c424344
01 302e3244
02 312f3344
01 36424344
00 37424344

