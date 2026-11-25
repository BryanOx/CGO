GAME DESIGN DOCUMENT + TECHNICAL DESIGN DOCUMENT

Versión 0.1 • 25 de noviembre de 2026 • Especificación inicial para desarrollo con agentes

## Visión del producto

Una aplicación mobile de juegos clásicos, con identidad visual consistente, partidas rápidas, juego offline y competitivo online. Conga es el primer módulo; dominó, damas, memoria y otros juegos se incorporan sin reescribir los servicios comunes.

## Principios no negociables

- Mobile primero: controles táctiles, pantallas pequeñas, interrupciones y redes inestables.

- Reglas deterministas y separadas de UI, transporte, anuncios y persistencia.

- Servidor autoritativo para resultados, monedas, inventario y rankings online.

- Cosméticos únicamente: ninguna ventaja comprable, apuesta ni conversión a dinero.

- MVP pequeño y extensible; no construir una plataforma de plugins remotos ni microservicios prematuros.

## Mapa del documento

01 Alcance • 02 Arquitectura • 03 Carpetas cliente • 04 Contratos GDScript • 05 Conga • 06 UI/UX • 07 Assets • 08 Backend • 09 Datos • 10 Multiplayer • 11 Economía • 12 Tienda • 13 Ads • 14 Seguridad • 15 QA • 16 Entrega y agentes • 17 Validación y lanzamiento

Decisiones propuestas, no código probado: revisar el repositorio de Conga y los assets antes de implementar. Las cantidades económicas son hipótesis de balance.

# 01 Alcance y producto

## MVP publicable

- Inicio como invitado, cuenta recuperable para sincronización y competitivo; selector de juegos con Conga habilitado.

- Conga offline contra bots; tutorial interactivo; partidas online casuales y privadas; ranked cuando esté validado.

- Perfil, estadísticas, leaderboard por juego, saldo, tienda, inventario y equipamiento.

- Anuncios recompensados opcionales; configuración de audio, idioma, accesibilidad y privacidad.

## Fuera del MVP

Chat libre, clanes, torneos con premios, suscripciones, intercambio de objetos, pases de temporada, múltiples juegos simultáneos en desarrollo y moneda premium. No implementar apuestas ni cajas aleatorias de pago.

## Bucle principal

Abrir → elegir juego → jugar → resultado → progreso/monedas → tienda o revancha. El modo offline funciona sin login ni anuncios; las monedas compartidas requieren conexión y validación.

## Indicadores

| Indicador         | Hipótesis inicial / medición                        |
|-------------------|-----------------------------------------------------|
| Primera partida   | Completada por ≥70% de quienes inician tutorial     |
| Retención D1 / D7 | Objetivos exploratorios 30% / 10%; cohortes reales  |
| Estabilidad       | ≥99.5% sesiones sin crash                           |
| Economía          | Medir emisión, gasto, saldo mediano y fraude        |
| PvP               | Tiempo de espera p50/p95, abandono, reconexión      |
| Ads               | Opt-in, fill, eCPM neto, retención con/sin anuncios |

No interpretar objetivos como predicciones de mercado. Medir antes de escalar adquisición.

# 02 Arquitectura y dependencias

Godot UI / GameView  
↓ comandos / snapshots  
Application: MatchSession + casos de uso  
↓ interfaces  
Domain: reglas, estado, acciones, eventos  
↑ implementaciones de puertos  
OfflineSession \| RemoteSession → REST / WS → NestJS  
↓  
PostgreSQL / Redis

## Decisiones

- Godot 4.x estable fijado en CI; GDScript tipado; renderer Compatibility inicialmente. Versionar export presets sin secretos.

- NestJS monolito modular; PostgreSQL como fuente de verdad. Redis opcional para presencia y colas; nunca saldo definitivo.

- Online: motor de reglas TypeScript autoritativo; offline: implementación GDScript equivalente. Fixtures JSON compartidas y pruebas de paridad. Reusar motor existente si pasa auditoría.

- REST para perfil, tienda y ranking; WebSocket para sesión de partida. Un protocolo versionado, DTOs validados y errores tipados.

