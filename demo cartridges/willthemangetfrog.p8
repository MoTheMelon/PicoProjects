--will the man get frog
--by marechalbanane & c.diffin

__lua__
c_tk=",/'-$"
function rzipped(a)
local l,s,c=peek2(a),"",0
a+=2
for i=1,l do
local t=peek2(a)>>c&31
c+=5
c%=8
if (c<5) a+=1
if t>=26 then
s..=c_tk[t-25]
else
s..=chr(t+97)
end
end
return s,a+1
end

g_ra=peek2(0x30fe)
c_vbs,g_ra=rzipped(g_ra)
c_kig,g_ra=rzipped(g_ra)

function isstring(a)return type(a)=="string"end
function decl(s,o)
local d=split(s,"$")
for i=1,#d,2 do
local v=d[i+1]
if v=="true" then
v=true
elseif v=="false" then
v=false
elseif v=="nil" then
v=nil
elseif v=="{}" then
v={}
elseif isstring(v) and #v>2 and v[2]=="_" and (v[1]=="g" or v[1]=="c") then
v=_ENV[v]
end
(o or _ENV)[d[i]]=v
end
end

decl"c_x$0$c_o$1$c_dsktp$false"

function functxt(s)
local r,u
for l in all(split(s,"/")) do
l=split(l,";")
for i,li in inext,l do
l[i]=_ENV[li] or li
end
r,u=deli(l,1)(unpack(l))
end
return r,u
end

function unzipspr(d,s)
local l,v,t=(peek2(s)&0xfff)-2,0,true
d+=(peek2(s)>>12&0xf)*0x200
for i=2,l+1do
local m=peek(s+i)
local c,l2=m&0xf,(m>>4&0xf)+1
for j=1,l2 do
if t then
v=c
else
v|=c<<4
poke(d,v)
v=0
d+=1
end
t=not t
end
end
end

function unzipmap(d,s)
local l=peek2(s)
for i=2,l+1,3do
local ls,t1,t2=peek(s+i,3)
local l1,l2=ls&15,ls>>4&15
memset(d,t1,l1)
memset(d+l1,t2,l2)
d+=l1+l2
end
end

