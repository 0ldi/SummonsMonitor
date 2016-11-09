-- ===============================================================================

-- By Zayla of Dethecus

-- ===============================================================================

-- Saved Stuff goes here

SummonsMonitor_Messages = {}
SummonsMonitor_Messages.announceSummon = " <%t> under summoning! ASSIST ME"; --"I am summoning %t.  Please click the portal.";
SummonsMonitor_Messages.announceSoulst = " <%t> under soulstoning!"; --"I am saving %t's soul in a soulstone.";
--need help to add this (not working): ..GetMinimapZoneText()..
-- ===============================================================================

SummonsMonitor_CoolOffTime         =  20;   -- Seconds
SummonsMonitor_ClearSummonedTime   = 600;   -- Seconds

BINDING_HEADER_SUMMONSMONITORHEADER = "Summons Monitor -- by Zayla";
BINDING_NAME_SUMMONSMONITOR_TOGGLEWINDOW = "Toggle window";
BINDING_NAME_SUMMONSMONITOR_SUMMONNEXT = "Summon next";

-- ===============================================================================

local SummonsList = {};  
-- Format is:  SummonsList["PlayerName"] is a structure with entries
--   .name
--   .status
--   .warlock
--   .time
-- .name is the name of the player
-- .status is one of:
--   REQUEST   -- Has requested a summons
--   SUMMONED  -- Has been/is being summoned by a warlock 
--   CLOSE     -- Has requested but is nearby
--   OUTZONE   -- Has requested but we are in an instance and they are not in it with us
--   NOTGROUP  -- this person is not in our group
--   MYSELF    -- this person is you... duh
-- .warlock is the name of the Warlock we think summoned the player
-- .time is the time that the request came in / last status change

local SortedSummonsNameList = {};  


local MonitorActive = true;

local REQUEST  = "REQUEST";
local SUMMONED = "SUMMONED";
local CLOSE    = "CLOSE";
local OUTZONE  = "OUTZONE"; 
local NOTGROUP = "NOTGROUP"; 
local MYSELF   = "MYSELF"; 

local NumEntries = 16;
local WidgetList = nil;
-- Format is: WidgetList[1..NumEntries] is a structure with members
--   .entry -- the main entry widget
--   .name  -- name widget
--   .status -- status widget

-- ===============================================================================

function SummonsMonitor_SayMessage(msg) 
  local chan = "PARTY";
  if UnitInRaid("player") then 
    chan = "RAID";
  end

  if (GetNumPartyMembers() == 0) then
    chan = "SAY";

  -- If we're not in a group, keep messages private.
  if (UnitName("Target")) then
    DEFAULT_CHAT_FRAME:AddMessage(string.gsub(msg,"%%t",UnitName("Target")));
  else
    DEFAULT_CHAT_FRAME:AddMessage(string.gsub(msg,"%%t","<no target>"));
  end 
  else
    SendChatMessage(msg,chan);
  end
end

-- ===============================================================================


function SummonsMonitor_StatusMessage(msg) 
  DEFAULT_CHAT_FRAME:AddMessage("Summons Monitor: " .. msg);
end  

-- ===============================================================================
                                                
function SummonsMonitor_SummonTarget()
  if (not UnitName("Target")) then
    SummonsMonitor_StatusMessage("No one is targeted.");
  else
    CastSpellByName('Ritual of Summoning');
  end
end

-- ===============================================================================

