--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL         = HeroLib
local Cache      = HeroCache
local Unit       = HL.Unit
local Player     = Unit.Player
local Target     = Unit.Target
local Pet        = Unit.Pet
local Spell      = HL.Spell
local MultiSpell = HL.MultiSpell
local Item       = HL.Item
-- HeroRotation
local HR         = HeroRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Hunter then Spell.Hunter = {} end
Spell.Hunter.Marksmanship = {
  SummonPet                             = Spell(883),
  HuntersMarkDebuff                     = Spell(257284),
  HuntersMark                           = Spell(257284),
  DoubleTap                             = Spell(260402),
  TrueshotBuff                          = Spell(288613),
  Trueshot                              = Spell(288613),
  AimedShot                             = Spell(19434),
  UnerringVisionBuff                    = Spell(274447),
  UnerringVision                        = Spell(274444),
  CallingtheShots                       = Spell(260404),
  SurgingShots                          = Spell(287707),
  Streamline                            = Spell(260367),
  FocusedFire                           = Spell(278531),
  RapidFire                             = Spell(257044),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  AncestralCall                         = Spell(274738),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  CarefulAim                            = Spell(260228),
  ExplosiveShot                         = Spell(212431),
  Barrage                               = Spell(120360),
  AMurderofCrows                        = Spell(131894),
  SerpentSting                          = Spell(271788),
  SerpentStingDebuff                    = Spell(271788),
  ArcaneShot                            = Spell(185358),
  MasterMarksman                        = Spell(260309),
  MasterMarksmanBuff                    = Spell(269576),
  PreciseShotsBuff                      = Spell(260242),
  IntheRhythm                           = Spell(264198),
  PiercingShot                          = Spell(198670),
  SteadyFocus                           = Spell(193533),
  SteadyShot                            = Spell(56641),
  TrickShotsBuff                        = Spell(257622),
  Multishot                             = Spell(257620),
  CounterShot                           = Spell(147362),
  Exhilaration                          = Spell(109304),
  BloodOfTheEnemy                       = MultiSpell(297108, 298273, 298277),
  MemoryOfLucidDreams                   = MultiSpell(298357, 299372, 299374),
  PurifyingBlast                        = MultiSpell(295337, 299345, 299347),
  RippleInSpace                         = MultiSpell(302731, 302982, 302983),
  ConcentratedFlame                     = MultiSpell(295373, 299349, 299353),
  TheUnboundForce                       = MultiSpell(298452, 299376, 299378),
  WorldveinResonance                    = MultiSpell(295186, 298628, 299334),
  FocusedAzeriteBeam                    = MultiSpell(295258, 299336, 299338),
  GuardianOfAzeroth                     = MultiSpell(295840, 299355, 299358),
  RecklessForce                         = Spell(302932)
};
local S = Spell.Hunter.Marksmanship;

-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.Marksmanship = {
  BattlePotionofAgility            = Item(163223),
  GalecallersBoon                  = Item(159614)
};
local I = Item.Hunter.Marksmanship;

-- Rotation Var
local ShouldReturn; -- Used to get the return string
local EnemiesCount;

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Hunter.Commons,
  Marksmanship = HR.GUISettings.APL.Hunter.Marksmanship
};

