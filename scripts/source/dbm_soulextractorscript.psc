Scriptname dbm_soulextractorscript extends ObjectReference

Actor property RelicHolder auto
Explosion property DLC1VampiresBaneExplosion auto
Message property DBM_LackCharge auto
ObjectReference property MyEffect auto
ObjectReference property MyEffect2 auto
SoulGem property SoulGemCommonFilled auto
SoulGem property SoulGemGrandFilled auto
SoulGem property SoulGemGreaterFilled auto
SoulGem property SoulGemLesserFilled auto
SoulGem property SoulGemPettyFilled auto

ObjectReference selfContainer

Event OnActivate(ObjectReference akActionRef)
  If akActionRef != Game.GetPlayer()
    return
  EndIf

  selfContainer = GetLinkedRef()

  string arg = selfContainer.GetFormID() + "|"
  arg += RelicHolder.GetFormID() + "|"
  arg += DLC1VampiresBaneExplosion.GetFormID() + "|"
  arg += DBM_LackCharge.GetFormID() + "|"
  arg += SoulGemPettyFilled.GetFormID() + "|"
  arg += SoulGemLesserFilled.GetFormID() + "|"
  arg += SoulGemCommonFilled.GetFormID() + "|"
  arg += SoulGemGreaterFilled.GetFormID() + "|"
  arg += SoulGemGrandFilled.GetFormID()

  SendModEvent("DBM_SoulExtractorActivation", arg)
  return
EndEvent