function SummonsMonitor_SlashCallBack(arg) 

  if (string.lower(arg) == "hide") then 
    SummonsMonitor_MainWindow_Hide();
  elseif (string.lower(arg) == "show") then 
    SummonsMonitor_MainWindow_Show();

  elseif (string.lower(string.sub(arg,1,7)) == "setmsg ") then 
    local newmsg = string.sub(arg,8)
    local target, lock = SummonsMonitor_IsSummonsNotice(string.lower(newmsg,"---"));
    if (target ~= "%t") then
      SummonsMonitor_StatusMessage("That summons message would not work.  See README file.");
    else
      SummonsMonitor_Messages.announceSummon = newmsg;
      SummonsMonitor_StatusMessage("Summons message now set to: " .. SummonsMonitor_Messages.announceSummon);
    end
  elseif (string.lower(arg) == "showmsg") then 
    if (SummonsMonitor_Messages.announceSummon) then
      SummonsMonitor_StatusMessage("Summons message is: " .. SummonsMonitor_Messages.announceSummon);
    else
      SummonsMonitor_StatusMessage("Summons message is disabled.");
    end
  elseif (string.lower(arg) == "nomsg") then 
    SummonsMonitor_StatusMessage("Summons message disabled.");
    SummonsMonitor_Messages.announceSummon = nil;

  elseif (string.lower(string.sub(arg,1,8)) == "setsoul ") then 
    local newmsg = string.sub(arg,9)
    SummonsMonitor_Messages.announceSoulst = newmsg;
    SummonsMonitor_StatusMessage("Soulstone message now set to: " .. SummonsMonitor_Messages.announceSoulst);
  elseif (string.lower(arg) == "showsoul") then 
    if (SummonsMonitor_Messages.announceSoulst) then
      SummonsMonitor_StatusMessage("Soulstone message is: " .. SummonsMonitor_Messages.announceSoulst);
    else
      SummonsMonitor_StatusMessage("Soulstone message is disabled.");
    end
  elseif (string.lower(arg) == "nosoul") then 
    SummonsMonitor_StatusMessage("Soulstone message disabled.");
    SummonsMonitor_Messages.announceSoulst = nil;

  elseif (string.lower(arg) == "next") then 
    SummonsMonitor_SummonNext()

  elseif (string.lower(arg) == "clear") then 
    SummonsMonitor_ClearList()

  else
    SummonsMonitor_StatusMessage("Usage:");
    SummonsMonitor_StatusMessage(" /smbz show     --  Shows the window");
    SummonsMonitor_StatusMessage(" /smbz hide     --  hides the window");
    SummonsMonitor_StatusMessage(" /smbz showmsg     --  display the summons message");
    SummonsMonitor_StatusMessage(" /smbz setmsg ...     --  set the summons message");
    SummonsMonitor_StatusMessage(" /smbz nomsg    --  disables summons messages from Summons Monitor");
    SummonsMonitor_StatusMessage(" /smbz next     --  summons the next person in the queue");
    SummonsMonitor_StatusMessage(" /smbz clear    --  clears the list");
    SummonsMonitor_StatusMessage(" /smbz help     --  prints this message");
    SummonsMonitor_StatusMessage("Use \%t in your summons message to indicate your target."); 
    SummonsMonitor_StatusMessage("See README file for more help."); 
  end
end

-- ===============================================================================

function SummonsMonitor_OnLoad() 
  SummonsMonitor_StatusMessage("Summons Monitor -- by Zayla.");

  -- Set up "slash" commands
  SLASH_SUMMONSMONITOR1 = "/SummonsMonitor";
  SLASH_SUMMONSMONITOR2 = "/smbz";
  SlashCmdList["SUMMONSMONITOR"] = SummonsMonitor_SlashCallBack;

  SummonsMonitor_StatusMessage("Addon loaded.");
  SummonsMonitor_StatusMessage("Type /smbz for usage and help");
end


-- ===============================================================================

function SummonsMonitor_ClearList()
  SummonsList           = {};
  SortedSummonsNameList = {};  
  SummonsMonitor_UpdateUIList(); 
end

-- ===============================================================================

function SummonsMonitor_OnEvent(event, arg1, arg2) 
   if (MonitorActive and (event == "SPELLCAST_START")) then
     if ((arg1 == "Ritual of Summoning") and SummonsMonitor_Messages.announceSummon) then
       SummonsMonitor_SayMessage(SummonsMonitor_Messages.announceSummon);
     elseif ((arg1 == "Soulstone Resurrection") and SummonsMonitor_Messages.announceSoulst) then
       SummonsMonitor_SayMessage(SummonsMonitor_Messages.announceSoulst);
     end

   elseif (MonitorActive and (string.sub(event,1,8) == "CHAT_MSG_WHISPER")) then
     SummonsMonitor_ProcessMessage(arg1,arg2,true);

   elseif (MonitorActive and (string.sub(event,1,8) == "CHAT_MSG")) then
     SummonsMonitor_ProcessMessage(arg1,arg2,false);

   elseif (event == "ACTIONBAR_UPDATE_COOLDOWN") then  -- <>
     SummonsMonitor_TestCoolDowns();

   else
     if (not arg1) then arg1 = "nil"; end	
     SummonsMonitor_StatusMessage("Got event: " .. event .. "-" .. arg1);
   end
