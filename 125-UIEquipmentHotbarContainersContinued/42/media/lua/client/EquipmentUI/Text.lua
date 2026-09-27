-- getText() reliably returns the raw key instead of the translated string for this
-- mod's custom keys on this build (same issue QuickBuildMenu works around with its
-- own key==result fallback check). Rather than depend on the engine's translation
-- loading, T(key) does its own language pick from a table baked into the mod.
--
-- All fallback strings are plain ASCII, no accented characters. Three different
-- byte-level approaches (UTF-8 file, Windows-1252 file, explicit \DDD escapes) all
-- rendered as "?" in this UI context - QuickBuildMenu's own source (same author)
-- sidesteps this entirely by never using accented characters in its Lua fallback
-- strings, so we do the same. Covers every Latin-alphabet language this mod ships
-- translate files for (FR, CS, DE, ES, PL, PTBR, TR). CH/CN/RU/TH/UA use non-Latin
-- scripts with no readable ASCII equivalent and fall through to English instead.

local FALLBACK_EN = {
    UI_optionscreen_binding_EquipmentUI = "UI Equipment, Hotbar & Containers Continued",
    UI_equipment_options_scale = "Equipment UI Scale",
    UI_equipment_options_hide_equipped_items = "Hide Equipped Items",
    UI_equipment_options_hotbar_reorder = "Enable Hotbar Reorder",
    UI_equipment_options_container_reorder = "Enable Container Reorder",
    UI_equipment_options_modules_title = "Modules",
    UI_equipment_options_modules_desc = "Changes here take effect at the main menu.",
    UI_equipment_options_settings_title = "Settings",
    UI_equipment_options_toggle_ui_controller_bind = "Open Equipment Window Gamepad",

    UI_equipment_equipment = "Equipment",
    UI_equipment_hotbar = "Hotbar",

    UI_equipment_head = "Head",
    UI_equipment_face = "Face",
    UI_equipment_torso = "Torso",
    UI_equipment_vest = "Vest",
    UI_equipment_back = "Back",
    UI_equipment_waist = "Waist",
    UI_equipment_left_hand = "Left Hand",
    UI_equipment_right_hand = "Right Hand",
    UI_equipment_jewelry = "Jewelry",
    UI_equipment_legs = "Legs",
    UI_equipment_feet = "Feet",

    UI_equipment_hotbar_lock_tooltip_locked = "Locked",
    UI_equipment_hotbar_lock_tooltip_unlocked = "Unlocked",
    UI_equipment_hotbar_swap_tooltip_swap = "Swap mode",
    UI_equipment_hotbar_swap_tooltip_insert = "Insert mode",

    UI_equipment_toggle_hidden_items_tooltip_hide = "Equipped items are hidden from the inventory list. Click to show them.",
    UI_equipment_toggle_hidden_items_tooltip_show = "Equipped items are shown in the inventory list. Click to hide them.",

    UI_equipment_options_hide_equipped_items_tooltip = "Hides equipped items from the inventory/loot list so they don't clutter it.",
    UI_equipment_options_hotbar_reorder_tooltip = "Lets you drag hotbar slots to reorder them. Takes effect immediately; the mod fully releases the game's hotbar at the next main menu.",
    UI_equipment_options_container_reorder_tooltip = "Lets you drag container/backpack tabs to reorder them, including vehicle trunks. Disable this if another mod already does it.",
    UI_equipment_search_placeholder = "Search...",
    UI_equipment_search_button = "Search",
    UI_equipment_search_button_tooltip = "Filter the list by name or category",
    UI_equipment_options_scale_tooltip = "Changes the size of the equipment window.",
    UI_equipment_options_toggle_ui_controller_bind_tooltip = "Gamepad button used to open the equipment window.",

    UI_equipment_options_reset_hotbar_order = "Reset Hotbar Order",
    UI_equipment_options_reset_hotbar_order_tooltip = "Clears your saved hotbar slot order, back to the default layout.",

    UI_reorder_containers_lock_tooltip_locked = "Locked",
    UI_reorder_containers_lock_tooltip_unlocked = "Unlocked",
    UI_reorder_containers_sort_tooltip = "Set sort priority",
    UI_reorder_containers_assign_color = "Assign a color",
    UI_reorder_containers_clear_color = "Clear color",
    UI_reorder_containers_sort_loot_checkbox = "Sort Loot Window?",
    UI_reorder_containers_container_fallback = "Container",
    UI_reorder_containers_sorting_priority = "Sorting Priority",
    UI_reorder_containers_entry_tooltip = "Type a number - lower shows first. Clear the field to sort automatically again.",
    UI_reorder_containers_priority_hint = "Lower number = shown first",
}

