import {
  on,
  Game,
  ObjectReference,
  Actor,
  Explosion,
  Message,
  SoulGem,
  Weapon,
} from "skyrimPlatform"
import { FormLib } from "DmLib"

export function main() {
  on("modEvent", (e) => {
    if (e.eventName !== "DBM_SoulExtractorActivation") return
    Process(e.strArg)
  })
}

let container: ObjectReference
let relicHolder: Actor
let explosion: Explosion
let lackCharge: Message
let sgPetty: SoulGem
let sgLesser: SoulGem
let sgCommon: SoulGem
let sgGrand: SoulGem
let sgGreater: SoulGem

function Process(formIds: string) {
  StrToObjs(formIds)
  const gemCount = ItemsToGems()
  if (gemCount > 0) {
    TransformGems(gemCount)
    container.placeAtMe(explosion, 1, false, false)
  }

  container.activate(Game.getPlayer(), true)
}

/** Gets objects needed for this script to work. */
function StrToObjs(formIds: string) {
  const ids = formIds.split("|").map((s) => Number(s))
  const G = (i: number) => Game.getFormEx(ids[i])

  container = ObjectReference.from(G(0)) as ObjectReference
  relicHolder = Actor.from(G(1)) as Actor
  explosion = Explosion.from(G(2)) as Explosion
  lackCharge = Message.from(G(3)) as Message
  sgPetty = SoulGem.from(G(4)) as SoulGem
  sgLesser = SoulGem.from(G(5)) as SoulGem
  sgCommon = SoulGem.from(G(6)) as SoulGem
  sgGreater = SoulGem.from(G(7)) as SoulGem
  sgGrand = SoulGem.from(G(8)) as SoulGem
}

/** Calculate how many petty soulgems are all items in the extractor worth. \
 * This function ultimately discards/returns to player all items. */
function ItemsToGems() {
  let count = 0
  const cn = container
  const p = FormLib.Player()

  FormLib.ForEachItemREx(cn, (weap) => {
    const w = Weapon.from(weap)
    if (!w) {
      cn.removeItem(weap, cn.getItemCount(weap), true, p)
      return
    }

    count += GetWeaponGems(GetCharge(w), w)
  })
  return count
}

/** Get how many petty soulgems a weapon is worth and discard/return it to player. */
function GetWeaponGems(charge: number, w: Weapon) {
  const n = relicHolder.getItemCount(w)
  if (charge <= 250) {
    relicHolder.removeItem(w, n, true, FormLib.Player())
    lackCharge.show(0, 0, 0, 0, 0, 0, 0, 0, 0)
    return 0
  }

  relicHolder.removeItem(w, n, true, null)
  return Math.round(charge / 250)
}

/** Get how much charge a weapon has. */
function GetCharge(w: Weapon) {
  container.removeItem(w, container.getItemCount(w), true, relicHolder)
  relicHolder.equipItem(w, false, true)
  return relicHolder.getActorValue("RightItemCharge")
}

/** Transform petty soul gems to final result. */
function TransformGems(count: number) {
  // Petty to lesser
  let lesser = count / 2
  let petty = count % 2

  // Lesser to common
  let common = lesser / 2
  lesser %= 2

  // Common to greater
  let greater = common / 2
  common %= 2

  //  Greater to grand
  let grand = (greater / 3) * 2
  greater %= 3

  AddGemsToExtractor(petty, lesser, common, greater, grand % 1)
}

/** Add the calculated gem count to the soul extractor.\
 * This is the final step of gem transformation.
 */
function AddGemsToExtractor(
  p: number,
  l: number,
  c: number,
  gt: number,
  gn: number
) {
  container.addItem(sgPetty, p, true)
  container.addItem(sgLesser, l, true)
  container.addItem(sgCommon, c, true)
  container.addItem(sgGreater, gt, true)
  container.addItem(sgGrand, gn, true)
}