- Inyección por constructor/configuración de dependencias; autoloads mínimos. Evitar un GameManager que concentre reglas, UI, red y economía.

## Límites

El dominio no importa escenas, servicios HTTP ni SDKs. La UI no altera el estado autoritativo. Los módulos de juegos no dependen entre sí. El backend no confía en resultados, precios ni recompensas enviados por el cliente.

# 03 Estructura de carpetas Godot

client/ \# raíz del proyecto Godot  
project.godot  
export_presets.cfg  
app/ \# bootstrap y navegación  
main.tscn  
app_context.gd  
router.gd  
core/  
domain/ \# contratos agnósticos de juego  
application/ \# sesiones y casos de uso  
ports/ \# interfaces de servicios  
infrastructure/ \# HTTP, WS, storage, SDKs  
features/  
auth/ profile/ home/ lobby/ leaderboard/  
wallet/ shop/ inventory/ settings/  
games/  
conga/  
domain/ \# estado, reglas, acciones  
application/ \# turnos, bots, sesión  
presentation/ \# escenas, vistas, animaciones  
content/ \# definiciones y recursos .tres  
tests/  
domino/ \# futuro, no scaffold vacío  
shared/  
ui/ \# controles reutilizables  
theme/ audio/ localization/  
assets/  
common/ cards/ boards/ cosmetics/ audio/ fonts/  
addons/ \# dependencias fijadas  
tests/ \# unit, integración, paridad  
tools/ \# validadores y scripts

## Convenciones

- snake_case para archivos, métodos y variables; PascalCase para class_name; UPPER_SNAKE_CASE para constantes.

- Escena y script juntos cuando son exclusivos de una vista. Resources para configuración inmutable; RefCounted para reglas; Node para lifecycle y señales; Control para UI.

- No referencias cruzadas mediante rutas absolutas a nodos ajenos. Usar señales, referencias exportadas y composición. No crear carpetas sin una responsabilidad concreta.

# 04 Clases base y contratos

Contratos conceptuales para implementar y probar; no son un SDK completo. GDScript permite bases con métodos que fallan explícitamente si no se implementan.

class_name GameRules  
extends RefCounted  
  
func create_initial_state(config: Dictionary, seed: int) -\> Dictionary:  
assert(false, "Implement create_initial_state")  
return {}  
  
func validate_action(state: Dictionary, action: Dictionary) -\> bool:  
assert(false, "Implement validate_action")  
return false  
  
func apply_action(state: Dictionary, action: Dictionary) -\> Dictionary:  
assert(false, "Implement apply_action")  
return {}  
  
func is_finished(state: Dictionary) -\> bool:  
assert(false, "Implement is_finished")  
return false

| Clase                          | Responsabilidad                                                            |
|--------------------------------|----------------------------------------------------------------------------|
| GameDefinition : Resource      | ID estable, escena, modos, versión de reglas, capacidades.                 |
| GameRegistry                   | Registro explícito de GameDefinition; sin imports dinámicos remotos.       |
| MatchSession : RefCounted      | Señales snapshot_changed, action_rejected, finished; submit_action, close. |
| LocalSession / RemoteSession   | Implementan mismo contrato; estado local o snapshot remoto filtrado.       |
| GameView : Control             | Renderizar snapshot y emitir intención; nunca otorgar monedas.             |
| BotPolicy : RefCounted         | Elegir acción legal con estado visible y dificultad.                       |
| ApiClient / RealtimeClient     | Timeout, autenticación, reconexión y serialización.                        |
| WalletService / CatalogService | Consultar servidor; caché solo de lectura.                                 |

Usar DTOs tipados en el código de producción; Dictionary aquí simplifica la especificación. No usar assert como única validación de datos externos en builds release.

# 05 Conga: primer juego

## Migración del juego actual

- Auditar reglas existentes, variantes, baraja, número de jugadores, reparto, cierre, puntuación y desempate. Congelar fixtures de partidas reales antes de modificar.