local FALLBACK_FR = {
    UI_optionscreen_binding_EquipmentUI = "UI Equipment, Hotbar & Containers Continued",
    UI_equipment_options_scale = "Taille d'interface d'equipement",
    UI_equipment_options_hide_equipped_items = "Masquer les objets equipes",
    UI_equipment_options_hotbar_reorder = "Activer la reorganisation de la barre de raccourcis",
    UI_equipment_options_container_reorder = "Activer la reorganisation des conteneurs",
    UI_equipment_options_modules_title = "Modules",
    UI_equipment_options_modules_desc = "Les changements ici prennent effet au menu principal.",
    UI_equipment_options_settings_title = "Reglages",
    UI_equipment_options_toggle_ui_controller_bind = "Ouvrir la fenetre d'equipement (Manette)",

    UI_equipment_equipment = "Equipement",
    UI_equipment_hotbar = "Barre de raccourci",

    UI_equipment_head = "Tete",
    UI_equipment_face = "Visage",
    UI_equipment_torso = "Torse",
    UI_equipment_vest = "Veste",
    UI_equipment_back = "Dos",
    UI_equipment_waist = "Taille",
    UI_equipment_left_hand = "Main gauche",
    UI_equipment_right_hand = "Main droite",
    UI_equipment_jewelry = "Bijoux",
    UI_equipment_legs = "Jambes",
    UI_equipment_feet = "Pieds",

    UI_equipment_hotbar_lock_tooltip_locked = "Verrouille",
    UI_equipment_hotbar_lock_tooltip_unlocked = "Deverrouille",
    UI_equipment_hotbar_swap_tooltip_swap = "Mode echange",
    UI_equipment_hotbar_swap_tooltip_insert = "Mode insertion",

    UI_equipment_toggle_hidden_items_tooltip_hide = "Les objets equipes sont masques dans l'inventaire. Cliquer pour les afficher.",
    UI_equipment_toggle_hidden_items_tooltip_show = "Les objets equipes sont affiches dans l'inventaire. Cliquer pour les masquer.",

    UI_equipment_options_hide_equipped_items_tooltip = "Masque les objets equipes de la liste d'inventaire pour ne pas l'encombrer.",
    UI_equipment_options_hotbar_reorder_tooltip = "Permet de glisser les cases de la hotbar pour les reorganiser. Prend effet immediatement ; le mod libere completement la hotbar du jeu au prochain passage par le menu principal.",
    UI_equipment_options_container_reorder_tooltip = "Permet de glisser les onglets de sacs/conteneurs pour les reorganiser, coffres de vehicule inclus. Desactiver si un autre mod le fait deja.",
    UI_equipment_search_placeholder = "Rechercher...",
    UI_equipment_search_button = "Recherche",
    UI_equipment_search_button_tooltip = "Filtrer la liste par nom ou categorie",
    UI_equipment_options_scale_tooltip = "Change la taille de la fenetre d'equipement.",
    UI_equipment_options_toggle_ui_controller_bind_tooltip = "Bouton manette pour ouvrir la fenetre d'equipement.",

    UI_equipment_options_reset_hotbar_order = "Reinitialiser l'ordre de la hotbar",
    UI_equipment_options_reset_hotbar_order_tooltip = "Efface l'ordre sauvegarde de la hotbar, retour a la disposition par defaut.",

    UI_reorder_containers_lock_tooltip_locked = "Verrouille",
    UI_reorder_containers_lock_tooltip_unlocked = "Deverrouille",
    UI_reorder_containers_sort_tooltip = "Definir la priorite de tri",
    UI_reorder_containers_assign_color = "Assigner une couleur",
    UI_reorder_containers_clear_color = "Retirer la couleur",
    UI_reorder_containers_sort_loot_checkbox = "Trier la fenetre de loot ?",
    UI_reorder_containers_container_fallback = "Conteneur",
    UI_reorder_containers_sorting_priority = "Priorite de tri",
    UI_reorder_containers_entry_tooltip = "Entrer un nombre - plus petit = en premier. Vider le champ pour revenir au tri automatique.",
    UI_reorder_containers_priority_hint = "Plus petit = affiche en premier",
}