local EnemyRanges = {40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

local function GetEnemiesCount(range)
  -- Unit Update - Update differently depending on if splash data is being used
  if HR.AoEON() then
    if Settings.Marksmanship.UseSplashData then
      HL.GetEnemies(range, nil, true, Target)
      return Cache.EnemiesCount[range]
    else
      UpdateRanges()
      Everyone.AoEToggleEnemiesUpdate()
      return Cache.EnemiesCount[40]
    end
  else
    return 1
  end
end

S.SerpentSting:RegisterInFlight()

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function MasterMarksmanBuffCheck()
  return (Player:BuffP(S.MasterMarksmanBuff) or (Player:IsCasting(S.AimedShot) and S.MasterMarksman:IsAvailable()))
end

HL.RegisterNucleusAbility(257620, 10, 6)               -- Multi-Shot
HL.RegisterNucleusAbility(120360, 40, 6)               -- Barrage

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Cds, St, Trickshots
  EnemiesCount = GetEnemiesCount(10)
  Precombat = function()
    -- flask
    -- augmentation
    -- food
    -- snapshot_stats
    if Everyone.TargetIsValid() then
      -- potion
      if I.BattlePotionofAgility:IsReady() and Settings.Commons.UsePotions then
        if HR.CastSuggested(I.BattlePotionofAgility) then return "battle_potion_of_agility 12"; end
      end
      -- hunters_mark
      if S.HuntersMark:IsCastableP() and Target:DebuffDown(S.HuntersMarkDebuff) then
        if HR.Cast(S.HuntersMark, Settings.Marksmanship.GCDasOffGCD.HuntersMark) then return "hunters_mark 14"; end
      end
      -- double_tap,precast_time=10
      if S.DoubleTap:IsCastableP() then
        if HR.Cast(S.DoubleTap, Settings.Marksmanship.GCDasOffGCD.DoubleTap) then return "double_tap 18"; end
      end
      -- worldvein_resonance
      if S.WorldveinResonance:IsCastableP() then
        if HR.Cast(S.WorldveinResonance, Settings.Marksmanship.GCDasOffGCD.Essences) then return "worldvein_resonance"; end
      end
      -- guardian_of_azeroth
      if S.GuardianOfAzeroth:IsCastableP() then
        if HR.Cast(S.GuardianOfAzeroth, Settings.Marksmanship.GCDasOffGCD.Essences) then return "guardian_of_azeroth"; end
      end
      -- memory_of_lucid_dreams
      if S.MemoryOfLucidDreams:IsCastableP() then
        if HR.Cast(S.MemoryOfLucidDreams, Settings.Marksmanship.GCDasOffGCD.Essences) then return "memory_of_lucid_dreams"; end
      end
      -- trueshot,precast_time=1.5,if=active_enemies>2
      if S.Trueshot:IsCastableP() and Player:BuffDownP(S.TrueshotBuff) and (EnemiesCount > 2) then
        if HR.Cast(S.Trueshot, Settings.Marksmanship.GCDasOffGCD.Trueshot) then return "trueshot 20"; end
      end
      -- aimed_shot,if=active_enemies<3
      if S.AimedShot:IsReadyP() and (EnemiesCount < 3) then
        if HR.Cast(S.AimedShot) then return "aimed_shot 38"; end
      end
    end
  end
  Cds = function()
    -- hunters_mark,if=debuff.hunters_mark.down&!buff.trueshot.up
    if S.HuntersMark:IsCastableP() and (Target:DebuffDown(S.HuntersMarkDebuff) and Player:BuffDownP(S.TrueshotBuff)) then
      if HR.Cast(S.HuntersMark, Settings.Marksmanship.GCDasOffGCD.HuntersMark) then return "hunters_mark 46"; end
    end
    -- double_tap,if=cooldown.rapid_fire.remains<gcd|cooldown.rapid_fire.remains<cooldown.aimed_shot.remains|target.time_to_die<20
    if S.DoubleTap:IsCastableP() and (S.RapidFire:CooldownRemainsP() < Player:GCD() or S.RapidFire:CooldownRemainsP() < S.AimedShot:CooldownRemainsP() or Target:TimeToDie() < 20) then
      if HR.Cast(S.DoubleTap, Settings.Marksmanship.GCDasOffGCD.DoubleTap) then return "double_tap 50"; end
    end
    -- berserking,if=buff.trueshot.up&(target.time_to_die>cooldown.berserking.duration+duration|(target.health.pct<20|!talent.careful_aim.enabled))|target.time_to_die<13
    if S.Berserking:IsCastableP() and HR.CDsON() and (Player:BuffP(S.TrueshotBuff) and (Target:TimeToDie() > S.Berserking:CooldownRemainsP() + S.Berserking:BaseDuration() or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable())) or Target:TimeToDie() < 13) then
      if HR.Cast(S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials) then return "berserking 86"; end
    end
    -- blood_fury,if=buff.trueshot.up&(target.time_to_die>cooldown.blood_fury.duration+duration|(target.health.pct<20|!talent.careful_aim.enabled))|target.time_to_die<16
    if S.BloodFury:IsCastableP() and HR.CDsON() and (Player:BuffP(S.TrueshotBuff) and (Target:TimeToDie() > S.BloodFury:CooldownRemainsP() + S.BloodFury:BaseDuration() or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable())) or Target:TimeToDie() < 16) then
      if HR.Cast(S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials) then return "blood_fury 90"; end
    end
    -- ancestral_call,if=buff.trueshot.up&(target.time_to_die>cooldown.ancestral_call.duration+duration|(target.health.pct<20|!talent.careful_aim.enabled))|target.time_to_die<16
    if S.AncestralCall:IsCastableP() and HR.CDsON() and (Player:BuffP(S.TrueshotBuff) and (Target:TimeToDie() > S.AncestralCall:CooldownRemainsP() + S.AncestralCall:BaseDuration() or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable())) or Target:TimeToDie() < 16) then
      if HR.Cast(S.AncestralCall, Settings.Commons.OffGCDasOffGCD.Racials) then return "ancestral_call 94"; end
    end
    -- fireblood,if=buff.trueshot.up&(target.time_to_die>cooldown.fireblood.duration+duration|(target.health.pct<20|!talent.careful_aim.enabled))|target.time_to_die<9
    if S.Fireblood:IsCastableP() and HR.CDsON() and (Player:BuffP(S.TrueshotBuff) and (Target:TimeToDie() > S.Fireblood:CooldownRemainsP() + S.Fireblood:BaseDuration() or (Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable())) or Target:TimeToDie() < 9) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 98"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 102"; end
    end
    -- worldvein_resonance
    if S.WorldveinResonance:IsCastableP() then
      if HR.Cast(S.WorldveinResonance, Settings.Marksmanship.GCDasOffGCD.Essences) then return "worldvein_resonance"; end
    end
    -- guardian_of_azeroth,if=cooldown.trueshot.remains<15
    if S.GuardianOfAzeroth:IsCastableP() and (S.Trueshot:CooldownRemainsP() < 15) then
      if HR.Cast(S.GuardianOfAzeroth, Settings.Marksmanship.GCDasOffGCD.Essences) then return "guardian_of_azeroth"; end
    end
    -- ripple_in_space,if=cooldown.trueshot.remains<7
    if S.RippleInSpace:IsCastableP() and (S.Trueshot:CooldownRemainsP() < 7) then
      if HR.Cast(S.RippleInSpace, Settings.Marksmanship.GCDasOffGCD.Essences) then return "ripple_in_space"; end
    end
    -- memory_of_lucid_dreams
    if S.MemoryOfLucidDreams:IsCastableP() then
      if HR.Cast(S.MemoryOfLucidDreams, Settings.Marksmanship.GCDasOffGCD.Essences) then return "memory_of_lucid_dreams"; end
    end
    -- potion,if=buff.trueshot.react&buff.bloodlust.react|buff.trueshot.up&ca_execute|target.time_to_die<25
    if I.BattlePotionofAgility:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.TrueshotBuff) and Player:HasHeroism() or Player:BuffP(S.TrueshotBuff) and ((Target:HealthPercentage() < 20 or Target:HealthPercentage() > 80) and S.CarefulAim:IsAvailable()) or Target:TimeToDie() < 25) then
      if HR.CastSuggested(I.BattlePotionofAgility) then return "battle_potion_of_agility 104"; end
    end
    -- trueshot,if=focus>60&(buff.precise_shots.down&cooldown.rapid_fire.remains&target.time_to_die>cooldown.trueshot.duration_guess+duration|target.health.pct<20|!talent.careful_aim.enabled)|target.time_to_die<15
    if S.Trueshot:IsCastableP() and (Player:Focus() > 60 and (Player:BuffDownP(S.PreciseShotsBuff) and S.RapidFire:CooldownRemainsP() > 0 and Target:TimeToDie() > S.Trueshot:CooldownRemainsP() + S.Trueshot:BaseDuration() or Target:HealthPercentage() < 20 or not S.CarefulAim:IsAvailable()) or Target:TimeToDie() < 15) then
      if HR.Cast(S.Trueshot, Settings.Marksmanship.GCDasOffGCD.Trueshot) then return "trueshot 112"; end
    end
  end
  St = function()
    -- explosive_shot
    if S.ExplosiveShot:IsCastableP() then
      if HR.Cast(S.ExplosiveShot) then return "explosive_shot 126"; end
    end
    -- barrage,if=active_enemies>1
    if S.Barrage:IsReadyP() and (EnemiesCount > 1) then
      if HR.Cast(S.Barrage) then return "barrage 128"; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows, Settings.Marksmanship.GCDasOffGCD.AMurderofCrows) then return "a_murder_of_crows 136"; end
    end
    -- serpent_sting,if=refreshable&!action.serpent_sting.in_flight
    if S.SerpentSting:IsCastableP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff) and not S.SerpentSting:InFlight()) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 138"; end
    end
    -- rapid_fire,if=buff.trueshot.down|focus<70
    if S.RapidFire:IsCastableP() and (Player:BuffDownP(S.TrueshotBuff) or Player:Focus() < 70) then
      if HR.Cast(S.RapidFire) then return "rapid_fire 152"; end
    end
    -- arcane_shot,if=buff.trueshot.up&buff.master_marksman.up&!buff.memory_of_lucid_dreams.up
    if S.ArcaneShot:IsCastableP() and (Player:BuffP(S.TrueshotBuff) and MasterMarksmanBuffCheck() and not Player:BuffP(S.MemoryOfLucidDreams)) then
      if HR.Cast(S.ArcaneShot) then return "arcane_shot 158"; end
    end
    -- aimed_shot,if=buff.trueshot.up|(buff.double_tap.down|ca_execute)&buff.precise_shots.down|full_recharge_time<cast_time
    if S.AimedShot:IsReadyP() and (Player:BuffP(S.TrueshotBuff) or (Player:BuffDownP(S.DoubleTap) or ((Target:HealthPercentage() < 20 or Target:HealthPercentage() > 80) and S.CarefulAim:IsAvailable())) and Player:BuffDownP(S.PreciseShotsBuff) or S.AimedShot:FullRechargeTimeP() < S.AimedShot:CastTime()) then
      if HR.Cast(S.AimedShot) then return "aimed_shot 170"; end
    end
    -- arcane_shot,if=buff.trueshot.up&buff.master_marksman.up&buff.memory_of_lucid_dreams.up
    if S.ArcaneShot:IsCastableP() and (Player:BuffP(S.TrueshotBuff) and MasterMarksmanBuffCheck() and Player:BuffP(S.MemoryOfLucidDreams)) then
      if HR.Cast(S.ArcaneShot) then return "arcane_shot 176"; end
    end
    -- piercing_shot
    if S.PiercingShot:IsCastableP() then
      if HR.Cast(S.PiercingShot) then return "piercing_shot 198"; end
    end
    -- focused_azerite_beam
    if S.FocusedAzeriteBeam:IsCastableP() then
      if HR.Cast(S.FocusedAzeriteBeam, Settings.Marksmanship.GCDasOffGCD.Essences) then return "focused_azerite_beam"; end
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      if HR.Cast(S.PurifyingBlast, Settings.Marksmanship.GCDasOffGCD.Essences) then return "purifying_blast"; end
    end
    -- concentrated_flame
    if S.ConcentratedFlame:IsCastableP() then
      if HR.Cast(S.ConcentratedFlame, Settings.Marksmanship.GCDasOffGCD.Essences) then return "concentrated_flame"; end
    end
    -- blood_of_the_enemy
    if S.BloodOfTheEnemy:IsCastableP() then
      if HR.Cast(S.BloodOfTheEnemy, Settings.Marksmanship.GCDasOffGCD.Essences) then return "blood_of_the_enemy"; end
    end
    -- the_unbound_force
    if S.TheUnboundForce:IsCastableP() then
      if HR.Cast(S.TheUnboundForce, Settings.Marksmanship.GCDasOffGCD.Essences) then return "the_unbound_force"; end
    end
    -- arcane_shot,if=buff.trueshot.down&(buff.precise_shots.up&(focus>41|buff.master_marksman.up)|(focus>50&azerite.focused_fire.enabled|focus>75)&(cooldown.trueshot.remains>5|focus>80)|target.time_to_die<5)
    if S.ArcaneShot:IsCastableP() and (Player:BuffDownP(S.TrueshotBuff) and (Player:BuffP(S.PreciseShotsBuff) and (Player:Focus() > 41 or MasterMarksmanBuffCheck()) or (Player:Focus() > 50 and S.FocusedFire:IsAvailable() or Player:Focus() > 75) and (S.Trueshot:CooldownRemainsP() > 5 or Player:Focus() > 80) or Target:TimeToDie() < 5)) then
      if HR.Cast(S.ArcaneShot) then return "arcane_shot 200"; end
    end
    -- steady_shot
    if S.SteadyShot:IsCastableP() then
      if HR.Cast(S.SteadyShot) then return "steady_shot 208"; end
    end
  end
  Trickshots = function()
    -- barrage
    if S.Barrage:IsReadyP() then
      if HR.Cast(S.Barrage) then return "barrage 210"; end
    end
    -- explosive_shot
    if S.ExplosiveShot:IsCastableP() then
      if HR.Cast(S.ExplosiveShot) then return "explosive_shot 212"; end
    end
    -- aimed_shot,if=buff.trick_shots.up&ca_execute&buff.double_tap.up
    if S.AimedShot:IsReadyP() and (Player:BuffP(S.TrickShotsBuff) and ((Target:HealthPercentage() < 20 or Target:HealthPercentage() > 80) and S.CarefulAim:IsAvailable()) and Player:BuffP(S.DoubleTap)) then
      if HR.Cast(S.AimedShot) then return "aimed_shot 213"; end
    end
    -- rapid_fire,if=buff.trick_shots.up&(azerite.focused_fire.enabled|azerite.in_the_rhythm.rank>1|azerite.surging_shots.enabled|talent.streamline.enabled)
    if S.RapidFire:IsCastableP() and (Player:BuffP(S.TrickShotsBuff) and (S.FocusedFire:AzeriteEnabled() or S.IntheRhythm:AzeriteRank() > 1 or S.SurgingShots:AzeriteEnabled() or S.Streamline:IsAvailable())) then
      if HR.Cast(S.RapidFire) then return "rapid_fire 214"; end
    end
    -- aimed_shot,if=buff.trick_shots.up&(buff.precise_shots.down|cooldown.aimed_shot.full_recharge_time<action.aimed_shot.cast_time|buff.trueshot.up)
    if S.AimedShot:IsReadyP() and (Player:BuffP(S.TrickShotsBuff) and (Player:BuffDownP(S.PreciseShotsBuff) or S.AimedShot:FullRechargeTimeP() < S.AimedShot:CastTime() or Player:BuffP(S.TrueshotBuff))) then
      if HR.Cast(S.AimedShot) then return "aimed_shot 226"; end
    end
    -- rapid_fire,if=buff.trick_shots.up
    if S.RapidFire:IsCastableP() and (Player:BuffP(S.TrickShotsBuff)) then
      if HR.Cast(S.RapidFire) then return "rapid_fire 238"; end
    end
    -- multishot,if=buff.trick_shots.down|buff.precise_shots.up&!buff.trueshot.up|focus>70
    if S.Multishot:IsCastableP() and (Player:BuffDownP(S.TrickShotsBuff) or Player:BuffP(S.PreciseShotsBuff) and Player:BuffDownP(S.TrueshotBuff) or Player:Focus() > 70) then
      if HR.Cast(S.Multishot) then return "multishot 242"; end
    end
    -- focused_azerite_beam
    if S.FocusedAzeriteBeam:IsCastableP() then
      if HR.Cast(S.FocusedAzeriteBeam, Settings.Marksmanship.GCDasOffGCD.Essences) then return "focused_azerite_beam"; end
    end
    -- purifying_blast
    if S.PurifyingBlast:IsCastableP() then
      if HR.Cast(S.PurifyingBlast, Settings.Marksmanship.GCDasOffGCD.Essences) then return "purifying_blast"; end
    end
    -- concentrated_flame
    if S.ConcentratedFlame:IsCastableP() then
      if HR.Cast(S.ConcentratedFlame, Settings.Marksmanship.GCDasOffGCD.Essences) then return "concentrated_flame"; end
    end
    -- blood_of_the_enemy
    if S.BloodOfTheEnemy:IsCastableP() then
      if HR.Cast(S.BloodOfTheEnemy, Settings.Marksmanship.GCDasOffGCD.Essences) then return "blood_of_the_enemy"; end
    end
    -- the_unbound_force
    if S.TheUnboundForce:IsCastableP() then
      if HR.Cast(S.TheUnboundForce, Settings.Marksmanship.GCDasOffGCD.Essences) then return "the_unbound_force"; end
    end
    -- piercing_shot
    if S.PiercingShot:IsCastableP() then
      if HR.Cast(S.PiercingShot) then return "piercing_shot 248"; end
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsCastableP() then
      if HR.Cast(S.AMurderofCrows, Settings.Marksmanship.GCDasOffGCD.AMurderofCrows) then return "a_murder_of_crows 250"; end
    end
    -- serpent_sting,if=refreshable&!action.serpent_sting.in_flight
    if S.SerpentSting:IsCastableP() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff) and not S.SerpentSting:InFlight()) then
      if HR.Cast(S.SerpentSting) then return "serpent_sting 252"; end
    end
    -- steady_shot
    if S.SteadyShot:IsCastableP() then
      if HR.Cast(S.SteadyShot) then return "steady_shot 266"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- Self heal, if below setting value
    if S.Exhilaration:IsCastableP() and Player:HealthPercentage() <= Settings.Commons.ExhilarationHP then
      if HR.Cast(S.Exhilaration, Settings.Commons.GCDasOffGCD.Exhilaration) then return "exhilaration"; end
    end
    -- Interrupts
    Everyone.Interrupt(40, S.CounterShot, Settings.Commons.OffGCDasOffGCD.CounterShot, false);
    -- auto_shot
    -- use_item,name=galecallers_boon,if=buff.trueshot.up|!talent.calling_the_shots.enabled|target.time_to_die<10
    if I.GalecallersBoon:IsReady() and (Player:BuffP(S.TrueshotBuff) or not S.CallingtheShots:IsAvailable() or Target:TimeToDie() < 10) then
      if HR.CastSuggested(I.GalecallersBoon) then return "galecallers_boon"; end
    end
    -- use_items,if=buff.trueshot.up|!talent.calling_the_shots.enabled|target.time_to_die<20
    -- call_action_list,name=cds
    if (true) then
      local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=st,if=active_enemies<3
    if (EnemiesCount < 3) then
      local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
    end
    -- call_action_list,name=trickshots,if=active_enemies>2
    if (EnemiesCount > 2) then
      local ShouldReturn = Trickshots(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

HR.SetAPL(254, APL)