- Preservar IDs y protocolo si es seguro y compatible. Migrar cuentas/ranking solo después de definir mapping y consentimiento aplicable.

- Separar motor puro, vista de mesa y controlador de sesión. Reproducir casos de empate, cierre inválido, mazo agotado, abandono y reconexión.

## Modelo de partida

CongaState: round_id, phase, active_seat, scores,  
draw_pile, discard_pile, hands, version, deadline  
CongaAction: draw_deck \| draw_discard \| discard \| close  
CongaEvent: round_started \| card_drawn \| card_discarded \|  
round_closed \| scores_updated \| match_finished

Los nombres de acciones son provisionales; adaptar a reglas reales. El servidor genera el mazo con aleatoriedad segura y entrega a cada jugador únicamente su mano, descarte visible y cantidades públicas. No enviar mazo ni manos rivales.

## Bots y dificultad

Easy: acción legal con heurística simple; normal: maximizar combinaciones y minimizar puntos; hard: evaluar alternativas con información pública, sin conocer cartas ocultas. Modo offline sin recompensas compartidas; bots online identificados y validados por servidor si se incorporan.

## Criterio de extensión

Agregar un segundo juego debe requerir su GameDefinition, reglas, acciones, vista, bots, fixtures y módulo servidor; no modificar wallet, auth, shop ni lógica de Conga.

# 06 UI/UX mobile

## Mapa de navegación

Splash → sesión/guest → Home → detalle de juego → modo → lobby o mesa → resultado. Barra inferior: Juegos, Ranking, Tienda, Perfil. Inventario desde perfil y tienda; ajustes desde perfil.

## Sistema visual

- Base lógica 360 × 800 como referencia, escalado adaptable; orientación vertical inicialmente, sin bloquear adaptación a tablets. Respetar safe areas y teclado.

- Usar Control, containers, anchors y Theme; evitar posiciones absolutas para layout. Componentes Button, Card, Modal, CurrencyPill, ItemTile, EmptyState, Toast y LoadingState.

- Targets táctiles de aproximadamente 48 dp, contraste suficiente, opción de reducir movimiento, texto legible y feedback háptico configurable.

- Estados obligatorios: carga, vacío, error, offline, reconexión, deshabilitado, éxito. No bloquear UI mientras se descarga un catálogo.

## Mesa de juego

Información rival arriba, mesa y descarte al centro, mano propia abajo. Selección y arrastre opcional con alternativa tap. Confirmación para acciones irreversibles. Animaciones no bloquean red ni reloj del servidor; reconstruir desde snapshot al volver de background.

## Pantalla tienda

Saldo visible, filtros por juego y categoría, vista previa, precio, estado comprado/equipado, confirmación, feedback de éxito/error. Mostrar cómo obtener monedas sin exigir anuncios.

## Rendimiento

Objetivo 60 fps en dispositivos medios y 30 fps estable en gama baja. Medir frame time, RAM y tamaño de export; reducir partículas, draw calls y texturas si exceden presupuesto.

# 07 Assets y catálogo visual

## Pipeline para tus assets existentes

- Inventariar archivos originales y su licencia comercial, autor, procedencia, atribución y restricciones. No asumir licencia por poseer el archivo.

- Guardar fuentes editables fuera del export en art_source/; importar PNG/WebP/SVG según compatibilidad. Usar atlas para sprites pequeños, compresión adecuada y fuentes con licencia.

- Mantener original, versión optimizada, preview y metadata. IDs estables, no usar nombre de archivo como ID comercial. No cambiar IDs después de publicar.

- Validar dimensiones, transparencias, márgenes, escala y contraste. Para cartas: mismo tamaño lógico, índices visibles y fallback si falta textura.

assets/cosmetics/conga/decks/classic_red/  
manifest.tres  
atlas.png  
preview.webp  
attribution.txt  
assets/cosmetics/common/avatars/fox/  
manifest.tres  
icon.webp

## CosmeticDefinition : Resource

item_id, category, compatible_game_ids, slot, preview, asset_key, fallback_key. El precio y disponibilidad vienen del servidor; el Resource no es autoridad de compra.