local FALLBACK_CS = {
    UI_optionscreen_binding_EquipmentUI = "UI Equipment, Hotbar & Containers Continued",
    UI_equipment_options_scale = "Velikost rozhrani vybaveni",
    UI_equipment_options_hide_equipped_items = "Schovat vybavene predmety",
    UI_equipment_options_hotbar_reorder = "Povolit prerazeni hotbaru",
    UI_equipment_options_container_reorder = "Povolit prerazeni kontejneru",
    UI_equipment_options_modules_title = "Moduly",
    UI_equipment_options_modules_desc = "Zmeny se projevi v hlavnim menu.",
    UI_equipment_options_settings_title = "Nastaveni",
    UI_equipment_options_toggle_ui_controller_bind = "Otevrit okno vybaveni (Gamepad)",

    UI_equipment_equipment = "Vybaveni",
    UI_equipment_hotbar = "Hotbar",

    UI_equipment_head = "Hlava",
    UI_equipment_face = "Oblicej",
    UI_equipment_torso = "Trup",
    UI_equipment_vest = "Vesta",
    UI_equipment_back = "Zada",
    UI_equipment_waist = "Pas",
    UI_equipment_left_hand = "Leva ruka",
    UI_equipment_right_hand = "Prava ruka",
    UI_equipment_jewelry = "Sperky",
    UI_equipment_legs = "Nohy",
    UI_equipment_feet = "Chodidla",

    UI_equipment_hotbar_lock_tooltip_locked = "Zamceno",
    UI_equipment_hotbar_lock_tooltip_unlocked = "Odemceno",
    UI_equipment_hotbar_swap_tooltip_swap = "Rezim vymeny",
    UI_equipment_hotbar_swap_tooltip_insert = "Rezim vlozeni",

    UI_equipment_toggle_hidden_items_tooltip_hide = "Vybavene predmety jsou skryte v inventari. Klikni pro zobrazeni.",
    UI_equipment_toggle_hidden_items_tooltip_show = "Vybavene predmety jsou zobrazene v inventari. Klikni pro skryti.",

    UI_equipment_options_hide_equipped_items_tooltip = "Skryje vybavene predmety ze seznamu inventare, aby ho nezaplnovaly.",
    UI_equipment_options_hotbar_reorder_tooltip = "Umozni presouvat sloty hotbaru tahem mysi. Projevi se okamzite; mod hotbar hry zcela uvolni pri pristim navratu do hlavniho menu.",
    UI_equipment_options_container_reorder_tooltip = "Umozni tahem mysi prerazovat zalozky kontejneru/batohu, vcetne kufru vozidel. Vypni, pokud uz to dela jiny mod.",
    UI_equipment_search_placeholder = "Hledat...",
    UI_equipment_search_button = "Hledat",
    UI_equipment_search_button_tooltip = "Filtrovat seznam podle nazvu nebo kategorie",
    UI_equipment_options_scale_tooltip = "Zmeni velikost okna vybaveni.",
    UI_equipment_options_toggle_ui_controller_bind_tooltip = "Tlacitko gamepadu pro otevreni okna vybaveni.",

    UI_equipment_options_reset_hotbar_order = "Resetovat poradi hotbaru",
    UI_equipment_options_reset_hotbar_order_tooltip = "Vymaze ulozene poradi slotu hotbaru, navrat k vychozimu rozlozeni.",

    UI_reorder_containers_lock_tooltip_locked = "Zamceno",
    UI_reorder_containers_lock_tooltip_unlocked = "Odemceno",
    UI_reorder_containers_sort_tooltip = "Nastavit prioritu razeni",
    UI_reorder_containers_assign_color = "Priradit barvu",
    UI_reorder_containers_clear_color = "Odebrat barvu",
    UI_reorder_containers_sort_loot_checkbox = "Radit okno loot?",
    UI_reorder_containers_container_fallback = "Kontejner",
    UI_reorder_containers_sorting_priority = "Priorita razeni",
    UI_reorder_containers_entry_tooltip = "Zadejte cislo - mensi = drive. Smazte pole pro navrat k automatickemu razeni.",
    UI_reorder_containers_priority_hint = "Mensi cislo = zobrazeno prvni",
}