function fyates(t,si)
si=si or 1
for i=si+1,#t do
local j=i+flr(rnd(#t-i+1))
t[j],t[i-1]=t[i-1],t[j]
end
end

c_catc=split"11,13,12,9,4,8,10,3"
c_ts={
split"1,7,6,1,1,11,8,4,5,-41,2",
split"14,6,1,1,1,10,10,1,7,-42,3",
split"10,7,1,1,7,8,0,1,5,-43,4",
split"12,6,1,1,1,3,9,13,7,-42,5",
split"0,6,6,0,0,12,7,5,1,-42,7",
split"1,7,1,1,1,9,7,13,1,-42,1"}

c_tp={
{split"66,72,1.2,35,0,18,16,1.98,1.98,.3333,0"},
{split"64,66,1.2,17,0,18,16,1.98,1.98,.3333,0"},
{split"63,66,1.2,0,0,17,17,1.98,1.98,.3333,0"},
{split"64,66,1.2,53,0,18,16,1.98,1.98,.3333,0"},
{split"56,65.5,1.2,15,16,18,16,0,1,.3333,0"},
{split"64,75,1.2,71,11,16,14,0,0,0,0,8",split"64,30.5,1.5,87,11,16,8,0,1,.3333,0,1"}}
c_tl={split"66,58,1,114,0,14,11,0,0,0,0",
split"64,58,1,71,0,13,11,0,0,0,0",
split"66,58,1,100,0,14,11,0,0,0,0",
split"64,58,1,84,0,16,11,0,0,0,0",
split"69,58,1,33,16,15,11,0,0,0,0",
split"64,58,1,103,11,16,11,0,0,0,0,8"}
c_tpd={split"64,82,1,71,11,16,12,0,0,0,0,8",
split"64,30.5,1.5,87,11,16,8,0,2,.2,0,1",
split"42,11,1.5,0,32,80,18",
split"86,15,1.5,80,40,8,10",
split"18,31,1.5,0,50,25,20",
split"48,31,1.5,25,50,31,20"}

c_fireworks={"-6,-24,1.1,6,9,4,3,.1,22","20,-20,1.1,7,12,1,3,1.8,20","47,-16,1.1,8,8,2,3,.7,34"}
c_pat=split"0x200.8,0xa0a.8,0x5a5a.8,0x5f5f.8,0xffdf.8,0xffff.8"
c_asongs,c_bsongs=split"2,17,4,14,22,29",split"3,19,9,15,24,30"
c_music_addr=split"0x3109,0x310c,0x3149,0x314c,0x3121,0x3124,0x3139,0x313c,0x315d,0x3160,0x3175,0x3178"
c_amem,c_bmem=split"147,17,234,41,156,24,162,33,151,22,141,8",split"19,145,106,169,28,152,34,161,23,159,13,136"
decl"c_v$v2.4$c_date$28.02.25$c_s_title$0$c_s_credits$1$c_s_pass$2$c_s_kigo$3$c_s_pick$4$c_s_help$5$c_s_compo$6$c_s_go$7$c_cf_none$0$c_cf_reset$1$c_cf_confirm$2$c_none$0$c_kb$1$c_pad$2$c_mouse$3$c_cw$3$c_ch$5$c_hmargin$2$c_vmargin$1$c_blankw$6$c_fly$40$c_buttonx$24$c_buttony$6$c_rectime$180$c_pwc$0$g_prndi$1$c_prnd${}"

for i=1,1024do c_prnd[i]=rnd(1)end

p,cl=print,color

function pb(b,t,a,a2,a3)
local x,y,c,s=a,a2,a3,b+16
if g_sch==c_mouse then
s=27
if b==c_o then
pal{8,6}
else
pal{6,8}
end
elseif g_sch==c_pad then
s+=2
end
if not a2 then
c=a
x=peek(24358)
y=peek(24359)
end
if (c) cl(c)
if c_dsktp or g_sch==c_mouse then
spr(s,x,y-1)
elseif b==c_x then
p("❎",x,y)
else
p("🅾️",x,y)
end
pal()
if t then
p(t,x+8,y)
end
end

function prnd(n)
    local v=c_prnd[g_prndi]*n
    g_prndi=smod(g_prndi,1,#c_prnd)
    return v
end

function smod(v,a,m)v+=a return (v-1)%m+1 end
function bp(b,s) return not g_sw and (btnp(b) or b==4 and m(1) or b==5 and m(2) or not s and g_btnt[b]>31 and g_btnt[b]%8==0)end
function togglebgs()
    sfx(63)
    g_bgs=not g_bgs
    dset(1,g_bgs and 1 or 0)
    if g_rectimer>0 then
        recf()
    end
    bgmi()
end

function togglemus()
    sfx(63)
    g_mon=not g_mon
    dset(0,g_mon and 0 or 1)
    if g_mon then
        if g_state>=c_s_compo then
            playmusic(g_sng[g_ti])
        else
            playmusic(g_state==c_s_title and 0 or 1)
        end
    else
        stopmusic()
    end
    if g_music then
        g_music.s=g_mon and 7 or 8
    end

    musmi()
end

function togglelang()
    g_langfr=not g_langfr
    dset(2,g_langfr and 1 or 0)
    load(g_langfr and "#willthemangetfrog_fr" or "#willthemangetfrog")
end

function gettextw(s)
    if (s==" ") return 1
    if (#s>=6 and sub(s,#s-5)=="\^x2...") return gettextw(sub(s,1,#s-6))+8
    return #s*(c_cw+1)-1
end

function iof(t,v)
    if t then
        for i=1,#t do
            if (t[i]==v) return i
        end
    end
    return -1
end

function wequal(a,b)
    local o=type(a)
    if o~=type(b) then
        return false
    elseif o=="string" then
        return a==b
    elseif #a~=#b then
        return false
    else
        for o=1,#a do if (a[o]~=b[o])return false end
        return true
    end
end

function repos(wh,c0)
local i,w,f=1,wh.chdrn
while c0 and i<=#w do
f=w[i]==c0
if (f) break
i+=1
end

while i<=#w do
local c=w[i]
local x,y=-wh.hw+c.hw,-wh.hh+c.hh
if i>1 then
local p=w[i-1]
x=p.tx+p.hw+1+c.hw
y=p.ty
end

local xr=x+c.hw

if wh.cw and i==#w-1 and g_state~=c_s_go then
xr+=1+w[#w].w
end

if xr>=wh.hw then
x=-wh.hw+c.hw
y+=c.h+1
end

c.tx,c.ty=x,y
i+=1
end
end

function pick(x,y,c,c2,i,s)
local d=g_dicos[c]
local w,f=d[i],true

while f do
f=false
for j=1,#g_wb.chdrn do
local w2=g_wb.chdrn[j]
if wequal(w,w2.word) then
f,w,i=true,d[i+1],i+1
break
end
if (w2.cat>c2)break
end
end

local l=_lbl(x,y,0,d[i],c==1)
l.cat=c
g_wb:addchild(l,findwordinserti(l))
if not s then
repos(g_wb,l)
sfx(55)
end
i+=1
return i
end

function findblank(s,t,ns,d)
local function it(inc)
local i0,i1,fs=1,#t
if inc<0 then
i0,i1=i1,i0
end
for i=i0,i1,inc do
local l=t[i].chdrn
local j0,j1=1,#l
if inc<0 then
j0,j1=j1,j0
end
for j=j0,j1,inc do
local w=l[j]
if w==s then
fs=true
end
if w:isblank() and fs and (w~=s or not ns) then
while j>1do
if l[j-1]:isblank() then
j-=1
else
break
end
end
return l[j]
end
end
end
return nil
end

return it(d) or it(-d)
end

function dc() return functxt"_ctrl;0;0;0;0;0" end

function _ctrl(x,y,z,w,h,p)
local c={
x=x,
y=y,
z=z,
tx=x,
ty=y,
w=w,
h=h,
hw=w/2,
hh=h/2,
chdrn={},
wp=function(c)
local x,y,p=c.x,c.y,c.parent
while p do
x+=p.x
y+=p.y
p=p.parent
end
return x,y
end,
wtp=function(c)
local x,y,p=c.tx,c.ty,c.parent
while p do
x+=p.tx
y+=p.ty
p=p.parent
end
return x,y
end,
findnextseli=function(c,i,t)
local r=-1
while i>=1 and i<=#c.chdrn do
local n=c.chdrn[i]
if n.selectable and not n.autodestroy then
r=i
break
end
i+=t
end
return r
end,
draw=function(c) end,
drawsel=function(c)
local x,y=c:wp()
local sx,sy=x-c.hw-1,y-c.hh-1
rect(sx,sy,sx+c.w+1,sy+c.h+1,flr(prnd(16)))
end,
addchild=function(p,c,i)
if not c.parent then
i=i or #p.chdrn+1
add(p.chdrn,c,i)
c.parent=p
local x,y=p:wp()
local tx,ty=p:wtp()
c.x-=x
c.y-=y
c.tx-=tx
c.ty-=ty
end
end,
remchild=function(p,c)
if c.parent==p then
del(p.chdrn,c)
c.parent=nil
local o,t=p:wp()
local n,l=p:wtp()
c.x+=o
c.y+=t
c.tx+=n
c.ty+=l
end
end,
destroy=function(c)
c:destroychildren()
if c.parent then
c.parent:remchild(c)
end
del(g_ctrls,c)
end,
destroychildren=function(c)
for i=#c.chdrn,1,-1do
c.chdrn[i]:destroy()
end
end,
clicko=function(c) end,
clickx=function(c) end
}

decl("mm_u$1$mm_d$1$mm_l$1$mm_r$1$autodestroy$false$selectable$false$enabled$true",c)

if p then
local x,y=p:wp()
local tx,ty=p:wtp()
c.tx+=tx
c.ty+=ty
c.x+=x
c.y+=y
p:addchild(c)
end

local i=1
while i<=#g_ctrls and c.z<=g_ctrls[i].z do
i+=1
end

add(g_ctrls,c,i)

return c
end

function _rect(x,y,z,w,h,c,p)
local r=_ctrl(x,y,z,w,h,p)
r.draw=function(s)
local wx,wy=s:wp()
local x0,y0,x1,y1=wx-s.hw,wy-s.hh,wx+s.hw-1,wy+s.hh-1
rectfill(x0,y0,x1,y1,c)
if s.oc then
line(x0,y0,x0,y1,s.oc)
line(x0,y0,x1,y0,s.oc)
line(x0,y1,x1,y1,s.oc)
line(x1,y0,x1,y1,s.oc)
end
end

return r
end

function _text(x,y,z,t,c,pa)
local w=gettextw(t)
local r=_ctrl(x,y,z,w,c_ch,pa)
r.draw=function(c)
local x,y=c:wp()
p(t,x-c.hw,y-c.hh,c)
end

return r
end

function _hln(x,y,w,h,p)
local r=_ctrl(x,y,0,w,h,p)
r.cw=function(h)
local c=0
for i=1,#h.chdrn-1 do
if not h.chdrn[i]:isblank() then
c+=1
end
end
return c
end

return r
end

function _btn(x,y,s,w,h,d,f,p)
local b=_ctrl(x,y,0,w,h,p)
b.selectable,b.clicko,b.s,b.desc=true,f,s,d
b.draw=function(c)
local x,y=c:wp()
local pl={[14]=c_ts[g_ti][3]}

if s==15 then
if not c.enabled then
pl[11]=5
else
pl[14]=7
end
end

pal(pl)
spr(c.s,x-c.hw,y-c.hh,c.w/8,c.h/8)
pal()
end

return b
end

function _lbl(x,y,z,wo,k,pa)
local t=wo or {""}
t=t[1]
local tw=gettextw(t)
local l=_ctrl(x,y,z,tw+2*c_hmargin,c_ch+2*c_vmargin,pa)
l.word,l.text,l.textw,l.iskigo=wo,t,tw,k
decl("removable$true$selectable$true$wi$1$margin$c_hmargin",l)
l.isblank=function(c)
return not c.word
end
l.settext=function(c,t,m)
c.margin,c.text,c.textw=m or c.margin,t,gettextw(t)
c.w=c.textw+2*c.margin
c.hw=c.w/2
end
l.draw=function(c)
local th,x,y=c_ts[g_ti],c:wp()
if g_state~=c_s_go then
local tx,ty=x-c.hw,y-c.hh
rectfill(tx,ty,tx+c.w-1,ty+c.h-1,th[2])
end
p(c.text,x-c.textw/2,y-c_ch/2,g_state==c_s_go and th[5] or (c.iskigo and th[6] or th[4]))
end
l.clicko=function(c)
if g_state==c_s_compo or g_state==c_s_pass then
local ls=g_state==c_s_pass and {g_passln} or g_hln
if c.parent==g_wb then
if g_curw then
local x,y=c:wp()
local px,py=g_curw.parent:wp()
g_curw.word=c.word
g_curw.wi=c.wi
g_curw.iskigo=c.iskigo
g_curw:settext(c.text,c.margin)
g_curw.x=x-px
g_curw.y=y-py
repos(g_curw.parent,g_curw)
g_curw=findblank(g_curw,ls,true,1)
sfx(55)
end
elseif c:isblank() then
if g_curw~=c then
g_curw=c
sfx(59)
end
elseif c.removable then
sfx(56,-1,0,3)
local iw,l=-1
for i=1,#ls do
iw=iof(ls[i].chdrn,c)
if iw>0 then
l=ls[i]
break
end
end
if l then
local x,y=l:wp()
local bl=_lbl(x+c.x,y+c.y,c.z,nil,false)
bl:settext("",c_blankw)
l:remchild(c)
l:addchild(bl,iw)
repos(l)
g_curw=findblank(bl,ls,false,-1)
g_sel=bl
end
local r=prnd(1)
c.tx,c.ty=64+96*cos(r),64+96*sin(r)
if c.parent then
local x,y=c.parent:wtp()
c.tx-=x
c.ty-=y
end
c.autodestroy=true
end
updatemusicside()
end
end
l.clickx=function(c)
local w,p=c.word,{g_wb}
if not c:isblank() and #w>1 then
sfx(58)
c.wi=smod(c.wi,1,#w)
c:settext(w[c.wi])
if g_hln then
for i=1,3do add(p,g_hln[i]) end
end
if g_passln then
add(p,g_passln)
end
for i=1,#p do
if c.parent==p[i] then
repos(c.parent,c)
break
end
end
end
end

return l
end

function _prop(d,s)
local x,y,z,sx,sy,w,h,mx,my,mr,mp,ac=unpack(d)
if #d>=8 then
w*=8
h*=8
end
local r=_ctrl(x,y,z,w,h,s)
r.draw=function(c)
local x,y=c:wp()
if mx then
local t,rx,ry=(t()-mp)*mr,mx,my
if (g_bgs) rx,ry=0,0
if (ac) palt(1<<ac-1)
map(sx,sy,x-c.hw+rx*cos(t),y-c.hh+ry*sin(t),w/8,h/8)
palt()
else
sspr(sx,sy,w,h,x-c.hw,y-c.hh)
end
end

return r
end

c_ppals=split"11,4,3,13,4,3,12,4,3,9,4,5,4,2,2,8,4,2,10,4,5,3,5,5"
function _picker(x,y,d,n,ct,pa)
local c=_ctrl(x,y,0,8,8,pa)
decl("dicoi$1$selectable$true$mm_d$11$mm_l$16$mm_r$15",c)
c.draw=function(c)
local x,y=c:wp()
local i=(ct-1)*3+1
pal{c_ppals[i],c_ppals[i+1],c_ppals[i+2]}
spr(0,x-c.hw,y-c.hh)
pal()
p(n,x-(#n*4-1)/2,y+8,6)
end
c.clicko=function(c)
local x,y=c:wp()
c.dicoi=pick(x,y,ct,1,c.dicoi)
if c.dicoi>#d then
local t=g_pickctrls.chdrn
local i=iof(t,c)
g_sel=i<#t and t[i+1] or t[i-1]
c:destroy()
end
end

return c
end

function setscheme(s)
if s~=g_sch then
if g_sch==c_none then
g_tprops[1].ty+=65
g_sw=true
sfx(63)
elseif c_dsktp then
g_sw=true
sfx(63)
end
g_sch=s
if g_sch~=c_mouse and not g_sel then
for c in all (g_ctrls)do
if c.selectable and not c.autodestroy then
g_sel=c
break
end
end
end
end
end

function resetgvariables(noflush)
if (not noflush)g_ctrls={}
g_pickctrls,g_fl,g_upbtns=dc(),dc(),dc()
decl"g_themectrls${}$g_curw$nil$g_passln$nil$g_haiku$nil$g_hln$nil$g_sel$nil$g_prevsel$nil$g_prevbg$nil$g_nextbg$nil$g_confirm$nil$g_rec$nil$g_reset$nil$g_music$nil$g_letter$nil$g_password$nil$g_passbg1$nil$g_passbg2$nil$g_passtext$nil$g_rectimer$0$g_winmusictimer$0$g_ti$1$g_doskip$false$g_canrec$false$g_3rdline$false$g_confsource$0"
updatemusicside()
end

function addwordbankbg()
local t=c_ts[g_ti]
g_wbbg1,g_wbbg2=_rect(64,76,.5,128,2,t[8],g_fl),_rect(64,126,.5,128,98,t[9],g_fl)
functxt"add;g_themectrls;g_wbbg1/add;g_themectrls;g_wbbg2"
end

function initdicos()
g_dicos={}
for i=1,#c_dicos do
g_dicos[i]={}
for j=1,#c_dicos[i] do
local w=c_dicos[i][j]
g_dicos[i][j]=isstring(w) and {w} or w
g_dicos[i][j].dicoi=j
end
end
end

function randomizedicos()
for i=1,#g_dicos-2do
fyates(g_dicos[i])
end
fyates(g_dicos[#g_dicos-1],c_fixhelp)
end

function spawnwb()
addwordbankbg()
g_wbbg2.y+=64
g_wbbg1.y+=64
g_wb=functxt"_ctrl;64;104;0;126;50;g_fl"
end

function newgame_standard(noflush)
resetgvariables(noflush)

functxt"initdicos/randomizedicos/spawnwb/decl;g_state$c_s_kigo"

g_pickctrls=dc()
g_sel=_picker(64,40,g_dicos[1],"kigo",1,g_pickctrls)
g_sel.y-=96
end

function playmusic(p,f)music(p,f,7)end
function stopmusic()functxt"playmusic;-1/decl;g_winmusictimer$0" end

function gototitle()
functxt"loadspr;1/resetgvariables"
decl"g_state$c_s_title$g_canproceed$nil$g_sch$c_none$g_tprops${}"
for i=1,#c_tpd do
add(g_tprops,_prop(c_tpd[i]))
end

g_tprops[1].y+=190
for c in all(g_tprops)do
c.y-=70
end

if (g_mon)functxt"playmusic;0;3000"
end

function _init()
functxt("cartdata;marechalbanane_willthemangetfrog/extcmd;set_title;Will The Man Get Frog "..c_v.."/poke;0x5f2d;1/poke;0x5f59;0x74/poke;0x5f36;0x40/poke;0x5f5c;0xff")
g_mon,g_bgs,g_langfr=dget(0)==0,dget(1)==1,dget(2)==1
if (g_langfr and c_cartlang!="fr") load"#willthemangetfrog_fr"

c_mnm,c_punc={k_stg,k_shg,k_lang,k_crd},split("./,/;/:/?/!/\^x2.../ ","/")

decl"g_tf$0$g_mmt$1$g_bipt$0$g_banks${}$g_tkad$0"
g_omx,g_omy,g_oldm=functxt"stat;32",functxt"stat;33,",functxt"stat;34"

while peek4(g_tkad)~=0xfedc.ba98 and g_tkad<0x2000 do
g_tkad+=4
end
local a,c=g_tkad+5,peek(g_tkad+4)&0xf
for i=1,c do
add(g_banks,a)
a+=peek2(a)&0xfff
end

functxt"memcpy;0x8000;0;0x3100"

unzipmap(0x2000,0x8000+a)

parsedicos()

functxt"decl;g_modei$1/loadspr;6/gototitle/musmi/bgmi"
end

function findc(c,ux,uy)
local bs,sq,r=-32000,sqrt
for i=1,#g_ctrls do
local v=g_ctrls[i]
local vx,vy=v:wtp()
local cx,cy=c:wtp()
local dx,dy=vx-cx-ux*c.hw,vy-cy-uy*c.hh
if v~=c and v.selectable and not v.autodestroy and dx*ux+dy*uy>0 then 
local sdx,sdy=max(0,abs(dx)-v.hw)/16,max(0,abs(dy)-v.hh)/16
local s=-sq(sdx*sdx+sdy*sdy)
if s>=bs then
bs=s
r=v
end
end
end

return r
end

function arelinesfull()
for i=1,#g_hln do
if g_hln[i]:cw()<#g_hln[i].chdrn-1 then
return false
end
end
return true
end

function iskigoplaced()
for i=1,#g_hln do
local l=g_hln[i].chdrn
for j=1,#l do
if l[j].iskigo then
return true
end
end
end
return false
end

function _fw(d,p)
local x,y,z,r,c,c2,tt,ph,d=unpack(split(d))
local f,ts,tri=_ctrl(x,y,z,32,64,p),{},0
f.draw=function(n)
local wx,wy=n:wp()
local ti=(g_t+ph)%tt/tt
local function maket(t,n,d,f)
t=mid(0,(t-n)/d,1)
return f and f(t) or t
end
for tr in all(ts)do
pset(wx,tr,5)
end
local yt=wy-d*maket(ti,0,.5,sqrt)
ts[tri+1]=g_tf%10==0 and ti<.5 and yt or -1
tri+=1
tri%=40
for i=1,#ts do
ts[i]-=abs(ts[i]-wy+d)*.001
end
if ti<.5 then
pset(wx,yt,4)
else
local fd,c=split"0,.12,.2,.1,.15,.2,.85,.72,.64",{c,c2,0}
for i=1,3do
local tii=ti-fd[i]
local tr,td=maket(tii,.5,fd[i+3],sqrt),maket(tii,fd[i+6],.12)
if (td>0) fillp(c_pat[ceil(td*#c_pat)])
if (tr>0) circfill(wx,wy-d+5*maket(tii+(i>1 and .05 or 0),.6,.4,function(t)return t*t end),r*tr,c[i])
fillp()
end
end
end
end

function applytheme(nomove)
for i=1,#g_themectrls do
g_themectrls[i]:destroy()
end

decl"g_themectrls${}"

if g_state~=c_s_go then
addwordbankbg()
end

for i=1,#c_tp[g_ti]do
local p=_prop(c_tp[g_ti][i])
if i==1 and g_ti==5 then
for d in all(c_fireworks)do
_fw(d,p)
end
end
add(g_themectrls,p)
end

g_letter=_prop(c_tl[g_ti],g_fl)
if g_3rdline then
g_letter.ty-=8
end

functxt"add;g_themectrls;g_letter"

if g_mon then
playmusic(g_sng[g_ti])
end

if not nomove then
g_fl.y+=96
g_upbtns.y-=16
end

local t=c_ts[g_ti]
if g_password then
g_passbg1=_rect(0,t[10],1.1,96,2,6,g_letter)
g_passbg2=functxt"_rect;0;4;1.15;96;9;7;g_passbg1"
g_passbg2.oc,g_passtext=6,functxt"_text;0;0;1.13;g_password;1;g_passbg2"
end

loadspr(t[11])
end

decl"c_ms_mid$1$c_ms_up$2$c_ms_down$3$g_mstate$1"
function updatefrontlayery()
if g_wb then
local t=g_wb.chdrn
local ty=40+(t[1].ty-t[#t].ty)
if g_state==c_s_pick or g_state==c_s_help then
g_fl.ty=min(0,ty)
elseif g_state==c_s_compo then
if g_sch==c_mouse then
local x,y=g_wbbg1:wtp()
if g_my<11 or g_confsource~=c_cf_none then
g_mstate=c_ms_up
elseif g_my>125 then
g_mstate=c_ms_down
elseif g_mstate==c_ms_up and g_my>=11 or g_mstate==c_ms_down and g_my<y-2 then
g_mstate=c_ms_mid
end

local v={0,c_fly,ty}
g_fl.ty=v[g_mstate]
elseif g_sel and g_sel.parent~=g_wb then
g_fl.ty=c_fly
else
local x,y=g_sel:wtp()
if g_sel.ty==g_wb.chdrn[1].ty then
g_fl.ty=0
elseif y>128 then
g_fl.ty-=8
end
end
end
end 
end

function disablectrls(c)
for i=1,#c.chdrn do
c.chdrn[i].selectable=false
end
end

function boom(c,y)
c.ty,c.autodestroy=y,true
end

function setmargin(c,m)
for i=1,#c.chdrn do
local w=c.chdrn[i]
w:settext(w.text,m)
end
repos(c)
end

function onconfirm()
functxt"boom;g_confirm;-64/boom;g_nextbg;-64/boom;g_prevbg;-64/boom;g_wbbg1;140/boom;g_wbbg2;140/boom;g_wb;130"

g_rec=_btn(c_buttonx+4,c_buttony,14,8,8,k_gif,function(c)
functxt"sfx;61/stopmusic"
g_rectimer=c_rectime+10
g_upbtns.ty-=64
g_upbtns.y-=64
end,g_upbtns)

g_sel,g_fl.ty,g_state=g_rec,c_fly+8,c_s_go
g_music.tx-=27

disablectrls(g_wb)
for i=1,#g_hln do
disablectrls(g_hln[i])
fusewords(g_hln[i])
setmargin(g_hln[i],1.5)
end

if (g_mon)functxt"playmusic;21/decl;g_winmusictimer$295"
end

function drawtext(b)
    local x,y=b:wp()
    p(b.desc,x-gettextw(b.desc)/2,y-c_ch/2,c_ts[g_ti][3])
end

function endconf()
    g_confno:destroy()
    g_confyes:destroy()
    decl"g_sel$g_prevsel$g_confsource$c_cf_none"
end

function startconf(s)
g_confyes=_btn(66,15,0,c_confyesw,7,k_yes,function()
if g_confsource==c_cf_reset then
sfx(63)
g_wb:destroy()
gototitle()
elseif g_confsource==c_cf_confirm then
endconf()
onconfirm()
end
end)
g_confno=_btn(81,15,0,c_confnow,7,k_no,function()
endconf()
sfx(55)
end)
g_confsource,g_prevsel,g_confyes.draw,g_confno.draw,g_sel=s,g_sel,drawtext,drawtext,g_confno
sfx(63)
end

function gotocompo()
g_haiku=functxt"_ctrl;68;30;0;0;0;g_fl"
g_hln={    functxt"_hln;0;0;96;16;g_haiku",
functxt"_hln;0;18;96;16;g_haiku",
functxt"_hln;0;36;96;16;g_haiku"}

local l={5,7,5}
for i=1,#g_hln do
local c=g_hln[i]
for j=1,l[i]do
_lbl(0,128,0,nil,false,c):settext("",c_blankw)
end
local p=_lbl(0,128,0,c_punc,false,c)
p:settext(p.text,1)
p.removable=false
repos(c)
end

g_ti,g_curw,g_state,g_doskip=flr(rnd(#c_ts))+1,g_hln[1].chdrn[1],c_s_compo
applytheme(true)

g_reset=_btn(c_buttonx-18,c_buttony,9,8,8,k_reset,function(e)
sfx(63)
startconf(c_cf_reset)
end,g_upbtns)
g_prevbg=_btn(c_buttonx,c_buttony,11,8,8,k_prevb,function(e)
sfx(63)
g_ti=smod(g_ti,-1,#c_ts)
applytheme()
end,g_upbtns)
g_nextbg=_btn(c_buttonx+10,c_buttony,12,8,8,k_nextb,function(e)
sfx(63)
g_ti=smod(g_ti,1,#c_ts)
applytheme()
end,g_upbtns)
g_music=_btn(c_buttonx+20,c_buttony,g_mon and 7 or 8,8,8,k_togm,togglemus,g_upbtns)
g_confirm=_btn(c_buttonx+30,c_buttony,15,8,8,k_conf,function(e)
if arelinesfull() and iskigoplaced() then
startconf(c_cf_confirm)
end
end,g_upbtns)

if g_sel and g_sel.y<g_wb.y-g_wb.hh then
g_sel=g_wb.chdrn[1]
end

g_pickctrls:destroychildren()
g_letter.y+=96
sfx(63)
end

function strcmpaz(a,b)
local a1,af,b1,bf=a[1],a[#a],b[1],b[#b]
if (a1=="-" and b1!="-") return false
if (a1!="-" and b1=="-") return true
if (af=="-" and bf!="-") return false
if (af!="-" and bf=="-") return true
for i=1,min(#a,#b)do
if a[i]~=b[i] then
return a[i]<=b[i]
end
end

return #a<=#b
end

function loadspr(i)
local i=0x8000+g_banks[i]
memset((peek2(i)>>12&0xf)*0x200,0,0x1c00)
unzipspr(0,i)
end

function updatemusicside()
local v,c={},0
if g_hln then
for l in all(g_hln)do
c+=l:cw()
end
end

if c>7 then
g_sng,v=c_bsongs,c_bmem
else
g_sng,v=c_asongs,c_amem
end

for i=1,#c_music_addr do
poke(c_music_addr[i],v[i])
end
end

function autopick()
local x,y,cs,ch,r,as,rs,si,rd=64,140,{},0,rnd(1),{2,4,5},{3,6,7},1,{.5,.85,.95}
pick(x,y,1,0,1,true)
for i=1,8do
cs[i]=c_catwc[i]
end
for i=1,3do
if (r>rd[i]) ch+=1
end
for i=1,ch do
local ai,ri=rnd(as),rnd(rs)
del(as,ai)
del(rs,ri)
cs[ai]+=1
cs[ri]-=1
end
for i=2,7do
local si=1
for j=1,cs[i]do
si=pick(x,y,i,1,si,true)
end
end
for i=1,c_catwc[8]do
si=pick(x,y,8,4,si)
end
repos(g_wb)
end

function recf()
decl"g_rectimer$0$g_canrec$false"
g_upbtns.ty+=64
g_upbtns.y+=64
if g_mon then
playmusic(g_sng[g_ti])
end
end

function m(b,h)
return stat(34)&b~=0 and (h or g_oldm&b==0)
end

function quittitle()
g_tprops[1].ty+=190
for c in all(g_tprops)do
c.autodestroy=true
c.ty-=70
end
functxt"menuitem;3/sfx;63"
if (g_mon)functxt"playmusic;1"
end

function getpw()
local s=""
for i=1,#g_passln.chdrn do
s..=g_passln.chdrn[i].text
if (i<#g_passln.chdrn) s..=" "
end
return s
end

function confpw(e)
local s=0
for i=1,#g_passln.chdrn do
for j=1,#g_wb.chdrn do
if g_passln.chdrn[i].text==g_wb.chdrn[j].text then
s|=j>>16<<(i-1)*5
break
end
end
end
srand(s)
g_password=getpw()
g_passconf:destroy()
g_passln:destroy()
g_wb:destroychildren()
functxt"randomizedicos/autopick/gotocompo"
end

g_btnt={}
decl("0$0$1$0$2$0$3$0$4$5$0",g_btnt)
function _update60()
if (g_sch==c_none and btn(6)) poke(0x5f30,1)

g_t=time()
g_tf+=1

g_bipt+=1

g_mx,g_my=stat(32),stat(33)
g_mmoved=g_omx~=g_mx or g_omy~=g_my
g_mmt=(g_mmoved or m(1) or m(2)) and 0 or g_mmt+.01
if g_mmoved and g_sch==c_mouse then
oldsel,g_sel=g_sel
local cs=g_confsource~=c_cf_none and {g_confyes,g_confno} or g_ctrls
if g_state==c_s_title and g_sch~=c_none then
local om=g_modei
g_modei=mid(1,1+(g_my-74)\7,#c_mnm)
if (om~=g_modei) sfx(59)
else
for c in all(cs)do
if c.selectable and not c.autodestroy then
local x,y=c:wp()
if c~=g_sel and x-c.hw-c.mm_l<=g_mx and x+c.hw+c.mm_r>g_mx and
y-c.hh-c.mm_u<=g_my and y+c.hh+c.mm_d>g_my then
g_sel=c
if g_sel~=oldsel and g_bipt>4 then
sfx(59)
g_bipt=0
end
break
end
end
end
end
end
g_omx,g_omy=g_mx,g_my

local bs=btn()
for i=0,5do
if bs&1<<i~=0 or bs&1<<i+8~=0 or i==4 and m(1,true) or i==5 and m(2,true) then
g_btnt[i]+=1
else
g_btnt[i]=0
end
end

g_sw=false
if m(1) or m(2) then
setscheme(c_mouse)
elseif stat(30) and (bs&0x4040==0 or g_sch==c_none) or bs&0x0f0f~=0 and g_sch~=c_pad then
setscheme(c_kb)
elseif bp(4,true) or bp(5,true) then
setscheme(c_pad)
end

stat(31)

if g_winmusictimer>0 and g_mon then
g_winmusictimer-=1
if g_winmusictimer==0 then
playmusic(g_sng[g_ti])
end
end

for i=#g_ctrls,1,-1do
local c=g_ctrls[i]
local x,y=c.tx-c.x,c.ty-c.y
if x~=0 or y~=0 then
c.x+=x*.2
c.y+=y*.2
if abs(c.tx-c.x)+abs(c.ty-c.y)<1 then
if c.autodestroy then
c:destroy()
else
c.x,c.y=c.tx,c.ty
end
end
end
end

if g_rectimer>0 and g_canrec then
g_rectimer-=1
if g_bgs and g_ti~=5 then
if (g_rectimer==c_rectime)functxt"extcmd;screen/recf()"
else
if (g_rectimer==c_rectime)extcmd"rec"
if (g_rectimer<c_rectime and g_rectimer%60==0)functxt"sfx;59"
if (g_rectimer==0)functxt"extcmd;video/sfx;62/recf"
end
elseif g_state~=c_s_title and g_sel and (g_state~=c_s_help or not g_doskip) then
local c
if g_confsource~=c_cf_none then
if bp(0) then
c=g_confyes
elseif bp(1) then
c=g_confno
end
else
local i,pa=-1,g_sel.parent
local function proc(inc)
if i>0 then
i=pa:findnextseli(i+inc,inc)
if i>0 then
c=pa.chdrn[i]
elseif g_passln and pa==g_passln and inc>0 then
c=g_passconf
elseif g_passconf and g_sel==g_passconf and inc<0 then
c=g_passln.chdrn[#g_passln.chdrn]
elseif g_hln then
if inc>0 then
if pa==g_hln[1] then
c=g_hln[2].chdrn[1]
elseif pa==g_hln[2] then
c=g_hln[3].chdrn[1]
end
else
if pa==g_hln[3] then
c=g_hln[2].chdrn[#g_hln[2].chdrn]
elseif pa==g_hln[2] then
c=g_hln[1].chdrn[#g_hln[1].chdrn]
end
end
end
else
c=findc(g_sel,inc,0)
end
end
if bp(0) or bp(1) then
if (pa) i=iof(pa.chdrn,g_sel)
proc(bp(0) and -1 or 1)
elseif bp(2) then
c=functxt"findc;g_sel;0;-1"
elseif bp(3) then
c=functxt"findc;g_sel;0;1"
end
end

if c and c~=g_sel then
g_sel=c
functxt"sfx;59"
end

if bp(4) then
if g_sel.enabled then
g_sel:clicko()
else
functxt"sfx;56;-1;16;4"
end
elseif bp(5) and g_sel.enabled then
g_sel:clickx()
end
end

local function ns(e)
g_sel,g_state=g_pickctrls.chdrn[1],e
sfx(63)
end

local function mi(e)
g_modei=smod(g_modei,e,#c_mnm)
sfx(59)
end

if g_state==c_s_title then
if g_sch~=c_none then
if (not bp(4)) g_canproceed=true
if bp(2) and g_sch~=c_mouse then
mi(-1)
elseif bp(3) and g_sch~=c_mouse then
mi(1)
elseif bp(4) and g_canproceed then
if g_modei==1 then
functxt"newgame_standard;true/quittitle"
elseif g_modei==2 then
functxt"initdicos/spawnwb/quittitle"

g_passln=functxt"_ctrl;56;40;0;96;8;g_fl"
for i=1,4do _lbl(0,128,0,nil,false,g_passln):settext("",c_blankw)end

for i=1,#g_dicos[#g_dicos] do pick(64,140,#g_dicos,0,i,true)end

g_passconf=_btn(119,39,15,8,8,k_strt,confpw,g_fl)

functxt"repos;g_wb/repos;g_passln"

g_curw,g_sel,g_fl.ty,g_state=g_passln.chdrn[1],g_wb.chdrn[1],8,c_s_pass
elseif g_modei==3 then
togglelang()
elseif g_modei==4 then
sfx(63)
g_tprops[1].ty+=64
g_state=c_s_credits
end
end
end
elseif g_state==c_s_credits then
if bp(4) or bp(5) then
g_tprops[1].ty-=64
functxt"decl;g_state$c_s_title/sfx;55"
end   
elseif g_state==c_s_pass then
updatefrontlayery()
local bc,l=0,#g_passln.chdrn
for i=1,l do
if not g_passln.chdrn[i]:isblank() then
bc+=1
end
end
local lw,e=g_passln.chdrn[4],g_passconf.enabled
g_passconf.tx,g_passconf.enabled=lw.tx+g_passln.tx+lw.hw+6,bc==l
if not e and g_passconf.enabled and g_sch!=c_mouse then
g_sel=g_passconf
end
elseif g_state==c_s_kigo then
if #g_wb.chdrn>0 then
g_pickctrls:destroychildren()
local n={k_pn,k_n,k_adv,k_aux,k_v,k_adj}
for i=0,5do
local c=i+2
local p=_picker(25+i%3*39,24+i\3*20,g_dicos[c],n[i+1],c,g_pickctrls)

p.y-=96
p.x+=(i%3-1)*96
end

ns(c_s_pick)
elseif bp(5) then
functxt"autopick/gotocompo"
end
elseif g_state==c_s_pick then
updatefrontlayery()
if #g_wb.chdrn==1+c_pwc then
g_pickctrls:destroychildren()
local p=_picker(64,40,g_dicos[#g_dicos-1],k_h,8,g_pickctrls)
p.clicko=function()
g_doskip=true
g_skiptimer=0
end

g_pickctrls.chdrn[1].y-=96

ns(c_s_help)
end
elseif g_state==c_s_help then
if g_doskip then
if g_skiptimer%6==0 and #g_wb.chdrn<c_wc then
local p=g_pickctrls.chdrn[1]
local x,y=p:wp()
p.dicoi=pick(x,y,8,4,p.dicoi)
end

g_skiptimer+=1
else
updatefrontlayery()
end   

if #g_wb.chdrn==c_wc then
gotocompo()
end
elseif g_state==c_s_compo then
updatefrontlayery()
g_confirm.enabled=arelinesfull() and iskigoplaced()
end

if g_state>=c_s_compo then
local l=g_hln[2].chdrn
local lw,o=l[#l],g_3rdline and 8 or -8
if g_3rdline and lw.ty<8 or not g_3rdline and lw.ty>8 then
g_3rdline=not g_3rdline
g_haiku.ty+=o
g_hln[3].ty-=o
g_letter.ty+=o
end

local x,y=g_letter:wtp()
if (g_state==c_s_compo) g_upbtns.ty=y<58 and -10 or 0

if g_passbg2 then
g_passbg2.ty=(g_sel and g_sel.parent==g_upbtns or g_sch==c_mouse and g_my<11 or g_state==c_s_go or g_confsource~=c_cf_none) and -4 or 4
end
end

g_oldm=stat(34)
end

function blink(p)
    return flr(g_t/(p or 1))%2==0
end

function canswitch()
    return g_sel and g_sel.word and #g_sel.word>1
end

function _draw()
local th=c_ts[g_ti]
cls(th[1])

local tc,kc=th[3],th[6]
for c in all(g_ctrls)do c:draw()end

if g_wb and g_state~=c_s_pass then
local ws=g_wb.chdrn
for i=1,#ws do
local c=ws[i]
local wx,wy=c:wp()
local x,y=wx-c.hw-1,wy-c.hh
local y2=y+c.h-1
line(x,y,x,y2,c_catc[c.cat])
end
end

if (g_state==c_s_compo or g_state==c_s_pass) and g_curw and blink(.5) then
local x,y=g_curw:wp()
x,y=x-g_curw.hw,y-g_curw.hh
line(x,y,x,y+6,(g_state==c_s_pass or th[2]==1) and 13 or 1)
end

if g_sel and g_rectimer==0 then
g_sel:drawsel()
if g_sel.word and #g_sel.word>1 then
local x,y=g_sel:wp()
spr(10,x-g_sel.hw-3,y-2)
spr(10,x+g_sel.hw-5,y-2,1,1,true)
end
end

if g_state==c_s_title then
if g_sch~=c_none then
p(k_sbt,20,64,tc)
for i=1,#c_mnm do
local c,x,y=tc,24,75+(i-1)*7
if i==g_modei then
c=8
spr(13,blink(.5) and x+10 or x+9,y)
if (g_sch~=c_mouse) pb(c_o,"",x,y)
end
p(c_mnm[i],x+15,y,c)
end
functxt(c_pflag)
elseif blink() then
presskeytext()
end
elseif g_state==c_s_credits then
cl(tc)
local y=77
p(c_v..", "..c_date,12,64)
p("marechalbanane",12,y+7)
p("c.diffin",12,y+25)
pb(c_o,"/",26,120)
functxt("pb;c_x;:"..k_bckt..";38;120/cl;12")
p("code, design, art, sfx",12,y)
p(k_crd2,12,y+18)
elseif g_state==c_s_pass then
passtext(tc,kc)
if g_sel then
cl(tc)
functxt"cursor;8;56"
if g_sel==g_passconf then
pb(c_o,"="..g_sel.desc)
if not g_passconf.enabled then
p(k_incp,c_incpx,56,8)
end       
elseif g_sel.parent==g_passln then
if g_sel:isblank() then
functxt"pb;c_o;k_setc"
elseif g_sel.removable then
functxt"pb;c_o;k_remw"
end
else
functxt"pb;c_o;k_plw"
end
end
elseif g_state==c_s_kigo then
kigotext(tc,kc)
elseif g_state==c_s_pick then
picktext(tc,kc)
if g_fl.ty>=-8 then
p(#g_wb.chdrn-1 .."/"..c_pwc,56,g_fl.y+69,tc)
end
elseif g_state==c_s_help then
helptext(tc,kc)
elseif g_state==c_s_compo then
local blk=true
for i=1,#g_hln do
local l=g_hln[i]
for j=1,#l.chdrn-1do
if not l.chdrn[j]:isblank() then
blk=false
break
end
end
if not blk then
break
end
end

local x,y=g_letter:wtp()
local ln1,ln2,pa=y>=50,y>=58
local tx,ty=ln2 and 70 or 8,2
if (g_sel) pa=g_sel.parent
if pa~=g_upbtns and g_confsource==c_cf_none and ln1 then
local t
cl(tc)
if iskigoplaced() and arelinesfull() then
t=k_done
elseif blk or not g_sel then
t=k_pls
end

if t then
if not ln2 then
local s=split(t,"\n")
t=s[1].." "..s[2]
end
p(t,tx,ty)
else
local tl
if (pa==g_wb) tl=k_plw
if pa==g_hln[1] or pa==g_hln[2] or pa==g_hln[3] then
if g_sel:isblank() then
tl=k_setc
elseif g_sel.removable then
tl=k_remw
end
end
if tl then
pb(c_o,tl,tx,ty)
if ln2 then
ty+=7
else
tx+=56
end
end
if canswitch() then
pb(c_x,k_var,tx,ty)
end
end
end
elseif g_state==c_s_go and g_password then
p(c_v,126-gettextw(c_v),2,tc)
end

if g_confsource~=c_cf_none then
p(k_sure,2,12,tc)
end

if g_sel and g_rectimer==0 then
if iof(g_upbtns.chdrn,g_sel)>0 then
pb(c_o,g_sel==g_rec and g_bgs and g_ti~=5 and k_scr or "="..g_sel.desc,2,12,tc)
end
if g_sel==g_confirm then
local t=""
if not iskigoplaced() then
t=k_knp
elseif not arelinesfull() then
t=k_lnf
end
p(t,2,19,th[7])
end
end

if g_rectimer>0 then
decl"g_canrec$true"
elseif g_mmt<1 then
functxt"spr;25;g_mx;g_my"
end
end

decl"c_pflag$rect;75;88;83;94;6/sspr;81;51;7;5;76;89$c_cartlang$en$c_fixhelp$9$c_incpx$44$c_confyesw$15$c_confnow$11"
c_catwc=split"1,3,7,4,3,7,6,13"
for i=2,7do c_pwc+=c_catwc[i]end
c_wc=c_pwc+c_catwc[1]+c_catwc[8]
c_kig..=",wall/walls,dove/doves"
c_dicos={
split(c_kig),
split("this/these/that/those/there/that's/that'll/there's,i/me/my/mine/i've/i'm/i'd/i'll,you/your/yours/you're/you've/you'd/you'll,he/him/his/he's/he'd/he'll,she/her/hers/she's/she'd/she'll,it/its/it's,they/them/their/theirs/they're/they've/they'd/they'll,we/our/ours/us/we're/we've/we'd/we'll"),
split(c_kig..",awe/awes,guy/guys,gun/guns,rock/rocks,cave/caves,drop/drops,plate/plates,car/cars,girl/girls,boy/boys,man/men,space,life,death,foot/feet,arm/arms,leg/legs,eye/eyes,mouth,nose,ear/ears,hair/hairs,god/gods,gift/gifts,team/teams,itch,clown/clowns,pen,sock/socks,pants,shirt/shirts,fridge,thief/thieves,song/songs,note/notes,tone/tones,box,chest/chests,bag/bags,wheel/wheels,truck/trucks,knife/knives,sword/swords,word/words,lamp/lamps,meat,herbs,hush,ball,truth/truths,friend/friends,foe/foes,glass,prey/preys,swamp/swamps,meal/meals,health,stealth,knee/knees,shed,blood,scratch,war/wars,peace,truce,map/maps,town/towns,scene/scenes,stage,set/sets,game/games,toy/toys,stove/stoves,boat/boats,plane/planes,palm/palms,mount/mounts,stack/stacks,neck/necks,stairs,hell/hells,saint/saints,world/worlds,sponge,hint/hints,sphere/spheres,disk/disks,square/squares,jaw/jaws,tooth/teeth,shout/shouts,lake/lakes,gut/guts,throat/throats,boot/boots,mom/moms,dad/dads,flame/flames,milk,hood/hoods,gold,juice,lip/lips,hip/hips,tongue/tongues,lap/laps,kid/kids,toe/toes,trash,past,beak/beaks,wine,claw/claws,clay,steam,bridge,deck/decks,die/dice,ground/grounds,king/kings,queen/queens,age,thumb/thumbs,axe,bed/beds,sheet/sheets,sound/sounds,knot/knots,fork/forks,spoon/spoons,pitch,base,shield/shields,bass,couch,rug/rugs,line/lines,dot/dots,bull/bulls,bar/bars,gum,jar/jars,stone/stones,bone/bones,land/lands,key/keys,wealth,room/rooms,joke/jokes,beard/beards,soap/soaps,tool/tools,tail/tails,fur/furs,club/clubs,brick/bricks,roof/roofs,glove/gloves,rift/rifts,bond/bonds,paint/paints,branch,pet/pets,paw/paws,mind/minds,soul/souls,cash,pie/pies,shark/sharks,skin/skins,mold,mould/moulds,rage,bot/bots,clock/clocks,cheese,mug/mugs,son/sons,cream/creams,chin/chins,chain/chains,void/voids,maze,thing/things,phase,lime/limes,style/styles,hole/holes,thread/threads,gas,oil/oils,web/webs,sense,hope/hopes,fate/fates,duel/duels,part/parts,sale/sales,end/ends,head/heads,grease,place,bus,prize,price,lot/lots,front/fronts,self/-self,goo,mud/muds,fool/fools,act/acts,trust/trusts,filth,poem/poems,hour/hours,art,smooch,scream/screams,side/sides,hand/hands,phone/phones,witch,goose/geese,ape/apes,mole/moles,crowd/crowds,quest/quests,tag/tags,tale/tales,term/terms,stress,squad/squads,luck/lucks,board/boards,pain/pains,scam/scams,freak/freaks"),
split("as/like,same/too,much/more/most,few/less/-less/least,so/hence/thus,through/via,since/due,by/per,one/two/three/four/five/six/ten/twelve,once/twice/oft,all/half/each,here/now,east/west/north/south,such/quite,some/-some/some-,hey/hi/ha/o/oh/uh/wow/hmm,on/on-/off/off-,in/in-/out/out-,up/up-/down/down-/left/right,if/then/else,yes/sure,next/back,near/soon,with/plus,just,till,still,than,while"),
split"have/has/had,be/am/are/aren't/ain't/is/was/were/been/be-,will/won't/would,can/can't/could,may/might,must/shall/should,do/does/don't/did/done",
split("match/matched,own/owns/owned,store/stores/stored,meow/meows/meowed,bark/barks/barked,spin/spins/span/spun,need/needs,want/wants,"..c_vbs),
split"good/well/best,bad/worse/worst,nice/kind,mean/vile,rude/loud,big/large/huge/grand,thin/lean/slim,black/white/green/blue/red/brown/grey/pink/teal/beige/blonde,strange/weird/odd,short/small,high/tall,wise/sane,smart/sly,dumb/slow,calm/shy/coy,thick/fat/dense,wide/vast/broad,wild/fierce,mild/tame,strong/tough,brave/bold,weak/frail,quick/swift,true/real,false/fake,blind/mute/deaf,cold/cool/chill,hot/warm/bright,sick/ill,soft/smooth,hard/harsh,rough/coarse,old/aged,tight/tense,full/-ful/whole,fair/fine,free/loose,pure/bare/blank,far/long/deep,dear/sweet,dull/bland/bored,rich/lush,poor/sad/ruined,close/nigh,new/fresh/young,lone/sole,proud/vain/smug,bleak/grim,raw/crude,dark/dim,round/plump,wet/soaked,dry/stale,faint/slight,mad/crazed,first/last,sharp/steep,rare/scarce,low/flat,fun/great",
split"the/a/a-/an,not/no/no-/none,for/to/at,of/from,and/or/nor,-ing/-ings,but/yet/though,what/where/when/how/why/who/whom/whose/which,on/on-/off/off-,in/in-/out/out-,up/up-/down/down-/left/right,-ly,-er/-ers/-est,-ness/-dom,-y/-ish,un-/de-/dis-,re-,-en/en-,with/plus,-ed/-es",
split"bad,best,big,break,bus,clown,dark,dear,deep,dream,duck,dumb,eat,for,frog,fruit,full,go,kid,kiss,make,man,no,pink,punch,sing,smile,steak,stick,toe,win"}

decl"k_lang$language:$k_stg$standard game$k_shg$shared game$k_crd$credits$k_gif$capture a gif$k_reset$reset the game$k_prevb$previous background$k_nextb$next background$k_togm$toggle music$k_conf$finish your haiku$k_strt$start!$k_sbt$a haiku writing game$k_bckt$back to title$k_crd2$music, additional code$k_incp$(incomplete password)$k_setc$=set cursor$k_remw$=remove word$k_plw$=place word$k_var$=use variant$k_sure$are you sure?$k_yes$yes$k_no$no$k_scr$=capture screenshot$k_knp$the kigo is not placed!$k_lnf$the lines are not full!$k_done$done! confirm\nin top menu.$k_pls$please compose\na nice haiku.$k_pn$pronouns$k_n$nouns$k_adv$adverbs$k_aux$aux.verbs$k_v$verbs$k_adj$adjectives$k_h$helpers"

function pvariants(tc,kc)
if canswitch() then
p("press    to see the\nof a word. it's very useful!",8,2,tc)
p("variants",88,2,kc)
pb(c_x,"",32,2)
return false
end
return true
end

function kigotext(tc,kc)
cl(tc)
p("welcome! before writing,\nyou need to gather      .\npress    to pick your     .",8,2)
p("the      is the '      ' word.\nit's mandatory in any haiku.",8,85)
p("(  : skip word picking)",20,121)
pb(c_x,"",24,121)
cl(kc)
p("words\n   kigo",84,9)
pb(c_o,"",32,16)
p("kigo         season",24,85)
end

function picktext(tc,kc)
if pvariants(tc,kc) then
p("now fill your          !\n        is important.",16,2,tc)
p("              word bank\nbalance",16,2,kc)
end
end

function helptext(tc,kc)
if pvariants(tc,kc) then
p("awesome! last step:        !\nthey're small       or      .\nit'll help you build          .",4,2,tc)
p("      helpers\nwords    parts\n       sentences",60,2,kc)
end
end

function passtext(tc,kc)
if g_passconf.enabled then
p("perfect! you can now",8,8,tc)
p("start the game!",kc)
else
p("welcome! select four words\nto make a          for\nyour shared game.",8,2,tc)
p("password",48,9,kc)
end
end

function presskeytext()functxt"rectfill;35;82;55;88;1/rectfill;59;82;63;88;1/rectfill;67;82;79;88;1/p;press a key;36;83;7"end

function musmi()menuitem(1,g_mon and "music:on" or "music:off",togglemus)end
function bgmi()menuitem(2,g_bgs and "moving bg:off" or "moving bg:on",togglebgs)end
function vowel(e)return e=="a" or e=="e" or e=="i" or e=="o" or e=="u" or e=="y" or e=="w"end
function fusewords(l)
for i=#l.chdrn-1,1,-1do
local w=l.chdrn[i]
local t=w.text
if t[#t]=="-" then
local p=sub(t,1,#t-1)
if i==#l.chdrn-1 then
w:settext(p)
else
local n=l.chdrn[i+1]
if (n.text[1]=="-") n:settext(sub(n.text,2,#n.text))
n:settext(p..n.text)
w:destroy()
end
end
end

local i=1
while i<#l.chdrn do
local w=l.chdrn[i]
if w.text[1]=="-" then
local s=sub(w.text,2)
if i==1 then
w:settext(s)
else
local pw=l.chdrn[i-1]
local nt=pw.text
local lc=nt[#nt]
local nv=#nt>2 and not vowel(nt[#nt-1])
if vowel(s[1]) then
if doublelastc(nt,lc) then
nt..=lc
elseif (lc==s[1] and s[1]~="y") or lc=="e" and nv then
nt=sub(nt,1,#nt-1)
if (s=="ing" and nt[#nt]=="i") nt=sub(nt,1,#nt-1).."y"
end
elseif #nt>2 then
local e=sub(nt,#nt-3,#nt)
if (lc=="y" and (e=="day" or nv)) nt=sub(nt,1,#nt-1).."i"
end
nt..=s
pw:settext(nt)
w:destroy()
i-=1
end
end
i+=1
end

local c0,c1=l.chdrn[#l.chdrn],l.chdrn[#l.chdrn-1]
c0:destroy()
c1:settext(c1.text..c0.text)
end

function doublelastc(w,lc)
local l=#w
if l<3 then
return false
else
return     not vowel(w[l]) and
vowel(w[l-1]) and
not vowel(w[l-2]) and
not (w[l-1]=="e" and (lc=="r" or lc=="n"))
end
end
function findwordinserti(w)
local t,i,c=g_wb.chdrn,1
if (#t==0) return 1

while i<=#t do
c=t[i]
if w.cat<=c.cat then
break
end
i+=1
end

while i<=#t do
c=t[i]
if strcmpaz(w.word[1],c.word[1]) or w.cat<c.cat then
break
end
i+=1
end

return i
end

function parsedicos()
for i=1,#c_dicos do
local d=c_dicos[i]
for j=1,#d do
local w=d[j]
if iof(w,"/")>0 then
d[j]=split(w,"/")
end
end
end
end