end

-- ===============================================================================

local spellID  = nil;
local spellName = "Howl of Terror";
local spellRank = "Rank 2";
local spellWaiting = false;
local spellColor = {r = 0.0, g = 1.0, b = 0.0};

function SummonsMonitor_TestCoolDowns() -- <>
  
  if (not spellID) then
    SummonsMonitor_StatusMessage("Looking for spells.");
    local n , r , i ;
    n = "-";
    i = 1;
    while (n) do
      n , r = GetSpellName(i, BOOKTYPE_SPELL);
      SummonsMonitor_StatusMessage("-" .. n .. "-" .. r .. "-");
      if ((n == spellName) and (r == spellRank)) then
        spellID = i;
        n = nil;
      end
      i = i + 1;
    end
  end

  local start , duration = GetSpellCooldown(spellID, BOOKTYPE_SPELL);

  if (spellWaiting and ((start == 0) or (duration == 0))) then
    spellWaiting = false;
    SummonsMonitor_StatusMessage(spellName .. " is ready.");
    SCT_Display(spellName .. " ready", spellColor);
 -- /script CT_RA_WarningFrame:AddMessage("QQ" , 0, 1, 0, 1, 0);
  elseif ((not spellWaiting) and ((start > 0) and (duration > 0))) then
    local timeLeft = duration - ( GetTime() - start );
    if (timeLeft > 5) then
      spellWaiting = true;
      SummonsMonitor_StatusMessage(spellName .. " on cooldown.");  
    end
  end

end

-- ===============================================================================

function SummonsMonitor_ProcessMessage(msg, speaker, wasTell) 

  local lmsg     = string.gsub(string.lower(msg),"%p"," ");  -- <<>> Does this work?
  local lspeaker = string.lower(speaker);

  local summontTarget, summonWarlock;

  summontTarget = SummonsMonitor_IsSummonsRequest(lmsg, lspeaker);

  if (summontTarget) then
    SummonsMonitor_EnterRequest(summontTarget, wasTell);
    return;
  end

  summontTarget, summonWarlock = SummonsMonitor_IsSummonsNotice(lmsg, lspeaker);

  if (summontTarget and summonWarlock) then
    SummonsMonitor_MarkSummoned(summontTarget, summonWarlock);
    return;
  end
    
end


-- ===============================================================================

function SummonsMonitor_MarkSummoned(name, warlock) 

  if (not SummonsList[name]) then
    SummonsList[name] = {};
  end

  SummonsList[name].name    = target;
  SummonsList[name].status  = SUMMONED;
  SummonsList[name].warlock = warlock;
  SummonsList[name].time    = GetTime();

  SummonsMonitor_UpdateUIList();
end

-- ===============================================================================

function SummonsMonitor_EnterRequest(target, wasTell) 
 
  local name    = target;
  local status  = REQUEST;
  local warlock = nil;
  local time    = GetTime();

  local isGroup , unitID = SummonsMonitor_IsGroupMember(target);

  if (not SummonsList[name]) then
    SummonsList[name] = {};
  end

  if (SummonsList[name].status == SUMMONED) then
    -- Someone should have summoned them... check cool off 
    if ((time - SummonsList[name].time) < SummonsMonitor_CoolOffTime) then
      return;
    end
  end

  if (not isGroup) then 
    status = NOTGROUP;
  elseif (unitID == "player") then
    status = MYSELF;
  elseif (SummonsMonitor_CheckClose(unitID)) then
    status = CLOSE;
  elseif (SummonsMonitor_CheckOutZone(unitID)) then
    status = OUTZONE;
  end

  if ((SummonsList[name].status == REQUEST) and (status == REQUEST)) then
    return;
  end

  -- Noobs using a tell... bah!
  if (wasTell) then
    time = time - 100;
  end


  SummonsList[name].name    = name;
  SummonsList[name].status  = status;
  SummonsList[name].warlock = warlock;
  SummonsList[name].time    = time;

  SummonsMonitor_UpdateUIList(); 
end

-- ===============================================================================