local FALLBACK_DE = {
    UI_optionscreen_binding_EquipmentUI = "UI Equipment, Hotbar & Containers Continued",
    UI_equipment_options_scale = "Ausruestungs-UI Groesse",
    UI_equipment_options_hide_equipped_items = "Ausgeruestete Gegenstaende ausblenden",
    UI_equipment_options_hotbar_reorder = "Hotbar-Neuanordnung aktivieren",
    UI_equipment_options_container_reorder = "Behaelter-Neuanordnung aktivieren",
    UI_equipment_options_modules_title = "Module",
    UI_equipment_options_modules_desc = "Aenderungen werden im Hauptmenue wirksam.",
    UI_equipment_options_settings_title = "Einstellungen",
    UI_equipment_options_toggle_ui_controller_bind = "Ausruestungsfenster oeffnen (Gamepad)",

    UI_equipment_equipment = "Ausruestung",
    UI_equipment_hotbar = "Hotbar",

    UI_equipment_head = "Kopf",
    UI_equipment_face = "Gesicht",
    UI_equipment_torso = "Torso",
    UI_equipment_vest = "Weste",
    UI_equipment_back = "Ruecken",
    UI_equipment_waist = "Taille",
    UI_equipment_left_hand = "Linke Hand",
    UI_equipment_right_hand = "Rechte Hand",
    UI_equipment_jewelry = "Schmuck",
    UI_equipment_legs = "Beine",
    UI_equipment_feet = "Fuesse",

    UI_equipment_hotbar_lock_tooltip_locked = "Gesperrt",
    UI_equipment_hotbar_lock_tooltip_unlocked = "Entsperrt",
    UI_equipment_hotbar_swap_tooltip_swap = "Tauschmodus",
    UI_equipment_hotbar_swap_tooltip_insert = "Einfuegemodus",

    UI_equipment_toggle_hidden_items_tooltip_hide = "Ausgeruestete Gegenstaende sind im Inventar ausgeblendet. Klicken zum Anzeigen.",
    UI_equipment_toggle_hidden_items_tooltip_show = "Ausgeruestete Gegenstaende werden im Inventar angezeigt. Klicken zum Ausblenden.",

    UI_equipment_options_hide_equipped_items_tooltip = "Blendet ausgeruestete Gegenstaende aus der Inventarliste aus.",
    UI_equipment_options_hotbar_reorder_tooltip = "Erlaubt das Verschieben von Hotbar-Slots per Drag & Drop. Wirkt sofort; der Mod gibt die Hotbar des Spiels beim naechsten Hauptmenue vollstaendig frei.",
    UI_equipment_options_container_reorder_tooltip = "Erlaubt das Verschieben von Behaelter-/Rucksack-Reitern per Drag & Drop, inklusive Fahrzeugkofferraeume. Deaktivieren, wenn ein anderes Mod das schon macht.",
    UI_equipment_search_placeholder = "Suchen...",
    UI_equipment_search_button = "Suchen",
    UI_equipment_search_button_tooltip = "Liste nach Name oder Kategorie filtern",
    UI_equipment_options_scale_tooltip = "Aendert die Groesse des Ausruestungsfensters.",
    UI_equipment_options_toggle_ui_controller_bind_tooltip = "Gamepad-Taste zum Oeffnen des Ausruestungsfensters.",

    UI_equipment_options_reset_hotbar_order = "Hotbar-Reihenfolge zuruecksetzen",
    UI_equipment_options_reset_hotbar_order_tooltip = "Loescht die gespeicherte Hotbar-Reihenfolge, zurueck zum Standardlayout.",

    UI_reorder_containers_lock_tooltip_locked = "Gesperrt",
    UI_reorder_containers_lock_tooltip_unlocked = "Entsperrt",
    UI_reorder_containers_sort_tooltip = "Sortierprioritaet festlegen",
    UI_reorder_containers_assign_color = "Farbe zuweisen",
    UI_reorder_containers_clear_color = "Farbe entfernen",
    UI_reorder_containers_sort_loot_checkbox = "Beute-Fenster sortieren?",
    UI_reorder_containers_container_fallback = "Behaelter",
    UI_reorder_containers_sorting_priority = "Sortierprioritaet",
    UI_reorder_containers_entry_tooltip = "Zahl eingeben - kleiner = zuerst. Feld leeren fuer automatische Sortierung.",
    UI_reorder_containers_priority_hint = "Kleinere Zahl = zuerst angezeigt",
}