## Distribución

MVP: todos los cosméticos empaquetados en el build y catálogo remoto de IDs conocidos. Desactivar en servidor ofertas con assets ausentes. Futuro: descarga de contenido visual firmado/verificado, sin ejecutar scripts remotos; revisar políticas antes de implementarlo.

# 08 Backend y monorepo

classic-games-online/  
client/ \# Godot  
server/ \# NestJS  
src/  
modules/  
auth/ users/ profiles/  
games/ conga/ matches/ matchmaking/  
rankings/ wallet/ catalog/ inventory/  
rewards/ ads/ purchases/  
common/ \# guards, errors, validation  
infrastructure/ \# db, redis, telemetry  
migrations/ test/  
contracts/ \# JSON Schema y fixtures  
art_source/ \# originales fuera del export  
infra/ \# Docker Compose, deploy  
docs/ \# ADR, reglas, protocolo  
.github/workflows/  
AGENTS.md

## Módulos

Cada módulo NestJS organiza domain/, application/, infrastructure/, presentation/ cuando la complejidad lo justifica. Exponer casos de uso y puertos mediante providers; no acceder al repositorio privado de otro módulo. No introducir CQRS framework ni event bus distribuido sin necesidad.

## Despliegue inicial

Un proceso API/WS, PostgreSQL persistente, proxy TLS, backup cifrado diario y restauración probada. Redis solo si la cola/presencia lo requiere. Mantener una única instancia de autoridad por partida; al escalar, asignar ownership con fencing y persistencia antes de ACK.

## Configuración

Variables de entorno validadas, .env.example sin secretos, dev/staging/prod separados, migraciones reversibles o expand/contract, logs estructurados con IDs de correlación. Los builds públicos no incluyen credenciales de administración.

# 09 Persistencia y API

| Entidad                     | Campos / restricciones principales                                                    |
|-----------------------------|---------------------------------------------------------------------------------------|
| users / identities          | id, status, provider + subject únicos; guest recuperable al vincular.                 |
| matches / match_players     | game_id, rules_version, mode, status, state_version; seat único.                      |
| match_events                | match_id + seq único; action_id único por partida/jugador.                            |
| ratings                     | user_id + game_id + season_id únicos; rating y games_count.                           |
| wallets / ledger            | user_id único; balance BIGINT \>= 0; delta, reason, source_id, idempotency_key único. |
| catalog_items               | item_id, slot, game_ids, price, active, asset_key, version.                           |
| inventory / equipped        | user_id + item_id único; slot + game_scope único por usuario.                         |
| reward_claims / ad_receipts | source_id único, estado, user_id, provider_transaction_id único.                      |
| outbox                      | event_id, type, payload, processed_at, attempts.                                      |

## API v1

POST /v1/auth/guest POST /v1/auth/link  
GET /v1/me GET /v1/games  
POST /v1/matchmaking DELETE /v1/matchmaking/:id  
POST /v1/rooms POST /v1/rooms/:code/join  
GET /v1/rankings/:game GET /v1/wallet  
GET /v1/catalog POST /v1/shop/purchases  
GET /v1/inventory PUT /v1/equipment/:slot  
POST /v1/ads/intents GET /v1/rewards/:id  
GET /v1/webhooks/admob \# SSV, verificar firma

Mutaciones financieras con clave de idempotencia, validación de ownership, transacciones y respuesta repetible. Cursor pagination para catálogos/rankings. Nunca aceptar user_id como identidad autenticada.

# 10 Multiplayer y ranking

## Protocolo de sesión

Client → join {match_id, last_seq, protocol_version}  
Server → snapshot {seq, rules_version, visible_state}  
Client → action {action_id, expected_seq, type, payload}  
Server → ack {action_id, seq} \| reject {code, current_seq}  
Server → event/snapshot {seq, visible_state}  
Client → resume {match_id, last_seq}

- Validar turno, estado, permisos, esquema, tamaño y rate limit; serializar acciones por partida; rechazar versión obsoleta y reenviar snapshot.