function SummonsMonitor_IsSummonsRequest(lmsg, lspeaker) 

  if ((lmsg == "summon") or
      (lmsg == "sumon") or
	  string.find(lmsg,"сумон" ) or
	  string.find(lmsg,"суман" ) or
	  string.find(lmsg,"суммон" ) or
	  string.find(lmsg,"сумман" ) or
	  string.find(lmsg,"самон" ) or
	  string.find(lmsg,"саман" ) or
	  string.find(lmsg,"саммон" ) or
	  string.find(lmsg,"самман" ) or
      string.find(lmsg,"summon me" ) or
      string.find(lmsg,"summonme"  ) or
      string.find(lmsg,"sumon"  ) or
      string.find(lmsg,"summone me") or
      string.find(lmsg,"summon pls") or
      string.find(lmsg,"summon plz") or
      string.find(lmsg,"wtb summon") or
      string.find(lmsg,"summon please")) then
    return lspeaker;
  end

  if (string.find(lmsg,"summon") and
      (not string.find(lmsg,"summoning")) and
      (not string.find(lmsg,"portal")) and
      (not string.find(lmsg,"click"))) then
    local t,n;
    for t in string.gfind(lmsg, "%S+") do
       n = SummonsMonitor_IsGroupMember(t);
       if (n and (n ~= lspeaker) ) then
         return n;
       end
    end
  end

  return nil;
end

-- ===============================================================================

function SummonsMonitor_IsSummonsNotice(lmsg, lspeaker) 

  if (string.find(lmsg,"summoning") or
      (string.find(lmsg,"summon") and string.find(lmsg,"click")) or
      (string.find(lmsg,"portal") and string.find(lmsg,"click"))) then
    local t,n;
    for t in string.gfind(lmsg, "%S+") do
       n = SummonsMonitor_IsGroupMember(t);
       if (n and (n ~= lspeaker) ) then
         return n, lspeaker;
       end
    end
  end

  return nil , nil;
end

-- ===============================================================================

function SummonsMonitor_CheckClose(unitID)
  if (unitID and CheckInteractDistance(unitID, 4)) then 
    return true;
  else
    return false;
  end
end

-- ===============================================================================

function SummonsMonitor_CheckOutZone(unitID)
  -- <>
  return false;
end


-- ===============================================================================

function SummonsMonitor_IsGroupMember(name)
  local lname = string.lower(name); 
  local i;
  if (string.find(lname,"%t",1,true)) then
    return "%t" , nil;
  end
  if (SummonsMonitor_SafeLower(UnitName("player")) == lname) then 
    return name , "player";
  end
  if (UnitInRaid("player")) then 
    for i = 1, 40 do
       if (SummonsMonitor_SafeLower(UnitName("raid"..i)) == lname) then
         return name , "raid"..i;
       end
    end
  else
    for i = 1, 4 do
       if (SummonsMonitor_SafeLower(UnitName("party"..i)) == lname) then
         return name , "party"..i;
       end
    end
  end
  return false , nil;
end

-- ===============================================================================

local function entComp(n1,n2) 

  if (not SummonsList[n2]) then 
    return true;
  end

  if (not SummonsList[n1]) then 
    return false;
  end

  local v1 = SummonsList[n1].time;
  local v2 = SummonsList[n2].time;

  if (SummonsList[n1].status == SUMMONED) then
    v1 = v1 + 10000;
  end

  if (SummonsList[n2].status == SUMMONED) then
    v2 = v2 + 10000;
  end

  if (SummonsList[n1].status == NOTGROUP) then
    v1 = v1 + 9000;
  end

  if (SummonsList[n2].status == NOTGROUP) then
    v2 = v2 + 9000;
  end

  if (SummonsList[n1].status == MYSELF) then
    v1 = v1 + 8000;
  end

  if (SummonsList[n2].status == MYSELF) then
    v2 = v2 + 8000;
  end

  if (SummonsList[n1].status == OUTZONE) then
    v1 = v1 + 7000;
  end

  if (SummonsList[n2].status == OUTZONE) then
    v2 = v2 + 7000;
  end

  if (SummonsList[n1].status == CLOSE) then
    v1 = v1 + 6000;
  end

  if (SummonsList[n2].status == CLOSE) then
    v2 = v2 + 6000;
  end

  return (v1 < v2);
end

-- ===============================================================================