local FALLBACK_ES = {
    UI_optionscreen_binding_EquipmentUI = "UI Equipment, Hotbar & Containers Continued",
    UI_equipment_options_scale = "Escala de la interfaz de equipo",
    UI_equipment_options_hide_equipped_items = "Ocultar objetos equipados",
    UI_equipment_options_hotbar_reorder = "Activar reordenar barra de acceso",
    UI_equipment_options_container_reorder = "Activar reordenar contenedores",
    UI_equipment_options_modules_title = "Modulos",
    UI_equipment_options_modules_desc = "Los cambios aqui surten efecto en el menu principal.",
    UI_equipment_options_settings_title = "Ajustes",
    UI_equipment_options_toggle_ui_controller_bind = "Abrir ventana de equipo (Mando)",

    UI_equipment_equipment = "Equipo",
    UI_equipment_hotbar = "Barra de acceso",

    UI_equipment_head = "Cabeza",
    UI_equipment_face = "Cara",
    UI_equipment_torso = "Torso",
    UI_equipment_vest = "Chaleco",
    UI_equipment_back = "Espalda",
    UI_equipment_waist = "Cintura",
    UI_equipment_left_hand = "Mano izquierda",
    UI_equipment_right_hand = "Mano derecha",
    UI_equipment_jewelry = "Joyeria",
    UI_equipment_legs = "Piernas",
    UI_equipment_feet = "Pies",

    UI_equipment_hotbar_lock_tooltip_locked = "Bloqueado",
    UI_equipment_hotbar_lock_tooltip_unlocked = "Desbloqueado",
    UI_equipment_hotbar_swap_tooltip_swap = "Modo intercambio",
    UI_equipment_hotbar_swap_tooltip_insert = "Modo insercion",

    UI_equipment_toggle_hidden_items_tooltip_hide = "Los objetos equipados estan ocultos en el inventario. Clic para mostrarlos.",
    UI_equipment_toggle_hidden_items_tooltip_show = "Los objetos equipados se muestran en el inventario. Clic para ocultarlos.",

    UI_equipment_options_hide_equipped_items_tooltip = "Oculta los objetos equipados de la lista de inventario.",
    UI_equipment_options_hotbar_reorder_tooltip = "Permite arrastrar las casillas de la barra para reordenarlas. Efecto inmediato; el mod libera por completo la barra del juego al volver al menu principal.",
    UI_equipment_options_container_reorder_tooltip = "Permite arrastrar las pestanas de contenedores/mochilas para reordenarlas, incluidos maleteros de vehiculos. Desactivalo si otro mod ya lo hace.",
    UI_equipment_search_placeholder = "Buscar...",
    UI_equipment_search_button = "Buscar",
    UI_equipment_search_button_tooltip = "Filtrar la lista por nombre o categoria",
    UI_equipment_options_scale_tooltip = "Cambia el tamano de la ventana de equipo.",
    UI_equipment_options_toggle_ui_controller_bind_tooltip = "Boton del mando para abrir la ventana de equipo.",

    UI_equipment_options_reset_hotbar_order = "Restablecer orden de la barra",
    UI_equipment_options_reset_hotbar_order_tooltip = "Borra el orden guardado de la barra de acceso, vuelve al diseno predeterminado.",

    UI_reorder_containers_lock_tooltip_locked = "Bloqueado",
    UI_reorder_containers_lock_tooltip_unlocked = "Desbloqueado",
    UI_reorder_containers_sort_tooltip = "Establecer prioridad de orden",
    UI_reorder_containers_assign_color = "Asignar un color",
    UI_reorder_containers_clear_color = "Quitar color",
    UI_reorder_containers_sort_loot_checkbox = "Ordenar ventana de botin?",
    UI_reorder_containers_container_fallback = "Contenedor",
    UI_reorder_containers_sorting_priority = "Prioridad de orden",
    UI_reorder_containers_entry_tooltip = "Escribe un numero - mas bajo = primero. Borra el campo para volver al orden automatico.",
    UI_reorder_containers_priority_hint = "Numero mas bajo = se muestra primero",
}