- Persistir estado/evento antes de confirmar; retry con el mismo action_id no aplica doble. Reconexion con backoff y jitter; token corto, renovar por HTTPS.

- Servidor fija deadlines y resultado; grace period inicial 30 s configurable. Background no detiene reloj. Definir abandono y no regalar victoria por desconexión breve.

- Matchmaking por juego, modo, región/latencia y rating; ampliar rango gradualmente. Cancelación idempotente. Salas privadas con código aleatorio y expiración.

## Ranking

Elo inicial 1200, K=32 como hipótesis para 1v1. Para Conga multijugador usar fórmula explícita de posiciones o rating multijugador validado; no aplicar Elo 1v1 directamente. Casual y privado no alteran ranked. Resultado final y rating se escriben una vez, con season_id y versión de algoritmo.

## Escalado

No habilitar ranked hasta que existan reconexión, validación autoritativa y protección contra resultados duplicados. Detectar colusión por patrones, sin sanciones automáticas irreversibles basadas solo en heurísticas.

# 11 Economía: monedas gratuitas

Moneda única: Coins (nombre provisional), enteros sin valor real. Saldo inicial 200 al crear cuenta, otorgado una sola vez. Recompensas de partidas verificadas por servidor; offline sin moneda global para evitar manipulación local.

| Fuente                 | Coins iniciales / límite                             |
|------------------------|------------------------------------------------------|
| Partida pública válida | 10 completar + 5 ganar; máximo 150/día por partidas. |
| Rewarded ad confirmado | 25 por anuncio; máximo 4/día.                        |
| Desafío diario         | 30 por objetivo verificable, una vez/día.            |
| Partida privada        | 0 inicialmente, evita farming entre cuentas.         |
| Tutorial               | 50 una vez por cuenta.                               |

## Sumideros y precios de prueba

| Cosmético          | Precio |
|--------------------|--------|
| Avatar sencillo    | 100    |
| Dorso de cartas    | 250    |
| Baraja completa    | 600    |
| Mesa temática      | 900    |
| Efecto de victoria | 1.200  |

Ejemplo: 3 partidas válidas, 1 victoria, 2 anuncios y un desafío = 115 Coins/día. Una baraja de 600 requiere aproximadamente 6 días sin contar bono inicial. Ajustar según telemetría, no forzar consumo de ads.

## Integridad financiera

Cada crédito/débito es un asiento append-only con motivo e ID de origen. Transacción bloquea wallet, verifica límite y saldo, escribe ledger y actualiza balance. No editar saldo manualmente; compensar con asiento auditado. Límites diarios UTC explícitos; UI muestra reinicio local equivalente. Reconciliar balance con suma de ledger.

# 12 Tienda, inventario y equipamiento

## Flujo de compra

UI → purchase(item_id, catalog_version, idempotency_key)  
API → valida catálogo activo y compatibilidad  
→ transacción: lock wallet, valida no adquirido  
→ debita Coins + inserta inventario + ledger  
→ commit → devuelve saldo e item adquirido  
UI → actualiza caché → permite equipar

- Precio obtenido del servidor; si cambió respecto a la versión mostrada, devolver PRICE_CHANGED y pedir nueva confirmación.

- Compras duplicadas concurrentes: constraint de inventario y clave idempotente. Una misma clave con payload diferente devuelve conflicto.

- Equipar valida propiedad y compatibilidad. Slots globales (avatar, marco) y por juego (baraja, mesa, fichas). Fallback estándar siempre disponible.

- No borrar inventario adquirido al retirar una oferta. Mantener un asset fallback y política de migración. Sin reventa, regalos ni loot boxes en MVP.

## Clases cliente

ShopViewModel consulta catálogo y billetera, InventoryViewModel consulta propiedad, EquipmentService solicita equipar. CatalogItemDTO contiene precio/versión; CosmeticDefinition resuelve visuales locales. ShopTile y PreviewPanel solo presentan datos.

## Compras reales futuras

Preparar PurchaseProvider como puerto, sin integrar billing en MVP. Si se activa, verificar recibos en servidor, restaurar compras, deduplicar transacciones y manejar reembolsos. No vincular dinero real con resultados competitivos. Revisar políticas de tiendas antes de activar pagos.