function SummonsMonitor_UpdateUIList()

  local time = GetTime();
  SortedSummonsNameList = {};

  table.insert(SortedSummonsNameList,"no body");
    
  for name in pairs(SummonsList) do
    if (SummonsList[name] and ((time - SummonsList[name].time) > SummonsMonitor_ClearSummonedTime)) then
      SummonsList[name] = nil;   
    else
      table.insert(SortedSummonsNameList,name);
    end
  end
  table.sort(SortedSummonsNameList,entComp);


  if (WidgetList) then
    local pos = 1;
    local name;

    for _, name in ipairs(SortedSummonsNameList) do
      if (SummonsList[name]) then

        local uname = string.upper(string.sub(name,1,1))..string.sub(name,2);
        
        local status  = SummonsList[name].status;
        local warlock = SummonsList[name].warlock;

        if (pos <= NumEntries) then
          WidgetList[pos].entry:SetText(name);
          WidgetList[pos].name :SetText(uname);

          if (status == REQUEST) then
            WidgetList[pos].status:SetText("");
          elseif ((status == SUMMONED) and (warlock)) then
            local uwarlock = string.upper(string.sub(warlock,1,1))..string.sub(warlock,2);
            WidgetList[pos].status:SetText("> "..uwarlock);
          elseif (status == CLOSE) then
            WidgetList[pos].status:SetText("Nearby");
          elseif (status == OUTZONE) then
            WidgetList[pos].status:SetText("Outside");
          elseif (status == NOTGROUP) then
            WidgetList[pos].status:SetText("Not in group");
          elseif (status == MYSELF) then
            WidgetList[pos].status:SetText("This is you");
          else
            WidgetList[pos].status:SetText("Error");
          end
          WidgetList[pos].entry:Show();
          pos = pos + 1;
        end
      end
    end

    for i = pos, NumEntries do
      WidgetList[i].entry:Hide();
    end
  end
end



-- ===============================================================================

UIPanelWindows["SummonsMonitor_MainWindow"] = { area = "left", pushable = 998 };

function SummonsMonitor_MainWindow_ToggleVisible()
  if (  SummonsMonitor_MainWindow:IsVisible() ) then 
    SummonsMonitor_MainWindow_Hide()
  else
    SummonsMonitor_MainWindow_Show()
  end
end

function SummonsMonitor_MainWindow_Show()
  SummonsMonitor_MainWindow_Title:SetText("Summons Monitor -- by Zayla");
  ShowUIPanel(SummonsMonitor_MainWindow);
  SummonsMonitor_BuildWidgetList();
  SummonsMonitor_UpdateUIList()
end

function SummonsMonitor_MainWindow_Hide()
  HideUIPanel(SummonsMonitor_MainWindow);
end

-- ===============================================================================

function SummonsMonitor_EntryClicked(name) 
  TargetByName(name, true);  
end

-- ===============================================================================

function SummonsMonitor_BuildWidgetList()
  if (not WidgetList) then
    WidgetList = {};
    local i;
    for i = 1, NumEntries do

      WidgetList[i] = {};
      WidgetList[i].entry  = getglobal("SummonsMonitor_Entry"..i); 
      WidgetList[i].name   = getglobal("SummonsMonitor_Entry"..i.."_NameString"); 
      WidgetList[i].status = getglobal("SummonsMonitor_Entry"..i.."_StatusString"); 

      WidgetList[i].entry :SetText("-----");
      WidgetList[i].name  :SetText("Name " .. i);
      WidgetList[i].status:SetText("Status " .. i);
    end
  end
end

-- ===============================================================================

function SummonsMonitor_SafeLower(s) 
  if (s) then 
    return string.lower(s);
  else
    return nil;
  end
end


-- ===============================================================================


function SummonsMonitor_SummonNext()
  
  local nextName = SortedSummonsNameList[1];
  
  if (nextName and SummonsList[nextName]) then 
    local uname = string.upper(string.sub(nextName,1,1))..string.sub(nextName,2);
    if (SummonsList[nextName].status == REQUEST) then
      SummonsMonitor_StatusMessage("Pulling " .. uname .. " from queue for summons."); 
    elseif (SummonsList[nextName].status == CLOSE) then
      SummonsMonitor_StatusMessage("Pulling " .. uname .. " (Nearby) from queue for summons."); 
    else
      SummonsMonitor_StatusMessage("No eligible targets left in queue.");
      return;
    end
    TargetByName(nextName, true);  
    CastSpellByName("Ritual of Summoning");
  else
    SummonsMonitor_StatusMessage("No targets left in queue.");
  end
end

-- ===============================================================================