local FALLBACK_PL = {
    UI_optionscreen_binding_EquipmentUI = "UI Equipment, Hotbar & Containers Continued",
    UI_equipment_options_scale = "Skala interfejsu ekwipunku",
    UI_equipment_options_hide_equipped_items = "Ukryj zalozone przedmioty",
    UI_equipment_options_hotbar_reorder = "Wlacz zmiane kolejnosci paska skrotow",
    UI_equipment_options_container_reorder = "Wlacz zmiane kolejnosci pojemnikow",
    UI_equipment_options_modules_title = "Moduly",
    UI_equipment_options_modules_desc = "Zmiany zaczynaja dzialac w menu glownym.",
    UI_equipment_options_settings_title = "Ustawienia",
    UI_equipment_options_toggle_ui_controller_bind = "Otworz okno ekwipunku (Pad)",

    UI_equipment_equipment = "Ekwipunek",
    UI_equipment_hotbar = "Pasek skrotow",

    UI_equipment_head = "Glowa",
    UI_equipment_face = "Twarz",
    UI_equipment_torso = "Tors",
    UI_equipment_vest = "Kamizelka",
    UI_equipment_back = "Plecy",
    UI_equipment_waist = "Talia",
    UI_equipment_left_hand = "Lewa reka",
    UI_equipment_right_hand = "Prawa reka",
    UI_equipment_jewelry = "Bizuteria",
    UI_equipment_legs = "Nogi",
    UI_equipment_feet = "Stopy",

    UI_equipment_hotbar_lock_tooltip_locked = "Zablokowane",
    UI_equipment_hotbar_lock_tooltip_unlocked = "Odblokowane",
    UI_equipment_hotbar_swap_tooltip_swap = "Tryb zamiany",
    UI_equipment_hotbar_swap_tooltip_insert = "Tryb wstawiania",

    UI_equipment_toggle_hidden_items_tooltip_hide = "Zalozone przedmioty sa ukryte na liscie ekwipunku. Kliknij, aby je pokazac.",
    UI_equipment_toggle_hidden_items_tooltip_show = "Zalozone przedmioty sa widoczne na liscie ekwipunku. Kliknij, aby je ukryc.",

    UI_equipment_options_hide_equipped_items_tooltip = "Ukrywa zalozone przedmioty z listy ekwipunku.",
    UI_equipment_options_hotbar_reorder_tooltip = "Pozwala przeciagac sloty paska skrotow, aby zmienic ich kolejnosc. Dziala natychmiast; mod calkowicie zwalnia pasek gry przy nastepnym wejsciu do menu glownego.",
    UI_equipment_options_container_reorder_tooltip = "Pozwala przeciagac zakladki pojemnikow/plecakow, aby zmienic ich kolejnosc, wliczajac bagazniki pojazdow. Wylacz, jesli robi to juz inny mod.",
    UI_equipment_search_placeholder = "Szukaj...",
    UI_equipment_search_button = "Szukaj",
    UI_equipment_search_button_tooltip = "Filtruj liste wedlug nazwy lub kategorii",
    UI_equipment_options_scale_tooltip = "Zmienia rozmiar okna ekwipunku.",
    UI_equipment_options_toggle_ui_controller_bind_tooltip = "Przycisk pada do otwierania okna ekwipunku.",

    UI_equipment_options_reset_hotbar_order = "Zresetuj kolejnosc paska skrotow",
    UI_equipment_options_reset_hotbar_order_tooltip = "Czysci zapisana kolejnosc slotow paska skrotow, powrot do domyslnego ukladu.",

    UI_reorder_containers_lock_tooltip_locked = "Zablokowane",
    UI_reorder_containers_lock_tooltip_unlocked = "Odblokowane",
    UI_reorder_containers_sort_tooltip = "Ustaw priorytet sortowania",
    UI_reorder_containers_assign_color = "Przypisz kolor",
    UI_reorder_containers_clear_color = "Usun kolor",
    UI_reorder_containers_sort_loot_checkbox = "Sortowac okno lupu?",
    UI_reorder_containers_container_fallback = "Pojemnik",
    UI_reorder_containers_sorting_priority = "Priorytet sortowania",
    UI_reorder_containers_entry_tooltip = "Wpisz liczbe - mniejsza = pierwsza. Wyczysc pole, aby wrocic do sortowania automatycznego.",
    UI_reorder_containers_priority_hint = "Mniejsza liczba = pierwsze",
}