# 13 Anuncios y monetización

## Rewarded ads: flujo autoritativo

- Cliente solicita intent autenticado; servidor reserva cupo temporal con nonce opaco y expiración. SDK muestra anuncio con datos personalizados asociados al intent.

- Callback local solo actualiza UI a pendiente. Backend recibe callback SSV del proveedor, verifica firma sobre datos originales con claves oficiales, identidad del anuncio, intent y transaction_id.

- Dentro de una transacción deduplicar receipt, validar intent y cupo, otorgar Coins y registrar ledger. Si llega tarde dentro de política de tolerancia, procesar una vez; si expiró definitivamente, registrar revisión.

- Cliente consulta estado o recibe evento de saldo actualizado. Nunca otorgar monedas por cerrar un anuncio ni por callback cliente aislado.

## AdProvider y ConsentService

Interfaz show_rewarded(intent), is_ready(), cancel/close lifecycle. Implementaciones Android/iOS y FakeAdProvider solo para dev/test. Cargar bajo demanda; manejar no fill, timeout y background. Sin recompensas falsas en producción.

## Interstitials

Desactivados en primera beta; experimentar luego con máximo uno cada 3 partidas y cooldown de 180 s, nunca durante partida ni al abrir la app. Rewarded siempre voluntario. Mostrar importe antes de ver el anuncio.

## Privacidad y compliance

Consentimiento según región/edad, datos mínimos, no publicidad personalizada para menores cuando corresponda; revisar SDK, formularios de datos y políticas vigentes. No se ha validado todavía un plugin Godot concreto; seleccionar uno mantenido y probar SSV en dispositivo real.

# 14 Seguridad y operaciones

- Auth: access token corto, refresh rotativo, revocación, almacenamiento seguro mediante Keychain/Keystore; invitado no equivale a identidad confiable para economía.

- Validar DTOs por allowlist, payloads y frecuencias; autorización por recurso; TLS; secretos solo servidor; no usar IDs públicos como permisos.

- Anti-cheat: RNG seguro servidor, estado oculto filtrado, reloj servidor, no confiar en score ni balance cliente. No incluir API keys privadas en assets.

- Economía: idempotencia, locks/constraints, reconciliación, límites y auditoría. Pruebas concurrentes con base real.

- Privacidad: telemetría sin manos privadas, tokens ni datos sensibles; eliminación de cuenta y política de retención; soporte para exportar datos cuando corresponda.

- Operaciones: health/readiness, alertas de errores y latencia, backups, restore, rollback, feature flags para ranked/ads y kill switch del catálogo.

## Amenazas prioritarias

| Amenaza                  | Control                                 |
|--------------------------|-----------------------------------------|
| Replay de acción         | ID único, secuencia, ACK persistido     |
| Falsificación de anuncio | SSV firmado y transacción única         |
| Compra doble             | Lock wallet y constraint inventario     |
| Lectura de mano rival    | Proyección de snapshot por jugador      |
| Farming / bots           | Cupos, validación, revisión de patrones |
| Robo de cuenta           | Tokens revocables y linking seguro      |

No declarar el producto seguro hasta completar tests de integración, revisión de dependencias y smoke tests reales.

# 15 Testing y calidad

| Nivel               | Casos mínimos                                                                         |
|---------------------|---------------------------------------------------------------------------------------|
| Dominio             | Acciones legales/ilegales, invariantes, terminación, scoring, seeds y variantes.      |
| Paridad             | Fixtures ejecutadas en GDScript y TS, mismos resultados para entradas deterministas.  |
| Backend integración | PostgreSQL real: saldo, compra concurrente, retry, rollback, inventario, ranking.     |
| Multiplayer         | Desconexión, replay, seq obsoleta, dos acciones, reinicio, privacidad de snapshot.    |
| Publicidad          | Firma válida/inválida, duplicados, expiración, no fill, callback tardío.              |
| Mobile              | Safe areas, rotación si habilitada, background, redes lentas, memoria, accesibilidad. |
| E2E                 | Guest → tutorial → partida → recompensa → comprar → equipar → reiniciar.              |

