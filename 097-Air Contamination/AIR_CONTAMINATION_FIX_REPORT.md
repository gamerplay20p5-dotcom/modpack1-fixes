# Causa do problema original

A primeira correção não chegou a executar: `AirContamination_Main.lua` foi salvo com BOM UTF-8. O console de 26/09 registra `SEVERE: Error found in LUA file` seguido por `ArrayIndexOutOfBoundsException` dentro do lexer Kahlua. O jogo abortou a compilação e não registrou o callback de exposição. Além disso, o sandbox estava com `DisableSicknessMoodle=true`, o que bloqueava o estágio de enjoo. A rotina original também era executada apenas uma vez por minuto.

O gás neste mod é global: `isContaminationActive()` o ativa após o atraso de SandboxVars. Não existe detecção de nuvem contaminada por quadrante/área.

# Sistema de exposição

`AirContaminationExposureTime` fica em `player:getModData()`, individual por personagem e persistente. `OnPlayerUpdate` dá tosse/embriaguez na primeira atualização exposta; depois de 600 atualizações (aprox. 10 s a 60 FPS) acrescenta 10 s. Abrigo e proteção reduzem o contador em 10 s por amostra. Sintomas aplicados permanecem.

# Detecção de construções

A verificação usa o quadrado atual e reconhece `isInARoom()`, ou `isOutside() == false` junto de `getBuilding()`. A opção `IndoorSafeZone` continua habilitando/desabilitando segurança interna. Não há progressão nova dentro de uma construção considerada segura.

# Sistema de máscaras

A busca de equipamento vestido continua usando `Data.MaskProtection` e `ItemBodyLocation`, com fallback por `getWornItems()`. Tipos reconhecidos pelo mod continuam sujeitos às proteções e taxas configuradas na tabela. Equipamentos sem filtro preservam sua proteção parcial original; filtros com carga continuam recebendo desgaste.

# Sistema de filtros

O código avalia `getCurrentUsesFloat`, `getUsedDelta`, `getCurrentUses` e, para itens conhecidos, durabilidade como fallback. Equipamento com filtro/carga zerada usa a proteção mínima original; máscara sem filtro conserva a proteção parcial cadastrada. Equipamento sem leitura de durabilidade continua confiando no tipo filtrado reconhecido, como já fazia o mod.

# Embriaguez

Build local confirma `stats:set(CharacterStat.INTOXICATION, valor)`. A exposição eleva o nível a 95/100 em uma atualização controlada por amostra; ao entrar em proteção, o mod deixa de elevar esse stat e o jogo pode reduzi-lo naturalmente.

# Enjoo após 1 minuto

Aos 60 segundos acumulados, o código aumenta `CharacterStat.FOOD_SICKNESS` para 28, valor acima do limiar de Queasy observado no jogo instalado. O avanço tóxico ignora `DisableSicknessMoodle`: o console do teste registrava essa opção como `true`, bloqueando o estágio solicitado.

# Náusea após 3 minutos

Aos 180 segundos, `FOOD_SICKNESS` sobe para 55, acima do limiar de Nauseous observado no código e nas opções de debug do jogo. O nível nunca é reduzido pelo mod ao entrar em proteção.

# Febre após 10 minutos

Aos 600 s, `BodyDamage:setHasACold(true)` inicia o estado de resfriado vanilla e `getColdStrength`/`setColdStrength` garantem força mínima 50, APIs usadas também pelos scripts vanilla/mods locais. Uma flag individual evita reaplicar o setter repetidamente. Isso usa doença vanilla, não temperatura corporal nem `ZOMBIE_FEVER`. A progressão visual precisa ser confirmada no jogo após o próximo teste.

# Multiplayer

A rotina vive em script `client` e opera no jogador local recebido por `OnPlayerUpdate`; o contador fica no modData individual. Não há handler em `server` nem comando cliente-servidor neste mod, então esta mudança não torna os efeitos server-authoritative. A gravação/replicação do modData e dos sintomas em servidor dedicado precisa ser validada em sessão multiplayer real.

# Arquivos alterados

- `42/media/lua/client/AirContamination_Main.lua`
- `media/lua/client/AirContamination_Main.lua` (cópia sincronizada)
- `_AIR_CONTAMINATION_BACKUP/42/media/lua/client/AirContamination_Main.lua`
- `_AIR_CONTAMINATION_BACKUP/media/lua/client/AirContamination_Main.lua`

# Funções alteradas

- `isPlayerIndoors`: fallback por sala, exterior e construção.
- `computeItemProtection`: mantém o sistema de proteção parcial e leitura de filtros existente.
- `updateBlurEffect`: passa a aplicar intoxicação real com `CharacterStat.INTOXICATION` e não limpa o efeito quando protegido.
- `updateSicknessMoodle`: define progressão monotônica por `FOOD_SICKNESS` aos 60/180 segundos.
- `applyExposureFever`: usa os setters vanilla `setHasACold`/`setColdStrength`, com flag por personagem para aplicar uma única vez.
- `onExposureInterval`: avança/regride exposição individual, conserva tosse/desgaste/dano e para o acúmulo em abrigo/proteção.

# Testes recomendados

Após corrigir, o compilador Kahlua empacotado com o jogo compilou os oito scripts da branch `42`, inclusive `AirContamination_Main.lua`; as duas cópias principais têm SHA-256 idêntico e não têm BOM. O jogo não foi iniciado novamente nesta sessão, então ainda faltam a confirmação visual dos estágios e o teste de Dedicated Server. O intervalo de 600 atualizações corresponde a cerca de 10 s a 60 FPS e varia conforme o desempenho.