local FALLBACK_PTBR = {
    UI_optionscreen_binding_EquipmentUI = "UI Equipment, Hotbar & Containers Continued",
    UI_equipment_options_scale = "Escala da interface de equipamento",
    UI_equipment_options_hide_equipped_items = "Ocultar itens equipados",
    UI_equipment_options_hotbar_reorder = "Ativar reordenar barra de atalhos",
    UI_equipment_options_container_reorder = "Ativar reordenar conteineres",
    UI_equipment_options_modules_title = "Modulos",
    UI_equipment_options_modules_desc = "As alteracoes tem efeito no menu principal.",
    UI_equipment_options_settings_title = "Configuracoes",
    UI_equipment_options_toggle_ui_controller_bind = "Abrir janela de equipamento (Controle)",

    UI_equipment_equipment = "Equipamento",
    UI_equipment_hotbar = "Barra de atalhos",

    UI_equipment_head = "Cabeca",
    UI_equipment_face = "Rosto",
    UI_equipment_torso = "Torso",
    UI_equipment_vest = "Colete",
    UI_equipment_back = "Costas",
    UI_equipment_waist = "Cintura",
    UI_equipment_left_hand = "Mao esquerda",
    UI_equipment_right_hand = "Mao direita",
    UI_equipment_jewelry = "Joias",
    UI_equipment_legs = "Pernas",
    UI_equipment_feet = "Pes",

    UI_equipment_hotbar_lock_tooltip_locked = "Travado",
    UI_equipment_hotbar_lock_tooltip_unlocked = "Destravado",
    UI_equipment_hotbar_swap_tooltip_swap = "Modo troca",
    UI_equipment_hotbar_swap_tooltip_insert = "Modo insercao",

    UI_equipment_toggle_hidden_items_tooltip_hide = "Itens equipados estao ocultos na lista de inventario. Clique para mostrar.",
    UI_equipment_toggle_hidden_items_tooltip_show = "Itens equipados estao visiveis na lista de inventario. Clique para ocultar.",

    UI_equipment_options_hide_equipped_items_tooltip = "Oculta itens equipados da lista de inventario.",
    UI_equipment_options_hotbar_reorder_tooltip = "Permite arrastar os slots da barra de atalhos para reordena-los. Efeito imediato; o mod libera totalmente a barra do jogo no proximo menu principal.",
    UI_equipment_options_container_reorder_tooltip = "Permite arrastar as abas de conteineres/mochilas para reordena-las, incluindo porta-malas de veiculos. Desative se outro mod ja fizer isso.",
    UI_equipment_search_placeholder = "Pesquisar...",
    UI_equipment_search_button = "Pesquisar",
    UI_equipment_search_button_tooltip = "Filtrar a lista por nome ou categoria",
    UI_equipment_options_scale_tooltip = "Muda o tamanho da janela de equipamento.",
    UI_equipment_options_toggle_ui_controller_bind_tooltip = "Botao do controle para abrir a janela de equipamento.",

    UI_equipment_options_reset_hotbar_order = "Redefinir ordem da barra de atalhos",
    UI_equipment_options_reset_hotbar_order_tooltip = "Limpa a ordem salva dos slots da barra de atalhos, volta ao layout padrao.",

    UI_reorder_containers_lock_tooltip_locked = "Travado",
    UI_reorder_containers_lock_tooltip_unlocked = "Destravado",
    UI_reorder_containers_sort_tooltip = "Definir prioridade de ordenacao",
    UI_reorder_containers_assign_color = "Atribuir uma cor",
    UI_reorder_containers_clear_color = "Remover cor",
    UI_reorder_containers_sort_loot_checkbox = "Ordenar janela de saque?",
    UI_reorder_containers_container_fallback = "Recipiente",
    UI_reorder_containers_sorting_priority = "Prioridade de ordenacao",
    UI_reorder_containers_entry_tooltip = "Digite um numero - menor = primeiro. Limpe o campo para voltar a ordenacao automatica.",
    UI_reorder_containers_priority_hint = "Numero menor = aparece primeiro",
}