## CI obligatoria

Servidor: lint, typecheck, unit, integración con DB, build, migraciones. Cliente: Godot headless import y tests GUT o harness fijado, validar recursos y fixtures, export Android debug. iOS requiere runner macOS y firma configurada. Secretos de release fuera de PRs no confiables.

## Definition of Done

- Criterios de aceptación cubiertos por tests; sin regresiones ni warnings nuevos relevantes.

- Logs útiles, manejo de errores, loading/offline, recursos liberados, documentación de contrato actualizada.

- PR pequeño, revisado, CI verde; evidencia de prueba en dispositivo para cambios de UX, SDKs o rendimiento.

# 16 Roadmap y agentes

| Fase               | Entregable / puerta de salida                                                   |
|--------------------|---------------------------------------------------------------------------------|
| 0 — Auditoría      | Inventario de repos, reglas Conga, assets y licencias; ADRs; fixtures baseline. |
| 1 — Fundación      | Monorepo, CI, navegación, tema, GameRegistry, contratos, mocks.                 |
| 2 — Vertical slice | Conga offline completo, bots y tutorial; pruebas de reglas.                     |
| 3 — Backend        | Auth, persistencia, WS, salas, reconexión, paridad; smoke PvP.                  |
| 4 — Economía       | Ledger, tienda, inventario, equipamiento, tests concurrentes.                   |
| 5 — Ads            | Consentimiento, SSV, rewarded real en staging, kill switch.                     |
| 6 — Beta           | Ranked validado, telemetría, QA dispositivos, publicación controlada.           |
| 7 — Expansión      | Segundo juego (dominó o memoria) para verificar modularidad.                    |

## División de agentes

Arquitectura define contratos y ADRs; cliente/core implementa shell y sesiones; gameplay migra Conga; backend implementa autoridad; economía/ads implementa ledger y SSV; QA escribe fixtures y pruebas adversariales. Cada agente tiene ownership por carpeta; cambios de contratos requieren PR coordinado.

## Reglas AGENTS.md

- Leer este documento y ADRs antes de tocar código. No inventar reglas de Conga ni APIs de SDKs.

- No mezclar refactors masivos con features. No modificar contratos sin fixtures y consumidores actualizados.

- Entregar código funcional, tests, comandos reproducibles, riesgos y decisiones. Nunca afirmar CI verde sin evidencia.

# 17 Validación y lanzamiento

## Primer sprint: orden exacto

- 1\. Auditar repositorio Conga y assets; documentar reglas y licencias pendientes.

- 2\. Crear monorepo y fijar versiones de Godot, Node, dependencias y CI.

- 3\. Implementar GameDefinition, GameRegistry, GameRules, MatchSession y fake backend.

- 4\. Crear Theme, navegación, pantalla Home y mesa Conga con assets reales.

- 5\. Portar reglas y fixtures; ejecutar una partida offline completa antes de empezar tienda o red.

- 6\. Implementar backend y probar PvP. Después economía, anuncios y ranked según gates.

## Validaciones externas pendientes

Confirmar compatibilidad del SDK de anuncios con Godot y versiones Android/iOS, licencias de assets, requisitos de firma, privacidad, billing y publicación. No se auditaron los repositorios ni los assets en esta especificación.

## Referencias técnicas para implementación

Godot: https://docs.godotengine.org/en/stable/  
NestJS: https://docs.nestjs.com/  
PostgreSQL: https://www.postgresql.org/docs/  
AdMob SSV: https://developers.google.com/admob/android/ssv  
Google Play: https://play.google.com/about/developer-content-policy/  
Apple: https://developer.apple.com/app-store/review/guidelines/

## Criterio de lanzamiento

Una partida divertida y estable es más importante que diez juegos incompletos. Publicar beta con Conga, medir retención y economía, ajustar recompensas y recién entonces invertir en más contenido. Mantener el producto independiente de la disponibilidad de rivales conectados.
