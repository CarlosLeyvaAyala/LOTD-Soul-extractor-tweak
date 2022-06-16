Scriptname dbm_soulextractorscript extends ObjectReference

SoulGem property SoulGemGrandFilled auto
SoulGem property SoulGemLesserFilled auto
ObjectReference property MyEffect auto
Actor property RelicHolder auto
Message property DBM_LackCharge auto
SoulGem property SoulGemPettyFilled auto
Explosion property DLC1VampiresBaneExplosion auto
ObjectReference property MyEffect2 auto
SoulGem property SoulGemGreaterFilled auto
SoulGem property SoulGemCommonFilled auto

ObjectReference selfContainer

State Working
  Event OnActivate(ObjectReference akActionRef)
  EndEvent
EndState

Event OnActivate(ObjectReference akActionRef)
  If akActionRef != Game.GetPlayer()
    return
  EndIf

  GoToState("Working")
  selfContainer = GetLinkedRef()
  selfContainer.BlockActivation(true)
  MyEffect2.Enable(true)

  DoProcess(akActionRef)

  MyEffect2.Disable(true)
  selfContainer.BlockActivation(false)
  selfContainer.Activate(akActionRef)
  Utility.Wait(0.1)
  GoToState("")
EndEvent

; Process all items placed in the soul extractor.
Function DoProcess(ObjectReference akActionRef)
  int gemCount = ItemsToGems()

  ; I don't know what is this for. The original script calls it and that's why I call it too.
  Disable(false)

  If gemCount > 0
    TransformGems(gemCount)
  EndIf

  ; I don't know what is this for. The original script calls it and that's why I call it too.
  MyEffect.Disable(true)
EndFunction

; Calculate how many petty soulgems are all items in the extractor worth.
; This function ultimately discards/returns to player all items.
int Function ItemsToGems()
  int i = selfContainer.GetNumItems()
  int gemCount = 0

  While i > 0
    i -= 1
    Weapon weap = selfContainer.GetNthForm(i) as weapon
    If weap
      gemCount += GetWeaponGems(GetCharge(weap), weap)
    Else
      ; Not a weapon. Return to player
      selfContainer.RemoveItem(weap, akOtherContainer = Game.GetPlayer())
    EndIf
  EndWhile

  return gemCount
EndFunction

; Get how much charge a weapon has.
int Function GetCharge(Weapon w)
  selfContainer.RemoveItem(w, akOtherContainer = RelicHolder)
  RelicHolder.EquipItem(w, abSilent = true)
  return RelicHolder.GetAV("RightItemCharge") as int
EndFunction

; Get how many petty soulgems a weapon is worth and discard/return it to player.
int Function GetWeaponGems(int charge, Weapon w)
  If charge <= 250
    RelicHolder.RemoveItem(w, akOtherContainer = Game.GetPlayer())
    DBM_LackCharge.Show()
    return 0
  Else
    RelicHolder.RemoveItem(w)
    return charge / 250
  EndIf
EndFunction

; Transform petty soul gems to final result.
Function TransformGems(int count)
  ; Petty to lesser
  int lesser = count / 2
  int petty = count % 2

  ; Lesser to common
  int common = lesser / 2
  lesser %= 2

  ; Common to greater
  int greater = common / 2
  common %= 2

  ; Greater to grand
  int grand = (greater / 3) * 2
  greater %= 3

  AddGemsToExtractor(petty, lesser, common, greater, grand)

  PlaceAtMe(DLC1VampiresBaneExplosion)
EndFunction

; Add the calculated gem count to the soul extractor.
; This is the final step of gem transformation.
Function AddGemsToExtractor(int p, int l, int c, int gt, int gn)
  selfContainer.AddItem(SoulGemPettyFilled, p)
  selfContainer.AddItem(SoulGemLesserFilled, l)
  selfContainer.AddItem(SoulGemCommonFilled, c)
  selfContainer.AddItem(SoulGemGreaterFilled, gt)
  selfContainer.AddItem(SoulGemGrandFilled, gn)
EndFunction