local FALLBACK_TR = {
    UI_optionscreen_binding_EquipmentUI = "UI Equipment, Hotbar & Containers Continued",
    UI_equipment_options_scale = "Ekipman Arayuzu Olcegi",
    UI_equipment_options_hide_equipped_items = "Kusanilan Esyalari Gizle",
    UI_equipment_options_hotbar_reorder = "Hotbar Yeniden Siralamayi Etkinlestir",
    UI_equipment_options_container_reorder = "Kap Yeniden Siralamayi Etkinlestir",
    UI_equipment_options_modules_title = "Moduller",
    UI_equipment_options_modules_desc = "Degisiklikler ana menude etkili olur.",
    UI_equipment_options_settings_title = "Ayarlar",
    UI_equipment_options_toggle_ui_controller_bind = "Ekipman Penceresini Ac (Kumanda)",

    UI_equipment_equipment = "Ekipman",
    UI_equipment_hotbar = "Hotbar",

    UI_equipment_head = "Kafa",
    UI_equipment_face = "Yuz",
    UI_equipment_torso = "Govde",
    UI_equipment_vest = "Yelek",
    UI_equipment_back = "Sirt",
    UI_equipment_waist = "Bel",
    UI_equipment_left_hand = "Sol El",
    UI_equipment_right_hand = "Sag El",
    UI_equipment_jewelry = "Mucevher",
    UI_equipment_legs = "Bacaklar",
    UI_equipment_feet = "Ayaklar",

    UI_equipment_hotbar_lock_tooltip_locked = "Kilitli",
    UI_equipment_hotbar_lock_tooltip_unlocked = "Kilit Acik",
    UI_equipment_hotbar_swap_tooltip_swap = "Takas Modu",
    UI_equipment_hotbar_swap_tooltip_insert = "Ekleme Modu",

    UI_equipment_toggle_hidden_items_tooltip_hide = "Kusanilan esyalar envanter listesinde gizli. Gostermek icin tikla.",
    UI_equipment_toggle_hidden_items_tooltip_show = "Kusanilan esyalar envanter listesinde gorunuyor. Gizlemek icin tikla.",

    UI_equipment_options_hide_equipped_items_tooltip = "Kusanilan esyalari envanter listesinden gizler.",
    UI_equipment_options_hotbar_reorder_tooltip = "Hotbar slotlarini surukleyerek yeniden siralamani saglar. Hemen etkili olur; mod bir sonraki ana menude oyunun hotbar'ini tamamen birakir.",
    UI_equipment_options_container_reorder_tooltip = "Konteyner/canta sekmelerini surukleyerek yeniden siralamani saglar, arac bagajlari dahil. Baska bir mod bunu zaten yapiyorsa kapat.",
    UI_equipment_search_placeholder = "Ara...",
    UI_equipment_search_button = "Ara",
    UI_equipment_search_button_tooltip = "Listeyi ada veya kategoriye gore filtrele",
    UI_equipment_options_scale_tooltip = "Ekipman penceresinin boyutunu degistirir.",
    UI_equipment_options_toggle_ui_controller_bind_tooltip = "Ekipman penceresini acmak icin kumanda dugmesi.",

    UI_equipment_options_reset_hotbar_order = "Hotbar Sirasini Sifirla",
    UI_equipment_options_reset_hotbar_order_tooltip = "Kayitli hotbar slot sirasini temizler, varsayilan duzene doner.",

    UI_reorder_containers_lock_tooltip_locked = "Kilitli",
    UI_reorder_containers_lock_tooltip_unlocked = "Kilit Acik",
    UI_reorder_containers_sort_tooltip = "Siralama onceligini ayarla",
    UI_reorder_containers_assign_color = "Renk ata",
    UI_reorder_containers_clear_color = "Rengi kaldir",
    UI_reorder_containers_sort_loot_checkbox = "Yagma penceresi siralansin mi?",
    UI_reorder_containers_container_fallback = "Kap",
    UI_reorder_containers_sorting_priority = "Siralama Onceligi",
    UI_reorder_containers_entry_tooltip = "Bir sayi gir - kucuk = once. Otomatik siralamaya donmek icin alani temizle.",
    UI_reorder_containers_priority_hint = "Kucuk sayi = once gosterilir",
}

-- CH/CN/RU/TH/UA use non-Latin scripts (Chinese, Cyrillic, Thai) - there's no ASCII
-- transliteration that stays readable, and we haven't confirmed those scripts render
-- correctly through this same drawText path that broke on Latin accented characters.
-- They fall through to English rather than risk unreadable native-script text or
-- another round of "?" placeholders.
local LANGUAGE_TABLES = {
    FR = FALLBACK_FR,
    CS = FALLBACK_CS,
    DE = FALLBACK_DE,
    ES = FALLBACK_ES,
    PL = FALLBACK_PL,
    PTBR = FALLBACK_PTBR,
    TR = FALLBACK_TR,
}

local function currentFallbackTable()
    local ok, name = pcall(function() return Translator.getLanguage():name() end)
    if ok and LANGUAGE_TABLES[name] then
        return LANGUAGE_TABLES[name]
    end
    return FALLBACK_EN
end

local function T(key)
    local text = getText(key)
    if text == nil or text == key then
        local fallback = currentFallbackTable()
        return fallback[key] or FALLBACK_EN[key] or key
    end
    return text
end

return T
