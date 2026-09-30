local L=loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local O,T=L.Options,L.Toggles
local P,W,RS,R=game:GetService("Players"),game:GetService("Workspace"),game:GetService("ReplicatedStorage"),game:GetService("RunService")
local LP,Cam=P.LocalPlayer,W.CurrentCamera
local UIS=game:GetService("UserInputService")
local GE,MT,CE=RS:FindFirstChild("GrabEvents"),RS:FindFirstChild("MenuToys"),RS:FindFirstChild("CharacterEvents")
local SN,ST,DT,RG,SG=GE and GE:FindFirstChild("SetNetworkOwner"),MT and MT:FindFirstChild("SpawnToyRemoteFunction"),MT and MT:FindFirstChild("DestroyToy"),CE and CE:FindFirstChild("RagdollRemote"),CE and CE:FindFirstChild("Struggle")
local CG,DG,EG=GE and GE:FindFirstChild("CreateGrabLine"),GE and GE:FindFirstChild("DestroyGrabLine"),GE and GE:FindFirstChild("ExtendGrabLine")
local STN,TOYV,TLO,TLT=nil,3,false,nil
local function N(t,d,tm)L:Notify({Title=t,Description=d,Time=tm or 3})end
local function PLS()local t={}for _,p in ipairs(P:GetPlayers())do if p~=LP then t[#t+1]=p.DisplayName.." (@"..p.Name..")"end end table.sort(t,function(a,b)return a:lower()<b:lower()end)return t end
local function US(s)return s and s:match("%(@(.+)%)$")end
local function MH()local c=LP.Character return c and c:FindFirstChild("HumanoidRootPart")end
local function MU()local c=LP.Character return c and c:FindFirstChildOfClass("Humanoid")end
local function PH(p)if not p then return end local c=p.Character if c and c.Parent==W then return c:FindFirstChild("HumanoidRootPart")end end
local function TP(n,oy)if not n then return end local t=P:FindFirstChild(n)if not t then return end local th=PH(t)if not th then return end local mh=MH()if not mh then return end mh.CFrame=th.CFrame+Vector3.new(0,oy or 3,0)mh.AssemblyLinearVelocity=Vector3.zero mh.AssemblyAngularVelocity=Vector3.zero end
local function STP()if TLT then pcall(task.cancel,TLT)TLT=nil end end
local function STPR()STP()if not STN then return end TLT=task.spawn(function()while TLO do TP(STN,TOYV)R.Heartbeat:Wait()end TLT=nil end)end
local _tk={}
local function reg(t)if t then _tk[#_tk+1]=t return t end end
local function cancelAll()for _,t in ipairs(_tk)do pcall(task.cancel,t)end _tk={}end
local function mkLag(rate)return function()local c,f=nil,0 local b=math.floor(rate/60)local r2=rate-b*60 local function st()if c then c:Disconnect()end c=R.Heartbeat:Connect(function()f=f+1 local sc=b+(f<=r2 and 1 or 0)local sp=W:FindFirstChild("SpawnLocation")or W:FindFirstChild("Spawn")or MH()if sp then for _=1,sc do pcall(function()if CG then CG:FireServer(sp,CFrame.new(math.random(-1e9,1e9),0,math.random(-1e9,1e9)))end end)end end)end local function sp()if c then c:Disconnect()c=nil end end return st,sp end end
local function mkKick(rate)
local stL,spL=mkLag(rate)()
local run,tk=false,nil
local function stop()run=false if tk then pcall(task.cancel,tk)tk=nil end spL()end
local function exec(single)
if run then return end run=true
tk=reg(task.spawn(function()
stL()local H=35 task.wait(single and 1 or .5)
local my=MH()if not my then stop()return end
local list={}
if single then if not STN then stop()return end local tp=P:FindFirstChild(STN)local h=tp and PH(tp)if h then list[1]=h end
else for _,p in ipairs(P:GetPlayers())do if p~=LP then local h=PH(p)if h then list[#list+1]=h end end end end
if #list==0 then task.wait(5)stop()return end
N("Kick",(single and"Target"or("All ("..#list..")")).." kicked",3)
local sp=W:FindFirstChild("SpawnLocation")or W:FindFirstChild("Spawn")
local cx=sp and sp.Position.X or 0 local cz=sp and sp.Position.Z or 0
pcall(function()my.CFrame=CFrame.new(cx,H,cz)my.AssemblyLinearVelocity=Vector3.zero end)
for _,h in ipairs(list)do pcall(function()my.CFrame=h.CFrame*CFrame.new(0,5,5)my.AssemblyLinearVelocity=Vector3.zero end)task.wait(.2)if SN then pcall(function()SN:FireServer(h,h.CFrame)end)end end
local Rr=single and 10 or 80
local step=(math.pi*2)/math.max(#list,1)
for i,h in ipairs(list)do local a=(i-1)*step local x,z=math.cos(a)*Rr,math.sin(a)*Rr if single and i>1 then break end pcall(function()h.CFrame=CFrame.new(cx+x,H,cz+z)h.AssemblyLinearVelocity=Vector3.zero end)local bp=Instance.new("BodyPosition")bp.MaxForce=Vector3.new(9e9,9e9,9e9)bp.P=5e11 bp.Position=Vector3.new(cx+x,H,cz+z)bp.Parent=h task.delay(2,function()pcall(function()bp:Destroy()end)end)task.wait()end
pcall(function()my.CFrame=CFrame.new(cx,H,cz)my.AssemblyLinearVelocity=Vector3.zero end)
for _=1,80 do for _,h in ipairs(list)do task.spawn(function()if CG and DG then pcall(function()CG:FireServer(h,CFrame.new(0,1e9,0))DG:FireServer(h)end)end end)end task.wait(.03)end
task.wait(6)stop()end))
end
return exec,stop
end
local function mkLKA(rad,mult)
local run,tk
local stL,spL=mkLag(1000)()
local function stop()run=false if tk then pcall(task.cancel,tk)tk=nil end spL()end
local function exec()
if run then return end run=true
tk=reg(task.spawn(function()
stL()local H=35 task.wait(.5)
local my=MH()if not my then stop()return end
local list={}for _,p in ipairs(P:GetPlayers())do if p~=LP then local h=PH(p)if h then list[#list+1]=h end end end
if #list==0 then task.wait(5)stop()return end
N("Kick","All ("..#list..") kicked",3)
local sp=W:FindFirstChild("SpawnLocation")or W:FindFirstChild("Spawn")
local cx=sp and sp.Position.X or 0 local cz=sp and sp.Position.Z or 0
pcall(function()my.CFrame=CFrame.new(cx,H,cz)my.AssemblyLinearVelocity=Vector3.zero end)
for _,h in ipairs(list)do pcall(function()my.CFrame=h.CFrame*CFrame.new(0,5,5)my.AssemblyLinearVelocity=Vector3.zero end)task.wait(.2)if SN then for _=1,mult do pcall(function()SN:FireServer(h,h.CFrame)end)end end end
local step=(math.pi*2)/math.max(#list,1)
for i,h in ipairs(list)do local a=(i-1)*step local x,z=math.cos(a)*rad,math.sin(a)*rad pcall(function()h.CFrame=CFrame.new(cx+x,H,cz+z)h.AssemblyLinearVelocity=Vector3.zero end)local bp=Instance.new("BodyPosition")bp.MaxForce=Vector3.new(9e9,9e9,9e9)bp.P=5e11 bp.Position=Vector3.new(cx+x,H,cz+z)bp.Parent=h task.delay(2,function()pcall(function()bp:Destroy()end)end)task.wait()end
pcall(function()my.CFrame=CFrame.new(cx,H,cz)my.AssemblyLinearVelocity=Vector3.zero end)
for _=1,80 do for _,h in ipairs(list)do task.spawn(function()if CG and DG then pcall(function()CG:FireServer(h,CFrame.new(0,1e9,0))DG:FireServer(h)end)end end)end task.wait(.03)end
task.wait(6)stop()end))
end
return exec,stop
end
local function mkLKS(rad,mult)
local run,tk
local stL,spL=mkLag(1000)()
local function stop()run=false if tk then pcall(task.cancel,tk)tk=nil end spL()end
local function exec()
if run then return end
if not STN then N("Error","No target",3)return end
local tp=P:FindFirstChild(STN)if not tp then N("Error","Not found",3)return end
run=true
tk=reg(task.spawn(function()
stL()local H=35 task.wait(.5)
local my=MH()if not my then stop()return end
local th=PH(tp)if not th then stop()return end
N("Kick",tp.DisplayName.." kicked",3)
local sp=W:FindFirstChild("SpawnLocation")or W:FindFirstChild("Spawn")
local cx=sp and sp.Position.X or 0 local cz=sp and sp.Position.Z or 0
pcall(function()my.CFrame=CFrame.new(cx,H,cz)my.AssemblyLinearVelocity=Vector3.zero end)
pcall(function()my.CFrame=th.CFrame*CFrame.new(0,5,5)my.AssemblyLinearVelocity=Vector3.zero end)task.wait(.2)
if SN then for _=1,mult do pcall(function()SN:FireServer(th,th.CFrame)end)end end
pcall(function()th.CFrame=CFrame.new(cx,H,cz+5)th.AssemblyLinearVelocity=Vector3.zero end)
local bp=Instance.new("BodyPosition")bp.MaxForce=Vector3.new(9e9,9e9,9e9)bp.P=5e11 bp.Position=Vector3.new(cx,H,cz+5)bp.Parent=th
task.delay(2,function()pcall(function()bp:Destroy()end)end)
pcall(function()my.CFrame=CFrame.new(cx,H,cz)my.AssemblyLinearVelocity=Vector3.zero end)
for _=1,80 do task.spawn(function()if CG and DG then pcall(function()CG:FireServer(th,CFrame.new(0,1e9,0))DG:FireServer(th)end)end end)task.wait(.03)end
task.wait(6)stop()end))
end
return exec,stop
end
local AK_E,AK_S=mkKick(85)
local TL_E,TL_S=mkKick(85)
local LKAE,LKAS=mkLKA(10,2)
local LKSE,LKSS=mkLKS(10,3)
local LK2E,LK2S=mkLKA(10,2)
local LK3E,LK3S=mkLKS(10,2)
local LK4E,LK4S=mkLKA(10,2)
local LK5E,LK5S=mkLKS(10,2)
local SKA,SKT,SKL,SKN=false,nil,false,nil
local function SKStop()SKA=false if SKT then pcall(task.cancel,SKT)SKT=nil end SKL=false local t=SKN and P:FindFirstChild(SKN)if t and t.Character then local r=t.Character:FindFirstChild("HumanoidRootPart")if r and r:FindFirstChild("ControlBP")then r.ControlBP:Destroy()end end end
local function SKStart(n)
if SKA then return end SKN=n SKA=true SKL=true
reg(task.spawn(function()while SKL do local sp=W:FindFirstChild("SpawnLocation")or W:FindFirstChild("Spawn")or MH()if sp and CG then CG:FireServer(sp,CFrame.new(math.random(-1e9,1e9),0,math.random(-1e9,1e9)))end task.wait()end end))
N("Kick",n.." kicked",3)
SKT=reg(task.spawn(function()
while SKA do
local t=P:FindFirstChild(n)local my=MH()
if t and my then
local tc=t.Character local th=tc and tc:FindFirstChild("HumanoidRootPart")local thu=tc and tc:FindFirstChild("Humanoid")
if th and thu then
if SN then SN:FireServer(th,th.CFrame)end if DG then DG:FireServer(th)end
th.AssemblyLinearVelocity=Vector3.zero th.AssemblyAngularVelocity=Vector3.zero
local bp=th:FindFirstChild("ControlBP")if not bp then bp=Instance.new("BodyPosition")bp.Name="ControlBP"bp.MaxForce=Vector3.new(math.huge,math.huge,math.huge)bp.P=800000 bp.Parent=th end
bp.Position=my.Position+Vector3.new(5,10,5)end end
task.wait()end end))
end
local DA=false
local function DStop()DA=false end
local function DStart()
DA=true
if not STN then N("Error","No target",2)DA=false return end
local t=P:FindFirstChild(STN)if not t or not t.Character then DA=false return end
N("Kick",t.DisplayName.." kicked",3)
reg(task.spawn(function()
local inv=W:FindFirstChild(LP.Name.."SpawnedInToys")local b=inv and inv:FindFirstChild("CreatureBlobman")
if not b and ST then local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")pcall(function()ST:InvokeServer("CreatureBlobman",mr and mr.CFrame or CFrame.new(0,50,0),Vector3.zero)end)task.wait(1)inv=W:FindFirstChild(LP.Name.."SpawnedInToys")b=inv and inv:FindFirstChild("CreatureBlobman")end
if not b then DA=false return end
local seat=b:FindFirstChild("VehicleSeat")local hm=LP.Character and LP.Character:FindFirstChild("Humanoid")
if seat and hm and not hm.Sit then pcall(function()seat:Sit(hm)end)task.wait(.6)end
local br=b:FindFirstChild("HumanoidRootPart")or b.PrimaryPart if not br then DA=false return end
local sv,lt=nil,tick()
local DR,DS,DH,DAn=19,8.5,0,0
while DA and b.Parent do
local tg=P:FindFirstChild(t.Name)if not tg or not tg.Character then break end
local tr=tg.Character:FindFirstChild("HumanoidRootPart")local th=tg.Character:FindFirstChild("Humanoid")
if not tr or not th or th.Health<=0 then break end
if not sv then sv=tr.CFrame end
local cn=sv+Vector3.new(0,30,0)local now=tick()local dt=now-lt lt=now
DAn=DAn+DS*dt local x=cn.Position+Vector3.new(math.cos(DAn)*DR,DH,math.sin(DAn)*DR)
pcall(function()br.CFrame=CFrame.new(x,cn.Position)br.AssemblyLinearVelocity=Vector3.zero tr.CFrame=cn tr.AssemblyLinearVelocity=Vector3.zero th.PlatformStand=true th.Sit=true if SN then SN:FireServer(tr,cn)end end)
R.Heartbeat:Wait()end
if br and sv then pcall(function()br.CFrame=sv br.AssemblyLinearVelocity=Vector3.zero end)end end))
end
local function SNOF(p,cf)if p and SN then pcall(function()SN:FireServer(p,cf or p.CFrame)end)end end
local DS={height="Spawn",lineLag=false,thread=nil,radius=20}
local function DSGetAll()local t={}for _,p in ipairs(P:GetPlayers())do if p~=LP then t[#t+1]=p end end return t end
local function DSTp(m,t)if not m or not t then return end pcall(function()m.CFrame=t.CFrame*CFrame.new(0,5,5)m.AssemblyLinearVelocity=Vector3.zero end)end
local function DSDestroy(h)if not CG or not DG then return end pcall(function()CG:FireServer(h,CFrame.new(0,1e9,0))task.wait()DG:FireServer(h)end)end
local function DSStartLag()
if DS.lineLag then return end DS.lineLag=true
DS.thread=coroutine.create(function()if not CG then return end while DS.lineLag do local sp=W:FindFirstChild("SpawnLocation")or W:FindFirstChild("Spawn")or MH()if sp then for i=1,20 do local x=math.random(-1e9,1e9)local z=math.random(-1e9,1e9)CG:FireServer(sp,CFrame.new(x,0,z))end end task.wait(.01)end end)
coroutine.resume(DS.thread)end
local function DSStopLag()DS.lineLag=false if DS.thread then coroutine.close(DS.thread)DS.thread=nil end end
local DSRT=nil
local function DSRun()
if DSRT then return end
DSRT=reg(task.spawn(function()
local height=(DS.height=="Heaven")and 1e9 or 35
DSStartLag()task.wait(1)
local players=DSGetAll()
if #players==0 then DSStopLag()N("Destroy","No targets",3)DSRT=nil return end
local mh=MH()if not mh then DSStopLag()DSRT=nil return end
local data={}for _,p in ipairs(players)do local c=p.Character local h=c and c:FindFirstChild("HumanoidRootPart")if h then data[#data+1]={p=p,h=h}end end
for _,d in ipairs(data)do DSTp(mh,d.h)task.wait(.2)if SN then pcall(function()SN:FireServer(d.h,d.h.CFrame)end)end task.wait()end
local r=DS.radius local step=(math.pi*2)/#data
for i,d in ipairs(data)do local a=(i-1)*step local x,z=math.cos(a)*r,math.sin(a)*r pcall(function()d.h.CFrame=CFrame.new(x,height,z)d.h.AssemblyLinearVelocity=Vector3.zero end)local bp=Instance.new("BodyPosition")bp.MaxForce=Vector3.new(1e9,1e9,1e9)bp.P=12e7 bp.Position=Vector3.new(x,height,z)bp.Parent=d.h task.delay(2,function()pcall(function()bp:Destroy()end)end)task.wait()end
for i=1,8 do for _,d in ipairs(data)do DSDestroy(d.h)end task.wait(.3)end
N("Destroy","Done",2)DSRT=nil end))
end
local SH={}
local function SAE()local r=MH()local h=MU()if not(r and h and h:FindFirstChild("Ragdolled"))then return end SH.exp=W.ChildAdded:Connect(function(o)if o.Name=="Part"and(o.Position-r.Position).Magnitude<40 and h.Ragdolled.Value then r.Anchored=true task.wait(.01)r.Anchored=false r.AssemblyLinearVelocity=Vector3.zero r.AssemblyAngularVelocity=Vector3.zero h:ChangeState(Enum.HumanoidStateType.Running)end end)end
local function DAE()if SH.exp then SH.exp:Disconnect()SH.exp=nil end end
local function SAB()local c=LP.Character or LP.CharacterAdded:Wait()local r=c:WaitForChild("HumanoidRootPart",.5)local h=c:WaitForChild("Humanoid",.5)if not(r and h)then return end SH.burn=h.FireDebounce.Changed:Connect(function()if h.FireDebounce.Value then local b=W.Plots.Plot1.Barrier.PlotBarrier local s=b.CFrame task.spawn(function()repeat task.wait()b.CFrame=r.CFrame until not h.FireDebounce.Value end)task.wait(1)h.FireDebounce.Value=false task.wait()b.CFrame=s end end)end
local function DAB()if SH.burn then SH.burn:Disconnect()SH.burn=nil end end
local function SAV(s)if SH.void then SH.void:Disconnect()SH.void=nil end if s then SH.void=R.Heartbeat:Connect(function()local r=MH()if r and r.Position.Y<-50 then r.CFrame=CFrame.new(r.Position.X,100,r.Position.Z)r.AssemblyLinearVelocity=Vector3.zero end end)end end
local function SABS(s)SH.bA=s if s then SH.bT=reg(task.spawn(function()while SH.bA do local h,r=MU(),MH()if h and r and h.Health>0 then h.Sit=true h:ChangeState(Enum.HumanoidStateType.Running)local lv=Cam.CFrame.LookVector r.CFrame=CFrame.new(r.Position,r.Position+Vector3.new(lv.X,0,lv.Z))end task.wait()end end))else if SH.bT then task.cancel(SH.bT)SH.bT=nil end end end
local function SABK(s)SH.bkA=s if s then SH.bkT=reg(task.spawn(function()while SH.bkA do local h,r=MU(),MH()if h and r and h.Health>0 then h.Sit=true h:ChangeState(Enum.HumanoidStateType.Running)local lv=Cam.CFrame.LookVector r.CFrame=CFrame.new(r.Position,r.Position+Vector3.new(lv.X,0,lv.Z))end task.wait()end end))else if SH.bkT then task.cancel(SH.bkT)SH.bkT=nil end end end
local function SSetRB(c)if not c then return end local h=c:FindFirstChild("Humanoid")local r=c:FindFirstChild("HumanoidRootPart")if not(h and r and RG)then return end if SH.rbConn then SH.rbConn:Disconnect()end SH.rbConn=h:GetPropertyChangedSignal("SeatPart"):Connect(function()if h.SeatPart and h.SeatPart.Parent and h.SeatPart.Parent.Name=="CreatureBlobman"and not SH.rbFlag then SH.rbFlag=true local s=h.SeatPart while not h.Sit do task.wait()end RG:FireServer(r,3)while not(h:FindFirstChild("Ragdolled")and h.Ragdolled.Value)and not h.Sit do task.wait()end task.wait(.4)h.Sit=false if s and s:IsA("Part")then s:Sit(h)end task.delay(.25,function()while h and h.SeatPart do local rr=MH()if rr then RG:FireServer(rr,1)end task.wait(.05)end SH.rbFlag=false end)end end)end
local function SERB(s)SH.rbA=s if s then SSetRB(LP.Character or LP.CharacterAdded:Wait())if SH.rbChConn then SH.rbChConn:Disconnect()end SH.rbChConn=LP.CharacterAdded:Connect(function(c)task.wait(.5)SSetRB(c)end)else if SH.rbConn then SH.rbConn:Disconnect()SH.rbConn=nil end if SH.rbChConn then SH.rbChConn:Disconnect()SH.rbChConn=nil end end end
local nrdC={}
local function SSetNRD(c)if not SH.nrd then return end local r=c:FindFirstChild("HumanoidRootPart")or c:WaitForChild("HumanoidRootPart",5)local h=c:FindFirstChild("Humanoid")or c:WaitForChild("Humanoid",5)local hd=c:FindFirstChild("Head")or c:WaitForChild("Head",5)if not(r and h and hd)then return end local cc=hd.ChildAdded:Connect(function(o)if not SH.nrd then return end if o and o.Name=="PartOwner"and not SH.nrdProc then SH.nrdProc=true pcall(function()h.Sit=false end)pcall(function()if SG then SG:FireServer(LP)end end)task.spawn(function()while SH.nrd and hd:FindFirstChild("PartOwner")do pcall(function()if SG then SG:FireServer(LP)end end)pcall(function()if RG then RG:FireServer(r,0)end end)task.wait()end end)pcall(function()r.Anchored=true end)if not SH.nrdWalk then SH.nrdWalk=true while SH.nrd and task.wait()do local hf=LP:FindFirstChild("IsHeld")if not hf or not hf.Value then break end pcall(function()if h.MoveDirection then r.CFrame=r.CFrame+h.MoveDirection*.43 end end)end SH.nrdWalk=false end pcall(function()r.Anchored=false end)SH.nrdProc=false end end)table.insert(nrdC,cc)end
local function SENRD(s)SH.nrd=s for _,c in ipairs(nrdC)do pcall(function()c:Disconnect()end)end nrdC={}if s and LP.Character then task.defer(function()SSetNRD(LP.Character)end)end end
local ka=false
local function PK()local inv=W:FindFirstChild(LP.Name.."SpawnedInToys")if inv and DT then for _,v in ipairs(inv:GetChildren())do if v.Name=="AntiKick"or v.Name=="NinjaShuriken"then pcall(function()DT:FireServer(v)end)end end end end
local SEKT=nil
local function SEK()
if SEKT then return end
ka=true
SEKT=reg(task.spawn(function()
local cs=LP:WaitForChild("CanSpawnToy",10)
if not ST or not cs then ka=false SEKT=nil return end
local function GR()local c=LP.Character if c and c:FindFirstChild("HumanoidRootPart")then return c.HumanoidRootPart end return LP.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")end
while ka do
task.wait(.05)
local c=LP.Character
if not c or not c:FindFirstChild("Humanoid")or c.Humanoid.Health<=0 then continue end
local inv=W:FindFirstChild(LP.Name.."SpawnedInToys")
local k=inv and(inv:FindFirstChild("NinjaShuriken")or inv:FindFirstChild("AntiKick"))
if not k then
local t=tick()while not cs.Value and tick()-t<5 do task.wait(.1)end
local r=GR()
if r then pcall(function()ST:InvokeServer("NinjaShuriken",r.CFrame*CFrame.new(0,2,2),Vector3.zero)end)end
task.wait(.5)inv=W:FindFirstChild(LP.Name.."SpawnedInToys")k=inv and(inv:FindFirstChild("NinjaShuriken")or inv:FindFirstChild("AntiKick"))
if k then k.Name="AntiKick"end end
if k and k:FindFirstChild("StickyPart")then
local w=k.StickyPart:FindFirstChild("StickyWeld")and k.StickyPart.StickyWeld.Part1~=nil
if not w and k.StickyPart.CanTouch then
local r=GR()if r then local fp=r:FindFirstChild("FirePlayerPart")or r:WaitForChild("FirePlayerPart",5)
if fp then
for _,o in pairs(k:GetChildren())do if o:IsA("BasePart")then o.CanTouch=false o.CanCollide=false o.CanQuery=false o.AssemblyLinearVelocity=Vector3.zero if o.Name=="Pyramid"or o.Name=="Main"then o.Transparency=0 else o.Transparency=1 end end end
if k:FindFirstChild("SoundPart")and(not k.SoundPart:FindFirstChild("PartOwner")or k.SoundPart.PartOwner.Value~=LP.Name)then pcall(function()if SN then SN:FireServer(k.SoundPart,k.SoundPart.CFrame)end end)end
k:PivotTo(fp.CFrame*CFrame.Angles(0,math.rad(90),math.rad(90)))
local PE=RS:FindFirstChild("PlayerEvents")
if PE and PE:FindFirstChild("StickyPartEvent")then PE.StickyPartEvent:FireServer(k.StickyPart,fp,CFrame.new(0,0,0)*CFrame.Angles(0,math.rad(90),math.rad(90)))end end end
k.Name="AntiKick"task.wait(.1)end
local r=GR()if r and(r.Position-k.StickyPart.Position).Magnitude>=20 then PK()end end end
PK()ka=false SEKT=nil end))
end
local function DEK()ka=false if SEKT then pcall(task.cancel,SEKT)SEKT=nil end PK()end
local gm={r=false,lcf=nil,lc=nil}
local function SGM()
if gm.r then return end gm.r=true
local r=MH()if r then gm.lcf=r.CFrame end
W.FallenPartsDestroyHeight=0/0
gm.lc=coroutine.wrap(function()
while gm.r do
local rr=MH()
if rr then
if not gm.lcf then gm.lcf=rr.CFrame end
local o=rr.CFrame local s=tick()
while tick()-s<1 and gm.r do
if not LP.Character or not rr.Parent then break end
local t=tick()*12 rr.CFrame=o+Vector3.new(math.cos(t)*10000,-10000,math.sin(t)*10000)
R.RenderStepped:Wait()end
if gm.r and rr.Parent then rr.CFrame=o end end
task.wait(.0001)end end)
gm.lc()end
local function TGM()gm.r=false gm.lc=nil local r=MH()if r and gm.lcf then r.CFrame=gm.lcf end W.FallenPartsDestroyHeight=-100 end
local gcc=0
local function SGucci()
gcc=gcc+1 local my=gcc
local c=LP.Character or LP.CharacterAdded:Wait()
local h=c:FindFirstChild("Humanoid")local r=c:FindFirstChild("HumanoidRootPart")
if not(h and r)then return end
local inv=W:FindFirstChild(LP.Name.."SpawnedInToys")
local b=inv and inv:FindFirstChild("CreatureBlobman")
if not b and ST then pcall(function()ST:InvokeServer("CreatureBlobman",r.CFrame,Vector3.new(0,-15.716,0))end)task.wait(1)inv=W:FindFirstChild(LP.Name.."SpawnedInToys")b=inv and inv:FindFirstChild("CreatureBlobman")end
if not b then return end
local s=b:FindFirstChild("VehicleSeat")
if s and h and not h.Sit then pcall(function()s:Sit(h)end)task.wait(.6)end
local sc=b:FindFirstChild("BlobmanSeatAndOwnerScript",true)
if sc then
local gr=sc:FindFirstChild("CreatureGrab")local dr=sc:FindFirstChild("CreatureDrop")
local ld=b:FindFirstChild("LeftDetector")local lw=ld and ld:FindFirstChild("LeftWeld")
local mr=MH()
if gr and ld and mr then
pcall(function()gr:FireServer(ld,mr,lw)end)task.wait(.08)
if SN then pcall(function()SN:FireServer(mr,mr.CFrame)end)end task.wait(.08)
mr.CFrame=mr.CFrame+Vector3.new(0,16,0)task.wait(.08)
if DG then pcall(function()DG:FireServer(mr)end)end task.wait(.08)
pcall(function()gr:FireServer(ld,mr,lw)end)task.wait(.08)
if dr then pcall(function()dr:FireServer(ld,mr)end)end task.wait(.08)
if DG then pcall(function()DG:FireServer(mr)end)end end end
if my~=gcc then return end
if DT then pcall(function()DT:FireServer(b)end)end end
local function DGucci()gcc=gcc+1 local inv=W:FindFirstChild(LP.Name.."SpawnedInToys")if inv then for _,v in ipairs(inv:GetChildren())do if v.Name=="CreatureBlobman"or v.Name=="Gucci"then pcall(function()v:Destroy()end)end end end end
local KA={mode="circle",r=10,iR=5,oR=15,sS=5,sE=15,py=100,sy=100,wl={}}
local KKTask=nil
local function KAKick(tn)
if KKTask then return end
if not tn then N("Error","No target",3)return end
local tp=P:FindFirstChild(tn)if not tp then N("Error","Not found",3)return end
local tc=tp.Character if not tc then N("Error","No char",3)return end
local tr=tc:FindFirstChild("HumanoidRootPart")if not tr then N("Error","No HRP",3)return end
local inv=W:FindFirstChild(LP.Name.."SpawnedInToys")local b=inv and inv:FindFirstChild("CreatureBlobman")
if not b and ST then local r=MH()if r then ST:InvokeServer("CreatureBlobman",r.CFrame,Vector3.zero)task.wait(1)inv=W:FindFirstChild(LP.Name.."SpawnedInToys")b=inv and inv:FindFirstChild("CreatureBlobman")end end
if not b then N("Error","Blob fail",3)return end
local s=b:FindFirstChild("VehicleSeat")local h=MU()
if s and h and not h.Sit then pcall(function()s:Sit(h)end)task.wait(.6)end
local mr=MH()
if mr and tr then
local op=mr.CFrame mr.CFrame=tr.CFrame task.wait(.07)
local sc=b:FindFirstChild("BlobmanSeatAndOwnerScript",true)
if sc then
local gr=sc:FindFirstChild("CreatureGrab")local dr=sc:FindFirstChild("CreatureDrop")
local ld=b:FindFirstChild("LeftDetector")local rd=b:FindFirstChild("RightDetector")
local lw=ld and ld:FindFirstChild("LeftWeld")local rw=rd and rd:FindFirstChild("RightWeld")
if gr and ld and lw then
pcall(function()gr:FireServer(ld,mr,lw)end)task.wait(.08)
if SN then pcall(function()SN:FireServer(tr,tr.CFrame)end)end task.wait(.08)
tr.CFrame=tr.CFrame+Vector3.new(0,16,0)task.wait(.08)
if DG then pcall(function()DG:FireServer(tr)end)end task.wait(.08)
pcall(function()gr:FireServer(ld,tr,lw)end)task.wait(.08)
if dr then pcall(function()dr:FireServer(ld,tr)end)end task.wait(.08)
if DG then pcall(function()DG:FireServer(tr)end)end end
if gr and rd and rw then pcall(function()gr:FireServer(rd,mr,rw)end)task.wait(.08)pcall(function()gr:FireServer(rd,tr,rw)end)end end
mr.CFrame=op end
if DT then pcall(function()DT:FireServer(b)end)end
N("Kick",tp.DisplayName.." kicked",3)end
local KAT=nil
local function KAll()
if KAT then return end
KAT=reg(task.spawn(function()
local list={}for _,p in ipairs(P:GetPlayers())do if p~=LP and not KA.wl[p.Name]and p.Character and p.Character:FindFirstChild("HumanoidRootPart")then list[#list+1]=p end end end
if #list==0 then N("KickAll","No targets",2)KAT=nil return end
N("KickAll","Kicking "..#list.." players",2)
local r=MH()if not r then KAT=nil return end
local inv=W:FindFirstChild(LP.Name.."SpawnedInToys")local b=inv and inv:FindFirstChild("CreatureBlobman")
if not b and ST then ST:InvokeServer("CreatureBlobman",r.CFrame*CFrame.new(0,0,-8),Vector3.new(0,27.4,0))task.wait(1)inv=W:FindFirstChild(LP.Name.."SpawnedInToys")b=inv and inv:FindFirstChild("CreatureBlobman")end
if not b then N("KickAll","Blob fail",3)KAT=nil return end
local s=b:FindFirstChild("VehicleSeat")local h=MU()
if s and h and not h.Sit then pcall(function()s:Sit(h)end)task.wait(.6)end
for _,p in ipairs(list)do local tr=p.Character and p.Character:FindFirstChild("HumanoidRootPart")if tr then r.CFrame=tr.CFrame task.wait(.02)if SN then SN:FireServer(tr,tr.CFrame)end end end
r.CFrame=CFrame.new(0,KA.sy,0)task.wait(.1)
for _,pp in ipairs(b:GetDescendants())do if pp:IsA("BasePart")then pcall(function()pp.Anchored=true end)end end
task.wait(.1)
local n=#list
for i,p in ipairs(list)do local tr=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
if tr then
local ang=(i-1)*(math.pi*2)/n local x,z=0,0
if KA.mode=="circle"then x=math.cos(ang)*KA.r z=math.sin(ang)*KA.r
elseif KA.mode=="double"then if i<=n/2 then x=math.cos(ang)*KA.iR z=math.sin(ang)*KA.iR else x=math.cos(ang)*KA.oR z=math.sin(ang)*KA.oR end
elseif KA.mode=="spiral"then local t=(i-1)/math.max(n-1,1)local rr=KA.sS+(KA.sE-KA.sS)*t x=math.cos(ang*3)*rr z=math.sin(ang*3)*rr end
tr.CFrame=CFrame.new(x,KA.py,z)
local bp=Instance.new("BodyPosition")bp.MaxForce=Vector3.new(1e9,1e9,1e9)bp.P=4e7 bp.Position=Vector3.new(x,KA.py,z)bp.Parent=tr
task.delay(2,function()pcall(function()bp:Destroy()end)end)end task.wait()end
for i=1,5 do for _,p in ipairs(list)do local tr=p.Character and p.Character:FindFirstChild("HumanoidRootPart")if tr and CG and DG then pcall(function()CG:FireServer(tr,CFrame.new(0,1e9,0))DG:FireServer(tr)end)end end task.wait(.3)end
for _,pp in ipairs(b:GetDescendants())do if pp:IsA("BasePart")then pcall(function()pp.Anchored=false end)end end
N("KickAll","Done",2)KAT=nil end))
end
local NBT=nil
local function NBRun()
if NBT then return end
NBT=reg(task.spawn(function()
local list={}for _,p in ipairs(P:GetPlayers())do if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart")then list[#list+1]=p end end end
if #list==0 then N("NBlob","No targets",2)NBT=nil return end
local r=MH()if not r then NBT=nil return end
for _,p in ipairs(list)do local tr=p.Character and p.Character:FindFirstChild("HumanoidRootPart")if tr then r.CFrame=tr.CFrame*CFrame.new(0,5,5)task.wait(.2)if SN then for _=1,3 do pcall(function()SN:FireServer(tr,tr.CFrame)end)end end end end
local n=#list local step=(math.pi*2)/math.max(n,1)
for i,p in ipairs(list)do local tr=p.Character and p.Character:FindFirstChild("HumanoidRootPart")if tr then local ang=(i-1)*step tr.CFrame=CFrame.new(math.cos(ang)*10,35,math.sin(ang)*10)local bp=Instance.new("BodyPosition")bp.MaxForce=Vector3.new(1e9,1e9,1e9)bp.P=5e11 bp.Position=Vector3.new(math.cos(ang)*10,35,math.sin(ang)*10)bp.Parent=tr task.delay(2,function()pcall(function()bp:Destroy()end)end)end task.wait()end
r.CFrame=CFrame.new(0,35,0)
for i=1,80 do for _,p in ipairs(list)do local tr=p.Character and p.Character:FindFirstChild("HumanoidRootPart")if tr and CG and DG then pcall(function()CG:FireServer(tr,CFrame.new(0,1e9,0))DG:FireServer(tr)end)end end task.wait(.03)end
N("NBlob","Done",2)NBT=nil end))
end
local AK={active=false,thread=nil,rad=10,spd=.15,adjY=23,adjX=0,adjZ=0,target=nil}
local function AKGet()return W:FindFirstChild(LP.Name.."SpawnedInToys")end
local function AKBlob()local f=AKGet()return f and f:FindFirstChild("CreatureBlobman")end
local function AKSpawn()local c=LP.Character local r=c and c:FindFirstChild("HumanoidRootPart")if not r then return end local cf=r.CFrame*CFrame.new(0,0,-5)if ST then pcall(function()ST:InvokeServer("CreatureBlobman",cf,Vector3.new(0,90,0))end)end end
local function AKDestroy()local b=AKBlob()if b and DT then pcall(function()DT:FireServer(b)end)end end
local function AKLoop(tn)
local ip=nil local cap=false local gt=false local ang=0
while AK.active do
local ct=P:FindFirstChild(tn)
local b=AKBlob()
local c=LP.Character local h=c and c:FindFirstChild("Humanoid")
if not b then AKSpawn()cap=false task.wait(.5)continue end
local s=b:FindFirstChildOfClass("VehicleSeat")or b:FindFirstChildOfClass("Seat")
if s and h and h.SeatPart~=s then s:Sit(h)end
local tc=ct and ct.Character local tr=tc and tc:FindFirstChild("HumanoidRootPart")
local th=tc and tc:FindFirstChild("Humanoid")local br=b:FindFirstChild("HumanoidRootPart")or b.PrimaryPart
if tr and th and th.Health>0 and br then
if not ip then ip=tr.Position end
local cp=ip+Vector3.new(AK.adjX,AK.adjY,AK.adjZ)
if not cap then tr.CFrame=CFrame.new(cp)th.PlatformStand=true if SN then SN:FireServer(tr,tr.CFrame)end task.wait(.1)cap=true end
ang=ang+AK.spd
local ox=math.cos(ang)*AK.rad local oz=math.sin(ang)*AK.rad
br.CFrame=CFrame.new(cp+Vector3.new(ox,0,oz),cp)br.Velocity=Vector3.zero tr.CFrame=CFrame.new(cp)
pcall(function()
local so=b:FindFirstChild("BlobmanSeatAndOwnerScript")
if so then
local cg=so:FindFirstChild("CreatureGrab")local cd=so:FindFirstChild("CreatureDrop")
local rd=b:FindFirstChild("RightDetector")local w=rd and(rd:FindFirstChild("RightWeld")or rd:FindFirstChildWhichIsA("Weld"))
if w then cd:FireServer(w)end
gt=not gt local tg=gt and tr or br
if SN then SN:FireServer(tr,tr.CFrame)end
if DG then DG:FireServer(tr)end
if cg and rd and w then cg:FireServer(rd,tg,w)end end end)
else ip=nil cap=false end
R.Heartbeat:Wait()end
AKDestroy()end
local function AKStart(tn)if AK.active then return end if not tn then N("Arkadia","No target",2)return end AK.active=true AK.target=tn AK.thread=reg(task.spawn(function()AKLoop(tn)end))N("Arkadia","Started "..tn,3)end
local function AKStop()AK.active=false if AK.thread then pcall(task.cancel,AK.thread)AK.thread=nil end AKDestroy()N("Arkadia","Stopped",2)end
local VL={active=false,target=nil,interval=1.5,conn=nil,timer=0}
local function VLSetNet(p,cf)if not p then return end pcall(function()if SN then SN:FireServer(p,cf or MH().CFrame)end end)end
local function VLExe(t)
local c=t.Character if not c then return end
local tr=c:FindFirstChild("HumanoidRootPart")if not tr or not tr.Parent then return end
local r=MH()if not r then return end
local sv=r.CFrame
reg(task.spawn(function()
for _,n in pairs({"Head","Torso","HumanoidRootPart"})do local p=LP.Character:FindFirstChild(n)if p then p.CanCollide=false end end
r.CFrame=CFrame.new(tr.Position.X,tr.Position.Y-6,tr.Position.Z)task.wait(.1)
Cam.CFrame=CFrame.lookAt(Cam.CFrame.Position,tr.Position)
for _=1,4 do VLSetNet(tr,r.CFrame)task.wait(.05)end
local lk=Cam.CFrame task.wait(.1)
local bv=Instance.new("BodyVelocity",tr)bv.MaxForce=Vector3.new(1e8,1e8,1e8)bv.Velocity=Vector3.new(0,10000,0)
task.delay(1,function()pcall(function()bv:Destroy()end)end)
Cam.CFrame=lk task.wait(.1)
for _,n in pairs({"Head","Torso","HumanoidRootPart"})do local p=LP.Character:FindFirstChild(n)if p then p.CanCollide=true end end
r.CFrame=sv r.AssemblyLinearVelocity=Vector3.zero end))end
local function VLStart()if VL.conn then VL.conn:Disconnect()VL.conn=nil end VL.active=true VL.timer=0 VL.conn=R.Heartbeat:Connect(function(dt)VL.timer=VL.timer+dt if VL.timer>=VL.interval then if VL.target and VL.target.Character and VL.active then VLExe(VL.target)end VL.timer=0 end end)N("VoidLoop","Start",2)end
local function VLStop()VL.active=false if VL.conn then VL.conn:Disconnect()VL.conn=nil end N("VoidLoop","Stop",2)end
local G={}
local pg,rg2,fg=nil,nil,nil
local function GrabLoop(ty)
while true do pcall(function()local gp=W:FindFirstChild("GrabParts")if gp then local gr=gp:FindFirstChild("GrabPart")if gr and gr:FindFirstChild("WeldConstraint")then local tg=gr.WeldConstraint.Part1 local hd=tg and tg.Parent and tg.Parent:FindFirstChild("Head")
if hd then local tn=ty=="poison"and"PoisonHurtPart"or"PaintPlayerPart"for _,dd in ipairs(W:GetDescendants())do if dd.Name==tn then dd.Size=Vector3.new(2,2,2)dd.Transparency=1 dd.Position=hd.Position end end task.wait()for _,dd in ipairs(W:GetDescendants())do if dd.Name==tn then dd.Position=Vector3.new(0,-200,0)end end end end end end)task.wait()end end
local function FireLoop()
while true do pcall(function()local gp=W:FindFirstChild("GrabParts")if gp then local gr=gp:FindFirstChild("GrabPart")if gr and gr:FindFirstChild("WeldConstraint")then local tg=gr.WeldConstraint.Part1 local hd=tg and tg.Parent and tg.Parent:FindFirstChild("Head")
if hd then local inv=W:FindFirstChild(LP.Name.."SpawnedInToys")if inv and not inv:FindFirstChild("Campfire")and ST then pcall(function()ST:InvokeServer("Campfire",LP.Character.Head.CFrame,Vector3.new(0,90,0))end)end local cf=inv and inv:FindFirstChild("Campfire")if cf then local fp=cf:FindFirstChild("FirePlayerPart")if fp then fp.Size=Vector3.new(7,7,7)fp.Position=hd.Position task.wait(.3)fp.Position=Vector3.new(0,-50,0)end end end end end end)task.wait()end end
local NF=false
local NFT=nil
local function sNOF()if NF then return end if not STN then N("NO Force","No target",3)return end NF=true NFT=reg(task.spawn(function()while NF do if STN then local t=P:FindFirstChild(STN)if t and t.Character then for _,p in ipairs(t.Character:GetDescendants())do if p:IsA("BasePart")and SN then SNOF(p,p.CFrame)end end end end task.wait(.1)end end))N("NO Force","On",3)end
local function tNOF()NF=false if NFT then pcall(task.cancel,NFT)NFT=nil end N("NO Force","Off",2)end
local AA=false
local function sAAR()
if AA then return end AA=true
local function w(c)local h=c:FindFirstChildOfClass("Humanoid")local r=c:FindFirstChild("HumanoidRootPart")local hd=c:FindFirstChild("Head")if not(h and r and hd)then return end hd.ChildAdded:Connect(function(po)if not AA or po.Name~="PartOwner"then return end local v=po.Value if v==LP or v==LP.Name then return end pcall(function()if SG then SG:FireServer(LP)end if RG then RG:FireServer(r,0)end h.Sit=false h:ChangeState(Enum.HumanoidStateType.GettingUp)h:ChangeState(Enum.HumanoidStateType.Running)end)local t=P:FindFirstChild(tostring(v))if t and t.Character then local th=t.Character:FindFirstChild("HumanoidRootPart")if th then pcall(function()if SN then SN:FireServer(th,r.CFrame+Vector3.new(0,80,0))end end)end end end)end
local c=LP.Character or LP.CharacterAdded:Wait()w(c)LP.CharacterAdded:Connect(w)N("AAR","On",3)end
local function tAAR()AA=false N("AAR","Off",2)end
local SS=false local SSD={}
local SST=nil
local function sSSF()
if SS then return end if not STN then N("SSF","No target",3)return end SS=true SSD={}
SST=reg(task.spawn(function()while SS do if STN then local t=P:FindFirstChild(STN)if t then local f=W:FindFirstChild(t.Name.."SpawnedInToys")if f then for _,ty in ipairs(f:GetChildren())do local n=ty.Name if n=="NinjaKunai"or n=="NinjaShuriken"or n=="AntiKick"or n:find("Anti")or n:find("Fling")or n:find("Kick")then if DT then pcall(function()DT:FireServer(ty)end)end pcall(function()ty:Destroy()end)if not SSD[n]then SSD[n]=true N("Script Deleted",t.DisplayName.."'s "..n,3)end end end end end end task.wait(.15)end end))
N("SSF","On",3)end
local function tSSF()SS=false if SST then pcall(task.cancel,SST)SST=nil end SSD={}N("SSF","Off",2)end
local PA=false local PAC
local function sPAL()
if PA then return end PA=true
PAC=R.Heartbeat:Connect(function()if not PA then return end local mc=LP.Character local mr=mc and mc:FindFirstChild("HumanoidRootPart")if mr then mr.AssemblyLinearVelocity=Vector3.zero mr.AssemblyAngularVelocity=Vector3.zero mr.Anchored=true for _,p in ipairs(mc:GetDescendants())do if p:IsA("BasePart")and p~=mr then p.CanCollide=false p.Transparency=1 end end end end)
N("PAL","On",3)end
local function tPAL()PA=false if PAC then PAC:Disconnect()PAC=nil end local mc=LP.Character if mc then for _,p in ipairs(mc:GetDescendants())do if p:IsA("BasePart")then p.Anchored=false if p.Name~="HumanoidRootPart"then p.Transparency=0 end end end end N("PAL","Off",2)end
local AD=false local ADC={} local ADH={}
local function sADB()
if AD then return end AD=true ADH={}
table.insert(ADC,R.Heartbeat:Connect(function()if not AD then return end for _,p in ipairs(P:GetPlayers())do if p~=LP and p.Character then local r=p.Character:FindFirstChild("HumanoidRootPart")if r then local h=ADH[p.Name]if not h then h={}ADH[p.Name]=h end table.insert(h,{cf=r.CFrame,t=tick()})if #h>10 then table.remove(h,1)end end end end end))
N("ADB","On",3)end
local function tADB()AD=false for _,c in ipairs(ADC)do if c then c:Disconnect()end end ADC={}ADH={}N("ADB","Off",2)end
local CFA=false local CFC local CFS
local function sCFAF()
if CFA then return end CFA=true local c=LP.Character if c then local r=c:FindFirstChild("HumanoidRootPart")if r then CFS=r.CFrame end end
CFC=R.RenderStepped:Connect(function()if not CFA then return end local mc=LP.Character if not mc then return end local r=mc:FindFirstChild("HumanoidRootPart")if not r then return end r.AssemblyLinearVelocity=Vector3.zero r.AssemblyAngularVelocity=Vector3.zero if CFS then r.CFrame=CFS else CFS=r.CFrame end end)
N("CFAF","On",3)end
local function tCFAF()CFA=false if CFC then CFC:Disconnect()CFC=nil end CFS=nil N("CFAF","Off",2)end
local HB=false local HBC
local function sHB()
if HB then return end if not STN then N("HB","No target",3)return end HB=true
HBC=R.Heartbeat:Connect(function()if not HB or not STN then return end local t=P:FindFirstChild(STN)if not t or not t.Character then return end for _,p in ipairs(t.Character:GetDescendants())do if p:IsA("BasePart")and not p:GetAttribute("_HBe")then p:SetAttribute("_HBe",true)pcall(function()p.Size=p.Size+Vector3.new(20,20,20)end)end end local r=t.Character:FindFirstChild("HumanoidRootPart")if r and SN then pcall(function()SN:FireServer(r,r.CFrame)end)end end)
N("HB","On",3)end
local function tHB()HB=false if HBC then HBC:Disconnect()HBC=nil end if STN then local t=P:FindFirstChild(STN)if t and t.Character then for _,p in ipairs(t.Character:GetDescendants())do if p:IsA("BasePart")and p:GetAttribute("_HBe")then p:SetAttribute("_HBe",nil)end end end end N("HB","Off",2)end
local IC=false local ICT
local function sICP()
if IC then return end if not STN then N("IC","No target",3)return end IC=true
ICT=reg(task.spawn(function()while IC do if STN then local t=P:FindFirstChild(STN)if t and t.Character then local r=t.Character:FindFirstChild("HumanoidRootPart")if r then for _=1,30 do pcall(function()if CG then CG:FireServer(r,CFrame.new(math.random(-1e9,1e9),0,math.random(-1e9,1e9)))end if EG then EG:FireServer(string.rep("X",2000))end if SN then SN:FireServer(r,r.CFrame)end end)end end end end task.wait(.05)end end))
N("IC","On",3)end
local function tICP()IC=false if ICT then pcall(task.cancel,ICT)ICT=nil end N("IC","Off",2)end
local BC=CFrame.new(-272.2197265625,-7.350403785705566,475.0108947753906)
local function GetBarrier()
local pl=W:FindFirstChild("Plots")if not pl then return nil end
for _,p in ipairs(pl:GetChildren())do if p:IsA("Model")and p.Name:match("^Plot%d+$")then local b=p:FindFirstChild("Barrier")if b then local pb=b:FindFirstChild("PlotBarrier")if pb and pb:IsA("BasePart")then local s=p:FindFirstChild("PlotSign")local ow=s and s:FindFirstChild("ThisPlotsOwners")local mine=false if ow then for _,o in ipairs(ow:GetChildren())do if o:IsA("ValueBase")and o.Value==LP.Name then mine=true break end end end if not mine then return pb,p end end end end end return nil end
local BA=false local BT
local function BE()
if BA then return end
local pb=GetBarrier()if not pb then N("Barrier","No enemy plot",3)return end
BA=true
BT=reg(task.spawn(function()local t=0 while BA and t<200 do t=t+1 local pb2=GetBarrier()if not pb2 then break end pcall(function()if SN then SN:FireServer(pb2,pb2.CFrame)end pb2.Anchored=false pb2.CanCollide=false pb2.Transparency=1 pb2.CFrame=BC pb2.AssemblyLinearVelocity=Vector3.zero if pb2.SetNetworkOwner then pcall(function()pb2:SetNetworkOwner(LP)end)end end)task.wait(.05)end BA=false N("Barrier","Done",2)end))
N("Barrier","Breaking...",2)end
local function BS()BA=false if BT then pcall(task.cancel,BT)BT=nil end N("Barrier","Stopped",2)end
local PBGT=nil
local function PBG()
if PBGT then return end
local inv=W:FindFirstChild(LP.Name.."SpawnedInToys")
if not inv then N("PlotBreak","No inv",3)return end
local r=MH()if not r then N("PlotBreak","No HRP",3)return end
N("PlotBreak","Breaking...",2)
PBGT=reg(task.spawn(function()
for i=1,5 do
local sh=nil
local conn=inv.ChildAdded:Connect(function(c)if c.Name=="NinjaShuriken"then sh=c conn:Disconnect()end end)
pcall(function()if ST then ST:InvokeServer("NinjaShuriken",r.CFrame*CFrame.new(5,8,20),Vector3.zero)end end)
local t0=tick()repeat task.wait(.01)until(sh and sh:FindFirstChild("StickyPart")and sh:FindFirstChild("SoundPart"))or tick()-t0>.5
sh=sh or inv:FindFirstChild("NinjaShuriken")
if sh then local sp=sh:FindFirstChild("SoundPart")local stp=sh:FindFirstChild("StickyPart")if sp and stp then for _=1,15 do if SN then pcall(function()SN:FireServer(sp,sp.CFrame)end)end if sp:FindFirstChild("PartOwner")and sp.PartOwner.Value==LP.Name then break end task.wait()end for _,o in pairs(sh:GetChildren())do if o:IsA("BasePart")then o.CanTouch=false o.CanCollide=false o.Transparency=1 end end sh.Name="Noclipped"local pl=W:FindFirstChild("Plots")local plot=pl and pl:FindFirstChild("Plot"..i)if plot then local pa=plot:FindFirstChild("PlotArea")local PE=RS:FindFirstChild("PlayerEvents")local SPE=PE and PE:FindFirstChild("StickyPartEvent")if pa and SPE then pcall(function()SPE:FireServer(stp,pa,CFrame.new(1e12,1e12,1e12))end)end end end end
task.wait(.1)end
N("PlotBreak","Done",2)PBGT=nil end))
end
local TSs={}
local function TCR()TSs.run=false for _,o in ipairs(TSs.objs or{})do if o and o.Parent then pcall(function()o:Destroy()end)end end TSs.objs={}N("Tsunami","Cleanup",2)end
local TRT=nil
local function TR()
if TRT then return end
TSs.run=true TSs.objs=TSs.objs or{} N("Tsunami","Running...",3)
local c=LP.Character local r=c and c:FindFirstChild("HumanoidRootPart")if not r then TSs.run=false return end
local org=r.Position+Vector3.new(0,500,0)
TRT=reg(task.spawn(function()
local pl=W:FindFirstChild("Plots")local tg={}
if pl then for _,p in ipairs(pl:GetChildren())do if p:IsA("Model")and p.Name:match("^Plot%d+$")then local s=p:FindFirstChild("PlotSign")local ow=s and s:FindFirstChild("ThisPlotsOwners")local mine=false if ow then for _,o in ipairs(ow:GetChildren())do if o:IsA("ValueBase")and o.Value==LP.Name then mine=true break end end end if not mine then local b=p:FindFirstChild("Base")or p.PrimaryPart if b then tg[#tg+1]=b.Position end end end end end
if #tg==0 then tg[1]=org end
for i=1,60 do if not TSs.run then break end local t=tg[(i-1)%#tg+1]local sp=Vector3.new(t.X+math.random(-20,20),org.Y+math.random(0,200),t.Z+math.random(-20,20))local part=Instance.new("Part")part.Size=Vector3.new(math.random(20,40),math.random(50,100),math.random(20,40))part.Position=sp part.Anchored=false part.CanCollide=true part.Material=Enum.Material.Water part.Color=Color3.fromRGB(0,120,200)part.Transparency=.3 part.Parent=W TSs.objs[#TSs.objs+1]=part if SN then pcall(function()SN:FireServer(part,part.CFrame)end)end if part.SetNetworkOwner then pcall(function()part:SetNetworkOwner(LP)end)end part.AssemblyLinearVelocity=Vector3.new(0,-200,0)task.delay(10,function()if part and part.Parent then part:Destroy()end end)task.wait(.05)end
N("Tsunami","Wave deployed",3)TSs.run=false TRT=nil end))
end
local FLY={active=false,speed=50,bv=nil,bg=nil,conn=nil}
local function sFly()
if FLY.active then return end FLY.active=true
local c=LP.Character or LP.CharacterAdded:Wait()
local h=c:FindFirstChild("Humanoid")
local r=c:FindFirstChild("HumanoidRootPart")
if not(h and r)then return end
h.PlatformStand=true
FLY.bv=Instance.new("BodyVelocity",r)FLY.bv.MaxForce=Vector3.new(1e9,1e9,1e9)FLY.bv.Velocity=Vector3.zero
FLY.bg=Instance.new("BodyGyro",r)FLY.bg.MaxTorque=Vector3.new(1e9,1e9,1e9)FLY.bg.P=1e4 FLY.bg.D=1e2
FLY.conn=R.RenderStepped:Connect(function()
if not FLY.active then return end
local mc=LP.Character if not mc then return end
local mh=mc:FindFirstChild("HumanoidRootPart")if not mh then return end
local move=Vector3.zero
if UIS:IsKeyDown(Enum.KeyCode.W)then move=move+Cam.CFrame.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.S)then move=move-Cam.CFrame.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.A)then move=move-Cam.CFrame.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.D)then move=move+Cam.CFrame.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.Space)then move=move+Vector3.new(0,1,0)end
if UIS:IsKeyDown(Enum.KeyCode.LeftControl)then move=move-Vector3.new(0,1,0)end
if move.Magnitude>0 then move=move.Unit*FLY.speed end
FLY.bv.Velocity=move
FLY.bg.CFrame=Cam.CFrame
end)
N("Fly","On",3)end
local function tFly()
FLY.active=false
if FLY.conn then FLY.conn:Disconnect()FLY.conn=nil end
if FLY.bv then FLY.bv:Destroy()FLY.bv=nil end
if FLY.bg then FLY.bg:Destroy()FLY.bg=nil end
local h=MU()if h then h.PlatformStand=false end
N("Fly","Off",2)end
local SPD={active=false,val=100}
local SPDC=nil
local function sSpeed()
if SPD.active then return end SPD.active=true
SPDC=R.Heartbeat:Connect(function()
if not SPD.active then return end
local h=MU()if h then h.WalkSpeed=SPD.val end
end)
N("Speed","On",3)end
local function tSpeed()SPD.active=false if SPDC then SPDC:Disconnect()SPDC=nil end local h=MU()if h then h.WalkSpeed=16 end N("Speed","Off",2)end
local CTP={active=false,conn=nil}
local function sClickTP()
if CTP.active then return end CTP.active=true
CTP.conn=UIS.InputBegan:Connect(function(input,gp)
if gp or not CTP.active then return end
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
local r=MH()if not r then return end
local mouse=LP:GetMouse()
if mouse.Target then
local pos=mouse.Hit.Position+Vector3.new(0,3,0)
r.CFrame=CFrame.new(pos)
r.AssemblyLinearVelocity=Vector3.zero
end
end
end)
N("ClickTP","On",3)end
local function tClickTP()CTP.active=false if CTP.conn then CTP.conn:Disconnect()CTP.conn=nil end N("ClickTP","Off",2)end
local PBG={active=false,thread=nil}
local function sPacketBypass()
if PBG.active then return end PBG.active=true
PBG.thread=reg(task.spawn(function()
while PBG.active do
local my=MH()
if my and STN then
local t=P:FindFirstChild(STN)
local th=PH(t)
if th then
for _=1,5 do
if CG then CG:FireServer(th,th.CFrame)end
if SN then SN:FireServer(th,th.CFrame)end
end
if EG then EG:FireServer(string.rep("X",500))end
end
end
R.Heartbeat:Wait()
endend))
N("PacketBypass","On",3)end
local function tPacketBypass()PBG.active=false if PBG.thread then pcall(task.cancel,PBG.thread)PBG.thread=nil end N("PacketBypass","Off",2)end
local SAG={active=false,thread=nil,radius=15}
local function sAutoGrab()
if SAG.active then return end SAG.active=true
SAG.thread=reg(task.spawn(function()
while SAG.active do
local my=MH()
if my then
for _,p in ipairs(P:GetPlayers())do
if p~=LP and p.Character then
local th=p.Character:FindFirstChild("HumanoidRootPart")
if th and (th.Position-my.Position).Magnitude<=SAG.radius then
for _=1,3 do
if SN then SN:FireServer(th,th.CFrame)end
end
if CG then CG:FireServer(th,th.CFrame)end
end
end
end
end
R.Heartbeat:Wait()
end
end))
N("AutoGrab","On",3)end
local function tAutoGrab()SAG.active=false if SAG.thread then pcall(task.cancel,SAG.thread)SAG.thread=nil end N("AutoGrab","Off",2)end
local TC={active=false,thread=nil,target=nil}
local function sTargetCrasher()
if TC.active then return end
if not STN then N("Crasher","No target",3)return end
TC.active=true TC.target=STN
TC.thread=reg(task.spawn(function()
while TC.active do
local t=P:FindFirstChild(TC.target)
if t and t.Character then
local th=t.Character:FindFirstChild("HumanoidRootPart")
if th then
for _=1,50 do
local part=Instance.new("Part")
part.Size=Vector3.new(math.random(1,5),math.random(1,5),math.random(1,5))
part.Position=th.Position+Vector3.new(math.random(-5,5),math.random(-5,5),math.random(-5,5))
part.Anchored=false part.CanCollide=false part.Transparency=1 part.Parent=W
part.AssemblyLinearVelocity=Vector3.new(math.random(-100,100),math.random(-100,100),math.random(-100,100))
if SN then pcall(function()SN:FireServer(part,part.CFrame)end)end
if part.SetNetworkOwner then pcall(function()part:SetNetworkOwner(LP)end)end
game:GetService("Debris"):AddItem(part,2)
end
end
end
R.Heartbeat:Wait()
end
end))
N("Crasher","On",3)end
local function tTargetCrasher()TC.active=false if TC.thread then pcall(task.cancel,TC.thread)TC.thread=nil end N("Crasher","Off",2)end
local AL={active=false,thread=nil,lastCF=nil}
local function sAntiLagback()
if AL.active then return end AL.active=true
AL.thread=reg(task.spawn(function()
while AL.active do
local r=MH()
if r then
if r.Position.Y<-50 or (AL.lastCF and (r.Position-AL.lastCF.Position).Magnitude>500) then
local safeCF=AL.lastCF or CFrame.new(0,100,0)
r.CFrame=safeCF
r.AssemblyLinearVelocity=Vector3.zero
r.AssemblyAngularVelocity=Vector3.zero
if SN then SN:FireServer(r,safeCF)end
end
AL.lastCF=r.CFrame
end
R.Heartbeat:Wait()
end
end))
N("AntiLagback","On",3)end
local function tAntiLagback()AL.active=false if AL.thread then pcall(task.cancel,AL.thread)AL.thread=nil end AL.lastCF=nil N("AntiLagback","Off",2)end
local Wn=L:CreateWindow({Title="Singularity premium",Footer="All in One",Icon="",NotifySide="Right",ShowCustomCursor=false})
local TB={Main=Wn:AddTab("Main","user"),Kick=Wn:AddTab("Kick","swords"),Kill=Wn:AddTab("Kill","skull"),Defense=Wn:AddTab("Defense","shield"),Grab=Wn:AddTab("Grab","hand"),Dest=Wn:AddTab("Destroy","bomb"),Util=Wn:AddTab("Utility","wrench")}
local TG=TB.Main:AddLeftGroupbox("Target","target")
TG:AddDropdown("TargetDropdown",{Values=PLS(),Default="",Text="Select Target",Searchable=true,Callback=function(s)if s and s~=""then local u=US(s)if u then STN=u N("Target",u,2)end end end})
TG:AddButton({Text="Refresh List",Func=function()if O.TargetDropdown then O.TargetDropdown:SetValues(PLS())end end})
local KL=TB.Kick:AddLeftGroupbox("Kick","swords")
KL:AddToggle("AllKickToggle",{Text="All Kick",Default=false,Callback=function(v)if v then AK_E(false)N("Start","On",2)else AK_S()N("Stop","Off",2)end end})
KL:AddToggle("NoBlobKickToggle",{Text="No Blob Kick",Default=false,Callback=function(v)if v then TL_E(true)N("Start","On",2)else TL_S()N("Stop","Off",2)end end})
KL:AddButton({Text="Kick Selected",Func=function()KAKick(STN)end})
local function mK(n,t,e,s)KL:AddToggle(n,{Text=t,Default=false,Callback=function(v)if v then e()N("Start",t,2)else s()N("Stop",t,2)end end})end
mK("LKA","Lag Kick All",LKAE,LKAS)
mK("LKS","Lag Kick Select",LKSE,LKSS)
mK("LKA2","Lag Kick All Strong",LK2E,LK2S)
mK("LKS2","Lag Kick Select Anti-Pierce",LK3E,LK3S)
mK("LKA3","Grab Kick All Vision",LK4E,LK4S)
mK("LKS3","Grab Kick Select Vision",LK5E,LK5S)
KL:AddToggle("SpamKToggle",{Text="Spam Kick",Default=false,Callback=function(v)if v then if not STN then N("Error","No target",3)T.SpamKToggle:SetValue(false)return end SKStart(STN)N("Start","On",2)else SKStop()N("Stop","Off",2)end end})
KL:AddToggle("DriftKToggle",{Text="Drift Kick",Default=false,Callback=function(v)if v then DStart()N("Start","On",2)else DStop()N("Stop","Off",2)end end})
local KR=TB.Kick:AddRightGroupbox("Kick All Options","zap")
KR:AddDropdown("KAMode",{Text="Mode",Values={"circle","double","spiral"},Default="circle",Callback=function(v)KA.mode=v end})
KR:AddSlider("KARadius",{Text="Radius",Default=10,Min=5,Max=100,Rounding=0,Callback=function(v)KA.r=v end})
KR:AddSlider("KAInner",{Text="Inner",Default=5,Min=5,Max=50,Rounding=0,Callback=function(v)KA.iR=v end})
KR:AddSlider("KAOuter",{Text="Outer",Default=15,Min=10,Max=100,Rounding=0,Callback=function(v)KA.oR=v end})
KR:AddSlider("KAPlayerY",{Text="Player Y",Default=100,Min=10,Max=500,Rounding=0,Callback=function(v)KA.py=v end})
KR:AddButton({Text="Execute Kick All",Func=KAll})
local KB=TB.Kick:AddRightGroupbox("Arkadia","zap")
KB:AddDropdown("AKTarget",{Values=PLS(),Default="",Text="Select",Searchable=true,Callback=function(s)if s and s~=""then local u=US(s)if u then AK.target=u end end end})
KB:AddToggle("AKToggle",{Text="Arkadia Spam Kick",Default=false,Callback=function(v)if v then if AK.target then AKStart(AK.target)else N("Error","No target",3)end else AKStop()end end})
KB:AddSlider("AKRadius",{Text="Radius",Default=10,Min=5,Max=100,Rounding=0,Callback=function(v)AK.rad=v end})
KB:AddSlider("AKSpeed",{Text="Speed",Default=15,Min=1,Max=100,Rounding=0,Callback=function(v)AK.spd=v/100 end})
KB:AddButton({Text="No Blob Kick All",Func=NBRun})
local KLL=TB.Kill:AddLeftGroupbox("Kill","skull")
KLL:AddToggle("KAToggle",{Text="Kill All",Default=false,Callback=function(v)KAll()end})
KLL:AddButton({Text="Void Loop Start",Func=function()if STN then VL.target=P:FindFirstChild(STN)VLStart()else N("Error","No target",3)end end})
KLL:AddButton({Text="Void Loop Stop",Func=VLStop})
KLL:AddSlider("VLInt",{Text="Void Interval",Default=1.5,Min=.1,Max=10,Rounding=1,Callback=function(v)VL.interval=v end})
local DR=TB.Dest:AddLeftGroupbox("Destroy Server","bomb")
DR:AddDropdown("DSHeight",{Text="Height",Values={"Spawn (Ground)","Heaven"},Default="Spawn (Ground)",Callback=function(v)DS.height=(v=="Heaven")and"Heaven"or"Spawn" end})
DR:AddSlider("DSRadius",{Text="Radius",Default=20,Min=5,Max=100,Rounding=0,Callback=function(v)DS.radius=v end})
DR:AddButton({Text="Destroy Server",Func=DSRun})
DR:AddButton({Text="Stop Lag",Func=DSStopLag})
local GL=TB.Grab:AddLeftGroupbox("Grab Effects","hand")
GL:AddToggle("PoisonG",{Text="Poison Grab",Default=false,Callback=function(v)if v then pg=coroutine.create(function()GrabLoop("poison")end)coroutine.resume(pg)else if pg then coroutine.close(pg)pg=nil end end end})
GL:AddToggle("RadioG",{Text="Radioactive Grab",Default=false,Callback=function(v)if v then rg2=coroutine.create(function()GrabLoop("radioactive")end)coroutine.resume(rg2)else if rg2 then coroutine.close(rg2)rg2=nil end end end})
GL:AddToggle("FireG",{Text="Fire Grab",Default=false,Callback=function(v)if v then fg=coroutine.create(FireLoop)coroutine.resume(fg)else if fg then coroutine.close(fg)fg=nil end end end})
local GL2=TB.Grab:AddRightGroupbox("Grab Config","wrench")
GL2:AddToggle("ThrowG",{Text="Throw",Default=false,Callback=function(v)if v then G.throw=W.ChildAdded:Connect(function(m)if m.Name=="GrabParts"then local pt=m:FindFirstChild("GrabPart")if pt and pt:FindFirstChild("WeldConstraint")then pt=pt.WeldConstraint.Part1 if pt then local bv=Instance.new("BodyVelocity",pt)m:GetPropertyChangedSignal("Parent"):Connect(function()if not m.Parent then local li=game:GetService("UserInputService").LastInputType if li==Enum.UserInputType.MouseButton2 or li==Enum.UserInputType.Touch then bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge)bv.Velocity=Cam.CFrame.LookVector*400 game:GetService("Debris"):AddItem(bv,1)else bv:Destroy()end end end)end end end end)elseif G.throw then G.throw:Disconnect()G.throw=nil end end})
local DL=TB.Defense:AddLeftGroupbox("Defense","shield")
DL:AddToggle("AEx",{Text="Anti Explode",Default=false,Callback=function(v)if v then SAE()else DAE()end end})
DL:AddToggle("ABn",{Text="Anti Burn",Default=false,Callback=function(v)if v then SAB()else DAB()end end})
DL:AddToggle("AVd",{Text="Anti Void",Default=false,Callback=SAV})
DL:AddToggle("ABnS",{Text="Anti Banana Sit",Default=false,Callback=SABS})
DL:AddToggle("ABK",{Text="Anti Blob Kill",Default=false,Callback=SABK})
DL:AddToggle("ABR",{Text="Anti Blob Ragdoll",Default=false,Callback=SERB})
DL:AddToggle("AKN",{Text="Anti Kick (Kunai)",Default=false,Callback=function(v)if v then SEK()else DEK()end end})
DL:AddToggle("AGN",{Text="Anti Grab NRD",Default=false,Callback=SENRD})
DL:AddToggle("GOD",{Text="GOD MODE",Default=false,Callback=function(v)if v then SGM()N("GOD","On",3)else TGM()N("GOD","Off",3)end end})
DL:AddToggle("GC",{Text="Gucci Anti Grab",Default=false,Callback=function(v)if v then SGucci()N("Gucci","On",3)else DGucci()N("Gucci","Off",3)end end})
local DR2=TB.Defense:AddRightGroupbox("FTAP Defense","zap")
DR2:AddToggle("NOForce",{Text="Network Take",Default=false,Callback=function(v)if v then sNOF()else tNOF()end end})
DR2:AddToggle("AAR",{Text="Anti Attach Reverse",Default=false,Callback=function(v)if v then sAAR()else tAAR()end end})
DR2:AddToggle("SSF",{Text="Script Freeze",Default=false,Callback=function(v)if v then sSSF()else tSSF()end end})
DR2:AddToggle("PAL",{Text="Physics Anchor",Default=false,Callback=function(v)if v then sPAL()else tPAL()end end})
DR2:AddToggle("ADB",{Text="Anti Desync",Default=false,Callback=function(v)if v then sADB()else tADB()end end})
DR2:AddToggle("CFAF",{Text="CFrame Anti Fling",Default=false,Callback=function(v)if v then sCFAF()else tCFAF()end end})
DR2:AddToggle("HB",{Text="Hitbox Expand",Default=false,Callback=function(v)if v then sHB()else tHB()end end})
DR2:AddToggle("ICP",{Text="Individual Crasher",Default=false,Callback=function(v)if v then sICP()else tICP()end end})
DR2:AddToggle("FlyHack",{Text="Fly Hack",Default=false,Callback=function(v)if v then sFly()else tFly()end end})
DR2:AddSlider("FlySpeed",{Text="Fly Speed",Default=50,Min=10,Max=500,Rounding=0,Callback=function(v)FLY.speed=v end})
DR2:AddToggle("SpeedHack",{Text="Speed Hack",Default=false,Callback=function(v)if v then sSpeed()else tSpeed()end end})
DR2:AddSlider("SpeedVal",{Text="Speed Value",Default=100,Min=16,Max=500,Rounding=0,Callback=function(v)SPD.val=v if SPD.active then local h=MU()if h then h.WalkSpeed=v end end end})
DR2:AddToggle("ClickTP",{Text="Click Teleport (Blink)",Default=false,Callback=function(v)if v then sClickTP()else tClickTP()end end})
DR2:AddToggle("PacketBypass",{Text="Packet Bypass Grab",Default=false,Callback=function(v)if v then sPacketBypass()else tPacketBypass()end end})
DR2:AddToggle("AutoGrab",{Text="Silent Aim & Auto-Grab",Default=false,Callback=function(v)if v then sAutoGrab()else tAutoGrab()end end})
DR2:AddSlider("AutoGrabRad",{Text="Auto-Grab Radius",Default=15,Min=5,Max=100,Rounding=0,Callback=function(v)SAG.radius=v end})
DR2:AddToggle("TargetCrasher",{Text="Target Crasher / Spam",Default=false,Callback=function(v)if v then sTargetCrasher()else tTargetCrasher()end end})
DR2:AddToggle("AntiLagback",{Text="Anti-Lagback Desync",Default=false,Callback=function(v)if v then sAntiLagback()else tAntiLagback()end end})
local UL=TB.Util:AddLeftGroupbox("Plot / Barrier","hammer")
UL:AddButton({Text="Break Barrier",Func=BE})
UL:AddButton({Text="Stop Barrier",Func=BS})
UL:AddButton({Text="Plot Break God",Func=PBG})
UL:AddButton({Text="Run Tsunami",Func=TR})
UL:AddButton({Text="Cleanup Tsunami",Func=TCR})
local UL2=TB.Util:AddRightGroupbox("Teleport","map-pin")
UL2:AddSlider("TPY",{Text="Y Offset",Default=3,Min=-20,Max=50,Rounding=0,Callback=function(v)TOYV=v if TLO then STPR()end end})
UL2:AddButton({Text="Teleport Once",Func=function()if STN then TP(STN,TOYV)else N("Error","No target",2)end end})
UL2:AddToggle("TPL",{Text="Loop Teleport",Default=false,Callback=function(v)TLO=v if v then if STN then STPR()N("TP","On",2)end else STP()end end})
P.PlayerAdded:Connect(function()task.wait(.5)if O.TargetDropdown and O.TargetDropdown.SetValues then O.TargetDropdown:SetValues(PLS())end end)
P.PlayerRemoving:Connect(function()task.wait(.5)if O.TargetDropdown and O.TargetDropdown.SetValues then O.TargetDropdown:SetValues(PLS())end end)
N("Singularity Premium","Loaded",3)
L:OnUnload(function()
cancelAll()
pcall(AK_S)pcall(TL_S)pcall(LKAS)pcall(LKSS)pcall(LK2S)pcall(LK3S)pcall(LK4S)pcall(LK5S)
pcall(SKStop)pcall(DStop)pcall(STP)pcall(DEK)pcall(BS)pcall(TCR)pcall(DSStopLag)pcall(AKStop)pcall(VLStop)
pcall(tNOF)pcall(tAAR)pcall(tSSF)pcall(tPAL)pcall(tADB)pcall(tCFAF)pcall(tHB)pcall(tICP)
pcall(DAE)pcall(DAB)pcall(SAV,false)pcall(SABS,false)pcall(SABK,false)pcall(SERB,false)pcall(SENRD,false)
pcall(DGucci)pcall(TGM)
pcall(tFly)pcall(tSpeed)pcall(tClickTP)pcall(tPacketBypass)pcall(tAutoGrab)pcall(tTargetCrasher)pcall(tAntiLagback)
if SH.bT then task.cancel(SH.bT)end
if pg then coroutine.close(pg)end
if rg2 then coroutine.close(rg2)end
if fg then coroutine.close(fg)end
print("[Singularity Premium] Unloaded")
end)
