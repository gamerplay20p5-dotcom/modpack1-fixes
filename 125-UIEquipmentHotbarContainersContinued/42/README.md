# UI Equipment, Hotbar & Containers Continued

Mod pour **Project Zomboid Build 42** qui ajoute une interface d'équipement façon Tarkov/STALKER, plus le glisser-déposer pour réorganiser la hotbar et les sacs/conteneurs.

## À quoi ça sert ?

Dans Project Zomboid, voir et gérer ce que ton perso porte demande de fouiller la liste d'inventaire équipement par équipement. Avec **UI Equipment, Hotbar & Containers Continued**, tu as un panneau dédié avec une silhouette du corps : chaque emplacement (tête, torse, jambes, mains, bijoux...) est visible d'un coup d'œil, et tu glisses/déposes les objets directement dessus.

En plus, la hotbar (les raccourcis numérotés en bas de l'écran) devient réorganisable par glisser-déposer, avec deux modes au choix.

## Comment ça marche ?

### Fenêtre d'équipement

Ouvre le panneau d'équipement (raccourci configurable), et glisse tes objets entre l'inventaire, la hotbar et les emplacements du corps. Un bouton permet de masquer les objets déjà équipés dans la liste d'inventaire, pour ne pas l'encombrer.

### Réorganisation de la hotbar

À côté de la hotbar, deux petites icônes :

- **Cadenas** : verrouille/déverrouille le glisser-déposer sur la hotbar
- **Flèches** : bascule entre deux modes de réorganisation
  - **Mode échange** : glisser une case sur une autre les fait juste échanger leur contenu
  - **Mode insertion** : la case glissée prend la nouvelle position, et tout ce qui était entre les deux se décale d'un cran (comme déplacer une carte dans un jeu de cartes)

Un bouton **« Reinitialiser l'ordre de la hotbar »** dans les options du mod remet la hotbar à sa disposition par défaut.

### Réorganisation des sacs et conteneurs

Dans la fenêtre d'inventaire ou de loot, glisse un onglet de conteneur (sac à dos, coffre de véhicule, boîte à gants...) vers le haut ou le bas pour changer son ordre d'affichage. Deux petits boutons apparaissent en bas à droite du panneau :

- **Cadenas** : verrouille/déverrouille le glisser-déposer (verrous séparés inventaire/loot)
- **Icône de tri** : règle une priorité exacte à la main, et active le tri dans la fenêtre de loot (désactivé par défaut)

Marche automatiquement sur les coffres et boîtes à gants de véhicule, vu qu'ils utilisent le même système d'onglets que les sacs à dos.

### Barre de recherche

Un bouton "Recherche" apparaît dans la barre de titre de chaque fenêtre d'inventaire (principal, loot, coffres/boîtes à gants, sacs ouverts). Clique dessus : il devient un champ de texte, et la liste se filtre en direct à chaque frappe. Entrée arrête la saisie sans fermer le champ — la recherche reste active tant que la fenêtre est ouverte, reclique pour continuer à taper.

La recherche matche par mot (pas juste par sous-chaîne) : "hu ja" trouve "Hunting Jacket" sans remonter tout ce qui contient juste "ja". Elle matche aussi la catégorie de l'objet, pas seulement son nom — taper "outil" fait remonter tout ce qui est catégorisé Outil/Arme.

## Origine du mod

C'est une reprise communautaire non-officielle de trois mods abandonnés par leur auteur original **Notloc**, tous publiés sous licence MIT :

- [Equipment UI](https://steamcommunity.com/sharedfiles/filedetails/?id=2950902979)
- [Reorder The Hotbar](https://steamcommunity.com/sharedfiles/filedetails/?id=2903771337)
- [Reorder Containers - Backpack Orders](https://steamcommunity.com/sharedfiles/filedetails/?id=2901962885)

Porté pour Build 42.20+, fusionné en un seul mod, traduction ajoutée. Voir `LICENSE` (code hérité de Notloc, MIT) et `LICENSE.md` (ajouts propres de Ghoosty) pour le détail exact de qui possède quoi.

## Installation

### Workshop Steam (recommandé)

Abonne-toi au mod sur le Workshop, active-le dans le menu Mods du jeu.

### Manuelle

1. Télécharger l'archive .zip
2. Extraire le dossier `UIEquipmentHotbarContainersContinued` dans `C:\Users\<TonNom>\Zomboid\mods\`
3. Activer le mod dans le menu Mods du jeu
4. Lancer une partie

## Options du mod

### Modules

Ces deux fonctionnalités peuvent être coupées complètement. Décochées, le mod ne touche plus du tout aux parties du jeu concernées — la place est libre pour un autre mod qui ferait la même chose.

| Module | Effet |
|---|---|
| Activer la réorganisation de la hotbar | Marche/arrêt. Décoché, le mod ne touche plus à la hotbar du jeu |
| Activer la réorganisation des conteneurs | Marche/arrêt. Décoché, le mod ne touche plus au panneau d'inventaire |

Couper un module l'arrête immédiatement, même en pleine partie. Le détachement complet se fait au prochain passage par le menu principal : le jeu recharge tout seul en quelques secondes, pas besoin de le fermer.

Recocher un module en cours de partie ne peut pas prendre effet sur-le-champ. Le jeu affiche alors son message habituel pour dire qu'il faut repasser par le menu principal.

### Réglages

| Option | Effet |
|---|---|
| Échelle de l'interface d'équipement | 0.5x à 4x |
| Masquer les objets équipés | Retire les objets déjà équipés de la liste d'inventaire |
| Reinitialiser l'ordre de la hotbar | Remet la hotbar à sa disposition par défaut |
| Bouton manette pour ouvrir la fenêtre d'équipement | Choix du bouton gamepad |

## Compatibilité

| Mode | Statut |
|---|---|
| Solo | Oui |
| Multijoueur | Oui |

**Version PZ requise : 42.0 à 42.20.x**

## Langues disponibles

Traduites (texte natif) : Anglais, Français, Tchèque, Allemand, Espagnol, Polonais, Portugais (Brésil), Turc

Repli automatique sur l'anglais (script non-latin, pas encore géré) : Chinois, Russe, Thaï, Ukrainien

## Crédits

- Code original par **Notloc** (Equipment UI, Reorder The Hotbar, Reorder Containers - Backpack Orders), licence MIT
- Reprise, fusion et maintenance par **Ghoosty**

## Licence

Mixte — voir `LICENSE` (MIT, code hérité de Notloc) et `LICENSE.md` (Tous droits réservés, ajouts propres de Ghoosty : `Text.lua`, textes descriptifs, visuels originaux).

---------------------------

# UI Equipment, Hotbar & Containers Continued

A mod for **Project Zomboid Build 42** that adds a Tarkov/STALKER style equipment interface, plus drag-to-reorder hotbar slots and container/backpack reordering.

## What does it do?

In Project Zomboid, seeing and managing what your character has equipped means digging through the inventory list item by item. With **UI Equipment, Hotbar & Containers Continued**, you get a dedicated panel with a body silhouette: every slot (head, torso, legs, hands, jewelry...) is visible at a glance, and you drag and drop items straight onto it.

On top of that, the hotbar (the numbered shortcuts at the bottom of the screen) becomes drag-to-reorder, with two modes to choose from.

## How does it work?

### Equipment window

Open the equipment panel (configurable keybind), and drag items between your inventory, hotbar, and body slots. A button lets you hide already-equipped items from the inventory list to reduce clutter.

### Hotbar reordering

Next to the hotbar, two small icons:

- **Lock**: locks/unlocks drag-and-drop on the hotbar
- **Arrows**: switches between two reorder modes
  - **Swap mode**: dragging one slot onto another just trades their contents
  - **Insert mode**: the dragged slot takes the new position, and everything between the two positions shifts over by one (like moving a card within a hand of cards)

A **"Reset Hotbar Order"** button in the mod's options restores the default hotbar layout.

### Container and backpack reordering

In the inventory or loot window, drag a container tab (backpack, vehicle trunk, glove box...) up or down to change its display order. Two small buttons appear at the bottom-right of the panel:

- **Lock**: locks/unlocks drag-to-reorder (separate locks for inventory vs loot)
- **Sort icon**: manually set an exact priority, and enable sorting in the loot window (off by default)

Works automatically on vehicle trunks and glove boxes too, since they use the same tab system as backpacks.

### Search bar

A "Search" button shows up in the title bar of every inventory window (main inventory, loot, vehicle trunks/glove boxes, opened bags). Click it and it turns into a text field, filtering the list live as you type. Enter stops typing without closing the field - the search stays active as long as the window is open, click back in to keep typing.

Search matches by word, not just substring: "hu ja" finds "Hunting Jacket" without pulling in everything that just contains "ja". It also matches item category, not just name - typing "tool" surfaces everything categorized as a Tool/Weapon.

## Where this mod comes from

This is an unofficial community continuation of three mods abandoned by their original author **Notloc**, all released under the MIT License:

- [Equipment UI](https://steamcommunity.com/sharedfiles/filedetails/?id=2950902979)
- [Reorder The Hotbar](https://steamcommunity.com/sharedfiles/filedetails/?id=2903771337)
- [Reorder Containers - Backpack Orders](https://steamcommunity.com/sharedfiles/filedetails/?id=2901962885)

Ported for Build 42.20+, merged into one mod, translations added. See `LICENSE` (Notloc's inherited code, MIT) and `LICENSE.md` (Ghoosty's own additions) for exactly who owns what.

## Installation

### Steam Workshop (recommended)

Subscribe to the mod on the Workshop, enable it in the in-game Mods menu.

### Manual

1. Download the .zip archive
2. Extract the `UIEquipmentHotbarContainersContinued` folder to `C:\Users\<YourName>\Zomboid\mods\`
3. Enable the mod in the in-game Mods menu
4. Start a game

## Mod options

### Modules

These two features can be switched off completely. Once unticked, the mod stops touching those parts of the game altogether - the space is free for another mod doing the same job.

| Module | Effect |
|---|---|
| Enable Hotbar Reorder | On/off. Off means the mod no longer touches the game's hotbar |
| Enable Container Reorder | On/off. Off means the mod no longer touches the inventory panel |

Switching a module off stops it immediately, even mid-game. The full detach happens the next time you pass through the main menu: the game reloads on its own in a few seconds, no need to close it.

Switching a module back on during a game can't take effect right away. The game shows its usual message telling you to pass through the main menu.

### Settings

| Option | Effect |
|---|---|
| Equipment UI Scale | 0.5x to 4x |
| Hide Equipped Items | Removes already-equipped items from the inventory list |
| Reset Hotbar Order | Restores the default hotbar layout |
| Gamepad button for the equipment window | Pick which gamepad button opens it |

## Compatibility

| Mode | Status |
|---|---|
| Single player | Yes |
| Multiplayer | Yes |

**Required PZ version: 42.0 to 42.20.x**

## Available languages

Translated (native text): English, French, Czech, German, Spanish, Polish, Portuguese (Brazil), Turkish

Automatic English fallback (non-Latin script, not yet supported): Chinese, Russian, Thai, Ukrainian

## Credits

- Original code by **Notloc** (Equipment UI, Reorder The Hotbar, Reorder Containers - Backpack Orders), MIT licensed
- Continuation, merge and maintenance by **Ghoosty**

## License

Mixed - see `LICENSE` (MIT, Notloc's inherited code) and `LICENSE.md` (All Rights Reserved, Ghoosty's own additions: `Text.lua`, descriptive text, original artwork).
